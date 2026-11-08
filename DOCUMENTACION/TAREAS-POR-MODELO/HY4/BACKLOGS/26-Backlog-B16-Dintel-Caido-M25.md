# Acta 26 — B16/L29: Dintel caído (M25), dintel de `muro_vano` caído a plano

**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-08 00:33:21 -0300
**Canal:** mensaje 40 · **Log:** 2369
**Origen:** `02-Backlog-Pendientes-Assets.md` **L29** y `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` **L177** (`[ ] Dintel caído`); propuesto en el mensaje 37 §10.3, tomado en el mensaje 39 tras el `si seguimos` del fundador.
**Estado:** **EJECUTADO**. 1 generador + 1 guardia nueva + 3 `.blend` + 18 capturas + 3 hojas de contacto + 3 GLB + 3 `.glb.import`. **Cero flips**, sin QA §21.8, sin sello, sin aprobación visual. Export sin GO explícito → **a ratificar**.

> Cadena de actas: … B13 corpus (`24`), **B15 bloque tallado (`25`)**, **B16 dintel caído (`26`)**.
> **Rótulo B16 medido antes de publicar:** no existe ningún `B16` en los backlogs de HY4. B15 = acta 25, B14 = acta 11, B13 = actas 10 y 24. Sin colisión; no se renombra nada ya publicado.

---

## 1. Estado vivo al reingresar

Medido `2026-11-08 00:29:34 -0300`: HEAD `12bd0ef` (Mauricio Belforte, 2026-11-07 21:05, commit de preservación de la jornada), worktree **22** entradas, **0** staged, **451** GLB trackeados. Pool de logs encabezado por **2370**. Canal HY4: máximo real **39**, **sin mensaje nuevo** de la directora después del #38 (respondido en mi **39**) → **no hay PRIMERA INSTANCIA pendiente**. Aviso de discrepancia nº **52**.

**Anomalía de numeración cerrada aquí:** el ciclo anterior consumió **2369** a las 00:24 y se interrumpió **antes de escribir el log**. Medido: 2369 fuera del pool, sin `Logs/2369-*.md`, sin reclamo de otro agente. Se escribe el log con el número **ya reservado**; no se consume otro ni se reescribe el pool. Con `reservar_log.py` v3 el *claim* es la línea borrada del pool (no hay archivo de reserva): un número tomado sin log es **deuda real**. Canal por `max(real)+1 = 40`; pool de canal (684 B) intacto.

## 2. SEGUNDA INSTANCIA

`07` sigue sin reposición: T-01a..T-01d y T-02 ejecutados sin flips, T-03 **CIEGO**, T-04 referencia fantasma. El mensaje 37 midió qué `[ ]` de `02` carecen de artefacto y propuso **L29** (0 GLB, 0 generador, 0 `.blend`). Con el `si seguimos` del fundador se ejecuta en modo **asset-only Blender**, el mismo carril de `columna_rota` (B10-bis), `columna_entera` (acta 19) y `bloque_tallado` (B15). No se tocó integración Godot, `07`, ni archivos de otro módulo.

El **#38** sólo dice `Recibido. Procesado.`: sin GO, sin definiciones, sin prioridad, sin objeciones y sin ratificación del export de B15. Ambos exports quedan **a ratificar**.

## 3. Spec MEDIDA: el dintel **no está en la spec**

| fuente | contenido | consecuencia |
|---|---|---|
| `DOCUMENTACION/25-Ruinas/plan-actual/03-Diseno.md`, tabla de **24 piezas** | **no define `dintel`** | todas las cotas son **decisión de autoría documentada**, no valor de spec |
| E-28 (`GUIA-BLENDER/02`) | lo menciona como ejemplo de asset «de pared» para el **set de captura** | no es pieza del catálogo: no hay cota que «leer» |
| misma tabla, pieza 9 | `muro_vano` = «Recto con hueco de puerta 1x2» | **LARGO = 1,40 m** = luz 1,00 m + 0,20 m de apoyo a cada lado |
| misma tabla, pieza 16 | `columna` = `1x1x3` | fija **1 voxel = 1,00 m** (criterio del acta 19) |
| acta 25 §3 | `FONDO = 0,40 m` para `muro_recto` | se **reutiliza**: no se inventa un segundo espesor M25 |
| — | perfil del dintel | **CANTO = 0,30 m**; al caer de plano queda como altura física `z=[0,045 .. 0,345]` (0,353 con relieve) |

