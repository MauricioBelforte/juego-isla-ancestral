# Log 207 — Cofre ancestral v2: más detalles y materiales brillantes (directiva "muy simple / opaco")

**Módulo:** M25 (Ruinas/Templos)
**Fecha:** 2026-08-28 20:30
**Hora:** 20:30
**Agente:** MiniMax-M3 · WorkBuddy AI
**Disparador:** "me gustaria que le agregues mas detalles al cofre lo veo muy simple, como hiciste una vez con los cocos que lo fuiste mejorando. algo mas brillante no se lo veo opaco"

## Resumen

Reconstrucción del cofre ancestral en 3 iteraciones. Pasamos de **25 objetos / materiales opacos** a **33 piezas / 7 materiales con coat + emisión**, sumando 6 tipos de detalles nuevos (remaches, costillas, glifos, gema, bisagras, asas). z_min 0.045 verificado en todos los orbitales.

## Iteración 1 — v2.0 (20:22, 32 piezas, COSTILLAS MAL)

- Materiales nuevos: `MAT_bronce`, `MAT_gema` (con coat + emission), `MAT_oro` con emis 0.30, `MAT_hierro` con coat 0.70, maderas barnizadas (rough 0.42 + coat 0.90).
- 6 detalles nuevos: 22 remaches en una sola malla, 2 costillas curvas (rotación Euler sobre X por ang-pi/2), 3 glifos en arco, gema emisiva, marco de cerradura, 2 bisagras, 2 asas laterales.
- **Problema detectado por visión:** las costillas se renderean como "alas rectas" sobre la tapa, no como anillos que la ciñen. La rotación que mandaba el eje local Z a la normal era correcta, pero el resultado visual no era el esperado. Glifos tampoco se leían contra el cilindro.

## Iteración 2 — v2.1 (20:24, 33 piezas, COSTILLAS OK)

- Costillas rehechas como **3 toroides anulares perpendiculares a X** (con eje sobre Y) a posiciones x = -0.21, 0, +0.21, radio mayor = R_TAPA = 0.20, minor 0.008. CADA ANILLO CIÑE LA TAPA como un cinturón de bronce.
- Glifos rehechos como **3 placas planas en la cara frontal de la tapa** (y = R_TAPA, z variable) — siempre visibles desde el frente, no en la curva.
- E-18 mantenido en `agregar()`: `padre.matrix_world.inverted()` (no `Matrix()`).
- Materiales: misma base pero oro emis 0.30 aún no impactaba visualmente (sin SSR).

## Iteración 3 — v2.2 (20:26/20:28, 33 piezas, BRILLANTE OK)

**Cambios que SÍ funcionaron para el look "brillante":**

1. **Activar Eevee Next SSR + raytracing** (`use_ssr=True`, `use_ssr_refraction=True`, `use_raytracing=True`). El motor estaba en `BLENDER_EEVEE_NEXT` pero sin SSR — por eso los materiales con metallic/coat se rendereaban planos. Con SSR activo, los highlights de los metales son nítidos.
2. **Subir emisión de los metales:** oro emis 0.30 → **0.80**; bronce emis 0.18 → **0.45**; gema emis 2.20 → **4.50**; madera con emis sutil 0.08 (para que no se hunda a negro en sombra).
3. **Subir base color** de madera (0.44,0.27,0.14) → (0.55,0.34,0.18) y hierro (0.42,0.42,0.46) → (0.55,0.55,0.58): más luminosos de base.
4. **Bajar roughness:** oro 0.12 → 0.10; bronce 0.18 → 0.14; madera 0.42 → 0.32; coat_rough 0.06 → 0.04.

**Resultado:** el cofre pasó de "pintado mate" a "con barniz y metal pulido" sin tocar el set de luces ni la cámara (regla §7.3 regla 3 de `09-GUIA-BLENDER.md`).

## Diagnóstico clave: Eevee sin SSR = materiales planos

```
Motor: BLENDER_EEVEE_NEXT
SSR: False  ← por eso metallic/coat se veían sin highlights
```

Activación dentro del script de captura (no en el script del asset para no contaminar el set de cámara por defecto):
```python
bpy.context.scene.eevee.use_ssr = True
bpy.context.scene.eevee.use_ssr_refraction = True
bpy.context.scene.eevee.use_raytracing = True
```

## Archivos generados

- `25-Ruinas-Templos/scripts/crear_cofre_ancestral_lowpoly.py` (v2, 33 piezas)
- `25-Ruinas-Templos/cofre_ancestral_lowpoly.blend`
- 6 capturas orbitales + contact sheet: `25-Ruinas-Templos/capturas/cap_25_cofre_v22b_20-28-00_az*.png` + `_hoja_cap_25_cofre_v22b.jpg`
- (obsoletas, conservadas por §6.2bis: `_v2_20-22-00_*`, `_v21_20-24-00_*` y la tanda original `cofre-orbita`)

## Incidencia menor

Error `Unable to make version backup / file saved with @` al guardar el .blend: Blender crea `cofre_ancestral_lowpoly.blend@` como backup; si ya existe, no puede sobrescribirlo. **Fix:** `os.remove(ruta + '@')` antes de `wm.save_as_mainfile`. Inocuo pero reproducible — anotado para futuros scripts.

## Pendiente para futuras iteraciones

- Los glifos se ven mejor con la cámara lateral (az240/300) que con la frontal (az000) — son 3 placas chiquitas en el frente de la tapa, no son tan destacados como deberían. Próxima iteración: hacerlos más grandes o con forma de cruz/rombo.
- Las asas laterales son muy pequeñas en relación al cuerpo. Próxima: major_radius 0.055 en vez de 0.045.
- Considerar Cycles en vez de Eevee Next para próximas capturas de assets con muchos metales — el specular es más limpio aunque el render es más lento.

## Contadores

- CHECKLIST-OBJETOS-BLENDER.md: el cofre ya estaba marcado [x] en la iteración anterior. Esta iteración mejora la calidad del mismo ítem, no agrega ítems nuevos al contador (sigue 40/117).
