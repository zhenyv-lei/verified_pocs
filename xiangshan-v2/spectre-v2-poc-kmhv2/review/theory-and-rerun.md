# spectre-v2-poc-kmhv2 review

Code: `/nfs/home/leizhenyu/opt/verified_poc/xiangshan-v2/spectre-v2-poc-kmhv2/code`

Statistics: `/nfs/home/leizhenyu/opt/verified_poc/logs/xiangshan-v2/spectre-v2-poc-kmhv2/20260714-review`

## Theory and source reasonableness

This is a standard Spectre V2-style indirect-control PoC. The runtime parameters use `V2_ATTACK_TRIES` and `V2_TRAINING_LOOPS` (`src/spectre-v2.c:14`, `src/spectre-v2.c:17`). The attack loop repeats tries at `src/spectre-v2.c:84`, and the branch-target training loop is at `src/spectre-v2.c:97`. The result check prints expected versus observed bytes at `src/spectre-v2.c:155`.

The setup is reasonable as a same-context V2 measurement: it tests whether indirect-control mistraining can redirect transient execution to a disclosure gadget and encode data through cache timing. It does not by itself prove a cross-privilege boundary.

## Rerun result

Result: PASS, top-1 recovered `S3CreT`.

Evidence:

- `result-lines.txt` shows `check 0..5` matching expected bytes.
- `run.log` ends in `HIT GOOD TRAP`.
