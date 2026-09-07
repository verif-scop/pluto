# Pluto for PolCert

This fork of [Pluto](https://github.com/bondhugula/pluto) supplies optimization
proposals to [PolCert](https://github.com/verif-scop/PolCert). It exports OpenScop
models at transformation boundaries and includes correctness fixes for affine
scheduling, tiling, and loop annotations. PolCert validates the proposals;
Pluto's optimization heuristics are not verified.

The `master` branch contains the repaired compiler. The [`buggy`](https://github.com/verif-scop/pluto/tree/buggy)
branch preserves a historical compiler for regression tests and documents its
known defects. Use `master` for optimization.

## Build and test

The build requires a C/C++ toolchain, Autoconf, Automake, Libtool, Flex, Bison,
GMP, GLPK, and LLVM/Clang 10. The [Dockerfile](Dockerfile) installs the system
dependencies. Initialize the pinned submodules before building:

```sh
git submodule update --init --recursive
./autogen.sh
./configure --enable-glpk --with-glpk-prefix=/usr
make -j2
make test
```

`tool/pluto` transforms a polyhedral model; `polycc` extracts a C loop region,
runs Pluto, and generates C. Run `./polycc --help` for optimization flags.

## Transformation boundaries

With the Clan or OpenScop frontend, `--dumpscop` exports these files:

| Suffix | Model |
| --- | --- |
| `.beforescheduling.scop` | Input before affine scheduling |
| `.midtransform.scop` | Affine schedule before tiling |
| `.posttile.scop` | Tiled model before subsequent affine transformations |
| `.afterscheduling.scop` | Final polyhedral model |

The post-tile file is emitted when tiling runs. These boundaries let PolCert
check affine scheduling and tiling separately. Diamond tiling must expose a
legal tiled model before restoring an evicted hyperplane or applying wavefront
scheduling. The PET frontend does not support these OpenScop exports.

For example:

```sh
./tool/pluto --dumpscop --tile --diamond-tile --nointratileopt \
  --noparallel --noprevector --nounrolljam test/diamond-nointratile-correctness.c
```

`--nointratileopt` disables optional locality optimization, not the restoration
needed for a legal diamond schedule. `--rar` adds read–read relations to the
scheduler; it is not required by PolCert's dependence checks.

## Correctness regressions

[FIXES.md](FIXES.md) summarizes the repairs. `make test` includes staged
OpenScop and diamond execution regressions. PolCert's
`tools/pluto_bugs/` tests additionally check the exported phase boundaries,
complete output states, and rejection of historical invalid proposals.

This fork retains Pluto's [license](LICENSE).
