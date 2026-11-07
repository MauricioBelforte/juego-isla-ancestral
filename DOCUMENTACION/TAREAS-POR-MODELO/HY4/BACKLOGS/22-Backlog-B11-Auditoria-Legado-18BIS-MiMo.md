# Acta 22 — B11: auditoría MEDIDA del legado 18-BIS (baja de MiMo)

**Fecha:** 2026-11-07 05:35:31 -0300
**Agente:** Hy4 (Tencent Hunyuan Hy) / WorkBuddy
**Canal:** mensaje 32 · **Log:** 2357
**Estado:** EJECUTADO — auditoría de **solo lectura**. **Cero flips.** Sin QA §21.8, sin sello, sin aprobación visual final, sin export, sin GO.

---

## 1. Origen

El fundador ratificó hoy (`05:27`) la baja de MiMo: *«mi mo ya no es parte de la flota»*. Ya existía la directiva del 6-nov registrada en el mensaje 28 y el acta 20, y el respaldo documental `Mensajes entre modelos/Nemotron-3.5-Super-VL/271-...-clarificacion-flota-activa.md` (`M64: MiMo (inactivo)`).

Con las reservas de MiMo sin dueño, el hueco medible de mi nicho era su legado en `tools/mcp/blender-mcp/18-BIS-Casas-Grandes/`. La COLA ACTIVA (`07`) sigue sin reposición: T-01a..T-01d / T-02 ejecutados sin flips, T-03 CIEGO, T-04 referencia fantasma, resto protegido/ajeno.

## 2. Qué se hizo

Un archivo nuevo, de lectura sobre los GLB heredados:

```
tools/mcp/blender-mcp/18-Casas/scripts/auditar_18bis_casas.py
```

Dos capas separadas a propósito:

- **CHECKS (guardia):** 8 aserciones positivas por GLB sobre el binario real — estructura glTF v2, alcanzabilidad de nodos de malla desde las raíces de escena, identidad `SM_`, vértices decodificados del BIN, `y_min` finito y físico, geometría no degenerada, triángulos contados por accessor, materiales. Su VERDE significa **«medí de verdad los 13 GLB»**, no «los assets están bien».
- **HALLAZGOS (datos):** presupuesto M166, apoyo `z=0.045`, LOD faltantes, deriva de cumbrera y presencia en Godot por sha256. Se **publican**, no se cuentan como checks: si un asset inválido hiciera fallar la guardia, un arreglo futuro podría consagrar el defecto sólo para volver al verde.

Trampas evitadas: glTF es Y-up (altura `y`, no `z`); matrices column-major `M[c*4+r]` con traslación en `M[12..14]`; no usar las 8 esquinas del AABB del accessor (inflan la caja con nodos rotados); nodos con `mesh` no alcanzables no se cuentan; un check que falla **sigue contando como ejecutado** (si sólo se contaran los verdes, el ROJO parecería CIEGO).

## 3. Guardia: piso medido y tres caminos

| camino | comando | resultado | exit |
|--------|---------|-----------|------|
| piso | `--piso 0` | `CHECKS=104 PASADOS=104 FALLOS=0 BLOQUES=13 CASAS=5 PISO=0` | 0 |
| VERDE | (sin args) | `CHECKS=104 PASADOS=104 FALLOS=0 BLOQUES=13 CASAS=5 PISO=104` | 0 |
| ROJO | `--inyectar` | `CHECKS=104 PASADOS=103 FALLOS=1` — falla **C3** (`14 nodos, identidad SM_=False`) | 1 |
| CIEGO | `--solo <glb>` | `CHECKS=8 ... BLOQUES=1 CASAS=1` | 3 |

`CHECKS_MINIMOS = 104` y `GLB_MINIMOS = 13` / `CASAS_ESPERADAS = 5` fijados **después** de medir el piso con la constante en 0. La inyección es reproducible: reescribe el GLB renombrando un nodo `SM_`→`BASURA_` y recalcula longitudes de chunk, en `Temp/` (scratch conservado, no versionado).

**Corrección intermedia publicada:** en el primer ROJO el GLB inyectado vivía en `Temp/` y el informe inventaba una 6.ª casa (`CASAS=6`). Se añadió un alias de etiqueta al path de origen; el ROJO final da `CASAS=5`. Falso conteo detectado y corregido antes de publicar la cifra.

## 4. Inventario real de los 13 GLB

Todos con `y_min = 0.0450` (**apoyo correcto en los 13**).

| casa | LOD | tris ALTA | mats | obj | y_max ALTA | presupuesto | Godot |
|------|-----|-----------|------|-----|------------|-------------|-------|
| CASA_01_CHOZA | 3/3 | 4100 | 8 | 14 | 3.9250 | OK | AUSENTE |
| CASA_02_CASA_MEDIANA | 3/3 | 4300 | 8 | 17 | 3.8700 | OK (obj 17>16) | AUSENTE |
| CASA_03_CASONA | **2/3, falta BAJA** | **6826** | 8 | 21 | 4.3325 | **EXCEDE 6000** | AUSENTE |
| CASA_04_MANSION | **2/3, falta BAJA** | **8779** | 8 | 27 | 4.9450 | **EXCEDE 6000** | AUSENTE |
| CASA_05_CASA_VECINO | 3/3 | 2746 | 8 | 14 | 3.5700 | OK | 3 GLB (B10-TER, msg 31) |

**10 de 13 GLB ausentes de Godot.** El conteo de objetos excede el límite M166 en 11 de 13 GLB; la excepción «casas grandes §6.1» está documentada para los generadores canónicos de `18-Casas`, **no confirmada** para 18-BIS → se publica sin aplicar dispensa.

