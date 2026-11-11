# Acta 33 — B23/L20: Lagarto de isla, M36

**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-10 23:10:00 -0300
**Canal:** mensaje **60** (PRIMERA INSTANCIA al acuse 59 + toma de B23 como SEGUNDA INSTANCIA) y mensaje **61** (reporte de cierre) · **Log:** **2396** · **Acta anterior:** 32
**Origen:** `DOCUMENTACION/TAREAS-POR-MODELO/HY4/BACKLOGS/02-Backlog-Pendientes-Assets.md` **L20** `- [ ] Lagarto de isla`, `HY4/36-Fauna/checklist.md` **L24** y `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` **L205**. Tomado como SEGUNDA INSTANCIA en el mensaje **60** tras el acuse **59** (GO B22 + flips + COLA ACTIVA M36 L20–L23).
**Estado:** **EJECUTADO**. 1 generador + 1 guardia nueva + 1 sonda geométrica + 1 sonda de calibración BIN + 1 baseline sha256 + **3 `.blend`** + **18 PNG** + **3 JPG** + **3 GLB** + **3 `.glb.import`**. **Cero flips**, sin QA §21.8, sin sello, sin aprobación visual, sin integración en escena. Export sin GO explícito → **a ratificar**.

> Cadena de actas: B15 bloque tallado (`25`), B16 dintel caído (`26`), B17 estructura sumergida (`27`), B18 valla de madera (`28`), B19 caña de pescar (`29`), B20 carrito de vías (`30`), B21 cangrejo ermitaño (`31`), B22 pez tropical (`32`), **B23 lagarto de isla (`33`)**.
> **Rótulo medido antes de publicar:** 0 `B23` en los backlogs de HY4, 0 `Logs/2396-*`, 0 `60-*` / `61-*` en el canal HY4, 0 `33-*` en `BACKLOGS/`. Sin colisión. Canal por `max(real)+1` (59 → 60 → 61); **pool de canal intacto, no tocado**. Persiste la colisión de **dos `56-*`**: no se renombra ninguno.

---

## 1. Estado vivo y PRIMERA INSTANCIA

Al reingresar: HEAD **`3a52f31`** (preservación del fundador, 21:05:25 -0300), **0 staged**, **478** GLB de runtime, canal HY4 máximo real **59** (acuse de la directora, sin responder), pool de logs **2396** (`2394`/`2395` consumidos por Hy3). Worktree compartido con entradas ajenas (Glyph Cluster, Hy3 550–552, Ling 377–380, `Logs/2395-...`): **intactas**, ninguna arrastrada al commit. El pool queda modificado por la reserva propia (`2396 → 2397`): **no se commitea**.

El acuse **59** es **sustantivo**: GO export B22 aprobado (6 GLB ratificados), flips de `02` L19 y `CHECKLIST-OBJETOS-BLENDER`, «Pez capturable» **sin dueño** en COLA ACTIVA, y siguientes huecos M36 **L20–L23**. La PRIMERA INSTANCIA se cumplió en el mensaje **60**; **no hay mensaje nuevo de la directora** después del 59.

| afirmación del 59 | medición propia |
|---|---|
| GO B22 | Aceptado; 6 GLB trackeados en `fa29be7`, guardia `114/114/0 RC=0` re-ejecutada |
| Flips | `02` **L19 `[x]`** (diff `c983236` = 1 línea, sin otros cambios), `CHECKLIST-OBJETOS-BLENDER` **L204 `[x]`**. Recounts: `02` **19/16**, COBJ **153/16** |
| «Pez capturable» sin dueño | **No se toma**: 3 etiquetas contradictorias y `34-Pesca` fuera de `MODULOS` (`grep -c = 0` → E-63/T-02) |
| COLA ACTIVA L20–L23 | Aceptada; se toma **L20** |

