# Log 1659: M50 — decisiones aplicadas · M113 — QA con deuda de baseline

**Fecha:** 2026-10-11
**Hora:** 10:55
**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code

## Resumen

El director aceptó la QA de M50 y dio dos decisiones de edición (msg 116). Las apliqué con backup.
Después verifiqué **M113-Pruebas-De-Stress** (el módulo que el director ofrecía). Encontré que el
`baseline` que las notas citan como "versionado" **no está en el repo**, pero el código lo maneja
correctamente.

## M50 — decisiones aplicadas

**Backup:** `Obsoletos/2026-10-11_05-11-32_05-Checklist-M50.md`

### 1. L110 — eliminado (decisión del director)

El ítem `[?] Definir registro vegetation_budget.json` pasó a:

```
[x] ~~Definir registro vegetation_budget.json~~ ELIMINADO (director, 2026-10-11, msg 116):
el rol de presupuesto por bioma lo cumple `densidad` en `data/vegetacion/vegetacion_config.json`
(12/25/22/10/15/10/30 por bioma). No se crea JSON separado. Evidencia: verificado por
stepfun-step-5-preview (Log 1657).
```

### 2. L212 — redacción corregida

`Autoload \`VegetationSpawner\` registrado en project.godot` →
`Nodo \`VegetationSpawner\` en \`scenes/main_island.tscn\` (L60) — redacción corregida 2026-10-11…`

### 3. Totales actualizados

`142 · 28 · 110 · 4` → `142 · 29 · 110 · 3` (verificado: 29 `[x]` / 3 `[?]` / 110 `[ ]` = 142).

### 4. Sin regresión

`test_vegetation_headless.gd` → **7 checks, 0 fallos, EXIT 0** tras las ediciones.

## M113 — QA (módulo ofrecido por el director)

| Verificación | Resultado |
|---|---|
| Disco (`^\s*-\s+\[[ x?]\]`) | **131 `[x]` / 0 `[?]` / 1 `[ ]` = 132** |
| Línea Totales (L259) | 132 · 131 · 1 · 0 ✅ |
| GLOBAL | **131/132** 🟡 Liberado ✅ |
| Director (msg 116) | "131/132, Ling audité, 1 `[ ]` con dueño" — **coincide** |

### El `[ ]` (L70)

```
- [ ] Definir prueba con cámara rápida (sobrevuelo) [S]
```

**NO tiene dueño asignado.** El director dijo "1 `[ ]` con dueño" — la nota de GLOBAL menciona a
`deepseek-v4-flash-vision-exp` en la columna `Recom`, pero el ítem en sí no nombra dueño. Es una
discrepancia menor entre el resumen del director y el ítem.

### ⚠️ `perf_base.json` — citado como "baseline versionado", no existe

| Verificación | Resultado |
|---|---|
| `scripts/stress/perf_base.json` | ❌ no existe |
| Búsqueda en todo el repo (fuera de `.git`) | ❌ no existe |
| Referencias en `stress_runner.gd` | 0 |
| Referencias en `test_stress_m113_comparador.gd` | 0 |

El código es honesto al respecto: `stress_comparator.gd:17` declara
`const RUTA_BASELINE := "res://scripts/stress/perf_base.json"` con la aclaración *"se versiona en el
repo; es el objetivo de referencia"*, y la suite verifica el caso **sin baseline**
(`hay_baseline=false → no regresion → sin_dato`).

### Suite ejecutada

```
test_stress_m113_comparador.gd → 19 checks, 0 fallos, EXIT 0
```

Incluido el caso de baseline ausente, que es el estado real del repo.

## Veredicto M113

El módulo está **bien implementado y veraz**: 131/132 cuadra en 3 fuentes, la suite pasa con 19
checks y el comparador es correcto. La deuda es menor y concreta:

1. **`perf_base.json` no está versionado** pese a que `RUTA_BASELINE` apunta ahí. El diseño lo
   contemplaba; el runner tiene `--update-baseline` para generarlo. **No es un bug: es una semilla
   que nunca se corrió.**
2. **L70 sin dueño** explícito.

Con 1 `[ ]`, el módulo está a un ítem del cierre. **No aplico flips** (decisión del director).

## Archivos Modificados/Creados

**Modificados:**
- `DOCUMENTACION/50-Vegetacion/plan-actual/05-Checklist.md` (L110, L212, L276)

**Creados:**
- `Logs/1659-M50-decisiones-aplicadas-M113-qa-baseline_2026-10-11.md`
