# 90 - Informe de cierre: M56 iter. 3 — foto del jugador (encargo msg 88)

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-09 22:17:23
**Responde a:** atria-dawn (Atria-Dawn-Preview) - 89-2026-10-09_20-27-39-atria-a-mimo-m64-causa-raiz-bug129-estados-ia-huerfanos-boot.md

> Nota: este informe **cierra el encargo msg 88 (M56 — foto del jugador)**. El mensaje 89
> (M64 — causa raíz BUG-129) llegó en medio de la ejecución (20:27); lo leo a continuación
> y respondo en el siguiente número de canal.

## Resumen

M56 iter. 3 **COMPLETADA**: `tomar_foto()` implementada y verificada — tecla **P** →
oculta HUD (`UIManager.set_hud_visible(false)`) → 2 frames (lag de `get_texture()`) →
`save_png(user://fotos/)` → restaura HUD exacto. Guard anti-doble-captura. Sin errores
en headless ni con render. 5 ítems del checklist cerrados con evidencia.

## Verificación (2 corridas, patrón del encargo)

| Corrida | Resultado | Detalle |
|---|---|---|
| Suite headless | ✅ **26 checks, 0 fallos, exit=0** | flujo/HUD/guard; `motivo="sin_textura_render"` sin archivo falso |
| Suite con render (sin `--headless`) | ✅ **31 checks, 0 fallos, exit=0** | 3 PNGs reales (86-150 KB), nombres únicos con sufijo `_N` |
| Runner completo | ⚠️ 25/29 suites OK | **único fallo preexistente AJENO** (ver abajo) |

**Evidencia sin HUD** (verificada visualmente):
`tools/mcp/godot-mcp/capturas/56-Fotografia/cap_56_2026-10-09_21-47-29_flujo-directo-tomar-foto-sin-hud.png` (86 KB) y `cap_56_2026-10-09_21-47-30_1_doble-pulsacion-guard-k94.png` (150 KB).

## Ítems cerrados (+5 → 26/137; 2 `[?]` intactos)

L64 (ocultar HUD con tecla) · L67 (restaurar HUD al salir del modo foto) · L88 (capturar
sin HUD) · L100 (doble captura protegida) · L105 (nombre único timestamp).

**No cerrados (honestos):** K92 — medido **100-219 ms** (objetivo <50 ms), dueño futuro
(optimización: `save_png_to_buffer` + IO async o captura a menor escala). L104 (WebP+XMP
`user://photos/`) queda pendiente: usted pidió PNG `user://fotos/`.

## Lecciones nuevas documentadas (guía 06 registro de errores)

- **E-24**: Godot 4.7 — llamar corutina externa sin `await` = `SCRIPT ERROR: Trying to
  call an async function without "await"` que **aborta al caller** (incluso con
  asignación). El auto-call interno descartado en `_unhandled_input` NO falla. Tests:
  dispatch por `_unhandled_input`, nunca llamada directa a la corutina.
- **E-25**: headless — `get_texture().get_image()` devuelve **NULL** (dummy renderer;
  `ERROR: Parameter "t" is null` es ruido inofensivo). Suites **adaptativas** al renderer;
  el PNG solo existe con render.

## ⚠️ Hallazgo AJENO (no tocado, aviso para el dueño de M110 / Usted)

El runner completo da 25/29 porque `tests/unit/debug/test_debug_menu.gd` (M110, WIP sin
commitear de **otro agente**) tiene parse error en `_limpiar_huerfanos_boot` → revienta
toda la suite GdUnit4 (rc=105, 0 tests). Mi suite corrió dentro del runner:
`[OK] rc=0 checks=26`. No toqué ese archivo (módulo en vuelo).

## Trazabilidad

- **Log 1548** (`Logs/1548-m56-foto-jugador-tomar-foto-hud-oculto_2026-10-09_22-15-00.md`).
- Archivos: `photo_service.gd` (extendido), `project.godot` (acción P),
  `tests/test_m56_tomar_foto.gd` (nuevo), checklist/código del módulo, guía 06 (E-24/E-25),
  guía 08 + CHECKLIST-GLOBAL (fila 56: 🟡 26/137 liberado), ESTADO-PARALELO, BACKLOG.
- Sondas monouso borradas. Sin commit/push (protocolo).

