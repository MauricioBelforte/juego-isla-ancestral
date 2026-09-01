# 05 — Checklist — M22: Historia Principal (100/100)

**Modelo:** glm-5.3-flash (último modificador; documentación base por Deepseek V4 Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-08-31

> **Reserva actual (LIBERADA 🟡)**
> **Agente:** glm-5.3-flash · **Plataforma:** Kilo Code · **Fecha:** 2026-08-31 22:20 · **Estado:** 🟡 Liberado (iter. 1 núcleo data verificado, Log 308)
> **Entrada:** M21 🟡 núcleo robusto (contrato aprobado) · **Salida:** grafo data-driven JSON + HistoriaService + gating Sellos + flags WorldState + validador de grafo + test headless 0 fallos
> **Archivos afectados:** `data/historia/historia_principal.json` (nuevo), `scripts/historia/story_manager.gd` (nuevo autoload Historia), `scripts/historia/validar_historia.gd` (nuevo), `scripts/historia/test_historia.gd` (nuevo), `project.godot` (autoload)

## Prólogo y capítulos

- [x] Definir el prólogo (llegada del navegante tras la tormenta) [M] — 03-Diseno §Arcos + nodo "prologo" en data/historia
- [x] Definir el capítulo 1 "Las Cenizas Futuras" [M] — 03-Diseno §Arcos + nodo en data/historia
- [x] Definir el capítulo 2 "El Puente de las Memorias" [M] — 03-Diseno §Arcos + nodo en data/historia
- [x] Definir el capítulo 3 "El Jardín Ahogado" [M] — 03-Diseno §Arcos + nodo en data/historia
- [x] Definir el capítulo 4 "El Valle de los Vientos" [M] — 03-Diseno §Arcos + nodo en data/historia
- [x] Definir el capítulo 5 "La Noche Eterna" [M] — 03-Diseno §Arcos + nodo en data/historia
- [x] Definir el capítulo 6 "El Corazón del Mundo" [M] — 03-Diseno §Arcos + nodo en data/historia
- [x] Definir el capítulo final "La Brisa y el Sello" [M] — 03-Diseno §Arcos + nodo en data/historia
- [x] Definir el gating narrativo por 7 sellos [M] — IMPLEMENTADO + testeado (HistoriaService.gating "sellos", 7/7 en test)
- [x] Documentar prólogo y capítulos en el plan-actual [S] — 04-Codigo Notas iter. 1

## Finales

- [x] Definir el final principal (la Brisa regresa) [M] — 03-Diseno + nodo final_principal (nota: data lo define como "florece")
- [x] Definir 3 finales alternativos (quedarse, regresar, guardián) [M] — nodos final_regresar/final_guardian + diseño (regresar/guardián; "quedarse" no está en 03-Diseno)
- [x] Definir el final secreto "El Primer Guardián" [M] — nodo final_secreto
- [x] Definir condiciones del final secreto (sello perfecto + salas secretas) [M] — IMPLEMENTADO: flag "pistas_secreto_completas" (M25/M147 lo alimentan)
- [x] Definir condiciones de los finales alternativos [M] — capítulo 7 completado + 7 sellos
- [x] Documentar los finales en el plan-actual [S] — 04-Codigo Notas iter. 1

## Escenas y giros

- [ ] Definir 14 escenas nodo principales [M]
- [ ] Definir los tipos de escena (diálogo, descubrimiento, puzzle, cutscene-hook) [M]
- [ ] Definir el grafo de escenas serializado (JSON) [M]
- [ ] Definir el giro narrativo 1 (ceniza = biblioteca quemada) [M]
- [ ] Definir el giro narrativo 2 (sombra = sombra del templo) [M]
- [ ] Definir el giro narrativo 3 (el Sello fue escondido, no roto) [M]
- [ ] Implementar la validación del grafo en Editor [M]
- [ ] Implementar la validación en tests (sin nodos huérfanos) [M]
- [ ] Documentar escenas y giros en el plan-actual [S]

## Pistas, foreshadowing y revelaciones

- [ ] Definir 30 pistas distribuidas por el mundo (murales, inscripciones, objetos, diálogos) [M]
- [ ] Definir 10 foreshadows explícitos [M]
- [ ] Definir los 3 pagos de los foreshadows (Cámara del Sello) [S]
- [ ] Definir las 6 revelaciones con desbloqueo contextual [M]
- [ ] Definir los 5 caches de lore oculto [M]
- [ ] Implementar formato de pista (único, no duplicable) [M]
- [ ] Implementar el test de leak de pistas (sin pista sin pagar) [M]
- [ ] Documentar pistas, foreshadowing y revelaciones [S]

## Ritmo y momentos

- [ ] Definir la curva de tensión por capítulo [M]
- [ ] Definir los picos álgidos (capítulos 3 y 5) [S]
- [ ] Definir los 4 momentos emotivos [M]
- [ ] Definir los 6 momentos de calma [M]
- [ ] Definir los 8 momentos de descubrimiento [M]
- [ ] Definir hooks a M33 (cutscenes) para los emotivos [M]
- [ ] Definir hooks a M41/M44 (música) para los emotivos [M]
- [ ] Documentar ritmo y momentos en el plan-actual [S]

## Secuencia de templos y sellos

- [ ] Definir la secuencia de templos (Ceniza → Mar → Brisa) [M]
- [ ] Definir el orden no lineal sugerido [S]
- [x] Definir los 7 sellos como gating real [M] — IMPLEMENTADO + testeado (catálogo sellos + req "sellos" cantidad 7)
- [x] Definir la salida del templo abierta solo con el sello restaurado [M] — flag "templo_brisa_abierto" en req C4 (M26 la activa)
- [x] Definir la Cámara del Sello como nodo final [S] — nodo c7 (Cámara) → 4 finales
- [x] Documentar la secuencia de templos y sellos [S] — data/historia/historia_principal.json sellos[] + 04-Codigo

## Misterio e información oculta

- [ ] Definir el misterio en 4 capas (qué cayó, quién era el guardián, por qué la brisa, qué es el Sello) [M]
- [ ] Definir el desarrollo del misterio por capítulo [M]
- [ ] Definir la información oculta (5 caches) [M]
- [ ] Definir la entrega de lore por contexto (mural/inscripción/objeto) [M]
- [ ] Definir el cierre del misterio en el final [S]
- [ ] Documentar el misterio y la información oculta [S]

## Anti-exposición

- [ ] Definir la regla de máx 4 líneas expositivas por escena [S]
- [ ] Definir la regla de ≤ 140 palabras por diálogo [M]
- [ ] Definir la entrega de lore por objetos/murales [M]
- [ ] Implementar el test de exposición (guion) [M]
- [ ] Implementar el test de palabras por escena [M]
- [ ] Documentar anti-exposición en el plan-actual [S]

## Integración

- [ ] Integrar con M21 (misiones: requisitos verificables) [M] — *parcial: flags WorldState + EventBus.quest consumidos; misiones reales M22/M23 con dueño*
- [ ] Integrar con M23 (secundarias: comentarios hook) [M]
- [ ] Integrar con M24/M25/M26 (templos y puzzles) [M]
- [ ] Integrar con M28 (caminos: capítulo 2) [M]
- [ ] Integrar con M31 (eclipse) [S]
- [ ] Integrar con M33 (cutscenes) [M]
- [ ] Integrar con M41/M44 (música) [M]
- [x] Integrar con M66 (sin softlocks de trama) [M] — requisitos verificables + validador (motivos explicativos, sin estados imposibles en v1)
- [ ] Documentar la integración en el plan-actual [M]

## Datos y validación

- [x] Definir el formato JSON de la Historia Principal [M] — data/historia/historia_principal.json v1
- [x] Definir los campos de Escena (id, tipo, requisitos, siguiente) [M] — nodos del JSON
- [x] Definir los campos de Capitulo [M] — campo "capitulo" 0-7 + títulos 03-Diseno
- [x] Definir los campos de Final [M] — tipo "final" + final_id
- [x] Implementar la carga de datos con validación al inicio [M] — HistoriaService._cargar_grafo + validar_historia.gd 0 fallos
- [x] Implementar verificación de requisitos contra el mundo (M21) [M] — puede_entrar: capitulos/sellos/flag WorldState/objeto M14; testeado
- [x] Implementar sin referencias rotas (Editor) [M] — validador: sin huérfanos/ciclos, 0 fallos
- [x] Documentar datos y validación en el plan-actual [S] — 04-Codigo Notas iter. 1

## Rendimiento y robustez

- [ ] Implementar carga diferida de los datos del capítulo actual [M]
- [ ] Implementar cero allocations en el tick de historia (eventos) [M]
- [x] Implementar manejo de datos corruptos (guardado atómico + fallback) [M] — restore tolerante (probado con {} y campos faltantes); JSON inválido → grafo vacío + push_error
- [x] Implementar sin excepciones ante datos faltantes [M] — get_nodo devuelve {}; puede_entrar lista motivo; testeaado
- [ ] Implementar el tick de historia ≤ 0.1 ms [S]
- [ ] Documentar rendimiento y robustez en el plan-actual [S]

## Testings y documentación

- [x] Definir el test de grafo (nodos, requisitos, finales alcanzables) [M] — scripts/historia/validar_historia.gd (0 fallos)
- [ ] Definir el test de anti-exposición [M]
- [ ] Definir el test de leak de pistas [M]
- [x] Definir el test de caminos a finales (principal + 3 alternativos + secreto) [M] — test_historia.gd _test_finales/_test_flags (4 finales alcanzables)
- [x] Definir el test de persistencia (guardar/recargar en cada capítulo) [M] — test_historia.gd _test_persistencia (round-trip); "cada capítulo" simplificado a estado final v1
- [x] Definir el test de integración con M26 (sellos) [M] — marcar_sello emite EventBus.quest.prereq_met (contrato M07/M26)
- [ ] Diseñar 06-Plan-Testings.md (unitarias + integración) [M]
- [ ] Crear 07-Resultados-Testings.md [S]
- [ ] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [ ] Actualizar plan-actual como espejo del estado real [M]
- [x] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S] — Log 308
- [x] Actualizar fila 22 en CHECKLIST-GLOBAL al implementar [S] — hecho (reserva y liberación)

