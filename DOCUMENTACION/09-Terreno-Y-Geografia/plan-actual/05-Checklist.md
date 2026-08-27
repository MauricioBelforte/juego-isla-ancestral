**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 09: Terreno y Geografía

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.

## A. Requisitos del módulo (12)

- [x] Definir el problema del módulo: geografía con intención y carácter para Aurora [S]
- [x] Registrar las dependencias entrantes: M08 (Mundo Voxel), M50 Vegetación, M27 Islas, M10 Generación [S]
- [x] Catalogar los 25 puntos del plan maestro (sección 8) [S]
- [x] Definir criterios de aceptación verificables [S]
- [x] Incluir requisitos funcionales RF1-RF6 (catálogos, transición, POI, legibilidad, narrativa) [S]
- [x] Incluir requisitos no funcionales (determinismo, reutilización, anti-softlock) [S]
- [x] Definir perfil del dueño de cada artefacto geográfico [S]
- [x] Registrar el alcance: solo diseño de contenido, sin scripts propios [S]
- [x] Restricción: volcán pacífico sin destrucción (filosofía cero violencia) [S]
- [x] Restricción: ningún POI narrativo bloqueado por geografía [S]
- [x] Restricción: biomas con tamaño mínimo (legibilidad) [S]
- [x] Restricciones alineadas con la Definición de Completado (DoD) de M08 [S]

## B. Catálogo de formaciones (16)

- [x] Receta genérica de formación (nombre, biomas, tamaño, alturas, material, ruido, mezcla, decoración, POI, restricciones) [M]
- [x] Definir montañas: cadenas, crestas, cumbres > +120, nieve estacional [M]
- [x] Definir valles: depresión ≥ 40 m, cauce de río, uso agrícola [M]
- [x] Definir playas: banda 5-10 bloques, inclinación 2-3%, arena clara [M]
- [x] Definir acantilados: pared 15-40 m, acceso por camino o puente (M40) [M]
- [x] Definir ríos: spline 2-4 bloques de ancho, profundidad 1-2, bordes de barro [M]
- [x] Definir lagos: depresión + agua a nivel, borde de barro y juncos [M]
- [x] Definir cascadas: regla de flujo (solo si salto ≥ 8 m) [M]
- [x] Definir cuevas: ruido 3D en piedra, entradas a nivel de río/acantilado [M]
- [x] Definir túneles: conexión entre zonas, ancho 3, luz interior [M]
- [x] Definir cañones y la GRAN GRIETA: 10-30 m, profundidad -40, puente roto [M]
- [x] Definir condiciones de generación por isla (receta por isla) [M]
- [x] Marcar formaciones que alojan POI (grieta→templo, cumbre→mirador) [S]
- [x] Restricción: la grieta no divide la isla sin alternativa de paso [M]
- [x] Restricción: ninguna formación sobre puerto, granja o sitios de base [M]
- [x] Formaciones reutilizables entre islas (biblia de recetas) [M]

## C. Biomas y transiciones (14)

- [x] Catalogar 13 biomas: costa, pradera, bosque, humedal, valle, montaña, cumbre, desierto, nevado, volcánico, tropical, ruinas, resonancia [M]
- [x] Asignar rango de alturas por bioma [S]
- [x] Asignar material base por bioma (arena, césped, barro, piedra, basalto, cristal) [S]
- [x] Asignar decoración por bioma (flores, pinos, palmas, cristales, vapor) [S]
- [x] Asignar islas destino por bioma (Aurora, Coral, Verde, Nieve, Viaje, roadmap) [S]
- [x] Mezcla por 2 ejes: altura (temperatura) + humedad (ruido) [C]
- [x] Fronteras diagonales, nunca líneas rectas [S]
- [x] Transición de 8-16 bloques con interpolación de material [M]
- [x] Regla de marea al borde del agua (humedad alta → playa/humedal) [M]
- [x] Tamaño mínimo de bioma 20×20 m (excepto islotes especiales) [S]
- [x] Biomas especiales (ruinas/resonancia) por marcador narrativo, no por ruido [M]
- [x] Transición nieve/cumbre controlada por estación (M29 se consume) [M]
- [x] Biomas coherentes con la narrativa (isla según clima) [S]
- [x] Nada de generación libre que pise bioma del POI [M]

## D. Reglas de terreno (14)

