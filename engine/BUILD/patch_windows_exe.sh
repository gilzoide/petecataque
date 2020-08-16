#!/bin/sh
exe_dir=$1
love_file=$2
out_zip=$3

fused_exe="$exe_dir/$(basename $love_file .love).exe"
cat $exe_dir/love.exe $love_file > $fused_exe

other_files=$(find $exe_dir ! -path $exe_dir ! -name '*.exe')
zip -9 -j $out_zip $fused_exe $other_files
