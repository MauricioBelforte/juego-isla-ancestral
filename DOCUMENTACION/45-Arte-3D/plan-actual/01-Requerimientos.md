**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 45: Arte 3D

## ID del Módulo
- **Código:** M45 (CHECKLIST-GLOBAL: ID 45 — Arte 3D; plan maestro: sección 44 "ARTE 3D")
- **Carpeta:** `DOCUMENTACION/45-Arte-3D/`
- **Dependencias:** M08 (Mundo Voxel — métrica de bloques y chunks), M04 (Game Engine — Godot 4.x + Voxel Tools), M09 (Terreno y Geografía — biomas), M11 (Personaje), M19 (NPC y Vecinos), M05 (Lenguaje — convenciones). Relaciones: M47 (Texturas y Materiales), M48 (Animación), M49 (Iluminación), M50 (Vegetación), M51 (Agua), M108 (Pipeline de Assets), M61 (Rendimiento), M06 (Git LFS)
- **Delegable desde:** M04 (motor confirmado), M08 (métrica voxel), M09 (biomas y paletas), M17 (construcción — props de construcción)

## 1. Problema

Aurora es un mundo voxel cozy: el terreno (M08/M09) se construye con bloques de 1 m³ y el jugador interactúa con personajes (M11/M19), construcciones (M17) y objetos. Sin una dirección de arte 3D definida, cada asset modelado corre el riesgo de sentirse de un juego distinto: proporciones que no calzan con el voxel, polígonos desmedidos que rompen el presupuesto de rendimiento (M61), topologías inutilizables, UVs incorrectas o escala inconsistente entre un árbol, un mueble y un NPC. El plan de producción lo advierte explícitamente: sin una guía de estilo 3D previa, "cada isla nueva corre el riesgo de sentirse hecha por un equipo distinto". Un pipeline de arte 3D disciplinado es la diferencia entre la estética cozy coherente que distingue al juego y un conjunto genérico de assets.

## 2. Objetivo

Definir el sistema de arte 3D del juego: guía de estilo (estilo voxel redondeado + low-poly, paleta pastel por bioma), métricas y restricciones técnicas por categoría (personajes, NPCs, animales, edificios, muebles, herramientas, vehículos, vegetación, props, ruinas, templos, decorativos, interactivos), límites de polígonos y de assets por escena, topología y UVs válidas para Godot 4.x, convenciones de escala, LODs, banco de assets reutilizables y herramientas (Blender como estándar). El resultado debe ser un catálogo de requisitos verificables que cualquier modelador —humano o asistido por IA— pueda cumplir sin ambigüedad, manteniendo la armonía visual con el mundo voxel y el presupuesto de rendimiento.

## 3. Alcance

### 3.1 Dentro del alcance
- Guía de estilo 3D: combinación voxel + low-poly redondeado, reglas de silueta y proporción.
- Software estándar: Blender (gratuito, evaluado frente a alternativas), con conectores MCP opcionales para asistencia por IA.
- Métricas por categoría: polígonos máximos, escala, proporciones y requisitos de topología de personajes, NPCs, animales, edificios, muebles, herramientas, barcos, vehículos, vegetación, props, ruinas, templos, decorativos e interactivos.
- Convenciones de escala: alineación con la grilla voxel de 1 m (M08) y con la hitbox del jugador (M11).
- Topología, UVs y materiales base: reglas verificables para Godot 4.x (texturas a cargo de M47).
- LOD: estrategia por categoría (niveles y distancias), en convivencia con los LODs del terreno voxel (Transvoxel, M08/M61).
- Variantes: límites de variantes por asset (color/skin/malla) y reutilización de materiales (M47).
- Assets reutilizables: sistema de componentes (kit modular) compartidos entre prop, construcción y templos.
- Integración: nombres y convenciones de carpetas (M108), respeto del presupuesto de draw calls (M61), integración con Git LFS (M06).
- Validación: checklist de revisión de asset (asset review) previo a la importación.

