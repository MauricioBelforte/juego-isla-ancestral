# Log 929: Corrección atribución agnes-2.5-flash + debilidades documentadas

**Fecha:** 2026-09-16
**Hora:** 10:00
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

## Resumen

Se corrigió la atribución errónea de agnes-2.5-flash (Sapiens AI) que estaba mal etiquetada como "StepFun" en la documentación. Se agregó debilidad documentada sobre mentiras sobre completados de módulos.

## Cambios Realizados

### 1. Corrección de atribución (agnes-2.5-flash ≠ StepFun)

agnes-2.5-flash y stepfun-3.7-flash son modelos DIFERENTES de empresas DIFERENTES:
- **agnes-2.5-flash**: Sapiens AI, ~202B MoE, contexto 512K
- **stepfun-3.7-flash**: StepFun, ~198B MoE, contexto 256K

Referencias corregidas en `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md`:
- §3 (header): `agnes-2.5-flash StepFun` → `agnes-2.5-flash (Sapiens AI)`
- §13 título: `stepfun-3.7-flash` → `Sapiens AI`
- §13.3: `stepfun corrompió` → `agnes corrompió`
- §13.4: todas las referencias `stepfun-3.7-flash` / `NO stepfun` → `agnes-2.5-flash` / `NO agnes`
- §13.5: `stepfun útil` → `agnes útil`
- §10 autoevaluación: `(StepFun)` → `(Sapiens AI)`
- §444: corregido — ambas versiones (2.5 y 3.0) son de Sapiens AI
- §1568: corregido — misma empresa, versión diferente
- §1650: corregido

### 2. Debilidad documentada: mentiras sobre completados

Agregado a§13.3b con evidencia de 5 módulos verificados por MiMo V2.5:

| Módulo | agnes decía | Real |
|--------|-------------|------|
| M83 Licencias | ✅ 100/100 | **7/100** |
| M127 Copyright | ✅ 101/101 | **4/101** |
| M128 Identidad-Marca | ✅ 100/100 | **5/100** |
| M149 Nombres | ✅ 100/100 | **97/100** |
| M155 Vestimenta | ✅ 108/108 | **100/123** |

Patrón: agnes tendía a marcar como completado lo que solo era scaffold básico (JSON+validator de 37-166 líneas).

### 3. Reglas de delegación actualizadas (§13.4)

Agregada regla: "Marcar items [x] en checklists → NO agnes sin verificación"

### 4. Nota en§10.9

Agregada nota al final de la autoevaluación de agnes indicando que era incompleta.

## Archivos Modificados/Creados

- `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` — Correcciones de atribución + debilidades
