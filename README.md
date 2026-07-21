# Verified XiangShan PoCs

This repository stores XiangShan transient-execution POCs as reproducible profile
bundles. The profile name is the address-translation mode only: `bare`, `sv39`, or
`sv48`. `historical` and `current` are deliberately not profile names.

The immutable reference snapshot made before this reorganization is
`/nfs/home/leizhenyu/opt/verified_poc-reference-20260720`.

## Layout

Every runnable profile has the same shape:

```text
<processor>/<poc>/
├── profiles/<bare|sv39|sv48>/
│   ├── source/                   # build inputs; no shared code/build is used
│   ├── runtime/
│   │   ├── kmhv2-emu/emu or kmhv3-emu/emu  # executable regular file, not a symlink
│   │   ├── emu.sha256
│   │   ├── emu.build-id
│   │   ├── emu.file / emu.readelf / emu.ldd / emu.help
│   │   └── noop-home/            # required by KMHv3; optional evidence for KMHv2
│   ├── artifacts/                # generated images are never committed here
│   ├── runs/<run-id>/             # logs/results created by a later run
│   └── reproduce/
│       ├── profile.conf           # profile identity and exact make/EMU parameters
│       ├── run.sh                 # one-click clean-build/run/parse
│       ├── verify.sh              # package and dependency preflight
│       ├── build.sh               # preflight + clean scratch build
│       └── parse.sh               # parse an existing RUN_ID
├── code/                         # legacy input retained for provenance
├── provenance/                   # original commands and historical evidence
└── runtime/                      # archived runtime evidence; profiles run from profiles/*/runtime
```

The repository currently contains 11 profiles:

- `xiangshan-v2/spectre-v1-poc-kmhv2/bare`
- `xiangshan-v2/spectre-v2-poc-kmhv2/bare`
- `xiangshan-v2/spectre-v1-priv-kmhv2/{sv39,sv48}`
- `xiangshan-v2/spectre-v1-asid-kmhv2/{sv39,sv48}`
- `xiangshan-v2/spectre-v1-vmid-kmhv2/{sv39,sv48}`
- `xiangshan-v2/spectre-v2-privilege-kmhv2/{sv39,sv48}`
- `xiangshan-v3/spectre-v1-poc-kmhv3/bare`

The `sv39` source bundles are copied from the pre-Sv48 backups recorded in each
POC's provenance. The `sv48` bundles are the checked-in post-conversion sources.
For VMID, `vsatp` is Sv39/Sv48 while `hgatp` remains Bare+VMID; the distinction is
recorded in `profile.conf` and the POC README rather than hidden in a suffix.

## One-click commands

From a profile directory:

```bash
cd xiangshan-v2/spectre-v1-poc-kmhv2/profiles/bare
./reproduce/run.sh
```

That command creates a new `runs/<run-id>/` and a separate scratch tree, then runs
`verify -> clean build -> EMU -> parse`. It never calls the legacy `code/build`.
The exact flags are in `reproduce/profile.conf`; all current profiles build the
six-byte full string (`SECRET_SZ=6`, expected `S3CreT`). The generated
`runs/<run-id>/command.sh` is a replayable record.

Individual stages are available when a run ID already exists:

```bash
./reproduce/verify.sh
./reproduce/build.sh
RUN_ID=20260720T120000Z ./reproduce/parse.sh
```

The AM tree and toolchain remain explicit host prerequisites and can be overridden:

```bash
AM_HOME=/path/to/nexus-am RUN_ID=my-run ./reproduce/run.sh
```

The top-level compatibility dispatcher accepts a full profile selector:

```bash
./run_verified_pocs.sh --list
./run_verified_pocs.sh xiangshan-v2/spectre-v1-poc-kmhv2/bare
./run_verified_pocs.sh spectre-v1-priv-kmhv2/sv48
```

`--list` is read-only. The `all` selector runs every profile and should only be
used when the host, AM trees, and runtime budget have been approved.

## EMU policy

The canonical KMHv2 runtime is the bundled copy of
`/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu-16threads`, identified by
SHA-256 `6ffccdb29be51b34133ed736075ca6a97cd006ead5ecb4dded599c06f7e67903` and
Build ID `1481083d32d093176a1ac671e10b42872c87d007`. Diagnostic candidates are
listed in [EMU_CATALOG.tsv](EMU_CATALOG.tsv) in the controlled order
16 -> 8 -> 4 -> 2 -> 1 threads. A candidate change gets a new run directory and
must not be silently merged into the canonical result.

The canonical KMHv3 runtime is `kmhv3-emu-v2-baseline` with its profile-local
`runtime/noop-home/build/constantin.txt`. KMHv2 keeps Constantin embedded by
default; the wrapper explicitly unsets `NOOP_HOME` and does not pass `--cst-file`.
The runner accepts only tagged runtime directories, `runtime/kmhv2-emu/emu` or
`runtime/kmhv3-emu/emu`; it does not select an untagged `runtime/emu` fallback.

## Log format

New `preflight.log`, `build.log`, `run.log`, and `parse.log` files start with the
same `[profile-runner] key=value` header. The header records the profile,
processor, VM mode, run ID, AM_HOME, tagged EMU path, EMU candidate ID, EMU hash,
parser kind, six-byte expected-secret length, seed, timeout, and build flags.

## Status policy

All newly created profiles are intentionally marked `NOT_RUN`. Existing logs under
`logs/` and `provenance/` are historical evidence, not a claim that these new
source/runtime bundles have passed. A future run must record package, build, run,
and assertion status separately; timeout, partial leakage, or static-only checks
cannot become `PASS`.

See [POC_REPRODUCIBILITY.md](POC_REPRODUCIBILITY.md) for the full R0-R3 evidence
standard, [POC_REGISTRY.tsv](POC_REGISTRY.tsv) for the profile-level index, and
[POC_REPRODUCTION_STATUS_20260720.md](POC_REPRODUCTION_STATUS_20260720.md) for
the current verification worklog.
