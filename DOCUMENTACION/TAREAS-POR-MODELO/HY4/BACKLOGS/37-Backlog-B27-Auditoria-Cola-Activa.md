# Acta 37 — B27: auditoría de evidencia de la nueva COLA ACTIVA (acuse 71)

**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-13 15:50:00 -0300
**Canal:** mensaje **71** (acuse sustantivo de la directora: GO B26, flip L23, M36 agotada, nueva COLA ACTIVA), **72** (PRIMERA INSTANCIA al 71 + SEGUNDA INSTANCIA B27) y **73** (reporte de cierre con evidencia) · **Log:** **2412** · **Acta anterior:** 36
**Estado:** **EJECUTADO**. **Auditoría de evidencia + 1 guardia positiva nueva**. **0 assets nuevos**, **0 GLB nuevos**, **1 sonda de calibración**, **1 guardia hermana re-ejecutada**. **Cero flips**, sin QA §21.8, sin sello, sin aprobación visual, sin integración en escena.

> Cadena de actas: B22 pez tropical (`32`), B23 lagarto (`33`), B24 cabra (`34`), B25 gallina (`35`), B26 mariposa (`36`), **B27 auditoría COLA ACTIVA (`37`)**.
> **Rótulo medido antes de publicar:** 0 `B27` en backlogs HY4, 0 `Logs/2412-*`, 0 `72-*` al escribirlo, 0 `73-*`, 0 `37-*` en `BACKLOGS/`. Sin colisión. Canal por `max(real)+1` (70 → 71 director → 72 → 73); **pool de canal intacto**. Persisten dos `56-*`.
> **B27 es el primer cierre de Hy4 sin GLB nuevos**: es auditoría, no autoría. 490 GLB trackeados antes y después.

---

## 1. Estado vivo y absorción del fundador

Al reingresar (15:37): HEAD **`cfc292e`**, 27 entradas sucias, **490** GLB, canal máximo real **70**, pool **2411**, acuse **71** sin responder. Durante la ejecución el fundador preservó **`cd8306a`** (15:39:15): absorbió B26 mariposa M36 CERRADO + TANDA 17nov Hy3 + M18 ventanas ERNIE + Ling v93-99 + **flips L19–L23**.

**Medido:** `cd8306a` **no absorbió nada de B27** (ni mensaje 72, ni `verificar_columna_rota.py`, ni la sonda): los 3 paths propios estaban **SIN_VERSIONAR** al cierre. Worktree compartido con **11** entradas sucias al cierre, todas ajenas salvo los artefactos propios; **0 staged**; ninguna se arrastra al commit.

Pool: **2411** lo consumió Hy3 (`Logs/2411-hy3-qa-tanda17nov-medido_2026-11-13_15-45-00.md`, ajeno, untracked) → **2412** reservado y escrito en el mismo turno (`→ 2413`, **no commiteado**). No es un gap.

---

## 2. Acuse 71: GO B26, flips y tres discrepancias publicadas

`71-2026-11-12_04-05-00-...-acuse-70-b26-mariposa-m36-cerrado.md` — 541 B, UTF-8/LF/sin BOM, con `Responde a: HY4 - 70`, **untracked** (ajeno, intacto para el fundador, **no se versiona**). Contenido: *«GO export B26: APROBADO. 3 GLB mariposa_lunar (alta/media/baja) ratificados. Flip: L23 flippeado. M36 COLA ACTIVA AGOTADA. 8/8 cerrados… Siguientes: Columnas M25 + Semillero + Palanca. TANDA nueva cuando estés listo»*.

**Flips verificados en disco** (diff del worktree = **1 línea** por archivo): `02` **L23** `[ ] → [x]`; COBJ **L209** `[ ] → [x]`. `36-Fauna/checklist.md` L23–L27 **siguen `[ ]`** (cinco cierres sin flip).

| espejo | `[x]` | `[ ]` |
|---|---|---|
| `02` | 29 | 6 |
| COBJ | 163 | 6 |
| `36-Fauna` | 16 | 5 |
| `07-Backlog-Tanda-Blender` | 0 | 17 (*stale*) |
| `35-Mineria` | 3 | 4 |

**Tres discrepancias publicadas con cita en el 72, sin corregir:**

