#!/usr/bin/env bash
set -ex

echo "2" > test_input.txt
./operation --input test_input.txt --term 10 --output test_output_add.txt
./operation --input test_input.txt --operator "-" --term 10 --output test_output_subtract.txt
./operation --input test_input.txt --operator "*" --term 10 --output test_output_multiply.txt
./operation --input test_input.txt --operator "/" --term 2 --output test_output_divide.txt

echo ">>> Checking whether output is generated"
[[ ! -f test_output_add.txt ]] && echo "Output file could not be found!" && exit 1
[[ ! -f test_output_subtract.txt ]] && echo "Output file could not be found!" && exit 1
[[ ! -f test_output_multiply.txt ]] && echo "Output file could not be found!" && exit 1
[[ ! -f test_output_divide.txt ]] && echo "Output file could not be found!" && exit 1

echo ">>> Checking if output is correct"
[ ! $(cat test_output_add.txt) -eq 12 ] && "Not the expected output" && exit 1
[ ! $(cat test_output_subtract.txt) -eq -8 ] && "Not the expected output" && exit 1
[ ! $(cat test_output_multiply.txt) -eq 20 ] && "Not the expected output" && exit 1
[ ! $(cat test_output_divide.txt) -eq 1 ] && "Not the expected output" && exit 1

echo ">>> Test done"
