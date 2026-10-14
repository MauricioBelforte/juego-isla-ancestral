**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 05: Lenguaje y Programación

## 1. Carácter del Componente

Módulo de **convenciones y patrones**. No genera código de juego aún (se aplica desde el hito M1 en adelante). Los testings 06/07 se incorporarán cuando los primeros scripts existan (validación de convenciones con linter/estático); por ahora no aplican.

## 2. Archivos que este módulo influye directamente

| Archivo real (verificado 2026-10-13) | Sistema | Módulo dueño |
|---|---|---|
| `scripts/core/event_bus.gd` | EventBus (autoload `EventBus`) | M05/M07 |
| `scripts/time/game_clock.gd` | Reloj/calendario (autoload `GameTime`) | M29 |
| `scripts/logging/logger.gd` | Logs con rotación (autoload `GameLogger`) | M05 |
| `scripts/core/game_settings.gd` | Config (autoload `GameSettings`) | M05/M58 |
| `scripts/world/` (block_*, terreno) | Voxel/mundo | M08 |
| `scripts/player/` (player.gd, equipment_*) | Jugador | M11 |
| (NO existe) `scripts/core/error_handler.gd` | Errores central | M05 — diseñado (03-Diseno §3), SIN implementar |

> **Drift de rutas corregido (2026-10-13, DeepSeek-V4.1-Flash).** La tabla previa citaba rutas inexistentes:
> `scripts/core/game_clock.gd` (real: `scripts/time/game_clock.gd`), `scripts/core/logger.gd` (real:
> `scripts/logging/logger.gd`), `scripts/core/settings.gd` (real: `scripts/core/game_settings.gd`) y
> `scripts/gameplay/player/*` (real: `scripts/player/`; no existe `scripts/gameplay/`). Además
> `scripts/core/error_handler.gd` **NO existe** en el árbol: el patrón ErrorHandler está diseñado pero
> sin implementación. Medición: `find game/isla-ancestral/scripts -name '<x>.gd'` + bloque `[autoload]`
> de `project.godot`. Esto cierra el drift señalado en la fila 05 de `CHECKLIST-GLOBAL.md`.

## 3. Decisiones que otros módulos consumen

| Decisión | Consumida por |
|---|---|
| GDScript primario + C# opcional | Todos los módulos de código |
| Convenciones (snake_case, tipado, 4 espacios) | Todos los módulos de código |
| EventBus tipado central | M07, M59, M29 |
| Patrón autoload para servicios | M07 (arquitectura) |
| Logger+ErrorHandler obligatorios | M59 (guardado), M61 (rendimiento) |
| Regla de capas (gameplay sin UI) | M53 (UI), M07 |
| FSM del jugador: `enum`+`match` en `RefCounted` (no nodos) | M11 (`player_fsm.gd`) |
| Config global vía autoload `GameSettings` (señal `settings_changed`) | M58 (accesibilidad) |
| Estado del mundo por EventBus tipado (dominio `world`) | M08 (`chunk_modified`, `block_placed`) |

> **Flujos M11/M58/M08 documentados (2026-10-14, DeepSeek-V4.1-Flash).** Cierra los ítems
> `G. Documentar flujo hacia M11/M58/M08` del `05-Checklist.md`. Medición (rutas relativas a
> `game/isla-ancestral/`):
> - **M11** — `scripts/player/player_fsm.gd` es `class_name PlayerFSM` + `extends RefCounted`
>   (L1-2), `enum Estado` (L25), `transicionar()` (L108), `derivar(snapshot)` (L125). Es la
>   convención "lógica pura en `RefCounted`, sin nodos" (03-Diseno §6.5 y §7.x) aplicada a la
>   state machine del jugador. Eventos del jugador: `EventBus.PlayerEvents`
>   (`core/event_bus.gd`, `player_died`/`level_up`/`damage_taken`).
> - **M58** — el autoload `GameSettings` (`scripts/core/game_settings.gd`, fila de §2 de este
>   doc) declara `signal settings_changed` (L7) y persiste en `user://settings.cfg` (L29). La
>   config de accesibilidad vive en `scripts/accesibilidad/` (`accesibilidad_manager.gd` L25
>   `RUTA_PERFIL := "user://accessibility_profile.json"`, `aplicador_accesibilidad.gd`).
> - **M08** — el dominio `world` del EventBus tipado define el estado de chunks:
>   `core/event_bus.gd` L50-56 (`block_placed`, `block_removed`, `chunk_modified`,
>   `biome_changed`); los scripts de mundo están en `scripts/world/` (`block_catalog.gd`,
>   `block_type.gd`).

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
- Resolví los 27 puntos del plan maestro (sección 4) con diseño de patrones transversales.
- Guía de convenciones verificable + arquitectura de carpetas + reglas "done".

### Lo que NO pude hacer (honestidad obligatoria)
- Ejecutar linter/estático real → no existe el proyecto aún (hito M1).
- Validar que las convenciones "se sienten bien" en código real → requiere prototipo.
- Detalle fino de la state machine del jugador → dueño M11.

### Recomendaciones para el próximo agente
- M07 (Arquitectura): usar EventBus/autoloads/GameState aquí definidos como base del diseño de managers.
- Al crear el proyecto (M1), configurar gdformat/gdlint + CI ligero desde el día 1 para que las convenciones se apliquen automáticamente.