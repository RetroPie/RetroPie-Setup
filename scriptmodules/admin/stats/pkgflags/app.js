async function fetch_packages() {
	const resp = await fetch('../packages.csv');
	const data = await resp.text();

	return data
		.split('\n')
		.map(line => line.split(';'))
		.filter(fields => fields.length >= 5)
		.map(fields => ({
			section: fields[0],
			id: fields[1],
			desc: fields[2],
			// fields[3] is the licence
			flags: fields[4].split(' '),
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

function create_device_bars(packages) {
	const devices = [{
			name: 'Raspberry Pi 0/1',
			flags: ['videocore', 'arm', 'armv6'],
			hover: 'VideoCore + ARMv6',
		}, {
			name: 'Raspberry Pi 2',
			flags: ['videocore', 'arm', 'armv7'],
			hover: 'VideoCore + ARMv7',
		},{
			name: 'Raspberry Pi 3',
			flags: ['videocore', 'arm', 'armv8'],
			hover: 'VideoCore + ARMv8',
		}, {
			name: 'Raspberry Pi 4',
			flags: ['kms', 'arm', 'armv8'],
			hover: 'DRM/KMS + ARMv8',
		}, {
			name: 'Odroid C1/XU3/XU4',
			flags: ['mali', 'arm', 'armv7'],
			hover: 'Mali + ARMv7',
		}, {
			name: 'Odroid C2',
			flags: ['mali', 'aarch64'],
			hover: 'Mali + AArch64',
		}, {
			name: 'Desktop Linux',
			flags: ['x11', 'x86'],
			hover: 'X11 + x86',
		},
	];

	const ui_holder = document.createElement('ul');
	devices
		.map(device => {
			const label = document.createElement('span');
			label.innerText = device.name;

			const bar = document.createElement('progress');
			bar.max = packages.length;
			bar.value = packages
				.filter(pkg => device.flags.every(flag => !pkg.flags.includes('!' + flag)))
				.length;
			bar.title = `${device.hover}\n${bar.value} / ${bar.max}`;

			const percent = document.createElement('span');
			percent.innerText = Math.round(100 * bar.value / bar.max) + '%';

			const row = document.createElement('li');
			row.appendChild(label);
			row.appendChild(bar);
			row.appendChild(percent);
			return row;
		})
		.forEach(row => ui_holder.appendChild(row));

	document.getElementById('devices').appendChild(ui_holder);
}

function create_commit_info(commit) {
	const date = commit.when.slice(0, 10);
	const time = commit.when.slice(11, 16);
	const text = `Last update: ${date} ${time}, <code>${commit.branch}</code> branch at <code>${commit.sha}</code>`;
	document.getElementById('commit').innerHTML = text;
}

function package_enabled_for(pkg, flag) {
	const video_flag_synonyms = {
		'videocore' : [ 'arm', 'rpi', 'rpi1', 'rpi2', 'rpi3', 'dispmanx', 'gles' ],
		'mali'     : [ 'arm' , 'gles' ],
		'kms'      : [ 'arm' , 'rpi', 'rpi4', 'dispmanx', 'mesa' , 'gles3' ],
		'x11'      : [ 'x86' , '64bit', 'mesa' ]
	};

	var equivs = (video_flag_synonyms[flag] ? [flag].concat(video_flag_synonyms[flag]) : [flag]);

	if ( pkg.flags.includes('!all') ) {
		return _flags_include(pkg.flags, equivs) && !_flags_exclude(pkg.flags, equivs);
	} else {
		return !_flags_exclude(pkg.flags, equivs);
	}

}

function _flags_include(pkg_flags, flags) {
	return flags.reduce( (acc, flag) => acc || pkg_flags.includes(flag), false);
}

function _flags_exclude(pkg_flags, flags) {
	return flags.reduce( (acc, flag) => acc || pkg_flags.includes('!' + flag), false);
}

function append_pkg_text_cell(parent, klass, text) {
	const cell = document.createElement('td');
	cell.innerText = text;
	if (Array.isArray(klass))
		klass.forEach(k => cell.classList.add(k));
	else
		cell.classList.add(klass);
	parent.appendChild(cell);
}

function append_pkg_flag_cell(parent, klass, is_pass) {
	const cell = document.createElement('td');
	cell.innerText = is_pass ? '\u2713' : '\u2717';
	cell.classList.add('flag', klass, is_pass ? 'pass' : 'fail');
	parent.appendChild(cell);
}

function create_section_thead() {
	const thead = document.createElement('thead');
	append_pkg_text_cell(thead, 'id', 'Package');
	append_pkg_text_cell(thead, 'desc', 'Description');
	append_pkg_text_cell(thead, ['flag', 'video'], 'VideoCore');
	append_pkg_text_cell(thead, ['flag', 'video'], 'Mali');
	append_pkg_text_cell(thead, ['flag', 'video'], 'DRM/KMS');
	append_pkg_text_cell(thead, ['flag', 'video'], 'X11');
	append_pkg_text_cell(thead, ['flag', 'cpu'], 'ARMv6');
	append_pkg_text_cell(thead, ['flag', 'cpu'], 'ARMv7');
	append_pkg_text_cell(thead, ['flag', 'cpu'], 'ARMv8 (32 bit)');
	append_pkg_text_cell(thead, ['flag', 'cpu'], 'AArch64');
	append_pkg_text_cell(thead, ['flag', 'cpu'], 'x86');
	thead.querySelector('.flag.video').classList.add('first');
	thead.querySelector('.flag.cpu').classList.add('first');
	return thead;
}

function create_section_row(pkg) {
	const row = document.createElement('tr');
	row.title='Script flags: ' + pkg.flags.join(' ');
	append_pkg_text_cell(row, 'id', pkg.id);
	append_pkg_text_cell(row, 'desc', pkg.desc);
	append_pkg_flag_cell(row, 'video', package_enabled_for(pkg, 'videocore'));
	append_pkg_flag_cell(row, 'video', package_enabled_for(pkg, 'mali'));
	append_pkg_flag_cell(row, 'video', package_enabled_for(pkg, 'kms'));
	append_pkg_flag_cell(row, 'video', package_enabled_for(pkg, 'x11'));
	append_pkg_flag_cell(row, 'cpu', !pkg.flags.includes('!arm') && !pkg.flags.includes('!armv6'));
	append_pkg_flag_cell(row, 'cpu', !pkg.flags.includes('!arm') && !pkg.flags.includes('!armv7'));
	append_pkg_flag_cell(row, 'cpu', !pkg.flags.includes('!arm') && !pkg.flags.includes('!armv8'));
	append_pkg_flag_cell(row, 'cpu', !pkg.flags.includes('!aarch64'));
	append_pkg_flag_cell(row, 'cpu', !pkg.flags.includes('!x86'));
	row.querySelector('.flag.video').classList.add('first');
	row.querySelector('.flag.cpu').classList.add('first');
	return row;
}

function create_package_sections(packages) {
	const section_ids = [
		'core',
		'main',
		'opt',
		'exp',
		'driver',
		'config',
		'',
	];
	const section_names = {
		opt: 'optional',
		exp: 'experimental',
		config: 'configuration',
		'': 'other',
	};
	const sections = [];
	section_ids.forEach(id => sections[id] = []);

	packages.forEach(pkg => {
		const section = sections[pkg.section] || sections[''];
		section.push(pkg);
	});


	const fragment = new DocumentFragment();
	section_ids
		.filter(id => sections[id])
		.forEach(id => {
			const ui_container = document.createElement('section');

			const ui_title = document.createElement('h2');
			ui_title.innerText = section_names[id] || id;
			ui_container.appendChild(ui_title);

			const ui_table = document.createElement('table');
			ui_table.appendChild(create_section_thead());
			sections[id]
				.sort((a, b) => a.id.localeCompare(b.id))
				.map(pkg => create_section_row(pkg))
				.forEach(row => ui_table.appendChild(row));
			ui_container.appendChild(ui_table);

			fragment.appendChild(ui_container);
		});
	document.getElementById('packages').appendChild(fragment);


	document.querySelector('table .flag.video').classList.add('first');
	document.querySelector('table .flag.cpu').classList.add('first');
}

window.onload = async () => {
	const packages = await fetch_packages();
	const commit = await fetch_commit_info();
	create_device_bars(packages);
	create_commit_info(commit);
	create_package_sections(packages);
};
