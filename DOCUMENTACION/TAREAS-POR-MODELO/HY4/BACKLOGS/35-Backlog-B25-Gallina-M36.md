# Acta 35 — B25/L22: Gallina, M36

**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-11 21:25:00 -0300
**Canal:** mensaje **65** (SEGUNDA INSTANCIA por orden del fundador + toma de B25), **66** (acuse de la directora, ajeno, llegado durante la ejecución) y **67** (PRIMERA INSTANCIA al 66 + reporte de cierre con evidencia) · **Log:** **2401** · **Acta anterior:** 34
**Origen:** `DOCUMENTACION/TAREAS-POR-MODELO/HY4/BACKLOGS/02-Backlog-Pendientes-Assets.md` **L22** `- [ ] Gallina`, `HY4/36-Fauna/checklist.md` **L26** y `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` **L208**.
**Estado:** **EJECUTADO**. 1 generador + 1 guardia nueva + 1 sonda geométrica + 1 sonda de calibración BIN + 1 baseline sha256 + **3 `.blend`** + **18 PNG** + **3 JPG** + **3 GLB** + **3 `.glb.import`**. **Cero flips**, sin QA §21.8, sin sello, sin aprobación visual, sin integración en escena. Export sin GO explícito → **a ratificar**.

> Cadena de actas: B15 (`25`) … B22 pez tropical (`32`), B23 lagarto (`33`), B24 cabra (`34`), **B25 gallina (`35`)**.
> **Rótulo medido antes de publicar:** 0 `B25` en backlogs HY4, 0 `Logs/2401-*`, 0 `65-*` / `67-*` propios en el canal, 0 `35-*` en `BACKLOGS/`. Sin colisión. Canal por `max(real)+1` (64 → 65 → 66 director → 67); **pool de canal intacto**. Persisten dos `56-*`.

---

## 1. Fuente de autorización y el acuse 66

Al reingresar: HEAD **`ff85340`**, **0 staged**, **484** GLB, canal máximo real **64** (cierre propio de B24), **sin acuse nuevo al 64**, pool **2400**. Worktree con 2 entradas sucias ajenas, intactas.

La **SEGUNDA INSTANCIA** la da la **orden directa del fundador** («continua trabajando», 21:11 -0300) sobre la **COLA ACTIVA M36 L21–L23** fijada por el acuse **62** (cuya PRIMERA INSTANCIA ya se cumplió en el **63**): L21 se cerró en B24, quedaban L22 y L23 → se toma **L22**.

**Desviación documentada:** el mensaje **64** cerraba con «Hy4 no los toma sin nueva PRIMERA / SEGUNDA INSTANCIA». Esa instancia **es la orden del fundador**. No se inventó un acuse del director ni se reinterpretó el silencio del canal. Si la directora objeta, B25 queda para ratificación o reversa (es un commit selectivo, reversible).

**Acuse 66 de la directora, llegado DURANTE la ejecución:**

> «Confirmo: B25 Gallina en ejecucion. Cuando cierres, reportame con evidencia y flippeo L21.»

- 296 B, UTF-8/LF/sin BOM, `Responde a: HY4 - 65`. Fecha escrita `2026-11-11 00:20`, mtime `21:15:58` → **~20 h 56 m de desfase**, mismo patrón inverso del 62.
- El **67** es simultáneamente la **PRIMERA INSTANCIA al 66** y el **reporte con evidencia** que el 66 pidió.
- **Interpretación publicada con cita, sin corregir al director:** dice «flippeo **L21**», y **L21 es Cabra (B24)**, no L22 (Gallina, B25). Es el flip pendiente de B24, no el de este cierre. Queda a decisión de la directora.

**Deuda de flips acumulada, sin tocar (REGLA CERO):** B24 **no fue flippeado**: `02` L21 `[ ]`, COBJ L207 `[ ]`, `36-Fauna` L25 `[ ]`. El tercer espejo acumula **cuatro cierres sin flip**: L23 (B22), L24 (B23), L25 (B24), L26 (B25). Siguen los 4 `[ ]` de `35-Mineria` (Cangrejo L12, Carrito L13) y `07` en 0/17. «Pez capturable» sigue sin dueño. **Aviso de discrepancia nº 66**: `AGENTS.md` §31 nombra `GLM-5.3 Flash-Director`; quien escribe y da el GO es **agnes-3-flash**.

**Numeración de logs:** el **2400** lo consumió Hy3 (`2400-Hy3-TANDA15nov-QA-Volumen4`); se reservó **2401** (`2401 → 2402`, pool no commiteado).

---

## 2. Hueco real y hueco de spec (medidos)

