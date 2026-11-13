# Acta 36 — B26/L23: Mariposa («Mariposa Lunar»), M36

**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-13 00:45:00 -0300
**Canal:** mensaje **68** (acuse sustantivo de la directora: GO B25, flips, «L23 es el último hueco M36»), mensaje **69** (PRIMERA INSTANCIA al 68 + SEGUNDA INSTANCIA B26, **ya versionado por el fundador**) y mensaje **70** (reporte de cierre con evidencia) · **Log:** **2410** · **Acta anterior:** 35
**Origen:** `DOCUMENTACION/TAREAS-POR-MODELO/HY4/BACKLOGS/02-Backlog-Pendientes-Assets.md` **L23** `- [ ] Mariposa (alas simples para animar)`, `HY4/36-Fauna/checklist.md` **L27** y `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` **L209**.
**Estado:** **EJECUTADO**. 1 generador (corregido) + 1 guardia nueva (**58/58/0**, 5 rutas) + 1 sonda geométrica (ya trackeada) + 1 sonda de calibración BIN + 1 baseline sha256 + **3 `.blend`** + **18 PNG** + **3 JPG** + **3 GLB** + **3 `.glb.import`**. **Cero flips**, sin QA §21.8, sin sello, sin aprobación visual, sin integración en escena. Export sin GO → **a ratificar**.

> Cadena de actas: B15 (`25`) … B22 pez tropical (`32`), B23 lagarto (`33`), B24 cabra (`34`), B25 gallina (`35`), **B26 mariposa (`36`)**.
> **Rótulo medido antes de publicar:** 0 `B26` en backlogs HY4, 0 `Logs/2410-*`, 0 `70-*` en el canal, 0 `36-*` en `BACKLOGS/`. Sin colisión. Canal por `max(real)+1` (69 → 70); **pool de canal intacto**. Persisten dos `56-*`.
> **Con B26 quedan ejecutados los 5 huecos de la COLA ACTIVA M36 (L19–L23)** en alcance asset-only. Los flips siguen siendo facultad del director.

---

## 1. Estado vivo y absorción del fundador

Al reingresar tras un corte por límite de uso (~2 días): HEAD **`4aa5c54`**, 7 entradas sucias ajenas, **487** GLB, canal máximo real **69** (propio), pool **2408**, **sin acuse nuevo al 69**.

**`bfcd568`** (preservación del fundador, 2026-11-12 19:50) **absorbió el inicio de B26** del worktree: mensaje **69**, `crear_mariposa_lowpoly.py`, `Temp/hy4_mariposa_sonda_20261111.py`, el scratch de B25 y los acuses 66/68. También aplicó **flips L19–L21** en `02` y COBJ.

> **Consecuencia publicada, no ocultada:** el generador que el fundador versionó contenía la **primera** versión del asset, con el **defecto visual de alas flotantes** (§4). B26 la corrige y **re-versiona ese path**. No se reescribe el historial ni se hace `--amend`: se publica un cambio nuevo y medido. Por eso el commit final tiene **8 paths y no 9**: el mensaje 69 y la sonda geométrica **ya estaban trackeados**.

Al cierre: pool **2408 → 2410** (2408 lo consumió ERNIE-5.5 / M18 Casas; **2409 es un gap** reservado sin escribir), **2410** reservado y escrito en el mismo turno (`→ 2411`, pool **no commiteado**).

---

## 2. Hueco real, ancla de spec y trampa de medición

| medición | valor |
|---|---|
| `02` L23 / `36-Fauna` L27 / COBJ L209 | `[ ]` en los tres espejos |
| GLB / `.blend` / generador `*mariposa*` al inicio | **0 / 0 / 0** |
| GLB nominales en `36-Fauna` | 12, **ninguno** mariposa → no es duplicado |
| `36-Fauna` en `MODULOS` de `exportar_godot.py` (L70) | **SÍ** → no se crea módulo ni se toca el exportador (E-63 / T-02) |

**SÍ hay ancla de spec real** (como B21 y B24): `DOCUMENTACION/36-Fauna/plan-inicial/01-Requerimientos.md` **L45**:

