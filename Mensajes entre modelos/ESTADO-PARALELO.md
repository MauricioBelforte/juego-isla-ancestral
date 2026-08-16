# ESTADO-PARALELO.md — Coordinación de Agentes

> **Modelo:** Deepseek V4 Flash
> **Plataforma:** OpenCode
> **Última actualización:** 2026-08-16 17:35:00

## NORMA DE CARPETAS (2026-08-16, decisión del usuario)

**Toda carpeta de componente se nombra `{ID-Módulo}-{Nombre}` según el ID de `CHECKLIST-GLOBAL.md`** (ej: `102-Bug-Tracking`, `103-Logging`, `31-Ciclo-Dia-Noche`). NO usar numeración cronológica, el orden de creación ni prefijos duplicados. El primer intento de SWE-1.6 (`30-Bug-Tracking`/`31-Bug-Tracking`) se renombró a `102-Bug-Tracking` — la ruta correcta es esa.

## Agentes activos

| Agente | Modelo | Plataforma | Estado | Tareas |
|---|---|---|---|---|
| Coordinador/documentación de módulos delegables | Deepseek V4 Flash | OpenCode | 🟢 Activo | M30 ✅ terminado. Siguientes: M31, M32, M41-M44, M57 (en orden) |
| Documentación de módulos triviales (Tanda A + B) | SWE-1.6 | DEVIN | 🔵 Activo (M102 completado; reanuda tras desbloqueo) | Tanda A restante: 103, 107, 110, 111, 122, 152, 88, 90, 91. Tanda B: 69, 72, 104, 118, 131, 149, 153 |
| — reservado — | — | — | — | M29 y M30 (documentados por Deepseek V4 Flash, libres para implementar después de GameClock) |

## Reglas de no-pisado

- **Zona de Deepseek V4 Flash (OpenCode):** módulos 31, 32, 41, 42, 43, 44, 57. No tocar.
- **Zona de SWE-1.6 (DEVIN):** módulos 103, 107, 110, 111, 122, 152, 88, 90, 91, 69, 72, 104, 118, 131, 149, 153 (carpeta `{ID}-Nombre`, ej. `103-Logging`). No tocar. M102 ya fue completado.
- **Zona común:** `CHECKLIST-GLOBAL.md` (solo actualizar filas propias), `Logs/ULTIMO_NUMERO.txt` (secuencial, leer y avanzar), `Logs/` (solo crear), `DOCUMENTACION/README.md` (solo agregar entradas propias).
- **Prohibido para ambos:** `00-PLAN-INICIAL/`, `plan-inicial/` de módulos ajenos, archivos `*-ACTUAL.md` de la raíz.

## Historial de completados

| Módulo | Agente | Fecha | Estado |
|---|---|---|---|
| 29 — Tiempo y Calendario | Deepseek V4 Flash | 2026-08-16 | ✅ Documentado (104/104), push `a3287a2` |
| 30 — Reloj en Tiempo Real | Deepseek V4 Flash | 2026-08-16 | ✅ Documentado (104/104), push `2a37b98` |
| 102 — Bug Tracking | SWE-1.6 (DEVIN) | 2026-08-16 | ✅ Documentado (121/121), carpeta renombrada a `102-Bug-Tracking` por coordinador |