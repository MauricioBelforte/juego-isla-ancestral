# 078 - Reporte de tanda B-2 V1 (Nemotron-3.5-Super-VL -> agnes-3-flash, cierre tanda 5 items)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
**Fecha:** 2026-10-27 23:55 (GMT-3)
**Responde a:** (cierre de tanda del riel B-2 V1 — RIEL-V1-VISION-CAPTURAS.md)

## Items cerrados (V1-038 a V1-042)

| Item | Modulo | Captura analizada | Estado |
|------|--------|-------------------|--------|
| V1-038 | 19-Muelle | `tools/mcp/godot-mcp/capturas/19-Muelle/cap_19M-AntorchaPared_antes-despues_2026-09-19_02-46-17.png` | [x] |
| V1-039 | 19-NPC-Y-Vecinos | `tools/mcp/godot-mcp/capturas/19-NPC-Y-Vecinos/cap_19_2026-08-28_02-07-15_Catalina Oso NPC visible en isla.png` | [x] |
| V1-040 | 19-NPC-Y-Vecinos | `tools/mcp/godot-mcp/capturas/19-NPC-Y-Vecinos/cap_19_2026-08-28_02-07-15_Catalina Oso NPC visible en isla.png` | [x] |
| V1-041 | 25-Ruinas | `tools/mcp/godot-mcp/capturas/25-Ruinas/cap_25_2026-10-25_23-48-00_nemotron_ruinas_horizonte.png` | [x] |
| V1-042 | 25-Ruinas | `tools/mcp/godot-mcp/capturas/25-Ruinas/cap_25_2026-10-25_23-48-00_nemotron_ruinas_horizonte.png` | [x] |

## Evidencia (citas textuales con ruta + descripcion)

- V1-038 (19-Muelle): escena de muelle de madera sobre agua con antorcha encendida, iluminación cálida, agua azul con reflejos, cielo grisáceo/nublado; panel "Controles:" lateral, FPS: 60, HUD inferior con barra de salud/energía (roja y verde). Ruta: `.../capturas/19-Muelle/cap_19M-AntorchaPared_antes-despues_2026-09-19_02-46-17.png`.
- V1-039 (19-NPC-Y-Vecinos): escena de isla con NPC Catalina Oso (oso antropomorfo) en el centro; terreno verde en bloques voxel; agua alrededor; panel lateral del editor Godot (jerarquía, inspector); barra de título "isla-ancestral (DEBUG)". Ruta: `.../capturas/19-NPC-Y-Vecinos/cap_19_2026-08-28_02-07-15_Catalina Oso NPC visible en isla.png`.
- V1-041 (25-Ruinas): escena 3D del juego en Godot Debug; terreno verde/bloques con costa irregular y agua azul, islas en el horizonte; personaje voxel (camisa verde, pantalón azul); objetos naranjas (nodos de recurso); FPS: 60; panel "Controles:"; HUD inferior salud/energía; reloj/calendario integrados ("19:30", "Lunes, 1 de Primavera, Año 1", "Primavera", "¡Festival!"). Ruta: `.../capturas/25-Ruinas/cap_25_2026-10-25_23-48-00_nemotron_ruinas_horizonte.png`.

## Hallazgos (defectos visuales detectados)

1. **Ausencia recurrente de HUD/UI de juego flotante** en todos los módulos analizados (19-Muelle, 19-NPC-Y-Vecinos, 25-Ruinas): solo barra inferior integrada (salud/energía) y reloj/calendario integrados en escena; sin menú principal, sin barra de vida/energía flotante, sin controles en pantalla aparte del panel del editor.
2. **NPCs y objetos sin etiquetas de interacción** (V1-040): el NPC Catalina Oso no tiene nombre visible ni tooltip "F - Hablar con NPC" asociado en escena; los objetos naranjas (nodos de recurso) en 25-Ruinas no tienen etiqueta de identificación.
3. **Escena de mundo voxel en bloques sin texturas de detalle** (V1-038, V1-040, V1-042): aspecto de bloques planos evidentes; transición agua-tierra es un borde de bloques voxel recto sin efecto de espuma de orilla ni mezcla suave.
4. **No se detectaron**: solapamientos de UI, textos ilegibles, colores fuera de paleta, assets faltantes evidentes.

## Propuestas de mejora (por ítem)

- V1-038: añadir HUD básico (barra de vida verde + barra de energía roja + controles "WASD - Mover / Scroll - Zoom / Escape - Pausa / F - Hablar con NPC") y menú principal "Jugar"; considerar etiquetas interactivas al muelle/antorcha.
- V1-039: añadir HUD básico y menú principal; el NPC no tiene nombre ni etiqueta de interacción visible.
- V1-040: añadir HUD básico y menú principal; añadir nombre/tooltip flotante sobre el NPC al acercarse; considerar texturas de detalle al terreno.
- V1-041: mantener barra inferior integrada o añadir HUD tradicional flotante según decisión de diseño; añadir etiqueta a los objetos naranjas (nodos de recurso).
- V1-042: mantener barra inferior integrada o añadir HUD tradicional; añadir etiqueta/tooltip a objetos naranjas; suavizar transición agua-tierra con banda de espuma de orilla; agregar texturas de detalle al terreno.

## Resumen

- hecho=5 (V1-038, V1-039, V1-040, V1-041, V1-042)
- skip=0
- fail=0

Los 5 ítems del riel B-2 V1 quedan marcados [x] en `RIEL-V1-VISION-CAPTURAS.md`. El riel V1 lleva 38 de 88 items completados; restan V1-043 a V1-088.

---

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
