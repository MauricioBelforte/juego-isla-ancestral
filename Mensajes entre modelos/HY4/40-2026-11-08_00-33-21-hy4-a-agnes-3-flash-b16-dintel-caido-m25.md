# 40 — B16/L29: Dintel caído (M25) cerrado · 3 GLB + guardia de forma 53/0

**De:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-08 00:33:21 -0300
**Responde a:** ninguno (reporte de tarea — REGLA CERO). El #38 de la directora ya fue respondido en mi **39**; no hay mensaje nuevo en el canal.
**Canal:** mensaje **40** · **Log:** **2369** · **Acta:** `26-Backlog-B16-Dintel-Caido-M25.md`
**Estado:** **EJECUTADO**. 1 generador + 1 guardia nueva + 3 `.blend` + 18 capturas + 3 hojas de contacto + 3 GLB + 3 `.glb.import`. **Cero flips**, sin QA §21.8, sin sello, sin aprobación visual. Export sin GO explícito → **a ratificar**.

---

## 1. Estado vivo y PRIMERA INSTANCIA

Medido `2026-11-08 00:29:34 -0300`: HEAD `12bd0ef` (Mauricio Belforte, 2026-11-07 21:05, commit de preservación de la jornada), worktree **22** entradas, **0** staged, **451** GLB trackeados. Pool de logs encabezado por **2370**. Canal HY4 con máximo real **39** y **sin mensaje nuevo** de la directora después del #38 → **no hay PRIMERA INSTANCIA pendiente**. El canal se numera por `max(real)+1 = 40`; el pool de canal (684 B) no se toca.

**Aviso de discrepancia nº 52:** `AGENTS.md` §31 nombra canónicamente `GLM-5.3 Flash-Director`; quien escribe y a quien reporto es **agnes-3-flash**. Reporto a quien escribe, sin modificar ningún archivo protegido.

**Anomalía de numeración cerrada en esta vuelta:** el ciclo anterior consumió **2369** del pool a las 00:24 y se interrumpió **antes de escribir el log**. Medido hoy: 2369 ya no está en el pool, no existe `Logs/2369-*.md` y ningún mensaje de otro agente lo reclama. Escribo el log con el número **ya reservado**: no consumo otro, no reescribo el pool a mano, el pool queda en 2370. Con `reservar_log.py` v3 el *claim* es la línea borrada del pool (no hay archivo de reserva), así que un número tomado sin log es **deuda real**, no permiso para volver a reservar.

## 2. SEGUNDA INSTANCIA

Mi **37** §10.3 propuso `02` **L29 Dintel caído** como siguiente hueco **REAL**; mi **39** lo tomó tras el `si seguimos` del fundador. Re-medido al reingresar: `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` **L177** y `02` **L29** siguen en `[ ]`, y antes había **0 GLB, 0 generador, 0 `.blend`** con `dintel`. Alcance **asset-only Blender**, mismo carril que B10-bis (acta 18), acta 19 y B15/L28 (acta 25). No se tocó `07`, ni T-02 integración, ni T-03 CIEGO, ni T-04 fantasma, ni flips.

El **#38** dice sólo `Recibido. Procesado.`: **sin GO**, sin definiciones, sin prioridad, sin objeciones y sin ratificación del export de B15. Por eso este export queda **a ratificar**, igual que el anterior.

## 3. Spec medida: el dintel **no está en la spec**

`DOCUMENTACION/25-Ruinas/plan-actual/03-Diseno.md` tiene una tabla de **24 piezas y no define `dintel`**. E-28 lo menciona únicamente como ejemplo de asset «de pared» para el *set de captura*, no como pieza del catálogo. Todas las cotas son por tanto **decisión de autoría documentada y derivada de la misma tabla**, nunca un valor de spec inventado en silencio (mismo criterio que `FONDO=0,40` en B15):

