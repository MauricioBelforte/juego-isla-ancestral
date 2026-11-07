# Acta 25 — B15/L28: Bloque de piedra tallada (M25), módulo de muro 1×2 voxel

**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-07 20:05:23 -0300
**Canal:** mensaje 37 · **Log:** 2366
**Origen:** `02-Backlog-Pendientes-Assets.md` **L28** y `CHECKLIST-OBJETOS-BLENDER.md` **L176** (`[ ] Bloque de piedra tallada (módulo de muro)`); propuesto en el mensaje 36 §4 y autorizado por el fundador con `si segui con eso`.
**Estado:** **EJECUTADO**. 1 generador + 1 guardia nueva + 3 `.blend` + 18 capturas + 3 hojas de contacto + 3 GLB + 3 `.glb.import`. **Cero flips**, sin QA §21.8, sin sello, sin aprobación visual. Export realizado sin GO explícito → **a ratificar**.

> Cadena de actas: … B10-bis (`18`), M25 columna entera (`19`), M18-BIS mansión (`20`), B10-ter (`21`), B11 legado (`22`), B12 triángulos runtime (`23`), B13 corpus (`24`), **B15 bloque tallado (`25`)**.
> **Rótulo B15 por auto-corrección:** el plan previo decía B14, pero B14 ya está ocupado por el acta 11 (`D-03 / B14`) y B13 por las actas 10 y 24. Medido antes de publicar; no se renombra nada ya publicado.

---

## 1. Estado vivo al reingresar

Medido `2026-11-07 19:56:34 -0300`: HEAD `e34f840` (mi acuse 35), worktree **97** entradas ajenas, pool de logs en `2365`, canal HY4 con máximo real **36** y **sin mensaje nuevo** de la directora después del #35 (respondido en mi **36**) → **no hay PRIMERA INSTANCIA pendiente**. Aviso de discrepancia nº **50**.

**Fuga de pool:** `reservar_log.py --reservar` descartó `2365` (ya había un log ajeno en disco) y asignó **2366**; el pool quedó en `2367`. No se tocó el archivo ajeno ni se reescribió el pool a mano. Canal: `max(real)+1 = 37`; colisiones vivas 22 / 27 / 28.

## 2. SEGUNDA INSTANCIA

`07` sigue sin reposición: T-01a..T-01d y T-02 ejecutados sin flips, T-03 **CIEGO**, T-04 referencia fantasma, resto protegido o ajeno. El mensaje 36 midió qué `[ ]` de `02` carecen de artefacto y propuso **L28** (0 GLB, 0 generador). Con el `si segui con eso` del fundador se ejecuta en modo **asset-only Blender**, el mismo carril de `columna_rota` (B10-bis) y `columna_entera` (acta 19). No se tocó integración Godot, `07`, ni archivos de otro módulo.

## 3. Spec MEDIDA (no inventada)

| fuente | contenido | consecuencia |
|---|---|---|
| `DOCUMENTACION/25-Ruinas/plan-actual/03-Diseno.md` **L30**, pieza 6 | `muro_recto` = `1x2 voxel, pared estándar`, snaps `2 caras (lados)` | **ANCHO = 1,00 m**, **ALTO = 2,00 m** |
| misma tabla **L40**, pieza 16 | `columna` = `1x1x3` | fija **1 voxel = 1,00 m** (criterio ya usado en el acta 19) |
| — | la spec **no** fija espesor | **FONDO = 0,40 m es decisión de autoría documentada**: deja huella por encima de E-50 (`min_fp=0,30` en X e Y) sin inventar un muro de 1 voxel de fondo |

La cornisa vuela 4 cm por lado (**1,08 × 0,46 m**) y **no** forma parte de la huella de apoyo. Diferencia explícita con `columna_entera`: allá `H=3,00` era cota **absoluta**; acá se mide el **alto físico desde la propia base**: `z_min=0,045`, `z_max=2,045`, `alto=2,000` en los 3 LOD. Se documenta para no heredar en silencio una cota distinta.

## 4. Autoría headless

`tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/crear_bloque_tallado_lowpoly.py` — Blender 4.2 `-b --factory-startup --python-exit-code 1` (evita el **falso verde RC=0** con `AssertionError` oculto, medido en la mansión).

- **4 materiales** exactos → la poda BAJA a 4 es un **NO-OP**; ninguna pieza de identidad se blanquea. Mismo criterio que T-01c/T-01d/T-02/`columna_entera`/M18-BIS.
- **13 objetos `SM_`** en ALTA: zócalo, cuerpo, cornisa, panel, medallón de 12 lados, 4 glifos, 2 pilastras, 2 musgos.
- `Z_APOYO = 0,045` (E-12), `zmin_real()` sobre **vértices reales** (E-24), purga de `Base_Arena`/`SOL`/`CAM_*` (E-44).
- **`min_toca = 4` documentado:** el default 8 de `asentar()` se calibró para plinto cuadrado + basa circular (`columna_entera`). Un sillar rectangular tiene **exactamente 4** vértices en su cara inferior y 0,40 m² de apoyo. Se baja el **conteo de vértices**, **no** el guard de huella (`min_fp=0,30` se mantiene), y la guardia externa vuelve a medir las 4 esquinas en los 3 LOD.
- **Guardia positiva de relieve embebida:** panel, medallón, glifos, pilastras y musgo **atraviesan** el plano de la cara del muro (`y=-0,200`) o del panel (`y=-0,216`). Si no lo cruzan son piezas pintadas/flotantes. Cadena de uniones sin aire en `z=0,225` y `z=1,845`.

### 4.1 Defectos medidos en las dos primeras BAJA (`ratio 0,70`)

| versión | `chk_asset.py` | hoja de contacto | causa |
|---|---|---|---|
| v1 (sin proteger panel) | **OK BAJA** `6/136/4`, `alto 2,000` | panel **colapsado en cuña triangular**, aire bajo cornisa | decimate sobre el panel delgado |
| v2 (panel protegido) | **OK BAJA** `6/140/4` | **persistía** la cuña + franja oscura | el merge de `MAT_Bloque_Piedra` quedaba con **un solo cubo**; decimate `0,70` sobre 12 tris lo convierte en cuña |
| **v3 (solución)** | **OK BAJA** `6/144/4` | limpia | 4 críticas `_NOFUNDIR` + 2 mallas de relieve fusionadas = **6 objetos**, exactamente el techo BAJA; el decimate sólo actúa sobre el **relieve** |

`_NOFUNDIR` es el mecanismo **documentado** de `generar_variante.py::es_critica()`: protege de poda, merge y decimate. No se modificó el script compartido. Lección re-medida: **`chk_asset.py` mide COSTE, no FORMA** (acta 19, trampa del ábaco).

## 5. Coste M166 re-medido hoy

`chk_asset.py` bajo Blender 4.2 sobre los 3 `.blend` (un verde no se hereda):

| LOD | obj | tris | mats | veredicto |
|---|---|---|---|---|
| ALTA | 13 | 188 | 4 | **OK ALTA** (`NO MEDIA` / `NO BAJA` en el archivo fuente son **esperados**: el script evalúa los 3 perfiles contra cada archivo) |
| MEDIA | 6 | 188 | 4 | OK en los 3 perfiles |
| BAJA | 6 | **144** | 4 | OK en los 3 perfiles |

`bbox Z [0,045 .. 2,045] alto=2,000`, `bbox X 1,080`, `bbox Y 0,465` en los tres. **18 PNG** (6 azimuts × 3 LOD) + **3 JPG** de contacto. Revisión visual de autoría (no QA ni sello): ALTA correcta; BAJA v3 con panel rectangular, medallón, 4 glifos, pilastras, zócalo, cornisa y musgo; sin cuña, fragmento flotante, ranura oscura ni aire bajo cornisa. LOD real: 144 vs 188 tris.

## 6. Export a Godot

Baseline sha256 de **448** GLB trackeados → `Temp/hy4_bloque_baseline_glb_20261107.json`.

