# 06-Plan-Testings.md — Módulo 87: Localización

> **Modelo:** DeepSeek-V4.1-Flash (iters. 5 y 6) · deepseek-v4-flash (iter. 4)
> **Plataforma:** WorkBuddy (iters. 5 y 6) · Kilo Code (iter. 4)
> **Fecha:** 2026-09-15 (iter. 6) · 2026-09-13 (iter. 5) · 2026-09-04 (iter. 4)
> **Estado:** Plan ejecutado en iteraciones 4, 5 y 6 (resultados en 07-Resultados-Testings.md)

## 1. Alcance

Sistema transversal de internacionalización (i18n/l10n) sobre Godot 4.x: LocalizationManager (autoload `Localization`), LocaleUtils (formato números/fechas/hora), catálogos gettext `.po` (es fuente / en traducción), validación RF21 y edge cases de parseo/formato. El selector de idioma visual pertenece a M53/M90 (V2) y se prueba allí.

## 2. Entorno de ejecución

- **Motor:** Godot 4.7.2 stable (`C:\Temp\godot\godot472.exe`)
- **Modo:** headless (`--headless --no-window --path game/isla-ancestral --script res://...`)
- **Proyecto:** `game/isla-ancestral/`

## 3. Suites de tests

| Suite | Archivo | Cobertura |
|---|---|---|
| Núcleo (iter. 1) | `test_localization.gd` | Carga catálogos, traducción es/en, placeholders, plurales, formato, fallback, validar_catalogos |
| Iteración 2 | `test_localizacion_iter2.gd` | Persistencia M60, sugerencia SO, contexto gettext, cache, debug |
| Iteración 3 | `test_localizacion_iter3.gd` | Cobertura M88 (fuentes por idioma), validación RF14 |
| Iteración 4 | `test_localizacion_iter4.gd` | Parseo .po corrupto sin crash, placeholders mal formados, estado de catálogos RF21, plurales n=0/negativos, formatos edge |
| **Iteración 5** | `test_validador_po_m87.gd` | Validador de catálogos (reglas R1-R13 y P1-P5): bytes BOM/CRLF/UTF-8, cabecera, estructura, duplicados, plurales, convención RF20, placeholders, coherencia es↔en + auditoría de claves código↔catálogo |
| **Iteración 6 (nueva)** | `test_localizacion_iter6.gd` | **Encaje de texto medido (expansión es→en, desborde, palabras sin espacios, truncado, estrategias), glosario de términos canónicos, re-traducción selectiva de UI y coste del HUD a 60 fps, regresión contra `ValidadorPO`/`Localization`, barrido de accesibilidad M58. 11 bloques con marcador `_fin()` + guardián anti-falso-verde con watchdog** |

## 4. Casos de prueba (iteración 4 — robustez determinista)

### 4.1 Parseo de .po corrupto (T-084)
- **CP-01:** catálogo con `msgstr[ sin_indice]` → se omite la línea, no crashea, el resto del catálogo parsea. Criterio: exit 0, clave sana sigue traduciendo.
- **CP-02:** catálogo con `msgstr[99]` (índice fuera de rango) → se omite, no crashea.
- **CP-03:** catálogo con plurales válidos `msgstr[0]/msgstr[1]` → se conservan íntegros.

### 4.2 Placeholders (T-085/T-086/T-087)
- **CP-04:** texto con `{sin_cierre` → queda literal, no rompe la UI ni crashea.
- **CP-05:** texto con `{param}` sin valor en params → queda literal (foo dev warning).
- **CP-06:** params con claves extra no usadas → se ignoran, texto resultante correcto.
- **CP-07:** placeholders repetidos `{a}{b}{a}` → se reemplazan todas las ocurrencias.

### 4.3 Estados de catálogos (RF21 ampliado)
- **CP-08:** `obtener_estado_catalogos()` devuelve por idioma `{total, faltantes, vacias, ok}`.
- **CP-09:** es (fuente) siempre `ok:true`; en cubre 100% de es (evidencia 64/64).
- **CP-10:** `validar_catalogos()` sin claves faltantes entre es y en.

