# Log 268: M53 — Corrección de superposición reintroducida (violación §9.47)

**Fecha:** 2026-08-30
**Hora:** 05:00
**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Resumen
**Corrección de un error propio.** En la iteración 3 (Log 267) se montó el HUDScreen formal con
widgets por código (ClockWidget, SeasonWidget, ResourceCounter, StatusBar) dentro del UIRoot
(CanvasLayer 100). Eso **reintrodujo la superposición** que MiMo ya había corregido y documentado
en §9.47 (Log anterior: "Se eliminó HotbarWidget duplicado" / commit c6ecf4c). No se releyó la
guía §9.47 ni los últimos logs antes de montar. Corregido: eliminado el HUD duplicado; el UIRoot
solo monta las capas MODALES (que no existían y no duplicaban nada).

## Causa Raíz
Violación directa de la regla §9.47 (07-GUIA-GODOT):
1. Se creó un SEGUNDO CanvasLayer (UIRoot layer 100) con widgets HUD.
2. Se recrearon widgets que YA EXISTEN como oficiales: RelojWidget (w_reloj.gd, escena),
   hotbar (player.gd dinámico), StatusBar (escena, abajo-izq).
3. Los widgets "formales" montados eran versiones inferiores a las oficiales que el otro agente
   había dejado superadoras.

## Cambios Realizados (corrección)

### Código (Godot)
- `scripts/ui/ui_root.gd` — **Eliminado `_build_hud()` completo** (HUDScreen + widgets por código
  + `_posicionar` + `_agregar_widget_hud`). El UIRoot ahora SOLO monta las capas modales del M53
  (DialogLayer, PauseLayer, MenusLayer, ConfirmPopup) que NO existían y NO duplican nada.
  Documentada la regla §9.47 en el header del script.

### Verificación con visión
- Captura `capturas/cap_53_fix_superposicion.png`: superposición ELIMINADA. HUD limpio:
  FPSLabel + ControlsLabel legibles (arriba-izq), StatusBar oficial (abajo-izq), sin reloj
  duplicado ni widgets superpuestos. Mundo y jugador correctos, FPS 60.
- `test_ui_framework.gd`: 0 fallos (las capas modales siguen funcionando).

## Archivos Modificados
| Archivo | Acción |
|---------|--------|
| `scripts/ui/ui_root.gd` | Modificado (eliminado HUD duplicado) |
| `tools/mcp/godot-mcp/capturas/cap_53_fix_superposicion.png` | Creada (evidencia) |
| `Logs/ULTIMO_NUMERO.txt` | Modificado (267 → 268) |
| `Logs/268-M53-Correccion-Superposicion-947_2026-08-30_05-00-00.md` | Creado (este log) |

## Lección (obligación de documentar en §9.47)
Caso real adicional de la regla §9.47: **leer la guía y los últimos commits ANTES de agregar UI**.
La regla ya existía documentada por MiMo (§9.47, commits b9c9687/c6ecf4c/f8b4498) y no fue
consultada. Los widgets oficiales vigentes son: RelojWidget (w_reloj.gd, escena), Hotbar
(player.gd dinámico), StatusBar (escena, abajo-izq), InteractPrompt (escena).

## Estado correcto del M53 tras la corrección
- UIRoot: SOLO capas modales (DialogLayer, PauseLayer, MenusLayer, ConfirmPopup). ✅
- ThemeService: tema cozy global (aplica a root.theme; los widgets oficiales heredan el tema
  cozy si no definen theme propio — el reloj w_reloj.gd usa colores propios, no roto). ✅
- Tooltips por foco: UIManager + TooltipService (sin duplicar widgets). ✅
- HUD: exactamente como lo dejó MiMo (oficiales). ✅