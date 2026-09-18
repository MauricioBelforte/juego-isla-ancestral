# Log 1015: M87 iter. 7 — la regresión que el `|| true` mantenía invisible, y el punto ciego del auditor

**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Módulo:** 87-Localizacion
**Iteración:** 7 (corrección — sin funcionalidad nueva)
**Fecha:** 2026-09-18 16:10
**Reserva:** 1015 (protocolo v3 — `Logs/NUMEROS_DISPONIBLES.txt` quedó con `primero=1019`)

## Resumen

Empezó como un pendiente de higiene de CI: auditar los **46 comandos neutralizados con `|| true`** en
`.github/workflows/quality.yml`. Terminó encontrando una **regresión real en producción** que el
neutralizador mantenía invisible, y la causa de raíz de por qué ningún test la veía.

| # | Qué | Resultado |
|---|---|---|
| 1 | Medición del exit **del proceso** de los 31 gates propios (trampa 75) | 30 verdes ×3 pasadas · **1 rojo** |
| 2 | El rojo: 3 claves de M53 ausentes de `es.po`/`en.po` | **corregido** |
| 3 | Punto ciego de `AuditorClaves` (claves pasadas como argumento) | **cerrado** + 6 aserciones |
| 4 | Los 31 gates propios dejan de ser falso-verde | **patrón acumulativo** (commit `0339042`) |
| 5 | 14 gates ajenos + 2 comandos inválidos | **reportados, no tocados** |

## 1. El barrido: medir el exit del proceso, no el de la tubería

`quality.yml` tenía **45 comandos `godot` con `|| true`** (más 1 de `python3`) desde el commit
`a466ab3` (2026-09-17 02:52, del usuario). Con `|| true` al final, el step **nunca** puede fallar.

Para saber cuáles eran gates legítimos y cuáles tapaban un rojo, se midió el exit **del proceso**
(`subprocess.run` sin shell; `returncode` es el de Godot) y no el de la tubería — **trampa 75**:
`godot … 2>&1 | tail` devuelve el exit de `tail`.

**31 comandos son de mis módulos** (M52, M87, M127, M26, M124, M68, M27, M60, M103, M105, M148).
Resultado de la pasada 1:

- **30 verdes** (`RC=0`, `SCRIPT ERROR=0`).
- **1 rojo**, el único de todo el barrido:

```
L162  M87  ROJO RC=1  SCRIPT_ERROR=0  11.9s
      godot --headless --script scripts/localization/test_validador_po_m87.gd
      | FALLO: auditor real: 0 claves de PRODUCCIÓN ausentes -> ["SETTINGS.DESCARTAR"]
```

### Determinismo (por qué los 30 se pueden endurecer)

Pasadas 2 y 3 completas: **30/30 con `RC=0` y `SCRIPT ERROR=0`**. Comparación de salidas 1↔2
normalizando lo volátil (timestamps, `session id` del CrashReporter de M122, duraciones en ms y el
recuento de archivos del auditor, que cambia porque otros agentes commitean `.gd` en paralelo):

- **30 de 31 byte-idénticos.**
- **1** (`test_datos_m60.gd`) idéntico **como multiset**: se reordena un log asíncrono de M60 entre
  líneas de `DOM-UI`. No es una diferencia de comportamiento.

## 2. El rojo era una regresión real, no un test mal escrito

`scripts/ui/layers/inventory_layer.gd` (**M53**, commit `84d975d` del 2026-09-17 20:21) usa tres claves
que **no existían en ninguno de los dos catálogos**:

```gdscript
_discard_button.text = _t("SETTINGS.DESCARTAR")            # línea 121
ui_mgr.open_confirm(
    "SETTINGS.DESCARTAR_TITULO",
    "SETTINGS.DESCARTAR_MENSAJE" % item_name,              # líneas 374-376
    _ejecutar_descarte.bind(_selected_slot), Callable())
```

Efecto real medido, no teórico: el botón de descarte **renderizaba la clave cruda** y
`LocalizationManager._avisar_faltante` emitía

```
WARNING: [M87] Clave sin traducción: SETTINGS.DESCARTAR
```

en **cada corrida headless del proyecto**: el aviso está en las **31 salidas** del barrido, o sea en
todos los tests que bootean la escena. (Regla del proyecto: *warnings = errores*.)

### El fix

3 entradas en `es.po` y `en.po`, **con `%s`** en el mensaje:

| Clave | es | en |
|---|---|---|
| `SETTINGS.DESCARTAR` | `Descartar` | `Discard` |
| `SETTINGS.DESCARTAR_TITULO` | `Descartar objeto` | `Discard item` |
| `SETTINGS.DESCARTAR_MENSAJE` | `¿Seguro que querés descartar %s?` | `Are you sure you want to discard %s?` |

