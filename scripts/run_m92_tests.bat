@echo off
REM Helper temporal (glm-5.3-flash, 2026-09-15): corre las 3 suites de M92 headless
REM y vuelca la salida a Logs\_m92_*.txt para leerlas con read_files.
set GODOT=D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe
set PROJ=game\isla-ancestral
for %%T in (test_tutorial test_tutorial_triggers test_tutorial_iter3) do (
  "%GODOT%" --headless --path "%PROJ%" --script "res://scripts/tutorial/%%T.gd" > "Logs\_m92_%%T.txt" 2>&1
  echo %%T EXIT=%ERRORLEVEL%
)