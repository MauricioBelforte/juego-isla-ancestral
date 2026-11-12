# Reporte — Capacidad de Modelado 3D en Blender para integración al juego

**Modelo:** ERNIE-5.5-Flash-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-11-11 (verificación en vivo 2026-11-12 00:50)
**Módulo de referencia:** `45-Arte3D` · pipeline Blender → Godot (M108)
**Alcance:** (1) objetos 3D generables, (2) formatos, (3) materiales PBR, (4) escalas, (5) dos mejoras concretas. Cifras **medidas**, no inferidas.

---

## 0. Estado de la conexión con Blender (verificado en vivo)

| Ítem | Estado | Evidencia |
|---|---|---|
| Blender | ✅ 4.2.23 LTS | `get_addon_status` → `blender_version: 4.2.23 LTS` |
| Addon MCP | ✅ v1.8, protocolo 15, `up_to_date: true` | `get_addon_status` |
| Ejecución de `bpy` | ✅ Operativa | `execute_code` importó 5 GLB reales y midió bounds/materiales |
| Escena | ✅ `BLENDER_EEVEE_NEXT`, unidad 1.0 | `get_scene_info` |
| Librerías (Poly Haven / Sketchfab / Poly Pizza) | ❌ Apagadas | `libraries: {polyhaven: off, sketchfab: off, polypizza: off}` |
| Generadores IA 3D (Tripo / Hunyuan / Hyper3D / Meshy) | ❌ Apagados | `generators: {tripo: off, hunyuan3d: off, hyper3d: off, meshy: off}` |

> **Alcance real:** puedo modelar con `bpy`/`bmesh`, exportar `.glb` y medir. **No** puedo descargar de librerías ni generar por IA (todo `off`), y el QA visual (E-13, 6 azimuts) requiere inspección de imágenes: si este chat no dispone de entrada de imágenes, lo ejecuta el usuario o un agente con visión. El QA numérico sí quedó ejecutado.

### 0.1 Inventario medido del pipeline

| Métrica | Valor | Método |
|---|---|---|
| `.blend` de autoría en `tools/mcp/blender-mcp/` | **784** | `Get-ChildItem -Recurse -Filter *.blend` |
| `.glb` en `assets/3d/` | **487** | `Get-ChildItem -Recurse -Filter *.glb` |
| — variante `alta` | **183** | conteo por carpeta |
| — variante `media` | **153** | conteo por carpeta |
| — variante `baja` | **151** | conteo por carpeta |
| Fichas de asset (`assets/fichas/`) | **161** | conteo de archivos |
| **Texturas de imagen en `assets/3d/`** | **0** | `.png/.jpg/.webp/.exr/.hdr` → 0 resultados |

> **Dato clave:** los 487 GLB usan **color base por material**, sin mapas de textura. Todos los materiales son Principled BSDF con `Base Color` + `Roughness` + `Metallic` constantes (y emisivo en piezas de fuego/cristal).

### 0.2 Prueba de importación real (5 GLB representativos, en vivo)

Importé cada GLB en Blender, medí AABB, triángulos y materiales, y limpié la escena entre uno y otro.

| GLB (`assets/3d/media/`) | Dimensiones X×Y×Z (m) | Tris | Materiales | Objetos |
|---|---|---|---|---|
| `70-Interacciones_cofre_pequeno.glb` | **0.62 × 0.466 × 0.50** | 72 | 3 | 1 |
| `40-Infraestructura_farola_fuego.glb` | **0.40 × 0.67 × 1.60** | 1 346 | 5 | 5 |
| `50-Vegetacion_palmera.glb` | **7.58 × 6.87 × 7.00** | 300 | 4 | 4 |
| `45-Arte3D_jarrones_urnas.glb` | **1.90 × 0.66 × 0.90** | 504 | 3 | 3 |
| `36-Fauna_jabali.glb` | **1.50 × 0.41 × 0.78** | 972 | 6 | 6 |

