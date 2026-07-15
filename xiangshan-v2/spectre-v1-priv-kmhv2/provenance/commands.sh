#!/usr/bin/env bash
set -euo pipefail

WORKLOAD_DIR=/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v1-priv-kmhv2-run-20260713
AM_HOME_LOCAL=/nfs/home/leizhenyu/opt/testbench/.local/nexus-am-kmhv2
EMU=/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu
LOG_DIR=/nfs/home/leizhenyu/opt/testbench/logs

make -C "$WORKLOAD_DIR" \
  AM_HOME="$AM_HOME_LOCAL" \
  ARCH=riscv64-xs \
  LINUX_GNU_TOOLCHAIN=1 \
  MARCH=rv64gc_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zknd_zkne_zknh_zkr_zksed_zksh_zkt_zicbom_zicboz \
  CC_OPT= \
  CPPFLAGS="-DCACHE_HIT_THRESHOLD=70 -DUSE_FIXED_CACHE_HIT_THRESHOLD=0 -DSECRET_SZ=6 -DPROBE_CANDIDATES=62 -DATTACK_SAME_ROUNDS=5 -DTRAIN_TIMES=10 -DFLUSH_LINES=256 -DDIRECT_SERVICE_CALL=0 -DUSE_AM_CTE=0 -DATTACKER_MPP=0 -DSTRICT_PAGE_TABLE_DEMO=1 -DFULL_BYTE_PROBE=0 -DEARLY_STOP=1 -DEARLY_STOP_MIN_SCORE=3 -DEARLY_STOP_GAP=2" \
  -j8 \
  > "$LOG_DIR/spectre-v1-priv-kmhv2-riscv64-xs-rebuild.log" 2>&1

timeout 30m "$EMU" --no-diff \
  -i "$WORKLOAD_DIR/build/spectre-v1-priv-riscv64-xs.elf" \
  > "$LOG_DIR/spectre-v1-priv-kmhv2-riscv64-xs-run.log" 2>&1

grep -a '\[v1-priv\] byte\|\[v1-priv\] check\|\[v1-priv\] isolation\|\[v1-priv\] traps' \
  "$LOG_DIR/spectre-v1-priv-kmhv2-riscv64-xs-run.log"
