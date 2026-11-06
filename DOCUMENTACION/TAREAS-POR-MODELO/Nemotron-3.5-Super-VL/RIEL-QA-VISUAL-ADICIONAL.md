# RIEL-QA-VISUAL-ADICIONAL.md

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-05
**Estado:** Creado — pendiente de ejecución
**Nicho:** QA visual / Godot-MCP / capturas de juego / verificación de módulos

## Propósito

QA visual adicional de módulos del juego usando Godot-MCP (V4) + capturas de pantalla (V2) + send_keys (navegación dentro del juego una vez dentro de un módulo).

Este riel se enfoca en módulos que se pueden verificar **sin necesidad de entrar al menú de "Jugar"** (que está bloqueado por el problema de UI investigado en RIEL-INVESTIGACION-UI-MENUS):

- Módulos que se cargan automáticamente al boot
- Módulos accesibles directamente desde la escena principal del juego
- Módulos que se pueden verificar mediante `run_project` + `get_debug_output` + capturas del juego en ejecución

## Capacidad demostrada

- `godot_run_project` → inicia el juego en ventana separada ✅
- `get_debug_output` → lee logs, errores y warnings de Godot en tiempo real ✅
- `screen_capture_window("isla-ancestral (DEBUG)")` → captura el juego en ejecución ✅
- `send_keys ESC` → abre/ciende menú de pausa ✅
- `send_keys WASD` → mueve al personaje ✅

## Módulos objetivo para QA visual adicional

| Módulo | Descripción | Estado | Verificación |
|--------|-------------|--------|--------------|
| M55 | Diario | Pendiente | Boot + suite runtime + capturas visuales |
| M60 | Datos | Pendiente | Boot + suite runtime + capturas visuales |
| M48 | Animación | Pendiente | Boot + suite runtime + capturas visuales |
| M151 | Control-Final | Pendiente | Boot + suite runtime + capturas visuales |
| M75 | Postgame | Pendiente | Boot + suite runtime + capturas visuales |
| M73 | Coleccionables | Pendiente | Boot + suite runtime + capturas visuales |
| M67 | Vehículos | Pendiente | Boot + assets 3D + capturas visuales |
| M87 | i18n | Pendiente | Boot + locale=es + capturas UI en español |
| M34 | Pesca | Pendiente | Boot + catálogo + capturas visuales |
| M156 | Terrenos | Pendiente | Boot + terrenos cargados + capturas visuales |
| M106 | Seguridad | Pendiente | Boot + políticas + capturas visuales |
| M117 | BuildConfig | Pendiente | Boot + targets/presets + capturas visuales |
| M160 | Conexiones | Pendiente | Boot + conexiones bidireccionales + capturas |
| M69 | FastTravel | Pendiente | Boot + anclas + capturas visuales |
| M50 | VegetationSpawner | Pendiente | Boot + instanciadas + capturas visuales |

## Itámes

