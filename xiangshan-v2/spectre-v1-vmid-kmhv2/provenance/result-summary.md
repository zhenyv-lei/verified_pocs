# Result summary

Target: `spectre-v1-vmid-priv` on `/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu`.

Outcome: the workload ran through using the stable per-byte configuration. Each byte run reported:

- direct attacker read of victim-only secret page faulted: `fault_seen=1 completed=0`
- requested and observed attacker/victim `hgatp` values used distinct VMID fields
- per-byte secret guess matched expected byte
- final per-byte check was `PASS`

Recovered bytes:

| offset | expected | guess | result |
| --- | --- | --- | --- |
| 0 | `S` / `0x53` | `S` / `0x53` | PASS |
| 1 | `3` / `0x33` | `3` / `0x33` | PASS |
| 2 | `C` / `0x43` | `C` / `0x43` | PASS |
| 3 | `r` / `0x72` | `r` / `0x72` | PASS |
| 4 | `e` / `0x65` | `e` / `0x65` | PASS |
| 5 | `T` / `0x54` | `T` / `0x54` | PASS |

Recovered secret: `S3CreT`.

Primary evidence files:

- `results/spectre-v1-vmid-priv-kmhv2-stable-summary-20260713.txt`
- `results/extracted-v1-vmid-priv-lines.txt`
- `logs/spectre-v1-vmid-priv-kmhv2-stable-byte0-run.log`
- `logs/spectre-v1-vmid-priv-kmhv2-stable-byte1-run.log`
- `logs/spectre-v1-vmid-priv-kmhv2-stable-byte2-run.log`
- `logs/spectre-v1-vmid-priv-kmhv2-stable-byte3-run.log`
- `logs/spectre-v1-vmid-priv-kmhv2-stable-byte4-run.log`
- `logs/spectre-v1-vmid-priv-kmhv2-stable-byte5-run.log`
