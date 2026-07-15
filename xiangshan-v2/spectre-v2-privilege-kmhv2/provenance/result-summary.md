# Result summary

Target: `spectre-v2-privilege` on `/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu`.

Outcome: baseline byte sweep ran through, but did not fully recover the expected string.

- Expected secret: `S3CreT`
- Baseline recovered string: `S3preT`
- Baseline pass count: `5/6`
- Baseline failure: offset 2, expected `C`, guessed `p`

Each baseline run reported:

- `attacker=U`, `victim=M`
- isolation via `Sv39-PTE-U0`
- direct U-mode read of M secret faulted: `fault_seen=1 completed=0`
- `bad_traps=0`

Baseline byte results:

| offset | expected | baseline guess | baseline check | note |
| --- | --- | --- | --- | --- |
| 0 | `S` | `S` | PASS | baseline |
| 1 | `3` | `3` | PASS | baseline |
| 2 | `C` | `p` | FAIL | `C` ranked third: `p:4,q:4,C:3,7:1` |
| 3 | `r` | `r` | PASS | baseline |
| 4 | `e` | `e` | PASS | baseline |
| 5 | `T` | `T` | PASS | baseline |

Auxiliary note:

- Offset 2 was also rerun with `V2_ASM_CONTROL_ROUND=1`.
- That auxiliary run produced `guess=C` and `check=PASS`.
- This is included only as an exploratory/control-round record and is not merged into the baseline conclusion.

Primary evidence:

- `results/baseline-byte-results.txt`
- `results/baseline-recovered-secret.txt`
- `logs/spectre-v2-privilege-kmhv2-byte2-tries8-train16-th70-run.log`
- `logs/spectre-v2-privilege-kmhv2-byte2-tries8-train16-th70-asmctrl1-run.log`
- `results/control-round-auxiliary-result.txt`
