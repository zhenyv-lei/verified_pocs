# spectre-v1-asid-priv on Kunminghu V2 emu

This artifact records a local authorized XiangShan/Kunminghu V2 simulation run for:

- Workload: `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v1-asid-priv`
- Experiment copy: `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v1-asid-priv-kmhv2-run-20260713`
- Emulator: `/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu`

The experiment used a one-byte-at-a-time stable configuration:

- `SECRET_SZ=1`
- `SECRET_OFFSET=0..5`
- `ATTACK_SAME_ROUNDS=5`
- `TRAIN_TIMES=10`
- `USE_FIXED_CACHE_HIT_THRESHOLD=1`
- `CACHE_HIT_THRESHOLD=50`
- `FILTER_KNOWN_NOISE=1`
- `ATTACKER_ASID=17`
- `VICTIM_ASID=23`
- `FENCE_ON_ASID_SWITCH=0`

Result: all 6 byte runs passed, and the recovered secret is `S3CreT`.

Directory contents:

- `code/original/`: original workload `Makefile` and `src/`.
- `code/modified/`: experiment copy, including per-byte ELF outputs.
- `logs/`: per-byte build and emu run logs.
- `env/`: git/build/emulator/toolchain evidence.
- `env/scripts/`: relevant project runner scripts.
- `results/`: extracted result lines and recovered secret.
- `commands.sh`: exact command pattern used for this artifact.
- `result-summary.md`: concise result summary for documentation.
- `MANIFEST.txt`: file inventory.
- `SHA256SUMS.txt`: checksums for artifact files.
