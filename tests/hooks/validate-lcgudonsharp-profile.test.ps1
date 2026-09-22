#Requires -Version 5.1

$ErrorActionPreference = 'Stop'

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$Hook = Join-Path $RepoRoot 'skills/unity-vrc-udon-sharp/hooks/validate-udonsharp.ps1'
$Fixtures = Join-Path $RepoRoot 'tests/hooks/fixtures/validate-udonsharp'
$TempRoot = Join-Path ([System.IO.Path]::GetTempPath()) ('validate-lcgudonsharp-' + [guid]::NewGuid())
$Passed = 0
$Failed = 0

New-Item -ItemType Directory -Path $TempRoot | Out-Null

function Invoke-Validator([string]$FilePath, [string]$Profile) {
    $Payload = @{ tool_input = @{ file_path = $FilePath } } | ConvertTo-Json -Compress
    $StartInfo = New-Object System.Diagnostics.ProcessStartInfo
    $StartInfo.FileName = (Get-Process -Id $PID).Path
    $StartInfo.Arguments = '-NoLogo -NoProfile -File "' + $Hook + '"'
    $StartInfo.UseShellExecute = $false
    $StartInfo.CreateNoWindow = $true
    $StartInfo.RedirectStandardInput = $true
    $StartInfo.RedirectStandardOutput = $true
    $StartInfo.RedirectStandardError = $true
    [void]$StartInfo.EnvironmentVariables.Remove('UDONSHARP_COMPILER_PROFILE')
    if ($Profile -ne 'auto') {
        $StartInfo.EnvironmentVariables['UDONSHARP_COMPILER_PROFILE'] = $Profile
    }

    $Process = New-Object System.Diagnostics.Process
    $Process.StartInfo = $StartInfo
    [void]$Process.Start()
    $Process.StandardInput.Write($Payload)
    $Process.StandardInput.Close()
    $Stdout = $Process.StandardOutput.ReadToEnd()
    $Stderr = $Process.StandardError.ReadToEnd()
    $Process.WaitForExit()

    if ($Process.ExitCode -ne 0 -or $Stdout -cne $Payload) {
        throw "validator process contract failed (exit=$($Process.ExitCode))"
    }
    return $Stderr
}

function Pass([string]$Label) {
    Write-Output "PASS [$Label]"
    $script:Passed++
}

function Fail([string]$Label, [string]$Detail) {
    Write-Output "FAIL [$Label] $Detail"
    $script:Failed++
}

function Assert-Contains([string]$Label, [string]$Text, [string]$Expected) {
    if ($Text.Contains($Expected)) { Pass $Label } else { Fail $Label "missing: $Expected" }
}

function Assert-NotContains([string]$Label, [string]$Text, [string]$Unexpected) {
    if ($Text.Contains($Unexpected)) { Fail $Label "unexpected: $Unexpected" } else { Pass $Label }
}

try {
    $SupportedFixture = Join-Path $Fixtures 'runtime-lcg-supported.cs'
    $UnsupportedFixture = Join-Path $Fixtures 'runtime-lcg-unsupported-linq.cs'
    $ListFixture = Join-Path $Fixtures 'runtime-lcg-list.cs'
    $StockBlockers = @(
        'async/await not supported',
        'try/catch/finally not supported',
        'LINQ not supported',
        'Interfaces not supported',
        'Lambda expression detected'
    )

    $StockOutput = Invoke-Validator $SupportedFixture 'stock'
    foreach ($Blocker in $StockBlockers) {
        Assert-Contains "stock keeps $Blocker" $StockOutput $Blocker
    }

    $LCGOutput = Invoke-Validator $SupportedFixture 'lcg'
    foreach ($Blocker in $StockBlockers) {
        Assert-NotContains "lcg removes $Blocker" $LCGOutput $Blocker
    }
    Assert-NotContains 'lcg supported subset has no LCG diagnostic' $LCGOutput '[LCGUdonSharp]'

    $UnsupportedOutput = Invoke-Validator $UnsupportedFixture 'lcg'
    Assert-Contains 'lcg rejects unsupported LINQ operator' $UnsupportedOutput '[LCGUdonSharp] BLOCKED: LINQ lowering supports Where(), Select(), and ToArray()'
    Assert-Contains 'lcg flags non-Where/Select lambda' $UnsupportedOutput '[LCGUdonSharp] WARNING: General delegate lambdas are not supported'

    $ListOutput = Invoke-Validator $ListFixture 'lcg'
    Assert-NotContains 'lcg permits lowered List<T>' $ListOutput 'Generic collections (List<T>'

    $ProjectRoot = Join-Path $TempRoot 'UnityProject'
    $AssetsRoot = Join-Path $ProjectRoot 'Assets'
    $PackagesRoot = Join-Path $ProjectRoot 'Packages'
    New-Item -ItemType Directory -Path $AssetsRoot, $PackagesRoot | Out-Null
    $ProjectSource = Join-Path $AssetsRoot 'RuntimeLCGSupported.cs'
    Copy-Item -LiteralPath $SupportedFixture -Destination $ProjectSource
    [System.IO.File]::WriteAllText(
        (Join-Path $PackagesRoot 'manifest.json'),
        '{"dependencies":{"com.logiccuteguy.lcgudonsharp":"file:../LCGUdonSharp"}}',
        (New-Object System.Text.UTF8Encoding($false)))

    $ManifestOutput = Invoke-Validator $ProjectSource 'auto'
    foreach ($Blocker in $StockBlockers) {
        Assert-NotContains "manifest auto-detection removes $Blocker" $ManifestOutput $Blocker
    }

    $ForcedStockOutput = Invoke-Validator $ProjectSource 'stock'
    Assert-Contains 'stock override wins over manifest' $ForcedStockOutput 'async/await not supported'

    $UnknownOverrideOutput = Invoke-Validator $ProjectSource 'unexpected-value'
    Assert-NotContains 'unknown override returns to manifest auto-detection' $UnknownOverrideOutput 'async/await not supported'

    Move-Item -LiteralPath (Join-Path $PackagesRoot 'manifest.json') -Destination (Join-Path $PackagesRoot 'vpm-manifest.json')
    $VpmManifestOutput = Invoke-Validator $ProjectSource 'auto'
    Assert-NotContains 'VPM manifest auto-detection removes stock async blocker' $VpmManifestOutput 'async/await not supported'

    $PackageSourceRoot = Join-Path $PackagesRoot 'com.logiccuteguy.lcgudonsharp/Example'
    New-Item -ItemType Directory -Path $PackageSourceRoot | Out-Null
    $PackageSource = Join-Path $PackageSourceRoot 'RuntimeLCGSupported.cs'
    Copy-Item -LiteralPath $SupportedFixture -Destination $PackageSource
    Remove-Item -LiteralPath (Join-Path $PackagesRoot 'vpm-manifest.json')
    $PackagePathOutput = Invoke-Validator $PackageSource 'auto'
    Assert-NotContains 'package path auto-detection removes stock async blocker' $PackagePathOutput 'async/await not supported'
} finally {
    if (Test-Path -LiteralPath $TempRoot) {
        Remove-Item -LiteralPath $TempRoot -Recurse -Force
    }
}

Write-Output "RESULT: $Passed passed, $Failed failed"
if ($Failed -gt 0) { exit 1 }
