#!/bin/bash

set -e

PROGNAME=$(basename $0)
CWD=$(pwd)

die() {
    echo "$PROGNAME: $*" >&2
    exit 1
}

mapping() {
    echo "generating default-mapping.ttl"
    /work/d2rq/generate-mapping -u ${U} -p ${P} ${JDBC} > default-mapping.ttl
}

transform() {
    echo "transform sql to transformation.ttl"
    /work/d2rq/dump-rdf -f TURTLE ${MF} > transformation.ttl
}

enrich() {
    echo "enrich rdf data saving to transformation.enriched.ttl"
    java -jar /work/enrichment/enrichment.jar --enrichment.inputFile=${RF} --enrichment.outputFile=/data/transformation.enriched.ttl
}

usage() {
    if [ "$*" != "" ] ; then
        echo "Error: $*"
    fi

    cat << EOF
Usage: $PROGNAME

Options:
--mapping --user <user> --pass <pass> --jdbc <jdbcString>
--transform --mapping-file <mapp.ttl>
--enrich --rdf-file <rdf.ttl>
EOF
    exit 1
}

while [ $# -gt 0 ] ; do
    case "$1" in
    -h|--help)
        usage
        ;;
    --mapping)
        MAPPING="true"
        ;;
    --transform)
        TRANSFORM="true"
        ;;
    --enrich)
        ENRICH="true"
        ;;
    --pass)
        P="$2"
        shift
        ;;
    --user)
        U="$2"
        shift
        ;;
    --jdbc)
        JDBC="$2"
        shift
        ;;
    --mapping-file)
        MF="$2"
        shift
        ;;
    --rdf-file)
        RF="$2"
        shift
        ;;
    -*)
        usage "Unknown option '$1'"
        ;;
    esac
    shift
done

if [ ! -z "$MAPPING" ] ; then
  mapping
fi

if [ ! -z "$TRANSFORM" ] ; then
  transform
fi

if [ ! -z "$ENRICH" ] ; then
  enrich
fi