# Log 1648: M74-Eventos — bloqueo, re-QA §21.8 y fallo real de suite detectado en producción

**Fecha:** 2026-10-11
**Hora:** 08:00
**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code

## Resumen

Asignación del director (msg 102, recordada en msg 106): **M74-Eventos**, 🟡 Liberado, stale desde
2026-09-07, con sello previo **Log 856 inválido** (cierre de agnes-2.5-flash, mismo patrón que
866/867 — verificado contra `Logs/856-AGNES-M54-AVANCE-RESUMEN_2026-09-12.md`).

Bloqueé el módulo en GLOBAL, leí el plan-actual, verifiqué el código en disco y corrí las suites
headless. **Encontré un fallo real de producción en una de las suites**, con causa exacta localizada.

## Cambios Realizados

### 1. Bloqueo en GLOBAL

`CHECKLIST-GLOBAL.md` L288:
- Estado: `🟡 Liberado (iter. 2 capítulos 1-7)` → `🔵 En curso (re-QA §21.8 stepfun-step-5-preview)`
- Agente actual: `—` → `stepfun-step-5-preview`
- Fila verificada tras el cambio: 12 pipes sin escapar, 11 celdas, cierra con `|` ✅

### 2. Conteo del módulo (verificado contra disco)

| Fuente | Valor |
|---|---|
| `05-Checklist.md` (`^\s*-\s+\[[ x?]\]`) | **95 [x] / 2 [ ] / 188 [?] = 285** |
| Línea Totales del checklist | 285 · 95 · 2 · 188 ✅ coincide |
| `CHECKLIST-GLOBAL.md` L288 | **95/285** ✅ coincide |

### 3. Código real en disco (sí existe)

`game/isla-ancestral/scripts/eventos/`:
- `event_manager.gd`, `event_definition.gd`, `event_state.gd`, `condicion_evento.gd`,
  `contexto_festival.gd`, `recompensa_def.gd`
- `data/capitulos/` con los **7 `.tres`** de capítulos (c1 mural → c7 cámara del sello)
- 3 suites: `test_capitulos_m74.gd`, `test_event_manager_headless.gd`, `test_event_manager_pure.gd`

### 4. Suites ejecutadas

| Suite | Resultado |
|---|---|
| `test_capitulos_m74.gd` | ✅ **23 checks, 0 fallos, EXIT 0** |
| `test_event_manager_headless.gd` | ❌ **SCRIPT ERROR** en L45 — ver abajo |
| `test_event_manager_pure.gd` | ⏸ no ejecutada aún |

**Nota de ejecución:** las suites arrancan el boot completo del proyecto (autoload `Bootstrap` carga
`main_island.tscn`), por lo que el proceso no termina solo. Hizo falta `--quit-after 600`. Es la
trampa documentada en MEMORY.md L22.

### 5. ⚠️ FALLO REAL detectado en `test_event_manager_headless.gd`

```
L270:  [FALLO] Catálogo con eventos reales (15)
L272:  SCRIPT ERROR: Invalid call to function 'get' in base 'Resource (EventDefinition)'. Expected 1 argument(s).
L273:     at: _run (res://scripts/eventos/test_event_manager_headless.gd:45)
```

**Causa exacta** (`test_event_manager_headless.gd:45`):

```gdscript
var mes: int = int(primer_ev.get("mes", primer_ev.mes))   # <-- 2 argumentos
```

En Godot 4, `Resource.get()` acepta **un solo** argumento; no existe la variante con valor por
defecto. La suite quedó rota en producción desde que se escribió (glm-5.3-flash, 2026-09-05).

**La suite nunca llega al `=== Resumen ===`** — muere en L45, antes de los 31 checks que declara.
O sea: el `0 fallos` que esa suite pueda haber reportado alguna vez **no es reproducible hoy**.

**Fix propuesto** (no aplicado — READ-ONLY sobre marcas):

```gdscript
var mes: int = int(primer_ev.mes)
var dia: int = int(primer_ev.dia)
```

`EventDefinition` tiene ambas propiedades `@export` (L27 `dia`, L29 `mes`), así que el acceso directo
es suficiente y no cambia la semántica.

## Archivos Modificados/Creados

**Modificados:**
- `CHECKLIST-GLOBAL.md` (L288: estado y agente de M74)

**Creados:**
- `Logs/1648-M74-Eventos-bloqueo-reqa-fallo-suite_2026-10-11.md`

## Pendiente

- Ejecutar `test_event_manager_pure.gd` con `--quit-after`.
- Aplicar el fix de L45 (decisión del director).
- Re-correr la suite tras el fix para tener un `Resumen` real.
- El sello §21.8 de M74 requiere re-verificación completa: verificador ≠ autor (el autor es
  glm-5.3-flash).
