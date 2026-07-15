#!/usr/bin/env bash
set -euo pipefail

ROOT=/nfs/home/leizhenyu/opt/testbench
WORKLOAD=$ROOT/targets/xiangshan/workloads/spectre-v1-vmid-priv-kmhv2-run-20260713
LOGDIR=$ROOT/logs
AM_HOME=$ROOT/.local/nexus-am-kmhv2
EMU=/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu
MARCH=rv64gch_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zknd_zkne_zknh_zkr_zksed_zksh_zkt_zicbom_zicboz

for offset in 0 1 2 3 4 5; do
  tag="spectre-v1-vmid-priv-kmhv2-stable-byte${offset}"
  build_log="$LOGDIR/${tag}-build.log"
  run_log="$LOGDIR/${tag}-run.log"

  make -C "$WORKLOAD" clean AM_HOME="$AM_HOME" ARCH=riscv64-xs >/dev/null 2>&1 || true
  printf 'VMID_MARCH=%s\n' "$MARCH" > "$build_log"
  make -C "$WORKLOAD" \
    AM_HOME="$AM_HOME" \
    ARCH=riscv64-xs \
    LINUX_GNU_TOOLCHAIN=1 \
    MARCH="$MARCH" \
    CC_OPT= \
    CPPFLAGS="-DSECRET_SZ=1 -DSECRET_OFFSET=${offset} -DATTACK_SAME_ROUNDS=5 -DTRAIN_TIMES=10 -DUSE_FIXED_CACHE_HIT_THRESHOLD=1 -DCACHE_HIT_THRESHOLD=50 -DFILTER_KNOWN_NOISE=1 -DFULL_BYTE_PROBE=0 -DPROBE_CANDIDATES=62 -DEARLY_STOP=1 -DEARLY_STOP_MIN_SCORE=3 -DEARLY_STOP_GAP=2 -DATTACKER_VMID=17 -DVICTIM_VMID=23 -DFENCE_ON_VMID_SWITCH=0" \
    -j8 >> "$build_log" 2>&1

  cp "$WORKLOAD/build/spectre-v1-vmid-priv-riscv64-xs.elf" \
    "$WORKLOAD/build/spectre-v1-vmid-priv-riscv64-xs-byte${offset}.elf"

  timeout 20m "$EMU" --no-diff \
    -i "$WORKLOAD/build/spectre-v1-vmid-priv-riscv64-xs-byte${offset}.elf" \
    > "$run_log" 2>&1
done
