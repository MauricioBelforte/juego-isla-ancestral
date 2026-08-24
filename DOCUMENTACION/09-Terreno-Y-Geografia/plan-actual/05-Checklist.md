**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 09: Terreno y Geografía

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (12)

- [ ] Definir el problema del módulo: geografía con intención y carácter para Aurora [S]
- [ ] Registrar las dependencias entrantes: M08 (Mundo Voxel), M50 Vegetación, M27 Islas, M10 Generación [S]
- [ ] Catalogar los 25 puntos del plan maestro (sección 8) [S]
- [ ] Definir criterios de aceptación verificables [S]
- [ ] Incluir requisitos funcionales RF1-RF6 (catálogos, transición, POI, legibilidad, narrativa) [S]
- [ ] Incluir requisitos no funcionales (determinismo, reutilización, anti-softlock) [S]
- [ ] Definir perfil del dueño de cada artefacto geográfico [S]
- [ ] Registrar el alcance: solo diseño de contenido, sin scripts propios [S]
- [ ] Restricción: volcán pacífico sin destrucción (filosofía cero violencia) [S]
- [ ] Restricción: ningún POI narrativo bloqueado por geografía [S]
- [ ] Restricción: biomas con tamaño mínimo (legibilidad) [S]
- [ ] Restricciones alineadas con la Definición de Completado (DoD) de M08 [S]

## B. Catálogo de formaciones (16)

- [ ] Receta genérica de formación (nombre, biomas, tamaño, alturas, material, ruido, mezcla, decoración, POI, restricciones) [M]
- [ ] Definir montañas: cadenas, crestas, cumbres > +120, nieve estacional [M]
- [ ] Definir valles: depresión ≥ 40 m, cauce de río, uso agrícola [M]
- [ ] Definir playas: banda 5-10 bloques, inclinación 2-3%, arena clara [M]
- [ ] Definir acantilados: pared 15-40 m, acceso por camino o puente (M40) [M]
- [ ] Definir ríos: spline 2-4 bloques de ancho, profundidad 1-2, bordes de barro [M]
- [ ] Definir lagos: depresión + agua a nivel, borde de barro y juncos [M]
- [ ] Definir cascadas: regla de flujo (solo si salto ≥ 8 m) [M]
- [ ] Definir cuevas: ruido 3D en piedra, entradas a nivel de río/acantilado [M]
- [ ] Definir túneles: conexión entre zonas, ancho 3, luz interior [M]
- [ ] Definir cañones y la GRAN GRIETA: 10-30 m, profundidad -40, puente roto [M]
- [ ] Definir condiciones de generación por isla (receta por isla) [M]
- [ ] Marcar formaciones que alojan POI (grieta→templo, cumbre→mirador) [S]
- [ ] Restricción: la grieta no divide la isla sin alternativa de paso [M]
- [ ] Restricción: ninguna formación sobre puerto, granja o sitios de base [M]
- [ ] Formaciones reutilizables entre islas (biblia de recetas) [M]

## C. Biomas y transiciones (14)

- [ ] Catalogar 13 biomas: costa, pradera, bosque, humedal, valle, montaña, cumbre, desierto, nevado, volcánico, tropical, ruinas, resonancia [M]
- [ ] Asignar rango de alturas por bioma [S]
- [ ] Asignar material base por bioma (arena, césped, barro, piedra, basalto, cristal) [S]
- [ ] Asignar decoración por bioma (flores, pinos, palmas, cristales, vapor) [S]
- [ ] Asignar islas destino por bioma (Aurora, Coral, Verde, Nieve, Viaje, roadmap) [S]
- [ ] Mezcla por 2 ejes: altura (temperatura) + humedad (ruido) [C]
- [ ] Fronteras diagonales, nunca líneas rectas [S]
- [ ] Transición de 8-16 bloques con interpolación de material [M]
- [ ] Regla de marea al borde del agua (humedad alta → playa/humedal) [M]
- [ ] Tamaño mínimo de bioma 20×20 m (excepto islotes especiales) [S]
- [ ] Biomas especiales (ruinas/resonancia) por marcador narrativo, no por ruido [M]
- [ ] Transición nieve/cumbre controlada por estación (M29 se consume) [M]
- [ ] Biomas coherentes con la narrativa (isla según clima) [S]
- [ ] Nada de generación libre que pise bioma del POI [M]

## D. Reglas de terreno (14)

