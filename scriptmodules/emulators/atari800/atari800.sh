#!/bin/bash

emulator="./EMULATOR"
rom="$1"
shift
params=("$@")

pushd "${0%/*}" >/dev/null

if [[ -z "$rom" ]]; then
    "$emulator" "${params[@]}"
else
    source "../../lib/archivefuncs.sh"

    archiveExtract "$rom" ".a52 .atr .bas .bin .car .dcm .xex .xfd"

    # check successful extraction and if we have at least one file
    if [[ $? == 0 ]]; then
        rom="${arch_files[0]}"
    fi

    "$emulator" "$rom" "${params[@]}"
    archiveCleanup
fi

popd
