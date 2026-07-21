#!/usr/bin/env bash
set -euo pipefail

cat <<'CMDS'
run.sh fullstring
run.sh onebyte
run.sh matrix
CMDS
