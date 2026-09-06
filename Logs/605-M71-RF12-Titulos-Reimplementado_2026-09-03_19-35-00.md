# Log 605: M71 Progresión — RF12 títulos re-implementado (deuda técnica de revert)

**Fecha:** 2026-09-03
**Hora:** 19:35
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Re-implementación de RF12 (títulos sociales cosméticos) en M71, cuya primera versión (Log 518) fue revertida por un agente concurrente. Aditivo y retro-compatible: sin bump de versión, sin tocar la RF10/imposibles que otro agente re-hizo con diseño superior. 6 checks nuevos → test_progresion 0 fallos.

## Causa y contexto
- Log 518 implementó RF12 (títulos) + RF10 (gating) en progression_manager.gd.
- Un agente concurrente revirtió el archivo (perdió ambas) — documentado en M72/M74 y BUG-013.
- Al volver a M71, la RF10 ya estaba RE-hecha por otro agente con mejor diseño (caché de evaluación, predicado puro, detección estática/dinámica de imposibles) — se respeta íntegramente.
- Solo faltaba RF12 → re-implementación quirúrgica del gap.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scripts/progresion/progression_manager.gd` | +señal progreso_titulo_obtenido; +_titulos dict; +_otorgar_titulo() idempotente; +API (otorgar_titulo_directo/titulos_obtenidos/tiene_titulo/titulo_count); recompensa "titulo" en marcar_hito ahora otorga; persistencia `titulos` (deep-copy, restore tolerante sin bump) |
| `scripts/progresion/test_progresion.gd` | +_test_titulos_rf12 (12 checks: otorgamiento desde hito, idempotencia, señal única, API directa, round-trip) |
| `DOCUMENTACION/71-Progresion/plan-actual/05-Checklist.md` | RF12 [x] + Notas del Agente |
| `CHECKLIST-GLOBAL.md` / `ESTADO-PARALELO.md` | M71 RF12 re-implementado (28/213) |

## Tests (headless Godot 4.7.2)
- `test_progresion.gd`: **0 fallos** (incluye 12 checks nuevos de RF12 + todas las iteraciones previas de otros agentes: caché, predicado puro, imposibles, validación)
- hito_amistades_5 del catálogo con recompensa "titulo": "Amigo del Pueblo" otorgado y persistido

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/progresion/progression_manager.gd` *(modificado, aditivo)*
- `game/isla-ancestral/scripts/progresion/test_progresion.gd` *(modificado)*
- `DOCUMENTACION/71-Progresion/plan-actual/05-Checklist.md` *(modificado)*
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md` *(modificados)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 605)*
- `Logs/reservas/605-...txt` *(creado y borrado)*

## Notas técnicas
- Sin bump de SECCION_VERSION: la clave `titulos` es aditiva — saves v1 carecen de ella y restore la maneja con `.get("titulos", {})`.
- Deep-copy en get_save_data (lección de aliasing Log 553) aplicado de inicio.
- El consumidor natural es M53 (panel de títulos del jugador) vía señal + API; M72/M45 pueden consultar para iconografía.
- Lección de coordinación: 2 reverts del mismo módulo en 48 h — los archivos calientes necesitan un registro de "quién está editando" más visible que ESTADO-PARALELO.
