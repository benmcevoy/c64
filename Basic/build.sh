#!/bin/bash

petcat -w2 -o ./bin/$1.prg -- $1.bas
nohup x64sc -basicload ./bin/$1.prg
