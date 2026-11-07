# 080 - Reporte de tanda B-2 V1 (Nemotron-3.5-Super-VL -> agnes-3-flash, cierre tanda 5 items)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
**Fecha:** 2026-10-28 00:07 (GMT-3)
**Responde a:** (cierre de tanda del riel B-2 V1 — RIEL-V1-VISION-CAPTURAS.md)

## Items cerrados (V1-048 a V1-052)

| Item | Modulo | Captura analizada | Estado |
|------|--------|-------------------|--------|
| V1-048 | 33-Agricultura | `tools/mcp/godot-mcp/capturas/33-Agricultura/cap_33_iter2_dia3.png` | [x] |
| V1-049 | 34-Pesca | `tools/mcp/godot-mcp/capturas/34-Pesca/cap_34_2026-10-25_21-31-21_nemotron_pesca_sin_ui_visible.png` | [x] |
| V1-050 | 34-Pesca | `tools/mcp/godot-mcp/capturas/34-Pesca/cap_34_2026-10-25_21-31-21_nemotron_pesca_sin_ui_visible.png` | [x] |
| V1-051 | 37-Museos-Y-Colecciones | `tools/mcp/godot-mcp/capturas/37-Museos-Y-Colecciones/cap_37_2026-10-09_00-08-55_vitrinas_museo.png` | [x] |
| V1-052 | 37-Museos-Y-Colecciones | `tools/mcp/godot-mcp/capturas/37-Museos-Y-Colecciones/cap_37_2026-10-09_00-08-55_vitrinas_museo.png` | [x] |

## Evidencia (citas textuales con ruta + descripcion)

- V1-048 (33-Agricultura): escena de campo de cultivo en bloques verdes (estilo voxel/low-poly) con surcos y parcelas, agua en el fondo, personaje voxel en primer plano centro-derecha; "FPS: 60"; panel "Controles:" lateral; barra inferior con barra roja y barra verde (salud/energía). Ruta: `.../capturas/33-Agricultura/cap_33_iter2_dia3.png`.
- V1-049/V1-050 (34-Pesca): escena 3D en Godot Debug; agua azul en primer plano con costa verde/bloques en el horizonte; personaje voxel centro-derecha; objetos naranjas (nodos de recurso/cebo) a la derecha del jugador; "FPS: 59"; panel "Controles:" lateral; barra inferior con barra roja y barra verde (salud/energía). Ruta: `.../capturas/34-Pesca/cap_34_2026-10-25_21-31-21_nemotron_pesca_sin_ui_visible.png`.
- V1-051/V1-052 (37-Museos-Y-Colecciones): escena de vitrina de museo; objeto central (cubo blanco con cara gris en el frente) sobre base blanca; fondo gris neutro/plano; barra de título "isla-ancestral (DEBUG)". Ruta: `.../capturas/37-Museos-Y-Colecciones/cap_37_2026-10-09_00-08-55_vitrinas_museo.png`.

## Hallazgos (defectos visuales detectados)

1. **Ausencia recurrente de HUD/UI de juego tradicional flotante** (33-Agricultura, 34-Pesca, 37-Museos-Y-Colecciones): solo barra inferior integrada (salud/energía) y panel de controles del editor; sin menú principal, sin barra de vida/energía flotante, sin controles en pantalla aparte del panel del editor.
2. **Objetos sin etiquetas de identificación** (V1-050, V1-052): objetos naranjas (nodos de recurso/cebo) en 34-Pesca sin etiqueta de función; objeto de museo (cubo blanco con cara gris) en 37-Museos-Y-Colecciones sin etiqueta ni descripción.
3. **Escena de mundo voxel en bloques sin texturas de detalle** (V1-048, V1-050, V1-052): aspecto de bloques planos evidentes; transiciones agua-tierra y entre parcelas son bordes rectos sin mezcla suave.
4. **Fondo/escenario vacío o plano** (V1-048, V1-051, V1-052): agua/costa sin detalle de espuma; fondo gris neutro en museo sin iluminación ni contexto ambiental.
5. **No se detectaron**: solapamientos de UI, textos ilegibles, colores fuera de paleta, assets faltantes evidentes.

## Propuestas de mejora (por ítem)

- V1-048: añadir HUD básico (barra de vida verde + barra de energía roja + controles "WASD - Mover / Scroll - Zoom / Escape - Pausa / F - Hablar con NPC") y menú principal "Jugar"; agregar texturas de detalle a parcelas de cultivo; añadir límites visuales o etiquetas a las parcelas para identificar su estado.
- V1-049: mantener barra inferior integrada o añadir HUD tradicional flotante según decisión de diseño.
- V1-050: añadir HUD básico y menú principal; añadir etiqueta/tooltip a los objetos naranjas (nodos de recurso/cebo); suavizar transición agua-tierra con banda de espuma de orilla; agregar texturas de detalle al terreno y al agua.
- V1-051: añadir HUD básico y menú principal; objeto de museo sin etiqueta ni descripción; fondo gris sin contexto ambiental.
- V1-052: añadir HUD básico y menú principal; añadir etiqueta/tooltip descriptivo al objeto de museo; agregar iluminación de museo (focos, sombras) y contexto ambiental al fondo; agregar texturas de detalle al objeto y a la vitrina.

## Resumen

- hecho=5 (V1-048, V1-049, V1-050, V1-051, V1-052)
- skip=0
- fail=0

Los 5 ítems del riel B-2 V1 quedan marcados [x] en `RIEL-V1-VISION-CAPTURAS.md`. El riel V1 lleva 47 de 88 items completados; restan V1-053 a V1-088. No se agota el riel, por lo que no se marca el BACKLOG MASTER ni se pasa al siguiente riel.

---

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
