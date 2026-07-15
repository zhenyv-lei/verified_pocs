# Result Summary

## Target

- XiangShan branch: `kunminghu-v2`
- XiangShan commit: `2acbf327c`
- Build configuration evidence: `KunminghuV2Config`
- Emulator: `/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu`

## Workload

- Workload: Spectre V1, `riscv64-xs-flash`
- Secret: `S3CreT`
- `SECRET_SZ=6`
- `TRAIN_TIMES=10`
- `ATTACK_SAME_ROUNDS=2`
- Cache threshold mode: dynamic calibration
- Final measured threshold: `85`

## Observation

The first direct run against the existing original build was not suitable as a
current-source Kunminghu V2 validation because the existing ELF reported
`fixed=1` and `reading 1 bytes`.

After rebuilding the current source in a new copy, the `char *secretString`
layout produced empty `want()` values. The experiment copy was therefore changed
to `char secretString[] = "S3CreT";`, keeping the original directory untouched.

## Final Run Result

Recovered bytes:

```text
S3CreT
```

Per-byte top-1 results:

```text
want(S) -> 1.(2, S)
want(3) -> 1.(2, 3)
want(C) -> 1.(2, C)
want(r) -> 1.(2, r)
want(e) -> 1.(2, e)
want(T) -> 1.(2, T)
```

Conclusion: the final run leaked all six bytes of the configured secret on the
current Kunminghu V2 emulator.
