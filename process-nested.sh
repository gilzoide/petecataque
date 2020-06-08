#!/bin/sh

inotifywait -m -e modify -e move scenes entities |
while read filename eventlist eventfile; do
    modified=$filename$eventfile
    case $(echo $modified | awk -F . '{print $NF}') in
        nested)
            output=$(echo $modified | cut -f 1 -d '.').lua
            if [ "$eventlist" = "MOVED_FROM" ]; then
                rm -f $output
            else
                cat $modified | nested | nested2table > $output
            fi
    esac
done