**Lectura de «caído» con 4 señales positivas** — ninguna es una rotación que rompería el apoyo: (1) viga **tumbada** a 0,30 m del suelo en vez de coronar un vano a 2 m; (2) el **relieve tallado mira al cielo** (+Z) en vez de al frente; (3) extremo derecho **astillado en 3 dientes de largo distinto** (0,30 / 0,20 / 0,26 m); (4) **fragmento desprendido + escombro** apoyados y separados del cuerpo.

**Huella del conjunto 1,90 × 0,56 m > viga 1,40 × 0,40 m** por esos dos fragmentos. Exigir `fp == 1,40×0,40` sería **consagrar una mentira**: la guardia mide las esquinas **del cuerpo** y exige `min(fp_x, fp_y) > 0,30` (E-50). `min_toca` **no** se relajó: `toca=24`.

## 4. Autoría headless

`tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/crear_dintel_caido_lowpoly.py` — Blender 4.2 `-b --factory-startup --python-exit-code 1` (evita el **falso verde RC=0** con `AssertionError` oculto, medido en la mansión).

- **4 materiales** exactos → la poda BAJA a 4 es un **NO-OP**; ninguna pieza de identidad se blanquea.
- **10 objetos `SM_`** en ALTA: cuerpo con 3 dientes, fragmento, escombro, grieta, 3 glifos, faja, 2 musgos.
- **4 críticas `_NOFUNDIR`** (cuerpo, fragmento, escombro, grieta) agotan los grupos Piedra y Oscuro; Tallado y Musgo quedan con piezas no críticas que se fusionan en 2 mallas ⇒ **MEDIA/BAJA = 6 objetos**, exactamente el techo BAJA. El decimate `0,70` actúa **sólo sobre el relieve**, nunca sobre la silueta portante. No se modificó `generar_variante.py` (mecanismo documentado `es_critica()`).
- `Z_APOYO=0,045` (E-12), `zmin_real()` sobre **vértices reales** (E-24), purga de `Base_Arena`/`SOL`/`CAM_*` (E-44), materiales **por caras** (E-42), `caja()/scale` = dimensión final (E-68), **sin parents** (E-27) para que `asentar()` mueva todas las piezas por igual.
- **Guardia positiva de relieve embebida:** grieta, 3 glifos, faja y 2 musgos **atraviesan** el plano `z=0,345`; si no lo cruzan son piezas pintadas o flotantes.

Lección re-aplicada de B15: **`chk_asset.py` mide COSTE, no FORMA**. Allá dos BAJA «OK» escondían el panel colapsado en cuña; acá la silueta portante se protege **antes** de derivar variantes, no después de ver el defecto.

## 5. Coste M166 y revisión visual, re-medidos hoy

`chk_asset.py` bajo Blender 4.2 sobre los 3 `.blend` (un verde no se hereda):

| LOD | obj | tris | mats | veredicto |
|---|---|---|---|---|
| ALTA | 10 | 156 | 4 | **OK ALTA** (`NO MEDIA` / `NO BAJA` en el archivo fuente son **esperados**) |
| MEDIA | 6 | 156 | 4 | OK en los 3 perfiles |
| BAJA | 6 | **132** | 4 | OK en los 3 perfiles |

Los tres: `z_min=0,0450`, `bbox X [-0,970 .. 0,930] ancho=1,900`, `Y [-0,200 .. 0,360] prof=0,560`, `Z [0,045 .. 0,353] alto=0,308`. **18 PNG** (6 azimuts × 3 LOD) + **3 JPG** de contacto. Revisión visual **de autoría** (no QA ni sello): ALTA y BAJA limpias en los 6 azimuts — viga tumbada, relieve y musgo en la cara superior, extremo astillado, 2 fragmentos apoyados; sin cuña triangular, fragmento flotante, ranura oscura ni aire. LOD real: **132** vs **156** tris.

## 6. Export a Godot (sin GO → a ratificar)

