**Modelo:** mimo-v2.6-flash-free (último modificador; base por Deepseek V4 Flash)
**Plataforma:** opencode

# 04-Codigo.md — Módulo 55: Diario del Jugador

## 1. Archivos Involucrados

### 1.1 Archivos REALES en disco (iter. 1 + iter. 2, verificados 2026-10-04)

| Archivo | Ruta | Rol | Origen |
|---|---|---|---|
| `diary_service.gd` | `scripts/diario/` | Autoload: registro/estado/favoritos/búsqueda/%/persistencia (ISaveProvider M59) | iter. 1 (glm, Log 374) |
| `diary_layer.gd` | `scripts/ui/layers/` | Capa MODAL_FULL: pestañas 14, lista, filtros, detalle, favoritos, i18n | iter. 2 (mimo, este log) |
| `diario_catalog.json` | `data/diario/` | 14 categorías, 44 entradas, claves `{id, titulo}` | iter. 1 |
| `test_diario.gd` | `scripts/diario/` | Suite del servicio: registro, 6 puentes de eventos, anti-spoiler, %, persistencia | iter. 1 |
| `test_diario_ui.gd` | `scripts/ui/` | Suite de la capa: 89 checks (estructura, filtros, i18n, favoritos, pila, edge cases) | iter. 2 |
| `ui_manager.gd` | `scripts/ui/core/` | Wiring: bloque `diario`/`favorito` en `_unhandled_input` + fix `close_top` (capa visible) | iter. 2 |
| `es.po` / `en.po` | `locales/` | +19 claves `DIARY.*` por idioma (36 totales nuevas) | iter. 2 |
| `project.godot` | raíz `game/isla-ancestral/` | Acción de input `diario` (tecla J, physical 74 / unicode 106) | iter. 2 |

### 1.2 Archivos del diseño original (PLAN — aún no existen)

| Archivo | Ruta (plan) | Estado |
|---|---|---|
| `diary_entry.gd` | `Assets/_Project/Diary/data/` | pendiente (entradas = Dictionary) |
| `diary_catalog.tres` | `Assets/_Project/Diary/data/` | reemplazado por JSON (iter. 1) |
| `diary_save.gd` | `Assets/_Project/Diary/service/` | integrado en `diary_service.gd` |
| `diary_screen/list_item/detail.gd` | `Assets/_Project/Diary/ui/` | unificados en `diary_layer.gd` |
| `validate_diary.gd` | `Assets/_Project/Diary/validators/` | **NO creado** (checklist Y) |

## 2. Funciones Clave y Logs Relacionados

### 2.1 `diary_service.gd`
```gdscript
func on_event(event: DiaryEvent) -> void:
    # Filtra el evento por categoría y actualiza la entrada del catálogo
    var entry: DiaryEntry = _entries.get(event.id)
    if entry == null: return  # sistema ajeno al diario
    _mark(entry, event.new_state)
    DiarySignals.diary_updated.emit(event.id)
    LOGS.diary("DIARY-ADD", {"id": event.id, "cat": entry.category})

func get_percent_discovered(category: String) -> float:
    # % sobre lo DESCUBIERTO (nunca revela totales ocultos)
    var total: int = _catalog.totals[category]
    var done: int = _count_done(category)
    return total == 0 ? 0.0 : (float(done) / float(total)) * 100.0
```
**Logs:** `DIARY-ADD` (entrada nueva), `DIARY-OPEN` (apertura), `DIARY-SAVE` (persistencia), `DIARY-SPOILER-WARN` (intento de revelar contenido oculto — solo debug).

### 2.2 `diary_save.gd`
```gdscript
func save() -> void:
    var data := {"schema_version": 1, "entries": _collect_states()}
    GameState.diary = data  # GameState central (M59/M60)
    LOGS.diary("DIARY-SAVE", {"size_kb": data.to_json().length() / 1024.0})

func load_safe(raw: Variant) -> void:
    # Migración + carga defensiva (M60): nunca falla si falta una categoría
    if raw == null: return
    _migrate(raw)  # schema_version → versiones nuevas
    _apply_states(raw.entries)
```

### 2.3 `diary_screen.gd`
```gdscript
func _open() -> void:
    _tabs.set_current(0)  # apertura en la primera pestaña
    _refresh(_tabs.current)  # virtualización: solo la lista visible
    LOGS.diary("DIARY-OPEN", {})

func _nav(category: String, id: String) -> void:
    # Navegación en 2 clics: pestaña → entrada
    _list_virtual.select(id); _detail.show(id)
```

## 3. Contratos de Integración (Eventos del EventBus M07)

