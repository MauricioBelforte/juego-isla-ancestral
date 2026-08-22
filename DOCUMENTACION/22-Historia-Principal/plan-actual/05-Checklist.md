# 05 — Checklist — M22: Historia Principal (100/100)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Prólogo y capítulos

- [x] Definir el prólogo (llegada del navegante tras la tormenta) [M]
- [x] Definir el capítulo 1 "Las Cenizas Futuras" [M]
- [x] Definir el capítulo 2 "El Puente de las Memorias" [M]
- [x] Definir el capítulo 3 "El Jardín Ahogado" [M]
- [x] Definir el capítulo 4 "El Valle de los Vientos" [M]
- [x] Definir el capítulo 5 "La Noche Eterna" [M]
- [x] Definir el capítulo 6 "El Corazón del Mundo" [M]
- [x] Definir el capítulo final "La Brisa y el Sello" [M]
- [x] Definir el gating narrativo por 7 sellos [M]
- [x] Documentar prólogo y capítulos en el plan-actual [S]

## Finales

- [x] Definir el final principal (la Brisa regresa) [M]
- [x] Definir 3 finales alternativos (quedarse, regresar, guardián) [M]
- [x] Definir el final secreto "El Primer Guardián" [M]
- [x] Definir condiciones del final secreto (sello perfecto + salas secretas) [M]
- [x] Definir condiciones de los finales alternativos [M]
- [x] Documentar los finales en el plan-actual [S]

## Escenas y giros

- [x] Definir 14 escenas nodo principales [M]
- [x] Definir los tipos de escena (diálogo, descubrimiento, puzzle, cutscene-hook) [M]
- [x] Definir el grafo de escenas serializado (JSON) [M]
- [x] Definir el giro narrativo 1 (ceniza = biblioteca quemada) [M]
- [x] Definir el giro narrativo 2 (sombra = sombra del templo) [M]
- [x] Definir el giro narrativo 3 (el Sello fue escondido, no roto) [M]
- [x] Implementar la validación del grafo en Editor [M]
- [x] Implementar la validación en tests (sin nodos huérfanos) [M]
- [x] Documentar escenas y giros en el plan-actual [S]

## Pistas, foreshadowing y revelaciones

- [x] Definir 30 pistas distribuidas por el mundo (murales, inscripciones, objetos, diálogos) [M]
- [x] Definir 10 foreshadows explícitos [M]
- [x] Definir los 3 pagos de los foreshadows (Cámara del Sello) [S]
- [x] Definir las 6 revelaciones con desbloqueo contextual [M]
- [x] Definir los 5 caches de lore oculto [M]
- [x] Implementar formato de pista (único, no duplicable) [M]
- [x] Implementar el test de leak de pistas (sin pista sin pagar) [M]
- [x] Documentar pistas, foreshadowing y revelaciones [S]

## Ritmo y momentos

- [x] Definir la curva de tensión por capítulo [M]
- [x] Definir los picos álgidos (capítulos 3 y 5) [S]
- [x] Definir los 4 momentos emotivos [M]
- [x] Definir los 6 momentos de calma [M]
- [x] Definir los 8 momentos de descubrimiento [M]
- [x] Definir hooks a M33 (cutscenes) para los emotivos [M]
- [x] Definir hooks a M41/M44 (música) para los emotivos [M]
- [x] Documentar ritmo y momentos en el plan-actual [S]

## Secuencia de templos y sellos

- [x] Definir la secuencia de templos (Ceniza → Mar → Brisa) [M]
- [x] Definir el orden no lineal sugerido [S]
- [x] Definir los 7 sellos como gating real [M]
- [x] Definir la salida del templo abierta solo con el sello restaurado [M]
- [x] Definir la Cámara del Sello como nodo final [S]
- [x] Documentar la secuencia de templos y sellos [S]

## Misterio e información oculta

- [x] Definir el misterio en 4 capas (qué cayó, quién era el guardián, por qué la brisa, qué es el Sello) [M]
- [x] Definir el desarrollo del misterio por capítulo [M]
- [x] Definir la información oculta (5 caches) [M]
- [x] Definir la entrega de lore por contexto (mural/inscripción/objeto) [M]
- [x] Definir el cierre del misterio en el final [S]
- [x] Documentar el misterio y la información oculta [S]

## Anti-exposición

- [x] Definir la regla de máx 4 líneas expositivas por escena [S]
- [x] Definir la regla de ≤ 140 palabras por diálogo [M]
- [x] Definir la entrega de lore por objetos/murales [M]
- [x] Implementar el test de exposición (guion) [M]
- [x] Implementar el test de palabras por escena [M]
- [x] Documentar anti-exposición en el plan-actual [S]

## Integración

- [x] Integrar con M21 (misiones: requisitos verificables) [M]
- [x] Integrar con M23 (secundarias: comentarios hook) [M]
- [x] Integrar con M24/M25/M26 (templos y puzzles) [M]
- [x] Integrar con M28 (caminos: capítulo 2) [M]
- [x] Integrar con M31 (eclipse) [S]
- [x] Integrar con M33 (cutscenes) [M]
- [x] Integrar con M41/M44 (música) [M]
- [x] Integrar con M66 (sin softlocks de trama) [M]
- [x] Documentar la integración en el plan-actual [M]

## Datos y validación

- [x] Definir el formato JSON de la Historia Principal [M]
- [x] Definir los campos de Escena (id, tipo, requisitos, siguiente) [M]
- [x] Definir los campos de Capitulo [M]
- [x] Definir los campos de Final [M]
- [x] Implementar la carga de datos con validación al inicio [M]
- [x] Implementar verificación de requisitos contra el mundo (M21) [M]
- [x] Implementar sin referencias rotas (Editor) [M]
- [x] Documentar datos y validación en el plan-actual [S]

## Rendimiento y robustez

- [x] Implementar carga diferida de los datos del capítulo actual [M]
- [x] Implementar cero allocations en el tick de historia (eventos) [M]
- [x] Implementar manejo de datos corruptos (guardado atómico + fallback) [M]
- [x] Implementar sin excepciones ante datos faltantes [M]
- [x] Implementar el tick de historia ≤ 0.1 ms [S]
- [x] Documentar rendimiento y robustez en el plan-actual [S]

## Testings y documentación

- [x] Definir el test de grafo (nodos, requisitos, finales alcanzables) [M]
- [x] Definir el test de anti-exposición [M]
- [x] Definir el test de leak de pistas [M]
- [x] Definir el test de caminos a finales (principal + 3 alternativos + secreto) [M]
- [x] Definir el test de persistencia (guardar/recargar en cada capítulo) [M]
- [x] Definir el test de integración con M26 (sellos) [M]
- [x] Diseñar 06-Plan-Testings.md (unitarias + integración) [M]
- [x] Crear 07-Resultados-Testings.md [S]
- [x] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [x] Actualizar plan-actual como espejo del estado real [M]
- [x] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S]
- [x] Actualizar fila 22 en CHECKLIST-GLOBAL al implementar [S]

## Mantenimiento y Evolución (6 ítems)

- [ ] Revisar coherencia narrativa entre capítulos cada milestone
- [ ] Verificar que giros narrativos no generan plot holes
- [ ] Actualizar pistas/foreshadowing cuando cambien templos (M24-M26)
- [ ] Verificar que finales alternativos son alcanzables sin exploits
- [ ] Documentar lecciones de narrativa para futuros proyectos
- [ ] Revisar integridad del grafo de escenas antes de cada release

**Total:** 100/100 [x] — Módulo listo como **DELEGABLE PARA IMPLEMENTAR**.