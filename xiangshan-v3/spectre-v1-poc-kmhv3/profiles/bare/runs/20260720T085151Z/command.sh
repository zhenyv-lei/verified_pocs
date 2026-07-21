#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C TZ=UTC HOME=/tmp/verified-poc/xiangshan-v3/spectre-v1-poc-kmhv3/bare/20260720T085151Z/home TMPDIR=/tmp/verified-poc/xiangshan-v3/spectre-v1-poc-kmhv3/bare/20260720T085151Z/tmp
make -C /tmp/verified-poc/xiangshan-v3/spectre-v1-poc-kmhv3/bare/20260720T085151Z/source clean AM_HOME=/nfs/home/leizhenyu/opt/DUTs/XiangShan-V3/third_party/nexus-am ARCH=riscv64-xs-flash
make -C /tmp/verified-poc/xiangshan-v3/spectre-v1-poc-kmhv3/bare/20260720T085151Z/source AM_HOME=/nfs/home/leizhenyu/opt/DUTs/XiangShan-V3/third_party/nexus-am ARCH=riscv64-xs-flash LINUX_GNU_TOOLCHAIN=1 MARCH=rv64gc_zba_zbb_zbc_zbs_zbkb_zbkc_zbkx_zknd_zkne_zknh_zkr_zksed_zksh_zkt_zicbom_zicboz CC_OPT= CPPFLAGS=-DCACHE_HIT_THRESHOLD=80\ -DUSE_FIXED_CACHE_HIT_THRESHOLD=1\ -DSECRET_SZ=6\ -DATTACK_SAME_ROUNDS=3\ -DTRAIN_TIMES=6\ -DFLUSH_CANDIDATE_LINES_ONLY=1\ -DFLUSH_LINES=256 -j8
ulimit -s 32768
timeout 40m /nfs/home/leizhenyu/opt/verified_poc/xiangshan-v3/spectre-v1-poc-kmhv3/profiles/bare/runtime/kmhv3-emu/emu --no-diff --seed=0 -i /tmp/verified-poc/xiangshan-v3/spectre-v1-poc-kmhv3/bare/20260720T085151Z/image
python3 /nfs/home/leizhenyu/opt/verified_poc/tools/parse_profile_log.py v1_basic S3CreT /nfs/home/leizhenyu/opt/verified_poc/xiangshan-v3/spectre-v1-poc-kmhv3/profiles/bare/runs/20260720T085151Z/run.log /nfs/home/leizhenyu/opt/verified_poc/xiangshan-v3/spectre-v1-poc-kmhv3/profiles/bare/runs/20260720T085151Z/result.json
# source image before copy: /tmp/verified-poc/xiangshan-v3/spectre-v1-poc-kmhv3/bare/20260720T085151Z/source/build/spectre-v1-riscv64-xs-flash.bin
