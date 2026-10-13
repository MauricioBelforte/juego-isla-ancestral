# Log 1649: M74 — fix de L45 aplicado, suite corre hasta el final (1 fallo real restante)

**Fecha:** 2026-10-11
**Hora:** 08:25
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

El director autorizó el fix de L45 (msg 108). Lo apliqué con backup y re-corrí la suite.
**El `SCRIPT ERROR` está resuelto: la suite ahora corre completa hasta el `Resumen`.** Queda un
fallo real, con causa localizada, que requiere decisión de fondo.

## Cambios Realizados

### 1. Fix aplicado (autorizado)

`game/isla-ancestral/scripts/eventos/test_event_manager_headless.gd` — backup en
`Obsoletos/2026-10-11_04-11-15_test_event_manager_headless.gd`.

```gdscript
# ANTES (L45-46) — Resource.get() con 2 argumentos, invalido en Godot 4
var mes: int = int(primer_ev.get("mes", primer_ev.mes))
var dia: int = int(primer_ev.get("dia", primer_ev.dia))

# AHORA
var mes: int = int(primer_ev.mes)
var dia: int = int(primer_ev.dia)
```

Diff: **2 inserciones / 2 borrados**. Sin BOM, sin caracteres de control.

### 2. Suite re-corrida (con `--quit-after 600`)

```
=== Resumen M74: 8 checks, 1 fallos ===
exit code 1 · SCRIPT ERROR: 0
```

Las 8 líneas de la suite:

| Check | Resultado |
|---|---|
| EventManager instanciado | ✅ |
| **Catálogo con eventos reales (15)** | ❌ |
| Primer evento con id | ✅ |
| Evento con semana programada (mes 11 dia 15) | ✅ |
| Día sin evento: flujo sin fallo | ✅ |
| Día del evento: verificación sin fallo | ✅ |
| Día siguiente: cierre sin fallo | ✅ |
| normalizar_agenda sin fallo | ✅ |

### 3. El fallo restante — causa exacta

`test_event_manager_headless.gd:31`:

```gdscript
_check("Catálogo con eventos reales (15)", catalogo.size() == 15)
```

**El catálogo real tiene 44 eventos** (contados del log de carga). Los 7 capítulos de la historia se
agregaron en la iter. 2 (2026-09-07, glm-5.3-flash) sobre la base original, pero la aserción quedó
fija en 15. La expectativa quedó en el pasado, igual que el `SCRIPT ERROR`.

### 4. Estado del módulo tras el fix

| Suite | Antes | Ahora |
|---|---|---|
| `test_event_manager_headless.gd` | ❌ SCRIPT ERROR (no llegaba al Resumen) | ⚠️ 8 checks / 1 fallo (exit 1) |
| `test_capitulos_m74.gd` | ✅ 23/0 | ✅ 23/0 |
| `test_event_manager_pure.gd` | ✅ 31/0 | ✅ 31/0 |

**Totales del módulo: 7 checks en verde adicionales y el `SCRIPT ERROR` eliminado.**

## Archivos Modificados/Creados

**Modificados:**
- `game/isla-ancestral/scripts/eventos/test_event_manager_headless.gd` (L45-46)

**Creados:**
- `Logs/1649-M74-fix-L45-aplicado-suite-corre-1-fallo_2026-10-11.md`

## Pendiente

- El check de L31 espera 15 y el catálogo tiene 44. **No cambié el número** — decidir si la
  aserción debe ser `>= 15`, `== 44`, o reflejar el catálogo esperado, es decisión de fondo del
  director.
- Re-verificación §21.8 completa de M74 tras cerrar ese fallo (verificador ≠ autor glm-5.3-flash).
- El director dijo que corregirá `Prioridad` de M74: `glm-5.3-flash` → `Media`.
