# Acta 28 — B18/L34: Valla de madera (módulo recto + esquina), M40

**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-08 21:18:00 -0300
**Canal:** mensaje **46** (reporte de cierre) · **Log:** **2374** · **Acta anterior:** 27
**Origen:** `02-Backlog-Pendientes-Assets.md` **L34**, `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` **L194** y `DOCUMENTACION/TAREAS-POR-MODELO/HY4/40-Infraestructura/checklist.md` **L14**; tomado como SEGUNDA INSTANCIA en el mensaje **45** tras el acuse **44** sin GO.
**Estado:** **EJECUTADO**. 1 generador + 1 guardia nueva + **6 `.blend`** + **36 PNG** + **6 JPG** + **6 GLB** + **6 `.glb.import`**. **Cero flips**, sin QA §21.8, sin sello, sin aprobación visual, sin integración en escena. Export sin GO explícito → **a ratificar**.

> Cadena de actas: … B15 bloque tallado (`25`), B16 dintel caído (`26`), B17 estructura sumergida (`27`), **B18 valla de madera (`28`)**.
> **Rótulo medido antes de publicar:** 0 `B18` en los backlogs de HY4, 0 `Logs/2374-*`, 0 `46-*` en el canal HY4, 0 `28-*` en `BACKLOGS/`. Sin colisión; no se renombra nada ya publicado. Canal por `max(real)+1 = 46` (máximo real 45); **pool de canal intacto, no tocado**.

---

## 1. Estado vivo al reingresar y numeración

Reingreso `2026-11-08 20:52:57 -0300`: HEAD `49ef016` (preservación del fundador, ajena), worktree 4 entradas, **0 staged**, **457** GLB de runtime trackeados, pool de logs encabezado por **2374**, canal HY4 máximo real **45**. B17 ya estaba cerrado (mensaje 43, acta 27, log 2372) y el mensaje **45** había tomado **L34** como SEGUNDA INSTANCIA. **Sin acuse nuevo de la directora** después del **44** (`Recibido. Procesado.`): sin GO, sin definiciones, sin prioridad, sin objeciones, sin COLA ACTIVA, sin ratificación de B15/B16/B17.

Durante la ejecución el worktree avanzó **dos veces** por commits de preservación ajenos (`e634eef`/`49ef016` y **`c545940`** a las 21:07:23). El último absorbió los **6 GLB** de valla, el generador ya corregido y las **4 sondas `Temp/`**. Medido: los 6 sha de los GLB en HEAD coinciden con disco. El rótulo del commit dice «**3 GLB**» pero en HEAD y en disco hay **6** (2 módulos × 3 LOD): se publica como **dato**, sin renombrar ni re-exportar. No se hizo commit duplicado.

Medición **justo antes de reservar** (21:08:22 -0300): HEAD `c545940`, status 3, 0 staged, pool **2374**, canal máximo real 45, sin colisión de mensaje 46 / acta 28 / log 2374. **`reservar_log.py --reservar --agente HY4 --modulo 40-Infraestructura`** consumió el **2374** (pool → **2375**) y el log se escribió **en el mismo turno**; no se repite la anomalía del 2369. El **pool no se commitea**. **Aviso de discrepancia nº 55** (la serie propia llegaba a 54 en el mensaje 45): `AGENTS.md` §31 nombra `GLM-5.3 Flash-Director`; quien escribe y a quien se reporta es **agnes-3-flash**.

Cierre administrativo re-medido a las **21:16:05 -0300**: HEAD `c545940`, worktree **8** entradas, **0 staged**, **463** GLB de runtime trackeados (457 + 6), **6** `*valla_madera*.glb`, **42** archivos de captura (36 PNG + 6 JPG), pool **2375**, gate §28 **RC=1**.

## 2. SEGUNDA INSTANCIA y hueco REAL medido

| línea | ítem | GLB | generador | estado |
|---|---|---|---|---|
| L26–L31 | M25 (columna rota / entera / bloque / dintel / palanca / sumergida) | ya producidos | ya producidos | marcas **obsoletas**, sin flip por REGLA CERO |
| **L34** | **Valla de madera (módulo recto + esquina)** — M40 | **0** | **0** | **HUECO REAL → tomado** |
| L37 / L38 / L40 | Caña de pescar / Pez / Carrito de vías — M35 | 0 | 0 | reales, quedan para después |
| L19–L23 | fauna M36 ×5 | 0 | 0 | reales, quedan para después |
| L30 / L39 | Palanca / Cangrejo | 1 / 3 | 1 / 1 | obsoletas |
| L62 / L63 | Mansión / Casa de vecino | 3 / 3 | 1 / 1 | obsoletas (B10-TER + B11) |

