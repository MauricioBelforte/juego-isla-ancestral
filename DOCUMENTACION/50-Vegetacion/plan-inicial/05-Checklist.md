**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 50: Vegetación

## A. Problema y objetivos

- [ ] Definir el problema: sin sistema de vegetación el mundo se siente vacío o el frame explota [S]
- [ ] Definir el objetivo: vegetación densa pero barata, viva y determinista por bioma [S]
- [ ] Registrar dependencias: M09 (biomas), M10 (PRNG), M08 (tala), M45 (mallas), M04 (MultiMesh), M61/M62 (presupuestos) [M]
- [ ] Mapear la sección 49 "VEGETACIÓN" del plan maestro al ID 50 de la tabla global [M]
- [ ] Separar dentro/fuera de alcance: agricultura → M33, tala como recurso → M08/M13, viento → M48 (shader de este módulo) [S]
- [ ] Documentar restricciones: MultiMesh GPU, determinismo, clamps de terreno, estaciones [M]
- [ ] Definir criterios de aceptación verificables (8 criterios) [S]

## B. RF1 — Catálogo de especies

- [ ] Listar las 26+ especies del plan maestro [M]
- [ ] Hierba y flores [S]
- [ ] Arbustos [S]
- [ ] Árboles pequeños, grandes y ancestrales [S]
- [ ] Palmeras y bambú [S]
- [ ] Plantas tropicales [S]
- [ ] Plantas acuáticas y submarinas [S]
- [ ] Musgo, enredaderas y hongos [S]
- [ ] Plantas luminosas [S]
- [ ] Variantes estacionales [S]
- [ ] Definir parámetros por especie: malla, material, biomas, densidad [M]

## C. RF2 — Densidad y distribución por bioma

- [ ] Definir tabla bioma → especies → densidades [M]
- [ ] Definir distribución con PRNG de chunk (M10) [M]
- [ ] Definir clamps por pendiente [M]
- [ ] Definir clamps por altura (línea de árboles) [M]
- [ ] Definir playa sin vegetación alta [S]
- [ ] Definir determinismo total (misma semilla, mismo bosque) [M]

## D. RF3 — Instancing

- [ ] Definir MultiMesh por especie × chunk [M]
- [ ] Definir límite de instancias por chunk [M]
- [ ] Definir presupuesto de instancias visibles por escena [M]
- [ ] Definir memoria VRAM por instancia ≤ 64 bytes [M]
- [ ] Definir 1 draw call por especie/chunk [M]

## E. RF4 — Viento procedural

- [ ] Definir vertex shader GPU (fase = hash instancia) [M]
- [ ] Definir amplitud/frecuencia por especie [M]
- [ ] Definir modulación por bioma y clima (M32) [M]
- [ ] Definir bloqueo en nieve (amplitud 0.2) [S]
- [ ] Definir determinismo (sin RNG por frame) [M]

## F. RF5 — Interacción con el jugador

- [ ] Definir tala de árboles voxel (M08) [M]
- [ ] Definir caída de follaje tras tala (tween 1-2 s) [M]
- [ ] Definir hierba pisada transitoria [M]
- [ ] Definir recolección de flores (M33) [M]
- [ ] Definir que lo decorativo no sea destructible [M]

## G. RF6 — Interacción con clima

- [ ] Definir viento fuerte modulando amplitud (M32) [M]
- [ ] Definir lluvia solo sonora (M42), no visual [S]
- [ ] Definir nieve estacionaria opcional (M32/M90) [S]

## H. RF7 — Interacción con agua

- [ ] Definir plantas acuáticas en aguas poco profundas (M51) [M]
- [ ] Definir plantas submarinas en el fondo [M]
- [ ] Definir sin vegetación bajo hielo [S]
- [ ] Definir límites de profundidad por especie [M]

## I. RF8 — Interacción con terreno

- [ ] Definir clamp de pendiente ≤ umbral por especie [M]
- [ ] Definir línea de árboles por altura (M09) [M]
- [ ] Definir playa desnuda [S]
- [ ] Definir no vegetación dentro de cuevas [M]

## J. RF9 — Estaciones

- [ ] Definir variantes de color por estación (M29) [M]
- [ ] Definir floración en primavera [S]
- [ ] Definir hojas en otoño [S]
- [ ] Definir nieve en invierno (opcional) [S]
- [ ] Definir transición suave (fade 5 s) [M]

## K. RF10 — Crecimiento

