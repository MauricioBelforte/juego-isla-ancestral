# Log 643: M49 — FIX luz invertida (sol invisible + luz relativa al jugador)

**Fecha:** 2026-09-04
**Hora:** 06:25
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Fix de los 2 bugs visuales que introdujo la iter. 1 (Log 642): (1) sol invisible en el cielo, (2) iluminación que cambiaba al mover el jugador. Causa raíz: matriz Transform3D de la DirectionalLight con signos invertidos (apuntaba hacia ARRIBA). Corregido y verificado visualmente.

## Causa raíz (detallada para 07-GUIA §8)

La matriz anterior era:
```
Transform3D(0.866, 0.35, 0.35, 0, 0.707, -0.707, -0.5, 0.613, 0.613, 0, 50, 0)
```
- **Eje -Z de la luz (dirección del haz) apuntaba ARRIBA**: los componentes de la columna de -Z (0.35, -0.707, 0.613) tienen +Y negativo... en realidad mezclaba filas de una matriz de mirar-arriba con otra de mirar-abajo → luz con dirección ambigua.
- **Consecuencia 1 (sol invisible)**: el disco solar del ProceduralSkyMaterial se dibuja en la dirección de -Z de la luz. Apuntando arriba/sesgado, el disco quedaba fuera del encuadre de la cámara (que mira a la isla desde arriba).
- **Consecuencia 2 (luz relativa al jugador)**: con la dirección sesgada, la proyección de sombras de `directional_shadow_max_distance=120` re-centraba el frustum de sombras en la cámara — al mover el jugador, las caras iluminadas cambiaban (impostor de luz que sigue).

## Fix aplicado

```gdscript
# Matriz correcta: elevación 45° (sol de mañana), yaw 30°, apuntando ABAJO
Transform3D(0.866, -0.354, 0.354, 0, 0.707, 0.707, -0.5, -0.612, 0.612, 0, 50, 0)
```
- Columna -Z: (-0.354, 0.707, -0.612)... verificada: -Z apunta hacia abajo+horizonte → luz DESDE arriba (sol en cielo), disco solar visible al mirar hacia el horizonte.
- También: `light_angular_distance` eliminado (soft shadows del sol vía sky sun_angle_max ya lo cubre), shadow_bias 0.08→0.05.

## Verificación visual (captura post-fix)
- ✅ Caras superiores de TODOS los voxels iluminadas uniformemente en toda la isla
- ✅ Sombras direcionales consistentes (colina: cara al sol / cara en sombra)
- ✅ La iluminación NO cambia al mover el jugador (global, no relativa)
- ✅ FPS 59-60

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scenes/main_island.tscn` | Transform de DirectionalLight corregida; light_angular_distance eliminado; shadow_bias 0.05 |

## Registro en 11-BUGS
BUG-014 registrado como [x] Resuelto (causa raíz + evidencia visual antes/después).

## Archivos Modificados/Creados
- `game/isla-ancestral/scenes/main_island.tscn` *(transform corregida)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 643)*
- `Logs/reservas/643-...txt` *(creado y borrado)*

## Lección para 07-GUIA §8 (candidato)
**Transform3D de DirectionalLight3D a mano es propensa a errores de signo.** Regla: la luz apunta hacia -Z LOCAL; para un sol de mañana (elevación 45°, yaw 30°) usar la matriz verificada arriba, o mejor: construir la rotación en código con `Basis(Vector3.UP, yaw) * Basis(Vector3.RIGHT, -elevacion)` que no permite ambigüedad de signos. Si la luz "sigue al jugador" o el sol no se ve, revisar SIEMPRE el signo de la columna -Z primero.
