#!/usr/bin/env bash
set -euo pipefail

BASE=${BASE:-/nfs/home/leizhenyu/opt/verified_poc}
EMU_V2=${EMU_V2:-/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu}
EMU_V3=${EMU_V3:-/nfs/home/leizhenyu/opt/DUTs/XiangShan-V3/build/emu}
AM_HOME_V2=${AM_HOME_V2:-/nfs/home/leizhenyu/opt/testbench/.local/nexus-am-kmhv2}
AM_HOME_V3=${AM_HOME_V3:-/nfs/home/leizhenyu/opt/DUTs/XiangShan-V3/third_party/nexus-am}
MARCH_GC=${MARCH_GC:-rv64gc_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zknd_zkne_zknh_zkr_zksed_zksh_zkt_zicbom_zicboz}
MARCH_GCH=${MARCH_GCH:-rv64gch_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zknd_zkne_zknh_zkr_zksed_zksh_zkt_zicbom_zicboz}
RUN_ID=${RUN_ID:-$(date +%Y%m%d-%H%M%S)}

selected=${1:-all}

make_clean() {
  local code=$1
  local arch=$2
  local am_home=$3
  make -C "$code" clean AM_HOME="$am_home" ARCH="$arch" >/dev/null 2>&1 || true
}

extract_common() {
  local run_log=$1
  local out=$2
  strings -a "$run_log" | grep -E '^\[v|^m\[|^want\(|^check |^HIT GOOD TRAP|^instrCnt|fault_seen=|check=|top4=|byte [0-9]|reading [0-9]|recovered|calibration|model=' > "$out" || true
}

run_v1_kmhv2() {
  local name=spectre-v1-poc-kmhv2
  local code="$BASE/xiangshan-v2/$name/code"
  local out="$BASE/logs/xiangshan-v2/$name/$RUN_ID"
  mkdir -p "$out"
  make_clean "$code" riscv64-xs-flash "$AM_HOME_V2"
  make -C "$code" AM_HOME="$AM_HOME_V2" ARCH=riscv64-xs-flash LINUX_GNU_TOOLCHAIN=1 MARCH="$MARCH_GC" CC_OPT= CPPFLAGS="-DSECRET_SZ=6 -DATTACK_SAME_ROUNDS=2 -DTRAIN_TIMES=10" -j8 > "$out/build.log" 2>&1
  timeout 30m "$EMU_V2" --no-diff -i "$code/build/spectre-v1-riscv64-xs-flash.elf" > "$out/run.log" 2>&1
  extract_common "$out/run.log" "$out/result-lines.txt"
}

run_v2_kmhv2() {
  local name=spectre-v2-poc-kmhv2
  local code="$BASE/xiangshan-v2/$name/code"
  local out="$BASE/logs/xiangshan-v2/$name/$RUN_ID"
  mkdir -p "$out"
  make_clean "$code" riscv64-xs "$AM_HOME_V2"
  make -C "$code" AM_HOME="$AM_HOME_V2" ARCH=riscv64-xs LINUX_GNU_TOOLCHAIN=1 MARCH="$MARCH_GC" CC_OPT= CPPFLAGS="-DSECRET_SZ=6 -DV2_ATTACK_TRIES=2 -DV2_TRAINING_LOOPS=16" -j8 > "$out/build.log" 2>&1
  timeout 30m "$EMU_V2" --no-diff -i "$code/build/spectre-v2-riscv64-xs.elf" > "$out/run.log" 2>&1
  extract_common "$out/run.log" "$out/result-lines.txt"
}

