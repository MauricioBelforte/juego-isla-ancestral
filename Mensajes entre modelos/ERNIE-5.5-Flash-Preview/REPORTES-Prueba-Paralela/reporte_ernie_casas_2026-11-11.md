# Reporte — Diseño de casas 3D para el juego (Isla Ancestral)

**Modelo:** ERNIE-5.5-Flash-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-11-11 (verificación de repositorio: 2026-11-12 01:00)
**Módulo principal:** M18 — Casas
**Módulos consultados:** M17 (Construcción), M45 (Arte 3D), M47 (Texturas y Materiales), M61 (Rendimiento), M108 (Pipeline de Assets), M167 (Isla Raíz), M168 (Plantilla de Isla)
**Alcance:** (1) tipos de casas, (2) materiales y texturas, (3) polígonos recomendados, (4) integración con el terreno de Godot, (5) dos diseños concretos. No se modificó código; este archivo es el único entregable.

---

## 0. Resumen ejecutivo

El juego ya tiene una base sólida para casas: **120 GLB** de la familia `18-Casas` en `game/isla-ancestral/assets/3d/` (**60 en `alta/`**, 30 en `media/`, 30 en `baja/`), 46 recetas de construcción en `game/isla-ancestral/data/construccion/piezas/`, y la lógica M18 implementada en `game/isla-ancestral/scripts/houses/` (8 scripts, suites `test_m18_*`). Lo que falta es **cerrar la familia visual**: las casas grandes actuales se modelaron con un pipeline de 6.000 tris que **rechazó la casona (6.826 tris) y la mansión (8.779 tris)**, mientras que M45 permite hasta 15.000 tris por edificio. Esa discrepancia es la principal decisión de diseño pendiente.

La recomendación es trabajar con **cinco tipos de casa** (choza, cabaña, casa mediana, casona/artesano, mansión), **3 LODs** (ALTA ≤6.000 tris para el pipeline actual; MEDIA 1.500; BAJA 700), **materiales low-poly con color por vértice + Principled BSDF** (el repo no usa imágenes de textura en `assets/3d/`), y **integración por `TerrainLocator` + M17**, nunca con posiciones hardcodeadas.

| Pregunta | Respuesta corta |
|---|---|
| (1) Tipos | Choza, cabaña costera, casa mediana, casa artesano/taller, casona, mansión, casa de vecino |
| (2) Materiales | Madera clara/oscura, paja, piedra, tela, musgo, metal forjado; color por vértice; atlas opcional 1024²/32 px |
| (3) Polígonos | LOD0 2.500–5.800 tris (casas); LOD1 ~1.500; LOD2 ~650; techo M45 15.000 tris |
| (4) Integración | `TerrainLocator.get_height()+1`, validación de huella, M17/`.tres`, colisión, portal interior, guardado M18/M60 |
| (5) Diseños | **Casa del Artesano "Taller de Marea"** (8×6 m) y **Cabaña del Litoral "Refugio del Pescador"** (5×4 m) |

---

## 1. Tipos de casas que necesita el juego

### 1.1 Criterio de clasificación

Las casas se clasifican por **función de gameplay**, **etapa de progresión** y **bioma**, no por tamaño estético. La fuente canónica es `DOCUMENTACION/18-Casas/plan-actual/01-Requerimientos.md:56-76` (progresión de la casa) y `:182-209` (familia de casas grandes habitables).

| Tipo | Función | Etapa M18 | Uso en el mundo | Evidencia |
|---|---|---|---|---|
| **Choza** | Vivienda inicial del jugador; techo de paja; 1 ambiente | 0–1 | Parcela del jugador | `01-Requerimientos.md:58` (etapa 0 "Choza"); `:202` |
| **Cabaña del litoral** | Refugio de pescador; pequeña, cerca de agua; opcional palafito | 0–1 | Costa / orilla; NPC pescador | `:202` (choza ampliada 5×4 m); `mundo_raiz.gd:22` (orilla r≈1700) |
| **Casa mediana** | Vivienda de familia NPC; 2 ambientes; cocina + dormitorio | 2 | Pueblo / pradera | `:203` (8×6 m); `CASA_02/INFORME.json:5-10` |
| **Casa artesano / taller** | Vivienda + taller funcional (M16); cobertizo, yunque, mesa de trabajo | 2–3 | Zona de talleres / pueblo | `:27` (RF8 taller); `:204` (casona 10×8 m) |
| **Casona** | Casa amplia de 3–4 ambientes; sala de estar; familia acomodada | 3 | Pueblo grande / colina | `:204`; `CASA_03_CASONA/INFORME.json:3-10` (10×8 m) |
| **Mansión** | Mansión multi-habitación; biblioteca / sala de museo; final de progresión | 4 | Ladera / zona noble | `:205` (14×10 m); `CASA_04_MANSION/INFORME.json:3-10` |
| **Casa de vecino** | Vivienda NPC reutilizable; 1 vecino por casa; visitas M19 | 1–5 | Pueblo; parcelas NPC | `house_manager.gd:153-168`; `01-Requerimientos.md:29` (RF10/RF12) |

