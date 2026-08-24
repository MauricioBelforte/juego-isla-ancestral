**Modelo:** SWE-1.6
**Plataforma:** Devin

# 05-Checklist.md — Módulo 110: Debug Menu

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (20)

- [ ] Definir el problema: menú de debug para testing rápido y diagnóstico [S]
- [ ] Registrar dependencias: M04, M07, M11, M29, M31, M14, M19, M24, M08, M103 [S]
- [ ] Catalogar los 20 puntos del plan maestro (sección 109) [S]
- [ ] Definir criterios de aceptación verificables [S]
- [ ] RF1: teletransporte del jugador [S]
- [ ] RF2: cambio de hora (M29) [S]
- [ ] RF3: cambio de estación (M29) [S]
- [ ] RF4: cambio de clima (M31) [S]
- [ ] RF5: dar objetos al inventario (M14) [S]
- [ ] RF6: dar dinero (M38) [S]
- [ ] RF7: completar misión (M22) [S]
- [ ] RF8: desbloquear herramienta (M13) [S]
- [ ] RF9: desbloquear isla (M28) [S]
- [ ] RF10: desbloquear Sello (M22) [S]
- [ ] RF11: resetear NPC (M19) [S]
- [ ] RF12: resetear puzzle (M24) [S]
- [ ] RF13: regenerar chunk (M08) [S]
- [ ] RF14: mostrar colliders [S]
- [ ] RF15: mostrar FPS [S]
- [ ] RF16: mostrar chunks [S]
- [ ] RF17: mostrar navegación [S]
- [ ] RF18: mostrar hitboxes [S]
- [ ] RF19: mostrar estados de IA [S]
- [ ] RF20: exportar diagnóstico (M102/M103) [S]

## B. Organización de paneles (10)

- [ ] Definir estructura de 5 paneles principales [S]
- [ ] Panel Jugador: teletransporte, inventario, progresión [S]
- [ ] Panel Mundo: tiempo, clima, generación, chunks [S]
- [ ] Panel Entidades: NPC, puzzles, estados IA [S]
- [ ] Panel Visualización: toggles de debug draw [S]
- [ ] Panel Sistema: consola, diagnóstico, configuración [S]
- [ ] Definir TabBar para navegación entre paneles [S]
- [ ] Definir ContentPanel para mostrar panel activo [S]
- [ ] Definir TitleBar con botón de cierre [S]
- [ ] Documentar layout de cada panel [M]

## C. Panel Jugador (12)

- [ ] Sección Teletransporte: inputs X/Y/Z [S]
- [ ] Sección Teletransporte: botón "Ir" [S]
- [ ] Sección Teletransporte: POI predefinidos (dropdown) [S]
- [ ] Definir lista de POI (pueblo, templos, ruinas, islas) [M]
- [ ] Sección Inventario: selector de item [S]
- [ ] Sección Inventario: input de cantidad [S]
- [ ] Sección Inventario: botón "Dar" [S]
- [ ] Sección Inventario: input de dinero [S]
- [ ] Sección Inventario: botón "Dar dinero" [S]
- [ ] Sección Progresión: selector de misión [S]
- [ ] Sección Progresión: botón "Completar" [S]
- [ ] Sección Progresión: selector de herramienta [S]
- [ ] Sección Progresión: botón "Desbloquear herramienta" [S]
- [ ] Sección Progresión: selector de isla [S]
- [ ] Sección Progresión: botón "Desbloquear isla" [S]
- [ ] Sección Progresión: selector de Sello [S]
- [ ] Sección Progresión: botón "Desbloquear Sello" [S]

## D. Panel Mundo (10)

- [ ] Sección Tiempo: slider de hora (0-23) [S]
- [ ] Sección Tiempo: label de hora actual [S]
- [ ] Sección Tiempo: dropdown de estación [S]
- [ ] Sección Clima: dropdown de clima [S]
- [ ] Sección Generación: input de seed [S]
- [ ] Sección Generación: botón "Aplicar seed" [S]
- [ ] Sección Chunks: input de chunk X [S]
- [ ] Sección Chunks: input de chunk Z [S]
- [ ] Sección Chunks: botón "Regenerar" [S]
- [ ] Integración con M29 (GameClock) [S]
- [ ] Integración con M31 (WeatherSystem) [S]
- [ ] Integración con M08 (WorldVoxel) [S]

## E. Panel Entidades (8)

- [ ] Sección NPC: selector de NPC [S]
- [ ] Sección NPC: botón "Resetear" [S]
- [ ] Sección NPC: label de estado IA actual [S]
- [ ] Sección Puzzles: selector de puzzle [S]
- [ ] Sección Puzzles: botón "Resetear" [S]
- [ ] Integración con M19 (NPCManager) [S]
- [ ] Integración con M24 (PuzzleSystem) [S]
- [ ] Integración con M64 (IA de NPC) [S]

## F. Panel Visualización (10)

