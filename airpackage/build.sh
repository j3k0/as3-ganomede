#!/bin/bash

set -e
cd "$(dirname "$0")"

echo "Generating SWC..."
make -C .. swc
mkdir -p swc

echo "Copying file to directory..."
cp ../bin/ganomede.swc ./swc/
cp ../README.md ./

echo "Generating airpackage..."
apm build
