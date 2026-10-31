**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-30

# 07-Resultados-Testings.md — Módulo 22: Historia Principal

> **Iter. 1 (2026-10-30, TANDA 7, msg 467).** Archivo nuevo: el ítem `05-Checklist.md` L127 lo pedía
> (`[ ]`) y no existía. Todas las cifras de este documento son **medidas en la corrida del
> 2026-10-30** con el binario real (`Godot_v4.7.2-stable_win64_console.exe`), no copiadas de otro
> módulo.

## 1. Suite headless — `scripts/historia/test_historia.gd`

| # | Comando | Resultado | Exit |
|---|---|---|---|
| 1 | `--script res://scripts/historia/test_historia.gd` | `=== Resumen M22: 41 checks, 0 fallos ===` | 0 |
| 2 | idem | `41 checks, 0 fallos` | 0 |
| 3 | idem | `41 checks, 0 fallos` | 0 |

- **3/3 corridas idénticas** en conteo y veredicto.
- **0 `SCRIPT ERROR`** en la salida de las 3 (verificado con `grep -acE "SCRIPT ERROR"`).
- **Piso `CHECKS_MINIMOS = 41`** ya declarado en la suite: coincide con lo medido (no se tocó).

## 2. Validador de grafo — `scripts/historia/validar_historia.gd`

| # | Comando | Resultado | Exit |
|---|---|---|---|
| 1 | `--script res://scripts/historia/validar_historia.gd` | `=== VALIDADOR M22 HISTORIA: 79 checks, 0 fallo(s) ===` | 0 |
| 2 | idem | `79 checks, 0 fallo(s)` | 0 |
| 3 | idem (tras restaurar la sonda B) | `79 checks, 0 fallo(s)` | 0 |

- **79 checks** medidos, **0 fallos**, **0 `SCRIPT ERROR`**, **0 `String formatting error`**.
- Advertencia esperada y ahora **legible**:
  `ADVERTENCIA: final 'secreto' exige flag externa 'pistas_secreto_completas' (seteada por M25/M147); in-alcanzable sin esa bandera.`

## 3. Defecto encontrado y corregido en esta iteración

**Síntoma:** el validador imprimía `ERROR: String formatting error: not all arguments converted
during string formatting` (con backtrace a `validar_historia.gd:95`) y la ADVERTENCIA salía con los
placeholders **literales**:

```
ADVERTENCIA: final '%s' exige flag externa '%s' (seteada por M25/M147); in-alcanzable sin esa bandera.
```

**Causa:** en GDScript `%` liga **más fuerte** que `+`. La expresión

```gdscript
print("ADVERTENCIA: ... '%s' ... '%s' ..." + "in-alcanzable ..." % [fid, flag])
```

aplicaba el formato **solo a la segunda cadena** (0 placeholders, 2 argumentos). El primer tramo
conservaba sus `%s` sin sustituir. Y como es un `ERROR` de motor (no un `SCRIPT ERROR`), la ejecución
**continuaba**: el validador terminaba en `0 fallo(s)` con la advertencia mutilada. Un error que no
rompe nada es el que nadie arregla.

**Fix (1 línea, parentizar la concatenación antes del `%`):**

```gdscript
print(("ADVERTENCIA: ... '%s' ... '%s' ..." + "in-alcanzable sin esa bandera.") % [String(fid), String(flags_externos[fid])])
```

**Verificado por sonda EN ROJO** (revertir el fix en el archivo real, correr, restaurar):

| Sonda | Mutación | Resultado medido |
|---|---|---|
| B | quitar los paréntesis (fix revertido) | **1** `String formatting error` + ADVERTENCIA con `%s` literales, exit 0 |
| B-restaurado | `sha256 = 398fdc…5181e` | **0** errores de formato + ADVERTENCIA con `'secreto'` / `'pistas_secreto_completas'`, exit 0 |

## 4. Guarda nueva y probada en rojo

Se agregó al validador un **piso de checks** (antes solo contaba fallos: 0 checks y 100 checks
imprimían lo mismo).

- `CHECKS_MINIMOS = 79` — **medido en verde**, no estimado. (El primer valor que escribí fue 26, una
  estimación; se corrigió al número medido antes de publicarlo.)
- Sonda A: piso a **80** (uno por encima del real) →

```
FALLO: solo 79 checks ejecutados (minimo 80): el validador no midio el grafo
=== VALIDADOR M22 HISTORIA: 79 checks, 1 fallo(s) ===
EXIT 1
```

Restaurado desde backup y verificado por `sha256` (`398fdc05644171f152e3fecd0fc852ab33d5f3cd2aef72cba694eaf08e5181e`).

## 5. Qué queda pendiente (medido, no estimado)

Los **7 ítems de integración** (L89-L95) siguen `[ ]`: `scripts/historia/` tiene **3 archivos** y **0
llamadas `.connect()`** contra los módulos contraparte. Cerrarlos exige cablear 7 integraciones
(M21, M23, M24/M25/M26, M28, M31, M33, M41/M44), cada una con su dueño. **No** es trabajo de una
tanda de documentación: es implementación cruzada.

`05-Checklist.md` de M22: **78 `[x]` / 9 `[ ]` / 4 `[?]` = 91**. Con este par de documentos, los dos
ítems documentales (L126 `06-Plan-Testings.md`, L127 `07-Resultados-Testings.md`) quedan con
artefacto en disco; el flip lo aplica el director.
