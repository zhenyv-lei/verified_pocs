#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C TZ=UTC HOME=/tmp/verified-poc/xiangshan-v2/spectre-v1-poc-kmhv2/bare/20260720Tbuild-v1poc/home TMPDIR=/tmp/verified-poc/xiangshan-v2/spectre-v1-poc-kmhv2/bare/20260720Tbuild-v1poc/tmp
make -C /tmp/verified-poc/xiangshan-v2/spectre-v1-poc-kmhv2/bare/20260720Tbuild-v1poc/source clean AM_HOME=/nfs/home/leizhenyu/opt/testbench/.local/nexus-am-kmhv2 ARCH=riscv64-xs-flash
make -C /tmp/verified-poc/xiangshan-v2/spectre-v1-poc-kmhv2/bare/20260720Tbuild-v1poc/source AM_HOME=/nfs/home/leizhenyu/opt/testbench/.local/nexus-am-kmhv2 ARCH=riscv64-xs-flash LINUX_GNU_TOOLCHAIN=1 MARCH=rv64gc_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zknd_zkne_zknh_zkr_zksed_zksh_zkt_zicbom_zicboz CC_OPT= CPPFLAGS=-DSECRET_SZ=6\ -DATTACK_SAME_ROUNDS=2\ -DTRAIN_TIMES=10 -j8
ulimit -s 32768
timeout 30m /nfs/home/leizhenyu/opt/verified_poc/xiangshan-v2/spectre-v1-poc-kmhv2/profiles/bare/runtime/emu/emu --no-diff --seed=0 -i /tmp/verified-poc/xiangshan-v2/spectre-v1-poc-kmhv2/bare/20260720Tbuild-v1poc/image
python3 /nfs/home/leizhenyu/opt/verified_poc/tools/parse_profile_log.py v1_basic S3CreT /nfs/home/leizhenyu/opt/verified_poc/xiangshan-v2/spectre-v1-poc-kmhv2/profiles/bare/runs/20260720Tbuild-v1poc/run.log /nfs/home/leizhenyu/opt/verified_poc/xiangshan-v2/spectre-v1-poc-kmhv2/profiles/bare/runs/20260720Tbuild-v1poc/result.json
# source image before copy: /tmp/verified-poc/xiangshan-v2/spectre-v1-poc-kmhv2/bare/20260720Tbuild-v1poc/source/build/spectre-v1-riscv64-xs-flash.elf
