**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 45: Arte 3D

## A. Problema y objetivos

- [ ] Definir el problema: sin dirección de arte 3D unificada, los assets rompen la armonía visual, el rendimiento y la métrica voxel [S]
- [ ] Definir el objetivo: guía de estilo, métricas verificables y pipeline de producción de assets 3D coherentes con el mundo voxel cozy [S]
- [ ] Registrar dependencias: M08 (voxel 1 m), M04 (Godot), M11/M19 (personaje), M47 (texturas), M48 (animación), M61 (rendimiento), M108 (pipeline) [S]
- [ ] Mapear la sección 44 "ARTE 3D" del plan maestro al ID 45 de la tabla global (desfase de numeración documentado) [M]
- [ ] Separar dentro/fuera de alcance: texturas → M47, animaciones → M48, pipeline de importación → M108 [S]
- [ ] Documentar restricciones: Godot 4.x, glTF 2.0, alineación a grilla voxel, techos de polígonos, LOD obligatorio [S]
- [ ] Definir criterios de aceptación verificables (8 criterios) [S]
- [ ] Incluir contexto del plan de producción: §4 pipeline de arte 3D, dirección de arte, low-poly redondeado [M]

## B. RF1 — Guía de estilo única

- [ ] Definir estilo "Cozy Voxel": bloques rectos + vivientes redondeados + paleta pastel [M]
- [ ] Definir regla de oro de coherencia: mismo juego en bloque y NPC [M]
- [ ] Definir proporciones chibi suaves (cabezas grandes, extremidades cortas) [M]
- [ ] Definir paleta por bioma (insumo de M09, 13 biomas) [M]
- [ ] Crear documento vivo ART_STYLE_3D.md en Docs/ [M]
- [ ] Incluir ejemplos de referencia (shader/atlas de referencia) en la guía [M]

## C. RF2 — Software estándar

- [ ] Evaluar alternativas: Blender, Maya, 3ds Max, Wings3D [S]
- [ ] Adoptar Blender como herramienta canónica [S]
- [ ] Documentar formato fuente .blend y salida glTF 2.0 (.glb) [S]
- [ ] Documentar flujo de exportación Blender → Godot (escala 1:1, apply scale) [M]

## D. RF3 — Escala unificada

- [ ] Fijar unidad Blender = 1 m [S]
- [ ] Fijar personaje 1.8 m coherente con hitbox M11 (0.6×1.8) [M]
- [ ] Fijar NPC 1.7-1.8 m [S]
- [ ] Definir alineación de props a la grilla voxel de 1 m (M08) [M]
- [ ] Definir punto de apoyo en origen (Y=0) para props de suelo [M]
- [ ] Documentar regla de múltiplos enteros para props integrados a voxel [M]
- [ ] Documentar medidas de puertas (2 m) y ventanas (1×1 m) [S]

## E. RF4 — Techo de polígonos por categoría

- [ ] Crear tabla de techos de tris por categoría (12+ categorías) [M]
- [ ] Jugador ≤ 8 000 tris [S]
- [ ] NPC ≤ 6 000 tris [S]
- [ ] Animal pequeño ≤ 2 500 tris [S]
- [ ] Animal grande ≤ 4 500 tris [S]
- [ ] Edificio pequeño ≤ 8 000 tris [S]
- [ ] Edificio grande ≤ 15 000 tris [S]
- [ ] Mueble ≤ 800 tris [S]
- [ ] Herramienta ≤ 600 tris [S]
- [ ] Barco ≤ 12 000 tris [S]
- [ ] Vehículo ≤ 6 000 tris [S]
- [ ] Árbol ≤ 3 000 tris [S]
- [ ] Prop pequeño ≤ 200 tris [S]
- [ ] Prop mediano ≤ 1 200 tris [S]
- [ ] Ruinas/templos ≤ 14 000 tris [S]
- [ ] Definir que el límite es por malla visible, no por asset total [M]

## F. RF5 — Topología válida

- [ ] Prohibir n-gons (solo quads/tris) fuera de planos invisibles [M]
- [ ] Exigir vértices soldados (sin duplicados) [M]
- [ ] Exigir normales hacia afuera [S]
- [ ] Exigir apply scale antes de exportar [S]
- [ ] Documentar tolerancia de escala en validador (< 1e-3) [S]

## G. RF6 — UVs válidas

- [ ] Prohibir superposición de UV salvo atlas intencional [M]
- [ ] Exigir UV dentro de [0,1] [S]
- [ ] Definir padding mínimo de 4 px (mipmapping) [S]
- [ ] Definir texel density por categoría (512 px/m personajes, 256 px/m props) [M]
- [ ] Documentar marcado de atlas (`atlas_uv`) en props voxel [M]

## H. RF7 — Origen y orientación

