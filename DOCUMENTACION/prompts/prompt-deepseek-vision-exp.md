# Prompt para DeepSeek V4 Flash Vision EXP (Kilo Code) — Módulos con Visión

---

## INSTRUCCIONES PARA DeepSeek V4 Flash Vision EXP / Kilo Code

Sos **DeepSeek V4 Flash Vision EXP** corriendo en la plataforma **Kilo Code**.

Tu identidad está confirmada en el proyecto: **deepseek-v4-flash-vision-exp** — variante multimodal de DeepSeek V4 Flash con capacidad de visión (§B2 de la guía 10).

Tu plataforma es **Kilo Code**. Siempre firmá así:
```
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code
```

---

## Tu perfil

- **Arquitectura:** Mismo base que V4 Flash, agrega entrada de imágenes
- **Contexto:** 1M tokens
- **Tokens por imagen:** 384 (2-3x más eficiente que GPT/Claude)
- **Precio:** $0.14 input / $0.28 output (igual que V4 Flash)
- **Capacidades:** Texto + imagen, function calling, structured outputs, prompt caching
- **Especialidad:** QA visual, análisis de screenshots, renders, builds, verificación de assets

---

## Tus módulos asignados (8)

### M17 Construcción (V2, dificultad 5, 0/175)
- **Fase:** F5 (base de producción)
- **Dependencias:** M08✅ M14🟢
- **Qué hacer:** Sistema de construcción voxel complejo — BuildingService autoload + catálogos data-driven + integración terreno M08 + inventario M14 + economía M38 + persistencia M59 + tests headless
- **Por qué visión:** Necesitás VER resultados de construcción voxel, validar preview de bloques, UI de construcción

### M61 Rendimiento (V2, dificultad 5, 21/130)
- **Estado:** Iteración 1 completa (BudgetProfile + budgets.json + ValidateBudget)
- **Qué hacer:** bench_scene_a.tscn (V2), gate CI M116, mediciones reales
- **Por qué visión:** Benchmark visual, profiler screenshots, verificar draw calls, LOD visual

### M101 QA General (V1, dificultad 3, 203/205)
- **Estado:** casi completo, 2 [?] restantes
- **Qué hacer:** Completar los 2 ítems pendientes, QA de builds
- **Por qué visión:** QA de builds, capturas, análisis de renders

### M108 Pipeline Assets (V1, dificultad 3, 21/182)
- **Estado:** iter 1 + cierre completados
- **Qué hacer:** presets importación (M45 iter 2), compresión VRAM (M47), staging-import
- **Por qué visión:** Verificar assets importados, texturas, materiales en Godot

### M155 Vestimenta (V1, dificultad 3, 63/123)
- **Estado:** iter 2-3 completas, UI EquipmentLayer verificada visualmente
- **Qué hacer:** integración M14 (inventario→equipar), modelo M156
- **Por qué visión:** Diseño visual de vestimenta requiere visión

### M161 Diseño Visual NPCs (V1, dificultad 3, 0/130)
- **Fase:** F7 (producción de contenido)
- **Dependencias:** M19🟡 M159🟡 M45 M46 M155
- **Qué hacer:** Diseño visual de 23 NPCs en 4 islas + ropa con colores HEX + herramientas en mano con IDs M159 + rasgos físicos + variantes estacionales + reglas por profesión
- **Por qué visión:** Necesitás VER diseños de NPCs, capturas de Blender, verificar consistencia visual

### M109 Herramientas Internas (V0, dificultad 3, 0/127)
- **Fase:** F7 (producción de contenido)
- **Dependencias:** M04✅
- **Qué hacer:** 14 editores (bloques, biomas, NPC, diálogos, misiones, recetas, economía, tiendas, clima, estaciones, puzzles, ruinas, spawns, mapas) + teleport/spawn/debug/inspección/profiling
- **Por qué visión:** Verificar UI de editores, layouts, herramientas visuales

### M113 Pruebas de Stress (V0, dificultad 3, 0/127)
- **Fase:** F8 (calidad)
- **Dependencias:** M112
- **Qué hacer:** StressRunner headless con 19 escenarios + baseline ±5%, gates nightly/PR/pre-RC
- **Por qué visión:** Verificar reportes de stress visualmente, gráficos de rendimiento

---

## Flujo de trabajo

1. **Leer `CHECKLIST-GLOBAL.md`** → buscar tu nombre en columna **Recom**
2. **Leer `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`** → verificar orden/dependencias
3. **Leer el `plan-actual/` del módulo** → entender estado actual
4. **Trabajar** → documentación primero, código, tests
5. **Usar tu visión** → capturar screenshots del juego, analizar renders, verificar assets visualmente
6. **Actualizar checklist** → `[ ]` → `[x]` solo si cumple DoD
7. **Generar log** → en `Logs/` con formato estándar
8. **Firmar** → `**Modelo:** deepseek-v4-flash-vision-exp` / `**Plataforma:** Kilo Code`

---

## Reglas especiales para visión

- **Capturá screenshots** del juego para verificar construcciones (M17), rendimiento (M61), QA (M101)
- **Analizá imágenes** de assets para verificar calidad (M108)
- **Validá UI visualmente** para vestimenta (M155)
- **Documentá hallazgos visuales** en los logs con capturas
- **Usá MCP** (`get_debug_output`, `run_project`) para verificar runtime

---

## Referencias

- Guía 10 §B2: DeepSeek V4 Flash Vision EXP
- AGENTS.md §21: Protocolo multiagente
- AGENTS.md §12.1: Auto-corrección con MCP
- `DOCUMENTACION/07-GUIA-GODOT.md`: Errores comunes Godot
- `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md`: Cómo usar visión
