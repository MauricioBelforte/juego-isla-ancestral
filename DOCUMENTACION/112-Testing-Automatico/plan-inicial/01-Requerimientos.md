**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 112: Testing Automático

## ID del Módulo

- **Código:** M112 (plan maestro: componente nuevo — Testing Automático)
- **Carpeta:** `DOCUMENTACION/112-Testing-Automatico/`
- **Dependencias:** M111 (Código de Calidad, ya documentado), M118 (CI/CD), M101 (Mundo/Core del juego), M122 (Crash Reporting)
- **Carácter:** Módulo de infraestructura de pruebas automatizadas (unit tests, integration tests, cobertura, regresión). El motor del juego es **Godot 4.x**, el lenguaje es **GDScript** (no Unity, no C#).

## 1. Problema

El proyecto "Isla Ancestral" es un juego de mundo voxel cozy (isla Aurora) con calidad técnica obligatoria y un protocolo multiagente que exige verificación post-tarea (sección 12 del AGENTS.md: 0 errores de compilación, sin excepciones en runtime, flujo completo validado en Play Mode). Sin un framework de pruebas automatizadas, la verificación de calidad depende de pruebas manuales repetitivas, el riesgo de regresiones crece con cada módulo nuevo (hay más de 100 módulos en el plan) y el pipeline de CI/CD (M118) no tiene forma objetiva de determinar si un commit está sano antes de construir un release. Se necesita una suite de tests automatizados reproducible, rápida y ejecutable en modo headless dentro de CI (GitHub Actions), escrita en GDScript y alineada con la arquitectura modular del proyecto.

## 2. Objetivo

Crear el framework de pruebas automatizadas del juego: seleccionar el framework (GUT o GdUnit4), definir la estructura de carpetas de tests por módulo, escribir unit tests e integration tests de los sistemas núcleo (inventario, crafting, economía, tiempo, generación voxel, persistencia, NPCs), medir cobertura con umbrales definidos, y conectar la suite con el pipeline de CI de M118 para que todos los commits pasen por la batería de pruebas antes de aprobarse.

## 3. Alcance

### Incluye

- Selección e instalación del framework de testing (GUT o GdUnit4) como addon de Godot 4.x.
- Estructura de carpetas de tests (`res://tests/...`) organizada por módulo del juego.
- Unit tests de lógica pura (utilidades, constantes, algoritmos, serialización).
- Integration tests entre sistemas (inventario-crafting, agricultura-economía, tiempo-calendario, guardado-carga, etc.).
- Ejecución headless de la suite (sin display, sin UI) para CI.
- Medición de cobertura de código con umbrales mínimos.
- Integración con el pipeline de GitHub Actions de M118 (job de tests que bloquea merge si falla).
- Tests de regresión para flujos estabilizados (sección 16 del AGENTS.md).
- Documentación de comandos de ejecución local y en CI.

### Excluye

- La implementación del pipeline de CI/CD en sí (pertenece a M118).
- La creación del sistema de bug tracking (M102) y del sistema de logs (M103); solo los usa como verificación.
- Corner cases estéticos/visuales (pixel-perfect, LOD visual) que se validan por inspección manual.
- Tests de rendimiento con Profiler completo (pertenecen a M61/M62); este módulo solo mide tiempo de suite.
- Pruebas manuales de jugabilidad (playtesting) — complementan, no sustituyen, a la suite automática.

## 4. Restricciones

- **Motor y lenguaje:** Godot 4.x + GDScript únicamente. Prohibido usar frameworks de testing de Unity (nada de Unity Test Framework ni NUnit).
- **Framework candidato:** GUT o GdUnit4 (compatible Godot 4.x, activo, con runner headless por línea de comandos).
- **Headless:** la suite completa debe poder ejecutarse con `godot --headless` en un runner de CI sin display.
- **Determinismo:** los tests no pueden depender del reloj real, de la locale del sistema ni del orden de ejecución.
- **Tiempo:** la suite completa debe terminar en menos de 10 minutos (objetivo duro para CI).
- **Aislamiento:** los tests no pueden escribir en archivos de guardado reales del jugador ni modificar configuraciones globales del proyecto.
- **Modularidad:** los tests se organizan por módulo del CHECKLIST-GLOBAL y siguen las convenciones de nomenclatura de M111.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Seleccionar framework de testing | Evaluar GUT y GdUnit4 y fijar uno como oficial |
| RF2 | Instalar framework como addon | Addon dentro de `res://addons/` compatible con Godot 4.x |
| RF3 | Definir estructura de tests | Carpetas `res://tests/` organizadas por módulo del juego |
| RF4 | Unit tests de lógica pura | Tests de funciones individuales (utilidades, validación, constantes, enums, matemática) |
| RF5 | Unit tests de sistemas núcleo | Tests de inventario, crafting, economía, calendario, tiempo, serialización |
| RF6 | Integration tests entre sistemas | Tests de interacción: inventario-crafting, agricultura-economía, tiempo-clima, guardado-carga, NPC-diálogos |
| RF7 | Tests de generación voxel | Tests de algoritmos de terreno/mundo (seed determinista) |
| RF8 | Runner headless | Ejecución por línea de comandos con `--headless` y exit code correcto |
| RF9 | Tests sin UI | Verificar que la lógica se testea sin instanciar Canvas/UI |
| RF10 | Cobertura de código | Instrumentación de cobertura con reportes generados |
| RF11 | Umbral de cobertura | Umbral mínimo definido y verificado en CI |
| RF12 | Integración con CI (M118) | Job de GitHub Actions que ejecuta la suite y bloquea el merge si falla |
| RF13 | Tests de regresión | Re-ejecutar suite completa sobre flujos estabilizados (sección 16 AGENTS.md) |
| RF14 | Fixtures centralizados | Escenas y datos de prueba compartidos (inventario ejemplo, terreno voxel de prueba, NPC de prueba) |
| RF15 | Helpers de simulación | Helpers de espera de frames, avance de días, carga de escenas |
| RF16 | Reporte de resultados | Resultados legibles localmente y artefacto de CI al fallar |
| RF17 | Documentación de ejecución | Comandos documentados para ejecutar local y en CI |

## 6. Requisitos No Funcionales

### Qué se testea

- Toda lógica de juego desacoplada de UI (M111: separación de responsabilidades).
- Sistemas núcleo del mundo voxel: generación, terreno, biome, clima.
- Sistemas de gameplay: inventario, crafting, construcción, agricultura, pesca, minería, economía, diálogos, amistad.
- Sistemas de calendario/tiempo: día/noche, estaciones, eventos.
- Persistencia: guardado/carga con validación de serialización.
- Utilidades y patrones de M111 (MathUtils, ValidationUtils, interfaces, state machine).
- Flujos críticos marcados como estables en la sección 16 del AGENTS.md (regresión).

### Cuándo se testea

- En cada push a ramas principales (main/develop) vía CI (M118).
- Antes de aprobar cualquier Pull Request (requisito de merge).
- Antes de cada release (al marcar tag de versión).
- Localmente por el desarrollador antes de declarar una tarea completada (sección 12 AGENTS.md).

### Umbral de cobertura

- Cobertura global de la suite ≥ 40% de líneas.
- Cobertura de módulos núcleo (M101, inventario, crafting, economía, tiempo, persistencia) ≥ 60%.
- La cobertura se mide con la herramienta del framework elegido y se publica como artefacto en CI.
- Las áreas excluidas (UI, shaders, código generado) deben justificarse en la documentación.

### Velocidad de la suite

- Suite completa ≤ 10 minutos en CI (objetivo duro).
- Suite de unit tests (solo lógica pura) ≤ 2 minutos.
- Cada test individual ≤ 5 segundos; los que excedan se marcan y optimizan.
- El job de CI debe poder correr paralelizado por módulo si se superan los 10 minutos.

## 7. Criterios de Aceptación

1. Framework de testing oficial seleccionado y documentado (decisión en 02-Analisis.md).
2. Addon instalado y runner headless funcionando con exit code correcto (0 = éxito, ≠0 = fallo).
3. Estructura `res://tests/` creada con carpetas por módulo y convención `test_*.gd`.
4. Suite de unit tests de lógica pura en funcionamiento (RF4, RF5).
5. Suite de integration tests de los sistemas núcleo en funcionamiento (RF6).
6. Tests de generación voxel con seed determinista (RF7).
7. Ejecución headless verificada sin display y sin UI (RF8, RF9).
8. Cobertura instrumentada con reporte generado y umbrales cumplidos (RF10, RF11).
9. Job de CI integrado con M118: fallo de tests bloquea el merge (RF12).
10. Tests de regresión ejecutados sobre flujos estables (RF13).
11. Documentación completa del módulo (5 archivos de plan-inicial y plan-actual idénticos).
12. Módulo delegable para implementación por otro agente.