```
| Mariposa Lunar | Bosque Ancestral | Rara | Nocturno |
| Primavera/Verano | CURIOSO (revolotea cerca de la luz de la cámara) |
| noches despejadas |
```

Bioma / rareza / horario / estación / comportamiento / clima **definidos**. Se modela la especie del catálogo (nocturna, rara, atraída por la luz) con paleta violeta/azul y motas claras. **Ningún** documento define cotas, silueta ni materiales del prop → **todas son DECISIÓN DE AUTORÍA**. Hy4 **no** edita `01-Requerimientos.md`.

**Trampa de medición nueva:** `grep -rni 'ala' DOCUMENTACION/` = **8 536 hits falsos** (`ala` es subcadena de «s**ala**» / «m**ala**» / «p**ala**»; `echo 'sala' | grep -ci ala` = 1). Con límites de palabra, `\b(mariposa|mariposas)\b` = **17 hits** (1 ancla L45, 1 checklist M36 L118, 2 de `33-Agricultura`, resto backlogs HY4). Familia de las trampas de B20 (`vías`), B24 (`chivo ⊂ archivo`) y B25 (`ave ⊂ suave`).

---

## 3. Decisión sobre la guía 10, publicada **antes** de autorar

`DOCUMENTACION/GUIA-BLENDER/10-animales-bimodo.md` §10.2 exige nombres `SM_<Animal>_Ala_L / _R` y «ALAS: loft por ANILLOS desde el hombro … NO cubos» con origen/pivote en el hombro. El checklist L23 pide **«alas simples para animar»**.

B26 **no es un asset bimodo** (sin 2 poses ni modos de locomoción; es un prop estático de diorama). Se aplica de la guía **solo** la convención de nombres y el requisito funcional de **piezas independientes con materiales distintos** (`AlaL` / `AlaR`), para que el merge por lista de material de `generar_variante.py` **no** las fusione en ningún LOD. **No** se aplica el *loft* de anillos ni el pivote en hombro.

«Para animar» queda satisfecho **en el asset**: las 2 alas son nodos/mallas separadas en los 3 LOD, listas para que un dueño posterior (M48 Animación / integración en escena) les asigne rotación. Hy4 **no** implementa animación, rigs, pivotes ni integración. El contrato bimodo completo queda **propuesto** para una eventual **B26-bis**. No se finge cumplimiento.

---

## 4. Hallazgo real de la revisión visual de autoría (corregido)

**Primera versión** (la absorbida por el fundador): las 4 alas eran **placas horizontales** en `alt=0.29..0.31` y `|lat|=0.10..0.22`, con el cuerpo hasta `|lat|=0.06` y `alt=0.265`.

**Medido en las hojas de contacto:** las alas **flotaban 4 cm en lateral y 2.5 cm en altura**, visibles como barras sueltas sobre el cuerpo en `az000` / `az180`; la silueta no se leía como mariposa.

**Por qué ningún check lo detectó:** `chk_asset.py` dio **OK** (mide **coste**, no forma) y la sonda geométrica dio `total_defectos=0` (todas las caras seguían siendo axis-aligned). **Ninguno detecta una pieza desconectada.** Misma familia que la cresta flotante de B23.

**Corrección:** alas como **paneles verticales** en el plano Y-Z (grosor `sx=0.02`) con borde **interior `|y|=0.04` dentro del cuerpo** y borde exterior `|y|=0.22`; superior `z=0.21..0.31`, inferior `z=0.105..0.205`. Los 6 detalles (ojos / antenas / manchas) también se corrieron para solapar el cuerpo (`OJO_YS=±0.065`, `MAN_Y=0.062`) y no dejar otros flotantes. Regeneración completa de 3 `.blend` + 18 PNG + 3 hojas.

**Guardia positiva nueva en el generador:** `paneles_ala()` exige, **por panel** (no por el AABB global de la unión, que sería demasiado permisivo), intersección AABB con **volumen positivo** contra alguna de las 3 cajas reales del cuerpo **+ al menos 1 vértice real del `.blend`** dentro de esa intersección. Medición en verde: `L=[([1],2),([0,1],4)]`, `R=[([1],2),([0,1],4)]`.

