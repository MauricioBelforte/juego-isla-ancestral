# Log 558 — M33 Espantapájaros v2 (re-trabajo post feedback E-73)

**Fecha:** 2026-09-02 19:50 (hora del sistema; el reloj inyectado puede estar desfasado)
**Agente:** MiniMax-M3 · WorkBuddy AI · Windows
**Módulo:** 33 — Agricultura
**Asset:** `espantapajaros` (M33)
**Tarea:** re-trabajo del asset aprobado en log 532 (2026-09-02 04:50)
**Estado:** ✅ CERRADO — 3 GLB re-exportados, 3 `.import` + 3 `.scn` (E-65 + E-72)

---

## 1. Origen: feedback del usuario

> *"ese tronco que tiene en el pecho atravesado quitaselo , parece la pinga"*

Sobre el espantapájaros aprobado en el log 532 a las 04:50: el palo horizontal
`SM_Espanta_Brazo` (1 caja de `1.30 × 0.07 × 0.07` a `z=1.65`) que cruzaba el
cuerpo de hombro a hombro lee como genital, no como bracito. La v2 lo reemplaza
por **dos brazos independientes** que nacen en cada hombro y bajan en diagonal.

---

## 2. Lección nueva: E-73

**Un travesaño horizontal largo y delgado a la altura del pecho/torso de una
figura humanoide LEE COMO FALO.** El cerebro prioriza genitales sobre ropa. La
forma larga + delgada + horizontal + centrada en el torso = silueta fálica
inequívoca.

**Regla de silueta:** si una pieza es larga, delgada y horizontal y queda alineada
con la cadera o el torso de una figura humanoide, NO la uses como elemento
estructural único. Rompela en dos y angulá cada mitad.

Aplicabilidad: maniquíes, cruces, siluetas de NPCs humanoides, cualquier "cruz"
de un cuerpo vertical. Si la pieza horizontal mide más que el ancho del torso,
casi siempre conviene angulizar.

Documentada en `DOCUMENTACION/09-GUIA-BLENDER.md` §3 (entrada E-73) y añadida
como ítem del §4 checklist global.

---

## 3. Decisión de diseño: dos brazos diagonales

Cada brazo es una caja de `0.50 × 0.07 × 0.07` anclada en:

```
hombro  = (sx * 0.16, 0, 1.62)   # adentro del torso (semiancho 0.19)
mano    = (sx * 0.543, 0, 1.299) # 40° debajo de la horizontal
ANG_BRAZO = 40°
L_BRAZO   = 0.50
```

Eje local del brazo rotado sobre `Y`:
- `+X` (brazo derecho): `rot_y = +40°` → cae a +X y -Z (abajo)
- `-X` (brazo izquierdo): `rot_y = 180° − 40° = 140°` → cae a -X y -Z (abajo)

La rotación de la caja preserva Y vertical, así que el grosor `0.07` del palo
queda en el plano horizontal — los brazos tienen **perfil de palo visto de
frente** y **espesor de palo visto desde arriba/lateral**. Buena lectura.

Las manos de paja (`SM_Espanta_Mano_{0,1}`) se reposicionan a
`(±0.58, 0, 1.28)`, ligeramente afuera y debajo de la punta del brazo, tamaño
`0.17 × 0.20 × 0.17`.

### 3.1. Costo de budget (E-70)

| | v1 (palo único) | v2 (2 brazos) |
|---|---|---|
| ALTA SM_ | 15 | **16** (techo ALTA ≤16) |
| MEDIA obj | 7 (madera = poste+brazo fundidos) | 7 (madera = poste+2 brazos fundidos) |
| BAJA obj | 6 | 6 |
| ALTA tris | ~270 | ~282 |
| BAJA tris | 186 | 194 |

**MEDIA y BAJA NO se resienten:** `generar_variante.py` agrupa por **lista de
materiales** y los dos brazos comparten `MAT_madera` con el poste → siguen
siendo 1 objeto fusionado en cada variante.

Lección: agregar una pieza en el mismo material que otra ya existente no siempre
cuesta un objeto en MEDIA/BAJA. Antes de rechazar un diseño por budget, simular
con `generar_variante.py`.

---

## 4. Pipeline ejecutado

1. **Sintaxis:** `py_compile` del generador v2 → OK.
2. **Generación ALTA:** `blender -b --factory-startup --python crear_espantapajaros_lowpoly.py`
   → `ASENTADO: z_min 0.0450 -> 0.0450`, `HUELLA: toca=20 footprint=0.80 x 0.80`.
3. **Captura ALTA:** `capturar_angulos_headless.py` con prefijo `SM_Espanta` →
   16 objetos encuadrados, 6 PNG. (E-66: el primer intento usó prefijo
   equivocado `espantapajaros_src` que matcheaba 0 objetos; corregido a `SM_Espanta`.)
