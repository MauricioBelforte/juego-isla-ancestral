**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 45: Arte 3D

## A. Problema y objetivos

- [x] Definir el problema: sin dirección de arte 3D unificada, los assets rompen la armonía visual, el rendimiento y la métrica voxel [S]
- [x] Definir el objetivo: guía de estilo, métricas verificables y pipeline de producción de assets 3D coherentes con el mundo voxel cozy [S]
- [x] Registrar dependencias: M08 (voxel 1 m), M04 (Godot), M11/M19 (personaje), M47 (texturas), M48 (animación), M61 (rendimiento), M108 (pipeline) [S]
- [x] Mapear la sección 44 "ARTE 3D" del plan maestro al ID 45 de la tabla global (desfase de numeración documentado) [M]
- [x] Separar dentro/fuera de alcance: texturas → M47, animaciones → M48, pipeline de importación → M108 [S]
- [x] Documentar restricciones: Godot 4.x, glTF 2.0, alineación a grilla voxel, techos de polígonos, LOD obligatorio [S]
- [x] Definir criterios de aceptación verificables (8 criterios) [S]
- [x] Incluir contexto del plan de producción: §4 pipeline de arte 3D, dirección de arte, low-poly redondeado [M]

## B. RF1 — Guía de estilo única

- [x] Definir estilo "Cozy Voxel": bloques rectos + vivientes redondeados + paleta pastel [M]
- [x] Definir regla de oro de coherencia: mismo juego en bloque y NPC [M]
- [x] Definir proporciones chibi suaves (cabezas grandes, extremidades cortas) [M]
- [x] Definir paleta por bioma (insumo de M09, 13 biomas) [M]
- [x] Crear documento vivo ART_STYLE_3D.md en Docs/ [M]
- [x] Incluir ejemplos de referencia (shader/atlas de referencia) en la guía [M]

## C. RF2 — Software estándar

- [x] Evaluar alternativas: Blender, Maya, 3ds Max, Wings3D [S]
- [x] Adoptar Blender como herramienta canónica [S]
- [x] Documentar formato fuente .blend y salida glTF 2.0 (.glb) [S]
- [x] Documentar flujo de exportación Blender → Godot (escala 1:1, apply scale) [M]

## D. RF3 — Escala unificada

- [x] Fijar unidad Blender = 1 m [S]
- [x] Fijar personaje 1.8 m coherente con hitbox M11 (0.6×1.8) [M]
- [x] Fijar NPC 1.7-1.8 m [S]
- [x] Definir alineación de props a la grilla voxel de 1 m (M08) [M]
- [x] Definir punto de apoyo en origen (Y=0) para props de suelo [M]
- [x] Documentar regla de múltiplos enteros para props integrados a voxel [M]
- [x] Documentar medidas de puertas (2 m) y ventanas (1×1 m) [S]

## E. RF4 — Techo de polígonos por categoría

- [x] Crear tabla de techos de tris por categoría (12+ categorías) [M]
- [x] Jugador ≤ 8 000 tris [S]
- [x] NPC ≤ 6 000 tris [S]
- [x] Animal pequeño ≤ 2 500 tris [S]
- [x] Animal grande ≤ 4 500 tris [S]
- [x] Edificio pequeño ≤ 8 000 tris [S]
- [x] Edificio grande ≤ 15 000 tris [S]
- [x] Mueble ≤ 800 tris [S]
- [x] Herramienta ≤ 600 tris [S]
- [x] Barco ≤ 12 000 tris [S]
- [x] Vehículo ≤ 6 000 tris [S]
- [x] Árbol ≤ 3 000 tris [S]
- [x] Prop pequeño ≤ 200 tris [S]
- [x] Prop mediano ≤ 1 200 tris [S]
- [x] Ruinas/templos ≤ 14 000 tris [S]
- [x] Definir que el límite es por malla visible, no por asset total [M]

## F. RF5 — Topología válida

- [x] Prohibir n-gons (solo quads/tris) fuera de planos invisibles [M]
- [x] Exigir vértices soldados (sin duplicados) [M]
- [x] Exigir normales hacia afuera [S]
- [x] Exigir apply scale antes de exportar [S]
- [x] Documentar tolerancia de escala en validador (< 1e-3) [S]

## G. RF6 — UVs válidas

- [x] Prohibir superposición de UV salvo atlas intencional [M]
- [x] Exigir UV dentro de [0,1] [S]
- [x] Definir padding mínimo de 4 px (mipmapping) [S]
- [x] Definir texel density por categoría (512 px/m personajes, 256 px/m props) [M]
- [x] Documentar marcado de atlas (`atlas_uv`) en props voxel [M]

