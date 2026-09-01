**Modelo:** MiniMax-M3
**Plataforma:** WorkBuddy AI

# Log 194 — M15-Recursos: Nido de cocos, corrección de apoyo + E-11

**Fecha:** 2026-08-28 15:32:00
**Hora:** 15:32

## Descripción breve
El usuario reportó que el nido de cocos estaba flotando en el aire. Diagnostiqué dos errores combinados y los corregí: el lecho de hojas tenía un tilt Y de ±8° que elevaba su tope real de 0.075 a 0.134, y los 3 "ojos" de cada coco estaban posicionados en coords de mundo, no parentados al coco, así que quedaban enterrados dentro de la malla. Reescribí el script con autocorrección de apoyo en caliente y ojos como hijos del coco.

## Archivos modificados
- `tools/mcp/blender-mcp/15-Recursos/scripts/crear_nido_cocos_lowpoly.py`:
  - Lecho de hojas plano (sin tilt Y) → tope EXACTO en z=0.075.
  - `rng` separado en `rng_hojas` y `rng_cocos` para que el semieje vertical del coco sea independiente de los cambios en las hojas.
  - 3 ojos de cada coco como **hijos** del coco con `matrix_parent_inverse = Matrix()` (identidad), en coords locales `(radio·0.33·cos(ang), radio·0.33·sin(ang), radio·0.80)` → quedan sobre la superficie y siguen al coco al rotarlo o trasladarlo.
  - Bloque de **autocorrección de apoyo** al final: mide `z_min` del monton y traslada todos los cocos para que apoye en `Z_APOYO = 0.067` (8 mm hundido en el lecho de hojas).
  - Cámara movida a `(2.1, -2.5, 1.55)` con target `(0, 0, 0.45)` para que el cluster no quede coronando el frame.
- `tools/mcp/blender-mcp/15-Recursos/nido_cocos_lowpoly.blend` — regenerado.
- `tools/mcp/blender-mcp/15-Recursos/capturas/cap_15_2026-08-28_15-31-30_nido-cocos-enfoque.png` — captura final correcta (apoyado, ojos visibles).
- `tools/mcp/blender-mcp/scripts-prueba/verificar_ojos_coco.py` — nuevo: usa `obj.ray_cast` en coords locales del coco para validar que cada hijo está sobre la superficie (ratio 0.90–1.15).
- `DOCUMENTACION/09-GUIA-BLENDER.md` — agregado **E-11** (detalles pegados a un cuerpo se entierran si no son hijos del cuerpo; cómo parenteo + ray_cast de validación) y extensión del checklist de §4 con "detalles parentados" y "apoyos medidos en caliente".
- `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` — línea del nido actualizada con la nueva captura.
- `Logs/ULTIMO_NUMERO.txt` — 193 → 194.

## Validación numérica (antes y después)

| Métrica | Antes (flotando) | Después (corregido) |
|---|---|---|
| `z_min` cocos | 0.133 | **0.067** |
| `z_max` hojas (tope real) | 0.134 | 0.075 |
| Separación coco-hoja | 0.001 (apoyado en pico) | **−0.008** (hundido 8 mm) |
| Ojos enterrados (ratio < 0.90) | 15/24 (63 %) | **0/24** |
| Ratio ojos (min/med/max) | — | 1.031 / 1.071 / 1.097 |

## Visión
La sesión recuperó la capacidad de imágenes a tiempo: pude **revisar visualmente la captura final** y confirmar que el nido está apoyado, las hojas clavadas en la arena y los 3 ojos de cada coco visibles.

## Estado del módulo
✅ Nido de cocos **corregido y aprobado visualmente** · `PENDIENTE EXPORTAR A GODOT`