1. **Naming:** el 71 dice «3 GLB **mariposa_lunar**»; el artefacto real es **`36-Fauna_mariposa.glb`** × 3 LOD (`cfc292e`). No existe ningún GLB `mariposa_lunar`. Propuesta reversible al director, sin renombrar.
2. **«8/8 cerrados» inexacto:** los **6** ítems M36 (L19–L23 + L39 Cangrejo) están `[x]`, pero **`02` L38 «Pez capturable» y L30 «Palanca de puzzle» siguen `[ ]`**. Los 2 citados como cerrados no lo están en ese espejo.
3. **Contradicción interna de «Palanca»:** declarada «fuera de M36» en el mismo renglón de los 8/8 y a la vez incluida en «Siguientes: … + Palanca». Hy4 no decide cuál prevalece.

**Reloj:** escrito `2026-11-12 04:05`, *mtime* `2026-11-13 01:00:55` → **desfase +20 h 55 m 55 s**, mismo patrón inverso de los acuses 62 y 68. **Aviso de discrepancia:** `AGENTS.md` §31 nombra `GLM-5.3 Flash-Director`; quien escribe y da el GO es **agnes-3-flash**.

---

## 3. Hallazgo central: la nueva COLA ACTIVA **ya está ejecutada**

| ítem del 71 | artefactos en disco | espejos con `[ ]` | conclusión |
|---|---|---|---|
| **Columnas M25** | **9 GLB trackeados**: `25-Ruinas-Templos_columna_entera.glb` ×3 LOD + `columna_rota_alta.glb` ×3 + `columna_rota_baja.glb` ×3 (las **2 variantes de altura**). Generadores, `.blend`, capturas, logs **2311 / 2335 / 2338** | `02` **L26 / L27**, COBJ **L174 / L175** | asset **EJECUTADO**; falta **flip** |
| **Semillero** | `33-Agricultura_cultivo_brote.glb` ×3 **trackeados** (10 924 / 10 160 / 9 004 B). `HY4/33-Agricultura/checklist.md` **L7 `[x]`**. Acta **11** L27 documenta que B11 lo clasificó mal como hueco real pese a tener GLB ×3 + ficha | COBJ **L50** | asset **EJECUTADO**; falta **flip** |
| **Palanca** | `70-Interacciones_palanca_madera.glb` ×3, COBJ **L182 `[x]`** con ficha `data/construccion/piezas/palanca_madera.tres` y commit `787ab35`; COBJ L262/L353 `[x]` (rediseño v3 horquilla) | `02` **L30** | asset **EJECUTADO y ratificado**; falta **flip** |

`25-Ruinas-Templos`, `33-Agricultura` y `70-Interacciones` **están en `MODULOS`** de `exportar_godot.py`: sin fallo E-63 / T-02 pendiente.

> **0 huecos de asset nuevos en la COLA ACTIVA.** Lo pendiente son **flips** (facultad exclusiva del director, REGLA CERO) y un **hueco de verificación real**: en todo el repo sólo existía `verificar_columna_entera.py` (guardia `bpy` sobre `.blend`, 27 checks). **No existía** `verificar_columna_rota.py`, ni guardia de `cultivo_brote`, ni de `palanca_madera`. Los 6 GLB de columna rota (exportados en B10bis / log 2335) **nunca** se habían verificado sobre su BIN.

---

## 4. SEGUNDA INSTANCIA B27: qué se hizo y qué no

**Fuente de autorización:** COLA ACTIVA del acuse **71** + orden directa del fundador («continua trabajando», 15:36 -0300). Se toma el **primer ítem** («Columnas M25») en su hueco **real de verificación**.

**Sí:** sonda de calibración sobre **12 GLB**, guardia positiva nueva sobre los **6 GLB** de `columna_rota`, re-ejecución de la guardia hermana en Blender, reporte de evidencia para flips, cierre documental y commit selectivo.

**No:** re-autorar assets, aplicar flips, editar `02` / COBJ / `36-Fauna` / `07`, tocar `CHECKLIST-GLOBAL.md`, `AGENTS.md`, `quality.yml`, `project.godot`, `exportar_godot.py`, `plantilla_asset.py`, `verificar_columna_entera.py` ni el pool de canal. **No se exportó ningún GLB**: 490 antes y 490 después.

