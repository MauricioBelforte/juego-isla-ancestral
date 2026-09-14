# Log 820: Guía simple de configuración + anillo circular v4 + gradiente de montañas

**Fecha:** 2026-09-11
**Hora:** 05:06
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
A pedido del usuario: (1) guía de configuración simple con las ubicaciones exactas (archivo:línea) de los valores ajustables "a ojo"; (2) ocultamiento del anillo de arena SEPARADO del impostor; (3) anillo circular LISO (descarte del abrazacostas v3 — bordes triangulares con agua no gustaron); (4) gradiente de exageración de montañas impostoras por distancia al centro (altas en el centro, bajas junto a la arena).

## Cambios Realizados
- **Creada** `DOCUMENTACION/GUIA-CONFIGURACION-SIMPLE.md`: 8 secciones (visión/carga, niebla, anillo de arena, disco verde, montañas impostoras, jugador, cámara, población/mundo) con archivo:línea, valor actual y sugerencias.
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd`:
  - **Anillo v4 circular**: qudiscarte el v3 abrazacostas (muestreo por dirección generaba cuñas triangulares con agua entre segmentos). Vuelta al disco circular liso con `ANILLO_R_INTERNO` (1800) y `ANILLO_R_EXTERNO` (2600) editables.
  - **Ocultamiento separado**: `ANILLO_OCULTAR_UMBRAL` (nuevo, default 400) solo para los sectores del anillo; `TILE_OCULTAR_UMBRAL` (que el usuario ya puso en 100.0) queda solo para el impostor. Helper `_aplicar_ocultamiento(lista, umbral, pp)` compartido.
  - **Gradiente de montañas**: `MONT_EXAG_CERCA` (4.0), `MONT_EXAG_LEJOS` (1.0), `RADIO_EXAG_CERCA` (0), `RADIO_EXAG_LEJOS` (2100) — interpola la exageración por distancia al centro; playa (h≤6) siempre a altura real.
  - `DISCO_R` const para el radio del disco verde; eliminado el helper `_radio_costa` (ya no se usa).
- Limpieza: autoload temporal `CapturaGradM09` + script eliminados (regla guía 19); sin procesos Godot residuales.

## Verificación (MCP + capturas)
- 3 capturas in-game (vista aérea y a ras del terreno): impostor construido 42 tiles, terrazas del gradiente renderizando, sin SCRIPT ERROR. Boot: `anillo arena circular r 1800-2600 (16 sectores, ocultar <400.0) — Log 820`.
- El usuario ajusta los valores a ojo con la guía (el propio usuario ya editó TILE_OCULTAR_UMBRAL a 100.0 en esta sesión).

## Archivos Modificados/Creados
- `DOCUMENTACION/GUIA-CONFIGURACION-SIMPLE.md` (nuevo)
- `game/isla-ancestral/scripts/world/terreno_horizonte.gd` (anillo v4, ocultamiento separado, gradiente, DISCO_R)
- `game/isla-ancestral/scripts/world/captura_grad_m09.gd` (creado y eliminado)
- `game/isla-ancestral/project.godot` (autoload temporal agregado y removido)

## Notas
- Sin commitear (acumulan logs 817, 818 y 820) — pendiente decisión del usuario.
- El error preexistente `VoxelViewer` en main_island.gd:330 sigue observado (no es de esta sesión).
