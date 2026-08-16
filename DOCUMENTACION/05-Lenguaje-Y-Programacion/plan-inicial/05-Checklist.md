**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 05: Lenguaje y Programación

**Estado:** `[ ]` pendiente · `[x]` completado · `[?]` no resuelto. Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

---

## A. Elección de lenguaje (12)

- [x] Evaluar GDScript como lenguaje principal [M]
- [x] Evaluar C# como alternativa (build .NET de Godot) [S]
- [x] Evaluar C++ para gameplay (descartado; GDExtension solo para sistemas nativos) [S]
- [x] Adoptar **GDScript** como lenguaje primario del proyecto [S]
- [x] Documentar por qué Voxel Tools (C++) cubre el cuello de botella de rendimiento [S]
- [x] Documentar el uso puntual de C# si un módulo lo exige (decisión por módulo) [S]
- [x] Documentar el riesgo de menor conocimiento externo de GDScript [S]
- [x] Documentar la mitigación: scripts autocontenidos y convenciones claras [S]
- [x] Verificar compatibilidad de la decisión con Godot 4.x (M04) [S]
- [x] Documentar tipado explícito como requisito (no GDScript sin tipar) [S]
- [x] Documentar la regla de const/export en vez de literales [S]
- [x] Registrar la decisión en CHECKLIST-GLOBAL (consumida por M07) [S]

## B. Convenciones de nombres (16)

- [x] Fijar clases: PascalCase + `class_name` [S]
- [x] Fijar archivos: snake_case derivado de la clase [S]
- [x] Fijar nodos/escenas: snake_case [S]
- [x] Fijar variables locales: snake_case [S]
- [x] Fijar variables privadas: prefijo `_` [S]
- [x] Fijar constantes: UPPER_SNAKE_CASE [S]
- [x] Fijar métodos: snake_case con retorno tipado [S]
- [x] Fijar señales: snake_case tipadas [S]
- [x] Fijar enums: UPPER_SNAKE con nombre contextual [S]
- [x] Fijar @export con rangos y descripciones [S]
- [x] Fijar indentación de 4 espacios y líneas ≤ 120 [S]
- [x] Fijar la regla de un archivo = una responsabilidad [S]
- [x] Fijar la regla de comentarios (propósito/por-qué, español) [S]
- [x] Fijar la prohibición de print() de debug en producción [S]
- [x] Fijar el límite de 400 líneas con justificación [S]
- [x] Documentar la aplicación del estándar a agentes IA y freelancers [S]

## C. Arquitectura de carpetas de código (12)

- [x] Diseñar `scenes/` por sistema [S]
- [x] Diseñar `scripts/core/` (autoloads) [S]
- [x] Diseñar `scripts/gameplay/` [S]
- [x] Diseñar `scripts/ai/` [S]
- [x] Diseñar `scripts/world/` [S]
- [x] Diseñar `scripts/ui/` [S]
- [x] Diseñar `scripts/data/` (resources) [S]
- [x] Diseñar `scripts/utils/` (helpers) [S]
- [x] Diseñar `resources/` (archivos .tres de datos) [S]
- [x] Diseñar `data/` (seeds y configs serializadas) [S]
- [x] Verificar coherencia con la estructura planteada en M04 §2 [S]
- [x] Documentar que UI no contiene lógica de negocio (regla de capas) [S]

## D. Patrones transversales (20)

- [x] Diseñar EventBus (autoload, señales tipadas por dominio) [M]
- [x] Diseñar GameClock (fecha/estación/hora, patrón observer) [M]
- [x] Diseñar Settings autoload (config con persistencia .cfg) [M]
- [x] Diseñar Logger con niveles y rotación (AGENTS §18) [M]
- [x] Diseñar ErrorHandler con fallback y reporte [M]
- [x] Diseñar SceneManager con carga diegética [M]
- [x] Diseñar PoolService genérico (props/partículas) [M]
- [x] Diseñar GameState (serializable, versionado; detalle en M59) [M]
- [x] Diseñar QuestManager con prerequisitos (sellos→boletos) [M]
- [x] Definir regla: señales que cruzan sistemas pasan por EventBus [S]
- [x] Definir regla: señales locales quedan en el nodo [S]
- [x] Definir payload tipado en eventos (no diccionarios abiertos) [S]
- [x] Diseñar state machine de entidades (jugador/NPC) [S]
- [x] Definir transiciones explícitas entre estados [S]
- [x] Definir regla: estados no editan otros directamente [S]
- [x] Diseñar TimerManager centralizado [S]
- [x] Diseñar serialización JSON/Resource [S]
- [x] Diseñar sistema de dependencias (autoloads + resources, sin espagueti) [S]
- [x] Diseñar sistema de pooling reutilizable [S]
- [x] Diseñar el flujo de errores "log → fallback → (dev) pausa" [S]

