# 06 — Plan de Testings — M24: Templos y Puzzles

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-07
**Estado:** vigente (iter. 3)
**Cierra:** ítems 168, 169, 170, 171 y 172 del `05-Checklist.md`.

Este documento define **cómo se prueba** el framework emisor→receptor de M24. No reemplaza al
`05-Checklist.md`: mientras el checklist declara *qué* falta, este plan declara *con qué evidencia*
se cierra cada pieza. Las cifras reales de ejecución van en `07-Resultados-Testings.md`.

## 1. Unitarias del framework (ítem 168)

Suites headless (Godot 4.7.2, `--headless --path game/isla-ancestral --script <ruta>`), todas
`SceneTree` con resumen y piso medido:

| Suite | Cubre | Contrato anti-falso-verde |
|---|---|---|
| `scripts/templos/test_puzzle_datos.gd` | Intérprete datos-driven (`PuzzleDef`): carga, validación, unicidad, "casi solución", umbral de peso, `a_puzzle_room`. | Bloques A-F nombrados; `CHECKS_MINIMOS` medido; `_summary()` en `call_deferred`; sonda de ambigüedad. |
| `scripts/templos/test_puzzle_multilateral.gd` | Familia multilateral migrada (anillos n=7, final 3 fases) + cruce contra el catálogo real. | Igual + **sonda roja** (mutación de la regla AND → ambigüedad). |
| `scripts/templos/test_puzzle_bloques.gd` | Familia bloques (push/pull): 1 eje, ranuras, límites, puente + capa espacial. | Igual + **sonda roja doble** (eje inválido / límite abierto / ambigüedad). |
| `scripts/templos/test_puzzles.gd` | Framework base (transiciones, completado, no-arbitrariedad, integración emisor→puerta). | Suite original de Hy3 (0 fallos). |
| `scripts/templos/test_templo_m26.gd` | Salas de M26 (7 anillos, fases). | 92 checks. |
| `scripts/templos/test_templo_headless.gd` | Humo de arranque del templo. | 4 checks. |

**Regla de oro:** ningún `[x]` de implementación se declara sin una suite que lo ejecute en verde
**con el piso medido**. Un "0 fallos" de una suite que aborta antes de sus aserciones es falso verde.

## 2. Playtests externos por familia (ítem 169)

Los playtests externos **no** corren en CI: se ejecutan con personas y se registran en
`07-Resultados-Testings.md`. Plan por familia:

| Familia | Qué se observa | Métrica de éxito |
|---|---|---|
| Presión | ¿Se entiende que hay que pisar a la vez? ¿La placa de peso estático (caja) es descubrible? | ≥ 4/5 resuelven sin pista; 0 bloqueos > 90 s. |
| Multilateral | ¿Se percibe que el estado es de la **sala** y no de un anillo? | ≥ 3/5 resuelven el puzzle final sin guía. |
| Bloques | ¿Se entiende el eje único de cada bloque? ¿El límite de sala se lee como "no se puede"? | ≥ 4/5 no intentan empujar fuera de la sala. |
| (resto) | Pendientes de iter. 4+. | — |

La **telemetría** de M24 (`PuzzleTimer`: tiempo, pistas, abandonos; exportación para playtests
externos) es el instrumento de registro.

## 3. Edge cases (ítem 170)

| Caso | Cómo se prueba | Resultado esperado |
|---|---|---|
| **2+ soluciones (ambigüedad)** | Sonda roja: 2 caminos OR incomparables. | `soluciones_minimas == 2` y `validar_def` falla con "ambiguo". |
| **Regla rota (emisor inexistente)** | Sonda sintética: regla `[0, 99]`. | `validar_def` falla con "emisor inexistente 99". |
| **Regla desconectada (emisor huérfano)** | Sonda sintética. | `validar_def` falla con "huérfano". |
| **Objetivo ≠ solución mínima** | Sonda sintética (regla redundante). | `validar_def` falla con "no es la solución mínima". |
| **Eje inválido (bloques)** | Sonda roja sobre el JSON real. | `validar_espacial` falla con "eje 'z' no permitido". |
| **Límite de sala abierto (bloques)** | Sonda roja. | `validar_espacial` falla con "debe ser false". |
| **Empuje fuera de grilla / celda ocupada** | Simulación real. | `empujar()` devuelve false y la pieza no se mueve. |

## 4. Rendimiento (ítem 171)

**Umbral: ≤ 1 ms por tick de sala.** Un "tick" = actualizar el estado de un emisor + recalcular
receptores + distancia al objetivo (`set_emisor` + `recalcular` + `distancia_objetivo`).

- Se mide con `Time.get_ticks_usec()` promediando 2000 ticks sobre una sala real.
- El coste de la **herramienta de autoría** (`PuzzleDef.validar_def`, fuerza bruta 2^n) **no** es un
  tick: se mide aparte y solo se exige que sea usable en el Editor (< 10 ms para n=2).
- Los valores medidos van en `07-Resultados-Testings.md` (nunca estimados).

## 5. Criterio de éxito (ítem 172)

Una iteración de M24 se considera **cerrada con evidencia** solo si, en el mismo commit:

1. Todas las suites de M24 corren **EXIT 0 con 0 `SCRIPT ERROR`**, y cada una reporta un número de
   checks **≥ su piso `CHECKS_MINIMOS` medido**.
2. Cada sonda roja produce **fallos nombrados** (no un simple "fallo") y **EXIT 1**.
3. Los datos mutados durante una sonda se **restauran byte-exactos** (sha256 antes == después).
4. Las cifras del `07-Resultados-Testings.md` son **medidas**, no copiadas de una corrida anterior.
5. El `05-Checklist.md` marca `[x]` **solo** los ítems con la evidencia anterior; el resto queda `[ ]`.

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — Log 1426.
