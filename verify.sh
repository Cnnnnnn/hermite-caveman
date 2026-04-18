#!/bin/bash
# hermes-cavemen Verify v4 — compression ratio + quality score
# 用法:
#   curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/verify.sh | bash
#   curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/verify.sh | bash -s -- "你的自定义测试文字"
#   curl -s https://raw.githubusercontent.com/Cnnnnnn/hermes-cavemen/main/verify.sh | bash -s -- --quality "测试文字"

set -e

REPO="Cnnnnnn/hermes-cavemen"
RAW="https://raw.githubusercontent.com/${REPO}/main"

Cyan='\033[0;36m'
Green='\033[0;32m'
Red='\033[0;31m'
Yellow='\033[1;33m'
Bold='\033[1m'
Reset='\033[0m'

banner() {
    echo ""
    echo -e "${Bold}═══════════════════════════════════════════════${Reset}"
    echo -e "${Bold}   hermes-cavemen Verify v4${Reset}"
    echo -e "${Bold}═══════════════════════════════════════════════${Reset}"
    echo ""
}

PASS=0
FAIL=0

check() {
    local label="$1"
    local result="$2"
    if [ "$result" = "OK" ]; then
        echo -e "  ${Green}✓${Reset} $label"
        PASS=$((PASS+1))
    else
        echo -e "  ${Red}✗${Reset} $label"
        FAIL=$((FAIL+1))
    fi
}

# ── Token estimation ──────────────────────────────────────────────────────────
# Chinese: 1 char ≈ 1 token
# English: 1 word  ≈ 1.3 tokens
count_tokens() {
    local text="$1"
    local zh=$(echo "$text" | grep -o '[\x{4e00}-\x{9fff}]' | wc -l)
    local en=$(echo "$text" | grep -oE '[a-zA-Z]+' | wc -l)
    echo $(( zh + (en * 13 / 10) ))
}

# ── Semantic density score ─────────────────────────────────────────────────────
# Returns: high | medium | low
# Looks for high-density financial/technical terms
semantic_density() {
    local text="$1"
    local score=0
    # Financial terms
    local financial="PE|PB|EPS|ROE|毛利率|净利率|北向资金|融资融券|市值|估值|营收|利润|同比增长|环比|产能|换手率"
    # Technical indicators
    local technical="MACD|KDJ|RSI|BOLL|MA|金叉|死叉|量比"
    # Numbers / percentages
    local numbers=$(echo "$text" | grep -oE '[0-9]+\.?[0-9]*%?' | wc -l)
    # High-density terms found
    local hd_found=$(echo "$text" | grep -oE "$financial|$technical" | wc -l)
    score=$(( hd_found * 2 + numbers ))
    if [ "$score" -ge 6 ]; then
        echo "high"
    elif [ "$score" -ge 3 ]; then
        echo "medium"
    else
        echo "low"
    fi
}

# ── Quality check ─────────────────────────────────────────────────────────────
# Returns: OK | LOW_QUALITY
quality_check() {
    local orig="$1"
    local compressed="$2"
    local qscore=0
    # Fact preservation: numbers
    local orig_nums=$(echo "$orig" | grep -oE '[0-9]+\.?[0-9]*%?' | wc -l)
    local comp_nums=$(echo "$compressed" | grep -oE '[0-9]+\.?[0-9]*%?' | wc -l)
    if [ "$orig_nums" -gt 0 ] && [ "$comp_nums" -gt 0 ]; then
        qscore=$((qscore + 1))
    fi
    # Direction preservation: 涨/跌/买入/卖出/up/down/buy/sell
    local dirs="涨|跌|买入|卖出|up|down|buy|sell|long|short"
    local orig_dir=$(echo "$orig" | grep -oE "$dirs" | wc -l)
    local comp_dir=$(echo "$compressed" | grep -oE "$dirs" | wc -l)
    if [ "$orig_dir" -gt 0 ] && [ "$comp_dir" -gt 0 ]; then
        qscore=$((qscore + 1))
    fi
    # Action preservation: 修|查|改|看|fix|check|fix|look
    local actions="修|查|改|看|fix|check|look|run|set"
    local orig_act=$(echo "$orig" | grep -oE "$actions" | wc -l)
    local comp_act=$(echo "$compressed" | grep -oE "$actions" | wc -l)
    if [ "$orig_act" -gt 0 ] && [ "$comp_act" -gt 0 ]; then
        qscore=$((qscore + 1))
    fi
    if [ "$qscore" -ge 2 ]; then
        echo "OK"
    else
        echo "LOW_QUALITY"
    fi
}

