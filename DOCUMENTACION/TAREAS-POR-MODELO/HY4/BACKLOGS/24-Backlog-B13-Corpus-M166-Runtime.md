# Acta 24 — B13-corpus: presupuesto M166 re-medido sobre 30 GLB de runtime

**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Fecha:** 2026-11-07 18:56:02 -0300
**Canal:** mensaje 34 · **Log:** 2364
**Origen:** deuda abierta por el acta 23 §4.3 («la cifra de presupuesto de un GLB debe medirse sobre el GLB, no sobre el `.blend`»)
**Estado:** EJECUTADO. Auditoría de **solo lectura** + guardia nueva. **Cero flips**, sin QA §21.8, sin sello, sin aprobación visual, sin export, sin GO.

---

## 1. Estado vivo al reingresar

Medido `2026-11-07 18:49:00 -0300`: HEAD `c436d21` (mi B12), worktree 24 entradas (ajenas: Hy3, pool, scratch), pool de logs en `2364`, canal HY4 con máximo real **33** y **sin mensaje nuevo** de la directora. El acuse sin NN del 7-nov 05:45 ya fue respondido en el mensaje 33 → **no hay PRIMERA INSTANCIA pendiente**. Aviso de discrepancia nº **48**.

## 2. SEGUNDA INSTANCIA

`07` sin reposición: T-01a..T-01d y T-02 ejecutados sin flips, T-03 **CIEGO**, T-04 referencia fantasma, resto protegido o ajeno. **Q2** (estrella de mar, acta 08) exige confirmación previa del fundador por Log 278 L152 → **no se toca sin GO**.

Se tomó la deuda de medición propia: todas las actas **13..21** publicaron cifras de `.blend`. Re-medir el corpus completo es aplicar «un verde no se hereda» a mis propios números.

## 3. Corpus y método

10 bases × 3 LOD = **30 GLB**, todos presentes y con fuente `.blend`: 4 vehículos M67, carreta M157, 2 columnas rotas + columna entera M25, mansión y casa de vecino M18. Total de GLB trackeados en el árbol: **448**.

| lado | método |
|---|---|
| `.blend` | Blender 4.2 headless, un proceso, 30 `open_mainfile`, `calc_loop_triangles()` sobre `SM_` **sin validar** (método exacto de `chk_asset.py`), marcador `HY4_CORPUS_BLEND_OK=30`. Ningún `.blend` se guardó. |
| GLB | decodificador de B12: vértices e índices reales del BIN, matrices column-major, glTF Y-up. |

**Resultado:** 30/30 GLB cumplen techo de tris (ALTA ≤6000 / MEDIA ≤1500 / BAJA ≤700), `y_min=0.0450`, materiales y objetos. `casa_vecino` = 14 objetos en MEDIA/BAJA **no es violación**: la excepción de casas grandes (`03-Backlog-Convenciones.md` L30-L31, sub-grupos de ≤16 `SM_`) la ampara. La guardia aplica techo 16, **no omite el check**.

## 4. Derivas medidas (dato, nunca check)

8 de 30 pares; suma |deriva| = **279**.

| base | LOD | `.blend` | GLB | deriva |
|---|---|---|---|---|
| `157-Medios-De-Transporte_carreta_ancestral` | **alta** | 792 | 704 | **+88** |
| `157-Medios-De-Transporte_carreta_ancestral` | baja | 491 | 479 | +12 |
| `18-Casas_casa_mansion` | baja | 676 | 530 | +146 |
| `25-Ruinas-Templos_columna_entera` | baja | 350 | 348 | +2 |
| `67-Vehiculos_barquita_aurora` | baja | 328 | 325 | +3 |
| `67-Vehiculos_globo_del_viento` | baja | 363 | 357 | +6 |
| `67-Vehiculos_gran_vapor` | baja | 646 | 626 | +20 |
| `67-Vehiculos_perla_ancestral` | baja | 371 | 369 | +2 |

Sonda Blender sobre **copias en memoria** de esos 8 `.blend`: `mesh.validate()` cierra los **8** deltas exactamente (`3/6/2/20/88/12/2/146`), 0 modifiers en todos. No es geometría perdida: es sobreconteo de polígonos inválidos.

## 5. Corrección al acta 23 (B12)

El acta 23 §4 afirmó: *«ALTA y MEDIA no presentan el fenómeno … Sólo aparece tras el decimate sobre mallas ya mergeadas»*. **Refutado**: `carreta_ancestral` **ALTA**, sin merge ni decimate (11 `SM_` originales), tiene +88.

| objeto ALTA | tris | tras `validate()` | delta |
|---|---|---|---|
| `SM_Carreta_Aros` | 128 | 64 | −64 |
| `SM_Carreta_Ruedas` | 200 | 176 | −24 |

Re-export de control con los parámetros reales de `exportar_godot.py` (`export_apply=True`, purga de no-`SM_`, GLB, Y-up): **44 448 B**, sha `2deda8c23193`, **byte-idéntico** al GLB publicado en `alta/`; 2 warnings `Mesh ... is not valid, and may be exported wrongly`. El `.blend` actual es la fuente; la diferencia es exclusivamente la validación del exportador.

**Regla corregida:** el sobreconteo **no** es exclusivo del decimate; cualquier malla con polígonos inválidos —incluidas las del generador ALTA— hace que `calc_loop_triangles()` cuente de más. Permanece la regla útil (medir sobre el GLB de runtime); se refuta la **atribución causal**.

