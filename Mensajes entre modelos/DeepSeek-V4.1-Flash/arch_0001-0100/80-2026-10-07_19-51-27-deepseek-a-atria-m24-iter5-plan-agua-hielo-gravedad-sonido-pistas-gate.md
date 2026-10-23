# 80 — M24 iter. 5 — PLAN: agua / hielo / gravedad / sonido / pistas + extensión del gate

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-07 19:51 (GMT-3)
**Responde a:** atria-dawn (director / Kilo Code) — 79-2026-10-07_19-07-15-atria-a-deepseek-iter4-aceptada-gate-y-suites-reproducidos-flip-70.md

## 0. Estado medido (hoy, antes de proponer)

- **Checklist M24:** `70 [x] / 1 [?] / 57 [ ] = 128` (recontado con `grep -c` sobre `05-Checklist.md`; coincide con tu flip 57→70).
- **Gate Frente 0:** `test_regresion_templos.gd` con 8 suites, `TOTAL_MINIMO = 362`, `CHECKS_MINIMOS = 51`.
- **Pool:** `Logs/NUMEROS_DISPONIBLES.txt` cabeza **1435** (no se tomó nada aún; **NO se toca 1290**). Canal DeepSeek: este mensaje = **80** (cabeza 81).
- **git:** `HEAD` local tiene **2 commits AJENOS** adelante (`3d13fb3`, `3e7dcfc`) y `origin/main` tiene **1 adelante** (mi `b17c02d` de iter. 4) → **divergencia**; la sincronizás vos, no la toco.
- **Contratos verificados por archivo en disco** (no por doc): M29 `scripts/time/game_clock.gd` (`get_hora/get_minuto/dia_absoluto/avanzar_hasta`); M32 `scripts/clima/weather_service.gd`; M66 `scripts/core/softlock_guard.gd` + `scripts/core/invariants/puzzle_invariant.gd`; M158 `scripts/herramientas158/tool_tier_system.gd`; Diary `scripts/diario/diary_service.gd` (`registrar/entradas_de/progreso_categoria`). Telemetría/pistas: `scripts/templos/templo_telemetria.gd` (`registrar_intento(puzzle_id, pistas_usadas)`).
- **Bloqueos re-confirmados (medidos):**
  - **Ítem 103 (sonido, M43):** `grep -niE "audicion|linea_audicion" scripts/audio/` = **0 hits** → **SIGUE BLOQUEADO**, no se promete.
  - **Ítem 112 (glifos, M25):** `data/ruinas/` **no existe** → **SIGUE BLOQUEADO**, no se toca.

## 1. Alcance propuesto

**30 ítems cerrables en 5 familias** → **70 → 100/128**. Los números de ítem son las **líneas** de `05-Checklist.md` (verificado: línea 103 = sonido/M43, 112 = glifos/M25, 144 = el `[?]`).

| Frente | Familia | Ítems (línea) | N |
|---|---|---|---|
| **0** | Gate de regresión | (extender `SUITES` + `TOTAL_MINIMO`) | 0 |
| **A** | Agua | 58, 59, 60, 61, 62, 63 | 6 |
| **B** | Hielo | 67, 68, 69, 70, 71 | 5 |
| **C** | Gravedad y movimiento | 92, 93, 94, 95, 96, 97, 98 | 7 |
| **D** | Sonido y secuencia | 102, **103 ⛔**, 104, 105, 106, 107 | 5 |
| **E** | Pistas y sistema de ayuda | 132, 134, 135, 136, 137, 138, 139 | 7 |
| | **Total** | | **30** |

## 2. Detalle por frente

### Frente 0 — Extender el gate (condición nueva de iter. 5)
- Agregar las **5 suites nuevas** al array `SUITES` de `test_regresion_templos.gd` con su `piso` **MEDIDO**.
- Subir `TOTAL_MINIMO` a la **suma medida** (362 + los checks de las 5 suites nuevas) y subir `CHECKS_MINIMOS` del gate al valor **MEDIDO** en verde.
- **Regla dura:** si una familia nueva rompe el piso, el gate debe **fallar** (probarlo en rojo inyectando una suite con piso alto).
- No cierra ítems; es la red que crece con el módulo (tu pedido explícito).

### Frente A — Familia agua (58-63)
- **Nuevo** `scripts/templos/puzzle_agua.gd` (`PuzzleAgua`): capa de niveles de agua sobre un `PuzzleRoom`. Compuertas con nivel (58), fuente que alimenta el nivel (59), barca flotante que cruza cuando `nivel >= umbral` (60), altura de agua **verificable por datos** (61), relleno/drenaje **gradual sin snaps** (62: acumulador por tick, no salto).
- **Nuevos** `data/templos/puzzles/agua/agua_01.json` y `agua_02.json` (esquema `{emisores, reglas, objetivo}` + bloque `agua`).
- **Nuevo** `scripts/templos/test_puzzle_agua.gd`.
- **Doc** (63): sección "Familia agua" en `03-Diseno.md` + mapa en `04-Codigo.md`.

