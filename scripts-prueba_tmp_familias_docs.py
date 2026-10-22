# Iter. 9 M23: actualiza 04-Codigo, 05-Checklist, 06-Plan-Testings y
# 07-Resultados-Testings. Los 4 archivos son LF sin BOM: se opera por str con
# anchors unicos (assert count==1) y se escribe por bytes.
import io

D = 'DOCUMENTACION/23-Historias-Secundarias/plan-actual/'

def editar(path, pares, append=None):
    t = open(path, 'rb').read().decode('utf-8')
    for a, b in pares:
        assert t.count(a) == 1, 'anchor no unica en %s: %r' % (path, a[:70])
        t = t.replace(a, b, 1)
    if append:
        t = t.rstrip('\n') + '\n' + append
    open(path, 'wb').write(t.encode('utf-8'))
    raw = open(path, 'rb').read()
    assert raw[:3] != b'\xef\xbb\xbf' and raw.count(b'\r\n') == 0
    print('OK', path, len(raw), 'bytes')

# ---------------- 05-Checklist ----------------
p5 = D + '05-Checklist.md'
editar(p5, [
    # 1) header Estado: prepend iter. 9
    ('> **Estado:** \U0001F7E1 Liberado — iter. 8 (2026-10-22, Log 2127):',
     '> **Estado:** \U0001F7E1 Liberado — iter. 9 (2026-10-22, Log 2129): cluster Familias del 03-Diseno (3 cadenas nuevas: molinera, pescadores, guardas — NPC y objetos REALES de data/villagers/ y data/items/) + flips de los 3 items de familias; suite 258 checks/0 fallos x3 y guardian probado EN ROJO por inyeccion de runtime sobre el bloque N; 61/105 [x]; 42 [ ] de contenido/duenos externos + 2 [?]. iter. 8 (2026-10-22, Log 2127):'),
    # 2) clasificacion: conteo + nota iter 9
    ('Conteo por prefijo de línea: 58 [x] / 45 [ ] / 2 [?] = 105 (iter. 3, Log 2083:',
     'Conteo por prefijo de línea: 61 [x] / 42 [ ] / 2 [?] = 105 (iter. 9, Log 2129: +3 [x] cluster Familias (molinera, pescadores, guardas con NPC y objetos REALES, suite 258 checks x3 + guardian en rojo sobre el bloque N); iter. 3, Log 2083:'),
    # 3) flips de los 3 items de familias
    ('- [ ] Crear la historia de la familia molinera [M]',
     '- [x] Crear la historia de la familia molinera [M] — cadena-molinera en data/historias/secundarias.json (4 pasos: hablar mateo_mapache / explorar molino / entregar OBJ-REL-003 / puzzle piedras-de-molienda; consecuencia molienda_familiar_restaurada en WorldState M21; testeada end-to-end en test_historias.gd bloque N). NPC REAL mateo_mapache (granjero, data/villagers/) y objeto REAL OBJ-REL-003 «Reloj de arena» (data/items/, verificado por campo id). Log 2129.'),
    ('- [ ] Crear la historia de la familia pescadores [M]',
     '- [x] Crear la historia de la familia pescadores [M] — cadena-pescadores en data/historias/secundarias.json (4 pasos: hablar finneas_zorro / explorar muelle_viejo / entregar OBJ-HER-014 / puzzle nudo-del-abuelo; consecuencia red_del_abuelo_reparada en WorldState M21; testeada end-to-end en test_historias.gd bloque N). NPC REAL finneas_zorro (pescador, data/villagers/) y objeto REAL OBJ-HER-014 «Red de captura» (data/items/, verificado por campo id). Log 2129.'),
    ('- [ ] Crear la historia de la familia guardas [M]',
     '- [x] Crear la historia de la familia guardas [M] — cadena-guardas en data/historias/secundarias.json (4 pasos: hablar nico_gato / explorar bosque_nocturno / entregar OBJ-LUZ-011 / puzzle ronda-de-los-guardas; consecuencia vigilia_de_los_guardas en WorldState M21; testeada end-to-end en test_historias.gd bloque N). NPC REAL nico_gato (guardabosques, data/villagers/) y objeto REAL OBJ-LUZ-011 «Candil» (data/items/, verificado por campo id). Log 2129.'),
    # 4) linea Total: numeros + nota iter 9 (y regularizacion de iters 7/8 no volcadas)
    ('**Total:** 55/105 [x] · 48/105 [ ] · 2 [?] (iter. 2 Step-5-WorkBuddy 2026-10-21, Log 2082:',
     '**Total:** 61/105 [x] · 42/105 [ ] · 2 [?] (iter. 2 Step-5-WorkBuddy 2026-10-21, Log 2082:'),
    ('los 48 [ ] son contenido narrativo ausente o ítems con dueño externo M22/M24/M28/M32/M36/M37/M68).',
     'los 48 [ ] son contenido narrativo ausente o ítems con dueño externo M22/M24/M28/M32/M36/M37/M68; iter. 7 Step-5-WorkBuddy 2026-10-22, Log 2125: +1 [x] cluster Ruinas; iter. 8 Step-5-WorkBuddy 2026-10-22, Log 2127: +2 [x] cluster Objetos — ninguna de las dos se había volcado en esta línea, regularizado hoy contra el conteo por prefijo medido; iter. 9 Step-5-WorkBuddy 2026-10-22, Log 2129: +3 [x] cluster Familias (molinera, pescadores, guardas con NPC y objetos REALES, suite 258 checks x3 + guardián en rojo sobre el bloque N)).'),
    # 5) Totales del firmante
    ('**Totales:** 105 ítems · Completados: 58 · Pendientes: 45 · No resueltos: 2.',
     '**Totales:** 105 ítems · Completados: 61 · Pendientes: 42 · No resueltos: 2.'),
])

