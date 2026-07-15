# spectre-v2-privilege-kmhv2 review

Code: `/nfs/home/leizhenyu/opt/verified_poc/xiangshan-v2/spectre-v2-privilege-kmhv2/code`

Statistics: `/nfs/home/leizhenyu/opt/verified_poc/logs/xiangshan-v2/spectre-v2-privilege-kmhv2/20260714-review`

## Theory and source reasonableness

This PoC combines a Spectre V2-style indirect-control disclosure path with a modeled U attacker / M victim service boundary. The secret is in an M-only section (`src/spectre-v2.c:156`). Sv39 setup is at `src/spectre-v2.c:356` and `src/spectre-v2.c:357`. Direct architectural U access is tested and expected to fault (`src/spectre-v2.c:467` to `src/spectre-v2.c:473`, and trap handling at `src/spectre-v2.c:676` to `src/spectre-v2.c:678`). The V2 training and attack controls are governed by `V2_ATTACK_TRIES`, `V2_TRAINING_LOOPS`, and `V2_ASM_CONTROL_ROUND` (`src/spectre-v2.c:24`, `src/spectre-v2.c:28`, `src/spectre-v2.c:88`). The attack loop is at `src/spectre-v2.c:841`, and the model/result printout is at `src/spectre-v2.c:1065` to `src/spectre-v2.c:1074`, `src/spectre-v2.c:1096`, and `src/spectre-v2.c:1136`.

The setup is useful, but interpretation must be strict: `V2_ASM_CONTROL_ROUND=1` is not a valid substitute for a baseline leak result, and even `check=PASS` should be cross-checked against top-1 ranking.

## Historical baseline

Historical corrected artifact baseline:

- expected: `S3CreT`
- top-1 recovered: `S3preT`
- pass count by top-1: `5/6`
- offset 2 failed: expected `C`, guessed `p`

## Rerun result

Rerun command used baseline `V2_ASM_CONTROL_ROUND=0`.

Rerun observations:

- direct U read faulted on all byte runs: `fault_seen=1 completed=0`
- offset 2 improved relative to historical baseline: expected `C`, top-1 `C`
- offset 5 was not a clean top-1 match: expected `T`, top-1 `q`, expected `T` ranked second
- program printed `check=PASS` for every byte

Top-1 recovered string for this rerun: `S3Creq`.

Conclusion: record this as a mixed/non-deterministic rerun. It supports that the channel can expose signal, but it should not be summarized as clean full-string top-1 recovery.
