#!/usr/bin/env bash
# Copy directory structure from src to dst.

# Example1: copy structure of `root` to `newdir`

#     dirstruct.sh copy root newdir

#     root
#     ├── .foo
#     ├── dir1
#     │   ├── subdir1
#     │   └── subdir2
#     └── dir2

#     newdir
#     └── root
#         ├── .foo
#         ├── dir1
#         │   ├── subdir1
#         │   └── subdir2
#         └── dir2

#     dirstruct.sh copy root newdir -i
#     * hidden directories will be ignored

#     newdir
#     └── root
#         ├── dir1
#         │   ├── subdir1
#         │   └── subdir2
#         └── dir2

# Example2: save structure of directory `root` into file `root.tree`

#     dirstruct.sh tree root

#     cat root.tree
#     root
#     root/.foo
#     root/dir2
#     root/dir1
#     root/dir1/subdir2
#     root/dir1/subdir1

#     Similarly，you can ignore hidden directories by using `-i` flag

function parse_args() {
    IGNORE_HIDDEN="no"
    POSITIONAL=()

    while [[ $# -gt 0 ]]; do
        key="$1"

        case $key in
        -i | --ignore-hidden)
            IGNORE_HIDDEN="yes"
            shift
            ;;
        *)
            POSITIONAL+=("${1}")
            shift
            ;;
        esac
    done

    set -- "${POSITIONAL[@]}"
    SUB_CMD=${1-}
    SRC=${2-}
    DST=${3-}
}

function usage_exit() {
    cat <<EOF
Usage: $0 <copy|tree> <src> [dst] [OPTIONS]

copy:
    Copy directory structure from src to dst.
    src    An existing directory or a file contains structure of directory
    dst    Base directory of src's copy, defaults to current directory

tree:
    Save structure of target directory into a file.
    src    An existing directory

OPTIONS:
    -i, --ignore-hidden    Igonre hidden directories
EOF
    echo
    for message; do
        echo "${message}"
    done
    exit 1
}

function ds_find() {
    if [[ "${2}" == "no" ]]; then
        find "${1}" -type d
    else
        find "${1}" -not -path '*/\.*' -type d
    fi
}

function ds_get_tree() {
    ABS_PATH="$(cd "$(dirname "${1}")" && pwd)"
    DIRS=$(cd "${ABS_PATH}" && ds_find "$(basename "${1}")" "${IGNORE_HIDDEN}")
}

function ds_tree() {
    ds_get_tree "${SRC}"
    printf "%s\n" "${DIRS[*]}" >"$(basename "${SRC}").tree"
}

function ds_copy() {
    [ -z "${DST}" ] || DST+="/"

    if [ -f "${SRC}" ]; then
        while IFS= read -r line; do
            mkdir -p "${DST}${line}"
        done <"${SRC}"
    elif [ -d "${SRC}" ]; then
        ds_get_tree "${SRC}"
        for dir in ${DIRS[*]}; do
            mkdir -p "${DST}${dir}"
        done
    else
        usage_exit "error: invalid src \"${SRC}\"" \
            "must be an existing directory or a file contains structure of directory"
    fi
}

parse_args "$@"

if [ -z "${SRC}" ] || [ -z "${SUB_CMD}" ]; then
    usage_exit
fi

case "${SUB_CMD}" in
copy)
    ds_copy "${SRC}" "${DST}"
    ;;
tree)
    ds_tree "${SRC}"
    ;;
*)
    usage_exit "error: invalid subcommand \"${SUB_CMD}\""
    ;;
esac