### 1.2 Casas que ya existen (inventario medido)

| Asset | Dimensiones (m) | Tris ALTA | Materiales | Estado |
|---|---|---|---|---|
| `18-Casas_casa_choza_ampliada.glb` | 5.60 × 4.60 × 3.88 | **4.100** | 8 | Exportado; LOD BAJA 665 tris |
| `18-Casas_casa_mediana.glb` | 8.60 × 7.09 × 3.83 | **4.300** | 8 | Exportado; LOD BAJA con error de apoyo |
| `18-Casas_casa_casona.glb` | — | **6.826** | — | **No exportado** (supera el presupuesto de 6.000 del pipeline) |
| `18-Casas_casa_mansion.glb` | — | **8.779** | — | **No exportado** (mismo motivo) |
| `18-Casas_casa_vecino.glb` | 7.60 × 7.10 × 3.52 | **2.746** | 8 | Exportado; LOD BAJA sin errores |
| `18-Casas_casa_completa_ejemplo.glb` | — | — | — | Solo referencia visual, **no habitable** |

Fuentes: `CASA_01_CHOZA/INFORME_CASA_01.json:6-12`, `CASA_02_CASA_MEDIANA/INFORME.json:231-236`, `CATALOGO_CASAS_02_05.json` (errores de casona y mansión), `18-Casas/plan-actual/01-Requerimientos.md:174-180`.

### 1.3 Brecha detectada: presupuesto de 6.000 vs 15.000 tris

- M45 permite **15.000 tris** para edificios (`45-Arte-3D/plan-actual/01-Requerimientos.md:62,71`).
- El script de las casas grandes usa un `assert alta["triangulos"] <= 6000` (`crear_casa_01_choza.py:815`) y LODs de 1.500/700 tris (`:1106-1107`).
- Consecuencia: **casona y mansión quedaron fuera del pipeline**, aunque el diseño M18 las pide (`01-Requerimientos.md:204-205`).
- Recomendación: **no subir el presupuesto global a 15.000 por defecto**. Mantener 6.000 tris por **casa individual** y, para casona/mansión, usar **grupos jerárquicos** (alas/pabellones de ≤6.000 tris) o componerlas con módulos M17. Así se respeta el presupuesto de escena de 150.000 tris (`45-Arte-3D/.../01-Requerimientos.md:87`) y los 200 draw calls.

---

## 2. Materiales y texturas por estilo

### 2.1 Realidad del pipeline (medida, no supuesta)

- `game/isla-ancestral/assets/3d/` contiene **487 GLB** y **0 archivos de imagen** (`.png/.jpg/.jpeg/.webp/.exr/.hdr`).
- Los materiales son **Principled BSDF con Base Color + Roughness + Metallic constantes**; el color se hornea en **vertex colors** (`COLOR_0`) en los scripts Blender.
- M47 define además un **atlas de bloques 1024×1024, 32 px/tile** (`artbook_specs_m47.md:49-56`) y **4 niveles de madera** (Base / Oscura / Teñida / Ancestral, `:71-74`), pero ese atlas **no se usa aún en las casas**.

**Conclusión de materiales:** para casas, usar **color por vértice + 6–8 materiales** (barato, mergeable, sin VRAM de texturas). Reservar el atlas M47 para superficies que exijan detalle fino (tejas, piedra, madera con vetas) y solo si el presupuesto de draw calls lo permite.

### 2.2 Paleta base copiada del pipeline real

`tools/mcp/blender-mcp/18-BIS-Casas-Grandes/CASA_01_CHOZA/BAJA/crear_casa_01_choza.py:62-82` define la paleta y los materiales usados por la choza. Es la referencia canónica para toda la familia:

| Clave | RGB sRGB | Uso | Material | Roughness | Metallic | Alpha |
|---|---|---|---|---|---|---|
| `MADERA` | (180, 140, 90) | Madera clara: paredes, vigas, muebles | `MAT_MaderaClara` | 0.85 | 0.0 | 1.0 |
| `OSCURA` | (90, 65, 40) | Madera oscura: vigas, marcos, ribetes | `MAT_MaderaOscura` | 0.90 | 0.0 | 1.0 |
| `PAJA` | (210, 180, 120) | Techo de paja / caña | `MAT_PajaClara` | 0.95 | 0.0 | 1.0 |
| `PIEDRA` | (130, 125, 120) | Cimientos, zócalo, chimenea | `MAT_Piedra` | 0.95 | 0.0 | 1.0 |
| `TELA` | (200, 190, 170) | Cortinas, mantas, toldos | `MAT_TelaCrudo` | 0.80 | 0.0 | 1.0 |
| `MUSGO` | (110, 120, 100) | Piedra con musgo, techos viejos | `MAT_PiedraMoss` | 0.95 | 0.0 | 1.0 |
| `CORTINA` | (200, 190, 170) | Cortinas semitransparentes | `MAT_CortinaCrudo` | 0.80 | 0.0 | 0.70 |
| `METAL` | (91, 83, 72) | Bisagras, herramientas, ancla | `MAT_MetalForjado` | 0.65 | 0.65 | 1.0 |

