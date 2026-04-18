# Hermite Caveman — Terse Mode

> 🪨 why use many token when few token do trick

Adaptation of [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) for **Hermes Agent / OpenClaw**. Cuts output tokens ~75% while keeping full technical accuracy.

---

## Before / After

**Normal:**
> "当然！我很高兴帮你解决这个问题。你遇到的问题很可能是由于认证中间件没有正确验证 token 过期时间导致的。让我看一下并建议一个修复方案。"

**Terse (full):**
> "认证中间件 bug。Token 过期检查用了 < 而不是 <=。修："

**Same answer. 75% less word. Brain still big.**

---

## Quick Start

### Option A: Copy SOUL.md (recommended)
Copy the `SOUL.md` file's Terse Mode section into your Hermes `SOUL.md`. Rules take effect immediately — no install needed.

### Option B: Install as Skill
Copy `SKILL.md` into your skills directory and reference it from your SOUL.md.

---

## Levels

| Level | Style |
|-------|-------|
| `lite` | Drop filler/hedging only. Professional but tight. |
| `full` | Classic caveman. Fragments OK. **← Default** |
| `ultra` | Max compression. Abbreviations + arrows. |
| `wenyan` | 文言文风格. |

Switch: `/terse lite|full|ultra|wenyan`

---

## Exit
Say: `正常模式` / `normal mode` / `stop terse`

---

## Auto-Clarity
Terse pauses automatically for:
- Security warnings / irreversible actions
- User asks for detail (解释一下/详细点)
- Multi-step sequences at risk of misread

---

## Project Structure

```
hermite-caveman/
├── README.md       ← 你在这里
├── SOUL.md         ← Terse Mode 规则（直接复制到你的 SOUL.md）
├── SKILL.md        ← Skill 格式版本（可选）
└── LICENSE         ← MIT
```

---

## Credits

Based on [JuliusBrussee/caveman](https://github.com/JuliusBrussee/caveman) — 37.6k stars.

MIT License.
