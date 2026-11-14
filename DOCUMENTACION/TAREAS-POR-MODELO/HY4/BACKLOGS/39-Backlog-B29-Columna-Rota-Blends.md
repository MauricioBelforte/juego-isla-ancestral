# Acta 39 — B29: guardia de FORMA sobre los 6 `.blend` de `columna_rota` (M25)

**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-14 06:10:00 -0300
**Canal:** mensaje **77** (acuse sustantivo: B28 OK + «Siguiente: Columna rota M25. Cuando cierres, flippeo»), **78** (PRIMERA INSTANCIA al 77 + SEGUNDA INSTANCIA B29) y **79** (reporte de cierre con evidencia) · **Log:** **2419** · **Acta anterior:** 38
**Estado:** **EJECUTADO**. **Verificación de FORMA sobre los `.blend` de origen**. **0 assets nuevos**, **0 GLB nuevos**, **0 `.blend` modificados**, **1 guardia positiva nueva (`63/63/0` con 5 rutas)**, **1 sonda de calibración**. **Cero flips**, sin QA §21.8, sin sello, sin aprobación visual, sin integración en escena.

> Cadena de actas: B23 lagarto (`33`), B24 cabra (`34`), B25 gallina (`35`), B26 mariposa (`36`), B27 auditoría COLA ACTIVA (`37`), B28 columna_entera GLB (`38`), **B29 columna_rota blends (`39`)**.
> **Rótulo medido antes de publicar:** 0 `B29` en backlogs HY4, 0 `Logs/2419-*`, 0 `78-*`, 0 `79-*`, 0 `39-*` en `BACKLOGS/`. Sin colisión. Canal por `max(real)+1` (77 → 78 → 79); **pool de canal intacto**. Persisten dos `56-*`.
> Tercer cierre consecutivo **sin GLB nuevos**: **490** trackeados antes y después.
> **Reingreso tras corte 429**: el límite de uso del 13 cortó **antes de escribir ningún archivo** de B29 (0 artefactos en disco, 0 `B29` en backlogs). Sólo quedaron las tareas 180/181/182; hoy se añaden 183/184. No hubo que rehacer ni deshacer nada.

---

## 1. Autorización y discrepancias publicadas con cita

El acuse **77** confirma B28 (`58/58/0`) y asigna «Columna rota M25» con promesa de flip. Dos discrepancias **medidas**, publicadas sin corregir:

| # | dicho en el 77 | medición en disco |
|---|---|---|
| A | «Siguiente: Columna rota M25» | **Ya ejecutada y verificada**: 6 GLB trackeados, logs 2311/2335/2338, guardia `verificar_columna_rota.py` **114/114/0** (B27, `35ed941`), re-ejecutada hoy en VERDE. **Tercera vez consecutiva** que la TANDA nombra un ítem cerrado (71 → 74 → 77). |
| B | «Cuando cierres, flippeo» | **No aplicado**: `02` L26/L27 `[ ]`, COBJ L174/L175 `[ ]`. Recounts idénticos a las 18:41 del 13: `02` **29/6**, COBJ **163/6**, `36-Fauna` **16/5**, `35-Mineria` **3/4**, `07` **0/17**. |

Reloj del 77: escrito `05:35`, *mtime* `16:32:30.142912` → **+10 h 57 m 30 s**. Tres patrones ya medidos: +3 h (47/50/53), +20 h 56 m (62/68/71), +10 h 5x (74/77). **Aviso de discrepancia nº 68**: `AGENTS.md` §31 nombra `GLM-5.3 Flash-Director`; quien escribe es **agnes-3-flash**.

---

## 2. Hueco real: asimetría de guardias M25

`find tools/mcp/blender-mcp -iname '*verificar*columna*'` = **3 archivos**.

| asset | `.blend` (`bpy`) | BIN (GLB) |
|---|---|---|
| `columna_entera` (3 LOD) | `verificar_columna_entera.py` **27/27/0** | `verificar_columna_entera_glb.py` **58/58/0** (B28) |
| `columna_rota` (2 variantes × 3 LOD) | **NO EXISTÍA** | `verificar_columna_rota.py` **114/114/0** (B27) |

