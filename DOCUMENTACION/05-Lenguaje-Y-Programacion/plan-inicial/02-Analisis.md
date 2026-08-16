**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 05: Lenguaje y Programación

## 1. Análisis de los 31 puntos del plan maestro (sección 4)

| # | Punto | Resolución |
|---|---|---|
| 1 | Elegir lenguaje principal | ✅ **GDScript** (Godot 4 nativo) |
| 2 | Evaluar C# | ✅ C# disponible (.NET build) — opcional para sistemas con necesidad de rendimiento |
| 3 | Evaluar GDScript | ✅ Elegido: tipado opcional fuerte, integración total, cero fricción con nodos |
| 4 | Evaluar C++ | ⚠️ No para gameplay; existe vía GDExtension (Voxel Tools ya lo usa) |
| 5 | Convenciones de código | ✅ Este componente (§3 de 03-Diseno) |
| 6 | Nombres de clases | ✅ PascalCase / snake_case por convención Godot |
| 7 | Nombres de variables | ✅ snake_case con `_` de privacidad |
| 8 | Nombres de métodos | ✅ snake_case (Godot) |
| 9 | Namespaces/estructura | ✅ `res://scripts/{sistema}/` + `class_name` globales registrados |
| 10 | Arquitectura de software | ⏳ Diseño detallado en M07 (dependencia; aquí se fijan los principios) |
| 11 | Separar lógica de presentación | ✅ Principio: gameplay sin UI, UI solo llama a managers/servicios |
| 12 | Separar datos de comportamiento | ✅ Resources (datos) vs scripts (comportamiento) |
| 13 | Sistema de eventos | ✅ Diseñado (§4): EventBus singleton con señales tipadas |
| 14 | Sistema de estados | ✅ Diseñado: máquinas de estados por entidad (jugador, NPC) |
| 15 | Sistema de servicios | ✅ Service Locator liviano (autoloads) |
| 16 | Sistema de guardado | ⏳ Diseño en profundidad en M59 (aquí: patrón GameState versionado) |
| 17 | Sistema de configuración | ✅ Autoload Settings con persistencia (cfg) |
| 18 | Sistema de dependencias | ✅ Inyección vía autoloads/resources; evitar singleton espagueti |
| 19 | Serialización | ✅ JSON/Resource; diffs de chunk para voxel (M08) |
| 20 | Sistema de escenas | ✅ SceneManager: carga diégetica entre islas |
| 21 | Sistema de recursos | ✅ Resource DB + ficheros Resources (datos diseñados, RuntimeResource) |
| 22 | Pooling | ✅ Pool de props/partículas; chunks persistentes |
| 23 | Timers | ✅ TimerManager centralizado (GameClock) |
| 24 | Calendario | ✅ GameClock con fecha/estación (M29/M30) |
| 25 | Tareas del jugador | ✅ QuestManager (PRQF: pre-requisitos de progreso) |
| 26 | Logs | ✅ Logger con rotación (AGENTS §18) |
| 27 | Errores | ✅ ErrorHandler: fallback + reporte en consola/archivo |

## 2. Decisión de lenguaje

**GDScript primario**, con estas razones:
- Nada de código C++ en gameplay: el costo de mantenerlo no se justifica en v1.0.
- C# solo si un módulo (ej. pathfinding custom) lo exige — decisión puntual por módulo.
- Voxel Tools (C++) ya cubre el cuello de botella de rendimiento; el resto es lógica de juego.

**Riesgo documentado:** GDScript es menos conocido fuera de Godot; mitigación: convenciones claras + scripts autocontenidos para que agentes IA y futuros freelancers no necesiten formación.

## 3. Análisis de errores típicos a prevenir

| Anti-patrón | Mitigación |
|---|---|
| GameManager monolítico | M07: managers por dominio |
| Código de UI con lógica de negocio | Regla de capas (RF4) con flujo de aprobación |
| Singleton espagueti | Service Locator con interface registrados |
| Eventos sin tipo | `static var signal` tipadas en EventBus |
| Pooling a mano | Pool component reutilizable |
| Strings mágicos para estados | Enums + autoload de constantes |
| Falta de logs en fallos | ErrorHandler obligatorio en todo catch/exception |