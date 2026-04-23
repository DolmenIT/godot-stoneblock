@echo off
if "%~1"=="" (
    echo [ERREUR] Veuillez glisser une video sur ce script.
    pause
    exit /b
)

set FFMPEG="C:\Users\dolme\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.1-full_build\bin\ffmpeg.exe"

echo [SB_Toolbox] Inversion de : %~n1%~x1
%FFMPEG% -i "%~1" -vf reverse -af areverse "%~dpn1_reversed%~x1"
echo.
echo [TERMINE] Fichier cree : %~n1_reversed%~x1
pause
