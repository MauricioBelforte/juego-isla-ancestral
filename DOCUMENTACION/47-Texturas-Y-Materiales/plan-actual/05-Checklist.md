**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 47: Texturas y Materiales

## A. Problema y objetivos

- [x] Definir el problema: sin sistema de texturas/materiales las superficies lucen dispares y el presupuesto se rompe [S]
- [x] Definir el objetivo: "material kit" central con atlas eficientes, variantes por bioma y presupuesto verificado [S]
- [x] Registrar dependencias: M08 (voxel), M45 (slots), M46 (paleta), M04 (Godot), M61/M62 (presupuestos), M108 [S]
- [x] Mapear la sección 46 "TEXTURAS Y MATERIALES" del plan maestro al ID 47 de la tabla global [M]
- [x] Separar dentro/fuera de alcance: modelado → M45, iluminación → M49, pipeline → M108, arte 2D UI → M46 [S]
- [x] Documentar restricciones: Godot 4.x, presupuesto VRAM, determinismo PRNG, atlas único de bloques, compresión [S]
- [x] Definir criterios de aceptación verificables (8 criterios) [S]
- [x] Incluir contexto del plan de producción §4 (paleta por bioma, coherencia visual) [M]

## B. RF1 — Catálogo de superficies

- [x] Listar las 25+ superficies del plan maestro [M]
- [x] Tierra, césped, piedra, arena, arcilla [S]
- [x] Madera, metal, cristal, hielo, lava [S]
- [x] Agua, coral, musgo, ruinas [S]
- [x] Paredes, pisos, techos, muebles [S]
- [x] Ropa, herramientas, vehículos, vegetación [S]
- [x] Materiales ancestrales, materiales luminosos [S]
- [x] Variantes por bioma [S]
- [x] Asignar prioridad y biomas a cada superficie [M]

## C. RF2 — Atlas de bloques

- [x] Definir tileset único con todos los bloques de M08 [M]
- [x] Definir resolución de tile: 32 px (LOD 16 px) [M]
- [x] Definir atlas 1024 con ~32 tiles [S]
- [x] Soportar caras diferenciadas (césped: verde arriba/tierra lados) [M]
- [x] Definir ≥3 variantes por bloque/bioma con misma métrica UV [M]
- [x] Prohibir duplicar un bloque en otro atlas [S]

## D. RF3 — Variantes por bioma

- [x] Definir variantes procedurales deterministas (semilla M10) [C]
- [x] Definir paleta por bioma (M09) como única entrada de color [M]
- [x] Definir barajado de variantes por PRNG de chunk [M]
- [x] Commitar PNG generados como fuente (nunca regenerar en runtime) [M]

## E. RF4 — Materiales de personajes

- [x] Definir slots de material de ropa (M19/M11) [M]
- [x] Definir recolor por NPC vía albedo compartida + texture swap [M]
- [x] Prohibir duplicar material por instancia [S]

## F. RF5 — Materiales de mobiliario

- [x] Definir atlas de mobiliario/construcción (M17/M18) [M]
- [x] Definir niveles de madera (base, oscura, teñida, ancestral) [S]

## G. RF6 — Materiales de ruinas/templos

- [x] Definir acabado ancestral para M25 y M24/M26 [M]
- [x] Definir acabado de piedra desgastada con musgo (M09 bioma) [S]

## H. RF7 — Materiales luminosos

- [x] Definir shader emisivo_ancestral (sellos, glifos, esporas M11) [M]
- [x] Definir tope de emisión ≤ 1.5 (sin bloom agresivo M49) [S]
- [x] Definir pulso sutil determinista [S]

## I. RF8 — Agua

- [x] Definir shader agua con normalmap animado por TIME [M]
- [x] Definir sin refracción global (solo pools pequeños) [M]
- [x] Definir coordinación con M51 [M]
- [x] Definir color por bioma [S]

## J. RF9 — Lava

- [x] Definir shader lava con ruido desplazado cruzado [M]
- [x] Definir emisión moderada [S]
- [x] Definir presencia solo en biomas volcánicos [S]

## K. RF10 — Cristal

- [x] Definir shader cristal con transparencia y refracción ligera [M]
- [x] Definir máximo 2 instancias por escena [M]
- [x] Definir uso en vitrinas M37 y templos M24/M26 [S]

## L. RF11 — Variantes de herramientas

- [x] Definir materiales de 9 herramientas × 4 niveles (M13) [M]
- [x] Definir diferencias de material por nivel (mango, hoja, aura) [M]

