# Log 565 — M19 Sombrero de paja (2026-09-02, WorkBuddy / Hy4)

## Resumen
Primer asset MONTADO de M19: **sombrero de paja de ala ancha**, montado
sobre la cabeza del NPC base. Aprobado por inspección visual en v1.
Pipeline completo: generador → 6 azimuts → hoja de contacto → MEDIA/BAJA →
GLB export → Godot import.

## Decisiones de modelado (5 detalles "premium")
1. **Ala tejida**: `loft(..., ondas=(0.018, 12), ondas_z=(0.006, 12))`.
   E-77: el formato del anillo del loft es `(z, cx, cy, rx, ry)` con Z primero.
   Nuevo helper: `plantilla_asset.loft(..., ondas, ondas_z)` para modular
   el radio y la altura por ángulo. Sirve para cestas, techos de paja,
   etc.
2. **Ala que cae**: el borde está 6.3 cm más abajo que la unión con la copa
   (4 anillos: 1.2 / 2.3 / 4.6 / 6.3 cm de caída).
3. **Dobladillo**: aro de 14 mm en el borde exterior (2 anillos). Mismas
   ondas que el ala → costura invisible (la modulación depende solo del
   ángulo).
4. **Cima hundida (pinch)**: 2 anillos formando un embudo. Sin esto la copa
   termina en punta y lee como gorro de fiesta.
5. **Inclinación +6° en X** (NO -6°): rotación POSITIVA levanta el ala
   frontal (+Y, donde están los ojos) y baja la nuca. Con -6° el ala TAPABA
   los ojos. + 4° en Z de yaw.

## Cotas
- Pivote = centro de la base de la copa, z_abs = 1.548 m
  (corresponde a la cabeza del NPC base, X_CABEZA=-0.023, Y_CABEZA=-0.006)
- Diámetro del ala: 61 cm (radio 0.305 m). Lo máximo permitido por E-79(d)
  (64 cm). No es sombrilla.
- 6 SM_ / 436 tris / 3 mats (paja, paja_osc, cinta) → 3 después del merge

## 5 nuevos errores documentados (E-75 … E-80)
- E-75 join aplica la inverse_matrix del activo: aplicar transformadas antes.
- E-76 Blender 4.x: `IDMaterials.pop(index, update_data=)` no existe.
  Usar `clear()`.
- E-77 `loft()` recibe anillos como `(z, cx, cy, rx, ry)`, Z primero. Guard
  en el propio helper.
- E-78 huella E-50 sobre anillos elípticos: vértice inferior en el CENTRO,
  no en el borde. Solución: caja plana (suela) bajo el pie.
- E-79 assets MONTADOS no usan `asentar()`/E-50: guard de encaje propio
  (no tapa cara, contiene pelo, no flota, no es sombrilla, no atraviesa
  orejas). Pivote = punto de montaje. Rotación a vértices (bmesh), no a
  `rotation_euler`. Materiales DS (glTF doubleSided) para superficies
  visibles desde abajo.
- E-80 `generar_variante.py` re-asienta con E-62 (umbral 25 cm) pero un
  sombrero a 13 cm cae dentro. Marcar el `.blend` con un Empty
  `_MONTADO` (sin SM_, sin geometría) hace que el script OMITA el
  re-asentado. Convención: cualquier asset montado lleva ese Empty.

## Pipeline ejecutado
1. `blender -b --factory-startup --python crear_sombrero_paja_lowpoly.py`
   → 6 SM_ / 436 tris / 5 guards E-79 pasan (holgura cara 2.4 cm, pelo en
   copa 25/0, 25 arriba + 13 abajo, diámetro 61 cm, orejas 6.6 cm)
2. `blender ... capturar_angulos_headless.py` → 6 capturas orbitales
3. `python contact_sheet.py` → hoja de contacto
4. Aprobación visual: silueta premium, ojos/cejas descubiertos, lazo en V
   visible en todos los azimuts
5. `python generar_variante.py 19-NPCs sombrero_paja_lowpoly.blend
   --media --baja` → RE-ASENTADO OMITIDO (E-80) en ambas: z_min -0.081
   preservado. MEDIA 3/436/3, BAJA 3/304/3
6. `EXPORT_DRY=1 EXPORT_MODULOS="19-NPCs" blender ... exportar_godot.py`
   → 3 exportados planeados, 0 errores
7. `EXPORT_FORZAR=1 EXPORT_MODULOS="19-NPCs" blender ... exportar_godot.py`
   → 3 OK: ALTA 28 KB / 6 objs, MEDIA 25 KB / 3, BAJA 19 KB / 3
8. `godot --headless --path game/isla-ancestral --import` → 3 `.glb.import`
   generados. Sin `.scn` aún (nadie referencia el sombrero todavía).

## Verificación E-65/E-72
- glb == .glb.import == 1 (alta/media/baja) ✓
- Sin .scn porque ningún .tscn referencia el sombrero todavía. Normal para
  un asset nuevo.

## Cambios
- `plantilla_asset.py`: `loft(..., ondas, ondas_z)` + assert z crecientes +
  centro de tapa = promedio de z. Constante docs.
- `generar_variante.py`: skip re-asentado si existe Empty `_MONTADO` (E-80).
- `exportar_godot.py`: comentario E-63 (antes mal etiquetado E-75).
- `crear_sombrero_paja_lowpoly.py`: nuevo. Premiun E-79, Empty `_MONTADO`.
- `09-GUIA-BLENDER.md`: E-75, E-76, E-77, E-78, E-79, E-80 añadidos al §3.
  Items del §4 actualizados.
- `CHECKLIST-OBJETOS-BLENDER.md`: marcar NPC base + Sombrero de paja [x]
  (siguiente entrada).
- `CHECKLIST-GLOBAL.md`: columna "Agente actual" fila 19 actualizada
  ("GLM-5.3 Flash (código) + WorkBuddy (assets 3D, lock 565)").
- `MEMORY.md`: E-79, E-80 añadidos al índice.

## Pendientes
- Marcar `Sombrero de paja` [x] en el checklist
- Liberar reserva 565 y avanzar `ULTIMO_NUMERO.txt` a 566
- Siguiente NPC premium: **Cabeza NPC (3 variantes de forma)** o
  **Vestimenta campesina** (decisión al empezar la próxima sesión)
- Resto del backlog: M19 6 items (NPC base ✅, sombrero ✅, faltan 5).
  Otros módulos: M33 9 · M25 6 · M16 4 · M34 3 · M15 3 · M40 1 · M35 1.
- Residual: commit+push selectivo (sin tocar los ~335 cambios ajenos),
  11 `~libvoxel...TMP` huérfanos, `cristal_ancestral` MEDIA 72 verts
  degenerados, `CHECKLIST-GLOBAL.md` mojibake.
