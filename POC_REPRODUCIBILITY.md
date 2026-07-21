# POC-RP-1.0 可复现性规范

本文定义 `verified_poc` 中 XiangShan 瞬态执行 POC 的打包、运行、记录和验收规则。
规范的目标是让一个 POC/profile 能够在脱离原始工作目录后被逐项检查、构建、运行和复盘。
规范不把一次历史日志自动提升为当前源码的成功结论，也不把更换 EMU 后的结果静默合并。

本文是仓库级规范。POC 的具体实验参数、预期输出和已知限制应写入该 POC 的
`README.md` 和 `manifest.json`，而不是只写在聊天记录或未结构化的日志中。

## 1. 术语和身份

一个可复现对象由下列字段共同定义：

```text
(processor, poc_id, vm_mode, source_tree_sha256, image_sha256, emu_sha256)
```

- `processor`：处理器代号，例如 `xiangshan-v2` 或 `xiangshan-v3`。
- `poc_id`：POC 名称，例如 `spectre-v1-priv-kmhv2`。
- `vm_mode`：地址转换 profile，取值只能是 `bare`、`sv39` 或 `sv48`。
- `source_tree_sha256`：参与构建的源码和构建输入的规范化树哈希。
- `image_sha256`：实际交给 EMU 的 ELF、镜像或 flash 输入的哈希。
- `emu_sha256`：解引用并物化后的 EMU 普通文件哈希。
- `emu_candidate_id`：EMU 候选的稳定名称；它不是 profile 名称的一部分。
- `run_id`：一次不可覆盖的运行记录标识，建议使用 UTC 时间加短标签。

`bare` 表示该 POC 不建立 Sv39/Sv48 页表，不能因为处理器支持分页而将其标为
`sv39` 或 `sv48`。`sv39` 和 `sv48` 只表示源码实际构造并启用的 RISC-V 地址转换模式。
如果同一 POC 同时保留两种模式，必须使用两个独立 profile、manifest、构建产物和运行目录。

规范禁止使用 `historical`、`current` 作为 profile 名称。旧版本和新版本按其实际
`vm_mode` 归档；如果源码模式未知，则不得创建正式 profile（也不能把它猜成 `bare`），
应先放在 provenance 中并在待处理记录里标记 `ENV_MISMATCH`，不能靠目录名猜测。

## 2. 复现等级

每个 profile 必须声明一个复现等级。等级是递进的，较高等级包含较低等级的全部要求。

| 等级 | 名称 | 必需内容 | 可以宣称的结论 |
| --- | --- | --- | --- |
| `R0` | 历史证据 | 源码/命令/日志中至少有可核查的来源和时间；不要求能重跑 | 只能引用为历史证据，不能宣称本仓库可重放 |
| `R1` | 运行重放 | profile 内有固定输入、已物化 EMU、运行参数、依赖检查和结果解析器 | 可以在满足主机 ABI 前提下重放运行；不保证从源码重建 |
| `R2` | 源码重建 | `R1` 全部内容，加上源码、构建依赖、工具链信息和 clean build | 可以在声明的工具链/主机约束内从源码重建并运行 |
| `R3` | 可移植重放 | `R2` 全部内容，加上容器或等效运行库锁定、完整外部依赖封装 | 可以在支持的 CPU/内核约束内跨工作目录或主机重放 |

R0 记录不得伪装成 R1。R1 的 EMU 必须复制到 POC/profile 包内；只保存
`/nfs/home/...` 的绝对路径不满足 R1。R2 的构建必须从干净 scratch 目录开始，不能
把已有的 `code/build` 当作 clean build 证据。R3 仍需记录 CPU、内核和资源约束，
因为仿真性能和信号行为可能受这些约束影响。

## 3. 目录和封装布局

现有仓库中的 `code/`、`provenance/` 和 `logs/` 是兼容输入；迁移完成后，新的可运行
profile 应按下列布局组织。迁移不得删除原始 provenance。

