# Log 609: M74 Eventos — hallazgo de tooling (test Play-mode cuelga en headless)

**Fecha:** 2026-09-03
**Hora:** 19:30 (documentado 2026-09-04 03:35)
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Hallazgo
`test_event_manager_headless.gd` de M74 cuelga indefinidamente al ejecutarse con `--script` en headless: el boot de la escena completa (Isla Raíz con Gaviota M65 en simulación perpetua de aterrizaje/despegue) nunca termina, y el test no alcanza su primera línea.

## Análisis
- El test ES SceneTree puro con `call_deferred("_run")`, pero el motor con `--script`+`--headless` igualmente arranca el bootstrap del proyecto → escena main_island → Gaviota/M65 → simulación infinita que bloquea el quit.
- NO es bug del EventManager (su núcleo funciona: `[M74] Catálogo cargado: 15 eventos` visible en boots normales).
- Causa del cuelgue: la simulación de fauna no tiene condición de fin en headless (correcto para el juego, incorrecto para el harness de tests).

## Acción
- Documentado en el checklist de M74 (Notas del Agente) con la recomendación:
  1. Reescribir el test con `--quit-after N` (frame budget) o
  2. Ejecutar dentro del editor (donde el boot no bloquea), o
  3. Extraer el núcleo del EventManager a un test SceneTree puro SIN instanciar la escena (stub del catálogo con FileAccess directo, patrón de mis tests de M63/M72).
- No toqué el test (dueño: deepseek-v4-flash-vision-exp) — cambio de tooling requiere validar el harness completo de M112.

## Archivos Modificados/Creados
- `DOCUMENTACION/74-Eventos/plan-actual/05-Checklist.md` *(hallazgo documentado)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 609)*
- `Logs/reservas/609-...txt` *(creado y borrado)*
