# Result Summary

## Target

- XiangShan branch: `kunminghu-v2`
- XiangShan commit: `2acbf327c`
- Build configuration evidence: `KunminghuV2Config`
- Emulator: `/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu`

## Workload

- Workload: Spectre V2, `riscv64-xs`
- Secret: `S3CreT`
- `SECRET_SZ=6`
- `V2_ATTACK_TRIES=2`
- `V2_TRAINING_LOOPS=16`
- Cache threshold mode: dynamic calibration
- Final measured threshold: `95`

## Observation

The prebuilt original ELF ran successfully but only read one byte:

```text
[v2] reading 1 bytes
[v2] check 0 0x53 0x53
```

The experiment copy was rebuilt with `SECRET_SZ=6`; no source-code change was
needed.

## Final Run Result

Recovered bytes:

```text
S3CreT
```

Per-byte checks:

```text
check 0 0x53 0x53
check 1 0x33 0x33
check 2 0x43 0x43
check 3 0x72 0x72
check 4 0x65 0x65
check 5 0x54 0x54
```

Conclusion: the final run leaked all six bytes of the configured secret on the
current Kunminghu V2 emulator.
