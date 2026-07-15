# Verified XiangShan PoCs

This repository is the long-term home for verified XiangShan transient-execution PoCs and their reproducibility logs.

The repository is intentionally organized around processor generation first, then PoC name:

```text
.
├── xiangshan-v2/
│   └── <poc-name>/
│       ├── code/          # verified source/build snapshot
│       └── provenance/    # selected historical artifact evidence
├── xiangshan-v3/
│   └── <poc-name>/
│       ├── code/
│       └── provenance/
├── logs/
│   └── <processor>/<poc-name>/<run-id>/
├── POC_REGISTRY.tsv       # machine-readable index
└── run_verified_pocs.sh   # rerun helper
```

## Current PoCs

| processor | PoC | rerun result | recovered / note |
| --- | --- | --- | --- |
| xiangshan-v2 | `spectre-v1-poc-kmhv2` | PASS | top-1 `S3CreT` |
| xiangshan-v2 | `spectre-v2-poc-kmhv2` | PASS | top-1 `S3CreT` |
| xiangshan-v2 | `spectre-v1-priv-kmhv2` | PASS | top-1 `S3CreT`; direct U read faulted |
| xiangshan-v2 | `spectre-v1-asid-kmhv2` | PASS | per-byte `S3CreT`; ASID isolation checked |
| xiangshan-v2 | `spectre-v1-vmid-kmhv2` | PASS | per-byte `S3CreT`; VMID isolation checked |
| xiangshan-v2 | `spectre-v2-privilege-kmhv2` | MIXED | historical baseline `S3preT` 5/6; rerun top-1 `S3Creq`; do not report as clean full recovery |
| xiangshan-v3 | `spectre-v1-poc-kmhv3` | PASS | top-1 `S3CreT` |

Use `POC_REGISTRY.tsv` for exact code path, emulator path, architecture, and historical result metadata.

## Naming convention

- First-level directory: processor generation, e.g. `xiangshan-v2`, `xiangshan-v3`.
- Second-level directory: PoC name, e.g. `spectre-v1-poc-kmhv2`, `spectre-v1-asid-kmhv2`.
- Rerun logs: `logs/<processor>/<poc-name>/<run-id>/`.

## Rerun

From the repository root:

```bash
./run_verified_pocs.sh spectre-v1-poc-kmhv2
./run_verified_pocs.sh all
```

The script defaults to:

- Kunminghu V2 emulator: `/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu`
- Kunminghu V3 emulator: `/nfs/home/leizhenyu/opt/DUTs/XiangShan-V3/build/emu`
- logs root: `logs/`

Override with environment variables when needed:

```bash
RUN_ID=20260715-review BASE=$PWD ./run_verified_pocs.sh all
```

## Documentation policy

Keep this repository compact:

1. One top-level README is the human entry point.
2. `POC_REGISTRY.tsv` is the structured index.
3. Detailed run outputs belong under `logs/`.
4. Historical artifact evidence belongs under each PoC's `provenance/`.
5. Do not merge exploratory/control results into baseline conclusions.

In particular, `spectre-v2-privilege-kmhv2` must be described carefully: the historical corrected baseline was `S3preT` vs expected `S3CreT` (`5/6` top-1), and the latest rerun was also not a clean top-1 full-string recovery.
