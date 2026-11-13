# Correctness fixes

The fixed compiler contains the following repairs relative to the historical
baseline `6f43860b6c4cddeeca09189bf3073f05b78b14a5`.

| Area | Repair |
| --- | --- |
| Affine scheduling | Scale LP solutions consistently when forming integer schedules, and check dependence satisfaction before using the result. |
| Parallel tiling | Update dependence-satisfaction metadata only when the corresponding schedule transformation is applied. |
| Loop annotations | Respect band boundaries when selecting parallel and unroll-and-jam loops. |
| Imported schedules | Recognize constant scattering rows as scalar hyperplanes during identity tiling. |
| Mixed-depth tiling | Transform constant coordinates consistently with the tiled band, preserving dependences to statements outside its loop nest. |
| Diamond tiling | Restore evicted hyperplanes even with `--nointratileopt`; complete dependent statements' schedules jointly rather than choosing incompatible per-statement tie breakers. |
| Wavefront scheduling | Preserve scalar phase coordinates when extending a wavefront across mixed-depth statements. |
| Dependence extraction | Project out existentially quantified variables that isl reintroduces after removing divisions, such as a parameter parity condition, instead of aborting on the extra constraint column. |

Joint diamond completion enforces the remaining dependence constraints. Adding
read–read relations with `--rar` must not cause dependent instances to receive
an unresolved common timestamp. The completion belongs in the optimizer;
PolCert does not recover a statement order from generated C and append it to
the schedule.

The OpenScop phase-export interface also exposes a legal tiling result before
later affine transformations. This is an integration requirement introduced
by this fork, distinct from a defect in upstream Pluto's original export API.
The direct tiling check and the following affine check therefore see the
transformations they are intended to validate.

The [`buggy`](https://github.com/verif-scop/pluto/tree/buggy) branch retains the
pre-repair implementation. Its documentation links each historical case to
the corresponding executable PolCert regression.