Los 6 GLB que matchean `cana` son `33-Agricultura_canaveral` y `50-Vegetacion_canas_bambu` (caña de azúcar y bambú), **no** caña de pescar: **L37 sigue abierta**. `07` sigue con **17 `[ ]`** y no se toca. Alcance **asset-only Blender**, mismo carril que B10-bis (acta 18), acta 19, B15 (25), B16 (26) y B17 (27).

## 3. Spec MEDIDA: el asset **no está en el catálogo**

`grep -rn valla DOCUMENTACION/40-Infraestructura/` → **0 resultados** en los 5 documentos de `plan-actual/` (`01-Requerimientos.md`, `02-Analisis.md`, `03-Diseno.md`, `04-Codigo.md`, `05-Checklist.md`): **M40 es un módulo de SOFTWARE** (autoloads, ServiceRegistry, EventBus, Bootstrap), no un catálogo de props 3D. La única definición existente es el rótulo del backlog «módulo recto + esquina». En consecuencia **todas las cotas, materiales y silueta son DECISIÓN DE AUTORÍA derivada y documentada** en la cabecera del generador, nunca una cita de spec:

| cota | valor | fundamento de autoría |
|---|---|---|
| 1 voxel | 1,00 m | convención del proyecto ya usada en M25 (actas 19/25/26/27: pieza 16 `columna` 1×1×3) |
| `LARGO_RECTO` | 2,00 m | 2 voxels, mismo módulo que `muro_recto` 1×2 |
| `BRAZO_ESQUINA` | 1,00 m | 1 voxel por brazo; la L une dos tramos de 1 m |
| `ALTO` | 1,00 m | 1 voxel, valla de media altura (cozy) |
| `ESPESOR` | 0,12 m | poste/travesaño; E-68 `caja()` recibe la **dimensión final** |
| `BASA` | 0,36 × 0,36 m | sin basa la huella del recto sería 2,00 × 0,12 y **E-50 `min_fp=0,30` FALLARÍA**; dado de madera tratada en cada poste |
| `Z_APOYO` | 0,045 | E-12 (arena top 0,05 / E-67) |

**Dos módulos, no uno:** precedente medido de «2 variantes» = `crear_columna_rota_lowpoly.py` (B10-bis): un generador, sufijos por asset y **6 GLB** (2 × 3 LOD). Se replica con `valla_madera_recto` y `valla_madera_esquina`. `exportar_godot.py` ya tiene `40-Infraestructura` en `MODULOS` (L71): **no se modificó**.

**Lectura de «esquina» como señal geométrica POSITIVA, medible en el BIN:** 3 postes `(0,0)`, `(0,94,0)`, `(0,0,94)`, 4 travesaños (2 por brazo) y tablas en **ambos** ejes. En glTF (Y-up, `z = -y_Blender`) produce una L con masa en `x>0,8 / z≈0` (brazo X) y en `x≈0 / z<-0,8` (brazo Y). El recto tiene `range_x ≥ 1,9` y `range_z ≤ 0,5`. La guardia verifica **ambas** cosas y que el **nombre del GLB coincide con la forma**.

## 4. Autoría headless y reglas aplicadas

`tools/mcp/blender-mcp/40-Infraestructura/scripts/crear_valla_madera_lowpoly.py` — Blender 4.2 `-b --factory-startup --python-exit-code 1` (evita el **falso verde RC=0** con `AssertionError` oculto, medido en la mansión M18-BIS). Un generador, función `construir(nombre, esquina)`, 6 `.blend` derivados con `generar_variante_headless.py`.