```text
<processor>/<poc-id>/
├── profiles/
│   ├── bare/
│   │   ├── manifest.json
│   │   ├── source/                 # R2/R3 必须物化；R1 可引用已哈希的输入快照
│   │   ├── runtime/
│   │   │   ├── kmhv2-emu/emu or kmhv3-emu/emu  # 必须是可执行普通文件，禁止符号链接
│   │   │   ├── emu.sha256
│   │   │   ├── emu.build-id
│   │   │   ├── emu.file
│   │   │   ├── emu.readelf
│   │   │   ├── emu.ldd
│   │   │   ├── emu.help
│   │   │   ├── config/              # 只放该候选需要的配置
│   │   │   └── noop-home/           # KMHv3 时包含 build/constantin.txt
│   │   ├── artifacts/               # ELF/镜像及其哈希
│   │   ├── reproduce/
│   │   │   ├── verify.sh
│   │   │   ├── build.sh
│   │   │   ├── run.sh
│   │   │   └── parse.sh
│   │   └── runs/<run-id>/
│   ├── sv39/
│   │   └── ...                      # 结构同上
│   └── sv48/
│       └── ...                      # 结构同上
├── emu-catalog.tsv                  # 该 POC 可用候选及指纹
├── provenance/                      # 原始来源、历史命令和未改写证据
└── README.md
```

每一个实际可运行的 profile 都必须拥有自己的 `runtime/kmhv2-emu/emu` 或
`runtime/kmhv3-emu/emu`。开发阶段可以从
按哈希管理的只读 EMU 缓存复制，但归档或导出时必须使用 `cp -L` 物化；绝对路径、
相对仓库外路径和符号链接都不能作为最终包的 EMU。profile 之间可以通过内容复制
共享相同哈希，但 manifest 仍要记录各自的路径和校验值。

现有 `code/` 目录可以在迁移阶段作为 `source/` 的来源，现有 `provenance/` 文件
作为 R0 证据保留。已经生成的 `build/` 只有在记录了完整构建命令、输入哈希和产物
哈希后才能进入 R1/R2 证据链；否则只标记为非规范构建产物。

## 4. EMU 目录、候选和回退

### 4.1 候选的强制指纹

`emu-catalog.tsv`（或等价 JSON）每行代表一个候选。至少包含以下字段：

```text
candidate_id
processor
source_path
materialized_path
sha256
size_bytes
build_id
compile_time
emu_threads
trace_enabled
chisel_db_enabled
config_no_difftest
rtl_or_vsimtop_sha256
dynamic_libs
constantin_mode
status
```

`source_path` 只用于 provenance；运行脚本必须使用 profile 内的
`materialized_path`。指纹生成前先执行 `readlink -f`，对目标普通文件计算 SHA-256，
并保存 `file`、`readelf -n`、`ldd`、`--help` 输出。还应记录 EMU 构建时的 XiangShan
commit、分支、dirty diff（如有）和配置文件哈希。仅有文件名或 mtime 不足以区分候选。

### 4.2 KMHv2 选择规则

KMHv2 的 canonical 首选是用户指定的稳定构建：

```text
/nfs/home/leizhenyu/opt/DUTs/XiangShan/build/emu-16threads
```

复制到 profile 后，manifest 必须记录物化文件的完整 SHA-256 和 Build ID；上述路径
本身不是身份标识。`emu-8threads`、`emu-4threads`、`emu-2threads`、`emu-1threads`
属于同一候选族，按此顺序作为诊断回退：

```text
emu-16threads -> emu-8threads -> emu-4threads -> emu-2threads -> emu-1threads
```

回退只在候选预检成功但运行断言失败、崩溃或无法推进时进行，并且必须保持源码、
镜像、seed、EMU 参数、超时和资源限制不变。当前构建目录中的
`verilator-compile/emu`（以及不同配置、不同 RTL 或不同 diff-test 选项的 EMU）不是
上述候选族的自动替代品，必须作为新的 `candidate_id` 经过兼容性检查。

如果首选候选的断言失败，先在同一 scratch 输入上以相同 seed 重跑两次；两次结果不一致
时标记 `NONCANONICAL` 或 `INDETERMINATE`，不要立即切换 EMU。每个候选的尝试都要留有
独立 run 目录，即使候选失败或没有输出也不能只保留最后成功的候选。

### 4.3 KMHv3 和专用构建

KMHv3 的 baseline、CMO 或其他专用 EMU 只能用于与其 RTL、生成配置、输入格式和
`constantin.txt` 相匹配的 profile。`emu.cmo-*`、`emu.pre-cmo` 等备份不得按
“同一代处理器”自动替换 baseline。候选切换只改变 `emu_candidate_id` 及其物化文件，
不得同时修改 POC 源码或结果判据。

### 4.4 预检

`verify.sh` 在每次构建或运行前必须检查：

