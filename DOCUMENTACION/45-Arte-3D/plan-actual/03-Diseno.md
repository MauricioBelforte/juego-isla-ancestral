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
## 7. Convenios de carpeta, nombres y límites (doc headless — agnes-3-flash, 2026-10-22, frente COLA A V3)

Cierra los 5 items documentables de M45 (COLA A V3). Los de validación de assets (escala/tris/UV/LOD) quedan bloqueados por `validate_mesh.gd` (MISS) + 0/23 GLB en disco.

### 7.1 Carpeta `npc/` (aldeanos M19)
- Ruta: `assets/models/npc/<rol>/`. Convencion: un subdirectorio por **rol** M19 (no por nombre propio).
- Dentro: `<rol>_<var>_c<N>.<ext>` (var = pose base: idle/walk/emote).
- Enlace M161: el `npc_id` M161 resuelve a la carpeta M45 por **rol/profesion** (campo `rol`), no por nombre propio M19.

### 7.2 Regla de nombres de variantes (sufijo `_c1`, `_c2`...)
- Sufijo `_c<N>` = variante cromatica/estacional (RF5/RF6). `c1` = base, `c2..cN` = variantes.
- Limite: **max 6 variantes por malla** (RF5); exceder = deuda `[?]` (no se crea).
- El sufijo NO cambia la topologia: misma malla, distinto material/textura (§4).

### 7.3 Límites de assets visibles por escena
- Presupuesto orientativo por tipo (validador de rendimiento = M61): **Pueblo** ≤ 40 assets / 300k tris; **Bosque** ≤ 120 / 500k (M50 LOD); **Templo/interior** ≤ 60 / 200k.
- Por encima del limite: LOD0→LOD3 o culling por distancia (§ M90 CULLING).

### 7.4 Compatibilidad con generación procedural (M10)
- **M10 NO crea assets: solo los COLOCA** (instancia los GLB de M45). M45 produce, M10 instancias.
- Cada asset M45 lleva metadata de colocacion (footprint Y=0 + colision) para colocarse en grilla voxel sin flotar (regla M167: `get_height(x,z)+1`).
- Los assets M45 NO contienen logica de spawn/placement (eso es M10/M15).

## 8. Validación automática de malla (RF14) — implementación headless

Cierra el diseño que el ítem L145 pedía como `[?]` y que el §7 daba por bloqueado.
**Corrección de premisa medida (2026-10-24):** el §7 L171 decía «`validate_mesh.gd`
(MISS) + 0/23 GLB en disco». En disco hay **418 `.glb` en `assets/3d/{alta,media,baja}`**
(`git ls-files 'game/isla-ancestral/assets/3d/*/*.glb'` = 418, todos parseables), no 0/23.

### 8.1 Decisión: por qué no es un `.gd` de editor

RF14 nombra `validate_mesh.gd` en `Assets/_Project/Editor/`, ruta de la era **Unity**
(este proyecto es Godot 4.7.2 y no existe `Assets/_Project/`). Tres razones para un
validador headless sobre el `.glb` exportado:

1. el `.glb` es la **fuente de verdad del runtime** (lo que carga Godot), no el `.blend`;
2. corre en CI sin abrir editor (`quality.yml` no tiene paso de Godot-editor);
3. es determinista y auditable: mide bytes, no estado de UI.

Implementación: `scripts/validar_malla_glb.py` (solo lectura, stdlib pura).

### 8.2 Eje UP: medido, no supuesto

El §7.4 ya habla de «footprint **Y=0**». La medición lo confirma con tres señales
independientes sobre los 418 assets:

| Señal | Y | Z |
|---|---|---|
| ancla en 0 (`min == 0 ± 1e-3`) | 3 | 1 (414 no anclan en ningún eje) |
| contacto en `0.045 ± 0.020` | **66** | **0** |
| extensión mayor en ese eje | 227 | 191 |

Corroboración morfológica: `18-Casas_alfombra.glb` mide `dim=[3.200, 0.038, 3.200]`
(una alfombra es plana en **Y**) y `50-Vegetacion_canas_bambu.glb` mide
`dim=[0.720, 3.145, 0.604]` (una caña es alta en **Y**).
**Conclusión: eje UP = Y.** El valor `0.045` es el mismo que M166 documenta como
`Z_APOYO`, pero sobre Y — ver §8.7 (hallazgo cruzado).

### 8.3 Criterios y clases

| Clase | Nivel | Regla | Medido hoy |
|---|---|---|---|
| `PARSE` | violación | contenedor GLB ilegible | 0 / 418 |
| `SIN_GEOMETRIA` | violación | 0 vértices | 0 / 418 |
| `ESCALA_NO_UNIFORME` | violación | `\|sx-sy\|, \|sy-sz\|, \|sx-sz\| > 1e-3` en la cadena de padres (deforma) | **95** |
| `ESCALA_NO_APLICADA` | aviso | `\|s-1\| > 1e-3` (RF3: aplicar escala en Blender) | 98 |
| `UV_FUERA_RANGO` | violación | `TEXCOORD_0` fuera de `[0,1] ± 1e-4` | **3** |
| `SIN_UV` | aviso | LOD0 sin `TEXCOORD_0` (no texturizable) | 31 |
| `TOPO_DEGENERADO` | violación | triángulo de área `< 1e-12` | **4** |
| `ORIGEN_BAJO_SUELO` | violación | `min_Y < 0` en categoría de suelo (el prop se hunde) | **285** |
| `ORIGEN_SIN_CONVENCION` | aviso | `\|min_Y - 0.045\| > 0.020` sin hundirse | 16 |
| `RF4_EXCEDIDO` | **aviso** | tris > techo RF4 de la categoría **inferida** | 58 |
| `LOD_FALTANTE` | violación | LOD0 con > 500 tris sin homónimo en `media/` o `baja/` (RF9) | **10** |

