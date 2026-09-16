@echo off
REM Validacion M13 Herramientas (check-only)
cd /d "%~dp0game\isla-ancestral"
"D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --headless --check-only --quit --verbose > "D:\tmp_m13_out.txt" 2>&1
echo === ERRORES/LOADS RELEVANTES ===
findstr /C:"Parse Error" /C:"SCRIPT ERROR" /C:"tool_" /C:"preview_herramientas" /C:"recurso_mock" /C:"Completed load" /C:"Failed" "D:\tmp_m13_out.txt"
echo === FIN ===
