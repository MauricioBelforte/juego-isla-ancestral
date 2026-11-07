# Acta 21 — B10-TER: export a Godot de Casa de vecino (CASA_05, 3 GLB)

**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-07 04:02:09 -0300
**Canal:** mensaje 31 · **Log:** 2356 · **Commit:** selectivo, ver §9
**Estado:** EJECUTADO (alcance **SOLO export** de un asset **YA EXISTENTE**, autoría de MiMo). **Cero flips.** Sin QA §21.8, sin sello, sin aprobación visual final. Export **sin GO explícito** → ratificación o revert pedida.

---

## 1. PRIMERA INSTANCIA y estado vivo al reingresar

Medición `2026-11-07 03:41 -0300`: HEAD `2ec8b63` (ajeno), worktree con 6 entradas propias pendientes de cierre, pool de logs `2356 / 2357 / ...`. En el canal HY4 había **dos** escritos nuevos de `agnes-3-flash` desde mi mensaje 29:

| archivo | fecha en texto | responde a | cuerpo | NN |
|---------|----------------|------------|--------|----|
| `acuse-2026-11-06_19-04-51.md` | 2026-11-06 21:58 | mi mensaje 29 | «Recibido.» | **ausente** |
| `30-2026-11-06_19-06-15-...-acuse.md` | 2026-11-06 22:00 | el acuse sin numerar | «Recibido.» | 30 |

Acuse de un acuse: **sin GO**, sin definición del alcance de T-02, sin spec de iconos de T-03, sin aclaración de `B-15-02`, sin prioridad, sin ratificación de los exports 23/25/27/29. Se responde a ambos con el mensaje **31** (`max(real)+1 = 30+1`). Colisiones vivas: **22, 27, 28**. Pool de mensajes roto (primera línea 5), no se toca. Deriva de reloj +2 h 53 m / +2 h 54 m. **Aviso de discrepancia nº 45**: `AGENTS.md` §31 nombra `GLM-5.3 Flash-Director`; quien escribe es `agnes-3-flash`.

## 2. Cierre anterior: ya está en HEAD, no se duplica

M18-BIS Mansión (mensaje 29 / log 2341 / acta 20 / 8 paths) fue **absorbido** por el commit de preservación del fundador `4091de8` (Mauricio Belforte, 2026-11-06 19:05:03, 1181 files). Verificado path por path con `git ls-files` y `git log`: **8/8 TRACK, 8/8 en disco**, último commit `4091de8`. No se hace segundo commit, no se usa `--amend`, no se toca el worktree ajeno.

Verificación que el corte por límite de uso dejó pendiente, **re-ejecutada hoy**: mensaje 29 / acta 20 / 2 scripts = UTF-8 sin BOM + LF, sin `U+FFFD`; log 2341 = ASCII puro + 181 CRLF + 0 LF sueltos + sin BOM; `py_compile` de `crear_casa_mansion_lowpoly.py` y `verificar_casa_mansion.py` RC=0; gate §28 (`scripts/verificar_bom.py`) RC=1 por **1 archivo ajeno** con BOM (`Mensajes entre modelos/DS-V4.1-Flash-Opencode/.ultima-revision-ds.txt`) + 6 `U+FEFF` embebidos ajenos. Ninguno de mis 5 paths aparece en la salida; no se corrige nada ajeno sin GO.

## 3. Anomalía propia publicada: el acta 20 proponía re-autorar

El acta 20 dejó para esta vuelta `02` L63 / `CHECKLIST-OBJETOS-BLENDER.md` L92 «Casa de vecino». La medición del 6-nov buscó **sólo** `18-Casas/` y `assets/3d/`; al medir el módulo completo aparece:

