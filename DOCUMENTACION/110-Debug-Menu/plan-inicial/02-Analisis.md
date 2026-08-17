**Modelo:** SWE-1.6
**Plataforma:** Devin

# 02-Analisis.md — Módulo 110: Debug Menu

## 1. Análisis de los puntos del plan maestro (sección 109)

| # | Punto | Resolución |
|---|---|---|
| 1 | Teletransportar jugador | ✅ Input de coordenadas X/Y/Z o selección de POI predefinido |
| 2 | Cambiar hora | ✅ Slider o input para hora (0-23) del juego (M29 GameClock) |
| 3 | Cambiar estación | ✅ Dropdown para seleccionar estación (M29) |
| 4 | Cambiar clima | ✅ Dropdown para seleccionar clima (M31) |
| 5 | Dar objetos | ✅ Selector de item + cantidad, agregar al inventario (M14) |
| 6 | Dar dinero | ✅ Input de cantidad, agregar al dinero del jugador (M38) |
| 7 | Completar misión | ✅ Selector de misión, marcar como completada (M22) |
| 8 | Desbloquear herramienta | ✅ Selector de herramienta, desbloquear (M13) |
| 9 | Desbloquear isla | ✅ Selector de isla, desbloquear para viaje (M28) |
| 10 | Desbloquear Sello | ✅ Selector de Sello, desbloquear (M22) |
| 11 | Resetear NPC | ✅ Selector de NPC, reiniciar posición y estado (M19) |
| 12 | Resetear puzzle | ✅ Selector de puzzle, reiniciar estado inicial (M24) |
| 13 | Regenerar chunk | ✅ Input de coordenadas de chunk, forzar regeneración (M08) |
| 14 | Mostrar colliders | ✅ Toggle para visualizar colliders (debug draw) |
| 15 | Mostrar FPS | ✅ Toggle para mostrar contador de FPS (overlay) |
| 16 | Mostrar chunks | ✅ Toggle para visualizar chunks cargados/activos |
| 17 | Mostrar navegación | ✅ Toggle para visualizar paths de NPC (M19/M64) |
| 18 | Mostrar hitboxes | ✅ Toggle para visualizar hitboxes de entidades |
| 19 | Mostrar estados de IA | ✅ Toggle para mostrar estado actual de IA de NPC |
| 20 | Exportar diagnóstico | ✅ Botón para exportar estado + logs (M102/M103) |

## 2. Alternativas consideradas

| Enfoque | Pros | Contras | Decisión |
|---|---|---|---|---|
| Godot Canvas UI | Nativo, fácil de implementar | Limitado, poco personalizable | ⚠️ Parcial |
| UI Toolkit (Godot 4) | Moderno, potente | Curva de aprendizaje más alta | ✅ ELEGIDO |
| Consola de comandos | Flexible, power user | Menos intuitivo para funciones visuales | ❌ Descartado |
| Herramienta externa (ImGui) | Potente, común en AAA | Requiere integración compleja | ❌ Descartado |

**Decisión final:** UI Toolkit de Godot 4.x con paneles organizados por categoría, balanceando facilidad de uso y potencia.

## 3. Organización del Debug Menu

**Estructura de paneles:**
```
Debug Menu (F1)
├── Jugador
│   ├── Teletransporte (coordenadas / POI)
│   ├── Inventario (dar objetos, dinero)
│   └── Progresión (misiones, Sellos, herramientas)
├── Mundo
│   ├── Tiempo (hora, estación)
│   ├── Clima (tipo, intensidad)
│   ├── Chunks (regenerar, visualizar)
│   └── Generación (seed, forzar regen)
├── Entidades
│   ├── NPC (seleccionar, resetear, estado IA)
│   ├── Puzzles (seleccionar, resetear)
│   └── Hitboxes/Colliders (toggle visualización)
├── Visualización
│   ├── FPS (toggle)
│   ├── Chunks (toggle)
│   ├── Navegación (toggle)
│   └── Debug Draw (colliders, hitboxes)
└── Sistema
    ├── Logs (consola in-game, filtros)
    ├── Diagnóstico (exportar estado)
    └── Configuración (guardar/cargar debug state)
```

## 4. Integración con otros módulos

### M29 (Tiempo y Calendario)
- Cambio de hora: `GameClock.avanzar_hasta(hora)`
- Cambio de estación: `GameClock.set_estacion(estacion)`

### M31 (Clima)
- Cambio de clima: `WeatherSystem.set_clima(tipo)`

### M14 (Inventario)
- Dar objetos: `Inventory.add_item(item_id, cantidad)`
- Dar dinero: `Economy.add_money(cantidad)`

### M22 (Historia Principal/Misiones)
- Completar misión: `QuestSystem.complete_mission(mission_id)`
- Desbloquear Sello: `QuestSystem.unlock_sello(sello_id)`

### M13 (Herramientas)
- Desbloquear herramienta: `ToolSystem.unlock_tool(tool_id)`

### M28 (Viajes)
- Desbloquear isla: `TravelSystem.unlock_isla(isla_id)`

### M19 (NPC)
- Resetear NPC: `NPCManager.reset_npc(npc_id)`
- Estado IA: `NPCManager.get_ai_state(npc_id)`

### M24 (Puzzles)
- Resetear puzzle: `PuzzleSystem.reset_puzzle(puzzle_id)`