| Evento | Emisor | → Diario |
|---|---|---|
| `NPC_CONOCIDO` | M19 | Entrada personaje → visto |
| `LUGAR_VISITADO` | M09 | Entrada lugar → visto |
| `ESPECIE_AVISTADA` | M36/M65 | Entrada criatura → visto |
| `PLANTA_IDENTIFICADA` | M50 | Entrada planta → visto |
| `MINERAL_DESCUBIERTO` | M35 | Entrada mineral → visto |
| `RECETA_DESBLOQUEADA` | M16 | Entrada receta → visto |
| `PISTA_LEIDA` | M24 | Entrada pista → visto + releíble |
| `SELLO_OBTENIDO` | M22 | Entrada Sello → completado |
| `RUIDA_PROGRESADA` | M25 | Entrada ruina → estado 1-4 |
| `CARTA_RECIBIDA` | M74 | Entrada carta → visto |
| `DESCUBRIMIENTO` | M71 | Entrada descubrimiento → visto |
| `MISION_CAMBIADA` | M22/M23 | Entrada misión → activa/completada |
| `EVENTO_OCURRIDO` | M74/M29 | Entrada evento → visto |
| `FOTO_TOMADA` | M56 | Entrada fotografía → vista (galería) |

## 4. Logs Relacionados (Sistema de Logs del Proyecto)

El diario usa el sistema central de logs de consola (M118): prefijo `[DIARY]` para desarrollo y un canal depurado en builds (sección 18 de AGENTS.md); rotación automática fuera de `Assets/`.

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Parcial (con dudas)

### Lo que hice
- Documenté el módulo 55 completo (diseño técnico de Godot 4): modelo de entradas, catálogo, DiaryService, persistencia, UI con virtualización, anti-spoilers, % de completado sobre descubierto, validación y contratos de eventos.

### Lo que NO pude hacer (honestidad obligatoria)
- `[?]` Verificar en runtime: no hay editor Godot ni build en este entorno; los archivos `.gd` de esta documentación son prototipos de diseño que se escribirán en la fase de implementación (los módulos de diseño se implementan al final según el flujo de producción del proyecto).
- `[?]` Confirmar el total de entradas por categoría con los números finales de M16/M19/etc.: los valores de la tabla 3.1 son estimaciones del plan maestro; el catálogo real se ajustará cuando existan los catálogos de los módulos fuente.

### Intentos fallidos / decisiones
- Decidí la regla "anti-spoiler estricta": entradas no descubiertas invisibles (ni atenuadas), a diferencia de la convención común de mostrar siluetas "???" — el plan maestro exige "Evitar spoilers automáticos".
- Decidí % de completado sobre lo DESCUBIERTO en la UI (para no filtrar el conteo oculto); los logros (M72) usan el total real fuera del diario.

### Recomendaciones para el próximo agente
- Al implementar: verificar el contrato de eventos del EventBus (M07) y que cada sistema emisor tenga el evento documentado.
- Testear el caso de 500+ entradas con virtualización (M61) y el cierre sin lag.
- Revisar el mapeo de categorías vs. los catálogos reales de M16/M19/M36/M50/M35/M24/M25/M26/M22/M23/M71/M74/M56 en la fase de implementación.

---

## Notas del Agente — Iteración 1 núcleo (historial, no borra las anteriores)

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 12:20:00
**Estado:** Parcial (núcleo de registro/consulta implementado y verificado; módulo liberado 🟡)
**Log:** 374 (renumerado desde 327 — ver Log 375)

### Lo que hice
- DiaryService autoload (scripts/diario/diary_service.gd): catálogo data-driven de las 14 categorías (data/diario/diario_catalog.json, 33 entradas base con ids reales de M19/M22/M28/M29/M34/M16/M15/M25), registro con validación (existe en catálogo; idempotente con promoción VISTO→COMPLETADO), marcar_completado/alternar_favorito/estado_de, entradas_de() con anti-spoiler §3.2 (no descubierto invisible; secreta visible como ???), buscar() solo sobre lo descubierto, progreso_categoria/get_progreso sobre lo DESCUBIERTO, nuevas_sesion para la notificación "¡Diario actualizado!" (M53/M44).
- Registro por eventos REALES de M07 (puentes conectados en _ready): quest.prereq_met→sellos (M22), npc.npc_moved_in→personajes (M19), quest.quest_completed→misiones, travel.island_loaded→lugares (M28), calendar.season_changed→eventos (M29), npc.carta_recibida→cartas (M74). Normalización _slug() (minúsculas + sin tildes: "Otoño"→"otono") para ids compuestos.
- Dominio diary en EventBus M07 (aditivo): entrada_nueva/categoria_completa/progreso_cambiado — M53/M44 notifican, M72 consume %.
- Persistencia ISaveProvider M59 sección "diary" (schema_version 1, < 5 KB típico §3.3): entradas con estado/favorito/día de registro; huérfanas de catálogos viejos purgadas con log al cargar.
- Test test_diario.gd: catálogo, registro manual + idempotencia + promoción, 6 integraciones por señal real, anti-spoiler, progreso sobre descubierto, favoritos, búsqueda, persistencia con huérfana → **0 fallos**.
- Regresiones: test_historia M22 0 fallos, test_mudanzas M19 0 fallos, test_viajes M28 0 fallos (los emisores de las señales que consume el diario).
- Checklist: progreso relevado (ítems del núcleo implementados).

