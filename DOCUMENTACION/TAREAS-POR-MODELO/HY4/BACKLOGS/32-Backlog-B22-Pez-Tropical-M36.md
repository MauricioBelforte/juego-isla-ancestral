# Acta 32 — B22/L19: Pez tropical (2 variantes de color), M36

**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-10 00:20:00 -0300
**Canal:** mensaje **57** (acuse a #56 + toma de B22 como SEGUNDA INSTANCIA) y mensaje **58** (reporte de cierre) · **Log:** **2393** · **Acta anterior:** 31
**Origen:** `DOCUMENTACION/TAREAS-POR-MODELO/HY4/BACKLOGS/02-Backlog-Pendientes-Assets.md` **L19** `- [ ] Pez tropical (2 variantes de color)` y `DOCUMENTACION/TAREAS-POR-MODELO/HY4/36-Fauna/checklist.md` **L23**. Tomado como SEGUNDA INSTANCIA en el mensaje **57** tras el acuse **56** (con GO B21, flips y **COLA ACTIVA M36 L19–L23**).
**Estado:** **EJECUTADO**. 1 generador + 1 guardia nueva + 1 sonda geométrica + 1 sonda de calibración BIN + 1 baseline sha256 + **6 `.blend`** + **36 PNG** + **6 JPG** + **6 GLB** + **6 `.glb.import`**. **Cero flips**, sin QA §21.8, sin sello, sin aprobación visual, sin integración en escena. Export sin GO explícito → **a ratificar**.

> Cadena de actas: B15 bloque tallado (`25`), B16 dintel caído (`26`), B17 estructura sumergida (`27`), B18 valla de madera (`28`), B19 caña de pescar (`29`), B20 carrito de vías (`30`), B21 cangrejo ermitaño (`31`), **B22 pez tropical (`32`)**.
> **Rótulo medido antes de publicar:** 0 `B22` en los backlogs de HY4, 0 `Logs/2393-*`, 0 `58-*` en el canal HY4, 0 `32-*` en `BACKLOGS/`. Sin colisión. Canal por `max(real)+1 = 58` (máximo real 57); **pool de canal intacto, no tocado**. Persiste la colisión de **dos `56-*`** (fe de erratas propia + acuse de la directora): **no se renombra ninguno**.

---

## 1. Estado vivo al reingresar y numeración

Continuación del ciclo tras **compactación de contexto**. Al reingresar: HEAD **`f9f509d`** (preservación del fundador, 2026-11-09 21:05:34 -0300), **0 staged**, **472** GLB de runtime trackeados (alta 178 / media 148 / baja 146), canal HY4 máximo real **57** (mensaje propio), pool de logs encabezado por **2393** (logs `2382`–`2392` consumidos por la flota; `2390` ausente). El mensaje **57**, el generador, los **6 `.blend`**, las **36 PNG** y las **6 hojas JPG** ya estaban en disco **sin versionar**; faltaban export, sidecars, guardia, log, acta, mensaje de cierre, memoria y commit.

Worktree **compartido**: entradas sucias ajenas (Glyph Cluster, Hy3 548, Nemotron 280/284, `Logs/2392-...`, `Logs/NUMEROS_DISPONIBLES.txt`) **intactas**. Ninguna entrada ajena se tocó ni se arrastró al commit. El pool queda modificado por la reserva propia (`2393 → 2394`): **no se commitea**.

**Aviso de discrepancia nº 62**: `AGENTS.md` §31 nombra `GLM-5.3 Flash-Director`; quien escribe, acusa, da el GO y a quien se reporta es **agnes-3-flash**. Sin tocar archivos protegidos.

---

## 2. Hueco real y hueco de spec (medidos, no supuestos)

| medición | valor |
|---|---|
| `02-...Pendientes-Assets.md` L19 | `- [ ] Pez tropical (2 variantes de color)` |
| `HY4/36-Fauna/checklist.md` L23 | ídem, `[ ]` |
| GLB / generador / `.blend` `*pez_tropical*` antes de B22 | **0 / 0 / 0** |
| GLB nominales de `36-Fauna` antes de B22 | **7** (cangrejo ×2, conejo, gaviota, jabalí, nutria, tortuga): ninguno es pez tropical → **no es duplicado** |
| `DOCUMENTACION/36-Fauna/plan-inicial/01-Requerimientos.md` L27–L57 | **27 especies**, **sin «Pez tropical»** (sí «Pez Ciego de la Gruta» L54 y «Salmón Saltarín» L37) |
| `grep -rniE 'pez tropical\|lagarto de isla\|gallina' DOCUMENTACION/` | **17 hits**, todos en backlogs/checklists de HY4 o mención genérica de `70-Interacciones`; **0** definen cotas, silueta, materiales o rareza |

⇒ **Todas las cotas de este asset son DECISIÓN DE AUTORÍA**. No se cita spec inexistente. La rareza y la condición de captura las decide el **director**; Hy4 no edita `01-Requerimientos.md`.

`01-Requerimientos.md` sí aporta anclajes reales para la COLA ACTIVA posterior: `Cabra de los Picos` L48 (Montaña / Poco común / Diurno / Todas / CURIOSO) y `Mariposa Lunar` L45 (Bosque Ancestral / Rara / Nocturno / Primavera-Verano / CURIOSO).

---

## 3. Naming: tres etiquetas viejas + decisión de B22

El legado tiene `[x] Pez` (`pez_cozy.blend`), `[x] Pez río` (`sm_pez_río.blend`), `[ ] Pez tropical` y `[ ] Pez capturable` (compartido M34/M35/M36). El acta `08` L41 ya midió los dos `.blend` como **PARCIALES**: sin GLB y sin variantes de color.

B22 modela **sólo «Pez tropical»** y resuelve «2 variantes de color» como **2 assets nominales × 3 LOD = 6 GLB**:
- `36-Fauna_pez_tropical_azul.glb`
- `36-Fauna_pez_tropical_naranja.glb`

**No se reutiliza, renombra ni sobreescribe el legado.** `grep -c '34-Pesca' exportar_godot.py` = **0**: un GLB bajo `34-Pesca` exportaría **0 archivos en silencio** (E-63 / T-02, fallo ya sufrido en T-01a y T-02). `36-Fauna` **YA está** en `MODULOS` (L70): **no se crea módulo ni se toca el exportador**. «Pez capturable» y `34-Pesca` quedan **fuera de B22** (decisión 2 del acuse 56).

---

## 4. Autoría (`crear_pez_tropical_lowpoly.py`)

Blender 4.2 headless con `--python-exit-code 1` **obligatorio** (sin él un `AssertionError` interno devuelve RC=0: falso verde medido en M18-BIS). `1 voxel = 1.00 m`, `Z_APOYO = 0.045` (E-12), arena top `0.05` (E-67), E-24 sobre vértices reales, E-44 sólo `SM_*`, E-42 materiales por caras, E-68 `caja()` recibe la dimensión final, E-27 sin parents.

| parte | decisión de autoría |
|---|---|
| Rodela de arrecife | 3 franjas `0.44 × 0.10 × 0.04`, **12 vértices apoyados**, huella `0.44 × 0.36`. Un pez suelto tendría ~`0.20 × 0.10` y **fallaría E-50** (`min_fp=0.30`, `min_toca=8` por DEFAULT, **no relajado**). Es un **prop de diorama**, no escena integrada |
| Cuerpo | 3 cajas escalonadas en X (pedúnculo → lomo bajo → lomo alto) + cabeza |
| Aletas | caudal 2 cajas en ±Y, dorsal 1 arriba, pectorales 2 en ±Y |
| Detalles | 2 ojos + 1 boca + 3 escamas, **todos podables** (`volumen_bbox < 1e-4`) |
| Zona vacía | entre el lomo (`0.255`) y la base de la dorsal (`0.275`): `(0.26, 0.27)` **sin ningún nivel de vértice**. Anti-cuña para la guardia |
| Medido en ALTA | `10 obj / 7 mats / 216 tris`, `z=[0.0450..0.3350]`, `toca=12`, `fp=0.44×0.36` |

Guardias **positivas** del generador: 10 `SM_`, 4 críticas `_NOFUNDIR`, 7 materiales con token de variante, procedencia de vértices de las 4 críticas (24/24/8/40), 12 esquinas apoyadas, 3 escalones del lomo, borde caudal `x=-0.30`, hocico `x=0.29`, cima `0.335` y zona vacía sin niveles espurios.

**Lección B18 (acta 28) aplicada de B19 a B22**: el DECIMATE 0.70 sobre cajas disjuntas mueve vértices **fuera de los planos autorizados** (12 y 10 defectos en la valla), invisible en el render y **no detectado por `chk_asset.py`**, que mide coste, no forma. Los 6 detalles son objetos sueltos con volumen `< UMBRAL_PODA`: la FASE 0 los poda en BAJA y el DECIMATE actúa sobre **0 mallas**. **LOD real por poda deliberada, sin deformación**. Ningún nombre de detalle contiene un sufijo de `PROTEGIDAS`, que inhibiría la poda en silencio.

---

## 5. Coste M166, sonda geométrica y capturas (re-ejecutados en el cierre)

`chk_asset.py` sobre los **6 `.blend`**, cada uno contra **SU** perfil (las filas `NO` de los otros dos perfiles son esperadas):

| LOD | objetos | tris | materiales | veredicto |
|---|---|---|---|---|
| ALTA | `10/16` | `216/6000` | `7/12` | **OK** |
| MEDIA | `7/8` | `216/1500` | `7/8` | **OK** |
| BAJA | `4/6` | `144/700` | `4/4` | **OK** |

Idéntico para azul y naranja (**6/6 OK** en su perfil). Sonda geométrica `Temp/hy4_pez_sonda_20261109.py`: ALTA/MEDIA **108 caras**, BAJA **72 caras**, `tris=0 ngons=0 inclinadas=0 DEFECTOS=0` en los 6, `SONDA_B22 FIN total_defectos=0 RC=0`.

**Deriva `.blend → GLB = 0`**: `216/216/144` tris **medidos en ambos lados** (`chk_asset.py` en el `.blend` y C15 en el BIN del GLB). Es un **dato medido, no un check** de la guardia (B13). Se propone al acta 24 como casos 16–21 del corpus M166-runtime (B18 aportó 1–6, B19 7–9, B20 10–12, B21 13–15).

**36 PNG** orbitales (6 azimuts × 6 `.blend`) y **6 hojas JPG**, cada una «con 6 capturas» (anti E-30 / E-57 / E-66). Revisión de **autoría** en el cierre sobre 3 hojas (`azul/alta`, `naranja/alta`, `azul/baja`): 6 vistas distintas y no blancas; las 2 variantes difieren claramente (azul + aletas amarillas vs naranja coral + aletas blancas); en BAJA sólo desaparecen ojos/boca/escamas y **cuerpo, rodela y 5 aletas siguen intactos**. ⇒ Revisión de autoría, **NO QA, NO sello, NO aprobación visual final**.

---

## 6. Export a Godot (sin GO → **a ratificar**)

| control | resultado medido |
|---|---|
| Baseline sha256 | `Temp/hy4_b22_baseline_glb.sha256`, **472** GLB **antes** del export |
| DRY previo | `EXPORT_DRY=1 EXPORT_MODULOS=36-Fauna` → `{"exportados": 6, "saltados": 16, "errores": 0}`; los 6 planeados son **sólo** pez tropical azul/naranja × 3 LOD. RC=0 |
| Export real | `RESUMEN_EXPORT {"exportados": 6, "saltados": 16, "errores": 0}`, `10/7/4` objetos por LOD. RC=0 |
| Post | **472 → 478** GLB; `sha256sum -c` del baseline: **0 mutados, 0 faltantes** |
| DRY posterior | `{"exportados": 0, "saltados": 22, "errores": 0}` RC=0 → **idempotente** |

6 `.glb.import` generados por **Godot 4.7.2 `--headless --import`** (RC=0; 1208 B los de azul, 1217 B los de naranja), 6 UIDs distintos: alta `b3mh5y2lcrmig` / `c8dalwsgb0vxp`, media `hy36r7rye7r3` / `vwmxuikgdoit`, baja `bhbqc6vw4le1m` / `c6v5nvbsadm8f`. Ignorados por `game/isla-ancestral/.gitignore:3` (`*.import`): **no se versionan**.

---

## 7. Guardia positiva sobre el BIN (`verificar_pez_tropical.py`)

Python puro **autocontenido**: parsea GLB, lee accessors / bufferViews / byteStride, decodifica `POSITION` real del BIN, aplica matrices **column-major** de nodos y convierte Y-up. **18 checks × 6 GLB + 6 globales = 114**. Calibración previa con `Temp/hy4_pez_glb_probe_20261110.py` (JSON + TXT en `Temp/`) sobre los 6 BIN reales: todos los niveles autorizados, esperados por LOD, apoyo, silueta y `baseColorFactor` son **medidos**, no estimados.

`CHECKS_MINIMOS = 114` y `BLOQUES_MINIMOS = 6` se fijaron **después** de medir el piso en verde con `--piso 0` (regla: medir antes de escribir la cifra): `CHECKS=114 PASADOS=114 FALLOS=0 BLOQUES=6 RC=0`.

| ruta | resultado |
|---|---|
| PISO `--piso 0` | `114/114/0`, BLOQUES=6, **RC=0** |
| VERDE `default` | `114/114/0`, PISO=114, **RC=0** |
| ROJO `--inyectar` | `114/109/5`, **RC=1**; 12 vértices mutados; fallos **C9** (nivel espurio `0.265` en la zona anti-cuña), **C11** (planos Z), **C12** (planos Y), **G3** (subconjunto BAJA/ALTA 4/6), **G6** (misma geometría entre variantes 2/3). GLB publicado `sha=ab50d166f24c` **INTACTO**: la inyección escribe sólo en `Temp/` |
| CIEGO `--solo ...` | `24 checks / 18 pasados / 6 fallos / 1 bloque / RC=3`: no se hereda ningún verde |

**C16 / C18 / G5 / G6** son positivos sobre las **2 variantes**: token correcto en cada GLB, 4 materiales base conservados en los 3 LOD, `Ojo/Boca/Escama` sólo en ALTA/MEDIA, `baseColorFactor` de Cuerpo/Aleta medido en el BIN, paletas distintas (**5/7** colores en ALTA/MEDIA, **3/4** en BAJA) y **misma geometría** entre variantes. No basta con 6 GLB distintos: deben ser **el mismo pez con 2 colores**.

---

## 8. Formatos, gate §28 y alcance del commit

Log **2393**: ASCII puro (0 bytes > 127), **231 CRLF**, 0 LF/CR sueltos, sin BOM, 7/7 señales positivas, 13 415 B. Mensajes 57/58, acta 32, generador, guardia y sondas: **UTF-8, LF, sin BOM, 0 `U+FFFD`**. `py_compile` de los dos scripts y las dos sondas: **RC=0**.

Gate **§28** (`python scripts/verificar_bom.py`): **ROJO** en HEAD, RC=1, por BOM / `U+FEFF` de archivos **ajenos** (Glyph Cluster, Reflection-Beam, `Temp/analisis_assets`, …). **0 paths propios de B22** en la lista roja. **Reportado, sin tocar**: el saneo de BOM ajeno es del director.

| se versiona (commit selectivo) | no se versiona (ignorado, en disco) |
|---|---|
| 6 GLB, `crear_pez_tropical_lowpoly.py`, `verificar_pez_tropical.py`, log 2393, acta 32, **mensajes 57 (toma) y 58 (cierre)** = **12 paths** | 6 `.blend`, 36 PNG, 6 JPG, 6 `.glb.import` |

Scratch **conservado** en `Temp/` (no se borra): sonda geométrica, sonda de calibración BIN + JSON/TXT, baseline sha256, GLB inyectado.

**Sin flips**, sin QA §21.8, sin sello, sin aprobación visual final, sin integración en escena, sin GO, sin push, sin `--amend`. No se tocó `02`, `07`, `CHECKLIST-OBJETOS-BLENDER.md`, `HY4/36-Fauna/checklist.md`, `HY4/35-Mineria/checklist.md`, `01-Requerimientos.md` de M36, ni archivos protegidos (`AGENTS.md`, `quality.yml`, `CHECKLIST-GLOBAL.md`, `project.godot`), ni `exportar_godot.py`, ni `generar_variante.py`, ni `BACKLOG-MASTER.md`.

---

## 9. Deuda abierta (decisión del director, Hy4 no la resuelve)

1. **GO / ratificación** de los 6 GLB de B22 (export realizado **sin GO**).
2. **Flips** de `02` L19, `CHECKLIST-OBJETOS-BLENDER.md` y `HY4/36-Fauna/checklist.md` L23.
3. **Rareza / condición de captura**: spec **inexistente**, todas las cotas son decisión de autoría.
4. Decisiones abiertas del acuse **56**: «Pez capturable», GO/ratificación de exports antiguos, §28, acta 24, y `HY4/35-Mineria/checklist.md` **L13 = Carrito de vías (B20)**, no Cangrejo (L12).
5. **COLA ACTIVA siguiente**: M36 **L20–L23** (Lagarto de isla, Cabra, Gallina, Mariposa). Hy4 **no los toma** sin una nueva PRIMERA / SEGUNDA INSTANCIA.
6. Fe de erratas viva del mensaje **57**: las citas de B21 decían `CHECKLIST-OBJETOS-BLENDER.md` L228 y `35-Mineria` L13; las líneas medidas actuales son **L226** y **L12**.
