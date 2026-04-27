# Script de push automatisé pour StoneBlock
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$MsgFile = Join-Path $ScriptDir "git-push.txt"

if (Test-Path $MsgFile) {
    $Message = Get-Content $MsgFile -Raw
    $Message = $Message.Trim()
    
    Write-Host "--- Début du Push ---"
    git add .
    git commit -m "$Message"
    git push
    Write-Host "--- Fin du Push ---"
} else {
    Write-Error "Fichier git-push.txt non trouvé dans $ScriptDir"
}