### 2.3 Materiales recomendados por estilo de casa

| Estilo | Materiales dominantes | Acentos | Evidencia / nota |
|---|---|---|---|
| **Choza / cabaña** | Madera clara, paja, piedra, musgo | Tela cruda, metal forjado | Paleta `crear_casa_01_choza.py:62-82`; techo `techo_paja.tres` |
| **Casa mediana** | Madera clara + oscura, piedra, paja/teja | Tela, metal | `CASA_02/INFORME.json:5-10`; recetas `pared_madera.tres`, `techo_dos_aguas.glb` |
| **Casa artesano** | Madera oscura (estructura), piedra (taller), metal (yunque/herramientas) | Paja, tela | RF8 taller (`18-Casas/01-Requerimientos.md:27`) |
| **Casona** | Piedra + madera oscura, teja, vidrio | Tela, metal, cristal | `CASA_03_CASONA/INFORME.json:3-10` |
| **Mansión** | Piedra tallada, madera noble, cristal, metal | Oro viejo / latón, tela fina | `CASA_04_MANSION/INFORME.json:3-10` |
| **Casa de vecino** | Madera clara, paja, piedra | Tela, flores | `18-Casas_casa_vecino.glb` (2.746 tris, 8 mats) |
| **Estilo oceánico** | Madera de deriva, coral, conchas, cuerda | Azul turquesa, rosa coral | Set "Oceánico" en `18-Casas/01-Requerimientos.md:123` |
| **Estilo ancestral** | Piedra con glifos, madera oscura, emisión sutil | Verde musgo, dorado | Set "Ancestral" `:121`; `47/artbook_specs_m47.md:76-85` |

### 2.4 Texturas: cuándo sí y cuándo no

| Caso | Recomendación |
|---|---|
| Paredes, pisos, techos vistos a >10 m | **Color por vértice** (sin textura). Merge por material. |
| Primer plano (interior, cámara cercana) | **Atlas M47 1024², 32 px/tile** para madera/piedra/paja; 3 variantes por bioma (`artbook_specs_m47.md:49-56,140-146`) |
| Muebles | **4 niveles de madera** por material (Base/Oscura/Teñida/Ancestral), no 4 mallas (`:71-74`) |
| Emisivos (faroles, glifos) | Shader `emisivo_ancestral`, emisión ≤1.5, sin bloom agresivo (`:81-85`) |
| Cristal / ventanas | Transparencia + refracción ligera; **máx. 2 instancias por escena** (`:100-104`) |
| Prohibido | Texturas 4K, textura individual por bloque, regenerar texturas en runtime (`:149-158`) |

---

## 3. Polígonos recomendados por casa

### 3.1 Techo por categoría (fuente M45)

`45-Arte-3D/plan-actual/01-Requerimientos.md:64-92`:

| Categoría | LOD0 | LOD1 | LOD2 | Distancias LOD |
|---|---:|---:|---:|---|
| Edificios (`bld_`) | **15.000** | 6.000 | 2.000 | 30 / 60 / 120 m |
| Muebles (`furn_`) | 1.200 | 400 | 150 | 10 / 25 / 50 m |
| Props (`prop_`) | 200 | 80 | — | — |
| Vegetación (`veg_`) | 3.000 | 1.200 | 400 | 15 / 35 / 70 m |
| **Presupuesto de escena** | **150.000 tris visibles** (incluye ~50.000 del terreno) | | | |
| **Draw calls** | **200 por escena** | | | |

### 3.2 Presupuesto recomendado para casas (3 niveles)

| Tipo | LOD0 (ALTA) | LOD1 (MEDIA) | LOD2 (BAJA) | Materiales | Objetos `SM_` | Notas |
|---|---:|---:|---:|---:|---:|---|
| Cabaña del litoral | 2.800–3.400 | 1.100 | 450 | ≤6 | 10–12 | 1 ambiente + porche; base `choza` 4.100 → reducir ~20 % |
| Choza ampliada | 3.800–4.200 | 1.400 | 600 | ≤8 | 14 | Ya medida: 4.100 / 1.426 / 665 (`INFORME_CASA_01.json`) |
| Casa de vecino | 2.500–2.800 | 1.000 | 420 | ≤8 | 14 | Ya medida: 2.746 (`CATALOGO_CASAS_02_05.json`) |
| Casa mediana | 4.000–4.400 | 1.400 | 600 | ≤8 | 17 | Ya medida: 4.300 / 1.420 (`INFORME.json:231`) |
| Casa artesano | 5.000–5.800 | 1.500 | 650 | ≤8 | 18–20 | Taller + vivienda; un solo volumen |
| Casona | 5.800–6.000 por ala | 1.500 | 650 | ≤8 | ≤20 por ala | Dividir en 2 alas si supera 6.000 |
| Mansión | 5.800–6.000 por ala | 1.500 | 650 | ≤8 | ≤20 por ala | 2–3 alas + pabellón |

