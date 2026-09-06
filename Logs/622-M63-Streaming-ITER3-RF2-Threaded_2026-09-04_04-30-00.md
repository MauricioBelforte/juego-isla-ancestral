# Log 622: M63 Streaming — iter. 3 (RF2 cargas asíncronas con load_threaded_request)

**Fecha:** 2026-09-04
**Hora:** 04:30
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. 3 de M63: RF2 completado — las operaciones de carga de RECURSOS (texturas_atlas, banco_audio, escena) ahora usan `ResourceLoader.load_threaded_request` REAL (thread del engine), con callback al completar y fallback honesto. 1 ítem marcado [x] → 12/101.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scripts/stream/stream_manager.gd` | encolar() acepta `ruta_recurso: String = ""` — si existe en el FS, hace `load_threaded_request`; _process: si THREADED, chequea estado (IN_PROGRESS → re-encola sin bloquear el frame, LOADED → callback con Resource, FAILED → callback fallback); operaciones sin ruta siguen siendo callables diferidos (compatibilidad) |
| `scripts/stream/test_rf2_threaded.gd` *(nuevo)* | 6 checks: threaded callback con recurso real, re-encolado no bloqueante, fallback ruta inexistente, compatibilidad sin ruta |
| `DOCUMENTACION/63-Cargas-Y-Streaming/plan-actual/05-Checklist.md` | RF2 [x] |
| `CHECKLIST-GLOBAL.md` / `ESTADO-PARALELO.md` | M63 iter. 3 Liberado (12/101) |

## Tests (headless Godot 4.7.2)
- `test_rf2_threaded.gd`: **0 fallos**
- Regresiones: test_pausa_cargas **0 fallos**, test_stream_m63 **8/0**
- Boot: sin errores nuevos

## Notas técnicas
- La re-encolación de ops IN_PROGRESS no consume presupuesto del frame (solo chequea estado del thread — ~0 ms) y respeta la pausa.
- El fallback honesto cubre 3 casos: ruta inexistente, THREAD_LOAD_FAILED, THREAD_LOAD_INVALID_RESOURCE.
- Los callables sin ruta (chunk_lod0, npc_instancia, etc.) mantienen el comportamiento diferido de iter. 1 — compatibilidad total con el núcleo existente.
- El thread real del engine es gestionado por Godot (no crea threads propios) — sin riesgo de threading en el gameplay.