# ---------------- 04-Codigo ----------------
p4 = D + '04-Codigo.md'
editar(p4, [], append='''
## Iter. 9 — Historias de familias (Step-5-WorkBuddy, 2026-10-22, Log 2129)

Cluster **Familias** del 03-Diseno L35 (molinera, pescadores, guardas): 3 cadenas
nuevas en `data/historias/secundarias.json` (23 -> 26).

- `cadena-molinera` — NPC REAL `mateo_mapache` (granjero, `data/villagers/`), lugar
  `molino`, objeto REAL `OBJ-REL-003` «Reloj de arena» (`data/items/`, verificado por
  campo id dentro del .tres — `item_database.gd` indexa por ese id), puzzle
  `piedras-de-molienda`. Consecuencia pelada `molienda_familiar_restaurada`.
- `cadena-pescadores` — NPC REAL `finneas_zorro` (pescador), lugar `muelle_viejo`,
  objeto REAL `OBJ-HER-014` «Red de captura», puzzle `nudo-del-abuelo`. Consecuencia
  pelada `red_del_abuelo_reparada` (distinta de `red_pescador_reparada` de iter. 5).
- `cadena-guardas` — NPC REAL `nico_gato` (guardabosques), lugar `bosque_nocturno`,
  objeto REAL `OBJ-LUZ-011` «Candil», puzzle `ronda-de-los-guardas`. Consecuencia
  pelada `vigilia_de_los_guardas` (distinta de `patrulla_nocturna` de iter. 8).

Anti-repetición: 3 consecuencias peladas nuevas sin colisión con las 24 previas
(23 en datos + `biblioteca_iluminada` de ejemplos) y 3 capítulos `capitulo-*` de diario
nuevos sin colisión; contextos narrativos >= 10 caracteres, 4 pasos cada una
(hablar/explorar/entregar/puzzle), validados por el validador del servicio.

- Suite `scripts/historias/test_historias.gd`: bloque N `_test_familias()` (31 checks:
  6 carga/fuente + 2 unicidad de flags + 1 diarios + 7x3 end-to-end + 1 puente diario)
  al FINAL de `_run()`. Piso 227 -> **258 checks / 0 fallos / EXIT 0 x3** (binario real).
  Conteos de los bloques A e I actualizados 24/23 -> 27/26 (medidos; la 1a corrida dio
  3 fallos de conteo, corregidos). Guardián EN ROJO por inyección de runtime
  (Variant con Array -> Dictionary tipado) sobre el bloque N: EXIT 1, «el bloque N NO
  se ejecuto» + «solo 228 checks ejecutados (minimo 258)»; sonda borrada, sha256 del
  original verificado.
- Regresiones medidas tras la tanda: M22 `test_historia.gd` 41/0, M71
  `test_progresion.gd` 83/0 + `test_flujo_xp_recompensa_m71_hy3.gd` 37/0, M59
  `test_rotate_m59.gd` 43/0 (9 bloques) + `test_backup_rotate_return.gd` 4/0 +
  `test_backup_rotations.gd` 7/0 y M55 `test_diario.gd` 0 fallos. Todas EXIT 0 con el
  binario real, 0 SCRIPT ERROR.
- Hallazgo (dueno M55, no tocado): el puente M23->M55 degrada en silencio tambien para
  las 3 nuevas (`mision_cadena-guardas` ausente del catalogo de M55; mismo patron que
  cadena-biblioteca en H, cadena-jardines en K, cadena-puente en L y cadena-brujula
  en M).
- Flips del 05-Checklist con cita: «Crear la historia de la familia molinera»,
  «...pescadores» y «...guardas» [ ] -> [x] (L44-L46). M23 = 61 [x] / 42 [ ] / 2 [?]
  = 105 (verificado por prefijo de línea). Las DOS líneas de totales estaban
  desincronizadas (L170 mentía 55/48/2: los flips de iter. 7 y iter. 8 no se habían
  volcado): ambas sincronizadas a 61/42/2.
''')

