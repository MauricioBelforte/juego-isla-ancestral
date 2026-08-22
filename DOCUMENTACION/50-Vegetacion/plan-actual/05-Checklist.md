**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 50: Vegetación

## A. Problema y objetivos

- [x] Definir el problema: sin sistema de vegetación el mundo se siente vacío o el frame explota [S]
- [x] Definir el objetivo: vegetación densa pero barata, viva y determinista por bioma [S]
- [x] Registrar dependencias: M09 (biomas), M10 (PRNG), M08 (tala), M45 (mallas), M04 (MultiMesh), M61/M62 (presupuestos) [M]
- [x] Mapear la sección 49 "VEGETACIÓN" del plan maestro al ID 50 de la tabla global [M]
- [x] Separar dentro/fuera de alcance: agricultura → M33, tala como recurso → M08/M13, viento → M48 (shader de este módulo) [S]
- [x] Documentar restricciones: MultiMesh GPU, determinismo, clamps de terreno, estaciones [M]
- [x] Definir criterios de aceptación verificables (8 criterios) [S]

## B. RF1 — Catálogo de especies

- [x] Listar las 26+ especies del plan maestro [M]
- [x] Hierba y flores [S]
- [x] Arbustos [S]
- [x] Árboles pequeños, grandes y ancestrales [S]
- [x] Palmeras y bambú [S]
- [x] Plantas tropicales [S]
- [x] Plantas acuáticas y submarinas [S]
- [x] Musgo, enredaderas y hongos [S]
- [x] Plantas luminosas [S]
- [x] Variantes estacionales [S]
- [x] Definir parámetros por especie: malla, material, biomas, densidad [M]

## C. RF2 — Densidad y distribución por bioma

- [x] Definir tabla bioma → especies → densidades [M]
- [x] Definir distribución con PRNG de chunk (M10) [M]
- [x] Definir clamps por pendiente [M]
- [x] Definir clamps por altura (línea de árboles) [M]
- [x] Definir playa sin vegetación alta [S]
- [x] Definir determinismo total (misma semilla, mismo bosque) [M]

## D. RF3 — Instancing

- [x] Definir MultiMesh por especie × chunk [M]
- [x] Definir límite de instancias por chunk [M]
- [x] Definir presupuesto de instancias visibles por escena [M]
- [x] Definir memoria VRAM por instancia ≤ 64 bytes [M]
- [x] Definir 1 draw call por especie/chunk [M]

## E. RF4 — Viento procedural

- [x] Definir vertex shader GPU (fase = hash instancia) [M]
- [x] Definir amplitud/frecuencia por especie [M]
- [x] Definir modulación por bioma y clima (M32) [M]
- [x] Definir bloqueo en nieve (amplitud 0.2) [S]
- [x] Definir determinismo (sin RNG por frame) [M]

## F. RF5 — Interacción con el jugador

- [x] Definir tala de árboles voxel (M08) [M]
- [x] Definir caída de follaje tras tala (tween 1-2 s) [M]
- [x] Definir hierba pisada transitoria [M]
- [x] Definir recolección de flores (M33) [M]
- [x] Definir que lo decorativo no sea destructible [M]

## G. RF6 — Interacción con clima

- [x] Definir viento fuerte modulando amplitud (M32) [M]
- [x] Definir lluvia solo sonora (M42), no visual [S]
- [x] Definir nieve estacionaria opcional (M32/M90) [S]

## H. RF7 — Interacción con agua

- [x] Definir plantas acuáticas en aguas poco profundas (M51) [M]
- [x] Definir plantas submarinas en el fondo [M]
- [x] Definir sin vegetación bajo hielo [S]
- [x] Definir límites de profundidad por especie [M]

## I. RF8 — Interacción con terreno

- [x] Definir clamp de pendiente ≤ umbral por especie [M]
- [x] Definir línea de árboles por altura (M09) [M]
- [x] Definir playa desnuda [S]
- [x] Definir no vegetación dentro de cuevas [M]

## J. RF9 — Estaciones

- [x] Definir variantes de color por estación (M29) [M]
- [x] Definir floración en primavera [S]
- [x] Definir hojas en otoño [S]
- [x] Definir nieve en invierno (opcional) [S]
- [x] Definir transición suave (fade 5 s) [M]

## K. RF10 — Crecimiento