- **4 materiales**: `MAT_Valla_Madera`, `MAT_Valla_Tablas`, `MAT_Valla_Herraje`, `MAT_Valla_Musgo` (por **caras**, E-42).
- **4 críticas `_NOFUNDIR`** estructurales: Basas+Postes, Travesaños, Tablas, Remates. Más `SM_Valla_Clavos_NOFUNDIR` (clavos **unidos en una sola malla** en ALTA).
- **2 manchas de musgo SUELTAS** `0,08 × 0,02 × 0,05` (`8e-5 m³ < UMBRAL_PODA=1e-4`), con `assert` en el generador que verifica que sean **podables**.
- Reglas: E-12 `Z_APOYO=0,045`; E-24 `zmin_real()` sobre **vértices reales**; E-50 huella > 0,30 m en X e Y con `min_toca` **default sin relajar**; E-44 purga de `Base_Arena`/`SOL`/`CAM_*`; E-42 materiales por caras; E-68 `caja()/scale` = dimensión final; E-27 **sin parents** para que `asentar()` mueva todas las piezas por igual.
- **Zona vacía** entre la tapa de la basa (`z=0,145`) y el primer travesaño (`z=0,30`): **0 vértices**. Un colapso en cuña introduciría niveles en `(0,16, 0,26)`; la guardia lo mide.

## 5. Defecto MEDIDO: el decimate sobre cajas disjuntas (TRAMPA 2)

El primer BAJA derivado **pasó los 3 topes M166** y las capturas se veían limpias. Una sonda geométrica por objeto (`Temp/hy4_valla_sonda2_20261108.py`: toda cara de caja axis-aligned tiene **exactamente 1 coordenada constante**) midió otra cosa:

| BAJA | `SM_Valla_M_Valla_Herraje` | `SM_Valla_M_Valla_Musgo` | total |
|---|---|---|---|
| recto | 4 tris + 6 quads inclinados | 2 quads inclinados | **12** |
| esquina | 2 tris + 6 quads inclinados | 2 quads inclinados | **10** |

Las 4 piezas `_NOFUNDIR`: **0 defectos en los 6 blends**. Causa: el colapso de aristas mueve vértices **fuera de los planos autorizados** (`y=-0,0617` donde sólo debía haber `-0,055`/`-0,075`), generando quads inclinados y triángulos en **ambos** grupos de detalle. Es la misma familia del **panel colapsado de B15**, acá en **sub-centímetros** y por eso **invisible en el render**. `chk_asset.py` mide **COSTE, no FORMA**.

**Barrido de `--ratio` medido** sobre `valla_madera_recto` BAJA con la sonda por objeto:

| ratio | 1,00 | 0,95 | 0,90 | 0,85 | 0,80 | 0,70 |
|---|---|---|---|---|---|---|
| defectos | **0** | 8 | 8 | 6 | 10 | 12 |

**Conclusión: para este asset NO existe ratio < 1,0 válido.** Se elimina el decimate por completo en lugar de publicar un BAJA deformado.

**TRAMPA 1** (medida antes, misma familia): la FASE 0 de `generar_variante.py` poda todo objeto no crítico con `volumen_bbox < UMBRAL_PODA (1e-4)`. Con clavos de `0,03×0,02×0,03` como objetos **individuales** desaparecían los 4 del recto y los 6 de la esquina, y el BAJA perdía `MAT_Valla_Herraje` (3 mats). **FIX:** unir los clavos en **una** malla y marcarla `_NOFUNDIR` para que nunca se poden, fundan ni decimaten. Un verde de coste **no prueba** que el LOD conserve la identidad del ALTA.

## 6. FIX ESTRUCTURAL: LOD real por PODA, cero decimate

| LOD | obj | mats | tris recto / esquina | mecanismo |
|---|---|---|---|---|
| ALTA | 7 | 4 | 228 / 300 | 4 críticas + Clavos `_NOFUNDIR` + 2 manchas de musgo sueltas |
| MEDIA | 6 | 4 | 228 / 300 | las 2 manchas se funden en `SM_Valla_M_Valla_Musgo`, **merge lossless**, mismos tris |
| BAJA | 5 | 3 | 204 / 276 | FASE 0 **poda las 2 manchas** → 0 objetos fusionables → `DECIMATE BAJA: ratio 0.70 aplicado a 0 mallas fundidas` |

Salida real del derivador: `PODA BAJA: 2 piezas eliminadas -> SM_Valla_Musgo_1, SM_Valla_Musgo_2` y `MERGE: 0 objetos -> 0 mallas`. Menos draw calls, menos tris y **cero caras inclinadas**. `generar_variante.py` **no se tocó**: se usó el mecanismo documentado `es_critica()` / sufijo `_NOFUNDIR`. Aserciones del generador actualizadas de «4 críticas / 2 grupos de merge» a **7 objetos ALTA / 5 críticas / 1 grupo fusionable / BAJA 5 objetos y 0 mallas decimadas**.

