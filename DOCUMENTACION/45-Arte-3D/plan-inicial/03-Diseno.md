**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 45: Arte 3D

## 1. Arquitectura

El arte 3D no es un sistema de runtime: es un **conjunto de estándares, herramientas de editor y contenido**. La arquitectura se organiza en:

```
[Contenido — Assets/]
Assets/_Project/Models/
├── characters/     (chr_*)      → jugador, NPCs
├── animals/        (ani_*)      → fauna de Aurora
├── buildings/      (bld_*)      → casas, cobertizos, granja
├── furniture/      (furn_*)     → muebles del hogar
├── tools/          (tool_*)     → herramientas (M13)
├── vehicles/       (veh_*)      → barcos, carretas
├── vegetation/     (veg_*)      → árboles, arbustos (M50)
├── props/          (prop_*)     → rocas, setas, cajas, faroles
├── ruins/          (ruin_*)     → piezas de ruinas (M25)
├── temples/        (temple_*)   → kit de templos (M24/M26)
├── decorations/    (dec_*)      → decorativos del mundo
└── interactives/   (int_*)      → objetos interactivos (M70)

[Herramientas de editor — Assets/_Project/Editor/]
validate_mesh.gd          → validador de assets al importar
asset_catalog.gd          → gestor del catálogo (RFC 13)
generate_lod.gd           → helper de generación de LODs

[Documentación viva]
Docs/ART_STYLE_3D.md      → guía de estilo única (RF1)
```

Todo lo que es contenido (mallas, materials, atlas) vive en `Assets/`; todo lo que es lógica de editor vive en `Assets/_Project/Editor/`. El runtime jamás referencia archivos de modelo directamente por path: usa el **catálogo de assets** (RF13) y el sistema de recursos de M108.

## 2. Diagramas de Flujo (texto)

### 2.1 Flujo de creación de un asset (modelador)

```
modelador elige categoría en ART_STYLE_3D.md (RF1)
  → consulta tabla de métricas (RF4: tris, escala, LOD)
  → modela en Blender (.blend) siguiendo topología/UVs (RF5/RF6)
  → exporta glTF 2.0 (.glb) con escala real 1:1, origen en socket_suelo
  → coloca el archivo en la carpeta de su categoría (RF15)
  → ejecuta validate_mesh.gd en Godot editor
      ├─ errores → corrige (mensajes accionables) → revalida
      └─ OK
  → registra en asset_catalog (RFC 13) con estado "reviewed"
  → asset review humano (RF17): estilo + paleta aprobados
  → estado "imported" → disponible para escenas (M108)
```

### 2.2 Flujo del validador (validate_mesh.gd)

```
al importar un .glb (M108):
  → verifica escala: |escala_mesh - 1.0| < 1e-3 ?
  → verifica cantidad de triángulos <= techo de la categoría (RF4)?
  → verifica topología: hay n-gons? vértices duplicados? (RF5)
  → verifica UVs: fuera de 0..1? (RF6) salvo atlas marca atlas_padding
  → verifica origen del eje Y en socket_suelo si aplica
  → verifica existencia de LODs si tris > 500 (RF9)
  → emite lista de errores acumulada (no muere en el primero)
  → si OK: emite advertencias opcionales (padding UV bajo, etc.)
  → registra resultado en catálogo (RF13)
```

## 3. Tablas de Métricas (técnico)

### 3.1 Techos de polígonos (LOD0) — resumen ejecutivo

| Categoría | Tris máx | LOD obligatorio | LOD1 (≈50%) | LOD2 (≈20%) |
|---|---|---|---|---|
| chr_ (jugador) | 8 000 | No (bajo presupuesto, cercano) | — | — |
| npc_ | 6 000 | No | — | — |
| ani_ pequeño | 2 500 | >500 tris? sí | sí | sí |
| ani_ grande | 4 500 | sí | 2 250 | 900 |
| bld_ pequeño | 8 000 | sí | 4 000 | 1 600 |
| bld_ grande | 15 000 | sí | 7 500 | 3 000 |
| furn_ | 800 | no | — | — |
| tool_ | 600 | no | — | — |
| veh_ barco | 12 000 | sí | 6 000 | 2 400 |
| veh_ carreta | 6 000 | sí | 3 000 | 1 200 |
| veg_ árbol | 3 000 | sí | 1 500 | 600 |
| prop_ pequeño | 200 | no | — | — |
| prop_ mediano | 1 200 | no | — | — |
| ruin_ | 14 000 | sí | 7 000 | 2 800 |
| temple_ | 14 000 | sí | 7 000 | 2 800 |
| dec_ | 800 | no | — | — |

