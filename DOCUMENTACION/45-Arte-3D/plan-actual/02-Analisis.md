**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 45: Arte 3D

## 1. Análisis del Dominio

El dominio del arte 3D de Aurora se descompone en diez subsistemas interconectados:

### 1.1 Estilo: "Cozy Voxel" (voxel + low-poly redondeado)
- **Dominio:** el mundo es voxel (M08), pero los entes vivientes y props tienen modelado estilizado tradicional. El estilo combinado ("Cozy Voxel") define:
  - Bloques del terreno: caras rectas, esquinas redondeadas solo en vegetación/props (M50/M17).
  - Personajes/NPCs/animales: siluetas redondeadas, cabezas grandes, extremidades cortas y gruesas (proporciones chibi suaves), sin dedos ni detalles finos.
  - Edificios/muebles: ortogonales como el voxel, con chaflanes suaves en bordes expuestos.
- **Regla de oro:** el ojo humano debe leer "el mismo juego" en un bloque de tierra y en un NPC; la paleta y el redondeo son el pegamento.

### 1.2 Software y formato
- **Dominio:** Blender es el estándar de facto de la industria indie: gratuito (GPL), scripting en Python, conectores MCP (`blender-mcp`) para asistencia IA, exportación nativa glTF 2.0.
- **Alternativas evaluadas:** Blender (adoptado), Maya/3ds Max (pagados, innecesarios), Wings3D/Hexagon (limitados), herramientas procedurales de IA (Rodin, Meshy — útiles como base, no como salida final directa; ver 1.10).
- **Formato fuente:** `.blend`; **formato de importación:** glTF 2.0 (`.glb` para runtime); Godot 4.x importa glTF con slots de animación y sockets.

### 1.3 Escala y alineación a grilla
- **Dominio:** la métrica del mundo es el voxel de 1 m (M08). Todo asset 3D debe mantener:
  - Unidad Blender = 1 m (aplicar scale 1:1; jamás importar con escala 1.3, 0.5).
  - Punto de apoyo en el origen (Y=0) para props que se apoyan en el suelo.
  - Alineación a grilla: si un prop debe calzar en un voxel (1x1x1, 2x2x4), sus dimensiones son múltiplos enteros de 1 m.
  - Personaje: 1.8 m (M11, hitbox 0.6x1.8), cabeza ~0.35-0.4 m de alto, ojo de cámara ~1.55 m.
- **Riesgo típico:** assets importados a otra escala; el validador (RF14) corrige esto automáticamente.

### 1.4 Techo de polígonos por categoría
- **Dominio:** el presupuesto de frame (M61) exige límites duros por categoría de asset. Tabla base:

| Categoría | Tris máx (LOD0) | Notas |
|---|---|---|
| Personaje jugador | 8 000 | + 2 000 para accesorios equipados |
| NPC (aldeano) | 6 000 | Variantes por material (ropa/skin) |
| Animal pequeño | 2 500 | Pájaros, peces: 1 200 |
| Animal grande | 4 500 | Caballos, bueyes |
| Edificio pequeño | 8 000 | Casa de 1 piso, cobertizo |
| Edificio grande | 15 000 | Ayuntamiento, granja principal |
| Mueble | 800 | Mesas, sillas, camas |
| Herramienta | 600 | Joyas, motivos decorativos |
| Barco | 12 000 | Barco del jugador |
| Vehículo | 6 000 | Carretas, globo |
| Vegetación (árbol) | 3 000 | Con LOD fuerte (ver 1.7) |
| Prop pequeño | 200 | Rocas, setas, cajas |
| Prop mediano | 1 200 | Carteles, faroles, bancos |
| Ruinas/Templo | 14 000 | Pieza modular, no malla única |

- **Clave:** los máximos son por *malla visible*, no por asset total (un árbol con 3 mallas de 1 000 tris cuenta 3 000).

### 1.5 Topología y UVs
- **Dominio:** requisitos verificables en editor:
  - Solo quads y tris (n-gons prohibidos) — son los que rompen los cálculos de normales/sombreado suave y a veces producen artefactos en Godot.
  - Vértices soldados (sin duplicados), normales orientadas hacia afuera, escala aplicada (apply scale).
  - UVs: sin capas superpuestas salvo atlas intencional (albedo con atlas de bloques M47), dentro del cuadrado 0-1, padding de textura ≥4 px (mipmapping), density uniforme por categoría (ej: 512 px/m para personajes, 256 px/m para props).
  - Los materiales se asignan en Godot (M47) vía slots; la malla no debe traer texturas embebidas al importarlas (evita doble carga).
- **Riesgo típico:** n-gons en superficies planas grandes (se aceptan *solo* en planos invisibles).

