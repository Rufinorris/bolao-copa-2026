# redeploy.ps1 — carimba a versão e publica em produção.
# O carimbo novo faz os clientes (amigos) se auto-atualizarem em até ~1 min,
# sem precisar limpar cache. Use SEMPRE este script no lugar de "vercel deploy --prod".
$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$v = [DateTimeOffset]::Now.ToUnixTimeSeconds().ToString()
[System.IO.File]::WriteAllText("$root\version.json", '{"v":"' + $v + '"}', (New-Object System.Text.UTF8Encoding $false))
Write-Host "version.json => $v"
Set-Location $root
vercel deploy --prod
