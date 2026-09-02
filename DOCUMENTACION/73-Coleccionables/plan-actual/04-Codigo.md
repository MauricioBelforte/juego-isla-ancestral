**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code

# 04-Codigo.md — Módulo 73: Coleccionables

## 1. Archivos Involucrados

| Archivo | Ruta | Rol |
|---|---|---|
| `collectible_item.gd` | `Assets/_Project/Collectibles/data/` | Modelo: id, categoría, nombre i18n, icono (M46), fuente, recompensa |
| `collectible_category.gd` | `Assets/_Project/Collectibles/data/` | Modelo: id, nombre i18n, total, recompensa |
| `collectibles_catalog.tres` | `Assets/_Project/Collectibles/data/` | Catálogo central: 22 categorías, ~500 ítems |
| `collectible_service.gd` | `Assets/_Project/Collectibles/service/` | Autoload: registro idempotente, progreso, completado |
| `collectible_save.gd` | `Assets/_Project/Collectibles/service/` | Persistencia compacta (M59/M60) |
| `collection_view.gd` | `Assets/_Project/Collectibles/ui/` | Vista en diario (M55): progreso por categoría |
| `collection_reward.gd` | `Assets/_Project/Collectibles/ui/` | Notificación de colección completada (M44) |
| `validate_collectibles.gd` | `Assets/_Project/Collectibles/validators/` | Ids únicos, totales, recompensas, i18n, persistencia |

## 2. Funciones Clave y Logs Relacionados

### 2.1 `collectible_service.gd` (autoload)
```gdscript
func mark_collected(id: String) -> void:
    var item: CollectibleItem = _catalog.find(id)
    if item == null:
        LOGS.collect("COLL-WARN", {"id": id}); return  # ítem ajeno
    if _state.has(id): return  # idempotente: sin duplicados
    _state.append(id)
    CollectionSignals.item_collected.emit(id)
    if _category_complete(item.category):
        _on_category_complete(item.category)
    LOGS.collect("COLL-ADD", {"id": id, "cat": item.category})

func _on_category_complete(cat_id: String) -> void:
    var cat: CollectibleCategory = _catalog.categories[cat_id]
    _reward(cat.reward)  # M14 ítem o M38 dinero
    CollectionSignals.category_completed.emit(cat_id)
    Progression.unlock(cat.unlock)  # M71
    LOGS.collect("COLL-COMPLETE", {"cat": cat_id})
```

### 2.2 `collectible_save.gd` (persistencia compacta)
```gdscript
func save() -> void:
    var data := {"schema_version": 1, "collected": _service.state}
    GameState.collectibles = data  # M59/M60, lista de ids < 5 KB
    LOGS.collect("COLL-SAVE", {"count": _service.state.size()})

func load_safe(raw: Variant) -> void:
    if raw == null: return
    _migrate(raw)  # M60
    for id in raw.collected:
        if _catalog.has(id): _service.mark_loaded(id)  # validar contra catálogo
```

## 3. Contratos de Integración (Eventos del EventBus M07)

| Evento | Emisor | → Coleccionables |
|---|---|---|
| `ITEM_COLLECTED` | M70/M14 | Registro genérico |
| `FISH_CAUGHT` | M34 | Registro de pez |
| `CROP_HARVESTED` | M33 | Registro de planta/cosecha |
| `MINERAL_MINED` | M35 | Registro de mineral |
| `FOSSIL_DUG` | M25 | Registro de fósil |
| `PERFORMANCE_DONE` | M74 | Registro de carta de festival |
| `PHOTO_TAKEN` | M56 | Registro de fotografía |
| `COLLECTION_COMPLETED` | collectible_service | M72 logros, M71 desbloqueos, M37 museo |

## 4. Logs Relacionados (Sistema de Logs del Proyecto)

El módulo usa el sistema central de logs de consola (M118): prefijo `[COLL]` en desarrollo y canal depurado en builds (sección 18 de AGENTS.md); rotación automática fuera de `Assets/`.

## 5. Notas del Agente

**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code
**Fecha:** 2026-08-17
**Estado:** Parcial (con dudas)

### Lo que hice
- Documenté el módulo 73 completo (diseño técnico de Godot 4): catálogo central de 22 categorías con ids unívocos, registro idempotente por eventos (M07), progreso sobre lo descubierto (anti-spoiler), colecciones completas con recompensa y desbloqueos (M71), vistas compartidas de museo (M37) y diario (M55), persistencia compacta (M59/M60) y validación.

### Lo que NO pude hacer (honestidad obligatoria)
- `[?]` Verificar en runtime: no hay editor Godot ni build en este entorno; los `.gd` de esta documentación son prototipos de diseño que se escribirán en la fase de implementación.
- `[?]` Confirmar los totales exactos por categoría: la tabla 3.1 son estimaciones para que el validador tenga orden de magnitud; los números finales salen de los catálogos de los módulos fuente (M34/M35/M33/M36/M25...).
- `[?]` Definir las recompensas exactas: son referencias de diseño; los valores finales se cierran con M38 (economía) y M16 (crafting).

### Intentos fallidos / decisiones
- Decidí el registro idempotente por id unívoco (evita duplicados por doble recolección).
- Decidí el anti-spoiler igual que M55 (los ítems no descubiertos son invisibles en el diario).
- Decidí que las recompensas NUNCA bloquean la historia principal (M22) — alineado con la filosofía cozy.

### Recomendaciones para el próximo agente
- Al implementar: cerrar los totales de cada categoría con los módulos fuente ANTES de poblar el catálogo.
- Coordinar con M37 (museo) que la donación marque el coleccionable (regla: donar = recolectar).
- Testear el anti-spoiler: entrar con el diario sin recolectar nada debe mostrar 0 pistas de lo que falta.