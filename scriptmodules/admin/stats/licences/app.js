async function fetch_packages() {
	const resp = await fetch('../packages.csv');
	const data = await resp.text();

	return data
		.split('\n')
		.map(line => line.split(';'))
		.filter(fields => fields.length >= 4)
		.map(fields => ({
			section: fields[0],
			id: fields[1],
			desc: fields[2],
			licence: fields[3],
		}));
}

async function fetch_commit_info() {
	const resp = await fetch('../commit.csv');
	const data = await resp.text();
	const fields = data.split(';');
	return {
		sha: fields[0] || '',
		when: fields[1] || '',
		branch: fields[2] || '',
	};
}

function create_commit_info(commit) {
	const date = commit.when.slice(0, 10);
	const time = commit.when.slice(11, 16);
	const text = `Last update: ${date} ${time}, <code>${commit.branch}</code> branch at <code>${commit.sha}</code>`;
	document.getElementById('commit').innerHTML = text;
}

function get_pkg_licence_name(pkg) {
	return pkg.licence
		? pkg.licence.split(' ', 1)[0]
		: 'Unknown';
}

function get_pkg_licence_link(pkg) {
	if (pkg.licence) {
		const url = pkg.licence.split(' ', 2)[1];
		if (url) {
			const anchor = document.createElement('a');
			anchor.href = url;
			anchor.target = '_blank';
			anchor.innerText = 'link';
			return anchor.outerHTML;
		}
	}
	return null;
}

const CATEGORIES = [
	'copyleft',
	'permissive',
	'nonfree',
	'other',
	'unknown',
];
const CATEGORY_COLORS = {
	unknown: '#555',
	copyleft: '#d11',
	permissive: '#1d1',
	nonfree: '#fc0',
	other: '#aaa',
};

function categorize_licence(licence) {
	if (licence == 'Unknown')
		return 'unknown';

	if (/^L?GPL/.test(licence) || /^MPL/.test(licence))
		return 'copyleft';

	if (['ZLIB', 'MIT', 'BSD'].includes(licence))
		return 'permissive';

	if (['PROP', 'NONCOM'].includes(licence))
		return 'nonfree';

	return 'other';
}

function create_pie(packages) {
	const counts = new Map();
	packages
		.map(get_pkg_licence_name)
		.map(categorize_licence)
		.forEach(lic => counts.set(lic, (counts.get(lic) || 0) + 1));

	const categories = CATEGORIES.filter(cat => counts.has(cat));
	const canvas = document.getElementById('pie');
	const chart = new Chart(canvas, {
		type: 'doughnut',
		data: {
			labels: CATEGORIES,
			datasets: [{
				data: categories.map(cat => counts.get(cat)),
				backgroundColor: categories.map(cat => CATEGORY_COLORS[cat]),
			}],
		},
		options: {
			legend: {
				position: 'bottom',
			},
		},
	});
}

function append_cell(parent, html) {
	const cell = document.createElement('td');
	cell.innerHTML = html;
	parent.appendChild(cell);
}

function create_section_row(type, cell_htmls) {
	const row = document.createElement(type);
	cell_htmls.forEach(str => append_cell(row, str))
	return row;
}

function create_package_tables(packages) {
	const pkg_licences = new Map();
	packages.forEach(pkg => {
		const licence = get_pkg_licence_name(pkg);
		const packages = pkg_licences.get(licence) || [];
		packages.push(pkg);
		pkg_licences.set(licence, packages);
	});

	const fragment = new DocumentFragment();

	const licence_names = [...pkg_licences.keys()].sort();
	licence_names.forEach(lic => {
		const lic_category = categorize_licence(lic);
		const lic_color = CATEGORY_COLORS[lic_category];

		const container = document.createElement('section');
		container.style.backgroundColor = lic_color + '2';

		const title = document.createElement('h3');
		title.innerText = lic;
		container.appendChild(title);

		const table = document.createElement('table');
		const thead = create_section_row('thead', ['Package', 'Description', 'Section', 'Licence']);
		table.appendChild(thead);

		pkg_licences
			.get(lic)
			.sort((a, b) => a.id.localeCompare(b.id))
			.map(pkg => [
				pkg.id,
				pkg.desc,
				pkg.section || '&mdash;',
				get_pkg_licence_link(pkg) || '&mdash;',
			])
			.map(fields => create_section_row('tr', fields))
			.forEach(row => table.appendChild(row));

		container.appendChild(table);
		fragment.appendChild(container);
	});

	document.getElementById('packages').appendChild(fragment);
}

window.onload = async () => {
	const packages = await fetch_packages();
	const commit = await fetch_commit_info();
	create_pie(packages);
	create_commit_info(commit);
	create_package_tables(packages);
};
