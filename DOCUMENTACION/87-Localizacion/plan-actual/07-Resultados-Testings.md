# 07-Resultados-Testings.md — Módulo 87: Localización

> **Modelo:** DeepSeek-V4.1-Flash (iters. 5 y 6) · deepseek-v4-flash (iters. 1-4)
> **Plataforma:** WorkBuddy (iters. 5 y 6) · Kilo Code (iters. 1-4)
> **Fecha:** 2026-09-15 (iter. 6) · 2026-09-13 (iter. 5) · 2026-09-04 (iters. 1-4)
> **Estado:** Ejecutado — **6/6 suites en verde, 0 fallos, 0 errores de script**

## 1. Resumen ejecutivo

| Suite | Check | Resultado |
|---|---|---|
| Núcleo (iter. 1) | `test_localization.gd` | ✅ 0 fallos (exit 0) |
| Iteración 2 | `test_localizacion_iter2.gd` | ✅ 0 fallos (exit 0) — reparada en iter. 5, ver §7 |
| Iteración 3 | `test_localizacion_iter3.gd` | ✅ 0 fallos (exit 0) |
| Iteración 4 | `test_localizacion_iter4.gd` | ✅ 0 fallos (exit 0) |
| Iteración 5 | `test_validador_po_m87.gd` | ✅ 0 fallos (exit 0) — ampliada en iter. 6 con el bloque I |
| **Iteración 6 (nueva)** | `test_localizacion_iter6.gd` | ✅ **82 checks, 0 fallos (exit 0)**, 3 corridas |

**Comando:** `godot472.exe --headless --path game/isla-ancestral --script res://scripts/localization/<suite>.gd`

## 2. Resultados por caso (iteración 4)

