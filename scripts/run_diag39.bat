@echo off
REM Helper temporal (glm-5.3-flash, 2026-09-18): corre el diagnostico de ids M39 headless
REM y vuelca la salida a Logs\_diag39_run.txt para leerla con read_files.
set GODOT=D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe
set PROJ=game\isla-ancestral
"%GODOT%" --headless --path "%PROJ%" --script "res://scripts/shops/scripts-prueba/diag_ids_m39.gd" > "Logs\_diag39_run.txt" 2>&1
echo DIAG EXIT=%ERRORLEVEL%