```
tools/mcp/blender-mcp/18-BIS-Casas-Grandes/CASA_05_CASA_VECINO/
  ALTA/MEDIA/BAJA : 3 .blend + 3 .blend1 + 3 .glb  (autoría de MiMo, 11-sep)
  CAPTURAS        : 12 JPG (6 exterior + 6 interior)
  INFORME.json    : L=7.0 W=5.0, vano REAL 1.00x2.10, 6 interacciones,
                    ALTA 2746 tris/14 meshes/8 mats, MEDIA 1428/14/6,
                    BAJA 660/14/4, z_min=0.045,
                    aprobacion_visual PENDIENTE, colisiones NO_GENERADAS
```

3 GLB + `INFORME.json` **trackeados**. La Mansión tiene el mismo problema: en `18-BIS` existe `CASA_04_MANSION` (ALTA+MEDIA, **sin BAJA**) y yo autoré una mansión nueva en `18-Casas/` con 3 LOD. El lado Godot queda cubierto por mi versión, pero la **duplicidad de fuentes se consigna, no se oculta**.

**Consecuencia operativa:** no se re-autora. El hueco real y medible es el **export**:

```
game/isla-ancestral/assets/3d/{alta,media,baja}/18-Casas_casa_vecino.glb
  -> 0 archivos antes de esta vuelta (las otras 4 casas SI tienen 3 LOD)
```

## 4. Referencia errónea en el backlog (MEDIDA, no corregida)

`02-Backlog-Pendientes-Assets.md` L63 dice «para **M19 RF12**». Medición:

- `DOCUMENTACION/19-NPC-Y-Vecinos/plan-actual/01-Requerimientos.md`: **sólo RF1..RF8** (`grep -c '^| RF' = 8`). **No existe RF12 en M19.**
- El RF12 de casas de vecinos es de **M18**: `DOCUMENTACION/18-Casas/plan-actual/01-Requerimientos.md` **L31** → `| RF12 | Casas de vecinos | Parcelas y casas de NPC en el pueblo (M19), con su propio interior y comportamiento |`.

Referencia fantasma por módulo equivocado, del mismo tipo que `B-15-02` de T-04. **Se reporta; no se edita el backlog ajeno sin GO** (flips y correcciones de marcas son del director).

## 5. Decisión: exportador dedicado, NO el pipeline compartido

`exportar_godot.py::planificar()` lista `.blend` **sólo en la raíz** de cada módulo de la whitelist `MODULOS`. `18-BIS-Casas-Grandes` **no está** en `MODULOS` y sus `.blend` viven en `CASA_05_CASA_VECINO/<LOD>/` (E-63 no aplica: aquí el GLB **ya está exportado**; lo que falta es llevarlo al juego). Además, re-exportar desde Blender con otra versión del motor **cambiaría la geometría ya medida** en `INFORME.json`.

Se copia el **binario canónico** y se exige `sha256(origen) == sha256(destino)`. **No se modifica `scripts-reutilizables/exportar_godot.py`.**

`tools/mcp/blender-mcp/18-Casas/scripts/exportar_casa_vecino_godot.py`:
- nunca sobrescribe un destino existente (`AssertionError` si ya existe);
- valida los **12 checks** de la guardia **antes y después** de cada copia, por LOD;
- baseline sha256 de **todos** los GLB de `assets/3d`, exige 0 mutados (worktree compartido);
- `--dry` planea sin escribir.

## 6. Guardia positiva nueva — `verificar_casa_vecino.py`

**NO es QA §21.8 ni sello**: verifica **efectos medibles sobre el binario GLB**, no la existencia del archivo ni un conteo declarado. 12 checks por GLB sobre **vértices reales del BIN**:

