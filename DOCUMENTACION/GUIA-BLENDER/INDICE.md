# GUIA BLENDER — ÍNDICE DE TEMAS

> **Modelo:** MiMo V2.5
> **Plataforma:** OpenCode
> **Fecha:** 2026-09-10
>
> Esta carpeta contiene la guía de Blender dividida en archivos temáticos.
> La guía original completa se conserva en `../OBSOLETOS/09-GUIA-BLENDER.md`
> como respaldo histórico.

---

## Archivos temáticos

### Fundamentales (01-05)

| # | Archivo | Contenido | Estado |
|---|---|---|---|
| 01 | [`01-conexion-mcp-convenciones.md`](01-conexion-mcp-convenciones.md) | Conexión MCP V5, herramientas reutilizables, convenciones bpy, tabla de alturas objetivo | ✅ |
| 02 | [`02-errores-comunes-e01-e35.md`](02-errores-comunes-e01-e35.md) | Errores comunes E-01 a E-35: tronco escalonado, imports, captura, parenteo, apoyo, decimate, slots | ✅ |
| 03 | [`03-scripts-reutilizables-helpers.md`](03-scripts-reutilizables-helpers.md) | Helpers: `plantilla_asset.py`, `loft()`, `prisma()`, `revolucion()`, `tubo_arco()`, `herramienta_util.py`, `hoja_util.py`, `montado_util.py` | ✅ |
| 04 | [`04-errores-avanzados.md`](04-errores-avanzados.md) | Errores avanzados E-36 en adelante: presupuesto, winding, variantes, export, import, animales bimodo | ✅ |
| 05 | [`05-checklist-asset.md`](05-checklist-asset.md) | Checklist antes de dar por terminado un asset (40+ ítems verificables) | ✅ |

### Específicos del juego (06-10)

| # | Archivo | Contenido | Estado |
|---|---|---|---|
| 06 | [`06-capturas-ordenes.md`](06-capturas-ordenes.md) | Capturas, órdenes de creación, checklist maestro de objetos, estructura de carpetas por módulo | ✅ |
| 07 | [`07-set-captura-vs-asset.md`](07-set-captura-vs-asset.md) | Set de captura vs. Asset: qué viaja a Godot y qué no, comparativa con flujo profesional | ✅ |
| 08 | [`08-asset-animable-godot.md`](08-asset-animable-godot.md) | Requisitos del asset para ser animado en Godot: reglas, errores fatales, checklist | ✅ |
| 09 | [`09-nivel-detalle-modelado.md`](09-nivel-detalle-modelado.md) | Nivel mínimo de detalle en el modelado: tapas planas, matrix_world, curvas cuerda | ✅ |
| 10 | [`10-animales-bimodo.md`](10-animales-bimodo.md) | Animales con dos modos de comportamiento: principios, anatomía, flujo, errores fatales | ✅ |

---

## Reglas de esta carpeta

1. Cada archivo es **autocontenido**: explica el tema de punta a punta con
   código de ejemplo probado.
2. Todo código de ejemplo **debe estar validado en Blender** — no teoría.
3. Cada archivo registra **los errores cometidos** y cómo evitarlos (la parte
   más valiosa de la guía).
4. La guía original completa se conserva en `../OBSOLETOS/09-GUIA-BLENDER.md`
   como respaldo histórico con las lecciones E-01 en adelante.
5. Cuando un tema de la guía original se migre acá, se actualiza esta
   referencia (el archivo original se mueve a OBSOLETOS/).

---

## Mapeo de secciones de la guía original → archivos

| Sección original | Archivo(s) en GUIA-BLENDER/ |
|---|---|
| §1 — Conexión con Blender (V5) | `01-conexion-mcp-convenciones.md` |
| §2 — Convenciones de código bpy | `01-conexion-mcp-convenciones.md` |
| §2.5 — Tabla de alturas objetivo | `01-conexion-mcp-convenciones.md` |
| §3 — Registro de Errores (E-01 a E-35) | `02-errores-comunes-e01-e35.md` |
| §3 — Scripts reutilizables (plantilla_asset, helpers) | `03-scripts-reutilizables-helpers.md` |
| §3 — Registro de Errores (E-36 en adelante) | `04-errores-avanzados.md` |
| §4 — Checklist antes de dar por terminado | `05-checklist-asset.md` |
| §5 — Caso de estudio: palmera lowpoly | `06-capturas-ordenes.md` |
| §6 — Directivas de Orden de Creación y Capturas | `06-capturas-ordenes.md` |
| §7 — Set de captura vs. Asset | `07-set-captura-vs-asset.md` |
| §8 — Requisitos del asset animable | `08-asset-animable-godot.md` |
| §9 — Nivel mínimo de detalle | `09-nivel-detalle-modelado.md` |
| §10 — Animales bimodo | `10-animales-bimodo.md` |

---

## Errores documentados por archivo

| Archivo | Errores cubiertos |
|---|---|
| `02-errores-comunes-e01-e35.md` | E-01 a E-35 |
| `04-errores-avanzados.md` | E-36 en adelante |

**Total:** 105 errores documentados (E-01 a E-105).

---

## Relación con GUIA-GODOT

La guía Blender es **complementaria** a la guía Godot (`DOCUMENTACION/GUIA-GODOT/`):

| Tema | GUIA-BLENDER | GUIA-GODOT |
|---|---|---|
| Pipeline de creación de assets | `01-conexion-mcp-convenciones.md` | `11-blender-godot.md` |
| Errores de exportación glTF | `04-errores-avanzados.md` (E-44, E-45) | `11-blender-godot.md` |
| Animales bimodo (Blender) | `10-animales-bimodo.md` | `12-animales-bimodo.md` (Godot side) |
| Nivel de detalle orgánico | `09-nivel-detalle-modelado.md` | — |
| Optimización de assets | `05-checklist-asset.md` | `05-checklist-referencias.md` |
