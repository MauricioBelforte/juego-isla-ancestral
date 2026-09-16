@echo off
cd /d "D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\game\isla-ancestral"
"D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --headless --path "." --quit-after 8 --no-window 1>D:\tmp_v2.log 2>&1
echo EXIT=%ERRORLEVEL%