**Reglas de aplicación:**

1. **LOD obligatorio si >500 tris** (`45-Arte-3D/.../01-Requerimientos.md:85`).
2. **Una casa = un GLB con LODs** o un grupo jerárquico; nunca 60 objetos sueltos en escena.
3. **`meshes/generate_lods=true`** ya está activo en los `.import` (verificado en `18-Casas_casa_mediana.glb.import`).
4. **`z_min = 0.045`** para todas las variantes (regla E-12; `GUIA-BLENDER/05-checklist-asset.md:32,38`).
5. **Misma altura entre LODs**: si `z_min` cambia, el objeto "salta" al cambiar de LOD (`GUIA-BLENDER/05:53`).
6. **≤8 materiales por casa**; el merge por material baja los draw calls ~80 % (`GUIA-BLENDER/05:40`).

### 3.3 Presupuesto por escena (ejemplo de aldea)

| Elemento | Tris |
|---|---:|
| Terreno voxel visible | ~50.000 |
| 6 casas (promedio 3.500) | ~21.000 |
| 20 props × 200 | ~4.000 |
| 30 muebles × 400 | ~12.000 |
| Vegetación (30 × 1.200) | ~36.000 |
| **Total** | **~123.000** (< 150.000) |

Conclusión: **se pueden tener ~6 casas visibles** sin exceder el presupuesto, siempre que cada casa esté en LOD1/LOD2 a partir de 30 m.

---

## 4. Integración en el terreno de Godot

### 4.1 Principio único: `TerrainLocator`

El posicionamiento **nunca** se hace con coordenadas fijas ni con un generador clonado. La fuente de verdad es el autoload `TerrainLocator` (`game/isla-ancestral/scripts/core/terrain_locator.gd`):

- `get_height(x: int, z: int) -> int` — altura del suelo real (`:45-52`).
- `posicionar_sobre_terreno(nodo, x, z) -> bool` — coloca el nodo en `y = altura + 1` (`:56-61`).
- `esta_sobre_superficie(nodo) -> bool` — verificación de que no flota (`:64-73`).

La regla está documentada en `DOCUMENTACION/GUIA-GODOT/08-terreno-voxel.md:190-202` y en `167-Isla-Raiz/plan-actual/MAPA-OBJETOS.md` ("SIEMPRE usar `TerrainLocator`").

### 4.2 Constantes del mundo (Isla Raíz)

`game/isla-ancestral/scripts/world/mundo_raiz.gd:15-29`:

| Constante | Valor |
|---|---|
| `CENTRO` | `Vector2(2560, 2560)` |
| `RADIO_ISLA` | `1800.0` |
| `RADIO_ORILLA` | `1700.0` |
| `SPAWN_JUGADOR` | `Vector3(3860, 0, 3860)` |

Las casas van **dentro del radio de orilla** y a **≥20 m** de otra casa (`house_manager.gd:20`, `MIN_DISTANCIA_CASAS = 20.0`).

### 4.3 Dos vías de integración

#### Vía A — Casa modular con recetas M17 (recomendada para el jugador)

Cada pieza (pared, piso, techo, puerta, ventana) es un `.tres` de `PlacementRule` en `game/isla-ancestral/data/construccion/piezas/`. El catálogo los carga recursivamente (`build_catalog_db.gd:32-54`) y los agrupa en 12 familias (`:17-21`).

Ejemplo real de receta (`pared_madera.tres`):

```gdscript
[resource]
id = &"pared_madera"
mesh_path = "res://assets/3d/alta/18-Casas_pared_madera.glb"
familia = &"pared"
costo = { "planks": 4 }
bloque = 8
superficie_ofrecida = &"pared"
```

Reglas de colocación declarativas (`placement_rule.gd:31-90`): `tamano`, `altura`, `soportes_minimos`, `superficie_ok`, `requiere_pared`, `deconstruible`, `devolucion`, `mesh_path`, `variantes_disponibles`.

Flujo: el jugador entra en modo construcción (M17), elige la pieza, el fantasma valida celda/soporte/zona, y al confirmar se descuenta el costo de M14. La casa resultante es un `House` (`house.gd`) con `etapa`, `en_obra`, `parcela_id`.

#### Vía B — Casa prearmada (GLB único) para NPC/pueblo

Para casas de vecinos y decorados del pueblo se usa un GLB completo (ej. `18-Casas_casa_vecino.glb`) instanciado como `Node3D`, con un `Area3D` en la puerta y un `House` adyacente para la lógica. Es más barato de colocar y no requiere que el jugador construya.