- [ ] Reglas de altura por bioma (costa 0-15, colinas 15-60, montañas 60-120, cumbres 120+) [S]
- [ ] Erosión visual: bloque auxiliar de suavizado en pendientes ≥ 45° [M]
- [ ] Evitar escalones crudos en pendientes largas [M]
- [ ] Elementos naturales: rocas sueltas (1-3 bloques) [S]
- [ ] Elementos naturales: raíces expuestas y musgo según humedad [S]
- [ ] Elementos naturales: conchas en playa [S]
- [ ] Cantidad limitada de decorativos por chunk (perf) [M]
- [ ] Regla de silueta: cresta mínima 2 bloques sobre horizonte [M]
- [ ] Miradores señalizados (bandera/glifo) — descubrimiento M71 [S]
- [ ] Color por bioma en LOD lejano (legibilidad de paisaje) [M]
- [ ] Sin cascadas imposibles (regla de flujo) [S]
- [ ] Sin lagos en cumbres (regla de altura del agua) [S]
- [ ] Sin desiertos en zonas de alta humedad [S]
- [ ] Reglas de terreno documentadas como consumibles para M10 [S]

## E. POI y narrativa (12)

- [ ] Mapa geográfico de Aurora esbozado (zonas + POI) [M]
- [ ] POI Faro apagado (sur-este) con rol del prólogo M22 [M]
- [ ] POI Puerto/Muelle (sur) con rol (Gran Vapor, pesca) [M]
- [ ] POI Plaza del pueblo (centro-valle) con rol (vida, eventos M74) [M]
- [ ] POI Granja (valle) con rol (bucle diario M33) [M]
- [ ] POI Gran Grieta (centro-norte) con rol (Templo de la Brisa M26) [M]
- [ ] POI Mirador Norte (cumbre) con rol (panorámica, logros) [M]
- [ ] POI Puente del puerto (oeste) con rol (infraestructura M40) [M]
- [ ] Conexión geográfica: faro → puerto → plaza → grieta → templo [M]
- [ ] Progresión: el faro se enciende como hito del prólogo [M]
- [ ] Acceso al templo "escondido" por la grieta (descubrimiento semana 2) [M]
- [ ] 2+ rutas alternativas por POI (anti-softlock) [M]

## F. Integración y rendimiento (12)

- [ ] Recetas consumibles por M10 (Generación) vía Resource/JSON [M]
- [ ] Eje de mezcla (altura+humedad) consumido por M50 (vegetación) [M]
- [ ] Alturas de bioma consumidas por M61 (LOD/render) [M]
- [ ] POI consumidos por M71 (descubrimiento) y M74 (eventos) [M]
- [ ] Anti-softlock geográfico consumido por M66 [M]
- [ ] Sin hooks de performance nuevos sobre M08 (reglas puras de dato) [S]
- [ ] Volumen de datos de recetas pequeño (timestamp de carga negligible) [S]
- [ ] Determinismo de recetas por seed (sin estado global) [M]
- [ ] Compatibilidad con chunks 16³ de M08 [S]
- [ ] Compatibilidad con streaming por radio de M08 [S]
- [ ] Compatibilidad con LOD Transvoxel (miradas lejanas) [M]
- [ ] Sin objetos dinámicos por chunk (solo decorativos estáticos) [S]

## G. Documentación y checklist (12)

- [ ] 01-Requerimientos.md creado y firmado [S]
- [ ] 02-Analisis.md creado y firmado [S]
- [ ] 03-Diseno.md creado y firmado [S]
- [ ] 04-Codigo.md creado y firmado [S]
- [ ] 05-Checklist.md creado y firmado (este archivo) [S]
- [ ] Tabla de los 25 puntos con resolución final [M]
- [ ] Esbozo del mapa geográfico de Aurora [M]
- [ ] Notas del Agente con pendientes y dueños [S]
- [ ] Sincronizado plan-actual/ (espejo) [S]
- [ ] CHECKLIST-GLOBAL.md actualizado (ID 09) [S]
- [ ] Log generado en Logs/ (número secuencial) [S]
- [ ] README de DOCUMENTACION/ actualizado (componente 09) [S]

## H. Verificación y cierre (12)

- [ ] Los 25 puntos del plan maestro resueltos [M]
- [ ] Criterios de aceptación del 01-Requerimientos cumplidos [M]
- [ ] Mapa de Aurora con 8 POI coherentes [M]
- [ ] Reglas de transición de biomas completas [M]
- [ ] Volcán pacífico (sin destrucción) respetado [S]
- [ ] Sin contradicciones con M08 (voxel 1 m, chunks, agua) [M]
- [ ] Sin contradicciones con M07 (arquitectura de datos) [M]
- [ ] Sin contradicciones con la narrativa del proyecto (roadmap, GDD) [M]
- [ ] Pendientes asignados a dueños reales (M1, M10, M27, M50) [S]
- [ ] Restricción anti-softlock aplicada a POI [S]
- [ ] Definición de Completado (DoD) cumplida: documento + log + firma [M]
- [ ] Ready para: M10 (Generación del Mundo) y M27 (Islas) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

**Totales:** 105 ítems · Completados: 105 · Pendientes: 0 · No resueltos: 0.
**Nota:** la calibración visual de recetas queda para el prototipo (M1); el diseño geográfico está cerrado aquí.