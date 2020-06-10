#!/usr/bin/env bash

REPO="$(echo "${1}" | sed -e 's/[[:space:]]*$//')".git
git clone ${REPO} >/dev/null 2>&1
DIR=`echo $1 | rev | cut -d'/' -f 1 | rev`
cd $DIR

while IFS= read -r TAG; do
  git checkout $TAG >/dev/null 2>&1
  LOC=`cloc -q . | grep ^Python | grep -oP "[0-9]+" | tail -n 1`

  pip install $2==$3 >/dev/null 2>&1 || { echo ${DIR},${TAG},${2},${3},"failed pip install ${2}==${3}"; break; } #no point in trying all tags if we cannot even install that version of the lib
  pip install . >/dev/null 2>&1  || { echo ${DIR},${TAG},${2},${3},"failed pip install . "; continue; }
  pip install pytest >/dev/null 2>&1  || { echo ${DIR},${TAG},${2},${3},"failed pip install pytest"; continue; }
  pip install coverage >/dev/null 2>&1  || { echo ${DIR},${TAG},${2},${3},"failed pip install coverage"; continue; }

  ALL_DEPS=`pip list --format json`
  EXPECTED_DEP="{\"name\": \"${2,,}\", \"version\": \"${3,,}\"}"
  #Test if $2 is indeed installed
  if [[ "${ALL_DEPS,,}" == *"${EXPECTED_DEP}"* ]]; then
    pytest -h >/dev/null 2>&1 || { echo ${DIR},${TAG},${2},${3},"pytest not found"; continue; }
    coverage help >/dev/null 2>&1 || { echo ${DIR},${TAG},${2},${3},"coverage not found"; continue; }
    TOTAL_PASSED=`coverage run -m pytest -q | tail -n -1 | cut -d ' ' -f 1`
    #coverage run -m pytest >/dev/null 2>&1
    COVERAGE_SUMMARY=`coverage report | tail -1`
    TOTAL_COVERAGE=`echo $COVERAGE_SUMMARY | rev | cut -d' ' -f 1 | rev`
    TOTAL_MISS=`echo $COVERAGE_SUMMARY | rev | cut -d' ' -f 2 | rev`
    TOTAL_TESTS=`echo $COVERAGE_SUMMARY | rev | cut -d' ' -f 3 | rev`
    echo ${DIR},${TAG},${2},${3},${TOTAL_TESTS},${TOTAL_MISS},${TOTAL_COVERAGE},${TOTAL_PASSED},$LOC
  else
    echo ${DIR},${TAG},${2},${3},"${2}==${3} not found"
  fi
done < <( git tag --sort=-creatordate )
