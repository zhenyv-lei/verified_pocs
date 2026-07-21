#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C TZ=UTC HOME=/tmp/verified-poc/xiangshan-v2/spectre-v2-poc-kmhv2/bare/20260720Tverify-runtime-tags/home TMPDIR=/tmp/verified-poc/xiangshan-v2/spectre-v2-poc-kmhv2/bare/20260720Tverify-runtime-tags/tmp
make -C /tmp/verified-poc/xiangshan-v2/spectre-v2-poc-kmhv2/bare/20260720Tverify-runtime-tags/source clean AM_HOME=/nfs/home/leizhenyu/opt/testbench/.local/nexus-am-kmhv2 ARCH=riscv64-xs
make -C /tmp/verified-poc/xiangshan-v2/spectre-v2-poc-kmhv2/bare/20260720Tverify-runtime-tags/source AM_HOME=/nfs/home/leizhenyu/opt/testbench/.local/nexus-am-kmhv2 ARCH=riscv64-xs LINUX_GNU_TOOLCHAIN=1 MARCH=rv64gc_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zknd_zkne_zknh_zkr_zksed_zksh_zkt_zicbom_zicboz CC_OPT= CPPFLAGS=-DSECRET_SZ=6\ -DV2_ATTACK_TRIES=2\ -DV2_TRAINING_LOOPS=16 -j8
ulimit -s 32768
timeout 30m /nfs/home/leizhenyu/opt/verified_poc/xiangshan-v2/spectre-v2-poc-kmhv2/profiles/bare/runtime/kmhv2-emu/emu --no-diff --seed=0 -i /tmp/verified-poc/xiangshan-v2/spectre-v2-poc-kmhv2/bare/20260720Tverify-runtime-tags/image
python3 /nfs/home/leizhenyu/opt/verified_poc/tools/parse_profile_log.py v2_basic S3CreT /nfs/home/leizhenyu/opt/verified_poc/xiangshan-v2/spectre-v2-poc-kmhv2/profiles/bare/runs/20260720Tverify-runtime-tags/run.log /nfs/home/leizhenyu/opt/verified_poc/xiangshan-v2/spectre-v2-poc-kmhv2/profiles/bare/runs/20260720Tverify-runtime-tags/result.json
# source image before copy: /tmp/verified-poc/xiangshan-v2/spectre-v2-poc-kmhv2/bare/20260720Tverify-runtime-tags/source/build/spectre-v2-riscv64-xs.elf