| check | aserción positiva |
|-------|-------------------|
| C1 | magia `glTF` v2, chunks JSON/BIN coherentes, longitudes vs `len(raw)` |
| C2 | ≥14 nodos de malla, **todos** `SM_` |
| C3 | sin `Base_Arena` / `SOL` / `CAM_` / `Arena` / `Luz` / `Light` (set de captura) |
| C4–C7 | `SM_Cama`, `SM_Cocina`, `SM_Mesa_Sillas`, `SM_Pared_Sur` presentes |
| C8 | `SM_Techo_Izq` **y** `SM_Techo_Der` (dos aguas en dos mitades) |
| C9 | `SM_Portico` **y** `SM_Valla_Patio` (pórtico + patio cozy) |
| C10 | >1000 vértices decodificados y `y_min = 0.045` (apoyado) |
| C11 | `y_max ≥ 3.55` (la cumbrera **viaja** al LOD) |
| C12 | materiales `8 / 6 / 4` por LOD |

Trampas evitadas a propósito: **no** se usan las 8 esquinas del AABB del accessor (con nodos rotados inflan el bbox); matrices glTF **column-major** `M[c*4+r]` con traslación en `M[12..14]`; glTF es **Y-up** (la altura es `y`, no `z`); la aserción es por **presencia** de nodos de identidad, no por ausencia de un sufijo de merge (MiMo conserva los 14 nodos `SM_` en los 3 LOD).

Un check que **falla sigue contando como ejecutado**: si se contaran sólo los verdes, el rojo parecería CIEGO (34 < 36). `CHECKS_MINIMOS = 36` se fijó **después** de medir el verde con el piso forzado a 0.

**Tres caminos re-ejecutados el 2026-11-07 04:01 -0300 sobre los destinos ya escritos** (no heredados del log ni de la vuelta anterior):

| camino | entrada | resultado | exit |
|--------|---------|-----------|------|
| **VERDE** | 3 GLB destino | `CHECKS=36 PASADOS=36 FALLOS=0 BLOQUES=3 PISO=36` | **0** |
| **ROJO** | 3.er GLB mutado en `Temp/` (`SM_Cama`→`SM_Zama`, vértice `0.045`→`-0.200`) | `CHECKS=36 PASADOS=34 FALLOS=2` (**C4, C10**), `y_min=-0.2000` | **1** |
| **CIEGO** | 1 solo GLB | `CHECKS=12 PASADOS=12 FALLOS=0 BLOQUES=1` → guardia de ceguera | **3** |

`py_compile` de ambos scripts RC=0.

### Dos fallos del propio decodificador, corregidos y documentados en sitio
1. **Late binding:** guardar generadores y evaluarlos después hace que todos usen `start/count` de la **última** primitiva y lean fuera del BIN (`struct.error: 204528 requeridos, 204516 reales`). Fix: `extend()` inmediato dentro del bucle.
2. **Inyección ROJO inicial FALSA:** `SM_Cama` aparece 2 veces en el JSON (nodo y mesh `SM_Cama_MESH`) y el `0.045` **no está en la primera primitiva** (es de `SM_Cimiento`). El primer «12 fallos» era en realidad **archivo ausente** por una ruta mal formada: **no se publicó como evidencia**. Fix: reemplazar sólo `"name":"SM_Cama"` y buscar el vértice de apoyo en **todas** las primitivas. ROJO real = 2 fallos.

## 7. Artefactos y mediciones

Baseline independiente: **445 GLB** trackeados con sha256 **antes** del export; re-medidos **después**: **0 mutados, 0 ausentes, 3 nuevos** (`Temp/hy4_baseline_glb_20261107.json`).

| LOD | bytes | sha256 (12) | vértices BIN | y_min | y_max | mats | nodos | `sha(src)==sha(dst)` |
|-----|-------|-------------|--------------|-------|-------|------|-------|----------------------|
| ALTA | 225064 | `efd186095c84` | 5272 | 0.0450 | 3.5700 | 8 | 14 | ✔ |
| MEDIA | 159704 | `23fdc2f8d55b` | 3664 | 0.0450 | 3.5700 | 6 | 14 | ✔ |
| BAJA | 80888 | `05b19319160d` | 1665 | 0.0450 | 3.5679 | 4 | 14 | ✔ |

Destino: `game/isla-ancestral/assets/3d/<lod>/18-Casas_casa_vecino.glb`. 3 `.glb.import` generados con Godot 4.7.2 headless `--import` (**RC=0**):

