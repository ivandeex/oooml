#!/bin/bash
F=$1
P=$2
shift; shift
[ -z "$F" -o -z "$P" ] && exit 1
ooo2db.sh -mml -sense -render -circlednumbers -dropcontents -indent -utf -progress "$@" ${F}_mml.odt
db2mw.sh -outdir ./${F}.wiki -pagename $P -input ./${F}_mml_db.xml
