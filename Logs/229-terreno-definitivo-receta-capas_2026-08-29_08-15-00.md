# Log 229: Terreno definitivo de la isla — receta por capas validada por el usuario

**Fecha:** 2026-08-29
**Modelo:** Hy3
**Plataforma:** Kilo

## Resumen
Iteración visual con el usuario (capturas + feedback en vivo) hasta llegar al terreno aprobado: isla circular (radio 2048, atolón de arena blanca) con montañas de piedra MÚLTIPLES que varían entre ellas en el interior, orilla con agua clara pisable y agua profunda donde se hunde. La receta completa quedó documentada en la guía Godot (10.12) para poder pedir este terreno exacto en islas nuevas.

## Cambios
- `island_generator.gd` (get_height): perfil en capas: agua profunda (98-100%), agua clara pisable (94-98%, height 2), anillo de arena (hasta 94%, height 3-4), interior con montañas múltiples (`pico_original` con `island_shape^1.5 * max_height` + relleno `altura_suave` + `crestas*6`) mezcladas con `lerp` por `peso_montana` (sin muros verticales).
- `main_island.gd`: spawn en (3148, 2048) con altura calculada del generador; VoxelViewer que SIGUE al jugador con viewer_radius 640; VoxelGeneratorFlat eliminado (no existe `block` en esta versión).
- `player.gd`: salto ESPACIO (velocity 7.0 + _on_ground false); velocidad dev 100 (revertido el sub-stepping que daba 1 FPS); print de diagnóstico [DEV].
- Fix crítico del día: la escena `Player.tscn` pisa el `@export move_speed` (por eso nunca cambiaba la velocidad).
- Documentación: guía Godot 10.8 (receta por capas), 10.9 (aguas de dos niveles), 10.10 (terreno infinito — descubrimiento accidental validado: 15 min sin orilla), 10.11 (tscn pisa @export), 10.12 (receta completa validada).

## Hallazgos clave
1. **Terreno infinito**: altura mínima SIN acotar por distancia => mundo sin orilla (técnica 10.10).
2. **El .tscn pisa el @export** (10.11): la escena Player.tscn tenía move_speed=5.0 guardado.
3. VoxelViewer fijo => borde cuadrado (10.1); debe seguir al jugador.
4. `VoxelGeneratorFlat.block` no existe en esta versión del addon.
5. M09 latente: world_generator.gd:34 `get_block_at in previously freed` al generar ciertos chunks.

## Archivos
- island_generator.gd, main_island.gd, player.gd, preview_ruina.gd
- Guía Godot (10.8-10.12), checklist M25, registros, capturas cap_25_*
