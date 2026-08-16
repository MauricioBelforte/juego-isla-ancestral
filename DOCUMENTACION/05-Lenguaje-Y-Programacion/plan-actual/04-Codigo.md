**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 05: Lenguaje y Programación

## 1. Carácter del Componente

Módulo de **convenciones y patrones**. No genera código de juego aún (se aplica desde el hito M1 en adelante). Los testings 06/07 se incorporarán cuando los primeros scripts existan (validación de convenciones con linter/estático); por ahora no aplican.

## 2. Archivos que este módulo influye directamente

| Archivo futuro | Sistema | Módulo dueño |
|---|---|---|
| `scripts/core/event_bus.gd` | EventBus | M05/M07 |
| `scripts/core/game_clock.gd` | Reloj/calendario | M29 |
| `scripts/core/logger.gd` | Logs con rotación | M05 |
| `scripts/core/error_handler.gd` | Errores central | M05 |
| `scripts/core/settings.gd` | Config | M05/M58 |
| `scripts/world/voxel/*` | Voxel | M08 |
| `scripts/gameplay/player/*` | Jugador | M11 |

## 3. Decisiones que otros módulos consumen

| Decisión | Consumida por |
|---|---|
| GDScript primario + C# opcional | Todos los módulos de código |
| Convenciones (snake_case, tipado, 4 espacios) | Todos los módulos de código |
| EventBus tipado central | M07, M59, M29 |
| Patrón autoload para servicios | M07 (arquitectura) |
| Logger+ErrorHandler obligatorios | M59 (guardado), M61 (rendimiento) |
| Regla de capas (gameplay sin UI) | M53 (UI), M07 |

## 4. Pendientes del módulo (dueño asignado)

| Pendiente | Dueño |
|---|---|
| Definir si los estados del jugador son nodos o enums+match | M11 Personaje |
| Definir lista final de autoloads (bootstrap) | M07 Arquitectura |
| Definir el fichero `.gdignore`/estructura de tests unitarios | M-QA |
| Configurar linter/estático de Godot (gdformat/gdlint si se adopta) | M1 (prototipo) |

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 01:35:00
**Estado:** Completado (convenciones; aplicación en M1)

### Lo que hice
- Decidí GDScript como lenguaje principal con justificación (Voxel Tools cubre el rendimiento).
- Resolví los 31 puntos del plan maestro (sección 4) con diseño de patrones transversales.
- Guía de convenciones verificable + arquitectura de carpetas + reglas "done".

### Lo que NO pude hacer (honestidad obligatoria)
- Ejecutar linter/estático real → no existe el proyecto aún (hito M1).
- Validar que las convenciones "se sienten bien" en código real → requiere prototipo.
- Detalle fino de la state machine del jugador → dueño M11.

### Recomendaciones para el próximo agente
- M07 (Arquitectura): usar EventBus/autoloads/GameState aquí definidos como base del diseño de managers.
- Al crear el proyecto (M1), configurar gdformat/gdlint + CI ligero desde el día 1 para que las convenciones se apliquen automáticamente.