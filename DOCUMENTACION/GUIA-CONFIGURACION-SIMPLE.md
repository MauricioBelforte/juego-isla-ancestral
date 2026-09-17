# Guía Simple de Configuración (ajustes a ojo)

> **Modelo:** glm-5.3-flash
> **Plataforma:** Kilo Code
> **Fecha:** 2026-09-11
>
> Para el USUARIO: cada entrada dice QUÉ controla, DÓNDE está (archivo:línea),
> el valor actual y cómo ajustarlo. Editar el número, guardar y correr el
> juego. Si algo se rompe, volver al valor anterior.
> ⚠️ Regla: cambiá UNA cosa a la vez y probá — así sabés qué hizo el cambio.

---

## 1. Distancia de visión (cuánto terreno real carga)

| Qué | Archivo:línea | Valor actual | Cómo ajustar |
|---|---|---|---|
| Distancia de carga del mundo voxel (chunks reales) | `game/isla-ancestral/scripts/main_island.gd:158` | `1024.0` | Subilo a `1500.0`/`2000.0` para ver más terreno real. Cuesta RAM. |
| Distancia de cambio de LOD del terreno | `game/isla-ancestral/scripts/main_island.gd:169` | `160.0` | Más alto = el detalle lejano se mantiene más tiempo. |

## 2. Niebla (lo que tapa a lo lejos)

| Qué | Archivo:línea | Valor actual | Cómo ajustar |
|---|---|---|---|
| Densidad de niebla | `game/isla-ancestral/scripts/main_island.gd:215` | `0.00018` | Bajala a `0.0001` para ver más lejos; `0.0` = sin niebla. |
| Color de niebla | `main_island.gd:214` | gris azulado | Cambiá el Color si querés otro tono. |
| Niebla sobre el cielo | `main_island.gd:216` | `0.25` | 0.0 = cielo limpio. |

## 3. Anillo de arena (disco blanco) — `scripts/world/terreno_horizonte.gd`

| Qué | Línea | Valor actual | Cómo ajustar |
|---|---|---|---|
| Dónde NACE la arena | `terreno_horizonte.gd:46` | `ANILLO_R_INTERNO := 1800.0` | Más chico = la arena empieza más adentro (queda bajo la isla). |
| Dónde TERMINA la arena | `terreno_horizonte.gd:47` | `ANILLO_R_EXTERNO := 3000.0` | Debe ser MAYOR que la costa más lejana — si queda adentro de una costa, el anillo se ve con forma de **C** (enterrado bajo la isla). |
| **Abertura donde vos estás** | `terreno_horizonte.gd:48` | `ANILLO_OCULTAR_UMBRAL := 150.0` | Los sectores a menos de esa distancia se ocultan para NO pisar tu terreno. Chico (150) = anillo casi completo con abertura mínima a tus pies. No pongas 1: el anillo pisaría tus bloques bajos. |
| Color de la arena | `terreno_horizonte.gd:60` | `Color(0.85, 0.82, 0.65)` | A ojo (0-1 por canal RGB). |
| Altura de la arena y del disco | `terreno_horizonte.gd:39` | `DISCO_BASE_Y := 4.3` | El agua está en y=4.05 — no bajar de eso. |

> **La forma de C (Log 843):** el anillo SIEMPRE es un círculo completo. Si
> lo ves como C es porque el borde externo (`ANILLO_R_EXTERNO`) quedó más
> adentro que alguna costa → ahí el anillo queda enterrado bajo la isla.
> Solución: subir `ANILLO_R_EXTERNO` hasta superar la costa más lejana.

## 4. Disco verde (base de la isla)

| Qué | Línea | Valor actual | Cómo ajustar |
|---|---|---|---|
| Radio del disco verde | `terreno_horizonte.gd:42` | `DISCO_R := 1800.0` | Cambialo junto con ANILLO_R_INTERNO (el anillo nace donde muere el disco). |
| Color del disco | `terreno_horizonte.gd:40` | `Color(0.60, 0.74, 0.38)` | A ojo. |

