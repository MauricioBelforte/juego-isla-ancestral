**Modelo:** MiniMax-M3
**Plataforma:** WorkBuddy AI

# Log 193 — M15-Recursos: Tronco caído + Nido de cocos (tier 1)

**Fecha:** 2026-08-28 15:24:30
**Hora:** 15:24

## Descripción breve
Se crearon dos assets del módulo 15 (Recursos): **Tronco caído** y **Nido de cocos**. Ambos con script, `.blend` y captura. Se documenta además una limitación de la sesión: la revisión visual de capturas quedó bloqueada porque el modelo en curso no acepta imágenes, por lo que el QA se hizo por verificación numérica de bounding boxes.

## Archivos creados

### Tronco caído
- `tools/mcp/blender-mcp/15-Recursos/scripts/crear_tronco_caido_lowpoly.py` — Tronco de UNA sola malla bmesh (regla E-01): 8 anillos × 9 lados, largo 3.20, radio 0.40→0.30, pandeo senoidal suave en Y/Z y ruido radial ±10 %. Las tapas usan `face.material_index = 1` para que los extremos cortados muestren madera interior mientras el cuerpo muestra corteza, todo en el mismo objeto. + 2 muñones de rama (conos), 3 raíces expuestas (conos invertidos) y 3 placas de hojarasca.
- `tools/mcp/blender-mcp/15-Recursos/tronco_caido_lowpoly.blend` — 12 objetos.
- `capturas/cap_15_2026-08-28_15-16-40_tronco-caido-01.png`

### Nido de cocos
- `tools/mcp/blender-mcp/15-Recursos/scripts/crear_nido_cocos_lowpoly.py` — Lecho de 5 tiras de hoja de palmera en abanico + 8 cocos (6 abajo, 2 arriba). Cada coco es una icosphere subdiv 2 achatada en Z (×0.84) con ruido fibroso ±12 mm y rotación aleatoria ≤14°, más 3 "ojos" semiesféricos oscuros.
- `tools/mcp/blender-mcp/15-Recursos/nido_cocos_lowpoly.blend` — 40 objetos.
- `capturas/cap_15_2026-08-28_15-24-10_nido-cocos-final.png`

### Herramienta nueva (reutilizable)
- `tools/mcp/blender-mcp/scripts-reutilizables/verificar_bounds.py` — QA numérico vía MCP. Uso: `python verificar_bounds.py SM_Coco_`. Reporta cantidad de objetos, `z_min`/`z_max`/alto, rango X/Y de centros y detección de centros duplicados. **Es el sustituto de la revisión visual cuando el modelo no acepta imágenes.**

## Modificados
- `CHECKLIST-OBJETOS-BLENDER.md` — "Tronco caído" y "Nido de cocos" marcados `[x]`; contador 9 → 11.
- `Logs/ULTIMO_NUMERO.txt` — 192 → 193.

## Detalles técnicos / errores corregidos

### E-08 (nuevo) — `primitive_cylinder_add` no acepta `radius2` en Blender 4.x
- **Síntoma:** `Code execution error: Converting py args to operator properties: keyword "radius2" unrecognized`.
- **Causa:** en Blender 4.x el operador de cilindro se quedó con un único parámetro `radius`; el cono sí conserva `radius1`/`radius2`.
- **Solución:** para piezas con afinado (raíces, muñones) usar `primitive_cone_add` con `radius1`/`radius2`; reservar `primitive_cylinder_add` para piezas de radio constante.

### E-09 (nuevo) — El tilt de una pieza plana eleva su tope real muy por encima del espesor nominal
- **Síntoma:** las tiras de hoja del nido tenían espesor 0.06 y centro en z=0.045 (tope nominal 0.075), pero el bounding box medido daba `z_max = 0.134`. Los cocos quedaban hundidos 10 cm.
- **Causa:** el tilt Y de ±8° sobre una tira de 0.95 de largo hace que el semi-eje Z efectivo sea `sqrt((0.475·sin8°)² + (0.03·cos8°)²) ≈ 0.072`, no 0.03.
- **Solución:** no calcular apoyos con el espesor nominal; medir el bounding box real con `verificar_bounds.py` y recién entonces posicionar. En el nido, la base de los cocos pasó de `R*1.20` a `R*1.65` (0.276 → 0.380), dejando `z_min coco = 0.133` contra `z_max hoja = 0.134`.

## Validación numérica (sin revisión visual)
- **Tronco caído:** 83 vértices / 90 polígonos; bbox X −1.68..1.65 (3.3 m), Z 0.078..0.876 → apoyado sobre la arena sin hundirse ni flotar; 2 materiales asignados (`MAT_Corteza_Tronco`, `MAT_Madera_Corte`).
- **Nido de cocos:** 8 cocos, `z_min 0.133` / `z_max 0.975` (alto 0.842, coherente con 2 capas); lecho de hojas `z_max 0.134`; sin centros duplicados.

## ⚠️ Pendiente
- **Revisión visual de las capturas de tronco caído y nido de cocos.** El modelo en curso no admite imágenes; hay que pasar a un modelo multimodal y revisar `cap_15_2026-08-28_15-16-40_tronco-caido-01.png` y `cap_15_2026-08-28_15-24-10_nido-cocos-final.png`.

## Estado del módulo
✅ Assets creados, QA numérico OK · `REVISIÓN VISUAL PENDIENTE` · `PENDIENTE EXPORTAR A GODOT`