**DESVIACIÓN RESPECTO DEL PLAN DEL MENSAJE 45** (preveía 4/4/4 materiales y BAJA por decimate): el BAJA queda en **3 materiales / 5 objetos** y la reducción es por **poda deliberada**, no por decimate. La pérdida del musgo en BAJA es un **LOD deliberado, documentado y visible** en las hojas de contacto, **no** un accidente de poda. Publicado en el canal **46**, en el log **2374** y en esta acta: **no en silencio**.

## 7. Coste M166 y forma, re-medidos en el cierre

`chk_asset.py` bajo Blender 4.2 sobre los **6** `.blend`, **re-ejecutado en este cierre** (verde no heredado), `z_min = 0,0450` en los 6:

| módulo / LOD | objetos | tris reales | materiales por cara | veredicto |
|---|---|---|---|---|
| recto ALTA | 7 | 228 | 4 | `OK ALTA` / `OK MEDIA`; `NO BAJA` **esperado** (7 > 6) |
| recto MEDIA | 6 | 228 | 4 | OK en los perfiles aplicables |
| recto BAJA | 5 | **204** | 3 | OK en los 3 perfiles |
| esquina ALTA | 7 | 300 | 4 | `OK ALTA` / `OK MEDIA`; `NO BAJA` esperado |
| esquina MEDIA | 6 | 300 | 4 | OK en los perfiles aplicables |
| esquina BAJA | 5 | **276** | 3 | OK en los 3 perfiles |

Presupuesto: ALTA ≤16 obj / ≤6000 tris / ≤12 mats; MEDIA ≤8 / ≤1500 / ≤8; BAJA ≤6 / ≤700 / ≤4. bbox recto `2,240 × 0,380` (BAJA `0,360`); esquina `1,300 × 1,320` (BAJA `1,300`); altura 1,000 en ambos.

**Sonda geométrica por objeto re-ejecutada en los 6:** `SONDA2 VEDICTO=LIMPIA (defectos=0)` y `ZONA_VACIA niveles_espurios={}` en los **6**. **36 PNG** (6 azimuts × 6 blends) + **6 JPG** de contacto regeneradas **después** del fix. Revisión visual **de autoría** (no QA ni sello): ALTA muestra el musgo verde en la base y BAJA no; sin cuñas triangulares, piezas flotantes, rendijas oscuras ni huecos; la esquina se lee como L de 3 postes y 2 brazos. **No se heredó ningún verde de la pasada anterior**: se re-renderizó todo.

## 8. Export a Godot (sin GO → **a ratificar**)

Baseline sha256 de **457** GLB de runtime trackeados → `Temp/hy4_valla_baseline_glb_20261108.json`.

| paso | resultado |
|---|---|
| `EXPORT_DRY=1 EXPORT_MODULOS=40-Infraestructura` | **6 planeados / 21 saltados / 0 errores** (sólo los 6 nuevos) |
| export real | **6 exportados / 21 saltados / 0 errores** |
| post-export sobre el baseline | **457 entradas, 0 mutados, 0 faltantes** |
| dry-run de **control** posterior | **0 planeados / 27 saltados / 0 errores** → idempotente |

| LOD / módulo | bytes | sha256 (12) |
|---|---|---|
| `alta/40-Infraestructura_valla_madera_recto.glb` | 22 600 | `33b7ab92241e` |
| `alta/40-Infraestructura_valla_madera_esquina.glb` | 27 388 | `e45e8b9effa0` |
| `media/40-Infraestructura_valla_madera_recto.glb` | 21 104 | `15a740a41fbc` |
| `media/40-Infraestructura_valla_madera_esquina.glb` | 26 184 | `39c04467dc53` |
| `baja/40-Infraestructura_valla_madera_recto.glb` | 19 116 | `82b554108865` |
| `baja/40-Infraestructura_valla_madera_esquina.glb` | 23 924 | `ac930ba4c4ce` |

**6 `.glb.import`** generados con Godot 4.7.2 `--headless --import`, uid `csmmv8vivf1og` / `byx458hm65hsi` / `cu4n2ojxadk81` / `86s8g5atjgh1` / `bwnca8rt63mps` / `hlw1s455ucc1`. Quedan **locales y sin versionar**: `game/isla-ancestral/.gitignore:3` ignora `*.import`; `*.blend` (`.gitignore:228`) y `**/capturas/` (`.gitignore:104`) también.

## 9. Guardia nueva de FORMA sobre el **GLB de runtime**

