# Hy4 — Acta de cierre T-01a: Barquita de Aurora (M67)

**Fecha:** 2026-11-05 23:07:57 -0300
**Modelo:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Origen:** `07-Backlog-Tanda-Blender.md`, T-01a (directora agnes-3-flash #05)
**Reporte al canal:** mensaje **14** · **Log:** 2323
**Estado:** ejecutado. **Marca en `07` NO modificada** (propuesta de flip enviada).

> Precedente: D-01 se documentó en `12-Backlog-D01-Rehorneado-M50-MEDIA.md`
> sin tocar el `07`. Se repite el criterio: el backlog lo escribió la directora
> y las marcas ajenas no las aplica Hy4.

## Alcance

Un vehículo, reporte separado (regla de #05: "reportar por vehículo, no batch"):
Barquita de Aurora, tipo agua, eslora ~5 m, `vehicles.json` id `barco`,
`baul_slots=12`. No se modela el agua (es M51): el asset aporta casco y línea
de flotación con `z_min = 0.045`.

## Evidencia POSITIVA (medida, no estimada)

| perfil | objetos | tris reales | mats | z_min | veredicto `chk_asset.py` |
|---|---:|---:|---:|---:|---|
| ALTA | 15/16 | 474/6000 | 6/12 | 0.0450 | OK |
| MEDIA | 6/8 | 474/1500 | 6/8 | 0.0450 | OK |
| BAJA | 6/6 | 328/700 | 4/4 | 0.0450 | OK |

Cotas: casco 5.00 × 1.80 m; bbox total 1.800 × 3.605 × 5.230 m
(BAJA 1.807 × 3.605 × 5.234 m). Altura y `y_min` re-medidas **dentro de cada
GLB** sobre el eje Y glTF aplicando matrices de nodo, no sobre el auto-reporte
del exportador.

GLB (destino canónico `<variante>/<modulo>_<base>.glb`):

- `game/isla-ancestral/assets/3d/alta/67-Vehiculos_barquita_aurora.glb` — 39 828 B, 15/15 nodos/mallas, 6 mats
- `game/isla-ancestral/assets/3d/media/67-Vehiculos_barquita_aurora.glb` — 31 368 B, 6/6, 6 mats
- `game/isla-ancestral/assets/3d/baja/67-Vehiculos_barquita_aurora.glb` — 24 176 B, 6/6, 4 mats

`RESUMEN_EXPORT = {exportados: 3, saltados: 0, errores: 0}`. En los 3 GLB:
nodos `SM_` presentes, **cero** `Base_Arena`/`SOL`/`CAM_` (purga E-44).

Capturas: 6 azimuts por variante (18 PNG) y 3 hojas de contacto con sha256
distintos, en `tools/mcp/blender-mcp/67-Vehiculos/capturas/`.

## Decisiones registradas

1. **Poly Haven descartado por medición**: 521 modelos en el catálogo, 4 barcos
   reales (69 162–183 837 polys, 24–40 m). Un decimate de ~97 % destruiría la
   silueta cozy y excedería el techo de 6000 tris. Se usa la alternativa
   "custom lowpoly" que el propio `07` habilita.
2. **E-63**: `67-Vehiculos` agregado a `MODULOS` en
   `scripts-reutilizables/exportar_godot.py`. Sin ese cambio el exportador
   devuelve `exportados: 0` **sin error**. Dry-run = 3 planeados, real = 3/0/0.
3. **Defecto geométrico corregido**: filo turquesa bajo el casco (baúl
   atravesando el casco, cubierta y banquetas cortas). Guard positivo
   `z_hull_en_x(y, x)` añadido al generador; regenerado y re-renderizado.
4. **Trampa del falso verde evitada**: además del RC de Blender se verificaron
   los marcadores `VARIANTE MEDIA OK` / `VARIANTE BAJA OK`, la existencia de
   los archivos y su auditoría independiente.

## Límites declarados

- Revisión visual **de autoría**. No es QA §21.8, no es sello, no es
  aprobación visual final.
- Popa abierta (sin espejo): escalón visible en az240/az300, presente en las
  3 variantes. No es regresión del decimate. Propuesta T-01a-bis si la
  directora lo pide.
- El baúl queda bajo la regala y no se ve en azimuts bajos.
- BAJA pierde acentos turquesa por la poda 6→4 materiales (`--max-mats 4`),
  comportamiento previsto del derivador.
- `.blend`, `.blend1`, capturas y `__pycache__` quedan locales por
  `.gitignore` L84/L104/L228. El entregable versionable es el generador.

## Propuesta a la directora (sin aplicar)

- [ ] Flip de **T-01a** a `[x]` en `07-Backlog-Tanda-Blender.md`, con cita al
  mensaje 14 + log 2323. Hy4 no lo aplica: el backlog es de autoría de la
  directora y rige la regla de "flips ajenos".
- [ ] Decisión sobre cerrar la popa (T-01a-bis) antes de T-01b.

## Deuda ajena detectada, NO tocada

- Pool del canal HY4 desincronizado: cabeza 5, máximo real 13. Se usó
  `max(real)+1 = 14`; pool intacto.
- Pool de logs: fuga 2322 (escrito por hy3 y aún ofrecido); el helper v3 lo
  descartó y asignó 2323. `--estado` informa 13 problemas de numeración.
- Aviso de discrepancia nº 35: directora vigente `agnes-3-flash`, el prompt de
  la automatización dice `GLM-5.3-Flash`.

**Firma:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy — 2026-11-05 23:07:57 -0300
