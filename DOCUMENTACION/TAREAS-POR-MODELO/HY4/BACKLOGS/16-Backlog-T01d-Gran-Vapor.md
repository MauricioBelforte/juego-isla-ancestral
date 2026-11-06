# Hy4 — Acta de cierre T-01d: Gran Vapor (M67/M68, locomotora de riel)

**Fecha:** 2026-11-06 01:23:00 -0300
**Modelo:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Origen:** `07-Backlog-Tanda-Blender.md`, T-01d (directora agnes-3-flash #05 / #17 / #21)
**Reporte al canal:** mensaje **22** (acuse de #21) · **Log:** 2328
**Estado:** ejecutado. **Marca en `07` NO modificada** (propuesta de flip enviada).

> Precedente: D-01 (`12-…`), T-01a (`13-…`), T-01b (`14-…`) y T-01c
> (`15-…`) se documentaron en actas propias sin tocar el `07`. Con esta acta
> **T-01 queda 4/4 ejecutado**, siempre con reporte separado por vehículo.

## Alcance

Gran Vapor, `id=locomotora`, tipo **riel**, ~15 m, `vehicles.json`
(`velocidad_max=20`, `velocidad_crucero=20`, `giro=0`, `frenado=6`,
`baul_slots=16`, `tiene_reversa=false`, `condicional="M68"`).
`m68_spec.md` condiciona la estación central, el andén de 8 m y la ruta
lineal a que M67 defina locomotora. Los **rieles y la ruta los aplica el
runtime**; el asset solo aporta geometría con `z_min = 0.045`.

## Evidencia POSITIVA (re-medida en esta vuelta)

| perfil | objetos | tris reales | mats | z_min | veredicto `chk_asset.py` |
|---|---:|---:|---:|---:|---|
| ALTA | 13/16 | 924/6000 | 4/12 | 0.0450 | OK (perfil propio) |
| MEDIA | 4/8 | 924/1500 | 4/8 | 0.0450 | OK |
| BAJA | 4/6 | 646/700 | 4/4 | 0.0450 | OK |

Cotas en los 3 `.blend` y los 3 GLB: `X [-1.430..1.430]` = 2.860 m,
`Y [-7.500..7.500]` = **15.000 m**, `Z [0.045..4.180]` = 4.135 m
(BAJA `4.174` / 4.129 tras decimate).

GLB (destino canónico `<variante>/<modulo>_<base>.glb`):

- `game/isla-ancestral/assets/3d/alta/67-Vehiculos_gran_vapor.glb` — 54 576 B, 13 nodos/mallas
- `game/isla-ancestral/assets/3d/media/67-Vehiculos_gran_vapor.glb` — 48 992 B, 4/4
- `game/isla-ancestral/assets/3d/baja/67-Vehiculos_gran_vapor.glb` — 38 288 B, 4/4

Medición sobre **vértices reales decodificados del BIN** (magic `glTF` v2,
chunks JSON+BIN, matrices de nodo por jerarquía en **column-major**,
`byteStride` real): ALTA 1636 vértices, MEDIA 1636, BAJA 1264. En los tres
`y_min = 0.0450`, `x = 2.860`, `z = 15.000`, 4 materiales usados de 4,
**0** nodos `Base_Arena`/`SOL`/`CAM_`, todos los nodos `SM_`. ALTA
`y_max = 4.1800`; BAJA `y_max = 4.1742`.

Dry-run del exportador: **3 planeados / 9 saltados / 0 errores**. Export real
**3/0/0** (`13objs`, `4objs`, `4objs`). Los **9 GLB de T-01a/b/c quedaron
byte-idénticos** a HEAD (sha256 antes/después).

Capturas: 6 azimuts por variante (**18 PNG**) y 3 hojas de contacto con
sha256 distintos (`bb90689f…`, `b71779cf…`, `10e9f498…`) en
`tools/mcp/blender-mcp/67-Vehiculos/capturas/`. Las 6 vistas muestran cabina,
caldera, chimenea, domo, farol, 12 ruedas y parachoques; sin piezas
desprendidas visibles. La identidad de color se conserva en los 3 LOD.

## Decisiones registradas

1. **Poly Haven descartado por medición**: 521 modelos, **0** ferroviarios.
   29 hits son falsos positivos; `rail` está dentro de `trail` (20 nature
   assets) y `cart` da 4 carritos de **18 902–29 418 polis** y **0.84–2.17 m**.
2. **Apoyo por RUEDAS, no patines** (a diferencia de T-01a/b/c): disposición
   4-6-2, 6 motrices `Y=(-2.60,-0.40,1.80)` + 6 de bogie `(-6.20,5.00,6.10)`,
   octógonos de arista inferior plana, **48 vértices reales de huella**,
   footprint medido `2.480 × 12.683`.
3. **4 materiales exactos** (`MAT_Vapor_Marfil`, `MAT_Vapor_Verde`,
   `MAT_Vapor_Laton`, `MAT_Vapor_Hierro`): reutiliza el fix de T-01c para que
   `--max-mats 4` sea un **no-op** y el merge produzca 4 objetos. No se
   modificó `generar_variante.py` (script compartido).
4. **Normales explícitas hacia afuera** en la caldera (winding `(a,d,c,b)`),
   con guard de producto punto radial; sin `recalc_face_normals` sobre tiras
   abiertas.
5. **Guardias de unión positivas** `z_caldera_inf(y,x)` / `z_caldera_sup(y)`:
   bastidor contra la superficie inferior real; chimenea, domo y farol contra
   la superior real. Más: bielas contra pernos (`d<0.07`), ventanas fuera de
   cabina, parachoques en `Y_PROA`, largo total 15.00 m.
6. **Dos defectos reales corregidos**: voladizo excesivo del techo; y 6 cubos
   de rueda como cilindros de 6 lados (120 tris) que llevaban BAJA a
   **720 > 700** → discos planos de 1 quad (12 tris), BAJA **646**.
7. **Falso verde de Blender evitado**: `RC=0` no prueba nada; se exigieron
   marcador `RESUMEN_EXPORT`, existencia de los 3 GLB y `py_compile` previo.
8. **E-63 resuelto en T-01a**: `67-Vehiculos` ya estaba en `MODULOS`. Ningún
   script compartido modificado en esta vuelta.

## Trampa NUEVA: el lector de matrices (no el accessor)

El acta 14 registró que transformar las 8 esquinas del AABB del accessor
`POSITION` infla el bbox con nodos rotados. Aquí apareció la **misma familia
en el lector de matrices**: `dump_glb.py` genera matrices column-major con
`trs()`/`mul()` pero `aplicar()` las lee **row-major** (`M[0*4+i]`,
traslación en `M[3]` en vez de `M[12..14]`). Mi primer decodificador copió
ese convenio y dio `y_min=-0.045`, `x_max=2.595`, que no cuadraban con el
`.blend` (`0.045`, `1.430`). Corregido a `M[c*4+r]` + `M[12..14]`, las 3
variantes coincidieron exactamente.

Reproducción medida sobre `SM_Vapor_Bielas` (nodo 12, con rotación y
traslación reales):

| fuente | Y mundo |
|---|---|
| `dump_glb.py` | `[-0.0450 .. 0.4715]` |
| decodificador column-major | `[0.9777 .. 1.4941]` |

Es un **defecto del helper compartido**, no del asset. Se reporta con GO para
el fix de 2 líneas; **no se aplicó** para no tocar un script de la flota.
Como **un verde no se hereda**, se re-medieron con el decodificador corregido
los 9 GLB de T-01a/b/c: Barquita `0.045/3.605`, Globo `0.045/7.655`, Perla
`0.045/3.510` (ALTA 1039 vértices, BAJA 785) → **acta 15 confirmada**.

## Formatos (medidos después de escribir, antes de insertar este bloque)

| archivo | bytes | BOM | CRLF | LF total | LF sin CR | U+FFFD | bytes > 127 |
|---|---:|---|---:|---:|---:|---:|---:|
| mensaje 22 | 9014 | no | 0 | 168 | 168 | 0 | 168 |
| acta 16 (pre-bloque) | 5888 | no | 0 | 111 | 111 | 0 | 115 |
| log 2328 | 7273 | no | 127 | 127 | 0 | 0 | 0 |
| generador | 18879 | no | 0 | 452 | 452 | 0 | 0 |

- Mensaje, acta y generador son **UTF-8 sin BOM + LF**: que todos sus LF
  aparezcan "sin CR" es lo esperado. El log es **ASCII puro + CRLF**:
  0 LF sueltos, 0 bytes > 127. Ninguno tiene BOM ni `U+FFFD`.
- `python -m py_compile` del generador: RC=0. Gate §28 `verificar_bom.py`:
  RC=0 con 6 avisos de `U+FEFF` embebido, ajenos y no bloqueantes.

## Límites declarados

- Revisión visual **de autoría**. No es QA §21.8, no es sello, no es
  aprobación visual final. Sin push, sin `--amend`, sin `add -A`.
- MEDIA es visualmente idéntica al ALTA (merge sin pérdida); BAJA conserva
  la silueta con 646 tris y la misma bbox X/Y.
- `.blend`, capturas y `__pycache__` quedan locales por `.gitignore`
  L84/L104/L228. El entregable versionable es generador + 3 GLB + cierre.

## Propuestas a la directora (sin aplicar)

- [ ] Flip de **T-01d** a `[x]` en `07`, con cita al mensaje 22 + log 2328.
- [ ] **T-01 queda 4/4**. Siguiente `[ ]` de la COLA ACTIVA es **T-02 M157
  Transporte**; pedir confirmación de alcance antes de tomarla (la
  integración en escena toca terreno/runtime ajeno).
- [ ] **T-01a-bis** (popa abierta de la Barquita, acta 13): sin GO en
  #17 / #19 / #21.
- [ ] GO para el fix de `dump_glb.py` y re-visitar mediciones históricas.
- [ ] `07` L33 (`quality.yml GO`) está obsoleto: P-01 ejecutado con GO de
  #05, commit `d806c45`. No se flipa sin orden.

## Deuda ajena detectada, NO tocada

- Pool del canal HY4: cabeza 5, máximo real 21 → `max(real)+1 = 22`; pool intacto.
- Pool de logs: 2328 → 2329 tras la reserva. Relojes desincronizados (#21
  dice 04:15, reloj local 2026-11-06 01:23:00).
- `07` cita `template_asset.py`; el helper real es `plantilla_asset.py`.
- Aviso de discrepancia nº **39**: directora vigente `agnes-3-flash`, el
  prompt de la automatización dice `GLM-5.3-Flash`.

**Firma:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy — 2026-11-06 01:23:00 -0300
