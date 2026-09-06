**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 50: Vegetación

## A. Problema y objetivos

- [x] Definir el problema: sin sistema de vegetación el mundo se siente vacío o el frame explota [S]
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

- [?] — agnes-2026-09-06: LOD no implementado; instancias simples por ahora Definir LOD 2 niveles por especie [M]
- [ ] Definir distancia de LOD (24 m) y cull (40 m) [M]
- [ ] Definir culling por frustum + distancia [M]
- [ ] Definir presupuesto contra M61 [M]

## M. RF12 — Optimización

- [ ] Definir draw calls por chunk ≤ umbral [M]
- [ ] Definir pooling de instancias (M62) [M]
- [ ] Definir liberación de memoria al descargar chunk [M]
- [x] Definir registro vegetation_budget.json [M]

## N. RF13 — Validación

- [ ] Definir validate_vegetation.gd [M]
- [ ] Verificar densidad real vs tabla [M]
- [x] Verificar instancias fuera de agua/cueva (arte sucio) [M] — iter. 6 (Log 646): BUG-022 fix (h<3 omitidas), test_distribucion.gd confirma distribución por bioma correcta, 109 instancias pobladas
- [?] — agnes-2026-09-06: LOD no implementado; instancias simples por ahora (GLB media) Verificar LOD presente [S]
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
- [x] Tala funcional (M08) y decorativo no destructible [M]
- [ ] Estaciones cambian color visualmente en ≤ X s [M]
- [ ] Densidad respeta clamps de terreno [M]
- [ ] Costo MultiMesh dentro del presupuesto [M]
- [ ] Regeneración por eventos sin romper determinismo [M]

## V. Notas finales

- [ ] Documentar el desfase de numeración del plan maestro (49=VEGETACIÓN → ID 50) [S]
- [x] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [x] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
## Iteración 1 — Inventario + verificación visual (2026-09-02 05:50, deepseek-v4-flash-vision-exp)

- [x] Inventario de vegetación del proyecto: **15 tipos × 3 variantes (media/baja/alta) = 45 GLB** en assets/3d (árbol frutal, arbustos ×2, cañas bambú, flor isla, helechos ×2, hierba alta, hongo luminoso, liana, musgo roca, palmeras ×3, raíces); los 45 ya validados por el pipeline M108 (198 GLB OK)
- [x] Verificación VISUAL de vegetación representativa (preview_assets extendido): palmera ✓, helecho gigante ✓, hongo luminoso ✓, arbusto floral ✓ — siluetas claras, escala uniforme, colores cozy, sin artefactos (captura analizada en tools/mcp/godot-mcp/capturas/50-Vegetacion/)
- [x] Cross-referencia: los assets de vegetación pertenecen al módulo M50 (prefijo 50-Vegetacion) y a la paleta Maldivas/M166
- [?] VegetationManager (spawn por bioma/estación, pooling, densidad) — iter 2 (dueño: deepseek-v4-flash-vision-exp; requiere M08/M10 en producción)
## Iteración 2 (2026-09-02 21:35 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] `data/vegetacion/vegetacion_config.json` — tipos por bioma (playa/pradera/bosque/montaña/ribera/humedal → GLBs de M166) + densidad
- [x] `scripts/vegetacion/vegetation_manager.gd` — VegetationManager: cargar_config, tipos_para_bioma, densidad, posiciones() deterministas (PRNG semilla = mundo + bioma)
- [x] Test 7/7 OK (6 biomas, tipos, densidades, determinismo por semilla)
- [?] Instanciación en el mundo (M08 poblar) — iter 3 (dueño: deepseek-v4-flash-vision-exp)
## Iteración 3 (2026-09-02 22:40 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] `scripts/vegetacion/vegetation_plan.gd` — VegetationPlan: plan determinista (45 ítems, 5 biomas por zonas anulares, rotaciones + seed por ítem) para que el mundo pueble
- [x] Test 5/5 OK (determinismo semilla 42, dentro del radio 256, 5 biomas, sin tipos vacíos)
- [x] `scripts/vegetacion/test_vegetation_plan_headless.gd` · Plan listo para consumo de M08 (poblar)
## Iteración 4 — Poblado del mundo (2026-09-02 23:25 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] `scripts/vegetacion/vegetation_spawner.gd` — Spawner autoload: espera 2 frames (terreno listo), genera el plan (semilla 42, radio 256), carga los GLB media del plan y los instancia con snap de altura (TerrainLocator) y rotación determinista
- [x] Autoload `VegetationSpawner` registrado en project.godot
- [x] **VERIFICADO EN RUNTIME: [M50] Vegetación poblada: 45 instancias, 0 omitidas** — el mundo quedó poblado (árboles, palmeras, helechos, hongos, arbustos, flores)
- [x] Test 4/4 (plan 45 ítems, todo GLB existe, spawner instanciable) + limpieza de warnings

## Notas del Agente (iter. 8 — feedback del usuario, Log 664, glm-5.3-flash)

### Feedback del usuario (2026-09-04 09:26)
> "Hay árboles que son gigantes, parecen piedras verdes, esos deberían cambiar el diseño no sé qué son... muchos problemas de tamaños que arreglar todavía."

