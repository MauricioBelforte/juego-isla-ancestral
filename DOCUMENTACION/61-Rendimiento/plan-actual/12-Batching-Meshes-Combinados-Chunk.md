# M61 — Batching: meshes combinados por chunk (item L289)

**Fecha:** 2026-10-28
**Autor:** DeepSeek-V4.1-Flash (WorkBuddy)
**Item:** `05-Checklist.md` L289 — *"Usar meshes combinados por chunk (M07) [S]"*
**Estado:** medido. Flip **propuesto**, no aplicado (el `05-Checklist.md` es NO TOCAR para este agente).

---

## 1. El problema: una afirmación sin medir

El bloque `batching` de `data/performance/budgets.json` ya declaraba, en su `nota`,
que *"el terreno voxel ya es por chunks: M07"*. Eso es una afirmación de diseño:
ningún gate la contrastaba contra el mesher real, así que si mañana alguien
cambiara el chunk, el mesher o la librería, la norma seguiría diciendo lo mismo y
nadie se enteraría.

El item L289 seguía en `[ ]` por ese motivo: no hay nada que "implementar" (el
terreno ya combina), lo que faltaba era **medirlo y clavarlo como norma**.

## 2. Qué se midió (CPU pura, headless, determinista)

`VoxelMesherBlocky.build_mesh(buffer, materiales)` es el mesher que usa el terreno
de producción (`scripts/main_island.gd`: `terrain.mesher = VoxelMesherBlocky.new()`).

| Caso | Entrada | Salida medida |
|---|---|---|
| Chunk 16³ **lleno** | 4 096 voxeles | **1 ArrayMesh**, **6 144 verts** |
| Referencia "un cubo por voxel" | 4 096 × 24 verts | 98 304 verts |
| **Ahorro de la combinación** | — | **16,00×** |
| 8 voxeles aislados (interiores) | 8 | 1 ArrayMesh, 192 verts (8 × 24) |
| Buffer vacío | 0 | sin geometría (null) |

Los 6 144 verts de la cáscara salen de la aritmética del cubo: `6 caras × 16×16
quads × 4 verts`. Es decir: el mesher **descarta las caras internas** (los 4 096
voxeles no aportan 4 096 cubos, aportan la superficie exterior del bloque).

`mesh_block_size` del `VoxelTerrain` de producción, **medido en una instancia
real** (no leído de la documentación del addon): **16**.

## 3. Trampa medida: el mesher exige 1 voxel de padding

`build_mesh()` devuelve **`null`** —no un error, no un mesh vacío— cuando algún
voxel toca el borde del buffer. El mesher necesita un margen de 1 voxel por lado
para decidir las caras de la frontera:

- buffer `16³` con un voxel en `x = 15` → **null**
- buffer `18³` con el bloque de `16³` en el interior `[1..16]` → **1 mesh / 6 144 verts**

Consecuencia práctica: **una medición que no use el buffer con padding reporta
"el mesher no produce nada" y parece un bug del addon**. No lo es: es el contrato
del mesher. Este documento y la suite lo dejan fijado.

## 4. Lo que se agregó al repositorio

| Archivo | Cambio |
|---|---|
| `data/performance/budgets.json` | `batching.meshes_combinados_por_chunk = true`, `batching.chunk_mesh_block_size = 16`, `batching.verts_cascara_chunk = 6144` + nota con la medición |
| `scripts/performance/validate_budget.gd` | las 3 claves en `TECNICAS_CANONICAS.batching` + `_invariante_batching()`: contrasta `chunk_mesh_block_size` contra el `mesh_block_size` **real** del motor y deriva `verts_cascara_chunk` como `6 × lado² × 4` |
| `tests/test_m61_batching_chunk.gd` | suite nueva, 26 checks, guardia de 3 capas |

### Por qué la invariante se mide contra el motor y no contra un número

`chunk_mesh_block_size = 16` **no es una constante copiada de la documentación**:
`_invariante_batching()` instancia un `VoxelTerrain` y compara su `mesh_block_size`
con el valor declarado. Si el addon cambia el default (o alguien configura otro
chunk en la escena), el gate se pone rojo y obliga a re-medir en vez de dejar la
norma mintiendo.

