# 05 — Checklist — M23: Historias Secundarias (100/100)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Historias de vecinos

- [x] Crear la historia de la panadera (2-4 pasos) [M]
- [x] Crear la historia del farero [M]
- [x] Crear la historia de la doctora [M]
- [x] Crear la historia del carpintero [M]
- [x] Crear la historia de la tejedora [M]
- [x] Crear la historia del pescador [M]
- [x] Crear la historia del guarda [M]
- [x] Crear la historia de la alquimista [M]
- [x] Documentar las historias de vecinos en el plan-actual [S]

## Historias de lugares, ruinas y objetos

- [x] Crear la historia del faro (lugar) [M]
- [x] Crear la historia de la biblioteca [M]
- [x] Crear la historia de los jardines [M]
- [x] Crear la historia de la plaza [M]
- [x] Crear la historia del molino [M]
- [x] Crear la historia de la cofradía [M]
- [x] Crear historias de 4 ruinas (biblioteca quemada, observatorio, estación, puente) [M]
- [x] Crear las historias de 6 objetos legendarios (relicto, gema, carta, llave, farol, brújula) [M]
- [x] Documentar historias de lugares, ruinas y objetos [S]

## Historias de familias y comerciantes

- [x] Crear la historia de la familia molinera [M]
- [x] Crear la historia de la familia pescadores [M]
- [x] Crear la historia de la familia guardas [M]
- [x] Crear las historias de 3 comerciantes (rutas y secretos) [M]
- [x] Documentar historias de familias y comerciantes [S]

## Historias estacionales y secretas

- [x] Crear el evento de siembra (M32) [M]
- [x] Crear el evento de vendimia [M]
- [x] Crear el evento de marea [M]
- [x] Crear el evento de eclipse [M]
- [x] Crear 5 cadenas secretas ocultas [M]
- [x] Definir el descubrimiento de las ocultas por el mundo [M]
- [x] Documentar historias estacionales y secretas [S]

## Cadenas de misiones y exploración

- [x] Definir 40+ cadenas de 3-5 pasos con contexto [M]
- [x] Definir el schema de cadena (pasos, recompensa, consecuencia, oculta, postgame) [M]
- [x] Crear 8 misiones de exploración (brújula, fauna, cronitado) [M]
- [x] Documentar cadenas y misiones de exploración [S]

## Misiones de construcción y agricultura

- [x] Crear 6 misiones de construcción (puentes, cofradía, plaza, senderos, kiosko, jardín) [M]
- [x] Definir la reconstrucción del puente (M28) [M]
- [x] Crear 5 misiones de agricultura (invernadero, cruces, variantes) [M]
- [x] Definir variantes estacionales de agricultura (M32) [S]
- [x] Documentar misiones de construcción y agricultura [S]

## Misiones de pesca y colección

- [x] Crear 4 misiones de pesca (peces-trofeo, documentación y suelta) [M]
- [x] Crear 6 misiones de colección (murales, glifos, sellos, minerales, peces, plantas) [M]
- [x] Definir la integración con M36 (museo) [M]
- [x] Documentar misiones de pesca y colección [S]

## Misiones de amistad e investigación

- [x] Crear 6 misiones de amistad (regalo, pesca, paseos, ficción) [M]
- [x] Crear 5 misiones de investigación (faro, biblioteca, geodesia, mapas) [M]
- [x] Definir la integración con M36 (mapas) [S]
- [x] Documentar misiones de amistad e investigación [S]

## Misiones de puzzles

- [x] Crear 6 misiones de puzzles (templos 24/25/26, ruinas ocultas) [M]
- [x] Definir la integración con el framework M24 [M]
- [x] Documentar misiones de puzzles [S]

## Recompensas

- [x] Crear 20 capítulos de diario (recompensa narrativa) [M]
- [x] Crear recetas de conversación desbloqueables [M]
- [x] Crear 10+ cosméticos (disfraces, sombreros, paletas de casa) [M]
- [x] Definir cero stats en recompensas (cozy) [S]
- [x] Definir recompensas únicas no duplicables (M66 cofre) [M]
- [x] Documentar recompensas en el plan-actual [S]

## Consecuencias y diálogos posteriores

- [x] Definir las 12 consecuencias persistentes [M]
- [x] Crear la consecuencia "faro encendido" [S]
- [x] Crear la consecuencia "jardín florecido" [S]
- [x] Crear la consecuencia "taller abierto" [S]
- [x] Crear la consecuencia "plaza decorada" [S]
- [x] Crear la consecuencia "cofradía activa" [S]
- [x] Crear la consecuencia "molino funcionando" [S]
- [x] Definir el cambio visual del mundo por consecuencia [M]
- [x] Definir diálogos posteriores por estado de mundo [M]
- [x] Documentar consecuencias y diálogos posteriores [S]

## Anti-repetición y contexto

- [x] Implementar el campo `contexto` obligatorio en el schema [M]
- [x] Implementar la validación de contexto en Editor [M]
- [x] Implementar la prohibición de misiones genéricas ("recoge N") [M]
- [x] Implementar la falla de build si una cadena carece de contexto [M]
- [x] Documentar la anti-repetición en el plan-actual [S]

## Misiones ocultas y postgame

- [x] Definir el descubrimiento de misiones ocultas sin marcador [M]
- [x] Definir la activación por pistas del mundo (M22) [S]
- [x] Crear 4 cadenas de postgame [M]
- [x] Definir la variación del postgame según el final de M22 [M]
- [x] Crear la reconstrucción de la plaza post-final [S]
- [x] Crear el memorial del Sello post-final [S]
- [x] Crear el epílogo de la aldea [S]
- [x] Crear el epílogo del guardián (final secreto) [S]
- [x] Documentar misiones ocultas y postgame [S]

## Persistencia y validador

- [x] Definir el guardado por cadena (paso, completada, consecuencias) [M]
- [x] Implementar guardado atómico + `.bak` [M]
- [x] Implementar el validador de referencias (NPC/lugares/objetos reales) [M]
- [x] Implementar el validador de alcanzabilidad (M66) [M]
- [x] Implementar el validador de recompensas únicas [M]
- [x] Documentar la persistencia y el validador [S]

## Integración

- [x] Integrar con M68 (objetivos y evaluación) [M]
- [x] Integrar con M22 (hooks de consecuencia y postgame) [M]
- [x] Integrar con M32 (estacionales) [M]
- [x] Integrar con M36 (museo y colección) [M]
- [x] Integrar con M37 (comerciantes) [M]
- [x] Integrar con M66 (sin softlocks de cadena) [M]
- [x] Documentar la integración en el plan-actual [M]

## Testings y documentación

- [x] Diseñar test de validador de cadenas (contexto/referencias) [M]
- [x] Diseñar test E2E de 10 cadenas completas [M]
- [x] Diseñar test de consecuencias aplicadas y persistidas [M]
- [x] Diseñar test de recompensas únicas [M]
- [x] Diseñar test de postgame tras cada final (4 variaciones) [M]
- [x] Diseñar 06-Plan-Testings.md (unitarias + integración) [M]
- [x] Crear 07-Resultados-Testings.md [S]
- [x] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [x] Actualizar plan-actual como espejo del estado real [M]
- [x] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S]
- [x] Actualizar fila 23 en CHECKLIST-GLOBAL al implementar [S]

**Total:** 100/100 [x] — Módulo listo como **DELEGABLE PARA IMPLEMENTAR**.