# Guía de Desarrolladores - Isla Ancestral

> **Módulo:** M111 Código de Calidad
> **Versión:** 1.0
> **Fecha:** 2026-08-28

---

## 1. Introducción

Esta guía establece los estándares de calidad de código para el proyecto **Isla Ancestral**. Todo contribuidor debe seguir estas convenciones para mantener la base de código consistente, mantenible y libre de deuda técnica excesiva.

---

## 2. Convenciones de Nomenclatura (GDScript 4.x)

### 2.1 Archivos
- **Formato:** `snake_case.gd`
- **Ejemplos:** `villager.gd`, `item_database.gd`, `time_calendar.gd`

### 2.2 Clases y `class_name`
- **Formato:** `PascalCase`
- **Ejemplos:** `Villager`, `ItemDatabase`, `TimeCalendar`

### 2.3 Funciones y Métodos
- **Formato:** `snake_case`
- **Privadas:** Prefijo `_` (ej: `_internal_helper`)
- **Built-in Godot:** `_ready`, `_process`, `_physics_process`, `_input`, `_init`
- **Ejemplos:** `calculate_damage()`, `_find_nearest_resource()`, `get_save_data()`

### 2.4 Variables y Propiedades
- **Formato:** `snake_case`
- **Privadas:** Prefijo `_` (ej: `_internal_state`)
- **Exportadas:** `snake_case` (ej: `@export var max_health: int`)

### 2.5 Constantes
- **Formato:** `UPPER_SNAKE_CASE`
- **Ejemplos:** `MAX_INVENTORY_SIZE`, `DAY_DURATION_SECONDS`, `DEFAULT_MOVE_SPEED`

### 2.6 Señales (Signals)
- **Formato:** `snake_case`
- **Ejemplos:** `health_changed`, `inventory_updated`, `dialogue_finished`

### 2.7 Enums
- **Nombre del enum:** `PascalCase`
- **Valores:** `UPPER_SNAKE_CASE`
- **Ejemplo:**
```gdscript
enum ItemType {
	CONSUMABLE,
	EQUIPMENT,
	MATERIAL,
	QUEST
}
```

### 2.8 Recursos (.tres) y Escenas (.tscn)
- **Formato:** `snake_case.tres` / `snake_case.tscn`
- **Ejemplos:** `villager_profile.tres`, `main_island.tscn`

---

## 3. Límites de Tamaño y Complejidad

| Elemento | Límite | Severidad |
|----------|--------|-----------|
| Líneas por método | 50 | Warning |
| Líneas por clase | 300 | Warning |
| Líneas por archivo | 500 | Warning |
| Complejidad ciclomática | 10 | Warning |
| Profundidad de anidamiento | 4 niveles | Warning |

**Herramienta:** Ejecutar `CodeQualityCheck` (EditorScript) para verificación automática.

---

## 4. Estructura de Archivos por Módulo

```
scripts/
├── core/           # Sistemas centrales (EventBus, ServiceRegistry, Bootstrap)
├── data/           # Datos y recursos (ItemData, ItemDatabase, GameConstants)
├── time/           # Sistema de tiempo (TimeCalendar, GameClock, FestivalData)
├── economy/        # Economía (EconomyManager, PriceManager)
├── inventory/      # Inventario (InventarioService, Container)
├── shops/          # Tiendas (ShopManager, Reputation)
├── friendship/     # Amistad (FriendshipService, GiftEvaluator)
├── saving/         # Guardado (SaveManager, SaveProvider, SaveSchema)
├── npc/            # NPCs (Villager, VillagerManager, VillagerProfile)
├── player/         # Jugador (Player, PlayerController)
├── tools/          # Herramientas (ToolController, ToolData)
├── world/          # Mundo (WorldManager, IslandGenerator)
├── ui/             # UI (UIManager, HUD, Theme)
├── camera/         # Cámara (CameraRig, FollowCamera)
├── particles/      # Partículas
└── editor/         # Herramientas de editor (CodeQualityCheck)
```

---

## 5. Plantillas de Documentación

### 5.1 Clase Pública
```gdscript
##
# Breve descripción de la clase (una línea).
#
# Descripción más detallada si es necesario. Explicar responsabilidad principal,
# relaciones con otros sistemas y patrones utilizados.
#
# @see OtroSistemaRelacionado
class_name MiClase
extends Node

## Descripción de la propiedad exportada.
@export var mi_propiedad: int = 10

## Descripción de la señal.
signal mi_senal(parametro: int)

## Inicialización.
func _init() -> void:
	pass

## Descripción de la función pública.
# @param valor Descripción del parámetro
# @return Descripción del valor de retorno
func mi_funcion_publica(valor: int) -> bool:
	return true

## Función privada (prefijo _).
func _mi_funcion_privada() -> void:
	pass
```

