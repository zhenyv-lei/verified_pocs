# spectre-v2-privilege on Kunminghu V2 emu

This artifact records a local authorized XiangShan/Kunminghu V2 simulation run for:

- Workload: `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v2-privilege`
- Experiment copy: `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v2-privilege-kmhv2-run-20260714`
- Emulator: `/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu`

The baseline experiment used a one-byte-at-a-time configuration based on the existing project byte-sweep runner:

```text
ARCH=riscv64-xs
SECRET_SZ=1
SECRET_OFFSET=0..5
CACHE_HIT_THRESHOLD=70
USE_FIXED_CACHE_HIT_THRESHOLD=1
V2_ATTACK_TRIES=8
V2_TRAINING_LOOPS=16
PROBE_CANDIDATES=62
V2_PROBE_MIX=1
EARLY_STOP=1
EARLY_STOP_MIN_SCORE=2
EARLY_STOP_GAP=1
STRICT_PAGE_TABLE_DEMO=1
ATTACKER_MPP=0
DIRECT_SERVICE_CALL=0
USE_AM_CTE=0
V2_ASM_ROUND=1
V2_ASM_CONTROL_ROUND=0
```

Baseline result: `5/6` bytes passed. The baseline recovered string is `S3preT`; expected string is `S3CreT`.

The only baseline failure was offset 2:

```text
expected=C(0x43), guess=p(0x70), second=q(0x71), expected_score=3
top4=p:4,q:4,C:3,7:1
check=FAIL
```

An auxiliary rerun of offset 2 with `V2_ASM_CONTROL_ROUND=1` is included for reference only. It produced `guess=C` and `check=PASS`, but this artifact does not use that auxiliary result as the baseline conclusion.

Directory contents:

- `code/original/`: original workload source and current build outputs.
- `code/experiment-copy/`: experiment copy, including generated per-byte ELF files.
- `logs/`: current build/run logs and selected-result summary.
- `logs/historical/`: relevant prior project logs for comparison.
- `env/`: git/build/emulator/toolchain evidence.
- `results/`: baseline byte results, baseline recovered secret, expected secret, and auxiliary control-round note.
- `commands.sh`: command pattern used for the baseline sweep and the auxiliary rerun.
- `result-summary.md`: concise result summary for documentation.
- `MANIFEST.txt`, `SHA256SUMS.txt`: inventory and checksums.
