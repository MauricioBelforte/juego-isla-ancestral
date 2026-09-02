# Log 541: M52 Partículas — Iteración 3: VfxFactory + lección hex en Godot 4

**Fecha:** 2026-09-02
**Hora:** 20:20
**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code

## Resumen

Iteración 3 del módulo M52: la VfxFactory completa (catálogo → parámetros → GPUParticles3D) con test 8/8. Durante la iteración se descubrió y documentó una **lección técnica**: `hex_to_int()` NO existe en Godot 4 y `float("0xF4")` tampoco parsea hex — se implementó parseo manual (`_hex_byte` con tabla de dígitos).

## Cambios Realizados

- `scripts/particles/vfx_factory.gd` — `cargar_catalogo()` (Array de 8 VFX), `parametros(vfx)` (color/cantidad/emisión/tipo, headless-safe) y `crear(container, vfx, pos)` (GPUParticles3D one_shot con ParticleProcessMaterial).
- `scripts/particles/test_vfx_factory_headless.gd` — 8/8 checks OK, exit 0.

## Lección documentada (para la guía)

- `hex_to_int()` no existe en Godot 4.7 · `("0x..").to_int()` no parsea hex · el parseo correcto es manual (tabla "0123456789abcdef" + `find(char.to_lower())`) o el parser de `Color.html`. Nota para el equipo (evita repetir la hora invertida).

## Verificación

- 8/8 tests OK (catálogo, parámetros polen #F4E04D, defaults, vacíos).

## Archivos Modificados/Creados

- Creados: `scripts/particles/vfx_factory.gd`, `scripts/particles/test_vfx_factory_headless.gd`
- Modificados: `DOCUMENTACION/52-Particulas-Y-VFX/plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md` (fila 52 → 🟡 18/130), `Logs/ULTIMO_NUMERO.txt` (→541)