1. `runtime/kmhv2-emu/emu` 或 `runtime/kmhv3-emu/emu` 存在、可执行且不是符号链接；
2. `sha256sum -c`、Build ID、文件类型和大小与 manifest 一致；
3. `ldd` 中的动态库可解析，缺库时返回 `ENV_MISMATCH`；
4. `emu --help` 成功；
5. 使用极短 `--max-cycles` 或等价参数执行 smoke，记录退出码和输出；
6. `NOOP_HOME`、Constantin 文件（若需要）和输入镜像都解析到包内相对路径；
7. 记录栈大小、地址空间/内存限制、CPU 线程数、seed、locale、时区和超时。

预检失败时不得进入长时间运行。预检通过不等于 POC 断言通过，二者必须分开记录。

## 5. Constantin 依赖规则

两代 EMU 的 Constantin 处理方式不同，不能用一个通用的“找
`constantin.txt`”脚本掩盖差异。

### 5.1 KMHv2：默认 embedded

KMHv2 默认运行路径使用 EMU 内置的 Constantin 初始化。只要命令行没有传入
`--cst-file`，profile 不要求外部 `constantin.txt`，manifest 应写：

```json
"constantin": {
  "mode": "embedded",
  "path": null,
  "sha256": null
}
```

运行脚本必须保留这一默认行为，不能因为设置了 `NOOP_HOME` 就悄悄改为读取外部
文件。某些 KMHv2 构建还会编译可选的 `${NOOP_HOME}/build/constantin.txt` 自动加载
路径；如果文件访问审计显示该路径被打开，应将模式记为
`optional-autoload` 并记录文件哈希，但文件缺失仍不能被解释为 KMHv3 那样的必需依赖。
若某个 KMHv2 实验显式使用 `--cst-file`，则它属于
`mode: "external-explicit"`：必须把实际文件复制到 `runtime/`，记录相对路径和
SHA-256，并在命令、manifest 和 run 日志中明确该覆盖项。

### 5.2 KMHv3：required external file

KMHv3 运行时必须提供 `${NOOP_HOME}/build/constantin.txt`。profile 应将该文件
物化为例如：

```text
runtime/noop-home/build/constantin.txt
```

`run.sh` 必须把 `NOOP_HOME` 设置为 profile 内的相对目录（通过脚本自身位置解析），
并在预检中校验文件存在、可读和 SHA-256 一致。找不到该文件、使用了包外默认
`NOOP_HOME` 或哈希不一致时，状态必须是 `ENV_MISMATCH`，不能继续运行。

### 5.3 依赖审计

首次封装和 EMU 更换时，应使用 `strace -e trace=file` 或等价文件访问审计确认实际
打开的非系统文件。任何未列入 manifest 的配置、镜像、Constantin 文件或脚本都必须
补入 `runtime/`，或显式记录为主机前置条件并将等级限制为 R0/R1。

## 6. `manifest.json` 最低字段

manifest 是 profile 的规范入口。所有路径使用相对于 profile 根的路径；原始主机绝对
路径只能出现在 `provenance` 字段或单独的历史文件中。下面是最小示例，实际项目可增加
字段但不能删除必需字段：

```json
{
  "schema_version": "POC-RP-1.0",
  "poc_id": "spectre-v1-priv-kmhv2",
  "processor": "xiangshan-v2",
  "vm_mode": "sv48",
  "reproducibility_level": "R2",
  "source": {
    "path": "source",
    "tree_sha256": "...",
    "origin": "...",
    "origin_commit": "...",
    "dirty_diff_sha256": "..."
  },
  "build": {
    "am_root": "source/nexus-am",
    "am_commit": "...",
    "toolchain": "riscv64-unknown-elf-gcc ...",
    "arch": "riscv64-xs",
    "march": "...",
    "defines": ["SECRET_SZ=6"],
    "command_sha256": "..."
  },
  "input": {
    "image": "artifacts/poc.elf",
    "image_sha256": "..."
  },
  "runtime": {
    "emu_candidate_id": "kmhv2-emu-16threads-20260629",
    "emu": "runtime/kmhv2-emu/emu",
    "emu_sha256": "...",
    "emu_build_id": "...",
    "args": ["--no-diff"],
    "seed": null,
    "wall_timeout_sec": 1200,
    "max_cycles": null,
    "constantin": {
      "mode": "embedded",
      "path": null,
      "sha256": null
    }
  },
  "expected": {
    "predicate": "v1_full_string",
    "secret": "S3CreT",
    "secret_length": 6
  },
  "provenance": {
    "captured_at_utc": "...",
    "source_absolute_path": "..."
  }
}
```

