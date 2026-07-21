#!/usr/bin/env bash
set -euo pipefail
POC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
mkdir -p "$POC_DIR/provenance/runs"
env ROOT="$POC_DIR" WORKLOAD="$POC_DIR/code" LOGDIR="$POC_DIR/provenance/runs" MODE=hs NAME=spectre-v1-hs-sv48-kmhv2   CELL=${CELL:-fullstring-smoke} TIMEOUT_SEC=${TIMEOUT_SEC:-5400} MATCH_GRACE_SEC=${MATCH_GRACE_SEC:-2}   CACHE_HIT_THRESHOLD=${CACHE_HIT_THRESHOLD:-80} ATTACK_SAME_ROUNDS=${ATTACK_SAME_ROUNDS:-3} TRAIN_TIMES=${TRAIN_TIMES:-6}   "$POC_DIR/scripts/run_param_matrix_cell.sh"
