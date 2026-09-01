# Log 227: M24 Templos y Puzzles — nucleo del framework emisor-receptor

**Fecha:** 2026-08-29
**Hora:** 02:20
**Modelo:** Hy3
**Plataforma:** Kilo

## Resumen
Se reservo M24 (F4, dificultad 5, V2) y se implemento el nucleo del framework de puzzles emisor-receptor de la decision central del 03-Diseno, con la validacion de no-arbitrariedad que exige la puerta F4. Verificado con test headless (0 fallos) y arranque del juego sin errores. Se libera como 🟡 (nucleo) — puzzles jugables, familias y sistema de ayuda quedan con dueno.

## Implementacion
- `scripts/templos/puzzle_room.gd` (PuzzleRoom, RefCounted): vector de estado S, reglas emisor->receptor, objetivo T, recalcular/progreso/completada, y `validar()` que rechaza reglas vacias, emisores inexistentes y salas sin reglas (no-arbitrariedad).
- `scripts/templos/puzzle_emisor.gd` (PuzzleEmisor, Node3D): emisor golpeado por el jugador o activado por peso -> actualiza el estado de la sala.
- `scripts/templos/puzzle_puerta.gd` (PuzzlePuerta, Node3D): receptor que al cumplirse su regla abre el sello (remueve voxels via VoxelTool, una escritura de diff).
- `scripts/templos/test_puzzles.gd`: suite que valida transiciones, completado y no-arbitrariedad. **Resultado: 0 fallos.**

## Verificacion
- Test headless 0 fallos; arranque completo vía godot-mcp (V4) sin errores de script (los warnings son preexistentes de event_bus/otros modulos).

## Pendiente (honestidad, con dueno)
- Puzzles jugables en escena (layout + arte M45), familias (luz/espejos/agua/hielo/bloques/gravedad/movimiento/sonido/secuencia/simbolos/ambientales/herramientas/multilateral), sistema de ayuda Guia del Templo, bandas de dificultad.

## Archivos
- 4 scripts nuevos en `game/isla-ancestral/scripts/templos/` (+ .uid)
- Checklist/CHECKLIST-GLOBAL/ESTADO-PARALELO/guia 08 actualizados; `Logs/ULTIMO_NUMERO.txt` -> 227