- [ ] Definir origen en socket de anclaje (suelo para props) [M]
- [ ] Definir orientación Y-up, +Z frente (o +X según convención Godot) [S]
- [ ] Documentar resolución de mismatch de ejes en import (no en malla) [M]

## I. RF8 — Sockets de anclaje

- [ ] Definir nombres de sockets: socket_suelo, socket_mano, socket_mano_izq, socket_cabeza, socket_corazon, socket_lomo, socket_puerta, socket_ventana, socket_piso [M]
- [ ] Definir sockets como Empties en Blender con escala 1 [S]
- [ ] Documentar uso de sockets por M48 (animación) y M70 (interacción) [M]

## J. RF9 — LOD

- [ ] Definir regla: LOD obligatorio si mesh > 500 tris [S]
- [ ] Definir LOD1 ≈ 50% y LOD2 ≈ 20% (decimación) [S]
- [ ] Definir distancias base por categoría (15/25/30/20 m y 40/60/80/60 m) [M]
- [ ] Definir exportación como variantes glTF (lod0..lod2), no assets separados [M]
- [ ] Documentar integración con M63 (Cargas y Streaming) para activación por distancia [M]

## K. RF10 — Variantes por material

- [ ] Definir límite ≤6 variantes de color por malla (recolor M47) [M]
- [ ] Prohibir duplicar mallas para variantes de color [M]
- [ ] Documentar aprobación manual para exceder el límite [S]

## L. RF11 — Kit modular

- [ ] Definir piezas: mod_pared1, mod_pared_ventana, mod_pared_puerta, mod_piso, mod_techo, mod_columna, mod_escalon, mod_viga [M]
- [ ] Definir dimensiones de encastre voxel para cada pieza [M]
- [ ] Definir origen inferior-izquierdo (0,0,0) común [S]
- [ ] Definir derivados como variantes de material (madera/piedra) [M]
- [ ] Documentar compatibilidad con M17 (construcción) y M24/M25/M26 (templos/ruinas) [M]

## M. RF12 — Categorías cubiertas

- [ ] Definir carpeta characters/ (jugador) [S]
- [ ] Definir carpeta npc/ (aldeanos M19) [S]
- [ ] Definir carpeta animals/ (fauna M36) [S]
- [ ] Definir carpeta buildings/ (casas M18) [S]
- [ ] Definir carpeta furniture/ (muebles) [S]
- [ ] Definir carpeta tools/ (herramientas M13) [S]
- [ ] Definir carpeta vehicles/ (barcos M67, carretas) [S]
- [ ] Definir carpeta vegetation/ (M50) [S]
- [ ] Definir carpeta props/ (rocas, setas, cajas, faroles) [S]
- [ ] Definir carpeta ruins/ (M25) [S]
- [ ] Definir carpeta temples/ (M24/M26) [S]
- [ ] Definir carpeta decorations/ (decorativos) [S]
- [ ] Definir carpeta interactives/ (interactivos M70) [S]

## N. RF13 — Catálogo de assets

- [ ] Definir asset_catalog.json con: asset_id, categoría, bioma, estado, dueño, prioridad, deps [M]
- [ ] Definir estados: planned → made → reviewed → imported [S]
- [ ] Definir consultas por categoría y bioma [S]
- [ ] Documentar que el runtime usa el catálogo, nunca paths directos [M]

## O. RF14 — Validación automática

- [ ] Definir script validate_mesh.gd en Assets/_Project/Editor/ [M]
- [ ] Verificar escala 1:1 (< 1e-3) [S]
- [ ] Verificar techos de tris por categoría [S]
- [ ] Verificar topología (n-gons, vértices duplicados) [S]
- [ ] Verificar UVs (fuera de rango, padding) [S]
- [ ] Verificar origen Y=0 para props de suelo [S]
- [ ] Verificar existencia de LODs si tris > 500 [S]
- [ ] Acumular errores (no morir en el primero) y emitir mensajes accionables [M]

## P. RF15 — Convenciones de nombres

- [ ] Definir prefijos por categoría: chr_, npc_, ani_, bld_, furn_, tool_, veh_, veg_, prop_, ruin_, temple_, dec_, int_ [S]
- [ ] Alinear convenciones con M108 (Pipeline de Assets) [M]
- [ ] Documentar regla de nombres de variantes (sufijo _c1, _c2...) [S]

## Q. RF16 — Presupuesto por escena

- [ ] Definir que los draw calls y vertexes por escena respetan M61 [M]
- [ ] Documentar límites de assets visibles por escena tipo (pueblo, bosque, templo) [M]
- [ ] Definir regla de clama de LODs por distancia (M63) [M]

## R. RF17 — Revisión de asset (asset review)

