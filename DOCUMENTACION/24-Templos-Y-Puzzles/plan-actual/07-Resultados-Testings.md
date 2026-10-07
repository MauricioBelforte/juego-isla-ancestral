# 07 — Resultados de Testings — M24: Templos y Puzzles

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-07 18:41 (GMT-3) — iter. 4
**Godot:** 4.7.2-stable (win64, `--headless`)
**Cierra:** ítem 173 del `05-Checklist.md`.
**Plan:** `06-Plan-Testings.md`.

Todas las cifras de esta página son **MEDIDAS** en esta fecha (no estimadas ni heredadas).

## 1. Suites (última corrida — 2026-10-07 18:41, iter. 4)

| Suite | Checks | Fallos | EXIT | SCRIPT ERROR | Piso |
|---|---|---|---|---|---|
| `test_puzzle_bloques.gd` | 64 | 0 | 0 | 0 | `CHECKS_MINIMOS=64` (medido) |
| `test_puzzle_luz.gd` | 60 | 0 | 0 | 0 | `CHECKS_MINIMOS=60` (medido) |
| `test_puzzle_espejos.gd` | 62 | 0 | 0 | 0 | `CHECKS_MINIMOS=62` (medido) |
| `test_puzzle_datos.gd` | 42 | 0 | 0 | 0 | `CHECKS_MINIMOS=42` (medido) |
| `test_puzzle_multilateral.gd` | 38 | 0 | 0 | 0 | `CHECKS_MINIMOS=38` (medido) |
| `test_puzzles.gd` | — | 0 | 0 | 0 | — (suite original Hy3) |
| `test_templo_m26.gd` | 92 | 0 | 0 | 0 | — |
| `test_templo_headless.gd` | 4 | 0 | 0 | 0 | — |

`test_puzzle_bloques.gd`: **64/0 EXIT 0 ×3** (3 corridas consecutivas, 0 `SCRIPT ERROR`).
`test_puzzle_luz.gd`: **60/0 EXIT 0 ×3** · `test_puzzle_espejos.gd`: **62/0 EXIT 0 ×3** (0 `SCRIPT ERROR`).
`test_regresion_templos.gd` (gate): **51/0 EXIT 0 ×3**, total MEDIDO **362** == piso total **362**.

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

## 2bis. Sondas rojas — familias luz y espejos (iter. 4, ítems 39-45 / 49-54)

**Luz** (`luz_01.json`): se cambió `"angulo": 45` → `30` en el espejo real y se corrió la suite.
- Corrida inyectada: `=== Resumen M24-Luz: 60 checks, 11 fallos ===` / **EXIT 1** (0 `SCRIPT ERROR`).
- Fallos nombrados (11): `validar_optica(luz_01) sin errores` · `espejo_a de luz_01 esta a 45 grados` ·
  `espejo a 45 refleja E->N` · `luz_01 llega al cristal` · `luz_01 activa el receptor` · `el emisor 0 de
  la sala queda ON` · `sala.estado_igual_objetivo()` · control positivo · `el camino termina en el
  cristal (3,1)` · `tras desbloquear (1,3) el rayo vuelve a llegar` · `y el receptor se reactiva`.
- Restauración byte-exacta: sha256 antes == después ==
  `4f0000afb742659f84a587cf684adea7943feeb5227b94e7d0f454160fca3c8e`. Re-corrida: 60/0, EXIT 0.

**Espejos** (`espejos_01.json`): se cambió `"angulo": 135` → `90` en el espejo fijo real.
- Corrida inyectada: `=== Resumen M24-Espejos: 62 checks, 9 fallos ===` / **EXIT 1** (0 `SCRIPT ERROR`).
- Fallos nombrados (9): `feedback(espejo_b) tras rotar es "S->O"` · `direccion_salida(espejo_b) == OESTE`
  · `01 — el espejo fijo desvia E->S` · `01 — el espejo movil devuelve el rayo S->N` · `01 — tras rotar
  45 el rayo LLEGA al cristal` · `01 — y el receptor se activa` · `01 — el emisor 0 queda ON` ·
  `01 — sala.estado_igual_objetivo()` · `01 — el camino resuelto termina en el cristal (0,4)`.
