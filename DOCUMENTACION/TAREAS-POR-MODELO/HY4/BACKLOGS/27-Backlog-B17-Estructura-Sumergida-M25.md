# Acta 27 — B17/L31: Estructura sumergida parcial (marea), M25

**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-08 02:22:42 -0300
**Canal:** mensaje 43 · **Log:** 2372
**Origen:** `02-Backlog-Pendientes-Assets.md` **L31**, `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` **L187** y `DOCUMENTACION/TAREAS-POR-MODELO/HY4/25-Ruinas/checklist.md` **L20**; tomado en el mensaje **42** tras el acuse **41** sin GO.
**Estado:** **EJECUTADO**. 1 generador + 1 guardia nueva + 3 `.blend` + 18 capturas + 3 hojas de contacto + 3 GLB + 3 `.glb.import`. **Cero flips**, sin QA §21.8, sin sello, sin aprobación visual. Export sin GO explícito → **a ratificar**.

> Cadena de actas: … B15 bloque tallado (`25`), B16 dintel caído (`26`), **B17 estructura sumergida (`27`)**.
> **Rótulo B17 medido antes de publicar:** no existe ningún `B17` en los backlogs de HY4, ni `Logs/2372-*`, ni `43-*` en el canal, ni acta 27. Sin colisión; no se renombra nada ya publicado.

---

## 1. Estado vivo al reingresar

Medido `2026-11-08 02:20:30 -0300`: HEAD `cff7645` (mi cierre de B16), worktree **68** entradas, **1 staged ajeno** (`Mensajes entre modelos/Glyph Cluster/REPORTES-Prueba-Paralela/reporte_glyph_cluster_economia_2026-11-08.md`), **454** GLB trackeados. Pool de logs encabezado por **2372** (2368/2370 de Hy3, 2371 de DS; ajenos). Canal HY4: máximo real **42**, **sin mensaje nuevo** de la directora después del **41** → **no hay PRIMERA INSTANCIA pendiente** (el 41 se respondió en el 42). Canal por `max(real)+1 = 43`; pool de canal (684 B) intacto. **Aviso de discrepancia nº 53** (mismo ciclo B17, ya reportado en el 42).

**Numeración cerrada sin deuda:** se midió el head **justo antes** de reservar (`2372`), se consumió con `reservar_log.py --reservar` (pool → `2373`) y el log **2372 se escribe en el mismo turno**. No se repite la anomalía del 2369 (número consumido y log ausente). El pool **no se commitea**.

El **#41** dice sólo `Recibido. Procesado.`: sin GO, sin definiciones, sin prioridad, sin objeciones y sin ratificación de B15/B16. Cabecera `2026-11-08 03:45` vs mtime `00:45:48 -0300` → desfase de reloj ~3 h, mismo patrón. Los tres exports quedan **a ratificar**; la **COLA ACTIVA** sigue vacía (recordatorios 518/519/520 de Hy3, ajenos).

## 2. SEGUNDA INSTANCIA

`07` sigue sin reposición: T-01a..T-01d y T-02 ejecutados sin flips, T-03 **CIEGO**, T-04 referencia fantasma. El mensaje **42** midió qué `[ ]` de `02` carecen de artefacto y tomó **L31** (0 GLB, 0 generador, 0 `.blend` con `sumerg`/`marea`). Alcance **asset-only Blender**, mismo carril que B10-bis (acta 18), acta 19, B15 (acta 25) y B16 (acta 26). No se tocó integración Godot, `07`, ni archivos de otro módulo.

## 3. Spec MEDIDA: el asset **no está en el catálogo**

| fuente | contenido | consecuencia |
|---|---|---|
| `DOCUMENTACION/25-Ruinas/plan-actual/03-Diseno.md` | catálogo de **40 piezas** + tabla de **13 ensamblajes**; **no** contiene `estructura sumergida`, `sumergida` ni `marea` | todas las cotas son **decisión de autoría documentada**, no valor de spec |
| pieza 16 `columna` 1x1x3 | fija **1 voxel = 1,00 m** | criterio del acta 19, reutilizado en B15/B16 |
| pieza 12 `arco` 2x2 + pieza 9 `muro_vano` 1x2 | **ANCHO_PORTICO = 2,00 m** | pórtico de 2 voxels |
| pieza 1 `suelo_losa` 1x1 | **FONDO = 1,00 m** | no se inventa un segundo espesor |
| pieza 6 `muro_recto` 1x2 | **ALTO_EMERGIDO = 2,00 m** | altura emergida |
| pieza 3 `suelo_losa_intermedia` 1x0.5 | **MAREA = +0,50 m** sobre el apoyo (`0,545`) | la marea sube **exactamente media losa** |
| pieza 22 `escalera_recta` (3 peldaños, sube 1 voxel) | plataforma 0,20 m + peldaños 0,10/0,20/0,30 | los 3 quedan **bajo** la marea: eso es «parcialmente sumergida» |

