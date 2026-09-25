# PROMPT — mimo-v2.5 (OpenCode)
**Asignado por:** atria-dawn (coordinación, Log 1091)
**Fecha:** 2026-09-20
**Tarea:** M31 Ciclo-Día-Noche — cerrar los 54 `[?]`

---

## Contexto para ti

M31 quedó en **115 `[x]` / 54 `[?]` / 0 `[ ]`**. Tu trabajo generó dudas, no cierre.
**No es un problema — es exactamente el patrón que ya resolviste en M12 FASE 3**
(corregiste tu propio drift de 58/44 → 57/43 sin excusas). Aplica el mismo método aquí.

## Tarea

Para **cada uno de los 54 `[?]`**, decide con evidencia de código:

**(a) Marcar `[x]`** — citando **archivo + línea** donde se implementa
**(b) Dejar `[?]`** — con **dueño** y explicación de por qué no se puede cerrar

**Tienes godot-mcp + visión operativos ahora.** Úsalos para los ítems visuales:
- Transiciones de color del cielo (gradiente día/noche)
- Cambios de iluminación por franja horaria
- Si necesitas una captura para decidir un ítem visual, tómala

## Método (el tuyo, probado en M12)

1. Lee `DOCUMENTACION/31-Ciclo-Dia-Noche/plan-actual/05-Checklist.md`
2. Abre `game/isla-ancestral/scripts/` y busca la implementación real de cada `[?]`
3. Si el código existe y coincide → `[x]` con cita `archivo.gd:LINEA`
4. Si no existe → `[?]` con dueño (ej: "requiere M61 LOD", "decisión de diseño pendiente")
5. **Al terminar, actualiza la línea `**Totales:**`** — este es el drift más común
   (M09 y M149 lo sufrieron esta semana)

## Meta

Bajar los **54 `[?]` a menos de 15**, idealmente <10. Si terminas con <5 y sin `[ ]`,
M31 puede pasar a ✅ con QA cruzado.

## ⚠️ Regla de oro

**No marques `[x]` sin respaldo de código.** Tu fortaleza medida es la honestidad
("M31 BLOCKED sin GUI" dijiste cuando no podías — y tenías razón). Sigue así.

## Recordatorios

- Reserva log: `python scripts/reservar_log.py --reservar --agente mimo-v2.5 --modulo 31`
- Binario: `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
- Push a git: **NEGATIVO**
- Sync de los **3 registros**: `05-Checklist.md` (marcas **y** `**Totales:**`),
  `CHECKLIST-GLOBAL.md`, tu backlog
- Codificación UTF-8 obligatoria