# ---------------- 06-Plan-Testings ----------------
p6 = D + '06-Plan-Testings.md'
editar(p6, [
    ('### Bloques (13)', '### Bloques (14)'),
    ('| M | Las 6 historias de objetos legendarios (iter. 8): carga, fuente del principal, unicidad de las 6 consecuencias nuevas vs las 18 preexistentes, 6 capitulos de diario unicos y corrida end-to-end de las 6 (npc REAL de `data/villagers/`; `gemstone`, `OBJ-SEC-004`, `OBJ-SEC-001` y `OBJ-LUZ-005` REALES de `data/items/`, `carta_sellada` y `brujula_desorientada` narrativos; puzzle) con `ws_has()` de `relicto_devuelto` / `gema_devuelta` / `receta_heredada` / `llave_encontrada` / `patrulla_nocturna` / `brujula_calibrada` | M14, M21, M55 |',
     '| M | Las 6 historias de objetos legendarios (iter. 8): carga, fuente del principal, unicidad de las 6 consecuencias nuevas vs las 18 preexistentes, 6 capitulos de diario unicos y corrida end-to-end de las 6 (npc REAL de `data/villagers/`; `gemstone`, `OBJ-SEC-004`, `OBJ-SEC-001` y `OBJ-LUZ-005` REALES de `data/items/`, `carta_sellada` y `brujula_desorientada` narrativos; puzzle) con `ws_has()` de `relicto_devuelto` / `gema_devuelta` / `receta_heredada` / `llave_encontrada` / `patrulla_nocturna` / `brujula_calibrada` | M14, M21, M55 |\n| N | Las 3 historias de familias (iter. 9): carga, fuente del principal, unicidad de las 3 consecuencias nuevas vs las 24 preexistentes, 3 capitulos de diario unicos y corrida end-to-end de las 3 (npc REAL de `data/villagers/`; `OBJ-REL-003`, `OBJ-HER-014` y `OBJ-LUZ-011` REALES de `data/items/`; puzzle) con `ws_has()` de `molienda_familiar_restaurada` / `red_del_abuelo_reparada` / `vigilia_de_los_guardas` | M14, M21, M55 |'),
    ('3. `CHECKS_MINIMOS` = **227** desde la iter. 8 (MEDIDO en verde el 2026-10-22 con 13\n   bloques; la cadena fue 40 con 7 -> 59 con 8 -> 70 con 9 -> 98 con 10 -> 129 con 11\n   -> 169 con 12 -> 227 con 13). No estimado.',
     '3. `CHECKS_MINIMOS` = **258** desde la iter. 9 (MEDIDO en verde el 2026-10-22 con 14\n   bloques; la cadena fue 40 con 7 -> 59 con 8 -> 70 con 9 -> 98 con 10 -> 129 con 11\n   -> 169 con 12 -> 227 con 13 -> 258 con 14). No estimado.'),
    ('5. Guardián probado EN ROJO por inyección de runtime, ocho veces:',
     '5. Guardián probado EN ROJO por inyección de runtime, nueve veces:'),
    ('   - iter. 8 (abort de runtime al inicio del bloque M, asignación tipada\n     `Variant` -> `Dictionary` sobre `cadenas_count()`): EXIT 1, «el bloque M NO se\n     ejecuto» + «solo 170 checks (mínimo 227)», 2 fallos.',
     '   - iter. 8 (abort de runtime al inicio del bloque M, asignación tipada\n     `Variant` -> `Dictionary` sobre `cadenas_count()`): EXIT 1, «el bloque M NO se\n     ejecuto» + «solo 170 checks (mínimo 227)», 2 fallos.\n   - iter. 9 (abort de runtime al inicio del bloque N, asignación tipada\n     `Variant` con `Array` -> `Dictionary`): EXIT 1, «el bloque N NO se ejecuto» +\n     «solo 228 checks (mínimo 258)», 2 fallos.'),
])