**Lectura de «sumergida parcial» con 4 señales positivas** — ninguna es un plano de agua transparente que el exportador convertiría en un alpha-sort roto: (1) plataforma + 3 peldaños + fragmento con **piedra húmeda** (más oscura) por debajo de `0,545`; (2) **banda de algas** horizontal a la **misma** cota en **ambas** columnas, que las **envuelve** (0,36 m > 0,30 m de sección) y **cruza** el plano (`0,515..0,575`) → la línea de agua es **geometría real**, no pintura; (3) **dos columnas de altura distinta** que emergen (2,145 / 1,245) con un **dintel hundido** apoyado en la corta y empotrado en la larga; (4) **algas colgantes** desde la banda hacia la zona sumergida.

**Huella del conjunto 2,29 × 1,45 m > pórtico 2,00 × 1,00 m** por el fragmento y el vuelo de la banda. Exigir `fp == 2,00×1,00` sería **consagrar una mentira**: la guardia mide las esquinas **de la plataforma** y exige `min(fp_x, fp_y) > 0,30` (E-50). `min_toca` **no** se relajó: `toca=20`.

## 4. Autoría headless

`tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/crear_estructura_sumergida_lowpoly.py` — Blender 4.2 `-b --factory-startup --python-exit-code 1` (evita el **falso verde RC=0** con `AssertionError` oculto, medido en la mansión M18-BIS).

- **4 materiales** exactos → la poda BAJA a 4 es un **NO-OP**; ninguna pieza de identidad se blanquea. **8 objetos `SM_`** en ALTA.
- **4 críticas `_NOFUNDIR`**: `Portico_Izq`, `Portico_Der` (Piedra), `Base` (Humedo), `Bandas` (Algas, 2 bandas unidas). Quedan **2 grupos no críticos** (algas colgantes 2 cajas → 1 malla; tallado 2 glifos → 1 malla) ⇒ **MEDIA/BAJA = 6 objetos**, exactamente el techo BAJA (`<= 6`). El decimate `0,70` actúa **sólo sobre el relieve**, nunca sobre la silueta portante **ni sobre la banda de marea**. No se modificó `generar_variante.py` (mecanismo documentado `es_critica()`).
- Reglas aplicadas: E-12 `Z_APOYO=0,045`; E-24 `zmin_real()` sobre **vértices reales**; E-50 huella > 0,30 m en X e Y con `min_toca` **default sin relajar**; E-44 purga de `Base_Arena`/`SOL`/`CAM_*`; E-42 materiales **por caras**; E-68 `caja()/scale` = dimensión final; E-27 **sin parents** para que `asentar()` mueva todas las piezas por igual.
- **Guardia positiva de autoría embebida:** la banda **atraviesa** la cota de marea, ambas columnas la cruzan, hay geometría con **masa real** por debajo **y** por encima, y las 4 esquinas de la plataforma están apoyadas en `z=Z_APOYO` (no flota).

Mediciones ALTA, re-leídas del log de corrida (`BLENDER_RC=0`, `py_compile RC=0`): `ASENTADO z_min 0.0450 -> 0.0450`; `HUELLA toca=20 footprint=2.29 x 1.45`; `MERGE_PREVISTO criticas=4 grupos=2 -> 6 objetos`; `ALTURA_REAL z=[0.0450..2.1450] alto=2.1000 | HUELLA=2.290x1.450`; `MAREA cota=0.5450 | banda z=[0.5150..0.5750] | niveles_x=4`; `SUMERGIDA_PARCIAL vertices bajo marea=64 sobre marea=56`; `DINTEL_HUNDIDO z=[1.3450..1.5650] x=[-0.85..0.85] 8/8 esquinas`.