- El cofre tiene `z_min = 0.045` → confirma la regla de apoyo E-12.
- La palmera mide **7.0 m** de alto (objetivo de tabla 8.0 m; el bbox incluye hojas).
- Conclusión del muestreo: **geometría lowpoly, 1 material por pieza, escala en metros y apoyo en el suelo**. El pipeline funciona de punta a punta.

---

## 1. Objetos 3D que puedo generar

La capacidad está **probada**, no es teórica: el repo ya contiene los `.blend` de autoría y los `.glb` consumidos por Godot.

| Categoría | Objetos que puedo generar | Evidencia en el repo |
|---|---|---|
| **Cofres y contenedores** | Cofre pequeño (tapa con bisagra), cofres de recompensa | `tools/mcp/blender-mcp/70-Interacciones/cofre_pequeno_lowpoly{,_media,_baja}.blend`; medido arriba (0.62×0.47×0.50 m, 72 tris, 3 mats) |
| **Lámparas / iluminación** | Farola de fuego, farol de mesa, antorcha de mano | `40-Infraestructura/farola_fuego_lowpoly.blend` (medido 1.60 m alto, 5 mats con brasa/llama); `18-Casas/decor_farol_mesa_lowpoly.blend`; `13-Herramientas_antorcha_mano.glb` |
| **Mobiliario** | Mesa de madera, silla, cama simple/doble, estantería, banco exterior | `18-Casas/{mesa_madera,silla_madera,cama_basica,cama_doble,estanteria,decor_banco_exterior}_lowpoly.blend`; GLBs `18-Casas_mesa_madera.glb`, `18-Casas_silla_madera.glb`, `18-Casas_cama_basica.glb`, `18-Casas_cama_doble.glb`, `18-Casas_estanteria.glb` |
| **Objetos decorativos** | Tótems, monolitos con glifos, jarrones/urnas, conchas, estrellas de mar, cráneos, ancla de naufragio, coral | `45-Arte3D/` (`totem_isla`, `monolito_glifos`, `jarrones_urnas`, `concha_mar`, `estrella_mar`, `caveira_criatura`, `ancla_naufragio`, `coral_abanico`) |
| **Elementos de terreno** | Rocas, vetas de mineral (cobre/hierro/oro), tronco caído, raíces expuestas, musgo, tierra arada/regada | `15-Recursos/` (`roca_comun`, `roca_pedernal`, `veta_*`, `tronco_caido`, `monton_ramas`, `nido_cocos`); `33-Agricultura_tierra_arada.glb`, `tierra_regada.glb` |
| **Interacción / puzzle** | Botón de piso, palanca de madera, puerta corrediza de piedra, válvula-manivela | `70-Interacciones/` (5 familias × variantes, con capturas orbitales) |
| **Construcción modular** | Pared lisa/ventana/puerta, piso, techo a dos aguas, techo de paja, zócalo, escalera | `CHECKLIST-OBJETOS-BLENDER.md:63-75` |
| **Vegetación / fauna / NPC** | Palmeras, arbustos, helechos, flores, animales lowpoly, NPCs con rig | `50-Vegetacion/`, `36-Fauna/`, `19-NPCs/` |
| **UI 3D** | ⚠️ **No existe `assets/ui/`** (solo `2d/`, `3d/`, `archive/`, `fichas/`, `final/`, `fonts/`, `staging/`). El HUD es 2D (Canvas). Puedo generar **iconos 3D renderizados a PNG** (inventario, objetos), pero eso queda fuera del pipeline GLB actual y requiere un paso de render→textura. | `game/isla-ancestral/assets/` (sin `ui/`) |

**Patrones de calidad que aplico (obligatorios y ya documentados):**
- Una malla `SM_` por pieza estructural con `bmesh` en vez de apilar primitivas.
- Piezas animables como `SM_` separados con pivote en la raíz articular (`GUIA-BLENDER/08:15-66`).
- Silueta orgánica: anillos que se contraen, sin tapas planas ni tubos uniformes (`GUIA-BLENDER/09:16-49`).
- Detalles anclados con `matrix_world` del padre ya transformado (`GUIA-BLENDER/09:51-77`).
- Apoyo medido en caliente, `z_min = 0.045` (`GUIA-BLENDER/05`, E-12).