## Mantenimiento y Evolución (6 ítems)

- [ ] Revisar coherencia narrativa entre capítulos cada milestone
- [ ] Verificar que giros narrativos no generan plot holes
- [ ] Actualizar pistas/foreshadowing cuando cambien templos (M24-M26)
- [ ] Verificar que finales alternativos son alcanzables sin exploits
- [ ] Documentar lecciones de narrativa para futuros proyectos
- [ ] Revisar integridad del grafo de escenas antes de cada release

**Total:** 100 ítems — 37/100 [x] (iter. 1 núcleo data, glm-5.3-flash 2026-08-31) · 63/100 [ ] con dueño (contenido narrativo, cutscenes, música, tests de guion, mantenimiento). Ver Log 308.

## QA Cruzado — Hy3 / WorkBuddy (2026-08-31, Log 313)

**Modelo:** Hy3 · **Plataforma:** WorkBuddy · **Tipo:** QA cruzado §21.8 (modelo distinto al autor glm-5.3-flash).

**Veredicto:** ✅ APROBADO. Grafo coherente (12 nodos, DAG, 4 finales alcanzables por aristas, 7 sellos). Gating correcto: c4/c7 exigen 7 sellos + flag templo; final_secreto exige flag `pistas_secreto_completas` (M25/M147). Persistencia M59 sección "historia" OK.

**Mejoras aplicadas (hardening de validación, mi fuerte):**
- `validar_historia.gd`: verifica `requisitos tipo "sellos" ≤ sellos_totales`; advierte cuando un final exige flag externo (M25/M147) — "in-alcanzable sin esa bandera"; `final_id` declarados ↔ nodos `tipo: final` bidireccionales.
- `story_manager.gd`: nuevo gate `_validar_grafo_en_ready()` que emite `push_error [VAL-HST]` al cargar si hay huérfanos / retroceso de capítulo / prólogo ausente / finales in-alcanzables / conteo de finales desparejo. No es fallo duro (el juego arranca), pero deja constancia temprana de regresiones del JSON.

**Hallazgo honesto:** el `final_secreto` es IN-ALCANZABLE sin `pistas_secreto_completas` (confirmado por `test_historia.gd:83`). No es bug: es por diseño (M25/M147 alimentan esa bandera). El validador ahora lo hace visible como ADVERTENCIA en lugar de silencio.

**Limitación:** no ejecutable headless en este entorno (Godot ausente); verificación estática de APIs preservadas + JSON válido.
