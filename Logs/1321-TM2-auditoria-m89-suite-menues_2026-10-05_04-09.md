# Log 1321: T-M2 M89 Diseño de Menús — auditoría contra disco + suite headless test_m89_menus

**Fecha:** 2026-10-05
**Hora:** 04:09
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Frente **T-M2** (encargo canal 18): módulo **89-Diseno-De-Menus** auditado ítem por ítem contra el estado real del repo Godot (el plan-actual es diseño heredado de Unity), con suite headless nueva `test_m89_menus.gd` (48 checks, verde + sonda rojo demostrada) y regresión limpia. Fila CG 89 (reconstruida 13→11 celdas en la reserva) cerrada a 🟡 30/125. Documentación de testings 06/07 creada por primera vez.

## Cambios Realizados

1. **Reserva** (2026-10-05 02:50, anterior a este log): fila CG 89 reconstruida de 13→11 celdas (mismo defecto en filas 88/90, ajenas — NO tocadas) y reclamada 🔵; registros en los 6 lugares (CG, ESTADO-PARALELO, 05-Checklist bloque Reserva actual, guía 08 fila M89, backlog, este log pendiente).
2. **Suite nueva** `game/isla-ancestral/scripts/ui/test_m89_menus.gd` (grupos A-H):
   - A MenusLayer (5 señales, 5 botones, MODAL_FULL, oculto al nacer) · B PauseLayer (4 opciones, open/close) · C MenuNavigator (focus_first/last, wrap_focus mueve el foco) · D CreditsLayer (MAX 300 s, 3 velocidades, ≥6 controles) · E UIRoot (montaje de capas + wiring `jugar_pedido`/`ajustes_pedido` verificado con GameFlowManager montado por Bootstrap) · F pausa del mundo (árbol pausado/reanudado) · G SaveManager (API de slots + `SaveWriter.save_exists`) · H gaps como `GAP-AUDITORIA` (INFO).
   - **Verde:** 48 checks / 0 fallos / `exit=0` (03:53-03:55).
   - **Sonda rojo:** `ESPERA_BOTONES_MENUS` 5→6 → `FALLO: A5 5 botones (esperados 6)` / 1 fallo / `exit=1`; constante restaurada y verde reejecutado.
   - **Regresión:** `test_ui_framework.gd` 0 fallos / `exit=0`; `test_diario_ui.gd` 89 checks / 0 fallos / `exit=0`.
   - ⚠️ Incidente de codificación: un `-replace` con `Set-Content -Encoding utf8` (PowerShell 5.1) corrompió el .gd con mojibake + BOM; reparado de inmediato con Python (cp1252→UTF-8, BOM eliminado) — §28 reforzado: **no usar cmdlets de PS para reescribir archivos UTF-8 del repo**.
3. **Auditoría contra disco** (docs Unity vs repo Godot): `ShellManager.cs`→`ui_manager.gd`+`ui_root.gd`; enum `IdPantalla`/21 pantallas no existe; `NavigatorManager`→`menu_navigator.gd` estático sin grafo; portada M147 y versión visibles no implementadas; menú 5/6 botones (falta "Cargar"); nadie llama `menus_layer.open()`; `salir_pedido`→`quit()` sin confirmación; pausa abrible solo vía RF18; ajustes solo Audio (1/4); perfiles 1-3 inexistentes (solo slots M59); inventario con scroll (no grid paginado); colección/habilidades/relación con manager sin UI.
4. **Flips en `05-Checklist.md`** (8 `[ ]`→`[x]` con evidencia citada + 2 `[x]`→`[?]` por INFLADOS): acceso a ajustes menú+pausa, scroll/volver/estética de créditos, Pausar() del mundo, reanudación sin saltos, cierre con estado de última pantalla (T-053-066), pestañas de inventario; **[?]**: "suite Navigator recorre 21 pantallas" (no existe) y "suite perfiles/slots 30 ciclos" (perfiles no existen; slots sí). **Totales nuevos: 125 = 30 [x] / 93 [ ] / 2 [?].**
5. **Documentación:** `05-Checklist.md` + sección `## Auditoría contra disco (T-M2 — 2026-10-05)`; `04-Codigo.md` + `§6 Estado real en Godot` (mapeo tabla Unity→Godot); `03-Diseno.md` + `§8 Nota de mapeo P1-P21`; **creados** `06-Plan-Testings.md` y `07-Resultados-Testings.md` (evidencia de runs).
6. **Cierre de registros:** CG fila 89 → **🟡 Con dudas · 30/125 · Agente `—` · 2026-10-05 04:06** (11 celdas, CR/LF/CRLF íntegros, solo esa fila difiere de HEAD); ESTADO-PARALELO entrada → cerrada; guía 08 fila M89 → 🟡 Liberado (working tree, NO commiteable); backlog T-M2 → `[x]`.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/ui/test_m89_menus.gd` — **CREADO** (suite 48 checks).
- `DOCUMENTACION/89-Diseno-De-Menus/plan-actual/05-Checklist.md` — flips, sección auditoría, totales 30/93/2.
- `DOCUMENTACION/89-Diseno-De-Menus/plan-actual/04-Codigo.md` — §6 estado real Godot.
- `DOCUMENTACION/89-Diseno-De-Menus/plan-actual/03-Diseno.md` — §8 mapeo P1-P21.
- `DOCUMENTACION/89-Diseno-De-Menus/plan-actual/06-Plan-Testings.md` — **CREADO**.
- `DOCUMENTACION/89-Diseno-De-Menus/plan-actual/07-Resultados-Testings.md` — **CREADO**.
- `CHECKLIST-GLOBAL.md` — fila 89 cerrada (solo esa línea).
- `Mensajes entre modelos/ESTADO-PARALELO.md` — entrada T-M2 cerrada.
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` — fila M89 (working tree, NO commiteable).
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md` — T-M2 `[x]`.
- `Logs/NUMEROS_DISPONIBLES.txt` — 1321 consumido (cabeza ahora 1322).

## Notas

- La cabeza del pool era **1321**, no 1296 (1296-1320 ya estaban consumidos por otros agentes): la referencia a 1296 en el backlog/canal era de la sesión de apertura y quedó corregida.
- `ui_manager.gd` (M53, zona s2) **no fue tocado**.
- Zonas prohibidas respetadas: `full_map_layer.gd` (DeepSeek, solo lectura), `interaction_manager`, `service_registry.gd`, `quality.yml`, M91.