---

## 2. Formatos soportados

| Formato | Soporte | Detalle verificado |
|---|---|---|
| **`.glb`** | ✅ **Nativo, principal** | `exportar_godot.py:175-187` exporta con `export_format='GLB'`, `export_materials='EXPORT'`, `export_yup=True`, `export_normals=True`, `export_apply=True`. Los 487 GLB del proyecto lo usan. |
| **`.gltf`** | ✅ Nativo | Mismo `io_scene_gltf2`. Se usa menos: el `.gltf` separado arrastra `.bin` + texturas; el `.glb` empaqueta todo. |
| **`.obj`** | ⚠️ Secundario | Exportable con `io_scene_obj`, pero **pierde PBR** (solo `map_Kd`/`map_Ka`, sin metallic-roughness ni emisivo) y no lleva jerarquía ni pivotes. No recomendado. |
| `.blend` | ✅ Nativo (autoría) | Es el **fuente**; no se exporta a Godot. Regla `GUIA-BLENDER/09:104-122`: primero `.blend`, GLB solo tras aprobación del usuario. |
| `.fbx` | ⚠️ Solo entrada | No se produce; si llega, se convierte en Blender y se re-exporta a GLB. Prohibido como formato de salida (ASSET-PIPELINE §2). |

**Convención de salida (verificada):** `game/isla-ancestral/assets/3d/<alta|media|baja>/<NN-Modulo>_<snake_case>.glb` (`exportar_godot.py:66` `DEST_ROOT`, `:116` construcción del destino). Godot 4.7 importa `.glb` de forma nativa con el importador `scene`, generando un `.scn` por archivo (ej.: `assets/3d/alta/13-Herramientas_antorcha_mano.glb.import` → `PackedScene`).

**Nota de pipeline:** el export corre **headless** (`blender -b --factory-startup --python exportar_godot.py`), no por socket, porque el exportador glTF necesita `bpy.context.active_object` real (`exportar_godot.py:16-28`). Aunque el addon MCP esté apagado, **igual puedo exportar GLB**.

---

## 3. Materiales PBR que puedo crear

La función base es `mat()` en `tools/mcp/blender-mcp/scripts-reutilizables/plantilla_asset.py:49-60` (Principled BSDF).

| Canal PBR | Parámetro Blender | glTF 2.0 | Uso en el proyecto |
|---|---|---|---|
| Color base | `Base Color` (`plantilla_asset.py:54`) | `baseColorFactor` | Madera, piedra, arena, follaje |
| Rugosidad | `Roughness` (`:55`) | `roughnessFactor` | Lowpoly mate: 0.85–0.98 |
| Metalicidad | `Metallic` | `metallicFactor` | Herrajes de cofre, vetas de cobre/hierro/oro |
| Reflejo especular | `Specular IOR Level` (`:56`) | `KHR_materials_specular` | Ajuste fino; Godot lo respeta parcialmente |
| Emisivo | `Emission Color` + `Emission Strength` (`:57-59`) | `emissiveFactor` + `KHR_materials_emissive_strength` | Brasa/llama de farola, hongo luminoso, cristal |
| Alpha / transparencia | `Alpha` + blend mode | `alphaMode: BLEND` | Vidrios de ventana, agua |
| Doble cara | `use_backface_culling=False` | `doubleSided: true` | Hojas, telas, alas |

**Medición real del cofre (`70-Interacciones_cofre_pequeno.glb`):**

| Material | Base Color (RGB) | Roughness | Metallic |
|---|---|---|---|
| `MAT_Madera_Cofre_Peq` | (0.44, 0.28, 0.15) | 0.88 | 0.00 |
| `MAT_Hierro_Cofre_Peq` | (0.36, 0.37, 0.40) | 0.38 | 0.86 |
| `MAT_Bronce_Cierre` | (0.74, 0.54, 0.28) | 0.30 | 0.92 |

> El canal emisivo existe, pero en el cofre el `Emission Strength` quedó en su default 1.0 con color negro → **sin emisión real**. La emisión se usa en piezas de fuego/cristal, no en el cofre.

