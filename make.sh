#!/bin/sh

rm -rf obj; mkdir obj
rm -rf compiled; mkdir compiled
tre configure.lisp
sh obj/_make.sh
sbcl --noinform --core bender/bender make.lisp
