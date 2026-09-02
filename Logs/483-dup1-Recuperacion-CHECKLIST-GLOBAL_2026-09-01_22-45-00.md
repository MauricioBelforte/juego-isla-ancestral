# Log 414: Recuperación de CHECKLIST-GLOBAL.md dañado + re-aplicación del sprint — glm-5.3-flash

**Fecha:** 2026-09-01
**Hora:** 22:45
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen

CHECKLIST-GLOBAL.md quedó dañado (94 líneas, tabla truncada en el módulo 16, doble encoding) tras una edición PowerShell con pipeline roto — el archivo se truncó al escribir. Recuperación completa ejecutada.

## Recuperación

1. **Backup del estado dañado** en `Obsoletos/2026-09-01_22-40-00_CHECKLIST-GLOBAL-da%C3%B1ado.md` (§5 de AGENTS.md).
2. **Restauración desde git HEAD** (commit 93e217a — 167 filas sanas, sin mojibake). Se perdieron solo los cambios de coordinación posteriores al último commit.
3. **Re-aplicación de las 12 filas de mi sprint** (M71, M72, M28, M37, M55, M92, M87, M66, M62, M57, M23, M16) con sus liberaciones completas — contenido idéntico al perdido.
4. **Verificación de integridad**: 167 filas, 0 líneas con mojibake.

## Cambios no recuperables (otros agentes)

Los cambios de coordinación de OTROS agentes posteriores al último commit (reservas de agnes M110, MiniMax M36/M73, Hy3, stepfun M159/M160, y el cierre de M165/M167 de glm-5.3/Cline) se perdieron con el truncado. Los agentes dueños deberán re-aplicar su fila si su reserva/liberación no aparece (sus ESTADO-PARALELO.md tienen el detalle).

## Causa raíz (para el protocolo)

La edición PowerShell con `$lineas -split "\`r?\`n"` + WriteAllBytes corrompió el encoding al aplicar una fila con caracteres UTF-8 multibyte (la fila 16 con 🟡). Regla nueva para el protocolo: editar CHECKLIST-GLOBAL.md SOLO con herramientas de edición con encoding UTF-8 garantizado (edit tool), nunca con pipelines de PowerShell que re-codifican.

## Archivos Modificados

- `CHECKLIST-GLOBAL.md` (restaurado desde HEAD + 13 filas re-aplicadas)
- `Obsoletos/2026-09-01_22-40-00_CHECKLIST-GLOBAL-da%C3%B1ado.md` (backup del estado dañado)
