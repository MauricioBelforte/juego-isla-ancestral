# Log 1709: M71-Progresion - barrido de verificacion (+19 items) y correccion de mi falso negativo

**Fecha:** 2026-10-12
**Hora:** 01:45
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Dos cosas: (1) corregir mi **falso negativo** sobre `AssetProfile` y (2) el barrido de
verificacion autorizado sobre **71-Progresion** (+19 items).

## 1. Falso negativo propio: AssetProfile SI existe

Reporte que `AssetProfile` "no existia en el repo". Era un **falso negativo**: la clase
esta en `game/isla-ancestral/scripts/rendimiento/asset_profile.gd` y es un
**autoload** (`extends Node`, registrado en `project.godot` como `AssetProfile=`), no
un `class_name`. Mi busqueda filtro por `class_name AssetProfile` y por eso fallo.

**La leccion:** para saber si un identificador existe hay que mirar `project.godot`
(autoloads) ademas de los `class_name`. Es el 7mo falso negativo documentado y el
primero mio por esta via.

**Segunda correccion:** el `Compile Error: Identifier not found: AssetProfile` NO se
arregla refrescando el cache (lo intente con `--editor --quit` y sigue). La causa real
es que los **autoloads no resuelven como identificadores bajo `--script`** (mi propia
leccion E-27/E-28/E-29 de M48): `build_ghost.gd:96` usa `AssetProfile.ruta(...)` en
vez de `get_node_or_null("/root/AssetProfile")`. Eso rompe `iter2`/`iter3` de M17 en
headless, aunque funcione en el editor. **Hallazgo para M166**: su codigo es
editor-only hasta que use el path del autoload.

## 2. Barrido de verificacion: M71-Progresion

Elegido por tener mas `[?]` (141) con codigo existente y suite propia. **M71: 72 -> 91
`[x]` / 213.**

Verificado con `test_progresion.gd` (83 checks, 0 fallos) + APIs confirmadas en
`scripts/progresion/`: RF1 (catalogo de 25+ hitos), RF2 (evaluador AND/NOT/OR),
RF3 (dirty flags, 5000 reevals < 500 ms), RF4 (`activar_desbloqueo`), RF5 (4 senales),
RF9 (`primera_vez`), RF11 (reputacion 60/40), RF12 (titulos), RF13 (save versionado +
purga), RF14 (restore sin re-emision), RF16 (`validar_catalogo`), C66/C67, F100/F101/
F104/F105, G113, G120.

**Quedan [?] a proposito (evidencia negativa):**
- RF6: los "6 puentes de senales M07" no estan en `player_profile.gd`.
- RF7: el enganche con `day_started` de M29 sigue pendiente (nota previa).
- RF10: `reportar_condiciones_imposibles()` no existe (la deteccion si).
- RF1/RF8: el catalogo es JSON, no `.tres`; la presentacion es de M72.

## Verificacion

```
test_progresion.gd   83 checks, 0 fallos   (suite existente, ejecutada)
```

## Archivos Modificados

- `DOCUMENTACION/71-Progresion/plan-actual/05-Checklist.md` (19 flips + nota)
- `DOCUMENTACION/71-Progresion/plan-actual/04-Codigo.md` (Notas del Agente)
