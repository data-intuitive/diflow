#!/bin/bash

# VIASH START
par_input="input.txt"
par_term="2"
par_output="output.txt"
# VIASH END

a=`cat $par_input`
let result="$a - $par_term"
echo "$result" > $par_output
