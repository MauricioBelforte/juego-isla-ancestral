# Log 2064 - M88/M87 - Cobertura de glifos del catalogo i18n (i18n b3)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-21 04:17 (GMT-3)
**Rama:** 1 (mensaje 341 del director: item 46 ACEPTADO, "segui COLA V3")
**Item de la COLA V3:** Bloque E, item 48 - i18n b3: migracion de fuentes tipograficas si faltan glifos (M88)

## Que se hizo

Se midio, por primera vez en el repo, si las fuentes REALES cubren los caracteres que
exigen los catalogos .po. Resultado: un glifo ausente en las 4 fuentes y DOS falsos
verdes en el detector que ya existia.

## Medicion previa (antes de escribir codigo)

- `locales/es.po` + `locales/en.po`: 275 entradas y 278 formas cada uno (548 con texto).
- Codepoints requeridos por el texto mostrable: 79 (74 en es.po, 69 en en.po, union).
- No-ASCII por BYTES del archivo: 16. En el TEXTO mostrable: 14. La diferencia es
  U+2500, que solo vive en las lineas de comentario `# ----`.
- Fuentes en `assets/fonts`: 4 .ttf reales (magic 00010000). Las 4 cubren 78 de 79
  codepoints. El UNICO ausente es U+2192 (flecha derecha).
- U+2192 lo usan 31 claves del catalogo (`M68.SIGN.*`, `M68.ROUTE.*`; la misma clave
  existe en los 2 idiomas) y 3 sitios de produccion: crafting_ui.gd:209,
  diary_layer.gd:634, transport_localizer.gd:327 y :400.

## Falso verde 1: el detector por ANCHO es ciego

El bloque B de `test_fuentes_reales_m88.gd` decidia "falta el glifo" con
`get_string_size(ch).x <= 0.0`. Un glifo ausente se dibuja como `.notdef` y su avance NO
es cero. Medido: U+2192 da 14.0 px en las 3 fuentes de produccion con
`has_char() == false`.

Prueba comparada con el MISMO input (`TEXTO_ESPECIAL` + U+2192):

| Detector | Resultado medido | Veredicto |
|---|---|---|
| por ancho (viejo) | 43 checks, 0 fallos, EXIT 0 | FALSO VERDE |
| por has_char (nuevo) | 43 checks, 4 fallos, EXIT 1, faltan: ["->"] | correcto |

Las 4 fuentes fallan con el metodo nuevo; el viejo las daba por buenas.

## Falso verde 2: una asercion infalsificable

`test_fuentes_reales_m88.gd:206` tenia `_check("ids con tiene_archivo=true tienen
archivo", true, ...)`: no puede fallar nunca (trampa 85). Se reemplazo por el contrato en
la OTRA direccion, que si discrimina: "ningun id declara tiene_archivo=false teniendo el
.ttf en disco". Sonda roja: se copio Nunito-Regular.ttf como
`assets/fonts/museo_moderno.ttf` -> `[FAIL] ... mienten: ["museo_moderno"]`, 48 checks,
1 fallo, EXIT 1; archivo borrado y suite re-medida verde.

## Artefactos NUEVOS

| Archivo | Bytes | Rol |
|---|---|---|
| `game/isla-ancestral/scripts/fonts/auditar_glifos.gd` | 8912 | API pura: parser .po (entradas, no bytes) + cobertura por `Font.has_char()` + tabla de sustitutos + informe |
| `game/isla-ancestral/scripts/fonts/test_glifos_i18n_m88.gd` | 9869 | Suite headless, 6 bloques, 50 checks |
| `game/isla-ancestral/data/fonts/glifos_sustitutos.json` | 1192 | Tabla de sustitucion como DATO (U+2192 -> U+00BB). ASCII puro, sin cablear |

Todos: UTF-8 sin BOM, LF (coincide con `git ls-files --eol` de los vecinos, attr eol=lf),
0 U+FFFD, 0 CR.

## Suite nueva: 50 checks / 0 fallos / EXIT 0 x3

- A (10 checks): parser. 275 entradas x2, 278 formas x2, 79 codepoints, U+2500 NO cuenta
  (solo comentario), 31 claves con flecha, la flecha esta en los 2 .po, sin controles,
  548 entradas con texto.
