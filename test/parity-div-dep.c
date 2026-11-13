// The dependence from the write a[i][j] to the read a[i - 1][N - 1 - j]
// exists only for odd N. isl reintroduces this parity condition as an
// existentially quantified variable after the divs are removed; dependence
// extraction must project it out instead of aborting.
// CHECK: Number of deps: 2
// CHECK: Output written
// TILE-PARALLEL: Number of deps: 2
// TILE-PARALLEL: Output written
#pragma scop
for (i = 1; i < N; i++)
  for (j = 0; j < N; j++)
    if (2 * j <= N - 1)
      a[i][j] = a[i][j] + a[i - 1][j] + a[i - 1][N - 1 - j];
#pragma endscop
