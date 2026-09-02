**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 55: Diario del Jugador

## 1. Archivos Involucrados

| Archivo | Ruta | Rol |
|---|---|---|
| `diary_entry.gd` | `Assets/_Project/Diary/data/` | Modelo: id, categoría, estado, tags, favorito, secreto, refs |
| `diary_catalog.tres` | `Assets/_Project/Diary/data/` | Catálogo estático: 14 categorías, entradas, totales reales |
| `diary_service.gd` | `Assets/_Project/Diary/service/` | Autoload: registro por eventos, estado, % completado |
| `diary_save.gd` | `Assets/_Project/Diary/service/` | Serialización en GameState (M59/M60) con schema_version |
| `diary_screen.gd` | `Assets/_Project/Diary/ui/` | Pantalla: pestañas, listas virtualizadas, filtros, detalle |
| `diary_list_item.gd` | `Assets/_Project/Diary/ui/` | Fila: icono (M46), título, estado, estrella favorito |
| `diary_detail.gd` | `Assets/_Project/Diary/ui/` | Detalle: descripción, acciones, foto (M56) |
| `validate_diary.gd` | `Assets/_Project/Diary/validators/` | Validador: mapeo, i18n, persistencia, rendimiento |

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
