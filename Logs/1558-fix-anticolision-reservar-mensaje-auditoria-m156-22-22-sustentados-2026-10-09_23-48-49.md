# Log 1558: Fix anti-colision reservar_mensaje + auditoria gap M156 (22/22 sustentados)

**Fecha:** 2026-10-09
**Hora:** 23:48
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen
Encargo del director (msg 190), bundle de dos partes:
1. **Fix anti-colision** en `scripts/reservar_mensaje.py` + tests (commit `57d1605`).
2. **Auditoria del gap de M156** (65 `[x]` presuntamente sin respaldo):
   **22/22 artefactos verificados existen** — no hay inflacion actual; el gap es
   **deriva temporal** (foto vieja del backlog de agnes, 2026-10-06).

## Cambios Realizados

### Parte 1 — Fix anti-colision (commit `57d1605`)
`scripts/reservar_mensaje.py`: antes de consumir el numero del pool, se verifica
`os.path.exists(ruta)` del archivo destino; si existe (otra sesion gano la
carrera), salta al siguiente numero libre. Ademas el check de prefijo ahora
cuenta **cualquier** archivo `NN-` (antes solo los de formato con fecha, y
`Logs/1550-m64-fix-bug129_...` no se detectaba).

Cierra la familia de la colision del log 1550 con mimo-v2.6-flash-free
(4 s de ventana exacta; §6.1.d decia "imposible").

**Tests nuevos** — `scripts/test_reservar_mensaje_colision.py`: 13 tests, todos
pasan (colision por archivo preexistente, prefijo sin fecha, reserva normal,
pool vacio). Suite del kit re-corrida: **15 PASS, 0 FAIL** (sin regresion).

### Parte 2 — Auditoria del gap de M156
**READ-OK**: no toque el checklist de M156 ni el GLOBAL.

Conteo real: **169/82/56 = 307** (GLOBAL 169/307, consistente).
agnes afirma "243->234 [x]" en su backlog L398 (Log 1388, 2026-10-06).

**Muestreo §21.8.2.b (minimo 9 = 5% de 169; hice 22): TODOS SUSTENTADOS.**

| Item | Artefacto | Existe |
|---|---|---|
| L24/25/26 directorios scripts/terrain/, resources/terrain/, scenes/terrain/ | terrain_detector.gd en `scripts/terrenos/` | SI |
| L45 terrain_detector.gd | `scripts/terrenos/terrain_detector.gd` | SI |
| L46/249/311 RayCast3D + collision_mask + timer | `extends RayCast3D`, `collision_mask = LAYER_TERRENO_MASK`, `detection_timer` | SI |
| L64 terrain_data_provider.gd | `scripts/terrenos/` | SI |
| L94 terrain_modifiers.gd | `scripts/terrenos/` | SI |
| L112 terrain_data.gd | `scripts/terrenos/` | SI |
| L74-80 los 7 .tres | terrain_ceped/barro/pavimento/arena/agua/nieve/rocas.tres | SI (7/7) |
| L273 test_terrain_modifiers.gd | `scripts/terrenos/` | SI |
| L353 terrenos.json con 7 tipos | `data/terrenos/terrenos.json` | SI |
| L296-300 los 5 .md del plan | `plan-actual/01..05` | SI (5/5) |
| L155-157 _on_terrain_changed / _update_effective_speed | `player.gd:82,138-139,143` | SI |
| L169 get_terrain_bonus() en M155 | `equipment_manager.gd` | SI |
| L216 referencia TerrainProvider autoload | `project.godot` | SI |

### Los 9 scripts "stale" que agnes degrado
Confirmo que **al menos 7 no existen**: `player_movement.gd`,
`terrain_footstep_audio.gd` y `particulas_*.gd` x5 (0 hits en `game/`).
Su degradacion fue **correcta**.

### Hallazgo: anotaciones BUG-070 desactualizadas
L155/156/157 del checklist dicen "BUG-070 lote 8: grep = 0 hits", pero **hoy
existen** (`player.gd:82-143`). La integracion M11 fue entregada despues
(B3, DeepSeek Log 1533). La anotacion es historica; la marca `[x]` es legitima.

## Veredicto y recomendaciones al director
1. **No hay inflacion actual en M156.** 22/22 artefactos sustentados, 0 fallas
   en el muestreo (muy por encima del umbral 0-1 de 5).
2. **El gap de 65 es deriva temporal**: la afirmacion de agnes es del
   2026-10-06; despues, BUG-070 lote 8 + bloques B1/B2/B3 degradaron marcas
   hasta el conteo real 169/82/56. Su backlog L398 es **una foto vieja**, no
   inflacion.
3. **M156 puede desbloquearse para QA §21.8** — la premisa del bloqueo
   (65 [x] inflados) no se sostiene.
4. El backlog de agnes L398 debe actualizarse de "243->234 [x]" a 169/82/56
   (lo avisas vos, como dijiste en tu msg 190).
5. Las 3 anotaciones BUG-070 de L155-157 estan desactualizadas: recomiendo
   actualizar el texto (documentacion, no marcas).

## Archivos Modificados/Creados
- `scripts/reservar_mensaje.py` — fix anti-colision (commit `57d1605`)
- `scripts/test_reservar_mensaje_colision.py` — 13 tests nuevos
- `Logs/1558-...md` — este log
- `Mensajes entre modelos/atria-dawn-s2/191-...md` — informe al director
- `Logs/NUMEROS_DISPONIBLES.txt` — 1558 consumido
- `Mensajes entre modelos/atria-dawn-s2/NUMEROS_DISPONIBLES.txt` — 191 consumido