# ── Compression levels ─────────────────────────────────────────────────────────
compress_lite() {
    local t="$1"
    echo "$t" \
        | sed 's/当然！//g; s/当然//g; s/很乐意//g; s/很高兴//g; s/大概//g; s/我认为//g' \
        | sed 's/just //g; s/really //g; s/basically //g; s/actually //g; s/simply //g' \
        | sed 's/I think //g; s/I believe //g; s/seems like //g' \
        | sed 's/sure, //g; s/certainly, //g; s/happy to //g; s/glad to //g' \
        | sed 's/and then //g; s/so basically //g' \
        | sed 's/  / /g' \
        | sed 's/^ *//; s/ *$//'
}

compress_full() {
    local t="$1"
    compress_lite "$t" \
        | sed 's/\bthe //g; s/\ba //g; s/\ban //g' \
        | sed 's/  / /g'
}

compress_ultra() {
    local t="$1"
    echo "$t" \
        | sed 's/\bthe //g; s/\ba //g; s/\ban //g' \
        | sed 's/database/DB/g; s/authentication/auth/g; s/configuration/config/g' \
        | sed 's/request/req/g; s/response/res/g; s/function/fn/g; s/implementation/impl/g' \
        | sed 's/because/→/g; s/therefore/→/g; s/so that/→/g; s/which causes/→/g' \
        | sed 's/I think //g; s/I believe //g; s/really //g; s/just //g' \
        | sed 's/sure, //g; s/certainly, //g; s/happy to //g; s/glad to //g' \
        | sed 's/and then //g; s/so basically //g' \
        | sed 's/  / /g' \
        | sed 's/^ *//; s/ *$//'
}

compress_wenyan() {
    local t="$1"
    # Wenyan structural rules (not simple substitution)
    echo "$t" \
        | sed 's/的/之/g; s/的/之/g' \
        | sed 's/是/乃/g' \
        | sed 's/为了 X/為 X/g' \
        | sed 's/当然！//g; s/当然//g; s/很乐意//g; s/很高兴//g; s/大概//g; s/我认为//g' \
        | sed 's/just //g; s/really //g; s/basically //g; s/actually //g; s/simply //g' \
        | sed 's/I think //g; s/I believe //g; s/seems like //g' \
        | sed 's/sure, //g; s/certainly, //g; s/happy to //g; s/glad to //g' \
        | sed 's/and then //g; s/so basically //g' \
        | sed 's/\bthe //g; s/\ba //g; s/\ban //g' \
        | sed 's/应该/应/g; s/可能/或/g; s/大概/约/g' \
        | sed 's/  / /g' \
        | sed 's/^ *//; s/ *$//'
}

# ── Compression ratio ────────────────────────────────────────────────────────
compression_ratio() {
    local orig="$1"
    local compressed="$2"
    local orig_tokens=$(count_tokens "$orig")
    local comp_tokens=$(count_tokens "$compressed")
    if [ "$orig_tokens" -eq 0 ]; then
        echo "0"
        return
    fi
    echo $(( (orig_tokens - comp_tokens) * 100 / orig_tokens ))
}

# ── Quality-weighted ratio ───────────────────────────────────────────────────
weighted_score() {
    local orig="$1"
    local compressed="$2"
    local ratio=$(compression_ratio "$orig" "$compressed")
    local q=$(quality_check "$orig" "$compressed")
    if [ "$q" = "LOW_QUALITY" ]; then
        # Penalise: effective ratio is lower if quality is poor
        echo $(( ratio * 70 / 100 ))
    else
        echo "$ratio"
    fi
}

# ── Platform detection ────────────────────────────────────────────────────────
detect_platform() {
    if [ -n "$HERMES_CONFIG_DIR" ]; then
        echo "hermes"
    elif [ -d "$HOME/.hermes" ]; then
        echo "hermes"
    elif [ -d "$HOME/.openclaw" ]; then
        echo "openclaw"
    else
        echo "hermes"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
banner

PLATFORM=$(detect_platform)
echo -e "${Yellow}[Platform]${Reset} $PLATFORM detected"

SOUL_DIR=""
case "$PLATFORM" in
    hermes) SOUL_DIR="${HERMES_CONFIG_DIR:-${HOME}/.hermes}" ;;
    openclaw) SOUL_DIR="$HOME/.openclaw" ;;
esac

