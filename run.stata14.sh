#!/bin/bash
nice stata14-mp -b $1
grep -C5 -E "^r\([0-9]+\)" ${1%do}log
let $?
exit
