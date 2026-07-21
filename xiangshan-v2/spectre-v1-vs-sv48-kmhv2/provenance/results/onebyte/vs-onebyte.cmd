CELL=onebyte
MODE=vs
PREFIX=vs
WORKLOAD=/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v1-vs-sv48-kmhv2
CPPFLAGS=-DCACHE_HIT_THRESHOLD=50 -DUSE_FIXED_CACHE_HIT_THRESHOLD=1 -DSECRET_SZ=1 -DSECRET_OFFSET=0 -DATTACK_SAME_ROUNDS=3 -DTRAIN_TIMES=6 -DEARLY_STOP=0 -DEARLY_STOP_MIN_SCORE=3 -DEARLY_STOP_GAP=2 -DPROBE_CANDIDATES=62 -DFULL_BYTE_PROBE=0 -DFLUSH_LINES=256 -DSMOKE_FAST_BOOT=1 -DSMOKE_TRACE=1 -DROUNDS=1 -DCONTROL_ONLY=0 -DFILTER_KNOWN_NOISE=0 -DUSE_BASELINE_SUBTRACT=0
TIMEOUT_SEC=1200
EXPECT_PATTERN= r=
PASS_PATTERN=[vs] b0 e=53 g=53
EXPECT_REGEX=
PASS_REGEX=
EMU=/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu --no-diff -i /nfs/home/leizhenyu/opt/testbench/targets/xiangshan/logs/spectre-v1-sv48-fullstring-recovery-20260717/health-cells/vs-onebyte-spectre-v1-vs-sv48-kmhv2-riscv64-xs.elf