4. **Hoja de contacto ALTA:** 6 azimuts visibles, 3 señales E-37 presentes
   (sombrero, cara con rasgos, paja). Pecho libre. Aprobado.
5. **Variantes:** `generar_variante.py 33-Agricultura espantapajaros_lowpoly.blend --media --baja`
   → MEDIA 7/320/7, BAJA 6/194/4.
6. **Captura MEDIA + BAJA:** 6+6 PNG, hojas de contacto armadas. Aprobadas.
   BAJA pierde ojos y boca (esperado por la poda); sombrero+silueta+paja siguen
   diciendo "espantapájaros".
7. **Export GLB:** `EXPORT_FORZAR=1 EXPORT_MODULOS=33-Agricultura blender -b --python exportar_godot.py`
   → 3 GLB: ALTA 32 KB / 16 obj, MEDIA 22 KB / 7 obj, BAJA 15 KB / 6 obj.
8. **Import Godot:** `Godot --headless --path game/isla-ancestral --import`
   → 3 `.glb.import` + 3 `.scn` generados.
9. **Verificación E-65 + E-72:** conteo `3 GLB = 3 .import = 3 .scn` para M33.
   Cobertura global 249/249 (los +6 sobre los 243 del log 532 son: 3 míos de
   M33 + 3 de otros modelos ajenos al working set de este log).

---

## 5. Archivos tocados

| Archivo | Tipo | Cambio |
|---|---|---|
| `tools/mcp/blender-mcp/33-Agricultura/scripts/crear_espantapajaros_lowpoly.py` | edit | v1 → v2: import `cos/sin/pi`, 2 brazos en lugar de 1, manos reposicionadas, docstring E-73, comentarios 3-4/5-6/.../15-16 renumerados |
| `tools/mcp/blender-mcp/33-Agricultura/espantapajaros_lowpoly.blend` | regen | re-generado |
| `tools/mcp/blender-mcp/33-Agricultura/espantapajaros_lowpoly_media.blend` | regen | re-derivado |
| `tools/mcp/blender-mcp/33-Agricultura/espantapajaros_lowpoly_baja.blend` | regen | re-derivado |
| `tools/mcp/blender-mcp/33-Agricultura/capturas/espantapajaros_src_19-48-55_az*.png` | new | 6 capturas ALTA v2 |
| `tools/mcp/blender-mcp/33-Agricultura/capturas/_hoja_cap_33_espantapajaros_lowpoly.jpg` | regen | hoja ALTA v2 |
| `tools/mcp/blender-mcp/33-Agricultura/capturas/espantapajaros_media_19-50-00_az*.png` | new | 6 capturas MEDIA |
| `tools/mcp/blender-mcp/33-Agricultura/capturas/_hoja_cap_33_espantapajaros_media.jpg` | regen | hoja MEDIA |
| `tools/mcp/blender-mcp/33-Agricultura/capturas/espantapajaros_baja_19-50-00_az*.png` | new | 6 capturas BAJA |
| `tools/mcp/blender-mcp/33-Agricultura/capturas/_hoja_cap_33_espantapajaros_baja.jpg` | regen | hoja BAJA |
| `game/isla-ancestral/assets/3d/alta/33-Agricultura_espantapajaros.glb` | reexport | 32 KB / 16 obj |
| `game/isla-ancestral/assets/3d/media/33-Agricultura_espantapajaros.glb` | reexport | 22 KB / 7 obj |
| `game/isla-ancestral/assets/3d/baja/33-Agricultura_espantapajaros.glb` | reexport | 15 KB / 6 obj |
| `DOCUMENTACION/09-GUIA-BLENDER.md` | edit | §3 nueva entrada E-73; §4 nuevo ítem de checklist |
| `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` | edit | línea M33 espantapájaros: descripción actualizada a v2 + E-73 + log 558 |
| `.workbuddy-ai/memory/2026-09-02.md` | append | bloque 19:50 — re-trabajo M33 |

---

## 6. Backlog (sin cambios)

33 pendientes (M25×7, M33×8, M34×3, M35×1 carrito de vías, M40×1 valla,
M45×5, M16, M70). M36 Fauna×9 sigue RESERVADO por otro agente.

---

## 7. Lecciones

1. **E-73:** pieza horizontal larga y delgada a la altura del torso = genital.
   Romper y angulizar. Aplicable a cualquier silueta humanoide vertical.
2. **Budget E-70 trampa:** agregar piezas que comparten material con piezas
   existentes no cuesta en MEDIA/BAJA (mismo grupo). Calcular antes de rechazar.
3. **E-66 reincidente:** `capturar_angulos_headless.py` toma **prefijo de
   objeto** (`SM_Espanta`) como `argv[1]`, no el prefijo del archivo de
   salida. Mezclar los dos argumentos da 0 objetos encuadrados.
