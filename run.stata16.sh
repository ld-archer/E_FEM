#!/bin/bash
nice stata-se -b $1
grep -C30 -E "^r\([0-9]+\)" ${1%do}log
let $?
exit