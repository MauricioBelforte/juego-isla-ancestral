# Log 730 — M16 Crafting 3D: CIERRE (gema tallada + frasco de agua + bowl de barro)

**Agente:** WorkBuddy (Hy4 preview)
**Fecha:** 2026-09-06
**Módulo:** 16 — Crafting (assets 3D)
**Reserva:** `Logs/reservas/730-workbuddy-M16-3D.txt` (liberada al cerrar este log)

---

## 1. Contexto

El log 679 cerró las 4 herramientas de mano de M16 (hacha_hierro, martillo,
azada, machete). Quedaban 3 ítems en la checklist de objetos Blender:

```
- [ ] Gema tallada
- [ ] Frasco de agua
- [ ] Bowl/plato de barro
```

Con estos 3, **M16 queda cerrado al 100% en 3D (7/7 assets)**.

Directiva permanente del usuario aplicada: *"los diseños tienen que ser
premium"* y *"asi con todo los objetos que creemos"* (no flotar, E-12/E-13).

---

## 2. Entregables

| Asset | Archivo generador | SM_ | Tris | Mats | z_min | toca | fp | bbox XY |
|---|---|---|---|---|---|---|---|---|
| Gema tallada | `crear_gema_tallada_lowpoly.py` | 1 | 96 | 3 | 0.0450 | 9 | 0.15×0.15 | 0.30×0.30 |
| Frasco de agua | `crear_frasco_agua_lowpoly.py` | 4 | 420 | 4 | 0.0450 | 13 | 0.12×0.12 | 0.18×0.18 |
| Bowl de barro | `crear_bowl_barro_lowpoly.py` | 1 | 280 | 3 | 0.0450 | 15 | 0.11×0.11 | 0.21×0.20 |

Variantes M166 derivadas de ALTA (sin duplicar arte):

| Asset | ALTA | MEDIA | BAJA |
|---|---|---|---|
| gema_tallada | 1 / 96 / 3 | 1 / 96 / 3 | 1 / 66 / 3 |
| frasco_agua | 4 / 420 / 4 | 4 / 420 / 4 | 4 / 292 / 4 |
| bowl_barro | 1 / 280 / 3 | 1 / 280 / 3 | 1 / 196 / 3 |

Presupuesto M166 §3.3 — ALTA ≤16 obj / ≤6000 tris / ≤12 mats ·
MEDIA ≤8 / ≤1500 / ≤8 · BAJA ≤6 / ≤700 / ≤4. **Las 9 variantes entran sobradas.**

---

## 3. Decisiones de diseño

### 3.1 Gema tallada — talla escalonada, sección octogonal, 1 objeto con 3 zonas

- 6 anillos `loft()` con `lados=8`: culete truncado → escalón del pabellón →
  filetin (banda de 2.3 cm) → escalón de la corona → tabla.
- **El culete está truncado a propósito.** Un pabellón que termina en punta
  apoyaría sobre un solo vértice: `toca=1`, huella nula, y la gema "flotaría"
  en todos los azimuts. Truncando, apoya sobre una cara plana de Ø 0.15.
- **3 materiales en 1 objeto sin sumar triángulos**: se asigna
  `material_index` por la altura del centro de cada cara (pabellón oscuro /
  filetin medio / corona clara). El degradado de valor es lo que hace que una
  gema de 96 tris lea como tallada y no como un octaedro de plástico.
- Emisión suave (0.16 / 0.22 / 0.30) para que lea como gema "ancestral" sin
  convertirse en una lámpara.

### 3.2 Frasco de agua — vidrio translúcido con agua como malla propia

- Vidrio: `loft()` `lados=12`, panza Ø 0.18, cuello corto, boca con labio.
  `blend_method='BLEND'` + `Alpha=0.45`.
- **El agua es una malla independiente**, no un material del vidrio: con un
  solo cuerpo no hay forma de marcar el nivel del líquido. Son ~8 mm más chica
  que el vidrio en cada altura para que se vea el espesor de la pared.
