#!/bin/bash
set -e
nice stata13-mp -b $1
set +e
grep -C5 -E "^r\([0-9]+\)" ${1%do}log
let $?
exit
