**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 47: Texturas y Materiales

## A. Problema y objetivos

- [ ] Definir el problema: sin sistema de texturas/materiales las superficies lucen dispares y el presupuesto se rompe [S]
- [ ] Definir el objetivo: "material kit" central con atlas eficientes, variantes por bioma y presupuesto verificado [S]
- [ ] Registrar dependencias: M08 (voxel), M45 (slots), M46 (paleta), M04 (Godot), M61/M62 (presupuestos), M108 [S]
- [ ] Mapear la sección 46 "TEXTURAS Y MATERIALES" del plan maestro al ID 47 de la tabla global [M]
- [ ] Separar dentro/fuera de alcance: modelado → M45, iluminación → M49, pipeline → M108, arte 2D UI → M46 [S]
- [ ] Documentar restricciones: Godot 4.x, presupuesto VRAM, determinismo PRNG, atlas único de bloques, compresión [S]
- [ ] Definir criterios de aceptación verificables (8 criterios) [S]
- [ ] Incluir contexto del plan de producción §4 (paleta por bioma, coherencia visual) [M]

## B. RF1 — Catálogo de superficies

- [ ] Listar las 25+ superficies del plan maestro [M]
- [ ] Tierra, césped, piedra, arena, arcilla [S]
- [ ] Madera, metal, cristal, hielo, lava [S]
- [ ] Agua, coral, musgo, ruinas [S]
- [ ] Paredes, pisos, techos, muebles [S]
- [ ] Ropa, herramientas, vehículos, vegetación [S]
- [ ] Materiales ancestrales, materiales luminosos [S]
- [ ] Variantes por bioma [S]
- [ ] Asignar prioridad y biomas a cada superficie [M]

## C. RF2 — Atlas de bloques

- [ ] Definir tileset único con todos los bloques de M08 [M]
- [ ] Definir resolución de tile: 32 px (LOD 16 px) [M]
- [ ] Definir atlas 1024 con ~32 tiles [S]
- [ ] Soportar caras diferenciadas (césped: verde arriba/tierra lados) [M]
- [ ] Definir ≥3 variantes por bloque/bioma con misma métrica UV [M]
- [ ] Prohibir duplicar un bloque en otro atlas [S]

## D. RF3 — Variantes por bioma

- [ ] Definir variantes procedurales deterministas (semilla M10) [C]
- [ ] Definir paleta por bioma (M09) como única entrada de color [M]
- [ ] Definir barajado de variantes por PRNG de chunk [M]
- [ ] Commitar PNG generados como fuente (nunca regenerar en runtime) [M]

## E. RF4 — Materiales de personajes

- [ ] Definir slots de material de ropa (M19/M11) [M]
- [ ] Definir recolor por NPC vía albedo compartida + texture swap [M]
- [ ] Prohibir duplicar material por instancia [S]

## F. RF5 — Materiales de mobiliario

- [ ] Definir atlas de mobiliario/construcción (M17/M18) [M]
- [ ] Definir niveles de madera (base, oscura, teñida, ancestral) [S]

## G. RF6 — Materiales de ruinas/templos

- [ ] Definir acabado ancestral para M25 y M24/M26 [M]
- [ ] Definir acabado de piedra desgastada con musgo (M09 bioma) [S]

## H. RF7 — Materiales luminosos

- [ ] Definir shader emisivo_ancestral (sellos, glifos, esporas M11) [M]
- [ ] Definir tope de emisión ≤ 1.5 (sin bloom agresivo M49) [S]
- [ ] Definir pulso sutil determinista [S]

## I. RF8 — Agua

- [ ] Definir shader agua con normalmap animado por TIME [M]
- [ ] Definir sin refracción global (solo pools pequeños) [M]
- [ ] Definir coordinación con M51 [M]
- [ ] Definir color por bioma [S]

## J. RF9 — Lava

- [ ] Definir shader lava con ruido desplazado cruzado [M]
- [ ] Definir emisión moderada [S]
- [ ] Definir presencia solo en biomas volcánicos [S]

## K. RF10 — Cristal

- [ ] Definir shader cristal con transparencia y refracción ligera [M]
- [ ] Definir máximo 2 instancias por escena [M]
- [ ] Definir uso en vitrinas M37 y templos M24/M26 [S]

## L. RF11 — Variantes de herramientas

- [ ] Definir materiales de 9 herramientas × 4 niveles (M13) [M]
- [ ] Definir diferencias de material por nivel (mango, hoja, aura) [M]

## M. RF12 — Validación automática

