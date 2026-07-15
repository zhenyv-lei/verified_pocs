# spectre-v1-kmhv3-poc full-string repro on XiangShan V3

This artifact records a full-string Spectre V1 PoC repro on:

- Emulator: `/nfs/home/leizhenyu/opt/DUTs/XiangShan-V3/build/emu`
- Workload: `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v1-kmhv3-poc`
- Image used for the successful repro: `build/spectre-v1-riscv64-xs-flash.bin`

Successful run command:

```bash
/nfs/home/leizhenyu/opt/DUTs/XiangShan-V3/build/emu --no-diff \
  -i /nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v1-kmhv3-poc/build/spectre-v1-riscv64-xs-flash.bin
```

The image was built with the known-good full-string parameters:

```text
ARCH=riscv64-xs-flash
MARCH=rv64gc_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zknd_zkne_zknh_zkr_zksed_zksh_zkt_zicbom_zicboz
AM_HOME=/nfs/home/leizhenyu/opt/DUTs/XiangShan-V3/third_party/nexus-am
CPPFLAGS=-DCACHE_HIT_THRESHOLD=80 -DUSE_FIXED_CACHE_HIT_THRESHOLD=1 -DSECRET_SZ=6 -DATTACK_SAME_ROUNDS=3 -DTRAIN_TIMES=6 -DFLUSH_CANDIDATE_LINES_ONLY=1 -DFLUSH_LINES=256
```

Result: full string recovered as `S3CreT`; the run ended with `HIT GOOD TRAP`.

Notes:

- A rebuild attempt using the original DUT `AM_HOME` from inside the current managed sandbox failed because the DUT AM build directory is read-only here. The failed build log is included.
- The successful current repro therefore re-ran the existing known-good flash image in the original workload directory.
- `-F <flash.bin>` was also tried and did not produce useful output in the observation window; the successful current run used `-i <flash.bin>`, matching the successful log behavior.

Directory contents:

- `code/original/`: original workload source and build outputs.
- `code/experiment-copy/`: copied source used for non-destructive build attempts.
- `logs/`: current run log, failed build attempt, failed `-F` attempt, and historical success log.
- `results/`: extracted key lines, byte results, expected secret, recovered secret.
- `env/`: git/toolchain/emulator/build metadata.
- `commands.sh`: command record for reproducing the run.
- `result-summary.md`: concise result summary.
- `MANIFEST.txt`, `SHA256SUMS.txt`: inventory and checksums.
