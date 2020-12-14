#!/bin/sh

for file in casts/*.cast; do
  base64 -i $file -o $file.base64
done
