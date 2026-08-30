# 245 — M166 · Creación del puente de cuerda (Tier D-2)

**Fecha:** 2026-08-29
**Hora de capturas:** 21-12-29
**Módulo:** M166 (Assets 3D — pipeline Blender)
**Carpeta destino:** `tools/mcp/blender-mcp/25-Ruinas-Templos/`
**Estado:** APROBADO

---

## 1. Pedido

Continuar con el **Tier D** del checklist de objetos Blender. Ítem 2:

> `- [ ] Puentes de cuerda (M25)`

Ítem 1 del mismo tier (vieira de playa, M45) ya estaba cerrado en el log 244.

---

## 2. Diseño

Puente colgante de madera y cuerda, de un solo tramo, pensado para cruzar
un río o quebrada de la isla. Composición:

| Pieza | Cantidad | Detalle |
|---|---|---|
| Postes de piedra | 4 | 2 por cabecera, cilindros de `r=0.085`, `h=1.40` |
| Tablas del tablero | 13 | `0.125 × 0.030`, siguiendo la catenaria |
| Cuerdas maestras | 2 | catenaria, `r=0.024`, 5 lados, 12 segmentos |
| Pasamanos | 2 | catenaria más alta y más tensa, `r=0.024` |
| Colgantes verticales | 10 | `r=0.011`, en x = −0.90, −0.45, 0.00, 0.45, 0.90 |

Todo en **un solo bmesh y un solo objeto** (`E-27` queda sin efecto por
construcción: no hay piezas hijas que puedan desacoplarse).

### Parámetros

```python
LARGO    = 2.40;  ANCHO = 0.90
MITAD_X  = 1.20;  MITAD_Y = 0.45
Z_CUERDA_EXT = 0.72;  SAG_CUERDA = 0.24
Z_PASAM_EXT  = 1.28;  SAG_PASAM  = 0.16
H_POST   = 1.40;  R_POST = 0.085
N_TAB    = 13;   ANCHO_TAB = 0.125;  GROSOR_TAB = 0.030
R_CUERDA = 0.024; LAD_CUERDA = 5;   N_SEG = 12
R_COLGANTE = 0.011
HANG_X = (-0.90, -0.45, 0.0, 0.45, 0.90)
```

### Catenaria

```python
def z_cat(x, z_ext, flecha):
    t = x / MITAD_X
    return z_ext - flecha * (1.0 - t * t)
```

Parábola de segundo grado: en los extremos (`|t| = 1`) da `z_ext`, en el
centro baja `flecha`. Simple, sin dependencias, y suave al ojo.

---

## 3. Ejecución

```
PUENTE asentado: z_min 0.0000 -> 0.0450 (delta +0.0450, piezas=1)
PUENTE CUERDA OK — objetos SM_: 1 — tris: 828 — materiales: 3
```

- `z_min = 0.0450` → aplica **E-12** (5 mm hundido bajo la arena, cuyo techo
  está en `0.050`). No flota.
- 1 objeto, 3 materiales (madera / cuerda / piedra).
- Bounding box: `x[-1.285 .. 1.285]  y[-0.535 .. 0.535]  z[0.045 .. 1.445]`

---

## 4. Variantes y presupuesto (triángulos REALES)

Medido con `loop_triangles`, no con `polygons` (ver E-33).

| Variante | Tris reales | Presupuesto | Objs | Mats | Estado |
|---|---|---|---|---|---|
| SRC  | 828 | —     | 1 | 3 | — |
| MEDIA | 828 | 1500 | 1 | 3 | OK (55 %) |
| BAJA  | 578 | 700  | 1 | 3 | OK (83 %) |

---

## 5. Capturas

18 capturas orbitales (6 azimuts × 3 perfiles), más 3 hojas de contacto:

```
25-Ruinas-Templos/capturas/puente_cuerda_{src,media,baja}_21-12-29_az{000,060,120,180,240,300}.png
25-Ruinas-Templos/capturas/puente_cuerda_{src,media,baja}_21-12-29_hoja.jpg
```

Las 3 hojas reportaron "con 6 capturas" (E-30: el modo prefijo de
`contact_sheet.py` busca en el CWD, hay que entrar a `capturas/`).

**Aprobación visual:** postes firmes en ambos extremos, tablero en
catenaria, dos cuerdas maestras, dos pasamanos y los 10 colgantes en su
lugar. Sin flotamiento en ninguno de los 6 ángulos.

---

## 6. Hallazgos técnicos

### E-32 v2 — el test del centroide NO sirve para islas no convexas

El patrón v1 de E-32 (recalc + medición global, o test del centroide para
islas convexas) **falló** en este asset: los tubos de la catenaria son islas
alargadas y curvadas, no convexas. Un punto "centro" adivinado puede quedar
fuera del sólido, y entonces `normal · (centroide_cara − centro)` da signos
incorrectos.

**Test universal: volumen firmado** (teorema de la divergencia). Para una
isla cerrada,

```python
def volumen_firmado(caras):
    v = 0.0
    for f in caras:
        co = [vert.co for vert in f.verts]
        for k in range(1, len(co) - 1):
            v += co[0].dot(co[k].cross(co[k + 1]))
    return v / 6.0
```

- `V > 0` → las normales apuntan hacia afuera → isla correcta.
- `V < 0` → la isla está del revés → invertir.

Vale para **cualquier** isla cerrada, convexa o no. Encapsulado en:

```python
def cerrar_isla(caras):
    bmesh.ops.recalc_face_normals(bm, faces=caras)
    if volumen_firmado(caras) < 0.0:
        bmesh.ops.reverse_faces(bm, faces=caras)
    return caras
```

