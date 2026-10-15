**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 05: Lenguaje y Programación

**Estado:** `[ ]` pendiente · `[ ]` completado · `[?]` no resuelto. Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

---

## A. Elección de lenguaje (12)

- [x] Evaluar GDScript como lenguaje principal [M] (02-Analisis §2: GDScript primario)
- [x] Evaluar C# como alternativa (build .NET de Godot) [S] (02-Analisis §1 #2 y §2: C# opcional por modulo)
- [x] Evaluar C++ para gameplay (descartado; GDExtension solo para sistemas nativos) [S] (02-Analisis §1 #4 y §2: sin C++ en gameplay)
- [x] Adoptar **GDScript** como lenguaje primario del proyecto [S] (02-Analisis §2)
- [x] Documentar por qué Voxel Tools (C++) cubre el cuello de botella de rendimiento [S] (02-Analisis §2: Voxel Tools cubre el rendimiento)
- [x] Documentar el uso puntual de C# si un módulo lo exige (decisión por módulo) [S] (02-Analisis §2)
- [x] Documentar el riesgo de menor conocimiento externo de GDScript [S] (02-Analisis §2 (Riesgo documentado))
- [x] Documentar la mitigación: scripts autocontenidos y convenciones claras [S] (02-Analisis §2 (mitigacion))
- [x] Verificar compatibilidad de la decisión con Godot 4.x (M04) [S] (MEDIDO 2026-10-13: project.godot config/features=("4.7","Forward Plus") + 1063 .gd; M04 04-Codigo §2 fija 4.7.2)
- [x] Documentar tipado explícito como requisito (no GDScript sin tipar) [S] (03-Diseno §1 (Tipado: obligatorio) + §6.1)
- [x] Documentar la regla de const/export en vez de literales [S] (03-Diseno §1 (Constantes/Exports) + §6.2)
- [x] Registrar la decisión en CHECKLIST-GLOBAL (consumida por M07) [S] (fila 05 de CHECKLIST-GLOBAL.md (verificada))

## B. Convenciones de nombres (16)

- [x] Fijar clases: PascalCase + `class_name` [S] (03-Diseno §1 (tabla de convenciones))
- [x] Fijar archivos: snake_case derivado de la clase [S] (03-Diseno §1)
- [x] Fijar nodos/escenas: snake_case [S] (03-Diseno §1)
- [x] Fijar variables locales: snake_case [S] (03-Diseno §1)
- [x] Fijar variables privadas: prefijo `_` [S] (03-Diseno §1)
- [x] Fijar constantes: UPPER_SNAKE_CASE [S] (03-Diseno §1)
- [x] Fijar métodos: snake_case con retorno tipado [S] (03-Diseno §1)
- [x] Fijar señales: snake_case tipadas [S] (03-Diseno §1)
- [x] Fijar enums: UPPER_SNAKE con nombre contextual [S] (03-Diseno §1)
- [x] Fijar @export con rangos y descripciones [S] (03-Diseno §1)
- [x] Fijar indentación con TAB (tabulación) y líneas ≤ 120 [S] (03-Diseno §1 (Reglas de estilo 1); corregido 2026-10-14: la guía se pasó a TAB por decisión del director — 1016/1054 `.gd` versionados usan TAB)
- [x] Fijar la regla de un archivo = una responsabilidad [S] (03-Diseno §1 (Reglas de estilo 1))
- [x] Fijar la regla de comentarios (propósito/por-qué, español) [S] (03-Diseno §1 (Reglas de estilo 2-3))
- [x] Fijar la prohibición de print() de debug en producción [S] (03-Diseno §1 (Reglas de estilo 4))
- [x] Fijar el límite de 400 líneas con justificación [S] (03-Diseno §1 (Reglas de estilo 6))
- [x] Documentar la aplicación del estándar a agentes IA y freelancers [S] (02-Analisis §2 (agentes IA y freelancers))

## C. Arquitectura de carpetas de código (12)

- [x] Diseñar `scenes/` por sistema [S] (03-Diseno §2)
- [x] Diseñar `scripts/core/` (autoloads) [S] (event_bus, game_settings, service_registry, softlock_guard, bootstrap + registro.gd)
- [x] Diseñar `scripts/gameplay/` [S] (03-Diseno §2)
- [x] Diseñar `scripts/ai/` [S] (03-Diseno §2)
- [x] Diseñar `scripts/world/` [S] (03-Diseno §2)
- [x] Diseñar `scripts/ui/` [S] (03-Diseno §2)
- [x] Diseñar `scripts/data/` (resources) [S] (03-Diseno §2)
- [x] Diseñar `scripts/utils/` (helpers) [S] (03-Diseno §2)
- [x] Diseñar `resources/` (archivos .tres de datos) [S] (03-Diseno §2)
- [x] Diseñar `data/` (seeds y configs serializadas) [S] (03-Diseno §2)
- [x] Verificar coherencia con la estructura planteada en M04 §2 [S] (MEDIDO: coherente con M04 04-Codigo §2 (project.godot/scenes/scripts/resources/data); la cita 'M04 §2' apunta a 04-Codigo (M04 03-Diseno §2 = chunks))
- [x] Documentar que UI no contiene lógica de negocio (regla de capas) [S] (02-Analisis §3 + 03-Diseno §6.4 + 01-Requerimientos RF4)

## D. Patrones transversales (20)

- [x] Diseñar EventBus (autoload, señales tipadas por dominio) [M] (event_bus.gd: EventBus_ con dominios world/economy/inventory/quest/npc/calendar/travel/ui/player; verificado con smoke)
- [x] Diseñar GameClock (fecha/estación/hora, patrón observer) [M] (03-Diseno §3 (tabla) + §5)
- [x] Diseñar Settings autoload (config con persistencia .cfg) [M] (03-Diseno §3)
- [x] Diseñar Logger con niveles y rotación (AGENTS §18) [M] (03-Diseno §3)
- [x] Diseñar ErrorHandler con fallback y reporte [M] (03-Diseno §3)
- [x] Diseñar SceneManager con carga diegética [M] (03-Diseno §3)
- [x] Diseñar PoolService genérico (props/partículas) [M] (03-Diseno §3)
- [x] Diseñar GameState (serializable, versionado; detalle en M59) [M] (03-Diseno §3)
- [x] Diseñar QuestManager con prerequisitos (sellos→boletos) [M] (03-Diseno §3)
- [x] Definir regla: señales que cruzan sistemas pasan por EventBus [S] (03-Diseno §4)
- [x] Definir regla: señales locales quedan en el nodo [S] (03-Diseno §4)
- [x] Definir payload tipado en eventos (no diccionarios abiertos) [S] (03-Diseno §4)
- [x] Diseñar state machine de entidades (jugador/NPC) [S] (03-Diseno §5)
- [x] Definir transiciones explícitas entre estados [S] (03-Diseno §5)
- [x] Definir regla: estados no editan otros directamente [S] (03-Diseno §5)
- [x] Diseñar TimerManager centralizado [S] (02-Analisis §1 #23)
- [x] Diseñar serialización JSON/Resource [S] (02-Analisis §1 #19)
- [x] Diseñar sistema de dependencias (autoloads + resources, sin espagueti) [S] (verificado por verificar_arquitectura.gd: dependencias unidireccionales + precedencias)
- [x] Diseñar sistema de pooling reutilizable [S] (02-Analisis §1 #22)
- [x] Diseñar el flujo de errores "log → fallback → (dev) pausa" [S] (03-Diseno §3 (ErrorHandler: log + fallback + (dev) pausa))

## E. Anti-patrones a prevenir (10)

- [x] Prohibir GameManager monolítico (regla M07) [S] (02-Analisis §3 (anti-patrones))
- [x] Prohibir lógica de negocio en scripts de UI [S] (02-Analisis §3)
- [x] Prohibir singletons espagueti (Service Locator con interfaces) [S] (02-Analisis §3)
- [x] Prohibir eventos sin tipado [S] (02-Analisis §3)
- [x] Prohibir strings mágicos para estados (enums centrales) [S] (02-Analisis §3)
- [x] Prohibir pooling manual repetido (usar PoolService) [S] (02-Analisis §3)
- [x] Prohibir acceso directo a GameState desde gameplay (capas) [S] (03-Diseno §6.5)
- [x] Prohibir modificar señales del engine en el momento equivocado (deferred) [S] (03-Diseno §7.1 (deferred obligatorio; aplicado en bootstrap.gd:47-50 y scene_manager.gd:33))
- [x] Prohibir procesar todo en `_process` (timers/eventos) [S] (03-Diseno §7.2 (input por _unhandled_input; MEDIDO: 58 scripts con _process))
- [x] Prohibir duplicar lógica entre módulos (reutilizar utils) [S] (03-Diseno §7.3 (helper a scripts/utils/ al 3er consumidor))

## F. Calidad y "done" por script (10)

- [x] Definir: código sin warnings del editor para merge [S] (03-Diseno §6.1)
- [x] Definir: tipado completo en firmas [S] (03-Diseno §6.1)
- [x] Definir: logs en sistemas críticos (Logger) [S] (03-Diseno §6.3)
- [x] Definir: sin strings mágicos [S] (03-Diseno §6.2)
- [x] Definir: sin llamadas UI desde gameplay [S] (03-Diseno §6.4)
- [x] Definir: acceso de datos solo vía módulos de datos [S] (03-Diseno §6.5)
- [ ] Definir: tests unitarios obligatorios para lógica pura (M-QA) [S]
- [x] Definir: revisión de convenciones en cada PR (revisión de código) [S] (01-Requerimientos §4.2 (guia verificable para cualquier PR) + 03-Diseno §1)
- [x] Definir: actualización de este checklist al crear módulos nuevos [S] (03-Diseno §9.1; AGENTS.md §21.1)
- [x] Definir: registro de cada decisión de código en Logs [S] (03-Diseno §9.2; AGENTS.md §6.1-§6.3)

## G. Integración con otros módulos (10)

- [x] Documentar flujo hacia M07 (arquitectura: managers y autoloads) [S] (04-Codigo §3 (EventBus/autoloads -> M07))
- [x] Documentar flujo hacia M11 (state machine del jugador) [S] (04-Codigo §3 (FSM del jugador -> M11; `player_fsm.gd`:1-2/25/108; `EventBus.PlayerEvents`))
- [x] Documentar flujo hacia M29 (GameClock) [S] (04-Codigo §3 (EventBus tipado -> M29))
- [x] Documentar flujo hacia M59 (GameState/guardado) [S] (04-Codigo §3 (Logger+ErrorHandler -> M59))
- [x] Documentar flujo hacia M53 (UI sin lógica) [S] (04-Codigo §3 (regla de capas -> M53))
- [x] Documentar flujo hacia M58 (Settings de accesibilidad) [S] (04-Codigo §3 (autoload `GameSettings` -> M58; `core/game_settings.gd`:7/29; `scripts/accesibilidad/`))
- [x] Documentar flujo hacia M61 (rendimiento: pooling/timers) [S] (04-Codigo §3 (Logger+ErrorHandler -> M61))
- [ ] Documentar flujo hacia QA (tests unitarios desde M1) [S]
- [x] Documentar flujo hacia M08 (voxel tools + estado de chunks) [S] (04-Codigo §3 (EventBus dominio `world` -> M08; `core/event_bus.gd`:50-56))
- [x] Verificar que ningún módulo contradice la guía de convenciones [S] (03-Diseno §1: las 2 reglas restantes —líneas ≤120 y `print()`— quedaron declaradas **aspiracionales/no bloqueantes** por decisión del director (msg 245); la guía ya no contradice al código)

## H. Edge cases y verificación documental (12)

- [x] Documentar edge case: migración GDScript 2 → 4 (scripts legacy) [S] (03-Diseno §8.1 (GUIA-GODOT/09 + GUIA-GODOT/01 §31))
- [x] Documentar edge case: señales emitidas antes de ready (deferred) [S] (03-Diseno §8.2 (GUIA-GODOT/01 §26 y §24))
- [x] Documentar edge case: resources mutables compartidos (duplicarlos) [S] (03-Diseno §8.3 (cache por ruta; accesibilidad_manager.gd:207/266))
- [x] Documentar edge case: ruta de `res://` vs `user://` (guardados) [S] (03-Diseno §8.4 (save_schema.gd:17; save_writer.gd:49))
- [x] Documentar edge case: floats y determinismo (generación procedural) [S] (03-Diseno §8.5 (island_generator.gd:47/54/61/68; game_clock.gd:203))
- [x] Documentar edge case: threads y nodos (call_deferred obligatorio) [S] (03-Diseno §8.6 (arbol no thread-safe))
- [x] Verificar trazabilidad de los 27 puntos del plan maestro [S] (MEDIDO 2026-10-14: plan-inicial-minimo §4 = 27 puntos (L106-137); tabla 02-Analisis §1 = 27 filas, mapeo 1:1)
- [ ] Verificar coherencia con AGENTS.md (convenciones §24) [S]
- [ ] Actualizar CHECKLIST-GLOBAL con el estado de M05 [S]
- [x] Actualizar DOCUMENTACION/README.md con el componente 05 [S] (verificado: README lista 05-Lenguaje-Y-Programacion (nota: su conteo 102/102 quedo stale))
- [x] Generar log de finalización (ULTIMO_NUMERO retirado: protocolo v3) [S] (Log 1842; ULTIMO_NUMERO.txt retirado en commits 2ac8b4b/b65c30b; el log se numera desde Logs/NUMEROS_DISPONIBLES.txt)
- [x] Copiar plan-inicial → plan-actual (espejo vigente) [S] (verificado: DOCUMENTACION/05-Lenguaje-Y-Programacion/plan-actual/ existe (5 archivos; espejo vigente))

---

**Totales:** 103 ítems · Completados: 99 · Pendientes: 4 · No resueltos: 0.

## Implementacion Fase 1 (2026-08-29 — Hy3/Kilo)

- [x] Preparar utilidades basicas de validacion y logging [S] (scripts/core/registro.gd: info/aviso/error/verificar/verificar_no_nulo con contadores; test headless 0 fallos)


## Notas del Agente (Cierre Fase 1 - 2026-08-29)

**Modelo:** Hy3 | **Plataforma:** Kilo | **Estado:** items de la guia 08 completados y verificados; auditoria del resto del checklist pendiente (honestidad 21.4.3)

### Lo que hice
- Verificacion con Godot 4.7.2 headless + runtime: proyecto arranca sin errores de script.
- Ver tilo de guia 08 del modulo completado con evidencia (ver seccion "Implementacion Fase 1").
- Libere el modulo en CHECKLIST-GLOBAL y ESTADO-PARALELO como nucleo verificado (🟡); la auditoria completa del checklist queda para la siguiente pasada.

### Pendiente (honestidad)
- Auditoria item por item del resto de este checklist contra el codigo real.

## Auditoria contra 01-04 (2026-10-13 - DeepSeek-V4.1-Flash)

78 flips `[ ]` -> `[x]` con cita real al contenido YA existente en 01-Requerimientos / 02-Analisis / 03-Diseno / 04-Codigo (criterio por verbo: "Fijar/Definir/Disenar/Documentar X" -> basta si X esta en 01-04). Totales: **82/103**. NO se toco CHECKLIST-GLOBAL (la fila la aplica el director).

### Los 21 `[ ]` restantes (honestidad - NO flipeados)

- **E8/E9/E10** (anti-patrones deferred / `_process` / duplicar logica): 02-Analisis §3 solo cubre 7 anti-patrones; estos 3 no tienen contenido -> requieren disenarse.
- **F7** (tests unitarios obligatorios para logica pura): dueno externo **M-QA** (04-Codigo §4 lo declara pendiente).
- **F9** (actualizacion de este checklist al crear modulos nuevos): regla de proceso; no vive en los 5 documentos del modulo.
- **F10** (registro de cada decision de codigo en Logs): cubierto por AGENTS.md §6, no por M05.
- **G2** (flujo hacia M11): 04-Codigo §4 lo declara pendiente con dueno **M11**.
- **G6** (flujo hacia M58): solo aparece como dueno de `settings.gd`, no como flujo.
- **G8** (flujo hacia QA): dueno **M-QA** (04-Codigo §4).
- **G9** (flujo hacia M08): solo aparece como dueno de `scripts/world/voxel/*`, no como flujo.
- **H1-H6** (edge cases): sin contenido en los 5 documentos -> requieren disenarse (fuente: GUIA-GODOT/01).
- **H7** (trazabilidad de los 31 puntos): 02-Analisis §1 titula "31 puntos" pero la tabla tiene **27 filas** -> inconsistencia a resolver (27 o 31).
- **H8** (coherencia con AGENTS.md §24): **FALLA** - AGENTS.md §24 "Stack Tecnologico" describe **Unity + C#** mientras M05 fija Godot 4.x + GDScript. Drift de documento ajeno; reportado, NO editado.
- **H9** (actualizar CHECKLIST-GLOBAL): la fila 05 existe; el flip de la fila lo aplica el director.
- **H11** (log de finalizacion + ULTIMO_NUMERO): log generado; `ULTIMO_NUMERO.txt` esta **retirado** (protocolo v3, commits `2ac8b4b`/`b65c30b`) -> item obsoleto.

## Diseno faltante escrito (2026-10-14 - DeepSeek-V4.1-Flash)

9 flips `[ ]` -> `[x]` tras ESCRIBIR el diseno faltante en `03-Diseno` (orden del director, msg 235). Totales: **91/103**. NO se toco CHECKLIST-GLOBAL (la fila la aplica el director).

- **E8/E9/E10** (anti-patrones deferred / `_process` / duplicar logica): disenados en `03-Diseno` §7.1/§7.2/§7.3 (GUIA-GODOT/01 §13-§14/§4/§26 + rutas reales del repo).
- **H1-H6** (edge cases): disenados en `03-Diseno` §8.1-§8.6 (migracion GDScript 3->4, senales antes de ready, resources compartidos, `res://` vs `user://`, floats/determinismo, threads+nodos).

### Los 12 `[ ]` restantes (honestidad - NO flipeados)

- **F7** (tests unitarios obligatorios para logica pura): dueno externo **M-QA** (04-Codigo §4).
- **F9** (actualizacion de este checklist al crear modulos nuevos): regla de proceso; no vive en los 5 documentos del modulo.
- **F10** (registro de cada decision de codigo en Logs): cubierto por AGENTS.md §6, no por M05.
- **G2** (flujo hacia M11): 04-Codigo §4 lo declara pendiente con dueno **M11**.
- **G6** (flujo hacia M58): solo aparece como dueno de `settings.gd`, no como flujo.
- **G8** (flujo hacia QA): dueno **M-QA** (04-Codigo §4).
- **G9** (flujo hacia M08): solo aparece como dueno de `scripts/world/voxel/*`, no como flujo.
- **G10** (ningun modulo contradice la guia): auditoria cross-modulo; requiere el barrido de todos los modulos.
- **H7** (trazabilidad de los 31 puntos): 02-Analisis §1 titula "31 puntos" pero la tabla tiene **27 filas** -> inconsistencia a resolver (27 o 31).
- **H8** (coherencia con AGENTS.md §24): **FALLA** - AGENTS.md §24 describe **Unity + C#** mientras M05 fija Godot 4.x + GDScript. Drift de documento ajeno; reportado, NO editado.
- **H9** (actualizar CHECKLIST-GLOBAL): la fila 05 existe; el flip de la fila lo aplica el director.
- **H11** (log de finalizacion + ULTIMO_NUMERO): log generado; `ULTIMO_NUMERO.txt` esta **retirado** (protocolo v3, commits `2ac8b4b`/`b65c30b`) -> item obsoleto.

## Cierre de items de proceso (2026-10-14 - DeepSeek-V4.1-Flash)

4 flips `[ ]` -> `[x]` (F9, F10, H7, H11) sobre items de **proceso/documento** del propio modulo, listados por el director (msg 239). Totales: **95/103**.

- **F9** (actualizacion del checklist al crear modulos): definido en `03-Diseno` §9.1 (dos indices: maestro M01 + fila GLOBAL; el `05-Checklist` del modulo es la fuente de verdad de sus subitems).
- **F10** (registro de decisiones en Logs): definido en `03-Diseno` §9.2 (protocolo v3, AGENTS.md §6).
- **H7** (trazabilidad de los puntos del plan maestro): **RESUELTO por medicion** - el plan maestro (`00-PLAN-INICIAL/Plan-inicial-minimo.md` §4, L106-137) tiene **27** puntos, no 31; la tabla de `02-Analisis` §1 mapea 1:1 con ellos. Drift "31" corregido en `02-Analisis` §1 y `04-Codigo` (linea 59).
- **H11** (log de finalizacion + ULTIMO_NUMERO): log generado (Log 1842); `ULTIMO_NUMERO.txt` esta **retirado** (protocolo v3) -> item reescrito para reflejarlo.

### Los 4 `[ ]` restantes (honestidad - NO flipeados)

> **Iter. 4 (2026-10-14, DeepSeek-V4.1-Flash):** G2/G6/G9 pasaron a `[x]` con evidencia medida
> (ver `04-Codigo` §3 y su nota).
> **Iter. 6 (2026-10-14, DeepSeek-V4.1-Flash):** G10 paso a `[x]` tras la decision del director
> (msg 245, opcion b: declarar las 2 reglas aspiracionales). Quedan 4.

- **F7** (tests unitarios obligatorios para logica pura): dueno externo **M-QA** (04-Codigo §4).
- **G8** (flujo hacia QA): dueno **M-QA** (04-Codigo §4).
- **G10** (ningun modulo contradice la guia): **RESUELTO (iter 5)** — ver `## Re-verificacion G10 y cierre` al final. El director resolvio con la opcion (b): declarar aspiracionales las reglas de lineas <=120 y `print()`, con lo cual la guia deja de contradecir al codigo.
- **H8** (coherencia con AGENTS.md §24): **FALLA** - AGENTS.md §24 describe **Unity + C#** mientras M05 fija Godot 4.x + GDScript. Drift de documento ajeno; reportado, NO editado.
- **H9** (actualizar CHECKLIST-GLOBAL): la fila 05 refleja **98/103**; el flip de la fila a **99/103** lo aplica el director (no se toca CHECKLIST-GLOBAL desde el modulo).

## Cierre de G10 (2026-10-14 - DeepSeek-V4.1-Flash, iter 6)

Historia de las mediciones de G10:

- **Iter. 5 (msg 243):** el director autorizo flipear G10 "ahora que la guia y el codigo coinciden". Se re-midio ANTES de tocar la marca: la coincidencia valia para la regla de INDENTACION (guia corregida a TAB), pero NO para las otras 2 reglas medibles de la misma `03-Diseno` §1.
- **Iter. 6 (msg 245):** el director resolvio con la **opcion (b): declarar las 2 reglas aspiracionales (no bloqueantes)** en `03-Diseno` §1, porque normalizar 692 lineas >120 y 3546 `print()` romperia `git blame` y varios `print` son intencionales. Con la guia declarando las reglas aspiracionales, G10 deja de ser contradiccion -> se flipea `[x]`.

Mediciones (2026-10-14, sobre `scripts/**/*.gd` versionado):
- Indentacion: **1016** archivos con TAB vs **13** con 4 espacios. Comando: `git grep -lP '^\t' -- 'scripts/**/*.gd' | wc -l`.
- Regla "lineas <= 120 chars": **692 lineas** por encima de 120 en **283 archivos** (9 son comentarios). Comando: `git grep -cP '^.{121,}$' -- 'scripts/**/*.gd' | wc -l`.
- Regla "nada de `print()` de debug en produccion": **3546 lineas** con `print(` al inicio en **207 archivos** no-test (8 en editor/tools/debug/qa). Comando: `git grep -lE '^\s*print\(' -- 'scripts/**/*.gd' | grep -v test_ | wc -l`.

Accion: nota aspiracional agregada a `03-Diseno` §1 (ver alli). **1 flip** (G10) -> `Totales` **99/103**. NO se toco `CHECKLIST-GLOBAL` (la fila a 99/103 la aplica el director).

En la iter. 5 previa se corrigieron 2 menciones stale de "4 espacios" (`04-Codigo` L35 y este checklist L37) para que M05 no contradiga su propia guia corregida.
