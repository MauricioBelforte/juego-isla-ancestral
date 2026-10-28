# Log 2235 - M61 - Batching: meshes combinados por chunk (item L289)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-28 04:15 (GMT-3)
**Modulo:** M61 Rendimiento
**Item:** 05-Checklist.md L289 - "Usar meshes combinados por chunk (M07) [S]"
**Tipo:** medicion + norma data-driven + suite nueva (flip NO aplicado)

---

## 1. Entrada de la vuelta

RAMA 1: mensaje **440** de agnes-3-flash (acuse de 439, sin tarea ejecutable).
Tracker previo 438 -> **440**. El director dejo abierto de verdad **L289** del 05 de
M61 ("1 [ ] + 1 [?]") y lo derivo a "tu proxima tanda". Eso es lo que se trabajo.

Sin commits, sin push, sin tocar archivos protegidos.

## 2. Premisa medida antes de escribir nada

El bloque `batching` de `data/performance/budgets.json` ya afirmaba en su `nota`
que "el terreno voxel ya es por chunks: M07". Ningun gate lo contrastaba: era
diseno, no medicion. L289 seguia en `[ ]` por eso (no habia nada que implementar;
faltaba medir y clavar la norma).

Medido con `VoxelMesherBlocky.build_mesh()` (CPU pura, headless):

| Caso | Entrada | Salida |
|---|---|---|
| Chunk 16^3 lleno | 4096 voxeles | 1 ArrayMesh / 6144 verts |
| Referencia "un cubo por voxel" | 4096 x 24 | 98304 verts |
| Ahorro de combinar | - | 16.00x |
| 8 voxeles aislados (interiores) | 8 | 1 mesh / 192 verts |
| Buffer vacio | 0 | sin geometria (null) |

`VoxelTerrain.mesh_block_size` medido en una instancia real: **16** (no asumido).

## 3. Trampa NUEVA (medida, documentada)

`build_mesh()` devuelve **null** -no error, no mesh vacio- si algun voxel toca el
borde del buffer. El mesher blocky exige **1 voxel de padding por lado**:

- buffer 16^3 con voxel en x=15 -> **null**
- buffer 18^3 con el bloque 16^3 en el interior [1..16] -> **1 mesh / 6144 verts**

Corolario: una medicion sin padding reporta "el mesher no produce nada" y parece
un bug del addon. No lo es. Una sonda que solo probara el caso con borde habria
concluido lo contrario de la verdad.

## 4. Entregado

| Archivo | Cambio |
|---|---|
| `data/performance/budgets.json` | `batching.meshes_combinados_por_chunk=true`, `batching.chunk_mesh_block_size=16`, `batching.verts_cascara_chunk=6144` + nota con la medicion |
| `scripts/performance/validate_budget.gd` | 3 claves en `TECNICAS_CANONICAS.batching` + `_invariante_batching()` (contrasta contra el `mesh_block_size` REAL del motor y deriva los verts como `6*lado^2*4`) |
| `tests/test_m61_batching_chunk.gd` | suite NUEVA, 26 checks, guardia de 3 capas (marcadores por bloque + piso medido + `_resumen()` en `call_deferred` aparte) |
| `DOCUMENTACION/61-Rendimiento/plan-actual/12-Batching-Meshes-Combinados-Chunk.md` | doc del item: medicion, trampa del padding, evidencia y limites |

La invariante NO usa un numero magico: instancia un `VoxelTerrain` y compara su
`mesh_block_size` con el valor declarado. Si el addon cambia el default o alguien
configura otro chunk, el gate se pone rojo y obliga a re-medir.

## 5. Evidencia medida

### Suite nueva

```
=== Resumen M61 batching por chunk: 26 checks, 0 fallos ===   EXIT 0  (x3 corridas)
```
Piso `CHECKS_MINIMOS = 24` **medido** (26 reales).

### Gate

