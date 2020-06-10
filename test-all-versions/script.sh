#!/usr/bin/env bash

WIN=1

function _docker
{
((WIN)) && export MSYS_NO_PATHCONV=1
timeout -k 600s 7200s docker $@
((WIN)) && export MSYS_NO_PATHCONV=0
}

_docker build -t camp/test-all .
_docker run --rm camp/test-all 'https://github.com/yaml/pyyaml' >> pyyaml.out &
_docker run --rm camp/test-all 'https://github.com/psf/requests' >> requests.out &