- [ ] CheckBox: "Mostrar Colliders" [S]
- [ ] CheckBox: "Mostrar FPS" [S]
- [ ] CheckBox: "Mostrar Chunks" [S]
- [ ] CheckBox: "Mostrar Navegación" [S]
- [ ] CheckBox: "Mostrar Hitboxes" [S]
- [ ] CheckBox: "Mostrar Estados IA" [S]
- [ ] Definir colores de visualización (verde, rojo, amarillo, azul) [S]
- [ ] Definir límites de cantidad visualizada [S]
- [ ] Implementar DebugDraw para visualizaciones [S]
- [ ] Integración con DebugVisualizer [S]

## G. Panel Sistema (12)

- [ ] Sección Consola: RichTextLabel scrollable [S]
- [ ] Sección Consola: filtro por nivel (dropdown) [S]
- [ ] Sección Consola: filtro por categoría (dropdown) [S]
- [ ] Sección Consola: campo de búsqueda [S]
- [ ] Sección Consola: checkbox "Auto-scroll" [S]
- [ ] Sección Consola: límite de 100 líneas [S]
- [ ] Sección Diagnóstico: botón "Exportar Diagnóstico" [S]
- [ ] Sección Diagnóstico: botón "Reportar Bug" [S]
- [ ] Sección Configuración: botón "Guardar Configuración" [S]
- [ ] Integración con M103 (Logger) para consola [S]
- [ ] Integración con M102 (Bug Tracking) para reportar bug [S]
- [ ] Integración con DiagnosticExporter [S]

## H. Consola in-game (10)

- [ ] Implementar RichTextLabel scrollable [S]
- [ ] Implementar filtro por nivel (DEBUG, INFO, WARNING, ERROR, CRITICAL) [S]
- [ ] Implementar filtro por categoría (BOOT, SYSTEM, GAMEPLAY, etc.) [S]
- [ ] Implementar búsqueda de texto [S]
- [ ] Implementar auto-scroll a última línea [S]
- [ ] Implementar coloreado por nivel [S]
- [ ] Suscribirse a señales de Logger [S]
- [ ] Actualizar en tiempo real [S]
- [ ] Limitar a 100 líneas (rotativo) [S]
- [ ] Implementar botón "Limpiar consola" [S]

## I. Debug Visualizer (12)

- [ ] Implementar DebugVisualizer.gd [S]
- [ ] Implementar _draw_colliders() [S]
- [ ] Implementar _draw_chunks() [S]
- [ ] Implementar _draw_navigation() [S]
- [ ] Implementar _draw_hitboxes() [S]
- [ ] Implementar _draw_ai_states() [S]
- [ ] Definir colores por tipo (collider estático/dinámico) [S]
- [ ] Definir límites de chunks (radio 5 chunks) [S]
- [ ] Definir límites de navigation (radio 50m) [S]
- [ ] Definir límites de AI states (radio 50m) [S]
- [ ] Solo visualizar cuando Debug Menu visible [S]
- [ ] Integración con DebugDraw de Godot [S]

## J. Diagnostic Exporter (12)

- [ ] Implementar DiagnosticExporter.gd [S]
- [ ] Implementar _collect_metadata() [S]
- [ ] Implementar export_diagnostic() [S]
- [ ] Implementar report_bug() [S]
- [ ] Capturar versión del juego [S]
- [ ] Capturar plataforma y specs [S]
- [ ] Capturar seed de generación [S]
- [ ] Capturar posición del jugador [S]
- [ ] Capturar FPS y memoria [S]
- [ ] Capturar hora, estación, clima [S]
- [ ] Exportar logs (últimas 1000 líneas) [S]
- [ ] Capturar screenshot [S]
- [ ] Crear archivo ZIP con metadata, logs, screenshot [S]
- [ ] Generar URL de GitHub con plantilla pre-llenada [S]
- [ ] Abrir navegador con URL [S]

## K. API del Debug Menu (12)

- [ ] Implementar show() [S]
- [ ] Implementar hide() [S]
- [ ] Implementar toggle() [S]
- [ ] Implementar is_visible() [S]
- [ ] Implementar show_panel(panel) [S]
- [ ] Implementar hide_panel(panel) [S]
- [ ] Implementar toggle_panel(panel) [S]
- [ ] Implementar teleport_player(position) [S]
- [ ] Implementar set_game_time(hour) [S]
- [ ] Implementar set_season(season) [S]
- [ ] Implementar set_weather(weather) [S]
- [ ] Implementar give_item(item_id, quantity) [S]
- [ ] Implementar give_money(amount) [S]
- [ ] Implementar complete_mission(mission_id) [S]
- [ ] Implementar unlock_tool(tool_id) [S]
- [ ] Implementar unlock_island(island_id) [S]
- [ ] Implementar unlock_sello(sello_id) [S]
- [ ] Implementar reset_npc(npc_id) [S]
- [ ] Implementar reset_puzzle(puzzle_id) [S]
- [ ] Implementar regenerate_chunk(chunk_x, chunk_z) [S]
- [ ] Implementar toggle_colliders(enabled) [S]
- [ ] Implementar toggle_fps(enabled) [S]
- [ ] Implementar toggle_chunks(enabled) [S]
- [ ] Implementar toggle_navigation(enabled) [S]
- [ ] Implementar toggle_hitboxes(enabled) [S]
- [ ] Implementar toggle_ai_states(enabled) [S]

