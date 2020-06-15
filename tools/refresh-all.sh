#!/bin/sh

SCRIPTPATH=$(dirname "$0")

for filename in $(ls script/*.nested); do
    output=$(echo $filename | cut -f 1 -d '.').lua
    cat $filename | lua $SCRIPTPATH/nested2object.lua > $output
done