- [ ] Definir checklist obligatorio previo a importar: estilo, métricas, topología, UVs, LOD, nombres [M]
- [ ] Definir responsable de review (dirección de arte) [S]
- [ ] Documentar revisión de paleta por bioma en cada asset [S]
- [ ] Documentar que los assets IA pasan la misma review (M86) [M]

## S. RF18 — Integración con el mundo

- [ ] Definir declaración de bioma/paleta por asset [S]
- [ ] Definir alineación a grilla de props voxel-adjacent [S]
- [ ] Documentar compatibilidad con generación procedural (M10 no crea assets, solo los coloca) [M]

## T. Requisitos no funcionales

- [ ] Coherencia visual entre islas y artistas (guía única + review) [M]
- [ ] Rendimiento: techos verificados por script, LOD por distancia [M]
- [ ] Mantenibilidad: kit modular, variantes, catálogo central [M]
- [ ] Herramienta gratuita: Blender sin costos de licencia [S]
- [ ] Compatibilidad Godot: glTF 2.0 bien formado [M]
- [ ] Escalabilidad a contenido futuro (islas, DLC) sin renegociar estándares [M]
- [ ] Accesibilidad visual (M58): siluetas legibles, sin flicker [M]
- [ ] Documentación viva versionada con Git LFS (M06) [M]

## U. Alternativas consideradas

- [ ] Descartar Maya/3ds Max por costo innecesario [S]
- [ ] Adoptar Blender por gratuidad, estándar indie, MCP y glTF nativo [S]
- [ ] Descartar salida final directa de IA (inconsistencia + legal M85/M86) [M]
- [ ] Descartar mallas únicas por objeto (costo y draw calls) [M]
- [ ] Descartar ausencia de LOD en arte (gastaría presupuesto M61) [M]
- [ ] Descartar texturas embebidas en malla (doble memoria M62) [M]

## V. Riesgos y mitigaciones

- [ ] Documentar riesgo de inconsistencia de estilo (mitigación: guía + review) [M]
- [ ] Documentar riesgo de assets sobredimensionados (mitigación: validador) [M]
- [ ] Documentar riesgo de error de escala (mitigación: validador) [M]
- [ ] Documentar riesgo de cuello de botella de producción (mitigación: kit modular) [M]
- [ ] Documentar riesgo de assets IA inconsistentes (mitigación: base + review) [M]
- [ ] Documentar riesgo de binarios que rompen el repo (mitigación: Git LFS) [M]

## W. Integraciones

- [ ] Documentar integración con M04 (Godot + Voxel Tools) [S]
- [ ] Documentar integración con M08 (voxel 1 m, atlas de bloques) [S]
- [ ] Documentar integración con M11/M19 (sockets, proporciones) [S]
- [ ] Documentar integración con M13 (socket_mano) [S]
- [ ] Documentar integración con M17/M18 (kit modular, casas) [M]
- [ ] Documentar integración con M24/M25/M26 (templos/ruinas) [M]
- [ ] Documentar integración con M47 (materiales en Godot) [S]
- [ ] Documentar integración con M48 (rigging/animaciones) [S]
- [ ] Documentar integración con M50/M51 (vegetación, agua) [S]
- [ ] Documentar integración con M61/M62 (LOD, memoria) [S]
- [ ] Documentar integración con M63 (LODs por distancia) [S]
- [ ] Documentar integración con M108 (importación) [S]
- [ ] Documentar integración con M06 (Git LFS) [S]

## X. Herramientas y flujos

- [ ] Documentar flujo completo de creación de asset (modelador → validador → review → import) [M]
- [ ] Documentar flujo del validador (check acumulado de errores) [M]
- [ ] Documentar uso de blender-mcp y IA como base con review humana [M]
- [ ] Documentar convención de no embeker texturas en .glb [M]
- [ ] Documentar configuración de PBR Metallic-Roughness y resolución 2K máx [M]

## Y. Criterios de aceptación verificados

- [ ] Tres assets de prueba pasan validate_mesh.gd y se ven armónicos en Aurora [M]
- [ ] Personaje 1.8 m con punto de apoyo en grilla voxel [M]
- [ ] Conteo de tris por categoría menor o igual a la tabla RF4 [M]
- [ ] Prop con UVs fuera de padding o n-gons rechazado con mensaje accionable [M]
- [ ] Edificio >500 tris con LOD1/LOD2 configurados [M]
- [ ] Variantes de color implementadas como material (no malla duplicada) [M]
- [ ] Kit modular arma una casa M17 sin piezas nuevas [M]
- [ ] Assets del catálogo cumplen M108 y Git LFS [M]

## Z. Notas finales

- [ ] Documentar el desfase de numeración entre plan maestro (44=ARTE 3D) y tabla global (45=Arte 3D) [S]
- [ ] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [ ] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
