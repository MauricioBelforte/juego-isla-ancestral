# Log 874: M87 Localización — iteración 5 (validador .po + auditoría código↔catálogo) — DeepSeek-V4.1-Flash

**Fecha:** 2026-09-13
**Hora:** 17:25
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Módulo:** M87 Localización
**Iteración:** 5
**Estado del módulo:** 🟡 Liberado (120/136 `[x]`; los 16 pendientes son UI/visión/arte/decisión)
**Modalidad:** §21.4.7 — reclamo por inactividad del dueño anterior (`deepseek-v4-flash`, última actividad 2026-09-04)

## Resumen

Iteración centrada en **verificación**: convertir RF21 ("validación de catálogos") y RF20 ("convención de claves") de enunciados documentados a **reglas ejecutables**, y usar ese instrumento para auditar el módulo. Resultado: 3 archivos nuevos, 5/5 suites en verde, **7 claves que la UI pedía y no existían** corregidas, un defecto de rendimiento real corregido en el núcleo, una regresión preexistente reparada y 10 hallazgos documentados con dueño.

## Qué se hizo

### 1. Herramientas nuevas (RF21 / RF20 ejecutables)

| Archivo | Qué es |
|---|---|
| `scripts/localization/validador_po.gd` (`class_name ValidadorPO`) | Reglas **R1-R13** por catálogo: BOM (§28), CRLF (RN10), UTF-8 válido, cabecera Content-Type/Language/Plural-Forms, `msgid`↔`msgstr`, plurales contiguos desde 0, `msgid` duplicados, convención RF20 con excepciones, mezcla de placeholders. Reglas **P1-P5** por par de idiomas: faltantes, huérfanas, placeholders desalineados, entradas sin traducir. `formatear_informe()` para consola/CI |
| `scripts/localization/auditor_claves.gd` (`class_name AuditorClaves`) | Inventario claves código↔catálogo. Reconoce `_t()`, `traducir_clave()`, `tr_key()`, `tr_ctx()`; detecta prefijos dinámicos; separa los probes que solo aparecen en tests; veredicto sobre **código de producción**. `auditar_texto()` permite auditar un diff |
| `scripts/localization/test_validador_po_m87.gd` | 8 bloques, fixtures sintéticos en `user://` + catálogos reales. **0 fallos, 0 errores de script** |

### 2. Defecto real corregido en el núcleo: tormenta de avisos

Medición directa de 200 llamadas en headless:

| Escenario | Tiempo |
|---|---|
| Clave existente (`SETTINGS.PAUSA`) | **333 µs** (1,6 µs por traducción — la cache funciona) |
| Clave ausente (`MENUS.SALUDOS.HOLA`) | **16.774 µs** (≈16 ms de **un solo** `push_warning` con backtrace + 199 aciertos) |

El coste no era la cache: era el aviso. **Corregido:** `_avisar_faltante()` deduplica por clave y sesión; se expone `claves_faltantes()` para dev/CI. Antes, una clave ausente en un path caliente producía un hitch por llamada.

### 3. 7 claves que la UI invocaba y no existían (corregidas)

La UI mostraba la **clave cruda** en pantalla; confirmado de forma independiente en el log de arranque (`[M87] Clave sin traducción: DIARY.CAT_PERSONAJES`).

| Clave | Consumidor |
|---|---|
| `DIARY.CATEGORIAS`, `DIARY.ENTRADAS`, `DIARY.SIN_ENTRADAS` | `diary_layer.gd` |
| `LOADING.TITULO`, `LOADING.CARGANDO`, `LOADING.TIP` | `loading_layer.gd` |
| `SETTINGS.FUERA_TEMPORADA` | `crafting_ui.gd` |

Más las **14** variantes dinámicas `DIARY.CAT_<CATEGORÍA>` (lista real en `DiaryService.CATEGORIAS`). `es.po`/`en.po`: 64 → **85 claves**. Textos **provisionales** (revisión humana RN9).

### 4. Regresión preexistente reparada

`test_localizacion_iter2._test_cache` **fallaba de forma estable** (31-48 ms contra un umbral de 20 ms) al empezar la iteración. Causa: medía la cache con una clave **ausente**, así que el umbral lo incumplía el `push_warning`. Corregido para medir con clave existente y verificar el dedup. También se reemplazó `_cache.size() >= 0` (aserción que no podía fallar) por `>= 1`.

### 5. Higiene y documentación

- **AGENTS.md §28:** BOM eliminado de `localization_manager.gd` y `test_localization.gd`. `scripts/localization/` queda **100 % UTF-8 sin BOM + LF** (verificado byte a byte).
- **`es.po`/`en.po`:** UTF-8 sin BOM, LF (199/198 saltos, 0 CRLF).
- **Doc↔código sincronizado** (8 discrepancias reales corregidas):
  - `02-Analisis.md` §1.4: `format_text` **no** usa regex `\{\w+\}` sino `String.replace` con guarda de llaves. §1.5: `Plural-Forms` **no** se parsea. §1.8: el proyecto **no** tiene sección `internationalization` (la afirmación del fallback de editor era falsa) y **no** existe `TranslationValidator`. §4 nuevo con los hallazgos.
  - `03-Diseno.md` §2.1.1: el núcleo **no** usa `load()` sobre el `.po` (construye `Translation.new()` + `add_message`). §2.1.3: `tr_cached` no existe. §2.3: el código **sí** aplica y persiste la sugerencia del SO sin confirmación (contradecía el diseño). §2.5: `SUPPORTED_LOCALES` → `LOCALES_SOPORTADOS`. §3.3.3/§3.4.2: mecanismo y API reales.
  - Firmas normalizadas a `DeepSeek-V4.1-Flash` / `WorkBuddy` en 01/02/03/04.

