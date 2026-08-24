# 05 — Checklist — M23: Historias Secundarias (100/100)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Historias de vecinos

- [ ] Crear la historia de la panadera (2-4 pasos) [M]
- [ ] Crear la historia del farero [M]
- [ ] Crear la historia de la doctora [M]
- [ ] Crear la historia del carpintero [M]
- [ ] Crear la historia de la tejedora [M]
- [ ] Crear la historia del pescador [M]
- [ ] Crear la historia del guarda [M]
- [ ] Crear la historia de la alquimista [M]
- [ ] Documentar las historias de vecinos en el plan-actual [S]

## Historias de lugares, ruinas y objetos

- [ ] Crear la historia del faro (lugar) [M]
- [ ] Crear la historia de la biblioteca [M]
- [ ] Crear la historia de los jardines [M]
- [ ] Crear la historia de la plaza [M]
- [ ] Crear la historia del molino [M]
- [ ] Crear la historia de la cofradía [M]
- [ ] Crear historias de 4 ruinas (biblioteca quemada, observatorio, estación, puente) [M]
- [ ] Crear las historias de 6 objetos legendarios (relicto, gema, carta, llave, farol, brújula) [M]
- [ ] Documentar historias de lugares, ruinas y objetos [S]

## Historias de familias y comerciantes

- [ ] Crear la historia de la familia molinera [M]
- [ ] Crear la historia de la familia pescadores [M]
- [ ] Crear la historia de la familia guardas [M]
- [ ] Crear las historias de 3 comerciantes (rutas y secretos) [M]
- [ ] Documentar historias de familias y comerciantes [S]

## Historias estacionales y secretas

- [ ] Crear el evento de siembra (M32) [M]
- [ ] Crear el evento de vendimia [M]
- [ ] Crear el evento de marea [M]
- [ ] Crear el evento de eclipse [M]
- [ ] Crear 5 cadenas secretas ocultas [M]
- [ ] Definir el descubrimiento de las ocultas por el mundo [M]
- [ ] Documentar historias estacionales y secretas [S]

## Cadenas de misiones y exploración

- [ ] Definir 40+ cadenas de 3-5 pasos con contexto [M]
- [ ] Definir el schema de cadena (pasos, recompensa, consecuencia, oculta, postgame) [M]
- [ ] Crear 8 misiones de exploración (brújula, fauna, cronitado) [M]
- [ ] Documentar cadenas y misiones de exploración [S]

## Misiones de construcción y agricultura

- [ ] Crear 6 misiones de construcción (puentes, cofradía, plaza, senderos, kiosko, jardín) [M]
- [ ] Definir la reconstrucción del puente (M28) [M]
- [ ] Crear 5 misiones de agricultura (invernadero, cruces, variantes) [M]
- [ ] Definir variantes estacionales de agricultura (M32) [S]
- [ ] Documentar misiones de construcción y agricultura [S]

## Misiones de pesca y colección

- [ ] Crear 4 misiones de pesca (peces-trofeo, documentación y suelta) [M]
- [ ] Crear 6 misiones de colección (murales, glifos, sellos, minerales, peces, plantas) [M]
- [ ] Definir la integración con M36 (museo) [M]
- [ ] Documentar misiones de pesca y colección [S]

## Misiones de amistad e investigación

- [ ] Crear 6 misiones de amistad (regalo, pesca, paseos, ficción) [M]
- [ ] Crear 5 misiones de investigación (faro, biblioteca, geodesia, mapas) [M]
- [ ] Definir la integración con M36 (mapas) [S]
- [ ] Documentar misiones de amistad e investigación [S]

## Misiones de puzzles

- [ ] Crear 6 misiones de puzzles (templos 24/25/26, ruinas ocultas) [M]
- [ ] Definir la integración con el framework M24 [M]
- [ ] Documentar misiones de puzzles [S]

## Recompensas

