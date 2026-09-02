# Log 542: M37 Museos — iter. 3 (fauna M36, toasts, API panel, M71/M55)

**Fecha:** 2026-09-02
**Hora:** 20:40
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. 3 de M37 Museos y Colecciones: exposición fauna con las 7 especies reales de M36, toast al completar exposición, validación de catálogo RF14, API de panel para M53, estadística para M71 y puente al diario M55. 14 ítems marcados [x] → 28/148.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `data/museum/exhibiciones.json` | +Exposición "fauna" (7 especies del catálogo real M36: gaviota, conejo, nutria, lechuza, salamandra, cangrejo, halcón) |
| `scripts/museum/collection_registry.gd` | +_emitir_toast_completada vía **bus.ui.notify** + validar_catalogo() RF14 (ejecutado en _ready) + get_resumen_para_ui() + exposiciones_completas_count() |
| `scripts/museum/donation_service.gd` | +estadística "donaciones_museo" en PlayerProfile (M71) + puente EventBus.diary.entrada_nueva(id, "museo") (M55) |
| `scripts/logros/achievement_service.gd` | FIX latente: _emitir_toast usaba bus.notify (raíz) en vez de bus.ui.notify — los toasts nunca salían |
| `scripts/museum/test_museo.gd` | 6 → 10 secciones (~55 checks) |
| `DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/05-Checklist.md` | Reserva + 14 ítems [x] + Notas del Agente |
| `CHECKLIST-GLOBAL.md` | M37: 🟢 → 🔵 → 🟡 Liberado (28/148) |

## Tests (headless Godot 4.7.2)
- `test_museo.gd` (M37): **0 fallos** (4 exposiciones, validación RF14 0 problemas, donación fauna aceptada + estadística M71 +1, diario M55, toast "Acuario de Aurora" al completar peces, panel resumen, recompensa idempotente, persistencia round-trip)
- Regresiones: M72 0, M67 0, M75 0 fallos
- Boot: `[M37] Exposiciones cargadas: 4` + `[M37][RF14] Catálogo OK: 4 exposiciones, 0 problemas`

## Hallazgos
1. **Señal notify en dominio interno:** `signal notify` vive en `UIEvents` (bus.ui), no en la raíz del EventBus — `bus.has_signal("notify")` da false. M72 tenía el mismo bug latente desde el Log 527 (toasts nunca emitidos); corregido ambos. El autoload es "EventBus_" (class_name EventBus_ anti-colisión) — acceso correcto: `get_node_or_null("/root/EventBus")` + `bus.ui.notify`.
2. **Donables por posesión (§4.1.2):** `get_donatable_items()` filtra por estar en inventario — el test debe poseer la pieza antes de consultarla (comportamiento correcto, lección capturada).
3. **Parse error ajeno:** `legal/credits_manager.gd` (M131, otro agente en curso) tiene `var loc` sin inferencia — no tocado (no es bloqueante de boot, solo ese autoload).

## Archivos Modificados/Creados
- `game/isla-ancestral/data/museum/exhibiciones.json` *(modificado)*
- `game/isla-ancestral/scripts/museum/collection_registry.gd` *(modificado)*
- `game/isla-ancestral/scripts/museum/donation_service.gd` *(modificado)*
- `game/isla-ancestral/scripts/logros/achievement_service.gd` *(fix latente)*
- `game/isla-ancestral/scripts/museum/test_museo.gd` *(modificado)*
- `DOCUMENTACION/37-Museos-Y-Colecciones/plan-actual/05-Checklist.md` *(modificado)*
- `CHECKLIST-GLOBAL.md` *(modificado)*
- `Logs/ULTIMO_NUMERO.txt` *(modificado)*
- `Logs/reservas/542-glm-5.3-flash-M37-Museos.txt` *(creado y borrado)*

## Notas técnicas
- La estadística vive en PlayerProfile (M71 dueño de estadísticas); M37 solo incrementa — desacople.
- validar_catalogo() es headless-friendly para gates CI (M117/M118).
- El pitfall del dominio interno de EventBus debe agregarse a 07-GUIA §8 en la próxima pasada de mantenimiento de guías.