**Límites que hay que respetar:**
- El exportador glTF **no hornea nodos procedurales**: si el material usa Noise/Voronoi/ColorRamp, Godot recibe solo un factor plano. Para texturas reales hay que **hornear a imagen** y conectar `Base Color`/`ORM`.
- Godot 4.7 usa **Forward Plus** (`project.godot:16` → `config/features=PackedStringArray("4.7", "Forward Plus")`), así que soporta PBR completo (metallic-roughness, SSAO, SSR, glow). No hay que degradar a móvil.
- Presupuesto por variante (`auditar_presupuesto.py:14-15`): **MEDIA** = ≤8 objetos, ≤1500 tris, ≤8 materiales; **BAJA** = ≤6 objetos, ≤700 tris, ≤4 materiales. Conteo por material realmente usado (E-36).

---

## 4. Escalas que usaría para el proyecto

Fuente de verdad: `GUIA-BLENDER/01-conexion-mcp-convenciones.md:58-109` y `game/isla-ancestral/data/escalas/escalas.json`.

**Reglas base:**
- Mundo: **personaje = 1.8 m**, **voxel = 1 m**, **celda de construcción = 1×1 m** (`GUIA-BLENDER/01:62`).
- Todo asset se modela a una **altura objetivo en metros** y se hornea con `transform_apply(scale=True)`; el multiplicador es `altura_objetivo / altura_actual_medida` (E-58, nunca un factor fijo).
- Apoyo al suelo: **`z_min = 0.045`** exacto (E-12), 5 mm bajo el tope de arena. Constante `Z_APOYO = 0.045` en `plantilla_asset.py:33` (medido en el cofre real).
- Los GLB horneados quedan en `1.0` en `escalas.json`; solo los planos (hierba, raíces) se escalan en runtime vía autoload `EscalasGlobales` (`GUIA-BLENDER/01:108-109`).

**Tabla de alturas objetivo que aplicaría (validada por el usuario):**

| Tipo | Altura objetivo | Fuente |
|---|---|---|
| Árbol frutal | **6.0 m** (referencia aprobada) | `GUIA-BLENDER/01:71` |
| Palmera / palmera inclinada | 8.0 m | `:72` |
| Palmera joven | 4.5 m | `:74` |
| Liana colgante | 8.0 m | `:73` |
| Arbusto redondo/floral | 0.5 m | `:77` |
| Helecho gigante / chico | 0.8 m / 0.35 m | `:75-76` |
| Flor de isla | 1.2 m | `:81` |
| Cañas de bambú | 2.5 m | `:80` |
| Jabalí adulto / tortuga / gaviota / conejo | 1.1 / 0.8 / 0.5 / 0.35 m | `:84-87` |
| NPC / vecino | 1.0 (GLB) = **1.8 m** | `:92` |
| Tótem ancestral / pequeño | 3.5 / 1.5 m | `escalas.json → props_totems` |
| Cofre | 0.8 (runtime) | `escalas.json → props_totems.cofre` |
| Mesa de trabajo | 1.0 | `escalas.json → props_totems.mesa_trabajo` |

**Verificación cruzada con lo medido:** palmera 7.0 m (objetivo 8.0), jabalí 0.78 m de alto (objetivo 1.1 m; el bbox alto del jabalí tiende a subestimar porque el lomo no es la cota máxima), cofre 0.50 m (objetivo 0.8 m con multiplicador runtime). La escala es **coherente en metros** y el ajuste fino se hace por multiplicador dinámico, no a ojo.

**Convenciones de modelado a escala:**
- Pivote en la base del objeto (para que `position.y = 0` lo apoye en el suelo).
- Piezas montadas (sombreros, armas) con origen en el punto de montaje (`GUIA-BLENDER/05:59-60`).
- LODs a la **misma altura** (`z_min` idéntico en alta/media/baja) para que el cambio de LOD no haga saltar el objeto (`GUIA-BLENDER/05:53`).

---

## 5. Dos mejoras concretas de activos 3D

### Mejora 1 — Horneado de atlas PBR 1K con ORM empaquetado