Lección re-aplicada de B15/B16: **`chk_asset.py` mide COSTE, no FORMA**. Dos BAJA «OK» de B15 escondían el panel colapsado en cuña; acá la silueta portante se protege **antes** de derivar variantes, no después de ver el defecto.

## 5. Coste M166 y revisión visual

`chk_asset.py` bajo Blender 4.2 sobre los 3 `.blend` (**un verde no se hereda**):

| LOD | obj | tris | mats | veredicto |
|---|---|---|---|---|
| ALTA | 8 | 192 | 4 | **OK ALTA** (`NO MEDIA` / `NO BAJA` en el archivo fuente son **esperados**) |
| MEDIA | 6 | 192 | 4 | OK en los perfiles aplicables |
| BAJA | 6 | **176** | 4 | OK en los perfiles aplicables |

Los tres: `z_min=0,0450`, `bbox X [-1,000 .. 1,290] ancho=2,290`, `Y [-0,950 .. 0,500] prof=1,450`, `Z [0,045 .. 2,145] alto=2,100`. **18 PNG** (6 azimuts × 3 LOD) + **3 JPG** de contacto. Revisión visual **de autoría** (no QA ni sello): ALTA y BAJA limpias en los 6 azimuts — plataforma con 3 peldaños, dos columnas de altura distinta, dintel con 2 glifos, banda de algas al **mismo nivel** en ambas columnas, algas colgantes; sin cuña triangular, fragmento flotante, ranura oscura, agujero ni aire. **LOD real: 176 vs 192 tris.**

## 6. Export a Godot (sin GO → a ratificar)

Baseline sha256 de **454** GLB trackeados → `Temp/hy4_sumerg_baseline_glb_20261108.json`. Post-verificación: **454 entradas, 0 mutados, 0 faltantes, 3 nuevos**.

| paso | resultado |
|---|---|
| `EXPORT_DRY=1 EXPORT_MODULOS=25-Ruinas-Templos` | **3 planeados / 39 saltados / 0 errores** |
| export real | **3 exportados / 39 saltados / 0 errores** |
| dry-run de **control** posterior | **0 planeados / 42 saltados / 0 errores** → idempotente |

| LOD | bytes | sha256 (12) |
|---|---|---|
| `alta/25-Ruinas-Templos_estructura_sumergida.glb` | 20 936 | `1894df5a351c` |
| `media/25-Ruinas-Templos_estructura_sumergida.glb` | 18 156 | `75463e6d1570` |
| `baja/25-Ruinas-Templos_estructura_sumergida.glb` | 18 084 | `3886b7322e4a` |

3 `.glb.import` generados con Godot 4.7.2 `--headless --import`, uid `cggwb32ueanua` / `dgln12op2n444` / `daajaths7spu3`. Quedan **locales y sin versionar**: `game/isla-ancestral/.gitignore:3` ignora `*.import`; `*.blend` (`.gitignore:228`) y `**/capturas/` (`.gitignore:104`) también.

## 7. Runtime: deriva `.blend` → GLB = **0** (dato, no check)

Sonda `Temp/hy4_sumerg_glb_probe.py` decodificando **BIN real** (índices + `POSITION` + matrices column-major, glTF **Y-up**):

| magnitud | ALTA / MEDIA | BAJA |
|---|---|---|
| tris / vértices / materiales | 192 / 384 / 4 | **176 / 362 / 4** |
| `y` (altura) | `[0,0450, 2,1450]` | `[0,0450, 2,1450]` |
| `x` | `[-1,0000, 1,2900]` | `[-1,0000, 1,2900]` |
| `z(glTF)` | `[-0,5000, 0,9500]` | `[-0,5000, 0,9500]` |
| vértices en zona vacía `0,60..1,20` | **0** | **0** |
| plataforma esquinas apoyadas | 4/4 | 4/4 |
| banda `x=±0,70` en planos `0,515/0,575` | 24 | 24 |
| masa bajo / sobre marea | 192 / 168 | 189 / 158 |

**Deriva `.blend` → GLB = 0 en los 3 LOD** (`192/192/176 → 192/192/176`). Es el **primer caso del corpus sin sobreconteo** por polígonos inválidos tras merge/decimate (fenómeno B12/B13: `calc_loop_triangles()` sobre malla no validada vs. exportador glTF que valida antes de escribir). Se publica como **dato**, nunca como check: la regla del acta 24 es medir M166 sobre el **GLB de runtime**, no sobre el `.blend`. Sugerencia para el acta 24: **caso 33** del corpus.

