# Hermite Caveman — Terse Mode

> 🪨 why use many token when few token do trick

**English | [中文](#中文)**

---

## What is this?

Adaptation of [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) for **Hermes Agent / OpenClaw**. Cuts output tokens ~75% while keeping full technical accuracy.

**Terse Mode is ON by default.** It compresses every reply automatically. No plugin install needed — just copy rules into `SOUL.md`.

---

## Before / After

**Normal (87 tokens):**
> "当然！我很高兴帮你解决这个问题。你遇到的问题很可能是由于认证中间件没有正确验证 token 过期时间导致的。让我看一下并建议一个修复方案。"

**Terse - full (24 tokens):**
> "认证中间件 bug。Token 过期检查用了 < 而不是 <=。修："

**Same answer. 75% less word. Brain still big.**

---

## Two Ways to Install / 两种安装方式

### Option A — Copy the Terse Mode section (recommended) / 推荐方式

Copy only the `## Terse Mode` section from `SOUL.md` and append it to your existing `SOUL.md` file.

**Steps:**
1. Open [`SOUL.md`](SOUL.md) in this repo
2. Find the `## Terse Mode` section
3. Copy that section into your Hermes `SOUL.md` file

---

### Option B — Replace your SOUL.md entirely / 完全覆盖方式

If your `SOUL.md` is empty or you want everything in one file, copy the entire [`SOUL.md`](SOUL.md) from this repo and replace your current one.

> ⚠️ This will replace all existing content in your SOUL.md.

**Steps:**
1. Backup your current `SOUL.md` first
2. Copy the entire content of [`SOUL.md`](SOUL.md)
3. Replace your file

---

## Levels / 级别

| Level | Description | 示例 |
|-------|-------------|------|
| `lite` | Drop filler/hedging only. Professional but tight. | "Your component re-renders because you create a new object reference each render. Wrap in useMemo." |
| `full` | Classic caveman. Fragments OK. Short synonyms. **← Default** | "New object ref each render. Inline object prop = new ref = re-render. useMemo." |
| `ultra` | Max compression. Abbreviations + arrows. | "Inline obj prop → new ref → re-render. useMemo." |
| `wenyan` | 文言文风格 Classical Chinese. | "物出新參照，致重繪。useMemo Wrap之。" |

**Switch level:** `/terse lite|full|ultra|wenyan`
**Exit:** `normal mode` / `正常模式`

---

## Auto-Clarity

Terse mode pauses automatically for / Terse 模式在这些情况下自动暂停：

- Security warnings / 安全警告
- Irreversible action confirmations / 不可逆操作确认
- User asks for detail: `解释一下` / `详细点` / `展开`
- Multi-step sequences at risk of misread / 多步骤指令可能产生误解时

Terse resumes after the clear part is done. / 明确部分完成后恢复 terse。

---

## How it works / 原理

The rules are written in `SOUL.md`. Hermes Agent reads SOUL.md on every session start, so the rules are always active — no skill loading needed.

Terse Mode is **persistent by default**. It stays on across all turns until you explicitly exit with `正常模式` or `normal mode`.

---

## Implementation: Original vs Hermite Caveman

### 原版 caveman 实现机制

原版针对 **Claude Code** 设计，有一套完整的多层架构：

```
Claude Code 启动时
    ↓
扫描项目根目录是否存在 .claude-plugin/
    ↓
若有 → 加载 .claude-plugin/settings.json
    ↓
注册三个 Hook：
  - SessionStart hook     → 每次启动自动执行
  - UserPromptSubmit hook → 用户每次发消息前执行
  - Caveman-statusline.sh → 状态栏显示
    ↓
SessionStart hook 做的事：
  1. 写入 flag 文件 $CLAUDE_CONFIG_DIR/.caveman-active，内容为 "full"
  2. stdout 打印 caveman 规则（Claude Code 把它注入为系统上下文，用户不可见）
  3. 检查 settings.json，若缺少 statusline 配置则提示用户
    ↓
UserPromptSubmit hook 做的事：
  1. 读取 flag 文件，获取当前模式
  2. 若用户输入匹配 /caveman 或自然语言激活词 → 更新 flag 文件
  3. 模式切换后，后续响应自动应用对应级别的压缩规则
```

**激活方式：**
- **自动激活：** 在项目目录有 `.claude-plugin/` 时，SessionStart hook 自动写入 "full" 到 flag 文件，后续所有回复自动压缩
- **手动激活：** `/caveman` 或 `talk like caveman` 等自然语言
- **持久化：** flag 文件机制确保跨会话保持激活状态

**核心文件：**
| 文件 | 作用 |
|------|------|
| `skills/caveman/SKILL.md` | 核心规则定义（6个级别、自动clarity、边界条件） |
| `rules/caveman-activate.md` | 自动激活规则的通用内容 |
| `.claude-plugin/settings.json` | 注册 Hook、定义状态栏 |
| `hooks/caveman-activate.js` | SessionStart hook 脚本 |
| `hooks/caveman-mode-tracker.js` | UserPromptSubmit hook 脚本 |
| `hooks/caveman-config.js` | 共享模块（flag 读写、默认模式解析） |
| `caveman.skill` | ZIP 包，分发给其他 agent 平台 |

**CI 自动同步：** `sync-skill.yml` 在 `skills/caveman/SKILL.md` 或 `rules/caveman-activate.md` 变更时自动触发，将规则同步到 Cursor、Windsurf、Cline、Copilot 等各平台的配置目录。

---

### Hermite Caveman 实现机制

针对 **Hermes Agent / OpenClaw** 重新设计，架构极简：

```
Hermes 启动时
    ↓
读取 SOUL.md 文件内容
    ↓
SOUL.md 中的 Terse Mode 规则被注入为系统上下文
    ↓
每个回复自动应用压缩规则
```

**激活方式：**
- **自动激活（默认）：** SOUL.md 中写明 `DEFAULT OUTPUT STYLE. Always active unless user explicitly exits.`
- **手动退出：** `正常模式` / `normal mode` / `stop terse`
- **手动切换：** `/terse lite|full|ultra|wenyan`
- **持久化：** 由 Hermes 自身的 SOUL.md 读取机制保证，每次启动自动加载

**核心文件：**
| 文件 | 作用 |
|------|------|
| `SOUL.md` | 完整的 Terse Mode 规则，直接嵌入 Hermes 系统配置 |
| `SKILL.md` | Skill 格式版本，可通过 skill loading 手动加载（可选） |

无 Hook 系统、无 flag 文件、无 CI 同步。纯规则注入。

---

### 一致性对比

| 维度 | 原版 caveman | Hermite Caveman | 说明 |
|------|-------------|-----------------|------|
| **核心规则** | ✅ 完全一致 | ✅ | 删除词完全相同，Pattern 一致 |
| **强度级别** | ✅ lite/full/ultra/wenyan-lite/wenyan-full/wenyan-ultra | ✅ lite/full/ultra/wenyan | Hermes 版本去掉了 wenyan 的 3 档细分，保留核心 4 档 |
| **Auto-Clarity** | ✅ | ✅ | 安全警告、不可逆操作、用户要求详细时自动退出 |
| **Code/commit/PR** | ✅ 正常书写 | ✅ | 两版均不压缩代码内容 |
| **退出指令** | ✅ "stop caveman" / "normal mode" | ✅ "stop terse" / "normal mode" / "正常模式" | Hermite 版本多加了中文指令 |
| **切换指令** | ✅ `/caveman lite|full|ultra` | ✅ `/terse lite|full|ultra|wenyan` | 名称不同但功能一致 |
| **Token 压缩效果** | ✅ ~75% | ✅ ~75% | 规则相同，效果一致 |

### 差异对比

| 维度 | 原版 caveman | Hermite Caveman | 原因 |
|------|-------------|-----------------|------|
| **平台** | Claude Code | Hermes / OpenClaw | 目标用户不同 |
| **激活机制** | Hook 系统 + flag 文件 + CI 同步 | SOUL.md 内置规则 | Hermes 没有 Claude Code 的 Hook API |
| **自动激活** | 需要项目目录有 `.claude-plugin/` | 默认激活，SOUL.md 存在即生效 | Hermes SOUL.md 读取是内置机制 |
| **持久化方式** | flag 文件（`~/.claude/.caveman-active`） | SOUL.md 读取（每次启动重新加载） | Hermes 无独立 flag 文件机制 |
| **Skill 格式** | `skills/caveman/SKILL.md` + `caveman.skill` ZIP | `SKILL.md`（可选，仅作 skill 加载备用） | Hermes skill 系统不支持 plugin 形式的自动加载 |
| **多 agent 分发** | CI 自动同步到 8+ 平台 | 单一平台，无分发需求 | 平台专属性质不同 |
| **状态栏显示** | `[CAVEMAN]` / `[CAVEMAN:ULTRA]` | 无 | Hermes 无 statusline 机制 |
| **CI 同步** | `sync-skill.yml` 自动同步到各平台 | 无 | Hermes 是单一平台 |
| **Wenyan 细分** | wenyan-lite / wenyan-full / wenyan-ultra | 单一 wenyan | Hermite 版本简化 |
| **配置灵活性** | `~/.config/caveman/config.json` 指定默认级别 | 硬编码 "full" 为默认 | Hermes SOUL.md 不支持外部配置读取 |

---

## Level Persistence / 级别持久化

原版用 flag 文件跨会话记住用户偏好的压缩级别。Hermite Caveman 用 MEMORY.md 实现同样效果：

```
用户说 /terse ultra
    ↓
更新 MEMORY.md：terse_level: ultra
    ↓
下次新会话启动
    ↓
读取 MEMORY.md → 发现 terse_level: ultra
    ↓
自动以 ultra 级别输出
```

每个 `/terse` 命令都会把偏好写入 MEMORY.md，下次启动自动生效。

---

## Project Structure / 项目结构

```
hermite-caveman/
├── README.md       ← This file (bilingual, implementation comparison)
├── SOUL.md         ← Full Terse Mode rules (copy section or entire file)
├── SKILL.md        ← Skill format version (optional, for skill-based loading)
└── LICENSE         ← MIT
```

---

## Credits

Based on [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) — 37.6k stars, MIT licensed.

---

## License

MIT License. See [`LICENSE`](LICENSE).

---

# 中文

# Hermite Caveman — Terse Mode

> 🪨 why use many token when few token do trick

**Hermes Agent / OpenClaw 的极度精简输出模式。将回复压缩约 75%，同时保留全部技术内容。**

**Terse Mode 默认开启。** 安装后自动生效，无需额外操作。

---

## 安装方式（二选一）

### 方式 A — 只复制 Terse Mode 部分（推荐）

只复制 `SOUL.md` 中的 `## Terse Mode` 章节，追加到你现有的 `SOUL.md` 文件末尾。

保留你原有的 SOUL.md 内容，只新增 terse 规则。

**步骤：**
1. 打开本仓库的 [`SOUL.md`](SOUL.md)
2. 找到 `## Terse Mode` 部分
3. 将该部分复制到你的 Hermes `SOUL.md` 文件末尾

---

### 方式 B — 完全覆盖 SOUL.md

如果你的 `SOUL.md` 是空的，或者想要完整版本，直接用本仓库的 [`SOUL.md`](SOUL.md) 整体覆盖。

> ⚠️ 这会替换掉你现有的所有 SOUL.md 内容，请先备份。

**步骤：**
1. 先备份你当前的 `SOUL.md`
2. 复制本仓库 [`SOUL.md`](SOUL.md) 的全部内容
3. 整体替换你的文件

---

## 级别

| 级别 | 说明 | 示例 |
|------|------|------|
| `lite` | 仅删除 filler/hedging。保留冠词和完整句子。专业简洁。 | "Your component re-renders because you create a new object reference each render. Wrap in useMemo." |
| `full` | 经典 caveman 风格。允许碎片化句子。**← 默认** | "New object ref each render. Inline object prop = new ref = re-render. useMemo." |
| `ultra` | 极致压缩。缩写 + 箭头表示因果。 | "Inline obj prop → new ref → re-render. useMemo." |
| `wenyan` | 文言文风格。 | "物出新參照，致重繪。useMemo Wrap之。" |

**切换级别：** `/terse lite|full|ultra|wenyan`
**退出：** `正常模式` / `normal mode`

---

## 自动退出情况

以下情况 Terse Mode 自动暂停，恢复正常输出：

- 安全警告 / 不可逆操作确认
- 用户要求详细解释：`解释一下` / `详细点` / `展开`
- 多步骤指令可能有误解风险

明确部分完成后自动恢复 Terse Mode。

---

## 实现机制：原版 vs Hermite Caveman

### 原版 caveman 架构（原版针对 Claude Code）

```
Claude Code 启动 → 扫描项目 .claude-plugin/ → 注册 Hook
  SessionStart hook：写 flag 文件 + 打印规则到 stdout
  UserPromptSubmit hook：读 flag 文件 + 模式切换
  flag 文件：~/.claude/.caveman-active
```

**关键组件：**
- `skills/caveman/SKILL.md` — 核心规则（单一真实来源）
- `rules/caveman-activate.md` — 自动激活规则体
- `.claude-plugin/settings.json` — Hook 注册
- `hooks/caveman-activate.js` — SessionStart hook
- `hooks/caveman-mode-tracker.js` — UserPromptSubmit hook
- `hooks/caveman-config.js` — 共享配置模块
- `caveman.skill` — ZIP 发布包
- `.github/workflows/sync-skill.yml` — CI 自动同步到多平台

**激活流程：**
1. 有 `.claude-plugin/` 的项目启动时，SessionStart hook 自动执行
2. 写入 flag 文件（`full`）+ 打印规则到 stdout（注入系统上下文）
3. 后续所有回复自动压缩
4. `/caveman` 或自然语言可切换模式
5. flag 文件保证跨会话持久化

---

### Hermite Caveman 架构（针对 Hermes / OpenClaw）

```
Hermes 启动 → 读取 SOUL.md → Terse Mode 规则注入上下文
```

**关键组件：**
- `SOUL.md` — 核心规则（直接嵌入 Hermes 配置）
- `SKILL.md` — 可选，仅用于 skill 加载备用

**激活流程：**
1. Hermes 每次启动读取 SOUL.md
2. Terse Mode 规则作为系统指令注入
3. 默认激活，无需任何操作
4. `正常模式` 可退出，`/terse` 可切换
5. 每次启动自动重新激活（由 SOUL.md 保证）

---

### 核心差异原因

| 差异 | 原因 |
|------|------|
| Hermite 无 Hook 系统 | Hermes / OpenClaw 不提供 Claude Code 那种 SessionStart / UserPromptSubmit Hook API |
| Hermite 默认激活 | Hermes 的 SOUL.md 读取是内置机制，文件存在即生效，不需要额外触发 |
| Hermite 无 flag 文件 | Hermes 没有独立的持久化 flag 机制，状态由 SOUL.md 内容决定 |
| Hermite 无多平台同步 | Claude Code 用户分布多平台（Cursor/Windsurf/Cline 等），Hermes 用户集中在单一平台 |
| Hermite 无状态栏 | Hermes 没有 statusline 机制显示 `[CAVEMAN]` 状态 |

---

## 级别持久化

原版用 flag 文件跨会话记住级别偏好。Hermite Caveman 用 MEMORY.md 实现同样效果：每个 `/terse xxx` 命令写入 `terse_level: xxx`，下次启动自动读取生效。

---

## 致谢

基于 [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman)（37.6k stars，MIT License）。

---

## 开源协议

MIT License。见 [`LICENSE`](LICENSE)。
