# Log 239 — Fix antorcha_pared v2 (bug reportado: placa flotando) (2026-08-29 18:25)

## Resumen ejecutivo

El usuario reportó en `revisa esa antorcha de pared, hay una placa cuadrada detras
separada flotando en el aire`. Diagnostiqué el defecto: en v1, el panel de pared
del set de captura (`Set_Pared`) estaba flotando a z=0.40 sobre la arena y la
placa estaba 0.42 unidades separada del muro (en y). La v1 pasó E-13 igual
porque el bug estaba en el set, no en el asset en sí.

**Acciones tomadas:**
1. Reescrito `25-Ruinas-Templos/scripts/crear_antorcha_pared_lowpoly.py` como v2:
   - `PARED_Z_CENTER = -0.05 + 1.40/2 = 0.65` → base del muro enterrada 5 cm.
   - `PLACA_Y_CENTER = (-0.45 + 0.025) + 0.010 = -0.415` → cara trasera de la
     placa tangente a la cara frontal del muro (y = -0.425).
   - `Y_BRAZO` y `cy` de los 4 remaches recomputados desde la nueva
     `PLACA_FRONT_Y = -0.405`.
   - `z_min` re-medido: 0.045 (sin delta).
2. Regeneradas las variantes MEDIA y BAJA desde la fuente v2 (eran v1 obsoleto).
3. E-13 aprobado: 6 capturas orbitales para MEDIA (4 obj/94 tris/4 mats) y 6
   para BAJA (4 obj/80 tris/4 mats), todas verificadas visualmente.
4. Documentado **E-28** (lección) en `09-GUIA-BLENDER.md` y referenciado desde
   §7.4 #14.
5. Actualizada la checklist (entradas M25 y Tier D) con las stats v2 y la nota
   de corrección.

## §1 El bug v1 (lo que reportó el usuario)

**Captura del problema** (v1, ya no existe en disco — fue sobrescrita por v2):

```
ANTORCHA PARED v1 asentada: z_min 0.045 -> 0.045
OBJETOS_ENCUADRADOS: 7 (prefijo 'SM_')
Set_Pared:    center=(0, -0.45, 1.10)  size=(2.0, 0.05, 1.40)
  → base = 1.10 - 1.40/2 = 0.40 (FLOTANDO 40 cm del suelo)
  → cara frontal y = -0.45 + 0.05/2 = -0.425
SM_Placa:     center=(0, -0.020, 0.205)  size=(0.16, 0.020, 0.32)
  → cara trasera y = -0.020 - 0.020/2 = -0.030
  → separación real al muro = -0.030 - (-0.425) = +0.395 m
    (NO era tangente — había 0.4 m de aire)
```

**Por qué pasó:** copié la receta de set de captura de assets sobre el suelo
(placa centrada en su altura nominal) y la apliqué a un set de pared sin
revisar que el panel `Set_Pared` estuviera apoyado. El asset (placa + brazo +
antorcha) sí estaba apoyado en la arena con `Z_APOYO = 0.045`, pero el panel
de referencia quedó flotando, y eso es exactamente lo que el usuario vio.

**Lecciones de proceso:**
- Aunque un asset esté numéricamente apoyado (`z_min = 0.045`), los elementos
  del set de captura deben pasar el mismo `auditar_apoyos.py`.
- El set de captura es **parte del asset a la hora de QA visual**, aunque no
  se exporte. Si el set está mal, el reporte del operador puede ser falso
  positivo o confundir dónde está el bug.

## §2 Fix v2 (lo aplicado)

**Archivo:** `25-Ruinas-Templos/scripts/crear_antorcha_pared_lowpoly.py`

**Receta del set de captura de pared (nueva, replicable):**

```python
PARED_W = 2.0; PARED_ESP = 0.05; PARED_ALTO = 1.40
PARED_Y_CENTER = -0.45               # cara frontal queda en y = -0.425
PARED_Z_CENTER = -0.05 + PARED_ALTO / 2  # 0.65 → base en z = -0.05 (enterrada)
bpy.ops.mesh.primitive_cube_add(size=1.0,
                                location=(0.0, PARED_Y_CENTER, PARED_Z_CENTER))
pared.scale = (PARED_W, PARED_ESP, PARED_ALTO)

PLACA_ANCHO = 0.16; PLACA_ALTO = 0.32; PLACA_ESP = 0.020
PLACA_Y_CENTER = (PARED_Y_CENTER + PARED_ESP/2) + PLACA_ESP/2  # -0.415
bpy.ops.mesh.primitive_cube_add(size=1.0,
                                location=(0.0, PLACA_Y_CENTER, 0.045 + PLACA_ALTO/2))
placa.scale = (PLACA_ANCHO, PLACA_ESP, PLACA_ALTO)
PLACA_FRONT_Y = PLACA_Y_CENTER + PLACA_ESP/2  # -0.405
```