`verts_cascara_chunk` tampoco es mágico: se deriva de `6 × lado² × 4`, así que
cambiar el lado sin recalcular los verts rompe el gate por aritmética, no por
memoria de quien lo escribió.

## 5. Evidencia

### Suite nueva — `tests/test_m61_batching_chunk.gd`

```
=== Resumen M61 batching por chunk: 26 checks, 0 fallos ===   EXIT 0  (×3 corridas)
```
Piso `CHECKS_MINIMOS = 24` **medido** (26 reales, 2 de margen).

### Gate — `scripts/performance/validate_budget.gd`

```
[M61] batching: 6 umbral(es) tecnicos validados
=== VALIDATE BUDGET M61: 0 fallo(s) ===   EXIT 0
```

### Sondas EN ROJO (probadas, con restauración por sha256)

| Sonda | Inyección | Resultado |
|---|---|---|
| S1 | aborto de **runtime** dentro del bloque C (`Object` → `Dictionary` vía intermedio sin tipo) | `[FALL] el bloque C/D/E NO se ejecuto` + `solo 21 checks (minimo 24)` + **EXIT 1**, sin colgarse |
| S2 | piso imposible (`CHECKS_MINIMOS = 999`) | `solo 26 checks ejecutados (minimo 999)` + **EXIT 1** |
| S3 | `meshes_combinados_por_chunk = false` | suite **2 fallos / EXIT 1** + gate `FALLO: batching.meshes_combinados_por_chunk == canonico` / **EXIT 1** |
| S4 | `verts_cascara_chunk = 6000` | gate `FALLO: == 6*lado^2*4 = 6144 (declarado 6000)` / **EXIT 1** |
| S5 | `chunk_mesh_block_size = 32` | gate **3 fallos / EXIT 1**, incluido `== VoxelTerrain.mesh_block_size medido (32 vs 16)` |

`budgets.json` restaurado byte-exacto en cada sonda (`sha256 4402a704d2d441ba…`
verificado antes y después).

### Regresión M61 (no se rompió nada)

| Suite | Resultado |
|---|---|
| `tests/test_m61_normas_performance.gd` | 88 checks / 0 fallos / EXIT 0 |
| `tests/test_m61_medicion_runtime.gd` | 59 checks / 0 fallos / EXIT 0 |
| `tests/test_m61_allocations_hotloop.gd` | 8 checks / 0 fallos / EXIT 0 |
| `scripts/performance/test_budget_profile.gd` | EXIT 0 |

## 6. Defectos propios corregidos en la misma vuelta

Se registran porque el primer intento del suite dio 4 fallos y **3 eran míos**:

1. **Comparar valores del JSON con `str()`**: `JSON.parse_string` devuelve **todo
   número como float**, así que `"16.0" != "16"` y dos checks fallaban con los
   datos correctos. Fix: comparación numérica (`is_equal_approx`). Es la trampa
   16 del skill, reincidente.
2. **Aserción falsa `verts < voxeles`**: la cáscara de un chunk de 16³ tiene
   **6 144** verts y el chunk tiene **4 096** voxeles, así que la comparación
   correcta es contra la referencia *naive* (98 304), no contra el número de
   voxeles. La aserción estaba mal, no el código.
3. **Control negativo mal definido**: un buffer vacío devuelve **null**, no un
   mesh con 0 superficies. El control correcto es "no produce geometría"
   (`superficies <= 0`), y sigue siendo falsable porque el bloque C exige que el
   caso CON voxeles devuelva un mesh real.

## 7. Lo que este trabajo NO cierra

- **El flip `[ ] → [x]` de L289 lo aplica el director.** Este agente no edita el
  `05-Checklist.md` de M61.
- **La suite no está cableada en `quality.yml`**: es un archivo NO TOCAR para este
  agente. Queda listada para que la cablee quien tenga la autorización.
- **No se midió el número de draw calls reales** (exige renderer). Lo que se midió
  es el mecanismo de combinación, que es lo que el item afirma.
