# Guía de Estilo Arte 2D (ART_STYLE_2D) — M46

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-06

> RF1 — Guía de estilo 2D heredada del 3D (M45). Permite dibujar sin preguntar.

## 1. Identidad visual

El juego es cozy: **paleta pastel amable**, formas redondeadas, luz cálida. El arte 2D debe sentirse
hermano del 3D lowpoly de la Isla Raíz: mismo lenguaje de color, misma suavidad.

## 2. Paleta pastel (referencia)

| Rol | Color | Hex |
|---|---|---|
| Base cálida | Arena clara | `#F2E3C6` |
| Madera | Marrón suave | `#A9815C` |
| Vegetación | Verde pastel | `#8FBC8F` |
| Agua | Turquesa suave | `#7FC8C0` |
| Acento coral | Rosa coral | `#F49E9E` |
| Ceniza | Gris cálido | `#9C9C9C` |
| Aurora | Celeste ancestral | `#A8D8EA` |
| Dorado ancestral | Oro apagado | `#E8C97A` |

## 3. Trazo y sombreado

- **Trazo exterior redondeado** 2-3 px a resolución de trabajo 128 px (proporcional en 256).
- **Sombra plana inferior** al 10% de oscuridad (sin gradiente).
- **Prohibido:** gradientes complejos, ruido, texturas fotográficas, neón, contornos duros negros.
- Ángulo canónico de iconos de objetos: **3/4**, generado desde la plantilla 3D de M45.

## 4. Familias y recetas visuales

| Familia | Prefijo | Receta |
|---|---|---|
| Iconos de objeto (M14/M15) | `ico_` | objeto centrado al 80%, fondo transparente, marco de rareza M38 al 100% |
| Iconos de herramienta (M13/M158) | `ico_herr_` | mango madera + cabeza por material (cobre/hierro/oro/cristal); T4 con símbolo ancestral |
| Retratos (M19/M20) | `pt_` | render 3D del modelo como base + repintado; busto 3/4, fondo plano de color del NPC |
| UI (M53/M57) | `ui_art_` | paneles slice9 con esquinas 8 px, estados normal/hover/pressed/disabled |
| Símbolos (M22/M25/M26) | `sym_` | geometría suave reutilizable, cero palabras |
| Mapas (M25/M54) | `illus_` | pergamino con safe zone central para UI |
| Insignias (M72/M22/M37) | `badge_` | círculo + figura + borde de rareza |
| Ilustraciones (M63) | `illus_` | 1024×1024, área de texto libre inferior |
| Logo (RF2) | `logo_` | principal + variante clara/oscura + icono solo; submarca plataformas (M97) |

## 5. Expresiones de retratos

Base: `base`, `alegre`, `triste`, `sorprendido`, `pensativo`.
NPCs románticos (M20): + `coqueteo`, `sonrojado`, `corazon` (3 extra).
Sufijo de variante: `pt_<npc>_<expresion>` (ej: `pt_npc_riz_001_alegre`).

## 6. Tamaños y legibilidad

- Iconos: trabajo **128×128**, prueba de legibilidad **obligatoria a 32 px**.
- Retratos: **256×256**, prueba a 96 px.
- Ilustraciones/mapas: **1024×1024** con área de texto libre.
- Insignias: grande 100 px, pequeña 48 px.

## 7. Formato y pipeline (M108)

- Fuente editable: **SVG** (Inkscape/Krita); renders 3D desde Blender.
- Runtime: **PNG/WebP**; múltiples de 4; alfa limpio sin halos.
- Atlas por superficie (RF12): `ui_atlas`, `icons_atlas`, `portraits_atlas`, `story_atlas`, `badges_atlas`;
  máximo **2048×2048**, padding ≥ 2 px, sin rotaciones, regeneración por `pack_atlas.gd`.
- Carga diferida (M63), sin duplicados en memoria (M62).
- **Cero texto embebido** (regla dura): toda la texto lo superponen M87/M88 con fuentes M88.

## 8. Validación

- Script: `res://scripts/arte2d/validar_arte_2d.gd` (headless).
- Verifica: naming convention (prefijos §4), formato PNG/WebP/SVG, múltiplo de 4, cuadrado
  para iconos/retratos, alfa sin halos en bordes, duplicados, cobertura contra
  `data/arte2d/inventario_2d.json`.
- Rechaza la pieza si falla cualquiera: el pipeline M108 no la incluye.

## 9. Flujo de trabajo

1. **Icono de objeto:** plantilla 3D (M45) → render → ilustrar SVG/PNG → validar → atlas.
2. **Retrato:** render del modelo 3D → repintado → 5 expresiones base (+3 románticos) → validar → atlas.
3. **Empaquetado:** `pack_atlas.gd` por superficie, límite 2K, padding 2 px, sin rotación.
4. **Revisión:** comparación lado a lado con el modelo 3D (coherencia M45).
5. **IA como base (M86):** permitida solo como base/inspiración con repintado obligatorio
   sobre la plantilla 3D; nunca arte IA directo sin repintar (incoherencia + trazabilidad).

## 10. Desfase de numeración

La sección "ARTE 2D" del plan maestro inicial es la **45**; el ID en CHECKLIST-GLOBAL.md es **46**
(mapeo documentado aquí y en el checklist §X).
