# Log 920 — M87 Localización, iteración 6 (encaje de texto, glosario y re-traducción selectiva)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-15
**Módulo:** 87-Localizacion
**Reserva:** `Logs/reservas/920-DSV41F-M87.txt` (borrada al cerrar)
**Entrada:** `120 [x] · 0 [?] · 16 [ ] = 136` (fila 87: `🔵 En curso`, última actividad 2026-09-12, Log 874)
**Salida:** `129 [x] · 7 [?] · 0 [ ] = 136` (fila 87: `129/136`)
**Suites:** 6/6 en verde · 82 checks nuevos, 0 fallos ×3 · 0 `SCRIPT ERROR`

---

## 1. De dónde venía el módulo

La iter. 5 (Log 874) había dejado **16 `[ ]` propios**, todos clasificados como "visual / QA visual / decisión /
otro módulo". La lectura honesta de esa clasificación era incómoda: **varios de esos ítems no eran visuales,
eran no medidos**. "Textos largos en inglés sin desbordes" no requiere un ojo: requiere métricas de fuente.

La pregunta que abrió la iteración fue: **¿se puede medir texto en headless?** La respuesta medida es sí.

## 2. El hallazgo que habilitó todo

`TextServerAdvanced` está registrado y `ThemeDB.fallback_font` mide correctamente:

| Medición | Resultado |
|---|---|
| `get_string_size("Jugar", LEFT, -1, 16)` | **41 × 23 px** |
| altura de línea a 16 px / 24 px | **23,0** / **34,0** |
| `get_multiline_string_size("Settings of the island game", LEFT, 60.0, 16)` | **67 × 92** (envuelve) |

Esto convirtió tres ítems marcados como "QA visual" en **verificables, deterministas y repetibles en CI**.
Medición sin motor gráfico: sí. Aprobación estética: no, y no se pretende.

## 3. Lo que se construyó

| Archivo | Qué es |
|---|---|
| `scripts/localization/analizador_layout.gd` (nuevo, `AnalizadorLayout`) | Medición real de texto: `medir`, `medir_linea`, `altura_linea`, `cabe`, `razon_expansion`, `palabras_largas`, `partir_palabra` (cortes de ancho cero U+200B), `truncar_con_puntos`, `tamano_minimo_que_cabe`, `estrategia`, `analizar`, `formatear_informe` |
| `scripts/localization/glosario.gd` (nuevo, `Glosario`) | Consistencia terminológica: `cargar`, `normalizar`, `es_termino`, `contiene_palabra`, `verificar`, `formatear_informe` |
| `data/localization/glosario.json` (nuevo) | 17 términos canónicos es/en con variantes inglesas aceptadas |
| `scripts/localization/retraductor_ui.gd` (nuevo, `RetraductorUI`) | Re-traducción selectiva: decisión PURA `debe_retraducir()` + recorrido iterativo del árbol + coste medido |
| `scripts/localization/localization_manager.gd` (modificado) | `catalogo(locale)` y `claves_catalogo(locale)`: acceso de SOLO LECTURA al catálogo cargado |
| `scripts/localization/test_localizacion_iter6.gd` (nuevo) | 11 bloques (A–K) + guardián con watchdog |
| `scripts/localization/validador_po.gd` (modificado) | Exención P5 declarada en el propio `.po` (`#. no-traducir:`) + `exentas_p5` auditable |
| `scripts/localization/test_validador_po_m87.gd` (modificado) | Bloque I nuevo (14 checks) sobre la exención |

`RetraductorUI` es el **primer consumidor real** de la señal `locale_changed` del autoload `Localization`.

## 4. Cifras medidas (no estimadas)

| Medición | Resultado |
|---|---|
| Expansión es→en sobre las 170 claves bilingües | media **0,934**, máxima **1,529**; **5 de 170** por encima del +30 % |
| Claves que desbordan el contenedor de referencia 220×40 a **16 px** | **63 de 170** |
| Ídem a **12 px** / **24 px** (escala `ui_scale` 0,8–1,5 de M58) | **0** / **97** |
| Palabra sin espacios antes/después de `partir_palabra` | **237 px** (no cabe) → **219 px** (cabe) |
| Re-traducción de un HUD de 120 labels | **1,4–2,0 ms** (presupuesto 16,67 ms/frame) |
| Árbol de prueba de 4 nodos | 1 traducido, **2 saltados** (invisible + fuera de pantalla) |
| Consistencia de glosario sobre los catálogos reales | **0 inconsistencias** (17 términos, 17 en uso) |
| Entradas de `es.po` / `en.po` | **171 / 171** (170 claves + cabecera) |