- B (13): las 4 fuentes cargan, cubren 78 de 79, el unico ausente es U+2192, el hueco es
  global (ninguna lo tiene), el veredicto del auditor es ROJO.
- C (8): control NEGATIVO del metodo viejo (has_char false + ancho 14.0 px en las 3
  fuentes de produccion = ciego) + control POSITIVO (U+00BB tiene glifo y mide 8.0 px).
- D (6): la tabla declara U+00BB, no queda ningun faltante sin sustituto, las 3 fuentes
  del tema dibujan el sustituto.
- E (8): los 3 sitios de produccion existen y emiten la flecha en un literal.
- F (3): el informe nombra U+2192, trae veredicto y lista las 4 fuentes.
- Piso `CHECKS_MINIMOS = 50` MEDIDO en verde (3 corridas identicas).

Guardian probado EN ROJO (3 sondas sobre copias, borradas despues):

1. `_fin("B")` suprimido -> `[FAIL] el bloque B NO se ejecuto`, 50 checks, 1 fallo, EXIT 1.
2. Piso a 99 -> `[FAIL] solo 50 checks ejecutados (minimo 99)`, EXIT 1.
3. Aborto de RUNTIME dentro del bloque A (Array -> Dictionary via intermedio `Variant`) ->
   `[FAIL] el bloque A NO se ejecuto` + `[FAIL] solo 39 checks`, 39 checks, 2 fallos,
   EXIT 1. (El primer intento con asignacion directa fue Parse Error: no sirve como sonda.)

## Regresiones (0 fallos en todas)

M87/i18n: validador_po 87, test_localization 23, iter2 21, iter3 12, iter4 25, iter6 82,
catalogo_exhaustivo 36, placeholders_plurales 46 = 332 checks.
M68: 177 + 199 + 108 = 484 checks.
Fuentes M88: test_fonts_m88 11, binarias_bug042 22, fuentes_reales 43, glifos 50 = 126.
Todas EXIT 0 y 0 SCRIPT ERROR.

## Hallazgos que NO son mios (reportados, no tocados)

- El catalogo `data/fonts/fonts.json` declara 4 fuentes ABSTRACTAS (museo_moderno,
  texto_cozy, script_isla, mono_debug) con `tiene_archivo: false` y `cobertura` declarada,
  mientras las 4 fuentes REALES de disco (Nunito x3 + FredokaOne) no figuran en el
  catalogo: la correspondencia catalogo <-> archivo no existe. La suite vieja lo fijaba
  con un `_check(true, ...)`.
- `Nunito-Variable.ttf` (276932 B) existe y solo lo usa una suite de M87; el tema
  (`theme_ux.gd`) usa las otras 3.

## Decisiones pendientes del director (no aplicadas)

1. Contenido: sustituir U+2192 por U+00BB en 62 entradas del .po (medido: las 3 fuentes
   del tema dibujan U+00BB), o por U+003E, o adquirir una fuente con flechas (licencia).
   La tabla de datos ya trae la propuesta.
2. Cableado de la tabla: en el punto de traduccion (afecta texto del jugador) o en los 3
   sitios de produccion. Hoy la tabla NO tiene consumidores: es dato + funcion pura.
3. Cablear `test_glifos_i18n_m88.gd` en `quality.yml` (archivo del director).
4. Flip del item 48: propuesto como parcial (codigo + suite + medicion), NO aplicado.

## Limites declarados

- 0 commits / 0 push / 0 flips / 0 auto-sellos 21.8.
- La mitigacion NO esta activa: el jugador sigue viendo la caja `.notdef` hasta que se
  decida el punto 1 o 2.
- Documentado en `DOCUMENTACION/88-Fuentes-Tipograficas/plan-actual/04-Codigo.md`
  (seccion nueva; 23384 B finales, LF preservado, sin BOM).

## Numeracion

- Log: 2064 (pool de Logs; cabeza medida justo antes = 2064).
- Canal: 341 era el mensaje del director; el reporte de esta vuelta toma 342
  (cabeza del pool de canal medida antes de reservar = 342 = ultimo 341 + 1).