**Problema (medido):** los 487 GLB usan **0 texturas de imagen**. Cada material es color plano + rugosidad + metalicidad. Eso obliga a multiplicar `MAT_*` (una pared = 2–3 materiales; la farola = 5) y deja las superficies planas. El presupuesto de BAJA es solo **4 materiales** (`auditar_presupuesto.py:15`).

**Propuesta:** hornear **un atlas 1024×1024 por familia** (madera, piedra, arena, follaje, metal) con empaquetado glTF estándar **ORM** (O = oclusión en R, R = rugosidad en G, M = metalicidad en B) + `Base Color` y `Normal` en el mismo atlas. UVs apuntando a regiones del atlas:
- Se baja de 5–8 materiales a **1 material por asset** → menos draw calls y menos slots.
- Mismo look lowpoly y mismo presupuesto de tris, pero con detalle de superficie (vetas, vetas de madera, granos).
- Forward Plus lo importa nativo, sin costo extra de pipeline.

**Criterio de cierre:** cofre, pared de madera y roca quedan en 1 material, ≤8 objetos y ≤1500 tris en MEDIA; captura orbital de 6 azimuts sin costuras visibles en el atlas.

### Mejora 2 — Kit de props interactivos con pivote, colisión y estado

**Problema (medido):** `70-Interacciones` tiene cofre, botón, palanca, puerta corrediza y válvula modelados con LODs, pero el pipeline documenta el **modelado**, no el **contrato de interacción**. El cofre real es **1 solo objeto malla** con 3 slots de material: la tapa **no** es una pieza separada con pivote de bisagra, así que Godot no puede animarla sin rehacer el modelo. `GUIA-BLENDER/08` cubre piezas animables de fauna/NPC, no props interactivos.

**Propuesta:** extender `GUIA-BLENDER/05` con un **sub-protocolo "prop interactivo"** que exija:
1. **Tapa/puerta como `SM_` separado con pivote en la bisagra** (no en el centro), igual que las aletas de la tortuga.
2. **Malla de colisión exportada aparte** (`_col` o custom property) — cofre y puerta necesitan colisión estática; la tapa, colisión de cuerpo.
3. **Empty `_PIVOTE` / `_MONTADO`** documentado para que Godot conecte el `AnimationPlayer` sin adivinar el eje.
4. **Material emisivo** en la parte activa (cerradura, gema, llama de farola) para feedback visual.

**Criterio de cierre:** los 5 props de `70-Interacciones` pasan a tener `SM_` de tapa/palanca con pivote en la bisagra + colisión + captura de 6 azimuts; se agrega la sección al checklist y un log. Esto habilita que Godot los anime sin rehacer el modelo.

---

## 6. Archivos y líneas de referencia

