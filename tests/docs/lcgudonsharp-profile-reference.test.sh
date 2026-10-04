#!/bin/bash
set -euo pipefail

REPO_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
SKILL="$REPO_ROOT/skills/unity-vrc-udon-sharp/SKILL.md"
REFERENCE="$REPO_ROOT/skills/unity-vrc-udon-sharp/references/lcgudonsharp.md"
POWERSHELL_HOOK="$REPO_ROOT/skills/unity-vrc-udon-sharp/hooks/validate-udonsharp.ps1"
BASH_HOOK="$REPO_ROOT/skills/unity-vrc-udon-sharp/hooks/validate-udonsharp.sh"

fail() {
    printf 'FAIL: %s\n' "$1" >&2
    exit 1
}

require_text() {
    local file="$1"
    local text="$2"
    grep -Fq -- "$text" "$file" || fail "$file missing: $text"
}

for file in "$SKILL" "$REFERENCE" "$POWERSHELL_HOOK" "$BASH_HOOK"; do
    require_text "$file" 'com.logiccuteguy.lcgudonsharp'
done

for text in 'Interfaces' 'async' 'Exceptions' 'LINQ closures' 'Generics' 'dynamic' 'Span<T>' '[LCGPacket]' 'LCGNetworkZone'; do
    require_text "$REFERENCE" "$text"
done

require_text "$REFERENCE" 'exact compiler-lowered `List<T>`'
require_text "$REFERENCE" 'VRChat Worlds SDK `3.10.5`'
require_text "$REFERENCE" 'LCGUdonSharp'
require_text "$REFERENCE" '`0.3.7`'
require_text "$REFERENCE" 'Dictionary<TKey,TValue>'
require_text "$REFERENCE" 'System.Text.Json'
require_text "$REFERENCE" '[UdonSynced, NonSerialized]'
require_text "$REFERENCE" 'UDONSHARP_COMPILER_PROFILE=lcg'
for text in 'Custom ScriptableObject data (0.3.7)' 'fresh shallow defensive copy' 'paired program asset' 'polymorphic references' 'edits during play do not update' '[UdonSynced]' 'ScriptableObjectShopExample.prefab'; do
    require_text "$REFERENCE" "$text"
done

for readme in README.md README.ja.md README.ko.md README.th.md README.zh-CN.md README.zh-TW.md; do
    require_text "$REPO_ROOT/$readme" 'LCGUdonSharp-0.3.7'
    require_text "$REPO_ROOT/$readme" 'ScriptableObject'
    require_text "$REPO_ROOT/$readme" '/blob/0.3.7/Example/ScriptableObjects/README.md'
done
for readme in .claude/audit/README.md unity-project-for-sdk-search/README.md; do
    require_text "$REPO_ROOT/$readme" '**4.2.4**'
    require_text "$REPO_ROOT/$readme" '**0.3.7**'
done

require_text "$SKILL" 'Choose the Compiler Profile First'
require_text "$SKILL" '`lcgudonsharp.md`'

printf 'PASS: LCGUdonSharp compiler-profile documentation contract\n'
