# spectre-v1-priv-kmhv2 review

Code: `/nfs/home/leizhenyu/opt/verified_poc/xiangshan-v2/spectre-v1-priv-kmhv2/code`

Statistics: `/nfs/home/leizhenyu/opt/verified_poc/logs/xiangshan-v2/spectre-v1-priv-kmhv2/20260714-review`

## Theory and source reasonableness

This PoC extends Spectre V1 to a modeled U attacker / M victim service boundary. It installs Sv39 state (`src/spectre-v1-priv.c:304`, `src/spectre-v1-priv.c:305`), probes direct architectural access with explicit fault tracking (`src/spectre-v1-priv.c:390` to `src/spectre-v1-priv.c:396`), and handles the expected fault by setting `direct_secret_fault_seen` (`src/spectre-v1-priv.c:458` to `src/spectre-v1-priv.c:460`). The Spectre V1 training/attack loop remains the same structure (`src/spectre-v1-priv.c:610`, `src/spectre-v1-priv.c:613`, `src/spectre-v1-priv.c:616`). The final model and isolation checks are printed at `src/spectre-v1-priv.c:752`, `src/spectre-v1-priv.c:780`, and `src/spectre-v1-priv.c:808`.

The setup is reasonable because it separately verifies architectural isolation (`fault_seen=1 completed=0`) and transient cache disclosure. The conclusion should be phrased as a modeled local U/M service-boundary PoC, not as evidence against an external system.

## Rerun result

Result: PASS, top-1 recovered `S3CreT`.

Key evidence:

- `fault_seen=1 completed=0`
- bytes `S`, `3`, `C`, `r`, `e`, `T` all matched
- `check=PASS`