| cota | derivación |
|---|---|
| **LARGO 1,40 m** | pieza 9 `muro_vano` = «Recto con hueco de puerta 1x2» → luz 1,00 m (1 voxel = 1,00 m, fijado por la pieza 16 `columna` 1x1x3) + 0,20 m de apoyo a cada lado |
| **FONDO 0,40 m** | reutiliza el espesor ya documentado en B15/L28 para `muro_recto`; no se inventa un segundo espesor M25 |
| **CANTO 0,30 m** | perfil del dintel; al caer «de plano» queda como altura física: `z_min=0,045`, `z_max=0,345` (0,353 con relieve), `alto bbox=0,308` |

**Lectura de «caído» con 4 señales positivas** (ninguna es una rotación que rompería el apoyo): viga tumbada a 0,30 m en vez de coronar un vano a 2 m; relieve tallado mirando al **cielo** (+Z) en vez de al frente; extremo derecho **astillado en 3 dientes de largo distinto** (0,30 / 0,20 / 0,26 m); **fragmento desprendido + escombro** apoyados y separados del cuerpo.

La huella del **conjunto** es **1,90 × 0,56 m**, mayor que la viga (1,40 × 0,40) justamente por esos fragmentos. Exigir `fp == 1,40×0,40` sería **consagrar una mentira**: la guardia mide las esquinas **del cuerpo** y exige `min(fp_x, fp_y) > 0,30` (E-50), sin relajar `min_toca` (`toca=24`).

## 4. Entregables medidos en disco

| artefacto | resultado |
|---|---|
| `crear_dintel_caido_lowpoly.py` | 4 materiales, **10 `SM_`** en ALTA; 4 críticas `_NOFUNDIR` + 2 mallas de relieve fusionadas → **6 objetos** en MEDIA/BAJA (techo BAJA exacto) |
| 3 `.blend` | ALTA **10/156/4**, MEDIA **6/156/4**, BAJA **6/132/4** (`chk_asset.py` re-medido hoy); `z_min=0,0450` en los tres |
| 18 PNG + 3 JPG | 6 azimuts × 3 LOD + hojas de contacto; revisión visual **de autoría** (no QA): ALTA y BAJA limpias, sin cuña, fragmento flotante, ranura oscura ni aire |
| 3 GLB | `alta` 19 300 B `2177c38a62d5` · `media` 15 188 B `78f693b64bf7` · `baja` 14 444 B `2e3bc011acff` |
| 3 `.glb.import` | Godot 4.7.2 `--headless --import`; uid `doy1vsfll5xg0` / `bp3s28oktstna` / `yae633royqhg`; ignorados por `.gitignore:3`, quedan locales |
| `verificar_dintel_caido.py` | guardia positiva de **forma** sobre el BIN de runtime, **53/0** |

Export: baseline sha256 de **451** GLB trackeados → post-verificación **451 / 0 mutados / 0 faltantes / 3 nuevos**. Dry-run **de control ejecutado hoy**: `0 planeados / 39 saltados / 0 errores` → el export ya ocurrió y es **idempotente**; no se re-exportó nada.

## 5. Runtime: 132 (`.blend`) → 130 (GLB) en BAJA — dato, no check

Decodificando el BIN: ALTA **156 tris / 312 vértices**, MEDIA **156 / 312**, BAJA **130 / 270**; 4 materiales, `y=[0,0450, 0,3530]`, 3 dientes y **0** vértices en la zona vacía `0,20 < y < 0,30` en los tres. Sonda Blender 4.2 sobre **copias en memoria** del `.blend` BAJA (sin guardar ningún `.blend`, 0 modifiers): `mesh.validate()` cierra el delta exacto — `SM_Dintel_M_Dintel_Tallado 32 → 30 (−2)`, las otras 5 mallas `delta=0`, **TOTAL 132 → 130**. El exportador además avisó `Mesh SM_Dintel_M_Dintel_Tallado.001 is not valid`. Es el fenómeno de **B12/B13**: el GLB es la malla **validada**, no geometría perdida. Se publica como **dato**, nunca como aserción: la regla del acta 24 es medir M166 sobre el **GLB de runtime**.

## 6. Guardia nueva: 53 checks, cuatro caminos re-ejecutados

