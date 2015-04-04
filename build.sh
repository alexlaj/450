#!/bin/bash
set -e
vhpcomp *.vhd
fuse -prj alu.prj -top work.cpu_tb