## 5. Verificación

### 5.1 Las 6 suites

| Suite | Resultado | `SCRIPT ERROR` |
|---|---|---|
| `test_localization.gd` (núcleo) | 0 fallos, exit 0 | 0 |
| `test_localizacion_iter2.gd` | 0 fallos, exit 0 | 0 |
| `test_localizacion_iter3.gd` | 0 fallos, exit 0 | 0 |
| `test_localizacion_iter4.gd` | 0 fallos, exit 0 | 0 |
| `test_validador_po_m87.gd` (iter. 5 + bloque I) | 0 fallos, exit 0 | 0 |
| `test_localizacion_iter6.gd` (nueva) | **82 checks, 0 fallos, exit 0** ×3 | 0 |

### 5.2 Desglose MEDIDO (no copiado)

`A9 + B5 + C8 + D9 + E5 + F6 + G6 + H6 + I12 + J9 + K6 = 81`, más 1 del guardián = **82** ✓
La suma de los `(+N checks)` impresos por `_fin()` coincide con el total del `=== Resumen ===`. Esa identidad
es la que delata un bloque que no llegó a ejecutarse.

### 5.3 Guardián probado por inyección

| Inyección | Resultado |
|---|---|
| Abortar el bloque K en la versión final de 11 bloques | `no terminaron: ["K"]`, 82 → **76** checks, **EXIT 1** |
| Poner la constante del marcador a un valor inexistente | **9 fallos** (el mecanismo se prueba de verdad) |
| Quitar el marcador de `M68.TRIP.CURRENCY` en **ambos** catálogos | `FALLO: sin entradas sin traducir -> ["M68.TRIP.CURRENCY"]` |

## 6. Regresión real encontrada y reparada

`test_validador_po_m87.gd` (iter. 5) **estaba en rojo** al empezar la iteración: 13 claves `M68.*` que la
iter. 2 de M68 (Log 910) había añadido a los catálogos tienen el `msgstr` **idéntico** entre español e inglés,
y la regla P5 lo reporta como "sin traducir".

No es un olvido de traducción: son textos **sin palabras que traducir**.

| Claves | Valor | Por qué es idéntico |
|---|---|---|
| `M68.SIGN.GENERICO` + 10 `M68.SIGN.<estación>` | `→ {destino} · {metros} m` | Flecha, distancia y unidad |
| `M68.TRIP.CURRENCY` | `AO` | Código de divisa |
| `M68.TRIP.HORAS_MINUTOS` | `{h} h {m} min` | Sólo unidades de tiempo |

**Arreglo, sin debilitar la regla:** marcador estándar de traductor gettext `#. no-traducir: <motivo>` en
`ValidadorPO`. Una entrada marcada sale de `no_traducidas` y se lista aparte en **`exentas_p5`**, de modo que
la exención es **auditable** y no un agujero negro. 13 entradas marcadas en `es.po` y `en.po`. El bloque I del
suite prueba la regla en las dos direcciones con fixtures sintéticos (no depende del estado de los catálogos
reales) y luego la contrasta con el par real.

**No se tocó M68:** el defecto era de la heurística de validación, no del contenido.

## 7. BUG-042 — las fuentes del proyecto son páginas HTML 404

| Archivo | `magic` | Realidad |
|---|---|---|
| `Nunito-Variable.ttf` | `00010000` | Fuente real (mide 37 × 23 px) |
| 3 archivos restantes | `0a0a0a0a` | **Página "404 Not Found" de GitHub**, 99,8 % bytes imprimibles |

El fallo es **silencioso**: `load()` de una fuente corrupta **no devuelve `null`**, devuelve un `FontFile` con
las métricas en cero, así que `if fuente != null` no detecta nada. Hay que medir.
`fonts.json` ya declaraba `tiene_archivo: false` en las cuatro — la pista estaba en los datos.
**Dueño: M46/M88.** Detalle en `DOCUMENTACION/11-BUGS.md`.

## 8. Trampas nuevas medidas (55–57, al skill del proyecto)

