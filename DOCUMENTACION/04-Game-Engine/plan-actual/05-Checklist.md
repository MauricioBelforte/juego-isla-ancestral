**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 04: Game Engine

**Estado:** `[ ]` pendiente · `[ ]` completado · `[?]` no resuelto. Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

## Reserva actual

- [x] Módulo reservado por GitHub Copilot para validación de la base del proyecto Godot 4.7.2 en la fase F1.
- [x] Registro sincronizado con `CHECKLIST-GLOBAL.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` y `Mensajes entre modelos/ESTADO-PARALELO.md`.
- [x] Validar que el binario Godot 4.7.2 exista y arranque correctamente. **✓ Completado:** Godot 4.7.2 en D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe arranca sin errores.
- [x] Ejecutar el proyecto para descubrir errores de runtime o de configuración. **✓ Completado:** Proyecto en `game/isla-ancestral` carga correctamente; sistema VoxelTerrain + VoxelGeneratorNoise2D + colisión operativos.
- [x] Corregir cualquier problema de arranque antes de continuar con M05/M07. **✓ Completado:** Parse error en `main_island.tscn` reparado (Transform3D y formato de string). Exit code 0.

---

## A. Evaluación de candidatos (12)

- [x] Evaluar Unity contra los requisitos del proyecto [M] (cita: 02-Analisis.md L14 + L45 - ver §7 A1)
- [x] Evaluar Godot contra los requisitos del proyecto [M] (cita: 02-Analisis.md L15 + L8 - ver §7 A2)
- [x] Evaluar Unreal Engine contra los requisitos del proyecto [M] (cita: 02-Analisis.md L16 - ver §7 A3)
- [x] Documentar por qué Unity queda descartado por defecto (costo >200k, voxel sin nativo) [S] (cita: 02-Analisis.md L14 + L45 + L46 - ver §7 A4)
- [x] Documentar por qué Unreal queda descartado (overkill, tasa 5%, curva) [S] (cita: 02-Analisis.md L16 + L63 + L76 - ver §7 A5)
- [x] Registrar la recomendación del Plan-de-produccion §2 como fuente de la decisión [S] (cita: 02-Analisis.md L8 -> Plan-de-produccion.md L111 - ver §7 A6)
- [x] Adoptar **Godot 4.x** como motor del proyecto [S] (cita: 02-Analisis.md L8 + L15 + L29; project.godot L16 ("4.7", "Forward Plus"); Logs/17 - ver §7 A7)
- [x] Documentar la comparativa Unity vs Godot en tabla (costo/voxel/IA/deck) [S] (cita: 02-Analisis.md §3 L43-49 - ver §7 A8)
- [x] Documentar que la decisión es revisable SOLO antes del hito M1 [S] (cita: 02-Analisis.md L8 - ver §7 A9)
- [x] Confirmar con el usuario la adopción de Godot (veto pendiente) [ ] [S] (cita: Logs/17-CONFIRMACION_MOTOR_GODOT-VOXELTOOLS_2026-08-16_06-10-00.md - "Por encargo explicito del usuario... se cerro la decision final del motor"; ver §7 A10)
- [x] Documentar el trade-off de animación (Godot menos maduro que Mecanim) [S] (cita: 02-Analisis.md L22 - ver §7 A11)
- [x] Documentar el trade-off de bolsa de talento (comunidad Godot más chica) [S] (cita: 02-Analisis.md L26 + L55 - ver §7 A12)

## B. Costos y licencias (10)

