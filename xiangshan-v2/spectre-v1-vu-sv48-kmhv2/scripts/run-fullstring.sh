#!/usr/bin/env bash
set -euo pipefail
POC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
mkdir -p "$POC_DIR/provenance/runs"
env ROOT="$POC_DIR" WORKLOAD="$POC_DIR/code" RUN_DIR="$POC_DIR/provenance/runs" MODE=vu NAME=spectre-v1-vu-sv48-kmhv2   CELL=fullstring-smoke TIMEOUT_SEC=5400 MATCH_GRACE_SEC=2   "$POC_DIR/scripts/debug_sv48_health_cells.sh"