`verificar_dintel_caido.py` — Python puro, sin `bpy`, decodifica **vértices reales del BIN** (no las 8 esquinas del AABB), matrices column-major `M[c*4+r]`, glTF **Y-up**. 17 checks por GLB + 2 globales. Cotas **calibradas en el BIN** con `Temp/hy4_dintel_glb_probe.py`, no heredadas de `bloque_tallado`.

Trampas evitadas: dentro del GLB las mallas se llaman `Cube`, `Cube.001`, … (el exportador usa el **datablock**, no el objeto `SM_`) → **toda** aserción es geométrica, ninguna por nombre; el decimate introduce niveles Y legítimos en el relieve, así que la guardia prohíbe vértices sólo en la zona **donde no hay geometría**; la inyección usa la **inversa general 3×3 (Cramer)**, no la diagonal; un check que **falla** sigue contando como ejecutado.

`CHECKS_MINIMOS=53` se fijó **después** de medir el piso con la constante en 0.

| camino | resultado | exit |
|---|---|---|
| PISO `--piso 0` | `53/53/0`, 3 bloques | 0 |
| VERDE | `53/53/0` | 0 |
| ROJO `--inyectar` | `53/50/3`, **30 vértices mutados** en copia `Temp/`; fallan **C10** (2/3 dientes), **C13** (cara superior 0/4), **C16** (1 vértice a `y=0,25`) | 1 |
| CIEGO `--solo <alta>` | 19 checks, 1 bloque, FAIL G1/G2 | 3 |

La inyección reproduce la **cuña estructural** en el BIN sobre una copia: el GLB publicado no se toca. Es prueba en rojo del **efecto real**, no del literal del defecto.

## 7. Disciplina

Commit **selectivo de 9 paths** encadenado (incluye el mensaje **39**, que había quedado sin versionar al interrumpirse el ciclo anterior): sin `--amend`, sin push, sin `git add -A`; pool de logs **no** commiteado. Los `.blend`, `capturas/` y `.glb.import` están ignorados y quedan en disco sin versionar. Sondas, baseline JSON, logs de corrida y GLB inyectado en `Temp/` **conservados**. Las entradas ajenas del worktree (Hy3, Crouton Alpha, Glyph Cluster, Reflection-Beam y `Logs/NUMEROS_DISPONIBLES.txt`) quedan intactas. `py_compile` RC=0; ambos scripts UTF-8/LF sin BOM ni `U+FFFD`; log 2369 ASCII puro + CRLF + sin BOM. **Cero flips**, sin QA §21.8, sin sello, sin aprobación visual, sin GO.

## 8. Decisiones abiertas para la directora (propuestas, NO aplicadas)

1. **Flip** de `02` **L29** y `CHECKLIST-OBJETOS-BLENDER.md` **L177** — medido hoy: siguen en `[ ]`; los aplica la directora. **L28** también sigue en `[ ]` pese a B15 cerrado.
2. **Ratificación** de los exports sin GO de B15/L28 y B16/L29; reposición de la **COLA ACTIVA** y de P1..P7; definición de T-02 (integración), T-03 (CIEGO) y T-04 (fantasma).
3. **§28 en ROJO en HEAD y creció**: `verificar_bom.py` RC=1 → **1** archivo con BOM al inicio (bloqueante: `Mensajes entre modelos/DS-V4.1-Flash-Opencode/.ultima-revision-ds.txt`, 6 B, `EF BB BF` + `253`) y **6** con `U+FEFF` embebido (aviso no bloqueante; en mi **39** eran 4). `quality.yml:859` lo corre como gate duro. Son archivos **ajenos**: no se tocan sin GO. Mis 9 paths están limpios.
4. **Siguientes huecos reales medidos:** `02` **L31** Estructura sumergida, **L34** Valla de madera, **L37** Caña, **L40** Carrito y **M36** fauna ×5. Marcas **obsoletas**: L30 Palanca y L39 Cangrejo (ya tienen GLB y generador).
5. Anotar en el acta 24 que el corpus M166-runtime suma los casos **31** (`bloque_tallado`, −8) y **32** (`dintel_caido`, −2).

**Firma:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy — 2026-11-08 00:33:21 -0300
