param(
    [switch]$Build,
    [switch]$Aggressive
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

# Ensure MSYS2 runtime DLLs are resolved first.
$env:Path = "C:\msys64\mingw64\bin;" + $env:Path

if ($Build -or -not (Test-Path ".\dpi_engine.exe")) {
    Write-Host "[Build] Building dpi_engine.exe with MSYS2 MinGW64..."
    & "C:\msys64\msys2_shell.cmd" -defterm -mingw64 -no-start -c "cd /c/Users/KIIT0001/Desktop/Packet_analyzer; g++ -std=c++17 -pthread -O2 -I include -o dpi_engine.exe src/dpi_mt.cpp src/pcap_reader.cpp src/packet_parser.cpp src/sni_extractor.cpp src/types.cpp"
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed with exit code $LASTEXITCODE"
    }
}

Write-Host "`n=== RUN 1: NO BLOCK ==="
& .\dpi_engine.exe test_dpi.pcap output_noblock.pcap
if ($LASTEXITCODE -ne 0) {
    throw "No-block run failed with exit code $LASTEXITCODE"
}

$blockArgs = @(
    "--block-app", "YouTube",
    "--block-domain", "facebook"
)

if ($Aggressive) {
    $blockArgs = @(
        "--block-app", "YouTube",
        "--block-app", "TikTok",
        "--block-app", "Facebook",
        "--block-app", "Twitter/X",
        "--block-domain", "facebook",
        "--block-domain", "twitter",
        "--block-domain", "netflix"
    )
}

Write-Host "`n=== RUN 2: WITH BLOCK ==="
& .\dpi_engine.exe test_dpi.pcap output_blocked.pcap @blockArgs
if ($LASTEXITCODE -ne 0) {
    throw "Blocked run failed with exit code $LASTEXITCODE"
}

Write-Host "`n=== OUTPUT FILES ==="
Get-Item .\output_noblock.pcap, .\output_blocked.pcap | Select-Object Name, Length, LastWriteTime
