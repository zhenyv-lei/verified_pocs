# spectre-v1-asid-kmhv2 review

Code: `/nfs/home/leizhenyu/opt/verified_poc/xiangshan-v2/spectre-v1-asid-kmhv2/code`

Statistics: `/nfs/home/leizhenyu/opt/verified_poc/logs/xiangshan-v2/spectre-v1-asid-kmhv2/20260714-review`

## Theory and source reasonableness

This PoC models two U-mode address spaces separated by ASID. It builds SATP with an ASID field (`src/spectre-v1-asid-priv.c:343`), switches and reads back SATP (`src/spectre-v1-asid-priv.c:348` to `src/spectre-v1-asid-priv.c:355`), and records requested/observed attacker/victim SATP values (`src/spectre-v1-asid-priv.c:928` to `src/spectre-v1-asid-priv.c:930`). Direct victim data access is expected to fault and is tracked at `src/spectre-v1-asid-priv.c:479` to `src/spectre-v1-asid-priv.c:485` and `src/spectre-v1-asid-priv.c:591` to `src/spectre-v1-asid-priv.c:593`. The V1 mistraining structure is at `src/spectre-v1-asid-priv.c:786`, `src/spectre-v1-asid-priv.c:802`, and `src/spectre-v1-asid-priv.c:805`.

The setup is reasonable because it checks both ASID distinction and architectural read failure before interpreting cache-timing leakage.

## Rerun result

Result: PASS, per-byte top-1 recovered `S3CreT`.

Key evidence:

- every byte log reports `fault_seen=1 completed=0`
- requested and observed attacker/victim SATP values differ in ASID bits
- offsets 0..5 all report `check=PASS`