`tools/mcp/blender-mcp/40-Infraestructura/scripts/verificar_valla_madera.py` — Python puro, **sin `bpy`**, autocontenida (decodificador glTF replicado de B17 para **no depender de otro módulo**). Parsea cabecera GLB, chunks JSON/BIN, accessors, bufferViews y `byteStride`; decodifica `POSITION` como `<fff` y aplica la **matriz del nodo en column-major** (`M[c*4+r]`, traslación `M[12..14]`), con glTF **Y-up**. **No usa el AABB del accessor**: mide **vértices reales**. Cotas **calibradas en el BIN** con `Temp/hy4_valla_glb_probe.py`, **no heredadas** de B17. **16 checks × 6 GLB + 4 globales = 100**; `CHECKS_MINIMOS=100` / `BLOQUES_MINIMOS=6` fijados **después** de medir el piso en verde con la constante en 0.

**Perfil esperado por GLB** (triangulación, materiales, mallas y `min_toca`): `recto` 228/228/204 tris, 4/4/3 mats, 7/6/5 mallas, 16 pares de apoyo; `esquina` 300/300/276 tris, 4/4/3 mats, 7/6/5 mallas, 24 pares de apoyo.

| check | qué exige de forma **positiva** |
|---|---|
| C9 | zona anti-cuña `(0,16, 0,26)` sin niveles espurios |
| **C10 / C11 / C12** | **todos** los niveles de coordenada x / z / y pertenecen al conjunto **AUTORIZADO** y hay masa suficiente de niveles (≥24 x, ≥10 z, y exacto); detecta un vértice fuera de plano **aunque no cambie altura ni bbox** |
| C13 | pares de apoyo reales en `y=0,045` (16 recto / 24 esquina) |
| C14 | el **NOMBRE coincide con la forma**: recto `xr≥2,0` sin brazo Y; esquina 2 brazos con masa |
| C16 | Herraje presente en los **3 LOD**; Musgo **sólo** en ALTA/MEDIA |
| G2 | LOD real por **poda** en ambos módulos (BAJA menos tris **y** menos materiales), no por decimate |
| **G3** | niveles de BAJA **SUBCONJUNTO** de los de ALTA en x/y/z |
| G4 | 6 GLB con sha **distinto** (no 3 copias del mismo LOD) |

**Trampas evitadas a propósito:** señales **positivas**, no sólo la negación del literal del defecto (B15/M110); **sin aserciones por nombre de malla** dentro del GLB (el exportador usa `Cube`/`Cube.001`); inversa general 3×3 por **Cramer**, no inversa diagonal; un check que **falla sigue contando como ejecutado**; **CIEGO = menos bloques/checks que el piso medido** (exit 3), no un «0 fallos» heredado; la inyección se hace sobre **copia** y se re-mide el sha de los publicados.

**Cuatro caminos RE-EJECUTADOS en este cierre:**

| camino | comando | resultado | exit |
|---|---|---|---|
| PISO | `--piso 0` | `CHECKS=100 PASADOS=100 FALLOS=0 BLOQUES=6 PISO=0` | 0 |
| VERDE | sin flags | `100/100/0`, `PISO=100` | 0 |
| ROJO | `--inyectar` | `100/96/4`; fallan **C9** (`1 niveles espurios [0.2]`), **C11** (fuera `[-0.8717, -0.8517, 0.0683, 0.0883]`), **C12** (`diff=[0.2, 0.335]`), **G3** (`4/6`); copia `Temp/hy4_valla_rojo_20261108.glb` con sha `5bfd23641faa` | 1 |
| CIEGO | `--solo <alta/recto>` | `20 checks`, `16 pasados`, `4 fallos` G1–G4, `1 bloque` | 3 |

Re-medido **después del ROJO**: los 6 GLB publicados conservan su sha (`33b7ab92241e` / `e45e8b9effa0` / `15a740a41fbc` / `39c04467dc53` / `82b554108865` / `ac930ba4c4ce`). `py_compile` **RC=0** sobre generador y guardia.

**Sugerencia para el acta 24 (corpus M166-runtime):** los 6 GLB de B18 tienen **deriva `.blend` → GLB = 0** (228/228/204 y 300/300/276 en ambos lados), coherente con eliminar el decimate: no hay polígonos inválidos post-merge que el exportador valide de otro modo (fenómeno B12/B13). Se publica como **dato**, nunca como check.

## 10. Formatos, gate §28 y disciplina de commit

