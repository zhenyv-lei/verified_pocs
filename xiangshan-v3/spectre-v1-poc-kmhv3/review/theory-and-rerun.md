# spectre-v1-poc-kmhv3 review

Code: `/nfs/home/leizhenyu/opt/verified_poc/xiangshan-v3/spectre-v1-poc-kmhv3/code`

Statistics: `/nfs/home/leizhenyu/opt/verified_poc/logs/xiangshan-v3/spectre-v1-poc-kmhv3/20260714-review`

## Theory and source reasonableness

This is the Kunminghu V3 Spectre V1 PoC with the known-good full-string parameters. The secret is `secretString[] = "S3CreT"` (`src/spectre-v1.c:51`). The victim function is at `src/spectre-v1.c:149`, the malicious offset is computed at `src/spectre-v1.c:175`, and the train/attack selector is at `src/spectre-v1.c:214`, `src/spectre-v1.c:220`, and `src/spectre-v1.c:222`. The result printout and top-candidate debug are at `src/spectre-v1.c:259` to `src/spectre-v1.c:263`.

The rerun used the known-good V3 parameters:

```text
CACHE_HIT_THRESHOLD=80
USE_FIXED_CACHE_HIT_THRESHOLD=1
SECRET_SZ=6
ATTACK_SAME_ROUNDS=3
TRAIN_TIMES=6
FLUSH_CANDIDATE_LINES_ONLY=1
FLUSH_LINES=256
```

The setup is reasonable for V3 same-context Spectre V1 validation. It does not claim privilege separation; it validates branch predictor/cache side-channel behavior under the V3 emu.

## Rerun result

Result: PASS, top-1 recovered `S3CreT`.

Evidence:

- six `m[...] = want(...)` lines match top-1 guesses `S`, `3`, `C`, `r`, `e`, `T`
- `HIT GOOD TRAP`
- `Host time spent: 1305593ms`
