# Log 2208 - M72 residuo: las 4 deudas medidas, 2 suites muertas resucitadas

- Modelo: DeepSeek-V4.1-Flash
- Plataforma: WorkBuddy
- Fecha: 2026-10-26 22:47
- Modulo: M72 (Sistema de Logros)
- Disparador: RAMA 1 - mensaje 421 de la directora agnes-3-flash: "Tu proximo riel:
  M72 residuo (los 4 hallazgos: test_logros.gd muerta / rf10 check muerto / 18 iconos
  a dir fantasma / LOGROS.* fuera de .po). Arrancalo." + orden de commit selectivo de
  la tanda M53 L210.
- Log: 2208 (reservado con `scripts/reservar_log.py --reservar`; cabeza del pool medida
  justo antes = 2208, ultimo log en disco = 2205 -> 2206 y 2207 fueron consumidos por
  otros agentes y NO tienen archivo todavia. No se renumero nada ajeno; el numero sale
  del pool por la herramienta, que es la via autoritativa del protocolo v3.)

## 0. Commit selectivo autorizado (punto 5 del msg 421)

Commit **3271665** por pathspec explicito (sin `-A`, sin `--amend`, sin push), 10 archivos:
las 3 capas de `scripts/ui/layers/` (diary/inventory/settings_audio), `test_m53_ratios.gd`,
`diag_arbol_m53.gd`, `04-Codigo.md` Iter. 25 de M53, `05-Checklist.md` de M53 (nota L210
que ella misma listo), `BACKLOG-MASTER.md`, Log 2205 y el mensaje 420.
Nota de honestidad: `05-Checklist.md` de M53 traia DOS cosas en el mismo archivo: mi nota
de evidencia de L210 y su sync de Totales (159/3/2/1). Se commitearon juntas porque ella
listo "nota L210" en el pathspec; yo no edite ese archivo.

## 1. Premisa medida antes de tocar nada

Las 4 deudas estaban declaradas en `04-Codigo.md` (M72) sin medicion propia. Se midieron
con el binario real, no con la nota:

| hallazgo | medicion de entrada |
|---|---|
| `test_logros.gd` muerta | `SCRIPT ERROR: Invalid assignment of property or key '_desbloqueados' with value of type 'Array' on a base object of type 'Node (achievement_service.gd)'` en L294, seguido de `=== TEST M72 LOGROS: 0 fallo(s) ===` y **EXIT 0** |
| `rf10` check muerto | `SCRIPT ERROR: Invalid access to property or key 'id' on a base object of type 'Dictionary'` en `_test_get_definicion` (L39), seguido de `OK=23 FALLOS=0` y **EXIT 0** |
| 18 iconos a dir fantasma | `data/logros/logros.json`: los 18 `icono` apuntan a `res://assets/ui/logros/*.png`; `assets/ui/` NO existe. En todo el repo hay 300 PNG y los 300 estan en `assets/2d/items_m159`; `assets/2d/ui` y `assets/2d/iconos` solo tienen `.gitkeep` |
| `LOGROS.*` fuera de `.po` | 36 claves (`nombre_i18n` + `descripcion_i18n` de 18 logros): 0 apariciones en `locales/es.po` y 0 en `locales/en.po` |

Causa raiz de las dos suites muertas, medida en el codigo: `achievement_service.gd:44`
declara `var _desbloqueados: Array[String] = []` y el test le asignaba un `Array` sin
tipar; `get_definicion()` devuelve `_logros.get(id, {})` (Dictionary VACIO, nunca `null`)
y el test hacia `d.id` sobre `{}` con un id que ademas no existe (`primer_sello` en vez de
`logro_primer_sello`). En GDScript un `SCRIPT ERROR` de runtime aborta SOLO la funcion
donde ocurre: el llamador sigue, el resumen se imprime igual y el proceso sale 0.

**Hallazgo colateral medido:** `test_logros.gd` esta cableado en `quality.yml:527`
(`godot --headless --script scripts/logros/test_logros.gd 2>&1`) y, como siempre salia 0,
el gate de M72-core era un **no-op** (familia trampa 81). Con el endurecimiento el gate
pasa a poder fallar. No se toco `quality.yml` (limite duro).

## 2. Fix 1 - `test_logros.gd`: 3 capas de guardian + el aborto

- `_checks` cuenta TODO check (no solo los fallos).
- `CHECKS_MINIMOS := 72`, **MEDIDO en verde** (el primer valor que escribi fue 74 por
  estimacion y el medido real fue 72: se corrigio antes de publicar la cifra).