- **El agua arranca 14 mm por encima del fondo del vidrio.** Motivo: el guard
  de apoyo cuenta los vértices a menos de `tol=5 mm` de `Z_APOYO`. Si el agua
  empezara en el fondo, sus vértices entrarían en la cuenta y la huella
  declarada dejaría de corresponder a lo que de verdad toca la arena.
- Corcho semihundido (la mitad inferior dentro de la boca) + cuerda torus en
  el cuello. **E-85**: el torus ya nace horizontal, no rotarlo.
- Vidrio cerrado arriba (`tapar_arriba=True`): si la boca quedara abierta se
  verían las contracaras del vidrio.

### 3.3 Bowl de barro — pieza HUECA (y de ahí `revolucion()`)

Ver E-92 más abajo: `loft()` no podía hacerlo y la alternativa de dos lofts
dejaba un bloque macizo. Resultado: **1 objeto / 280 tris / 3 materiales**
(barro, vidriado interior, dos franjas pintadas) asignados por tramo del perfil.

---

## 4. E-92 — `revolucion()` y el volumen firmado (lección nueva)

**Problema:** un bowl es una pieza hueca. Su perfil **sube** por la pared
exterior y **vuelve a bajar** por la interior. `loft()` exige z crecientes
(guard de E-77), y construirlo con dos lofts más un disco tapando el borde
tapa la boca: el cuenco desaparece.

**Solución:** helper `revolucion()` agregado a
`tools/mcp/blender-mcp/scripts-reutilizables/plantilla_asset.py`. Revoluciona
un perfil 2D `(r, z)` alrededor de Z y acepta perfiles no monótonos.

Dos claves:

1. **Orientación automática.** Las caras usan el mismo winding que `loft()`
   (`(a[i], a[j], b[j], b[i])`), que apunta hacia afuera cuando el perfil sube.
   Cuando el perfil baja —el tramo de la pared interior— ese mismo winding se
   invierte solo y la normal pasa a mirar hacia la cavidad. Sin
   `flip_normals()` y sin geometría duplicada.
2. **Material por tramo** (`idx_mat`, un entero por segmento del perfil). Las
   franjas pintadas y el vidriado interior no cuestan ni un triángulo ni un
   objeto extra.

**Vértices en el eje:** si un punto tiene `r ≈ 0`, se crea **UN** vértice y se
abanica, no `lados` coincidentes. Son los vértices degenerados que dejaron 72
en el origen en `cristal_ancestral` MEDIA (E-72).

**Verificación sin visión — VOLUMEN FIRMADO.** Si el perfil arranca y termina
en el eje, la superficie es cerrada y encierra el volumen de barro. Por el
teorema de la divergencia, `V = (1/6)·Σ(v0×v1)·v2` sobre los triángulos da
**> 0 ssi las normales apuntan hacia afuera**. Un assert de una línea que
atrapa un bowl "del revés" en autoría. `bowl_barro` dio **+488 cm³** → correcto,
confirmado después en las 6 capturas orbitales.

Documentado en `DOCUMENTACION/09-GUIA-BLENDER.md` §3 (E-92) y §4 (checklist).

---

## 5. Corrección a E-91 (regla escrita en el log 679)

En el log 679 dejé escrito en el checklist: *"Si la pieza es ancha (lingote,
tablón, cesta, vasija) sí va el E-50 original"*. **Es incorrecto.**

El criterio no es "alargado vs ancho", es **tamaño absoluto**. E-50 exige
`min(fp) > 0.30`, así que rechaza a **todo objeto de menos de ~0.7 m de
diámetro**, sea alargado o ancho. Un bowl de 0.21 m y un frasco de 0.18 m son
"anchos" en forma pero chicos en medida: E-50 los rechaza espuriamente.

