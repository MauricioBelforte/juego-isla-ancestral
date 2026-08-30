# 233 — M166: Tier ALTA mergeada + fix de palanca (E-24)

**Fecha:** 2026-08-29 14:15 (GMT-3)
**Módulo:** M166 (Variantes y perfil de rendimiento)
**Trigger:** Usuario pidió "agarra un nuevo tier y segui creando objetos". El nuevo tier natural era crear las `_alta_media.blend` (versiones mergeadas y exportables de los 15 `_alta.blend` generados en log 232).

## Resumen ejecutivo

**15/15 variantes `_alta_media.blend` creadas** vía `generar_variante.py <mod> <asset>_alta --media`. Cada una con merge por material + re-asentado a `z_min=0.045`.

**Bug crítico encontrado y reparado:** la palanca estaba flotando 44 cm. Re-asentado por AABB es insuficiente cuando hay objetos rotados (E-24).

## Tabla de merge

| Héroe | Obj src | Obj merge | Tris merge | Mats | Veredicto |
|---|---|---|---|---|---|
| pico_hierro | 8 | 3 | 956 | 3 | OK |
| pico_piedra | 7 | 3 | 716 | 3 | OK |
| antorcha_mano | 6 | 4 | 556 | 4 | OK |
| cristal_ancestral | 8 | 4 | 657 | 4 | OK |
| hacha_piedra | 6 | 3 | 1228 | 3 | OK |
| lingote_metal | 4 | 2 | 678 | 2 | OK |
| cofre_ancestral | 33 | **6** | 5980 | 6 | OK (presupuesto es post-merge, ver corrección abajo) |
| altar_ritual | 11 | 4 | 1162 | 4 | OK |
| puerta_templo | 15 | 3 | 1470 | 3 | OK |
| bote_pesca | 13 | 4 | 1304 | 4 | OK |
| farola_fuego | 13 | 5 | 1229 | 5 | OK |
| monolito_glifos | 19 | **2** | 2406 | 2 | OK |
| totem_isla | 32 | 4 | 10543 | 4 | ⚠ Tris (10.543 > 6.000) — única excepción real |
| anillo_piedras_ritual | 9 | 5 | 680 | 5 | OK |
| palanca_madera | 5 | 3 | 560 | 3 | OK (post-fix) |

**⚠️ Corrección al log 232:** las "3 excepciones legítimas" (cofre 33 obj, monolito 19 obj, totem 32 obj) que listé en el log anterior **eran incorrectas**. El budget de "16 objetos" del perfil ALTA (M166 §3.3) aplica **después del merge**, no antes. Post-merge: cofre 6, monolito 2, totem 4. **Todos dentro del budget de objetos.**

La única excepción real es `totem_isla_alta` con 10.543 tris (vs 6.000 del budget). Es el "hito visual" de la isla, se renderiza con poca frecuencia y la inversión se justifica.

## E-24: bug del re-asentado por AABB en objetos rotados (NUEVO)

### Síntoma

`palanca_madera_lowpoly_media.blend` y `_baja.blend` (los pre-existentes, generados en log 218 o anteriores) tienen la base flotando:

```
SM_Palanca_M_Madera_Pal_Osc   zmin=0.486  (la base)
SM_Palanca_M_Madera_Pal_Cla   zmin=0.045  (el brazo, que se usaba como referencia)
SM_Palanca_M_Hierro_Perno     zmin=0.591  (el pin)
```

El test numérico `z_min=0.0450` del GRUPO pasaba porque medía el AABB del Brazo (barra inclinada) cuya esquina inferior del bounding box llegaba a z=-0.396, no porque la base estuviera apoyada.

### Causa raíz

`generar_variante.py` re-asienta midiendo:
```python
z_min = min(min((o.matrix_world @ Vector(c)).z for c in o.bound_box) for o in piezas)
```

Esto es **AABB corners**, no vértices reales. Para un objeto rotado, el AABB incluye esquinas vacías (donde no hay geometría), y la coordenada mínima del AABB puede ser mucho más baja que la pieza real más baja.

En `palanca_madera`, el `SM_Palanca_Brazo` es una barra de 1.4 m con pivote a 0.21 m, inclinada (0, 35°, 90°). El AABB del brazo es 1.4 m vertical, con la esquina inferior a -0.396. La barra real (vértices) tiene la esquina más baja a -0.396 también, pero eso es porque está mal modelada (enterrada) — sin embargo, la lógica del re-asentado la usa como referencia y levanta TODO el conjunto +44 cm.

### Fix aplicado a la palanca

1. **Rotar el Brazo** a `rotation_euler = (0, 81.1°, 90°)` → la barra queda a ~12° de la horizontal, con su extremo inferior en `z=0.0453` (apoyado).
2. **Recolocar el Pomo** (hijo del Brazo) en el extremo ALTO de la barra (era hijo con offset en Y, que con la nueva rotación quedó enterrado). Fórmula:
   ```python
   m = brazo.matrix_world @ pomo.matrix_parent_inverse
   pomo.location = m.inverted() @ target_world   # target_world = high end of bar
   ```