### 4.4 Plurales y formatos edge
- **CP-11:** plural es/en con n=0, 1, 2 y n=-3 (negativos activan rama plural tras fix iter. 4).
- **CP-12:** `format_number` con 0, negativos y valores ≥ 1e6 (separadores de miles correctos).
- **CP-13:** `format_hora` 12h en medianoche (0:05 → 12:05 AM).
- **CP-14:** `format_date` con día/mes/año de un dígito (relleno 2/4 dígitos).

### 4.5 Regresión
- **CP-15:** las 3 suites anteriores (núcleo, iter2, iter3) siguen en 0 fallos tras los cambios de iteración 4.

### 4.6 Iteración 5 — validador .po y auditoría de claves (DeepSeek-V4.1-Flash)

Fixtures sintéticos escritos en `user://` por el propio test (no tocan el repo) más los catálogos reales.

**Reglas de bytes**
- **CP-16:** catálogo con BOM UTF-8 → error R1 (AGENTS.md §28); el resto igual parsea.
- **CP-17:** catálogo con saltos CRLF → error R2 (RN10 exige LF).
- **CP-18:** ruta inexistente → error R1 sin crash.

**Cabecera y estructura**
- **CP-19:** sin cabecera gettext → error R4.
- **CP-20:** `msgstr` vacío → error R6.
- **CP-21:** `msgid` duplicado → error R7.
- **CP-22:** plural con `msgstr[1]` y sin `msgstr[0]` → error R13.

**Convención y placeholders**
- **CP-23:** clave en minúscula → aviso R10; `npc.catalina` **exenta** por diseño (no se marca) y es la única marcada cuando convive con una clave inválida.
- **CP-24:** entrada que mezcla `{llave}` y `%s` → aviso R12.
- **CP-25:** `placeholders_de()` extrae llaves y printf, y une las formas plurales.

**Coherencia entre idiomas**
- **CP-26:** par sintético correcto → `ok` y 0 errores.
- **CP-27:** clave de la fuente ausente en la traducción → error P1 con la clave reportada.
- **CP-28:** placeholder distinto entre idiomas (`{n}` vs `{x}`) → error P3.
- **CP-29:** `msgstr` idéntico a la fuente → aviso P5 con la clave reportada.

**Auditoría de claves**
- **CP-30:** detecta el prefijo dinámico `DIARY.CAT_` y **no** lo reporta como clave ausente.
- **CP-31:** detecta una clave usada y ausente del catálogo; no marca las presentes.
- **CP-32:** ignora claves de test (`NOPE.*`) y resuelve `tr_key("A","B","C")` a `A.B.C`.
- **CP-33:** sobre el repo real (702 `.gd`): **0 claves de producción ausentes**, veredicto `OK`, 3 probes solo-test separados y 14 claves cubiertas por prefijo dinámico.
- **CP-34:** `clave_cumple_convencion()` acepta `HUD.ENERGIA`, `CLOCK.ESTACIONES.0` y `npc.catalina` (exenta), y rechaza minúsculas.
- **CP-35:** `formatear_informe()` de ambos validadores devuelve texto legible.
- **CP-36:** regresión de iteración 2 — 50 llamadas a la misma clave ausente registran **1** entrada en `claves_faltantes()` (dedup del aviso).

### 4.7 Iteración 6 — encaje de texto, glosario y re-traducción selectiva (DeepSeek-V4.1-Flash)

**Premisa que habilita el bloque:** la medición de texto **sí** funciona en headless (`TextServerAdvanced` +
`ThemeDB.fallback_font`). Eso convierte la comprobación de desbordes en determinista y repetible en CI, en
lugar de "requiere QA visual". Contenedor de referencia: **220×40 px** a 16 px.

**A. Fuente y medición (9 checks)**
- **CP-37:** la fuente de respaldo del tema mide (`get_string_size("Jugar")` a 16 px = 41×23).
- **CP-38:** la altura de línea crece con el tamaño (23,0 a 16 px → 34,0 a 24 px).
- **CP-39:** el ancho se mide con `get_multiline_string_size` cuando hay ancho máximo (trampa 55: `get_string_size` con ancho positivo **trunca** y devuelve la altura de una sola línea).

