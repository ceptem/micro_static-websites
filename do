#!/bin/sh

set -e

NAMESPACE=${NAMESPACE-ceptem}
CATEGORY=${CATEGORY-micro}
REPOSITORY=${REPOSITORY-static-websites}
VERSION=${VERSION-1.0.0}

IMAGE=${NAMESPACE}/${CATEGORY}_${REPOSITORY}:${VERSION}

DOCKER_BUILD=${DOCKER_BUILD-docker build}

sources_list=sources.list

THIS_NAME=`basename "$0"`

usage() {
    printf "Usage : %s [-c] build (default)\n"  "$THIS_NAME"
    printf "        %s [-c] collect\n"          "$THIS_NAME"
    printf "        %s [-c] configure\n"        "$THIS_NAME"
    printf "        %s -h\n"                    "$THIS_NAME"
    printf "        %s -V\n"                    "$THIS_NAME"
    printf "\n"
    printf "    -c  sources_list\n"
    printf "        Path to the sources definition file (default\n"
    printf "        ./sources_list).\n"
    printf "\n"
    printf "build:\n"
    printf "        Collects then configures\n"
    printf "collect:\n"
    printf "        Collects sources described in sources_list.\n"
    printf "configure:\n"
    printf "        Generate NGinX configuration files for collected\n"
    printf "        sources.\n"
}

log() {
    if [ -t 1 ]; then
        printf "\e[1;35m • \e[1;36m%s\e[0m\n" "$1"
    else
        printf " • %s\n" "$1"
    fi
}

cmdl_args=`getopt hVc: $*`
# you should not use `getopt ... "$@"` since that would parse
# the arguments differently from what the set command below does.
if [ $? != 0 ]; then
    usage
    exit 2
fi
set -- $cmdl_args

# You cannot use the set command with a backquoted getopt directly,
# since the exit code from getopt would be shadowed by those of set,
# which is zero by definition.
for i; do
    case "$i" in
    -h)
        usage
        exit 0
        ;;
    -V)
        printf "$THIS_NAME version $VERSION\n"
        exit 0
        ;;
    -c)
        sources_list="$2"
        shift
        shift
        ;;
    --)
        shift
        break
        ;;
    esac
done

# Reasonably test we're in the right directory
test -d conf/conf.d
test -f Dockerfile
test -f libexec/collect
test -f libexec/configure

case "$1" in
build)
    log "Building Docker image"
    ${DOCKER_BUILD} -t "$IMAGE" $DOCKER_BUILD_FLAGS .
    ;;
collect)
    log "Collecting sources"
    libexec/collect "$sources_list"
    ;;
configure)
    log "Generating NGinX configuration files"
    libexec/configure "$sources_list"
    ;;
"")
    "$0" collect
    "$0" configure
    "$0" build
    ;;
*)
    usage
    exit 1
    ;;
esac
