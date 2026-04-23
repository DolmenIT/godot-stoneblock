@echo off
if "%~1"=="" (
    echo [ERREUR] Veuillez glisser une video sur ce script.
    pause
    exit /b
)

set FFMPEG="C:\Users\dolme\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.1-full_build\bin\ffmpeg.exe"

echo [SB_Toolbox] Conversion WEBM (VP8 - Qualite Pro) de : %~n1%~x1
%FFMPEG% -i "%~1" -c:v libvpx -crf 10 -b:v 2M -c:a libvorbis -q:a 5 "%~dpn1.webm"
echo.
echo [TERMINE] Fichier cree : %~n1.webm
pause