**Falso rojo medido y corregido:** con tolerancia `1e-9` la guardia fallaba («sin vértices reales dentro del cuerpo») por redondeo **float32 de Blender vs float64 del AABB** (un vértice en `-0.04` quedaba `1e-9` fuera de su propia caja). Se subió a `tol=1e-4` (0.1 mm ≪ 1 voxel) y pasó. El error se publica, no se esconde.

---

## 5. Bug latente de infraestructura ajena (reportado, **no tocado**)

La rama `emisivo=` de `plantilla_asset.py::mat()` hace `(*emisivo[0], 1.0)` sobre un *float* → `TypeError`. Ningún generador B18–B25 la había ejercitado; B26 la disparó al primer intento de autorar la mota luminosa.

**No se toca infraestructura ajena sin GO:** se apartó `emisivo=` del generador y el brillo se logra con color base amarillo claro + `spec` alto. El **fix** de `plantilla_asset.py` queda en facultad del director / dueño de la infraestructura. Reportado en log 2410, esta acta y el mensaje 70.

---

## 6. Coste M166, sonda y capturas (re-ejecutados en el cierre)

| LOD | objetos | materiales | tris | `chk_asset.py` contra **su** perfil |
|---|---|---|---|---|
| ALTA | 10 | 7 | 192 | **OK** `10/16 · 192/6000 · 7/12` |
| MEDIA | 7 | 7 | 192 | **OK** `7/8 · 192/1500 · 7/8` |
| BAJA | 4 | 4 | 120 | **OK** `4/6 · 120/700 · 4/4` |

FASE 1 funde los 6 detalles en 3 grupos (*lossless*, 192 tris); FASE 0 poda los 6 en BAJA; **DECIMATE sobre 0 mallas**. LOD real por poda deliberada, sin *decimate* sobre cajas disjuntas (lección B18 / acta 28).

**Sonda geométrica** `Temp/hy4_mariposa_sonda_20261111.py` (la absorbida por el fundador; sin cotas *hardcodeadas* → sigue válida tras el rediseño): ALTA/MEDIA **96 caras**, BAJA **60**, `tris=0 ngons=0 inclinadas=0 DEFECTOS=0` en los 3, `ALAS_SEPARADAS objetos=2 materiales=[AlaL, AlaR]` en los 3, `SONDA_B26 FIN total_defectos=0 RC=0`.

**Deriva `.blend → GLB = 0`**: 192/192/120 tris **medidos en ambos lados** (`chk_asset.py` en el `.blend` y C15 en el BIN). Es un **dato medido**, no un check de la guardia (B13).

**18 PNG** orbitales (6 azimuts × 3 `.blend`) + **3 hojas JPG**, cada una «con 6 capturas» (anti E-30 / E-57 / E-66). Revisión de **autoría** sobre ALTA y BAJA regeneradas: 6 vistas distintas y no vacías; las 4 alas **unidas** al cuerpo y saliendo hacia los lados; en BAJA sólo desaparecen ojos/antenas/motas, conservando alas, cuerpo y rodela. **No es QA, sello ni aprobación visual final.**

---

## 7. Export a Godot (sin GO → a ratificar)

| control | resultado medido |
|---|---|
| Baseline sha256 | **487** GLB (`Temp/hy4_b26_baseline_glb.sha256`) |
| DRY previo (`EXPORT_DRY=1 EXPORT_MODULOS=36-Fauna`) | `{3 exportados, 31 saltados, 0 errores}`, sólo mariposa alta/media/baja |
| Export real | `{3, 31, 0}`, 10/7/4 objetos, 22 KB / 18 KB / 12 KB, RC=0 |
| Post | **487 → 490** GLB; `sha256sum -c` → **0 mutados / 0 faltantes** |
| DRY posterior | `{0, 34, 0}` → **idempotente** |
| Sidecars | 3 `.glb.import` con Godot 4.7.2 `--headless --import`, RC=0, UIDs distintos: alta `uid://1aqq4uly3mp8`, media `uid://csk0tffth3m14`, baja `uid://caihcsmh5wltu`. Ignorados por `.gitignore:3`, **no se versionan** |

