# Sv48 root-fix summary - 2026-07-17

## Problem

The Sv48 converted POCs can reach guest-level completion, e.g. `check=PASS`, but the host emulator does not terminate with `HIT GOOD TRAP`. The observed failure mode is:

- guest prints `Exit with code = 0`;
- host process is killed only by outer `timeout`;
- old Sv39 logs do contain `HIT GOOD TRAP`.

This means the failure is on the final host/AM exit path, not in the Spectre result check itself.

## Root-cause hypothesis

The Sv48 POCs install non-bare address-translation state (`satp`, and for VMID also `vsatp/hgatp`) before entering the attacker context. When execution returns to machine-mode C code and then AM `_halt()`, that translation/virtualization state was still live.

AM `_halt()` executes the XiangShan/NOOP trap instruction `.word 0x0005006b`. In the broken Sv48 runs the instruction falls through to AM's fallback print and infinite loop:

```c
printf("Exit with code = %d\n", code);
while (1);
```

So the root fix is to restore bare machine execution state before returning to AM/host exit code.

## Code changes

Updated `machine_low_return` in:

- `xiangshan-v2/spectre-v1-priv-kmhv2/code/src/spectre-v1-priv.c`
- `xiangshan-v2/spectre-v2-privilege-kmhv2/code/src/spectre-v2.c`
- `xiangshan-v2/spectre-v1-asid-kmhv2/code/src/spectre-v1-asid-priv.c`
- `xiangshan-v2/spectre-v1-vmid-kmhv2/code/src/spectre-v1-vmid-priv.c`

For Sv48 PTE/ASID cases:

```asm
csrw satp, zero
sfence.vma zero, zero
fence.i
```

For the VMID/VS case:

```asm
csrw satp, zero
sfence.vma zero, zero
csrw vsatp, zero
csrw hgatp, zero
hfence.vvma zero, zero
hfence.gvma zero, zero
li t0, 0x8000020000
csrc mstatus, t0
fence.i
```

The `mstatus` mask clears residual virtualization/MPRV-related state before returning to normal M-mode AM code.

## Verification status

Build validation passed for all four modified POCs:

```text
v1-priv=0
v2-priv=0
v1-asid=0
v1-vmid=0
```

Build logs:

- `logs/xiangshan-v2/sv48-rootfix-build-20260717/v1-priv-build.log`
- `logs/xiangshan-v2/sv48-rootfix-build-20260717/v2-priv-build.log`
- `logs/xiangshan-v2/sv48-rootfix-build-20260717/v1-asid-build.log`
- `logs/xiangshan-v2/sv48-rootfix-build-20260717/v1-vmid-build.log`

Runtime validation attempted:

- `logs/xiangshan-v2/spectre-v1-priv-kmhv2/20260717-sv48-smoke-satpclear/`
- `logs/xiangshan-v2/spectre-v1-priv-kmhv2/20260717-sv48-1byte-satpclear-scriptmatch/`

Both runtime attempts were limited by current emulator throughput/host load and did not reach `machine_low_return`, so they are not valid pass/fail evidence for the root fix.

The prior evidence that motivates the fix remains:

- old Sv39 logs: `HIT GOOD TRAP`;
- broken Sv48 1-byte full run: `check=PASS` followed by `Exit with code = 0` and timeout.