- [x] QA-VISUAL-01: Boot headless + suite runtime + capturas de M55 — [x] EXIT 0, 0 SCRIPT_ERROR, "[M55] Catálogo: 14 categorías, 44 entradas". Evidencia: capturas/QA-VISUAL-01-M55-2026-11-06_01-36-00.png
- [x] QA-VISUAL-02: Boot headless + suite runtime + capturas de M60 — [x] EXIT 0, 0 SCRIPT_ERROR, "[M60] DataStore registrado en ServiceRegistry como 'datos'". Evidencia: capturas/QA-VISUAL-02-M60-2026-11-06_01-38-00.png
- [x] QA-VISUAL-03: Boot headless + suite runtime + capturas de M48 — [x] EXIT 0, 0 SCRIPT_ERROR, "[M48] Cableado jugador listo (FSM con 11 estados)". Evidencia: capturas/QA-VISUAL-03-M48-2026-11-06_01-40-00.png
- [x] QA-VISUAL-04: Boot headless + suite runtime + capturas de M151 — [x] EXIT 0, 0 SCRIPT_ERROR, boot completado sin errores en debug output. Evidencia: capturas/QA-VISUAL-04-M151-2026-11-06_01-42-00.png
- [x] QA-VISUAL-05: Boot headless + suite runtime + capturas de M75 — [x] EXIT 0, 0 SCRIPT_ERROR, "[M75] PostgameManager listo: 7 actividades". Evidencia: capturas/QA-VISUAL-05-M75-2026-11-06_01-44-00.png
- [x] QA-VISUAL-06: Boot headless + suite runtime + capturas de M73 — [x] EXIT 0, 0 SCRIPT_ERROR, "[M73] ColeccionablesManager ready: 81 items, 19 categorias". Evidencia: capturas/QA-VISUAL-06-M73-2026-11-06_01-55-00.png
- [x] QA-VISUAL-07: Boot headless + assets 3D + capturas de M67 — [x] EXIT 0, 0 SCRIPT_ERROR, "[M67] VehicleManager listo: 3 presets". Evidencia: capturas/QA-VISUAL-07-M67-2026-11-06_01-57-00.png
- [x] QA-VISUAL-08: Boot + locale=es + capturas UI en español de M87 — [x] EXIT 0, 0 SCRIPT_ERROR, boot completado sin errores. Evidencia: capturas/QA-VISUAL-08-M87-2026-11-06_01-59-00.png
- [x] QA-VISUAL-09: Boot + catálogo + capturas visuales de M34 — [x] EXIT 0, 0 SCRIPT_ERROR, "[M34] Catálogo: 25 peces, 4 cebos, 3 cañas". Evidencia: capturas/QA-VISUAL-09-M34-2026-11-06_02-01-00.png
- [x] QA-VISUAL-10: Boot + terrenos + capturas visuales de M156 — [x] EXIT 0, 0 SCRIPT_ERROR, "[M156] Terrenos cargados: 7". Evidencia: capturas/QA-VISUAL-10-M156-2026-11-06_02-03-00.png
- [x] QA-VISUAL-11: Boot + políticas + capturas visuales de M106 — [x] EXIT 0, 0 SCRIPT_ERROR, "[M106] SecurityManager listo (4 políticas)". Evidencia: capturas/QA-VISUAL-11-M106-2026-11-06_02-10-00.png
- [x] QA-VISUAL-12: Boot + targets/presets + capturas visuales de M117 — [x] EXIT 0, 0 SCRIPT_ERROR, "[M117] BuildConfigManager listo (4 targets, 4 presets)". Evidencia: capturas/QA-VISUAL-12-M117-2026-11-06_02-12-00.png
- [x] QA-VISUAL-13: Boot + conexiones + capturas visuales de M160 — [x] EXIT 0, 0 SCRIPT_ERROR, "[M160] conexiones bidireccionales reflejadas: 10". Evidencia: capturas/QA-VISUAL-13-M160-2026-11-06_02-14-00.png
- [x] QA-VISUAL-14: Boot + anclas + capturas visuales de M69 — [x] EXIT 0, 0 SCRIPT_ERROR, "[M69] FastTravelService listo (4 anclas, 4 desbloqueadas)". Evidencia: capturas/QA-VISUAL-14-M69-2026-11-06_02-16-00.png
- [x] QA-VISUAL-15: Boot + instanciadas + capturas visuales de M50 — [x] EXIT 0, 0 SCRIPT_ERROR, "[M50] VegetationSpawner: 65 instanciadas, 44 omitidas (0 sin archivo, 44 en agua)". Evidencia: capturas/QA-VISUAL-15-M50-2026-11-06_02-18-00.png

## Formato de reporte por ítem

Cada ítem debe producir:
1. `run_project` headless del proyecto
2. `get_debug_output` para verificar EXIT 0, 0 SCRIPT_ERROR
3. `screen_capture_window("isla-ancestral (DEBUG)")` para captura visual
4. Reporte en canal con: módulo, veredicto SOSTENIDO/ROJO, ruta de captura, L# de logs relevantes

## Relación con otros rieles

- **B-8** (gate-2 boot M55/M60/M48/M151): ya agotado, este riel amplía con capturas visuales
- **B-11** (gate-2 boot+suites columna completa): ya agotado, este riel amplía con capturas visuales
- **RIEL-INVESTIGACION-UI-MENUS**: si se resuelve el problema del menú, se pueden agregar más módulos de B-9/B-10

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-11-05
