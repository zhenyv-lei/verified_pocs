# spectre-v1-poc-kmhv2 review

Code: `/nfs/home/leizhenyu/opt/verified_poc/xiangshan-v2/spectre-v1-poc-kmhv2/code`

Statistics: `/nfs/home/leizhenyu/opt/verified_poc/logs/xiangshan-v2/spectre-v1-poc-kmhv2/20260714-review`

## Theory and source reasonableness

This is a standard Spectre V1 bounds-check bypass PoC. The secret is adjacent to attacker-controlled array state (`secretString[] = "S3CreT"` at `src/spectre-v1.c:33`). The victim path is `victimFunc(idx)` (`src/spectre-v1.c:75`), and the malicious index is computed as `secretString - array1` (`src/spectre-v1.c:101`). The training/attack selector alternates trained in-bounds indices with the malicious index using the `TRAIN_TIMES` pattern (`src/spectre-v1.c:142`, `src/spectre-v1.c:148`, `src/spectre-v1.c:150`), then the probe array timing result is printed at `src/spectre-v1.c:187`.

The setup is reasonable for a same-address-space Spectre V1 measurement: it does not model a privilege boundary, but it directly tests whether transient execution can encode secret-dependent data into cache state.

## Rerun result

Result: PASS, top-1 recovered `S3CreT`.

Evidence:

- `result-lines.txt` shows six `want(...)` lines with top-1 guesses `S`, `3`, `C`, `r`, `e`, `T`.
- `run.log` ends in `HIT GOOD TRAP`.
