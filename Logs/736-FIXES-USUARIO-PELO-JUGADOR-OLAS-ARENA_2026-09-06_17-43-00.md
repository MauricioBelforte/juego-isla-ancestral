# Log 736: Fixes de feedback del usuario — pelo del jugador + olas en la arena

**Fecha:** 2026-09-06
**Hora:** 17:43
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Corrección de 2 bugs reportados por el usuario tras revisar las iteraciones de hoy:
1. El pelo del jugador voxel "interfería con su cabeza" (engordaba la cara).
2. El efecto de olas aparecía raro sobre la arena de la orilla.
Además, ajuste fino pedido por el usuario: las olas deben llegar "un poco más cerca, hasta el agua clara".

## Cambios Realizados
### Fix 1 — Pelo (M45)
- Causa: `pelo_top` (6×6×1 en z 1.7-1.8) solapaba el rango de la cabeza (1.2-1.8) y `pelo_izq`/`pelo_der` (1×6×3 en z 1.5-1.8) envolvían media cara → z-fighting y cara "engordada".
- Solución (`crear_jugador_voxel.py`): gorro FINO 7×7×1 POR ENCIMA de la cabeza (z 1.8-1.9, sin solapar), nuca 7×1×2 pegada atrás (fuera del volumen), patillas 1×1×2 solo en la mitad trasera superior. Cara libre de pelo.
- GLB regenerado + reimport (pipeline de cache: borrar .scn + .import → --import). Verificado con render CYCLES y captura en juego.

### Fix 2 — Olas en la arena (M51)
- Causa: cresta de ola máxima (y_base 4.05 + amplitud 0.16 ≈ 4.21) superaba el top de la arena de orilla (y≈4.0) → parches de agua/espuma sobre arena seca.
- Solución (`agua_olas.gdshader`): máscara radial `costa` en el vertex shader — el plano se hunde (hundimiento_costa 1.2m) y las olas se atenúan cerca del borde de la isla; y_base bajada a 3.7 (cresta máx 3.86 < arena 4.0). Espuma ligada a `costa_mask` (varying).
- **Ajuste por feedback del usuario** ("que lleguen hasta el agua clara"): transición movida de r 240→300 a **r 255→285** — olas plenas hasta el agua clara, apagándose solo en la franja de arena (espuma ahora SOLO en la orilla, como borde de marea).

## Evidencia Visual
- `tools/mcp/blender-mcp/capturas/45-Arte-3D/render_jugador_voxel_v1.png` — gorro fino + nuca, cara limpia (antes: cara engordada).
- `tools/mcp/godot-mcp/capturas/45/cap_45_2026-09-06_17-39-42_pelo_v2_spawn_3persona.png` — jugador en juego con pelo corregido y orilla seca.
- `tools/mcp/godot-mcp/capturas/51/cap_51_2026-09-06_17-42-50_olas_hasta_agua_clara.png` — olas extendidas hasta el agua clara, arena seca, espuma como borde de marea.
- Comparativa ANTES: `capturas/45/cap_45_2026-09-06_15-25-34_jugador_voxel_en_juego.png` y `capturas/51/cap_51_2026-09-06_16-30-00_agua_costa_suroeste.png`.

## Tests
- Boot completo sin errores (log confirma `y=3.70` y `Jugador voxel M45 en uso`).
- No se tocó código de sistemas con tests (solo GLB + shader + constantes); sin regresiones posibles.

## Archivos Modificados/Creados
- `tools/mcp/blender-mcp/scripts-reutilizables/crear_jugador_voxel.py` (pelo v2)
- `game/isla-ancestral/assets/3d/media/45-Arte3D_jugador_voxel.glb` (regenerado)
- `game/isla-ancestral/shaders/agua_olas.gdshader` (máscara costa + espuma orilla + feedback agua clara)
- `game/isla-ancestral/scripts/world/agua_animada.gd` (Y_SUPERFICIE 4.05 → 3.7)
- `game/isla-ancestral/scenes/main_island.tscn` (AguaAnimada y 3.7)
- `DOCUMENTACION/45-Arte-3D/plan-actual/05-Checklist.md` + `DOCUMENTACION/51-Agua/plan-actual/05-Checklist.md` (notas fix)
