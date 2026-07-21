# Verified POC 仓库整理计划

本文件是仓库整理工作的唯一计划入口。具体复现规则见
`POC_REPRODUCIBILITY.md`，但目录与实施顺序以本文件为准。

## 1. 本轮边界

- 保留只读参考：`/nfs/home/leizhenyu/opt/verified_poc-reference-20260720`。
- 只整理目录、源码快照、EMU、命令和历史证据，不执行 `make`、EMU 或 POC。
- profile 名称只使用 `bare`、`sv39`、`sv48`，不使用 `historical/current`。
- 不使用 `manifest.json`。profile 身份由目录名表达，参数由
  `reproduce/profile.conf` 固定。
- 所有新 profile 初始状态均为 `NOT_RUN`；旧日志只作为 provenance。
- 先逐个完成 Spectre-v1，再处理 Spectre-v2。

## 2. 统一目录格式

```text
<processor>/<poc>/
├── run.sh                         # POC 级一键入口
├── profiles/
│   └── <bare|sv39|sv48>/
│       ├── source/                # 独立构建输入，不读取旧 code/build
│       ├── runtime/
│       │   ├── kmhv2-emu/emu or kmhv3-emu/emu  # profile 内普通可执行文件，禁止符号链接
│       │   ├── emu.sha256
│       │   ├── emu.build-id
│       │   ├── emu.file
│       │   ├── emu.readelf
│       │   ├── emu.ldd
│       │   ├── emu.help
│       │   └── noop-home/          # KMHv3 必需；KMHv2 仅保留证据
│       ├── reproduce/
│       │   ├── profile.conf        # 唯一参数清单和完整构建/运行配置
│       │   ├── run.sh              # verify -> clean build -> run -> parse
│       │   ├── verify.sh
│       │   ├── build.sh
│       │   └── parse.sh
│       ├── artifacts/              # 后续运行生成的镜像/哈希
│       └── runs/<run-id>/           # 后续运行日志；本轮保持为空
├── code/                           # 原仓库 legacy 快照，暂不删除
├── provenance/                     # 原始命令、来源和旧结果
└── README.md                       # profile、命令和限制说明
```

## 3. EMU 规则

- KMHv2 默认使用 profile 内的 `emu-16threads` 副本：
  SHA-256 `6ffccdb29be51b34133ed736075ca6a97cd006ead5ecb4dded599c06f7e67903`，
  Build ID `1481083d32d093176a1ac671e10b42872c87d007`。
- `emu-8threads -> emu-4threads -> emu-2threads -> emu-1threads` 只作为显式诊断候选，
  不自动回退；完整候选见 `EMU_CATALOG.tsv`。
- KMHv2 默认 Constantin 为 embedded：命令显式清除继承的 `NOOP_HOME`，不传
  `--cst-file`。
- KMHv3 使用 `kmhv3-emu-v2-baseline`，并设置 profile 内
  `runtime/noop-home/build/constantin.txt`。

## 4. Spectre-v1 实施顺序

| 顺序 | POC | profile | POC 级命令 | 本阶段状态 |
| --- | --- | --- | --- | --- |
| 1 | `xiangshan-v2/spectre-v1-poc-kmhv2` | `bare` | `./run.sh` | 整理中 |
| 2 | `xiangshan-v2/spectre-v1-priv-kmhv2` | `sv39`, `sv48` | `./run.sh sv39` / `./run.sh sv48` | 待整理 |
| 3 | `xiangshan-v2/spectre-v1-asid-kmhv2` | `sv39`, `sv48` | `./run.sh sv39` / `./run.sh sv48` | 待整理 |
| 4 | `xiangshan-v2/spectre-v1-vmid-kmhv2` | `sv39`, `sv48` | `./run.sh sv39` / `./run.sh sv48` | 待整理 |
| 5 | `xiangshan-v3/spectre-v1-poc-kmhv3` | `bare` | `./run.sh` | 待整理 |

每个 POC 按以下顺序收口：

1. 核对 profile 与源码中的实际分页模式；
2. 复制并哈希独立 source；
3. 放入对应 EMU、Build ID、依赖和 Constantin 证据；
4. 将准确的 `ARCH`、`MARCH`、`CPPFLAGS`、镜像名、seed 和 timeout 写入
   `reproduce/profile.conf`；
5. 写 POC 根 `README.md` 和 `run.sh`；
6. 只做 Shell/路径/哈希静态检查，保持 `runs/` 为空和状态 `NOT_RUN`。

## 5. 后续执行约定

本轮不会执行下面命令；它们只作为未来人工复现入口：

```bash
# 基础 POC
cd <processor>/<poc>
./run.sh

# 同时包含 Sv39/Sv48 的 POC
cd <processor>/<poc>
./run.sh sv39
./run.sh sv48
```

后续真正运行时，命令必须在新 scratch 中构建，生成唯一 `run-id`，并分别记录
预检、构建、EMU 退出和断言结果。未实际运行前不得把 `NOT_RUN` 改为 `PASS`。