### 5.2 Función Pública
```gdscript
## Calcula el daño final aplicando resistencias.
# @param base_damage Daño base del ataque
# @param damage_type Tipo de daño (ver DamageType enum)
# @param target_resistances Diccionario de resistencias del objetivo
# @return Daño final después de resistencias
func calculate_final_damage(base_damage: float, damage_type: DamageType, target_resistances: Dictionary) -> float:
	var final_damage = base_damage
	# ... lógica
	return final_damage
```

---

## 6. Proceso de Code Review

### 6.1 Cambios que Requieren Code Review
- ✅ Módulos nuevos (M07, M08, M59+)
- ✅ Cambios críticos de gameplay (combate, economía, guardado)
- ✅ Cambios en arquitectura central (EventBus, ServiceRegistry, Bootstrap)
- ✅ Refactorizaciones > 100 líneas
- ✅ Correcciones de bugs P0/P1

### 6.2 Checklist de Code Review (16 ítems)

| # | Verificación |
|---|--------------|
| 1 | Convenciones de nomenclatura respetadas |
| 2 | Límites de tamaño (método ≤50, clase ≤300, archivo ≤500) |
| 3 | Complejidad ciclomática ≤10 |
| 4 | Anidamiento ≤4 niveles |
| 5 | Documentación en clases públicas |
| 6 | Documentación en funciones públicas |
| 7 | Tipado estático en parámetros y retorno |
| 8 | Uso de `@onready` para referencias a nodos |
| 9 | Señales tipadas (`signal name(param: Type)`) |
| 10 | Callable.bind para callbacks con parámetros |
| 11 | Sin memory leaks (señales desconectadas, queue_free) |
| 12 | Validaciones defensivas (`is_instance_valid()`) |
| 13 | Manejo de errores (assert, push_error, fallback) |
| 14 | Tests unitarios/integración si aplica (M112) |
| 15 | Sin código duplicado (DRY) |
| 16 | Compatibilidad Godot 4.4.1+ |

### 6.3 Flujo de Code Review
```
PR creado → Asignar reviewer → Review (checklist) → Comentarios → Correcciones → Aprobación → Merge
```

---

## 7. Registro de Deuda Técnica

### 7.1 Formato de Registro
Ubicación: `docs/codigo_de_calidad/deuda_tecnica.md`

| Campo | Descripción |
|-------|-------------|
| ID | Identificador único (TD-XXX) |
| Descripción | Qué deuda técnica existe |
| Prioridad | Alta / Media / Baja |
| Estado | Abierta / En Progreso / Resuelta / Aceptada |
| Dueño | Responsable |
| Estimación | Horas/días estimados |
| Módulo Afectado | Módulo(s) relacionado(s) |
| Fecha Creación | YYYY-MM-DD |
| Fecha Objetivo | YYYY-MM-DD (opcional) |

### 7.2 Criterios de Prioridad
- **Alta:** Bloquea hito mayor, causa crashes, vulnerabilidad seguridad
- **Media:** Impacta performance, mantenibilidad, dificulta testing
- **Baja:** Mejoras cosméticas, refactorizaciones opcionales, documentación

---

## 8. Prevención de Problemas Comunes

### 8.1 Memory Leaks
- ✅ Desconectar señales en `_exit_tree()` o `queue_free()`
- ✅ Usar `weakref()` para referencias circulares
- ✅ Liberar texturas/materiales no usados
- ✅ Evitar referencias fuertes en autoloads a nodos de escena

### 8.2 Null References
- ✅ Usar `is_instance_valid(obj)` antes de acceder
- ✅ Valores por defecto seguros (`var x: int = 0`)
- ✅ Pattern matching con `match` para opciones

### 8.3 Excepciones
- ✅ `assert(condición)` para invariantes en desarrollo
- ✅ `push_error()` para errores en runtime
- ✅ Retornar valores por defecto o `false` en lugar de lanzar

### 8.4 Serialización (M59)
- ✅ Versionar `GameState` 
- ✅ Validar tipos antes de cargar
- ✅ Valores por defecto para campos faltantes
- ✅ Backward compatibility en saves

---

## 9. Rendimiento y Optimización

### 9.1 Buenas Prácticas
- ✅ Medir antes de optimizar (M61 Profiler)
- ✅ Object pooling para objetos frecuentes
- ✅ Caché de resultados costosos
- ✅ Evitar `new()` en `_process()` / `_physics_process()`
- ✅ Usar `distance_squared()` en lugar de `distance_to()`

### 9.2 Cuándo Optimizar
1. Profiling muestra bottleneck real (M61)
2. Afecta FPS objetivo (60 FPS desktop, 30 FPS mobile)
3. Memoria excede presupuesto (M62)

---

## 10. Internacionalización y Accesibilidad (Preparación M87/M58)

- ✅ Externalizar todas las cadenas de texto (tr())
- ✅ Preparar UI para navegación por teclado
- ✅ Contraste de color suficiente (WCAG AA)
- ✅ Tamaños de fuente ajustables
- ✅ Soporte lectores de pantalla (ARIA-like en Godot)

