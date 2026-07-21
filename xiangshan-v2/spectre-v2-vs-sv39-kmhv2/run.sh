#!/usr/bin/env bash
set -euo pipefail

POC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
CODE_DIR="$POC_DIR/code"
LOG_DIR="${LOG_DIR:-$POC_DIR/run-logs/$(date +%Y%m%d-%H%M%S)}"

AM_HOME="${AM_HOME:-/nfs/home/leizhenyu/opt/testbench/.local/nexus-am-kmhv2}"
EMU="${EMU:-/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu}"
ARCH="${ARCH:-riscv64-xs}"
LINUX_GNU_TOOLCHAIN="${LINUX_GNU_TOOLCHAIN:-1}"
MARCH="${MARCH:-rv64gc_h_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zknd_zkne_zknh_zkr_zksed_zksh_zkt_zicbom_zicboz}"
CPPFLAGS="${CPPFLAGS:--DCACHE_HIT_THRESHOLD=70 -DUSE_FIXED_CACHE_HIT_THRESHOLD=0 -DSECRET_SZ=6 -DV2_ATTACK_TRIES=16 -DV2_TRAINING_LOOPS=32 -DPROBE_CANDIDATES=62 -DFULL_BYTE_PROBE=0 -DV2_ASM_CONTROL_ROUND=0 -DV2_PROBE_CONTROL_ROUND=0 -DV2_PROBE_MIX=0}"
TIMEOUT="${TIMEOUT:-30m}"

mkdir -p "$LOG_DIR"

make -C "$CODE_DIR" \
  AM_HOME="$AM_HOME" \
  ARCH="$ARCH" \
  LINUX_GNU_TOOLCHAIN="$LINUX_GNU_TOOLCHAIN" \
  MARCH="$MARCH" \
  CPPFLAGS="$CPPFLAGS" \
  -B -j4 > "$LOG_DIR/build.log" 2>&1

timeout "$TIMEOUT" stdbuf -oL -eL "$EMU" --no-diff \
  -i "$CODE_DIR/build/spectre-v2-vs-sv39-kmhv2-riscv64-xs.bin" \
  > "$LOG_DIR/run.log" 2>&1

grep -a '\[v2-vs-sv39\] byte\|\[v2-vs-sv39\] check\|\[vs\] done' "$LOG_DIR/run.log" \
  > "$LOG_DIR/result-lines.txt" || true

echo "$LOG_DIR"