**Por qué `%s` y no un texto plano:** el llamador hace `_t("SETTINGS.DESCARTAR_MENSAJE") % item_name` y
`ConfirmPopup.configurar` traduce la clave con `_t(title_key)` / `_t(message_key)`. O sea la API
**espera claves** y la interpolación del nombre del objeto ocurre sobre la traducción. Sin `%s` el
`% item_name` era un **no-op silencioso** y el mensaje no habría mostrado el objeto.

Restricciones respetadas (las impone el propio suite): LF sin BOM (R1/R2), paridad de claves (P1) y de
placeholders (P3) entre idiomas, y `no_traducidas` vacío (P5) → los `msgstr` de `en` no repiten los de `es`.

## 3. Causa de raíz: el punto ciego de `AuditorClaves`

El auditor sólo veía claves dentro de una llamada `_t("…")`. Las que se pasan **como argumento** a una
API que traduce adentro (`open_confirm` → `ConfirmPopup.configurar` → `_t(title_key)`) eran
**invisibles**. Consecuencia exacta:

- `SETTINGS.DESCARTAR` (usada con `_t()`) → reportada como **faltante**. Eso es lo que hizo fallar el test.
- `SETTINGS.DESCARTAR_TITULO` / `_MENSAJE` (usadas como argumento) → reportadas como **huérfanas del
  catálogo**, no como faltantes del código. El veredicto del auditor las ignora, así que **aunque el
  test hubiera corrido, el hueco de esas 2 no se habría visto**.

Se agregaron dos patrones posicionales en `auditor_claves.gd`:

- `RE_CLAVE_ARG1` → la clave en la posición 1 de `open_confirm(...)`.
- `RE_CLAVE_ARG2` → la clave en la posición 2 (tolerando que la 1 sea texto literal).

Ambos exigen la forma `MODULO.SECCION.CLAVE`, así que un texto humano (`open_confirm("¿Seguro?", …)`) no
se confunde con una clave. Se captura cada posición por separado para tolerar llamadas mixtas.

**Verificación de que no es un parche cosmético:** `open_confirm` tiene **un solo llamador en todo el
repo** (`inventory_layer.gd:374`), así que el efecto del cambio es acotado y determinista.

### Efecto medido

| Métrica | Antes | Después |
|---|---|---|
| `usadas` (auditor sobre `res://scripts`) | 55 | **57** |
| `total_claves` (catálogo `es.po`) | 174 | **177** |
| `usadas_sin_clave` de producción | 1 (`SETTINGS.DESCARTAR`) | **0** |
| `claves_sin_uso` con `DESCARTAR_*` | 2 | **0** |
| avisos `Clave sin traducción` por corrida | 1 | **0** |
| veredicto | `CLAVES SIN TRADUCCIÓN` | **`OK`** |

## 4. Por qué el defecto sobrevivió 18 horas (cadena de custodia)

| Fecha/hora | Hecho |
|---|---|
| 2026-09-13 | M87 iter. 5 cierra con `AuditorClaves` en verde. La afirmación era correcta **en ese momento** (las claves no existían todavía). |
| 2026-09-17 02:52 | Commit `a466ab3` (Mauricio Belforte): el gate de M87 en `quality.yml` queda **neutralizado con `|| true`** para desbloquear el CI. |
| 2026-09-17 20:21 | Commit `84d975d` (M53): `inventory_layer.gd` empieza a usar 3 claves que no están en el catálogo. El gate **habría** fallado. Estaba neutralizado. |
| 2026-09-18 16:0x | Barrido de esta iteración: midiendo el exit del proceso, el test aparece **RC=1**. |

La neutralización **no causó** la regresión, pero **sí** su invisibilidad: durante 18 h el único test que
la detectaba no podía hacer fallar nada. Por eso el fix va acompañado del endurecimiento del gate.

## 5. Los gates propios dejan de ser falso-verde

Decisión del usuario: **patrón acumulativo** (no fail-fast), para que todos los tests sigan corriendo e
informando pero el job falle si alguno rompe.

```yaml
run: |
  cd game/isla-ancestral
  FAIL=0
  godot --headless --script scripts/… 2>&1 || FAIL=1
  …
  echo "All validation tests completed"
  exit $FAIL
```

- **31 comandos** de mis módulos: `|| true` → `|| FAIL=1`.
- `FAIL=0` al inicio del step y `exit $FAIL` al final.
- Los **14 `|| true` ajenos** quedan **intactos**: no es mi decisión.
- Commit **`0339042`** (33 inserciones / 31 borrados).