### 1.6 Sockets y punto de anclaje
- **Dominio:** los puntos de unión (sockets) habilitan animación (M48) e interacción (M70):
  - `socket_suelo` (pie, origen), `socket_mano` (mano derecha — herramienta), `socket_mano_izq`, `socket_corazon` (flotación de corazones/regalos), `socket_cabeza` (sombreros), `socket_lomo` (montura), `socket_puerta`, `socket_ventana`.
  - Convención: nodos vacíos (Empty) con esos nombres exactos, escala 1, sin rotación curiosa.
  - Los slots en glTF se conservan al importar en Godot.

### 1.7 LOD (Level of Detail)
- **Dominio:** obligatorio para assets grandes (RF9) consistente con el terreno voxel (Voxel Tools ya genera LOD con Transvoxel para el mundo; el arte 3D aporta el LOD de meshes).
  - Regla: si el mesh > 500 tris → LOD1 (≈50%) y LOD2 (≈20%) obligatorios.
  - Distancias base: LOD1 a 15 m el prop, 25 m el edificio, 30 m el árbol; LOD2 a 40/60/80 m.
  - Los LODs se generan por decimación (Decimate > Collapse 0.5/0.3) y se exportan como variantes glTF (`lod0`... `lod2`), no como assets separados en disco.
  - La cámara (M12) clama el radio de carga; el modulo 63 (Cargas y Streaming) activa/desactiva LODs por distancia.

### 1.8 Variantes por material y kit modular
- **Dominio:** el costo de un asset bajo (M61/optimización) se logra con **variantes por material** (recolor en M47) en lugar de múltiples mallas: un mismo modelo de silla con 4 colores = 1 malla + 4 materiales.
  - Límite sugerido: ≤6 variantes por malla en color; si se necesitan más → reutilizar otra malla o pedir aprobación.
- **Kit modular (RF11):** piezas estándar de construcción que consumen M17/Templos (M24/M25): pared (1x1x2), pared con ventana, piso (1x1), techo, escalera, columna, puerta. Reglas: encastre perfecto en voxels, 0 overlap, izq/der simétricas.

### 1.9 Catálogo y nombres
- **Dominio:** `Assets/docs/asset_catalog.md` (o `asset_catalog.tres`) centraliza: id único, categoría, bioma, estado (planned/made/reviewed/imported), dueño, prioridad, deps. Prefijos de nombre según M108 (`chr_`, `npc_`, `ani_`, `bld_`, `furn_`, `tool_`, `veh_`, `veg_`, `prop_`, `ruin_`, `temple_`, `dec_`). Git LFS (M06) trackea `.blend` y `.glb`; los binarios grandes jamás al repo normal.

### 1.10 IA asistiva para modelado
- **Dominio:** el plan de producción autoriza IA para tareas repetitivas (retopología, UV unwrap, variantes) y desaprueba salida final directa sin revisión humana. Herramientas: `blender-mcp` (creación por lenguaje natural), Rodin/Meshy (base mesh que luego se retopologiza y reestiliza a mano). **Regla:** todo asset generado por IA pasa la misma asset review (RF17) y queda declarable según M86/M85 si llega al juego.

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| Maya / 3ds Max | **Descartado** | Pagos, misma capacidad; innecesarios para este estilo |
| Blender | **Adoptado** | Gratuito, estándar indie, Python/MCP, glTF nativo |
| Modelos de IA directos (salida final) | **Descartado** | Inconsistencia de estilo, topología mala, conflictos M85/M86; se usan como base únicamente |
| Mallas únicas por objeto | **Descartado** | Costo de producción y draw calls; se prioriza variantes + kit modular |
| Sin LOD en arte (solo voxel) | **Descartado** | Los edificios/árboles gastarían el presupuesto de M61 |
| Texturas embebidas en malla | **Descartado** | Doble memoria (M62), pierde control de atlas (M47) |

## 3. Decisiones del Módulo

1. **Blender es la herramienta canónica** con exportación glTF 2.0 (`.glb`).
2. **El estilo es "voxel + low-poly redondeado"**: bloques rectos, vivientes redondeados, paleta pastel por bioma (M09).
3. **Escala 1:1 con el voxel 1 m** (M08); personaje 1.8 m (M11).
4. **Tabla de techos de polígonos** verificable por script (RF14).
5. **LOD obligatorio >500 tris** con distancias base definidas.
6. **Variantes por material, kit modular y catálogo central** como estrategia anti-costo.
7. **Validador en editor** como puerta de entrada: no se importa nada que no pase `validate_mesh.gd`.

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Inconsistencia de estilo entre islas/artistas | Alta | Alto | Guía de estilo única + asset review (RF17) + paleta por bioma |
| Assets sobredimensionados en polígonos | Media | Alto | Validador automático + LOD obligatorio + tabla RF4 |
| Importación a escala errónea | Alta | Medio | Validador (check escala 1:1) + convención de exportación documentada |
| Cuello de botella de producción (muchos assets únicos) | Alta | Alto | Kit modular, variantes, catálogo con prioridades y dueños |
| Assets IA inconsistentes | Media | Medio | Uso solo como base + review humana + declaración M86 |
| Archivos binarios que rompen el repo | Media | Medio | Git LFS trackeado desde el día 1 (M06) |