| Caso | Descripción | Resultado |
|---|---|---|
| CP-01 | msgstr[ sin índice → omitido sin crash, resto parsea | ✅ |
| CP-02 | msgstr[99] fuera de rango → omitido sin crash | ✅ |
| CP-03 | plurales válidos msgstr[0]/[1] conservados | ✅ |
| CP-04 | `{sin_cierre` queda literal | ✅ |
| CP-05 | `{param}` sin valor queda literal | ✅ |
| CP-06 | params extra no usados ignorados | ✅ |
| CP-07 | placeholders repetidos `{a}{b}{a}` → "xyx" | ✅ |
| CP-08 | estado catálogos: {total, faltantes, vacias, ok} por idioma | ✅ |
| CP-09 | es.ok true; en sin faltantes (evidencia 64/64) | ✅ |
| CP-10 | validar_catalogos sin faltantes | ✅ |
| CP-11 | plurales n=0/1/2/-3 en es y en | ✅ (tras fix n != -1, ver §3) |
| CP-12 | format_number 0 / -1234.5 / 1e6 separadores correctos | ✅ |
| CP-13 | format_hora 0:05 → "12:05 AM" (12h en) | ✅ |
| CP-14 | format_date relleno 07/03/0026 | ✅ |
| CP-15 | regresión núcleo + iter2 + iter3 | ✅ 3/3 |

## 3. Fix aplicado durante la iteración 4 (NÚCLEO)

**Bug real detectado por el test CP-11:** el contrato del núcleo usaba `n >= 0` para activar la rama plural, lo que EXCLUÍA números negativos (`n=-3` devolvía la clave literal). El checklist exigía "plurales con n = 0, 1, 2, números negativos y decimales".

- **Cambio:** en `localization_manager.gd`, `_tr_clave` y `_buscar_texto` ahora usan `n != -1` (donde `-1` = sin plural, valor por defecto). Cualquier otro valor (0, 1, 2, -3...) activa la rama plural.
- **Compatibilidad:** aditivo, no rompe llamadas existentes (el default `n=-1` conserva comportamiento).
- **Verificado:** test iter4 0 fallos + regresión base 0 fallos.

## 4. Evidencia de cobertura de catálogos

- `es.po` (fuente de verdad): **64 claves** *(cifra de la iter. 4; tras la iter. 5 y el contenido de M68 el
  catálogo tiene **171 entradas**, 170 claves + la cabecera — ver §8.4)*.
- `en.po` (traducción): **64 claves** *(ídem: hoy 171 entradas, cobertura 1:1 con la fuente)*.
- **Faltantes en vs es: 0** → `validar_catalogos()` en verde.
- El caso especial `ITEMS.SE_OFRECEN` (plural gettext msgstr[0]/[1]) parsea correctamente en ambos idiomas.

## 5. Ruido no atribuible (documentado)

Durante el boot headless aparecen avisos de otros sistemas (autoloads de IA/fauna, `get_path of node not in scene tree`, orphanes al cierre). **No afectan los resultados de M87** (los 4 tests reportan 0 fallos propios) y son teardown del boot del proyecto, no del módulo.

## 6. Pendientes con dueño (fuera de alcance de tests headless)

| Pendiente | Dueño | Tipo |
|---|---|---|
| Selector de idioma visual en configuración | M53/M90 | V2 UI |
| Desbordes de texto inglés +30% en layouts | M53 + QA visual (V1/V4) | C visual |
| Confirmación del idioma del SO (diálogo) | M53 | V2 UI |
| Traducción humana de catálogos de producción | Traductor humano | Revisión |
| Integración con subtítulos M44 en UI | M44 | Integración |

---

## 7. Iteración 5 — validador .po y auditoría de claves (2026-09-13)

**Modelo:** DeepSeek-V4.1-Flash · **Plataforma:** WorkBuddy

### 7.1 Resultado de la suite nueva

`test_validador_po_m87.gd` — 8 bloques, **0 fallos**, **0 errores de script**.

| Bloque | Casos | Resultado |
|---|---|---|
| A Catálogos reales (es/en + par) | CP-16 base | ✅ |
| B Reglas de bytes (BOM/CRLF/inexistente) | CP-16..18 | ✅ |
| C Cabecera y estructura | CP-19..21 | ✅ |
| D Plurales y convención de claves | CP-22..23 | ✅ |
| E Placeholders | CP-24..25 | ✅ |
| F Coherencia entre idiomas | CP-26..29 | ✅ |
| G Auditoría de claves (sintética + repo real) | CP-30..33 | ✅ |
| H Unidades e informes | CP-34..35 | ✅ |

### 7.2 Evidencia del auditor sobre el repositorio real

```
── AuditorClaves: 702 archivo(s), 54 clave(s) usadas, 85 en catálogo
USADAS EN CÓDIGO PERO AUSENTES DEL CATÁLOGO (0)
AUSENTES PERO SOLO USADAS POR TESTS (probes) (3):
  · MENUS.BOTONES.NARRATIVA|CERRAR  [test_localizacion_iter2.gd, test_localizacion_iter4.gd]
  · MENUS.BOTONES.UI|CERRAR  [test_localizacion_iter2.gd, test_localizacion_iter4.gd]
  · MENUS.SALUDOS.HOLA  [test_localizacion_iter2.gd]
EN EL CATÁLOGO, USADAS POR PREFIJO DINÁMICO (14)
EN EL CATÁLOGO SIN USO LITERAL NI DINÁMICO (23)
RESULTADO: OK
```

Antes de esta iteración el mismo auditor reportaba **10 claves ausentes**, de las cuales **7 eran de producción** (la UI mostraba la clave cruda) y 3 eran probes de test.

### 7.3 Regresión reparada (fallo preexistente)

`test_localizacion_iter2._test_cache` **fallaba de forma estable** (31-48 ms contra un umbral de 20 ms) al comenzar la iteración. Diagnóstico con una sonda de 200 llamadas:

| Escenario | Tiempo medido |
|---|---|
| Clave existente (`SETTINGS.PAUSA`) | **333 µs** |
| Clave ausente (`MENUS.SALUDOS.HOLA`) | **16.774 µs** |

La cache funcionaba; el costo era **un `push_warning` con backtrace completo (≈16 ms)** porque el test medía con una clave que no existe en el catálogo. Correcciones aplicadas:

1. **Núcleo:** `_avisar_faltante()` deduplica el aviso por clave y sesión (antes: 1 aviso por llamada). Se expone `claves_faltantes()`.
2. **Test:** mide con una clave existente y verifica el dedup (50 llamadas → 1 entrada).
3. **Test:** `_cache.size() >= 0` (aserción que no podía fallar) → `>= 1`.

### 7.4 Correcciones de higiene

- **AGENTS.md §28:** BOM eliminado de `localization_manager.gd` y `test_localization.gd`. El directorio `scripts/localization/` queda **100 % UTF-8 sin BOM + LF** (verificado byte a byte).
- **`es.po` / `en.po`:** siguen en UTF-8 sin BOM + LF (199 y 198 saltos LF, 0 CRLF).

### 7.5 Pendientes con dueño (actualizado)

| Pendiente | Dueño | Tipo |
|---|---|---|
| Eliminar o marcar obsoleto el autoload duplicado `LocalizationManager` | Decisión del usuario / dueño del módulo | Refactor transversal |
| Parsear `Plural-Forms` de la cabecera (idiomas con 3+ formas) | M87 (deuda) | Robustez |
| Unificar la lista de idiomas (`LOCALES_SOPORTADOS` / `LocaleUtils`) | M87 (deuda) | Refactor |
| Normalizar los prefijos de clave sobrecargados (`SETTINGS.*`) | M87 + M53 | Convención |
| Revisión humana de los textos provisionales agregados | Traductor humano | Revisión (RN9) |
| Desbordes de texto inglés +30% en layouts | M53 + QA visual | C visual |
---

## 8. Iteración 6 — encaje de texto, glosario y re-traducción selectiva (2026-09-15)

**Modelo:** DeepSeek-V4.1-Flash · **Plataforma:** WorkBuddy · **Log:** 920

### 8.1 Resultado de las suites (6/6)

| Suite | Resultado | `SCRIPT ERROR` |
|---|---|---|
| `test_localization.gd` (núcleo) | ✅ 0 fallos, exit 0 | 0 |
| `test_localizacion_iter2.gd` | ✅ 0 fallos, exit 0 | 0 |
| `test_localizacion_iter3.gd` | ✅ 0 fallos, exit 0 | 0 |
| `test_localizacion_iter4.gd` | ✅ 0 fallos, exit 0 | 0 |
| `test_validador_po_m87.gd` (iter. 5 + bloque I) | ✅ 0 fallos, exit 0 | 0 |
| `test_localizacion_iter6.gd` (nueva) | ✅ **82 checks, 0 fallos, exit 0** ×3 | 0 |

**Comando:** `Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --script res://scripts/localization/<suite>.gd`

### 8.2 Desglose por bloque del suite nuevo (MEDIDO, no copiado)

| Bloque | Contenido | Checks |
|---|---|---|
| A | Fuente y medición real de texto | 9 |
| B | Encaje (`cabe`) y envoltura | 5 |
| C | Expansión es→en sobre las 170 claves reales | 8 |
| D | Palabras largas, corte de ancho cero y truncado | 9 |
| E | Estrategias y tamaño mínimo de fuente | 5 |
| F | Carga del glosario | 6 |
| G | Verificación del glosario + inconsistencia inyectada | 6 |
| H | Decisión pura de visibilidad | 6 |
| I | Re-traducción en vivo + coste del HUD | 12 |
| J | Regresión contra `ValidadorPO` / `Localization` | 9 |
| K | Barrido de accesibilidad M58 | 6 |
| — | **Subtotal** | **81** |
| — | Guardián anti-falso-verde | 1 |
| — | **Total `=== Resumen ===`** | **82** |

La suma de los `(+N checks)` impresos por `_fin()` **coincide** con el total del resumen. Esa identidad es la
que detecta un bloque que no llegó a ejecutarse.

### 8.3 Guardián probado por inyección

| Inyección | Resultado |
|---|---|
| Abortar el bloque K en la versión final de 11 bloques | `no terminaron: ["K"]`, 82 → **76** checks, **EXIT 1** |
| Poner la constante del marcador a un valor inexistente | **9 fallos** en el suite del validador (el mecanismo se prueba de verdad) |
| Quitar el marcador de `M68.TRIP.CURRENCY` en **ambos** catálogos | `FALLO: sin entradas sin traducir -> ["M68.TRIP.CURRENCY"]` |

### 8.4 Cifras medidas

| Medición | Resultado |
|---|---|
| Expansión es→en sobre las 170 claves bilingües | media **0,934**, máxima **1,529**; **5 de 170** por encima del +30 % |
| Claves que desbordan el contenedor 220×40 a **16 px** | **63 de 170** |
| Ídem a **12 px** / **24 px** (escala M58 0,8–1,5) | **0** / **97** |
| Palabra sin espacios antes/después de `partir_palabra` | **237 px** (no cabe) → **219 px** (cabe) |
| Re-traducción de un HUD de 120 labels | **1,4–2,0 ms** (presupuesto 16,67 ms/frame) |
| Nodos traducidos/saltados en un árbol de prueba de 4 nodos | 1 traducido, **2 saltados**, 1 sin clave |
| Consistencia de glosario sobre los catálogos reales | **0 inconsistencias** (17 términos, 17 en uso) |
| Entradas de `es.po` / `en.po` | **171 / 171** (170 claves + cabecera) |
| Exenciones P5 declaradas | **13** (11 plantillas de cartel + `AO` + `{h} h {m} min`) |

### 8.5 Defecto real corregido — 13 claves rotas en P5

Al empezar la iteración, `test_validador_po_m87.gd` **estaba en rojo** (1 fallo): 13 claves `M68.*` que la
iter. 2 de M68 (Log 910) añadió a los catálogos tienen el `msgstr` **idéntico** entre español e inglés, y la
regla P5 lo reporta como "sin traducir".

No es un olvido de traducción: son textos **sin palabras que traducir**.

| Claves | Valor | Por qué es idéntico |
|---|---|---|
| `M68.SIGN.GENERICO` + 10 `M68.SIGN.<estación>` | `→ {destino} · {metros} m` | Flecha, distancia y unidad: no hay palabras |
| `M68.TRIP.CURRENCY` | `AO` | Código de divisa |
| `M68.TRIP.HORAS_MINUTOS` | `{h} h {m} min` | Sólo unidades de tiempo |

**Arreglo (sin debilitar la regla):** se implementó en `ValidadorPO` el marcador estándar de traductor
gettext `#. no-traducir: <motivo>`. Una entrada marcada sale de `no_traducidas` y se lista aparte en
`exentas_p5`, de modo que la exención es **auditable** y no un agujero negro. Se marcaron las 13 entradas en
`es.po` y `en.po`. El bloque I del suite prueba la regla en las dos direcciones con fixtures sintéticos (no
depende del estado de los catálogos reales) y luego la contrasta con el par real.

### 8.6 Trampas nuevas medidas

1. **`Font.get_string_size(texto, align, ancho, size)` con ancho POSITIVO trunca a ese ancho y devuelve la
   altura de UNA sola línea.** Para texto con salto de línea hay que usar `get_multiline_string_size()`.
   Medido con `"Settings of the island game"` a 60 px: `(55, 23)` con `get_string_size` (parece que cabe)
   frente a `(67, 92)` con `get_multiline_string_size`. Una palabra sin cortes da `(56, 23)` (recortada)
   frente a `(427, 23)` (real). Una comprobación de encaje escrita con `get_string_size` informa
   **"todo cabe"**: misma forma de falso verde que la trampa 51.
2. **`FileAccess` en Godot 4 no tiene `.eof()`** (usar `get_length()` + `get_position()`). El `SCRIPT ERROR`
   aborta la función en silencio y, con `extends SceneTree`, **cuelga el árbol para siempre**: se mató a los
   2 m 7 s porque `quit()` nunca se alcanzó y la salida se perdió por buffering. El watchdog lo convierte en
   `EXIT=1` limpio.
3. **`load()` de una fuente corrupta NO devuelve `null`**: devuelve un `FontFile` con las métricas en cero,
   así que `if fuente != null` no detecta el problema — hay que **medir**.

### 8.7 Bug registrado

**BUG-042** — 3 de las 4 fuentes de `assets/fonts/` son páginas HTML "404 Not Found" de GitHub guardadas con
extensión `.ttf` (`magic 0a0a0a0a`, 99,8 % de bytes imprimibles). Sólo `Nunito-Variable.ttf` es una fuente
real. El fallo es silencioso por la trampa 3. Dueño: **M46/M88**. Registrado en `11-BUGS.md`.

### 8.8 Pendientes con dueño (actualizado)

| Pendiente | Dueño | Tipo |
|---|---|---|
| Absorber el desborde medido (63/170 claves a 16 px; 97/170 a 24 px) | **M53** | Layout |
| Adoptar el metadato `text_key` / `tooltip_text_key` en los labels de UI | **M53** | Integración |
| Usar `LocaleUtils.format_date/format_hora` en reloj y calendario | **M29/M30** | Integración |
| Migrar los 26 módulos de contenido a claves M87 | **M14-M39** | Contenido |
| Eliminar o marcar obsoleto el autoload duplicado `LocalizationManager` | Decisión del usuario | Refactor transversal |
| Parsear `Plural-Forms` de la cabecera (idiomas con 3+ formas) | M87 (deuda) | Robustez |
| Unificar la lista de idiomas (`LOCALES_SOPORTADOS` / `LocaleUtils`) | M87 (deuda) | Refactor |
| Revisión humana de los textos provisionales | Traductor humano | Revisión (RN9) |
| Arreglar las fuentes de `assets/fonts/` (BUG-042) | **M46/M88** | Assets |

> **Nota de honestidad:** la QA visual sigue sin hacerse y no se disimula: 3 de las 4 fuentes del proyecto
> son páginas HTML 404, así que no hay nada fiable que mirar. Lo que sí se hizo fue convertir en **medición**
> todo lo que admitía medición. Los 7 ítems `[?]` del checklist tienen dueño nombrado; ningún `[x]` de esta
> iteración se apoya en una impresión.