- `BLOQUES` (20) + `_fin(bloque)` al FINAL del cuerpo de cada bloque.
- `_summary()` registrado con un `call_deferred` SEPARADO del de `_run()`, asi un aborto
  de `_run()` no impide que el resumen corra, nombre el bloque y salga != 0.
- Fix del aborto: `_ach._desbloqueados.clear()` + `.append("logro_primer_sello")` en vez
  de asignar un `Array` sin tipar (usa el array tipado REAL, sin cast fragil).
- **2 aserciones infalsificables eliminadas** (`_check(true, ...)`):
  - RN7 (toasts): el test original hacia `desbloquear("logro_primer_sello")` sobre un logro
    YA desbloqueado (devuelve false, no emite toast) y luego afirmaba `true`: vacio por
    partida doble. Ahora ejercita el guard REAL (`_emitir_toast`) y observa `_toast_buffer`
    en las dos direcciones: con `_toasts_disabled = true` el buffer NO crece, con `false`
    SI crece (control positivo).
  - RF7 (`panel_solicitado`): ahora conecta un Callable, emite y afirma que llego 1 vez con
    payload `"logros"`.
- Guarda nueva en `_test_ocultos()`: si `logro_secreto_guardian` no aparece en el listado,
  el bloque corria **0 checks** (falso verde estructural). Ahora eso es un fallo explicito.

Medicion: **72 checks / 0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR en las 3 corridas.

Guardian probado EN ROJO (2 modos, sonda restaurada byte-exacta):
- aborto de runtime inyectado en `_test_api_consulta_rf10` (intermedio `Variant` para que
  no lo cace el compilador): `[FAIL] bloques que NO se ejecutaron: ["api_rf10"]` +
  `[FAIL] solo 65 checks ejecutados (minimo 72)` + `65 checks, 2 fallo(s)` + **EXIT 1**.
- asercion falsa (18 -> 19 en `logros_count`): `72 checks, 1 fallo(s)` + **EXIT 1**.
- control restaurado: `72/0/EXIT 0`; sha256 `c22750f9ea4547ae` identico antes/despues.

## 3. Fix 2 - `test_logros_rf10_m72.gd`: id inexistente + contrato del API

- `_test_get_definicion` usaba `"primer_sello"` (no existe) y esperaba `null` para id
  desconocido (el API devuelve `{}`). Ahora: id real `logro_primer_sello` + contrato real
  medido (`{}` vacio) + 1 check de `get_estado` con el id real.
- 3 capas tambien aca: `_checks`, piso **27 MEDIDO**, `BLOQUES` (4) + `_fin`, `_reportar()`
  en `call_deferred` aparte.
- **Defecto de API encontrado y corregido (aditivo):** `_logros[id]` NO guardaba el campo
  `id` (el id era la clave del diccionario), mientras `_estado_de()` si lo agrega. O sea:
  `get_definicion(id)` devolvia una definicion que **no se identificaba a si misma** y
  `get_estado(id)` si. Se agrego `"id": id` en `_cargar_catalogo()`; ningun consumidor
  itera las claves de forma estricta (verificado: los unicos consumidores externos son
  `sfx_manager.gd` y `test_postgame.gd`, que usan la senal y `get_todos`).

Medicion: **27 checks / 0 fallos / EXIT 0 x3** (antes publicaba "OK=23" con 2 checks
muertos y EXIT 0). Guardian EN ROJO: aborto inyectado en `_test_get_todos` ->
`[FAIL] bloques ... ["todos"]` + `[FAIL] solo 9 checks (minimo 27)` + **EXIT 1**;
sha256 `f50c51967d6bbf4f` restaurado identico; control `27/0/EXIT 0`.

## 4. Fix 3 y 4 - iconos y claves i18n: de invisibles a MEDIDAS

No se invento arte ni se toco el `.po` ajeno (M88 esta en NO TOCAR). Lo que se cerro es la
parte que era mia: **la deuda ya no es invisible**.

`achievement_service.gd` suma 3 metodos:
- `iconos_ausentes() -> Array[String]`: ids cuyo `icono` declarado no existe en disco
  (`FileAccess.file_exists`).
- `claves_i18n_ausentes() -> Array[String]`: claves `nombre_i18n`/`descripcion_i18n` que no
  estan en `locales/es.po`.
- `_msgids_po(ruta) -> Dictionary`: parser de msgid del `.po` (una clave por linea).

