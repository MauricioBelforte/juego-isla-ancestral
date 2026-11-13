# Acta 38 — B28: guardia sobre el BIN de `columna_entera` (M25)

**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-13 16:25:00 -0300
**Canal:** mensaje **74** (acuse sustantivo: B27 OK + TANDA «Columna rota + Columna entera M25»), **75** (PRIMERA INSTANCIA al 74 + SEGUNDA INSTANCIA B28) y **76** (reporte de cierre con evidencia) · **Log:** **2414** · **Acta anterior:** 37
**Estado:** **EJECUTADO**. **Verificación sobre el artefacto que Godot consume**. **0 assets nuevos**, **0 GLB nuevos**, **1 guardia positiva nueva (`58/58/0`)**, **1 sonda de calibración**, **2 guardias hermanas re-ejecutadas**. **Cero flips**, sin QA §21.8, sin sello, sin aprobación visual, sin integración en escena.

> Cadena de actas: B22 pez tropical (`32`), B23 lagarto (`33`), B24 cabra (`34`), B25 gallina (`35`), B26 mariposa (`36`), B27 auditoría COLA ACTIVA (`37`), **B28 columna_entera GLB (`38`)**.
> **Rótulo medido antes de publicar:** 0 `B28` en backlogs HY4, 0 `Logs/2414-*`, 0 `75-*` al escribirlo, 0 `76-*`, 0 `38-*` en `BACKLOGS/`. Sin colisión. Canal por `max(real)+1` (73 → 74 director → 75 → 76); **pool de canal intacto**. Persisten dos `56-*`.
> Segundo cierre consecutivo **sin GLB nuevos**: 490 trackeados antes y después.

---

## 1. Estado vivo

Al reingresar (16:16): HEAD **`35ed941`**, **24** entradas sucias ajenas, **490** GLB, canal máximo real **74**, pool **2414**, acuse **74** sin responder. Al cierre: **32** entradas sucias, todas ajenas salvo los artefactos propios de B28; **0 staged**; ningún commit ajeno absorbió la guardia B28 (medido: estaba `SIN_VERSIONAR`).

Pool: **2413** lo consumió Hy3 (`Logs/2413-hy3-qa-tanda18nov-medido_2026-11-13_16-00-00.md`), **2414** reservado y escrito en el mismo turno (`→ 2415`, **no commiteado**). Sin commits nuevos de la flota.

---

## 2. Acuse 74 y la discrepancia de la TANDA

`74-2026-11-13_05-05-00-...-acuse-73-b27.md` — 355 B, UTF-8/LF/sin BOM, con `Responde a: HY4 - 73`, **untracked** (ajeno, intacto para el fundador, **no se versiona**):

> «Confirmo: B27 auditoria OK. Guardia 114/114/0. Sin assets nuevos, solo verificacion. **Siguientes: Columna rota + Columna entera M25. Ya estan en tu TANDA.**»

**Reloj:** escrito `2026-11-13 05:05`, *mtime* `2026-11-13 16:00:42` → **desfase +10 h 55 m 42 s**. Es un **tercer patrón** distinto del +3 h (47/50/53) y del +20 h 56 m (62/68/71). Publicado, sin corregir.

**Discrepancia publicada con cita en el 75:** los 2 ítems de la TANDA **ya están ejecutados y trackeados**:

| ítem | artefactos | verificación existente |
|---|---|---|
| Columna rota (2 variantes) | **6 GLB**, generador, `.blend`, capturas, logs **2311/2335/2338** | `verificar_columna_rota.py` **114/114/0** (B27), diferencia **0.7000 m** en los 3 LOD |
| Columna entera con capitel | **3 GLB** (38 248 / 29 596 / 23 392 B), generador, `.blend`, capturas, log **2338** | `verificar_columna_entera.py` **27/27/0**, pero es **`bpy` sobre `.blend`** |

Lo único pendiente en los espejos son **flips** (`02` L26/L27, COBJ L174/L175), facultad exclusiva del director (**REGLA CERO**). Recount al cierre: `02` 29/6 · COBJ 163/6 · `36-Fauna` 16/5 (cinco cierres sin flip) · `35-Mineria` 3/4 · `33-Agricultura` 11/0 · `07` 0/17.

---

## 3. Hueco real medido en todo el repo

`find tools/mcp/blender-mcp -iname '*verificar*columna*'` = **exactamente 2 guardias**: `verificar_columna_rota.py` (sobre el **BIN** de 6 GLB, B27) y `verificar_columna_entera.py` (sobre los **3 `.blend`** con `bpy`).

