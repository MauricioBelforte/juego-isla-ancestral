# Log 1756: M58-Accesibilidad barrido con 6 flips y hallazgo de regresión en suite

**Fecha:** 2026-10-12
**Hora:** 20:15
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen
Barrido del checklist de M58-Accesibilidad (encargo del director, msg 318). 6 ítems `[ ]` -> `[x]` con evidencia en disco y documentación; conteo final 154/27/2 = 183 sin drift. Se detectó una **regresión estructural** en `test_perfil_m58_iter4.gd` (piso de checks inalcanzable) que contradijo el Log 1701 de Step 5.

## Cambios Realizados
### Flips aplicados (6)
1. **RF4** (L29): niveles de texto Normal/Grande/Muy grande delegados a M88 — definido en `01-Requerimientos.md` RF4; M88 tiene `FontCatalog` con 4 .ttf.
2. **RF12** (L50): alternativa visual para pistas auditivas existentes — `INDICADORES_SONIDO` (`accesibilidad_manager.gd:353`) define forma visual + clave de texto para 7 pistas: insectos/agua/canto_npc (anillo), cofre (rizos), alerta_vida/alerta_tormenta/alerta_hambre (cartel).
3. **Presets de control** (L68): `control_preset` se guarda en el perfil (`_perfil["control_preset"]`, manager L409) y persiste en `user://accesibilidad/profile.json`; `03-Diseno.md:40/77` documenta carga al arranque + 5 presets.
4. **RF23 diálogos a ritmo del jugador** (L86): `dialog_layer.gd:153/158/166` avanza por input (interactuar/ui_accept/teclado); `AutoAdvanceManager` existe pero **no está cableado en ninguna escena** (0 referencias externas) -> no hay cuenta regresiva forzada.
5. **Letreros sustituibles** (L104): `02-Analisis.md:41` «letreros y placas deben ser opcionalmente sustituibles por diálogo redundante o marcas visuales».
6. **Flujo de arranque** (L137): `03-Diseno.md:98-110` diagrama 2.1 Arranque: Godot boot -> SettingsManager._ready() -> cargar/validar profile.json -> AccessibilityApplier.apply() -> escena Título.

### No flippeados (honestidad)
- **RF26 guía de textos** (L99): no hay guía redactada; solo RF26 en requerimientos y mención en 02-Analisis:39.
- **Reabrir último diálogo** (L87): sin implementar; solo existe el signal `_on_dialogue_ended(_id, _ultimo)` en dialog_layer.gd:135.
- **F10 atajo global** (L215): 0 `KEY_F10` en todo el código; solo figura en 02-Analisis.md D4 como diseño.
- **Carteles con tiempo de vida/fade** (L181): INDICADORES_SONIDO define forma "cartel" pero sin tiempo de vida ni fade-out.

### Hallazgo material — regresión en suite
`test_perfil_m58_iter4.gd` (commit 2172f23 de Step 5): la suite tiene **33 llamadas `_ok()`** pero `const CHECKS_MINIMOS: int = 34` -> en runtime impime `PISO NO CUMPLIDO: 33 < 34` y termina con `quit(1)`. Los 33 checks que se ejecutan son todos correctos (0 fallos lógicos). Es un fallo estructural: la suite **nunca puede pasar** tal como está. El Log 1701 de Step 5 declaró "39 checks, 0 fallos" — inexacto (mi Log 1702 propagó esa cifra). Fix mínimo: `CHECKS_MINIMOS = 33` (o agregar 1 check de los 33 existentes).

### Runtime (4 suites, Godot 4.7.2 headless)
- `test_accesibilidad_manager.gd`: 39 checks, 0 fallos
- `test_accesibilidad_headless.gd`: 13 checks, 0 fallos
- `test_perfil_m58_iter4.gd`: 33 checks, 0 fallos lógicos, **EXIT 1 por piso inalcanzable**
- `test_sonido_visual_m58.gd`: 25 checks, 0 fallos
- Total útil: 110 checks, 0 fallos de lógica

## Archivos Modificados/Creados
- `DOCUMENTACION/58-Accesibilidad/plan-actual/05-Checklist.md` (6 flips + Totales 148/33/2 -> 154/27/2 + nota de agente)

## Pendiente para el director
- Decidir el fix de `test_perfil_m58_iter4.gd` (bajar `CHECKS_MINIMOS` a 33) — no lo toqué porque es código de Step 5 y el barrido es de checklist.
- Los 27 `[ ]` restantes son deuda externa (M53/M57/M88/M154/M61/M17/M34/M59) o de implementación pendiente (RF26 guía, reabrir diálogo, F10, fade de carteles).
