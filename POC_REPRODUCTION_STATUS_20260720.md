# POC reproduction status - 2026-07-20

本文记录 2026-07-20 本轮整理后的实际复现状态。仓库规范仍以
`POC_REPRODUCIBILITY.md` 和 `POC_REGISTRY.tsv` 为准；本文记录本轮已经执行过的
环境、配置、日志和结果。

## Reference snapshot

- Reference snapshot: `/nfs/home/leizhenyu/opt/verified_poc-reference-20260720`
- Snapshot time: `2026-07-20T11:25:24+08:00`
- Source at capture: `/nfs/home/leizhenyu/opt/verified_poc`
- Host at capture: `open05`
- Kernel at capture: `Linux 6.14.0-37-generic x86_64 GNU/Linux`
- Copy verification at capture: `diff-identical for all 260 regular files`
- Snapshot metadata:
  - `/nfs/home/leizhenyu/opt/verified_poc-reference-20260720/SNAPSHOT_INFO.txt`
  - `/nfs/home/leizhenyu/opt/verified_poc-reference-20260720/SNAPSHOT_DIGEST.txt`

## Current runner policy

`tools/profile_runner.sh` has been tightened for this deliverable:

- All future run evidence is written under each profile's `runs/<RUN_ID>/`.
- Default scratch root is repo-local: `/nfs/home/leizhenyu/opt/verified_poc/.scratch`.
- Default AM_HOME is repo-local through each profile's `reproduce/profile.conf`:
  - KMHv2: `/nfs/home/leizhenyu/opt/verified_poc/.scratch/nexus-am-kmhv2`
  - KMHv3: `/nfs/home/leizhenyu/opt/verified_poc/.scratch/nexus-am-kmhv3`
- Runner output uses the unified `[profile-runner] key=value` format.
- Untagged EMU fallback is disabled. Profiles must use:
  - KMHv2: `runtime/kmhv2-emu/emu`
  - KMHv3: `runtime/kmhv3-emu/emu`
- All current profiles are configured for the six-byte full string:
  - `SECRET_SZ=6`
  - `EXPECTED_SECRET=S3CreT`

## Batch preflight

After the runner fixes and runtime tag tightening, all 11 profiles passed
package/runtime preflight. The preflight evidence includes `preflight.log`, `env.txt`,
`host.txt`, `emu.help.preflight`, `profile.conf`, `command.sh`, and `status.json`.

All 11 `20260720Tverify-runtime-tags` preflight runs recorded
`expected_secret_len=6` and selected only the profile-local tagged EMU path.

## Full reproduction matrix

The following table is the current evidence matrix after the user-run batch. The
scope of this matrix is the 11 profiles registered in `POC_REGISTRY.tsv`. Runs 1-8
are complete full runs, but their command environment had been split by shell line
wrapping in the pasted invocation, so they used the historical profile AM_HOME
default before the repo-local default switch. Runs 9-11 are canonical repo-local
AM_HOME/scratch reruns.

| # | Profile | Run ID | AM_HOME/scratch | Status | Expected | Observed |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | `xiangshan-v2/spectre-v1-poc-kmhv2/profiles/bare` | `20260720Tupdate-v1poc-kmhv2-bare` | historical AM_HOME default | `ASSERTION_PASS` | `S3CreT` | `S3CreT` |
| 2 | `xiangshan-v2/spectre-v2-poc-kmhv2/profiles/bare` | `20260720Tupdate-v2poc-kmhv2-bare` | historical AM_HOME default | `ASSERTION_PASS` | `S3CreT` | `S3CreT` |
| 3 | `xiangshan-v2/spectre-v1-priv-kmhv2/profiles/sv39` | `20260720Tupdate-v1priv-kmhv2-sv39` | historical AM_HOME default | `ASSERTION_PASS` | `S3CreT` | `S3CreT` |
| 4 | `xiangshan-v2/spectre-v1-priv-kmhv2/profiles/sv48` | `20260720Tupdate-v1priv-kmhv2-sv48` | historical AM_HOME default | `ASSERTION_PASS` | `S3CreT` | `S3CreT` |
| 5 | `xiangshan-v2/spectre-v1-asid-kmhv2/profiles/sv39` | `20260720Tupdate-v1asid-kmhv2-sv39` | historical AM_HOME default | `ASSERTION_PASS` | `S3CreT` | `S3CreT` |
| 6 | `xiangshan-v2/spectre-v1-asid-kmhv2/profiles/sv48` | `20260720Tupdate-v1asid-kmhv2-sv48` | historical AM_HOME default | `ASSERTION_FAIL` | `S3CreT` | `S3CreS` |
| 7 | `xiangshan-v2/spectre-v1-vmid-kmhv2/profiles/sv39` | `20260720Tupdate-v1vmid-kmhv2-sv39` | historical AM_HOME default | `ASSERTION_PASS` | `S3CreT` | `S3CreT` |
| 8 | `xiangshan-v2/spectre-v1-vmid-kmhv2/profiles/sv48` | `20260720Tupdate-v1vmid-kmhv2-sv48` | historical AM_HOME default | `ASSERTION_PASS` | `S3CreT` | `S3CreT` |
| 9 | `xiangshan-v2/spectre-v2-privilege-kmhv2/profiles/sv39` | `20260720Tcanonical-v2priv-kmhv2-sv39-r2` | repo-local `.scratch` | `ASSERTION_FAIL` | `S3CreT` | `S31DDC` |
| 10 | `xiangshan-v2/spectre-v2-privilege-kmhv2/profiles/sv48` | `20260720Tcanonical-v2priv-kmhv2-sv48` | repo-local `.scratch` | `ASSERTION_FAIL` | `S3CreT` | `S3p1C1` |
| 11 | `xiangshan-v3/spectre-v1-poc-kmhv3/profiles/bare` | `20260720Tcanonical-v3poc-kmhv3-bare` | repo-local `.scratch` | `ASSERTION_PASS` | `S3CreT` | `S3CreT` |