### 4.4 Validación de parcela (antes de colocar)

`house_manager.gd:116-125` ya implementa:

```gdscript
func parcela_despejada(pos: Vector3) -> bool:
    if hay_casa_en(pos, MIN_DISTANCIA_CASAS):
        return false
    var tl = get_node_or_null("/root/TerrainLocator")
    if tl != null and tl.has_method("get_height"):
        var h := int(tl.get_height(int(pos.x), int(pos.z)))
        if h <= 0:
            return false
    return true
```

Falta validar **pendiente** y **huella completa**. Recomendación: muestrear las 4 esquinas + centro de la huella y exigir que la diferencia de altura sea ≤1 bloque; si no, rechazar o nivelar con cimientos.

### 4.5 Colisión, puerta y portal interior

- **Colisión exterior:** `StaticBody3D` con `BoxShape3D` por volumen (más barato que trimesh) o `trimesh` solo para casas prearmadas.
- **Puerta:** `Area3D` + `prompt` de interacción; `House.obtener_entrada()` devuelve `global_position + Vector3.FORWARD * 2.0` (`house.gd:33-35`).
- **Interior:** escena separada `HouseInterior` (`house_interior.gd`), no voxel. `House.abrir_interior()` instancia el interior y emite `interior_abierto` (`house.gd:37-47`). Las habitaciones se desbloquean por etapa (`house_interior.gd:45-59`).
- **Techo removible:** las casas grandes traen techos desmontables por objetos para inspección (`INFORME_CASA_01.json: notas`), lo que facilita la vista aérea y el QA.

### 4.6 Guardado y persistencia

`house_manager.gd:291-326`:

```gdscript
func obtener_estructuras() -> Array:
    # {id, tipo:"casa", pos:[x,y,z], rot_y, planta, variante}
func restaurar_estructuras(lista: Array) -> void:
    # reconstruye _casas, _vecinos y la parcela del jugador
```

- La posición se guarda como enteros; la rotación como `rot_y`.
- El interior (muebles, almacenamiento) se guarda aparte vía `HouseInterior.recolectar_estado()` (`house_interior.gd:61-70`) y el contrato `BuildingsSaveProvider` (M60).
- No guardar en el save la malla ni el LOD: se derivan del `id`/`variante`.

### 4.7 Rendimiento y draw calls

| Técnica | Implementación |
|---|---|
| LOD | `meshes/generate_lods=true` en el `.import`; `visibility_range` 30/60/120 m |
| Merge por material | `generar_variante.py --media --baja` (merge lossless, −80 % draw calls; `GUIA-BLENDER/05:40`) |
| Un GLB por casa | Evita 14–20 nodos sueltos; el `.blend` de autoría queda en `tools/`, no se exporta |
| Culling de muebles | `HouseDecor` / `HouseInterior` desactivan muebles fuera de la habitación |
| Presupuesto | 150.000 tris/escena, 200 draw calls (`45-Arte-3D/.../01-Requerimientos.md:87-88`) |

### 4.8 Verificación con MCP de Godot (obligatoria)

1. `godot_run_project` con la escena de prueba.
2. `godot_get_debug_output` → 0 errores.
3. Captura orbital (6 azimuts) y comparación con `capturas/{ID}-Casas/`.
4. Validar `z_min`, bounds y materiales con `scripts-reutilizables/auditar_presupuesto.py`.
5. Solo después de la aprobación visual del usuario, exportar el GLB a `game/isla-ancestral/assets/3d/` (`GUIA-BLENDER/09:104-122`).

---

## 5. Dos diseños concretos

### 5.1 Diseño A — Casa del Artesano "Taller de Marea"

**Rol:** casa-taller de un artesano NPC (o del jugador en etapa 2–3). Combina vivienda y taller funcional (RF8, M16). Pensada para la **zona de talleres del pueblo** o el borde del bosque, no para la playa.

**Silueta:** volumen rectangular de 8×6 m, **una planta + altillo**, techo a dos aguas con cumbrera a 3,4 m. La mitad izquierda es el taller (puerta doble ancha), la derecha es la vivienda (puerta de 1,0 m). Un cobertizo exterior de 2×2 m adosa leña y herramientas.

**Exterior:**

| Elemento | Detalle |
|---|---|
| Zócalo | Piedra de 0,25 m de alto, perímetro completo |
| Paredes | Madera clara (180,140,90) con **vigas vistas** en madera oscura (90,65,40) cada 2 m |
| Techo | Teja de madera/paja a dos aguas, alero 0,30 m; cumbrera decorada |
| Puerta taller | Doble hoja 1,8×2,2 m, bisagras de metal forjado |
| Puerta vivienda | 1,0×2,1 m, marco oscuro |
| Ventanas | 4 (2 taller, 2 vivienda), 0,6×0,6 m, marco de madera y postigo |
| Letrero | Tabla colgante con símbolo de yunque/martillo |
| Exterior | Mesa de trabajo 2×0,8 m, rack de tablones, barrica, farol de pared |

