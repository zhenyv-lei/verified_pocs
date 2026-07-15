# Spectre V1 on XiangShan Kunminghu V2 - Artifact Bundle

Date: 2026-07-13

This bundle records the local authorized Spectre V1 experiment run against the
current XiangShan Kunminghu V2 Verilator emulator:

- DUT root: `/nfs/home/leizhenyu/opt/DUTs/XiangShan`
- DUT branch: `kunminghu-v2`
- DUT commit: `2acbf327c`
- Emulator: `/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu`
- Effective emulator target: `/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/verilator-compile/emu`
- Workload source root: `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v1`
- Modified experiment copy: `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v1-kmhv2-run-20260713`

## Directory Contents

- `code/original/`: original `spectre-v1` Makefile and source files.
- `code/modified/`: modified copy, including rebuilt `build/` outputs.
- `code/source.diff`: source delta between original and modified copy.
- `logs/`: direct run, rebuild, baseline run, fixed rebuild, and final run logs.
- `env/`: git status, emulator metadata, help text, build config evidence, symbol table, and binary checksums.
- `results/`: extracted result lines and concise run summary.
- `commands.sh`: exact commands used to rebuild and run the final experiment.
- `result-summary.md`: human-readable conclusion and interpretation.

## Important Source Change

The original source declares:

```c
char* secretString = "S3CreT";
```

In the `riscv64-xs-flash` ELF run on this emulator, that form produced empty
`want()` values, so it did not validate the intended secret. The modified copy
uses:

```c
char secretString[] = "S3CreT";
```

This places the secret bytes directly in the data object used for the
`secretString - array1` out-of-bounds index calculation.

## Final Result

Final run recovered all 6 bytes of the secret:

```text
S3CreT
```

The top-1 guesses matched the expected byte for all six bytes.
