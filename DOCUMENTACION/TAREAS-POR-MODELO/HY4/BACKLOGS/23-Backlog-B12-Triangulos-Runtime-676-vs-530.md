# Acta 23 — B12: la deriva 676 → 530 tris era medición, no pérdida de geometría

**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-07 18:40:16 -0300
**Canal:** mensaje 33 · **Log:** 2361
**Origen:** anomalía abierta por mí en el acta 22 §6, sin causa afirmada
**Estado:** RESUELTO con medición real. Auditoría de **solo lectura** + guardia nueva. **Cero flips**, sin QA §21.8, sin sello, sin aprobación visual, sin export a Godot.

---

## 1. Estado vivo al reingresar

Medido `2026-11-07 18:27:43 -0300`: HEAD `8e0ebba` (mi B11), worktree con **25 entradas ajenas** (Hy3, Ling-3.1-Flash, scratch, pool), pool de logs en `2359` y canal HY4 con máximo real **32**.

Entró un acuse **sin numerar** de `agnes-3-flash` (`acuse-2026-11-07_05-45-51.md`, 133 B, «Recibido.», cabecera 08:45 contra mtime 05:45). **PRIMERA INSTANCIA** respondida en el mensaje 33. Sin GO, sin definiciones, sin prioridad. Numeración `max(real)+1 = 33`; **no se invocó `proximo_numero.py`** (reescribió el pool del canal en B11). Aviso de discrepancia nº 47.

## 2. SEGUNDA INSTANCIA

`07` sin reposición. Tomé el hueco **abierto por mi propio cierre**: *«BAJA de `casa_mansion` = 676 tris en `.blend` según `chk_asset.py` vs 530 en el GLB enviado»* (acta 22 §6). No es un ítem nuevo del backlog: es deuda de medición propia. Se trabajó una tanda con dos frentes (anomalía + scripts divergentes del legado MiMo).

## 3. Hipótesis descartadas antes de afirmar nada

| hipótesis | medición | veredicto |
|---|---|---|
| Purga de `Base_Arena` / `SOL` / `CAM_*` | `chk_asset.py` cuenta **sólo `SM_`** y el exportador purga **sólo no-`SM_`** | descartada |
| Modifiers sin aplicar (`export_apply=True`) | 6 objetos, **0 modifiers**; `TOTAL_TRIS_BASE = TOTAL_TRIS_EVAL = 676` | descartada |
| Objetos ocultos | `hide_render=False`, `hide_viewport=False` en los 6 | descartada |
| Caras degeneradas (área 0 / índices repetidos) | `repetidos=0  area0=0  lado0=0`; área mínima `1.28e-2 m²` | descartada |
| GLB corrupto o de otra versión | re-export **byte-idéntico** al GLB en Godot | descartada |

## 4. Causa demostrada

Binario: `D:/Archivos de programa/Blender Foundation/Blender 4.2/blender.exe`, modo `-b --factory-startup --python-exit-code 1`. Sondas en `Temp/` (conservadas, no versionadas).

`mesh.validate()` sobre **copias en memoria** del `.blend` BAJA (el archivo original nunca se guardó):

| objeto | tris base | tras `validate()` | delta | `validate()` reporta cambio |
|---|---|---|---|---|
| `SM_Mansion_M_Mansion_Madera` | 154 | 114 | −40 | Sí |
| `SM_Mansion_M_Mansion_Piedra` | 206 | 132 | −74 | Sí |
| `SM_Mansion_M_Mansion_Acento` | 76 | 56 | −20 | Sí |
| `SM_Mansion_M_Mansion_Jade` | 60 | 48 | −12 | Sí |
| `SM_Mansion_Pedestal_NOFUNDIR` | 120 | 120 | 0 | No |
| `SM_Mansion_Zocalo_NOFUNDIR` | 60 | 60 | 0 | No |
| **Total** | **676** | **530** | **−146** | |

Los deltas **coinciden exactamente** con los que faltan en el GLB, primitiva por primitiva (`114 / 132 / 56 / 48 / 60 / 120 = 530`). El exportador glTF valida la malla antes de escribir y emite 4 warnings `Mesh ... .001 is not valid, and may be exported wrongly`, uno por malla mergeada.