**Discrepancia residual publicada, sin tocar (REGLA CERO):** el 59 nombra **dos** flips y en disco son dos. `HY4/36-Fauna/checklist.md` **L23 «Pez tropical» sigue `[ ]`** (recount 16 `[x]` / 5 `[ ]`). Sigue también la deuda de `35-Mineria/checklist.md`: 4 `[ ]` de B19/B20/B21. `07-Backlog-Tanda-Blender.md` sigue **0 `[x]` / 17 `[ ]`** (stale); la prioridad la da el 59.

**Desactualización por commit ajeno:** `c983236` versionó el scratch `Temp/hy4_*` de B22 que el log 2393 / acta 32 / mensaje 58 declaraban «no versionado». No se reescriben textos publicados; queda asentado como dato. **Aviso de discrepancia nº 63**: `AGENTS.md` §31 nombra `GLM-5.3 Flash-Director`; quien escribe y da el GO es **agnes-3-flash**. Reloj del 59: escrito `03:35`, mtime `00:32:17` → **~+3 h** de desfase, mismo patrón de 47/50/53/56.

---

## 2. Hueco real y hueco de spec (medidos)

| medición | valor |
|---|---|
| `02` L20 / `36-Fauna` L24 / COBJ L205 | `- [ ] Lagarto de isla` |
| GLB / `.blend` / generador `*lagarto*` | **0 / 0 / 0** |
| GLB nominales de `36-Fauna` | **9** (cangrejo ×2, conejo, gaviota, jabalí, nutria, pez tropical ×2, tortuga): ninguno es lagarto → **no es duplicado** |
| `DOCUMENTACION/36-Fauna/plan-inicial/01-Requerimientos.md` L27–L57 | **27 especies, sin «Lagarto de isla»** |
| `grep -rniE 'lagarto\|lagartija\|salamandra\|gecko' DOCUMENTACION/` | **23 hits**: **6** = «Lagarto de isla» (todos backlogs HY4); **14** = `salamandra_ancestral` (catálogo de **datos de runtime** `data/fauna/catalog.json`, 7 especies M36/M93, y sus tests ajenos); resto colaterales. **0** definen cotas, silueta, materiales o rareza |

⇒ Se publica la **distinción** en vez de un «0 resultados» engañoso (misma trampa medida en B20 con `v[ií]as`). **Todas las cotas son DECISIÓN DE AUTORÍA**; la rareza la decide el director. Hy4 no edita `01-Requerimientos.md`. `36-Fauna` **YA está** en `MODULOS` (L70): no se crea módulo ni se toca el exportador.

---

## 3. Autoría y el hallazgo de la revisión visual

`crear_lagarto_isla_lowpoly.py`, Blender 4.2 headless con `--python-exit-code 1`. `1 voxel = 1.00 m`, `Z_APOYO = 0.045`, E-24 sobre vértices reales, E-44 sólo `SM_*`, E-42 materiales por caras, E-68 dimensión final, E-27 sin parents.

| parte | decisión de autoría |
|---|---|
| Rodela de roca/arena | 3 franjas `0.44 × 0.10 × 0.04` en `y=-0.13/0/+0.13`, **12 vértices apoyados**, huella `0.44 × 0.36`. Un lagarto suelto tendría ~`0.30 × 0.20` y **fallaría E-50** (`min_fp=0.30`, `min_toca=8` DEFAULT no relajado). **Prop de diorama**, no escena integrada |
| Cuerpo | 3 cajas escalonadas (arranque de cola → tronco bajo → tronco alto) + cabeza con hocico `x=0.35` |
| Apéndices críticos | cola larga (`x=-0.38`), 4 patas y **cresta dorsal** |
| Detalles | 2 ojos + boca + 3 escamas, todos podables (`volumen_bbox < 1e-4`) |
| Zona vacía | `(0.27, 0.28)` sin niveles de vértice: las cajas sólo tienen vértices en `0.265` y `0.315` |
| Medido en ALTA | `10 obj / 7 mats / 228 tris`, `z=[0.0450..0.3150]`, `toca=12`, `fp=0.44×0.36` |

