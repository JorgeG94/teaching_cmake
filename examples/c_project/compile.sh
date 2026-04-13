#!/bin/bash
# "It works on my machine" build script

CC=gcc
CFLAGS="-O2 -Wall -I./include"

echo "Compiling heatmap library..."
$CC $CFLAGS -c src/heatmap.c -o heatmap.o

echo "Compiling main program..."
$CC $CFLAGS -c src/main.c -o main.o

echo "Linking..."
$CC heatmap.o main.o -lm -o heatmap_sim

echo "Done: ./heatmap_sim"