## 8. Guardia nueva de FORMA sobre el GLB de runtime

`tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/verificar_estructura_sumergida.py` — Python puro, sin `bpy`, autocontenido. Decodifica **vértices reales del BIN** que Godot consume (no las 8 esquinas del AABB), matrices `M[c*4+r]`, traslación en `M[12..14]`, glTF Y-up. Cotas **calibradas en el BIN** con `Temp/hy4_sumerg_glb_probe.py`, **no heredadas** de `dintel_caido` ni de `bloque_tallado`. **18 checks × 3 GLB + 2 globales = 56**; `CHECKS_MINIMOS=56` / `BLOQUES_MINIMOS=3` fijados **después** de medir el piso con la constante en 0.

**Trampas evitadas a propósito:**

- Los nombres de malla dentro del GLB son `Cube`, `Cube.001`, … (el exportador usa el **datablock**, no el objeto `SM_`) → **ninguna** aserción de identidad depende de nombres: todas son **geométricas por coordenadas**.
- La inyección usa la **inversa general 3×3 de la parte lineal (Cramer)**, no la inversa diagonal (trampa documentada en B15).
- La señal es **positiva** (banda envolviendo ambas columnas, masa bajo **y** sobre la marea, 4 esquinas apoyadas, 0 vértices en la zona vacía), no sólo la negación del literal del defecto.
- Un check que **falla** sigue contando como **ejecutado**; CIEGO = menos bloques/checks que el piso medido (exit 3), no un «0 fallos» heredado.
- La deriva `.blend` → GLB se publica como **dato**, nunca como check (B13).

**Corrección de código muerto en esta vuelta:** el camino `--volcar` referenciaba `niveles_con_masa_cache`, una variable que **nunca se calculaba**, por lo que el diagnóstico no ejercitaba ningún dato real. Se eliminó y se computa `d['niveles']` con `Counter(round(p[1], 4) for p in puntos)`. Es la misma familia del falso verde que esta guardia existe para evitar: un camino que «pasa» porque no ejecuta nada.

Los **cuatro caminos fueron re-ejecutados en esta vuelta** (el verde del ciclo interrumpido no se heredó):

| camino | comando | resultado | exit |
|---|---|---|---|
| PISO | `--piso 0` | `56/56/0`, 3 bloques | 0 |
| VERDE | sin flags | `56/56/0`, `PISO=56` | 0 |
| ROJO | `--inyectar` | `56/53/3`; **66 vértices mutados** en copia `Temp/hy4_sumerg_rojo_20261108.glb`; fallan **C9** (plataforma 0/4 esquinas), **C11** (banda 0/16), **C17** (1 vértice en `y=0,8` → cuña/flotante) | 1 |
| CIEGO | `--solo <alta>` | 20 checks, 1 bloque, FAIL G1/G2 | 3 |

La inyección reproduce el **colapso en el BIN** sobre una copia en `Temp/`; los GLB publicados conservan su sha (`1894df5a351c` / `75463e6d1570` / `3886b7322e4a`). `py_compile` RC=0 sobre ambos scripts.

## 9. Formatos y gate §28

| archivo | formato |
|---|---|
| `Logs/2372-…md` | **ASCII puro** (0 bytes > 127) + **CRLF** + sin BOM |
| mensaje 43, acta 27 | UTF-8 / LF, sin BOM, sin `U+FFFD`, 0 CR |
| ambos scripts | UTF-8 / LF, sin BOM, 0 CR, sin `U+FFFD`, `py_compile` RC=0 |

**Incidente propio, publicado (no ocultado).** La primera normalización del log 2372 usó `mapa.get(c, '?')` para transliterar tildes/ñ; el default `'?'` se aplicó a **todos** los caracteres ASCII normales y el archivo quedó en **15 328 bytes de `?`**. «0 bytes > 127» y «sin BOM» daban **VERDE sobre el archivo destruido**; lo delató `CRLF=0`, no el chequeo de formato. Se reescribió en ASCII puro y se verifica **por contenido** (cabecera, 11 secciones, firma, 7 señales positivas) además de por contadores: **16 374 B, 307 CRLF, 0 LF/CR sueltos, 3 `?` legítimos** (los del propio texto del incidente). Lección: toda afirmación de formato debe incluir una **señal positiva de contenido**; el default de un mapa de transliteración es `mapa.get(c, c)`. Misma familia del falso verde que la guardia de B17 existe para evitar, y emparentada con el código muerto de `--volcar` corregido en §8.