| var | uid |
|-----|-----|
| alta | `uid://bws4now6y8akb` |
| media | `uid://dgw3mpnu5qt1i` |
| baja | `uid://rf7etqb4v8v6` |

Locales y **sin versionar**: `game/isla-ancestral/.gitignore:3` ignora `*.import`, `git ls-files '*.glb.import'` → **0** trackeados (convención medida).

**Cobertura de LOD en `18-BIS` (medida):** `CASA_01`, `CASA_02`, `CASA_05` = 3/3; `CASA_03_CASONA` y `CASA_04_MANSION` = **2/3** (falta BAJA en la fuente de MiMo). En el lado Godot las **5** casas quedan con 3 LOD: casona y mansión ya los tenían por el módulo `18-Casas`. Se reporta; no se re-deriva nada ajeno. La `aprobacion_visual` de MiMo sigue `PENDIENTE` y las colisiones `NO_GENERADAS`: **no se inventa certificación**.

## 8. Límites y marcas

**NINGUNA marca volteada.** `02` L62/L63 y `CHECKLIST-OBJETOS-BLENDER.md` (bajo `tools/mcp/blender-mcp/`) L91/L92 siguen `[ ]`; los flips son del director. No se tocó `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`, `project.godot`, `05-Checklist` ajeno ni el exportador compartido. **Sin QA §21.8, sin sello, sin aprobación visual final.** Export **sin GO explícito** (igual que 23, 25, 27 y 29): reversible, 3 archivos nuevos, de nicho Blender; **ratificación o revert pedida** y consignada sin ocultarla.

Abierto y reiterado: **T-02** integración en escena (GO fundador + visión M154 + owner gameplay) · **T-03 CIEGO** · **T-04** `B-15-02` referencia fantasma · `02` L30 «Palanca de puzzle» obsoleta por D-03 pero `[ ]` · 7 flips de M110 y peticiones P1..P7 del mensaje 29 · gate §28 RC=1 por archivo ajeno · **COLA ACTIVA sin reposición**: los dos acuses no definen el próximo `[ ]`.

## 9. Cierre administrativo

Log **2356** **reservado** (pool `2356 → 2357`) **y escrito en la misma vuelta**: se evita repetir la anomalía del 2341, que se reservó y no se escribió. Formato medido hoy: **ASCII puro** (`max_byte=125`, `bytes=10573`) + **184 CRLF** + **0** LF sueltos + sin BOM.

Cierre: canal **31** · log **2356** · acta **21** · memoria `.workbuddy-ai/memory/2026-11-07.md` (append) · **commit selectivo de 8 paths**:

```
Logs/2356-HY4-B10TER-EXPORT-3-GLB-CASA-VECINO_2026-11-07_03-55-45.md
Mensajes entre modelos/HY4/31-2026-11-07_04-02-09-hy4-a-agnes-3-flash-acuse-30-b10ter-export-casa-vecino.md
DOCUMENTACION/TAREAS-POR-MODELO/HY4/BACKLOGS/21-Backlog-B10ter-Export-Casa-Vecino.md
tools/mcp/blender-mcp/18-Casas/scripts/verificar_casa_vecino.py
tools/mcp/blender-mcp/18-Casas/scripts/exportar_casa_vecino_godot.py
game/isla-ancestral/assets/3d/alta/18-Casas_casa_vecino.glb
game/isla-ancestral/assets/3d/media/18-Casas_casa_vecino.glb
game/isla-ancestral/assets/3d/baja/18-Casas_casa_vecino.glb
```

Sin push, sin `--amend`, sin `git add -A` (worktree compartido: entradas ajenas **no tocadas**). Scratch local (`Temp/hy4_baseline_glb_20261107.json`, `Temp/hy4_vecino_rojo_20261107.glb`) queda **sin versionar y NO se borra**. Los `.glb.import` quedan locales por convención medida.
