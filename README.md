# Pluto

This fork of the original Pluto repository (https://github.com/bondhugula/pluto) is the customized version especially for the artifact of "Verified Validator for Polyhedral Scheduling" (not public yet). Notice that this fork is made in June 15, 2023.

Following changes are made:
1. adding `--dumpscop` option (for non-pet frontend), to dump scheduled polyhedral model in openscop format (with `.afterscheduling.scop` suffix).
2. `--dumpscop` will also dump polyhedral model for the input scop (just after polyhedral extraction, before any further scheduling) in openscop format (with `.beforescheduling.scop`), no matter `--readscop` is enabled or not.
3. redirect piplib and cloog to texlive-free upstream...

The dumped files are used for validation. This minimal-changed fork is still under the MIT LICENSE. 

## FORK FOR THE VERIFIED VALIDATOR

The verified validator is proven in Coq, and is used to check two polyhedral models have same "semantics". Two models should differ only in the scheduling, so the validator is "scheduling validator". Advanced polyhedral techniques like tiling are not supported (actually, scheduling and tiling are two different phrases in polyhedral compilation, so they should also be validated in two phrases).

We use following options for pluto scheduling. It avoids not-supported unrolling/tiling/parallization/vectorization (those will change "domain" of polyhedral model, split the "instruction", complicate the "semantics", not supported yet), but enable basic scheduling like fusion/unfusion/interchange/... (note that pluto's scheduler find a "optimized" execution order for the instances according to a cost function, and therefore the scheduling result is a composition of commonsense loop transformations). We also enable "--rar" for read-read dependences.

```
pluto --dumpscop --nointratileopt --nodiamond-tile --noprevector --smartfuse --nounrolljam --noparallel --notile --rar covcol.c
```

Only with sequential "reordering/scheduling", the final model could gain significant speed up because of locality optimization. [WIP, covcol, gemver]


## INSTALLING PLUTO

We refer you to the [Dockerfile](./Dockerfile) for the step-by-step installation.

```
sudo docker build . -t pluto
# this may take 30 min, decided by your network condition
sudo docker run -ti --rm pluto
# open a container for testing (like `make test` in it) (and it will be removed when you exit)
```

Though the newest pluto repo has revised installing instructions, but we recommend to follow the following. Due to time limit, we only test on Ubuntu 20.04.2 LTS, but we believe it should run on similar environments.

1. install `autoconf`, `automake`, and `libtool`.
2. install `llvm-10-dev`, `libclang-10-dev`. 
3. `update-alternative` your `FileCheck-10` to `FileCheck` and `llvm-config-10` to `llvm-config`
4. install `gmp`, `texinfo`, `libtool-bin`...

### BUILDING PLUTO

```shell
git clone https://github.com/verif-scop/pluto.git
cd pluto/
git submodule init
git submodule update
./autogen.sh
./configure [--enable-debug] [--with-clang-prefix=<clang headers/libs location>]
# Example: on an Ubuntu: --with-clang-prefix=/usr/lib/llvm-10. Emit options for default location
make
make test
# You should see all 65 tests are passed.
# if only test_libpluto and unit_tests not pass, dynamic lib are not correctly configured. You should clean the environment and rebuild.
make install
# install pluto to PATH
```