### Lo que NO pude hacer (honestidad obligatoria)
- UI del diario (diary_screen/list_item/detail de M53, pestañas, virtualización M61): V2 con visión — las señales y consultas quedan listas.
- Fotografías (categoría M56): la categoría existe en catálogo con entradas dinámicas; el enganche con M56 es del dueño.
- Entradas de fauna (M36 🟢), minerales con avistamiento real (M35), recetas con desbloqueo real (M16 [?]): el catálogo tiene las entradas base; cuando esos módulos emitan, se agregan puentes de 1 línea (patrón _conectar_eventos).
- M72 logros con % REAL: get_progreso() expone sobre-descubierto; el % real para logros requiere sumar no-descubiertas (función aparte pendiente con M72).

### Recomendaciones para el próximo agente
- M53: pantalla escucha diary.entrada_nueva para el toast sutil y lee entradas_de(categoria)/progreso_categoria() para pestañas.
- M36/M35/M16: al emitir avistamientos/desbloqueos, conectar 1 puente en _conectar_eventos() (patrón de los 6 existentes) y agregar entradas al JSON.
- El catálogo escala SIN tocar código: nueva entrada = nueva línea en diario_catalog.json (checklist escalabilidad).
- NUEVOS ids compuestos por señal: pasar SIEMPRE por _slug() (minúsculas/sin tildes) — el catálogo es ascii-plana.

---

## Notas del Agente — Iteración 2: UI del diario (historial, no borra las anteriores)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-04 21:50:00
**Estado:** Parcial (lote 1 de UI completado y verificado; módulo liberado 🟡 con pendientes honestos)
**Log:** 1295

### Lo que hice
- **`diary_layer.gd` reescrito por completo** (iter. 2): capa `DiaryLayer` MODAL_FULL sobre el framework M53 — 3 columnas (categorías / lista / detalle), 14 pestañas, barra de % por categoría + % global (siempre sobre lo descubierto, clamp [0,100], tooltip anti-spoiler), filtros (TODOS/NUEVOS/VISTOS/COMPLETADOS/FAVORITOS), búsqueda con diacríticos, ★ de favorito en fila y detalle con undo visual, "???" para entradas `secreta` no registradas, mensajes amistosos para categoría vacía y búsqueda sin resultados, wrap + tooltip en detalle, nodos con nombre para test (Fila_*, Tab_*, Lbl*), API consumida del servicio real (`get_categorias/entradas_de/buscar/progreso_categoria/alternar_favorito/nuevas_sesion`), `_t()` en todos los textos + `tooltip_text_key` (M87).
- **`diary_service.gd`**: +`get_categorias() -> Array[String]` (la UI no debía mapear el JSON crudo) y `buscar()` con `_slug()` aplicado a **ambos** lados (consulta y candidato → búsqueda sin acentos funciona, M87).
- **`ui_manager.gd`** (3 cambios): (1) bloque `diario` en `_unhandled_input` que hace `toggle()` de la capa "DiaryLayer"; (2) bloque `favorito` que delega a la capa solo si está visible; (3) **fix `close_top()`**: ahora purga la capa **visible** más reciente (antes siempre `stack[-1]`, con Esc sobre el diario purgaba SettingsAudioLayer oculta — bug real del framework M53). `_unhandled_input` también calcula `top_layer` = capa visible más reciente para pausa/nav.
- **`project.godot`**: acción `diario` = tecla J (physical_keycode 74, unicode 106), insertada antes de `inventario` en `[input]` con CRLF preservado (script Python idempotente).
- **`locales/es.po` + `en.po`**: +19 claves `DIARY.*` por idioma (título, detalle, buscar, 5 filtros, 3 estados, sin selección, sin resultados, favorito, progreso global/categoría, Día %s, BLOQUEADO "???"). Verificado sin BOM/FFFD y EOL LF.
- **`test_diario_ui.gd`** (nuevo, ~300 L): SceneTree, 89 checks — estructura de nodos, apertura/cierre/pila, anti-spoiler, detalle en 2 clics, favorito round-trip, los 5 filtros, búsqueda con/sin acento y EN, categoría vacía, 13/14 categorías con entradas, scroll preservado, persistencia round-trip (snapshot/restore), clamp [0,100], Esc/`close_top` + re-registro, acciones `diario`/`favorito` vía `_unhandled_input(InputEventAction)`, locale EN + nombres propios sin traducir, sin tweens/partículas (source scan), wrap/tooltip, `_sin_claves_crudas` recursivo. **Sonda rojo ejecutada** (★ de fila sabotada → 1 FALLO, exit=1 → revert → verde).
- **Regresión 4/4 verde** tras los cambios en `ui_manager.gd`: `test_diario` 0 fallos · `test_ui_i18n_m53` 0 fallos · `test_settings_audio_roundtrip` 51/0 · `test_ui_framework` 0 fallos.
- Docs: 03-Diseno §5 (implementación real + drift), 04-Codigo §1.1/§1.2 (archivos reales vs plan), 05-Checklist (marcas honestas), 06/07 de testings nuevos.