Usada por `caja()` y por `tubo()`. **Este es el patrón a usar de ahora en
adelante**, y reemplaza las dos variantes de v1.

### E-33 — `generar_variante.py` reportaba CARAS, no triángulos

Corregido en el origen: el print final ahora usa `len(m.loop_triangles)`
después de `m.calc_loop_triangles()`, en vez de `len(mesh.polygons)`.

Impacto: en mallas quad, `polygons` subestima ~2×. El puente reportó 482
"tris" cuando en realidad tiene 828.

### E-34 — `generar_variante.py` duplicaba slots de material

`new_from_object()` **ya** copia los slots del objeto evaluado; el código
encima volvía a appendarlos → 3 slots se convertían en 6. BAJA tiene límite
de 4 materiales, así que el puente quedaba marcado como excedido sin
razón.

Corrección en el origen:

```python
o.data.materials.clear()
for m in mats:
    o.data.materials.append(m)
```

Y saneo masivo con el nuevo `scripts-reutilizables/saneo_bajas_e34.py`:

```
total: 46 | modificados: 45 | ya limpios: 1 | fallas: 0
```

---

## 7. Auditoría real de presupuesto (109 variantes)

Nueva herramienta `scripts-reutilizables/auditar_presupuesto.py`. Mide tris
reales, objetos, slots, materiales efectivamente usados por las caras, y
`z_min`. Reemplaza a `auditar_optimizacion.py`, que **solo** escanea el
sistema de archivos buscando si existe `_media.blend` (no mide nada).

**Corrección a mi propia documentación:** en el log 244 escribí que
`auditar_optimizacion.py` "ya cuenta tris reales". Leyendo su fuente, no es
así. Queda corregido en la guía y en el checklist.

Resultado:

```
TOTAL: 109 variantes, 18 exceden el presupuesto
```

Los 18 exceden **solo por `tris+`**. No hay ningún `obj+` ni `mats+`.

**Héroes `_alta_media` (11)** — se asume que son lod de héroes, el
presupuesto de MEDIA no les aplica igual:

| Asset | Tris | Presupuesto |
|---|---|---|
| `pico_hierro_alta_media` | — | 1500 |
| `hacha_piedra_alta_media` | 2448 | 1500 |
| `altar_ritual_alta_media` | 2320 | 1500 |
| `cofre_ancestral_alta_media` | 11510 | 1500 |
| `puerta_templo_alta_media` | 2820 | 1500 |
| `bote_pesca_alta_media` | 2512 | 1500 |
| `farola_fuego_alta_media` | 2410 | 1500 |
| `muelle_madera_alta_media` | 3836 | 1500 |
| `concha_mar_alta_media` | 2232 | 1500 |
| `monolito_glifos_alta_media` | 4656 | 1500 |
| `totem_isla_alta_media` | 21014 | 1500 |

**Assets `_lowpoly` dados por aprobados que realmente exceden (7)** —
estos sí son deuda técnica:

| Asset | Tris | Presupuesto | Exceso |
|---|---|---|---|
| `cofre_ancestral_baja` | 962 | 700 | +37 % |
| `helecho_gigante_baja` | 1144 | 700 | +63 % |
| `helecho_gigante_media` | 2288 | 1500 | +53 % |
| `hierba_alta_baja` | 1072 | 700 | +53 % |
| `hierba_alta_media` | 1536 | 1500 | +2 % |
| `hongo_luminoso_baja` | 1010 | 700 | +44 % |
| `nido_cocos_media` | 1636 | 1500 | +9 % |

Queda como **Task #34**.

---

## 8. Archivos tocados

| Archivo | Acción |
|---|---|
| `25-Ruinas-Templos/scripts/crear_puente_cuerda_lowpoly.py` | CREADO |
| `25-Ruinas-Templos/puente_cuerda_lowpoly.blend` | CREADO |
| `25-Ruinas-Templos/puente_cuerda_lowpoly_media.blend` | CREADO |
| `25-Ruinas-Templos/puente_cuerda_lowpoly_baja.blend` | CREADO |
| `25-Ruinas-Templos/capturas/puente_cuerda_*_21-12-29_*.png|jpg` | CREADOS (21) |
| `scripts-reutilizables/generar_variante.py` | EDITADO (E-33, E-34) |
| `scripts-reutilizables/saneo_bajas_e34.py` | CREADO |
| `scripts-reutilizables/auditar_presupuesto.py` | CREADO |
| `DOCUMENTACION/09-GUIA-BLENDER.md` | EDITADO (E-32 v2, E-34, §4) |
| `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` | EDITADO |

---

## 9. Verificación final

- [x] Un solo objeto (`E-27` irrelevante por construcción)
- [x] `z_min = 0.0450` → no flota (**E-12**)
- [x] Tris reales dentro del presupuesto en MEDIA y BAJA
- [x] 3 materiales, sin slots duplicados (**E-34**)
- [x] 18 capturas orbitales + 3 hojas, todas con 6 capturas (**E-13**)
- [x] Aprobación visual

---

## 10. Pendiente

- **Tier D-3:** Pozo de piedra (M40)
- **Tier D-4:** Puentes de troncos (M40)
- **Task #34:** re-derivar los 7 assets `_lowpoly` que exceden con `--ratio`
- **17 héroes** con `_alta_media` pero sin `_alta_baja`
- **Pipeline Blender → Godot:** sigue en cero (0 assets integrados)

---

*Firmado: M166 · $1285 · 2026-08-29 21:12*