### 3.2 Distancias base de LOD

| Categoría | LOD1 @ | LOD2 @ |
|---|---|---|
| prop_/dec_/furn_ | 15 m | 40 m |
| bld_/ruin_/temple_ | 25 m | 60 m |
| veg_ | 30 m | 80 m |
| veh_ | 20 m | 60 m |

### 3.3 Escala y proporciones

| Elemento | Medida |
|---|---|
| Voxel | 1 m³ (M08) |
| Personaje (jugador) | alto 1.8 m, ancho 0.6×0.6 (M11) |
| NPC | alto 1.7-1.8 m (proporción chibi suave) |
| Animales pequeños | 0.3-0.5 m |
| Animales grandes | 1.2-1.8 m |
| Puertas (edificios) | 2 m de alto × 1 m de ancho |
| Ventanas | 1×1 m (integrables a pared voxel 1×1×2) |
| Muebles | múltiplos de 1 m en planta (0.5 solo excepciones) |

### 3.4 Sockets estándar

| Socket | Ubicación | Uso |
|---|---|---|
| `socket_suelo` | pie/origen | apoyo, interacción |
| `socket_mano` | mano derecha | herramientas (M13) |
| `socket_mano_izq` | mano izquierda | objetos a dos manos |
| `socket_cabeza` | vértice cabeza | sombreros, accesorios |
| `socket_corazon` | pecho (1.1 m) | flotación regalos (M20) |
| `socket_lomo` | lomo animales | montura (M67) |
| `socket_puerta`, `socket_ventana`, `socket_piso` | marcos | puertas/ventanas (M17) |

## 4. Convenciones de Materiales y Texturas (resumen, detalle en M47)

- El mesh exporta **materials slots vacíos nombrados** (`mat_body`, `mat_madera`, `mat_metal`); el texturizado se hace en Godot con atlas de M47.
- No embeker texturas en el `.glb` (peso y memoria, M62).
- Atlas de bloques: los props "voxel" usan el atlas de bloques del terreno (M08) con `atlas_uv`; los modelados estilizados usan atlas propios de la categoría.
- PBR: Metallic-Roughness (glTF), texturas de 2K máx (1K para props), compresión según M108.

## 5. Kit Modular (RF11)

Piezas estándar compatibles con construcción (M17) y templos (M24/M26), todas de encastre voxel:

| Pieza | Dimensiones | Observaciones |
|---|---|---|
| `mod_pared1` | 1×1×2 | muro sólido |
| `mod_pared_ventana` | 1×1×2 | con hueco ventana 0.6×0.6 |
| `mod_pared_puerta` | 1×1×2 | con marco puerta |
| `mod_piso` | 1×1×0.2 | losa |
| `mod_techo` | 2×1×0.3 | con voladizo 0.2 |
| `mod_columna` | 0.25×1×0.25 | refuerzos torre |
| `mod_escalon` | 1×0.5×0.5 | escalera a 2 m |
| `mod_viga` | 2×0.1×0.1 | vigas visibles |

- Todos comparten origen inferior-izquierdo (0,0,0) y enrasan con la grilla voxel.
- Derivados (color, madera vs piedra) son variantes de material.

## 6. Integraciones Clave

| Módulo | Integración |
|---|---|
| M04 (Godot) | Formato glTF 2.0, importación nativa, Compatible con Voxel Tools |
| M08 (Voxel) | Escala 1 m, alineación de props a grilla, atlas de bloques |
| M11/M19 | Sockets y proporciones de personaje/NPC |
| M13 | Sockets de herramientas (`socket_mano`) |
| M17 | Kit modular (sección 5) |
| M24/M25/M26 | Piezas `temple_`/`ruin_` modulares |
| M47 | Materiales/texturas en Godot (slots) |
| M48 | Rigging y animaciones (sockets, huesos) |
| M50/M51 | Meshes de vegetación y agua |
| M61/M62 | LOD, presupuesto de tris, memoria de texturas |
| M63 | Activación de LODs por distancia |
| M108 | Pipeline de importación, convenciones, optimización |
| M06 | Git LFS para binarios |