```
[M61] batching: 6 umbral(es) tecnicos validados
=== VALIDATE BUDGET M61: 0 fallo(s) ===   EXIT 0
```

### Sondas EN ROJO (5, todas con restauracion verificada por sha256)

| Sonda | Inyeccion | Resultado |
|---|---|---|
| S1 | aborto de RUNTIME en el bloque C (Object -> Dictionary via intermedio sin tipo) | nombra C/D/E + `solo 21 checks (minimo 24)` + EXIT 1, sin colgarse |
| S2 | piso imposible (`CHECKS_MINIMOS=999`) | `solo 26 checks (minimo 999)` + EXIT 1 |
| S3 | `meshes_combinados_por_chunk=false` | suite 2 fallos / EXIT 1 + gate 1 fallo / EXIT 1 |
| S4 | `verts_cascara_chunk=6000` | gate: `== 6*lado^2*4 = 6144 (declarado 6000)` / EXIT 1 |
| S5 | `chunk_mesh_block_size=32` | gate 3 fallos / EXIT 1, incluido `== VoxelTerrain.mesh_block_size medido (32 vs 16)` |

`budgets.json` restaurado byte-exacto en cada sonda (`sha256 4402a704d2d441ba...`).

### Regresion M61 (no se rompio nada)

| Suite | Resultado |
|---|---|
| `tests/test_m61_normas_performance.gd` | 88 checks / 0 fallos / EXIT 0 |
| `tests/test_m61_medicion_runtime.gd` | 59 checks / 0 fallos / EXIT 0 |
| `tests/test_m61_allocations_hotloop.gd` | 8 checks / 0 fallos / EXIT 0 |
| `scripts/performance/test_budget_profile.gd` | EXIT 0 |

## 6. Defectos PROPIOS corregidos en la misma vuelta

El primer intento del suite dio 4 fallos y **3 eran mios**:

1. **Comparar valores del JSON con `str()`.** `JSON.parse_string` devuelve TODO
   numero como float -> `"16.0" != "16"`, dos checks rojos con los datos
   correctos. Fix: comparacion numerica. Es la trampa 16 del skill, reincidente.
2. **Asercion falsa `verts < voxeles`.** La cascara de 16^3 tiene 6144 verts y el
   chunk 4096 voxeles: la comparacion correcta es contra la referencia naive
   (98304), no contra el numero de voxeles. La asercion estaba mal, no el codigo.
3. **Control negativo mal definido.** Un buffer vacio devuelve null, no un mesh de
   0 superficies. Control correcto: "no produce geometria" (`superficies <= 0`),
   falsable porque el bloque C exige mesh real en el caso CON voxeles.

## 7. Limites de esta vuelta

- **0 flips aplicados.** El `05-Checklist.md` de M61 es NO TOCAR para este agente:
  el flip `[ ] -> [x]` de L289 lo aplica el director. Se propone con la cita.
- **La suite NO esta cableada en `quality.yml`** (archivo NO TOCAR). Queda listada
  para quien tenga la autorizacion.
- **No se midieron draw calls reales** (exigen renderer). Lo medido es el
  mecanismo de combinacion, que es exactamente lo que afirma el item.
- **L221 (`[?]` festival M74 sin picos) NO se toco.** Su nota dice que el conteo
  de runtime es del dueno M52 y que "sin picos" exige frame time real; no hay
  medicion headless honesta de eso. Se reporta, no se degrada ni se flipea.
- `reservar_log.py --estado` reporta **12 problemas de numeracion AJENOS**
  (colisiones 1878 / 1888 / 2120 entre otras). No se tocaron: renumerar un log
  ajeno es destructivo.

## 8. Numeracion

- Log: **2235** (cabeza del pool 2235, max en disco 2234 -> consistente).
- Mensaje al director: **441** (max de archivos del canal 440 + 1).
- Pool de canal: head en 423 (desincronizado, 5.a vuelta consecutiva). NO tocado.
