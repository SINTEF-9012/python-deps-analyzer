#!/usr/bin/env bash

WIN=1

function _docker
{
((WIN)) && export MSYS_NO_PATHCONV=1
timeout -k 300s 600s docker $@
((WIN)) && export MSYS_NO_PATHCONV=0
}

_docker build -t camp/test-dep .

BASEDIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

LIB="pyyaml"
CSV_FILE=$BASEDIR/dependents_${LIB}.csv
VERSIONS_FILE=$BASEDIR/test-all-versions/${LIB}.out

while IFS= read -r line; do
  URL=`echo $line | perl -F, -wane 'print $F[-2]'`
  CLEAN_URL=${URL%/}
  if [[ $CLEAN_URL == *"github.com"* ]]; then
    REPO=`echo $CLEAN_URL | perl -F/ -wane 'print $F[-1]'`
    echo $REPO": "$CLEAN_URL
    (while IFS= read -r vline; do
      VERSION=`echo $vline | perl -F, -wane 'print $F[0]'`
      echo ${LIB}==${VERSION}
      _docker run --rm camp/test-dep $CLEAN_URL ${LIB} ${VERSION} >> ${LIB}_${REPO}.out
    done < $VERSIONS_FILE) &
  fi
done < $CSV_FILE
