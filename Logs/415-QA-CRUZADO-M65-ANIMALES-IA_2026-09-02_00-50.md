# Log 415: QA cruzado M65 Animales-IA (iter 1)

**Fecha:** 2026-09-02
**Hora:** 00:50
**Modelo:** Hy3
**Plataforma:** Kilo Code

## Resumen
QA cruzado (§21.8) de M65 Animales-IA, liberado por minimax-m3-free (Log 384, 23 OK / 0 fallos) con aportes de agnes-2.5-flash (pack_logic/school_logic, Log 387). Verifiqué la coherencia con `test_m65.gd` y el contrato M36↔M65. **Hallé y corregí un bug de integración real y latente** que impediría el movimiento y el registro de avistamientos en gameplay real.

## Verificación
- `m65_animal_ai.gd`: `registrar`/`desregistrar`/`tick`/`_on_solicitar_movimiento(destino, velocidad, instancia_id)` coherentes con `FaunaBehavior`.
- `test_m65.gd` (175 líneas, 13 tests) es consistente con el código: presupuesto, registro, tick de movimiento, anti-stuck, llegada, señal, persistencia, desregistro.
- Autoload `animal_ai` registrado en `project.godot`.

## Bug encontrado y corregido (integración M36↔M65)
**Síntoma:** `FaunaBehavior.tick()` (FSM que decide HUIDA/ALERTA/CURIOSA y emite `solicitar_movimiento`) **nunca era invocado**. `FaunaManager._process` solo llama a `animal_ai.tick` (que únicamente mueve según la señal ya recibida). En gameplay real (cuando M09 instancie los comportamientos) los animales no se moverían ni cambiarían de estado.
**Segundo fallo relacionado:** la señal `solicitar_avistamiento` del behavior no estaba cableada a `fauna_registry` en el camino vivo (solo funcionaba el helper de test `registrar_avistamiento_test`), así que los avistamientos no se registrarían en juego.
**Fix (en `fauna_behavior.gd`, seguro y autocontenido):**
1. `set_process(true)` en `_ready` + `_process(delta)` que llama `tick(delta, _get_player_position())` → el behavior dirige su propia FSM cada frame y emite `solicitar_movimiento`.
2. `_get_player_position()` resuelve el jugador vía grupo `"player"` (fallback origen) — sin acoplar a un nodo concreto.
3. Conexión en `_ready`: `solicitar_avistamiento.connect(fauna_registry.registrar_avistamiento)`.
**Por qué no rompe el test:** `test_m65.gd` corre sincrónicamente dentro de `_run` y llama `quit` sin procesar frames, por lo que el nuevo `_process` del behavior no se ejecuta durante el test; el camino manual de señal sigue siendo el único que actúa en tests.

## Hallazgos / Deuda
- `pack_logic.gd` y `school_logic.gd` (M65) viven en `scripts/fauna/` en vez de `scripts/animales_ia/`. No se rompe nada (no se preloadan por ruta en el código revisado), pero es una inconsistencia de organización; se recomienda moverlos. No se movió para no arriesgar referencias.
- `[?]` restantes con dueño: movimiento real con NavigationServer3D evitando voxels (M08), spawner con burbuja 72m (M09), visuales M45, sonidos M43.
- DoD de documentación incumplido: M65 no tiene `DOCUMENTACION/65-Animales-IA/`. Se crea `plan-actual/` con los 5 archivos y `05-Checklist.md` (≥100 ítems).

## Veredicto
M65 cumple DoD para su alcance iter 1 tras el fix de integración. Mantiene `🟡` (resto con dueño externo). QA cruzado aprobado.

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/fauna/fauna_behavior.gd` — auto-impulso FSM + cableado avistamiento (fix integración M36↔M65).
- `DOCUMENTACION/65-Animales-IA/plan-actual/01-Requerimientos.md` (nuevo)
- `DOCUMENTACION/65-Animales-IA/plan-actual/02-Analisis.md` (nuevo)
- `DOCUMENTACION/65-Animales-IA/plan-actual/03-Diseno.md` (nuevo)
- `DOCUMENTACION/65-Animales-IA/plan-actual/04-Codigo.md` (nuevo)
- `DOCUMENTACION/65-Animales-IA/plan-actual/05-Checklist.md` (nuevo, ≥100 ítems)
- `Logs/reservas/415-hy3-M65.txt` (reserva)
- `Logs/ULTIMO_NUMERO.txt` → 415
- `Mensajes entre modelos/ESTADO-PARALELO.md` → fila M65 actualizada

**Modelo:** Hy3
**Plataforma:** Kilo Code