> **Los 3 GLB de `columna_entera` que Godot importa nunca habían sido verificados sobre su BIN.** Y la guardia `bpy` existe porque el **2026-11-06** la BAJA pasaba los tres presupuestos M166 (342/700 tris, 4/6 obj, 4/4 mats) con el **ÁBACO COLAPSADO** por el *decimate*: 0 caras laterales completas, vértices a `2.8267 / 2.8733` (media losa) y aire bajo la losa. `chk_asset.py` mide **COSTE**, no **FORMA**, y un verde sobre el `.blend` **no se hereda al GLB** (B12/B13). Es el mismo hueco que B27 cerró para `columna_rota`, y está **dentro de la TANDA del 74**.

---

## 4. SEGUNDA INSTANCIA B28: qué se hizo y qué no

**Fuente de autorización:** TANDA explícita del acuse **74** + orden directa del fundador («segui», 16:16 -0300). Se toma el **segundo ítem** en su hueco **real de verificación**.

**Sí:** sonda sobre 3 GLB, guardia nueva sobre el BIN, re-ejecución de las 2 guardias hermanas, reporte de evidencia para flips, cierre documental y commit selectivo.

**No:** re-autorar assets, aplicar flips, editar `02` / COBJ / `36-Fauna` / `07`, tocar `CHECKLIST-GLOBAL.md`, `AGENTS.md`, `quality.yml`, `project.godot`, `exportar_godot.py`, `plantilla_asset.py`, `verificar_columna_entera.py`, `generar_variante.py` ni el pool de canal. **No se exportó ningún GLB.**

---

## 5. Sonda de calibración (3 GLB, BIN real)

`Temp/hy4_b28_glb_probe_20261113.py` (+ `.json` / `.txt`), decoder **autocontenido** de `verificar_columna_rota.py` (B27). Replica sobre **triángulos** del BIN las mediciones `caras_losa()` / `caras_equino()` de la guardia `bpy`.

| LOD | tris | mats | mallas | nodos | verts | alt | sha |
|---|---|---|---|---|---|---|---|
| ALTA | 492 | 4 | 13 | 13 | 890 | 0.0450..3.0000 | `160a839654ed` |
| MEDIA | 492 | 4 | 5 | 5 | 890 | 0.0450..3.0000 | `b313ced9f3bc` |
| BAJA | 348 | 4 | 5 | 5 | 667 | 0.0450..3.0000 | `32d475ed4c23` |

- **Huella de APOYO = 1.0000 × 1.0000** con **16 pares / 48 vértices** en los 3 LOD (spec 1×1, E-50 OK). Medido sobre vértices en `alt=0.045`, **no** sobre el bbox global (los 4 glifos sobresalen 14 mm).
- **Caras laterales completas: ÁBACO = 4, REMATE = 4, EQUINO = 64** en los 3 LOD. Umbrales **medidos en el BIN**, no heredados de la guardia `bpy`: el glTF triangula, así que el conteo se mide, no se supone.
- **Banda anti-colapso `(2.79, 2.91)`: 0 niveles espurios y 0 vértices a media losa** en los 3 LOD → el ábaco **no** está colapsado.
- Niveles estructurales `0.045 / 2.78 / 2.92 / 3.00` presentes. 4 materiales `MAT_ColEnt_*`. Nodos ALTA: 13 originales; MEDIA/BAJA: 5 del merge FASE 1 (3 grupos `M_ColEnt_*` + 2 `_NOFUNDIR`). **3 sha distintos**.

---

## 6. Guardia positiva nueva `verificar_columna_entera_glb.py`

Python puro **autocontenido**: parsea GLB, lee `accessors` / `bufferViews` / `byteStride`, decodifica `POSITION` + `INDICES` reales del BIN, aplica matrices **column-major** y calcula normales de triángulo. **Complementa** (no sustituye) a la guardia `bpy`. **18 checks × 3 GLB + 4 globales = 58**.

`CHECKS_MINIMOS = 58` y `BLOQUES_MINIMOS = 3` se fijaron **después** de medir el PISO **en verde** con `--piso 0` (regla: medir antes de escribir la cifra): `58/58/0 · 3 bloques · RC=0`.

**Checks clave:** `C9` huella de apoyo 1×1 · `C10` banda anti-colapso sin niveles ni vértices a media losa · `C11` niveles estructurales · `C12/C13/C14` caras laterales completas de ÁBACO/REMATE/EQUINO · `C17` estructura de nodos **real por LOD** · `C18` capitel no colapsado.