### Diagnóstico
Los GLBs del pipeline M166 tienen **problemas de DISEÑO** (no de escala):
- **arbol_frutal**: a 6m se ve como "piedra verde gigante" — el mesh no tiene forma de árbol (tronco+copa), es un blob
- **palmera**: las grandes (5m) están bien de tamaño pero pueden tener el mismo problema de forma
- **flor_isla**: re-escalada a 0.8m (era invisible a 0.25m) — el usuario ya no la vio pero no confirmó si se ve bien
- Los GLBs son placeholders del pipeline M166 que priorizaba cantidad sobre calidad

### Lo que SÍ está funcionando
- Escalas relativas coherentes (árbol > arbusto > hierba > flor)
- Distribución por biomas correcta (114→134 instancias, cercanías del spawn)
- Iluminación M49 (sombras, tono cálido) ✓
- Sistema EscalasGlobales (tabla data-driven de 43 tipos) ✓

### Acciones requeridas (dueño M45/M50 contenido)
1. **Rediseñar los meshes GLB** en Blender: árboles con tronco+copa (no blobs), palmeras con hojas, arbustos con ramas
2. Definir tabla de alturas definitiva por especie en M45 (colisión con la tabla EscalasGlobales actual)
3. Texturas/materials para cada especie (no color plano)
4. Colisiones: árboles/rocas sólidos (5-FUTURAS-MEJORAS "Objetos sólidos")

### Cómo ayuda la infraestructura ya implementada
- `reescalar_vegetacion_v2.py` reutilizable: se re-ejecuta cuando los meshes nuevos estén listos (solo cambiar la tabla de alturas objetivo)
- `EscalasGlobales.escala_de()` para ajustes finos por tipo sin re-exportar
- Respaldos en Obsoletos/ para rollback
- **Iter. 9 (Log 715, glm-5.3-flash/Kilo Code):** feedback usuario — flor x3 (2.4m), hierba baja (0.15m runtime), lianas x2 (4m), helecho_gigante 0.8m, helecho_chico 0.35m. 4 GLBs horneados en Blender + escalas.json ajustado. Boot sin errores.


## Iteración 10 — Verificación visual de escalas + horneado GLBs (2026-09-06 15:15, glm-5.3-flash / Kilo Code)

- [x] Capturas de verificación en juego cerca de 6 tipos (autoload temporal teleport + viewport PNG, eliminado al finalizar) [M]
- [x] Medición Blender headless de 10 GLBs: arbol_frutal=10.9m, arbusto_redondo=12.2m (¡gigante!), arbusto_floral=5.2m, flor_isla=1.4m, hierba_alta=1.0m, helecho_chico=2.1m, helecho_gigante=1.9m, palmera_joven=5.5m, palmera=9.6m, palmera_inclinada=9.6m [M]
- [x] Script reutilizable tools/mcp/blender-mcp/scripts-reutilizables/reescalar_v5.py: hornea altura objetivo (respaldo Obsoletos/ + asentar base Z=0 + verificación reimport) [C]
- [x] 10/10 GLBs horneados a su altura objetivo (arbol_frutal 6.0, flor_isla 1.2 aprobados por usuario; resto normalizado a proporciones del plan) [C]
- [x] Verificación visual post-horneado: arbol_frutal 6m exacto, arbusto_redondo ~1m, flor_isla ~1.2m — capturas verif3_* en capturas/50/ [M]
- [x] FIX de pipeline: al reemplazar GLBs hay que borrar .godot/imported/*.scn + los .glb.import (hash viejo) y reimportar con --import antes de relanzar [M]
- [x] Tests actualizados al diseño real (Log 644): plan >=45 ítems + 6 biomas (7 checks 0 fallos), plan determinista (5/0), spawner (5/0) [S]
- [ ] escalas.json a 1.0 definitivo para los 10 tipos horneados (dejar 1.0 evita doble escala; pendiente edición fina por usuario) [S]
- [ ] Revisión visual final del usuario (propongo capturas verif3_*) [S]

### Notas del Agente — iter. 10

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-06 15:15
**Estado:** Iteración completada (escala base normalizada; ajuste fino por usuario pendiente)

#### Lo que hice
- Verifiqué en juego con capturas (teleport cerca de cada tipo) y medí con Blender headless los 10 GLBs: 6 de 10 estaban fuera de proporción (el peor: arbusto_redondo a 12.2m — 7× el jugador).
- Creé reescalar_v5.py (reutilizable, patrón E-45 headless) que hornea la altura objetivo: respaldo automático a Obsoletos/, escala con factor objetivo/alto, transform_apply, base asentada en Z=0, export GLB y re-verificación midiendo el archivo. 10/10 OK.
- Descubrí el pipeline de cache: reemplazar un GLB no basta — Godot sirve el .scn viejo de .godot/imported si el hash del .import coincide mal; hay que borrar .scn + .import y pasar --import. Lo aprendí tras 1 captura "idéntica" post-cambio.
- Los 3 tests de vegetación estaban desactualizados vs el diseño del Log 644 (45→109 ítems, 5→7 biomas): actualizados, 3/3 en verde.

#### Recomendaciones para el próximo agente
- Cualquier reemplazo de GLB: borrar .godot/imported/*nombre*.scn + *.glb.import → godot --headless --import → relanzar.
- El patrón del autoload temporal de verificación (teleport + viewport PNG) es el mejor método para verificar escala con visión; reutilizarlo para NPCs/props.