**Staging por bytes (trampa 70, variante "mismo archivo"):** `quality.yml` tenía **5 líneas sin commitear
de agnes-3** (gates M66, Log 1018) al final del **mismo step**. Como no se puede separar por ruta, se
commiteó `HEAD + mi cambio` y después se restauró el árbol con `ajeno + mío`. Verificado: el commit
contiene sólo mi cambio y el árbol sigue mostrando exactamente las 5 líneas ajenas sin commitear.

## 6. Reporte: no tocado por ser ajeno

De los 14 gates ajenos que siguen neutralizados, **2 son comandos inválidos** — el `|| true` es lo único
que evita que el CI falle por un comando mal escrito:

| Línea | Comando | Problema |
|---|---|---|
| 33 | `godot --headless --script 2>&1 \|\| true` | `--script` **sin ruta**. Además el paso imprime `echo "Godot headless lint completed"` incondicional. |
| 83 | `godot --headless --check-only 2>&1 \|\| true` | `--check-only` **sin ruta**. El `echo "… (exit code: $?)"` de la línea siguiente siempre imprime `0`, porque `$?` es el del `\|\| true`. |

Los otros 12: `code_quality_check.gd` ×2 (jobs `godot-lint` y `code-quality-script`), `validate_save.gd`
(M59), `test_calendario.gd` (M29), `test_consumidores_tiempo.gd`, `test_amistad.gd` (M20),
`test_m38_economia_smoke.gd` / `test_minorista_mayorista.gd` / `test_topos_banda.gd` (M38),
`test_m111_utils_headless.gd` (M111), `test_backup_m107.gd` (M107), `test_build_m117.gd` (M117).

## 7. Verificación

- `test_validador_po_m87.gd`: **RC=0 · 0 fallos · 0 `SCRIPT ERROR` ×3**, 9/9 bloques con marca `_fin()`,
  **`sha256` idéntico** en las 3 corridas (timestamps y `session id` normalizados).
- Las 6 suites de `scripts/localization/` siguen verdes.
- Barrido de los 31 gates propios: 30/30 verdes ×3 pasadas; el rojo corregido.
- `es.po` 13107 B · `en.po` 12478 B — LF, sin BOM.
- Documentación anexada (no reescrita): `04-Codigo.md`, `05-Checklist.md`, `06-Plan-Testings.md` §7,
  `07-Resultados-Testings.md` §9, checklist personal (nota de iteración), `BACKLOG-MASTER.md` fila 20.
- Los checklists **no cambiaron de conteo** (129 `[x]` / 7 `[?]` / 0 `[ ]` en ambos): es una corrección
  sobre alcance ya declarado, no alcance nuevo.

## 8. Lo que NO hice (honestidad obligatoria)

- **No toqué `inventory_layer.gd`.** El defecto era del catálogo, no del llamador: M53 usa claves, que
  es exactamente lo que M87 le pide.
- **No convertí en error las claves huérfanas** (`claves_sin_uso`). Son legítimas (contenido aún no
  migrado) y el veredicto del auditor no las mira.
- **No endurecí los gates ajenos** de `quality.yml` (14 siguen con `|| true`), ni arreglé los 2 comandos
  inválidos: la decisión no es de M87.
- **No hice QA visual** del diálogo: sigue bloqueada por **BUG-042** (3 de las 4 fuentes de
  `assets/fonts/` son páginas HTML 404 con extensión `.ttf`).
- **No cerré los textos** como definitivos: la revisión humana es de RN9.
- **No eliminé la colisión 1013** ni la reserva heredada `1017-glm-5.3-flash-M39.txt` de
  `Logs/reservas/`: son de otros dueños (`--estado` las sigue reportando).

## 9. Pendientes con dueño

| Pendiente | Dueño |
|---|---|
| QA visual del diálogo de descarte | Bloqueado por BUG-042 (M46/M88) |
| Generalizar `RE_CLAVE_ARG*` si aparece otra API que reciba claves | M87 (deuda declarada) |
| Arreglar L33/L83 de `quality.yml` (`--script`/`--check-only` sin ruta) | M118 (glm-5.3-flash) |
| Decidir sobre los 12 gates ajenos restantes | Dueños de M59/M29/M20/M38/M111/M107/M117 |
| Renumerar la colisión 1013 | agnes-3-flash / atria-dawn |
| Borrar la reserva heredada `1017-glm-5.3-flash-M39.txt` (`--liberar 1017`) | glm-5.3-flash |
| QA cruzado §21.8 de M87 iter. 7 (verificador ≠ autor) | Otro agente |
