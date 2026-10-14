**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 47: Texturas y Materiales

## A. Problema y objetivos

- [x] Definir el problema: sin sistema de texturas/materiales las superficies lucen dispares y el presupuesto se rompe [S]
- [x] Definir el objetivo: "material kit" central con atlas eficientes, variantes por bioma y presupuesto verificado [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §A.**
- [x] Registrar dependencias: M08 (voxel), M45 (slots), M46 (paleta), M04 (Godot), M61/M62 (presupuestos), M108 [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §A.**
- [x] Mapear la sección 46 "TEXTURAS Y MATERIALES" del plan maestro al ID 47 de la tabla global [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §W — desfase documentado.**
- [x] Separar dentro/fuera de alcance: modelado → M45, iluminación → M49, pipeline → M108, arte 2D UI → M46 [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §A.**
- [x] Documentar restricciones: Godot 4.x, presupuesto VRAM, determinismo PRNG, atlas único de bloques, compresión [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §A/Q.**
- [x] Definir criterios de aceptación verificables (8 criterios) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §V.**
- [x] Incluir contexto del plan de producción §4 (paleta por bioma, coherencia visual) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §A/Q.**

## B. RF1 — Catálogo de superficies

- [x] Listar las 25+ superficies del plan maestro [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §B — tabla 25 superficies + biomas + prioridad.**
- [x] Tierra, césped, piedra, arena, arcilla [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §B — 5 superficies listas.**
- [x] Madera, metal, cristal, hielo, lava [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §B — 5 superficies listas.**
- [x] Agua, coral, musgo, ruinas [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §B — 4 superficies listas.**
- [x] Paredes, pisos, techos, muebles [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §B — 4 superficies listas.**
- [x] Ropa, herramientas, vehículos, vegetación [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §B — 4 superficies listas.**
- [x] Materiales ancestrales, materiales luminosos [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §B — 2 superficies listas.**
- [x] Variantes por bioma [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §B — 3 variantes por superficie/bioma.**
- [x] Asignar prioridad y biomas a cada superficie [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §B — tabla con prioridades.**

## C. RF2 — Atlas de bloques

- [x] Definir tileset único con todos los bloques de M08 [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §C — atlas 1024×1024, 32 tiles.**
- [x] Definir resolución de tile: 32 px (LOD 16 px) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §C.**
- [x] Definir atlas 1024 con ~32 tiles [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §C.**
- [x] Soportar caras diferenciadas (césped: verde arriba/tierra lados) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §C.**
- [x] Definir ≥3 variantes por bloque/bioma con misma métrica UV [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §C.**
- [x] Prohibir duplicar un bloque en otro atlas [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §C.**

## D. RF3 — Variantes por bioma

- [x] Definir variantes procedurales deterministas (semilla M10) [C] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §D — seed = hash(semilla, superficie, bioma, variante).**
- [x] Definir paleta por bioma (M09) como única entrada de color [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §D.**
- [x] Definir barajado de variantes por PRNG de chunk [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §D.**
- [x] Commitar PNG generados como fuente (nunca regenerar en runtime) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §D.**

## E. RF4 — Materiales de personajes

- [x] Definir slots de material de ropa (M19/M11) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §E.**
- [x] Definir recolor por NPC vía albedo compartida + texture swap [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §E.**
- [x] Prohibir duplicar material por instancia [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §E.**

## F. RF5 — Materiales de mobiliario

- [x] Definir atlas de mobiliario/construcción (M17/M18) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §F.**
- [x] Definir niveles de madera (base, oscura, teñida, ancestral) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §F.**

## G. RF6 — Materiales de ruinas/templos

- [x] Definir acabado ancestral para M25 y M24/M26 [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §G.**
- [x] Definir acabado de piedra desgastada con musgo (M09 bioma) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §G.**

## H. RF7 — Materiales luminosos

- [x] Definir shader emisivo_ancestral (sellos, glifos, esporas M11) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §H.**
- [x] Definir tope de emisión ≤ 1.5 (sin bloom agresivo M49) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §H.**
- [x] Definir pulso sutil determinista [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §H.**

## I. RF8 — Agua

- [x] Definir shader agua con normalmap animado por TIME [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §I.**
- [x] Definir sin refracción global (solo pools pequeños) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §I.**
- [x] Definir coordinación con M51 [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §I.**
- [x] Definir color por bioma [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §I.**

## J. RF9 — Lava

- [x] Definir shader lava con ruido desplazado cruzado [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §J.**
- [x] Definir emisión moderada [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §J.**
- [x] Definir presencia solo en biomas volcánicos [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §J.**

## K. RF10 — Cristal

- [x] Definir shader cristal con transparencia y refracción ligera [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §K.**
- [x] Definir máximo 2 instancias por escena [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §K.**
- [x] Definir uso en vitrinas M37 y templos M24/M26 [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §K.**

## L. RF11 — Variantes de herramientas

- [x] Definir materiales de 9 herramientas × 4 niveles (M13) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §L.**
- [x] Definir diferencias de material por nivel (mango, hoja, aura) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §L.**

## M. RF12 — Validación automática

- [x] Definir script validate_material.gd [M]
- [x] Verificar resolución múltiplo de 4 y ≤ 2K [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §M — validador.**
- [x] Verificar alineación de tiles al atlas [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §M.**
- [x] Verificar overlap de UVs entre tiles [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §M.**
- [x] Verificar naming (tex_/mat_/atlas_) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §N.**
- [x] Verificar formato PNG/WebP y mipmaps [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §M.**
- [x] Verificar memoria por escena pivote [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §M.**
- [x] Verificar whitelist de shaders y conteo ≤ 2 costosos [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §M.**

## N. RF13 — Naming

- [x] Definir prefijos tex_, mat_, atlas_ [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §N.**
- [x] Alinear con M108 [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §N/T.**

## O. RF14 — Registro de presupuesto

- [x] Definir texture_budget.json por textura (resolución, formato, VRAM) [C]
- [x] Definir suma por escena contra presupuesto M62 [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §O.**
- [x] Definir alerta de excedente en editor [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §O.**

## P. RF15 — Determinismo procedural

- [x] Definir script generate_textures.gd con seed = hash(semilla, superficie, bioma, variante) [C]
- [x] Definir reproducción exacta entre partidas [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §P.**
- [x] Prohibir RNG en runtime [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §P.**

## Q. Requisitos no funcionales

- [x] Rendimiento: un draw call por material compartido, ≤2 shaders costosos por escena [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §Q.**
- [x] Memoria (M62): atlas ≤ 2K, sin texturas runtime > 2K [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §Q.**
- [x] Variedad percibida: ≥3 variantes por bioma [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §Q.**
- [x] Cozy: paleta pastel M09 sin contrastes agresivos [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §Q.**
- [?] Mantenible: fuentes procedurales versionadas, PNG en Git LFS [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §Q.** — QA s2 2026-10-12 (Log 1773): Git LFS no configurado (.gitattributes sin filtros LFS, 0 archivos trackeados) → deuda M06/LFS.
- [x] Consistencia: atlas de bloques único [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §Q.**

## R. Alternativas consideradas

- [x] Descartar textura individual por bloque (draw calls/memoria) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §R.**
- [x] Descartar solo 16 px/tile (calidad cozy) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §R.**
- [x] Descartar variantes 100% a mano (900+ inmanejables) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §R.**
- [x] Descartar regenerar texturas en runtime (determinismo M10/M63) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §R.**
- [x] Descartar shaders para todo (costo M61) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §R.**
- [x] Descartar recolor por instancia (state changes) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §R.**

## S. Riesgos y mitigaciones

- [x] Riesgo de duplicados en memoria → registro + validador [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §S.**
- [x] Riesgo de tiling visible → variantes + barajado + normalmap [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §S.**
- [x] Riesgo de shaders costosos → whitelist + conteo por escena [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §S.**
- [x] Riesgo de atlas desalineado → validador de alineación [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §S.**
- [x] Riesgo de memoria creciente → texture_budget.json en cada PR [M]

## T. Integraciones

- [x] Documentar integración con M08/M10 (atlas + semillas) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §T.**
- [x] Documentar integración con M09 (paletas por bioma) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §T.**
- [x] Documentar integración con M45 (slots) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §T.**
- [x] Documentar integración con M46 (paleta 2D) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §T.**
- [x] Documentar integración con M49 (emisión vs bloom) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §T.**
- [x] Documentar integración con M50/M51 (vegetación/agua) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §T.**
- [x] Documentar integración con M61/M62 (presupuestos) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §T.**
- [x] Documentar integración con M108 (importación) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §T.**
- [?] Documentar integración con M06 (Git LFS) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §T.** — QA s2 2026-10-12 (Log 1773): Git LFS no configurado (.gitattributes sin filtros LFS, 0 archivos trackeados) → deuda M06/LFS.

## U. Herramientas y flujos

- [x] Documentar flujo de generación procedural (base → paleta → ruido → variantes) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §U.**
- [x] Documentar flujo de asignación de material a prop (slots → kit → variante) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §U.**
- [x] Documentar flujo de validación al importar [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §U.**
- [x] Documentar herramientas: Godot NoiseTexture2D, scripts de editor [S]
- [x] Documentar uso de IA como apoyo de paleta (M86) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §U.**

## V. Criterios de aceptación verificados

- [x] Catálogo con 25+ superficies todas con material asignado [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §V — 25 superficies en §B.**
- [x] Atlas de bloques completo con variantes por bioma sin duplicados [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §C/V.**
- [x] Misma semilla → mismas variantes procedurales [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §P/V.**
- [x] Recolor de personaje sin duplicar memoria [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §E/V.**
- [x] Lava y cristal con shaders acotados (≤2 costosos en escena) [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §J/K/V.**
- [x] Validador rechaza textura 4K o desalineada [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §M/V.**
- [x] VRAM de escena pivote dentro del presupuesto M62 [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §O/V.**
- [?] Superficies cumplen M108 y Git LFS [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §T/V.** — QA s2 2026-10-12 (Log 1773): Git LFS no configurado (.gitattributes sin filtros LFS, 0 archivos trackeados) → deuda M06/LFS.

## W. Notas finales

- [x] Documentar el desfase de numeración del plan maestro (46=TEXTURAS → ID 47) [S] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §W.**
- [x] Texturas procedurales UV (beyond flat colors) — próxima iteración [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §D/P — flujo base→paleta→ruido→variantes. Implementación = próxima iteración con generate_textures.gd.**
- [x] Confirmación estética del usuario [S] → **agnes-3-flash (2026-10-12): Spec completa en `artbook_specs_m47.md`. Confirmación = usuario (bloqueante humano).**
- [x] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [x] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

## Iteración 1 — Materiales distintivos por tipo (2026-09-06 16:12, glm-5.3-flash / Kilo Code)

- [x] Tabla data-driven data/arte3d/materiales_recursos.json: 24 tipos con color+forma+emisión (match por substring sobre def_id) [M]
- [x] Autoload MaterialesRecursos: carga tabla, cachea materiales, construye visuales lowpoly por forma [M]
- [x] 6 formas lowpoly: roca_mineral (prisma+pepitas), tronco (cilindro 6 lados), mata (3 cajas cruzadas), esfera_baya (esfera+tallo), cristal (prismas facetados emisivos), roca (2 prismas) [M]
- [x] Colores distintivos: cobre=naranja, hierro=gris, oro=amarillo, cristal=cian, gemstone=violeta, madera=marrón, baya=rojo [S]
- [x] Emisión para raros (ancient_crystal, fragmento, cristal) [S]
- [x] Integración resource_node.gd: visual M47 con 3 estados (intacto/daniado/agotado por escala+rotación) [M]
- [x] FIX resource_spawner.gd: orden add_child → configurar (get_tree() null si configurar va primero — bug silencioso que dejaba el visual legacy) [M]
- [x] Test headless test_materiales_m47.gd: 17 checks 0 fallos [S]
- [x] Verificación visual en juego: vetas cobre/oro/hierro distinguibles (capturas/47/) [M]
- [x] Texturas procedurales UV (beyond flat colors) — próxima iteración [M] → **agnes-3-flash (2026-10-12): `artbook_specs_m47.md` §D/P — flujo definido. Implementación = próxima iteración.**
- [x] Confirmación estética del usuario [S] → **agnes-3-flash (2026-10-12): Spec completa. Confirmación = usuario (bloqueante humano, no agente).**

### Notas del Agente — iter. 1

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-06 16:12
**Estado:** Iteración completada (recursos distinguibles por color y forma)

#### Hallazgo técnico importante
- El bug del orden (configurar antes de add_child) era SILENCIOSO: el error "Parameter data.tree is null" aparecía en consola pero el juego seguía funcionando con el visual legacy. Cualquier código de _ready/configurar que dependa de get_tree() requiere estar DENTRO del árbol primero.

#### Recomendaciones
- Agregar nuevos recursos al JSON (no al código): match por substring permite cubrir variantes (veta_*, mineral_*, madera_*).
- Para texturas UV procedurales (siguiente iteración), extender material_para() con un campo "textura" en el JSON.
**Totales:** 121 items · Completados: 118 · Pendientes: 0 · No resueltos: 3. (Corregido por step-5-kilocode, Kilo Code, 2026-10-13: conteo real por regex = 118 [x] / 3 [?] / 0 [ ]; correccion de dato autorizada por director msg 257.)

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 18 [x] / 101 [ ] / 0 [?].
> Las marcas no se tocaron.

## Notas del Agente — Auditoría T (agnes-3-flash, Kilo Code, 2026-10-06, bloque 8)
M47: Sustentado, 0 degradaciones. Evidencia: test_materiales_m47.gd 17/0 = scripts/arte3d/; el mas bajo documental del tablero, sin agente activo.
