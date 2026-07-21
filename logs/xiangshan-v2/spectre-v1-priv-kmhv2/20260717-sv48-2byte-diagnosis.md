# Sv48 v1-priv 2-byte failure diagnosis - 2026-07-17

## Question

Why did the full-strength 2-byte Sv48 v1-priv run not pass?

## Evidence

### Full-strength 2-byte run

Directory:

- `logs/xiangshan-v2/spectre-v1-priv-kmhv2/20260717-sv48-2byte-rootfix/`

Configuration:

```text
SECRET_SZ=2
PROBE_CANDIDATES=62
ATTACK_SAME_ROUNDS=5
TRAIN_TIMES=10
FLUSH_LINES=256
```

Result:

```text
run_elapsed=45:00.01 exit=124
```

The log reached startup/control setup but did not reach:

- `traps=`
- `byte`
- `check=`
- `Exit with code`
- `HIT GOOD TRAP`

### Reduced 2-byte no-debug control

Directory:

- `logs/xiangshan-v2/spectre-v1-priv-kmhv2/20260717-sv48-2byte-reduced-nodebug-rootfix/`

Configuration:

```text
SECRET_SZ=2
PROBE_CANDIDATES=8
ATTACK_SAME_ROUNDS=1
TRAIN_TIMES=2
FLUSH_LINES=8
EARLY_STOP=0
```

Result:

```text
[v1-priv] isolation U-direct-secret-read fault_seen=1 completed=0 value=0x00 expected=fault
[v1-priv] traps=10 victim_calls=6 flush_calls=2 exit_calls=1 bad_traps=0 last_mcause=8 last_mepc=0000000080002360 status=0
[v1-priv] byte 0: expected=S(0x53) guess=2(0x32) score=1 second=8(0x38) score=1
[v1-priv] byte 0 rounds=1 early_stop=0 min_score=3 gap=2
[v1-priv] byte 1: expected=3(0x33) guess=2(0x32) score=1 second=8(0x38) score=1
[v1-priv] byte 1 rounds=1 early_stop=0 min_score=3 gap=2
[v1-priv] check=FAIL
Exit with code = 1
run_elapsed=20:00.01 exit=124
```

Interpretation:

- The reduced 2-byte run reached U-mode, took the expected U direct secret page fault, handled ecall traps, returned to M-mode, printed both byte results, and reached AM `_halt()`.
- `check=FAIL` is expected for this reduced configuration because candidates/rounds are intentionally too small for leakage quality.
- Therefore the 2-byte logic path is not fundamentally deadlocked.

### Trap debug control

Directory:

- `logs/xiangshan-v2/spectre-v1-priv-kmhv2/20260717-sv48-2byte-reduced-debug-rootfix/`

Observation:

```text
[v1-priv-debug] trap=1 cause=13 epc=00000000800022B2 ...
[v1-priv-debug] trap=2 cause=8 epc=0000000080002342 a7=2 ...
```

Interpretation:

- `cause=13` is the expected U-mode direct secret load page fault.
- `cause=8, a7=2` is the first `svc_flush_probe()` ecall.
- This confirms the mret/U-mode/trap entry path is live.
- Long `printf` from inside trap handling is too expensive in the current emulator environment and should not be used for full validation.

## Why the full-strength 2-byte run did not pass

The full-strength 2-byte run did not produce a result within 45 minutes because the workload is much larger under the current emulator conditions:

- full-strength 2-byte requires roughly two bytes worth of flush/victim/reload work;
- the current host is also running other heavy emulator workloads, including a CI emulator using many CPU cores and another long-running XiangShan emulator;
- console output and emulator throughput are currently very slow.

The reduced control proves the 2-byte guest logic can complete, so the 45-minute full-strength timeout is not evidence of a basic Sv48 page-table or U→M trap deadlock.

## Remaining independent problem

The host good-trap exit is still not fixed.

Even after the reduced 2-byte guest logic reaches `_halt()`, the log shows:

```text
Exit with code = 1
run_elapsed=20:00.01 exit=124
```

and does not show:

```text
HIT GOOD TRAP
```

This means the AM/host exit recognition path is still broken in the current Jul 16 emulator / Sv48 run setup. Clearing `satp` in `machine_low_return` was necessary cleanup, but it is not sufficient.

One important comparison caveat: the old Sv39 successful log used an emulator compiled on `Jun 29 2026`, while the current Sv48 logs use an emulator compiled on `Jul 16 2026`. Therefore, "old Sv39 good-trap worked" is not yet a same-emulator A/B comparison.

## Next actions

1. Run the original Sv39 binary or Sv39 source under the current Jul 16 emulator to determine whether good-trap failure is emulator-version-wide or Sv48-specific.
2. Avoid trap-path `printf` for performance diagnostics; use memory counters or short final summaries.
3. Do not launch full-string Sv48 until:
   - full-strength 2-byte completes under acceptable runtime, and
   - host good-trap exit is restored or a justified emulator-side exit method is chosen.

