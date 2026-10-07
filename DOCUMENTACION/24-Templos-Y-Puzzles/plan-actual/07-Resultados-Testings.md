# 07 — Resultados de Testings — M24: Templos y Puzzles

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-07 03:55 (GMT-3)
**Godot:** 4.7.2-stable (win64, `--headless`)
**Cierra:** ítem 173 del `05-Checklist.md`.
**Plan:** `06-Plan-Testings.md`.

Todas las cifras de esta página son **MEDIDAS** en esta fecha (no estimadas ni heredadas).

## 1. Suites (última corrida — 2026-10-07 03:55)

| Suite | Checks | Fallos | EXIT | SCRIPT ERROR | Piso |
|---|---|---|---|---|---|
| `test_puzzle_bloques.gd` | 64 | 0 | 0 | 0 | `CHECKS_MINIMOS=64` (medido) |
| `test_puzzle_datos.gd` | 42 | 0 | 0 | 0 | `CHECKS_MINIMOS=42` (medido) |
| `test_puzzle_multilateral.gd` | 38 | 0 | 0 | 0 | `CHECKS_MINIMOS=38` (medido) |
| `test_puzzles.gd` | — | 0 | 0 | 0 | — (suite original Hy3) |
| `test_templo_m26.gd` | 92 | 0 | 0 | 0 | — |
| `test_templo_headless.gd` | 4 | 0 | 0 | 0 | — |

`test_puzzle_bloques.gd`: **64/0 EXIT 0 ×3** (3 corridas consecutivas, 0 `SCRIPT ERROR`).

## 2. Sonda roja — familia bloques (condición del director, ítems 84-87)

Procedimiento: se inyectó un **eje inválido** (`"eje": "z"`) en el JSON REAL
`data/templos/puzzles/bloques/bloques_01.json`, se corrió la suite y se restauró el archivo.

- **Corrida con el JSON inyectado:** `=== Resumen M24-Bloques: 64 checks, 12 fallos ===` / **EXIT 1**.
- **Fallos nombrados (12):** `validar_espacial(bloques_01) sin errores` · `bloque_a de bloques_01
  declara eje 'x'` · control positivo de la sonda · y 9 checks de simulación (con eje inválido el
  bloque no se mueve: empuje +x, empujes por eje prohibido, vuelta a origen, llegada a la ranura,
  emisor ON, puente activo, `estado_igual_objetivo`).
- **Restauración byte-exacta:** sha256 antes == después ==
  `fdf06cbc45cd5c02005790842c4572aef0e3b3e25aa023e1db134ff67c99b1b9`.
- **Re-corrida tras restaurar:** 64/0, EXIT 0.

### Sondas del guardián anti-falso-verde (inyección en la propia suite)

| Inyección | Resultado medido |
|---|---|
| Quitar la llamada al bloque E (dejando su `_fin`) | `40 checks, 1 fallo` → `[FALLO] solo 40 checks ejecutados (minimo 64)` / EXIT 1 |
| Quitar la llamada al bloque E **y** su `_fin` | `40 checks, 2 fallos` → `[FALLO] el bloque E NO se ejecuto` + piso / EXIT 1 |

Ambas inyecciones se revirtieron; la suite quedó en **64/0 EXIT 0**.

## 3. Sondas in-memory permanentes (bloque D de cada suite)

- `test_puzzle_bloques.gd` bloque D: eje inválido → `validar_espacial` falla con "eje 'z' no
  permitido"; límite `salir_de_grilla=true` → falla con "debe ser false"; ambigüedad (2 caminos OR) →
  `soluciones_minimas == 2` y `validar_def` falla con "ambiguo".
- `test_puzzle_multilateral.gd` bloque D: ambigüedad sobre una copia del anillos real → 2 mínimas.

## 4. Rendimiento MEDIDO (ítem 171)

`Time.get_ticks_usec()` promediando 2000 ticks (salas 01 y 02) y 200 validaciones (n=2):

| Métrica | Medido | Umbral | Veredicto |
|---|---|---|---|
| tick de sala (bloques_01) | 2.0020 µs/tick (0.002002 ms) | ≤ 1 ms | OK |
| tick de sala (bloques_02) | 2.1135 µs/tick (0.002114 ms) | ≤ 1 ms | OK |
| `validar_def(bloques_02, n=2)` (autoría) | 22.61 µs (0.0226 ms) | < 10 ms | OK |

Los valores en µs varían entre corridas (dependen de la máquina); lo que sostiene el veredicto es el
**orden de magnitud**: el tick queda ~2 órdenes por debajo del umbral de 1 ms.

## 5. Playtests externos

Pendientes de ejecución con personas (instrumento: telemetría `PuzzleTimer`). Sin datos aún; no se
declaran resultados. El plan por familia está en `06-Plan-Testings.md` §2.

## 6. Regresión

Las 6 suites de M24 corren en verde (tabla §1). No se modificó ningún archivo de otro módulo.

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — Log 1426.