# ---------------- 07-Resultados-Testings ----------------
p7 = D + '07-Resultados-Testings.md'
editar(p7, [
    ('''Guardián EN ROJO por inyección de runtime sobre el bloque M (asignación tipada
`Variant` -> `Dictionary` sobre `cadenas_count()`): EXIT 1 con «el bloque M NO se
ejecuto» y «solo 170 checks (mínimo 227)», 2 fallos. Sonda borrada; sha256 del
original verificado; 0 sondas residuales.
''',
     '''Guardián EN ROJO por inyección de runtime sobre el bloque M (asignación tipada
`Variant` -> `Dictionary` sobre `cadenas_count()`): EXIT 1 con «el bloque M NO se
ejecuto» y «solo 170 checks (mínimo 227)», 2 fallos. Sonda borrada; sha256 del
original verificado; 0 sondas residuales.

### Iter. 9 (Log 2129) — 3 historias de familias + bloque N

| Corrida | Checks | Fallos | EXIT | SCRIPT ERROR |
|---|---|---|---|---|
| 1 | 258 | 0 | 0 | 0 |
| 2 | 258 | 0 | 0 | 0 |
| 3 | 258 | 0 | 0 | 0 |

Salida: `=== TEST M23 HISTORIAS: 0 fallo(s) (258 checks) ===`

Carga medida: catálogo vivo **27** (26 del principal + 1 de ejemplos). El bloque N corre
las 3 cadenas nuevas end-to-end (hablar con npc REAL / explorar lugar / entregar item
REAL / puzzle) y mide las consecuencias `molienda_familiar_restaurada`,
`red_del_abuelo_reparada` y `vigilia_de_los_guardas` aplicadas a WorldState (M21).

Asserts existentes actualizados por el contenido nuevo (A: merge 24 -> 27 y principal
23 -> 26; I: principal 23 -> 26, cargadas 24 -> 27).

Guardián EN ROJO por inyección de runtime sobre el bloque N (asignación tipada
`Variant` con `Array` -> `Dictionary`): EXIT 1 con «el bloque N NO se ejecuto» y «solo
228 checks (mínimo 258)», 2 fallos. Sonda borrada; sha256 del original verificado;
0 sondas residuales.
'''),
    ('''rojo OCHO veces (iter. 2; iter. 3; las dos de iter. 4 — aborto de runtime en el bloque
I y regresión de datos con prefijo re-inyectado; iter. 5 en el bloque J; iter. 6 en el
bloque K; iter. 7 en el bloque L; iter. 8 en el bloque M; todas EXIT 1 nombrando el
bloque o la clave). Estado actual: suite en **227 checks / 0 fallos / EXIT 0 x3**,
catálogo vivo 24 cadenas, y regresiones M22 (41/0) · M71 (83/0) · M59 (43/0 con 9
bloques, 4/0 en backup-rotate-return y 7/0 en backup-rotations) · M55 (0 fallos)
medidas el 2026-10-22 en la iter. 8.''',
     '''rojo NUEVE veces (iter. 2; iter. 3; las dos de iter. 4 — aborto de runtime en el bloque
I y regresión de datos con prefijo re-inyectado; iter. 5 en el bloque J; iter. 6 en el
bloque K; iter. 7 en el bloque L; iter. 8 en el bloque M; iter. 9 en el bloque N;
todas EXIT 1 nombrando el bloque o la clave). Estado actual: suite en **258 checks /
0 fallos / EXIT 0 x3**, catálogo vivo 27 cadenas, y regresiones M22 (41/0) · M71
(83/0 y 37/0 en flujo-XP) · M59 (43/0 con 9 bloques, 4/0 en backup-rotate-return y
7/0 en backup-rotations) · M55 (0 fallos) medidas el 2026-10-22 en las iters. 8 y 9.'''),
])

print('docs OK')