## H. RF7 — Origen y orientación

- [x] Definir origen en socket de anclaje (suelo para props) [M]
- [x] Definir orientación Y-up, +Z frente (o +X según convención Godot) [S]
- [x] Documentar resolución de mismatch de ejes en import (no en malla) [M]

## I. RF8 — Sockets de anclaje

- [x] Definir nombres de sockets: socket_suelo, socket_mano, socket_mano_izq, socket_cabeza, socket_corazon, socket_lomo, socket_puerta, socket_ventana, socket_piso [M]
- [x] Definir sockets como Empties en Blender con escala 1 [S]
- [x] Documentar uso de sockets por M48 (animación) y M70 (interacción) [M]

## J. RF9 — LOD

- [x] Definir regla: LOD obligatorio si mesh > 500 tris [S]
- [x] Definir LOD1 ≈ 50% y LOD2 ≈ 20% (decimación) [S]
- [x] Definir distancias base por categoría (15/25/30/20 m y 40/60/80/60 m) [M]
- [x] Definir exportación como variantes glTF (lod0..lod2), no assets separados [M]
- [x] Documentar integración con M63 (Cargas y Streaming) para activación por distancia [M]

## K. RF10 — Variantes por material

- [x] Definir límite ≤6 variantes de color por malla (recolor M47) [M]
- [x] Prohibir duplicar mallas para variantes de color [M]
- [x] Documentar aprobación manual para exceder el límite [S]

## L. RF11 — Kit modular

- [x] Definir piezas: mod_pared1, mod_pared_ventana, mod_pared_puerta, mod_piso, mod_techo, mod_columna, mod_escalon, mod_viga [M]
- [x] Definir dimensiones de encastre voxel para cada pieza [M]
- [x] Definir origen inferior-izquierdo (0,0,0) común [S]
- [x] Definir derivados como variantes de material (madera/piedra) [M]
- [x] Documentar compatibilidad con M17 (construcción) y M24/M25/M26 (templos/ruinas) [M]

## M. RF12 — Categorías cubiertas

- [x] Definir carpeta characters/ (jugador) [S]
- [x] Definir carpeta npc/ (aldeanos M19) [S]
- [x] Definir carpeta animals/ (fauna M36) [S]
- [x] Definir carpeta buildings/ (casas M18) [S]
- [x] Definir carpeta furniture/ (muebles) [S]
- [x] Definir carpeta tools/ (herramientas M13) [S]
- [x] Definir carpeta vehicles/ (barcos M67, carretas) [S]
- [x] Definir carpeta vegetation/ (M50) [S]
- [x] Definir carpeta props/ (rocas, setas, cajas, faroles) [S]
- [x] Definir carpeta ruins/ (M25) [S]
- [x] Definir carpeta temples/ (M24/M26) [S]
- [x] Definir carpeta decorations/ (decorativos) [S]
- [x] Definir carpeta interactives/ (interactivos M70) [S]

## N. RF13 — Catálogo de assets

- [x] Definir asset_catalog.json con: asset_id, categoría, bioma, estado, dueño, prioridad, deps [M]
- [x] Definir estados: planned → made → reviewed → imported [S]
- [x] Definir consultas por categoría y bioma [S]
- [x] Documentar que el runtime usa el catálogo, nunca paths directos [M]

## O. RF14 — Validación automática

- [x] Definir script validate_mesh.gd en Assets/_Project/Editor/ [M]
- [x] Verificar escala 1:1 (< 1e-3) [S]
- [x] Verificar techos de tris por categoría [S]
- [x] Verificar topología (n-gons, vértices duplicados) [S]
- [x] Verificar UVs (fuera de rango, padding) [S]
- [x] Verificar origen Y=0 para props de suelo [S]
- [x] Verificar existencia de LODs si tris > 500 [S]
- [x] Acumular errores (no morir en el primero) y emitir mensajes accionables [M]

## P. RF15 — Convenciones de nombres

- [x] Definir prefijos por categoría: chr_, npc_, ani_, bld_, furn_, tool_, veh_, veg_, prop_, ruin_, temple_, dec_, int_ [S]
- [x] Alinear convenciones con M108 (Pipeline de Assets) [M]
- [x] Documentar regla de nombres de variantes (sufijo _c1, _c2...) [S]

## Q. RF16 — Presupuesto por escena

- [x] Definir que los draw calls y vertexes por escena respetan M61 [M]
- [x] Documentar límites de assets visibles por escena tipo (pueblo, bosque, templo) [M]
- [x] Definir regla de clama de LODs por distancia (M63) [M]

## R. RF17 — Revisión de asset (asset review)

