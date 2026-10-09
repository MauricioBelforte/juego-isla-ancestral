# Log 1504 - M87 Localizacion - Iter. 8 - Auditor: prefijos dinamicos de traducir_clave

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-09 00:22:35 (GMT-3)
**Modulo:** M87 Localizacion
**Encargo:** mensaje del director 103 (2026-10-08 23:38) - diagnosticar y reparar los 2 fallos de `test_validador_po_m87.gd`

## 1. Objetivo

El director acepto el LOTE 2 (23 suites propias) y pidio investigar el bug de M87 que yo mismo
habia reportado como deriva de contenido/localizacion: los 2 fallos PRE-EXISTENTES de
`test_validador_po_m87.gd`.

1. `auditor real: 0 claves de PRODUCCION ausentes -> ["items."]`
2. `auditor real: veredicto OK`

Meta del encargo: suite **82/82 checks, 0 fallos, rc=0**. Sin tocar la instrumentacion de 3 capas
(ya auditada y aceptada). Sin commit/push. Si el bug fuera de otro modulo: reportar, no arreglar.

## 2. Reproduccion (estado inicial, MEDIDO)

```
godot --headless --path game/isla-ancestral --script res://scripts/localization/test_validador_po_m87.gd
EXIT=1 | "=== Resumen M87: 82 checks, 2 fallos ===" | 0 SCRIPT ERROR
```

Informe del auditor (extracto literal):

```
FALLO: auditor real: 0 claves de PRODUCCION ausentes -> ["items."]
FALLO: auditor real: veredicto OK
-- AuditorClaves: 931 archivo(s), 86 clave(s) usadas, 225 en catalogo
USADAS EN CODIGO PERO AUSENTES DEL CATALOGO (1):
  - items.  [inventario_iter4.gd]
...
Prefijos dinamicos detectados (1):
  - DIARY.CAT_*
RESULTADO: CLAVES SIN TRADUCCION
```

## 3. Causa raiz (MEDIDA)

No es una clave que falte del catalogo: **`items.` es un PREFIJO construido en runtime**.

- Uso real: `game/isla-ancestral/scripts/inventario/inventario_iter4.gd:283`

  ```
  var s: String = String(l_mgr.traducir_clave("items." + item_id + ".name"))
  ```

  Pertenece al helper `nombre_localizado(item_id, fallback)` (M14-Inventario, RF K12): nombre
  localizado **CON FALLBACK** - si la clave no existe devuelve el fallback, nunca muestra la clave
  cruda.

- El auditor SI ve la llamada (`RE_TRAD` = `traducir_clave\s*\(\s*"([^"]+)"` registra `items.`
  como clave LITERAL usada) pero NO la clasifica como prefijo dinamico: `RE_DINAMICA` solo cubria
  la forma de `_t`.
- Prueba de la asimetria, en la MISMA corrida: `DIARY.CAT_` (usado como `_t("DIARY.CAT_" + cat)`
  en `diary_layer.gd`) SI se reconoce -> `Prefijos dinamicos detectados (1): DIARY.CAT_*`.
  `items.` (mismo patron, otra funcion de traduccion) NO.
- Al no estar en `dinamicas`, `_cubierta("items.", dinamicas)` da `false` y `_finalizar` lo mete en
  `usadas_sin_clave` -> `ok = false` -> los 2 checks fallan.

**DESCARTADO (medido):** la clave NO existe en el catalogo porque nunca fue una clave completa:

```
grep -c '^msgid "items\.'  game/isla-ancestral/locales/es.po  -> 0
grep -c '^msgid "ITEMS\.'  game/isla-ancestral/locales/es.po  -> 3
   (ITEMS.MADERA, ITEMS.MADERA_DESC, ITEMS.SE_OFRECEN)
```

Es un esquema `items.<id>.name` que no existe en el catalogo; el codigo lo trata como OPCIONAL
(fallback explicito). Agregar la clave seria inventar datos y ademas no aplica: es un prefijo, no
una clave.

**CONCLUSION:** falso positivo del AUDITOR (M87, mio). Misma familia que el punto ciego del
Log 1015 (el auditor veia `open_confirm` pero no que la clave iba como argumento y no por `_t()`).

## 4. Reparacion (un solo archivo, M87)

`game/isla-ancestral/scripts/localization/auditor_claves.gd`

- `const RE_DINAMICA`:

  ```
  antes:  "_t\\s*\\(\\s*\"([^\"]*)\"\\s*\\+"
  ahora:  "(?:traducir_clave|_t)\\s*\\(\\s*\"([^\"]*)\"\\s*\\+"
  ```