`expected.secret` 可以按仓库安全策略改为哈希或脱敏值；解析器必须仍能验证完整
断言。manifest 的哈希应在封装后冻结，运行中不得被脚本改写。

## 7. 构建和运行记录

每一次尝试使用新的 `runs/<run-id>/`，禁止覆盖旧目录。至少包含：

```text
runs/<run-id>/
├── manifest.json       # 运行时使用的不可变副本
├── command.sh          # 完整、可执行的实际命令
├── env.txt             # 环境变量和资源限制
├── host.txt            # uname、CPU、内核和主机信息
├── toolchain.txt       # 编译器、binutils、make、AM 版本
├── preflight.log
├── build.log           # R2/R3 必需；R1 可为 not-run
├── run.log             # stdout/stderr，保留原始顺序
├── parse.log
├── result.json         # 机器可读断言结果
├── status.json         # 分阶段退出码、耗时、信号和超时原因
└── SHA256SUMS
```

`status.json` 至少记录 `verify_exit`、`build_exit`、`run_exit`、`parse_exit`、开始/结束
时间、墙钟耗时、信号、超时标志、`emu_candidate_id`、`emu_sha256` 和 scratch 路径。
日志应包含 EMU 版本 banner、完整参数、`NOOP_HOME`、工作目录和输入哈希。

运行协议如下：

1. 从只读 profile 复制到新的 scratch 目录，并执行 `verify.sh`；
2. 固定 `LC_ALL=C`、`TZ=UTC`、`HOME`、`TMPDIR`、seed、栈大小和超时；
3. R2/R3 先执行 clean build，保存构建命令、日志、退出码和产物哈希；
4. 仅使用 manifest 指定的本地 EMU、输入和相对路径执行 runtime；
5. 独立执行 `parse.sh`，生成 `result.json`，不依赖人工 grep 的单行输出；
6. 在 fresh scratch 上至少再做一次 replay，确认结果不是旧 build、旧日志或共享
   `AM_HOME` 造成的假成功。

构建、运行、解析必须分阶段记录。运行超时后可以保留进程诊断和部分日志，但不能将
超时目录重命名为成功目录。

## 8. 状态和验收判据

状态分为阶段状态和最终状态。推荐使用以下枚举：

```text
PACKAGE_PASS       profile 文件、路径和哈希完整
BUILD_PASS         clean build 成功
BUILD_FAIL         构建失败
RUN_PASS           EMU 正常退出或达到明确的运行终点
RUN_TIMEOUT        达到 wall/cycle timeout
RUN_CRASH          信号退出或 EMU 崩溃
RUN_INCOMPLETE     启动后停滞、输出不完整或无法判定
ASSERTION_PASS     POC 专属断言全部满足
ASSERTION_FAIL     至少一个断言不满足
STATIC_ONLY        只有源码/二进制静态检查通过
ENV_MISMATCH       依赖、哈希、工具链或主机约束不匹配
NONCANONICAL       诊断参数、非首选候选或不完整输入产生的结果
INDETERMINATE      重复运行结果不稳定，无法归因
```

只有同时满足以下条件，最终状态才可写 `PASS`：

- `PACKAGE_PASS`，且 manifest、EMU、输入和依赖哈希全部通过；
- 对 R2/R3，`BUILD_PASS` 来自 clean scratch；
- `RUN_PASS`，无 timeout、崩溃或停滞；
- `ASSERTION_PASS`，且使用的 EMU 候选和参数已在 manifest 中批准；
- fresh-scratch replay 得到同一断言结论。

`RUN_PASS` 不等于 `ASSERTION_PASS`。EMU 正常退出但猜测结果错误必须是
`ASSERTION_FAIL`；只完成静态检查的页表 POC 必须是 `STATIC_ONLY`。部分泄漏、噪声
top-1、启动 banner 后停滞和超时都不能写成 `PASS`。切换候选得到的结果首先属于
该候选的 `run_id`，只有经过维护者确认兼容性后才能更新 canonical 状态。

各类 POC 的默认断言应明确写入 manifest：

- v1/v3 基础 POC：完整 secret 的 top-1 与预期字符串一致；
- v2 基础 POC：每个 `check i expected guess` 均一致；
- privilege/ASID/VMID POC：先验证隔离或 fault 行为，再验证泄漏结果和最终 check；
- 任意模式：输出缺失、结果截断或只命中部分字节均不能满足完整断言。

