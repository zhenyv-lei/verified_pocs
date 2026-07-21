# Sv48 v1-priv 2-byte rootfix run summary - 2026-07-17

## Configuration

- PoC: `xiangshan-v2/spectre-v1-priv-kmhv2`
- Page table mode: Sv48
- Secret size: `SECRET_SZ=2`
- Candidates: `PROBE_CANDIDATES=62`
- Attack rounds: `ATTACK_SAME_ROUNDS=5`
- Training: `TRAIN_TIMES=10`
- Flush lines: `FLUSH_LINES=256`
- Root-fix included: `machine_low_return` clears `satp` before returning to AM/host exit path.

## Build result

Build passed.

```text
build_clean_elapsed=0:00.05 exit=0
build_elapsed=0:00.39 exit=0
```

## Runtime result

The emulator run did not reach the result/exit path within the 45 minute window.

```text
run_elapsed=45:00.01 exit=124
run_exit=124
```

Observed guest output stopped after startup/control setup:

```text
[v1-priv] model=sv48-pte-u-isolation attacker=U victim=M isolation=Sv48-PTE-U0 secret=PTE_U0 pmp=permissive-not-boundary satp=sv48 service=machine-ecall secret_sz=2 candidates=62 flush_lines=256 control_only=0
[v1-priv] calibration fallback=70 measured=85 threshold=85 fixed=0
[v1-priv] control service_return=no-secret direct_secret_access=expect-fault
[v1-priv] b_array1=0000000080007000 b_secret=0000000080007050 malicious_base=80 probe=0000000080008000
```

No `traps=`, `byte`, `check=`, `Exit with code`, or `HIT GOOD TRAP` line was emitted.

## Decision

Full-string (`SECRET_SZ=6`) was not started because the requested 2-byte gate did not complete normally. Running the full-string workload now would not provide useful evidence.

