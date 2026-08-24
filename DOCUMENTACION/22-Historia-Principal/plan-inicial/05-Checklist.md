# 05 — Checklist — M22: Historia Principal (100/100)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Prólogo y capítulos

- [ ] Definir el prólogo (llegada del navegante tras la tormenta) [M]
- [ ] Definir el capítulo 1 "Las Cenizas Futuras" [M]
- [ ] Definir el capítulo 2 "El Puente de las Memorias" [M]
- [ ] Definir el capítulo 3 "El Jardín Ahogado" [M]
- [ ] Definir el capítulo 4 "El Valle de los Vientos" [M]
- [ ] Definir el capítulo 5 "La Noche Eterna" [M]
- [ ] Definir el capítulo 6 "El Corazón del Mundo" [M]
- [ ] Definir el capítulo final "La Brisa y el Sello" [M]
- [ ] Definir el gating narrativo por 7 sellos [M]
- [ ] Documentar prólogo y capítulos en el plan-actual [S]

## Finales

- [ ] Definir el final principal (la Brisa regresa) [M]
- [ ] Definir 3 finales alternativos (quedarse, regresar, guardián) [M]
- [ ] Definir el final secreto "El Primer Guardián" [M]
- [ ] Definir condiciones del final secreto (sello perfecto + salas secretas) [M]
- [ ] Definir condiciones de los finales alternativos [M]
- [ ] Documentar los finales en el plan-actual [S]

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
- [ ] Definir los 7 sellos como gating real [M]
- [ ] Definir la salida del templo abierta solo con el sello restaurado [M]
- [ ] Definir la Cámara del Sello como nodo final [S]
- [ ] Documentar la secuencia de templos y sellos [S]

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

- [ ] Integrar con M21 (misiones: requisitos verificables) [M]
- [ ] Integrar con M23 (secundarias: comentarios hook) [M]
- [ ] Integrar con M24/M25/M26 (templos y puzzles) [M]
- [ ] Integrar con M28 (caminos: capítulo 2) [M]
- [ ] Integrar con M31 (eclipse) [S]
- [ ] Integrar con M33 (cutscenes) [M]
- [ ] Integrar con M41/M44 (música) [M]
- [ ] Integrar con M66 (sin softlocks de trama) [M]
- [ ] Documentar la integración en el plan-actual [M]

## Datos y validación

- [ ] Definir el formato JSON de la Historia Principal [M]
- [ ] Definir los campos de Escena (id, tipo, requisitos, siguiente) [M]
- [ ] Definir los campos de Capitulo [M]
- [ ] Definir los campos de Final [M]
- [ ] Implementar la carga de datos con validación al inicio [M]
- [ ] Implementar verificación de requisitos contra el mundo (M21) [M]
- [ ] Implementar sin referencias rotas (Editor) [M]
- [ ] Documentar datos y validación en el plan-actual [S]

## Rendimiento y robustez

- [ ] Implementar carga diferida de los datos del capítulo actual [M]
- [ ] Implementar cero allocations en el tick de historia (eventos) [M]
- [ ] Implementar manejo de datos corruptos (guardado atómico + fallback) [M]
- [ ] Implementar sin excepciones ante datos faltantes [M]
- [ ] Implementar el tick de historia ≤ 0.1 ms [S]
- [ ] Documentar rendimiento y robustez en el plan-actual [S]

## Testings y documentación

- [ ] Definir el test de grafo (nodos, requisitos, finales alcanzables) [M]
- [ ] Definir el test de anti-exposición [M]
- [ ] Definir el test de leak de pistas [M]
- [ ] Definir el test de caminos a finales (principal + 3 alternativos + secreto) [M]
- [ ] Definir el test de persistencia (guardar/recargar en cada capítulo) [M]
- [ ] Definir el test de integración con M26 (sellos) [M]
- [ ] Diseñar 06-Plan-Testings.md (unitarias + integración) [M]
- [ ] Crear 07-Resultados-Testings.md [S]
- [ ] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [ ] Actualizar plan-actual como espejo del estado real [M]
- [ ] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S]
- [ ] Actualizar fila 22 en CHECKLIST-GLOBAL al implementar [S]

**Total:** 100/100 [ ] — Módulo listo como **DELEGABLE PARA IMPLEMENTAR**.