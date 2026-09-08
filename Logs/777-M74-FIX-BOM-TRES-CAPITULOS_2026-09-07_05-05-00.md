# Log 777: M74 — fix BOM UTF-8 en los .tres de capítulos (errores del depurador)

**Fecha:** 2026-09-07
**Hora:** 05:05
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
El usuario reportó "muchos errores en el depurador" del editor de Godot: `Parse Error: Expected '['` en los 7 .tres de capítulos M74 (creados en Log 728). Causa: **BOM UTF-8** (bytes EF BB BF) al inicio de cada archivo — el parser de recursos de texto de Godot no lo tolera. Corregido quitando los 3 bytes; verificado 0 BOM en todo el proyecto y los 7 eventos cargando limpios.

## Cambios Realizados
- BOM eliminado de los 7 .tres de `scripts/eventos/data/capitulos/`.
- Escaneo completo del proyecto (.tres/.tscn/.import): 0 archivos con BOM restantes.
- Registrado como B-077 en `11-BUGS.md` y E-16 en `07-GUIA-GODOT.md §8` (con regla de verificación de los primeros 3 bytes al crear recursos).

## Evidencia
- Editor del usuario mostraba 3+ Parse Error en historia_c3/c4/c5 (captura) → tras el fix, boot completo: los 7 `historia_cN` cargan, "Catálogo cargado: 22 eventos", 0 errores de parse.
- Regla aplicable a AGENTS.md §28: los .tres/.tscn deben ser UTF-8 SIN BOM.

## Archivos Modificados
- `game/isla-ancestral/scripts/eventos/data/capitulos/historia_c{1..7}_*.tres` (BOM eliminado)
- `DOCUMENTACION/11-BUGS.md` (B-077)
- `DOCUMENTACION/07-GUIA-GODOT.md` (E-16)