- Restauración byte-exacta: sha256 antes == después ==
  `e2b08324fd75bc09066339c84489243241f2083ab21ff434bf166ceab1e3fa4e`. Re-corrida: 62/0, EXIT 0.

### Guardián anti-falso-verde (inyección en la propia suite)

| Inyección (se omite el bloque F y su `_fin`) | Resultado medido |
|---|---|
| `test_puzzle_luz.gd` | `57 checks, 2 fallos` → `[FALLO] el bloque F NO se ejecuto` + `solo 57 checks ejecutados (minimo 60)` / EXIT 1 |
| `test_puzzle_espejos.gd` | `59 checks, 2 fallos` → `[FALLO] el bloque F NO se ejecuto` + `solo 59 checks ejecutados (minimo 62)` / EXIT 1 |

Ambas inyecciones se revirtieron; las suites quedaron en 60/0 y 62/0 EXIT 0.

## 3. Sondas in-memory permanentes (bloque D de cada suite)

- `test_puzzle_bloques.gd` bloque D: eje inválido → `validar_espacial` falla con "eje 'z' no
  permitido"; límite `salir_de_grilla=true` → falla con "debe ser false"; ambigüedad (2 caminos OR) →
  `soluciones_minimas == 2` y `validar_def` falla con "ambiguo".
- `test_puzzle_multilateral.gd` bloque D: ambigüedad sobre una copia del anillos real → 2 mínimas.
- `test_puzzle_luz.gd` bloque D: ángulo 30 (no múltiplo de 45) → `validar_optica` falla con "no es
  multiplo de 45"; desvío 45 (no múltiplo de 90) → falla con "no es multiplo de 90"; fuente fuera de
  grilla → falla; sin la lente la concentración es 0 y el cristal (exige 1) NO se activa; desvío 0 → el
  rayo NO llega; ambigüedad (2 caminos OR) → 2 mínimas.
- `test_puzzle_espejos.gd` bloque D: rotación de espejo fijo rechazada; rotación no múltiplo de 45
  rechazada; rotación de espejo inexistente rechazada; ambigüedad → 2 mínimas.

## 4. Rendimiento MEDIDO (ítem 171)

`Time.get_ticks_usec()` promediando 2000 ticks (salas 01 y 02) y 200 validaciones (n=2):

| Métrica | Medido | Umbral | Veredicto |
|---|---|---|---|
| tick de sala (bloques_01) | 2.0020 µs/tick (0.002002 ms) | ≤ 1 ms | OK |
| tick de sala (bloques_02) | 2.1135 µs/tick (0.002114 ms) | ≤ 1 ms | OK |
| `validar_def(bloques_02, n=2)` (autoría) | 22.61 µs (0.0226 ms) | < 10 ms | OK |
| re-trazado (luz_01) | 10.7745 µs/tick (0.010774 ms) | ≤ 1 ms | OK |
| re-trazado (luz_02) | 12.9285 µs/tick (0.012928 ms) | ≤ 1 ms | OK |
| `validar_optica(luz_01)` (autoría) | 34.99 µs (0.0350 ms) | < 10 ms | OK |
| rotar + re-trazado (espejos_01) | 22.2500 µs/tick (0.022250 ms) | ≤ 1 ms | OK |
| rotar + re-trazado (espejos_02) | 12.5980 µs/tick (0.012598 ms) | ≤ 1 ms | OK |
| `validar_espejos(espejos_01)` (autoría) | 51.03 µs (0.0510 ms) | < 10 ms | OK |

Los valores en µs varían entre corridas (dependen de la máquina); lo que sostiene el veredicto es el
**orden de magnitud**: el tick queda ~2 órdenes por debajo del umbral de 1 ms.

## 5. Playtests externos

Pendientes de ejecución con personas (instrumento: telemetría `PuzzleTimer`). Sin datos aún; no se
declaran resultados. El plan por familia está en `06-Plan-Testings.md` §2.

## 6. Regresión

Las 8 suites de M24 corren en verde (tabla §1). El gate `test_regresion_templos.gd` las corre como
subprocesos y exige, por suite, `EXIT 0` + 0 `SCRIPT ERROR` + checks ≥ su piso; total MEDIDO **362**
== piso total **362** (51 checks, 0 fallos, EXIT 0 ×3). No se modificó ningún archivo de otro módulo.

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — Log 1431 (iter. 4).
