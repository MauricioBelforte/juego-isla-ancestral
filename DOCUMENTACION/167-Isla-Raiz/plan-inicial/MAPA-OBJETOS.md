**Modelo:** Hy3
**Plataforma:** Kilo
**Fecha:** 2026-08-30

# MAPA DE OBJETOS — Isla Raíz (posición de arranque del juego)

> 📍 **FUENTE DE VERDAD DE POSICIONES** de los objetos del inicio de la partida (Isla Raíz).
> Si el código cambia una posición, ACTUALIZAR ESTE DOCUMENTO. Si se rompe el mundo, aquí
> está dónde va cada objeto para restaurarlo. Este mapa es SOLO del inicio de la partida;
> luego el jugador mueve cosas (no se documenta).

## Referencia del mundo
- **Centro de la isla:** `(256, 256)` (= island_radius 256).
- **Radio:** 256 (isla visible: montaña interior, plato de arena, agua al borde).
- **Semilla:** 42. **Perfil:** montaña (dist<0.78) → plato de arena → agua clara/profunda.
- El VoxelViewer sigue al jugador (`main_island.gd:_process`).

## Tabla de objetos

| # | Objeto | Tipo | Posición (X, Z) | Altura (Y) | Nota / cómo se posiciona |
|---|---|---|---|---|---|
| 1 | **Player** (jugador) | CharacterBody3D | (256, 256) | `get_height+3` | Spawn en el centro de la isla. `main_island.gd` `_ajustar_spawn_superficie` usa TerrainLocator. |
| 2 | **VoxelViewer** | VoxelViewer | (256, 256) | (float) | Sigue al jugador. Posición inicial en el spawn. |
| 3 | **CatalinaOso** (NPC) | CharacterBody3D | (268, 268) | `TerrainLocator.get_height+1` | Junto al spawn. Snap con TerrainLocator (no flota). Transform en `main_island.tscn`. |
| 4 | **Ruina Chozavil** (M25) | Node3D (RuinaChozavil) | (320, 320) | `get_buscar_altura+1` | ✅ DENTRO de la isla (dist 0.35, ladera). Antes estaba (660,660) FUERA. Ver `generador_ruina.gd base`. |
| 5 | **Camera3D** | Camera3D | (0, 0) | — | Cámara inicial de la escena; el follow_camera la reposiciona. |
| 6 | **DirectionalLight** | DirectionalLight3D | (0, 0) | — | Luz del mundo. |
| 7 | **WorldEnvironment** | WorldEnvironment | (0, 0) | — | Entorno. |

## Objetos dinámicos (creados en _ready, no en el tscn)

| Objeto | Creador | Posición base | Nota |
|---|---|---|---|
| Ruina Chozavil | `_crear_ruina()` | (320, 320) | Genera voxels (paredes, columna, sello). DENTRO de la isla. |
| Hotbar HUD | `_create_hotbar_hud()` | UI (no mundo) | Muestra herramientas. |
| DialogueUI | `_crear_ui_dialogo()` | UI (no mundo) | Caja de diálogo de M21. |

## Reglas de actualización
1. **SIEMPRE** usar `TerrainLocator` (`posicionar_sobre_terreno`) para objetos del mundo.
2. Al mover un objeto: actualizar ESTE mapa Y el código (sincronizados).
3. La ruina estaba desalineada (660,660 fuera) — corregida a (320,320) DENTRO de la isla (dist 0.35).
4. El spawn del jugador debe estar en el centro (256,256) para que la vista inicial muestre
   montaña + plato + agua.
5. Los objetos de UI (hotbar, dialogo) NO van en este mapa (no son del mundo).

## Posiciones candidatas verificadas (del generador, radio 256)

| Coordenada (X,Z) | Dist del centro | Altura del suelo | Tipo de terreno |
|---|---|---|---|
| (256, 256) | 0.00 | ~23 | Centro (montaña) |
| (268, 268) | 0.066 | ~23 | Montaña (Catalina) |
| (320, 320) | 0.35 | ~8 | Ladera interior (ruina) |
| (256, 128) | 0.5 | ~6 | Pradera plana |

> Nota: la ruina quedó en (320,320) (dist 0.35, ladera) — verificar con TerrainLocator
> que quede sobre la superficie. La ruina del preview está en (68,68) (escena prueba).
