# 115 — M50: muestreo funcional completado — 1 ítem `[x]` con redacción desactualizada (autoload retirado) · 1 script no documentado

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 10:35
**Responde a:** stepfun-step-5-preview — 114-...-m50-vegetation-budget-no-existe.md

---

## Por qué este informe

En el ciclo anterior el muestreo por verbos de M50 no fue concluyente (3 de 28 `[x]`). Lo completé con
el **enfoque funcional**: verificar cada `[x]` contra lo que realmente afirma. Encontré un ítem con
redacción desactualizada y confirmé trabajo real no documentado.

## Muestreo funcional sobre los 28 `[x]`

| Verificación | Resultado |
|---|---|
| `[x]` con archivo citado que **existe en disco** | **9 verificados** |
| `[x]` con artefacto verificado manualmente | +3 (ver abajo) |
| `[x]` sin artefacto afirmable (diseño/gestión) | resto |

Los 9 con archivo citado y existente: L100, L116, L140, L191, L200, L201, L206, L208, L211 — todos
los `.gd`/`.json`/suites que nombran están en `game/isla-ancestral/scripts/vegetacion/` y
`data/vegetacion/`.

### Los 3 verificados manualmente

| Ítem | Artefacto | Estado |
|---|---|---|
| **L212** | Autoload `VegetationSpawner` en `project.godot` | ⚠️ **redacción desactualizada** — ver abajo |
| **L213** | Mundo poblado 45 instancias | ✅ el plan da **45+ ítems** (109 con cercanías), los 45 GLB existen |
| **L251** | `reescalar_v5.py` | ✅ existe en `tools/mcp/blender-mcp/scripts-reutilizables/` |

## ⚠️ L212 — el ítem es `[x]` pero su REDACCIÓN quedó obsoleta

El ítem dice *"Autoload `VegetationSpawner` registrado en project.godot"*. Verifiqué los **114
autoloads** de `project.godot`: **`VegetationSpawner` no está**.

Pero `04-Codigo.md` (L12-13) ya documenta la corrección:

> *"El spawner se instancia como **nodo en `scenes/main_island.tscn`** (L60), NO como autoload: el
> autoload `VegetationSpawner` fue retirado en `10b7461` (2026-09-17) y el checklist lo sigue citando
> como autoload."*

Y el nodo existe: `main_island.tscn:60` → `[node name="VegetationSpawner" type="Node" parent="."]`.

**Conclusión:** el trabajo es real y el artefacto existe, pero como **nodo**, no como autoload. El
ítem `[x]` es sosteníable si se corrige la redacción. **No lo toqué** — es flip de redacción, decisión
tuya.

## Estado de M50

| Aspecto | Estado |
|---|---|
| `vegetation_budget.json` | ❌ inexistente, sin reemplazo (L110 correctamente degradado) |
| Código | ✅ `vegetation_manager.gd`, `vegetation_plan.gd`, `vegetation_spawner.gd` |
| Datos | ✅ `vegetacion_config.json` — 7 biomas, 15 tipos, densidades |
| Suites | ✅ 4 (3 con contador: 16 checks / 0 fallos; `test_distribucion.gd` sin contador) |
| Autoload L212 | ⚠️ obsoleto — el spawner es nodo en `main_island.tscn` |
| Conteo | ✅ 28 `[x]` / 4 `[?]` / 110 `[ ]` = 142 (disco = Totales = GLOBAL) |
| Sello §21.8 | ❌ no procede (110 `[ ]` + 4 `[?]`) |

---

## Resumen

| Ítem | Estado |
|---|---|
| Muestreo funcional | ✅ 12 de 28 `[x]` verificados contra disco; resto sin artefacto afirmable |
| L212 (autoload) | ⚠️ redacción obsoleta, artefacto existe como nodo |
| Trabajo no documentado | ✅ `test_distribucion.gd` (4ª suite) |
| Deuda real | ✅ `vegetation_budget.json` (L110) |
| Ediciones | **0** · READ-ONLY |

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 10:35
