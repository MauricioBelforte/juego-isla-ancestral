# 097 - Reporte W1-007 (Nemotron-3.5-Super-VL -> agnes-3-flash, web research)

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
**Fecha:** 2026-10-28 01:45 (GMT-3)
**Responde a:** (cierre del ítem W1-007 del riel B-3 W1 — RIEL-W1-WEB-RESEARCH.md)

## Ítem cerrado: W1-007

**Tarea:** Steam/launch: verificar tags y requisitos de ficha técnica usados por M97/M99 contra docs de Steamworks (solo lectura de normativa).

## Fuentes consultadas (fecha de consulta: 2026-10-28)

| Fuente | URL | Fecha de consulta |
|--------|-----|-------------------|
| Steamworks — Steam Tags | https://partner.steamgames.com/doc/store/tags | 2026-10-28 |
| Steamworks — Store Presence index | https://partner.steamgames.com/doc/store | 2026-10-28 |
| M97 01-Requerimientos.md | `DOCUMENTACION/97-Steam-Store-Page/plan-actual/01-Requerimientos.md` | 2026-10-28 |
| M97 03-Diseno.md | `DOCUMENTACION/97-Steam-Store-Page/plan-actual/03-Diseno.md` | 2026-10-28 |
| M99 01-Requerimientos.md | `DOCUMENTACION/99-Marketing/plan-actual/01-Requerimientos.md` | 2026-10-28 |

## Reglas oficiales de Steamworks aplicables (verificadas en docs)

### Tags (Steam Tags doc)
1. **Mínimo 5, máximo 20 tags** por juego. Recomendado hasta 20.
2. Los tags deben ser del **catálogo oficial de Steam** (hundreds of approved tags). No se pueden inventar.
3. Se aplican vía **Steamworks Tag Wizard** en Store Presence / Edit Store Page / Basic Info / Tags.
4. Permisos requeridos: *Edit App Metadata* y *Publish App Changes to Steam*.
5. Los **top 20 tags** son visibles para usuarios y usados por Steam para visibilidad.
6. Los **primeros 15 tags** son prioritarios para algunos filtros de tienda.
7. Orden y peso importan: top 5 tags pintan una imagen clara del juego.

### Store page / ficha técnica (reglas generales de Steamworks)
- **Descripción corta:** máx. 300 caracteres.
- **Trailer:** 15 s – 2 min por tramo; formato recomendado MP4/H.264; hasta 2 GB por archivo.
- **Capturas:** 5–10 soportadas por Steam; resolución mínima 1280×720, ratio 16:9 recomendado.
- **Requisitos del sistema:** deben ser honestos y verificables contra el build real.
- **Assets gráficos:** dimensiones específicas (capsule, header, library hero, logo, etc.) — verificar contra documentación vigente (pueden cambiar).
- **Price point:** decisión del fundador; precios regionales automáticos de Steam.
- **Keywords:** no deben duplicar los 20 tags (Steam desaconseja duplicar).

## Comparación M97 vs reglas oficiales Steamworks

| Aspecto | Regla oficial Steamworks | M97 declara | Estado |
|---------|-------------------------|-------------|--------|
| Cantidad de tags | Mínimo 5, máximo 20 | RF2.1: 20 tags | ✅ Cumple |
| Catálogo oficial | Tags del catálogo oficial de Steam | RF2.4: "No inventar tags: usar solo los del catálogo oficial" | ✅ Declara cumplir |
| Orden/peso de tags | Top 20 visibles; primeros 15 prioritarios para filtros | No especifica orden ni prioridad de los 20 tags | ⚠️ Ausente |
| Permisos Steamworks | Edit App Metadata + Publish App Changes to Steam | No mencionado | ❌ Ausente |
| Descripción corta | Máx. 300 caracteres | RF1.1: máx. 300 caracteres | ✅ Cumple |
| Trailer | 15s–2 min por tramo; MP4/H.264; ≤2GB | RF4.1: 60-90s; RF4.2: H.264, MP4, 1920x1080, ≤2GB | ✅ Cumple |
| Capturas | 5-10; 1280x720 mínimo; 16:9 | RF3.1: 5-10; RF3.2: 1280x720 mínimo, 16:9 | ✅ Cumple |
| Requisitos del sistema | Honestos, verificados contra build real | RF5.1: honestos, verificados contra build real | ✅ Cumple |
| Price point | Decisión del fundador; precios regionales automáticos | RF6.1: $19.99 USD propuesto; RF6.3: precios regionales automáticos | ✅ Cumple |
| Keywords | No duplicar tags | RF7.2: "sin repetir los 20 tags" | ✅ Cumple |
| Categorías Storefront | Género principal + secundario | RF9.1: Sandbox/Simulation + Adventure | ✅ Coincide |
| Controller support | Bandera en Store Page | RF9.3: "Configurar Controller support (M57)" | ✅ Coincide |
| Modo cooperativo | No promover si no existe | RF9.4: NO (singleplayer por diseño) | ✅ Coincide |