---

## 11. Seguridad

- ✅ No exponer datos sensibles en logs
- ✅ Validar input del usuario (sanitización)
- ✅ Sanitizar datos de archivos externos (saves, configs)
- ✅ Usar versiones fijas de dependencias (addons, plugins)

---

## 12. Multi-threading (Godot 4.x)

- ✅ Solo para cálculos pesados (pathfinding, generación terreno)
- ✅ Mutex para datos compartidos
- ✅ **NUNCA** llamar Godot API desde threads secundarios
- ✅ Usar `call_deferred()` para comunicarse con main thread

---

## 13. Checklist de Calidad por Commit

### 13.1 Antes de Commit (7 ítems)
- [ ] `godot --headless --check-only` pasa sin errores
- [ ] `godot --headless --format --check-only` pasa
- [ ] CodeQualityCheck sin errores críticos (naming conventions)
- [ ] Tests relevantes pasan (M112)
- [ ] Sin warnings de Godot en Output log
- [ ] Documentación actualizada si API pública cambió
- [ ] Deuda técnica registrada si se introdujo intencionalmente

### 13.2 Después de Commit (4 ítems)
- [ ] CI pipeline verde (GitHub Actions)
- [ ] Code review aprobado si requerido
- [ ] Changelog actualizado (Conventional Commits)
- [ ] No regresiones en funcionalidad relacionada

---

## 14. Refactorización Regular

### 14.1 Cuándo Refactorizar
- Antes de hitos mayores (Pre-Alpha, Alpha, Beta)
- Cada 3 meses (sprint técnico)
- Cuando deuda técnica excede umbral (ver M133)

### 14.2 Pasos de Refactorización
1. **Identificar** zona con deuda técnica
2. **Tests** - Asegurar cobertura antes de tocar
3. **Refactorizar** - Cambios incrementales, compilar seguido
4. **Verificar** - Tests pasan, CodeQualityCheck limpio
5. **Documentar** - Actualizar guía si cambió patrón

---

## 15. Principios SOLID Aplicados

| Principio | Aplicación en Proyecto |
|-----------|------------------------|
| **SRP** | Una clase = una responsabilidad (Villager = lógica NPC, VillagerManager = gestión colección) |
| **OCP** | Extender vía herencia/composición, no modificar core (EventBus, ServiceRegistry) |
| **LSP** | Subclases intercambiables (ItemData → ConsumableData, EquipmentData) |
| **ISP** | Interfaces pequeñas (IInteractable, IDamageable, ISaveable) |
| **DIP** | Depender de abstracciones (EventBus, ServiceRegistry), no implementaciones |

---

## 16. Code Smells a Evitar

| Smell | Descripción | Solución |
|-------|-------------|----------|
| Long Parameter List | >5 parámetros | Agrupar en struct/objeto |
| Feature Envy | Método usa más datos de otra clase | Mover método a esa clase |
| Inappropriate Intimacy | Clases muy acopladas | Introducir interfaz/mediador |
| Lazy Class | Clase que no hace lo suficiente | Eliminar o fusionar |
| Data Clumps | Grupos de datos que van juntos | Crear struct/Resource |
| Primitive Obsession | Usar primitivos en lugar de tipos | Crear tipos envoltorio (Resource, Enum) |

---

## 17. Herramientas Disponibles

| Herramienta | Uso | Comando |
|-------------|-----|---------|
| **CodeQualityCheck** | Análisis estático completo | `godot --headless --script scripts/editor/code_quality_check.gd` |
| **Godot Linter** | Linter nativo GDScript | `godot --headless --check-only` |
| **Godot Formatter** | Formateo automático | `godot --headless --format` |
| **Pre-commit** | Hooks locales | `pre-commit run --all-files` |
| **CI Pipeline** | Gates en PR/Push | GitHub Actions (`.github/workflows/quality.yml`) |

---

## 18. Recursos y Referencias

- [GDScript Style Guide (Godot Docs)](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Godot 4.x GDScript Documentation](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/)
- [M07 Arquitectura](../../DOCUMENTACION/07-Arquitectura-General/plan-actual/03-Diseno.md) - ServiceRegistry, EventBus, Bootstrap
- [M112 Testing Automático](../../DOCUMENTACION/112-Testing-Automatico/plan-actual/03-Diseno.md) - GdUnit4 patterns
- [M61 Rendimiento](../../DOCUMENTACION/61-Rendimiento/plan-actual/03-Diseno.md) - Profiling y optimización

---

## 19. Historial de Cambios

| Versión | Fecha | Autor | Cambios |
|---------|-------|-------|---------|
| 1.0 | 2026-08-28 | ox-alpha | Versión inicial M111 |

---

*Documento generado como parte del Módulo 111 - Código de Calidad*