**Cadena causal:** `generar_variante.py` hace merge por material + decimate → quedan **polígonos inválidos** → `calc_loop_triangles()` (lo que usa `chk_asset.py`) los triangula de más (676) → el exportador valida y escribe la malla corregida (530). ALTA y MEDIA no presentan el fenómeno: **1428 tris en `.blend` y 1428 en GLB**, sin degenerados. Sólo aparece tras el **decimate sobre mallas ya mergeadas**; los dos objetos protegidos con `_NOFUNDIR` (sin merge ni decimate) no cambian.

### 4.1 Re-export de control

`Temp/hy4_mansion_baja_reexport_20261107.glb`: `38392 B`, sha `c34707b57f82`, **byte-idéntico** (`diff bytes=0`) a `game/isla-ancestral/assets/3d/baja/18-Casas_casa_mansion.glb`. Parámetros usados, los mismos de `exportar_godot.py`: `export_format='GLB'`, `export_apply=True`, `export_yup=True`, `export_materials='EXPORT'`, purga de todo no-`SM_`, sin cámaras/luces/animaciones.

### 4.2 No hay pérdida de geometría

Comparación **triángulo a triángulo por posición real en coordenadas mundiales** (glTF Y-up → Blender Z-up: `(x, -z, y)`), con el GLB decodificado del BIN y el `.blend` validado:

| malla GLB | tris | coincide | área GLB | área validada | Δárea |
|---|---|---|---|---|---|
| `Cube` (Zocalo) | 60 | exacto | 46.6000 | 46.6000 | −9e−6 |
| `Cube.051` (Pedestal) | 120 | exacto | 31.6556 | 31.6556 | +3e−6 |
| `..._Acento.001` | 56 | exacto | 20.5983 | 20.5983 | +2e−6 |
| `..._Jade.001` | 48 | exacto | 8.5248 | 8.5248 | +5e−6 |
| `..._Madera.001` | 114 | 7 diagonales distintas | 356.2906 | 356.2906 | +1.4e−5 |
| `..._Piedra.001` | 132 | exacto | 260.1934 | 260.1934 | +2.7e−5 |

**5 de 6 mallas coinciden triángulo a triángulo**; la sexta retriangula 7 caras con **superficie idéntica**. Δárea global < `3e-5 m²` (ruido float32). `y_min=0.0450`, `y_max=4.9950` en los 3 LOD.

**Veredicto:** los 146 triángulos son **artefactos de triangulación de polígonos inválidos**, no superficie perdida. El GLB de runtime es correcto. Ambas cifras están bajo el techo M166 BAJA de 700 → **no hay violación de presupuesto**; hay una **deriva documental**: el acta 20 publicó 676 como si fuera el artefacto entregado.

### 4.3 Trampa nueva registrada

> `chk_asset.py` mide `calc_loop_triangles()` sobre la malla **sin validar**. Tras un merge + decimate puede **sobrecontar**. La cifra de presupuesto de un GLB debe medirse **sobre el GLB**, no sobre el `.blend`. Un «VERDE 676/700» no certifica el artefacto de runtime.

Corolario de la regla del fundador «un verde no se hereda»: el verde del `.blend` no se hereda al GLB.

## 5. Guardia nueva: `verificar_triangulos_runtime.py`

Ruta: `tools/mcp/blender-mcp/18-Casas/scripts/verificar_triangulos_runtime.py`. Python puro, sin `bpy`, sin dependencias. 8 checks por GLB (`C1` cabecera/BIN · `C2` estructura · `C3` primitivas `TRIANGLES(4)` · `C4` índices en rango y `count` múltiplo de 3 · `C5` vértices reales finitos · `C6` alcanzabilidad de nodos · `C7` apoyo `0.0450 ± 0.0005` · `C8` techo M166 por LOD).

Publica la cifra de **runtime por primitiva** y, con `--declarado <json>`, la deriva contra las cifras documentales como **dato, nunca como check**: un número viejo no debe hacer fallar la guardia ni consagrarse como aserción.

| camino | comando | resultado | exit |
|---|---|---|---|
| PISO | `--piso 0` | `CHECKS=24 PASADOS=24 FALLOS=0 BLOQUES=3 PISO=0` | 0 |
| VERDE | `--declarado Temp/hy4_declarado_mansion_20261107.json` | `24/24/0`; ALTA `+0`, MEDIA `+0`, **BAJA `+146`** | 0 |
| ROJO | `--inyectar` | `24/23/1` (C4 `count=343 no múltiplo de 3`) | 1 |
| CIEGO | `--solo <glb>` | `8 checks / 1 bloque` | 3 |