- [x] Documentar costo Godot: gratis siempre, MIT, sin regalías [S] (cita: 02-Analisis.md L15 y L45; fuente godotengine.org/license verificada 2026-10-12 — ver §6 B1)
- [x] Documentar costo Unity: gratis < USD 200k, Pro ~USD 2.300/asiento/año [S] (cita: 02-Analisis.md L45, tabla comparativa §3 — ver §6 B2)
- [x] Documentar el episodio Runtime Fee 2023 y su cancelación (contexto) [S] (cita: Plan-de-produccion.md L100 — ver §6 B3)
- [x] Documentar el caso Unreal: 5% tras USD 1M de ingresos [S] (cita: 02-Analisis.md L16 + umbral verificado en unrealengine.com/release 2026-10-12 — ver §6 B4)
- [x] Verificar que el modelo autofinanciado es compatible con Godot [S] (cita: 01-Requerimientos.md L23 RF5 y L30 RNF cruzados con 02-Analisis.md L15 — ver §6 B5)
- [x] Documentar costos de assets/plugins a futuro (presupuesto separado) [S] (cita: Plan-de-produccion.md §15 L420 + L271 middleware — ver §6 B6)
- [x] Documentar que Voxel Tools es MIT y gratuito [S] (cita: game/isla-ancestral/addons/zylann.voxel/LICENSE.md L1-3 — ver §6 B7)
- [x] Verificar licencias de exportación (Vulkan/video drivers no requieren fees) [S] (cita: motor MIT (§6 B1) + exportación real en build/ (.pck/.wasm) — ver §6 B8)
- [x] Documentar el costo cero como factor decisiva del análisis [S] (cita: Plan-de-produccion.md L111 — ver §6 B9)
- [x] Registrar el costo de herramientas de apoyo (Blender gratis, etc.) en módulo de arte [S] (cita: 46-Arte-2D/plan-actual/02-Analisis.md L43 — ver §6 B10)

## C. Soporte voxel y rendimiento (14)

- [ ] Documentar Voxel Tools (Zylann) como módulo clave [S]
- [ ] Documentar que Voxel Tools es C++/GDExtension orientado a rendimiento [S]
- [ ] Documentar soporte de terreno editable en tiempo real [S]
- [ ] Documentar colisiones voxel tipo Minecraft del módulo [S]
- [ ] Documentar streaming de chunks infinito [S]
- [ ] Documentar LOD Transvoxel para terreno suave [S]
- [ ] Documentar meshing multihilo (sin bloquear hilo principal) [S]
- [ ] Documentar face culling como requisito innegociable (GDD directiva 1) [S]
- [ ] Documentar greedy meshing como optimización a evaluar [S]
- [ ] Documentar diffs de chunk para persistencia (no guardar mundo entero) [S]
- [ ] Documentar el conteo de draw calls del terreno mesheado [S]
- [ ] Documentar el presupuesto de partículas/vfx del motor [S]
- [ ] Documentar el raycast voxel para herramientas (pala/pico/hacha) [S]
- [ ] Documentar la validación 60 FPS como criterio de aceptación del motor [S]

## D. Ecosistema del motor (10)

- [ ] Documentar estado de la comunidad Godot (activa, en crecimiento) [S]
- [ ] Documentar la documentación oficial estable de Godot 4.x [S]
- [ ] Documentar el mercado de plugins (Voxel Tools + diálogos + UI) [S]
- [ ] Documentar las opciones MCP de Godot para desarrollo con IA (GDAI MCP, godot-mcp) [S]
- [ ] Documentar comparativa MCP vs Unity (MCP oficial beta + Unity MCP 12.7k★) [S]
- [ ] Documentar los editores de diálogo (sistema de nodos de Godot) [S]
- [ ] Verificar que el pipeline de audio cubre lo-fi + ASMR [S]
- [ ] Verificar que la UI de Control nodes cubre HUD/inventario/hotbar [S]
- [ ] Documentar que el networking no es requisito v1.0 [S]
- [ ] Documentar el estado del editor de partículas (GPU particles) [S]

## E. Versión y gestión del motor (10)

