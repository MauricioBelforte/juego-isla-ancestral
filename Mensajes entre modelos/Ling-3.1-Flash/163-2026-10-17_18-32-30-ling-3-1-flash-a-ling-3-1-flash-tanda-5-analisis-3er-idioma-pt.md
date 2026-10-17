# 163 — Tanda 5: análisis de esfuerzo para el 3er idioma (tarea 48) — insumo PT

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-17 18:32:30
**Responde a:** Ling-3.1-Flash - 162-2026-10-17_18-22-56-ling-3-1-flash-a-ling-3-1-flash-tanda-4-sufijos-idioma-pt-huerfano.md

Vuelta del cronómetro V2: sin mensajes nuevos del director → backlog (§2), Bloque H tarea 48 (control/insumo para la decisión de scope multilingüe).

## Análisis de esfuerzo para PT como 3er idioma

**Contexto (Tanda 4):** el catálogo PT existe en JSON (148 claves, paridad 0/1 con ES) pero es huérfano en runtime (`LOCALES_SOPORTADOS := ["es","en"]`).

1. **Catálogo `locales/pt.po` (236 msgids):**
   - 121 claves → traducción PT YA existe en `strings_pt.json` (aprovechable, medición Tanda 1).
   - 115 claves → solo existen en `.po` (bloque M68 transporte ~85, `DIARY.CAT_*` 17, `CLOCK.ESTACIONES` 4, `HUD.VIDA`, `ITEMS.MADERA(_DESC)`, `MAIN_MENU.OPTIONS`, `SETTINGS.IDIOMA`, `UI.INTERACTUAR`, `npc.catalina`, `DIALOGOS.VECINO_SALUDO`) → traducir ES→PT nuevo.
2. **Código (2 líneas):** `LOCALES_SOPORTADOS := ["es","en","pt"]` (`localization_manager.gd` L15) + tabla pt y `NOMBRES_NATIVOS["pt"]` en `locale_utils.gd` (GAP de la Tanda 3).
3. **Glosario M87:** `glosario.json` `"idiomas": ["es","en"]` → añadir `"pt"` + campo `"pt"` en los 17 términos (consistencia terminológica ES/EN/PT).
4. **Fuentes M88:** PT añade **7 caracteres no-ASCII exclusivos** (U+00E0 à, U+00E2 â, U+00E3 ã, U+00E7 ç, U+00EA ê, U+00F4 ô, U+00F5 õ) — ES tiene 10 (¡ ¿ Á á é í ó ú — …), EN 3 (Á — …). Verificar cobertura de la fuente (`test_fuentes_reales_m88.gd`: `validar_cobertura_idiomas(["es","en"])` → extender a pt).
5. **Tests:** `locales_disponibles().size() == 3` (`test_localization.gd:75` hoy ==2; `test_localizacion_iter2.gd:144` "es+en disponibles").

## Dependencia crítica

Toca la **conciliación .po↔JSON bloqueada por el fundador (msg 153)**: si el runtime migra de .po a JSON (o viceversa), el trabajo de pt cambia (en escenario JSON-pt, `strings_pt.json` YA es el catálogo completo y solo haría falta el switch de runtime). El orden de operaciones lo define esa decisión.

**Decisión de scope = director/fundador** — este análisis es el insumo. Pendiente relacionado: huérfana PT `historia_c2_nome` (tarea 16, rename).

## Estado

Tarea 48 marcada [x] en BACKLOG-MASTER. Sin cambios fuera de mi nicho. Próxima tanda: Bloque I (tarea 51, log de iteración del frente) o lo que ordene el director.

**Firma:** Ling-3.1-Flash / Kilo Code — 2026-10-17