**Interior:**

| Ambiente | Muebles |
|---|---|
| Taller (4×6 m) | Mesa de trabajo 2×0,8, yunque de piedra, estantería de herramientas, estufa de leña, nevera rústica, taburete |
| Vivienda (4×6 m) | Cama doble 2×2, mesa 2×2, 4 sillas, cómoda, cofre, alfombra, lámpara de pie |
| Altillo | Estantería, baúl, cuadro ancestral |

**Materiales:** `MAT_MaderaClara`, `MAT_MaderaOscura`, `MAT_Piedra`, `MAT_PajaClara`, `MAT_MetalForjado`, `MAT_TelaCrudo` (6 materiales; ≤8).

**Polígonos objetivo:**

| LOD | Tris | Materiales | Objetos `SM_` |
|---|---:|---:|---:|
| ALTA | **5.400** | 6 | 18 |
| MEDIA | **1.500** | 4 | 18 |
| BAJA | **640** | 3 | 18 |

**Colores (mismos del pipeline):** madera (180,140,90), oscura (90,65,40), piedra (130,125,120), paja (210,180,120), tela (200,190,170), metal (91,83,72).

**Integración:**

1. Modelar en `tools/mcp/blender-mcp/18-Casas/casa_artesano_lowpoly.py` (función `crear_casa_artesano()`), guardar `.blend` + `.blend_media` + `.blend_baja`.
2. Exportar a `game/isla-ancestral/assets/3d/alta/18-Casas_casa_artesano.glb` (y variantes).
3. Crear `game/isla-ancestral/scenes/houses/house_artesano.tscn` con `House` + `Area3D` puerta + colisión.
4. Colocar en el pueblo con `TerrainLocator.posicionar_sobre_terreno()`; validar huella 8×6 y pendiente ≤1 bloque.
5. Registrar en `HouseManager.registrar_casa(pos, "casa_artesano")`; asignar vecino artesano.
6. Añadir recetas M17 opcionales: `pared_artesano`, `techo_artesano`, `puerta_taller` (reutilizando `PlacementRule`).

**Aceptación:** 0 errores en `get_debug_output`; `z_min=0.045` en los 3 LODs; ≤8 materiales; el taller permite colocar mesa/yunque/estantería en el grid de `HouseDecor`; la puerta abre al interior.

---

### 5.2 Diseño B — Cabaña del Litoral "Refugio del Pescador"

**Rol:** refugio pequeño de pescador (etapa 0–1), junto a la orilla. Puede ser **palafito** (sobre pilotes en aguas poco profundas) o cabaña de playa. Aporta variedad de silueta y un punto de interés costero.

**Silueta:** 5×4 m, **una planta + altillo de dormir**, techo de paja muy inclinado (cumbrera 3,2 m). Porche frontal de 5×1,2 m con dos pilotes y baranda. Si es palafito, 6 pilotes de madera de deriva de 1,5 m levantan el piso sobre el agua.

**Exterior:**

| Elemento | Detalle |
|---|---|
| Estructura | 6 pilotes de madera de deriva (0,18 m de diámetro) + vigas |
| Paredes | Tablas horizontales de madera clara/verdeada, 2,4 m de alto |
| Techo | Paja/cáñamo muy inclinado, alero 0,35 m; remate con cuerda |
| Puerta | 1,0×2,1 m, madera oscura, bisagra de metal |
| Ventanas | 2 (0,6×0,6 m), sin vidrio o con mica; postigo de madera |
| Porche | 5×1,2 m, baranda de cuerda, 2 postes |
| Accesorios | Red de pesca colgada, 3 boyas de corcho, remo, nasa, farol de aceite |
| Muelle | Pantalán de 3×1,5 m (receta `muelle_madera.tres` ya existe) |

**Interior:**

| Ambiente | Muebles |
|---|---|
| Dormitorio/sala (4×3 m) | Cama 2×0,9, cofre, mesa chica, taburete, estantería, lámpara de aceite |
| Altillo | Paja, manta, baúl pequeño |
| Exterior | Pescadero (mesa de limpiar), cubo, cañas |

**Materiales:** `MAT_MaderaClara`, `MAT_MaderaOscura`, `MAT_PajaClara`, `MAT_Piedra`, `MAT_TelaCrudo`, `MAT_MetalForjado` (6 materiales; ≤6 recomendado).

**Polígonos objetivo:**

| LOD | Tris | Materiales | Objetos `SM_` |
|---|---:|---:|---:|
| ALTA | **3.200** | 6 | 12 |
| MEDIA | **1.100** | 4 | 12 |
| BAJA | **450** | 3 | 12 |

**Integración:**