## E. Anti-patrones a prevenir (10)

- [x] Prohibir GameManager monolítico (regla M07) [S]
- [x] Prohibir lógica de negocio en scripts de UI [S]
- [x] Prohibir singletons espagueti (Service Locator con interfaces) [S]
- [x] Prohibir eventos sin tipado [S]
- [x] Prohibir strings mágicos para estados (enums centrales) [S]
- [x] Prohibir pooling manual repetido (usar PoolService) [S]
- [x] Prohibir acceso directo a GameState desde gameplay (capas) [S]
- [x] Prohibir modificar señales del engine en el momento equivocado (deferred) [S]
- [x] Prohibir procesar todo en `_process` (timers/eventos) [S]
- [x] Prohibir duplicar lógica entre módulos (reutilizar utils) [S]

## F. Calidad y "done" por script (10)

- [x] Definir: código sin warnings del editor para merge [S]
- [x] Definir: tipado completo en firmas [S]
- [x] Definir: logs en sistemas críticos (Logger) [S]
- [x] Definir: sin strings mágicos [S]
- [x] Definir: sin llamadas UI desde gameplay [S]
- [x] Definir: acceso de datos solo vía módulos de datos [S]
- [x] Definir: tests unitarios obligatorios para lógica pura (M-QA) [S]
- [x] Definir: revisión de convenciones en cada PR (revisión de código) [S]
- [x] Definir: actualización de este checklist al crear módulos nuevos [S]
- [x] Definir: registro de cada decisión de código en Logs [S]

## G. Integración con otros módulos (10)

- [x] Documentar flujo hacia M07 (arquitectura: managers y autoloads) [S]
- [x] Documentar flujo hacia M11 (state machine del jugador) [S]
- [x] Documentar flujo hacia M29 (GameClock) [S]
- [x] Documentar flujo hacia M59 (GameState/guardado) [S]
- [x] Documentar flujo hacia M53 (UI sin lógica) [S]
- [x] Documentar flujo hacia M58 (Settings de accesibilidad) [S]
- [x] Documentar flujo hacia M61 (rendimiento: pooling/timers) [S]
- [x] Documentar flujo hacia QA (tests unitarios desde M1) [S]
- [x] Documentar flujo hacia M08 (voxel tools + estado de chunks) [S]
- [x] Verificar que ningún módulo contradice la guía de convenciones [S]

## H. Edge cases y verificación documental (12)

- [x] Documentar edge case: migración GDScript 2 → 4 (scripts legacy) [S]
- [x] Documentar edge case: señales emitidas antes de ready (deferred) [S]
- [x] Documentar edge case: resources mutables compartidos (duplicarlos) [S]
- [x] Documentar edge case: ruta de `res://` vs `user://` (guardados) [S]
- [x] Documentar edge case: floats y determinismo (generación procedural) [S]
- [x] Documentar edge case: threads y nodos (call_deferred obligatorio) [S]
- [x] Verificar trazabilidad de los 31 puntos del plan maestro [S]
- [x] Verificar coherencia con AGENTS.md (convenciones §24) [S]
- [x] Actualizar CHECKLIST-GLOBAL con el estado de M05 [S]
- [x] Actualizar DOCUMENTACION/README.md con el componente 05 [S]
- [x] Generar log de finalización y actualizar ULTIMO_NUMERO [S]
- [x] Copiar plan-inicial → plan-actual (espejo vigente) [S]

---

**Totales:** 102 ítems · Completados: 102 · Pendientes: 0 · No resueltos: 0.