| medición | valor |
|---|---|
| `02` L22 / `36-Fauna` L26 / COBJ L208 | `- [ ] Gallina` |
| GLB / `.blend` / generador `*gallina*` | **0 / 0 / 0** |
| GLB nominales de `36-Fauna` | **11**: ninguno es gallina → **no es duplicado** |
| `01-Requerimientos.md` L27–L57 | **27 especies, 0 menciones de gallina** → **sin ancla de spec real**, a diferencia de B21 (L29) y B24 (L48) |
| `grep -rniE 'gallina\|pollo\|corral\|huevo' DOCUMENTACION/33-Agricultura/` | **0 hits** |
| `grep -rniE '\b(gallina\|gallo\|poll[oa]s?)\b' DOCUMENTACION/` | **11 hits**, todos en backlogs/checklists/actas de HY4; **0** definen cotas, silueta, materiales, paleta, rareza o comportamiento |

**Falso positivo medido y excluido:** la alternativa `ave` suelta da **15 802 hits** (`ave` ⊂ «su**ave**» / «cl**ave**» / «n**ave**»; `echo 'suave' | grep -ci ave` = 1). Se usaron límites de palabra. Familia de B20 (`v[ií]as`), B23 (`salamandra_ancestral`) y B24 (`chivo ⊂ archivo`).

**`GUIA-BLENDER/10-animales-bimodo.md` §10.2 NO aplica:** define el **ave BIMODO** (2 poses, `_Ala_L/R`, `_Pata_0/1`, `_Cola`, cuaterniones medidos). **L22 «Gallina» no pide animación**, a diferencia de **L23 «Mariposa (alas simples para animar)»**. B25 es un **prop estático de diorama**; se publica la distinción para no aplicar un contrato de rigs ajeno.

⇒ **Todas las cotas son DECISIÓN DE AUTORÍA**; rareza/bioma las decide el director. Hy4 no edita `01-Requerimientos.md` ni la guía. `36-Fauna` YA está en `MODULOS` (L70): no se crea módulo ni se toca el exportador.

---

## 3. Autoría (silueta de ave, no copia de B23/B24)

`crear_gallina_lowpoly.py`, Blender 4.2 headless con `--python-exit-code 1`. `Z_APOYO=0.045`, E-24 sobre vértices reales, E-44 sólo `SM_*`, E-68 dimensión final, E-27 sin parents.

| parte | decisión de autoría |
|---|---|
| Rodela | 3 franjas `0.44 × 0.10 × 0.04`, **12 vértices apoyados**, huella `0.44 × 0.36`; E-50 con `min_fp=0.30` / `min_toca=8` DEFAULT **sin relajar** |
| Cuerpo / cabeza | 3 cajas escalonadas (topes `0.155/0.225/0.265`) + cabeza con hocico `x=0.35` |
| Apéndices críticos (6) | **2 patas + 2 alas laterales (`y=±0.12`) + cresta + cola levantada (`x=-0.28`)** → silueta de ave, geométricamente distinta del lagarto y la cabra |
| Detalles (6) | 2 ojos + 1 pico (`x=0.38`) + 3 plumas (`y=0.285`), todos podables `< 1e-4` |
| Cresta y cola **apoyadas** | base de cresta `0.245` = tope de la cabeza; base de cola `0.085` = tope de la rodela. **Lección del hallazgo visual B23** aplicada desde el diseño |
| Zona vacía | `(0.27, 0.28)` sin niveles (sólo hay vértices en `0.265`, `0.285`, `0.335`) |
| ALTA | `10 obj / 7 mats / 228 tris`, `z=[0.0450..0.3350]`, `toca=12`, `fp=0.44×0.36` |

**1 material por crítica** → en BAJA quedan exactamente **4** materiales, sin disparar la poda de materiales del generador. **Lección B18 aplicada:** los 6 detalles son objetos sueltos con volumen `< 1e-4`, FASE 0 los poda en BAJA y el DECIMATE actúa sobre **0 mallas**. Ningún sufijo `PROTEGIDAS`.

---

## 4. Coste M166, capturas y revisión de autoría

| LOD | objetos | tris | mats | `chk_asset.py` contra SU perfil |
|---|---|---|---|---|
| ALTA | 10 | 228 | 7 | **OK** `10/16 · 228/6000 · 7/12` |
| MEDIA | 7 | 228 | 7 | **OK** `7/8 · 228/1500 · 7/8` |
| BAJA | 4 | 156 | 4 | **OK** `4/6 · 156/700 · 4/4` |

Sonda `Temp/hy4_gallina_sonda_20261111.py`: ALTA/MEDIA **114 caras**, BAJA **78**, `tris=0 ngons=0 inclinadas=0 DEFECTOS=0`, `SONDA_B25 FIN total_defectos=0 RC=0`. **Deriva `.blend → GLB = 0`** (`228/228/156` medidos en ambos lados) → se propone al acta 24 como casos **28–30** del corpus M166-runtime.

**18 PNG** orbitales y **3 hojas JPG** «con 6 capturas» (anti E-30/E-57/E-66). Revisión de autoría sobre ALTA y BAJA: 6 vistas distintas y no blancas; se lee **ave** (cresta mostaza apoyada, pico, 2 alas, cola levantada, cuerpo blanco, ojos negros, motas rojas, rodela gris); en BAJA sólo desaparecen ojos/pico/motas, conservando cuerpo, cabeza, cresta, alas, cola, patas y rodela **sin deformación**. No se repitió el defecto de B23. ⇒ **NO QA, NO sello, NO aprobación visual final**.

