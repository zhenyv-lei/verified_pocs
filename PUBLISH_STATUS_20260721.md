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

## Push attempt

The commit was created locally, but GitHub push did not complete because this host
could not reach GitHub:

- `ssh://git@ssh.github.com:443/...`: connection timed out
- `git@github.com:...` over port 22: connection timed out
- `https://github.com/...` over port 443: connection timed out

When network access is available, push with the BOSC proxy:

```bash
cd /tmp/verified_pocs_publish_20260721
GIT_SSH_COMMAND='ssh -o ConnectTimeout=30 -o ProxyCommand="nc -x 172.38.10.247:8970 -X 5 %h %p"' \
  git push ssh://git@ssh.github.com:443/zhenyv-lei/verified_pocs.git HEAD:main
```

If the `/tmp` worktree is gone, restore from the bundle:

```bash
git clone verified_pocs_publish_e8be3b2_20260721.bundle verified_pocs_publish_restore
cd verified_pocs_publish_restore
git push ssh://git@ssh.github.com:443/zhenyv-lei/verified_pocs.git main:main
```