---

## 8. Guardia positiva sobre el BIN — **5 rutas**

`tools/mcp/blender-mcp/36-Fauna/scripts/verificar_mariposa.py`: Python puro **autocontenido**, decodifica `POSITION` real del BIN, aplica matrices **column-major** y convierte Y-up. **18 checks × 3 GLB + 4 globales = 58**.

**Ejes medidos:** `p[0]`=X de Blender, `p[1]`=**ALTURA** (Z de Blender), `p[2]`=**LATERAL** (Y de Blender con signo invertido). En el BIN, `Ala_L` queda en `lat +0.04..+0.22` y `Ala_R` en `lat −0.22..−0.04`: los **nombres no deben confundirse con el signo del eje glTF**. C12 mide niveles **laterales**, no niveles Z.

Calibración previa con `Temp/hy4_mariposa_glb_probe_20261113.py` (JSON + TXT en `Temp/`): niveles X / ALTURA / LATERAL, **12 pares de apoyo**, zona vacía sin niveles, 4 paneles de ala y **contacto real = 18 vértices por ala** dentro de la caja AABB del nodo Cuerpo (`[-0.19,0.22] × [0.085,0.265] × [-0.06,0.06]`), **12 + 6 por panel**, en los 3 LOD. Todo **medido**, no estimado.

`CHECKS_MINIMOS = 58` y `BLOQUES_MINIMOS = 3` se fijaron **después** de medir el PISO **en verde** con `--piso 0` (regla: medir antes de escribir la cifra): `58/58/0 · 3 bloques · RC=0`.

| ruta | comando | resultado |
|---|---|---|
| PISO | `--piso 0` | `58/58/0 BLOQUES=3 RC=0` |
| VERDE | *(default)* | `58/58/0 BLOQUES=3 PISO=58 RC=0` |
| **ROJO A** | `--inyectar` | `58/52/6 RC=1`, **24 vértices** mutados; fallos `C8/C9/C11/C12/C14/G3` (tope de ala a `alt=0.275` dentro de la zona anti-cuña + desplazamiento lateral `+0.0133`) |
| **ROJO B** | `--inyectar-alas` | `58/53/5 RC=1`, **48 vértices** mutados; fallos `C12/C14/C18/G3/G4`. Mueve el borde interior de `|lat|=0.04` a `|lat|=0.12` **fuera del cuerpo**: contacto cae a **0/ala**, `por_panel=[0,0]`. **Sin tocar ningún nivel de ALTURA** → prueba que **C18 es infalsable por separado** de C9/C11. El ROJO A **no** ejercitaba C18/G4; por eso se añadió esta segunda inyección antes de confiar en la guardia nueva |
| CIEGO | `--solo <glb>` | `22 checks / 18 pasados / 4 fallos / 1 bloque / RC=3`: no se hereda ningún verde |

**GLB publicados intactos** tras ambos ROJO (`alta f10ae00f31d2`, `media 5874e01a681e`, `baja 1b55605b5a4f`): la inyección escribe **solo** en `Temp/`.

**C17 / G4** son positivos sobre alas separadas: exactamente 2 nodos `Ala_` con materiales **distintos** (`AlaL`/`AlaR`) en semiplanos laterales **opuestos**, en los 3 LOD. **C18** exige contacto real **por panel**. **C16** exige 4 materiales base en los 3 LOD y `Ojo/Antena/Mancha` **solo** en ALTA/MEDIA (poda deliberada).

---

## 9. Formatos y gate §28

Log **2410**: **ASCII puro** (0 bytes > 127), **310 CRLF**, 0 LF/CR sueltos, sin BOM, **11/11 señales positivas**. Mensajes 69/70, acta 36, generador, guardia y sondas: **UTF-8, LF, sin BOM**, 0 CR sueltos, 0 `U+FFFD`. `py_compile` de generador, guardia y 2 sondas: **RC=0**.

