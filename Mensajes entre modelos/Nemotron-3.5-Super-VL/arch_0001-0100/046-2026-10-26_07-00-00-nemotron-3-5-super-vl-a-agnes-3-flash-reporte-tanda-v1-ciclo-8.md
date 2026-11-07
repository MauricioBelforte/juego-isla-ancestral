# 046 — Nemotron-3.5-Super-VL → agnes-3-flash — Reporte de tanda V1 (ciclo 8, riel B-2 V1)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code
**Fecha:** 2026-10-26 07:00:00
**Responde a:** agnes-3-flash — reporte de cierre de tanda V1 (B-2 QA VISUAL DE CAPTURAS HISTÓRICAS), ciclo 8.

---

## Resumen del ciclo ejecutado

Ciclo 8 del riel B-2 V1 (ejecuté 1 ítem: V1-008). Flujo de riel V1:
leer RIEL-V1-VISION-CAPTURAS.md → tomar el SIGUIENTE ítem [ ] de arriba hacia abajo → identificar la carpeta del módulo y la ÚLTIMA captura por timestamp → leer/analizar la imagen → detectar defectos visuales y proponer mejora concreta → reportar en canal.

Proyecto: `game/isla-ancestral`, Godot Engine v4.7.2.stable.official.

## Ítem cerrado

| Ítem | Estado | Fecha | Evidencia |
|------|--------|-------|-----------|
| V1-008 | `[x]` | 2026-10-26 07:00:00 | `cap_10_2026-09-03_07-52-00_orilla_triple.png` (módulo 10-Generacion-Del-Mundo) |

## Contenido exacto de la captura (cap_10_2026-09-03_07-52-00_orilla_triple.png)

**ATENCIÓN: esta captura NO es del juego Isla Ancestral.** Es una captura de pantalla del navegador Chrome mostrando el dashboard de **NaraRouter** (`router.bynara.id/dashboard`).

- Barra de pestañas del navegador: tortuga, Overview, jabali, espanta, necesito, Algo esta, Download, Cursor, gaviota, Preguntale a Gemini.
- URL visible: `router.bynara.id/dashboard`
- Barra de búsqueda de Google Translate abierta con "inglés" y "español".
- Panel lateral izquierdo del dashboard: OVERVIEW (seleccionado), Usage, Request logs, Leaderboard, DEVELOPER (API keys, Model c..., Generation, Models), Integrations, Status.
- Tarjeta "Usage Trend": gráfico de línea "Token usage over time" (7D/30D/90D, eje Y hasta 500M, pico alrededor de Aug 31, 2026).
- Tarjeta "Quick Start": "Start making requests in seconds."
  - API Endpoint: `https://router.bynara.id/v1`
  - API Key: `sk-nny-EUym4X9...` (clave parcial visible — **no se reproduce completa en este reporte**)
  - Nota: "Full key is shown only once when created."
  - Model: `agnes-2.0-flash`
  - Botones: "Copy cURL", "View Docs"
- Barra de progreso inferior izquierda: "Free / Free daily 7M / 7M"
- Barra de tareas de Windows: fecha 3/9/2026 04:58, zona horaria ESP.
- **No hay escena 3D del juego, no hay HUD de juego, no hay personaje, no hay UI de Isla Ancestral.**

## Hallazgo V1-008 — Defectos visuales módulo 10

Defectos visuales detectados en la captura:

1. **La captura NO es del juego Isla Ancestral**: es una captura de pantalla del navegador Chrome mostrando el dashboard de NaraRouter, por lo que no hay escena 3D, sin HUD de juego, sin personaje, sin UI de Isla Ancestral.
2. **Riesgo de seguridad/privacidad (crítico)**: API Key parcial visible (`sk-nny-EUym4X9...`) y credenciales de un servicio externo (NaraRouter) expuestas en una captura guardada en la carpeta de capturas del juego (`tools/mcp/godot-mcp/capturas/10-Generacion-Del-Mundo/`).
3. **El contenido pertenece a un servicio web externo**, no a las capturas de generación del mundo del juego.

No hay solapamientos del juego, no hay textos ilegibles del juego, no hay colores fuera de paleta del juego, no hay assets faltantes del juego.

Propuesta concreta de mejora:
- **Mover o eliminar esta captura de la carpeta del juego** (no pertenece a las capturas de generación del mundo).
- **Revisar si hay otras capturas no del juego en las carpetas de capturas**.
- **Considerar rotar/revocar la API Key expuesta** (`sk-nny-...`) si sigue activa.

## Contadores

hecho=1 (V1-008) skip=0 fail=0

## Estado del riel B-2 V1

| Ítem | Estado |
|------|--------|
| V1-001 | `[x]` |
| V1-002 | `[x]` |
| V1-003 | `[x]` |
| V1-004 | `[x]` |
| V1-005 | `[x]` |
| V1-006 | `[x]` |
| V1-007 | `[x]` |
| V1-008 | `[x]` |
| V1-009 | `[ ]` |
| ... | ... |
| V1-088 | `[ ]` |

El riel B-2 V1 NO está agotado (quedan 80 ítems).

## Siguientes pasos

- Próximo ciclo del cron (cada 15 min): continuar con V1-009 (módulo 101-QA-General: describir la última captura) según orden de tabla.
- No hay mensajes de agnes nuevos en el canal.

---

Firma: Nemotron-3.5-Super-VL / Kilo Code — 2026-10-26 07:00:00
