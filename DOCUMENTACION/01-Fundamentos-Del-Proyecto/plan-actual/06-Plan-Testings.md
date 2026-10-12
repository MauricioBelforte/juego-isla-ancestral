**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# 06-Plan-Testings.md — Módulo 01: Fundamentos del Proyecto

> **Iter. 1 (2026-10-12, Log 1722).** Este archivo existía **vacío (0 bytes)** desde el 2026-08-26,
> igual que su gemelo en `plan-inicial/`. Un archivo de 0 bytes no es un plan: es un hueco (un lector
> que no itera no es un aprobado). Se escribe con las cifras **medidas** de la corrida real.

## 1. Objetivo y alcance

El módulo 01 tiene **dos capas**, de naturaleza distinta:

| Capa | Artefacto | Naturaleza |
|---|---|---|
| (a) **Núcleo ejecutable** | `scripts/proyecto/fundamentals_validator.gd` + `data/proyecto/fundamentos.json` + `scripts/proyecto/test_fundamentals_m01.gd` | GDScript puro (data-driven) |
| (b) **Índice maestro** | `plan-actual/05-Checklist.md` (los **152 módulos** del plan inicial) | Documental |

Este documento cubre **(a)**, que es lo único con suite. La capa (b) se **mide por script** (§5): no
tiene suite propia porque sus 152 ítems son **módulos**, no tareas, y cada uno tiene su propia suite
en su propio componente.

**Fuera de alcance (con dueño):** los 152 componentes del índice. M01 mantiene el índice; **no**
verifica los módulos ajenos.

## 2. Herramienta

Godot 4.7.2 headless (el ejecutable es un **directorio** en este entorno):

```
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral \
  --script res://scripts/proyecto/test_fundamentals_m01.gd
```

**Filtrar siempre la salida.** El proyecto arranca TODOS los autoloads en modo `--script` y varios
arrastran un `Parse Error` propio y **ajeno** (medido 2026-10-12: `Could not parse global class
"BlockType" from "res://scripts/world/block_type.gd"` + `Invalid access to property or key
'detection_interval' on a base object of type 'RayCast3D'`). Eso **ensucia el conteo de
`SCRIPT ERROR` de cualquier suite** (trampa AF del skill). La evidencia del módulo son sus propias
lineas `=== [M01] ... ===` y `=== Resumen M01 ... ===`.

## 3. Suites del módulo

| Suite | Checks | Cobertura | Guardián |
|---|---|---|---|
| `test_fundamentals_m01.gd` (deepseek-v4-flash/Kilo; **endurecida 2026-10-12**) | 8 | `fundamentos.json` + `FundamentalsValidator`: camino **feliz** (0 errores) y **4 caminos de error** | ✅ 3 capas |

## 4. Guardián de 3 capas (patrón M62 / M60 / M103)

La suite original **no tenía guardián**: contaba `_checks` pero publicaba `0 fallos` sin piso, sin
marcadores de bloque y con `_summary()` **al final de `_run()`**. Endurecimiento aplicado:

1. **Bloques + `_fin("X")`.** `const BLOQUES := ["datos", "validator", "errores"]`. Si un `SCRIPT
   ERROR` aborta una función de test, sus `_check()` nunca corren y **nunca fallan**; el marcador que
   falta hace que `_summary()` lo **nombre**.
2. **Piso `CHECKS_MINIMOS := 8`** — **medido** en la corrida verde, no estimado. Si el total baja del
   piso, la suite falla aunque no haya ningún `[FAIL]`.
3. **`_summary()` en su propio `call_deferred`** (registrado en `_init` junto a `_run`). Si `_run()`
   aborta, la cola diferida **sigue**, el resumen corre y sale con código 1 — en vez de colgar el
   `SceneTree` para siempre (trampa 61). `_run()` **no** llama a `quit()`.

El guardián se **probó EN ROJO por inyección** (2 sondas), no se heredó: ver
`07-Resultados-Testings.md` §4.

## 5. La capa documental (índice de 152 módulos): cómo se mide

El `05-Checklist.md` del módulo lista **152 módulos**, no 152 tareas. El mapeo — **no documentado
hasta esta iteración** — es:

> ítem **`**M##**`** ↔ carpeta `DOCUMENTACION/{##+1:03d}-{Nombre}`
> (p. ej. `M007 Mundo Voxel` ↔ `08-Mundo-Voxel`; `M152` ↔ `153-Objetivo-Final`).

Medición de la iter. 1:

- **152/152** ítems resuelven a una carpeta; **149** con nombre coincidente y **3** con nombre
  distinto: `M131`→`132-Produccion-De-Equipo`, `M151`→`152-Principios-Innegociables`,
  `M152`→`153-Objetivo-Final`.
- **22** módulos con checklist propia **100 % cerrada** (`[?]=0` y `[ ]=0`); **21** de ellos con la
  fila de `CHECKLIST-GLOBAL.md` en `✅`. `M024 Ruinas` está cerrado pero en
  `🟡 Con dudas (deuda implementación)` → **no** es candidato.
- Suma de los 152 sub-checklists: **14 334 `[x]` / 1 241 `[?]` / 6 421 `[ ]` = 21 996** ítems.

**Regla dura que gobierna el marcado** (commit `41ff104`, del dueño, 2026-08-24, que **revirtió 68
`[x]`** de este mismo archivo): `[x]` = **código implementado + testing**, *no* «sólo documentación».
Por eso este módulo **no flipea marcas por su cuenta**: **propone** los 21 candidatos al director
(§5 de `07-Resultados-Testings.md`).

## 6. Criterios de aceptación

- `EXIT 0` y `0 fallos` en **3 corridas consecutivas**.
- Los **3 bloques** cierran (sin abortos silenciosos).
- El total **no baja** del piso `CHECKS_MINIMOS = 8`.
- El guardián **falla** al inyectar un aborto de bloque y al subir el piso (probado, no supuesto).

## 7. Qué NO cubre (honestidad obligatoria)

- Los **152 módulos** del índice: cada uno tiene su propia suite; M01 sólo mantiene el índice.
- Integración M01↔M02: `test_vision_m02.gd` es de M02 (fuera de alcance).
- El `SCRIPT ERROR` de autoloads ajenos (`block_type.gd`): se **reporta**, no se toca (zona ajena).
- La suite **no está cableada en `quality.yml`** (no aparece ninguna cita a `test_fundamentals_m01`
  en los 6 workflows). Cablearla es de quien administra el CI; se reporta.