Current aggregate:

- `ASSERTION_PASS`: 8 profiles
- `ASSERTION_FAIL`: 3 profiles
- `NOT_RUN`: 0 profiles

Additional POC-style directories that are present but not part of this 11-profile
matrix are tracked separately in `POC_PENDING_STATUS_20260721.md`.

## Canonical repo-local reruns

### KMHv2 Spectre-v2 privilege sv39

- Profile: `xiangshan-v2/spectre-v2-privilege-kmhv2/profiles/sv39`
- Run ID: `20260720Tcanonical-v2priv-kmhv2-sv39-r2`
- Final status: `ASSERTION_FAIL`
- Secret: expected `S3CreT`, observed guess `S31DDC`
- AM_HOME: `/nfs/home/leizhenyu/opt/verified_poc/.scratch/nexus-am-kmhv2`
- Scratch: `/nfs/home/leizhenyu/opt/verified_poc/.scratch/xiangshan-v2/spectre-v2-privilege-kmhv2/sv39/20260720Tcanonical-v2priv-kmhv2-sv39-r2`
- EMU: `kmhv2-emu-16threads`
- EMU SHA-256: `6ffccdb29be51b34133ed736075ca6a97cd006ead5ecb4dded599c06f7e67903`
- Elapsed in status: `888` seconds
- Evidence directory:
  `xiangshan-v2/spectre-v2-privilege-kmhv2/profiles/sv39/runs/20260720Tcanonical-v2priv-kmhv2-sv39-r2/`

### KMHv2 Spectre-v2 privilege sv48

- Profile: `xiangshan-v2/spectre-v2-privilege-kmhv2/profiles/sv48`
- Run ID: `20260720Tcanonical-v2priv-kmhv2-sv48`
- Final status: `ASSERTION_FAIL`
- Secret: expected `S3CreT`, observed guess `S3p1C1`
- AM_HOME: `/nfs/home/leizhenyu/opt/verified_poc/.scratch/nexus-am-kmhv2`
- Scratch: `/nfs/home/leizhenyu/opt/verified_poc/.scratch/xiangshan-v2/spectre-v2-privilege-kmhv2/sv48/20260720Tcanonical-v2priv-kmhv2-sv48`
- EMU: `kmhv2-emu-16threads`
- EMU SHA-256: `6ffccdb29be51b34133ed736075ca6a97cd006ead5ecb4dded599c06f7e67903`
- Elapsed in status: `786` seconds
- Evidence directory:
  `xiangshan-v2/spectre-v2-privilege-kmhv2/profiles/sv48/runs/20260720Tcanonical-v2priv-kmhv2-sv48/`

### KMHv3 Spectre-v1 bare

- Profile: `xiangshan-v3/spectre-v1-poc-kmhv3/profiles/bare`
- Run ID: `20260720Tcanonical-v3poc-kmhv3-bare`
- Final status: `ASSERTION_PASS`
- Secret: expected `S3CreT`, observed guess `S3CreT`
- AM_HOME: `/nfs/home/leizhenyu/opt/verified_poc/.scratch/nexus-am-kmhv3`
- Scratch: `/nfs/home/leizhenyu/opt/verified_poc/.scratch/xiangshan-v3/spectre-v1-poc-kmhv3/bare/20260720Tcanonical-v3poc-kmhv3-bare`
- EMU: `kmhv3-emu-v2-baseline`
- EMU SHA-256: `7886cdf6081378bfcd84fb9397cd192f19c499ca607fb8b403f91b47c5c88bd1`
- Elapsed in status: `1559` seconds
- Evidence directory:
  `xiangshan-v3/spectre-v1-poc-kmhv3/profiles/bare/runs/20260720Tcanonical-v3poc-kmhv3-bare/`

## Evidence files

Every full run directory contains the relevant execution artifacts:

- `status.json`
- `result.json`
- `run.log`
- `build.log`
- `image.sha256`
- `toolchain.txt`
- `env.txt`
- `host.txt`

Historical raw run logs are preserved in-place. Stale failed attempts caused by
shell line wrapping or reused `RUN_ID` values are not deleted; the canonical run IDs
above identify the records used for this status document.
