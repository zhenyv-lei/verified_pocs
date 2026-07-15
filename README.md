# verified_poc archive

This directory stores locally authorized and reviewed XiangShan transient-execution PoCs.

Directory convention:

```text
verified_poc/
  xiangshan-v2/
    <poc-name>/
      code/          # verified PoC source snapshot used for rerun
      provenance/    # prior artifact summary, commands, checksums, extracted results
      review/        # theory review, rerun summary, open issues
  xiangshan-v3/
    <poc-name>/
      code/
      provenance/
      review/
  logs/
    <processor>/
      <poc-name>/
        <run-id>/    # new rerun build/run logs and extracted result lines
```

Processor naming:

- `xiangshan-v2`: Kunminghu V2 emu under `/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu`.
- `xiangshan-v3`: Kunminghu V3 emu under `/nfs/home/leizhenyu/opt/DUTs/XiangShan-V3/build/emu`.

Review policy:

1. Keep the historical artifact as provenance, but do not silently merge exploratory runs into a baseline conclusion.
2. For each PoC, record:
   - threat/model boundary;
   - secret layout and victim/attacker relationship;
   - branch/misprediction or BTB/indirect-control mechanism;
   - cache side-channel measurement mechanism;
   - whether direct architectural access is blocked when privilege/isolation is claimed;
   - exact build flags, emu path, run command, and result.
3. Rerun logs go under `logs/`, not mixed into provenance.
4. If a rerun differs from historical provenance, preserve both results and state the discrepancy.

Scope note:

- The local XiangShanLab weekly-sync check required by the analysis skill could not run because `xiangshanlab_home` / `XIANGSHANLAB_HOME` was not configured in the current shell.
- This archive therefore uses the user-provided local DUT/workload paths and existing artifact evidence for this pass.
