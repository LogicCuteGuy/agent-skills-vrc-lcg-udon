#!/bin/bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
HOOK="$REPO_ROOT/skills/unity-vrc-udon-sharp/hooks/validate-udonsharp.sh"
FIXTURES="$REPO_ROOT/tests/hooks/fixtures/validate-udonsharp"
TMPROOT=$(mktemp -d)
trap 'rm -rf "$TMPROOT"' EXIT

PASS=0
FAIL=0

invoke_validator() {
    local file_path="$1"
    local profile="$2"
    local output_path="$3"
    local payload
    local stdout_path="${output_path}.stdout"
    payload=$(jq -cn --arg path "$file_path" '{tool_input:{file_path:$path}}')

    if [[ "$profile" == "auto" ]]; then
        (unset UDONSHARP_COMPILER_PROFILE; printf '%s' "$payload" | "$HOOK") >"$stdout_path" 2>"$output_path"
    else
        printf '%s' "$payload" | env UDONSHARP_COMPILER_PROFILE="$profile" "$HOOK" >"$stdout_path" 2>"$output_path"
    fi

    if [[ "$(cat "$stdout_path")" != "$payload" ]]; then
        fail "validator passthrough ($profile)" 'stdout changed the hook payload'
    fi
}

pass() {
    printf 'PASS [%s]\n' "$1"
    PASS=$((PASS + 1))
}

fail() {
    printf 'FAIL [%s] %s\n' "$1" "$2"
    FAIL=$((FAIL + 1))
}

assert_contains() {
    local label="$1"
    local file="$2"
    local expected="$3"
    if grep -Fq -- "$expected" "$file"; then pass "$label"; else fail "$label" "missing: $expected"; fi
}

assert_not_contains() {
    local label="$1"
    local file="$2"
    local unexpected="$3"
    if grep -Fq -- "$unexpected" "$file"; then fail "$label" "unexpected: $unexpected"; else pass "$label"; fi
}

SUPPORTED="$FIXTURES/runtime-lcg-supported.cs"
UNSUPPORTED="$FIXTURES/runtime-lcg-unsupported-linq.cs"
LIST_FIXTURE="$FIXTURES/runtime-lcg-list.cs"
STOCK_BLOCKERS=(
    'async/await not supported'
    'try/catch/finally not supported'
    'LINQ not supported'
    'Interfaces not supported'
    'Lambda expression detected'
)

invoke_validator "$SUPPORTED" stock "$TMPROOT/stock.err"
for blocker in "${STOCK_BLOCKERS[@]}"; do
    assert_contains "stock keeps $blocker" "$TMPROOT/stock.err" "$blocker"
done

invoke_validator "$SUPPORTED" lcg "$TMPROOT/lcg.err"
for blocker in "${STOCK_BLOCKERS[@]}"; do
    assert_not_contains "lcg removes $blocker" "$TMPROOT/lcg.err" "$blocker"
done
assert_not_contains 'lcg supported subset has no LCG diagnostic' "$TMPROOT/lcg.err" '[LCGUdonSharp]'

invoke_validator "$UNSUPPORTED" lcg "$TMPROOT/unsupported.err"
assert_contains 'lcg rejects unsupported LINQ operator' "$TMPROOT/unsupported.err" '[LCGUdonSharp] BLOCKED: LINQ lowering supports Where(), Select(), and ToArray()'
assert_contains 'lcg flags non-Where/Select lambda' "$TMPROOT/unsupported.err" '[LCGUdonSharp] WARNING: General delegate lambdas are not supported'

invoke_validator "$LIST_FIXTURE" lcg "$TMPROOT/list.err"
assert_contains 'lcg keeps List<T> restriction' "$TMPROOT/list.err" 'Generic collections (List<T>'

PROJECT_ROOT="$TMPROOT/UnityProject"
mkdir -p "$PROJECT_ROOT/Assets" "$PROJECT_ROOT/Packages"
cp "$SUPPORTED" "$PROJECT_ROOT/Assets/RuntimeLCGSupported.cs"
printf '%s' '{"dependencies":{"com.logiccuteguy.lcgudonsharp":"file:../LCGUdonSharp"}}' > "$PROJECT_ROOT/Packages/manifest.json"

invoke_validator "$PROJECT_ROOT/Assets/RuntimeLCGSupported.cs" auto "$TMPROOT/manifest.err"
for blocker in "${STOCK_BLOCKERS[@]}"; do
    assert_not_contains "manifest auto-detection removes $blocker" "$TMPROOT/manifest.err" "$blocker"
done

invoke_validator "$PROJECT_ROOT/Assets/RuntimeLCGSupported.cs" stock "$TMPROOT/forced-stock.err"
assert_contains 'stock override wins over manifest' "$TMPROOT/forced-stock.err" 'async/await not supported'

invoke_validator "$PROJECT_ROOT/Assets/RuntimeLCGSupported.cs" unexpected-value "$TMPROOT/unknown.err"
assert_not_contains 'unknown override returns to manifest auto-detection' "$TMPROOT/unknown.err" 'async/await not supported'

mv "$PROJECT_ROOT/Packages/manifest.json" "$PROJECT_ROOT/Packages/vpm-manifest.json"
invoke_validator "$PROJECT_ROOT/Assets/RuntimeLCGSupported.cs" auto "$TMPROOT/vpm-manifest.err"
assert_not_contains 'VPM manifest auto-detection removes stock async blocker' "$TMPROOT/vpm-manifest.err" 'async/await not supported'

mkdir -p "$PROJECT_ROOT/Packages/com.logiccuteguy.lcgudonsharp/Example"
cp "$SUPPORTED" "$PROJECT_ROOT/Packages/com.logiccuteguy.lcgudonsharp/Example/RuntimeLCGSupported.cs"
rm "$PROJECT_ROOT/Packages/vpm-manifest.json"
invoke_validator "$PROJECT_ROOT/Packages/com.logiccuteguy.lcgudonsharp/Example/RuntimeLCGSupported.cs" auto "$TMPROOT/package-path.err"
assert_not_contains 'package path auto-detection removes stock async blocker' "$TMPROOT/package-path.err" 'async/await not supported'

printf 'RESULT: %s passed, %s failed\n' "$PASS" "$FAIL"
if [[ "$FAIL" -gt 0 ]]; then exit 1; fi
