#!/usr/bin/env bash
set -e
./full &
pid=$!

logfile=$(mktemp -t memory.log.XXXX)
start=$(date +%s)

# get the process' memory usage and run until `ps` fails which it will do when
# the pid cannot be found any longer

while mem=$(ps -o rss= -p "$pid"); do
    time=$(date +%s)

    # print the time since starting the program followed by its memory usage
    printf "%d %s\n" $((time-start)) "$mem" >> "$logfile"

    # sleep for a tenth of a second
    sleep .1
done

printf "Find the log at %s\n" "$logfile"

gnuplot <<EOF
set terminal png
set output 'memory.png'
set autoscale
set offset graph 0, 0, 0.10, 0
set key bottom center
set bmargin 3
set xtics rotate by 45 offset -2.2,-1.5
set nomxtics
set grid ytics lc rgb "#bbbbbb" lw 1 lt 0
set grid xtics lc rgb "#bbbbbb" lw 1 lt 0
plot "$logfile" using 1:2 title "rss" with lines
EOF