`CHECKS_MINIMOS=24` y `BLOQUES_MINIMOS=3` se fijaron **después** de medir el piso con la constante forzada a 0. Los checks fallidos **siguen contando como ejecutados**: si sólo se contaran los verdes, el ROJO parecería CIEGO.

**Corrección intermedia publicada:** el primer ROJO daba `24/22/2` porque el GLB inyectado vive en `Temp/`, el LOD se infería del directorio y `limite=None` hacía fallar C8 por ruido. Se añadió `lod_hint` por alias (misma clase de defecto corregido en B11, donde el GLB inyectado inventaba una 6ª casa). El ROJO final tiene **1 solo fallo semántico**.

## 6. Segundo frente: scripts divergentes del legado MiMo (B11 se corrige a sí mismo)

| par | medición | veredicto |
|---|---|---|
| `NPC_SCRIPTS/crear_luna.py` (1087 l, `d5497d8a4823`) vs `scripts-reutilizables/crear_luna.py` (1102 l, `7386086d3367`) | `git diff --no-index --stat` = **15 inserciones**: 14 de cabecera de comentario + 1 blanco final | **código ejecutable idéntico**. No hay dos implementaciones que reconciliar; el acta 22 lo había listado como «divergente» sin diff. |
| `CASA_01_CHOZA/BAJA/crear_casa_01_choza.py` vs `CASA_02_CASA_MEDIANA/BAJA/crear_casa_01_choza.py` | byte-idénticos (`0e612a939d3f`, 1156 l), encabezado «CASA 01 — CHOZA AMPLIADA» | artefacto de copia mal etiquetado. Los GLB sí son distintos (CASA_01 ALTA `4100 tris/14 obj/y_max 3.9250`; CASA_02 `4300/17/3.8700`) → **no es el generador real de CASA_02**. Sin tocar. |

Búsqueda acotada de referencias en `DOCUMENTACION/` (`*.md`): 12 archivos, todos prompts de personajes/casas o backlogs históricos; **ninguna referencia ejecutable viva**. Los 4 scripts están trackeados.

## 7. Entregables y disciplina

| path | destino |
|---|---|
| `Mensajes entre modelos/HY4/33-...-acuse-b12-triangulos-runtime.md` | canal (PRIMERA INSTANCIA + REGLA CERO) |
| `Logs/2361-HY4-B12-TRIANGULOS-RUNTIME-676-VS-530_2026-11-07_18-40-16.md` | log formal, ASCII puro + CRLF + sin BOM |
| `DOCUMENTACION/TAREAS-POR-MODELO/HY4/BACKLOGS/23-Backlog-B12-Triangulos-Runtime-676-vs-530.md` | esta acta |
| `tools/mcp/blender-mcp/18-Casas/scripts/verificar_triangulos_runtime.py` | guardia |
| `.workbuddy-ai/memory/2026-11-07.md` | append (archivo ignorado por git) |

**Commit selectivo de 4 paths**, encadenado, sin `--amend`, sin push, sin `git add -A`. Pool de logs **no se commitea**. `Temp/` conservado (sondas `.py`, `.log`, `.json`, re-export y GLB rojo), no borrado ni versionado. Las entradas ajenas del worktree quedaron intactas.

Sin flips, sin QA §21.8, sin sello, sin aprobación visual final, sin GO explícito. El pool pasó de `2359` (medido al reingresar) a `2361` al reservar: Hy3 consumió `2359/2360` entre ambas mediciones.

## 8. Decisiones abiertas para la directora

1. **Anotar el acta 20** (L91/L122): `676` = `.blend` sin validar; **runtime = 530**. Propuesta, **no aplicada**: es una nota de cierre ya publicada y los cambios documentales los aplica la directora.
2. Archivar el set `18-BIS` como obsoleto (recomendación B11) o re-exportarlo.
3. Heredero de M19 y de los pares de scripts del legado MiMo, ya acotados en §6.
4. Limpieza de las 6 notas stale de la reserva de MiMo; corregir `02` L63 (`M19 RF12` inexistente; el RF12 real es M18 `01-Requerimientos.md` L31).
5. Reposición de la **COLA ACTIVA**, P1..P7, GO/ratificación de exports 23/25/27/29/31/32 y definición de T-02 / T-03 / T-04.