### Deriva de cumbrera (`y_max` del LOD contra su ALTA)

| casa | LOD | delta | veredicto |
|------|-----|-------|-----------|
| CASA_01_CHOZA | MEDIA / BAJA | +0.0000 / +0.0000 | ok |
| CASA_02_CASA_MEDIANA | MEDIA / BAJA | -0.0003 / **-0.0246** | DERIVA en BAJA |
| CASA_03_CASONA | MEDIA | +0.0000 | ok |
| CASA_04_MANSION | MEDIA | **-0.1700** | DERIVA (17 cm) |
| CASA_05_CASA_VECINO | MEDIA / BAJA | +0.0000 / -0.0021 | ok |

## 5. Catálogo de MiMo contra medición

| afirmación heredada | medición | veredicto |
|---------------------|----------|-----------|
| CASONA ALTA 6826 tris, «no se exporta como modelo válido» | 6826 tris | **CONFIRMADO** |
| MANSION ALTA 8779 tris, ídem | 8779 tris | **CONFIRMADO** |
| CASA_MEDIANA/BAJA «El LOD alteró el apoyo de la casa» | `y_min=0.0450` (igual que ALTA/MEDIA) | **REFUTADO** |
| (no registrado) | deriva de cumbrera -0.0246 / -0.1700 m | **HALLAZGO NUEVO** |

`aprobacion_visual: PENDIENTE` y `colisiones: NO_GENERADAS` siguen vigentes en los `INFORME.json`.

## 6. Equivalencias canónicas (por qué NO se exportó nada)

Medidas hoy con el mismo decodificador: `18-Casas_casa_{choza_ampliada,mediana,casona,mansion,vecino}.glb` × 3 LOD = **15/15 presentes**, 0 fallos de guardia, `y_min=0.0450` en todos, ALTA entre 1140 y 3172 tris (mansión 1428 tris / 4 mats). Hay reemplazo válido para las 4 casas pendientes: el legado 18-BIS es **duplicado/inválido**, no un faltante de runtime. Exportarlo habría empeorado el árbol.

**Anomalía abierta (sin causa afirmada):** BAJA de `casa_mansion` = **676 tris en `.blend`** (`chk_asset.py`, acta 20 L91/L122) vs **530 tris en el GLB enviado**. Queda para verificar; no se tocó el GLB.

## 7. Otros huecos sin dueño (medidos, no tocados)

| archivo | medición | antes |
|---------|----------|-------|
| `NPC_SCRIPTS/crear_luna.py` | 1087 líneas, md5 `d5497d8a4823` | «avisar a MiMo» |
| `scripts-reutilizables/crear_luna.py` | 1102 líneas, md5 `7386086d3367` | duplicado divergente |
| `CASA_01_CHOZA/BAJA/crear_casa_01_choza.py` | 1156 líneas, md5 `0e612a939d3f` | «no tocar» |
| `CASA_02_CASA_MEDIANA/BAJA/crear_casa_01_choza.py` | 1156 líneas, md5 **idéntico** | etiqueta equivocada para casa 02 |

Documentación stale que sigue citando la reserva (propuesta de limpieza **sin aplicar**; flips y anotaciones son de la directora): `02` L42-L44 / L62-L63, `00` L104-L106, `01` L15 y L38-L39, `08` L43, `11` L20. Y el error ya reportado en 31: `02` L63 cita «M19 RF12» pero M19 tiene RF1..RF8 (RF12 real en M18 `01-Requerimientos.md` L31).

## 8. Incidente propio: pool del canal

Al medir la numeración invoqué `scripts/proximo_numero.py HY4`, que **reescribió** el pool ignorado `Mensajes entre modelos/HY4/NUMEROS_DISPONIBLES.txt` eliminando 5..31. La regla es no tocar el pool roto. Restaurado a su estado exacto anterior: **5..200, 196 números, 684 B, UTF-8/LF, sin BOM**, verificado sin entrada en `git status`. Operativamente se usa `max(real)+1 = 32`. Colisiones vivas 22/27/28; acuse sin NN sin renombrar.

## 9. Entregables y disciplina

- `tools/mcp/blender-mcp/18-Casas/scripts/auditar_18bis_casas.py` (nuevo)
- canal **32** · log **2357** (ASCII puro + CRLF + sin BOM) · acta **22** · append en `.workbuddy-ai/memory/2026-11-07.md`
- `Temp/hy4_auditoria_18bis_verde_20261107.txt` y `Temp/hy4_18bis_rojo_20261107.glb`: scratch **conservado**, no borrado, no versionado
- `py_compile` RC=0; formatos verificados; commit selectivo, sin push, sin `--amend`, sin `git add -A`; entradas ajenas del worktree intactas

**Cero flips**, sin QA §21.8, sin sello, sin aprobación visual final. **Aviso de discrepancia nº 46:** `AGENTS.md` §31 nombra `GLM-5.3 Flash-Director`; quien escribe y a quien se reporta es `agnes-3-flash`.

## 10. Decisiones que quedan para la directora

1. ¿Se **archiva** el set 18-BIS como obsoleto (sin borrar) o se re-exporta? Recomendación técnica: archivar, por duplicidad + 2 excesos M166 + 2 BAJA faltantes.
2. ¿Quién hereda **M19** y los dos pares de scripts divergentes?
3. Limpieza de las 6 referencias documentales a la reserva de MiMo.
4. Reposición de la **COLA ACTIVA** y las peticiones abiertas P1..P7, GO/ratificación de exports 23/25/27/29/31, T-02, T-03, T-04, `02` L30.