Corregido en `09-GUIA-BLENDER.md` §4: E-50 original solo para props de ~1 m o
más; todo lo demás va con `asentar_herramienta()`.

---

## 6. Verificaciones

- **E-13 (6 capturas orbitales por variante):** 3 assets × 3 variantes × 6 = **54
  PNG** en `tools/mcp/blender-mcp/16-Crafting/capturas/`, más **9 hojas de
  contacto** `_hoja_{asset}[_media|_baja]_v1.jpg`. Aprobación visual ✓ en las 9:
  ningún azimut muestra aire entre el objeto y la arena.
- **E-12/E-24 (asentado):** los 9 blends con `z_min = 0.0450` medido sobre
  vértices reales. `generar_variante.py` re-asentó con `delta = -0.000` en las 6
  derivadas.
- **E-63 (whitelist MODULOS):** `16-Crafting` está en la tupla (3.º). DRY antes
  del real: **9 planeados, 0 errores**.
- **E-49 (export forzado):** `EXPORT_FORZAR=1` → **33 GLB exportados, 0 errores**
  (re-exportó todo el módulo; los 9 de este log incluidos).
- **E-65/E-72 (sidecars por CONTEO, no por mtime):** `godot --headless --import`
  y luego, para cada uno de los 9, se resolvió el `.glb.import` → `.scn` real en
  `.godot/imported/`. **9/9 OK.**
- **Presupuesto:** auditado en la salida de `auditar` de cada generador y en el
  reporte de `generar_variante.py` (tris reales con `calc_loop_triangles()`).

---

## 7. Archivos tocados

**Nuevos:**
- `tools/mcp/blender-mcp/16-Crafting/scripts/crear_gema_tallada_lowpoly.py`
- `tools/mcp/blender-mcp/16-Crafting/scripts/crear_frasco_agua_lowpoly.py`
- `tools/mcp/blender-mcp/16-Crafting/scripts/crear_bowl_barro_lowpoly.py`
- 9 `.blend` (ALTA/MEDIA/BAJA × 3) en `tools/mcp/blender-mcp/16-Crafting/`
- 54 PNG + 9 JPG en `tools/mcp/blender-mcp/16-Crafting/capturas/`
- 9 GLB en `game/isla-ancestral/assets/3d/{alta,media,baja}/`

**Modificados:**
- `tools/mcp/blender-mcp/scripts-reutilizables/plantilla_asset.py` — helper
  `revolucion()` (aditivo, no rompe a nadie).
- `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` — 3 ítems M16 a `[x]`;
  contadores 99 → **102** completados, 49 → **46** pendientes.
- `DOCUMENTACION/09-GUIA-BLENDER.md` — E-92 en §3, bullet en §4, corrección de
  la regla de E-91.
- `CHECKLIST-GLOBAL.md` — fila 16 actualizada.

---

## 8. Deudas que quedan

- Backlog 3D global (fuera de M16): M33 11 · M25 6 · M36 5 (reservado por otro
  modelo, NO tocar) · M34/35 4 · M40 1 · M18-BIS 19.
- QA visual de los assets M19 (6 de 7 pendientes). Por la regla nueva de
  asignación (§15.3 de `10-GUIA-COMPARATIVA-MODELOS.md`), la aprobación visual
  final no debe apoyarse solo en Hy4: su lectura de imágenes es intermitente.
- Instanciado en Godot de los assets M19 (cabezas/ropas como hijos del NPC).
- 11 archivos `~libvoxel...TMP` (82 MB) en `addons/zylann.voxel/bin/`.
- Commit + push **selectivo** (el árbol tiene ~335 cambios de otro modelo; no
  se tocaron).

---

## 9. Liberación

Módulo 16 (Crafting) — **3D cerrado al 100% (7/7 assets)**. Reserva liberada.
No queda ningún módulo reservado por este agente.

**Firma:** WorkBuddy (Hy4 preview) · Plataforma: WorkBuddy / Windows ·
2026-09-06
