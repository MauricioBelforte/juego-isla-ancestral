# Log 415: M66 Anti-Softlock iter. 3 — MisionInvariant funcional — glm-5.3-flash

**Fecha:** 2026-09-01
**Hora:** 23:20
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen

Iteración 3 del M66 Anti-Softlock (V0/V1, sobre el núcleo de ox-alpha + mi iter. 2): MisionInvariant ya no es un stub — detecta objetivos de misión sin ruta alternativa, activa fallbacks con aviso al diario y evita recompensas duplicadas. Módulo liberado 🟡 23/117.

## Cambios Realizados

### mision_invariant.gd (funcional — era stub)
- _check(): recorre los objetivos activos registrados; un objetivo SIN fallback declarado = condición imposible → _check falla → el detector central (SoftlockGuard) emite estado_invalido_detectado (§2.4).
- _razon_fallo() específica: objetivo + misión.
- activar_fallback(objetivo, mision): activa la ruta alternativa + registra aviso en el diario M55 (categoría descubrimientos) — funciona desde RefCounted vía Engine.get_main_loop() (pitfall documentado).
- registrar_recompensa_entregada()/recompensa_ya_entregada(): registro anti-duplicado de recompensas equivalentes (§4.2 coherencia M37).

### data/diario/diario_catalog.json (+1 entrada)
- descubrimiento_fallback_* (aviso de camino alternativo al jugador).

### test_fallbacks_m66.gd (nuevo)
- Fallback registrado, _check detecta imposible sin fallback, con fallback pasa, activar_fallback → aviso en M55, recompensa anti-duplicada → **0 fallos**.

### Registro
- Checklist: +6 ítems [x] (MisionInvariant 46-51). Progreso 17→23/117.
- Fila 66 global actualizada; guía 08 y ESTADO-PARALELO con fila nueva.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/core/invariants/mision_invariant.gd` (funcional)
- `game/isla-ancestral/scripts/core/test_fallbacks_m66.gd` (nuevo)
- `game/isla-ancestral/data/diario/diario_catalog.json` (+1 entrada)
- `DOCUMENTACION/66-Anti-Softlock/plan-actual/04-Codigo.md` (Notas del Agente iter. 3)
- `DOCUMENTACION/66-Anti-Softlock/plan-actual/05-Checklist.md` (23/117 + reserva liberada)
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`

## Verificación

- test_fallbacks_m66.gd: 0 fallos (Godot 4.5 headless).
