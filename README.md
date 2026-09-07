# Historical Pluto regression baseline

This branch preserves the compiler implementation at
`6f43860b6c4cddeeca09189bf3073f05b78b14a5` for reproducing known miscompilations.
Subsequent commits on this branch document the baseline; they do not repair
its compiler code. Use [`master`](https://github.com/verif-scop/pluto/tree/master)
for the fixed compiler.

## Build

Use the same dependencies as the fixed branch, including LLVM/Clang 10, GMP,
GLPK, Autoconf, Automake, Libtool, Flex, and Bison:

```sh
git submodule update --init --recursive
./autogen.sh
./configure --enable-glpk --with-glpk-prefix=/usr
make -j2
```

PolCert's development image builds this baseline separately from the fixed
compiler. Its ordinary optimization commands use the fixed compiler; only
explicit bug-reproduction tests select this one.

## Known defects and reproduction

The fixtures and executable checks live in
[PolCert's `tests/pluto-bugs`](https://github.com/verif-scop/PolCert/tree/main/tests/pluto-bugs)
and [`tools/pluto_bugs`](https://github.com/verif-scop/PolCert/tree/main/tools/pluto_bugs).
From a built PolCert checkout, set `POLCERT_BUGGY_ROOT` to this built checkout
and run the indicated Make target.

| Fixture | Defect | Make target |
| --- | --- | --- |
| `auto-affine-lp-cc-scaling` | Inconsistent conversion of an LP solution to an integer schedule can violate dependences. | `test-pluto-miscompilation-auto-affine-lp` |
| `tiling-innerpar-satvec` | Dependence-satisfaction metadata changes without the matching schedule change, permitting an unsafe parallel hint. | `test-pluto-miscompilation-tiling-innerpar` |
| `vanished-outer-parallel` | Parallel-loop selection mishandles a band boundary. | `test-pluto-miscompilation-vanished-outer` |
| `notile-unrolljam-nonpermutable` | Unroll-and-jam is requested across a nonpermutable band. | `test-pluto-miscompilation-notile-unrolljam` |
| `tiling-mixed-depth-cross-band` | Tiling moves a copy before a dependent standalone write. | `test-pluto-miscompilation-tiling-mixed-depth` |

For example:

```sh
POLCERT_BUGGY_ROOT=/path/to/pluto-buggy \
  opam exec -- make test-pluto-miscompilation-tiling-innerpar
```

The checks compare execution results and exercise PolCert's rejection of
invalid proposals. Optimizer schedules and harmless singleton-loop annotations
may vary between builds; those variations are not themselves miscompilations.
The fixed compiler also has diamond and staged-OpenScop regressions that check
repairs beyond these five historical cases.

The original [license](LICENSE) applies.
