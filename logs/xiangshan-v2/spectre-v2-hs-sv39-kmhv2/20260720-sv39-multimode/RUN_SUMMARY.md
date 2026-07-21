# Spectre-v2 SV39 multi-mode run summary (2026-07-20)

## Scope

Implemented initial Spectre-v2 multi-mode PoC variants by reusing the existing Spectre-v1 SV39 mode/page-table/trap scaffolds and replacing the victim gadget with the Spectre-v2 indirect-branch single-site assembly round.

Workload directories:

- `targets/xiangshan/workloads/spectre-v2-hs-sv39-kmhv2`
- `targets/xiangshan/workloads/spectre-v2-vu-sv39-kmhv2`
- `targets/xiangshan/workloads/spectre-v2-vs-sv39-kmhv2`

Backups of the pre-v2-logic placeholder directories:

- `targets/xiangshan/workloads/spectre-v2-hs-sv39-kmhv2.backup-before-v2logic-20260720`
- `targets/xiangshan/workloads/spectre-v2-vu-sv39-kmhv2.backup-before-v2logic-20260720`
- `targets/xiangshan/workloads/spectre-v2-vs-sv39-kmhv2.backup-before-v2logic-20260720`

## Design note

- HS variant: attacker and victim are HS/S contexts separated by distinct `satp` ASIDs. Shared probe is mapped into both spaces; `victim_secret` and the v2 target chain are mapped only in the victim space.
- VU variant: attacker and victim are VU contexts separated by distinct `hgatp` VMIDs with `hgatp` bare and independent `vsatp` roots.
- VS variant: attacker and victim are VS contexts separated by distinct `hgatp` VMIDs with supervisor guest PTE permissions.
- The Spectre-v2 mechanism uses one indirect branch site. Training directs the predictor toward `v2_asm_gadget`; the attack path architecturally targets `v2_asm_safe`, while speculative target confusion may touch `shared_probe[secret * 64]`.

## Build commands

HS:

```bash
AM_HOME=/nfs/home/leizhenyu/opt/testbench/.local/nexus-am-kmhv2 \
ARCH=riscv64-xs \
LINUX_GNU_TOOLCHAIN=1 \
MARCH=rv64gc_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zknd_zkne_zknh_zkr_zksed_zksh_zkt_zicbom_zicboz \
make -j4
```

VU/VS:

```bash
AM_HOME=/nfs/home/leizhenyu/opt/testbench/.local/nexus-am-kmhv2 \
ARCH=riscv64-xs \
LINUX_GNU_TOOLCHAIN=1 \
MARCH=rv64gc_h_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zknd_zkne_zknh_zkr_zksed_zksh_zkt_zicbom_zicboz \
make -j4
```

## Run commands

```bash
timeout 180 stdbuf -oL -eL /nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu --no-diff \
  -i targets/xiangshan/workloads/spectre-v2-hs-sv39-kmhv2/build/spectre-v2-hs-sv39-kmhv2-riscv64-xs.bin \
  > targets/xiangshan/logs/spectre-v2-sv39-multimode-20260720/spectre-v2-hs-sv39-kmhv2-full-xs.log 2>&1

timeout 120 stdbuf -oL -eL /nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu --no-diff \
  -i targets/xiangshan/workloads/spectre-v2-vu-sv39-kmhv2/build/spectre-v2-vu-sv39-kmhv2-riscv64-xs.bin \
  > targets/xiangshan/logs/spectre-v2-sv39-multimode-20260720/spectre-v2-vu-sv39-kmhv2-full-xs.log 2>&1

timeout 120 stdbuf -oL -eL /nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu --no-diff \
  -i targets/xiangshan/workloads/spectre-v2-vs-sv39-kmhv2/build/spectre-v2-vs-sv39-kmhv2-riscv64-xs.bin \
  > targets/xiangshan/logs/spectre-v2-sv39-multimode-20260720/spectre-v2-vs-sv39-kmhv2-full-xs.log 2>&1
```

## Observed result

- All three variants compile successfully for `ARCH=riscv64-xs`.
- All three variants enter application-level logging on `/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu`.
- The default 6-byte full-string runs did not complete within the short timeout windows used in this pass. The logs are partial and should be treated as smoke/entry evidence, not leakage verdicts.
- A 60-second control run of the previously built `spectre-v2-privilege` binary also did not reach application output, indicating that the current emu throughput/startup latency is a confounder for short-timeout full-string evaluation.

## Artifact hashes

```text
7ab235f6b1e6bb85c26baac3e5e0fe4c8db8d7a5ba58ee45156d1e07bf75452b  targets/xiangshan/workloads/spectre-v2-hs-sv39-kmhv2/build/spectre-v2-hs-sv39-kmhv2-riscv64-xs.bin
b47b596345ea26ac87fcfaabc5693fbb1f6979e3d162fc20ca821472dd952bc5  targets/xiangshan/workloads/spectre-v2-vu-sv39-kmhv2/build/spectre-v2-vu-sv39-kmhv2-riscv64-xs.bin
10195f3e9f2d60889e27b9a87ac542c962a91346299f9730f4a65f7a7cc93e7e  targets/xiangshan/workloads/spectre-v2-vs-sv39-kmhv2/build/spectre-v2-vs-sv39-kmhv2-riscv64-xs.bin
```