## 5. Montañas impostoras — GRADIENTE por distancia (Log 820)

El impostor estira las montañas MÁS en el centro y MENOS hacia la arena.
4 números en `scripts/world/terreno_horizonte.gd:32-35`:

| Qué | Línea | Valor actual | Cómo ajustar |
|---|---|---|---|
| Exageración en el CENTRO | `terreno_horizonte.gd:32` | `MONT_EXAG_CERCA := 4.0` | Más = montañas gigantes en el medio (2.0 la mitad, 6.0 enormes). |
| Exageración junto a la ARENA | `terreno_horizonte.gd:33` | `MONT_EXAG_LEJOS := 1.0` | `1.0` = altura real; `0.5` = bien bajitas junto a la arena. |
| Dónde arranca el gradiente | `terreno_horizonte.gd:34` | `RADIO_EXAG_CERCA := 0.0` | Radio (m) desde el centro donde vale la exageración "cerca". |
| Dónde termina el gradiente | `terreno_horizonte.gd:35` | `RADIO_EXAG_LEJOS := 2100.0` | Radio donde se alcanza la exageración "lejos". Entre ambos radios interpola suave. |

Colores por altura del impostor: `_color_por_altura()` en
`terreno_horizonte.gd:327` (arena < 6, pasto < 16, transición < 27,
piedra < 45, cima ≥ 45 — son ALTURAS YA EXAGERADAS).

Ocultamiento de los tiles del impostor: `terreno_horizonte.gd:60`
`TILE_OCULTAR_UMBRAL := 400.0` — a menos de esa distancia tuyo los tiles se
ocultan y **el terreno real toma el mando**. ⚠️ No lo pongas chico (ej. 10):
el impostor cercano deja de ocultarse y TAPA tu terreno real (por eso se veía
"que las montañas no se generan cerca"). **Independiente** del umbral del
anillo (sección 3).

## 6. Jugador — `scripts/player/player.gd`

| Qué | Línea | Valor actual | Cómo ajustar |
|---|---|---|---|
| Velocidad al caminar | `player.gd:8` (y override DEV en `:57`) | `100.0` (DEV 25) | ⚠️ La escena `player.tscn` sobrescribe el @export: si no cambia, editar el valor en la escena (inspector del Player) o la línea 57. Valor de juego pensado: `5.0`. |
| Fuerza de salto | `player.gd:10` | `8.0` | Más = salta más alto. |

## 7. Cámara — `scripts/follow_camera.gd`

| Qué | Línea | Valor actual | Cómo ajustar |
|---|---|---|---|
| Suavidad de seguimiento | `follow_camera.gd:6` | `12.0` | Más = sigue más pegado; menos = más flotante. |
| Velocidad del zoom (scroll) | `follow_camera.gd:7` | `2.0` | A ojo. Más ajustes de cámara en `GUIA-GODOT/16-zoom-camara-personaje.md`. |

## 8. Población y mundo

| Qué | Archivo:línea | Valor actual | Cómo ajustar |
|---|---|---|---|
| Máximo de vecinos | `scripts/npc/villager_manager.gd:29` | `POBLACION_MAX := 10` | Más vecinos = más NPCs simulados. |
| Vecinos al arrancar | `scripts/npc/villager_manager.gd:36` | `POBLACION_ARRANQUE := 6` | A ojo. |
| Duración del día y del año | `game/isla-ancestral/data/time/time_config.tres` | día 1440 min, año 336 días | Es un recurso (.tres): editar en el editor de Godot (Inspector) o pedirle al agente. |

---

## Recordatorios

1. **Después de editar, verificar**: correr el juego y mirar que no haya
   errores (guía: `GUIA-GODOT/19-diagnostico-tildes.md` si algo se tilda).
2. **No tocar**: `get_voxel` (prohibido en streaming — guía 18), y cualquier
   archivo marcado como flujo estable (AGENTS.md §16).
3. Estos valores son "a ojo": si subís `view_distance` y el juego anda mal,
   volvé al valor anterior — la GPU integrada tiene techo.