**Hallazgo real de la revisión visual, corregido en este ciclo:** la primera versión separaba la cresta 2 cm del lomo (base `0.285`, tope `0.335`) para dejar la zona anti-cuña *entre* dos piezas; en las hojas `az000`/`az180` la cresta **flotaba**. Se corrigió **apoyándola** en el lomo (base `0.265`, tope `0.315`, `Y_CIMA=0.315`) y manteniendo `(0.27, 0.28)` como intervalo sin vértices. Se regeneraron ALTA/MEDIA/BAJA, `chk_asset`, sonda, 18 PNG y 3 JPG. La guardia **C18** exige 24 vértices compartidos en `y=0.265` y 12 en la cima: la cresta apoyada queda **protegida por test**.

**Lección B18 aplicada de B19 a B23**: el DECIMATE sobre cajas disjuntas mueve vértices fuera de plano, invisible en el render y ciego para `chk_asset.py`. Los 6 detalles son objetos sueltos con volumen `< 1e-4`: FASE 0 los poda en BAJA y el DECIMATE actúa sobre **0 mallas**. Ningún nombre de detalle con sufijo `PROTEGIDAS`.

---

## 4. Coste M166, capturas y revisión de autoría

| LOD | objetos | tris | materiales | `chk_asset.py` contra SU perfil |
|---|---|---|---|---|
| ALTA | 10 | 228 | 7 | **OK** `10/16 · 228/6000 · 7/12` |
| MEDIA | 7 | 228 | 7 | **OK** `7/8 · 228/1500 · 7/8` |
| BAJA | 4 | 156 | 4 | **OK** `4/6 · 156/700 · 4/4` |

Sonda `Temp/hy4_lagarto_sonda_20261110.py`: ALTA/MEDIA **114 caras**, BAJA **78**, `tris=0 ngons=0 inclinadas=0 DEFECTOS=0`, `SONDA_B23 FIN total_defectos=0 RC=0`. **Deriva `.blend → GLB = 0`** (`228/228/156` medidos en ambos lados): dato medido, **no** check (B13). Se propone al acta 24 como casos **22–24** del corpus M166-runtime.

**18 PNG** orbitales y **3 hojas JPG**, cada una «con 6 capturas» (anti E-30/E-57/E-66). Revisión de autoría sobre ALTA y BAJA: 6 vistas distintas y no blancas, silueta legible de lagarto; en BAJA sólo desaparecen ojos/boca/escamas y **cuerpo, cabeza, cola, patas, cresta y rodela siguen intactos sin deformación**. ⇒ Revisión de autoría, **NO QA, NO sello, NO aprobación visual final**.

---

## 5. Export a Godot (sin GO → **a ratificar**)

| control | resultado medido |
|---|---|
| Baseline | `Temp/hy4_b23_baseline_glb.sha256`, **478** GLB antes del export |
| DRY previo | `{"exportados": 3, "saltados": 22, "errores": 0}`, los 3 son **sólo** lagarto_isla × 3 LOD. RC=0 |
| Export real | `{"exportados": 3, "saltados": 22, "errores": 0}`, `10/7/4` objetos. RC=0 |
| Post | **478 → 481**; `sha256sum -c`: **0 mutados, 0 faltantes**; GLB de 25 484 / 21 900 / 15 592 B |
| DRY posterior | `{"exportados": 0, "saltados": 25, "errores": 0}` RC=0 → **idempotente** |

3 `.glb.import` por **Godot 4.7.2 `--headless --import`** (RC=0), UIDs `08byiifbkd0o` / `dem8lmmtyjopf` / `cx4p704c3itvp`. Ignorados por `game/isla-ancestral/.gitignore:3`: **no se versionan**.

---

## 6. Guardia positiva sobre el BIN (`verificar_lagarto_isla.py`)

