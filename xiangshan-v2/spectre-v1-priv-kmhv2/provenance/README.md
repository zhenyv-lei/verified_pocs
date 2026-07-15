# Spectre V1 Privileged Interface on XiangShan Kunminghu V2

Date: 2026-07-13

This bundle records the local authorized Spectre V1 privileged-interface
experiment run against the current XiangShan Kunminghu V2 Verilator emulator.

- DUT root: `/nfs/home/leizhenyu/opt/DUTs/XiangShan`
- DUT branch: `kunminghu-v2`
- DUT commit: `2acbf327c`
- Emulator: `/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu`
- Effective emulator target: `/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/verilator-compile/emu`
- Original workload: `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v1-priv`
- Experiment copy: `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v1-priv-kmhv2-run-20260713`

## Directory Contents

- `code/original/`: original `spectre-v1-priv` Makefile and source files.
- `code/modified/`: experiment copy, including rebuilt `build/` outputs.
- `code/source.diff`: source delta between original and experiment copy. It is empty for this run.
- `logs/`: final rebuild/run logs and the earlier flash-format attempt logs.
- `env/`: DUT git status, emulator metadata, build config evidence, symbol table, scripts, and binary checksums.
- `results/`: extracted result lines and concise run summary.
- `commands.sh`: exact commands used to rebuild and run the final experiment.
- `result-summary.md`: human-readable conclusion and interpretation.

## Notes

The old prebuilt `spectre-v1-priv-riscv64-xs-flash.elf` dependency file pointed
to a previous `XiangShan-V3` AM path, so the final evidence was rebuilt in a new
copy using the local writable AM tree under the current testbench.

An initial manual rebuild with `ARCH=riscv64-xs-flash` did not progress beyond
early emulator initialization in the allotted observation window. The project
script and documentation use `ARCH=riscv64-xs` for this workload, so the final
run uses `spectre-v1-priv-riscv64-xs.elf`.

## Final Result

Final run recovered all 6 bytes of the secret:

```text
S3CreT
```

The direct U-mode secret load faulted as expected, and the run ended with:

```text
[v1-priv] check=PASS
```
