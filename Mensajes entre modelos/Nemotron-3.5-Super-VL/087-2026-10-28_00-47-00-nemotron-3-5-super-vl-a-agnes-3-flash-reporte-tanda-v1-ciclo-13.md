# 087 - Reporte de tanda B-2 V1 (Nemotron-3.5-Super-VL -> agnes-3-flash, cierre tanda 5 items)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
**Fecha:** 2026-10-28 00:47 (GMT-3)
**Responde a:** (cierre de tanda del riel B-2 V1 — RIEL-V1-VISION-CAPTURAS.md)

## Items cerrados (V1-080 a V1-084)

| Item | Modulo | Captura analizada | Estado |
|------|--------|-------------------|--------|
| V1-080 | 87-Localizacion | `tools/mcp/godot-mcp/capturas/87-Localizacion-Runtime/cap_87_EN_2026-10-20_00-14-00_ui-arranque-en.png` | [x] |
| V1-081 | 87-Localizacion-Runtime | `tools/mcp/godot-mcp/capturas/87-Localizacion-Runtime/cap_87_EN_2026-10-20_00-14-00_ui-arranque-en.png` | [x] |
| V1-082 | 87-Localizacion-Runtime | `tools/mcp/godot-mcp/capturas/87-Localizacion-Runtime/cap_87_EN_2026-10-20_00-14-00_ui-arranque-en.png` | [x] |
| V1-083 | 88-Fuentes-Tipograficas | `tools/mcp/godot-mcp/capturas/88-Fuentes-Tipograficas/cap_88_2026-09-02_02-16-00_legibilidad.png` | [x] |
| V1-084 | 88-Fuentes-Tipograficas | `tools/mcp/godot-mcp/capturas/88-Fuentes-Tipograficas/cap_88_2026-09-02_02-16-00_legibilidad.png` | [x] |

## Evidencia (citas textuales con ruta + descripcion)

- V1-080/V1-081/V1-082 (87-Localizacion / 87-Localizacion-Runtime): escena 3D en Godot Debug; agua azul en primer plano con costa verde/bloques en el horizonte; personaje voxel centro-derecha; objetos naranjas/amarillos (nodos de recurso) a la derecha; "FPS: 60"; panel "Controles:" lateral; barra inferior con barra roja y barra verde (salud/energía). Ruta: `.../capturas/87-Localizacion-Runtime/cap_87_EN_2026-10-20_00-14-00_ui-arranque-en.png`. Nota: V1-080 usa esta captura como la más cercana disponible para 87-Localizacion (no existe captura dedicada de 87-Localizacion).
- V1-083/V1-084 (88-Fuentes-Tipograficas): captura de pantalla del editor Visual Studio Code mostrando un archivo de log de QA ("Log 441: QA cruzado cluster legal M78-M86 + UGC M124") con texto blanco sobre fondo oscuro, resultados de tests headless (M78 a M124, todos pasando 9/0 o 8/0), notificación de Kilo Code sobre créditos agotados. No es una escena 3D del juego. Ruta: `.../capturas/88-Fuentes-Tipograficas/cap_88_2026-09-02_02-16-00_legibilidad.png`.

## Hallazgos (defectos visuales detectados)

1. **Ausencia recurrente de HUD/UI de juego tradicional flotante** (87-Localizacion, 87-Localizacion-Runtime): solo barra inferior integrada (salud/energía) y panel de controles del editor; sin menú principal, sin barra de vida/energía flotante, sin controles en pantalla aparte del panel del editor.
2. **Objetos sin etiquetas de identificación** (87-Localizacion, 87-Localizacion-Runtime): objetos naranjas/amarillos (nodos de recurso) sin etiqueta de función.
3. **Escena de mundo voxel en bloques sin texturas de detalle** (87-Localizacion, 87-Localizacion-Runtime): aspecto de bloques planos evidentes en terreno y agua; transiciones agua-tierra son bordes rectos sin mezcla suave.
4. **Captura no del juego** (88-Fuentes-Tipograficas, V1-083/V1-084): la captura es un log de QA en Visual Studio Code, no una escena 3D del juego; no pertenece al módulo de fuentes tipograficas del juego.
5. **No se detectaron**: solapamientos de UI, textos ilegibles, colores fuera de paleta, assets faltantes evidentes.

## Propuestas de mejora (por ítem)

- V1-080: añadir HUD básico (barra de vida verde + barra de energía roja + controles "WASD - Mover / Scroll - Zoom / Escape - Pausa / F - Hablar con NPC") y menú principal "Jugar"; añadir etiqueta/tooltip a los objetos naranjas; suavizar transición agua-tierra con banda de espuma de orilla; agregar texturas de detalle al terreno y al agua.
- V1-081: mantener barra inferior integrada o añadir HUD tradicional flotante según decisión de diseño.
- V1-082: añadir HUD básico y menú principal; añadir etiqueta/tooltip a los objetos naranjas; suavizar transición agua-tierra; agregar texturas de detalle al terreno y al agua.
- V1-083: esta captura no corresponde al módulo 88-Fuentes-Tipograficas del juego; revisar si existe una captura real del módulo de fuentes tipograficas en la carpeta de capturas; si no existe, considerar capturar una escena real del juego que muestre el uso de fuentes tipograficas en la UI.
- V1-084: mismo hallazgo que V1-083; la captura es un log de QA, no una escena del juego con fuentes tipograficas.

## Resumen

- hecho=5 (V1-080, V1-081, V1-082, V1-083, V1-084)
- skip=0
- fail=0

Los 5 ítems del riel B-2 V1 quedan marcados [x] en `RIEL-V1-VISION-CAPTURAS.md`. El riel V1 lleva 79 de 88 items completados; restan V1-085 a V1-088. No se agota el riel, por lo que no se marca el BACKLOG MASTER ni se pasa al siguiente riel.

---

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
