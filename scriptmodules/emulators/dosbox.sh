rp_module_id="dosbox"
rp_module_desc="DOS emulator"
rp_module_menus="2+"
rp_module_flags="dispmanx"

function depends_dosbox() {
    checkNeededPackages libsdl1.2-dev libsdl-net1.2-dev libsdl-sound1.2-dev libasound2-dev libpng12-dev automake autoconf zlib1g-dev
}

function sources_dosbox() {
    wget -O- -q http://downloads.petrockblock.com/retropiearchives/dosbox-r3876.tar.gz | tar -xvz --strip-components=1
}

function build_dosbox() {
    ./autogen.sh
    ./configure --prefix="$md_inst" --disable-opengl
    # enable dynamic recompilation for armv4
    sed -i 's|/\* #undef C_DYNREC \*/|#define C_DYNREC 1|' config.h
    sed -i 's/C_TARGETCPU.*/C_TARGETCPU ARMV4LE/g' config.h
    make clean
    make
    md_ret_require="$md_build/src/dosbox"
}

function install_dosbox() {
    make install
    md_ret_require="$md_inst/bin/dosbox"
}

function configure_dosbox() {
    mkRomDir "pc"

    cat > "$romdir/pc/Start DOSBox.sh" << _EOF_
#!/bin/bash
$rootdir/supplementary/runcommand/runcommand.sh 1 "$md_inst/bin/dosbox -c \"MOUNT C $romdir/pc\"" "$md_id"
_EOF_
    chmod +x "$romdir/pc/Start DOSBox.sh"

    local config_path=$(su "$user" -c "\"$md_inst/bin/dosbox\" -printconf")
    if [ -f "$config_path" ]; then
        iniConfig "=" "" "$config_path"
        iniSet "usescancodes" "false"
        iniSet "core" "dynamic"
        iniSet "cycles" "max"
    fi

    configure_dispmanx_off_dosbox

    setESSystem "PC (x86)" "pc" "~/RetroPie/roms/pc" ".sh" "$rootdir/supplementary/runcommand/runcommand.sh 0 \"%ROM%\" \"$md_id\"" "pc" "pc"
}

function configure_dispmanx_off_dosbox() {
    local config_path=$(su "$user" -c "\"$md_inst/bin/dosbox\" -printconf")
    if [ -f "$config_path" ]; then
        iniConfig "=" "" "$config_path"
        # scaling
        iniSet "scaler" "normal2x"
    fi
}

function configure_dispmanx_on_dosbox() {
    local config_path=$(su "$user" -c "\"$md_inst/bin/dosbox\" -printconf")
    if [ -f "$config_path" ]; then
        iniConfig "=" "" "$config_path"
        # no scaling
        iniSet "scaler" "none"
    fi
}