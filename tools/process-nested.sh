#!/bin/sh

SCRIPTPATH=$(dirname "$0")

# install fswatch: http://emcrisostomo.github.io/fswatch/
fswatch objects |
while read filename; do
    modified=$filename
    case $(echo $modified | awk -F . '{print $NF}') in
        nested)
            output=$(echo $modified | cut -f 1 -d '.').lua
            if [ ! -f $modified ]; then
                rm -f $output
            else
                cat $modified | lua $SCRIPTPATH/nested2object.lua > $output
            fi
    esac
done