1. **`Font.get_string_size(texto, align, ancho, size)` con ancho POSITIVO trunca a ese ancho y devuelve la
   altura de UNA sola línea.** Para texto con salto hay que usar `get_multiline_string_size()`.
   Medido con `"Settings of the island game"` a 60 px: `(55, 23)` con `get_string_size` (parece que cabe)
   frente a `(67, 92)` con `get_multiline_string_size`. Una palabra sin cortes: `(56, 23)` (recortada)
   frente a `(427, 23)` (real). Una comprobación de encaje escrita con `get_string_size` informa
   **"todo cabe"** — misma forma de falso verde que la trampa 51. Este error **se cometió y se corrigió** en
   esta misma iteración: la primera versión de `medir()` mentía y reportaba 0 desbordes.
2. **`FileAccess` en Godot 4 no tiene `.eof()`**: usar `get_length()` + `get_position()`. El `SCRIPT ERROR`
   aborta la función en silencio y, con `extends SceneTree`, **cuelga el árbol para siempre** — se mató el
   proceso a los **2 m 7 s** porque `quit()` nunca se alcanzó y la salida se perdió por buffering. El watchdog
   `_process` lo convierte en un `EXIT=1` limpio.
3. **`load()` de una fuente corrupta no devuelve `null`** (ver §7).

## 9. Lo que NO se hizo (honestidad obligatoria)

- **No se verificó visualmente nada.** 3 de las 4 fuentes del proyecto son páginas HTML 404 (**BUG-042**),
  así que la QA visual está bloqueada de hecho, no por comodidad. Donde no se puede mirar, se mide.
- **No se arreglaron los layouts.** El desborde medido (63/170 a 16 px) es trabajo de **M53**; M87 aporta la
  medición y la lista.
- **No se tradujo contenido narrativo:** los textos siguen siendo provisionales hasta la revisión humana (RN9).
- **No se eliminó el autoload duplicado `LocalizationManager`** (hallazgo H-1): es una decisión transversal.
- **No se tocó M68** (ver §6).

## 10. Los 7 `[?]` (con dueño y motivo)

| Ítem | Dueño |
|---|---|
| Accesibilidad de texto de M58 sin romper layouts | **M53** (medido: 0/63/97 desbordes a 12/16/24 px) |
| Revisión humana de las traducciones | **Usuario** (no automatizable) |
| Integrar M53: labels con `tr_key` | **M53** (mecanismo provisto y probado) |
| Integrar M53: tooltips y descripciones | **M53** (ruta `tooltip_text_key`) |
| Integrar M58: tamaño de texto ajustable | **M53** (la herramienta responde de forma monótona) |
| Integrar M14-M39: contenido con claves M87 | **26 módulos de contenido** |
| Integrar M29/M30: fechas y horas localizadas | **M29/M30** (`LocaleUtils` listo y probado) |

## 11. Registros actualizados

- `DOCUMENTACION/87-Localizacion/plan-actual/05-Checklist.md` — 129 `[x]` · 7 `[?]` · **0 `[ ]`** + bloque de
  historial de la iteración 6 (sin checkboxes, para no falsear el conteo).
- `DOCUMENTACION/87-Localizacion/plan-actual/04-Codigo.md` — §2/§4/§5/§8 **corregidas** (describían archivos
  previstos bajo `res://localizacion/` marcados "Pendiente de implementación" que no existen) + notas de iter. 6.
- `DOCUMENTACION/87-Localizacion/plan-actual/06-Plan-Testings.md` — §4.7 con los casos CP-37..CP-66.
- `DOCUMENTACION/87-Localizacion/plan-actual/07-Resultados-Testings.md` — §8 con los resultados y las cifras.
- `CHECKLIST-GLOBAL.md` — fila 87 → `129/136`, fecha 2026-09-15 (solo esa fila).
- `Mensajes entre modelos/ESTADO-PARALELO.md` — sección de cierre.
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md` — M87 marcado.
- `DOCUMENTACION/11-BUGS.md` — BUG-042 (fila + detalle).
- `.github/workflows/quality.yml` — **las 6 suites cableadas** (antes solo estaba `test_localizacion_m87.gd`
  de `scripts/localizacion/`; ninguna suite de `scripts/localization/` estaba en CI). YAML validado.
- `python scripts/verificar_checklist.py --checklist CHECKLIST-GLOBAL.md` → M87 **sin inconsistencias**.

## 12. Pendiente para otro modelo

⏳ **QA cruzado §21.8 de M87 iter. 6** — nunca auto-QA (verificador ≠ autor). Sigue pendiente también el de
**M103 iter. 1** y **M60 iter. 4**.
