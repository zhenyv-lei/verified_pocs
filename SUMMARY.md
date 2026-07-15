# verified_poc review summary

Run ID: `20260714-review`

Archive root: `/nfs/home/leizhenyu/opt/verified_poc`

## Scope

This pass archives and reruns the PoCs that already had historical evidence artifacts:

| processor | PoC | rerun status | top-1 recovered | notes |
| --- | --- | --- | --- | --- |
| xiangshan-v2 | `spectre-v1-poc-kmhv2` | PASS | `S3CreT` | Standard Spectre V1 bounds-check bypass. |
| xiangshan-v2 | `spectre-v2-poc-kmhv2` | PASS | `S3CreT` | Standard Spectre V2 indirect-control/BTB-style PoC. |
| xiangshan-v2 | `spectre-v1-priv-kmhv2` | PASS | `S3CreT` | U attacker / M victim service; direct U read faulted. |
| xiangshan-v2 | `spectre-v1-asid-kmhv2` | PASS | `S3CreT` | Per-byte ASID isolation; direct victim read faulted; ASIDs differ. |
| xiangshan-v2 | `spectre-v1-vmid-kmhv2` | PASS | `S3CreT` | Per-byte VMID isolation; direct victim read faulted; VMIDs differ. |
| xiangshan-v2 | `spectre-v2-privilege-kmhv2` | mixed | `S3Creq` by top-1 guess | Program printed `check=PASS` for all bytes, but offset 5 top-1 was `q`, expected `T`; historical baseline was `S3preT`, 5/6. |
| xiangshan-v3 | `spectre-v1-poc-kmhv3` | PASS | `S3CreT` | Known-good V3 parameters reproduced full string. |

## Important interpretation rule

For documentation, distinguish:

- `program check`: what the PoC's own final check printed.
- `top-1 recovered`: the highest-scoring character in the timing channel.
- `historical baseline`: the result stored in previous artifact provenance.

This matters for `spectre-v2-privilege-kmhv2`: the rerun printed `check=PASS` on offset 5 even though the top-1 guess was `q` and the expected byte `T` ranked second. This should not be described as a clean top-1 full-string recovery.

## Log directories

- `/nfs/home/leizhenyu/opt/verified_poc/logs/xiangshan-v2/spectre-v1-poc-kmhv2/20260714-review`
- `/nfs/home/leizhenyu/opt/verified_poc/logs/xiangshan-v2/spectre-v2-poc-kmhv2/20260714-review`
- `/nfs/home/leizhenyu/opt/verified_poc/logs/xiangshan-v2/spectre-v1-priv-kmhv2/20260714-review`
- `/nfs/home/leizhenyu/opt/verified_poc/logs/xiangshan-v2/spectre-v1-asid-kmhv2/20260714-review`
- `/nfs/home/leizhenyu/opt/verified_poc/logs/xiangshan-v2/spectre-v1-vmid-kmhv2/20260714-review`
- `/nfs/home/leizhenyu/opt/verified_poc/logs/xiangshan-v2/spectre-v2-privilege-kmhv2/20260714-review`
- `/nfs/home/leizhenyu/opt/verified_poc/logs/xiangshan-v3/spectre-v1-poc-kmhv3/20260714-review`

## Environment note

The analysis skill's weekly XiangShanLab sync check did not run because `xiangshanlab_home` / `XIANGSHANLAB_HOME` was not configured. This pass uses the user-provided local DUT/workload paths and the already collected artifact provenance.
