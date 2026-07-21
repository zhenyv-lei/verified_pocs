# Pending POC inventory - 2026-07-21

This file records POC-style directories that are present in the workspace but were
not included in the current 11-profile verified deliverable.

## Current verified scope

The verified deliverable currently covers the 11 profiles listed in
`POC_REGISTRY.tsv` and summarized in `POC_REPRODUCTION_STATUS_20260720.md`.

## Present but not yet standardized

These directories exist under `xiangshan-v2/` and contain source/runtime/provenance
material, but they do not yet have the standardized
`profiles/<bare|sv39|sv48>/reproduce/` layout and are not in `POC_REGISTRY.tsv`.

| Directory | Source entry |
| --- | --- |
| `xiangshan-v2/spectre-v1-hs-sv48-kmhv2` | `code/src/spectre-v1-hs-sv48-kmhv2.c` |
| `xiangshan-v2/spectre-v1-vs-sv48-kmhv2` | `code/src/spectre-v1-vs-sv48-kmhv2.c` |
| `xiangshan-v2/spectre-v1-vu-sv48-kmhv2` | `code/src/spectre-v1-vu-sv48-kmhv2.c` |
| `xiangshan-v2/spectre-v2-hs-sv39-kmhv2` | `code/src/spectre-v2-hs-sv39-kmhv2.c` |
| `xiangshan-v2/spectre-v2-vs-sv39-kmhv2` | `code/src/spectre-v2-vs-sv39-kmhv2.c` |
| `xiangshan-v2/spectre-v2-vu-sv39-kmhv2` | `code/src/spectre-v2-vu-sv39-kmhv2.c` |

## Present only in source testbench

The Spectre V4 workload has not been merged into this verified deliverable yet.
Its source remains in the original testbench tree:

- `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v4`
- `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v4/src/spectre-v4.c`
- `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v4/src/spectre-v4-gadget.S`
- `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/scripts/run-spectre-v4.sh`