### 3.2 Fuera del alcance
- Texturas y materiales de superficie: pertenecen a M47 (Texturas y Materiales).
- Animaciones y rigging: pertenecen a M48 (Animación).
- Iluminación y post-procesado: pertenecen a M49.
- Vegetación procedural de terreno y agua: M50 y M51 consumen meshes definidos aquí, pero su lógica es de esos módulos.
- Pipeline de importación/optimización de Godot: M108 (Pipeline de Assets).
- Generación procedural de mallas: M10 (Generación del Mundo) y M08.
- El software y licencias de las herramientas: aquí solo se define la evaluación; las licencias se tratan en M85 (Modelos 3D — Legal).

## 4. Restricciones

- **Motor:** Godot 4.x (>= 4.4.1), formato glTF 2.0 para importación de mallas; .blend como fuente editable.
- **Coherente con voxel:** ningún asset 3D puede contradecir la métrica de voxels de 1 m (M08); los props se alinean a la grilla.
- **Cozy:** siluetas redondeadas, proporciones amables (cabezas grandes en personajes, angulos suaves), sin detalles agresivos.
- **Rendimiento:** categorías con techos de polígonos; el conteo total de vertexes por escena respeta M61; LOD obligatorio para assets grandes.
- **Reutilización:** kit modular y variantes por material antes que mallas únicas por objeto.
- **Determinismo visual:** guía de estilo única; no se modela sin consultar la categoría correspondiente.
- **Data-driven:** los assets son contenido (no código); los puntos de anclaje (sockets) siguen convenciones de nombres.
- **Validable:** cada asset pasa una revisión con checklist (sección 5) antes de importarse al proyecto.
- **Sin red:** todo local; sin dependencia de servidores de assets en runtime.

## 5. Requisitos Funcionales

| # | Requisito | Detalle |
|---|---|---|
| RF1 | Guía de estilo única | Documento vivo `ART_STYLE_3D.md` con reglas de silueta, proporción, redondeo y paleta por bioma |
| RF2 | Software estándar | Blender como herramienta canónica; formato fuente `.blend`, salida glTF 2.0 |
| RF3 | Escala unificada | Unidad Blender = 1 m; alineación a grilla voxel de 1 m (M08); personajes ~1.8 m como M11 |
| RF4 | Techo de polígonos por categoría | Tabla de máximos: personaje ≤8k tris, prop pequeño ≤200 tris, edificio ≤15k tris, etc. |
| RF5 | Topología válida | Sin n-gons (solo quads/tris), sin vértices duplicados no soldados, normales consistentes |
| RF6 | UVs válidas | Sin superposición (excepto atlas intencional), dentro de 0..1, padding ≥4px, texel density por categoría |
| RF7 | Origen y orientación | Origen del mesh en punto de anclaje convencional; +Z frente (o +X según convención Godot), Y arriba |
| RF8 | Sockets de anclaje | Puntos de unión con nombres convencionales (`socket_mano`, `socket_corazon`, `socket_suelo`) para M48/M70 |
| RF9 | LOD por categoría | Definición de LOD0/LOD1/LOD2 con distancias por categoría; LOD obligatorio si >500 tris |
| RF10 | Variantes por material | Máximo N variantes por mesh vía material/M47 (recolor), no duplicando la malla |
| RF11 | Kit modular | Componentes reutilizables (paredes, techos, muebles, decoración) compatibles con M17 y M24/M25 |
| RF12 | Categorías cubiertas | Personajes, NPCs, animales, edificios, muebles, herramientas, barcos, vehículos, vegetación, props, ruinas, templos, decorativos, interactivos |
| RF13 | Catálogo de assets | Inventario central (`Assets/docs/asset_catalog.tres` o MD) con estado, dueño y prioridad de cada asset |
| RF14 | Validación automática | Script `validate_mesh.gd` (editor) que verifica escala, tris, UVs, origen y normales al importar |
| RF15 | Convenciones de nombres | Prefijos por categoría (`chr_`, `npc_`, `ani_`, `bld_`, `furn_`, `tool_`, `veh_`, `veg_`, `prop_`, `ruin_`, `temple_`) según M108 |
| RF16 | Presupuesto por escena | Draw calls y vertexes por escena limitados por M61; el arte 3D declara límites de assets visibles |
| RF17 | Revisión de asset (asset review) | Checklist obligatorio antes de importar: estilo, métricas, topología, UVs, LOD, nombres |
| RF18 | Integración con el mundo | Los assets declaran su bioma/paleta; los props voxel-adjacent se alinean a la grilla 1 m |

