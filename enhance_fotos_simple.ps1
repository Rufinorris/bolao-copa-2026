# Script simples para enriquecer o JSON

$InputFile = "C:\Users\Notebook\Documents\projects\bolao-copa-2026\fotos_wikipedia.json"
$OutputFile = "C:\Users\Notebook\Documents\projects\bolao-copa-2026\fotos_wikipedia.json"

$resultado = Get-Content $InputFile | ConvertFrom-Json
$comFoto = $resultado.PSObject.Properties.Count

Write-Host "Fotos atuais: $comFoto"
Write-Host "Tentando encontrar mais..."
Write-Host ""

# Jogadores mais famosos que provavelmente têm foto
$famosos = @(
    'Neymar','Messi','Ronaldo','Haaland','Mbappe','Kane','Lewandowski',
    'De Bruyne','Modric','Busquets','Leweling','Van Dijk','Silva'
)

$reqs = 0
$batchTime = Get-Date

foreach ($nome in $famosos) {
    $reqs++
    if ($reqs -ge 10) {
        $elapsed = ((Get-Date) - $batchTime).TotalMilliseconds
        if ($elapsed -lt 2000) {
            Start-Sleep -Milliseconds ([int](2000 - $elapsed))
        }
        $reqs = 0
        $batchTime = Get-Date
    }

    if ($nome -in $resultado.PSObject.Properties.Name) {
        continue
    }

    try {
        $url = "https://en.wikipedia.org/api/rest_v1/page/summary/$([System.Uri]::EscapeDataString($nome))"
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 2 -ErrorAction Stop
        $data = $resp.Content | ConvertFrom-Json

        if ($data.thumbnail -and $data.thumbnail.source) {
            $resultado | Add-Member -NotePropertyName $nome -NotePropertyValue $data.thumbnail.source -Force
            Write-Host "Encontrado: $nome"
        }
    }
    catch {
        Write-Host "Nao encontrado: $nome"
    }
}

$json = $resultado | ConvertTo-Json -Depth 10
Set-Content -Path $OutputFile -Value $json -Encoding UTF8

$total = $resultado.PSObject.Properties.Count
Write-Host ""
Write-Host "Fotos agora: $total"