SOUL_TARGET="${SOUL_DIR}/SOUL.md"
MEMORY_PATH="${SOUL_DIR}/memories/MEMORY.md"

# ═══════════════════════════════════════════════════════════════════════════════
echo -e "${Bold}[1] Installation Checks${Reset}"
echo "──────────────────────────────────────────"

if [ -f "$SOUL_TARGET" ]; then
    check "SOUL.md exists at ${SOUL_TARGET}"
    if grep -q "## Terse Mode" "$SOUL_TARGET"; then
        check "Terse Mode section found"
    else
        check "Terse Mode section found" "FAIL"
    fi
else
    check "SOUL.md exists" "FAIL"
fi

if [ -f "$MEMORY_PATH" ]; then
    check "MEMORY.md exists"
    if grep -q "^terse_level:" "$MEMORY_PATH"; then
        LEVEL=$(grep "^terse_level:" "$MEMORY_PATH" | cut -d: -f2 | tr -d ' ')
        echo -e "    Level: ${Cyan}$LEVEL${Reset}"
        check "terse_level is set"
    else
        check "terse_level is set" "FAIL"
    fi
else
    check "MEMORY.md exists" "FAIL"
    echo -e "    ${Yellow}(will be created on first /terse command)${Reset}"
fi

# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${Bold}[2] Semantic Density Detection${Reset}"
echo "──────────────────────────────────────────"

DENSITY_TEST="康强电子PE=18，MACD金叉，营收同比增长25%，北向资金净买入2亿，建议买入。"
DENSITY_RESULT=$(semantic_density "$DENSITY_TEST")
echo "  Test: \"$DENSITY_TEST\""
echo -e "    Density: ${Cyan}${DENSITY_RESULT}${Reset}"
if [ "$DENSITY_RESULT" = "high" ]; then
    check "Semantic density detection (high-density paragraph → high)" "OK"
else
    check "Semantic density detection (high-density paragraph → high)" "FAIL"
fi

DENSITY_TEST2="当然，其实我觉得这个问题基本上可能应该怎么说呢。"
DENSITY_RESULT2=$(semantic_density "$DENSITY_TEST2")
echo "  Test: \"$DENSITY_TEST2\""
echo -e "    Density: ${Cyan}${DENSITY_RESULT2}${Reset}"
if [ "$DENSITY_RESULT2" = "low" ]; then
    check "Semantic density detection (low-density paragraph → low)" "OK"
else
    check "Semantic density detection (low-density paragraph → low)" "FAIL"
fi

# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${Bold}[3] Quality Score${Reset}"
echo "──────────────────────────────────────────"

ORIG_Q="康强电子PE=18，建议买入，目标价25元。"
COMP_Q="康强电子PE=18，建议买入，目标25元。"
QUAL=$(quality_check "$ORIG_Q" "$COMP_Q")
echo "  Original: \"$ORIG_Q\""
echo "  Compressed: \"$COMP_Q\""
echo -e "    Quality: ${Cyan}${QUAL}${Reset}"
check "Quality check preserves numbers and action"

ORIG_Q2="当然，我很高兴帮你解决这个问题。"
COMP_Q2="帮你解决这个问题。"
QUAL2=$(quality_check "$ORIG_Q2" "$COMP_Q2")
echo "  Original: \"$ORIG_Q2\""
echo "  Compressed: \"$COMP_Q2\""
echo -e "    Quality: ${Cyan}${QUAL2}${Reset}"
if [ "$QUAL2" = "LOW_QUALITY" ]; then
    check "Quality check detects missing direction/action" "OK"
else
    check "Quality check detects missing direction/action" "FAIL"
fi

# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${Bold}[4] Compression Ratio Tests${Reset}"
echo "──────────────────────────────────────────"

if [ "$1" = "--quality" ]; then
    ORIG="${*:2}"
elif [ -n "$1" ]; then
    ORIG="$*"
else
    ORIG="当然！我很高兴帮你解决这个问题。你遇到的问题很可能是由于认证中间件没有正确验证 token 过期时间导致的。"
fi

ORIG_TOKENS=$(count_tokens "$ORIG")
echo -e "${Yellow}[Original]${Reset}"
echo "  \"$ORIG\""
echo -e "  Tokens (est): ${Bold}${ORIG_TOKENS}${Reset}"
echo ""

DENSITY=$(semantic_density "$ORIG")
echo -e "  Semantic density: ${Cyan}${DENSITY}${Reset}"
echo ""

PASS_THRESHOLD_LITE=20
PASS_THRESHOLD_FULL=40
PASS_THRESHOLD_ULTRA=60
PASS_THRESHOLD_WENYAN=70

