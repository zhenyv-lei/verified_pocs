#!/usr/bin/env bash
set -euo pipefail

WORKLOAD_DIR=/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v1-kmhv2-run-20260713
AM_HOME_LOCAL=/nfs/home/leizhenyu/opt/testbench/.local/nexus-am-kmhv2
EMU=/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu
LOG_DIR=/nfs/home/leizhenyu/opt/testbench/logs

make -C "$WORKLOAD_DIR" \
  AM_HOME="$AM_HOME_LOCAL" \
  ARCH=riscv64-xs-flash \
  LINUX_GNU_TOOLCHAIN=1 \
  MARCH=rv64gc_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zknd_zkne_zknh_zkr_zksed_zksh_zkt_zicbom_zicboz \
  CC_OPT= \
  CPPFLAGS="-DSECRET_SZ=6 -DATTACK_SAME_ROUNDS=2 -DTRAIN_TIMES=10" \
  -j8 \
  > "$LOG_DIR/spectre-v1-kmhv2-array-rebuild.log" 2>&1

timeout 30m "$EMU" --no-diff \
  -i "$WORKLOAD_DIR/build/spectre-v1-riscv64-xs-flash.elf" \
  > "$LOG_DIR/spectre-v1-kmhv2-array-run.log" 2>&1

grep -a 'want(' "$LOG_DIR/spectre-v1-kmhv2-array-run.log"
