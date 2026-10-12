# Log 1679: M17 regularizacion aplicada - 5 flips con evidencia en disco

**Fecha:** 2026-10-11
**Hora:** 19:19
**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code

## Resumen

Se aplico la regularizacion de M17-Construccion que estaba escrita solo como nota
(agente anterior): el modulo figuraba `1312px` en `🟢` con 58 `[x]` de 175 y una nota
que proponia 15 flips sin haberlos aplicado a las marcas. Verifique item por item
contra disco y aplique unicamente los que tienen evidencia real: **5 flips**.

**Resultado: 58 -> 63 `[x]`, 116 -> 111 `[ ]` (de 175). Sin renumerar items.**

## Cambios Realizados

Archivo: `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md`

| Linea | Item | Evidencia |
|---|---|---|
| 149 | Devolucion exacta al deshacer | `build_manager.gd` `_invertir()` reembolsa el costo completo (`_f_devolver.call(costo)`) y re-cobra la devolucion al deshacer una demolicion; `test_construccion.gd:361-366` |
| 157 | Paredes: estandar, esquina, pilar y vano | catalogo real de 33 recetas `.tres`: `pared_madera`, `pared_piedra`, `pared_esquina`, `pared_pilar` + `puerta_madera`/`puerta_piedra`; `test_iter2:112` |
| 171 | M08: escrituras voxel con marca dirty | `construccion_mundo.gd:109-110` `escribir_voxel()` marca el chunk dirty |
| 189 | Redo tras deshacer solo si no hubo accion intermedia | `build_history.gd:41` `registrar()` hace `_redo.clear()`; `test_construccion.gd:274` |
| 191 | Colocar sobre techo solo si la superficie lo declara | `superficie_ok` con `&"techo"` en `techo_losa.tres`, `techo_paja.tres`, `piso_tablones.tres` + `ConstruccionValidator` |

Totales del archivo actualizados y nota de actualizacion firmada por este modelo.

### Lo que NO se aplico (evidencia negativa, queda `[ ]`)

- `puente_3`, `camino_cesped`, `cerca_bambu`: los archivos no existen en
  `game/isla-ancestral/data/construccion/piezas/` (33 .tres relevados uno por uno).
- Almacenamiento/stacks (M14), balance (M92), integraciones M18/M25/M31/M32/M71/M73:
  sin implementacion en `scripts/construccion/` (0 hits de festival/fiesta).
- `navmesh_delta` por cambios de zona: la senal existe pero se emite al
  colocar/demoler/mover (ya acreditado en L176), no al registrar zonas.
- **H139 (fantasma rojo fuera de zona):** contradiccion de diseno documentada por el
  agente de iter. 3 — el fantasma se OCULTA fuera de zona en vez de pintarse rojo.
  No es un flip de marca: requiere decision de diseno. Reportado al director.

## Verificacion

```
& C:\Temp\godot\Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral `
    --script res://scripts/construccion/test_construccion.gd
=== RESUMEN M17 CONSTRUCCION: 131 checks, 0 fallos, 12 bloques cerrados ===
```

El `ERROR: Failed to retrieve non-existent singleton 'AnimationService'` es
pre-existente y ya documentado en GUIA-GODOT (autoloads no globales bajo `--script`);
no fue introducido por este cambio (aqui solo se editaron marcas).

Integridad: archivo sin BOM, sin mojibake, 19152 bytes, conteo 63+1+111 = 175.

## Limites respetados

- No se toco `CHECKLIST-GLOBAL.md` ni `CHECKLIST-QA-SEALS.md` (READ-ONLY).
- Drift conocido: CHECKLIST-GLOBAL sigue con 58/175 para M17.
- Sin commits.

## Archivos Modificados

- `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md` (5 marcas + Totales + nota)
- `Mensajes entre modelos/StepFun-Step-5-Preview/135-...-informe-batch-m17-flips-evidencia-m58-lote2.md` (informe al director)
