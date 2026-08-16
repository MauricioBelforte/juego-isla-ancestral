**Modelo:** Devin
**Plataforma:** Antigravity

# 02-Analisis.md — Módulo 111: Código de Calidad

## 1. Análisis de los puntos del plan maestro (sección 110)

| # | Punto | Resolución |
|---|---|---|
| 1 | Evitar código duplicado | ✅ DRY (Don't Repeat Yourself) - extraer lógica común a funciones reutilizables |
| 2 | Evitar métodos gigantes | ✅ Límite de 50 líneas por método (excepciones con justificación) |
| 3 | Evitar clases gigantes | ✅ Límite de 300 líneas por clase (usar composición) |
| 4 | Documentar sistemas complejos | ✅ Comentarios para lógica no obvia, algoritmos complejos |
| 5 | Documentar APIs internas | ✅ Documentación de funciones públicas con parámetros y retorno |
| 6 | Crear interfaces | ✅ Interfaces para contratos entre sistemas (IInteractable, IDamageable, etc.) |
| 7 | Usar composición donde convenga | ✅ Preferir composición sobre herencia profunda (máx 3 niveles) |
| 8 | Minimizar acoplamiento | ✅ Baja dependencia entre módulos, usar EventBus para comunicación |
| 9 | Crear tests unitarios | ✅ Tests de funciones individuales (M112) |
| 10 | Crear tests de integración | ✅ Tests de interacción entre sistemas (M112) |
| 11 | Revisar memory leaks | ✅ Detección de fugas de memoria (M62, profiler) |
| 12 | Revisar null references | ✅ Prevención de accesos a null (validaciones, optionals) |
| 13 | Revisar excepciones | ✅ Manejo robusto de errores (try/catch, asserts) |
| 14 | Revisar race conditions | ✅ Prevenir condiciones de carrera (Godot single-threaded, pero cuidado con señales) |
| 15 | Revisar serialización | ✅ Validación de guardado/carga (M60) |
| 16 | Revisar compatibilidad | ✅ Versiones de Godot y plataformas (M96) |
| 17 | Revisar rendimiento | ✅ Profiling y optimización (M61) |
| 18 | Refactorizar regularmente | ✅ Limpieza periódica de código (sprints técnicos) |
| 19 | Mantener deuda técnica controlada | ✅ Registro y seguimiento de deuda técnica (AGENTS.md o documento específico) |

## 2. Límites de tamaño y complejidad

**Líneas de código:**
- Método: máximo 50 líneas (excepciones con justificación en comentario)
- Clase: máximo 300 líneas (usar composición si excede)
- Archivo: máximo 500 líneas (separar en múltiples archivos si excede)

**Complejidad ciclomática:**
- Método: máximo 10 (si excede, extraer subfunciones)
- Clase: máximo 50 (si excede, dividir responsabilidades)

**Anidamiento:**
- Máximo 4 niveles de anidación (if/for/while)
- Si excede, extraer a función separada

## 3. Convenciones de nomenclatura (GDScript)

**Clases:**
- PascalCase: `PlayerController`, `WorldVoxel`, `GameClock`
- Sufijos: `*Controller`, `*Manager`, `*System`, `*Service`

**Funciones:**
- snake_case: `get_player_position()`, `set_game_time()`
- Privadas: `_internal_function()`

**Variables:**
- snake_case: `player_position`, `game_time`
- Constantes: UPPER_CASE: `MAX_PLAYERS`, `DEFAULT_FPS`
- Privadas: `_internal_variable`

**Archivos:**
- snake_case: `player_controller.gd`, `world_voxel.gd`

**Señales:**
- snake_case: `player_died`, `game_time_changed`

## 4. Plantillas de documentación

**Documentación de clase:**
```gdscript
## PlayerController
##
## Controla el movimiento e interacción del jugador en el mundo voxel.
##
## Dependencias
## - WorldVoxel (para colisiones)
## - GameClock (para hora del juego)
## - EventBus (para eventos)
##
## Señales
## - player_moved(position: Vector3)
## - player_interacted(object: Node3D)
##
## Métodos públicos
## - move(direction: Vector3) -> void
## - interact() -> void
class_name PlayerController
extends Node3D
```

**Documentación de función:**
```gdscript
## teleport_player
##
## Teletransporta al jugador a la posición especificada.
##
## @param position: Posición de destino (Vector3)
## @param check_collision: Si debe verificar colisiones antes de teletransporte (bool)
## @return: true si el teletransporte fue exitoso, false si hubo colisión (bool)
func teleport_player(position: Vector3, check_collision: bool = true) -> bool:
```

## 5. Interfaces recomendadas

**Interfaces principales:**
```gdscript
# IInteractable
## Objeto con el que el jugador puede interactuar
interface IInteractable:
    func interact(player: Node3D) -> void
    func get_interaction_prompt() -> String
    func is_interactable() -> bool

# IDamageable
## Entidad que puede recibir daño
interface IDamageable:
    func take_damage(amount: int, source: Node) -> void
    func get_health() -> int
    func is_alive() -> bool

# ISaveable
## Entidad que puede persistir su estado
interface ISaveable:
    func get_save_data() -> Dictionary
    func load_save_data(data: Dictionary) -> void
```

## 6. Patrones de composición

**Preferir composición sobre herencia:**
- ✅ `PlayerMovement` + `PlayerInteraction` + `PlayerInventory`
- ❌ `Player` con herencia profunda de `Entity` → `MobileEntity` → `InteractableEntity`

**Componentes reutilizables:**
- `HealthComponent` (para cualquier entidad con vida)
- `InventoryComponent` (para cualquier entidad con inventario)
- `StateComponent` (para máquinas de estado)

## 7. Prevención de memory leaks

**Fuentes comunes de leaks:**
- Conexiones a señales no desconectadas
- Referencias circulares
- Objetos no liberados en `queue_free()`
- Texturas/materiales no liberados

**Prevención:**
```gdscript
# Al desconectar
signal.disconnect(_on_signal)
# Al liberar
if is_instance_valid(object):
    object.queue_free()
```

## 8. Prevención de null references

**Validaciones defensivas:**
```gdscript
# Con validación explícita
if player != null and player.is_inside_tree():
    player.position = new_position

# Con operador safe navigation (si GDScript lo soporta)
player?.position = new_position

# Con optionals (pattern recomendado)
if player:
    player.position = new_position
```

## 9. Manejo de excepciones

**Asserts para desarrollo:**
```gdscript
assert(condition, "Mensaje de error si falla")
```

**Validaciones en runtime:**
```gdscript
if not condition:
    push_error("Mensaje de error")
    return  # o manejo alternativo
```

**Try/catch si es aplicable:**
```gdscript
# GDScript no tiene try/catch tradicional, pero en APIs externas usar equivalentes
```

## 10. Serialización y compatibilidad

**Validación de guardado:**
- Versionado de GameState (M59)
- Validación de tipos antes de cargar
- Valores por defecto para campos faltantes

**Compatibilidad:**
- Godot 4.4.1+ (versión fija)
- Windows, Linux, macOS (plataformas objetivo)
- Backward compatibility en saves (M60)

## 11. Proceso de code review

**Obligatorio para:**
- Cambios en M07 (Arquitectura)
- Cambios en M08 (Mundo Voxel)
- Cambios en M59 (Guardado)
- Cambios críticos en gameplay

**Checklist de review:**
- Código sigue convenciones de nomenclatura
- No hay código duplicado evidente
- Métodos/clases dentro de límites de tamaño
- Documentación presente en APIs públicas
- No hay warnings de Godot
- Tests cubren cambios (M112)
- No introduce deudas técnicas sin registro

## 12. Registro de deuda técnica

**En AGENTS.md o documento específico:**
```markdown
## Deuda Técnica

| ID | Descripción | Prioridad | Estado | Dueño |
|----|-------------|-----------|--------|-------|
| DT001 | Sistema de inventario monolítico, difícil de probar | Alta | Pendiente | M14 |
| DT002 | Generación de mundo sin tests de integración | Alta | Pendiente | M10 |
```

## 13. Refactorización regular

**Sprints técnicos:**
- Antes de hitos mayores (M1, M2, etc.)
- Cada 3 meses de desarrollo
- Cuando la deuda técnica excede umbral

**Tareas típicas:**
- Extraer lógica duplicada a funciones comunes
- Dividir clases gigantes en componentes
- Mejorar documentación de APIs complejas
- Agregar tests a código sin tests

## 14. Herramientas de análisis estático

**Herramientas para GDScript:**
- GDScript Linter (built-in en Godot)
- gdlint (herramienta externa si disponible)
- Análisis de código integrado en Godot Editor

**Validaciones automáticas:**
- Warnings de Godot como indicador de problemas
- Errores de sintaxis en tiempo real
- Comprobación de tipos (opcional en GDScript)

## 15. Code smells a evitar

**Code smells comunes:**
- Long Parameter List: más de 5 parámetros en función (usar struct/dict)
- Feature Envy: clase que usa demasiados métodos de otra clase
- Inappropriate Intimacy: exponer variables privadas sin razón
- Lazy Class: clase que hace muy poco
- Data Clumps: grupos de datos que siempre viajan juntos (extraer a clase)
- Primitive Obsession: usar tipos primitivos en lugar de objetos

## 16. Principios SOLID aplicados

**Single Responsibility Principle (SRP):**
- Cada clase tiene una única responsabilidad
- Ejemplo: `PlayerMovement` solo maneja movimiento, no inventario

**Open/Closed Principle (OCP):**
- Abierto para extensión, cerrado para modificación
- Ejemplo: usar interfaces para nuevos tipos de herramientas

**Liskov Substitution Principle (LSP):**
- Subclases pueden sustituir a su clase base
- Ejemplo: todos los `IInteractable` pueden usarse polimórficamente

**Interface Segregation Principle (ISP):**
- Interfaces específicas y pequeñas
- Ejemplo: `IInteractable` vs `IDamageable` vs `ISaveable`

**Dependency Inversion Principle (DIP):**
- Depender de abstracciones, no de implementaciones concretas
- Ejemplo: depender de `IInventory` en lugar de `PlayerInventory`

## 17. Patrón EventBus

**Uso de EventBus para desacoplamiento:**
- Publicar eventos en lugar de llamadas directas
- Suscribirse a eventos en lugar de polling
- Ejemplo: `EventBus.publish("player_moved", position)` en lugar de `PlayerMoved(position)`

**Beneficios:**
- Bajo acoplamiento entre módulos
- Fácil testing (mock de eventos)
- Fácil extensión (nuevos suscriptores sin modificar código existente)

## 18. Patrón Service Locator

**Uso de ServiceLocator (M07):**
- Obtener servicios por nombre en lugar de dependencias directas
- Ejemplo: `ServiceRegistry.get("game_clock")` en lugar de `GameClock.instance`

**Beneficios:**
- Inyección de dependencias fácil para testing
- Centralización de configuración de servicios
- Fácil mock para tests

## 19. Patrón ScriptableObject para datos

**Uso de ScriptableObject para datos estáticos:**
- Datos de configuración (ToolCatalog, TimeConfig)
- Datos de diseño (BiomaData, NPCData)
- Sin instanciación, solo referencia

**Beneficios:**
- Ahorro de memoria (compartido)
- Fácil modificación en Editor
- Fácil testing (datos de prueba diferentes)

## 20. Manejo de errores y asserts

**Uso de asserts para desarrollo:**
```gdscript
assert(condition, "Mensaje de error")
assert(condition, "Condition failed: %s" % variable)
```

**Validaciones en runtime:**
```gdscript
if not is_instance_valid(object):
    push_error("Object is not valid")
    return
```

**Logging de errores:**
```gdscript
Logger.error("Failed to load save file: %s" % file_path, Category.SAVE)
```

## 21. Optimizaciones prematuras

**Evitar optimizaciones prematuras:**
- No optimizar antes de medir (M61 Rendimiento)
- Código legible > código micro-optimizado
- Godot engine ya optimiza muchas cosas

**Cuándo optimizar:**
- Cuando profiler muestra cuello de botella
- Cuando FPS baja en áreas específicas
- Cuando memoria excede budget

## 22. Documentación inline

**Comentarios útiles:**
- Explicar POR QUÉ, no QUÉ hace el código
- Explicar algoritmos no obvios
- Explicar decisiones de diseño
- NO comentar código obvio

**Ejemplo de buen comentario:**
```gdscript
# Usamos distancia euclidiana cuadrada para evitar sqrt() (más rápido)
if distance_squared < attack_range_squared:
    attack()
```

**Ejemplo de mal comentario:**
```gdscript
# Sumar 1 a contador
counter += 1  # Obvio, no aporta
```

## 23. Estructura de archivos

**Organización por módulo:**
```
scripts/
├── core/           # Múcleo (M07)
├── world/          # Mundo (M08, M09, M10)
├── player/         # Jugador (M11)
├── camera/         # Cámara (M12)
├── tools/          # Herramientas (M13)
├── inventory/      # Inventario (M14)
├── crafting/       # Crafting (M16)
├── npc/            # NPC (M19)
├── quests/         # Misiones (M22)
├── puzzles/        # Puzzles (M24)
├── time/           # Tiempo (M29)
├── save/           # Guardado (M59)
└── debug/          # Debug (M110)
```

## 24. Convenciones de Godot específicas

**Nodos y escenas:**
- Nombre de escena: PascalCase con guiones: `Main_Menu.tscn`
- Nombre de nodo: PascalCase: `PlayerCamera`, `InventoryUI`
- Path relativo desde `res://` o `user://`

**Grupos:**
- Usar grupos para búsqueda de nodos: `add_to_group("player")`
- Nombres de grupos: snake_case: `player`, `interactable`, `npc`

**Layers:**
- Usar layers para física y render: `add_to_layer("player")`
- Nombres de layers: snake_case: `player`, `enemy`, `interactable`

## 25. Testing (preparación para M112)

**Filosofía de testing:**
- Tests unitarios para funciones lógicas puras
- Tests de integración para interacción entre sistemas
- Tests de E2E para flujos completos (jugador → interacción → resultado)

**Preparación para tests:**
- Código debe ser testeable (inyección de dependencias)
- Código debe tener límites claros (input → output)
- Código debe manejar errores sin crashear

## 26. Patrones de diseño recomendados

**Patrones útiles para Godot:**
- State Machine (para AI, estados de jugador)
- Observer (para eventos)
- Singleton (para servicios, con precaución)
- Factory (para creación de objetos)
- Strategy (para algoritmos intercambiables)
- Command (para acciones deshacibles)

## 27. Variables y constantes

**Uso de constantes:**
- Valores mágicos como constantes con nombres descriptivos
- `const MAX_INVENTORY_SIZE = 30`
- `const DAY_DURATION_SECONDS = 1440`

**Uso de enums:**
- Para estados finitos: `enum State { IDLE, WALKING, RUNNING }`
- Para categorías: `enum Category { GAMEPLAY, UI, AUDIO }`

## 28. Funciones helper

**Extracción de lógica común:**
- Funciones matemáticas (distance, lerp, clamp)
- Funciones de validación (is_valid_position, is_valid_item)
- Funciones de formato (format_time, format_money)

**Ubicación:**
- `scripts/utils/math_utils.gd`
- `scripts/utils/validation_utils.gd`
- `scripts/utils/format_utils.gd`

## 29. Performance - buenas prácticas

**Buenas prácticas de rendimiento:**
- Evitar new() en _process() (reutilizar objetos)
- Usar object pooling para entidades frecuentes
- Evitar consultas costosas en loops
- Usar señales en lugar de polling
- Cachear resultados de cálculos costosos

## 30. Seguridad - buenas prácticas

**Buenas prácticas de seguridad:**
- Nunca exponer datos sensibles en logs
- Validar input del usuario (cheats, exploits)
- Sanitizar datos de archivos externos
- Usar versiones fijas de dependencias

## 31. Internacionalización (preparación para M87)

**Preparación para localización:**
- Todas las cadenas de texto para UI externalizadas
- Sin texto hardcodeado en código (usar TranslationServer)
- Formato de fecha/hora localizable
- Números y monedas localizables

## 32. Accesibilidad (preparación para M58)

**Preparación para accesibilidad:**
- UI soporta navegación por teclado
- UI soporta lectores de pantalla
- Contrastes de color suficientes
- Tamaños de fuente ajustables
- Textos descriptivos para imágenes

## 33. Validación de inputs

**Validación de inputs del usuario:**
- Validar rangos de valores (0-1 para normalized)
- Validar que existan referencias (NPC, item, misión)
- Validar que no se introduzcan valores corruptos
- Proporcionar valores por defecto seguros

## 34. Error handling

**Estrategia de error handling:**
- Fail-safe: el juego no crashea, degrada gracefulmente
- Mensajes de error claros para el usuario
- Logging de errores para debugging (M103)
- Fallbacks para recursos faltantes

## 35. Optimización de assets

**Buenas prácticas de assets:**
- Comprimir texturas sin pérdida visual
- Usar LODs para modelos 3D (M50)
- Usar atlases para texturas
- Comprimir audio (M41, M43)
- Minimizar draw calls (M61)

## 36. Memory management

**Buenas prácticas de memoria:**
- Liberar recursos cuando no se usan
- Usar `queue_free()` para objetos no necesarios
- Evitar memory leaks en señales
- Monitorear uso de memoria en profiler

## 37. Multi-threading (Godot 4.x)

**Precauciones con threads:**
- Godot single-threaded principal, cuidado con threads adicionales
- Usar Mutex para datos compartidos
- Evitar llamadas a Godot API desde threads secundarios
- Considerar multithreading solo para cálculos pesados

## 38. Code reviews - checklist detallado

**Checklist de code review:**
- [ ] Código sigue convenciones de nomenclatura
- [ ] No hay código duplicado evidente
- [ ] Métodos dentro de límites de tamaño (50 líneas)
- [ ] Clases dentro de límites de tamaño (300 líneas)
- [ ] Documentación presente en APIs públicas
- [ ] No hay warnings de Godot (0 errores en Console)
- [ ] Tests cubren cambios (M112)
- [ ] No introduce deudas técnicas sin registro
- [ ] No rompe backward compatibility
- [ ] Código es legible y mantenible
- [ ] No hay hardcoded values (usar constantes)
- [ ] Validaciones de inputs presentes
- [ ] Error handling robusto
- [ ] Performance aceptable (no cuello de botella)
- [ ] Security: no datos sensibles expuestos

## 39. Documentación de deudas técnicas

**Formato de registro:**
```markdown
## Deuda Técnica ID001

**Descripción:** Sistema de inventario monolítico, difícil de probar
**Impacto:** Alta - bloquea testing de M14
**Causa:** Arquitectura inicial rápida sin separación de responsabilidades
**Prioridad:** Alta - resolver antes de M1
**Estado:** Pendiente
**Dueño:** M14
**Estimación:** 2 días
**Plan:** Extraer `InventoryComponent`, separar `InventoryUI`, crear `InventoryManager`
```

## 40. Integración continua de calidad

**Automatización:**
- Linter en pre-commit (si disponible)
- CI que verifique convenciones (si disponible)
- Tests automáticos en CI (M118)
- Análisis de coverage de tests (M112)

**Manual:**
- Code reviews para cambios críticos
- Sprints técnicos periódicos
- Auditoría de deuda técnica trimestral
