**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 109: Herramientas Internas

## 1. Análisis del dominio
El contenido del juego es data-driven (SO/MODs: M108) y el mundo es generado proceduralmente (M10). Los datos viven en ScriptableObjects/MODs y el editor importa/exporta. El toolset debe: 1) editar datos con validación, 2) depurar en runtime, 3) medir performance, 4) generar contenido reproducible.

## 2. Alternativas consideradas y decisiones

### D1: Framework de editores
- **A1 (Sistemas de terceros)**: coste de integración y dependencia.
- **A2 (Editor nativo de Unity sobre SO serializados)**: natural para el stack (M108) con Undo de Unity integrado.
- **Decisión:** **A2** — ventanas de editor (EditorWindow) que operan sobre los mismos SO/mods que el juego, compatibles con M108. Custom inspector + prefab de editor reutilizable.

### D2: Filosofía de validación
- **A1 (validación centralizada periódica en CI)**: detecta tarde.
- **A2 (validación incremental por editor al guardar + checker global on-demand y en CI)**: feedback inmediato del editor y gate en CI.
- **Decisión:** **A2** — cada editor valida su dominio al guardar (errores por color) y existe `DataValidator` global que corre en Editor y en CI (M112), reutilizado por M151.

### D3: Generación de contenido
- **A1 (generación aleatoria pura)**: no reproducible, difícil de depurar.
- **A2 (seed-driven)**: usa la semilla de M10; mapas/ruinas/spawns reproducibles under same seed.
- **Decisión:** **A2** — la herramienta de generación usa seeds de M10 y permite "regenerar con semilla X" para depurar bugs de layout.

### D4: Runtime debug
- **A1 (console commands)**: frágil y difícil de descubrir.
- **A2 (Debug Menu UI de M110 + toolset en Editor)**: menú in-game para QA y teleport dentro del editor.
- **Decisión:** **A2** — el menú de debug (M110) es la interfaz de runtime; las herramientas de editor complementan.

## 3. Riesgos y mitigaciones
| Riesgo | Prob | Impacto | Mitigación |
|--------|------|---------|------------|
| Herramientas que rompen datos | Media | Alta | Validación al guardar + backups M107 |
| Editor que crece sin control | Alta | Media | Estructura por dominio + asmdef `Editor` separada |
| Datos inconsistentes entre editores | Media | Alta | DataValidator global cross-check (RF10) |
| Build con debugging accesible | Baja | Alta | asmdef Editor + compilación condicional (RF12) |
| Curva de aprendizaje | Media | Baja | Shortcuts consistentes + docs en 04-Codigo.md |

## 4. Plan de ejecución (fases)
| Fase | Contenido |
|------|-----------|
| **F1 Core de editor** | Framework EditorWindow + Undo + validación incremental (RF1-RF5) |
| **F2 Editores de datos 1** | Bloques, biomas, NPC, diálogos, misiones, recetas |
| **F3 Editores de datos 2** | Economía, tiendas, clima, estaciones, puzzles, ruinas, spawns, mapas |
| **F4 Runtime** | Debug menu (M110), teleport, spawn, inspección, profiling |
| **F5 Validación y generación** | DataValidator global, generador seed-driven, export/import JSON/CSV |

## 5. Métricas de éxito
1. Tiempo medio de edición de una misión < 10 min (con editor vs manual).
2. 0 errores de datos en el build diario (validator en CI).
3. 100% de dominios cubiertos por los 14 editores.
4. Reproducibilidad: mismo seed → mismo mundo (ruinas/spawns).
5. Toolset sin presencia en el build de jugador (verificado por script).
6. Todos los editores con Undo y validación de color.
7. Test de editor ≥ 1 suite en M112.

## 6. Notas para integración
- Interactúa con M108 (formato de datos) y M110 (debug menu runtime).
- Alimenta QA: M102 (categorías de bugs de contenido) y M135 (validación de proyecto).
- El profiling del editor usa los providers de M61/M62 para no duplicar instrumentación.