**B. Encaje (5 checks)**
- **CP-40:** `cabe()` acepta un texto que entra y rechaza uno que no.
- **CP-41:** con salto de línea el bloque envuelto es **más alto y más angosto** que el que no envuelve.

**C. Expansión es→en sobre las 170 claves reales (8 checks)**
- **CP-42:** expansión media y máxima medidas (0,934 / 1,529) y **sólo 5 de 170** superan el +30 %.
- **CP-43:** `razon_expansion()` de un par idéntico es 1,0 y crece con el texto inglés más largo.

**D. Palabras largas y truncado (9 checks)**
- **CP-44:** `palabras_largas()` detecta una palabra sin espacios por encima del umbral.
- **CP-45:** `partir_palabra()` inserta cortes de ancho cero y el resultado **cabe** donde antes no (237 px → 219 px).
- **CP-46:** `truncar_con_puntos()` garantiza que el resultado mide menos que el ancho máximo.

**E. Estrategias (5 checks)**
- **CP-47:** `estrategia()` propone `cabe` / `reducir_fuente` / `partir_palabra` / `truncar` según el caso, y `tamano_minimo_que_cabe()` respeta el factor mínimo.

**F/G. Glosario (12 checks)**
- **CP-48:** carga de `data/localization/glosario.json` (17 términos) y `terminos()`.
- **CP-49:** `normalizar()` quita acentos y mayúsculas; `es_termino()` **rechaza prosa** (frase larga con salto de línea o puntuación final) para no confundir un término con una narración que contiene ese verbo.
- **CP-50:** `contiene_palabra()` compara **palabra completa** (no substring).
- **CP-51:** `verificar()` sobre los catálogos reales → **0 inconsistencias** (17 términos, 17 en uso).
- **CP-52:** **inyección**: con una inconsistencia sembrada a propósito, `verificar()` la reporta (prueba de que la comprobación no es vacía).

**H. Decisión pura de visibilidad (6 checks)**
- **CP-53:** `debe_retraducir()` descarta nodos invisibles, fuera del árbol y fuera del rectángulo visible, y acepta el visible.

**I. Re-traducción en vivo + coste (12 checks)**
- **CP-54:** con el autoload **real**, `set_locale("en")` re-traduce el nodo visible («Energía» → «Energy») y al restaurar el idioma vuelve (se restaura el locale original al terminar).
- **CP-55:** de un árbol de 4 nodos traduce 1 y **salta 2** (invisible + fuera de pantalla).
- **CP-56:** un HUD de 120 labels se re-traduce en **1,4–2,0 ms** contra el presupuesto de 16,67 ms por frame (`cabe_en_60fps`).

**J. Regresión (9 checks)**
- **CP-57:** `ValidadorPO.validar_par` sobre los catálogos reales sigue en `ok`, y `AuditorClaves` sigue sin claves de producción ausentes.

**K. Barrido de accesibilidad M58 (6 checks)**
- **CP-58:** el desborde responde de forma **monótona** a la escala: 0 claves a 12 px, 63 a 16 px, 97 a 24 px (equivalente al `ui_scale` 0,8–1,5 de M58). La traducción no se rompe; los **layouts** sí a 1,5×, y eso es trabajo de M53.

**Guardián anti-falso-verde**
- **CP-59:** `_run()` exige que los 11 bloques (A–K) hayan dejado su marca `_fin()`. Un `SCRIPT ERROR` aborta la función en silencio, así que sin esta comprobación un bloque podría no ejecutarse y el suite reportar "0 fallos" igual.
- **CP-60:** watchdog en `_process`: si a los 900 frames no se llegó a `quit()`, imprime el motivo y sale con **código 1**. Necesario porque un aborto dentro de `_run()` con `extends SceneTree` **cuelga el árbol para siempre** (la salida se perdió por buffering).
- **CP-61:** el desglose por bloque se **mide**: la suma de los `(+N checks)` debe igualar el total del `=== Resumen ===` (81 + 1 del guardián = 82). Probado por inyección: abortar el bloque K da `no terminaron: ["K"]`, 82→76 y **EXIT 1**.

