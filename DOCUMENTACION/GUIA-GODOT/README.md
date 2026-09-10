# GUIA GODOT — ÍNDICE

> **Modelo:** glm-5.3-flash
> **Plataforma:** Kilo Code
> **Fecha:** 2026-09-09
>
> Esta carpeta contiene la guía de Godot dividida en archivos temáticos. La
> guía principal (`DOCUMENTACION/07-GUIA-GODOT.md`) queda como respaldo e
> índice general — de a poco todo su contenido migrará a archivos individuales
> en esta carpeta.

---

## Archivos temáticos

| Archivo | Contenido | Estado |
|---|---|---|
| [`01-zoom-camara-personaje.md`](01-zoom-camara-personaje.md) | Cómo hacer el zoom de cámara correcto en el personaje (scroll, minimapa, cámara tercera persona) | ✅ Completo |
| [`02-disco-plano-verde.md`](02-disco-plano-verde.md) | Cómo crear un disco plano sólido con SurfaceTool (el "plato verde" sobre el agua) | ✅ Completo |
| [`03-impostores-terreno.md`](03-impostores-terreno.md) | Cómo crear impostores del terreno: heightmap completo + anti-tildes + anti-caída | ✅ Completo |

---

## Archivos previstos (a crear)

| Archivo | Contenido | Estado |
|---|---|---|
| `04-terreno-por-capas.md` | Receta del terreno por capas (agua clara/profunda, playa, montañas) | ⬜ Pendiente |
| `05-animales-bimodo.md` | Animales con dos modos: vuelo→tierra (caso gaviota M36) | ⬜ Pendiente |
| `06-objeto-blender-a-godot.md` | Flujo completo: traer un objeto animado de Blender a Godot (caso tortuga M36) | ⬜ Pendiente |
| `07-terrainlocator.md` | Estrategia anti-flotamiento con TerrainLocator (servicio central) | ⬜ Pendiente |
| `08-paleta-maldivas.md` | Paleta "Maldivas" aprobada + directiva colores por isla | ⬜ Pendiente |
| `09-generacion-isla-10x.md` | Escalado de mundos: isla 10×, mundo 5120×5120, spawns | ⬜ Pendiente |

---

## Reglas de esta carpeta

1. Cada archivo es **autocontenido**: explica el tema de punta a punta con
   código de ejemplo probado.
2. Todo código de ejemplo **debe estar validado en juego** — no teoría.
3. Cada archivo registra **los errores cometidos** y cómo evitarlos (la parte
   más valiosa de la guía).
4. La guía principal (`07-GUIA-GODOT.md`) mantiene las lecciones E-01 a E-19
   (registro de errores) — los archivos de esta carpeta las referencian.
5. Cuando un tema de la guía principal se migre acá, se deja en la principal
   una referencia a este archivo (no se borra el contenido).
