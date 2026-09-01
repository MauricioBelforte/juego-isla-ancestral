# 305-M18-Inicio-TierE-ParedMadera_2026-08-31_20-30-00.md

**Agente:** MiniMax-M3 (WorkBuddy)
**Módulo:** M18 Casas

## 1. Consulta del usuario

El usuario preguntó **"teniamos mas tiers para hacer mas objetos?"** (~04:30).

Investigación:
- `CHECKLIST-OBJETOS-BLENDER.md` §182: 4 tiers definidos (A=6, B=6, C=15, D=7+Palanca v3). **Los 4 cerrados. No existe Tier E.**
- Backlog por módulo (no por tier): 50 hechos / **66 pendientes** / 116 ítems totales.
- **35 pendientes en módulos libres** (🟢 + agente_actual = —): M50 Vegetación (5), M18 Casas (11), M36 Fauna (9), M45 Arte-3D (5), M27 Landmarks (5).
- Bloqueados: M16 (🔵 GLM), M40 (🔵 Deepseek V4 Flash), M33/M25/M34 (🟡 spec con dudas).

Corrección de errores previos en el inventario:
- M40 es **🔵 En curso** (Deepseek V4 Flash), no 🟢.
- M27 Landmarks **sí es 🟢**.
- Borré el ítem duplicado `- [ ] Puentes de troncos (M40)` (era duplicado del ya cerrado).
- Contadores actualizados: 116 ítems / 50 hechos / 66 pendientes.

Pregunta al usuario: priorizó **M18 Casas (11) (Recomendado)**, y "Esperar, no tocar" los módulos ocupados/con dudas.

## 2. Reserva de M18

`CHECKLIST-GLOBAL.md` fila 18: estado 🟢 Disponible → 🔵 En curso, agente_actual = `MiniMax-M3 (WorkBuddy)`, fecha 2026-08-31.

`CHECKLIST-OBJETOS-BLENDER.md` línea 62: `- [ ]` → `- [/]` con descripción completa del primer asset.

## 3. Primer asset: `pared_madera_lowpoly` (módulo base)

Decisiones de arquitectura reusable para los 10 piezas restantes de M18:
- **Rejilla voxel de 1 m (M17 RF2):** todas las piezas modulares ocupan 1×1 celda → ancho X = **1.000 m exacto**.
- **Postes de medio grosor** (0.06) centrados en x=±0.47: dos paredes contiguas reconstruyen un poste entero de 0.12 → encastre modular sin postes dobles en la junta.
- **E-24 obligatorio:** apoyo medido sobre **vértices reales**, nunca `bound_box`.
- **E-12:** `Z_APOYO = 0.045`, assert `abs(z_final - Z_APOYO) < 1e-4` al final del script.
- **Set de captura "de pared"**: si la pieza va montada sobre superficie vertical (E-28) → asentar también el panel.

Archivos creados:
- `tools/mcp/blender-mcp/18-Casas/scripts/crear_pared_madera_lowpoly.py` (140 líneas)
- `tools/mcp/blender-mcp/18-Casas/pared_madera_lowpoly.blend` (7 SM_, 84 tris, 3 mats)
- `tools/mcp/blender-mcp/18-Casas/capturas/pared_madera_lowpoly_az000..300.png` (6 azimuts)
- `tools/mcp/blender-mcp/18-Casas/capturas/_hoja_cap_18_pared_madera_lowpoly.jpg` (hoja de contacto)

## 4. E-55 (nuevo): capturar sin socket MCP

Blender estaba cerrado → `capturar_angulos.py` no podía correr (depende de `bpy_cliente.blender_command`). Creé `capturar_angulos_headless.py` en `scripts-reutilizables/`:

```
blender -b --factory-startup --python scripts-reutilizables/capturar_angulos_headless.py -- \
    <ruta.blend> <prefijo_SM_> <ruta_base.png> [N] [altura] [dist_mult]
```

Mismo encuadre que la versión por socket (centro del bbox, radio = max semieje, dist = radio*3.0*dist_mult, cámara a ALTURA + radio*0.55, lente 45, 1200x800, EEVEE con SSR activado en el script, no en el .blend).

**Utilidad futura:** cualquiera de los 35 pendientes puede auditarse visualmente con Blender cerrado. El único paso que requiere socket es `generar_variante.py` (que llama `bpy.ops` activos) y `exportar_godot.py` (que ya era headless via E-45, OK).

## 5. Verificación visual (E-13)

6 capturas orbitales (az 000/060/120/180/240/300):
- **Cara plana (az 060/120/240/300)**: se ve el marco completo (2 postes oscuros + 2 soleras + 2 travesaños + panel claro retranqueado). Base apoyada en la arena sin aire.
- **Canto (az 000/180)**: tabla de 0.16 m de espesor → correcto, el módulo ES una pared.
- **Aire entre objeto y base: NINGUNO en los 6 azimuts.** Aprobada.

Veredicto: **APROBADO**.

## 6. Pendiente inmediato

- **Abrir Blender GUI** para que `generar_variante.py` y `exportar_godot.py` corran → cerrar el ciclo MEDIA/BAJA + .glb + import a Godot de `pared_madera_lowpoly`.
- Continuar con los 10 piezas modulares restantes de M18: Pared con ventana, Pared con puerta, Piso de madera, Techo a dos aguas, Techo de paja, Puerta articulada, Ventana con marco, Escalera de mano, Zócalo/fundamento de piedra, Casa completa ejemplo.
- Después: módulos libres restantes (M50 Vegetación 5, M36 Fauna 9, M45 Arte-3D 5, M27 Landmarks 5) = 24 más.

## 7. Cambios producidos

- `tools/mcp/blender-mcp/18-Casas/` (directorio nuevo)
- `tools/mcp/blender-mcp/18-Casas/scripts/crear_pared_madera_lowpoly.py` (nuevo)
- `tools/mcp/blender-mcp/18-Casas/pared_madera_lowpoly.blend` (nuevo)
- `tools/mcp/blender-mcp/18-Casas/capturas/pared_madera_lowpoly_az*.png` (6 nuevos)
- `tools/mcp/blender-mcp/18-Casas/capturas/_hoja_cap_18_pared_madera_lowpoly.jpg` (nuevo)
- `tools/mcp/blender-mcp/scripts-reutilizables/capturar_angulos_headless.py` (nuevo, E-55)
- `_chk_asset_tmp.py` (temporal, en raíz — útil para próximas auditorías)
- `CHECKLIST-GLOBAL.md` línea 113 (M18 reservado)
- `CHECKLIST-OBJETOS-BLENDER.md` línea 62 (ítem marcado `[/]` con descripción)
- `MEMORY.md` (compactado, ahora bajo el límite)

## 8. Errores documentados (este turno)

- **E-55**: `capturar_angulos.py` exige socket MCP (Blender GUI). Workaround: `capturar_angulos_headless.py` (CLI puro). Mismo encuadre, sin pérdida de calidad.
- **E-56**: `generar_variante.py` también exige socket (verificado leyendo `blender_command` en líneas 44 y 453). NO tiene workaround headless todavía — espera Blender GUI.
- **E-57** (refinamiento): el shell NO expande globos entre comillas dobles. `contact_sheet.py "ruta/*.png" ...` falla; sin comillas funciona. (También afecta `for png in *.png` en scripts shell; usar `bash` nativo o `find`.)