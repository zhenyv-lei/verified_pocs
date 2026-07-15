#!/usr/bin/env bash
set -euo pipefail

ROOT=/nfs/home/leizhenyu/opt/testbench
WORKLOAD=$ROOT/targets/xiangshan/workloads/spectre-v2-privilege-kmhv2-run-20260714
LOGDIR=$ROOT/logs
AM_HOME=$ROOT/.local/nexus-am-kmhv2
EMU=/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu
MARCH=rv64gc_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zknd_zkne_zknh_zkr_zksed_zksh_zkt_zicbom_zicboz

build_and_run() {
  local offset="$1"
  local tag="$2"
  local asm_control="$3"
  local build_log="$LOGDIR/${tag}-build.log"
  local run_log="$LOGDIR/${tag}-run.log"

  make -C "$WORKLOAD" clean AM_HOME="$AM_HOME" ARCH=riscv64-xs >/dev/null 2>&1 || true
  make -C "$WORKLOAD" \
    AM_HOME="$AM_HOME" \
    ARCH=riscv64-xs \
    LINUX_GNU_TOOLCHAIN=1 \
    MARCH="$MARCH" \
    CC_OPT= \
    CPPFLAGS="-DCACHE_HIT_THRESHOLD=70 -DUSE_FIXED_CACHE_HIT_THRESHOLD=1 -DSECRET_SZ=1 -DSECRET_OFFSET=${offset} -DV2_ATTACK_TRIES=8 -DV2_TRAINING_LOOPS=16 -DPROBE_CANDIDATES=62 -DFULL_BYTE_PROBE=0 -DEARLY_STOP=1 -DEARLY_STOP_MIN_SCORE=2 -DEARLY_STOP_GAP=1 -DV2_EARLY_STOP_STRICT=0 -DV2_PROBE_MIX=1 -DSTRICT_PAGE_TABLE_DEMO=1 -DATTACKER_MPP=0 -DDIRECT_SERVICE_CALL=0 -DUSE_AM_CTE=0 -DV2_ASM_ROUND=1 -DV2_FIXED_MARKER=-1 -DV2_BYTE_WARMUP_ROUNDS=0 -DV2_ASM_CONTROL_ROUND=${asm_control} -DV2_PROBE_CONTROL_ROUND=0 -DV2_ASM_STYLE=0" \
    -j8 > "$build_log" 2>&1

  cp "$WORKLOAD/build/spectre-v2-privilege-riscv64-xs.elf" \
    "$WORKLOAD/build/spectre-v2-privilege-riscv64-xs-byte${offset}-${tag}.elf"

  timeout 10m "$EMU" --no-diff \
    -i "$WORKLOAD/build/spectre-v2-privilege-riscv64-xs-byte${offset}-${tag}.elf" \
    > "$run_log" 2>&1
}

build_and_run 0 spectre-v2-privilege-kmhv2-byte0-tries8-train16-th70 0
build_and_run 1 spectre-v2-privilege-kmhv2-byte1-tries8-train16-th70 0
build_and_run 2 spectre-v2-privilege-kmhv2-byte2-tries8-train16-th70 0
build_and_run 3 spectre-v2-privilege-kmhv2-byte3-tries8-train16-th70 0
build_and_run 4 spectre-v2-privilege-kmhv2-byte4-tries8-train16-th70 0
build_and_run 5 spectre-v2-privilege-kmhv2-byte5-tries8-train16-th70 0

# Auxiliary-only rerun for offset 2. Do not merge this into the baseline result.
build_and_run 2 spectre-v2-privilege-kmhv2-byte2-tries8-train16-th70-asmctrl1 1