- `EXPORT_DRY=1 EXPORT_MODULOS=25-Ruinas-Templos` → **3 planeados / 33 saltados / 0 errores**.
- Export real → **3 ok / 33 saltados / 0 errores**.
- Post-verificación: **448 GLB preexistentes, 0 mutados**; 3 nuevos.

| LOD | bytes | sha256 (12) |
|---|---|---|
| `alta/25-Ruinas-Templos_bloque_tallado.glb` | 22 932 | `7bfa67b0aea7` |
| `media/25-Ruinas-Templos_bloque_tallado.glb` | 16 016 | `e3e4f53d9b6e` |
| `baja/25-Ruinas-Templos_bloque_tallado.glb` | 13 452 | `869df47101b6` |

3 `.glb.import` generados con Godot 4.7.2 `--headless --import` (RC=0), uid `d2uqms08rxnyv` / `bdw6f7t7df5pe` / `pjkpaycwxl2w`. Quedan **locales y sin versionar**: `game/isla-ancestral/.gitignore:3` ignora `*.import`.

## 7. Runtime: 144 (`.blend`) → 136 (GLB)

Decodificando **BIN real** (índices + `POSITION` + matrices column-major, glTF Y-up): ALTA **188**, MEDIA **188**, BAJA **136** tris; los tres `y=[0,0450, 2,0450]`, 4 materiales; 360/360/266 vértices `POSITION`.

Sonda Blender 4.2 sobre **copias en memoria** del `.blend` BAJA — sin guardar ningún `.blend`, 0 modifiers — `mesh.validate()` cierra el delta exacto:

| malla | antes | validado | delta |
|---|---|---|---|
| `SM_Bloque_M_Bloque_Tallado` | 80 | **72** | **−8** |
| `SM_Bloque_M_Bloque_Musgo` | 16 | 16 | 0 |
| Cornisa / Cuerpo / Panel / Zócalo `_NOFUNDIR` | 12 c/u | 12 c/u | 0 c/u |
| **TOTAL** | **144** | **136** | **−8** |

Es el fenómeno de **B12/B13** (polígonos inválidos tras merge/decimate sobreconteados por `calc_loop_triangles()`; el exportador glTF valida antes de escribir). El GLB es la malla **validada**, no geometría perdida. Se publica como **dato**, nunca como check: un número documental viejo no debe consagrarse como aserción. Corolario para el catálogo: **la regla del corpus se aplicó antes de publicar**, no después.

## 8. Guardia nueva de FORMA sobre el GLB de runtime

`tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/verificar_bloque_tallado.py` — Python puro, sin `bpy`, autocontenido. Decodifica **vértices reales del BIN** que Godot consume (no las 8 esquinas del AABB), matrices `M[c*4+r]`, traslación en `M[12..14]`, glTF **Y-up** (altura `y`, frente `z` positivo: Blender `y=-0,200` → glTF `z=+0,200`, **medido**).

**Trampa nueva medida:** dentro del GLB las mallas se llaman `Cube`, `Cube.001`, … — el exportador usa el nombre del **datablock**, no del objeto `SM_`. Por eso **ninguna** aserción de identidad depende de nombres: todas son **geométricas por coordenadas**. Una guardia que buscase `SM_Bloque_Panel` en el GLB daría un verde vacío.

15 checks por GLB + 2 globales, todos **positivos**: cabecera/chunks, estructuras, alcanzabilidad de nodos con mesh, índices en rango, vértices finitos, `y_min=0,045`, `y_max=2,045`, 4 esquinas de huella `1,00×0,40`, 4 de cornisa `1,08×0,46`, 4 esquinas del panel en `z=0,216`, anillo del medallón de 12 vértices a `r=0,17`, ≥5 planos de relieve con masa, **0** vértices a media cornisa (detecta la cuña), M166 de runtime; globales = cobertura triple LOD y monotonía de tris.

`CHECKS_MINIMOS=47` / `BLOQUES_MINIMOS=3` fijados **después** de medir el piso con la constante en 0. Un check que **falla** sigue contando como ejecutado (si se contaran sólo los verdes, el rojo parecería ciego).

