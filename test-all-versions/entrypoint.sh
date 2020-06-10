#!/usr/bin/env bash

REPO="$(echo "${1}" | sed -e 's/[[:space:]]*$//')".git
git clone ${REPO} >/dev/null 2>&1
DIR=`echo $1 | rev | cut -d'/' -f 1 | rev`
cd $DIR

while IFS= read -r TAG; do
  git checkout $TAG >/dev/null 2>&1
  LOC=`cloc -q . | grep ^Python | grep -oP "[0-9]+" | tail -n 1`
  pip install . >/dev/null 2>&1
  pip install pytest >/dev/null 2>&1
  pip install coverage >/dev/null 2>&1
  TOTAL_PASSED=`coverage run -m pytest -q | tail -n -1 | cut -d ' ' -f 1`
  COVERAGE_SUMMARY=`coverage report | tail -1`
  TOTAL_COVERAGE=`echo $COVERAGE_SUMMARY | rev | cut -d' ' -f 1 | rev`
  TOTAL_MISS=`echo $COVERAGE_SUMMARY | rev | cut -d' ' -f 2 | rev`
  TOTAL_TESTS=`echo $COVERAGE_SUMMARY | rev | cut -d' ' -f 3 | rev`
  pip install $DIR==$TAG >/dev/null 2>&1 || { continue; } #that version cannot be installed by pip install, so we ignore it as we will not be able to use it in other experiments
  echo ${TAG},$(pytest --collect-only -q | head -n -2 | wc -l),${TOTAL_TESTS},${TOTAL_MISS},${TOTAL_COVERAGE},${TOTAL_PASSED},$LOC
done < <( git tag --sort=-creatordate )