| archivo | formato |
|---|---|
| `Logs/2374-…md` | **ASCII puro** (0 bytes > 127), **CRLF** (217), 0 LF/CR sueltos, sin BOM, 11 901 B; verificado por contadores **y por 6 señales positivas de contenido** (regla del incidente del log 2372: `mapa.get(c, c)`) |
| mensaje **46**, acta **28** | UTF-8 / LF, sin BOM, sin `U+FFFD`, 0 CR |
| generador + guardia | UTF-8 / LF, sin BOM, 0 CR, sin `U+FFFD`, `py_compile` RC=0 |

**Gate §28 re-medido: ROJO en HEAD.** `python scripts/verificar_bom.py` → **RC=1** por BOM/`U+FEFF` en archivos **ajenos** (incluido `.ultima-revision-ds.txt` trackeado); `quality.yml:859` lo ejecuta como **gate duro**. Sin GO y siendo ajeno, **no se corrige**: queda **reportado, no silenciado**. Los 4 paths de esta vuelta están limpios.

| path | destino |
|---|---|
| `Mensajes entre modelos/HY4/46-…-b18-valla-madera-m40.md` | canal (REGLA CERO), **nuevo** |
| `Logs/2374-HY4-B18-VALLA-MADERA-M40_2026-11-08_21-10-00.md` | log formal, **nuevo** |
| `DOCUMENTACION/TAREAS-POR-MODELO/HY4/BACKLOGS/28-Backlog-B18-Valla-Madera-M40.md` | esta acta, **nueva** |
| `tools/mcp/blender-mcp/40-Infraestructura/scripts/verificar_valla_madera.py` | guardia, **nueva** |
| `tools/mcp/blender-mcp/40-Infraestructura/scripts/crear_valla_madera_lowpoly.py` | generador — **ya en HEAD** por `c545940` |
| 6 GLB `game/isla-ancestral/assets/3d/{alta,media,baja}/…valla_madera…` | **ya en HEAD** por `c545940` |
| 4 sondas / baseline JSON en `Temp/` | **ya en HEAD** por `c545940`; conservadas, no borradas |
| `.workbuddy-ai/memory/2026-11-08.md` | append (ignorado por `.gitignore:92`) |

**Commit selectivo de 4 paths**, `add` + `commit` **encadenados con pathspec**, sin `--amend`, sin push, sin `git add -A`. El **pool de logs no se commitea**. `Temp/hy4_valla_rojo_20261108.glb` (GLB inyectado) queda **conservado y sin versionar**. Entradas ajenas del worktree (Ling-3.1-Flash, Glyph Cluster, Crouton Alpha, `Logs/NUMEROS_DISPONIBLES.txt`) **intactas y fuera del commit**; 0 staged ajenos arrastrados.

**Sin flips**, sin QA §21.8, sin sello, sin aprobación visual final, sin integración en escena, sin GO, sin push. No se tocó `07`, T-02/T-03/T-04, ni archivos protegidos (`AGENTS.md`, `quality.yml`, `CHECKLIST-GLOBAL.md`, `project.godot`), ni checklist de otro módulo.

## 11. Decisiones abiertas para la directora

1. **GO / ratificación** de las exportaciones sin GO de B10-bis, B15, B16, B17 y **B18**.
2. **Flip** de `02` **L34**, `CHECKLIST-OBJETOS-BLENDER.md` **L194** y `40-Infraestructura/checklist.md` **L14** — **propuesto, NO aplicado** (REGLA CERO). Siguen `[ ]` también L26–L31 / L30 / L39 / L62 / L63 (marcas obsoletas con artefacto real).
3. **§28 en ROJO en HEAD**: requiere GO por ser archivo ajeno. Los 4 paths de esta vuelta están limpios.
4. **COLA ACTIVA vacía** y sin prioridad; P1..P7 sin respuesta; `07` con **17 `[ ]`** sin dueño; T-02 (integración), T-03 (CIEGO), T-04 (fantasma) y Q2 sin definir.
5. **Siguientes huecos REALES** medidos en `02`: **L37 Caña de pescar**, **L40 Carrito de vías**, **M36 fauna ×5**. Con L34 cerrado, M40 ya no tiene hueco de asset pendiente en el backlog de HY4.
6. Anotar en el **acta 24** los **6 casos** de deriva 0 de B18 como ampliación del corpus M166-runtime (el acta 27 ya propuso el caso 33 de `estructura_sumergida`).
