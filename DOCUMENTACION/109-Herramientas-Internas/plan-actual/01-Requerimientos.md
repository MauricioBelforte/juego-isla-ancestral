**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 109: Herramientas Internas

## 1. Problema
El desarrollo del juego (contenido del mundo, NPC, misiones, recetas, economía, clima, puzzles, ruinas, mapas) se vuelve inmanejable y lento con edición manual de datos: se necesitan **herramientas internas de editor y diagnóstico** para diseñar, validar, depurar y generar contenido de forma rápida y segura, separadas del juego autónomo (nunca llegan al build de jugador).

## 2. Objetivo del módulo
Diseñar y documentar el **toolset interno de desarrollo**: 14 editores (bloques, biomas, NPC, diálogos, misiones, recetas, economía, tiendas, clima, estaciones, puzzles, ruinas, spawns, mapas) + 7 herramientas de runtime/debug (teleport, spawn, debug, inspección, profiling, validación, generación de contenido), todas con la arquitectura de M04/M09/M110 y QA de M112.

## 3. Alcance (derivado del plan maestro: sección 108 "HERRAMIENTAS INTERNAS DE DESARROLLO")
1. **Editor de bloques** — catálogo de bloques voxel (M08/M47): añadir/editar/borrar propiedades.
2. **Editor de biomas** — biomas (M09/M10): parámetros, vegetación, clima asociado.
3. **Editor de NPC** — NPCs (M19): datos, rutinas, economía, relaciones.
4. **Editor de diálogos** — árboles de diálogo (M21) con condición/efectos.
5. **Editor de misiones** — misiones (M22/M23) con etapas, objetivos, rewards.
6. **Editor de recetas** — crafting (M16/17): ingreso/salida, estaciones, desbloqueos.
7. **Editor de economía** — precios y mercado (M38) por NPC/tienda/objeto.
8. **Editor de tiendas** — inventarios y restock (M39).
9. **Editor de clima** — climas (M32) y transiciones.
10. **Editor de estaciones** — estaciones (M31/32) y eventos por fecha.
11. **Editor de puzzles** — puzzles (M24/25/26): condiciones, recompensas, conectividad.
12. **Editor de ruinas** — ruinas generadas (M25): layout, tesoros, puzzles.
13. **Editor de spawns** — spawns (M36/M65): fauna/flora por bioma/hora.
14. **Editor de mapas** — mapas/islas (M54): estructura de islas y puntos.
15. **Herramienta de teleport** — moverse a coordenada/isla/POI en editor y debug.
16. **Herramienta de spawn** — instanciar objetos/NPC/fauna bajo cursor.
17. **Herramienta de debug** — menú de debug del juego (M110): flags, invincibilidad, etc.
18. **Herramienta de inspección** — inspector de entidades: estado de componentes.
19. **Herramienta de profiling** — profiling del editor: stats de chunk/NPC/AI (M62/M61).
20. **Herramienta de validación** — consistency checker de datos (M102/M135).
21. **Herramienta de generación de contenido** — genera/regenera contenido base (M108 pipeline + M10).

## 4. Requisitos funcionales (RF)
| RF | Descripción |
|----|-------------|
| RF1 | 14 editores operativos con guardado idem LO (M108) |
| RF2 | Todos los editores son modo editor (Unity Editor) — nunca en build de jugador |
| RF3 | Undo/redo por editor (Unity Undo) |
| RF4 | Previsualización en vivo (cambios aplicados al entrar al juego) |
| RF5 | Validación por editor: errores tipados (de color) al guardar |
| RF6 | Exportación/importación JSON/CSV (para revisión y migración) |
| RF7 | Runtime debug: teleport, spawn, flags, tiempo, clima, estado del juego (M110) |
| RF8 | Inspección de entidad: árbol de componentes y variables |
| RF9 | Profiling del editor: FPS, chunk stats, memoria, draw calls (M61/62) |
| RF10 | Validación global: cross-checks entre editores (recetas→objetos, misiones→diálogos) |
| RF11 | Generador de contenido: semilla para mundo (M10) y ruinas (M25) |
| RF12 | Sin overhead en el build final (excluido por #if UNITY_EDITOR y asmdef) |

## 5. Criterios de aceptación (DoD del módulo)
1. Los 21 items del plan maestro están documentados con su diseño específico.
2. Cada editor tiene: datos que edita, formato de persistencia, validación y undo.
3. Runtime debug cubre al menos: teleport, spawn, hora/estación/clima, dar objetos/dinero, completar misión, desbloquear isla/sello (M110).
4. La validación global detecta incoherencias típicas (receta con objeto inexistente, misión que referencia diálogo borrado).
5. La herramienta de generación reutiliza seeds (M10) y produce mundos reproducibles.
6. Todo el toolset vive fuera del build de jugador (asmdef + UNITY_EDITOR).
7. Tests de editores en M112 (EditMode con editor scripts).

## 6. Restricciones
- **Aplican:** M04 (arquitectura/asmdef), M08-M10 (voxel/biomas/mundo), M16-M26 (crafting/construcción/misiones/templos), M31-M39 (tiempo/clima/economía), M54 (mapa), M57/M58, M108 (pipeline de datos), M110 (debug menu), M61/M62 (rendimiento/memoria).
- Los editores NUNCA se empaquetan: se compila solo en el Editor (Unity asmdef `Editor` + `#if UNITY_EDITOR`).
- Prioridad de implementación: datos primero (bloques/biomas/NPC/diálogos/recetas), luego rutinas avanzadas (economía/puzzles/ruinas).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M004** — Game Engine | Editores del editor |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M004** — Game Engine | Depende de este módulo |