1. Modelar en `tools/mcp/blender-mcp/18-Casas/casa_pescador_lowpoly.py`; partir de `crear_casa_01_choza.py` y reducir ~20 % (quitar muebles internos, simplificar chimenea).
2. Exportar a `game/isla-ancestral/assets/3d/alta/18-Casas_casa_pescador.glb` (+ media/baja).
3. Crear `game/isla-ancestral/scenes/houses/house_pescador.tscn`.
4. Colocar en la **orilla**: radio 1.650–1.700 m desde el centro (2560,2560), con `TerrainLocator.get_height()` > 0; si es palafito, permitir el muelle con `sobre_agua=true` solo para la receta del pantalán (`placement_rule.gd:45-46`).
5. Registrar en `HouseManager`; asignar NPC pescador (M19); conectar el muelle como punto de pesca (M34).
6. Añadir `muelle_madera.tres` (ya existe) y, si hace falta, `cabaña_pilote` como variante de `PlacementRule`.

**Aceptación:** 0 errores de runtime; `z_min=0.045`; la cabaña no flota (verificar con `esta_sobre_superficie`); el muelle no bloquea la navegación; el interior es accesible por la puerta; el techo se puede quitar para la vista aérea.

---

## 6. Archivos y líneas de referencia

### 6.1 Documentación

| Archivo | Líneas | Qué aporta |
|---|---|---|
| `DOCUMENTACION/18-Casas/plan-actual/01-Requerimientos.md` | 56-76 | Progresión de la casa y grid de decoración |
| | 174-243 | Sección 6: casas grandes habitables, familia, mobiliario, reglas técnicas |
| `DOCUMENTACION/18-Casas/plan-actual/02-Analisis.md` | 10-45 | Alternativa A (portal interior) y justificación |
| `DOCUMENTACION/18-Casas/plan-actual/03-Diseno.md` | 8-35 | Arquitectura `House`/`HouseInterior` y diagrama |
| | 168-285 | Specs RF/P de casas |
| `DOCUMENTACION/18-Casas/plan-actual/04-Codigo.md` | 7-25 | Rutas `res://` de scripts y escenas |
| | 30-156 | Firmas GDScript y Resources |
| `DOCUMENTACION/18-Casas/plan-actual/05-Checklist.md` | 1-205 | Estado real M18 (implementado) |
| `DOCUMENTACION/45-Arte-3D/plan-actual/01-Requerimientos.md` | 62-92 | Techo de polígonos por categoría, LOD, presupuesto |
| `DOCUMENTACION/45-Arte-3D/plan-actual/ART_STYLE_3D.md` | 8-41 | Estilo, paleta y métricas |
| | 53-92 | Nombres, herramientas y checklist |
| `DOCUMENTACION/47-Texturas-Y-Materiales/plan-actual/artbook_specs_m47.md` | 49-56 | Atlas 1024² / 32 px |
| | 71-85 | Madera (4 niveles) y materiales luminosos |
| | 111-126 | Validación, naming y presupuesto |
| `DOCUMENTACION/GUIA-BLENDER/05-checklist-asset.md` | 32-53 | `z_min`, multi-ángulo, variantes |
| | 40 | Merge por material (−80 % draw calls) |
| `DOCUMENTACION/GUIA-BLENDER/09-nivel-detalle-modelado.md` | 104-122 | `.blend` primero, GLB después |
| `DOCUMENTACION/GUIA-GODOT/08-terreno-voxel.md` | 190-202 | Regla de oro `TerrainLocator` |
| `DOCUMENTACION/167-Isla-Raiz/plan-actual/MAPA-OBJETOS.md` | 1-45 | Centro, radio, spawn, posicionamiento |

### 6.2 Código

| Archivo | Líneas | Qué aporta |
|---|---|---|
| `game/isla-ancestral/scripts/core/terrain_locator.gd` | 43-73 | `get_height`, `posicionar_sobre_terreno`, `esta_sobre_superficie` |
| `game/isla-ancestral/scripts/world/mundo_raiz.gd` | 15-29 | `CENTRO`, `RADIO_ISLA`, `RADIO_ORILLA`, `SPAWN_JUGADOR` |
| `game/isla-ancestral/scripts/houses/house_manager.gd` | 11-20 | Etapas, `MIN_DISTANCIA_CASAS=20` |
| | 105-125 | Costes por etapa, `parcela_despejada` |
| | 170-201 | Slots de muebles, posición de puerta |
| | 245-258 | Habitaciones por etapa |
| | 291-326 | Guardado/restauración (M60) |
| `game/isla-ancestral/scripts/houses/house.gd` | 33-47 | Entrada, `abrir_interior`, `cerrar_interior` |
| `game/isla-ancestral/scripts/houses/house_interior.gd` | 45-70 | Habitaciones por etapa, persistencia |
| `game/isla-ancestral/scripts/construccion/placement_rule.gd` | 31-90 | Campos declarativos de la receta |
| | 101-127 | Huella con rotación, costo, devolución |
| `game/isla-ancestral/scripts/construccion/build_catalog_db.gd` | 17-21 | 12 familias |
| | 32-66 | Carga recursiva y registro |
| `game/isla-ancestral/scripts/construccion/construccion_tipos.gd` | 28-61 | Categorías y mapa familia→categoría |
| `game/isla-ancestral/data/construccion/piezas/pared_madera.tres` | 1-14 | Receta de pared |
| `.../techo_paja.tres` | 1-16 | Receta de techo 2×2, soportes 2 |
| `.../puerta_madera.tres` | 1-15 | Puerta 1×2, `requiere_pared` |

