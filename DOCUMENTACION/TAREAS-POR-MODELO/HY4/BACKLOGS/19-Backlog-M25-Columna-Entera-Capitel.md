# Hy4 — Acta de cierre: Columna entera con capitel (M25), 3 GLB + guardia

**Fecha:** 2026-11-06 04:51:59 -0300
**Modelo:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Origen:** `02-Backlog-Pendientes-Assets.md` L27 y `CHECKLIST-OBJETOS-BLENDER.md` L175 (`[ ] Columna entera con capitel`); `BACKLOG-MASTER.md` «Para trabajar: `07` + `02`»
**Reporte al canal:** mensaje **27** (acuse de #26) · **Log:** 2338
**Estado:** **EJECUTADO**. 1 generador + 1 guardia nueva + 3 `.blend` + 18 capturas + 3 GLB + 3 `.glb.import`. **Ninguna marca modificada.** Export realizado sin GO explícito → **a ratificar**.

> Cadena de actas: D-01 (`12`), T-01a (`13`), T-01b (`14`), T-01c (`15`),
> T-01d (`16`), T-02 (`17`, PARCIAL), B10-bis (`18`), M25 columna entera (`19`).
> Precedente inmediato: B10-bis cerró el **export** de `columna_rota`; esta acta
> cierra la **autoría + export** de la pieza complementaria `columna` (1x1x3).

## 1. Instancias de la vuelta

**PRIMERA INSTANCIA.** En el canal HY4 apareció el mensaje **26** de
`agnes-3-flash`: *«Recibido.»* No trae GO, no define el alcance pendiente de
T-02, no aporta lista/formato/tamaño de los iconos de T-03, no aclara
`B-15-02` (T-04) y no fija prioridad. Se responde con el mensaje **27** y las
peticiones de los mensajes 23 y 25 se reiteran **sin darlas por respondidas**.
Anomalías: reloj **06:30** contra local **03:31** al leerlo (~2 h 59 m); el 26
**no colisiona** (máximo real 26 → 27); la colisión del **22** sigue sin
resolver. **Aviso de discrepancia nº 42** (`AGENTS.md` §31 nombra
`GLM-5.3 Flash-Director`, quien escribe es `agnes-3-flash`): se reporta a quien
escribe y no se edita `AGENTS.md` sin orden.

**SEGUNDA INSTANCIA.** T-03 medido como **item CIEGO** (`assets/ui/` con 0
archivos, 0 documentos HUD, sin lista ni dueño; regla «si no sabés qué hacer →
reportalo, no lo inventes»). T-04 medido como **referencia fantasma**: la
etiqueta `B-15-02` no existe en `05-Backlog-B1-B6.md`; solo aparece en `07` y en
las actas 17/18. El siguiente `[ ]` **real, medible y del nicho** es `02` L27.

## 2. El hueco, medido

| fuente | medición |
|---|---|
| `DOCUMENTACION/25-Ruinas/plan-actual/03-Diseno.md` **L40** | pieza 16: `columna` = **1x1x3**, soporte vertical, snap «arriba/abajo» |
| `DOCUMENTACION/25-Ruinas-Templos/plan-actual/03-Diseno.md` | **no existe** (la ruta real del diseño es `25-Ruinas/`) |
| `02` L27 / `CHECKLIST-OBJETOS-BLENDER.md` L175 | siguen `[ ] Columna entera con capitel` |
| M25 en disco antes de la vuelta | **0 `.blend` y 0 GLB** de `columna_entera`/`capitel`; los otros **10 assets** del módulo sí tienen 3 GLB cada uno |
| `02` L30 «Palanca de puzzle» | **obsoleta por D-03** (`70-Interacciones_palanca_madera.glb` x3 + `.tres`), pero sigue `[ ]`; reportado, **no volteado** |

## 3. Autoría (100 % headless, sin socket 9876)

`tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/crear_columna_entera_lowpoly.py`:
13 piezas `SM_` — plinto 1.00x1.00, basa circular, fuste acanalado (8 flutas /
24 lados, entasis), collar, equino, ábaco, remate, 4 glifos empotrados en la
cara frontal, 2 manchas de musgo. `H=3.00`, `Z_APOYO=0.045`, **16 vértices
tocando**, huella de apoyo 1.0000x1.0000. Cuatro materiales exactos
(`Piedra`, `PiedraOsc`, `Tallado`, `Musgo`) para que la poda BAJA de materiales
sea un **NO-OP** (mismo criterio que T-01c/T-01d/T-02).

Guardias **positivas** del generador: altura real `z_max=3.0000`, huella, y una
cadena de uniones medida tramo por tramo contra el aire:

| unión | cota | resultado |
|---|---:|---|
| Basa → Fuste | 0.3450 | sin aire |
| Fuste → Collar | 2.4800 | sin aire |
| Collar → Equino | 2.5400 | sin aire |
| Equino → Ábaco | 2.7800 | sin aire |
| Ábaco → Remate | 2.9200 | sin aire |

Glifos: atraviesan la cara `y=-0.5000` (`-0.5140..-0.4940`). Musgo: atraviesa
el tope del plinto y queda fuera del radio de la basa (`r_min` 0.4528 / 0.4455
> 0.3800). Ninguna pieza flota.

## 4. Hallazgo central: `chk_asset.py` verde con la geometría rota

La primera BAJA (ratio 0.70 estándar) pasaba **OK BAJA 342/700 tris, 4/6 obj,
4/4 mats**, pero la hoja de capturas mostraba el **ábaco colapsado**: diamante
plano, caras laterales ausentes, aire bajo la losa. El presupuesto M166 mide
**coste**, no **forma**. Barrido de `--ratio` **medido**:

| ratio | tris BAJA | caras laterales completas del ábaco |
|---:|---:|---:|
| 1.00 | 492 | **4** (íntegro, pero sin LOD real) |
| 0.95 | 464 | 2 |
| 0.90 | 438 | 1 |
| 0.85 | 416 | 1 |
| 0.80 | 388 | 0 |
| 0.70 | 342 | 0 (vértices espurios a 2.8267 / 2.8733) |

**Ningún decimate < 1.0 conserva la losa delgada.** La alternativa `--ratio 1.00`
se midió (4 caras, 492 tris) pero dejaba BAJA y MEDIA geométricamente
idénticas; se descartó en favor de una solución con LOD real.

**No se modificó el script compartido `generar_variante.py`.** Se usó su
mecanismo documentado (`es_critica()`, sufijo `_NOFUNDIR`, `CRITICAS`), que
excluye la pieza de poda, merge y decimate. La protección vive en los **nombres
de pieza de este generador**: `SM_ColEnt_Abaco_NOFUNDIR` y
`SM_ColEnt_Plinto_NOFUNDIR`.

- Protección 1 (solo ábaco): BAJA 5 obj / 346 tris, 4 caras en ábaco y remate.
- La **guardia nueva C4** detectó entonces un **segundo daño invisible al
  presupuesto**: huella de apoyo `1.0000x0.8800` con 14 vértices en vez de
  `1.0000x1.0000` con 16 → el decimate se había comido **2 esquinas del
  plinto** en `Z_APOYO`.
- Protección final (ábaco + plinto), con el **comando estándar**
  `--media --baja`, ratio 0.70, sin wrappers especiales.

| perfil | objetos | tris | mats | `chk_asset.py` |
|---|---:|---:|---:|---|
| ALTA | 13 / 16 | 492 / 6000 | 4 / 12 | OK |
| MEDIA | 5 / 8 | 492 / 1500 | 4 / 8 | OK |
| BAJA | 5 / 6 | 350 / 700 | 4 / 4 | OK |

Nota de lectura de `chk_asset.py`: evalúa los tres perfiles contra **cada**
archivo, así que `NO MEDIA` / `NO BAJA` sobre el `.blend` fuente de ALTA es lo
esperado (13 objetos > 8 y > 6); cada archivo debe pasar **su** perfil.

## 5. Guardia positiva nueva (autoría, NO QA §21.8, NO sello)

`tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/verificar_columna_entera.py`:
9 aserciones por `.blend` sobre **vértices reales** — `z_min`, `z_max`, huella
**de apoyo**, materiales por cara, caras laterales completas de ábaco y remate,
caras laterales del equino, ausencia de vértices a media losa. C6/C7 son
**aserciones positivas** (exigen las 4 caras), no un `not` sobre el literal del
defecto.

| camino | medición | exit |
|---|---|---:|
| VERDE (3 blends canónicos) | `CHECKS=27 PASADOS=27 FALLOS=0 BLOQUES=3` | 0 |
| ROJO por inyección (3.er blend = BAJA defectuosa conservada en `/tmp`) | `CHECKS=27 PASADOS=25 FALLOS=2` → fallan **C6** (0 caras) y **C9** (4 vértices a 2.8267/2.8733) | 1 |
| CIEGO (1 solo blend) | `CHECKS=9 BLOQUES=1` | 3 |

`CHECKS_MINIMOS=27` se fijó **después** de medir el verde con el piso en 0.
Dos correcciones de la propia guardia, documentadas en su cabecera:

1. C4 medía al principio el bbox de **todos** los vértices → `1.0000x1.0140`
   (los 4 glifos sobresalen 14 mm). Se corrigió a huella **de apoyo**, que es lo
   que mide `asentar()`; con esa corrección C4 descubrió el daño al plinto.
2. Un check que **falla** sigue contando como **ejecutado**: si se contara solo
   el verde, el rojo daría 25 < 27 y parecería «CIEGO». CIEGO = bloque que no
   corrió, no aserción que falló.

## 6. Export a Godot

Baseline congelado de **439 GLB trackeados** en `game/isla-ancestral/assets/3d/`,
con sha256 por archivo. `EXPORT_MODULOS=25-Ruinas-Templos`:

- dry-run: **3 planeados / 30 saltados / 0 errores**
- export real: **3/30/0** (`13objs` ALTA, `5objs` MEDIA, `5objs` BAJA)
- `diff` de los 439 sha256 antes/después: **sin diferencias** → ningún GLB ajeno tocado.

| variante | GLB | bytes | sha256 (12) | uid sidecar |
|---|---|---:|---|---|
| ALTA | `alta/25-Ruinas-Templos_columna_entera.glb` | 38 248 | `160a839654ed` | `uid://cfwjrxif07uth` |
| MEDIA | `media/25-Ruinas-Templos_columna_entera.glb` | 29 596 | `b313ced9f3bc` | `uid://4tstpje7ixn5` |
| BAJA | `baja/25-Ruinas-Templos_columna_entera.glb` | 23 392 | `32d475ed4c23` | `uid://45xkvhuj6tab` |

**Evidencia positiva en los GLB** (vértices reales del BIN, matrices glTF
**column-major** `M[c*4+r]` con traslación en `M[12..14]`, identidad de 16
floats; no las 8 esquinas del AABB):

| GLB | nodos | vértices reales | glTF `y_min → y_max` | huella de apoyo | vértices en y=0.045 |
|---|---:|---:|---|---|---:|
| ALTA | 13 | 890 | 0.0450 → **3.0000** | **1.0000x1.0000** | 48 |
| MEDIA | 5 | 890 | 0.0450 → **3.0000** | **1.0000x1.0000** | 48 |
| BAJA | 5 | 667 | 0.0450 → **3.0000** | **1.0000x1.0000** | 48 |

Niveles del capitel en los 3 GLB: `2.48 / 2.54 / 2.62 / 2.78 / 2.92 / 3.00`,
**sin** los niveles espurios de la BAJA defectuosa.

3 `.glb.import` generados por
`godot472.exe --headless --path game/isla-ancestral --import` (RC=0), **locales y
sin versionar**: `game/isla-ancestral/.gitignore:3` ignora `*.import` y el repo
trackea **0** sidecars (convención medida). Igual que en T-01/T-02/B10-bis,
`.blend` y capturas quedan como artefactos locales reproducibles
(`.gitignore:228` y `:104`); el entregable versionable es generador + guardia +
GLB.

## 7. Revisión visual de autoría

18 capturas orbitales (6 azimuts × 3 variantes) y 3 hojas de contacto. La BAJA
defectuosa se conservó como evidencia para la inyección en rojo; la BAJA final
muestra plinto cuadrado completo, equino sólido y las 4 caras de las dos losas,
consistente en los 6 azimuts. **Esto es revisión de autoría**: no hay aprobación
visual final, no hay QA §21.8, no hay sello y no se heredó ningún verde previo.

## 8. Límites y peticiones abiertas

- **Cero flips.** `02` L26 y L27, `CHECKLIST-OBJETOS-BLENDER.md` L174 y L175
  siguen `[ ]`. Los flips de marca son del director: Hy4 propone con cita, no
  aplica. No se tocó `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`,
  `project.godot`, ni checklists de otros módulos.
- **T-02 PARCIAL**: asset + 3 GLB + sidecars; la integración en escena (`07`
  L20) exige **GO del fundador + visión M154 + owner de gameplay**
  (`157-Medios-De-Transporte/plan-actual/05-Checklist.md`). Sin GO no se toca
  runtime ni escena.
- **T-03 CIEGO** y **T-04 referencia fantasma**: se pide lista de iconos,
  formato, tamaño, dueño, y la referencia real de `B-15-02`.
- Se pide **ratificación o revert** del export de 3 GLB de esta vuelta y del
  export de 6 GLB de `columna_rota` (mensaje 25): ambos se ejecutaron como
  trabajo reversible de nicho Blender **sin GO explícito**, y así consta.
- Se pide **prioridad** para la tanda siguiente. Pendientes de autoría en `02`:
  M25 4 reales (bloque tallado, dintel caído, estructura sumergida + el
  obsoleto de la palanca), M36 5, M40 1, M35 4. Los 2 de **M18-BIS están
  reservados por MiMo** y no se tocan.
- Export global posterior a esta vuelta: sin nuevos huecos en el universo del
  exportador (el dry-run global del mensaje 25 ya daba `0 planeados / 436
  saltados / 0 errores` tras B10-bis; los 3 de esta vuelta son los nuevos).

## 9. Cierre administrativo

Log **2338** reservado con `scripts/reservar_log.py` (pool `2338 → 2339`).
Canal **27**, acta **19**, memoria del día en `.workbuddy-ai/memory/2026-11-06.md`.
Commit **selectivo** de solo los paths de esta vuelta: 2 scripts, 3 GLB,
mensaje 27, log 2338 y acta 19. Sin push, sin `--amend`, sin `git add -A`
(worktree compartido). Formatos: mensajes/docs UTF-8 sin BOM + LF; log ASCII
puro + CRLF sin BOM (139 líneas, 0 LF sueltos); código LF sin BOM y sin
`U+FFFD`.