**Receta de Y para piezas montadas (en este caso el brazo y los remaches):**
- `Y_BRAZO = PLACA_FRONT_Y + BRAZO_R` (cilindro tangente a la cara frontal
  de la placa).
- `cy = PLACA_FRONT_Y + 0.002` para los remaches (un pelín delante de la
  cara frontal para que se vean, no que queden hundidos en la placa).

**Comprobación numérica v2:**
```
ANTORCHA PARED v2 asentada: z_min 0.045 -> 0.045 (delta -0.000)
SM_: 7
Set_Pared: center=(0, -0.45, 0.65)  → base z=0.65-0.70=-0.05 (enterrada 5 cm)
Placa:     center=(0, -0.415, 0.205) → cara trasera y=-0.425 = cara frontal muro
```
Diferencia entre cara frontal del muro y cara trasera de la placa:
`|-0.425 - (-0.425)| = 0` (tangente, sin aire).

## §3 Regeneración de variantes (eran v1 obsoleto)

Las variantes `_media.blend` y `_baja.blend` existían pero con la geometría v1
(4 obj/94 tris y 4 obj/81 tris respectivamente, con el bug del set replicado
aunque el set no se funde — la geometría de la placa y el brazo seguía siendo
la de v1). Las regeneré desde la fuente v2:

```
$ python generar_variante.py 25-Ruinas-Templos antorcha_pared_lowpoly --media
MERGE: 7 objetos -> 4 mallas
RE-ASENTADO: z_min 0.045 -> 0.045 (delta -0.000)
VARIANTE MEDIA OK -> antorcha_pared_lowpoly_media.blend
  objetos=4  tris=94  materiales=4

$ python generar_variante.py 25-Ruinas-Templos antorcha_pared_lowpoly --baja
PODA BAJA: 0 piezas eliminadas -> ninguna
MERGE: 7 objetos -> 4 mallas
DECIMATE BAJA: ratio 0.70 aplicado a 4 mallas fundidas (criticas intactas)
RE-ASENTADO: z_min 0.045 -> 0.045 (delta -0.000)
VARIANTE BAJA OK -> antorcha_pared_lowpoly_baja.blend
  objetos=4  tris=80  materiales=4
```

**Comparativa v1 vs v2 (post-merge):**
| Variante | v1 tris | v2 tris | Δ      | mats | z_min | Estado |
|----------|---------|---------|--------|------|-------|--------|
| fuente   | 96      | 96      | 0      | 7    | 0.045 | OK     |
| MEDIA    | 94      | 94      | 0      | 4    | 0.045 | OK     |
| BAJA     | 81      | 80      | -1     | 4    | 0.045 | OK     |

(La BAJA perdió 1 triángulo por el decimate sobre la nueva geometría; dentro
del presupuesto BAJA = 700 tris.)

## §4 E-13 — capturas orbitales

**Timestamp:** 2026-08-29 18:14:21 (fuente) y 18:18:02 (variantes).
**Cantidad:** 6 azimutales por variante = 18 capturas totales.
**Receta:** `python capturar_angulos.py SM_ "../25-Ruinas-Templos/capturas/<asset>_<ts>.png" 6 --blend "<ruta>"`
**Verificación:** cada captura revisada con Read; confirmada:
- Muro `Set_Pared` apoyado en la arena en los 6 azimut.
- Placa tangente al muro (sin gap) en az060 (frontal) y az120 (3/4 frontal).
- Placa con sus 4 remaches visibles en az060, az120.
- Torch sobresaliendo del lado +Y del muro (correcto).
- Sin flotación en az000, az180, az240, az300 (vistas donde la antorcha no
  está visible y solo se ve el muro: en todas, el muro se ve apoyado).

**E-13 cumplido para fuente, MEDIA y BAJA.**

## §5 Lección E-28 (nueva, documentada en 09-GUIA-BLENDER.md)

