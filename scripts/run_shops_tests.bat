@echo off
REM Helper temporal (glm-5.3-flash, 2026-09-17): corre las 3 suites de M39 headless
REM y vuelca la salida a Logs\_t39_*.txt para leerlas con read_files.
set GODOT=D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe
set PROJ=game\isla-ancestral
setlocal enabledelayedexpansion
for %%T in (test_tiendas test_loop_economico test_tiendas_iter_glm) do (
  "%GODOT%" --headless --path "%PROJ%" --script "res://scripts/shops/%%T.gd" > "Logs\_t39_%%T.txt" 2>&1
  echo %%T EXIT=!ERRORLEVEL!
)