Los 6 `.blend` existen (mtime 2026-11-04 18:41) pero sólo pasaron por `chk_asset.py`, que mide **COSTE**, no **FORMA**. Precedente real 2026-11-06: la BAJA de `columna_entera` pasaba los 3 presupuestos M166 (342/700 tris, 4/6 obj, 4/4 mats) con el **ÁBACO COLAPSADO** por *decimate*. Un verde de coste no se hereda a la forma; un verde del BIN no se hereda al `.blend`.

---

## 3. Calibración (sonda `Temp/hy4_b29_blends_probe_20261114.py`)

Blender 4.2 headless con `--python-exit-code 1` obligatorio. `RC=0`. Salidas `.json` + `.txt` conservadas en `Temp/`.

| variante | LOD | obj | tris | mats | z | huella apoyo | vértices apoyo |
|---|---|---|---|---|---|---|---|
| A `columna_rota_alta` | ALTA | 12 | 464 | 5 | 0.0450..2.1900 | 1.2280×0.9498 | 28 |
| A | MEDIA | 5 | 464 | 5 | 0.0450..2.1900 | 1.2280×0.9498 | 28 |
| A | BAJA | 4 | 303 | 4 | 0.0450..2.1907 | 1.2280×0.9475 | 24 |
| B `columna_rota_baja` | ALTA | 12 | 464 | 5 | 0.0450..1.4900 | 1.2280×0.9498 | 28 |
| B | MEDIA | 5 | 464 | 5 | 0.0450..1.4900 | 1.2280×0.9498 | 28 |
| B | BAJA | 4 | 304 | 4 | 0.0450..1.4907 | 1.2280×0.9475 | 24 |

**Diferencia de altura entre variantes = 0.7000 m exactos en los 3 LOD** (medido, no supuesto). FASE 1 renombra los nodos a `SM_ColRota_M_ColRota_<Material>`; ALTA conserva `Fuste`/`Corona`/`Basa`.

La métrica de «bandas» de la sonda dio 0 caras laterales: **no es un defecto del asset**, es una métrica inaplicable aquí (45 niveles densos por escombros rotados). Se descartó como check; **no se consagró un 0 como fallo**.

---

## 4. Hallazgo real de B29 — DEUDA ABIERTA

Referencia de niveles = el **ALTA del mismo asset** (sin *decimate*), no un número escrito a mano.

- **MEDIA**: `desv_max = 0.0000`, **0** vértices fuera de plano → merge FASE 1 limpio.
- **BAJA**: `desv_max = 0.0418 m` (**4.18 cm**), **21 niveles espurios / 34 vértices** (A) y **22 / 42** (B) fuera de los planos autorizados; `z_max` deriva **+0.0007 m**. Niveles espurios: `0.0472`, `0.0477`, `0.0807`, `0.0850`, `0.1485`, `0.1503`.

Es la **TRAMPA B18** (acta 28): el DECIMATE sobre cajas disjuntas mueve vértices fuera de plano, invisible en el render y en `chk_asset.py`. B27 ya había publicado la deriva `+0.0007` en el BIN como **dato, no consagrada**; B29 la confirma en el `.blend` con la magnitud completa.

**C10 es un TECHO DE REGRESIÓN sobre esa deuda, NO una aprobación**: tolera lo ya medido para que un daño mayor caiga en ROJO. Si el director autoriza **re-autorar la BAJA con poda deliberada (0 decimate**, como B19–B26), el techo **DEBE bajar a 0** y C10 re-medirse. No se consagra el bug: se publica con la cifra medida y se propone el fix.

---

## 5. Guardia nueva `verificar_columna_rota_blends.py`

Autocontenida (`bpy` + stdlib). **10 checks positivos × 6 bloques + 3 globales = 63**.

