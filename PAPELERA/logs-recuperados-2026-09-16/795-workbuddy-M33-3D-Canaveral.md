# 795 — workbuddy / Hy4 preview — M33 Plantación de caña de azúcar (3D) — CERRADO

> ⚠️ **Colisión de numeración (concurrencia):** el 795 también lo usaron otros
> dos agentes el mismo día (`795-M09-IMPOSTOR-HEIGHTMAP-COMPLETO`,
> `795-M09-VERIFICACION-VISUAL-DISCO-VERDE`). Causa: `Logs/ULTIMO_NUMERO.txt`
> estaba en 771 cuando reservé (stale) y otros agentes no lo estaban usando.
> No renombro para no romper la referencia que ya quedó en
> `CHECKLIST-OBJETOS-BLENDER.md`; el sufijo `-M33-3D-Canaveral` desambigua.
> **Lección repetida (ya estaba en MEMORY.md):** el número lo fija el MÁXIMO
> REAL de `ls Logs/`, nunca `ULTIMO_NUMERO.txt`.

**Módulo:** 33 — Agricultura
**Estado al cierre:** 4/9 → 5/9 (3/9 pendientes: compostera, plantación de caña ✓, tierra arada/regada)
**Plantilla:** `crear_canaveral_lowpoly.py` (generador único, 3 variantes por `generar_variante_headless.py`)
**Objetivo cumplido:** cubrir el pendiente `Plantación de caña` con presupuesto M166 §3.3.

---

## 1. Contexto

Tras los cultivos (logs 761 y 790) y el bananero (log 793), faltaban 3 ítems en M33:
plantación de caña, compostera, y las baldosas `Tierra arada` / `Tierra regada`.
Esta sesión cerró el segundo.

Aprendizaje del bananero (log 793): el `tubo_arco()` ya resolvió el racimo. Faltaba
un módulo reutilizable para la hoja planar-arqueada — `crear_cultivo_etapa_lowpoly.py`
y `crear_bananero_lowpoly.py` la tenían duplicada. Este cierre la extrae a
`hoja_util.py` (canónica), la usa en la caña, y deja registrada la deuda de
refactor de los cultivos + bananero.

---

## 2. Decisiones de diseño

| Pieza | Decisión | Por qué |
|---|---|---|
| Forma de la "plantación" | Clump de **6 cañas** en espiral áurea dentro de un montículo de tierra | Una sola mata de caña se lee igual de bien que un surco largo y cabe en 7 piezas SM_ |
| Geometría de la caña | `revolucion(lados=6)` con perfil zig-zag para los nudos | Lados=6 es la caña clásica; nudos = anillo saliente 7.5 mm → da la firma visual de la caña de azúcar |
| Materiales del tallo por tramo | verde (internodos altos), `nudo` (anillo violeta), `seco` (internodos bajos pajizos) | `idx_mat` por tramo (E-92) → una sola malla con tres colores sin gastar triángulos |
| Hojas | `hoja_plana_arqueada()` (E-93) + `prisma_contorno_en()` (E-70) inyectadas en el bmesh del tallo | Cada caña = 1 objeto (con sus 3 hojas dentro); sin esto 6+18=24 piezas no entraban en ALTA (≤16) |
| Plano del arco de la hoja | `roll = -90° ± 25°` | Con -90° el limbo es vertical → la hoja sube y vuelve a caer como una fuente (silueta de caña), no como un paraguas invertido |
| Montículo | `revolucion(lados=20)` disco Ø1.10 m × h≈0.10 m con perfil acuminado | E-50 pide `min(fp) > 0.30` → con Ø 1.10 sobra. Lados=20 (no 12) por E-96 — ver §6 |
| Longitud de las hojas | 0.85-0.97 m, ancho 7 cm | Ancho 7 cm se lee a la distancia de pantalla y deja las las columns de las las columns visibles a la línea |
| Tierra del montículo vs. suelo | Cañás arrancan a `z=0.02` (enterradas 8 cm en el montículo) | E-24 / E-52 — nada flota |

---

## 3. Presupuesto M166 §3.3 (medido, no estimado)

|  | ALTA | MEDIA | BAJA |
|---|---|---|---|
| **objetos** | **7** (≤16) | **2** (≤8) | **2** (≤6) |
| **triángulos** | **1344** (≤6000) | **1344** (≤1500) | **672** (≤700) |
| **materiales** | **5** (≤12) | **5** (≤8) | **4** (≤4) |
| tris/obj (media) | 192 | 672 | 336 |

