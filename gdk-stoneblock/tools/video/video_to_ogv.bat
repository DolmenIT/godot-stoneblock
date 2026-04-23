@echo off
if "%~1"=="" (
    echo [ERREUR] Veuillez glisser une video sur ce script.
    pause
    exit /b
)

set FFMPEG="C:\Users\dolme\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-8.1-full_build\bin\ffmpeg.exe"

echo [SB_Toolbox] Conversion OGV "INCASSABLE" (GOP 1) de : %~n1%~x1
%FFMPEG% -i "%~1" -c:v libtheora -q:v 7 -g 1 -c:a libvorbis -q:a 5 "%~dpn1_safe.ogv"
echo.
echo [TERMINE] Fichier cree : %~n1_safe.ogv
pause