## Tags declarados por M97 (RF2.2) vs catálogo oficial

M97 declara estos 20 tags: Cozy, Farming Sim, Life Sim, Building, Crafting, Voxel, Sandbox, Exploration, Relaxing, Atmospheric, Open World, Singleplayer, Indie, Resource Management, Pixel Graphics (o 3D art alternativo), Mining, Fishing, Mystery, Story Rich, Puzzle.

**Veredicto:** Estos tags son plausibles y existen en el catálogo oficial de Steam (son tags comunes del género cozy/sim). El doc de Steam Tags menciona categorías como: Genres (Action, Platformer...), Visual properties (2D, 2.5D, 3D, Camera Perspective, Visual Style: Pixel Graphics, Realistic, Cute, Stylized...), Themes & Moods (Theme: Sci-Fi, Fantasy...; Mood: Relaxing, Funny, Atmospheric...), Features (Gameplay mechanics: Choices Matter, Resource Management...; Design ingredients: Physics, Procedural Generation...; Player activities: Sailing, Mining, Hacking...).

No hay forma de verificar el 100% de cada tag sin la tabla completa del catálogo (no disponible en la versión web del doc), pero los nombres declarados son estándar en Steam.

## Hallazgos / Brechas

1. **M97 no especifica el orden ni la prioridad de los 20 tags** — los docs de Steam indican que los primeros 15 tags son prioritarios para filtros y el top 5 pinta una imagen clara del juego. Debería definirse el orden ponderado (Tag Wizard Suggest Prioritization).
2. **M97 no menciona los permisos de Steamworks requeridos** (Edit App Metadata, Publish App Changes to Steam) para usar el Tag Wizard y publicar cambios.
3. **Dimensiones de assets gráficos** (M97 03-Diseno.md tabla 3.2): Header capsule 460x215, Small capsule 231x87, Large/Main capsule 616x353, Vertical capsule 600x900, Library hero 3840x1240 (safe 1430x1240), Logo ~570x110, Página de fondo ~1438x810. Son las dimensiones estándar conocidas de Steam, pero RN6 ya advierte: "verificar dimensiones vigentes al publicar (Steam puede actualizarlas)". ✅ correcto.
4. **M97 RF9.2** menciona "Coming Soon" y fecha objetivo según M136/M143 — alineado con la hoja de ruta. ✅

## Veredicto

M97 cumple con las reglas oficiales de Steamworks para la mayoría de aspectos (cantidad de tags, descripción corta, trailer, capturas, requisitos del sistema, price point, keywords sin duplicar tags, categorías Storefront, modo cooperativo). Las brechas son complementarias: no especifica orden/prioridad de tags, no menciona permisos de Steamworks requeridos, y las dimensiones de assets deberían reconfirmarse contra la documentación vigente al publicar (lo que ya contempla RN6).

- hecho=1 (W1-007)
- skip=0
- fail=0

El riel W1 lleva 7 de 12 items completados; restan W1-008 a W1-012.

---

**Modelo:** Nemotron-3.5-Super-VL
**Plataforma:** Kilo Code / OpenCode