Trampa para el catálogo: **un verde no se hereda ni siquiera entre LOD del mismo asset**; y una conclusión causal obtenida de **un solo caso** (B12 = mansión BAJA) no sobrevive a un corpus de 30.

## 6. Guardia nueva

`tools/mcp/blender-mcp/18-Casas/scripts/auditar_corpus_runtime.py` — Python puro, sin `bpy`, reutiliza el decodificador de B12 (no lo duplica).

- Por GLB: **C1..C8** (decodificador) + **C9** techo de objetos + **C10** techo de materiales.
- Por base: **C11** tris `alta≥media≥baja`, **C12** mats idem, **C13** triple LOD presente.
- `--declarado <json>` publica las derivas como **dato**; un número documental viejo no hace fallar la guardia ni se consagra.
- `CHECKS_MINIMOS=330`, `BASES_MINIMAS=10`, fijados **después** de medir el piso con la constante en 0. Los checks fallidos cuentan como ejecutados.

| camino | comando | resultado | exit |
|---|---|---|---|
| PISO | `--piso 0` | 330 checks / 30 bloques / 0 fallos | 0 |
| VERDE | `--declarado <json>` | `330/330/0`, 8 derivas publicadas | 0 |
| ROJO | `--inyectar` | `330/329/1` (C4, índices) | 1 |
| ROJO | `--inyectar-mats` | `330/329/1` (**C10, check nuevo**) | 1 |
| CIEGO | `--solo <base>` | `33/33/0` pero 3/30 bloques | 3 |

**Por qué dos ROJO:** el primero sólo ejercitaba **C4**, un check heredado del decodificador; no probaba que los checks nuevos estuvieran vivos. El segundo inyecta 5 materiales en el GLB ALTA de `casa_vecino` (8 → 13 > 12) sin tocar vértices ni índices, y el único fallo es **C10**. Un guardián que sólo se prueba por un check ajeno es un verde heredado.

## 7. Entregables y disciplina

| path | destino |
|---|---|
| `Mensajes entre modelos/HY4/34-...-b13-corpus-m166-runtime-30-glb.md` | canal (REGLA CERO) |
| `Logs/2364-HY4-B13-CORPUS-M166-RUNTIME-30-GLB_2026-11-07_18-56-02.md` | log formal, ASCII puro + CRLF + sin BOM |
| `DOCUMENTACION/TAREAS-POR-MODELO/HY4/BACKLOGS/24-Backlog-B13-Corpus-M166-Runtime.md` | esta acta |
| `tools/mcp/blender-mcp/18-Casas/scripts/auditar_corpus_runtime.py` | guardia |
| `.workbuddy-ai/memory/2026-11-07.md` | append (ignorado por git) |

**Commit selectivo de 4 paths**, encadenado, sin `--amend`, sin push, sin `git add -A`. Pool de logs **no se commitea**. Verificación sha256 de los 30 GLB antes/después: **30 GLB, 0 mutados**. `py_compile` RC=0; nuevo script UTF-8/LF sin BOM. Sondas, JSON, logs de Blender, manifiesto y GLB inyectados en `Temp/`, **conservados y sin versionar**. No se tocó ningún `.blend`, GLB, `.glb.import` ni checklist ajeno; las 57 entradas ajenas del worktree al cierre quedaron intactas.

Sin flips, sin QA §21.8, sin sello, sin aprobación visual final, sin GO.

## 8. Decisiones abiertas para la directora

1. **Anotar acta 20** (676 = `.blend` sin validar; runtime 530) y **acta 23 §4** (atribución al decimate refutada por carreta ALTA). Propuestas, **no aplicadas**: son notas de cierre ya publicadas y los cambios documentales los aplica la directora.
2. Reposición de la **COLA ACTIVA**, P1..P7, GO/ratificación de exports 23/25/27/29/31/32/33 y definición de T-02 (integración), T-03 (CIEGO), T-04 (fantasma) y Q2 (estrella de mar, Log 278 L152).
3. Rótulo **B13**: ya ocupado por el acta 10 (falso verde de escalas M50). Se reutiliza igual que B11 (actas 08 y 22) y B12 (actas 09 y 23). Si se prefiere serie única → renombrar a **B14**.
4. Heredero de **M19**, legado **18-BIS**, las 6 notas stale de la reserva de MiMo, y `02` L63 (`M19 RF12` inexistente; el RF12 real está en M18 `01-Requerimientos.md` L31).
5. **§28 en ROJO en HEAD (hallazgo medido, ajeno, SIN TOCAR).** Al verificar formatos, `python scripts/verificar_bom.py` devolvió **RC=1**: `Mensajes entre modelos/DS-V4.1-Flash-Opencode/.ultima-revision-ds.txt` (6 B, `tracked=1`, `ignored=0`, sin cambios en el worktree) empieza con `EF BB BF` y su contenido es únicamente `253`. `quality.yml:859` ejecuta ese verificador en el job `encoding-guard` como gate duro, en un `run:` sin tolerancia de fallo → **el CI de §28 falla hoy en HEAD**. Los 6 avisos de `U+FEFF` embebido son informativos y no bloquean. Fix propuesto: eliminar los 3 bytes del BOM conservando `253` (o excluir el fichero por regla explícita, no por parche). **No se aplica**: es archivo de otro agente y no hay GO. Mis 4 paths están limpios (BOM=False, CR=0 en doc/mensaje/script; log ASCII+CRLF). Queda registrado como próximo hueco medible.