- [ ] Documentar la regla de fijar la versión del motor [S]
- [ ] Documentar la regla de NO actualizar arbitrariamente durante producción [S]
- [ ] Registrar el campo Versión exacta como pendiente del hito M1 [S]
- [ ] Documentar el pinneado de Voxel Tools contra la versión de Godot [S]
- [ ] Documentar el procedimiento de migración de versión (log + changelog) [S]
- [ ] Documentar parche de seguridad crítico como única excepción [S]
- [ ] Documentar la congelación de assets/plugins por versión [S]
- [ ] Registrar el renderer elegido: Forward+ (Vulkan) [S]
- [ ] Documentar el renderer Mobile como alternativa para builds livianas [S]
- [ ] Documentar la decisión de física (Godot Physics, Jolt si hace falta) [S]

## F. Configuración del proyecto base (18)

- [ ] Instalar Godot 4.x versión estable (pendiente hito M1) [M]
- [ ] Crear el proyecto con la versión fijada [S]
- [ ] Agregar `.godot/` al .gitignore [S]
- [ ] Configurar renderer Forward+ [S]
- [ ] Configurar niveles de calidad Baja/Media/Alta [M]
- [ ] Configurar resolución y escalado (window mode, aspect) [S]
- [ ] Configurar framerate objetivo 60 y VSync opcional [S]
- [ ] Definir capas de física (voxel, jugador, NPC, props, UI, receptores) [M]
- [x] Configurar Input Map: mover (WASD+stick) [S] (acciones mover_norte/sur/este/oeste con teclado y stick izquierdo)
- [x] Configurar Input Map: cámara rotación/zoom [S] (camara_zoom_in/out por rueda; rotación por stick derecho)
- [x] Configurar Input Map: herramienta/interacción [S] (interactuar=E, colocar=Q)
- [x] Configurar Input Map: inventario/hotbar 1-9 [S] (inventario=B, favorito=F, hotbar_1..9)
- [x] Crear escena Bootstrap (config + carga) [M] (scripts/core/bootstrap.gd: registra servicios y carga main_island; verificado en runtime)
- [ ] Crear escena Main (world + player + cámara) [M]
- [ ] Crear estructura de carpetas del proyecto (scenes, scripts, resources, data) [S]
- [ ] Crear export presets Windows/Linux/Web/SteamOS [M]
- [ ] Configurar autoloads/singletons iniciales (GameState, EventBus) [M]
- [ ] Verificar build de prueba y un .pck distribuible [M]

## G. Rendimiento y calidad gráfica (12)

- [ ] Documentar objetivo de 60 FPS como requisito de estilo (M01) [S]
- [ ] Documentar presupuesto de draw calls por escena [M]
- [ ] Documentar batching/frustum culling del renderer Forward+ [S]
- [ ] Documentar LOD de chunks y props [S]
- [ ] Documentar iluminación pastel (SDFGI/SSIL) apta para el género [S]
- [ ] Documentar sombras ajustables (quality vs rendimiento) [S]
- [ ] Documentar el presupuesto de material/shader (vertex color + toon) [S]
- [ ] Documentar el costo del agua y reflejos (módulo Agua M51) [S]
- [ ] Documentar el límite de luces dinámicas por escena [S]
- [ ] Documentar pooling de partículas y props [S]
- [ ] Documentar compresión de texturas por plataforma [S]
- [ ] Documentar el frame budget como entregable de M61 [S]

## H. Integración con otros módulos (12)

