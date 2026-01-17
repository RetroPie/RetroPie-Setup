#!/bin/bash
is_amiberry=0

emulator="./uae4arm"
[[ "$is_amiberry" -eq 1 ]] && emulator="./amiberry"

pushd "${0%/*}" >/dev/null
source "../../lib/archivefuncs.sh"

params=()

arg="$1"

if [[ "$arg" == *.uae ]]; then
    config="$arg"
else
    rom="$arg"
fi
shift

images=()

if [[ "$is_amiberry" -eq 1 ]] && [[ "$rom" == *.lha || "$rom" == *.cue || "$rom" == *.chd ]]; then
    params+=(--autoload "$rom")
elif [[ -n "$rom" ]]; then
    # check successful extraction and if we have at least one file
    if archiveExtract "$rom" ".adf .adz .dms .ipf"; then
        for i in {0..3}; do
            [[ -n "${arch_files[$i]}" ]] && images+=(-$i "${arch_files[$i]}")
        done
        name="${arch_files[0]}"
    elif [[ -n "$rom" ]]; then
        name="$rom"
        # try and find the disk series
        base="${name##*/}"
        base="${base%Disk*}"
        i=0
        while read -r disk; do
            images+=(-$i "$disk")
            ((i++))
            [[ "$i" -eq 4 ]] && break
        done < <(find "${rom%/*}" -iname "$base*" | sort)
        [[ "${#images[@]}" -eq 0 ]] && images=(-0 "$rom")
    fi

    rom_path="${rom%/*}"
    rom_name="${rom##*/}"
    rom_bn="${rom_name%.*}"

    # check for .uae files with the same base name as the adf/zip in the rom directory and conf
    if [[ -f "$rom_path/$rom_bn.uae" ]]; then
        config="$rom_path/$rom_bn.uae"
    elif [[ -f "conf/$rom_bn.uae" ]]; then
        config="conf/$rom_bn.uae"
    # if no config / model parameters are included in the arguments choose a config/model automatically
    elif [[ "$*" != *-config* && "$*" != *--model* ]]; then
        # if amiberry choose a model for amiberry based on the rom filename
        if [[ "$is_amiberry" -eq 1 ]]; then
            model="A500"
            case "$name" in
                *ECS*)
                    model="A500P"
                    ;;
                *AGA*)
                    model="A1200"
                    ;;
                *CD32*)
                    model="CD32"
                    ;;
                *CDTV*)
                    model="CDTV"
                    ;;
            esac
            params+=(--model "$model")
        else
            # or for uae4arm choose an Amiga config based on the rom filename
            if [[ "$name" =~ AGA|CD32 ]]; then
                config="conf/rp-a1200.uae"
            else
                config="conf/rp-a500.uae"
            fi
        fi
    fi
fi

# if there is a config set then use it
if [[ -n "$config" ]]; then
    if [[ "$is_amiberry" -eq 1 ]]; then
        params+=(--config "$config")
    else
        params+=(-config="$config")
    fi
fi

# add any other provided arguments
params+=("$@")

# add images to parameters (needs to be after any config arguments)
params+=("${images[@]}")

# start directly into emulation if the first argument is set
[[ -n "$arg" ]] && params+=(-G)

echo "Launching ..."
echo "$emulator" "${params[@]}"

"$emulator" "${params[@]}"
archiveCleanup

popd
