#!/usr/bin/env bash
set -euo pipefail

ROOT=${ROOT:-/nfs/home/leizhenyu/opt/testbench}
LOGDIR=${LOGDIR:-$ROOT/targets/xiangshan/logs/spectre-v1-sv48-fullstring-matrix-20260720}
EMU=${EMU:-/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu}
AM_HOME=${AM_HOME:-$ROOT/.local/nexus-am-kmhv2}
ARCH=${ARCH:-riscv64-xs}
MARCH=${MARCH:-rv64gc_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zknd_zkne_zknh_zkr_zksed_zksh_zkt_zicbom_zicboz}
MODE=${MODE:-hs}
case "$MODE" in
  hs|vu|vs) ;;
  *)
    echo "unknown MODE=$MODE" >&2
    exit 2
    ;;
esac

PREFIX=${PREFIX:-$MODE}
CELL_TAG=${CELL_TAG:-matrix-${MODE}-th${CACHE_HIT_THRESHOLD:-80}-r${ATTACK_SAME_ROUNDS:-3}-t${TRAIN_TIMES:-6}}
WORKLOAD=${WORKLOAD:-$ROOT/targets/xiangshan/workloads/spectre-v1-${MODE}-sv48-kmhv2}
NAME=${NAME:-spectre-v1-${MODE}-sv48-kmhv2}

CACHE_HIT_THRESHOLD=${CACHE_HIT_THRESHOLD:-80}
USE_FIXED_CACHE_HIT_THRESHOLD=${USE_FIXED_CACHE_HIT_THRESHOLD:-1}
SECRET_SZ=${SECRET_SZ:-6}
SECRET_OFFSET=${SECRET_OFFSET:-0}
ATTACK_SAME_ROUNDS=${ATTACK_SAME_ROUNDS:-3}
TRAIN_TIMES=${TRAIN_TIMES:-6}
EARLY_STOP=${EARLY_STOP:-0}
EARLY_STOP_MIN_SCORE=${EARLY_STOP_MIN_SCORE:-3}
EARLY_STOP_GAP=${EARLY_STOP_GAP:-2}
PROBE_CANDIDATES=${PROBE_CANDIDATES:-62}
FULL_BYTE_PROBE=${FULL_BYTE_PROBE:-0}
FLUSH_LINES=${FLUSH_LINES:-256}
SMOKE_FAST_BOOT=${SMOKE_FAST_BOOT:-1}
SMOKE_TRACE=${SMOKE_TRACE:-1}
ROUNDS=${ROUNDS:-1}
CONTROL_ONLY=${CONTROL_ONLY:-0}
FILTER_KNOWN_NOISE=${FILTER_KNOWN_NOISE:-0}
USE_BASELINE_SUBTRACT=${USE_BASELINE_SUBTRACT:-0}
CC_OPT=${CC_OPT:--O2}
TIMEOUT_SEC=${TIMEOUT_SEC:-5400}
MATCH_GRACE_SEC=${MATCH_GRACE_SEC:-2}

ART_DIR="$LOGDIR/health-cells"
mkdir -p "$ART_DIR"

CPPFLAGS_CELL="-DCACHE_HIT_THRESHOLD=${CACHE_HIT_THRESHOLD} -DUSE_FIXED_CACHE_HIT_THRESHOLD=${USE_FIXED_CACHE_HIT_THRESHOLD} -DSECRET_SZ=${SECRET_SZ} -DSECRET_OFFSET=${SECRET_OFFSET} -DATTACK_SAME_ROUNDS=${ATTACK_SAME_ROUNDS} -DTRAIN_TIMES=${TRAIN_TIMES} -DEARLY_STOP=${EARLY_STOP} -DEARLY_STOP_MIN_SCORE=${EARLY_STOP_MIN_SCORE} -DEARLY_STOP_GAP=${EARLY_STOP_GAP} -DPROBE_CANDIDATES=${PROBE_CANDIDATES} -DFULL_BYTE_PROBE=${FULL_BYTE_PROBE} -DFLUSH_LINES=${FLUSH_LINES} -DSMOKE_FAST_BOOT=${SMOKE_FAST_BOOT} -DSMOKE_TRACE=${SMOKE_TRACE} -DROUNDS=${ROUNDS} -DCONTROL_ONLY=${CONTROL_ONLY} -DFILTER_KNOWN_NOISE=${FILTER_KNOWN_NOISE} -DUSE_BASELINE_SUBTRACT=${USE_BASELINE_SUBTRACT}"