## Evidencia de ejecución

```
test_localization            err=0 | === TEST M87 LOCALIZACION: 0 fallo(s) ===
test_localizacion_iter2      err=0 | === TEST M87 ITER2: 0 fallo(s) ===
test_localizacion_iter3      err=0 | === TEST M87 ITER3: 0 fallo(s) ===
test_localizacion_iter4      err=0 | === TEST M87 ITER4: 0 fallo(s) ===
test_validador_po_m87        err=0 | === TEST M87 ITER5 (validador .po): 0 fallo(s) ===

── AuditorClaves: 702 archivo(s), 54 clave(s) usadas, 85 en catálogo
USADAS EN CÓDIGO PERO AUSENTES DEL CATÁLOGO (0)
AUSENTES PERO SOLO USADAS POR TESTS (probes) (3)
EN EL CATÁLOGO, USADAS POR PREFIJO DINÁMICO (14)
EN EL CATÁLOGO SIN USO LITERAL NI DINÁMICO (23)
RESULTADO: OK
```

Comando: `Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral --script res://scripts/localization/<suite>.gd`

## Hallazgos registrados (con dueño, no ocultados)

| # | Hallazgo | Sev. | Destino |
|---|---|---|---|
| H-1 | **Autoload duplicado**: `Localization` (`.po`) y `LocalizationManager` (JSON, `scripts/localizacion/`) coexisten; el segundo **no lo consume ningún módulo de producción** | Media | Decisión del usuario / refactor transversal |
| H-2 | 7 claves de producción ausentes del catálogo | Alta | **Corregido** |
| H-3 | `push_warning` sin deduplicar (~16 ms por aviso) | Media | **Corregido** |
| H-4 | Dos convenciones de placeholder coexisten (`{clave}` y `%s`/`%d`) | Baja | Documentado; vigilado por R12/P3 |
| H-5 | `Plural-Forms` no se parsea (regla hardcodeada es/en) | Media | Deuda M87 |
| H-6 | Lista de idiomas duplicada en 3 lugares | Media | Deuda M87 |
| H-7 | 5 strings hardcodeados en UI (`equipment_ui.gd`, `equipment_layer.gd` ×3, `interact_prompt.gd`) | Media | M53 / módulo de equipamiento |
| H-8 | `format_date`/`format_hora`/`format_number` **sin consumidores** | Media | M29/M30 |
| H-9 | `SETTINGS.*` sobrecargado | Baja | M87 + M53 |
| H-10 | 23 claves del catálogo sin uso (claves-semilla) | Baja | M53/M21 — no se borran |

## Lo que NO se hizo (honestidad)

- **No se eliminó el autoload duplicado (H-1)**: es un cambio transversal que puede afectar a otro módulo; se registra para decisión.
- **No se parseó `Plural-Forms` (H-5)** ni se unificó la lista de idiomas (H-6): deuda técnica documentada.
- **No se tocaron los 5 strings hardcodeados de UI (H-7)**: son archivos de otro módulo.
- **No se hizo QA visual**: los 16 pendientes del checklist requieren UI/visión (V1/V2/V5), arte (M46) o decisión.
- **Los textos agregados son provisionales** (RN9, revisión humana pendiente).

## Pendientes con dueño

| Pendiente | Dueño |
|---|---|
| Decidir sobre el autoload duplicado (H-1) | Usuario / dueño del módulo |
| Parsear `Plural-Forms` (H-5) y unificar la lista de idiomas (H-6) | M87 (deuda) |
| Traducir los 5 strings hardcodeados de UI (H-7) | M53 / equipamiento |
| Consumir la API de formato localizado (H-8) | M29/M30 |
| Revisión humana de los textos provisionales | Traductor humano |
| Desbordes de texto en inglés (+30%) y selector visual | M53 + QA visual |

## Archivos tocados

**Nuevos:** `scripts/localization/validador_po.gd`, `scripts/localization/auditor_claves.gd`, `scripts/localization/test_validador_po_m87.gd`
**Modificados:** `scripts/localization/localization_manager.gd` (dedup de avisos, `claves_faltantes()`, BOM, LF), `scripts/localization/test_localizacion_iter2.gd` (test de cache), `scripts/localization/test_localization.gd` (BOM), `locales/es.po`, `locales/en.po` (+21 claves), `DOCUMENTACION/87-Localizacion/plan-actual/{01,02,03,04,05,06,07}`
**Registro:** `CHECKLIST-GLOBAL.md` (fila 87), `Mensajes entre modelos/ESTADO-PARALELO.md`

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
