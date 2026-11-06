# Hy4 — Acta de cierre T-01c: Perla Ancestral (M67, submarino)

**Fecha:** 2026-11-06 00:59:41 -0300
**Modelo:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Origen:** `07-Backlog-Tanda-Blender.md`, T-01c (directora agnes-3-flash #05 / #17)
**Reporte al canal:** mensaje **20** (acuse de #19) · **Log:** 2327
**Estado:** ejecutado. **Marca en `07` NO modificada** (propuesta de flip enviada).

> Precedente: D-01 (`12-…`), T-01a (`13-…`) y T-01b (`14-…`) se documentaron
> en actas propias sin tocar el `07`. Se repite el criterio: el backlog lo
> escribió la directora y las marcas ajenas no las aplica Hy4.

## Alcance

Un vehículo, reporte separado (regla de #05: "reportar por vehículo, no
batch"): Perla Ancestral, `id=submarino`, tipo **subagua**, ~8 m,
`vehicles.json` (`velocidad_max=8`, `profundidad_max=-40`, `baul_slots=10`,
`tiene_reversa=true`). El agua y la profundidad los aplica el runtime de M67.
El asset se modela **posado / en dique seco**: dos patines dan el
`z_min = 0.045` que exige el `07`. Casco de 8.000 m de eslora (eje Y),
radio máximo 1.05, centro `z=1.42`.

## Evidencia POSITIVA (medida, no estimada)

| perfil | objetos | tris reales | mats | z_min | veredicto `chk_asset.py` |
|---|---:|---:|---:|---:|---|
| ALTA | 15/16 | 534/6000 | 4/12 | 0.0450 | OK (perfil propio) |
| MEDIA | 4/8 | 534/1500 | 4/8 | 0.0450 | OK |
| BAJA | 4/6 | 371/700 | 4/4 | 0.0450 | OK |

Cotas idénticas en los 3 `.blend` y en los 3 GLB: bbox
`X [-1.403..1.403]` = 2.806 m, `Y [-4.380..4.320]` = 8.700 m,
`Z [0.045..3.555]` = 3.510 m.

GLB (destino canónico `<variante>/<modulo>_<base>.glb`):

- `game/isla-ancestral/assets/3d/alta/67-Vehiculos_perla_ancestral.glb` — 44 192 B, 15 nodos/mallas, 4 mats
- `game/isla-ancestral/assets/3d/media/67-Vehiculos_perla_ancestral.glb` — 32 300 B, 4/4, 4 mats
- `game/isla-ancestral/assets/3d/baja/67-Vehiculos_perla_ancestral.glb` — 25 296 B, 4/4, 4 mats

Medición sobre **vértices reales decodificados del BIN** (magic `glTF` v2,
chunks JSON+BIN, matrices de nodo por jerarquía, `byteStride` real):
ALTA 1039 vértices / 4 nodos rotados, MEDIA 1039, BAJA 785; en los tres
`y_min = 0.0450`, `y_max = 3.5550`, alto 3.5100, `x = 2.806`, `z = 8.700`,
**0** nodos `Base_Arena`/`SOL`/`CAM_`, todos los nodos `SM_`.
Los 6 GLB de T-01a/T-01b quedaron byte-idénticos a HEAD tras el export.

Capturas: 6 azimuts por variante (18 PNG) y 3 hojas de contacto con sha256
distintos (`de23004d…`, `192ac28a…`, `fd595e86…`) en
`tools/mcp/blender-mcp/67-Vehiculos/capturas/` (21 archivos "perla").
Comparación ALTA/MEDIA/BAJA: portillos crema, torreta, aletas y franjas
conservan identidad → la poda de materiales no blanqueó piezas.

## Decisiones registradas

1. **Poly Haven descartado por medición**: 521 modelos, **0** submarinos.
   Los 4 hits de `underwater` son falsos positivos (`bronze_ray_statue`,
   `bronze_shark_statue`, `bronze_whale_statue`, `lambis_shell`). Los 4
   barcos miden 69 162–183 837 polis y 24–40 m: fuera de escala.
2. **4 materiales, no 6** (decisión clave): con 6, `--max-mats 4` de BAJA
   remapeaba por número de caras y dejaba portillos/perla/caja de carga
   **blancos**. Con exactamente 4 la poda es un **no-op**, el merge produce
   4 grupos y BAJA nace con 4 objetos (techo 6). `assert len(MATS) == 4`.
   No se modificó `generar_variante.py` (script compartido).
3. **Normales explícitas hacia afuera** en el casco (winding `(a,d,c,b)`)
   con guard de producto punto radial; sin `recalc_face_normals` sobre
   tiras abiertas.
4. **Guardias de unión positivas**: `z_casco_inf(y,x)` y `z_casco_sup(y)`
   prueban que montantes arrancan en la superficie inferior real y que
   torreta/portillos se apoyan en la superior real; reemplazan guardias
   tautológicas por medición de `matrix_world`.
5. **Trampa del AABB rotado re-aplicada**: el ALTA tiene 4 nodos rotados;
   transformar las 8 esquinas del accessor `POSITION` infla el bbox y da un
   `y_min` falso. Decodificar los 1039 vértices reales da el mismo
   `0.0450 / 3.510` que el `.blend`.
6. **Falso verde de Blender evitado**: `RC=0` no prueba nada; se exigen
   marcadores de stdout + existencia del `.blend` + `py_compile` previo.
7. **E-63 ya resuelto en T-01a**: `67-Vehiculos` estaba en `MODULOS` de
   `exportar_godot.py`. Dry-run = 3 planeados, real = 3/0/0. Ningún script
   compartido modificado en esta vuelta.
8. **Deuda documental ajena**: el `07` cita `template_asset.py`, pero el
   helper real es `plantilla_asset.py` (E-67: `ALTURA_ARENA = 0.05`
   intacto). No se corrige.

## Formatos (medidos después de escribir)

Medición tomada con los cuatro archivos ya escritos, **antes de insertar este
bloque** (el acta crece al insertarlo; el tamaño final se re-mide al cierre y
se consigna en la memoria de la vuelta):

| archivo | bytes | BOM | CRLF | LF total | LF sin CR | U+FFFD | bytes > 127 |
|---|---:|---|---:|---:|---:|---:|---:|
| mensaje 20 | 7053 | no | 0 | 132 | 132 | 0 | 146 (UTF-8 válido) |
| acta 15 (pre-bloque) | 6107 | no | 0 | 120 | 120 | 0 | 121 |
| log 2327 | 7387 | no | 158 | 158 | **0** | 0 | **0** (ASCII puro) |
| generador | 19 469 | no | 0 | 462 | 462 | 0 | 0 |

- Mensaje, acta y generador son **UTF-8 sin BOM + LF**: que todos sus LF
  aparezcan "sin CR" es lo esperado. El log es **ASCII puro + CRLF**: 0 LF
  sueltos, 0 bytes > 127. Ninguno tiene BOM ni `U+FFFD`.
- `python -m py_compile` del generador: RC=0. Gate §28 `verificar_bom.py`:
  RC=0.
- **Mismo tamaño ≠ mismo contenido**: el acta 14 (T-01b) y el acta 15
  miden 6107 B cada una, pero su sha256 es distinto
  (`2beaa5cc…` vs `9a110b54…`) y sus cabeceras difieren. Se verificó por
  medición positiva, no por el tamaño.

## Límites declarados

- Revisión visual **de autoría**. No es QA §21.8, no es sello, no es
  aprobación visual final. Sin push, sin `--amend`, sin `add -A`.
- MEDIA es visualmente idéntica al ALTA (merge sin pérdida); BAJA conserva
  la silueta con 371 tris y la misma bbox.
- `.blend`, `.blend1`, capturas y `__pycache__` quedan locales por
  `.gitignore` L84/L104/L228. El entregable versionable es el generador +
  los 3 GLB.
- Gate §28: RC=0 con **6** avisos de U+FEFF embebido, ajenos y no
  bloqueantes (el nuevo respecto de #18 es `Temp/kilo/ritual_log2326.py`).

## Propuestas a la directora (sin aplicar)

- [ ] Flip de **T-01c** a `[x]` en `07-Backlog-Tanda-Blender.md`, con cita al
  mensaje 20 + log 2327.
- [ ] Confirmar **T-01d Gran Vapor** (locomotora M68, ~15 m, riel) como
  siguiente; es el último `[ ]` de T-01.
- [ ] **T-01a-bis** (popa abierta de la Barquita, acta 13): sin respuesta en
  #17 ni #19, deuda abierta no ejecutada.

## Deuda ajena detectada, NO tocada

- Pool del canal HY4 desincronizado: cabeza 5, máximo real 19. Se usó
  `max(real)+1 = 20`; pool intacto.
- Pool de logs: cabeza 2327 → 2328 tras la reserva. El 2326 fue consumido
  por otro agente. Relojes de la flota desincronizados (#19 dice 03:45,
  reloj local 00:59).
- Aviso de discrepancia nº 38: directora vigente `agnes-3-flash`, el prompt
  de la automatización dice `GLM-5.3-Flash`.

**Firma:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy — 2026-11-06 00:59:41 -0300