BUILD_LOG="$ART_DIR/${CELL_TAG}-build.log"
RUN_LOG="$ART_DIR/${CELL_TAG}-run.log"
CMD_LOG="$ART_DIR/${CELL_TAG}.cmd"
ELF_SRC="$WORKLOAD/build/${NAME}-${ARCH}.elf"
ELF_DST="$ART_DIR/${CELL_TAG}-${NAME}-${ARCH}.elf"
VERDICT="$ART_DIR/${CELL_TAG}.verdict"

{
  echo "CELL_TAG=$CELL_TAG"
  echo "MODE=$MODE"
  echo "PREFIX=$PREFIX"
  echo "WORKLOAD=$WORKLOAD"
  echo "CPPFLAGS=$CPPFLAGS_CELL"
  echo "TIMEOUT_SEC=$TIMEOUT_SEC"
  echo "MATCH_GRACE_SEC=$MATCH_GRACE_SEC"
  echo "EMU=$EMU --no-diff -i $ELF_DST"
} > "$CMD_LOG"

cd "$WORKLOAD"
AM_HOME="$AM_HOME" make clean > "$BUILD_LOG" 2>&1
CPPFLAGS="$CPPFLAGS_CELL" CC_OPT="$CC_OPT" make \
  ARCH="$ARCH" \
  MARCH="$MARCH" \
  LINUX_GNU_TOOLCHAIN=1 \
  AM_HOME="$AM_HOME" >> "$BUILD_LOG" 2>&1

cp "$ELF_SRC" "$ELF_DST"
sha256sum "$ELF_DST" > "$ART_DIR/${CELL_TAG}.sha256"

{
  date -Is
  echo "$EMU --no-diff -i $ELF_DST"
} > "$RUN_LOG"

"$EMU" --no-diff -i "$ELF_DST" >> "$RUN_LOG" 2>&1 &
emu_pid=$!
deadline=$((SECONDS + TIMEOUT_SEC))
matched=0
EXPECT_REGEX="^\\[${PREFIX}\\] b5 .* r="
PASS_REGEX="$EXPECT_REGEX"

while kill -0 "$emu_pid" 2>/dev/null; do
  if rg -q "$EXPECT_REGEX" "$RUN_LOG"; then
    matched=1
    break
  fi
  if [ "$SECONDS" -ge "$deadline" ]; then
    break
  fi
  sleep 1
done

if kill -0 "$emu_pid" 2>/dev/null; then
  if [ "$matched" -eq 1 ] && [ "$MATCH_GRACE_SEC" -gt 0 ]; then
    sleep "$MATCH_GRACE_SEC"
  fi
  kill "$emu_pid" 2>/dev/null || true
  sleep 1
  kill -9 "$emu_pid" 2>/dev/null || true
fi
wait "$emu_pid" 2>/dev/null || true

{
  echo "EMU_MONITOR_DONE matched=$matched"
  date -Is
} >> "$RUN_LOG"

if rg -q "$PASS_REGEX" "$RUN_LOG"; then
  echo "PASS cell=$CELL_TAG matched_regex=$PASS_REGEX" > "$VERDICT"
  exit 0
fi

if rg -q -F "[${PREFIX}] b5" "$RUN_LOG"; then
  echo "FAIL cell=$CELL_TAG observed=[${PREFIX}] b5 missing_pass_regex=$PASS_REGEX" > "$VERDICT"
  exit 0
fi

if [ "$SECONDS" -ge "$deadline" ]; then
  echo "TIMEOUT cell=$CELL_TAG missing=^\\[${PREFIX}\\] b5 .* r=" > "$VERDICT"
  exit 124
fi

echo "FAIL cell=$CELL_TAG missing=^\\[${PREFIX}\\] b5 .* r=" > "$VERDICT"
exit 1