### 6.3 Assets y pipeline Blender

| Archivo | Líneas / clave | Qué aporta |
|---|---|---|
| `game/isla-ancestral/assets/3d/alta/18-Casas_casa_choza_ampliada.glb` | — | Casa 5,6×4,6×3,88 m |
| `.../18-Casas_casa_mediana.glb` | — | Casa 8,6×7,09×3,83 m |
| `.../18-Casas_casa_vecino.glb` | — | Casa 7,6×7,10×3,52 m |
| `.../18-Casas_casa_casona.glb` | — | No exportado (6.826 tris) |
| `.../18-Casas_casa_mansion.glb` | — | No exportado (8.779 tris) |
| `tools/mcp/blender-mcp/18-BIS-Casas-Grandes/CASA_01_CHOZA/INFORME_CASA_01.json` | 6-12 | 4.100 / 1.426 / 665 tris; 14 meshes; 8 mats |
| `.../CASA_02_CASA_MEDIANA/INFORME.json` | 5-10, 231-236 | 8×6 m; 4.300 tris; 8,6×7,09×3,83 |
| `.../CASA_03_CASONA/INFORME.json` | 3-10 | 10×8 m; 6.826 tris (rechazado) |
| `.../CASA_04_MANSION/INFORME.json` | 3-10 | 14×10 m; 8.779 tris (rechazado) |
| `.../CASA_05_CASA_VECINO/INFORME.json` | 3-10 | 7×5 m; 2.746 tris |
| `.../CATALOGO_CASAS_02_05.json` | — | Resumen de exportación y errores |
| `.../CASA_01_CHOZA/BAJA/crear_casa_01_choza.py` | 62-82 | Paleta y 8 materiales |
| | 815 | `assert alta["triangulos"] <= 6000` |
| | 1106-1107 | Presupuestos LOD 1.500 / 700 |

---

## 7. Conclusión final

1. **El juego necesita cinco tipos principales de casa** —choza, cabaña costera, casa mediana, casa artesano/taller, casona y mansión—, más la reutilizable **casa de vecino**. La progresión M18 (etapas 0–5) ya define el tamaño y las habitaciones; el diseño 3D debe seguir esa escalera, no inventar una paralela.

2. **El estilo es "cozy voxel redondeado + low-poly"** (`ART_STYLE_3D.md:8-16`): siluetas suaves, proporciones amables, sin bordes agresivos. La paleta real del pipeline (madera 180,140,90; oscura 90,65,40; paja 210,180,120; piedra 130,125,120) es coherente con la paleta pastel de M09 y debe reutilizarse.

3. **Materiales:** color por vértice + Principled BSDF, 6–8 materiales por casa, **sin imágenes de textura** en `assets/3d/` (0 confirmadas). El atlas M47 1024²/32 px queda como opción para primer plano; no es necesario para la silueta.

4. **Polígonos:** LOD0 **2.500–5.800 tris** por casa (cabaña ~3.200; mediana ~4.300; artesano ~5.400), LOD1 ~1.500, LOD2 ~450–650. El techo M45 de 15.000 tris es el máximo teórico, pero el pipeline actual de casas usa 6.000: **casona y mansión deben dividirse en alas** o aceptar el techo de 6.000 por volumen.

5. **Integración:** `TerrainLocator` es obligatorio; validar huella y pendiente; usar M17/`.tres` para construcción del jugador y GLB único para NPC/pueblo; colisión estática + `Area3D` de puerta; interior por portal (`HouseInterior`), no voxel; guardado por IDs en `house_manager.gd`.

6. **Los dos diseños propuestos** —"Taller de Marea" (artesano, 8×6 m, 5.400 tris) y "Refugio del Pescador" (cabaña costera, 5×4 m, 3.200 tris)— son viables con el pipeline actual, respetan los 8 materiales y los 3 LODs, y cubren dos huecos reales: **taller funcional** (RF8) y **variedad costera** (M34/M167).

7. **Acción recomendada inmediata:** (a) decidir si la casona/mansión se dividen en alas o se modelan a 6.000 tris; (b) crear los `.blend` y scripts de los dos diseños en `tools/mcp/blender-mcp/18-Casas/`; (c) exportar solo tras aprobación visual del usuario; (d) validar con `godot_get_debug_output` y capturas orbitales antes de integrar.

**Estado del reporte:** diseño completo, listo para modelado. No se modificó código ni assets.