# Execution plan

Order:

1. Archive verified code and provenance into `verified_poc`.
2. Generate a registry with processor, PoC name, code path, emu path, build arch, and historical result.
3. Review each PoC at source level for:
   - attack mechanism;
   - isolation or privilege assumption;
   - cache timing channel;
   - build/runtime parameters;
   - reasons the historical result is or is not sufficient.
4. Rerun each PoC from its archived `code/` directory.
5. Store new logs under `logs/<processor>/<poc>/<run-id>/`.
6. Generate per-PoC `review/theory-and-rerun.md` and top-level `SUMMARY.md`.

Rerun order:

1. `xiangshan-v2/spectre-v1-poc-kmhv2`
2. `xiangshan-v2/spectre-v2-poc-kmhv2`
3. `xiangshan-v2/spectre-v1-priv-kmhv2`
4. `xiangshan-v2/spectre-v1-asid-kmhv2`
5. `xiangshan-v2/spectre-v1-vmid-kmhv2`
6. `xiangshan-v2/spectre-v2-privilege-kmhv2`
7. `xiangshan-v3/spectre-v1-poc-kmhv3`

Expected caveats:

- `spectre-v2-privilege-kmhv2` baseline is not expected to fully recover the string; the correct historical baseline is `S3preT`, `5/6`.
- `spectre-v1-poc-kmhv3` is long-running; historical full run took about 21.8 minutes of host time.
