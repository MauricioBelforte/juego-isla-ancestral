# 086 - Reporte de tanda B-2 V1 (Nemotron-3.5-Super-VL -> agnes-3-flash, cierre tanda 5 items)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
**Fecha:** 2026-10-28 00:40 (GMT-3)
**Responde a:** (cierre de tanda del riel B-2 V1 — RIEL-V1-VISION-CAPTURAS.md)

## Items cerrados (V1-075 a V1-079)

| Item | Modulo | Captura analizada | Estado |
|------|--------|-------------------|--------|
| V1-075 | 61-Rendimiento | `tools/mcp/godot-mcp/capturas/61-Rendimiento/cap_61_2026-10-25_23-20-34_nemotron_rendimiento_hud_fps.png` | [x] |
| V1-076 | 61-Rendimiento | `tools/mcp/godot-mcp/capturas/61-Rendimiento/cap_61_2026-10-25_23-20-34_nemotron_rendimiento_hud_fps.png` | [x] |
| V1-077 | 76-Multijugador | `tools/mcp/godot-mcp/capturas/76-Multijugador/cap_76_2026-10-21_02-23-30_inventario_dark_pestania_mobiliario.png` | [x] |
| V1-078 | 76-Multijugador | `tools/mcp/godot-mcp/capturas/76-Multijugador/cap_76_2026-10-21_02-23-30_inventario_dark_pestania_mobiliario.png` | [x] |
| V1-079 | 87-Localizacion | `tools/mcp/godot-mcp/capturas/87-Localizacion/cap_87_2026-10-26_01-12-26_nemotron_localizacion_spawn.png` | [x] |

## Evidencia (citas textuales con ruta + descripcion)

- V1-075/V1-076 (61-Rendimiento): escena 3D en Godot Debug; agua azul en primer plano con costa verde/bloques en el horizonte; personaje voxel centro-derecha; objetos naranjas/amarillos (nodos de recurso) a la derecha; "FPS: 60"; panel "Controles:" lateral; barra inferior con barra roja y barra verde (salud/energía). Ruta: `.../capturas/61-Rendimiento/cap_61_2026-10-25_23-20-34_nemotron_rendimiento_hud_fps.png`.
- V1-077/V1-078 (76-Multijugador): pantalla de inventario; encabezado "Inventario"; contador "Slots: 3/24"; pestañas de categoría (Todos, Mobiliario, Decoración, Iluminación, Plantas, Alfombras, Cocina, Trabajo, Exteriores, Naturaleza, Construcción, Herramientas, Items); campo "Buscar"; controles "Ordenar" / "Favoritos+ID" / "Aplicar"; rejilla de slots (3 ocupados: Cama simple x1, Cama doble x1, Cama doble x1; 21 vacíos); texto inferior "Click en un objeto para marcar/desmarcar favorito. Esc para cerrar."; botón "Descartar". Ruta: `.../capturas/76-Multijugador/cap_76_2026-10-21_02-23-30_inventario_dark_pestania_mobiliario.png`.
- V1-079 (87-Localizacion): escena 3D en Godot Debug; agua azul en primer plano con costa verde/bloques en el horizonte; personaje voxel centro-derecha; objetos naranjas/amarillos a la derecha; gaviota volando en el cielo a la derecha; "FPS: 60"; panel "Controles:" con WASD - Mover / Scroll - Zoom in/out / Escape - Pausa / Liberar mouse / E - Hablar con NPC; barra inferior con barra roja y barra verde. Ruta: `.../capturas/87-Localizacion/cap_87_2026-10-26_01-12-26_nemotron_localizacion_spawn.png`.

## Hallazgos (defectos visuales detectados)

1. **Ausencia recurrente de HUD/UI de juego tradicional flotante** (61-Rendimiento, 87-Localizacion): solo barra inferior integrada (salud/energía) y panel de controles del editor; sin menú principal, sin barra de vida/energía flotante, sin controles en pantalla aparte del panel del editor.
2. **UI de inventario como overlay completo** (76-Multijugador): cubre toda la escena sin integración con HUD de juego; muchos slots vacíos (21 de 24) sin indicación de accesibilidad; botón "Descartar" sin confirmación (riesgo de descarte accidental); sin indicador de peso/capacidad más allá de "Slots: 3/24"; objetos sin tooltips descriptivos.
3. **Objetos sin etiquetas de identificación** (V1-076, V1-078): objetos naranjas/amarillos (nodos de recurso) sin etiqueta de función.
4. **Escena de mundo voxel en bloques sin texturas de detalle** (V1-076, V1-078): aspecto de bloques planos evidentes; transiciones agua-tierra son bordes rectos sin mezcla suave.
5. **No se detectaron**: solapamientos de UI, textos ilegibles, colores fuera de paleta, assets faltantes evidentes.

## Propuestas de mejora (por ítem)

- V1-075: mantener barra inferior integrada o añadir HUD tradicional flotante según decisión de diseño.
- V1-076: añadir HUD básico (barra de vida verde + barra de energía roja + controles "WASD - Mover / Scroll - Zoom / Escape - Pausa / F - Hablar con NPC") y menú principal "Jugar"; añadir etiqueta/tooltip a los objetos naranjas; suavizar transición agua-tierra con banda de espuma de orilla; agregar texturas de detalle al terreno y al agua.
- V1-077: mantener inventario como overlay para pruebas de QA-WEB; para el juego principal, añadir HUD básico y menú principal.
- V1-078: añadir confirmación al hacer clic en "Descartar"; añadir indicador de peso/capacidad del inventario; añadir tooltips descriptivos a los objetos en los slots; permitir cerrar el inventario con "Esc".
- V1-079: mantener barra inferior integrada o añadir HUD tradicional flotante según decisión de diseño.

## Resumen

- hecho=5 (V1-075, V1-076, V1-077, V1-078, V1-079)
- skip=0
- fail=0

Los 5 ítems del riel B-2 V1 quedan marcados [x] en `RIEL-V1-VISION-CAPTURAS.md`. El riel V1 lleva 74 de 88 items completados; restan V1-080 a V1-088. No se agota el riel, por lo que no se marca el BACKLOG MASTER ni se pasa al siguiente riel.

---

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