- [x] Reglas de altura por bioma (costa 0-15, colinas 15-60, montañas 60-120, cumbres 120+) [S]
- [x] Erosión visual: bloque auxiliar de suavizado en pendientes ≥ 45° [M]
- [x] Evitar escalones crudos en pendientes largas [M]
- [x] Elementos naturales: rocas sueltas (1-3 bloques) [S]
- [x] Elementos naturales: raíces expuestas y musgo según humedad [S]
- [x] Elementos naturales: conchas en playa [S]
- [x] Cantidad limitada de decorativos por chunk (perf) [M]
- [x] Regla de silueta: cresta mínima 2 bloques sobre horizonte [M]
- [x] Miradores señalizados (bandera/glifo) — descubrimiento M71 [S]
- [x] Color por bioma en LOD lejano (legibilidad de paisaje) [M]
- [x] Sin cascadas imposibles (regla de flujo) [S]
- [x] Sin lagos en cumbres (regla de altura del agua) [S]
- [x] Sin desiertos en zonas de alta humedad [S]
- [x] Reglas de terreno documentadas como consumibles para M10 [S]

## E. POI y narrativa (12)

- [x] Mapa geográfico de Aurora esbozado (zonas + POI) [M]
- [x] POI Faro apagado (sur-este) con rol del prólogo M22 [M]
- [x] POI Puerto/Muelle (sur) con rol (Gran Vapor, pesca) [M]
- [x] POI Plaza del pueblo (centro-valle) con rol (vida, eventos M74) [M]
- [x] POI Granja (valle) con rol (bucle diario M33) [M]
- [x] POI Gran Grieta (centro-norte) con rol (Templo de la Brisa M26) [M]
- [x] POI Mirador Norte (cumbre) con rol (panorámica, logros) [M]
- [x] POI Puente del puerto (oeste) con rol (infraestructura M40) [M]
- [x] Conexión geográfica: faro → puerto → plaza → grieta → templo [M]
- [x] Progresión: el faro se enciende como hito del prólogo [M]
- [x] Acceso al templo "escondido" por la grieta (descubrimiento semana 2) [M]
- [x] 2+ rutas alternativas por POI (anti-softlock) [M]

## F. Integración y rendimiento (12)

- [x] Recetas consumibles por M10 (Generación) vía Resource/JSON [M]
- [x] Eje de mezcla (altura+humedad) consumido por M50 (vegetación) [M]
- [x] Alturas de bioma consumidas por M61 (LOD/render) [M]
- [x] POI consumidos por M71 (descubrimiento) y M74 (eventos) [M]
- [x] Anti-softlock geográfico consumido por M66 [M]
- [x] Sin hooks de performance nuevos sobre M08 (reglas puras de dato) [S]
- [x] Volumen de datos de recetas pequeño (timestamp de carga negligible) [S]
- [x] Determinismo de recetas por seed (sin estado global) [M]
- [x] Compatibilidad con chunks 16³ de M08 [S]
- [x] Compatibilidad con streaming por radio de M08 [S]
- [x] Compatibilidad con LOD Transvoxel (miradas lejanas) [M]
- [x] Sin objetos dinámicos por chunk (solo decorativos estáticos) [S]

## G. Documentación y checklist (12)

- [x] 01-Requerimientos.md creado y firmado [S]
- [x] 02-Analisis.md creado y firmado [S]
- [x] 03-Diseno.md creado y firmado [S]
- [x] 04-Codigo.md creado y firmado [S]
- [x] 05-Checklist.md creado y firmado (este archivo) [S]
- [x] Tabla de los 25 puntos con resolución final [M]
- [x] Esbozo del mapa geográfico de Aurora [M]
- [x] Notas del Agente con pendientes y dueños [S]
- [x] Sincronizado plan-actual/ (espejo) [S]
- [x] CHECKLIST-GLOBAL.md actualizado (ID 09) [S]
- [x] Log generado en Logs/ (número secuencial) [S]
- [x] README de DOCUMENTACION/ actualizado (componente 09) [S]

## H. Verificación y cierre (12)

- [x] Los 25 puntos del plan maestro resueltos [M]
- [x] Criterios de aceptación del 01-Requerimientos cumplidos [M]
- [x] Mapa de Aurora con 8 POI coherentes [M]
- [x] Reglas de transición de biomas completas [M]
- [x] Volcán pacífico (sin destrucción) respetado [S]
- [x] Sin contradicciones con M08 (voxel 1 m, chunks, agua) [M]
- [x] Sin contradicciones con M07 (arquitectura de datos) [M]
- [x] Sin contradicciones con la narrativa del proyecto (roadmap, GDD) [M]
- [x] Pendientes asignados a dueños reales (M1, M10, M27, M50) [S]
- [x] Restricción anti-softlock aplicada a POI [S]
- [x] Definición de Completado (DoD) cumplida: documento + log + firma [M]
- [x] Ready para: M10 (Generación del Mundo) y M27 (Islas) [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

**Totales:** 105 ítems · Completados: 105 · Pendientes: 0 · No resueltos: 0.
**Nota:** la calibración visual de recetas queda para el prototipo (M1); el diseño geográfico está cerrado aquí.
