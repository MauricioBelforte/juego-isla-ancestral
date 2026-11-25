# Log 2463: M17 Construccion — P10: auditoria de coherencia docs↔codigo (04-Codigo.md)

**Fecha:** 2026-11-25
**Hora:** 15:25
**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

## Resumen

Auditoria del criterio **"la documentacion del modulo promete una API que el codigo no tiene"** sobre
`DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md`, el documento tecnico de referencia de M17.
**0 flips** (ningun item de checklist cambia): lo corregido es deriva documental.

**M17 sigue en 148/175, 0 `[?]`, 0 items inflados.**

## Metodo

1. Se extrajeron todos los identificadores citados en backticks dentro de `04-Codigo.md` (364 tokens).
2. Se cruzo cada uno contra el codigo real (`game/isla-ancestral/scripts/**/*.gd`, mas los `.tres` del
   catalogo), buscando su definicion (`class_name`, `func`, `var`, `const`, `signal`, `enum`) o su
   existencia como archivo.
3. Los tokens sin definicion se clasificaron: falso positivo (nombre de archivo, palabra comun,
   API del motor) vs **deriva real**.

## Deriva real encontrada (7)

| # | Lo que decia el doc | Lo que hay de verdad (verificado por grep) |
|---|---|---|
| 1 | `res://src/construccion/*.gd` en la **tabla de archivos** (10 filas) | La carpeta `res://src/` **no existe**: el modulo esta en `res://scripts/construccion/`. La propia nota del doc lo decia ("rutas propuestas de diseño") pero nunca se actualizo al consolidar la estructura (M07). |
| 2 | `res://src/construccion/build_validator.gd` | El archivo real es `construccion_validator.gd` (`class_name ConstruccionValidator`). |
| 3 | `res://src/construccion/modo_construccion.gd` | Los modos viven en `construccion_tipos.gd` (`ConstruccionTipos.Modo.CONSTRUCCION` / `DECORACION`). |
| 4 | `VoxelWorld.escribir_celdas(celdas, bloque)` | **No existe en ningun lado.** La API que M17 usa de verdad es `ConstruccionMundo.escribir_voxel(celda, bloque)` / `borrar_voxel(celda)` (la marca de chunk dirty la lleva el mundo). |
| 5 | `Inventario.consultar(costo)` / `.descontar(costo)` / `.devolver(item_id, cantidad)` | **Ninguno existe.** La API real del autoload `Inventario` es `count_item`, `remove_item`, `add_item`, `agregar_items`, `has_free_space`. El manager llama a los adaptadores `_f_agregar_item` / `_f_tirar_item` / `_f_hay_espacio`. |
| 6 | `ConstruccionData` serializa el snapshot | **La clase no existe.** El contrato real es `BuildManager.obtener_estructuras()` + `restaurar_estructuras(lista)` (idempotente); a disco lo escriben `SaveWriter` / `SaveSchema` (M59). |
| 7 | `dia_cambio`, **`noche_cambio`**; `recargas_festival()` | El reloj emite `dia_cambio`, `hora_cambio`, `minuto_cambio`, `estacion_cambio`, `evento_activado` (autoloads `Reloj` y `Calendario`; **ninguno declara `class_name`**). `noche_cambio` y `recargas_festival()` **no existen**. Ademas `devolve_al_pool()` era un typo de `devolver_al_pool()`. |

## Correccion aplicada (solo `04-Codigo.md`)

- La tabla de archivos paso a las **rutas reales verificadas contra disco**, con la nota que explica
  que `res://src/` fue el prefijo propuesto y jamas existio.
- `construccion_validator.gd` y `construccion_tipos.gd` con los nombres reales.
- La seccion "Suscripciones e integracion" ahora cita las **APIs reales** de cada modulo vecino
  (M08 mundo, M14 inventario, M58/M59 guardado, M31 reloj, M73/M64 eventos) y **marca explicitamente**
  las que NO existen ("OJO: ... era un nombre propuesto (2026-11-25)"), para que el proximo agente no
  las busque.
- `devolve_al_pool()` -> `devolver_al_pool()`.

## Lo que NO se hizo (honestidad)

- **No se toco ningun modulo vecino**: M08, M14, M31, M58, M64, M73 son de otros duenos. Solo se
  documento, en el documento de M17, cual es el estado real de su API.
- **0 flips de checklist**: la deriva era del documento, no de los items.
- **M20** intacto (GLM-5.3-Flash).
- La misma deriva `res://src/` podria existir en documentos de otros modulos: **no se revisaron**
  (no son de M17).
- M17 = 148/175, 0 `[?]`, 0 items inflados.
