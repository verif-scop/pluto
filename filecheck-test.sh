#!/bin/bash

check_ret_val_emit_status()
{
if [ $? -ne 0 ]; then
  echo -e "[\e[31mFailed\e[0m]" " $file"!
else
  echo -e "[\e[32mPassed\e[0m]"
fi
}

TESTS="\
  test/matmul.c \
  test/heat-2d.c \
  test/heat-3d.c \
  test/jacobi-3d-25pt.c \
  "
# Tests with pet with tiling and parallelization disabled
for file in $TESTS; do
  echo -ne "$file "
  ./src/pluto $file --pet --notile --noparallel  -o test_temp_out.pluto.c | FileCheck $file
  check_ret_val_emit_status
done

# Tests with pet
for file in $TESTS; do
    echo -ne "$file with --tile --parallel "
    ./src/pluto $file --pet -o test_temp_out.pluto.c | FileCheck --check-prefix TILE-PARALLEL $file
    check_ret_val_emit_status
done


TESTS="\
  test/matmul.c \
  test/jacobi-1d-imper.c \
  test/jacobi-2d-imper.c \
  test/matmul.c \
  test/costfunc.c \
  test/fdtd-2d.c \
  test/seq.c \
  test/gemver.c \
  test/seidel.c \
  test/mvt.c \
  test/mxv.c \
  test/mxv-seq.c \
  test/mxv-seq3.c \
  test/matmul-seq.c \
  test/matmul-seq3.c \
  test/doitgen.c \
  test/polynomial.c \
  test/1dloop-invar.c \
  test/fusion1.c \
  test/fusion2.c \
  test/fusion3.c \
  test/fusion4.c \
  test/fusion5.c \
  test/fusion6.c \
  test/fusion7.c \
  test/fusion8.c \
  test/fusion9.c \
  test/fusion10.c \
  test/negparam.c \
  test/nodep.c \
  test/noloop.c \
  test/shift.c \
  test/simple.c \
  test/tricky1.c \
  test/tricky2.c \
  test/tricky3.c \
  test/tricky4.c \
  test/tce-4index-transform.c \
  test/wavefront.c \
  "

# Tests without --pet and without any tiling and parallelization "
for file in $TESTS; do
    echo -ne "$file "
    ./src/pluto --notile --noparallel $file $* -o test_temp_out.pluto.c | FileCheck $file
    check_ret_val_emit_status
done

cleanup()
{
rm -f test_temp_out.pluto.c
rm -f test_temp_out.pluto.pluto.cloog
}

echo

trap cleanup SIGINT exit