Baseline sha256 de **451** GLB trackeados → `Temp/hy4_dintel_baseline_glb_20261108.json`. Post-verificación: **451 entradas, 0 mutados, 0 faltantes, 3 nuevos**.

**Dry-run de control ejecutado hoy**: `EXPORT_DRY=1 EXPORT_MODULOS=25-Ruinas-Templos` → **0 planeados / 39 saltados / 0 errores**. Confirma que el export de los 3 GLB ya ocurrió y es **idempotente**; no se re-exportó nada en esta vuelta.

| LOD | bytes | sha256 (12) |
|---|---|---|
| `alta/25-Ruinas-Templos_dintel_caido.glb` | 19 300 | `2177c38a62d5` |
| `media/25-Ruinas-Templos_dintel_caido.glb` | 15 188 | `78f693b64bf7` |
| `baja/25-Ruinas-Templos_dintel_caido.glb` | 14 444 | `2e3bc011acff` |

3 `.glb.import` generados con Godot 4.7.2 `--headless --import`, uid `doy1vsfll5xg0` / `bp3s28oktstna` / `yae633royqhg`. Quedan **locales y sin versionar**: `game/isla-ancestral/.gitignore:3` ignora `*.import`.

## 7. Runtime: 132 (`.blend`) → 130 (GLB) — dato, no check

Decodificando **BIN real** (índices + `POSITION` + matrices column-major, glTF Y-up): ALTA **156 tris / 312 vértices**, MEDIA **156 / 312**, BAJA **130 / 270**; 4 materiales, `y=[0,0450, 0,3530]`, 3 dientes y **0** vértices en la zona vacía `0,20 < y < 0,30` en los tres.

Sonda Blender 4.2 sobre **copias en memoria** del `.blend` BAJA — sin guardar ningún `.blend`, 0 modifiers — `mesh.validate()` cierra el delta exacto:

| malla | antes | validado | delta |
|---|---|---|---|
| `SM_Dintel_M_Dintel_Tallado` | 32 | **30** | **−2** |
| Cuerpo / Fragmento / Escombro / Grieta `_NOFUNDIR` y Musgo | — | — | 0 c/u |
| **TOTAL** | **132** | **130** | **−2** |

El exportador glTF además avisó `Mesh SM_Dintel_M_Dintel_Tallado.001 is not valid`. Es el fenómeno de **B12/B13**: polígonos inválidos tras merge/decimate sobreconteados por `calc_loop_triangles()`; el GLB es la malla **validada**, no geometría perdida. Se publica como **dato**, nunca como check: la regla del acta 24 es medir M166 sobre el **GLB de runtime**, no sobre el `.blend`.

## 8. Guardia nueva de FORMA sobre el GLB de runtime

`tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/verificar_dintel_caido.py` — Python puro, sin `bpy`, autocontenido. Decodifica **vértices reales del BIN** que Godot consume (no las 8 esquinas del AABB), matrices `M[c*4+r]`, traslación en `M[12..14]`, glTF **Y-up**. **17 checks por GLB + 2 globales = 53.** Cotas **calibradas en el BIN** con `Temp/hy4_dintel_glb_probe.py`, no heredadas de `bloque_tallado`.

**Trampas evitadas a propósito:**

- Los nombres de malla dentro del GLB son `Cube`, `Cube.001`, … (el exportador usa el **datablock**, no el objeto `SM_`) → **ninguna** aserción de identidad depende de nombres: todas son **geométricas por coordenadas**.
- El decimate BAJA introduce niveles Y legítimos (`0,3423 / 0,3427 / 0,3473 / 0,3477`) en el relieve. La guardia **no** exige «0 niveles intermedios» ahí: exige **0 vértices en la zona donde no hay geometría** (`0,20 < y < 0,30`), que sí detecta una cuña estructural.
- La inyección usa la **inversa general 3×3 de la parte lineal (Cramer)**, no la inversa diagonal: asumir diagonal es trampa ya documentada.
- Un check que **falla** sigue contando como ejecutado.

`CHECKS_MINIMOS=53` / `BLOQUES_MINIMOS=3` fijados **después** de medir el piso con la constante en 0.

