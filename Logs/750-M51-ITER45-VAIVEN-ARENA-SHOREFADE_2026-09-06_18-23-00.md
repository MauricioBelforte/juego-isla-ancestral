# Log 750: M51 iter. 4-5 — vaivén de marea real (shore-fade por profundidad)

**Fecha:** 2026-09-06
**Hora:** 18:23
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Petición del usuario: "las olas me gustan ahora, ahora sí quizás estaría bueno que lleguen hasta la arena porque el efecto está bueno". Se implementó el vaivén de marea con dos enfoques: el radial (iter. 4, descartado por datos reales) y el shore-fade por profundidad de pantalla (iter. 5, resultado final).

## Proceso (2 iteraciones en una sesión)

### Iter. 4 — vaivén radial (DESCARTADO)
- Reescribí el shader con frente de marea radial (`wavefront = r 190 ± 10`) que trepaba sobre la arena y se hundía al retroceder.
- Al verificar con capturas descubrí que el vaivén quedaba sobre MAR ABIERTO: **la costa real NO está en r=262 como asumía**.
- **Medición real del terreno** (`medir_costa_m51.gd`, 24 rayos radiales con TerrainLocator): el agua voxel termina en **r≈180-204 (mediana 184)** — el modelo de la isla es más chico que el anillo nominal de 256. Corregí los radios, pero una costa radial no puede seguir una costa irregular real (islas voxel tienen borde festoneado).

### Iter. 5 — shore-fade por profundidad de pantalla (FINAL)
- Enfoque completamente distinto: el shader compara la **profundidad de pantalla** del píxel del agua contra la profundidad del fondo (arena/terreno renderizado detrás, vía `hint_depth_texture` + `INV_PROJECTION_MATRIX`). La diferencia = profundidad de agua en metros.
- **El fade y la espuma siguen la línea de costa REAL automáticamente**, con cualquier forma de isla, sin radios hardcodeados:
  - `profundidad_agua < 0.15m` → alpha 0 (el plano desaparece sobre la arena seca)
  - `profundidad_agua > 2.2m` → agua plena
  - Entre ambos: fade + tinte turquesa suave (marea somera) + **banda de espuma pulsante** (`sin(TIME*1.6 + altura_ola*2)`) pegada a la orilla — el vaivén que pidió el usuario, generado por las propias olas del vertex.
- Ajuste post-captura: el primer tinte de orilla se veía lechoso (0.45/0.82/0.88 al 50%); corregido a azul natural (0.28/0.68/0.78 al 28%) con alpha 0.45 mínimo para que la arena se vea ligeramente a través (efecto mojado).
- Las olas de mar abierto quedaron INTACTAS (gustadas por el usuario).

## Evidencia Visual (capturas/51/)
- `cap_51_..._vaiven_costa_real.png` — jugador de cerca (pelo OK) + interior de la isla.
- `cap_51_..._shorefade_f1.png` — ANTES del ajuste de tinte: orilla limpia + agua lechosa.
- `cap_51_..._shorefade_azul.png` — FINAL: agua azul natural, orilla seca, espuma pegada a la arena, mar lejano con olas. FPS 60.

## Hallazgo técnico (para 07-GUIA-GODOT §8 / 09-GUIA-BLENDER)
- **La costa real de la Isla Raíz está en r≈180-204 (mediana 184), no en 256.** El `island_radius` nominal (256) incluye la franja de océano poco profundo. Cualquier efecto de orilla (shader, spawns de playa, triggers) debe usar los radios medidos o el patrón depth-fade.
- **Patrón shore-fade** (recomendado para cualquier superficie sobre agua voxel): hint_depth_texture + INV_PROJECTION_MATRIX → profundidad de agua por píxel → fade + espuma. Siguiendo la costa real sin medirla.
- El script `medir_costa_m51.gd` queda en scripts/world/ como herramienta reutilizable de medición de costa.

## Archivos Modificados/Creados
- `game/isla-ancestral/shaders/agua_olas.gdshader` (shore-fade final; el radial de la iter. 4 fue reemplazado)
- `game/isla-ancestral/scripts/world/medir_costa_m51.gd` (NUEVO, herramienta de medición)
- `game/isla-ancestral/scripts/world/captura_vaiven_m51.gd` (temporal, ELIMINADO)
- Autoload temporal (ELIMINADO de project.godot)
- `DOCUMENTACION/51-Agua/plan-actual/05-Checklist.md` + `CHECKLIST-GLOBAL.md` (fila 51)