**Gate §28 re-medido: ROJO en HEAD.** `py -3.13 scripts/verificar_bom.py` → **RC=1**. Bloqueante: `Mensajes entre modelos/DS-V4.1-Flash-Opencode/.ultima-revision-ds.txt` (6 B, `EF BB BF` + `253`); además avisos por `U+FEFF` embebido en reportes ajenos (Glyph Cluster, Reflection-Beam, Crouton Alpha). `quality.yml:859` ejecuta ese verificador como **gate duro**. Archivos **ajenos**: sin tocar y sin GO. Reportado en 34 §7.5, 39 §3, 40 §8, 42 §4 y 43 §9. Mis 9 paths están limpios.

## 10. Entregables y disciplina

| path | destino |
|---|---|
| `Mensajes entre modelos/HY4/42-…-acuse-41-segunda-instancia-l31-estructura-sumergida.md` | acuse del ciclo anterior, **sin versionar hasta hoy** |
| `Mensajes entre modelos/HY4/43-…-b17-estructura-sumergida-m25.md` | canal (REGLA CERO) |
| `Logs/2372-HY4-B17-ESTRUCTURA-SUMERGIDA-M25_2026-11-08_02-22-42.md` | log formal, ASCII puro + CRLF + sin BOM |
| `DOCUMENTACION/TAREAS-POR-MODELO/HY4/BACKLOGS/27-Backlog-B17-Estructura-Sumergida-M25.md` | esta acta |
| `tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/crear_estructura_sumergida_lowpoly.py` | generador |
| `tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/verificar_estructura_sumergida.py` | guardia |
| `game/isla-ancestral/assets/3d/{alta,media,baja}/25-Ruinas-Templos_estructura_sumergida.glb` | 3 GLB de runtime |
| `.workbuddy-ai/memory/2026-11-08.md` | append (ignorado por git) |

**Commit selectivo de 9 paths**, `add` + `commit` encadenados con **pathspec**, sin `--amend`, sin push, sin `git add -A`. El **staged ajeno** de Glyph Cluster queda **fuera** del commit y sigue en stage. Pool de logs **no** se commitea. Los `.blend`, `capturas/` y `.glb.import` están ignorados y quedan en disco sin versionar. Sondas, baseline JSON, logs de corrida y GLB inyectado en `Temp/` **conservados**, no borrados. Entradas ajenas del worktree (Hy3, DS, Crouton Alpha, Glyph Cluster, Reflection-Beam, `Logs/NUMEROS_DISPONIBLES.txt`) intactas.

Sin flips, sin QA §21.8, sin sello, sin aprobación visual final, sin GO.

## 11. Decisiones abiertas para la directora

1. **Flip** de `02` **L31**, `CHECKLIST-OBJETOS-BLENDER.md` **L187** y `25-Ruinas/checklist.md` **L20** — propuesto, **no aplicado**; medido hoy, los tres siguen en `[ ]`. También siguen `[ ]` **L28/L176** (B15), **L29/L177** (B16), **L26/L174** y **L27/L175** (B10-bis / acta 19). **L30/L178** y **L39** son marcas **obsoletas**: ya tienen GLB y generador.
2. **Ratificación** de los exports sin GO de B15/L28, B16/L29 y **B17/L31**; reposición de la **COLA ACTIVA** y de P1..P7; definición de T-02 (integración), T-03 (CIEGO), T-04 (fantasma) y Q2.
3. **§28 en ROJO en HEAD**: requiere GO por ser archivo ajeno. Los 9 paths de esta vuelta están limpios.
4. **Con L31 cerrado, M25 queda sin huecos reales de asset**: lo que resta en M25 son marcas obsoletas por flip. Siguientes huecos reales medidos en `02`: **L34** Valla de madera, **L37** Caña, **L40** Carrito y **M36** fauna ×5. `07` sigue con 17 `[ ]`.
5. Anotar en el **acta 24** el **caso 33** del corpus M166-runtime: `estructura_sumergida`, **deriva 0 en los 3 LOD**, primer caso sin sobreconteo por polígonos inválidos.
