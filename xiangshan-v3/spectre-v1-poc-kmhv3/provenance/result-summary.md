# Result summary

The full-string repro succeeded on XiangShan V3 emu.

Recovered secret: `S3CreT`.

| address | expected | guess | top score | second |
| --- | --- | --- | ---: | --- |
| `0x00000000F0000018` | `S` | `S` | 3 | empty / 0 |
| `0x00000000F0000019` | `3` | `3` | 3 | `S` / 0 |
| `0x00000000F000001A` | `C` | `C` | 3 | `p` / 1 |
| `0x00000000F000001B` | `r` | `r` | 3 | `p` / 1 |
| `0x00000000F000001C` | `e` | `e` | 3 | `p` / 1 |
| `0x00000000F000001D` | `T` | `T` | 3 | `e` / 0 |

Primary evidence:

- `logs/spectre-v1-kmhv3-poc-full-repro-run-i-th80-sz6-r3-t6-20260714.log`
- `results/extracted-key-lines.txt`
- `results/byte-results.txt`
- `results/recovered-secret.txt`

The run ended with:

```text
HIT GOOD TRAP
instrCnt = 603995, cycleCnt = 674028, IPC = 0.896098
Host time spent: 1306730ms
```