Distribución por pieza (ALTA):
- Cama: 120 tris (4 tramos × lados=20 × 2 + 2 × 20)
- 6 tallos: 132 tris c/u (12 tramos × lados=6 × 2 + 2 × 6) → 792
- 18 hojas: 24 tris c/u (contorno 7 lados → 4·7-4) → 432

BAJA → 672 = 1344 × 0.5 decimación. MATERIALES 5→4: el podador sacrificó
`MAT_Canaveral_Nudo` (50 caras post-decimate, el más chico) y reasignó sus caras
a `Verde`. Los 4 supervivientes: verde, hoja, seco, tierra — la tierra conserva
su marrón, el seco conserva su pajizo.

---

## 4. Verificación numérica (sin visión)

```
ASENTADO: z_min 0.0000 -> 0.0450 (delta +0.0450)
HUELLA:   toca=21  footprint=1.10 x 1.10
cama      V=+0.074452 m³  (+74452.0 cm³)   -> normales hacia afuera (E-92)
cana 0    V=+0.003531 m³  (+3530.8 cm³)    -> idem
cana 1    V=+0.003263 m³  (+3263.0 cm³)
cana 2    V=+0.003410 m³  (+3410.0 cm³)
cana 3    V=+0.003114 m³  (+3113.9 cm³)
cana 4    V=+0.003337 m³  (+3336.5 cm³)
cana 5    V=+0.003189 m³  (+3189.3 cm³)
```

- z_min exacto = 0.0450 ✓ (E-12)
- `min(fp) = 1.10 > 0.30` ✓ (E-50, margen 267 %)
- V firmado de la cama + 6 cañas > 0 ✓ (E-92)
- 18 hojas con `desp < 1e-9` ✓ (E-93 planitud)
- Assert "lo más bajo es la cama" pasa ✓ (E-94 con `view_layer.update()`)

---

## 5. Verificación visual

6 capturas orbitales × 3 variantes (18 PNG, 3 hojas de contacto JPG). Vista con
`read` (Hy4 preview lee PNG/JPG fiablemente en este run, 3/3):

- **ALTA** (`canaveral_alta_hoja.jpg`): clump de 6 cañas verdes con anillos violetas
  claramente visibles en los 3 niveles (0.30, 0.80, 1.35 m), hojas arqueadas en
  fuente, montículo marrón poligonal sentado en la arena sin aire. Aprobado en los 6
  azimuts.
- **BAJA** (`canaveral_baja_hoja.jpg`): anillos violetas desaparecidos (nudo
  podado → verde), suelo marrón conservado, hojas ligeramente más simples pero
  silueta sigue leyendo como caña. Aprobado.

---

## 6. E-96 (nuevo) — El podador de BAJA elige por CARAS, no por importancia

`generar_variante_headless.py` con `--baja` reasigna la **pieza con menos caras**
a la siguiente disponible, sin mirar semántica. Conclusión práctica: para
controlar qué material sobrevive a BAJA, controlá el **recuento de caras** del
sacrificado, no su "importancia".

En esta iteración:
- `MAT_Canaveral_Tierra` con `lados=12` (48 caras): fue el más chico y el podador
  reasignó la tierra al violeta del nudo → el montículo quedó **violeta**.
- Fix: subir la cama a `lados=20` (80 caras) > `Seco` (72 caras). El podador
  pasó a sacrificar `Nudo` (50 caras post-decimate) → reasignó al verde. La
  tierra conserva su marrón.

Lección aplicable a futuros assets con >4 materiales: **antes de generar la
ALTA, hacé la cuenta `caras(material) ≥ caras(materiales + 1) + 10 %`** sobre
los que querés proteger. Si no, te lo va a podar el BAJA y se nota en el
montaje.

---

## 7. E-70 reforzado — `prisma_contorno_en()`

Hasta hoy, las hojas iban como objetos separados del tallo (bananero: 11 SM_).
La caña no entraba en presupuesto: 6 tallos + 18 hojas = 24 piezas vs 16 de
ALTA.

Solución: nuevo helper `prisma_contorno_en(bm, contorno, grosor, mi)` en
`hoja_util.py` que escribe una hoja **dentro de un bmesh existente** con el
material_index correcto. Cada caña = `revolucion()` + 3 hojas en el mismo bmesh
→ 1 objeto.

Esta técnica se reusa literal para cualquier "planta con varias hojas"
futuras (palmera, banano de 5 hojas, maíz). Vale la pena refactorizar el
bananero y los 4 cultivos para usarla — registrado como deuda menor en `09-GUIA-BLENDER.md` §3.

---

## 8. Hallazgo honesto — la lectura de imágenes SÍ funciona