- [ ] Definir script validate_material.gd [M]
- [ ] Verificar resolución múltiplo de 4 y ≤ 2K [S]
- [ ] Verificar alineación de tiles al atlas [M]
- [ ] Verificar overlap de UVs entre tiles [M]
- [ ] Verificar naming (tex_/mat_/atlas_) [S]
- [ ] Verificar formato PNG/WebP y mipmaps [S]
- [ ] Verificar memoria por escena pivote [M]
- [ ] Verificar whitelist de shaders y conteo ≤ 2 costosos [M]

## N. RF13 — Naming

- [ ] Definir prefijos tex_, mat_, atlas_ [S]
- [ ] Alinear con M108 [M]

## O. RF14 — Registro de presupuesto

- [ ] Definir texture_budget.json por textura (resolución, formato, VRAM) [C]
- [ ] Definir suma por escena contra presupuesto M62 [M]
- [ ] Definir alerta de excedente en editor [S]

## P. RF15 — Determinismo procedural

- [ ] Definir script generate_textures.gd con seed = hash(semilla, superficie, bioma, variante) [C]
- [ ] Definir reproducción exacta entre partidas [M]
- [ ] Prohibir RNG en runtime [S]

## Q. Requisitos no funcionales

- [ ] Rendimiento: un draw call por material compartido, ≤2 shaders costosos por escena [M]
- [ ] Memoria (M62): atlas ≤ 2K, sin texturas runtime > 2K [M]
- [ ] Variedad percibida: ≥3 variantes por bioma [M]
- [ ] Cozy: paleta pastel M09 sin contrastes agresivos [M]
- [ ] Mantenible: fuentes procedurales versionadas, PNG en Git LFS [M]
- [ ] Consistencia: atlas de bloques único [S]

## R. Alternativas consideradas

- [ ] Descartar textura individual por bloque (draw calls/memoria) [M]
- [ ] Descartar solo 16 px/tile (calidad cozy) [S]
- [ ] Descartar variantes 100% a mano (900+ inmanejables) [M]
- [ ] Descartar regenerar texturas en runtime (determinismo M10/M63) [M]
- [ ] Descartar shaders para todo (costo M61) [M]
- [ ] Descartar recolor por instancia (state changes) [M]

## S. Riesgos y mitigaciones

- [ ] Riesgo de duplicados en memoria → registro + validador [M]
- [ ] Riesgo de tiling visible → variantes + barajado + normalmap [M]
- [ ] Riesgo de shaders costosos → whitelist + conteo por escena [M]
- [ ] Riesgo de atlas desalineado → validador de alineación [M]
- [ ] Riesgo de memoria creciente → texture_budget.json en cada PR [M]

## T. Integraciones

- [ ] Documentar integración con M08/M10 (atlas + semillas) [S]
- [ ] Documentar integración con M09 (paletas por bioma) [S]
- [ ] Documentar integración con M45 (slots) [S]
- [ ] Documentar integración con M46 (paleta 2D) [S]
- [ ] Documentar integración con M49 (emisión vs bloom) [M]
- [ ] Documentar integración con M50/M51 (vegetación/agua) [S]
- [ ] Documentar integración con M61/M62 (presupuestos) [S]
- [ ] Documentar integración con M108 (importación) [S]
- [ ] Documentar integración con M06 (Git LFS) [S]

## U. Herramientas y flujos

- [ ] Documentar flujo de generación procedural (base → paleta → ruido → variantes) [M]
- [ ] Documentar flujo de asignación de material a prop (slots → kit → variante) [M]
- [ ] Documentar flujo de validación al importar [M]
- [ ] Documentar herramientas: Godot NoiseTexture2D, scripts de editor [S]
- [ ] Documentar uso de IA como apoyo de paleta (M86) [S]

## V. Criterios de aceptación verificados

- [ ] Catálogo con 25+ superficies todas con material asignado [M]
- [ ] Atlas de bloques completo con variantes por bioma sin duplicados [M]
- [ ] Misma semilla → mismas variantes procedurales [M]
- [ ] Recolor de personaje sin duplicar memoria [M]
- [ ] Lava y cristal con shaders acotados (≤2 costosos en escena) [M]
- [ ] Validador rechaza textura 4K o desalineada [M]
- [ ] VRAM de escena pivote dentro del presupuesto M62 [M]
- [ ] Superficies cumplen M108 y Git LFS [M]

## W. Notas finales

- [ ] Documentar el desfase de numeración del plan maestro (46=TEXTURAS → ID 47) [S]
- [ ] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [ ] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
