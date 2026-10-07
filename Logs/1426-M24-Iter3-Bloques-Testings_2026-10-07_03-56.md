# Log 1426 - M24: iter. 3 - familia bloques (push/pull) + plan/resultados de testings

**Fecha:** 2026-10-07 03:56 (local -0300; UTC 2026-10-07 06:56)
**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Modulo:** M24-Templos-Y-Puzzles
**Plan:** aprobado por el director (canal DeepSeek/72, mensaje 72). Alcance = Frente A (familia bloques) + Frente B (testings/docs); 14 cierres.
**Mensaje de canal:** 73 (deepseek-a-atria)

## 1. Frente A - familia bloques (items 84-88)

NUEVOS:
- `game/isla-ancestral/scripts/templos/puzzle_bloques.gd` - `PuzzleBloques` (RefCounted): capa
  espacial push/pull sobre un `PuzzleRoom` existente. `cargar` / `desde_def`,
  `empujar(pieza_id, dx, dy)`, `eje_de`, `posicion`, `ranura_de`, `ranuras_ocupadas`,
  `puente_activo`, `validar_espacial`.
  - item 84: 1 eje por pieza ("eje" en x|y); paso no ortogonal o de eje no permitido -> rechazado.
  - item 85: "ranura" por pieza; pos == ranura -> emisor ON; todas las ranuras -> S == T.
  - item 86: receptor = puente desplegable (`puente_bloques`).
  - item 87: "limites" de sala (salir_de_grilla / salas_adyacentes en false); rechaza salir de la
    grilla y ocupar una celda ocupada por otra pieza.
- `game/isla-ancestral/data/templos/puzzles/bloques/bloques_01.json` - 1 bloque, eje x, 1 ranura, grilla 4x1.
- `game/isla-ancestral/data/templos/puzzles/bloques/bloques_02.json` - 2 bloques (eje x + eje y), 2 ranuras, grilla 4x4, regla AND -> puente.
- `game/isla-ancestral/scripts/templos/test_puzzle_bloques.gd` - suite headless (bloques A-F).

NOTA (honestidad): el catalogo `templo_layout_diseno.json` NO tiene ningun puzzle `tipo: "bloques"`,
asi que la familia se DISENA desde el esquema (los items 84-88 son "Definir", no "Migrar"). No se
inventaron datos legacy.

## 2. Frente B - testings y documentacion (items 168-176)

NUEVOS en `DOCUMENTACION/24-Templos-Y-Puzzles/plan-actual/`:
- `06-Plan-Testings.md` (items 168-172): unitarias del framework, playtests externos por familia,
  edge cases, rendimiento (<= 1 ms por tick), criterio de exito.
- `07-Resultados-Testings.md` (item 173): cifras MEDIDAS de las 6 suites + la sonda roja + rendimiento.

MODIFICADOS:
- `02-Analisis.md` (decision: capa espacial aparte) y `03-Diseno.md` (familia bloques + esquema de datos)
  [item 174].
- `04-Codigo.md` (mapa de codigo de la familia bloques) [item 174].
- `05-Checklist.md` (14 flips + Totales) [item 175].
- Este Log en Logs/ con formato NN-DESCRIPCION_FECHA [item 176].

## 3. Anti-falso-verde

- `test_puzzle_bloques.gd`: **64 checks, 0 fallos, EXIT 0 x3**, 0 SCRIPT ERROR. Piso
  `CHECKS_MINIMOS=64` **MEDIDO** en verde (no estimado). Bloques nombrados A-F + `_summary()` en
  `call_deferred` que NOMBRA los bloques faltantes.
- Guardian probado EN ROJO por 2 inyecciones:
  - quitar la llamada al bloque E (dejando `_fin`) -> `40 checks, 1 fallo` / EXIT 1 (lo atrapa el piso);
  - quitar la llamada Y el `_fin` -> `40 checks, 2 fallos` / EXIT 1
    (`[FALLO] el bloque E NO se ejecuto` + piso).
  Ambas revertidas; la suite quedo 64/0 EXIT 0.
- SONDA ROJA en vivo (condicion 1 del director): inyectado `"eje": "z"` en el JSON REAL
  `bloques_01.json` -> `64 checks, 12 fallos` / **EXIT 1**, con fallos nombrados (validar_espacial,
  eje de bloque_a, control positivo + 9 de simulacion). JSON restaurado **byte-exacto**: sha256
  antes == despues == `fdf06cbc45cd5c02005790842c4572aef0e3b3e25aa023e1db134ff67c99b1b9`.
  Re-corrida tras restaurar: 64/0 EXIT 0.
- Sondas in-memory permanentes (bloque D): eje invalido, limite abierto y ambiguedad (2 caminos OR).

## 4. Regresion (todas EXIT 0, 0 SCRIPT ERROR)

- test_puzzle_datos 42/0 | test_puzzle_multilateral 38/0 | test_puzzles 0 fallos |
  test_templo_m26 92/0 | test_templo_headless 4/0.

## 5. Rendimiento MEDIDO (item 171)

- tick de sala (bloques_01): 2.0020 us/tick (0.002002 ms) - umbral <= 1 ms.
- tick de sala (bloques_02): 2.1135 us/tick (0.002114 ms).
- `validar_def(bloques_02, n=2)`: 22.61 us (0.0226 ms) - herramienta de autoria, no tick.

## 6. Conteo

- 05-Checklist M24: **57 [x] / 1 [?] / 70 [ ] = 128** (14 flips: 84, 85, 86, 87, 88, 168, 169, 170,
  171, 172, 173, 174, 175, 176).
- `verificar_checklist.py`: unico drift del modulo = el esperado (GLOBAL dice 43/128, el checklist
  57/128) -> lo resuelve el flip del director. Las otras 18 alertas son preexistentes de otros modulos.

## 7. Bytes / EOL

- Nada con BOM/NUL/FFFD. EOL por archivo preservado: .gd y .json LF; 02-Analisis LF; 03-Diseno LF;
  04-Codigo CRLF=127; 05-Checklist CRLF=260 + LF=3 (los mismos 3 LF preexistentes); 06/07 LF.

## 8. Pool

- Log 1426 (pool GLOBAL; head previo 1426 -> 1427).
- Canal 73 (pool DeepSeek; head previo 73 -> 74).

## 9. Lo que NO se toco

`quality.yml` (sigue sin el OK de s2), `CHECKLIST-GLOBAL.md` (el flip 43->57 lo hace el director),
`interaction_manager.gd` / `service_registry.gd` / `bootstrap.gd`, el `[?]` 144 (EditorPlugin),
`main_island.gd` ni escenas de templo (mimo esta en M163 seccion C), y el worktree ajeno.

## 10. Pendiente

- Flip de la fila 24 del GLOBAL a 57/128 (director).
- OK de s2 para cablear las suites en `quality.yml` (aditivo).
- Iter. 4 (familias luz/espejos/agua/hielo/gravedad/sonido/pistas) - alcance a proponer.
