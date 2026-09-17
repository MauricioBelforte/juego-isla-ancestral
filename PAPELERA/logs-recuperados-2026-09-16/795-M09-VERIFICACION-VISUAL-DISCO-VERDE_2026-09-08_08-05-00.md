# Log 795: M09 — impostor verde sobre el agua VERIFICADO VISUALMENTE (Log 793-795)

**Fecha:** 2026-09-08
**Hora:** 08:05
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
**CONFIRMACIÓN VISUAL DEL USUARIO**: la captura `verde_imp_1.png` (copiada a `capturas/9/cap_9_..._disco_verde_43_activo.png`) muestra el sistema completo funcionando:

- **El disco verde impostor** cubre la laguna interior completa — ya NO se ve el agua azul fantasma dentro de la isla (el problema original del usuario: "veo agua rodeando las montañas").
- **Los acantilados escalonados** del impostor con paredes verticales se ven en los bordes del relieve.
- **El agua azul real** solo aparece en el horizonte (fuera de la isla) — correcto.
- **Las montañas grises del perfil original** al fondo — sin tocar (max_height 40 restaurado).
- **El jugador voxel M45** con los recursos M47 (vetas cobre/oro/hierro) alrededor.
- **FPS 60** — sin tildes (material opaco + fade binario por tile, Log 794).

## La solución final (secuencia de logs 790-795)
1. El disco itera las CLAVES del cache de alturas (fix claves no coincidientes, Log 790).
2. Disco a y=4.3 ENCIMA del agua azul (no debajo — fix posición, Log 800).
3. Material OPACO con fade binario por tile (fix tildes GPU integrada, Log 794).
4. Relieve vertical en las paredes (visible de canto — Log 795 heightmap).

## Estado del código
- `terreno_horizonte.gd`: montañas impostoras (r 700 de (2660,2580)) + disco verde uniforme (r 0-2600 a y=4.3, opaco).
- `_fade_tiles` con métrica AABB-clamp por tile.
- Perfil del terreno: original M167 (max_height 40, boost 1.0) — restaurado Log 791.

## Archivos Modificados
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd` (posiciones de disco + opacidad)
- Autoloads temporales limpiados (diag, capturas)

## Pendiente
- Commit del trabajo pendiente del usuario (el commit 841afaf ya tiene la base; este log + cambios de color/altura son pequeños ajustes).
