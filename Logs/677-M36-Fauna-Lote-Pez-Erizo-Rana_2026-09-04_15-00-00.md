# Log 677: M36 Fauna — Lote de animales voxel (pez, erizo, rana) + estado del diseño de fauna

**Fecha:** 2026-09-04
**Hora:** 15:00
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Lote de 3 animales voxel nuevos (pez, erizo, rana) con renders CYCLES-CPU y .blend guardados. Total de fauna diseñada con visión: **7 animales** (conejo aprobado, nutria, lechuza, abeja, pez, erizo, rana).

## Animales creados

| Animal | Altura | Estado | .blend | Render |
|---|---|---|---|---|
| Conejo | 0.35m | ✅ APROBADO (v5) + GLB exportado | conejo_cozy.blend | orbital 7 vistas + 4 de cerca |
| Nutria | 0.7m | v1 — forma OK, colores por verificar | nutria_cozy.blend | 6 vistas EEVEE (oscuras) + 2 CYCLES |
| Lechuza | 0.5m | v1 — disco facial + ojos grandes ✓ | lechuza_cozy.blend | 3 vistas CYCLES (colores OK) |
| Abeja | 0.1m | v1 — rayas + alas translúcidas ✓ | abeja_cozy.blend | 3 vistas CYCLES (v2 con cámara correcta) |
| Pez | 0.3m | v1 — forma OK, colores a ajustar (azules similares) | pez_cozy.blend | 3 vistas CYCLES |
| Erizo | 0.4m | v1 — púas diagonales ✓, colores a ajustar | erizo_cozy.blend | 3 vistas CYCLES |
| Rana | 0.15m | v1 — ojos saltones ✓ | rana_cozy.blend | 2 vistas CYCLES |

## Lecciones del pipeline (para 07-GUIA §8 y 09-GUIA-BLENDER)
1. **EEVEE_NEXT en headless renderiza SIN colores** (todo gris) — usar CYCLES con device CPU para renders con materiales en background mode
2. **La cámara dentro del objeto** renderiza nada útil — calcular dist = tamaño_objeto × 3
3. **get() con 2 args** no existe en Godot 4.7.2 — usar `in` + get() separado
4. **Resource.new() genérico** no retiene propiedades — usar instancias reales del catálogo

## Scripts reutilizables (en scripts/)
- `render_orbital.py` (patrón): 7 vistas orbitales de un .blend
- `render_cerca.py`: renders de detalle
- `reescalar_v5.py` / `v6_flor.py`: pipeline de escalado con altura objetivo
- `erizo_rana_v1.py` (patrón): múltiples animales en un script con helpers compartidos

## Pendientes
- Exportar nutria/lechuza/abeja/pez/erizo/rana a GLB (patrón conejo_exportar.py)
- Registrar en FaunaManager (catálogo data-driven)
- Ajustes de color del pez (diferenciar vientre/espinas)
- Púas del erizo más oscuras (marrón claro en vez de crema)
- Aprobación del usuario por animal