---

## 5. Sonda de calibración (12 GLB, BIN real)

`Temp/hy4_b27_glb_probe_20261113.py` (+ `.json` / `.txt`), decoder **autocontenido** de `verificar_mariposa.py` (B26). Ejes glTF Y-up: `p[0]`=X, `p[1]`=**ALTURA**, `p[2]`=**LATERAL**.

| grupo | ALTA / MEDIA / BAJA |
|---|---|
| `columna_rota_alta` | tris **464/464/303**, mats 5/5/4, mallas 12/5/4, verts 857/857/605, altura 2.1450/2.1450/**2.1457**, tope 2.1900/2.1900/**2.1907**, apoyo 28/28/24 |
| `columna_rota_baja` | tris **464/464/304**, mats 5/5/4, mallas 12/5/4, verts 857/857/626, altura 1.4450/1.4450/**1.4457**, tope 1.4900/1.4900/**1.4907**, apoyo 28/28/24 |
| `cultivo_brote` | tris 152/152/102, mats 3/3/3, alt 0.045..0.1998, apoyo 13/13/10 |
| `palanca_madera` | tris 516/516/66, mats 3/3/3, alt 0.045..0.6155, apoyo 4/4/4 |

**Diferencia entre variantes = 0.7000 m exactos en los 3 LOD.** Huella `x[-0.5493..0.9051]` = 1.4544 y `lat[-0.4668..0.5542]` = 1.0210 → **E-50 OK** (≥ 0.30 en ambos ejes). Materiales: 4 base + `MAT_ColRota_Glifo` **sólo** en ALTA/MEDIA (poda deliberada). **12 sha distintos** medidos. Todo **dato medido**, no estimado.

**Deriva heredada publicada como dato, NO consagrada:** las variantes BAJA tienen tope `2.1907 / 1.4907` (deriva `+0.0007 m` por *decimate* sobre cajas disjuntas, familia B18 / acta 28) y niveles de altura espurios. La guardia **no exige** esos niveles: exige la **forma esencial** (altura dentro de `1e-3`, apoyo, silueta, materiales, LOD por poda). No se corrige el asset *legacy* sin GO; una aserción que fijara el valor equivocado consagraría el bug.

---

## 6. Guardia positiva nueva `verificar_columna_rota.py`

Python puro **autocontenido** (no depende del decoder de B26 ni de la guardia `bpy` hermana): parsea GLB, lee `accessors` / `bufferViews` / `byteStride`, decodifica `POSITION` real del BIN y aplica matrices **column-major**. **18 checks × 6 GLB + 6 globales = 114**.

`CHECKS_MINIMOS = 114` y `BLOQUES_MINIMOS = 6` se fijaron **después** de medir el PISO **en verde** con `--piso 0` (regla: medir antes de escribir la cifra): `114/114/0 · 6 bloques · RC=0`.

**Check clave (anti-copia):** `C17` exige que cada GLB tenga la altura de **su propia** variante; `G2` exige diferencia **0.7000 m** en los 3 LOD; `G5` exige 6 sha distintos; `G6` exige altura consistente entre LOD (deriva ≤ 0.001 m, no colapso). «2 variantes de altura» no pueden ser 2 copias.

| ruta | resultado |
|---|---|
| PISO `--piso 0` | `114/114/0 BLOQUES=6 RC=0` |
| VERDE *(default)* | `114/114/0 BLOQUES=6 PISO=114 RC=0` |
| ROJO `--inyectar` | `114/108/6 RC=1`, **9 vértices** mutados; fallos `C8/C9/C11/C17/G2/G6` = **confusión de variantes** |
| CIEGO `--solo` | `24 checks / 19 pasados / 5 fallos / 1 bloque / RC=3` |

**Medido con precisión, no estimado:** el tope **resultante** del GLB inyectado es **2.1649** (no 1.4907) porque otros vértices del fuste quedan por encima; aun así `G2` cae a **0.6742**. Se publica el dato real, no el valor que «debería» dar. **GLB publicados intactos** tras el ROJO (6 sha sin cambios): la inyección escribe **solo** en `Temp/`.

**Falso rojo medido y corregido (C18):** la primera versión exigía `Basa/Fuste/Corona` en **todos** los LOD y fallaba en 4 bloques. Medición: la **FASE 1** de `generar_variante.py` **renombra** los nodos a `SM_ColRota_M_ColRota_<Material>` en MEDIA (5 grupos) y BAJA (4). **No se relajó** el check: ahora exige la estructura **real** de cada LOD.

**Guardia hermana re-ejecutada en Blender 4.2** (es `bpy`, **no** corre con `python`): `verificar_columna_entera.py` → `CHECKS=27 PASADOS=27 FALLOS=0 MINIMO=27 BLOQUES=3 RC=0`. Dato **medido en este cierre**, no heredado de 2026-11-06.

---

## 7. Formatos y gate §28

Log **2412**: **ASCII puro** (0 bytes > 127), **256 CRLF**, 0 LF/CR sueltos, sin BOM, **11/11 señales positivas**. Mensajes 72/73, acta 37, guardia, sonda y memoria: UTF-8 / LF / sin BOM / 0 CR sueltos / 0 `U+FFFD`. `py_compile` de guardia y sonda: **RC=0**.

**Gate §28:** ROJO en HEAD (RC=1) por BOM / `U+FEFF` **ajenos**; con filtro correcto, **0 paths propios de B27** en rojo. **Trampa de medición del filtro publicada:** un primer `grep '7[23]-'` confundió dos carpetas ajenas `73-Coleccionables/checklist.md` (Crouton Alpha y Glyph Cluster) con posibles mensajes propios `73-*`. No eran falsos positivos **del gate** sino **de mi patrón**: esos archivos sí están en rojo y son ajenos. Re-medido con patrón explícito → 0 paths propios. Reportado, **sin tocar**.

---

## 8. Cierre: alcance y deuda abierta

**Se versionan** (commit selectivo, *pathspec* explícito, **sin `git add -A`**): `verificar_columna_rota.py`, log 2412, acta 37, mensajes **72** y **73** = **5 paths**. **No hay GLB nuevos**: B27 es auditoría, no autoría. **Scratch conservado en `Temp/`** (no se borra): sonda `.py/.json/.txt` y GLB inyectado. Si el fundador vuelve a absorber scratch (ya lo hizo en B22/B25/B26), la afirmación «no versionado» quedará desactualizada **por un commit ajeno**, no por Hy4.

**0 flips**, sin QA §21.8, sin sello, sin aprobación visual final, sin integración en escena, sin GO de export, sin push, sin `--amend`. No se tocó ningún checklist ni archivo protegido.

**Propuesta de flips al director (con cita, SIN aplicar):**

- `02` **L26** «Columna rota (2 variantes de altura)» → 9 GLB trackeados, logs 2311/2335/2338, **guardia 114/114/0 nueva**.
- `02` **L27** «Columna entera con capitel» → 3 GLB trackeados, **guardia hermana 27/27/0 re-ejecutada en verde**.
- `02` **L30** «Palanca de puzzle» → 3 GLB + ficha `.tres` + COBJ L182 `[x]`.
- COBJ **L174 / L175** (columnas) y **L50** (Semillero) → los 3 GLB de `cultivo_brote` medidos por BIN en §5.
- `36-Fauna/checklist.md` **L23–L27**: **cinco cierres sin flip** acumulados.
- `35-Mineria` **L10–L13**: deuda viva de B19/B20/B21 (**L13 = Carrito de vías**, Cangrejo = **L12**).

**Otras decisiones abiertas:** GO/ratificación de export (B26 ya tiene GO del 71; B27 no exporta); naming `mariposa_lunar` vs `36-Fauna_mariposa.glb`; ambigüedad de «Palanca» y exactitud del «8/8»; dueño / *naming* / módulo de «Pez capturable» (`34-Pesca` fuera de `MODULOS`); fix del bug latente de `plantilla_asset.py::mat(emisivo=...)` (B26); gate §28; acta 24 (casos 34–36 del corpus M166-runtime); contrato bimodo completo B26-bis.

**«TANDA nueva cuando estés listo» del acuse 71:** Hy4 **no** toma ningún hueco nuevo sin nueva PRIMERA / SEGUNDA INSTANCIA. Queda a la espera del acuse al **73**.
