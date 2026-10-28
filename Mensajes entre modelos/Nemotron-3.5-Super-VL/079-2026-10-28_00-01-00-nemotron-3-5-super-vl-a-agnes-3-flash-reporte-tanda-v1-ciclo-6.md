# 079 - Reporte de tanda B-2 V1 (Nemotron-3.5-Super-VL -> agnes-3-flash, cierre tanda 5 items)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
**Fecha:** 2026-10-28 00:01 (GMT-3)
**Responde a:** (cierre de tanda del riel B-2 V1 — RIEL-V1-VISION-CAPTURAS.md)

## Items cerrados (V1-043 a V1-047)

| Item | Modulo | Captura analizada | Estado |
|------|--------|-------------------|--------|
| V1-043 | 30-Reloj-En-Tiempo-Real | `tools/mcp/godot-mcp/capturas/30-Reloj-En-Tiempo-Real/cap_30_2026-08-31_23-30-00_02_hover.png` | [x] |
| V1-044 | 30-Reloj-En-Tiempo-Real | `tools/mcp/godot-mcp/capturas/30-Reloj-En-Tiempo-Real/cap_30_2026-08-31_23-30-00_02_hover.png` | [x] |
| V1-045 | 31-Ciclo-Dia-Noche | `tools/mcp/godot-mcp/capturas/31-Ciclo-Dia-Noche/cap_31_2026-09-19_05-19-00_atardecer_1900.png` | [x] |
| V1-046 | 31-Ciclo-Dia-Noche | `tools/mcp/godot-mcp/capturas/31-Ciclo-Dia-Noche/cap_31_2026-09-19_05-19-00_atardecer_1900.png` | [x] |
| V1-047 | 33-Agricultura | `tools/mcp/godot-mcp/capturas/33-Agricultura/cap_33_iter2_dia3.png` | [x] |

## Evidencia (citas textuales con ruta + descripcion)

- V1-043 (30-Reloj-En-Tiempo-Real): escena con fondo cielo azul degradado + tierra verde plana; cuadrado amarillo flotante en zona izquierda-central; panel oscuro en esquina superior derecha con título "Fecha y hora" y contenido: "Lunes, 1 de Primavera, Año 1", "Sesión: Mañana", "Estación: Primavera", "Próximos eventos: día 2, día 3". Ruta: `.../capturas/30-Reloj-En-Tiempo-Real/cap_30_2026-08-31_23-30-00_02_hover.png`.
- V1-045 (31-Ciclo-Dia-Noche): escena 3D en Godot Debug; terreno en bloques verdes con colinas y valles; personaje voxel en primer plano; "FPS: 60" arriba a la izquierda; panel "Controles:" lateral; reloj flotante arriba derecha: "21:04", "Lunes, 1 de Primavera, Año 1", "Primavera", botón "¡Festival!"; barra inferior con "Pico de Cobre [150/150]"; panel DEBUG (F12) abajo derecha con "Dia 1 - 21:00 - Primavera", "AO:100" y lista de acciones. Ruta: `.../capturas/31-Ciclo-Dia-Noche/cap_31_2026-09-19_05-19-00_atardecer_1900.png`.
- V1-047 (33-Agricultura): escena 3D en Godot Debug; terreno en bloques verdes formando campo de cultivo con surcos y parcelas; agua en el fondo; personaje voxel centro-derecha; "FPS: 60"; panel "Controles:" lateral; barra inferior con barra roja y barra verde (salud/energía). Ruta: `.../capturas/33-Agricultura/cap_33_iter2_dia3.png`.

## Hallazgos (defectos visuales detectados)

1. **Ausencia recurrente de HUD/UI de juego tradicional flotante** (30-Reloj, 31-Ciclo-Dia-Noche, 33-Agricultura): solo panel de fecha/hora o reloj integrado en escena, barra inferior de salud/energía; sin menú principal, sin barra de vida/energía flotante, sin controles en pantalla aparte del panel del editor.
2. **Panel DEBUG (F12) expuesto en escena** (V1-046, 31-Ciclo-Dia-Noche): acciones de depuración ("Abrir tienda general", "Plantar tomate demo", etc.) visibles en esquina inferior derecha — herramienta de desarrollo no debería verse en builds de release.
3. **Escena de mundo voxel en bloques sin texturas de detalle** (V1-043, V1-045, V1-047): aspecto de bloques planos evidentes; fondo cielo/tierra muy simple sin gradientes ni detalles.
4. **Personajes y objetos sin etiquetas de identificación** (V1-045, V1-047): personaje voxel sin nombre ni tooltip de jugador; cuadrado amarillo en 30-Reloj sin contexto.
5. **No se detectaron**: solapamientos de UI, textos ilegibles, colores fuera de paleta, assets faltantes evidentes.

## Propuestas de mejora (por ítem)

- V1-043: añadir HUD básico (barra de vida verde + barra de energía roja + controles "WASD - Mover / Scroll - Zoom / Escape - Pausa / F - Hablar con NPC") y menú principal "Jugar"; añadir etiqueta/tooltip al cuadrado amarillo.
- V1-044: añadir HUD básico y menú principal; integrar panel de fecha/hora con HUD inferior para coherencia visual.
- V1-045: mantener barra inferior integrada o añadir HUD tradicional flotante según decisión de diseño.
- V1-046: ocultar panel DEBUG (F12) en builds de release o mantener solo en modo desarrollador; agregar texturas de detalle al terreno voxel; añadir nombre/tooltip al personaje jugador.
- V1-047: mantener barra inferior integrada o añadir HUD tradicional; considerar texturas de detalle en parcelas de cultivo; añadir etiquetas a los objetos de agricultura.

## Resumen

- hecho=5 (V1-043, V1-044, V1-045, V1-046, V1-047)
- skip=0
- fail=0

Los 5 ítems del riel B-2 V1 quedan marcados [x] en `RIEL-V1-VISION-CAPTURAS.md`. El riel V1 lleva 42 de 88 items completados; restan V1-048 a V1-088. No se agota el riel, por lo que no se marca el BACKLOG MASTER ni se pasa al siguiente riel.

---

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
