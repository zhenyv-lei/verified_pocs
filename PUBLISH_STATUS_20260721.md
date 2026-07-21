# Publish status - 2026-07-21

## Local commit

- Initial local staging commit: `e8be3b2`
- Subject: `Add verified XiangShan POC profile deliverable`
- Prepared worktree: `/tmp/verified_pocs_publish_20260721`
- Bundle backup: `verified_pocs_publish_e8be3b2_20260721.bundle`
- Intended GitHub repository: `ssh://git@ssh.github.com:443/zhenyv-lei/verified_pocs.git`
- Intended branch: `main`
- Note: GitHub `main` had advanced after the staging commit was created, so the
  final publish commit should be based on the fetched remote `main` rather than
  force-pushing `e8be3b2`.

## Included scope

The commit includes the current verified deliverable scope:

- `POC_REGISTRY.tsv`
- `POC_REPRODUCTION_STATUS_20260720.md`
- `POC_PENDING_STATUS_20260721.md`
- `EMU_CATALOG.tsv`
- `POC_REPRODUCIBILITY.md`
- `run_verified_pocs.sh`
- `tools/`
- verified XiangShan V2/V3 POC directories covering the 11 registered profiles

The six unstandardized POC-style directories are intentionally excluded from this
publish commit and recorded in `POC_PENDING_STATUS_20260721.md`.

## Verification before commit

Run from `/tmp/verified_pocs_publish_20260721`:

```bash
awk -F'\t' 'NF!=14 {print NR, NF, $0}' POC_REGISTRY.tsv
bash -n tools/profile_runner.sh
bash -n tools/prepare_poc_runtime.sh
bash -n run_verified_pocs.sh
./run_verified_pocs.sh --list | wc -l
```

Observed results:

- Registry column check: no output
- Shell syntax checks: pass
- Profile count: `11`

## Published commit

- Final published commit: `6d253dbacd04e098c9adfa1c932ce3abee665d36`
- Subject: `Publish verified XiangShan POC profiles`
- Branch: `main`
- Remote: `ssh://git@ssh.github.com:443/zhenyv-lei/verified_pocs.git`
- Push result: `302e2ea..6d253db HEAD -> main`
- Large runtime binaries: tracked through Git LFS with
  `**/runtime/**/emu filter=lfs diff=lfs merge=lfs -text`

The successful push used the BOSC IVP6 socks5 proxy for both SSH and Git LFS:

```bash
cd /tmp/verified_pocs_publish_lfs_20260721
git config --local http.proxy socks5h://172.38.10.247:8970
git config --local https.proxy socks5h://172.38.10.247:8970
GIT_SSH_COMMAND='ssh -o ConnectTimeout=30 -o ProxyCommand="nc -x 172.38.10.247:8970 -X 5 %h %p"' \
  /nfs/home/leizhenyu/.codex/skills/bosc-ivp6-proxy-install/scripts/with_bosc_proxy.sh -- \
  git push ssh://git@ssh.github.com:443/zhenyv-lei/verified_pocs.git HEAD:main
```

## Six-profile update

- Payload commit: `719a1fac16f99407ba6f4e99423476151401af8e`
- Subject: `Record six additional XiangShan POC profiles`
- Branch: `main`
- Remote: `ssh://git@ssh.github.com:443/zhenyv-lei/verified_pocs.git`
- Push result: `bea15cc..719a1fa HEAD -> main`
- Registered profile count after this update: `17`
- Runtime binaries remain tracked through Git LFS with
  `**/runtime/**/emu filter=lfs diff=lfs merge=lfs -text`

The update promotes six 2026-07-21 candidate profiles into
`POC_REGISTRY.tsv`:

| Profile | Final status | Observed guess |
| --- | --- | --- |
| `xiangshan-v2/spectre-v1-hs-sv48-kmhv2/profiles/sv48` | `ASSERTION_PASS` | `S3CreT` |
| `xiangshan-v2/spectre-v1-vs-sv48-kmhv2/profiles/sv48` | `ASSERTION_FAIL` | `S3CreS` |
| `xiangshan-v2/spectre-v1-vu-sv48-kmhv2/profiles/sv48` | `ASSERTION_FAIL` | `S3Cre7` |
| `xiangshan-v2/spectre-v2-hs-sv39-kmhv2/profiles/sv39` | `ASSERTION_FAIL` | `SPWVF3` |
| `xiangshan-v2/spectre-v2-vs-sv39-kmhv2/profiles/sv39` | `ASSERTION_FAIL` | `S3xFFE` |
| `xiangshan-v2/spectre-v2-vu-sv39-kmhv2/profiles/sv39` | `ASSERTION_FAIL` | `S3xFFc` |

Pre-push checks for this update:

- `python3 -m py_compile tools/parse_profile_log.py`: pass
- `bash -n tools/profile_runner.sh`: pass
- `POC_REGISTRY.tsv`: 17 registered profile rows, 14 fields per row
- Staged scope excluded local `.scratch`, `.agents`, `.codex`, tarballs, bundle
  backups, `tools/__pycache__`, and the unregistered `spectre-v2-*-sv48-kmhv2`
  candidate directories.
