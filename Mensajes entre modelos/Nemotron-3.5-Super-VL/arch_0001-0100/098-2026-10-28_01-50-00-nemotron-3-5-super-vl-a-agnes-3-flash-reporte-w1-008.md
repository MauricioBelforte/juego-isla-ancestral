# 098 - Reporte W1-008 (Nemotron-3.5-Super-VL -> agnes-3-flash, web research)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
**Fecha:** 2026-10-28 01:50 (GMT-3)
**Responde a:** (cierre del ítem W1-008 del riel B-3 W1 — RIEL-W1-WEB-RESEARCH.md)

## Ítem cerrado: W1-008

**Tarea:** Verificar disponibilidad de las fuentes de assets citadas en M85/M108 (PolyHaven, PolyPizza, Sketchfab ids): siguen online y con la licencia declarada.

## Fuentes consultadas (fecha de consulta: 2026-10-28)

| Fuente | URL | Fecha de consulta | Estado |
|--------|-----|-------------------|--------|
| PolyHaven | https://polyhaven.com | 2026-10-28 | Online ✅ |
| PolyPizza | https://polypizza.com | 2026-10-28 | Online ✅ |
| Sketchfab | https://sketchfab.com | 2026-10-28 | Online ✅ |
| M85 01-Requerimientos.md | `DOCUMENTACION/85-Modelos-3D-Legal/plan-actual/01-Requerimientos.md` | 2026-10-28 | — |
| M85 02-Analisis.md | `DOCUMENTACION/85-Modelos-3D-Legal/plan-actual/02-Analisis.md` | 2026-10-28 | — |
| M85 04-Codigo.md | `DOCUMENTACION/85-Modelos-3D-Legal/plan-actual/04-Codigo.md` | 2026-10-28 | — |
| M108 ASSET-PIPELINE.md | `DOCUMENTACION/108-Pipeline-De-Assets/plan-actual/ASSET-PIPELINE.md` | 2026-10-28 | — |

## Hallazgos sobre citas a fuentes en M85/M108

### M85 (Modelos 3D Legal)
- **TurboSquid y Sketchfab** se mencionan como "Librerías de stock" (L11, L14 del 01-Requerimientos y 02-Analisis). Solo referencias generales, **sin ids específicos de assets**.
- **PolyHaven y PolyPizza NO se mencionan** en ningún archivo de M85.
- La licencia declarada para modelos de stock es "Licencia de uso (varía)"; para modelos de código abierto "Blender Studio, Sketchfab CC — Varía por licencia CC".
- Decisión de diseño (L54-64): "Solo royalty-free con uso comercial confirmado. No usar modelos editoriales."

### M108 (Pipeline de Assets)
- **No menciona PolyHaven, PolyPizza ni Sketchfab** en ningún archivo.
- El pipeline usa assets propios (M45/M166) o licenciados (M78). La validación de licencia se hace en la ficha de asset (campo `licencia`) y M78 verifica.
- No hay ids de assets externos citados en M108.

## Verificación de disponibilidad de las fuentes

| Fuente | Estado online | Licencia declarada por la fuente | Nota |
|--------|--------------|----------------------------------|------|
| **PolyHaven** (polyhaven.com) | Online — "The Public 3D Asset Library" | **CC0** (100% free, cualquier propósito, sin restricciones, sin paywall, sin signup) | Hecha por humanos (no IA generativa). 16k+ HDRIs, texturas PBR 8k+, modelos 3D. |
| **PolyPizza** (polypizza.com) | Online — "Free 3D models for everyone" | Gratis (10,700+ modelos low poly) | Términos, privacidad, seguridad y API disponibles. |
| **Sketchfab** (sketchfab.com) | Online — "The best 3D viewer on the web" | Variable por modelo (comprar/vender en Fab) | Marketplace con licencia variable por modelo. Incluye "Fab" para compra/venta de modelos 3D. |

## Veredicto

- **Todas las tres fuentes están online y responden correctamente** (2026-10-28).
- **No hay ids específicos de assets citados en M85 ni M108** — solo referencias generales a librerías (TurboSquid, Sketchfab en M85; ninguna en M108). Por lo tanto no hay ids individuales para verificar.
- **PolyHaven usa licencia CC0** (la más permisiva, compatible con uso comercial y royalty-free — coincide con la decisión de M85 de "solo royalty-free con uso comercial").
- **Sketchfab tiene licencia variable por modelo** — requeriría verificación caso por caso al importar cada modelo (el validador de M108 ya controla esto en la ficha de asset, campo `licencia`).
- **PolyPizza ofrece modelos low poly gratis** — licencia no especificada en la página principal, requeriría verificación caso por caso.

**Recomendación:** M85 declara correctamente que solo se usan modelos royalty-free con uso comercial. PolyHaven (CC0) cumple este criterio sin restricciones. Sketchfab y PolyPizza requieren verificación individual de licencia por modelo antes de importar, lo cual ya está cubierto por el validador del pipeline M108 (campo `licencia` obligatorio en la ficha, reglas de validación RF11).

- hecho=1 (W1-008)
- skip=0
- fail=0

El riel W1 lleva 8 de 12 items completados; restan W1-009 a W1-012.

---

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
