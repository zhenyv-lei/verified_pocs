# Result Summary

## Target

- XiangShan branch: `kunminghu-v2`
- XiangShan commit: `2acbf327c`
- Build configuration evidence: `KunminghuV2Config`
- Emulator: `/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu`

## Workload

- Workload: Spectre V1 privileged interface, `riscv64-xs`
- Attacker privilege: U-mode
- Victim privilege: M-mode service through machine `ecall`
- Isolation model: Sv39 page-table isolation, victim secret page has `PTE_U=0`
- Direct U-mode secret read: expected to fault
- Secret: `S3CreT`
- `SECRET_SZ=6`
- `ATTACK_SAME_ROUNDS=5`
- `TRAIN_TIMES=10`
- `PROBE_CANDIDATES=62`
- `FLUSH_LINES=256`
- `EARLY_STOP=1`, `EARLY_STOP_MIN_SCORE=3`, `EARLY_STOP_GAP=2`
- Cache threshold mode: dynamic calibration
- Final measured threshold: `85`

## Final Run Result

The direct U-mode read from the secret page faulted as expected:

```text
fault_seen=1 completed=0 expected=fault
```

Recovered bytes:

```text
S3CreT
```

Per-byte top guesses:

```text
byte 0: expected=S(0x53) guess=S(0x53) score=3
byte 1: expected=3(0x33) guess=3(0x33) score=4
byte 2: expected=C(0x43) guess=C(0x43) score=3
byte 3: expected=r(0x72) guess=r(0x72) score=3
byte 4: expected=e(0x65) guess=e(0x65) score=3
byte 5: expected=T(0x54) guess=T(0x54) score=3
```

Final check:

```text
[v1-priv] check=PASS
```

Conclusion: the final run leaked all six bytes of the configured secret across
the modeled U-mode attacker / M-mode victim service boundary while the direct
architectural U-mode secret load was blocked by page-table permissions.