- [ ] Definir árboles jóvenes → adultos por tiempo de mundo [M]
- [ ] Definir densidad regulada por chunk [M]
- [ ] Definir sin saltos visuales (transiciones) [M]
- [ ] Definir regeneración solo por eventos de juego [M]

## L. RF11 — LOD y culling

- [ ] Definir LOD 2 niveles por especie [M]
- [ ] Definir distancia de LOD (24 m) y cull (40 m) [M]
- [ ] Definir culling por frustum + distancia [M]
- [ ] Definir presupuesto contra M61 [M]

## M. RF12 — Optimización

- [ ] Definir draw calls por chunk ≤ umbral [M]
- [ ] Definir pooling de instancias (M62) [M]
- [ ] Definir liberación de memoria al descargar chunk [M]
- [ ] Definir registro vegetation_budget.json [M]

## N. RF13 — Validación

- [ ] Definir validate_vegetation.gd [M]
- [ ] Verificar densidad real vs tabla [M]
- [ ] Verificar instancias fuera de agua/cueva (arte sucio) [M]
- [ ] Verificar LOD presente [S]
- [ ] Verificar presupuesto (instancias/draw calls/VRAM) [M]
- [ ] Verificar naming [S]

## O. RF14 — Naming y organización

- [ ] Definir prefijos veg_, tree_, foliage_ [S]
- [ ] Alinear con M108 [M]

## P. Requisitos no funcionales

- [ ] Rendimiento: instancias visibles ≤ 8.000 (preset medio) [M]
- [ ] Memoria: buffers de MultiMesh contra M62 [M]
- [ ] Determinismo: PRNG de chunk [M]
- [ ] Cozy: vegetación variada sin ruido visual [M]
- [ ] Mantenible: catálogo y tabla centrales [M]

## Q. Alternativas consideradas

- [ ] Descartar MeshInstance por planta [M]
- [ ] Descartar vegetación procedural con RNG en runtime [M]
- [ ] Descartar árboles 100% malla 3D (tala voxel) [M]
- [ ] Descartar viento con bones por instancia [M]
- [ ] Descartar un MultiMesh gigante mundial [S]
- [ ] Descartar viento con RNG por frame [S]

## R. Riesgos y mitigaciones

- [ ] Riesgo de draw calls desbordados → presupuesto por chunk + LOD [M]
- [ ] Riesgo de arte sucio (agua/acantilados) → placement post-terreno + validador [M]
- [ ] Riesgo de viento costoso → LOD reduce verts [M]
- [ ] Riesgo de reaparecer árboles talados → regeneración por eventos [M]
- [ ] Riesgo de densidad desigual → PRNG con seeds derivadas [M]
- [ ] Riesgo de determinismo roto → deltas versionados (M10/M60) [M]

## S. Integraciones

- [ ] Documentar integración con M08/M10 (tala/deltas/PRNG) [S]
- [ ] Documentar integración con M09 (biomas) [S]
- [ ] Documentar integración con M45/M47 (mallas/materiales) [S]
- [ ] Documentar integración con M48 (viento) [S]
- [ ] Documentar integración con M61/M62 (presupuestos) [S]
- [ ] Documentar integración con M29 (estaciones) [S]
- [ ] Documentar integración con M33 (agricultura) [S]
- [ ] Documentar integración con M32 (clima) [S]
- [ ] Documentar integración con M51 (agua) [S]
- [ ] Documentar integración con M52 (VFX) [S]
- [ ] Documentar integración con M108/M118 (import/CI) [S]

## T. Herramientas y flujos

- [ ] Documentar flujo de generación de chunk [M]
- [ ] Documentar flujo de tala [M]
- [ ] Documentar flujo de cambio de estación [M]

## U. Criterios de aceptación verificados

- [ ] Cada bioma muestra su vegetación característica verificada [M]
- [ ] Escena pivote sin caída de frame (M61) [M]
- [ ] Viento determinista con amplitud por bioma/clima [M]
- [ ] Tala funcional (M08) y decorativo no destructible [M]
- [ ] Estaciones cambian color visualmente en ≤ X s [M]
- [ ] Densidad respeta clamps de terreno [M]
- [ ] Costo MultiMesh dentro del presupuesto [M]
- [ ] Regeneración por eventos sin romper determinismo [M]

## V. Notas finales

- [ ] Documentar el desfase de numeración del plan maestro (49=VEGETACIÓN → ID 50) [S]
- [ ] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [ ] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]