**Exención P5 declarada en el catálogo (14 checks, en `test_validador_po_m87.gd`)**
- **CP-62:** sin marcador, un `msgstr` idéntico a la fuente sigue reportándose (la regla no se debilitó).
- **CP-63:** con `#. no-traducir: <motivo>` la clave sale de `no_traducidas` y entra en `exentas_p5`; el aviso P5 baja su cuenta.
- **CP-64:** la exención es **por clave**: no contagia al resto del archivo.
- **CP-65:** el marcador en la **fuente** también exime; y el comentario **no contamina** el `msgstr` parseado.
- **CP-66:** sobre los catálogos reales: 0 sin traducir y **13 exenciones** declaradas (11 plantillas de cartel + `AO` + `{h} h {m} min`).

## 5. Criterios de éxito

- Exit code 0 en las **6** suites headless.
- 0 fallos en cada suite y **0 `SCRIPT ERROR`** en la salida.
- Sin regresiones en M21 (resolve_text traduce claves) ni M88 (fuentes por idioma) — verificadas por los tests del módulo.

## 6. Límites del plan

- **Selector de idioma visual (M53/M90):** V2, requiere UI — fuera del alcance de tests headless (se prueba en M53).
- **Aprobación estética del texto:** sigue fuera de alcance. Lo que la iter. 6 demuestra es que el **encaje** se puede medir sin visión; que el resultado *guste* no es medible.
- **QA visual de las fuentes:** bloqueada de hecho por **BUG-042** (3 de las 4 fuentes de `assets/fonts/` son páginas HTML 404 con extensión `.ttf`; `load()` no devuelve `null` sino un `FontFile` con métricas en cero). Dueño: M46/M88.
- **Traducción humana del catálogo completo:** el contenido narrativo crece de forma continua; cada clave nueva debe agregarse a es.po y en.po (validar_catalogos lo controla).

## 7. Casos de prueba (iteración 7 — corrección de la regresión M53/M87)

Corrección, no funcionalidad nueva. El objetivo es que la regresión medida **no pueda volver a pasar
inadvertida**.

| # | Caso | Qué mide | Evidencia |
|---|------|----------|-----------|
| C1 | `es.po` / `en.po` sin errores de bytes ni de estructura | R1 sin BOM, R2 sin CRLF, R6 sin `msgstr` vacío, R7 sin `msgid` duplicado | `ValidadorPO.validar_archivo(…, "es")` / `(…, "en")` → `ok=true` |
| C2 | Paridad es↔en tras agregar las 3 claves | P1 claves faltantes = 0, P3 placeholders desalineados = 0 | `validar_par` → `ok=true` |
| C3 | Ninguna entrada queda "sin traducir" (P5) | `no_traducidas` vacío: los `msgstr` de `en` no repiten los de `es` | `validar_par` → `no_traducidas = []` |
| C4 | `SETTINGS.DESCARTAR_MENSAJE` lleva `%s` en ambos idiomas | El llamador hace `_t(clave) % item_name`; sin `%s` la interpolación es un no-op | `placeholders` de la clave = `{printf: ["%s"], printf_n: 1}` en los dos catálogos |
| C5 | El auditor ve claves pasadas como argumento a `open_confirm` | `RE_CLAVE_ARG1`/`RE_CLAVE_ARG2` sobre un fixture que imita el llamador real (multi-línea, con `% n` en el mensaje) | `usadas_sin_clave` contiene las 2 claves del fixture |
| C6 | Un texto humano no se confunde con una clave | El patrón exige la forma `MODULO.SECCION.CLAVE` | `open_confirm("¿Seguro?", "DLG.OK", …)` → `DLG.OK` sí, `¿Seguro?` no |
| C7 | Producción sin claves ausentes (el caso que falló) | `usadas_sin_clave` vacío y `ok=true` sobre `res://scripts` real | bloque G del suite |
| C8 | Las 2 claves del llamador de M53 dejan de figurar como huérfanas | `claves_sin_uso` ya no las lista | bloque G del suite |
| C9 | Determinismo | 3 corridas con salida idéntica salvo timestamps y `session id` | `sha256` normalizado igual ×3 |

**Fuera de alcance:** no se convirtieron en error las claves huérfanas (`claves_sin_uso`): son
legítimas (contenido aún no migrado) y el veredicto del auditor no las mira.