- [ ] Crear 20 capítulos de diario (recompensa narrativa) [M]
- [ ] Crear recetas de conversación desbloqueables [M]
- [ ] Crear 10+ cosméticos (disfraces, sombreros, paletas de casa) [M]
- [ ] Definir cero stats en recompensas (cozy) [S]
- [ ] Definir recompensas únicas no duplicables (M66 cofre) [M]
- [ ] Documentar recompensas en el plan-actual [S]

## Consecuencias y diálogos posteriores

- [ ] Definir las 12 consecuencias persistentes [M]
- [ ] Crear la consecuencia "faro encendido" [S]
- [ ] Crear la consecuencia "jardín florecido" [S]
- [ ] Crear la consecuencia "taller abierto" [S]
- [ ] Crear la consecuencia "plaza decorada" [S]
- [ ] Crear la consecuencia "cofradía activa" [S]
- [ ] Crear la consecuencia "molino funcionando" [S]
- [ ] Definir el cambio visual del mundo por consecuencia [M]
- [ ] Definir diálogos posteriores por estado de mundo [M]
- [ ] Documentar consecuencias y diálogos posteriores [S]

## Anti-repetición y contexto

- [ ] Implementar el campo `contexto` obligatorio en el schema [M]
- [ ] Implementar la validación de contexto en Editor [M]
- [ ] Implementar la prohibición de misiones genéricas ("recoge N") [M]
- [ ] Implementar la falla de build si una cadena carece de contexto [M]
- [ ] Documentar la anti-repetición en el plan-actual [S]

## Misiones ocultas y postgame

- [ ] Definir el descubrimiento de misiones ocultas sin marcador [M]
- [ ] Definir la activación por pistas del mundo (M22) [S]
- [ ] Crear 4 cadenas de postgame [M]
- [ ] Definir la variación del postgame según el final de M22 [M]
- [ ] Crear la reconstrucción de la plaza post-final [S]
- [ ] Crear el memorial del Sello post-final [S]
- [ ] Crear el epílogo de la aldea [S]
- [ ] Crear el epílogo del guardián (final secreto) [S]
- [ ] Documentar misiones ocultas y postgame [S]

## Persistencia y validador

- [ ] Definir el guardado por cadena (paso, completada, consecuencias) [M]
- [ ] Implementar guardado atómico + `.bak` [M]
- [ ] Implementar el validador de referencias (NPC/lugares/objetos reales) [M]
- [ ] Implementar el validador de alcanzabilidad (M66) [M]
- [ ] Implementar el validador de recompensas únicas [M]
- [ ] Documentar la persistencia y el validador [S]

## Integración

- [ ] Integrar con M68 (objetivos y evaluación) [M]
- [ ] Integrar con M22 (hooks de consecuencia y postgame) [M]
- [ ] Integrar con M32 (estacionales) [M]
- [ ] Integrar con M36 (museo y colección) [M]
- [ ] Integrar con M37 (comerciantes) [M]
- [ ] Integrar con M66 (sin softlocks de cadena) [M]
- [ ] Documentar la integración en el plan-actual [M]

## Testings y documentación

- [ ] Diseñar test de validador de cadenas (contexto/referencias) [M]
- [ ] Diseñar test E2E de 10 cadenas completas [M]
- [ ] Diseñar test de consecuencias aplicadas y persistidas [M]
- [ ] Diseñar test de recompensas únicas [M]
- [ ] Diseñar test de postgame tras cada final (4 variaciones) [M]
- [ ] Diseñar 06-Plan-Testings.md (unitarias + integración) [M]
- [ ] Crear 07-Resultados-Testings.md [S]
- [ ] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [ ] Actualizar plan-actual como espejo del estado real [M]
- [ ] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S]
- [ ] Actualizar fila 23 en CHECKLIST-GLOBAL al implementar [S]

**Total:** 100/100 [ ] — Módulo listo como **DELEGABLE PARA IMPLEMENTAR**.