- [ ] Documentar que M05 (Lenguaje) usará GDScript (+C# opcional) [S]
- [ ] Documentar que M07 (Arquitectura) se diseña sobre Godot [S]
- [ ] Documentar que M08 (Mundo Voxel) integra Voxel Tools [S]
- [ ] Documentar el sistema de escenas separadas para islas (M28 Viajes) [S]
- [ ] Documentar la carga diegética del Gran Vapor (M28/M63) [S]
- [ ] Documentar el raycast voxel para herramientas (M13) [S]
- [ ] Documentar los singletons GameState/EventBus (M59 Guardado) [S]
- [x] Documentar el Input Map remapeable (M57/M58) [S] (acciones en project.godot [input]; remapeables desde Project Settings; ver 04-Codigo.md)
- [ ] Documentar el asset pipeline de audio (M41-M44) [S]
- [ ] Documentar el pipeline de arte procedimental voxel (M45-M48) [S]
- [ ] Documentar la UI del juego (Control nodes) con M53 [S]
- [ ] Documentar que el autosave del editor usa `.godot/` (no versionar) [S]

## I. Riesgos y edge cases (10)

- [ ] Documentar riesgo: dependencia de Voxel Tools (comunitaria) [S]
- [ ] Documentar mitigación: MIT + versión fijada + código fuente disponible [S]
- [ ] Documentar riesgo: transvoxel perf en islas grandes [S]
- [ ] Documentar riesgo: reaprendizaje si el usuario viene de Unity [S]
- [ ] Documentar riesgo: actualización de Godot a mitad de producción [S]
- [ ] Documentar edge case: Windows vs Linux paths en tools (portabilidad) [S]
- [ ] Documentar edge case: export SteamOS exige pruebas en Deck real [S]
- [ ] Documentar edge case: drivers Vulkan en PCs viejas (fallback a OpenGL) [S]
- [ ] Documentar edge case: pérdida de compatibilidad de saves con cambios de versión [S]
- [ ] Documentar decisión: si M1 falla 60 FPS, re-evaluar motor con replanificación [S]

## J. Validación del hito M1 y cierre del módulo (12)

- [ ] Definir el prototipo de validación: chunk 16³ + face culling + editing + camera [M]
- [ ] Validar 60 FPS en PC media [C]
- [ ] Validar 60 FPS en Steam Deck (o configuración Deck) [C]
- [ ] Validar raycast de extracción/colocación sin lag [M]
- [ ] Confirmar con el usuario la decisión Godot (confirmado 2026-08-16 por encargo explícito, ver Log 17) [S]
- [ ] Registrar la versión exacta del motor en 04-Codigo.md [S]
- [ ] Generar Logs con la instalación y configuración [S]
- [ ] Actualizar 1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md con la decisión [S]
- [ ] Crear los 5 archivos de documentación del componente [S]
- [ ] Copiar plan-inicial → plan-actual [S]
- [ ] Actualizar CHECKLIST-GLOBAL.md con estado del módulo 04 [S]
- [ ] Registrar el criterio de salida del módulo (prototipo M1) [S]

---

**Totales:** 128 ítems · Completados: 36 · Pendientes: 92 (instalación y configuración real del motor → hito M1, dueño: prototipo) · No resueltos: 0.

## Implementacion Fase 1 (2026-08-29 — Hy3/Kilo)

- [x] Configurar capas de fisica e Input Map inicial [M] (project.godot: [layer_names] 3d_physics mundo/jugador/npc/interactuable/agua + [input] con 18 acciones teclado/gamepad/rueda)
- [x] Crear `Bootstrap` y `Main` vacios pero ejecutables [M] (bootstrap.gd + scenes/main_island.tscn ejecutan sin errores; verificado headless y runtime)
- [x] Documentar el Input Map remapeable [S]


## Notas del Agente (Cierre Fase 1 - 2026-08-29)

**Modelo:** Hy3 | **Plataforma:** Kilo | **Estado:** items de la guia 08 completados y verificados; auditoria del resto del checklist pendiente (honestidad 21.4.3)

### Lo que hice
- Verificacion con Godot 4.7.2 headless + runtime: proyecto arranca sin errores de script.
- Ver tilo de guia 08 del modulo completado con evidencia (ver seccion "Implementacion Fase 1").
- Libere el modulo en CHECKLIST-GLOBAL y ESTADO-PARALELO como nucleo verificado (🟡); la auditoria completa del checklist queda para la siguiente pasada.

### Pendiente (honestidad)
- Auditoria item por item del resto de este checklist contra el codigo real.
