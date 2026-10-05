# 07-Resultados-Testings.md — Módulo 89: Diseño de Menús

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-05

Ejecución real del plan `06-Plan-Testings.md` (frente T-M2). Todos los runs son headless con Godot 4.7.2 (`C:\Temp\godot\godot472.exe`).

## 1. Run 1 — Verde inicial (`test_m89_menus.gd`)

- **Comando:** `--headless --path game/isla-ancestral --script res://scripts/ui/test_m89_menus.gd`
- **Resultado:** `=== TEST M89 MENUS: 48 checks, 0 fallo(s) ===`
- **Exit code:** `0` ✅
- Warnings preexistentes de arranque (M39 catálogo de tiendas, ObjectDB leak al salir) — NO introducidos por este test.

## 2. Run 2 — Sonda rojo (honestidad)

- **Cambio temporal:** `const ESPERA_BOTONES_MENUS := 5` → `6`.
- **Resultado:** `FALLO: A5 5 botones (esperados 6)` · `=== TEST M89 MENUS: 48 checks, 1 fallo(s) ===`
- **Exit code:** `1` ✅ (la suite sí detecta el gap de RF1).
- **Restauración:** constante de vuelta a `5` vía Python (UTF-8 sin BOM; un intento intermedio con `Set-Content` de PowerShell 5.1 corrompió el archivo con mojibake+BOM y fue reparado de inmediato — lección reforzada de §28: no usar cmdlets de PS para reescribir archivos UTF-8 del repo).

## 3. Run 3 — Verde final

- **Resultado:** `=== TEST M89 MENUS: 48 checks, 0 fallo(s) ===`
- **Exit code:** `0` ✅
- Verificación de bytes: `BOM=False`, mojibake=0.

## 4. Regresión

| Suite | Resultado | Exit |
|-------|-----------|------|
| `test_ui_framework.gd` (M53, zona s2) | `0 fallo(s)` | `0` ✅ |
| `test_diario_ui.gd` (M55) | `89 checks, 0 fallo(s)` | `0` ✅ |

## 5. Hallazgos (GAP-AUDITORIA del run, comprobados a mano)

1. **RF1 incompleto:** MenusLayer tiene **5/6 botones** — falta "Cargar" (Jugar/Continuar/Ajustes/Créditos/Salir). Detección viva en el test A5.
2. **Sin open() inicial:** ningún archivo llama `menus_layer.open()` → el título del juego no se muestra al arrancar (solo los logs de Bootstrap→MUNDO).
3. **RF11 sin confirmación:** `ui_root.gd` `salir_pedido` → `get_tree().quit()` directo.
4. **Pausa no abrible por input:** la acción `pausa` en `ui_manager._unhandled_input` solo cierra capas; `PauseLayer.open()` solo lo llama RF18 (M58, `_on_pausa_instantanea`).
5. **Ajustes 1/4:** solo `SettingsAudioLayer`; no hay pantallas de Controles/Accesibilidad/Gráfica (managers sin UI).
6. **Perfiles 1-3:** no existen; M59 solo tiene slots (`slot_metadata/load_slot/slot_recoverable`, `SaveWriter.save_exists` verificados en G1-G6).
7. **Inventario con scroll**, no grid paginado (§12).
8. **Docs heredadas de Unity:** `ShellManager.cs`, enum `IdPantalla`, NavigatorManager con grafo y suites Unity no existen como tales en Godot (mapeo completo en `04-Codigo.md` §6).

## 6. Flips resultantes en `05-Checklist.md`

- `[ ]→[x]` (8): §6 acceso ajustes menú+pausa · §7 scroll créditos · §7 volver desde créditos · §7 estética M06 · §11 Pausar() mundo · §11 reanudación sin saltos · §11 cierre con estado de última pantalla (T-053-066) · §12 pestañas inventario.
- `[x]→[?]` (2): §23 suite Navigator 21 pantallas (INFLADO — no existe) · §23 suite perfiles/slots 30 ciclos (perfiles inexistentes; slots sí).
- **Totales nuevos:** 125 ítems · **30 [x] · 93 [ ] · 2 [?]**.

## 7. Siguiente trabajo dejado documentado

- Los 93 `[ ]` restantes (portada, "Cargar", confirmación de salida, categorías de ajustes, perfiles, pantallas de contenido sin UI, métrica <300 ms, playtest humano) quedan pendientes para la fase de implementación; T-M2 solo cubre auditoría + suite.
- Zona s2 (`ui_manager.gd`) no fue modificada; si M53 necesita tocarla para abrir pausa por input, avisar al canal 25.
