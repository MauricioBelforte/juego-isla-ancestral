# Log 1824: M11-Personaje auditada completa (51 `[?]`, 0 promos) — 3 ítems desactualizados detectados

**Fecha:** 2026-10-13
**Hora:** 21:10
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Auditoría de los 51 `[?]` de M11-Personaje-Del-Jugador (encargo del director mimo, msg 280/285 +
reenvío de s3). Commit `89de8d8`. **0 promociones**, pero **3 ítems marcados como desactualizados**
porque la evidencia en disco contradice su texto.

## Resultado

- Conteos: **72 `[x]` / 0 `[ ]` / 51 `[?]`** = 123 (coincide con la línea Totales del módulo).
- 51 `[?]` anotados con archivo/línea/evidencia.

## Los 3 ítems DESACTUALIZADOS (el disco contradice el texto del ítem)

| Ítem | Decía | Evidencia real |
|---|---|---|
| 3 — Velocidad de correr 6.5 m/s | "NO implementado (sin sprint)" | `player_core_m11.gd` L50 `VELOCIDAD_CORRER := 6.5`, aplicado como FACTOR proporcional sobre `move_speed` (L19-30, autorizado por director msg 141) |
| 12/13 — InteractionService 4 m | "NO implementado (sin InteractionService)" | El nombre no existe, pero el equivalente de M70 sí: `scripts/interacciones/interaction_manager.gd` (autoload) con `DEFAULT_RANGO=2.5` + radio por interactuable (1.5 m default) = **4.0 m totales**, coincidiendo con el diseño; `test_interacciones.gd` L124 lo verifica |
| 38 — 10 clips placeholder | "NO existen AnimationPlayer ni AnimationTree" | `Player.tscn` L48 **sí** tiene AnimationPlayer con `jugador_lib.tres` (L7); la libreria tiene **3** clips reales (idle/walk/run), no 10 |

Nota: no los promoví porque el ítem 3 pide la velocidad absoluta y el runtime usa `move_speed`
escalado en modo DEV (25.0); el 12/13 pide el nombre exacto `InteractionService`; y el 38 pide
10 clips cuando hay 3. La promoción correspondería a reescribir los ítems, decisión del director.

## Deuda real de M11 encontrada

- **`data/player/` no existe** (80 carpetas en `data/`, ninguna `player`): las constantes físicas
  viven hardcodeadas en `player.gd` (move_speed L8, gravity L9, jump_force L10) y `Player.tscn`
  L19-21. No hay `player_motion.tres`.
- **`PlayerEnergy` no está cableado a `player.gd`** (comentario L24-25 del propio archivo): el
  modelo cozy (1/min, umbral fatiga 30% informativo) existe pero no informa ni bloquea en runtime.
- **Sin daño por caída** (confirmado) pero **sin amortiguación** >3 bloques.
- **Sin aire de buceo, sin velocidad de nado/buceo horizontal, sin step-up** (VoxelBoxMover no lo
  expone), sin highlight de objetivo del jugador (los highlights son de herramientas).
- **Guardado**: `player_save_provider.gd` (M59) guarda name/position/spawn_position/zone con
  duck-typing; energía/stamina/FSM no se persisten; no hay `GameState` con sección M11.

## Archivos Modificados/Creados

- `DOCUMENTACION/11-Personaje-Del-Jugador/plan-actual/05-Checklist.md` (51 `[?]` anotados; commit
  `89de8d8`)
- `Logs/1824-...md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (1824 consumido)
- `scripts-prueba-temp/audit_m11_b*.py` (scripts de anotación por bloque)

## Cierre del encargo de 10 bloques

M27 (66), M74 (59), M34 (54), M11 (51) = **230 `[?]` auditados, 3 promociones**
(M27 es_flotante, M74 M154, y las demás con evidencia en disco).
