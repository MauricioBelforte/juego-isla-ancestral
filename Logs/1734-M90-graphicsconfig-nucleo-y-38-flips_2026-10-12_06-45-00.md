# Log 1734: M90-Configuracion-Grafica - nucleo GraphicsConfig (69 -> 107)

**Fecha:** 2026-10-12
**Hora:** 06:45
**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code

## Resumen

Encargo del director (msg 182): barrido de M90-Configuracion-Grafica.
**M90: 69 -> 107 `[x]` / 249 (+38).** Sin commits (indicación del director).

## Implementado: `scripts/settings/graphics_config.gd` (nuevo, ~14 KB)

Núcleo **puro** (sin nodos ni UI) que implementa `03-Diseno.md` §1:

- **Pantalla**: `RESOLUCIONES` (720p/1080p/1440p/4K/nativa), `ASPECT_RATIOS` (16:9, 16:10, 21:9),
  `MODOS` (ventana / pantalla completa / borderless).
- **Calidad**: `SOMBRAS` (cascadas, mapas, resolución y soft por calidad), `TEXTURAS` (escala,
  mipmap, filtrado, aniso), `DISTANCIA`, `EFECTOS`, `VEGETACION`, `AGUA`, `PARTICULAS`.
- **AA / Upscaling**: 5 opciones de AA, 5 de upscaling, 5 escalas de resolución.
- **VSync / FPS**: 0/1/2 y 30/60/120/ilimitado.
- **Presets**: bajo/medio/alto/ultra con el juego **completo** de claves + detección de
  "personalizado" cuando el usuario cambia un valor.
- **Detección de hardware**: `clasificar_ram`, `clasificar_cpu`, `_clasificar_gpu` (por palabras
  clave) y `recomendar_preset`.
- **Persistencia**: `to_dict` / `from_dict` / `from_json` con **migración suave** (las claves que
  faltan toman el default del preset medio).
- **Cálculos derivados**: `pixeles_sombra()`, `distancia_metros()`, `max_particulas()`,
  `tamano_resolucion()`, `aspect_de_resolucion()`, `resolucion_mas_cercana()`.

## ⚠️ Bug real encontrado por el test

`recomendar_preset()` usaba `maxi` sobre los índices de calidad, o sea que tomaba la **más alta**
de las tres clasificaciones: una RTX 4090 con 4 GB de RAM recomendaba "ultra" y el juego habría
arrancado sin poder. Corregido a `mini` (gana la más baja: nunca sobre-recomendar). La regla del
diseño (§1) dice exactamente eso y el código la cumplía al revés.

## Pitfall de Godot detectado

No se pueden llamar `get()` / `set()` a métodos propios: `Object` ya define `get(StringName, Variant)`
y `set(StringName, Variant)`, y pisarlos rompe el contrato nativo
("The function signature doesn't match the parent"). Renombrados a `obtener()` / `fijar()`.
Es el mismo tipo de problema que el `AssetProfile` por identificador (E-27/E-28/E-29): hay que
conocer los miembros nativos antes de elegir nombre.

## Verificación

`scripts/settings/test_graphics_config.gd` — **62 checks, 0 fallos**, 6 bloques:
pantalla, calidad, AA/upscaling, presets, detección, persistencia.
Regresión verificada: `test_settings_audio_roundtrip.gd` (M53) 51 checks, 0 fallos.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/settings/graphics_config.gd` (nuevo)
- `game/isla-ancestral/scripts/settings/test_graphics_config.gd` (nueva, 62 checks)
- `DOCUMENTACION/90-Configuracion-Grafica/plan-actual/05-Checklist.md` (38 flips)
- `DOCUMENTACION/90-Configuracion-Grafica/plan-actual/04-Codigo.md` (Notas del Agente)

## Nota

El director pidió "Actualizar GLOBAL con nuevo conteo", pero `CHECKLIST-GLOBAL.md` es READ-ONLY para
mí (regla de mis encargos), así que el conteo nuevo queda en el informe para que el director lo
aplique. Sin commits, según indicación.