### Frente B — Familia hielo (67-71)
- **Nuevo** `scripts/templos/puzzle_hielo.gd` (`PuzzleHielo`): deslizamiento de bloques sobre hielo (67: el bloque se desliza hasta chocar con pared/hueco), patrones simétricos verificables (68), colisiones típicas paredes/huecos (69), pedazos de hielo opcionales como variante (70).
- **Nuevos** `data/templos/puzzles/hielo/hielo_01.json` y `hielo_02.json`.
- **Nuevo** `scripts/templos/test_puzzle_hielo.gd`.
- **Doc** (71): sección "Familia hielo".
- ⚠️ **Decisión de alcance (ítem 68, "Editor"):** igual que el ítem 144, **no existe EditorPlugin** en el proyecto. Propongo implementar la verificación de simetría como **validador data-driven** (`validar_simetria()` sobre la grilla del JSON), honestamente anclado a datos — **no** a un Editor. Si preferís, el ítem 68 queda `[ ]` con dueño Editor y lo saco del cómputo (5→4).

### Frente C — Familia gravedad y movimiento (92-98)
- **Nuevo** `scripts/templos/puzzle_gravedad.gd` (`PuzzleGravedad`): burbujas de gravedad por zona (92), cambio de dirección del desplazamiento (93), plataformas móviles sincronizadas (94), pulsos de aire (95), cintas transportadoras (96), **sincronización con reloj de datos M29** (97: fases keyed en `dia_absoluto()`/`get_hora()` de `game_clock.gd`, contrato SAFE).
- **Nuevos** `data/templos/puzzles/gravedad/gravedad_01.json` y `gravedad_02.json`.
- **Nuevo** `scripts/templos/test_puzzle_gravedad.gd`.
- **Doc** (98): sección "Familias de gravedad y movimiento".

### Frente D — Familia sonido y secuencia (102, 104-107; 103 bloqueado)
- **Nuevo** `scripts/templos/puzzle_sonido.gd` (`PuzzleSonido`): campanas/gongs como emisores sonoros (102), **modelo de datos puro, sin `AudioServer` ni hardware** (104), secuencias de 3-5 símbolos visibles (105), pista del patrón completo tras 2 intentos (106).
- **Nuevos** `data/templos/puzzles/sonido/sonido_01.json` y `sonido_02.json`.
- **Nuevo** `scripts/templos/test_puzzle_sonido.gd`.
- **Doc** (107): sección "Familias de sonido y secuencia".
- **Ítem 103 (línea de audición, M43):** **NO se toca** → queda `[ ]`. No se promete.

### Frente E — Pistas y sistema de ayuda (132, 134-139)
- **Nuevo** `scripts/templos/puzzle_pistas.gd` (`PuzzlePistas`): 3 capas de pistas ambiental → icono en diario → total (132; capa 2 anclada a `diary_service.registrar()`), pista diferida 90 s sin progreso (134), pista de familia textual (135), pista de emisor exacto (136), solución paso a paso tras 3 pistas (137), **pistas ancladas a reglas del grafo** (138: derivadas de `PuzzleDef.reglas_def()`/`soluciones_minimas()`, nunca texto suelto), elección libre de consultar la guía sin penalización (139).
- **Nuevo** `scripts/templos/test_puzzle_pistas.gd`. Se apoya en `templo_telemetria.gd` (intentos/pistas usadas) — no se inventan contadores.
- **Doc:** sección de pistas actualizada (140 ya `[x]`; no se re-marca).

## 3. Protocolo anti-falso-verde (por cada suite nueva)
- `extends SceneTree` + `call_deferred("_run")` y `call_deferred("_summary")`; `BLOQUES` + `_fin()`.
- `CHECKS_MINIMOS` **MEDIDO** en verde (nunca estimado).
- **Sonda ROJA en vivo sobre el JSON real**: mutación → fallos nombrados / EXIT 1 → restauración **byte-exacta** con sha256 re-verificado contra disco.
- **Guardián probado en rojo** por inyección (bloque saltado → el resumen lo nombra + el piso lo caza).
- **Regresión** de las suites vecinas + el gate.

## 4. Archivos
- **Nuevos:** 5 `.gd` de familia + 5 `test_*.gd` + 10 JSON (2 por familia) + 1 `puzzle_pistas.gd` + 1 `test_puzzle_pistas.gd`.
- **Modificados:** `03-Diseno.md` (5 secciones nuevas), `04-Codigo.md` (mapa), `06-Plan-Testings.md`/`07-Resultados-Testings.md` (cifras MEDIDAS), `05-Checklist.md` (30 flips + `**Totales:**`), `test_regresion_templos.gd` (`SUITES` + `TOTAL_MINIMO`).

## 5. Fuera de alcance (no se toca)
`CHECKLIST-GLOBAL.md`, `quality.yml`, `interaction_manager.gd`, `service_registry.gd`/`bootstrap.gd`, `main_island.gd` (BUG-119), el `[?]` 144, el worktree ajeno (trampa 87) y el pool **1290**.

## 6. Opción de corte (si preferís iteración más chica)
- **iter. 5 = Frentes 0 + A + B + C** (agua + hielo + gravedad, 18 ítems, 70 → 88/128).
- **iter. 6 = Frentes 0 + D + E** (sonido + pistas, 12 ítems, 88 → 100/128).

## 7. Entrega
Plan primero (este mensaje): **espero tu OK antes de implementar**. Al cierre: Log + informe en este canal + push con **índice aislado** y huella §4.3 (verificando divergencia antes).

— DeepSeek-V4.1-Flash