### Lo que NO pude hacer (honestidad obligatoria)
- **Virtualización/pooling/LazyLoad (checklist W)**: la lista crea una fila por entrada descubierta; sin medir con 500+ entradas. Pendiente de un lote de rendimiento.
- **Descripción/refs en el detalle (B/Q)**: el catálogo JSON solo tiene `{id, titulo}` — no hay descripción, refs ni iconos que mostrar. Requiere enriquecer el catálogo (dueños de las fuentes) o M56.
- **Icono faltante con fallback (X)**: no hay iconos en las filas (solo texto + ★).
- **3er idioma y plurales (V)**: solo `es.po`/`en.po` en el repo; plurales no resueltos.
- **`validate_diary.gd` (Y)**: no creado.
- **14 categorías con ≥1 entrada (Y)**: **13/14** — `fotografías` tiene 0 entradas (falta M56). Marcado `[?]`.
- **Persistencia entre sesiones real (Z)**: el test hace round-trip `get_save_data`→`restore_save_data` en un solo proceso; no probé guardar→salir→cargar en ejecuciones separadas.
- **Estética cozy comprobada (B)**: sin vía de visión operativa en esta sesión (M154 V1–V5 no usadas); la verificación fue estructural/por test, no estética. Ítem queda `[ ]`.
- **CHECKLIST-GLOBAL fila 55**: NO se modificó (el único hunk de CG en mi working tree es ajeno — fila 120 de DeepSeek; el director gestiona el GLOBAL). Reclamo reportado por informe para su aplicación controlada.

### Intentos fallidos / decisiones
- **Bug propio encontrado por el test:** `_on_favorito_pressed` usaba `if not d.alternar_favorito(eid): return` — pero `alternar_favorito` devuelve el **nuevo estado** (false al desmarcar), así que el desmarcado salía sin refrescar la fila. Fix: guard con `esta_registrada()` + refresh incondicional.
- **Locale EN no aplicaba a textos estáticos**: `on_layer_opened` no re-traducía (LblTitulo/Cerrar/pestañas…). Fix: `_aplicar_textos_estaticos()` al abrir.
- **Test buscaba la capa por nombre `DiaryLayer` pero la capa se instanciaba como `DiaryTest`** → acciones `diario`/`favorito` no la encontraban. Fix: nombre correcto + liberación preventiva de una capa homónima previa (defensa contra UIRoot).
- **Decisión:** NO traducir nombres propios ni títulos de entradas (son identidad, M87) — solo UI strings.
- **Decisión:** NO tocar `interaction_manager.gd` (BUG-096, zona kimi-k3): el error preexistente `Nonexistent 'bool' constructor` en `interaction_manager.gd:669` se emite en todo `pop_layer` (aparece también en las suites de M53 y no aborta resultados). Documentado, no es regresión mía.
- **Encoding/EOL (§28):** `.po`/`.gd` LF, `project.godot` CRLF; `.po` escritos con `Set-Content`/here-string (nunca `-c` inline) y verificados FFFD=0/BOM=0; guard de idempotencia en todos los scripts de inserción.

### Recomendaciones para el próximo agente
- **Lote de rendimiento (W/X):** virtualizar `ListaEntradas` (solo visible en árbol), pooling de filas (M62), LazyLoad de categorías; medir apertura con 500+ entradas.
- **Catálogo rico (B/Q):** si se agregan `descripcion`/`refs`/`icono` al JSON, el detalle ya tiene dónde mostrarlos (`ColDetalle`); respetar que los títulos de entrada NO se traducen.
- **M56 fotografías:** crear las entradas base de `fotografías` (pasa a 14/14) y enganchar FOTO_TOMADA (puente de 1 línea, patrón `_conectar_eventos`).
- **`validate_diary.gd` (Y):** puede reutilizar las aserciones de `test_diario_ui.gd` (claves, estructura, anti-spoiler).
- **Ojo con `alternar_favorito`:** devuelve estado, no éxito — usar `esta_registrada()` como guard.
- **`close_top()`** ya purga la capa visible: no regresar al comportamiento `stack[-1]` (rompe Esc con capas ocultas en la pila).