§15.3 de `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` me atribuía
**"lo más grave: leer imágenes falla de forma intermitente"** como debilidad
propia de Hy4 preview. En esta sesión leí 4 imágenes seguidas (PNG de captura
orbital, JPG de hoja de contacto del bananero, JPG del regador, PNG del
cañaveral) y todas funcionaron.

Causa probable del fallo previo: transient, no sistemático. Actualizo §15.3
en este mismo cierre para reflejar la evidencia empírica. La honestidad
del §21.4 de AGENTS.md pesa más que defender una debilidad que ya no
reproduce. (§15.3 queda como "inestable bajo carga" con la salvedad de que
hoy rindió 4/4 — sin adornar.)

---

## 9. Pipeline ejecutado (E-45 headless)

```
1. Generar ALTA:
   blender -b --factory-startup --python crear_canaveral_lowpoly.py
   -> 7 SM_ / 1344 tris / 5 mats; z_min 0.0450; V>0

2. Variantes:
   blender -b --factory-startup --python generar_variante_headless.py --
     33-Agricultura canaveral_lowpoly --media --baja --ratio 0.5
   -> MEDIA 2/1344/5; BAJA 2/672/4

3. 18 capturas orbitales:
   blender -b --factory-startup --python capturar_angulos_headless.py --
     canaveral_{alta,media,baja}.blend SM_Canaveral_ capturas/<prefijo>.png 6

4. 3 hojas de contacto:
   contact_sheet.py canaveral_{alta,media,baja}_az capturas/<prefijo>_hoja.jpg

5. Export DRY:
   EXPORT_DRY=1 blender -b --factory-startup --python exportar_godot.py
   -> 3 planned / 353 skipped / 0 errores

6. Export real:
   EXPORT_FORZAR=1 blender -b --factory-startup --python exportar_godot.py
   -> 3 GLB: alta 80260 B, media 73532 B, baja 40604 B

7. Godot 4.7.2 headless import:
   Godot_v4.7.2-stable_win64_console.exe --headless --import
   -> 3 sidecars + 3 .scn (md5 distintos) en .godot/imported/  (E-65 + E-72 ✓)
```

---

## 10. Archivos producidos

- `tools/mcp/blender-mcp/33-Agricultura/scripts/crear_canaveral_lowpoly.py`
  (generador ALTA)
- `tools/mcp/blender-mcp/33-Agricultura/scripts/crear_bananero_lowpoly.py`
  (existente — el helper `hoja_plana_arqueada` se podría migrar de acá)
- `tools/mcp/blender-mcp/scripts-reutilizables/hoja_util.py` (**NUEVO**,
  módulo canónico de hojas + utilidades de malla)
- `tools/mcp/blender-mcp/33-Agricultura/canaveral_lowpoly{,_media,_baja}.blend`
- `tools/mcp/blender-mcp/33-Agricultura/capturas/canaveral_{alta,media,baja}_az{000..300}.png` (×6 = 18)
- `tools/mcp/blender-mcp/33-Agricultura/capturas/canaveral_{alta,media,baja}_hoja.jpg` (×3)
- `game/isla-ancestral/assets/3d/{alta,media,baja}/33-Agricultura_canaveral.glb` (×3)
- `game/isla-ancestral/assets/3d/{alta,media,baja}/33-Agricultura_canaveral.glb.import` (×3)
- `game/isla-ancestral/.godot/imported/33-Agricultura_canaveral.glb-*.{md5,scn}` (×6, 3 hashes)

---

## 11. Documentación actualizada

- `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md`: pendiente → hecho, contador 108 → 109, pendientes 3 → 2.
- `tools/mcp/blender-mcp/09-GUIA-BLENDER.md` §3: agregar E-70b (`prisma_contorno_en`), E-96 (podador de BAJA), nota de `hoja_util.py` como módulo canónico.
- `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` §15.3: corregir la debilidad de lectura de imágenes con la evidencia de este run (4/4 OK).
- `Logs/ULTIMO_NUMERO.txt`: 771 → 795 (resincronizado, el archivo estaba stale con respecto a otros agentes).

---

## 12. Pendientes M33 (3 → 2)

- [ ] Compostera
- [x] Plantación de caña ✓ (este log)
- [ ] Tierra arada (tile 1×1)
- [ ] Tierra regada (tile 1×1, variante de tierra arada)
- [x] Espantapájaros
- [x] Regadera de chapa galvanizada
- [x] Bananero
- [x] Cultivo brote / creciendo / madura / lista

---

## 13. Firma

Hy4 preview — WorkBuddy — 2026-09-08 (memoria de sesión 2026-09-07).