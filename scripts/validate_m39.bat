@echo off
rem Validacion M39 Tiendas - capa de datos
cd /d "%~dp0"
"D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --headless --path "game\isla-ancestral" --check-only --script res://scripts/shops/shop_data.gd
"D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --headless --path "game\isla-ancestral" --check-only --script res://scripts/shops/shop.gd
"D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --headless --path "game\isla-ancestral" --check-only --script res://scripts/shops/stock_generator.gd
"D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --headless --path "game\isla-ancestral" --check-only --script res://scripts/shops/reputacion_tienda.gd
"D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe" --headless --path "game\isla-ancestral" --check-only --script res://scripts/shops/shop_manager.gd
echo === CHECK M39 COMPLETO ===
