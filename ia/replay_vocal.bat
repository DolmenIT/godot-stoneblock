@echo off
set "SCRIPT_DIR=%~dp0"
set "WAV_FILE=%SCRIPT_DIR%ia_runtime\vocal_ia_last.wav"

if exist "%WAV_FILE%" (
    echo [VOIX IA] Relecture du dernier extrait...
    powershell -Command "(New-Object System.Media.SoundPlayer '%WAV_FILE%').PlaySync()"
) else (
    echo [ERREUR] Aucun fichier audio trouve. Lancez vocal_ia.ps1 d'abord.
    pause
)
