# Log 421: M71 Progresión iter 3 — Integración M13 nivel_herramienta

**Fecha:** 2026-09-02
**Hora:** 02:15
**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code

## Resumen
M71 iter 3: Puente M13->M71 implementado y verificado. ToolController.herramienta_equipada -> ProgressionManager.conectar_tool_controller() -> PlayerProfile.incrementar(nivel_*). Test headless 7/0 OK.

## Cambios Realizados

### Integración M13->M71
- `progression_manager.gd`: método `conectar_tool_controller(tc)` que suscribe a `tc.herramienta_equipada`
- Al recibir herramienta_equipada: extraer id y nivel, emitir `bus.progresion.nivel_herramienta_cambio(id, nivel)`
- `player_profile.gd`: incrementa estadística `nivel_{tool_id}` si el nuevo nivel es mayor (monótono)

### Test existente verificado
- `test_nivel_herramienta.gd`: 7 checks, 0 fallos
  - ToolData.crear(PICO, HIERRO) OK
  - Conectar ToolController OK
  - nivel_herramienta_cambio emitido OK
  - tool_id = "pico" OK
  - nivel_pico = 1 OK
  - Subir a ORO: nivel_pico = 2 OK
  - Bajar a COBRE: nivel_pico no baja (monótono) OK

## Tests
- **M71 test:** 13/0 OK (test_progresion.gd)
- **M13/M71 test:** 7/0 OK (test_nivel_herramienta.gd)
- **Regresiones:** M36 59/0 · M65 9/0 · M73 44/0 · M94 38/0

## Pendientes M71
- Señal nivel_casa_cambio (M18) — sin casa_manager implementado aún
- Reputación con amistad real de M20
- Logros (M72) y títulos
- Catálogo completo 22 categorías