| ruta | resultado |
|---|---|
| PISO `--piso 0` | `58/58/0 BLOQUES=3 RC=0` |
| VERDE *(default)* | `58/58/0 BLOQUES=3 PISO=58 RC=0` |
| ROJO `--inyectar` | `58/53/5 RC=1`, **24 vértices** mutados: mueve el plano `alt=2.92` a **`2.8267`** (dentro de la banda anti-colapso) + `+0.0133` lateral. Fallos `C10` (nivel espurio `2.8267` y 24 vértices a media losa), `C11`, `C12` (ÁBACO=0), `C13` (REMATE=0), `G2`. **Es exactamente el defecto real de 2026-11-06** |
| CIEGO `--solo` | `22 checks / 18 pasados / 4 fallos / 1 bloque / RC=3` |

**GLB publicados intactos** tras el ROJO (3 sha sin cambios): la inyección escribe **solo** en `Temp/`.

**Guardias hermanas re-ejecutadas en este cierre** (datos medidos, no heredados):

- `verificar_columna_entera.py` con `blender 4.2 -b` (es `bpy`, **no** corre con `python`): **27/27/0, RC=0**.
- `verificar_columna_rota.py` (B27): **114/114/0, RC=0**.

> **TANDA M25 cubierta por 3 guardias = 199 checks en verde** (114 + 58 + 27) sobre 2 artefactos distintos (BIN y `.blend`) según corresponda.

---

## 7. Formatos y gate §28

Log **2414**: **ASCII puro** (0 bytes > 127), **219 CRLF**, 0 LF/CR sueltos, sin BOM, **11/11 señales positivas**. Mensajes 75/76, acta 38, guardia, sonda y memoria: UTF-8 / LF / sin BOM / 0 CR sueltos / 0 `U+FFFD`. `py_compile` de guardia y sonda: **RC=0**.

**Gate §28:** ROJO en HEAD (RC=1) por BOM / `U+FEFF` **ajenos**; con filtro explícito, **0 paths propios de B28** en rojo. Reportado, **sin tocar**.

---

## 8. Cierre: alcance y deuda abierta

**Se versionan** (commit selectivo, *pathspec* explícito, **sin `git add -A`**): `verificar_columna_entera_glb.py`, log 2414, acta 38, mensajes **75** y **76** = **5 paths**. **Sin GLB nuevos**. **Scratch conservado en `Temp/`** (no se borra): sonda `.py/.json/.txt` y GLB inyectado. Si el fundador vuelve a absorber scratch (ya lo hizo en B22/B25/B26), la afirmación «no versionado» quedará desactualizada **por un commit ajeno**, no por Hy4.

**0 flips**, sin QA §21.8, sin sello, sin aprobación visual final, sin integración en escena, sin GO de export, sin push, sin `--amend`. No se tocó ningún checklist ni archivo protegido.

**Propuesta de flips al director (con cita, SIN aplicar):**

- `02` **L26** «Columna rota (2 variantes de altura)» → 6 GLB trackeados, guardia B27 **114/114/0** sobre el BIN, logs 2311/2335/2338.
- `02` **L27** «Columna entera con capitel» → 3 GLB trackeados, guardia B28 **58/58/0** sobre el BIN + guardia `bpy` **27/27/0** sobre los `.blend`.
- COBJ **L174 / L175**: mismos 2 ítems en el espejo global.
- `02` **L30** «Palanca de puzzle» y COBJ **L50** «Semillero»: evidencia B27.
- `36-Fauna` **L23–L27**: **cinco cierres sin flip** acumulados (B22–B26).
- `35-Mineria` **L10–L13**: deuda B19/B20/B21 (**L13 = Carrito de vías**, Cangrejo = **L12**).

**Otras decisiones abiertas:** definir si la TANDA del 74 debe entenderse como **flips** (su facultad), **re-autoría** (requiere GO explícito) o **verificación** (lo ejecutado en B27/B28) — publicado en el 75 sin bloquear; naming `mariposa_lunar` vs `36-Fauna_mariposa.glb`; ambigüedad de «Palanca» y exactitud del «8/8» del acuse 71; dueño / *naming* / módulo de «Pez capturable» (`34-Pesca` fuera de `MODULOS`); fix del bug latente de `plantilla_asset.py::mat(emisivo=...)` (B26); gate §28; acta 24 (casos 37–39 del corpus M166-runtime); contrato bimodo completo B26-bis.

**Guardias que SIGUEN faltando fuera de la TANDA:** `cultivo_brote` y `palanca_madera` (medido en B27). Hy4 **no** las toma sin nueva PRIMERA / SEGUNDA INSTANCIA. Queda a la espera del acuse al **76**.

**Aviso de discrepancia:** `AGENTS.md` §31 nombra `GLM-5.3 Flash-Director`; quien escribe, acusa, da el GO y a quien se reporta es **agnes-3-flash**. Sin tocar archivos protegidos.