`C1` objetos (12/5/4) · `C2` `z_min=0.045` · `C3` `z_max` por variante (tol 0.001 admite la deriva) · `C4` huella de apoyo (E-50) · `C5` materiales por cara (5/5/4) · `C6` tris ≤ perfil M166 · `C7` estructura real por LOD · `C8` fuste íntegro ≥1.0 m · `C9` corona no colapsada · `C10` techo de regresión de *decimate* (`desv≤0.0450` y `vértices≤46`) · `G1/G2/G3` diferencia 0.7000 ± 0.001 por LOD.

**Corrección real de la propia guardia (falso verde medido)**: el primer ROJO dejó C9 en verde porque usaba el `zmax` **medido** para definir su banda — un colapso redefinía la banda y el check daba verde sobre el propio daño. Se corrigió a banda **absoluta respecto del tope esperado** (más estricto, no relajado).

`CHECKS_MINIMOS = 63` / `BLOQUES_MINIMOS = 6` se fijaron **después** de medir el PISO en VERDE con `--piso 0`.

### 5 rutas ejercitadas

| ruta | resultado |
|---|---|
| PISO `--piso 0` | `63/63/0` · 6 bloques · 3 globales · `RC=0` |
| VERDE default | `63/63/0` · PISO=63 · `RC=0` |
| ROJO A `--inyectar` | `63/60/3` `RC=1` — 5 vértices de corona bajados 0.09 m (colapso real de 2026-11-06). Caen **C3 / C9 / G3**. |
| **ROJO B `--inyectar-decimate`** | `63/61/2` `RC=1` — 94 vértices desplazados +0.0133 m (TRAMPA B18). Caen **C4 / C10** (116 vértices fuera de plano vs techo 46). |
| CIEGO `--solo` | 10 checks · 1 bloque · 0 globales · `RC=3` |

El **ROJO B se agregó** porque el A no probaba C10, la guardia nueva del hallazgo (igual que B26 con `--inyectar-alas`). Ambas inyecciones escriben **sólo en `Temp/`**: sha del `.blend` publicado `db06b845393f` intacto. **6/6 `.blend` intactos** tras las 5 rutas.

---

## 6. Formatos, gate §28 y cierre

- Log **2419**: ASCII puro, **256 CRLF**, 0 LF/CR sueltos, sin BOM, **12/12 señales positivas**. Pool `2419 → 2420`, **no commiteado**.
- Mensajes 78/79, acta 39, sonda y guardia: UTF-8/LF/sin BOM, 0 CR sueltos, 0 `U+FFFD`. `py_compile RC=0`.
- Gate §28: **rojo en HEAD por BOM ajenos**, `RC=1`, **0 paths propios** en la lista roja. Reportado, sin tocar.
- **Commit selectivo de 5 paths**: guardia nueva, log 2419, acta 39, mensajes 78 y 79. Sin `git add -A`, sin `--amend`, sin push. **0 GLB nuevos**, **0 `.blend` modificados**, **0 flips**.
- **No se versiona** el scratch de `Temp/` (sonda `.py/.json/.txt` + 2 `.blend` inyectados); se conserva. Si el fundador lo absorbe en un commit ajeno, como hizo con B25/B26, se publicará como fe de erratas (precedente B22).

---

## 7. Pendiente del director (REGLA CERO: Hy4 no lo resuelve)

1. **Definir la TANDA**: tercera vuelta consecutiva asignando un ítem ya ejecutado (flips con GO / re-autorar / TANDA distinta).
2. **Re-autorar la BAJA** de `columna_rota` con poda deliberada (0 *decimate*) → eliminar 34/42 vértices fuera de plano y los 4.18 cm; entonces **C10 debe re-medirse con techo 0**.
3. **Flips con evidencia**: `02` L26/L27/L30/L38 · COBJ L50/L174/L175/L225 · `36-Fauna` L23–L27 · `35-Mineria` L10–L13 (**L13 = Carrito de vías**, Cangrejo es **L12**).
4. Naming `mariposa_lunar` · dueño de «Pez capturable» · fix `mat(emisivo=...)` de `plantilla_asset.py` (hallado en B26, no tocado) · B26-bis · gate §28.
5. Guardias fuera de la TANDA que siguen faltando: `cultivo_brote`, `palanca_madera`. No se toman sin nueva PRIMERA/SEGUNDA INSTANCIA.
