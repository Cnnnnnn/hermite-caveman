# Changelog

## v1.2.1

### SOUL.md Size Optimization
- **Reduced from 14.4KB → 8.4KB (42% saving)** while preserving all 12 mechanisms
- Removed redundant content: decision tree → 8-line prioritized list, duplicate tables → merged, verbose prose → bullet points
- Surviving mechanisms: Conversation-Level Memory, Semantic Density Detection, AssertionTracker, User Preference Learning, Wenyan Structural Rules, Compression Quality Score, Multilingual Awareness, Adaptive Compression, Auto-Escalation, Code Boundaries, Auto-Clarity, Wenyan Sub-Levels
- Result: stronger signal-to-noise ratio in SOUL competition, less token overhead per response

---

## v1.2.0

### New Features

**1. Conversation-Level Memory**
Track already-covered topics within a session. Subsequent references to explained concepts are compressed more aggressively (pronoun/label, no re-explanation). Session-scoped, resets each new session.

**2. Semantic Density Detection**
Before compressing, estimate information density using high-density signals (PE/MACD/毛利率/北向资金/percentages) vs low-density signals (当然/其实/可能/应该). High-density → one level LESS compression; Low-density → one level MORE compression.

**3. AssertionTracker**
Maintain a running set of key assertions (stock positions, financial ratios, directional claims) within the conversation. Detect contradictions and de-escalate to `full` with a conflict note.

**4. User Preference Learning**
Track `terse_upgrades` and `terse_degrades` counts in MEMORY.md. If user frequently manually escalates → default level auto-upgrades one tier. If frequently degrades → auto-downgrades. Silent, persistent.

**5. Wenyan Structural Rules**
wenyan compression now uses grammatical structure transformations (语序倒装, 主语省略, 动词优先) instead of simple word substitution. English technical terms stay as-is.

**6. Compression Quality Score**
Beyond ratio, verify.sh now measures: fact preservation (numbers), direction preservation (涨/跌/buy/sell), and action preservation (修/查/fix/check). Quality-weighted score displayed alongside ratio.

### verify.sh changes (v4)
- `--quality` flag: quality-weighted scoring mode
- `semantic_density()` function: high/medium/low detection
- `quality_check()` function: fact/direction/action preservation
- `weighted_score()`: ratio × quality factor
- Section [2]: Semantic Density Detection tests
- Section [3]: Quality Score tests
- Section [5]: Weighted score in benchmark results
- All 4 levels now show quality status and weighted score

---

## v1.1.0

### New Features
- **Adaptive Compression** — auto-selects best level by task type, language, output length
- **Auto-Escalation** — output >800 chars mid-response escalates to ultra
- **Multilingual Awareness** — handles Chinese/English mixed output naturally
- **wenyan sub-levels** — wenyan-lite / wenyan-full / wenyan-ultra
- **Maintenance Scripts** — update.sh, uninstall.sh, verify.sh
- **TROUBLESHOOTING.md** — common issues + fixes
- **Enhanced verify.sh v3** — char-based token estimation, 4-level sed simulation, pass/fail thresholds

### verify.sh changes (v3)
- `count_tokens()` char-based: zh=1/char, en=1.3/word
- Built-in 4-level sed compression simulation
- Pass thresholds: lite≥20%, full≥40%, ultra≥60%, wenyan≥70%
- Built-in benchmark with fixed texts
- `--custom` flag for user text
- HTTP reachability checks
- Exit 0/1 for CI integration

---

## v1.0.0
- Initial release
- Terse Mode as default (full level)
- SOUL.md injection approach
- MEMORY.md level persistence
- Single-file bilingual README (EN + ZH)
- Idempotent install.sh with update-check
- SkillHub publish (deferred — requires phone login)
- Based on JuliusBrussee/caveman