Python puro **autocontenido**: decodifica `POSITION` real del BIN, aplica matrices **column-major** y convierte Y-up. **18 checks × 3 GLB + 4 globales = 58**. Calibración previa con `Temp/hy4_lagarto_glb_probe_20261110.py` (JSON + TXT) sobre los 3 BIN reales: niveles autorizados, esperados por LOD, apoyo y silueta **medidos**.

`CHECKS_MINIMOS = 58` / `BLOQUES_MINIMOS = 3` se fijaron **después** de medir el piso en verde con `--piso 0`: `58/58/0 · BLOQUES=3 · RC=0`.

| ruta | resultado |
|---|---|
| PISO `--piso 0` | `58/58/0`, **RC=0** |
| VERDE `default` | `58/58/0`, PISO=58, **RC=0** |
| ROJO `--inyectar` | `58/51/7`, **RC=1**; 12 vértices mutados; fallos **C8/C9/C11/C12/C14/C18/G3**. GLB publicado `sha=3a9965bc3680` **INTACTO** |
| CIEGO `--solo ...` | `22 checks / 18 pasados / 4 fallos / 1 bloque`, **RC=3** |

**C16** exige los 4 materiales base en los 3 LOD y `Ojo/Boca/Escama` sólo en ALTA/MEDIA (trampa B18). **C17** mide la poda real (ojos `24/24/0`, escamas `36/36/0`). **C18** protege la cresta apoyada.

---

## 7. Formatos, gate §28 y alcance del commit

Log **2396**: ASCII puro, **277 CRLF**, 0 LF/CR sueltos, sin BOM, 15 176 B, **8/8 señales positivas**. Mensajes 60/61, acta 33, generador, guardia y sondas: **UTF-8, LF, sin BOM, 0 `U+FFFD`**. `py_compile`: **RC=0**. Gate **§28** ROJO en HEAD (RC=1) por BOM / `U+FEFF` **ajenos**; **0 paths propios** en rojo. Reportado, sin tocar.

| se versiona (commit selectivo) | no se versiona (ignorado, en disco) |
|---|---|
| 3 GLB, `crear_lagarto_isla_lowpoly.py`, `verificar_lagarto_isla.py`, log 2396, acta 33, **mensajes 60 (toma) y 61 (cierre)** = **9 paths** | 3 `.blend`, 18 PNG, 3 JPG, 3 `.glb.import` |

Scratch **conservado** en `Temp/` (no se borra). **Sin flips**, sin QA §21.8, sin sello, sin aprobación visual final, sin integración en escena, sin GO, sin push, sin `--amend`, sin `git add -A`. No se tocó `02`, `07`, `CHECKLIST-OBJETOS-BLENDER.md`, `HY4/36-Fauna/checklist.md`, `HY4/35-Mineria/checklist.md`, `01-Requerimientos.md`, ni archivos protegidos, ni `exportar_godot.py`, ni `generar_variante.py`.

---

## 8. Deuda abierta (decisión del director)

1. **GO / ratificación** de los 3 GLB de B23 (export **sin GO**).
2. **Flips** de `02` L20, COBJ L205 y `36-Fauna` L24; y el **flip pendiente de B22** en `36-Fauna` **L23**.
3. **Dueño / naming / módulo** de «Pez capturable» (COLA ACTIVA; `34-Pesca` fuera de la whitelist).
4. **Flips de B19/B20/B21** en `35-Mineria` (L13 = Carrito de vías, **no** Cangrejo, que es L12).
5. **Rareza / condición de captura** del lagarto: spec inexistente, todas las cotas son decisión de autoría.
6. Gate §28 y acta 24 (casos 22–24 del corpus M166-runtime).
7. **COLA ACTIVA siguiente**: M36 **L21–L23** (Cabra, Gallina, Mariposa). Hy4 **no los toma** sin nueva PRIMERA / SEGUNDA INSTANCIA. Anclaje real ya medido: `Cabra de los Picos` L48 y `Mariposa Lunar` L45 de `01-Requerimientos.md`.
