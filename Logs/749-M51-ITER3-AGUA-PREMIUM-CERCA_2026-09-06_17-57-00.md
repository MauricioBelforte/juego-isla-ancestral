# Log 749: M51 iter. 3 — agua premium de cerca + fix pelo confirmado por usuario

**Fecha:** 2026-09-06
**Hora:** 17:57
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Ajuste del agua pedido por el usuario: las olas se veían bien de lejos pero desaparecían al acercarse (el plano a y=3.7 quedaba OCULTO bajo el top de los bloques de agua voxel opacos, 4.0, cuando el suelo real cargaba). Solución: plano de vuelta a y=4.05 (encima del agua voxel) con el hundimiento de costa desplazado a la franja de arena (r 262-292), y efecto premium cerca de la orilla: agua más clara/turquesa + línea de marea espumosa animada. El usuario confirmó además que el pelo corregido (Log 736) quedó bien.

## Cambios Realizados
- `agua_animada.gd`: Y_SUPERFICIE 3.7 → **4.05** (el plano vuelve a estar sobre el top del bloque de agua voxel → olas visibles de cerca aunque el terreno real esté cargado).
- `main_island.tscn`: nodo AguaAnimada a y 4.05.
- `agua_olas.gdshader`:
  - Hundimiento de costa movido de r 255-285 a **r 262-292** (solo la franja de arena; el agua clara r 241-264 queda con olas plenas).
  - **Efecto premium orilla**: albedo mezcla hacia celeste claro (0.45/0.82/0.88) según `costa_mask` (marea somera), alpha reducido cerca de la orilla (más transparente sobre el fondo).
  - **Línea de marea**: anillo de espuma pulsante (sin TIME 2.2) donde `costa_mask` ≥ 0.75 — el borde del agua respira contra la arena.
  - Espuma de crestas reconvertida: 100% en mar abierto → 50% en la transición costera (para no competir con la línea de marea).
- Diagnóstico del problema (para el registro): un plano bajo el top de bloques voxel opacos es invisible cerca — los efectos de superficie sobre agua voxel deben flotar POR ENCIMA del top del bloque (y_water_level + 0.05).

## Evidencia Visual (capturas/51/)
- `cap_51_..._olas_cerca_premium.png` — jugador en la costa: línea de marea espumosa pegada a la arena, agua clara celeste, mar profundo azul con olas. FPS 60.
- Comparativa: `cap_51_..._olas_hasta_agua_clara.png` (ANTES: agua clara plana sin olas) vs premium (DESPUÉS).
- Boot confirma `y=4.05` y 0 errores de shader.

## Confirmaciones del usuario
- ✅ "el pelo está bien" (fix Log 736 validado).
- Olas en profundo OK; pedido: extenderlas cerca — implementado en esta iteración.

## Tests
- No se modificó lógica con tests (solo shader + constantes de posición). Boot sin errores; FPS 60 en las capturas.

## Archivos Modificados/Creados
- `game/isla-ancestral/shaders/agua_olas.gdshader` (y_base 4.05, transición 262-292, tinte marea, línea de espuma pulsante)
- `game/isla-ancestral/scripts/world/agua_animada.gd` (Y_SUPERFICIE 4.05)
- `game/isla-ancestral/scenes/main_island.tscn` (AguaAnimada y 4.05)
- `DOCUMENTACION/51-Agua/plan-actual/05-Checklist.md` + `CHECKLIST-GLOBAL.md` (fila 51)
