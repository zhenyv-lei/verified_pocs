#!/usr/bin/env bash
set -euo pipefail

ROOT=/nfs/home/leizhenyu/opt/testbench
WORKLOAD=$ROOT/targets/xiangshan/workloads/spectre-v1-kmhv3-poc
EMU=/nfs/home/leizhenyu/opt/DUTs/XiangShan-V3/build/emu
AM_HOME=/nfs/home/leizhenyu/opt/DUTs/XiangShan-V3/third_party/nexus-am
MARCH=rv64gc_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zknd_zkne_zknh_zkr_zksed_zksh_zkt_zicbom_zicboz

# Known-good build command for the image used in this artifact.
# In the current managed sandbox, rebuilding with this AM_HOME may fail if the DUT tree is read-only.
make -C "$WORKLOAD" \
  AM_HOME="$AM_HOME" \
  ARCH=riscv64-xs-flash \
  LINUX_GNU_TOOLCHAIN=1 \
  MARCH="$MARCH" \
  CC_OPT= \
  CPPFLAGS="-DCACHE_HIT_THRESHOLD=80 -DUSE_FIXED_CACHE_HIT_THRESHOLD=1 -DSECRET_SZ=6 -DATTACK_SAME_ROUNDS=3 -DTRAIN_TIMES=6 -DFLUSH_CANDIDATE_LINES_ONLY=1 -DFLUSH_LINES=256" \
  -j8

# Successful run command used for the current repro.
timeout 40m "$EMU" --no-diff \
  -i "$WORKLOAD/build/spectre-v1-riscv64-xs-flash.bin"