## 6. Requisitos No Funcionales

- **Coherencia visual:** un mismo criterio aplicado a Aurora y a todas las islas futuras; revisión por pares de cada asset.
- **Rendimiento:** techos de polígonos verificados automáticamente; el arte nunca supera el presupuesto de M61.
- **Mantenibilidad:** kits modulares y variantes por material minimizan assets únicos; catálogo central actualizado.
- **Herramienta gratuita:** Blender (GPL) sin costos de licencia; flujos documentados para modeladores y asistencia IA.
- **Compatibilidad Godot:** glTF 2.0 bien formado (mismatch de ejes resuelto en import, no en malla).
- **Escalabilidad:** las reglas aplican igual al contenido futuro (islas nuevas, DLC) sin renegociar estándares.
- **Accesibilidad visual (M58):** siluetas legibles, sin parpadeo auto-flicker, sin patrones de alto contraste agresivos.
- **Documentación:** guía de estilo viva; versionada junto al código (Git LFS para binarios, M06).

## 7. Criterios de Aceptación

1. Tres assets de prueba (personaje, prop, edificio) pasan el `validate_mesh.gd` sin errores y se ven armónicos en Aurora junto al terreno voxel.
2. Un personaje modelado según RF3 mide ~1.8 m y su punto de apoyo calza con la grilla voxel (M08) sobre suelo plano.
3. El conteo de triángulos de cada categoría no excede la tabla de RF4 (verificado por el validador).
4. Un prop con UVs fuera del padding o n-gons es rechazado por el validador con mensajes accionables.
5. Un edificio con >500 tris tiene LOD1/LOD2 configurados y las distancias respetan la tabla de RF9.
6. Dos muebles iguales de diferente color se implementan como variante de material (M47), no como malla duplicada.
7. El kit modular de paredes (RF11) permite ensamblar una casa M17 sin modelar piezas nuevas.
8. Todos los assets del catálogo (RF13) cumplen convenciones de nombres de M108 y quedan trackeados en Git LFS.

## 8. Fuentes de Contexto (plan maestro)

- Sección 44 "ARTE 3D": software, estilos (low-poly, voxel, redondeado), polígonos máximos, escala, topología, UV, materiales, LOD y todas las categorías de creación.
- Plan de producción §4: pipeline de arte y contenido 3D — dirección de arte, paleta por bioma, "Cozy Voxel" con modelado estilizado tradicional, low-poly redondeado, LOD con Transvoxel, Git LFS.
- Plan de producción §5.6: la IA se usa para tareas repetitivas/técnicas; la dirección de arte es humana.
- Principios innegociables (M152): calidad > cantidad, performance prioridad sobre visuales.

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M046** — Arte 2D | Arte 2D |
| **M047** — Texturas y Materiales | Texturas y materiales |
| **M048** — Animación | Animación |
| **M049** — Iluminación | Iluminación |
| **M050** — Vegetación | Vegetación |
| **M052** — Partículas y VFX | Partículas y VFX |
| **M085** — Modelos 3D — Legal | Usado por modelos 3d — legal |
| **M108** — Pipeline de Assets | Pipeline de assets |
| **M130** — Artbook | Usado por artbook |
| **M159** — Catálogo de Objetos | Catálogo de objetos |
| **M161** — Diseño Visual de NPCs | Diseño visual de NPCs |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M046** — Arte 2D | Este módulo lo necesita |
| **M047** — Texturas y Materiales | Este módulo lo necesita |
| **M048** — Animación | Este módulo lo necesita |
| **M049** — Iluminación | Este módulo lo necesita |
| **M050** — Vegetación | Este módulo lo necesita |
| **M052** — Partículas y VFX | Este módulo lo necesita |
| **M085** — Modelos 3D — Legal | Este módulo lo necesita |
| **M108** — Pipeline de Assets | Este módulo lo necesita |