### M08 (Mundo Voxel)
- Regenerar chunk: `WorldVoxel.regenerate_chunk(chunk_x, chunk_z)`

### M103 (Logging)
- Consola in-game: `Logger.get_logs_filtered()`
- Exportar diagnóstico: `Logger.export_last_lines(1000)`

### M102 (Bug Tracking)
- Exportar diagnóstico: generar `bug_{timestamp}.log` + metadata
- Abrir GitHub con plantilla pre-llenada

## 5. Funciones de teletransporte

**Opciones:**
1. **Coordenadas manuales:** Input X/Y/Z para teletransporte absoluto
2. **POI predefinidos:** Dropdown con puntos de interés (templos, pueblos, ruinas)
3. **Posición del cursor:** Teletransportar a donde apunta el cursor
4. **Posición de NPC:** Teletransportar junto a NPC seleccionado

**POI predefinidos:**
- Pueblo Aurora (centro)
- Templo de la Brisa (entrada)
- Ruinas del Valle (entrada)
- Isla de Coral (muelle)
- Gran Vapor (cubierta)
- Casa del jugador
- Tienda de Hana
- Forja del herrero

## 6. Visualizaciones debug

### Colliders
- Toggle: `DebugDraw.draw_colliders = true/false`
- Colores: verde (estático), rojo (dinámico), amarillo (trigger)
- Opción: mostrar solo colliders cercanos al jugador

### FPS
- Overlay en esquina superior derecha
- Formato: `FPS: 60 (ms: 16.7)`
- Color: verde (>50), amarillo (30-50), rojo (<30)
- Toggle: ocultar/mostrar

### Chunks
- Visualizar chunks cargados (verde)
- Visualizar chunks activos (amarillo)
- Visualizar chunks descargados (rojo)
- Opción: mostrar chunk del jugador (resaltado)

### Navegación
- Visualizar paths de NPC actual
- Visualizar destino actual
- Color: azul (path), blanco (destino)
- Toggle: por NPC o todos los NPC

### Hitboxes
- Visualizar hitboxes de jugador (azul)
- Visualizar hitboxes de NPC (verde)
- Visualizar hitboxes de objetos (amarillo)
- Toggle: mostrar todos o solo cercanos

### Estados de IA
- Mostrar estado actual sobre cada NPC
- Formato: `[IDLE]` / `[PATHFINDING]` / `[INTERACTING]`
- Toggle: mostrar todos o solo seleccionado

## 7. Consola in-game

**Características:**
- Scrollable (últimas 100 líneas)
- Filtros por nivel (DEBUG, INFO, WARNING, ERROR, CRITICAL)
- Filtros por categoría (BOOT, SYSTEM, GAMEPLAY, WORLD, etc.)
- Búsqueda de texto
- Auto-scroll a última línea (opcional)
- Coloreado por nivel (DEBUG=gris, INFO=blanco, WARNING=amarillo, ERROR=rojo, CRITICAL=magenta)

**Integración con M103:**
- `Logger.get_logs_filtered(level, category, search)`
- Actualización en tiempo real (suscripción a señales de Logger)

## 8. Exportar diagnóstico

**Botón "Exportar Diagnóstico":**
1. Captura metadata del juego:
   - Versión del juego
   - Plataforma (OS, CPU, GPU, RAM)
   - Seed de generación (M08/M10)
   - Posición del jugador
   - Estado de FPS
   - Memoria usada
   - Hora del juego (M29)
   - Estación actual (M29)
   - Clima actual (M31)

2. Captura logs:
   - Últimas 1000 líneas de log (M103)
   - Filtrado por nivel (ERROR+)

3. Genera archivo `diagnostico_{timestamp}.zip`:
   - `metadata.json` (info del sistema)
   - `game.log` (logs)
   - `screenshot.png` (captura de pantalla)

4. Opción "Reportar Bug":
   - Abre GitHub con plantilla pre-llenada (M102)
   - Adjunta archivo de diagnóstico automáticamente

## 9. Configuración y persistencia

**Configuración guardada en `user://debug_config.json`:**
```json
{
  "position": {"x": 100, "y": 100},
  "size": {"width": 800, "height": 600},
  "panel_visibility": {
    "jugador": true,
    "mundo": true,
    "entidades": false,
    "visualizacion": true,
    "sistema": true
  },
  "debug_toggles": {
    "colliders": false,
    "fps": true,
    "chunks": false,
    "navegacion": false,
    "hitboxes": false,
    "ai_states": false
  },
  "console_filters": {
    "level": "INFO",
    "category": "ALL",
    "auto_scroll": true
  }
}
```

**Carga al iniciar el debug menu:**
- Leer configuración
- Restaurar posición y tamaño
- Restaurar visibilidad de paneles
- Restaurar toggles de visualización

**Guardado al cerrar:**
- Guardar posición y tamaño
- Guardar visibilidad de paneles
- Guardar toggles de visualización
- Guardar filtros de consola

## 10. Seguridad y builds

**Solo en builds de desarrollo:**
- `OS.is_debug_build()` retorna true
- En release build: debug menu desactivado completamente
- Atajo de teclado no funciona en release

**Protección adicional:**
- Opción de password para debug menu (opcional)
- Log de accesos al debug menu (M103)
- Advertencia al abrir: "DEBUG MENU - Solo para desarrollo"