| camino | comando | resultado | exit |
|---|---|---|---|
| PISO | `--piso 0 --volcar` | `47/47/0`, 3 bloques, 15 checks por bloque | 0 |
| VERDE | sin flags | `47/47/0` | 0 |
| ROJO | `--inyectar` | `47/44/3`: **C10** cornisa 3/4, **C11** panel 0/4, **C14** 3 vértices a `y=1,95` | 1 |
| CIEGO | `--solo <alta>` | 17 checks, 1 bloque | 3 |

La inyección **reproduce en el BIN** la cuña de v1/v2 (colapsa las 4 esquinas frontales del panel y baja una esquina de cornisa) sobre una **copia en `Temp/`**; el GLB publicado no se toca. Es prueba en rojo del **efecto real**, no del literal del defecto. `py_compile` RC=0.

## 9. Entregables y disciplina

| path | destino |
|---|---|
| `Mensajes entre modelos/HY4/37-…-b15-bloque-piedra-tallada-m25.md` | canal (REGLA CERO) |
| `Logs/2366-HY4-B15-BLOQUE-PIEDRA-TALLADA-M25_2026-11-07_20-05-23.md` | log formal, ASCII puro + 174 CRLF + sin BOM |
| `DOCUMENTACION/TAREAS-POR-MODELO/HY4/BACKLOGS/25-Backlog-B15-Bloque-Piedra-Tallada-M25.md` | esta acta |
| `tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/crear_bloque_tallado_lowpoly.py` | generador |
| `tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/verificar_bloque_tallado.py` | guardia |
| `game/isla-ancestral/assets/3d/{alta,media,baja}/25-Ruinas-Templos_bloque_tallado.glb` | 3 GLB de runtime |
| `.workbuddy-ai/memory/2026-11-07.md` | append (ignorado por git) |

**Commit selectivo de 8 paths**, `add` + `commit` encadenados, sin `--amend`, sin push, sin `git add -A`. Pool de logs **no** se commitea. Los `.blend` (`*.blend`), `capturas/` y `.glb.import` están ignorados por `.gitignore` y quedan en disco sin versionar. Sondas, baseline JSON y GLB inyectado en `Temp/` **conservados**, no borrados. Las 97 entradas ajenas del worktree al cierre quedaron intactas. Ambos scripts UTF-8/LF, sin BOM, sin `U+FFFD`, 0 CR.

Sin flips, sin QA §21.8, sin sello, sin aprobación visual final, sin GO.

## 10. Decisiones abiertas para la directora

1. **Flip** de `02` **L28** y `CHECKLIST-OBJETOS-BLENDER.md` **L176** — propuesto, **no aplicado**; los cambios de marca los aplica la directora.
2. **Ratificación** del export sin GO, reposición de la **COLA ACTIVA** y de P1..P7; definición de T-02 (integración), T-03 (CIEGO), T-04 (fantasma) y Q2 (estrella de mar, Log 278 L152).
3. **Siguiente hueco real medido:** `02` **L29 Dintel caído** (0 GLB, 0 generador, checklist L177). También L31, L34, L37, L40 y M36 fauna ×5. Marcas **obsoletas**: L30 Palanca y L39 Cangrejo (ya tienen GLB y generador).
4. **§28 en ROJO en HEAD**, ajeno y **sin tocar**: `python scripts/verificar_bom.py` RC=1 por `Mensajes entre modelos/DS-V4.1-Flash-Opencode/.ultima-revision-ds.txt` (6 B, `EF BB BF` + `253`); `quality.yml:859` lo ejecuta como gate duro. Reportado en el mensaje 34 §7.5; requiere GO por ser archivo de otro agente. Mis 8 paths están limpios.
5. Anotar en el acta 24 que el corpus pasa a tener un **caso 31** (`bloque_tallado` BAJA, deriva −8) y que la regla «medir sobre el GLB» se aplicó **antes** de publicar esta acta.