`validar_catalogo()` imprime en cada arranque:
`[M72][DEUDA] 18 icono(s) declarados sin archivo en disco (arte: 18 PNG) y 36 clave(s)
i18n fuera de locales/es.po`. **NO** incrementan `problemas`: RF14 valida la FORMA del
catalogo (ids, categorias, condiciones, steam ids) y esto es dependencia externa (arte /
M88). Mezclarlos habria roto el contrato "0 problemas" que otras 3 suites afirman.

Suite nueva `scripts/logros/test_m72_deuda_assets.gd` (no fija cifras: **cruza**):
- Bloque A: para cada uno de los 18 logros, `(id en iconos_ausentes()) == (not
  FileAccess.file_exists(icono))` en las DOS direcciones. Invariante, no numero.
- Bloque B: cada clave reportada como ausente NO aparece como `msgid "..."` en el texto
  crudo del `.po` (camino independiente del parser) + clasificacion completa de las 36.
- Bloque C (guarda de CEGUERA): el parser debe leer > 50 msgid y reconocer una clave
  conocida (`MAIN_MENU.PLAY`). Un parser roto devuelve `{}` y entonces TODAS las claves
  parecen ausentes: el numero sube y parece correcto.
- Bloque D: `validar_catalogo()` sigue en 0 problemas (la deuda no contamina el contrato).

Medicion: **9 checks / 0 fallos / EXIT 0 x3**, piso 9 MEDIDO, `[MEDIDO] iconos ausentes:
18 de 18` y `[MEDIDO] claves i18n ausentes: 36`. Sondas EN ROJO 2: (C) API ciega
(`iconos_ausentes() -> []`) -> `desalineados` los 18 ids + **EXIT 1**; (D) asercion falsa
-> **EXIT 1**. Ambas restauraciones byte-exactas (sha256 `18eb6a6fd9a8b0e2` servicio,
`68ee9ba54d09617a` suite) y control verde.

## 5. Regresion (todo con el binario real)

| suite | resultado |
|---|---|
| test_logros | 72 / 0 / EXIT 0 x3, 0 SCRIPT ERROR |
| test_logros_rf10_m72 | 27 / 0 / EXIT 0 x3, 0 SCRIPT ERROR |
| test_logros_rf13_m72 | 3 / 0 / EXIT 0 |
| test_logros_m72_statids | 9 / 0 / EXIT 0 |
| test_logros_rf1_e | 39 / 0 / EXIT 0 |
| test_m72_rf6_m72 | 7 / 0 / EXIT 0 |
| test_logros_depende_de_m72 | 6 / 0 / EXIT 0 |
| test_m72_deuda_assets (nueva) | 9 / 0 / EXIT 0 x3 |
| test_postgame (M75, consume M72) | 86 / 0 / EXIT 0 |
| test_sfx_m43 (consume la senal) | OK, EXIT 0 |

`--check-only` sobre `achievement_service.gd`: EXIT 0 (0 parse/compile error).

## 6. Lo que NO hice y por que

- **No cree los 18 PNG.** El arte no existe en el repo y generar placeholders habria
  metido basura en `assets/`. Decision del fundador / pipeline de assets.
- **No toque `locales/es.po` ni `en.po`.** Son de M88, que esta en la lista NO TOCAR. Las
  36 claves necesitan GO. Ademas: hoy **nadie** traduce `nombre_i18n` (`grep tr(` en
  `achievement_service.gd` = 0), asi que las claves son data expuesta y no consumida: la
  UI muestra el literal `nombre` en espanol. Si se agregan al `.po` hay que cablear el
  `tr()` en el consumidor, o las claves siguen siendo decorativas.
- **No cablee `test_m72_deuda_assets.gd` en `quality.yml`** (limite duro). Queda pedido.
- **No aplique ningun flip de marca.** M72 esta en 200 [x] / 0 [ ] / 0 [?]: no hay item
  que flipar; los 4 hallazgos eran defectos DENTRO de items ya marcados.

## 7. Numeracion e higiene

- Log 2208: ASCII puro verificado por bytes, CRLF, sin BOM.
- Pool de logs: cabeza 2208 -> consumido, nueva cabeza 2209.
- Pool del canal: cabeza 420 (stale: 420 y 421 ya tienen archivo) -> se tomo el 422, que
  es `ultimo+1` y estaba en el pool; se retiro el 420 stale. Discrepancia reportada.
- 1 commit (3271665, autorizado). 0 push. 0 flips.