## M. RF12 — Validación automática

- [x] Definir script validate_material.gd [M]
- [x] Verificar resolución múltiplo de 4 y ≤ 2K [S]
- [x] Verificar alineación de tiles al atlas [M]
- [x] Verificar overlap de UVs entre tiles [M]
- [x] Verificar naming (tex_/mat_/atlas_) [S]
- [x] Verificar formato PNG/WebP y mipmaps [S]
- [x] Verificar memoria por escena pivote [M]
- [x] Verificar whitelist de shaders y conteo ≤ 2 costosos [M]

## N. RF13 — Naming

- [x] Definir prefijos tex_, mat_, atlas_ [S]
- [x] Alinear con M108 [M]

## O. RF14 — Registro de presupuesto

- [x] Definir texture_budget.json por textura (resolución, formato, VRAM) [C]
- [x] Definir suma por escena contra presupuesto M62 [M]
- [x] Definir alerta de excedente en editor [S]

## P. RF15 — Determinismo procedural

- [x] Definir script generate_textures.gd con seed = hash(semilla, superficie, bioma, variante) [C]
- [x] Definir reproducción exacta entre partidas [M]
- [x] Prohibir RNG en runtime [S]

## Q. Requisitos no funcionales

- [x] Rendimiento: un draw call por material compartido, ≤2 shaders costosos por escena [M]
- [x] Memoria (M62): atlas ≤ 2K, sin texturas runtime > 2K [M]
- [x] Variedad percibida: ≥3 variantes por bioma [M]
- [x] Cozy: paleta pastel M09 sin contrastes agresivos [M]
- [x] Mantenible: fuentes procedurales versionadas, PNG en Git LFS [M]
- [x] Consistencia: atlas de bloques único [S]

## R. Alternativas consideradas

- [x] Descartar textura individual por bloque (draw calls/memoria) [M]
- [x] Descartar solo 16 px/tile (calidad cozy) [S]
- [x] Descartar variantes 100% a mano (900+ inmanejables) [M]
- [x] Descartar regenerar texturas en runtime (determinismo M10/M63) [M]
- [x] Descartar shaders para todo (costo M61) [M]
- [x] Descartar recolor por instancia (state changes) [M]

## S. Riesgos y mitigaciones

- [x] Riesgo de duplicados en memoria → registro + validador [M]
- [x] Riesgo de tiling visible → variantes + barajado + normalmap [M]
- [x] Riesgo de shaders costosos → whitelist + conteo por escena [M]
- [x] Riesgo de atlas desalineado → validador de alineación [M]
- [x] Riesgo de memoria creciente → texture_budget.json en cada PR [M]

## T. Integraciones

- [x] Documentar integración con M08/M10 (atlas + semillas) [S]
- [x] Documentar integración con M09 (paletas por bioma) [S]
- [x] Documentar integración con M45 (slots) [S]
- [x] Documentar integración con M46 (paleta 2D) [S]
- [x] Documentar integración con M49 (emisión vs bloom) [M]
- [x] Documentar integración con M50/M51 (vegetación/agua) [S]
- [x] Documentar integración con M61/M62 (presupuestos) [S]
- [x] Documentar integración con M108 (importación) [S]
- [x] Documentar integración con M06 (Git LFS) [S]

## U. Herramientas y flujos

- [x] Documentar flujo de generación procedural (base → paleta → ruido → variantes) [M]
- [x] Documentar flujo de asignación de material a prop (slots → kit → variante) [M]
- [x] Documentar flujo de validación al importar [M]
- [x] Documentar herramientas: Godot NoiseTexture2D, scripts de editor [S]
- [x] Documentar uso de IA como apoyo de paleta (M86) [S]

## V. Criterios de aceptación verificados

- [x] Catálogo con 25+ superficies todas con material asignado [M]
- [x] Atlas de bloques completo con variantes por bioma sin duplicados [M]
- [x] Misma semilla → mismas variantes procedurales [M]
- [x] Recolor de personaje sin duplicar memoria [M]
- [x] Lava y cristal con shaders acotados (≤2 costosos en escena) [M]
- [x] Validador rechaza textura 4K o desalineada [M]
- [x] VRAM de escena pivote dentro del presupuesto M62 [M]
- [x] Superficies cumplen M108 y Git LFS [M]

## W. Notas finales

- [x] Documentar el desfase de numeración del plan maestro (46=TEXTURAS → ID 47) [S]
- [x] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [x] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
