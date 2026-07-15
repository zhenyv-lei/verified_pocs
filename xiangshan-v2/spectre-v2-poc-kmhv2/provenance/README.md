# Spectre V2 on XiangShan Kunminghu V2 - Artifact Bundle

Date: 2026-07-13

This bundle records the local authorized Spectre V2 experiment run against the
current XiangShan Kunminghu V2 Verilator emulator:

- DUT root: `/nfs/home/leizhenyu/opt/DUTs/XiangShan`
- DUT branch: `kunminghu-v2`
- DUT commit: `2acbf327c`
- Emulator: `/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu`
- Effective emulator target: `/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/verilator-compile/emu`
- Workload source root: `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v2`
- Experiment copy: `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v2-kmhv2-run-20260713`

## Directory Contents

- `code/original/`: original `spectre-v2` Makefile and source files.
- `code/modified/`: experiment copy, including rebuilt `build/` outputs.
- `code/source.diff`: source delta between original and experiment copy. It is empty for this run.
- `logs/`: direct run, rebuild, and final run logs.
- `env/`: git status, emulator metadata, help text, build config evidence, symbol table, and binary checksums.
- `results/`: extracted result lines and concise run summary.
- `commands.sh`: exact commands used to rebuild and run the final experiment.
- `result-summary.md`: human-readable conclusion and interpretation.

## Notes

The original prebuilt ELF in `spectre-v2/build/` only read one byte in this run.
The experiment copy was rebuilt with `SECRET_SZ=6` to validate the full default
secret `S3CreT`. No source-code change was required.

## Final Result

Final run recovered all 6 bytes of the secret:

```text
S3CreT
```

The top guesses matched the expected byte for all six bytes.
