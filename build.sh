#!/bin/bash -ex

function usage () {
    cat >&2 <<EOF
usage:
    build.sh <command>

    commands:
        container       INTERNAL use inside container build
        host            run the build script
        props <file>    extract version and architecture properties
                        from package file name
EOF
    exit 1
}

function main () {
    WORKDIR=$PWD
    cd "$(dirname "$0")"
    trap cleanup EXIT

    command=$1
    shift
    case "$command" in
        host)       host ;;
        container)  container ;;
        props)      props "$@" ;;
        *)
            echo "error: invalid command: $command" >&2
            usage
            ;;
    esac
}

function cleanup () {
    cd "$WORKDIR"
}

function host () {
    docker build -t open-lens-build -f Build.dockerfile .
    docker run --rm -v "$PWD/out:/out" open-lens-build container
}

function container () {
    npm run build:app -- -- --linux AppImage --x64
    cp open-lens/dist/OpenLens-* /out/
}

function props () {
    local file name

    if (( $# != 1 )) ; then
        echo "error: too many arguments: $*" >&2
        usage
    fi

    file=$1

    name=${file##*/}
    pattern='^OpenLens-(.+)\.([^.]+)\..*$'
    vers=$(sed -r "s/$pattern/\1/" <<< "$name")
    arch=$(sed -r "s/$pattern/\2/" <<< "$name")

    echo "VERS=$vers"
    echo "ARCH=$arch"
}

if [[ $0 == "${BASH_SOURCE[0]}" ]] ; then
    main "$@"
fi
