#!/usr/bin/env bash
set -euo pipefail
POC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
case "${1:-fullstring}" in
  fullstring) exec "$POC_DIR/scripts/run-fullstring.sh" "${@:2}" ;;
  onebyte) exec "$POC_DIR/scripts/run-onebyte.sh" "${@:2}" ;;
  matrix) exec "$POC_DIR/scripts/run-matrix.sh" "${@:2}" ;;
  *) echo "usage: $0 [fullstring|onebyte|matrix]" >&2; exit 2 ;;
esac