---

## 5. Export a Godot (sin GO → **a ratificar**)

| control | resultado medido |
|---|---|
| Baseline | `Temp/hy4_b25_baseline_glb.sha256`, **484** GLB |
| DRY previo | `{"exportados": 3, "saltados": 28, "errores": 0}`, los 3 son **sólo** gallina × 3 LOD. RC=0 |
| Export real | `{"exportados": 3, "saltados": 28, "errores": 0}`, `10/7/4` objetos. RC=0 |
| Post | **484 → 487**; `sha256sum -c`: **0 mutados, 0 faltantes**; GLB de 25 388 / 21 836 / 15 548 B |
| DRY posterior | `{"exportados": 0, "saltados": 31, "errores": 0}` RC=0 → **idempotente** |

3 `.glb.import` por **Godot 4.7.2 `--headless --import`** (RC=0), UIDs `dapqa808t7uav` / `opl6iqmyajds` / `c2disftj2w3ho`. Ignorados por `.gitignore:3`: **no se versionan**.

---

## 6. Guardia positiva sobre el BIN (`verificar_gallina.py`)

Python puro **autocontenido**: `POSITION` real, matrices **column-major**, Y-up, inversa **Cramer 3x3** para inyectar. **18 checks × 3 GLB + 4 globales = 58**. Calibración con `Temp/hy4_gallina_glb_probe_20261111.py` (JSON + TXT). `CHECKS_MINIMOS = 58` / `BLOQUES_MINIMOS = 3` fijados **después** de medir el piso en verde con `--piso 0`: `58/58/0 · BLOQUES=3 · RC=0`.

| ruta | resultado |
|---|---|
| PISO | `58/58/0`, **RC=0** |
| VERDE | `58/58/0`, PISO=58, **RC=0** |
| ROJO `--inyectar` | `58/51/7`, **RC=1**; 12 vértices mutados; fallos **C8/C9/C11/C12/C14/C18/G3**; GLB publicado `sha=0680716b1b47` **INTACTO** |
| CIEGO `--solo ...` | `22 checks / 18 pasados / 4 fallos / 1 bloque`, **RC=3** |

**C14** exige silueta de ave (lomo, cresta, hocico, cola, **alas en `z=±0.12`**, xr/zr). **C16** exige 4 materiales base en los 3 LOD y `Ojo/Pico/Pluma` sólo en ALTA/MEDIA. **C17** mide la poda real (ojos `24/24/0`, plumas `36/36/0`). **C18** protege cresta+cola apoyadas (36 vértices en `y=0.245`, 12 en la cima).

---

## 7. Formatos, gate §28 y alcance del commit

Log **2401**: ASCII puro, **276 CRLF**, 0 LF/CR sueltos, sin BOM, 15 358 B, **9/9 señales positivas**. Mensajes 65/67, acta 35, generador, guardia y sondas: **UTF-8, LF, sin BOM, 0 `U+FFFD`**. `py_compile` **RC=0**. Gate §28 **ROJO** (RC=1) por BOM / `U+FEFF` **ajenos**, 0 paths propios. Reportado, sin tocar.

| se versiona (commit selectivo) | no se versiona |
|---|---|
| 3 GLB, `crear_gallina_lowpoly.py`, `verificar_gallina.py`, log 2401, acta 35, **mensajes 65 (toma) y 67 (cierre / PRIMERA INSTANCIA al 66)** = **9 paths** | **acuse 66 de la directora (ajeno, intacto)**, 3 `.blend`, 18 PNG, 3 JPG, 3 `.glb.import` |

Scratch **conservado** en `Temp/`. **Sin flips**, sin QA §21.8, sin sello, sin aprobación visual final, sin integración en escena, sin GO, sin push, sin `--amend`, sin `git add -A`.

---

## 8. Deuda abierta (decisión del director)

1. **GO / ratificación** de los 3 GLB de B25 (export **sin GO**).
2. **Flips** de `02` L22, COBJ L208, `36-Fauna` L26; **y los acumulados** L23 (B22), L24 (B23), L25 (B24) → **cuatro cierres sin flip** en el tercer espejo.
3. **El 66 anuncia «flippeo L21»** = Cabra (B24), no Gallina (B25): interpretación publicada con cita, decisión de la directora.
4. **Dueño / naming / módulo** de «Pez capturable»; flips de B19/B20/B21 en `35-Mineria` (L13 = Carrito, Cangrejo = L12).
5. **Rareza / bioma** de la gallina: spec inexistente.
6. Gate §28 y acta 24 (casos 28–30 del corpus M166-runtime).
7. **COLA ACTIVA siguiente: M36 L23 «Mariposa»**, que **sí pide «alas simples para animar»** → requiere definir si aplica el contrato de ave bimodo de `GUIA-BLENDER/10`. Hy4 **no la toma** sin nueva PRIMERA / SEGUNDA INSTANCIA. Anclaje real: `Mariposa Lunar` L45.
