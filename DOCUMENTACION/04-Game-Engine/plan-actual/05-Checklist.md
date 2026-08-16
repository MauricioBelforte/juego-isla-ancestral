**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 04: Game Engine

**Estado:** `[ ]` pendiente · `[x]` completado · `[?]` no resuelto. Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

---

## A. Evaluación de candidatos (12)

- [x] Evaluar Unity contra los requisitos del proyecto [M]
- [x] Evaluar Godot contra los requisitos del proyecto [M]
- [x] Evaluar Unreal Engine contra los requisitos del proyecto [M]
- [x] Documentar por qué Unity queda descartado por defecto (costo >200k, voxel sin nativo) [S]
- [x] Documentar por qué Unreal queda descartado (overkill, tasa 5%, curva) [S]
- [x] Registrar la recomendación del Plan-de-produccion §2 como fuente de la decisión [S]
- [x] Adoptar **Godot 4.x** como motor del proyecto [S]
- [x] Documentar la comparativa Unity vs Godot en tabla (costo/voxel/IA/deck) [S]
- [x] Documentar que la decisión es revisable SOLO antes del hito M1 [S]
- [x] Confirmar con el usuario la adopción de Godot (veto pendiente) [ ] [S]
- [x] Documentar el trade-off de animación (Godot menos maduro que Mecanim) [S]
- [x] Documentar el trade-off de bolsa de talento (comunidad Godot más chica) [S]

## B. Costos y licencias (10)

- [x] Documentar costo Godot: gratis siempre, MIT, sin regalías [S]
- [x] Documentar costo Unity: gratis < USD 200k, Pro ~USD 2.300/asiento/año [S]
- [x] Documentar el episodio Runtime Fee 2023 y su cancelación (contexto) [S]
- [x] Documentar el caso Unreal: 5% tras USD 1M de ingresos [S]
- [x] Verificar que el modelo autofinanciado es compatible con Godot [S]
- [x] Documentar costos de assets/plugins a futuro (presupuesto separado) [S]
- [x] Documentar que Voxel Tools es MIT y gratuito [S]
- [x] Verificar licencias de exportación (Vulkan/video drivers no requieren fees) [S]
- [x] Documentar el costo cero como factor decisivo del análisis [S]
- [x] Registrar el costo de herramientas de apoyo (Blender gratis, etc.) en módulo de arte [S]

## C. Soporte voxel y rendimiento (14)

- [x] Documentar Voxel Tools (Zylann) como módulo clave [S]
- [x] Documentar que Voxel Tools es C++/GDExtension orientado a rendimiento [S]
- [x] Documentar soporte de terreno editable en tiempo real [S]
- [x] Documentar colisiones voxel tipo Minecraft del módulo [S]
- [x] Documentar streaming de chunks infinito [S]
- [x] Documentar LOD Transvoxel para terreno suave [S]
- [x] Documentar meshing multihilo (sin bloquear hilo principal) [S]
- [x] Documentar face culling como requisito innegociable (GDD directiva 1) [S]
- [x] Documentar greedy meshing como optimización a evaluar [S]
- [x] Documentar diffs de chunk para persistencia (no guardar mundo entero) [S]
- [x] Documentar el conteo de draw calls del terreno mesheado [S]
- [x] Documentar el presupuesto de partículas/vfx del motor [S]
- [x] Documentar el raycast voxel para herramientas (pala/pico/hacha) [S]
- [x] Documentar la validación 60 FPS como criterio de aceptación del motor [S]

## D. Ecosistema del motor (10)

- [x] Documentar estado de la comunidad Godot (activa, en crecimiento) [S]
- [x] Documentar la documentación oficial estable de Godot 4.x [S]
- [x] Documentar el mercado de plugins (Voxel Tools + diálogos + UI) [S]
- [x] Documentar las opciones MCP de Godot para desarrollo con IA (GDAI MCP, godot-mcp) [S]
- [x] Documentar comparativa MCP vs Unity (MCP oficial beta + Unity MCP 12.7k★) [S]
- [x] Documentar los editores de diálogo (sistema de nodos de Godot) [S]
- [x] Verificar que el pipeline de audio cubre lo-fi + ASMR [S]
- [x] Verificar que la UI de Control nodes cubre HUD/inventario/hotbar [S]
- [x] Documentar que el networking no es requisito v1.0 [S]
- [x] Documentar el estado del editor de partículas (GPU particles) [S]

## E. Versión y gestión del motor (10)

- [x] Documentar la regla de fijar la versión del motor [S]
- [x] Documentar la regla de NO actualizar arbitrariamente durante producción [S]
- [x] Registrar el campo Versión exacta como pendiente del hito M1 [S]
- [x] Documentar el pinneado de Voxel Tools contra la versión de Godot [S]
- [x] Documentar el procedimiento de migración de versión (log + changelog) [S]
- [x] Documentar parche de seguridad crítico como única excepción [S]
- [x] Documentar la congelación de assets/plugins por versión [S]
- [x] Registrar el renderer elegido: Forward+ (Vulkan) [S]
- [x] Documentar el renderer Mobile como alternativa para builds livianas [S]
- [x] Documentar la decisión de física (Godot Physics, Jolt si hace falta) [S]

## F. Configuración del proyecto base (18)

