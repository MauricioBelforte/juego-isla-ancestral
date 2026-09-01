**Modelo:** MiniMax-M3
**Plataforma:** WorkBuddy AI

# Log 195 — Auditoría de apoyos (E-12, directiva del usuario 2026-08-28)

**Fecha:** 2026-08-28 15:50:00
**Hora:** 15:50

## Descripción breve
El usuario rotó la cámara manualmente y reportó que el nido de cocos seguía flotando. Al re-medir descubrí que mi "apoyo" medía contra el **pico más alto** del lecho de hojas, no contra lo que había debajo de cada coco. El lecho de 5 tiras de 14 cm de ancho en un abanico de ±70° no cubría la base: 3 de los 6 cocos inferiores (los que caían fuera del abanico) colgaban sobre arena desnuda.

Aproveché la auditoría para revisar **todos los 10 assets** existentes y detectar los que también estuvieran flotando. Encontré que:

- **Nido de cocos:** 3 cocos exteriores sin cobertura del lecho.
- **Tronco caído:** `z_min 0.078` vs arena `0.05` → flotaba 2.8 cm.
- **Veta de cobre:** la roca OK, los cristales arriba de la roca (no flotan, emergen de ella).
- **Palmera común:** tronco `z_min 0.080` → flotaba 3.0 cm.
- **Palmera joven:** tronco `z_min 0.060` → flotaba 1.0 cm.
- **Palmera inclinada:** tronco `z_min 0.080` → flotaba 3.0 cm.
- **Cañas de bambú:** el conjunto `z_min 0.080` → flotaba 3.0 cm.
- **Hongo luminoso:** la piedra base está hundida (`z_min -0.103`); el sombrero y el pie no tocan el suelo, son partes del hongo.
- **Arbusto, roca, roca pedernal, veta cobre, flor:** ya apoyados o enterrados.

## Archivos modificados

### Scripts de asset (autocorrección embebida)
Todos los scripts de asset que tocan la arena ahora terminan con un bloque de autocorrección que mide `z_min` y traslada el conjunto a `Z_APOYO = 0.045` (5 mm hundido en la arena).

- `tools/mcp/blender-mcp/15-Recursos/scripts/crear_nido_cocos_lowpoly.py` — **rediseño del lecho**: pasó de "abanico de 5 tiras" a "disco continuo + anillo radial de 8 hojas" para garantizar cobertura total. Materiales `MAT_Hoja_Seca` para el disco, `MAT_Hoja_Palmera` para el anillo. `Z_APOYO = 0.045`.
- `tools/mcp/blender-mcp/15-Recursos/scripts/crear_tronco_caido_lowpoly.py` — autocorrección del bloque `SM_Tronco_Caido + SM_Raiz_ + SM_Munon_ + SM_Hojarasca_`.
- `tools/mcp/blender-mcp/50-Vegetacion/scripts/crear_palmera_lowpoly.py` — autocorrección de `SM_Tronco`. También arreglado el bug `bpy.data.worlds['World']` (no garantizada la presencia del World default en Blender 4.x) → `bpy.data.worlds.get('World') or bpy.data.worlds.new('World')`.
- `tools/mcp/blender-mcp/50-Vegetacion/scripts/crear_palmera_joven_lowpoly.py` — autocorrección de `SM_Tronco_Joven`.
- `tools/mcp/blender-mcp/50-Vegetacion/scripts/crear_palmera_inclinada_lowpoly.py` — autocorrección de `SM_Tronco_Inclinado`.
- `tools/mcp/blender-mcp/50-Vegetacion/scripts/crear_canas_bambu_lowpoly.py` — autocorrección del bloque `SM_Cana_*` completo (cañas + anillos + hojas).

### Herramientas nuevas
- `tools/mcp/blender-mcp/scripts-reutilizables/asentar_en_base.py` — baja un grupo de objetos a un `z_min` objetivo (default 0.05). Para correcciones one-off.
- `tools/mcp/blender-mcp/scripts-reutilizables/auditar_apoyos.py` — recorre todos los `crear_*_lowpoly.py` de un módulo, los ejecuta y reporta el estado de apoyo de cada uno. Distingue entre "FLOTA" (z_min 0.05-0.50, pieza base) y "no es base (alto)" (z_min > 0.50, parte alta de la composición).

### Documentación
- `DOCUMENTACION/09-GUIA-BLENDER.md` — **E-12** (cobertura completa del apoyo + autocorrección medida + directiva del usuario 2026-08-28 *"así con todos los objetos"*). §1 tabla con `asentar_en_base.py` y `auditar_apoyos.py`. §4 extendido con dos ítems nuevos (cobertura total, asentado en base). §7.4 reglas 5 y 6. Firma actualizada.
- `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` — líneas de palmeras, cañas, tronco y nido actualizadas con las nuevas capturas y los `z_min` finales. Limpiado el duplicado de palmera joven/inclinada.
- `Logs/ULTIMO_NUMERO.txt` — 194 → 195.

## Validación numérica (auditoría final)
| Asset | z_min pieza base | Estado |
|---|---|---|
| Nido de cocos (cocos) | 0.045 | ok (asentado) |
| Nido de cocos (disco) | 0.020 | ok (enterrado) |
| Roca común | -0.367 | ok (enterrado) |
| Roca de pedernal | -0.963 | ok (enterrado) |
| Tronco caído (conjunto) | 0.045 | ok (asentado) |
| Veta de cobre (roca) | 0.005 | ok (apoyado) |
| Veta de cobre (cristales) | 0.640 | no es base (alto) ✓ |
| Palmera común (tronco) | 0.045 | ok (asentado) |
| Palmera joven (tronco) | 0.045 | ok (asentado) |
| Palmera inclinada (tronco) | 0.045 | ok (asentado) |
| Cañas de bambú | 0.045 | ok (asentado) |
| Hongo (piedra base) | -0.103 | ok (enterrado) |
| Hongo (pie, sombrero) | 0.400+ | no es base (alto) ✓ |
| Arbusto | -0.155 | ok (enterrado) |
| Flor | 0.000 | ok (apoyado) |

## Visión
Captura del nido final: los cocos están **asentados sobre el disco marrón del nido**, con el anillo de hojas asomando alrededor. Ya no se ve flotación desde ningún ángulo.

## Estado del módulo
✅ Todos los 10 assets existentes asentados correctamente · 11/117 en checklist