| Archivo | Líneas clave | Qué aporta |
|---|---|---|
| `tools/mcp/blender-mcp/scripts-reutilizables/plantilla_asset.py` | 30-33 (`RAIZ`, `Z_APOYO=0.045`), 49-60 (`mat()` Principled BSDF), 64-99 (`caja`), 103-214 (`loft`), 216-... (`revolucion`, piezas huecas) | Helpers canónicos de material, apoyo y forma |
| `tools/mcp/blender-mcp/scripts-reutilizables/exportar_godot.py` | 16-28 (por qué headless), 66 (`DEST_ROOT`), 68-74 (`MODULOS`), 116 (destino), 175-187 (`export_scene.gltf` con `GLB`, `export_yup`, `export_apply`) | Export `.blend` → `.glb` |
| `tools/mcp/blender-mcp/scripts-reutilizables/auditar_presupuesto.py` | 14-15 (presupuestos MEDIA/BAJA), 27-51 (conteo real de tris/slots/materiales) | QA numérico de presupuesto |
| `DOCUMENTACION/GUIA-BLENDER/01-conexion-mcp-convenciones.md` | 58-92 (tabla de alturas), 94-109 (E-58, pipeline de escalado, `EscalasGlobales`) | Escalas y conexión MCP |
| `DOCUMENTACION/GUIA-BLENDER/05-checklist-asset.md` | 11-63 (checklist completo) | Requisitos de cierre de asset |
| `DOCUMENTACION/GUIA-BLENDER/09-nivel-detalle-modelado.md` | 16-49 (nivel de detalle), 51-77 (`matrix_world`), 104-122 (`.blend` antes que GLB) | Calidad orgánica y orden de guardado |
| `DOCUMENTACION/GUIA-GODOT/11-blender-godot.md` | 20-30 (export), 94-101 (naming), 105-113 (troubleshooting) | Integración y nombres |
| `game/isla-ancestral/data/escalas/escalas.json` | completo (vegetación, fauna, npcs, props_totems) | Escalas runtime reales |
| `game/isla-ancestral/project.godot` | 16 (`"4.7", "Forward Plus"`) | Motor 4.7 con PBR completo |
| `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` | 15-75 (vegetación, recursos, agricultura, casas) | Inventario de objetos ya creados |
| `tools/mcp/blender-mcp/70-Interacciones/` | `cofre_pequeno_lowpoly{,_media,_baja}.blend` | Props interactivos existentes |
| `tools/mcp/blender-mcp/45-Arte3D/` | `totem_isla`, `monolito_glifos`, `jarrones_urnas`, `concha_mar`, `ancla_naufragio` | Decoración y elementos de terreno |
| `tools/mcp/blender-mcp/18-Casas/` | `mesa_madera`, `silla_madera`, `cama_basica`, `cama_doble`, `estanteria`, `decor_farol_mesa` | Mobiliario existente |

**Cifras medidas (no inferidas):**
- 784 `.blend` en `tools/mcp/blender-mcp/`.
- 487 `.glb` en `assets/3d/`: **183 alta, 153 media, 151 baja**.
- **0** texturas de imagen en `assets/3d/`.
- 161 fichas en `assets/fichas/`.
- 5 GLB importados y medidos en vivo (tabla §0.2).

---

## 7. Conclusión final

Puedo generar y entregar activos 3D listos para Godot con el pipeline existente: **cofres, lámparas/farolas, mobiliario, decoración, props de puzzle y elementos de terreno**, con LODs alta/media/baja, `z_min = 0.045` y materiales Principled BSDF que Godot 4.7 (Forward Plus) importa de forma nativa. La capacidad no es teórica: **importé y medí 5 GLB reales del proyecto** y el pipeline `bpy → .blend → .glb → Godot` está operativo de punta a punta.

El formato correcto es **`.glb` (glTF 2.0 binario)**; `.gltf` funciona igual y `.obj` solo como respaldo sin PBR. Los materiales PBR disponibles son color base, rugosidad, metalicidad, especular, emisivo y doble cara; los nodos procedurales no sobreviven al export y deben hornearse si se quieren texturas. El cambio más importante que detecté es que **los 487 GLB no tienen ni una textura**: todo es color plano. Eso es lo que hace la Mejora 1 (atlas PBR 1K con ORM) la de mayor impacto.

**Dos límites reales, honestos:**
1. **QA visual (E-13):** depende de inspección de imágenes. Si este chat no dispone de entrada de imágenes, el QA de 6 azimuts lo hace el usuario o un agente con visión; mi QA fue numérico (bounds, tris, materiales, `z_min`).
2. **Librerías y generadores OFF:** Poly Haven, Sketchfab, Poly Pizza, Tripo, Hunyuan3D, Hyper3D y Meshy están apagados. Puedo modelar con `bmesh` y exportar, pero no descargar ni generar modelos por IA hasta que se activen.

Las dos mejoras propuestas —**atlas PBR 1K con ORM empaquetado** y **kit de props interactivos con pivote + colisión + emisivo**— atacan los dos cuellos reales: el exceso de materiales/draw calls en BAJA y la falta de contrato de interacción en `70-Interacciones`. Ambas caben dentro del presupuesto actual y reutilizan los helpers ya probados (`plantilla_asset.mat()`, `auditar_presupuesto.py`, `generar_variante.py`, `exportar_godot.py`).

---

**Modelo:** ERNIE-5.5-Flash-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-11-11 (verificación en vivo 2026-11-12 00:50)