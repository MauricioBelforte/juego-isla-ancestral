# 083 - Reporte de tanda B-2 V1 (Nemotron-3.5-Super-VL -> agnes-3-flash, cierre tanda 5 items)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
**Fecha:** 2026-10-28 00:27 (GMT-3)
**Responde a:** (cierre de tanda del riel B-2 V1 — RIEL-V1-VISION-CAPTURAS.md)

## Items cerrados (V1-064 a V1-068)

| Item | Modulo | Captura analizada | Estado |
|------|--------|-------------------|--------|
| V1-064 | 51-Agua | `tools/mcp/godot-mcp/capturas/51-Agua/cap_51_2026-10-25_23-34-00_nemotron_agua_correlacion_debug.png` | [x] |
| V1-065 | 52-Particulas-Y-VFX | `tools/mcp/godot-mcp/capturas/52-Particulas-Y-VFX/cap_52M-CalibracionVisual_post-iter6_2026-09-19_03-03-38.png` | [x] |
| V1-066 | 52-Particulas-Y-VFX | `tools/mcp/godot-mcp/capturas/52-Particulas-Y-VFX/cap_52M-CalibracionVisual_post-iter6_2026-09-19_03-03-38.png` | [x] |
| V1-067 | 52-QA-WEB | `tools/mcp/godot-mcp/capturas/52-QA-WEB/cap_web_52_2026-08-25_03-30-39_shot2_polen-web.png` | [x] |
| V1-068 | 52-QA-WEB | `tools/mcp/godot-mcp/capturas/52-QA-WEB/cap_web_52_2026-08-25_03-30-39_shot2_polen-web.png` | [x] |

## Evidencia (citas textuales con ruta + descripcion)

- V1-064 (51-Agua): escena 3D en Godot Debug; agua azul en primer plano con costa verde/bloques en el horizonte; personaje voxel centro-derecha; objetos naranjas/amarillos (nodos de recurso) a la derecha; "FPS: 59"; panel "Controles:" lateral; barra inferior con barra roja y barra verde (salud/energía); el agua tiene aspecto de bloques sin reflejos ni ondas realistas. Ruta: `.../capturas/51-Agua/cap_51_2026-10-25_23-34-00_nemotron_agua_correlacion_debug.png`.
- V1-065/V1-066 (52-Particulas-Y-VFX): escena de calibración visual con fondo gris oscuro y cinco puntos de texto verde dispersos en el centro (texto pequeño, ilegible); barra de título "isla-ancestral (DEBUG)"; sin panel de controles visible, sin HUD de juego tradicional, sin FPS visible. Ruta: `.../capturas/52-Particulas-Y-VFX/cap_52M-CalibracionVisual_post-iter6_2026-09-19_03-03-38.png`.
- V1-067/V1-068 (52-QA-WEB): captura de prueba web del módulo QA-WEB (shot2_polen-web); sin barra de título de Godot, sin panel de controles del editor, sin HUD de juego tradicional; no es una escena 3D del juego. Ruta: `.../capturas/52-QA-WEB/cap_web_52_2026-08-25_03-30-39_shot2_polen-web.png`.

## Hallazgos (defectos visuales detectados)

1. **Ausencia recurrente de HUD/UI de juego tradicional flotante** (51-Agua): solo barra inferior integrada (salud/energía) y panel de controles del editor; sin menú principal, sin barra de vida/energía flotante, sin controles en pantalla aparte del panel del editor.
2. **Escena de calibración sin UI de juego** (52-Particulas-Y-VFX): cinco puntos de texto verde ilegibles en fondo gris oscuro; sin panel de controles, sin HUD de salud/energía, sin menú principal, sin FPS visible.
3. **Captura de prueba web, no escena del juego** (52-QA-WEB): pertenece al módulo QA-WEB de pruebas web, no representa la UI/UX del juego principal; sin contexto de escena 3D (sin personaje, sin terreno, sin agua).
4. **Texto ilegible en puntos de calibración** (V1-066): los cinco puntos de texto verde son demasiado pequeños para leerse desde la distancia mostrada.
5. **Agua sin reflejos ni ondas realistas** (V1-064, 51-Agua): aspecto de bloques sólidos sin superficie dinámica.
6. **No se detectaron**: solapamientos de UI, colores fuera de paleta, assets faltantes evidentes.

## Propuestas de mejora (por ítem)

- V1-064: añadir HUD básico (barra de vida verde + barra de energía roja + controles "WASD - Mover / Scroll - Zoom / Escape - Pausa / F - Hablar con NPC") y menú principal "Jugar"; añadir etiqueta/tooltip a los objetos naranjas (nodos de recurso); suavizar transición agua-tierra con banda de espuma de orilla; agregar reflejos y ondas realistas al agua; agregar texturas de detalle al terreno y al agua.
- V1-065: mantener escena de calibración como entorno de desarrollo; considerar añadir HUD básico si se desea probar con UI de juego.
- V1-066: aumentar el tamaño de los puntos de texto o añadir etiquetas legibles para identificar qué representa cada punto de calibración; añadir contexto ambiental al fondo (cielo, suelo, terreno) para referencia espacial.
- V1-067: esta captura pertenece al módulo QA-WEB (pruebas web), no a la escena principal del juego; no requiere HUD de juego. Para QA-WEB, asegurar que la captura de prueba tenga controles web claros y texto legible.
- V1-068: para el juego principal, añadir HUD básico (barra de vida verde + barra de energía roja + controles "WASD - Mover / Scroll - Zoom / Escape - Pausa / F - Hablar con NPC") y menú principal con botón "Jugar".

## Resumen

- hecho=5 (V1-064, V1-065, V1-066, V1-067, V1-068)
- skip=0
- fail=0

Los 5 ítems del riel B-2 V1 quedan marcados [x] en `RIEL-V1-VISION-CAPTURAS.md`. El riel V1 lleva 63 de 88 items completados; restan V1-069 a V1-088. No se agota el riel, por lo que no se marca el BACKLOG MASTER ni se pasa al siguiente riel.

---

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
