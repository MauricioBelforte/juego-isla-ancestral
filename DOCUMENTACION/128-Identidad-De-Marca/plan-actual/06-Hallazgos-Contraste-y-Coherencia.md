# Módulo 128: Identidad de Marca — Hallazgos, Contraste y Coherencia

**Modelo:** Ling 3.1 Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 23:10 UTC
**Encargo:** mimo-v2.6 (Director) — msg 48 del canal Ling-3.1-Flash (lote documental M128)
**Ítem del checklist:** H.L149 "Documentar hallazgos y correcciones" + evidencia de L97/L146/L166/L167/L168

---

## 1. Hallazgos de contraste WCAG (test H3 de Hy3, 2026-10-11)

Hy3 implementó `tests/test_brand_contrast_m128.gd` (87 checks, 0 fallos). El test midió
todos los pares de la paleta oficial (M128 §3) y encontró pares **< 3.0** (umbral AA
para texto grande/UI):

| Par | Contraste | Veredicto |
|-----|----------|-----------|
| Carbón / Azul Bosque | 1.78 | ❌ no usar texto oscuro sobre Azul Bosque |
| Blanco Perla / Dorado Anciano | 1.95 | ❌ no usar texto claro sobre Dorado Anciano |
| Dorado Anciano / Cielo Claro | 1.01 | ❌ nunca como par texto/fondo |

### Combinaciones seguras verificadas (cálculo WCAG 2.1, esta sesión)

| Par | Contraste | Uso |
|-----|----------|-----|
| Blanco Perla / Azul Bosque | ≈6.9:1 | ✅ AA texto — texto claro sobre fondo Azul Bosque |
| Carbón / Dorado Anciano | ≈6.3:1 | ✅ AA texto — texto oscuro sobre acento Dorado Anciano |
| Carbón / Blanco Perla | alto (≈13:1) | ✅ texto principal sobre fondos claros |

### Restricciones de uso para el diseñador (M45/M46)

1. **No** texto oscuro (Carbón) sobre Azul Bosque → usar Blanco Perla (≈6.9:1).
2. **No** texto claro (Blanco Perla) sobre Dorado Anciano → usar Carbón (≈6.3:1).
3. **No** combinar Dorado Anciano con Cielo Claro como texto/fondo (1.01).
4. Números/acentos grandes (≥24 px bold) sobre Azul Bosque pueden usar Dorado Anciano
   (≈3.5:1, cumple AA-large 3:1, **no** AA texto normal 4.5:1).

## 2. Auditoría de coherencia con otros módulos (sección J)

| Ítem | Módulo | Resultado | Evidencia |
|------|--------|-----------|-----------|
| L166 | M97 Steam Store Page | ✅ PASA | `97-Steam-Store-Page/plan-actual/03-Diseno.md` L88 (estilo: paleta cálida dorados/verdes/turquesas = secundarios M128 §3, tipografías M88, logo legible a tamaño pequeño), L96 (cierre: logo del juego + Coming Soon + wishlist), L116 ("todos los assets usan la identidad visual del juego: paleta, tipografía M88, logo aprobado") |
| L167 | M98 Trailer | ✅ PASA | `98-Trailer/plan-actual/03-Diseno.md` §2 L16-18 (logo + CTA en teaser/gameplay/lanzamiento), §7 L58 (miniatura con identidad visual de M99: logo + 1 plano fuerte). Colores: footage 100% real del juego (§3, RF4) + identidad visual M99 (que define la paleta oficial en su §9.1) |
| L168 | M99 Marketing | ✅ PASA | `99-Marketing/plan-actual/03-Diseno.md` §9 (Ling-3.1-Flash, 2026-10-11): paleta oficial (ítem 1.2), tipografías de marca (1.3), guía de uso de la identidad (1.5), plantillas de publicación (1.6), estilo de piezas (1.4) |
| L169 | M53 UI/UX | ⚠️ PARCIAL — queda `[ ]` | Tipografía SÍ: `theme_ux.gd` L23-25 carga Nunito + Fredoka One (fuentes de marca, M88). Paleta NO: `theme_ux.gd` L13-20 define una paleta pastel propia (arena/ocre/marrón/dorado suave) que **no** es la paleta oficial M128 §3 |
| L170 | M131 Créditos | ❌ NO PASA — queda `[ ]` | `131-Creditos/plan-actual` sin referencias a identidad de marca: `creditos.json` + `credits_manager.gd` son catálogo data-driven con contraste accesible, pero sin logo/paleta/tipografía de marca |

## 3. Brechas y correcciones (acciones con dueño)

1. **Paleta de la UI (M53):** `theme_ux.gd` L13-20 usa paleta pastel propia. Corrección:
   migrar las constantes `COLOR_*` a `BrandConfig.color()` (autoload existente, Hy3
   2026-10-11, `project.godot` L65). Dueño: M53.
2. **Nombres de paleta M99 ↔ M128:** M99 §9.1 define roles "océano / arena cálida /
   coral / niebla ancestral / tinta" (muestreados del arte de M45/M46); M128 §3 define
   Azul Bosque / Dorado Anciano / Blanco Perla. Alinear nombres cuando M45/M46 produzcan
   el arte. Dueño: M128 + M45/M46.
3. **App icon 512 vs 1024:** checklist/04-Codigo dicen 512×512; `03-Diseno.md` §2
   "Tamaño Mínimo" dice 1024×1024. Godot/Steam requieren 1024+. Dueño: M46.
4. **Contraste:** aplicar restricciones de la sección 1 en todo arte nuevo. Dueño: M45/M46.
5. **M131:** sin formato de marca en créditos. Dueño: M131.

## 4. Verificación de fuentes en builds (L97 / L146)

- 4 fuentes en `res://assets/fonts/`: `Nunito-Variable.ttf`, `Nunito-Regular.ttf`,
  `Nunito-Bold.ttf`, `FredokaOne-Regular.ttf`.
- `theme_ux.gd` L23-25 las carga por ruta (`PATH_FONT_BODY` / `PATH_FONT_BODY_BOLD` /
  `PATH_FONT_TITLE`) con `load_dynamic_font` (Godot 4.7).
- Godot 4 exporta por defecto todos los recursos bajo `res://` → las fuentes viajan en
  el build.
- **Conclusión:** fuentes de marca incluidas en builds ✅ (L97 y L146).

## 5. Auditoría de UI (L145)

- `theme_ux.gd` L13-20: paleta pastel (fondo arena `Color(0.95, 0.90, 0.82)`, acento
  ocre `Color(0.72, 0.55, 0.30)`, texto marrón `Color(0.25, 0.18, 0.12)`, highlight
  dorado suave `Color(0.85, 0.72, 0.35)`).
- **No** es la paleta oficial M128 §3 (Azul Bosque #2E5A4C / Dorado Anciano #D4A843 /
  Blanco Perla #F5F0E8).
- **L145 "Validar que UI del juego usa paleta de marca" → NO PASA.** Queda `[ ]` con
  dueño M53 (ver corrección 3.1).

**Firma:** Ling 3.1 Flash / Kilo Code — 2026-10-11 23:10 UTC
