param (
    [Parameter(Mandatory=$true)]
    [string]$FilePath
)

$RuntimeDir = Join-Path $PSScriptRoot ""
$PiperExe = Join-Path $RuntimeDir "piper_bin\piper\piper.exe"
$ModelPath = Join-Path $RuntimeDir "fr_FR-siwis-low.onnx"
$OutputPath = Join-Path $RuntimeDir "vocal_ia_last.wav"
$TempTxtPath = Join-Path $RuntimeDir "vocal_ia_last.txt"

if (!(Test-Path $PiperExe)) {
    Write-Error "Moteur Piper introuvable."
    exit
}

# Forçage de l'encodage
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8

# Lecture en UTF8
$rawContent = Get-Content $FilePath -Encoding utf8

$processedLines = New-Object System.Collections.Generic.List[string]

foreach ($line in $rawContent) {
    $l = $line.Trim()
    if (-not $l) {
        $processedLines.Add(" . ")
        continue
    }

    $isHeader = $l -match '^#+\s+'
    
    # --- TRAITEMENT SPÉCIFIQUE PONCTUATION ---
    $l = $l -replace '\*\*', ' . '
    $l = $l -replace '\(', ' , '
    $l = $l -replace '\)', ' , '

    # --- TRAITEMENT CAMEL CASE (CASE-SENSITIVE) ---
    $l = $l -creplace '([a-z])([A-Z])', '$1 $2'
    $l = $l -creplace '([A-Z])([A-Z][a-z])', '$1 $2'

    # Nettoyage Markdown classique
    $l = $l -replace '(?s)```.*?```', ' '
    $l = $l -replace '\[([^\]]+)\]\([^\)]+\)', '$1'
    $l = $l -replace '!\[[^\]]+\]\([^\)]+\)', ' '
    $l = $l -replace '\*|__|(?<!\w)_|_(?!\w)', '' 
    $l = $l -replace '^#+\s*', ''
    $l = $l -replace '^[\s]*[\*\-\+\d\.]+\s+', ''
    $l = $l -replace '^[\-\*_]{3,}\s*$', ''
    $l = $l -replace '[`\|]', ' '

    # --- NETTOYAGE DES ÉMOJIS ET SYMBOLES ---
    $l = $l -replace '[\uD83C-\uDBFF\uDC00-\uDFFF]+', ''
    $l = $l -replace '[\u2600-\u27BF\u2300-\u23FF\u2100-\u214F\u25A0-\u25FF]', ''

    if ($isHeader -and $l -notmatch '[\.\!\?:]$') { $l += " ." }
    elseif ($l -and $l -notmatch '[\.\!\?:\,]$') { $l += " ," }

    $processedLines.Add($l)
}

$content = $processedLines -join " "

# --- DICTIONNAIRE PHONÉTIQUE ET ÉPELAGE ---
$PhoneticMap = @{
    "(?i)\bManager\b" = "Manadjure";
    "(?i)\bBundle\b" = "Beune-deul";
    "(?i)\bChunk\b" = "Tcheunk";
    "(?i)\bShader\b" = "Chadeurre";
    "(?i)\bSB_Heightmap\b" = "S.B. Haït-mappe";
    # Épelage des extensions et acronymes
    "\.res\b" = " point R E S ";
    "\.tscn\b" = " point T S C N ";
    "\.gd\b" = " point G D ";
    "\bGPU\b" = " G P U ";
    "\bCPU\b" = " C P U ";
    "\bRAM\b" = " R A M ";
    "\bUI\b" = " U I ";
}

foreach ($term in $PhoneticMap.Keys) {
    $content = $content -replace $term, $PhoneticMap[$term]
}

# --- RÉDUC RÉCURSIVE DE LA PONCTUATION ---
do {
    $oldLen = $content.Length
    $content = $content -replace '\s*,\s*,', ' ,'
    $content = $content -replace '\s*\.\s*\.', ' .'
    $content = $content -replace '\s*,\s*\.', ' .'
    $content = $content -replace '\s*\.\s*:', ' .'
    $content = $content -replace '\s*\.\s*,', ' .'
    $content = $content -replace '\s*,\s*:', ' :'
} while ($content.Length -ne $oldLen)

$content = $content -replace '\s+', ' '

# Écriture UTF8 sans BOM (on garde le fichier pour replay)
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($TempTxtPath, $content, $Utf8NoBom)

Write-Host "--- Génération de la voix IA (Neural Piper) ---" -ForegroundColor Cyan

$cmdArgs = "/c type ""$TempTxtPath"" | ""$PiperExe"" --model ""$ModelPath"" --output_file ""$OutputPath"""
Start-Process "cmd.exe" -ArgumentList $cmdArgs -NoNewWindow -Wait

if (Test-Path $OutputPath) {
    Write-Host "Lecture audio en cours..." -ForegroundColor Green
    $player = New-Object System.Media.SoundPlayer
    $player.SoundLocation = $OutputPath
    $player.PlaySync()
    # On ne supprime plus les fichiers pour permettre le replay
} else {
    Write-Error "Erreur lors de la génération."
}