## 9. Registry 和日志整合

`POC_REGISTRY.tsv` 应逐步改为“一行一个 profile”，至少增加：

```text
vm_mode	reproducibility_level	manifest	canonical_emu_candidate_id	canonical_emu_sha256	status
```

已有 `code_path`、原始 EMU 路径和历史结果字段可以保留为 provenance，但不能替代
profile manifest。详细构建、运行和候选比较结果放在：

```text
logs/<processor>/<poc-id>/<run-id>/
```

日志目录名必须与 `status.json.run_id` 一致。探索性参数、控制实验和失败候选不得覆盖
canonical 目录；应使用单独的 `run_id` 并标记 `NONCANONICAL`。

## 10. 实施顺序和迁移检查表

按以下顺序为现有仓库落地规范：

1. 为 `spectre-v1-poc-kmhv2/bare` 建立 pilot，物化 `emu-16threads`，生成 manifest、
   `verify.sh` 和一组完整 run 记录；
2. 在随机 scratch 根目录中断开 `/opt/testbench`、外部 EMU 和外部 `AM_HOME`，验证
   pilot 仍可预检和 smoke；
3. 为三个基础 POC 完成 `bare` profile，并记录 KMHv2 候选族的健康矩阵；
4. 为页表 POC 按源码实际模式建立 `sv39` 或 `sv48` profile。若两种源码都保留，
   建立两个独立目录，不用 `historical/current` 命名；
5. 为 KMHv3 profile 封装必需的 `runtime/noop-home/build/constantin.txt`，并校验
   `NOOP_HOME` 不会逃逸到包外；
6. 迁移 registry、README 和 runner，使 runner 只接受 profile/manifest，不再依赖
   隐式绝对路径；
7. 完成所有 profile 的 fresh-scratch replay 后，再冻结新的参考快照和校验清单。

迁移期间，任何旧日志都按其实际源码模式和 EMU 哈希重新归档。旧日志没有足够指纹时
只能标为 R0/`NONCANONICAL`，不得凭目录或文件名推断 `sv39`、`sv48` 或 canonical EMU。

## 11. 最终验收清单

维护者在宣布某个 profile 完成前，逐项确认：

- [ ] profile 名称是 `bare`、`sv39` 或 `sv48`，且与源码实际行为一致；
- [ ] `manifest.json` 存在并通过 schema/路径/哈希检查；
- [ ] `runtime/kmhv2-emu/emu` 或 `runtime/kmhv3-emu/emu` 是包内可执行普通文件，不是符号链接；
- [ ] EMU SHA-256、Build ID、配置、动态库和候选 ID 已记录；
- [ ] KMHv2 的 Constantin 模式或 KMHv3 的 `constantin.txt` 已明确并验证；
- [ ] 输入镜像、源码、AM、工具链和构建参数已固定到声明的复现等级；
- [ ] 预检、build、run、parse 日志和退出码齐全；
- [ ] 每个 EMU 候选尝试都有独立 `run_id`，没有静默替换；
- [ ] 至少一次 fresh-scratch replay 与 canonical 结论一致；
- [ ] 最终状态同时反映运行成功和断言成功，没有把 timeout、partial 或 static-only
      结果写成 PASS。

## 12. 本轮封装边界（2026-07-20）

本轮只完成静态封装，不执行 `make`、EMU 或 POC。11 个 profile 已有独立的
`source/`、`runtime/`、`artifacts/`、`runs/` 和 `reproduce/`，并以
`manifest.json` 固定源码树哈希、构建参数、EMU SHA/Build ID、seed=0、墙钟超时和
断言。每个 profile 的 `reproduce/run.sh` 是后续唯一的一键入口；它会在临时 scratch
中复制 source、清理并构建，不写入旧的 `code/build`。

当前 `reproducibility_level` 保守标为 `R1`、`status` 标为 `NOT_RUN`：EMU 已物化，
但 AM/toolchain 仍是清单中明确的外部前置，且本轮没有产生新的 clean-build、run 或
assertion 证据。只有后续命令完成并通过分阶段验收后，才能把 profile 升级为 R2 或
写入 `PASS`。

为使每个 profile 自包含，打包副本中的旧跨 POC include 已归一化到同一
`source/src` 下的头文件；这只改变 profile 快照，不修改保留的 legacy `code/`。
原始 Sv39 快照路径、旧命令和旧日志仍只通过 `provenance` 字段引用。