- Comentarios de cabecera y de la constante actualizados (iter. 8).
- NO se toco la suite (instrumentacion de 3 capas intacta).
- NO se toco M14 ni el catalogo.

## 5. Verificacion (MEDIDA)

- Suite objetivo: `EXIT=0 | "82 checks, 0 fallos" | 0 SCRIPT ERROR` (x3 corridas identicas).
- Informe del auditor tras el fix:

  ```
  USADAS EN CODIGO PERO AUSENTES DEL CATALOGO:  (seccion ausente = 0 items)
  Prefijos dinamicos detectados (2):
    - DIARY.CAT_*
    - items.*
  RESULTADO: OK
  ```

- Regresiones de localizacion (todas EXIT 0, 0 fallos, 0 SCRIPT ERROR):

  ```
  test_localization       23/0
  test_localizacion_iter2 21/0
  test_localizacion_iter3 12/0
  test_localizacion_iter4 25/0
  test_localizacion_iter6 82/0
  ```

- Parseo: `--check-only` sobre `auditor_claves.gd` -> EXIT 0, 0 Parse/Compile Error.
- Bytes: `auditor_claves.gd` LF puro (crlf=0, lf_solo=236), `bom=False`, `fffd=0`.

## 6. Anti-falso-verde (sonda DIRIGIDA)

Sonda scratch (gitignored: `game/isla-ancestral/_wb_m87.tmp/`, borrada al cerrar) que compara el
auditor ARREGLADO contra una copia PRE-FIX de `HEAD` (`auditor_pre.gd`, sin `class_name`):

```
=== Resumen PROBE M87: 8 checks, 0 fallos ===
```

Discrimina en las dos direcciones:

- **FIX:** `traducir_clave("PREFIJO." + id + ".name")` -> `dinamicas` tiene `PREFIJO.` y NO aparece
  en `usadas_sin_clave`.
- **FIX:** `_t("OTROPREF." + id)` -> sigue detectandose como dinamico (no-regresion).
- **FIX:** `traducir_clave("FALTA.LITERAL")` y `_t("HUD.FANTASMA")` -> SIGUEN reportandose ausentes
  (el fix NO apaga el detector).
- **PRE (rojo):** el MISMO fixture de prefijo SI se reportaba en `usadas_sin_clave` y NO en
  `dinamicas` -> reproduce el bug en aislamiento. Si alguien revierte el fix, la sonda pasa a rojo.

## 7. Hallazgos reportados (NO arreglados, fuera de alcance)

- **H1 (menor):** el auditor se AUTO-ESCANEA (vive bajo `res://scripts`) -> un COMENTARIO que
  contenga el patron literal de llamada inventa un prefijo fantasma. Medido: mi primer comentario
  genero `Prefijos dinamicos detectados (3): ...* | DIARY.CAT_* | items.*`. Se reescribieron los
  comentarios para no matchear; queda documentado en el propio archivo. `validate_diary.gd:186/190`
  tiene el mismo patron en comentarios, hoy inofensivo porque `DIARY.CAT_` es genuino.
- **H2 (latente, no bloqueante):** `UiI18n.traducir` / `traducir_param` / `meta_texto` (14 claves,
  TODAS presentes en el catalogo) NO son vistos por el auditor -> esas claves figuran como "sin uso
  literal" en `claves_sin_uso`. Hoy es ruido, no un falso "ausente"; pero una clave usada SOLO por
  `UiI18n` y ausente del catalogo seria invisible (falso negativo, familia BUG-1015). No se toco: no
  lo pide el encargo y cambiaria el conteo de `claves_sin_uso`.
- **H3 (M14, no mio):** `nombre_localizado()` (`inventario_iter4.gd:276`) NO se llama desde ningun
  lado (grep: solo su definicion) y el esquema `items.<id>.name` no existe en el catalogo -> siempre
  devolveria el fallback. Es de M14-Inventario; se reporta, no se toca.

## 8. Pool / numeracion

- **Log 1504** (pool GLOBAL, head 1504 -> 1505). Colisiones AJENAS **1290** y **1468** reportadas,
  no tocadas.
- **Mensaje 104** (pool canal DeepSeek, head 104 -> 105).
- NO se commiteo el pool (regla dura).

## 9. Estado

- **SIN commit / SIN push** (el director centraliza; msg 103).
- No se toco: `quality.yml`, `CHECKLIST-GLOBAL.md`, `interaction_manager.gd`,
  `service_registry.gd`, `bootstrap.gd`, `main_island.gd`, ni el `05-Checklist` de M87/M14.
- **Pendiente:** autorizacion del director para (a) commit del fix, (b) decidir H2/H3, (c) si quiere
  una asercion de regresion PERMANENTE en la suite (subiria el conteo 82 -> 83+, hoy no pedido).