**Resumen:** cualquier `Set_Pared` / `Set_Techo` / `Set_Suelo_Colgante` del
set de captura debe pasar `auditar_apoyos.py` con `z_min ≤ 0.05` antes de
usarse en captura. Si el set flota, el reporte del operador puede confundir
"set flotando" con "asset mal apoyado".

**Receta replicable para futuros sets de pared:**
1. `Y_CENTER_PARED = offset_negativo` (más cerca del origen).
2. `Z_CENTER_PARED = -0.05 + ALTO/2` (base enterrada 5 cm).
3. `Y_CENTER_PLACA = (Y_CENTER_PARED + ESP_PARED/2) + ESP_PLACA/2`.
4. Para piezas montadas en la cara frontal: `Y = PLACA_FRONT_Y + pieza_R` o
   `Y = PLACA_FRONT_Y + offset_pequeño` (según si son pasantes o no).
5. Auditar el set con `auditar_apoyos.py` antes de capturar.

**Aplicabilidad:** esta lección se aplica a TODO asset que se monte sobre
una superficie vertical. Próximos casos esperados: cartel_indicador (si se
cuelga de un techo en vez de clavarse en suelo), dintel de puerta, gárgola,
insignia de clan. El cartel actual M40 está clavado en suelo, no le aplica,
pero si en el futuro se hace una versión "de pared" se reescribe siguiendo
esta receta.

## §6 Cambios al sistema

| Archivo | Cambio | Por qué |
|---------|--------|---------|
| `25-Ruinas-Templos/scripts/crear_antorcha_pared_lowpoly.py` | reescrito v2 con set de captura asentado y placa tangente | fix bug reportado |
| `25-Ruinas-Templos/antorcha_pared_lowpoly.blend` | regenerado desde v2 (timestamp 18:14) | fuente con bug corregido |
| `25-Ruinas-Templos/antorcha_pared_lowpoly_media.blend` | regenerado desde v2 (timestamp 18:18) | variantes sincronizadas |
| `25-Ruinas-Templos/antorcha_pared_lowpoly_baja.blend` | regenerado desde v2 (timestamp 18:18) | variantes sincronizadas |
| `25-Ruinas-Templos/capturas/antorcha_pared_src_18-14-21_az*.png` | 6 capturas nuevas | E-13 fuente v2 |
| `25-Ruinas-Templos/capturas/antorcha_pared_media_18-18-02_az*.png` | 6 capturas nuevas | E-13 MEDIA v2 |
| `25-Ruinas-Templos/capturas/antorcha_pared_baja_18-18-02_az*.png` | 6 capturas nuevas | E-13 BAJA v2 |
| `25-Ruinas-Templos/antorcha_pared_lowpoly.blend1` | backup v1 conservado (no se borra) | §24 capturas nunca se sobreescriben |
| `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` | actualizadas entradas M25 y Tier D con stats v2 y nota de corrección | trazabilidad |
| `docs/09-GUIA-BLENDER.md` | agregadas E-24, E-25, E-26, E-27, E-28 en §3 y referencia a E-28 en §7.4 #14 | lecciones registradas |
| `Logs/ULTIMO_NUMERO.txt` | 238 → 239 | siguiente log |

## §7 Pendientes inmediatos

- `antorcha_pared` v2 ya está cerrada. La checklist queda en **43/117** (sin
  sumar este fix porque no es un asset nuevo).
- Siguiente paso de la cadena Tier D (M45 conchas, M25 puentes, M40 pozo, M40
  puentes) — pendiente directiva del usuario.
- Carry-over del log 238: `hacha_piedra` offset lateral (defecto de modelado),
  `nido_cocos_baja` 970 tris y `helecho_gigante_baja` 936 tris exceden 700,
  `piedra_afilar` 15 tris sospechoso, 5 sources con AABB < 0.045 a verificar
  visualmente, `diagnosticar_pose.py` clasificación TUMBADO poco fiable.

## §8 Contadores

- Asset creado en este turn: 0 (es un fix).
- Asset re-aprobado: 1 (`antorcha_pared` v2).
- Variantes regeneradas: 2 (MEDIA + BAJA).
- Capturas nuevas: 18 (6×3).
- Lecciones nuevas: 1 (E-28). E-24, E-25, E-26, E-27 también se documentaron
  en este turn para dejar la guía completa.
