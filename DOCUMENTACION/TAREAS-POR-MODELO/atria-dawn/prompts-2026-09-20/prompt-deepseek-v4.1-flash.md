# PROMPT — deepseek-v4.1-flash (WorkBuddy)
**Asignado por:** atria-dawn (coordinación, Log 1091)
**Fecha:** 2026-09-20
**Tarea:** M103 Logging — cerrar los 12 `[?]`

---

## Contexto para ti

**M103 es TU módulo.** Hiciste la iter. 1 (Log 918, 2026-09-15):
- Suite `test_logging_m103_iter1.gd` → **131 checks / 0 fallos ×3**, 0 SCRIPT ERROR
- **7 fixes reales:** `log_buffer` eliminado (código muerto) · rotación disparada desde
  `_log()` con contador `_bytes_written` · JSON con contexto INVÁLIDO (faltaba coma) ·
  `export_by_date(hours)` no-op (regex exigía espacio, Godot emite `T`; comparaba días) ·
  `export_by_level`/`export_by_category` ahora entienden JSON · `_json_escape` escapa CR/TAB ·
  `LogRotator.get_size()` devolvía caracteres, no bytes
- Dejaste el módulo en **167 `[x]` · 12 `[?]` · 0 `[ ]`**

El módulo estuvo 🔵 a nombre de kimi-k3 pero **nunca lo tocó** (stale desde 2026-09-15).
**Reasignado a ti** — los `[?]` son decisiones de diseño (tu especialidad) y el scope
encaja en tu límite de tokens.

## Tus 10 ítems

`DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/103-Logging/checklist.md`:

| Ítem | Qué es | Esfuerzo |
|---|---|---|
| T-093 | Definir buffer de escritura (performance) | [S] |
| T-094 | Definir flush periódico (cada 100 líneas o 1s) | [S] |
| T-130 | Definir búsqueda de texto | [S] |
| T-133 | Definir scroll en consola in-game | [S] |
| T-134 | Definir coloreado por nivel (INFO=blanco, ERROR=rojo) | [S] |
| T-135 | Definir timestamp relativo (hace X segundos) | [S] |
| T-142 | Definir impacto máximo en frame budget (< 0.5%) | [S] |
| T-153 | Criterios de aceptación cumplidos | [M] |
| **T-165** | **Implementar buffer + flush periódico** — el único [M] real | [M] |
| T-178 | Regresión: 6 tests economía/tiendas/tiempo con 0 fallos | [S] |

## ⚠️ NO toques T-022 ni T-109

- **T-022** (RF18: crash reporting integración) y **T-109** (bug_{timestamp}.log) son de
  **M122 Crash-Reporting (kimi-k3)**.
- Déjalos `[?]` con dueño M122 y documenta la dependencia. **No los implementes.**

## Método (el tuyo, probado en Log 918)

1. **Los 7 "Definir X" [S]**: documenta la decisión de diseño en
   `plan-actual/03-Diseno.md` con **criterios medibles** (ej: "buffer de 8KB", "flush cada
   100 líneas O 1s, lo que ocurra primero"). Marca `[x]` solo si la decisión queda
   respaldada por código existente o es una decisión explícita y coherente.
2. **T-153**: verifica los criterios de aceptación del módulo uno por uno contra el código.
3. **T-165 (implementación real)**: buffer + flush en el Logger. Nueva suite
   `test_logging_m103_iter2.gd` con guardián anti-falso-verde (marcador `_fin` por bloque +
   watchdog, como en tu iter. 1). Verifica con el binario **Godot 4.7.2** real.
4. **T-178**: re-corre las 6 suites de economía/tiendas/tiempo con el autoload activo.

## Meta

M103: **167 → 177+ `[x]`**, con T-022/T-109 explícitamente diferidos a M122.

## Recordatorios

- Reserva log: `python scripts/reservar_log.py --reservar --agente DeepSeek-V4.1-Flash --modulo 103`
- Binario: `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
  `--headless --path game/isla-ancestral --quit --script res://...`
- **Anti-falso-verde (lección 28):** exit code **Y** 0 SCRIPT ERROR en stderr
- Push a git: **NEGATIVO**
- Sync de los **3 registros**: `05-Checklist.md` (marcas **y** `**Totales:**`),
  `CHECKLIST-GLOBAL.md`, tu backlog
- Codificación UTF-8 obligatoria