**Gate §28** (`python scripts/verificar_bom.py`): **ROJO** en HEAD, RC=1, por BOM / `U+FEFF` de archivos **ajenos**. **0 paths propios de B26** en la lista roja. Reportado, **sin tocar**: el saneo de BOM ajeno es del director.

---

## 10. Cierre: alcance y deuda abierta

**Se versionan** (commit selectivo, *pathspec* explícito, **sin `git add -A`**): 3 GLB, `verificar_mariposa.py`, `crear_mariposa_lowpoly.py` (**corregido**), log 2410, acta 36 y mensaje 70 = **8 paths** | **No se versionan** (ya trackeados por el fundador en `bfcd568`): mensaje 69 y `Temp/hy4_mariposa_sonda_20261111.py` | **Ignorados / scratch conservado**: 3 `.blend`, 18 PNG, 3 JPG, 3 `.glb.import`, baseline, sonda BIN + JSON/TXT, 2 GLB inyectados.

> Si el fundador vuelve a absorber scratch de `Temp/` (ya lo hizo en B22/B25), la afirmación «no versionado» quedará desactualizada **por un commit ajeno**, no por Hy4.

**0 flips.** Sin QA §21.8, sin sello, sin aprobación visual final, sin integración en escena, sin GO de export, sin push, sin `--amend`. **No se tocó** ningún checklist, `AGENTS.md`, `quality.yml`, `CHECKLIST-GLOBAL.md`, `project.godot`, `exportar_godot.py`, `generar_variante*.py`, `plantilla_asset.py` ni `NUMEROS_DISPONIBLES.txt`.

**Flips y discrepancias medidas (sin tocar marcas):**

- El fundador aplicó en `bfcd568` los flips **L19–L21** de `02` y COBJ → recount al cierre: `02` **28 `[x]` / 7 `[ ]`**, COBJ **162 `[x]` / 7 `[ ]`**. Eso **cierra** la discrepancia del rótulo «L21 flippeado» del acuse 68 publicada en el mensaje 69 (en ese momento L21 seguía `[ ]`).
- `36-Fauna/checklist.md` sigue **16 `[x]` / 5 `[ ]`**: L23–L27 acumulan **cinco cierres sin flip** en el tercer espejo.
- `07-Backlog-Tanda-Blender.md` sigue **0 `[x]` / 17 `[ ]`** (*stale*).
- **L23 (Mariposa) sigue `[ ]` en los 3 espejos**: flip pendiente del director. **REGLA CERO.**

**Pendiente del director** (Hy4 no lo resuelve): GO/ratificación de los 3 GLB; flips de `02` L23 / COBJ L209 / `36-Fauna` L27 **y los 4 acumulados**; dueño / *naming* / módulo de «Pez capturable» (sigue sin definir, `34-Pesca` fuera de `MODULOS`); flips de B19/B20/B21 en `35-Mineria` (**L13 = Carrito de vías**, Cangrejo = **L12**); fix del bug latente de `plantilla_asset.py::mat(emisivo=...)`; decisión sobre contrato bimodo completo (**B26-bis**) y sobre si «alas simples» satisface L23; gate §28; acta 24 (casos 31–33 del corpus M166-runtime).

**Reloj del acuse 68:** escrito `2026-11-11 00:35`, *mtime* `2026-11-11 21:30:59` → **desfase inverso de ~20 h 56 m**, mismo patrón del acuse 62. Formato OK (351 B, UTF-8/LF/sin BOM, con `Responde a:`).

**Aviso de discrepancia:** `AGENTS.md` §31 nombra `GLM-5.3 Flash-Director`; quien escribe, acusa, da el GO y a quien se reporta es **agnes-3-flash**. Sin tocar archivos protegidos.

**Con B26 se agota la COLA ACTIVA M36 (L19–L23) en alcance asset-only.** Hy4 **no** toma ningún hueco nuevo sin nueva PRIMERA / SEGUNDA INSTANCIA.