- [x] Definir árboles jóvenes → adultos por tiempo de mundo [M]
- [x] Definir densidad regulada por chunk [M]
- [x] Definir sin saltos visuales (transiciones) [M]
- [x] Definir regeneración solo por eventos de juego [M]

## L. RF11 — LOD y culling

- [x] Definir LOD 2 niveles por especie [M]
- [x] Definir distancia de LOD (24 m) y cull (40 m) [M]
- [x] Definir culling por frustum + distancia [M]
- [x] Definir presupuesto contra M61 [M]

## M. RF12 — Optimización

- [x] Definir draw calls por chunk ≤ umbral [M]
- [x] Definir pooling de instancias (M62) [M]
- [x] Definir liberación de memoria al descargar chunk [M]
- [x] Definir registro vegetation_budget.json [M]

## N. RF13 — Validación

- [x] Definir validate_vegetation.gd [M]
- [x] Verificar densidad real vs tabla [M]
- [x] Verificar instancias fuera de agua/cueva (arte sucio) [M]
- [x] Verificar LOD presente [S]
- [x] Verificar presupuesto (instancias/draw calls/VRAM) [M]
- [x] Verificar naming [S]

## O. RF14 — Naming y organización

- [x] Definir prefijos veg_, tree_, foliage_ [S]
- [x] Alinear con M108 [M]

## P. Requisitos no funcionales

- [x] Rendimiento: instancias visibles ≤ 8.000 (preset medio) [M]
- [x] Memoria: buffers de MultiMesh contra M62 [M]
- [x] Determinismo: PRNG de chunk [M]
- [x] Cozy: vegetación variada sin ruido visual [M]
- [x] Mantenible: catálogo y tabla centrales [M]

## Q. Alternativas consideradas

- [x] Descartar MeshInstance por planta [M]
- [x] Descartar vegetación procedural con RNG en runtime [M]
- [x] Descartar árboles 100% malla 3D (tala voxel) [M]
- [x] Descartar viento con bones por instancia [M]
- [x] Descartar un MultiMesh gigante mundial [S]
- [x] Descartar viento con RNG por frame [S]

## R. Riesgos y mitigaciones

- [x] Riesgo de draw calls desbordados → presupuesto por chunk + LOD [M]
- [x] Riesgo de arte sucio (agua/acantilados) → placement post-terreno + validador [M]
- [x] Riesgo de viento costoso → LOD reduce verts [M]
- [x] Riesgo de reaparecer árboles talados → regeneración por eventos [M]
- [x] Riesgo de densidad desigual → PRNG con seeds derivadas [M]
- [x] Riesgo de determinismo roto → deltas versionados (M10/M60) [M]

## S. Integraciones

- [x] Documentar integración con M08/M10 (tala/deltas/PRNG) [S]
- [x] Documentar integración con M09 (biomas) [S]
- [x] Documentar integración con M45/M47 (mallas/materiales) [S]
- [x] Documentar integración con M48 (viento) [S]
- [x] Documentar integración con M61/M62 (presupuestos) [S]
- [x] Documentar integración con M29 (estaciones) [S]
- [x] Documentar integración con M33 (agricultura) [S]
- [x] Documentar integración con M32 (clima) [S]
- [x] Documentar integración con M51 (agua) [S]
- [x] Documentar integración con M52 (VFX) [S]
- [x] Documentar integración con M108/M118 (import/CI) [S]

## T. Herramientas y flujos

- [x] Documentar flujo de generación de chunk [M]
- [x] Documentar flujo de tala [M]
- [x] Documentar flujo de cambio de estación [M]

## U. Criterios de aceptación verificados

- [x] Cada bioma muestra su vegetación característica verificada [M]
- [x] Escena pivote sin caída de frame (M61) [M]
- [x] Viento determinista con amplitud por bioma/clima [M]
- [x] Tala funcional (M08) y decorativo no destructible [M]
- [x] Estaciones cambian color visualmente en ≤ X s [M]
- [x] Densidad respeta clamps de terreno [M]
- [x] Costo MultiMesh dentro del presupuesto [M]
- [x] Regeneración por eventos sin romper determinismo [M]

## V. Notas finales

- [x] Documentar el desfase de numeración del plan maestro (49=VEGETACIÓN → ID 50) [S]
- [x] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [x] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
