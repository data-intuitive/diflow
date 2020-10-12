#!/usr/bin/env bash
set -ex

echo "2" > test_input.txt

./subtract --input test_input.txt --term 10 --output test_output.txt

echo ">>> Checking whether output is generated"
[[ ! -f test_output.txt ]] && echo "Output file could not be found!" && exit 1

echo ">>> Checking if output is correct"
[ ! $(cat test_output.txt) -eq -8 ] && "Not the expected output" && exit 1

echo ">>> Test done"