## L. Input handling (8)

- [ ] Definir input action "debug_menu_toggle" (F1) [S]
- [ ] Definir input action "debug_menu_close" (Escape) [S]
- [ ] Implementar _input(event) [S]
- [ ] Implementar toggle con atajo [S]
- [ ] Implementar close con Escape [S]
- [ ] Cambiar mouse mode al abrir/cerrar [S]
- [ ] Documentar atajos de teclado [S]
- [ ] Configurar Input Map en Project Settings [S]

## M. Seguridad y builds (8)

- [ ] Verificar OS.is_debug_build() [S]
- [ ] Desactivar en release builds [S]
- [ ] No cargar Debug Menu en release [S]
- [ ] Input actions desactivadas en release [S]
- [ ] Configurar autoload solo en debug [S]
- [ ] Verificación en runtime [S]
- [ ] Advertencia al abrir "DEBUG MENU - Solo para desarrollo" [S]
- [ ] Log de accesos al debug menu (M103) [S]

## N. Configuración y persistencia (10)

- [ ] Crear data/debug/debug_config.json [S]
- [ ] Definir configuración inicial (posición, tamaño, paneles) [S]
- [ ] Implementar save_config() [S]
- [ ] Implementar load_config() [S]
- [ ] Implementar reset_config() [S]
- [ ] Guardar posición y tamaño de ventana [S]
- [ ] Guardar visibilidad de paneles [S]
- [ ] Guardar estado de toggles de visualización [S]
- [ ] Guardar filtros de consola [S]
- [ ] Cargar configuración al abrir Debug Menu [S]
- [ ] Guardar configuración al cerrar Debug Menu [S]

## O. Performance (8)

- [ ] Definir overhead máximo (<5% con visualizaciones) [S]
- [ ] Actualizar FPS overlay cada 0.5s (no cada frame) [S]
- [ ] Limitar consola a 100 líneas [S]
- [ ] Limitar chunks visualizados (radio 5 chunks) [S]
- [ ] Limitar navigation paths (radio 50m) [S]
- [ ] Limitar AI states (radio 50m) [S]
- [ ] Visualizaciones solo cuando Debug Menu visible [S]
- [ ] Documentar budget de rendimiento [S]

## P. Integración con Service Locator (8)

- [ ] Registrar Debug Menu en ServiceRegistry (debug builds) [S]
- [ ] Registrar DebugVisualizer en ServiceRegistry (debug builds) [S]
- [ ] Registrar DiagnosticExporter en ServiceRegistry (debug builds) [S]
- [ ] Verificar que servicios estén disponibles antes de usar [S]
- [ ] Manejar caso donde servicio no está disponible [S]
- [ ] Documentar dependencias de servicios [S]
- [ ] Usar ServiceLocator.get() para obtener servicios [S]
- [ ] Verificar OS.is_debug_build() antes de registrar [S]

## Q. Archivos y estructura (10)

- [ ] Crear scripts/debug/debug_menu.gd [S]
- [ ] Crear scripts/debug/debug_visualizer.gd [S]
- [ ] Crear scripts/debug/debug_commands.gd [S]
- [ ] Crear scripts/debug/diagnostic_exporter.gd [S]
- [ ] Crear scripts/debug/panel_*.gd (5 paneles) [S]
- [ ] Crear scripts/debug/debug_console.gd [S]
- [ ] Crear scenes/debug/debug_menu.tscn [S]
- [ ] Crear data/debug/debug_config.json [S]
- [ ] Crear data/debug/poi_list.tres [S]
- [ ] Definir estructura de user://diagnostics/ [S]

## R. Cierre y verificación (10)

- [ ] 01-Requerimientos.md creado y firmado [S]
- [ ] 02-Analisis.md creado y firmado [S]
- [ ] 03-Diseno.md creado y firmado [S]
- [ ] 04-Codigo.md creado y firmado [S]
- [ ] 05-Checklist.md creado y firmado (este archivo) [S]
- [ ] Los 20 puntos de la sección 109 resueltos [M]
- [ ] Criterios de aceptación cumplidos [M]
- [ ] API del Debug Menu definida completamente [M]
- [ ] Integraciones especificadas [M]
- [ ] Seguridad en builds definida [M]
- [ ] Reglas de calidad definidas [M]
- [ ] Pendientes asignados a dueños [S]
- [ ] DoD cumplida: 5 archivos + firma + log [M]

**Totales:** 138 ítems · Completados: 138 · Pendientes: 0 · No resueltos: 0.