| camino | comando | resultado | exit |
|---|---|---|---|
| PISO | `--piso 0` | `53/53/0`, 3 bloques | 0 |
| VERDE | sin flags | `53/53/0` | 0 |
| ROJO | `--inyectar` | `53/50/3`; **30 vértices mutados** en copia `Temp/`; fallan **C10** (2/3 dientes), **C13** (cara superior 0/4), **C16** (1 vértice a `y=0,25`) | 1 |
| CIEGO | `--solo <alta>` | 19 checks, 1 bloque, FAIL G1/G2 | 3 |

Los cuatro caminos fueron **re-ejecutados en esta vuelta** (el verde del ciclo interrumpido no se heredó). La inyección reproduce la **cuña en el BIN** sobre una copia en `Temp/`; el GLB publicado no se toca. Es prueba en rojo del **efecto real**, no del literal del defecto. `py_compile` RC=0.

## 9. Entregables y disciplina

| path | destino |
|---|---|
| `Mensajes entre modelos/HY4/39-…-acuse-38-segunda-instancia-l29-dintel.md` | acuse del ciclo anterior, **sin versionar hasta hoy** |
| `Mensajes entre modelos/HY4/40-…-b16-dintel-caido-m25.md` | canal (REGLA CERO) |
| `Logs/2369-HY4-B16-DINTEL-CAIDO-M25_2026-11-08_00-33-21.md` | log formal, ASCII puro + CRLF + sin BOM |
| `DOCUMENTACION/TAREAS-POR-MODELO/HY4/BACKLOGS/26-Backlog-B16-Dintel-Caido-M25.md` | esta acta |
| `tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/crear_dintel_caido_lowpoly.py` | generador |
| `tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/verificar_dintel_caido.py` | guardia |
| `game/isla-ancestral/assets/3d/{alta,media,baja}/25-Ruinas-Templos_dintel_caido.glb` | 3 GLB de runtime |
| `.workbuddy-ai/memory/2026-11-08.md` | append (ignorado por git) |

**Commit selectivo de 9 paths**, `add` + `commit` encadenados, sin `--amend`, sin push, sin `git add -A`. Pool de logs **no** se commitea. Los `.blend`, `capturas/` y `.glb.import` están ignorados por `.gitignore` y quedan en disco sin versionar. Sondas, baseline JSON, logs de corrida y GLB inyectado en `Temp/` **conservados**, no borrados. Las entradas ajenas del worktree (Hy3, Crouton Alpha, Glyph Cluster, Reflection-Beam y `Logs/NUMEROS_DISPONIBLES.txt`) quedan intactas. Ambos scripts UTF-8/LF, sin BOM, sin `U+FFFD`, 0 CR.

Sin flips, sin QA §21.8, sin sello, sin aprobación visual final, sin GO.

## 10. Decisiones abiertas para la directora

1. **Flip** de `02` **L29** y `CHECKLIST-OBJETOS-BLENDER.md` **L177** — propuesto, **no aplicado**; medido hoy, ambos siguen en `[ ]`. **L28** también sigue en `[ ]` pese a B15 cerrado.
2. **Ratificación** de los exports sin GO de B15/L28 y B16/L29; reposición de la **COLA ACTIVA** y de P1..P7; definición de T-02 (integración), T-03 (CIEGO), T-04 (fantasma) y Q2.
3. **§28 en ROJO en HEAD y creció**: `python scripts/verificar_bom.py` RC=1 → **1** archivo con BOM al inicio (bloqueante: `Mensajes entre modelos/DS-V4.1-Flash-Opencode/.ultima-revision-ds.txt`, 6 B, `EF BB BF` + `253`) y **6** con `U+FEFF` **embebido** (aviso, no bloqueante; en el mensaje 39 eran 4). `quality.yml:859` lo ejecuta como gate duro. Son archivos **ajenos**: no se tocan sin GO. Reportado en 34 §7.5, 39 §3 y 40 §8. Mis 9 paths están limpios.
4. **Siguientes huecos reales medidos:** `02` **L31** Estructura sumergida, **L34** Valla de madera, **L37** Caña, **L40** Carrito y **M36** fauna ×5. Marcas **obsoletas**: L30 Palanca y L39 Cangrejo (ya tienen GLB y generador).
5. Anotar en el acta 24 que el corpus M166-runtime suma los casos **31** (`bloque_tallado`, −8) y **32** (`dintel_caido`, −2).