**Por qué RF4 es aviso y no violación:** la categoría no está declarada por asset.
El catálogo RF13 (`asset_catalog.json`) **no existe en disco** y **0 de 694** `.glb`
cumple el prefijo RF15 (`chr_`, `prop_`, …): el nombre es `<Modulo>_<nombre>.glb`
(`13-Herramientas_pico_hierro.glb`) y la carpeta es el **nivel de LOD**, no el módulo.
La categoría se infiere del prefijo de módulo (§8.4) y esa inferencia falla: una
alfombra (`18-Casas_alfombra.glb`) se inferiría `bld` (techo 15.000) cuando es `furn`
(techo 1.200). Promoverlo a violación sería inventar una categoría que nadie declaró.

**Topología — límite declarado:** glTF 2.0 solo admite `TRIANGLES`/`TRIFAN`/`TRISTRIP`,
así que un **n-gon no puede sobrevivir a la exportación**; el validador mide el proxy
medible (degenerados). La detección de n-gons exige leer el `.blend` fuente y queda
**fuera de alcance** de este validador (declarado, no silenciado).

**Vértices duplicados — no es criterio:** se cuentan (417 / 418 los tienen) pero NO se
reportan como defecto: glTF 2.0 obliga a **partir vértices** por costura de normal y de
UV, porque un vértice no puede tener dos normales. Un aviso aquí sería un falso positivo
en el 100% del corpus.

### 8.4 Categoría RF4 por prefijo de módulo

| Prefijo | Categoría RF4 | Techo LOD0 |
|---|---|---|
| `13-Herramientas` | `tool` | 800 |
| `15-Recursos`, `27-Islas-Ubicaciones`, `35-Mineria`, `45-Arte3D` | `prop` | 200 |
| `16-Crafting` | `furn` | 1.200 |
| `18-Casas`, `40-Infraestructura` | `bld` | 15.000 |
| `19-NPCs` | `npc` | 8.000 |
| `25-Ruinas-Templos` | `ruin` | 12.000 |
| `33-Agricultura`, `50-Vegetacion` | `veg` | 3.000 |
| `36-Fauna` | `ani` | 6.000 |
| `70-Interacciones` | `int` | 1.500 |

Sin coincidencia → `categoria = None` y **no se evalúa RF4** (nunca se adivina).

### 8.5 Cómo se corre

```
python scripts/validar_malla_glb.py              # informe legible
python scripts/validar_malla_glb.py --json       # + tools/legal/malla_glb.json
python scripts/validar_malla_glb.py --check      # exit 1 si hay violaciones
python scripts/validar_malla_glb.py --archivo R  # un solo asset
python scripts/validar_malla_glb.py --selftest   # 27 checks, piso medido
```

Códigos: `0` = sin violaciones · `1` = violaciones · `3` = **validador ciego**
(0 archivos, para que un glob roto no publique un verde).

**No cableado a CI todavía:** `--check` sale **1 hoy** (368 de 418 con violaciones).
Cablearlo sin baseline congelaría un rojo permanente; la decisión (baseline vs. sanear
el corpus primero) es del director.

### 8.6 Medición de la corrida (2026-10-24)

- 418 archivos, **418 parseables**, 237.385 tris, 486.855 vértices.
- **368 con al menos una violación**; 169 con avisos.
- 131 con `TEXCOORD_0` / **287 sin UV**: alta 129/160, media 2/130, baja **0/128**.
- **0 de 1.532 materiales usa `baseColorTexture`**: el corpus es color plano, sin texturas.
  Consecuencia: RF6 (padding ≥ 4 px, texel density) es **vacuo hoy** — no hay nada que
  texturizar — y los LOD1/LOD2 **perdieron las UV** que sí tiene el LOD0.

### 8.7 Hallazgo cruzado (M166 / `scripts/auditar_flotacion_glb.py`)

El auditor de flotación existente mide el componente **Z** (`m[2]`, `t[2]`) mientras el
eje UP del corpus es **Y**. Resultado de su propia corrida: **`ASENTADO = 0` de 694**
archivos — una clasificación imposible si el criterio estuviera bien aplicado. Con el eje
correcto, **66** assets caen en `0.045 ± 0.020`. Las categorías `FLOTA` / `HUNDIDO` /
`ORIGEN-CENTRADO` de ese informe (3 / 495 / 589) no describen altura.
**No se modificó ese script** (pertenece al frente M166): se reporta al director.