run_v1_priv_kmhv2() {
  local name=spectre-v1-priv-kmhv2
  local code="$BASE/xiangshan-v2/$name/code"
  local out="$BASE/logs/xiangshan-v2/$name/$RUN_ID"
  mkdir -p "$out"
  make_clean "$code" riscv64-xs "$AM_HOME_V2"
  make -C "$code" AM_HOME="$AM_HOME_V2" ARCH=riscv64-xs LINUX_GNU_TOOLCHAIN=1 MARCH="$MARCH_GC" CC_OPT= CPPFLAGS="-DCACHE_HIT_THRESHOLD=70 -DUSE_FIXED_CACHE_HIT_THRESHOLD=0 -DSECRET_SZ=6 -DPROBE_CANDIDATES=62 -DATTACK_SAME_ROUNDS=5 -DTRAIN_TIMES=10 -DFLUSH_LINES=256 -DDIRECT_SERVICE_CALL=0 -DUSE_AM_CTE=0 -DATTACKER_MPP=0 -DSTRICT_PAGE_TABLE_DEMO=1 -DFULL_BYTE_PROBE=0 -DEARLY_STOP=1 -DEARLY_STOP_MIN_SCORE=3 -DEARLY_STOP_GAP=2" -j8 > "$out/build.log" 2>&1
  timeout 30m "$EMU_V2" --no-diff -i "$code/build/spectre-v1-priv-riscv64-xs.elf" > "$out/run.log" 2>&1
  extract_common "$out/run.log" "$out/result-lines.txt"
}

run_v1_asid_kmhv2() {
  local name=spectre-v1-asid-kmhv2
  local code="$BASE/xiangshan-v2/$name/code"
  local out="$BASE/logs/xiangshan-v2/$name/$RUN_ID"
  mkdir -p "$out"
  make_clean "$code" riscv64-xs "$AM_HOME_V2"
  make -C "$code" AM_HOME="$AM_HOME_V2" ARCH=riscv64-xs LINUX_GNU_TOOLCHAIN=1 MARCH="$MARCH_GC" CC_OPT= CPPFLAGS="-DSECRET_SZ=6 -DSECRET_OFFSET=0 -DATTACK_SAME_ROUNDS=5 -DTRAIN_TIMES=10 -DUSE_FIXED_CACHE_HIT_THRESHOLD=1 -DCACHE_HIT_THRESHOLD=50 -DFILTER_KNOWN_NOISE=1 -DFULL_BYTE_PROBE=0 -DPROBE_CANDIDATES=62 -DEARLY_STOP=1 -DEARLY_STOP_MIN_SCORE=3 -DEARLY_STOP_GAP=2 -DATTACKER_ASID=17 -DVICTIM_ASID=23 -DFENCE_ON_ASID_SWITCH=0" -j8 > "$out/build.log" 2>&1
  timeout 30m "$EMU_V2" --no-diff -i "$code/build/spectre-v1-asid-priv-riscv64-xs.elf" > "$out/run.log" 2>&1
  extract_common "$out/run.log" "$out/result-lines.txt"
}

run_v1_vmid_kmhv2() {
  local name=spectre-v1-vmid-kmhv2
  local code="$BASE/xiangshan-v2/$name/code"
  local out="$BASE/logs/xiangshan-v2/$name/$RUN_ID"
  mkdir -p "$out"
  make_clean "$code" riscv64-xs "$AM_HOME_V2"
  make -C "$code" AM_HOME="$AM_HOME_V2" ARCH=riscv64-xs LINUX_GNU_TOOLCHAIN=1 MARCH="$MARCH_GCH" CC_OPT= CPPFLAGS="-DSECRET_SZ=6 -DSECRET_OFFSET=0 -DATTACK_SAME_ROUNDS=5 -DTRAIN_TIMES=10 -DUSE_FIXED_CACHE_HIT_THRESHOLD=1 -DCACHE_HIT_THRESHOLD=50 -DFILTER_KNOWN_NOISE=1 -DFULL_BYTE_PROBE=0 -DPROBE_CANDIDATES=62 -DEARLY_STOP=1 -DEARLY_STOP_MIN_SCORE=3 -DEARLY_STOP_GAP=2 -DATTACKER_VMID=17 -DVICTIM_VMID=23 -DFENCE_ON_VMID_SWITCH=0" -j8 > "$out/build.log" 2>&1
  timeout 30m "$EMU_V2" --no-diff -i "$code/build/spectre-v1-vmid-priv-riscv64-xs.elf" > "$out/run.log" 2>&1
  extract_common "$out/run.log" "$out/result-lines.txt"
}

