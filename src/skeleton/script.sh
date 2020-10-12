#!/bin/bash

# VIASH START
par_input="input.txt"
par_output="output.txt"
# VIASH END

cat $par_input | sed 's/input/output/' > $par_output
