#!/usr/bin/env bash
set -euo pipefail

WORKLOAD=/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v2-vu-sv39-kmhv2
AM_HOME=/nfs/home/leizhenyu/opt/testbench/.local/nexus-am-kmhv2
EMU=/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu
MARCH=rv64gc_h_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zknd_zkne_zknh_zkr_zksed_zksh_zkt_zicbom_zicboz
LOGDIR=/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/logs/spectre-v2-sv39-multimode-20260720

make -C "$WORKLOAD" AM_HOME="$AM_HOME" ARCH=riscv64-xs \
  LINUX_GNU_TOOLCHAIN=1 MARCH="$MARCH" -j4

timeout 120 stdbuf -oL -eL "$EMU" --no-diff \
  -i "$WORKLOAD/build/spectre-v2-vu-sv39-kmhv2-riscv64-xs.bin" \
  > "$LOGDIR/spectre-v2-vu-sv39-kmhv2-full-xs.log" 2>&1