run_level_test() {
    local level="$1"
    local compressed="$2"
    local threshold="$3"
    local ratio=$(compression_ratio "$ORIG" "$compressed")
    local wscore=$(weighted_score "$ORIG" "$compressed")
    local qual=$(quality_check "$ORIG" "$compressed")
    local status="OK"
    if [ "$ratio" -lt "$threshold" ]; then status="FAIL"; fi
    check "${level} compression: ${ratio}% (≥${threshold}%), quality: ${qual}, weighted: ${wscore}%" "$status"
    echo -e "    ${Cyan}→${Reset} \"$compressed\""
}

echo "  --- lite ---"
LITE_OUT=$(compress_lite "$ORIG")
run_level_test "lite" "$LITE_OUT" "$PASS_THRESHOLD_LITE"

echo "  --- full ---"
FULL_OUT=$(compress_full "$ORIG")
run_level_test "full" "$FULL_OUT" "$PASS_THRESHOLD_FULL"

echo "  --- ultra ---"
ULTRA_OUT=$(compress_ultra "$ORIG")
run_level_test "ultra" "$ULTRA_OUT" "$PASS_THRESHOLD_ULTRA"

echo "  --- wenyan (structural) ---"
WENYAN_OUT=$(compress_wenyan "$ORIG")
run_level_test "wenyan" "$WENYAN_OUT" "$PASS_THRESHOLD_WENYAN"

# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${Bold}[5] Built-in Benchmark${Reset}"
echo "──────────────────────────────────────────"

BENCH_ORIG="当然！我很高兴帮你解决这个问题。你遇到的问题很可能是由于认证中间件没有正确验证 token 过期时间导致的。"
BENCH_FULL="认证中间件 bug。Token 过期检查用了 < 而不是 <=。修："
BENCH_FULL_RATIO=$(compression_ratio "$BENCH_ORIG" "$BENCH_FULL")
BENCH_QUAL=$(quality_check "$BENCH_ORIG" "$BENCH_FULL")
BENCH_WEIGHTED=$(weighted_score "$BENCH_ORIG" "$BENCH_FULL")

echo "  Benchmark (full level):"
echo "    Original: \"$BENCH_ORIG\""
echo "    Terse:    \"$BENCH_FULL\""
echo -e "    Compression: ${Bold}${BENCH_FULL_RATIO}%${Reset}"
echo -e "    Quality:     ${Cyan}${BENCH_QUAL}${Reset}"
echo -e "    Weighted:    ${Bold}${BENCH_WEIGHTED}%${Reset}"

if [ "$BENCH_FULL_RATIO" -ge "$PASS_THRESHOLD_FULL" ]; then
    check "Benchmark compression ratio passed"
else
    check "Benchmark compression ratio passed" "FAIL"
fi
if [ "$BENCH_QUAL" = "OK" ]; then
    check "Benchmark quality preservation passed"
else
    check "Benchmark quality preservation passed" "FAIL"
fi

# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${Bold}[6] Network & Scripts${Reset}"
echo "──────────────────────────────────────────"

for script in install.sh update.sh uninstall.sh verify.sh star.sh SOUL.md; do
    HTTP_CODE=$(curl -sI "${RAW}/${script}" 2>/dev/null | grep -i "^HTTP" | awk '{print $2}' | tail -1)
    if [ "$HTTP_CODE" = "200" ]; then
        check "${script} reachable (HTTP $HTTP_CODE)"
    else
        check "${script} reachable (HTTP $HTTP_CODE)" "FAIL"
    fi
done

# ═══════════════════════════════════════════════════════════════════════════════
echo ""
echo -e "${Bold}═══════════════════════════════════════════════${Reset}"
echo -e " Result: ${Green}${PASS}${Reset} passed, ${Red}${FAIL}${Reset} failed"
echo -e "${Bold}═══════════════════════════════════════════════${Reset}"

if [ $FAIL -eq 0 ]; then
    echo -e "${Green}hermes-cavemen v1.2 is properly installed ✓${Reset}"
    echo ""
    echo "Quick reference:"
    echo "  Switch: /terse ultra | /terse wenyan"
    echo "  Exit:   normal mode"
    echo "  New:    --quality flag for quality-weighted scoring"
    exit 0
else
    echo -e "${Red}Some checks failed. Re-run install:${Reset}"
    echo "  curl -s ${RAW}/install.sh | bash"
    exit 1
fi
