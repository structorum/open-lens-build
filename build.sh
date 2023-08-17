#!/bin/bash -ex

function usage () {
    cat >&2 <<EOF
usage:
    build.sh <command>

    commands:
        host        run the build script
        container   INTERNAL use inside container build
EOF
    exit 1
}

function main () {
    WORKDIR=$PWD
    cd "$(dirname "$0")"
    trap cleanup EXIT

    command=$1
    case "$command" in
        host)       host ;;
        container)  container ;;
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
    npm run build:app -- -- --linux AppImage
    cp -r open-lens/dist/OpenLens-* /out/
}

if [[ $0 == "${BASH_SOURCE[0]}" ]] ; then
    main "$@"
fi
