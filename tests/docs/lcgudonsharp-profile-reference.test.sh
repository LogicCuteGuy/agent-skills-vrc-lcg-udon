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

require_text "$REFERENCE" 'List<T>` remain rejected'
require_text "$REFERENCE" 'VRChat Worlds SDK `3.10.5`'
require_text "$REFERENCE" 'UDONSHARP_COMPILER_PROFILE=lcg'
require_text "$SKILL" 'Choose the Compiler Profile First'
require_text "$SKILL" '`lcgudonsharp.md`'

printf 'PASS: LCGUdonSharp compiler-profile documentation contract\n'
