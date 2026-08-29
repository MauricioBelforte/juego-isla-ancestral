**Modelo:** Hy3
**Plataforma:** Kilo

# 168 — Plantilla de Isla (Maqueta)

## Propósito
Este módulo es la **MAQUETA / PLANTILLA genérica** para crear un módulo de una isla nueva.
**No contiene el terreno de ninguna isla en concreto** — es un formato vacío que copias,
completas con los datos de tu isla, y renombras.

## Cómo crear un módulo de isla nueva (paso a paso)
1. **Reservar el ID**: el siguiente ID libre en `CHECKLIST-GLOBAL.md` (ej. 169).
2. **Copiar esta carpeta** → `DOCUMENTACION/<ID>-Isla-<Nombre>`. Ej: `169-Isla-Volcanica`.
3. **Renombrar** todos los títulos `168 Plantilla` → `<ID> Isla <Nombre>`.
4. **Completar** los 5 archivos con los datos de TU isla (ver secciones abajo).
5. **Registrar** la fila en `CHECKLIST-GLOBAL.md` y en `DOCUMENTACION/README.md`.

## Estructura de la plantilla
| Archivo | Qué completar |
|---|---|
| `01-Requerimientos.md` | Problema/objetivos de la isla, restricciones |
| `02-Analisis.md` | Análisis del terreno/isla, decisiones |
| `03-Diseno.md` | **Fuente de verdad**: config del terreno, mapa de posiciones, recovery |
| `04-Codigo.md` | Archivos involucrados, configuración exacta |
| `05-Checklist.md` | 100+ ítems de la isla |

## Reglas (heredadas de la jornada 2026-08-29)
- **Cada isla = su propio módulo** (un agente que toque una isla no rompe las demás).
- El terreno ideal es una isla de radio ~256 (se ve el plato de arena, la montaña y el agua).
- El centro de la isla es `(island_radius, island_radius)`.
- Se posicionan objetos con `get_height(x, z)` — nunca con Y fija.
- Ver detalle completo en el módulo real `167-Isla-Raiz` (ejemplo resuelto).

## Ejemplos de islas futuras (para cuando apliquen)
- `169-Isla-Volcanica` (M164 menciona isla de combate endgame)
- Islas de biomas alternativos (paleta propia por isla — directiva 10.13)
- Islas de eventos/festivales (M73)