run_v2_privilege_kmhv2() {
  local name=spectre-v2-privilege-kmhv2
  local code="$BASE/xiangshan-v2/$name/code"
  local out="$BASE/logs/xiangshan-v2/$name/$RUN_ID"
  mkdir -p "$out"
  make_clean "$code" riscv64-xs "$AM_HOME_V2"
  make -C "$code" AM_HOME="$AM_HOME_V2" ARCH=riscv64-xs LINUX_GNU_TOOLCHAIN=1 MARCH="$MARCH_GC" CC_OPT= CPPFLAGS="-DCACHE_HIT_THRESHOLD=60 -DUSE_FIXED_CACHE_HIT_THRESHOLD=1 -DSECRET_SZ=6 -DSECRET_OFFSET=0 -DV2_ATTACK_TRIES=8 -DV2_TRAINING_LOOPS=16 -DPROBE_CANDIDATES=62 -DFULL_BYTE_PROBE=0 -DEARLY_STOP=1 -DEARLY_STOP_MIN_SCORE=2 -DEARLY_STOP_GAP=1 -DV2_EARLY_STOP_STRICT=0 -DV2_PROBE_MIX=1 -DSTRICT_PAGE_TABLE_DEMO=1 -DATTACKER_MPP=0 -DDIRECT_SERVICE_CALL=0 -DUSE_AM_CTE=0 -DV2_ASM_ROUND=1 -DV2_FIXED_MARKER=-1 -DV2_BYTE_WARMUP_ROUNDS=0 -DV2_EXTRA_CHANNEL_FLUSHES=0 -DV2_ASM_CONTROL_ROUND=0 -DV2_PROBE_CONTROL_ROUND=0 -DV2_ASM_STYLE=0" -j8 > "$out/build.log" 2>&1
  timeout 20m "$EMU_V2" --no-diff -i "$code/build/spectre-v2-privilege-riscv64-xs.elf" > "$out/run.log" 2>&1
  extract_common "$out/run.log" "$out/result-lines.txt"
}

run_v1_kmhv3() {
  local name=spectre-v1-poc-kmhv3
  local code="$BASE/xiangshan-v3/$name/code"
  local out="$BASE/logs/xiangshan-v3/$name/$RUN_ID"
  mkdir -p "$out"
  make_clean "$code" riscv64-xs-flash "$AM_HOME_V3"
  make -C "$code" AM_HOME="$AM_HOME_V3" ARCH=riscv64-xs-flash LINUX_GNU_TOOLCHAIN=1 MARCH="$MARCH_GC" CC_OPT= CPPFLAGS="-DCACHE_HIT_THRESHOLD=80 -DUSE_FIXED_CACHE_HIT_THRESHOLD=1 -DSECRET_SZ=6 -DATTACK_SAME_ROUNDS=3 -DTRAIN_TIMES=6 -DFLUSH_CANDIDATE_LINES_ONLY=1 -DFLUSH_LINES=256" -j8 > "$out/build.log" 2>&1
  timeout 40m "$EMU_V3" --no-diff -i "$code/build/spectre-v1-riscv64-xs-flash.bin" > "$out/run.log" 2>&1
  extract_common "$out/run.log" "$out/result-lines.txt"
}

run_one() {
  case "$1" in
    spectre-v1-poc-kmhv2) run_v1_kmhv2 ;;
    spectre-v2-poc-kmhv2) run_v2_kmhv2 ;;
    spectre-v1-priv-kmhv2) run_v1_priv_kmhv2 ;;
    spectre-v1-asid-kmhv2) run_v1_asid_kmhv2 ;;
    spectre-v1-vmid-kmhv2) run_v1_vmid_kmhv2 ;;
    spectre-v2-privilege-kmhv2) run_v2_privilege_kmhv2 ;;
    spectre-v1-poc-kmhv3) run_v1_kmhv3 ;;
    *) echo "unknown PoC: $1" >&2; return 2 ;;
  esac
}

if [[ "$selected" == "all" ]]; then
  for poc in \
    spectre-v1-poc-kmhv2 \
    spectre-v2-poc-kmhv2 \
    spectre-v1-priv-kmhv2 \
    spectre-v1-asid-kmhv2 \
    spectre-v1-vmid-kmhv2 \
    spectre-v2-privilege-kmhv2 \
    spectre-v1-poc-kmhv3; do
    echo "=== running $poc RUN_ID=$RUN_ID ==="
    run_one "$poc"
  done
else
  echo "=== running $selected RUN_ID=$RUN_ID ==="
  run_one "$selected"
fi

echo "RUN_ID=$RUN_ID"