- [x] Definir checklist obligatorio previo a importar: estilo, métricas, topología, UVs, LOD, nombres [M]
- [x] Definir responsable de review (dirección de arte) [S]
- [x] Documentar revisión de paleta por bioma en cada asset [S]
- [x] Documentar que los assets IA pasan la misma review (M86) [M]

## S. RF18 — Integración con el mundo

- [x] Definir declaración de bioma/paleta por asset [S]
- [x] Definir alineación a grilla de props voxel-adjacent [S]
- [x] Documentar compatibilidad con generación procedural (M10 no crea assets, solo los coloca) [M]

## T. Requisitos no funcionales

- [x] Coherencia visual entre islas y artistas (guía única + review) [M]
- [x] Rendimiento: techos verificados por script, LOD por distancia [M]
- [x] Mantenibilidad: kit modular, variantes, catálogo central [M]
- [x] Herramienta gratuita: Blender sin costos de licencia [S]
- [x] Compatibilidad Godot: glTF 2.0 bien formado [M]
- [x] Escalabilidad a contenido futuro (islas, DLC) sin renegociar estándares [M]
- [x] Accesibilidad visual (M58): siluetas legibles, sin flicker [M]
- [x] Documentación viva versionada con Git LFS (M06) [M]

## U. Alternativas consideradas

- [x] Descartar Maya/3ds Max por costo innecesario [S]
- [x] Adoptar Blender por gratuidad, estándar indie, MCP y glTF nativo [S]
- [x] Descartar salida final directa de IA (inconsistencia + legal M85/M86) [M]
- [x] Descartar mallas únicas por objeto (costo y draw calls) [M]
- [x] Descartar ausencia de LOD en arte (gastaría presupuesto M61) [M]
- [x] Descartar texturas embebidas en malla (doble memoria M62) [M]

## V. Riesgos y mitigaciones

- [x] Documentar riesgo de inconsistencia de estilo (mitigación: guía + review) [M]
- [x] Documentar riesgo de assets sobredimensionados (mitigación: validador) [M]
- [x] Documentar riesgo de error de escala (mitigación: validador) [M]
- [x] Documentar riesgo de cuello de botella de producción (mitigación: kit modular) [M]
- [x] Documentar riesgo de assets IA inconsistentes (mitigación: base + review) [M]
- [x] Documentar riesgo de binarios que rompen el repo (mitigación: Git LFS) [M]

## W. Integraciones

- [x] Documentar integración con M04 (Godot + Voxel Tools) [S]
- [x] Documentar integración con M08 (voxel 1 m, atlas de bloques) [S]
- [x] Documentar integración con M11/M19 (sockets, proporciones) [S]
- [x] Documentar integración con M13 (socket_mano) [S]
- [x] Documentar integración con M17/M18 (kit modular, casas) [M]
- [x] Documentar integración con M24/M25/M26 (templos/ruinas) [M]
- [x] Documentar integración con M47 (materiales en Godot) [S]
- [x] Documentar integración con M48 (rigging/animaciones) [S]
- [x] Documentar integración con M50/M51 (vegetación, agua) [S]
- [x] Documentar integración con M61/M62 (LOD, memoria) [S]
- [x] Documentar integración con M63 (LODs por distancia) [S]
- [x] Documentar integración con M108 (importación) [S]
- [x] Documentar integración con M06 (Git LFS) [S]

## X. Herramientas y flujos

- [x] Documentar flujo completo de creación de asset (modelador → validador → review → import) [M]
- [x] Documentar flujo del validador (check acumulado de errores) [M]
- [x] Documentar uso de blender-mcp y IA como base con review humana [M]
- [x] Documentar convención de no embeker texturas en .glb [M]
- [x] Documentar configuración de PBR Metallic-Roughness y resolución 2K máx [M]

## Y. Criterios de aceptación verificados

- [x] Tres assets de prueba pasan validate_mesh.gd y se ven armónicos en Aurora [M]
- [x] Personaje 1.8 m con punto de apoyo en grilla voxel [M]
- [x] Conteo de tris por categoría menor o igual a la tabla RF4 [M]
- [x] Prop con UVs fuera de padding o n-gons rechazado con mensaje accionable [M]
- [x] Edificio >500 tris con LOD1/LOD2 configurados [M]
- [x] Variantes de color implementadas como material (no malla duplicada) [M]
- [x] Kit modular arma una casa M17 sin piezas nuevas [M]
- [x] Assets del catálogo cumplen M108 y Git LFS [M]

## Z. Notas finales

- [x] Documentar el desfase de numeración entre plan maestro (44=ARTE 3D) y tabla global (45=Arte 3D) [S]
- [x] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [x] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]