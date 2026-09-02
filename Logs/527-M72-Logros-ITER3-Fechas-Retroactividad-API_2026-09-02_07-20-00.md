# Log 527: M72 Logros — iter. 3 (fechas, retroactividad, API, toasts, validación)

**Fecha:** 2026-09-02
**Hora:** 07:20
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. 3 de M72 Sistema de Logros sobre el núcleo iter. 1-2 (glm-5.3-flash 2026-09-01): fechas de desbloqueo deterministas, retroactividad al cargar, evaluación event-driven extendida a EventBus, API de consulta completa, progreso humano, toasts vía EventBus.notify y validación de catálogo headless. 48 ítems de checklist marcados [x] con evidencia → 62/190.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scripts/logros/achievement_service.gd` | +_fechas {dia,hora} (RF4) + re_evaluar_todo() retroactivo (RF5) + EventBus listeners (RF3) + get_progreso_humano (RF8) + API consulta (RF10) + _emitir_toast EventBus.notify (RF6) + validar_catalogo/TIPOS_CONDICION_VALIDOS (RF14) + persistencia v2 con migración v1 (RF9) + mark_dirty write-through (RF4) |
| `scripts/logros/test_logros.gd` | +7 secciones: validación RF14, fechas RF4, API RF10, progreso humano RF8, migración v1, retroactividad RF5, persistencia v2 |
| `scripts/audio/music_director.gd` | FIX ajeno bloqueante: línea 209 `_ = viejo` (sintaxis Python inválida) → rename `_viejo` (rompía el boot de todo el proyecto) |
| `DOCUMENTACION/72-Sistema-De-Logros/plan-actual/05-Checklist.md` | Reserva actual + 48 ítems [x] con evidencia + Notas del Agente |
| `CHECKLIST-GLOBAL.md` | M72: 🟢 → 🔵 → 🟡 Liberado (62/190) |
| `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` | Fila M72 iter. 3 agregada |
| `Mensajes entre modelos/ESTADO-PARALELO.md` | Entrada M72 liberada |
| `Logs/ULTIMO_NUMERO.txt` | → 527 (con detección de race: otro agente llegó a 526 en paralelo) |

## Tests (todos headless Godot 4.7.2)
- `test_logros.gd` (M72, 13 secciones): **0 fallos**
- Regresión `test_progresion.gd` (M71): **0 fallos**
- Regresión `test_viajes.gd` (M28): **0 fallos**
- Regresión `test_harbor_viajes.gd` (M28): **0 fallos**
- Boot: `[M72] Logros cargados: 7`, `[M72][RF14] Catálogo OK`, sin errores nuevos

## Hallazgos
1. **Race de log (protocolo v2 funcionó):** al reservar, ULTIMO_NUMERO decía 524 pero otros agentes crearon logs 520-526 en paralelo. La verificación 6.1.a.2 (existe log/reserva) absorbió la colisión → liberé 527.
2. **M71 revertido por agente concurrente:** `progression_manager.gd` perdió mi iter. 3 (RF12 títulos + RF10 gating, Log 518). Documentado en Notas del Agente de M72 y M71; el check `version >= 1` del test sobrevivió y es compatible con el revert.
3. **music_director.gd roto en boot:** sintaxis Python `_ = viejo` (M41, otro agente). Fix mínimo documentado; las líneas 177-179 las arregló su agente en paralelo.

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/logros/achievement_service.gd` *(modificado)*
- `game/isla-ancestral/scripts/logros/test_logros.gd` *(modificado)*
- `game/isla-ancestral/scripts/audio/music_director.gd` *(fix ajeno bloqueante)*
- `DOCUMENTACION/72-Sistema-De-Logros/plan-actual/05-Checklist.md` *(modificado)*
- `CHECKLIST-GLOBAL.md` *(modificado)*
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` *(modificado)*
- `Mensajes entre modelos/ESTADO-PARALELO.md` *(modificado)*
- `Logs/ULTIMO_NUMERO.txt` *(modificado)*
- `Logs/reservas/527-glm-5.3-flash-M72-Logros.txt` *(creado y borrado)*

## Notas técnicas
- Fechas de logro = día absoluto del calendario Aurora (M29): determinista, replay-safe, cero tiempo real (RN11).
- Toast vía señal existente `EventBus.ui.notify` (M07) — no se creó CanvasLayer propio (M53 dueño de la presentación).
- `validar_catalogo()` es ejecutable headless → apto para gates CI de M117/M118.
- Persistencia: `{version:2, desbloqueados:{id:{dia,hora}}}`; restore acepta Array v1 (fechas -1) y Dictionary v2.