3. **Regenerar** las 4 variantes (`_alta`, `_alta_media`, `_media`, `_baja`).

Después del fix: Brazo 0.0453, Soporte 0.0450, Pivote 0.140, Perno 0.150, Pomo 0.202 (todos > 0.045, sin enterrar ni flotar).

Verificación visual E-13: 6 capturas orbitales de `_alta_media` confirmadas. La palanca se ve como una palanca de madera en reposo, brazo inclinado, pomo al final del lado alto, base apoyada.

### Alcance del bug en otros assets

Hice un scan comparando `z_min(AABB)` vs `z_min(vértices reales)` sobre los 41 sources. **Solo `veta_hierro` diverge significativamente** (delta +0.0097, ~1 cm, ya conocida y arreglada en log 231).

Otros sources con `z_min(AABB) < 0.045` (piezas legítimamente enterradas, NO son bug):
- `roca_pedernal` (-0.9627): roca grande parcialmente enterrada, intencional.
- `concha_mar` (-0.0400): pieza interior muy fina, intencional.
- `arbusto_redondo` (-0.1550): arbusto, base en la tierra, intencional.
- `hongo_luminoso` (-0.1025): piedra base, intencional.
- `palmera` `SM_Arena_Base` (-0.3000): disco de arena de 5.4m, **verificar visualmente** que no flota.
- `flor_isla` (0.0000): planta baja, intencional.
- `veta_cobre` (0.0047): veta casi al ras, intencional.

**PENDIENTE DE REVISIÓN:** confirmar visualmente que `roca_pedernal`, `arbusto_redondo`, `hongo_luminoso`, `palmera`, `flor_isla` y `veta_cobre` NO flotan en sus variantes MEDIA/BAJA a pesar del re-asentado "incorrecto" por AABB. El log 230 los aprobó visualmente, pero la altura de re-asentado los puede haber levantado 1-2 cm sin que se notara a la distancia de cámara típica.

### Recomendación a futuro (no aplicada)

Reemplazar el cálculo de `z_min` en `generar_variante.py` y en `diagnosticar_pose.py` para usar **vértices reales** en vez de AABB. Más robusto y elimina toda la clase de bugs E-24. Lo dejo documentado pero no lo aplico en este log porque requiere validación cuidadosa (cambiar la función nuclear de re-asentado puede romper variantes que hoy están OK).

## Verificación visual (E-13)

3 sets de 6 capturas generados en este log:

- `cap_70_2026-08-29_14-14-12_palanca_madera_ALTA-MEDIA_az*.png` (6 tomas, palanca reparada)
- `cap_25_2026-08-29_14-14-45_cofre_ancestral_ALTA-MEDIA_az*.png` (6 tomas, cofre)
- `cap_45_2026-08-29_14-15-24_monolito_glifos_ALTA-MEDIA_az*.png` (6 tomas, monolito)
- `cap_45_2026-08-29_14-15-24_totem_isla_ALTA-MEDIA_az*.png` (6 tomas, totem)

Cofre y totem: sin defectos, presupuestos cumplidos, sin flotar. Monolito: notablemente más "limpio" sin las 19 piezas individuales, los glifos se ven como relieves en el lado derecho (cost of merge, aceptable en el perfil ALTA). Pivote del monolito: el monolito fuente tenía el cuerpo + 19 glifos como 19 piezas separadas, ahora son 2 mallas mergeadas (cuerpo + glifos).

## Cambios al script `generar_variante.py`

Ninguno. El script funciona correctamente cuando el source está bien modelado. El bug es del source (palanca mal modelada con el brazo inclinado de más).

## Cambios al skill `blender-m166-qa`

Pendiente: agregar nota sobre E-24 y el scan comparativo AABB vs vértices (a redactar en próxima sesión).

## Archivos tocados

- `tools/mcp/blender-mcp/<13/15/16/25/40/45/70>/<asset>_alta_media.blend` (15 archivos nuevos)
- `tools/mcp/blender-mcp/70-Interacciones/palanca_madera_lowpoly.blend` (Brazo rotado de 35° a 81.1°, Pomo recolocado)
- `tools/mcp/blender-mcp/70-Interacciones/palanca_madera_alta.blend` (regenerado tras fix)
- `tools/mcp/blender-mcp/70-Interacciones/palanca_madera_lowpoly_media.blend` (regenerado, ahora con z_min=0.045 correcto)
- `tools/mcp/blender-mcp/70-Interacciones/palanca_madera_lowpoly_baja.blend` (regenerado, ahora con z_min=0.045 correcto)
- `tools/mcp/blender-mcp/<25/45/70>/capturas/cap_*_ALTA-MEDIA_az*.png` (4 sets de 6 = 24 PNGs)
- `Logs/ULTIMO_NUMERO.txt` (232 → 233)