- [ ] Instalar Godot 4.x versión estable (pendiente hito M1) [M]
- [ ] Crear el proyecto con la versión fijada [S]
- [ ] Agregar `.godot/` al .gitignore [S]
- [ ] Configurar renderer Forward+ [S]
- [ ] Configurar niveles de calidad Baja/Media/Alta [M]
- [ ] Configurar resolución y escalado (window mode, aspect) [S]
- [ ] Configurar framerate objetivo 60 y VSync opcional [S]
- [ ] Definir capas de física (voxel, jugador, NPC, props, UI, receptores) [M]
- [ ] Configurar Input Map: mover (WASD+stick) [S]
- [ ] Configurar Input Map: cámara rotación/zoom [S]
- [ ] Configurar Input Map: herramienta/interacción [S]
- [ ] Configurar Input Map: inventario/hotbar 1-9 [S]
- [ ] Crear escena Bootstrap (config + carga) [M]
- [ ] Crear escena Main (world + player + cámara) [M]
- [ ] Crear estructura de carpetas del proyecto (scenes, scripts, resources, data) [S]
- [ ] Crear export presets Windows/Linux/Web/SteamOS [M]
- [ ] Configurar autoloads/singletons iniciales (GameState, EventBus) [M]
- [ ] Verificar build de prueba y un .pck distribuible [M]

## G. Rendimiento y calidad gráfica (12)

- [x] Documentar objetivo de 60 FPS como requisito de estilo (M01) [S]
- [x] Documentar presupuesto de draw calls por escena [M]
- [x] Documentar batching/frustum culling del renderer Forward+ [S]
- [x] Documentar LOD de chunks y props [S]
- [x] Documentar iluminación pastel (SDFGI/SSIL) apta para el género [S]
- [x] Documentar sombras ajustables (quality vs rendimiento) [S]
- [x] Documentar el presupuesto de material/shader (vertex color + toon) [S]
- [x] Documentar el costo del agua y reflejos (módulo Agua M51) [S]
- [x] Documentar el límite de luces dinámicas por escena [S]
- [x] Documentar pooling de partículas y props [S]
- [x] Documentar compresión de texturas por plataforma [S]
- [x] Documentar el frame budget como entregable de M61 [S]

## H. Integración con otros módulos (12)

- [x] Documentar que M05 (Lenguaje) usará GDScript (+C# opcional) [S]
- [x] Documentar que M07 (Arquitectura) se diseña sobre Godot [S]
- [x] Documentar que M08 (Mundo Voxel) integra Voxel Tools [S]
- [x] Documentar el sistema de escenas separadas para islas (M28 Viajes) [S]
- [x] Documentar la carga diegética del Gran Vapor (M28/M63) [S]
- [x] Documentar el raycast voxel para herramientas (M13) [S]
- [x] Documentar los singletons GameState/EventBus (M59 Guardado) [S]
- [x] Documentar el Input Map remapeable (M57/M58) [S]
- [x] Documentar el asset pipeline de audio (M41-M44) [S]
- [x] Documentar el pipeline de arte procedimental voxel (M45-M48) [S]
- [x] Documentar la UI del juego (Control nodes) con M53 [S]
- [x] Documentar que el autosave del editor usa `.godot/` (no versionar) [S]

## I. Riesgos y edge cases (10)

- [x] Documentar riesgo: dependencia de Voxel Tools (comunitaria) [S]
- [x] Documentar mitigación: MIT + versión fijada + código fuente disponible [S]
- [x] Documentar riesgo: transvoxel perf en islas grandes [S]
- [x] Documentar riesgo: reaprendizaje si el usuario viene de Unity [S]
- [x] Documentar riesgo: actualización de Godot a mitad de producción [S]
- [x] Documentar edge case: Windows vs Linux paths en tools (portabilidad) [S]
- [x] Documentar edge case: export SteamOS exige pruebas en Deck real [S]
- [x] Documentar edge case: drivers Vulkan en PCs viejas (fallback a OpenGL) [S]
- [x] Documentar edge case: pérdida de compatibilidad de saves con cambios de versión [S]
- [x] Documentar decisión: si M1 falla 60 FPS, re-evaluar motor con replanificación [S]

## J. Validación del hito M1 y cierre del módulo (12)

- [ ] Definir el prototipo de validación: chunk 16³ + face culling + editing + camera [M]
- [ ] Validar 60 FPS en PC media [C]
- [ ] Validar 60 FPS en Steam Deck (o configuración Deck) [C]
- [ ] Validar raycast de extracción/colocación sin lag [M]
- [x] Confirmar con el usuario la decisión Godot (confirmado 2026-08-16 por encargo explícito, ver Log 17) [S]
- [ ] Registrar la versión exacta del motor en 04-Codigo.md [S]
- [ ] Generar Logs con la instalación y configuración [S]
- [ ] Actualizar 1-DOCUMENTO-DE-ESPECIFICACIONES-ACTUAL.md con la decisión [S]
- [x] Crear los 5 archivos de documentación del componente [S]
- [x] Copiar plan-inicial → plan-actual [S]
- [x] Actualizar CHECKLIST-GLOBAL.md con estado del módulo 04 [S]
- [x] Registrar el criterio de salida del módulo (prototipo M1) [S]

---

**Totales:** 120 ítems · Completados: 95 · Pendientes: 25 (instalación y configuración real del motor → hito M1, dueño: prototipo) · No resueltos: 0.