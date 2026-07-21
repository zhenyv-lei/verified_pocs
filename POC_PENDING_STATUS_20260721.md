# Pending POC inventory - 2026-07-21

This file records POC-style directories that are present in the workspace but were
not included in the current 11-profile verified deliverable.

## Current verified scope

The verified deliverable currently covers the profiles listed in
`POC_REGISTRY.tsv`: the original 11 profiles summarized in
`POC_REPRODUCTION_STATUS_20260720.md`, plus six 2026-07-21 candidate profiles
that now have full parseable results.

## Standardized candidate profiles

These directories exist under `xiangshan-v2/` and now have the standardized
`profiles/<bare|sv39|sv48>/reproduce/` layout. Profiles are promoted into
`POC_REGISTRY.tsv` only after a full run produces a recorded `ASSERTION_PASS` or
`ASSERTION_FAIL` result.

| Directory | Candidate profile | Parser kind | Runtime | Registry state |
| --- | --- | --- | --- | --- |
| `xiangshan-v2/spectre-v1-hs-sv48-kmhv2` | `profiles/sv48` | `v1-hs-sv48` | `runtime/kmhv2-emu/emu` | promoted, `ASSERTION_PASS` |
| `xiangshan-v2/spectre-v1-vs-sv48-kmhv2` | `profiles/sv48` | `v1-vs-sv48` | `runtime/kmhv2-emu/emu` | promoted, `ASSERTION_FAIL` |
| `xiangshan-v2/spectre-v1-vu-sv48-kmhv2` | `profiles/sv48` | `v1-vu-sv48` | `runtime/kmhv2-emu/emu` | promoted, `ASSERTION_FAIL` |
| `xiangshan-v2/spectre-v2-hs-sv39-kmhv2` | `profiles/sv39` | `v2-hs-sv39` | `runtime/kmhv2-emu/emu` | promoted, `ASSERTION_FAIL` |
| `xiangshan-v2/spectre-v2-vs-sv39-kmhv2` | `profiles/sv39` | `v2-vs-sv39` | `runtime/kmhv2-emu/emu` | promoted, `ASSERTION_FAIL` |
| `xiangshan-v2/spectre-v2-vu-sv39-kmhv2` | `profiles/sv39` | `v2-vu-sv39` | `runtime/kmhv2-emu/emu` | promoted, `ASSERTION_FAIL` |

## Preparation checks

The candidate profiles were prepared with the same runner contract as the 11
verified profiles:

- `reproduce/{run,build,parse,verify}.sh` dispatch to `tools/profile_runner.sh`
- `source/` is self-contained and builds from scratch under `.scratch`
- `runtime/kmhv2-emu/emu` is a materialized executable copy
- `profile.conf` pins `SOURCE_TREE_SHA256`, `EMU_SHA256`, parser kind, 6-byte
  `EXPECTED_SECRET=S3CreT`, and wall timeout
- preflight/package checks passed for all six profiles under
  `20260721Tprep-*`; the v1 candidate-id rename was rechecked under
  `20260721Tprep2-*`
- build checks passed for all six profiles: v1 hs/vs/vu under
  `20260721Tbuild3-*`; v2 hs/vs/vu under `20260721Tbuild4-*` after increasing
  their wall timeout to `120m`
- the runner now reports `ASSERTION_PASS` when parsing proves the full expected
  string, while still preserving `run_exit=124` and `timeout=true` if the
  emulator process was later killed by the wall timeout

## Canonical full-run attempts

The first canonical v1 hs/vs/vu full-string attempt used a `90m` wall timeout:

| Profile | Run ID | Status | Notes |
| --- | --- | --- | --- |
| `spectre-v1-hs-sv48-kmhv2/profiles/sv48` | `20260721Tcanonical-v1hs-kmhv2-sv48` | `ASSERTION_PASS` | observed `S3CreT`, `check=PASS`; `run_exit=124` because the emulator was killed after the assertion evidence was printed |
| `spectre-v1-vs-sv48-kmhv2/profiles/sv48` | `20260721Tcanonical-v1vs-kmhv2-sv48` | `RUN_TIMEOUT` | partial result `S3C` before timeout |
| `spectre-v1-vu-sv48-kmhv2/profiles/sv48` | `20260721Tcanonical-v1vu-kmhv2-sv48` | `RUN_TIMEOUT` | partial result `S3Cre` before timeout |

The v1 hs/vs/vu profiles still use `SECRET_SZ=6` and local
`runtime/kmhv2-emu/emu`, but now have `WALL_TIMEOUT=180m` for subsequent
full-string reruns.

The second canonical v1 vs/vu full-string attempt used the `180m` wall timeout.
Both produced full 6-byte parse results:

| Profile | Run ID | Status | Observed guess |
| --- | --- | --- | --- |
| `spectre-v1-vs-sv48-kmhv2/profiles/sv48` | `20260721Tcanonical2-v1vs-kmhv2-sv48` | `ASSERTION_FAIL` | `S3CreS` |
| `spectre-v1-vu-sv48-kmhv2/profiles/sv48` | `20260721Tcanonical2-v1vu-kmhv2-sv48` | `ASSERTION_FAIL` | `S3Cre7` |

The first canonical v2 hs/vs/vu full-string attempt used the previous `30m`
wall timeout. All three built and started correctly, but timed out before a full
6-byte result could be parsed:

| Profile | Run ID | Status | Notes |
| --- | --- | --- | --- |
| `spectre-v2-hs-sv39-kmhv2/profiles/sv39` | `20260721Tcanonical-v2hs-kmhv2-sv39` | `RUN_TIMEOUT` | no byte rows before timeout |
| `spectre-v2-vs-sv39-kmhv2/profiles/sv39` | `20260721Tcanonical-v2vs-kmhv2-sv39` | `RUN_TIMEOUT` | partial result `S3` before timeout |
| `spectre-v2-vu-sv39-kmhv2/profiles/sv39` | `20260721Tcanonical-v2vu-kmhv2-sv39` | `RUN_TIMEOUT` | no byte rows before timeout |

After reviewing the logs, the v2 vs/vu model header `printf` argument lists
were fixed so the printed run parameters match the actual compiled constants.
The corrected profiles still use `SECRET_SZ=6` and local `runtime/kmhv2-emu/emu`,
but now have `WALL_TIMEOUT=120m`.

The second canonical v2 hs/vs/vu full-string attempt completed without timeout
and produced full 6-byte parse results:

| Profile | Run ID | Status | Observed guess |
| --- | --- | --- | --- |
| `spectre-v2-hs-sv39-kmhv2/profiles/sv39` | `20260721Tcanonical2-v2hs-kmhv2-sv39` | `ASSERTION_FAIL` | `SPWVF3` |
| `spectre-v2-vs-sv39-kmhv2/profiles/sv39` | `20260721Tcanonical2-v2vs-kmhv2-sv39` | `ASSERTION_FAIL` | `S3xFFE` |
| `spectre-v2-vu-sv39-kmhv2/profiles/sv39` | `20260721Tcanonical2-v2vu-kmhv2-sv39` | `ASSERTION_FAIL` | `S3xFFc` |

All six 2026-07-21 candidate profiles now have full parseable results and are
registered in `POC_REGISTRY.tsv`.

## Present only in source testbench

The Spectre V4 workload has not been merged into this verified deliverable yet.
Its source remains in the original testbench tree:

- `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v4`
- `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v4/src/spectre-v4.c`
- `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/workloads/spectre-v4/src/spectre-v4-gadget.S`
- `/nfs/home/leizhenyu/opt/testbench/targets/xiangshan/scripts/run-spectre-v4.sh`
