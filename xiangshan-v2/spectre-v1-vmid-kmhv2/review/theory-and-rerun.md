# spectre-v1-vmid-kmhv2 review

Code: `/nfs/home/leizhenyu/opt/verified_poc/xiangshan-v2/spectre-v1-vmid-kmhv2/code`

Statistics: `/nfs/home/leizhenyu/opt/verified_poc/logs/xiangshan-v2/spectre-v1-vmid-kmhv2/20260714-review`

## Theory and source reasonableness

This PoC models VM separation using VS-stage and HGATP state. It creates `satp` and `hgatp` values (`src/spectre-v1-vmid-priv.c:345`, `src/spectre-v1-vmid-priv.c:346`), switches and reads back `vsatp` / `hgatp` (`src/spectre-v1-vmid-priv.c:349` to `src/spectre-v1-vmid-priv.c:367`), and prints requested/observed values (`src/spectre-v1-vmid-priv.c:931` to `src/spectre-v1-vmid-priv.c:936`). Direct victim access fault tracking is implemented at `src/spectre-v1-vmid-priv.c:492` to `src/spectre-v1-vmid-priv.c:498` and `src/spectre-v1-vmid-priv.c:607` to `src/spectre-v1-vmid-priv.c:609`. The V1 mistraining structure is at `src/spectre-v1-vmid-priv.c:804`, `src/spectre-v1-vmid-priv.c:807`, and `src/spectre-v1-vmid-priv.c:810`.

The setup is reasonable because it checks architectural isolation through the expected direct read fault and confirms distinct VMID-bearing `hgatp` values.

## Rerun result

Result: PASS, per-byte top-1 recovered `S3CreT`.

Key evidence:

- every byte log reports `fault_seen=1 completed=0`
- requested and observed attacker/victim HGATP values differ in VMID bits
- offsets 0..5 all report `check=PASS`
