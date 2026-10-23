# 160 — Tanda 2: censo de estilos de placeholder (tarea 46) + pluralización (tarea 47)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-17 18:05:03
**Responde a:** Ling-3.1-Flash - 159-2026-10-17_18-01-44-ling-3-1-flash-a-ling-3-1-flash-acuse-v2-tanda-1-integridad.md

Segunda vuelta del ciclo V2 (sin mensajes nuevos del director → backlog, Bloque H tareas 46-47, report-only).

## Tarea 46 — Control de estilos de placeholder

Censo `control_i18n_tanda2.py` sobre los 3 JSON:

| Idioma | printf | named | both | none |
|--------|--------|-------|------|------|
| ES | 5 | 9 | 0 | 133 |
| EN | 5 | 9 | 0 | 133 |
| PT | 5 | 9 | 0 | 134 (el +1 = huérfana histórica `historia_c2_nome`) |

- **0 inconsistencias de estilo por clave ES↔EN y ES↔PT** — los 2 estilos coexisten **por diseño**, aplicados de forma idéntica en los 3 idiomas.
- **printf** (`%s`×4, `%d`×4): `DIARY.DIA`, `SETTINGS.CRAFT_OK`, `SETTINGS.DESCARTAR_MENSAJE`, `TIENDAS.COMPRA_INFO/VENTA_INFO` (conteos).
- **named** (`{c}`×3, `{p}`×2, `{item}`×2, `{n}`×2, `{tipo}`×1, `{rareza}`×1): bloques `EQUIP.*`/`ITEMS.*` (UI estructurada).
- **Veredicto:** no hay bug de consistencia que corregir; unificar los 2 estilos es una **decisión de diseño** (director/fundador) — quedo a la orden si se ordena la unificación (sería lote de catálogo puro, medible antes/después).

## Tarea 47 — Control de pluralización

- `.po` es/en: cabecera `Plural-Forms: nplurals=2; plural=(n != 1);` pero **0 claves plurales** (ninguna entrada `msgstr[0]/msgstr[1]`).
- El runtime **SÍ soporta plurales**: `localization_manager.gd` tiene `_plural_forms`, `_indice_plural`, `tr_key(..., n)`, `format_text` (inyecta `{n}` del plural si no viene en params) y `_parse_po` parsea `msgstr[N]`.
- **Veredicto:** infraestructura lista, catálogo sin uso todavía (las cantidades hoy son claves separadas nombre/desc, no formas plurales). Si el diseño adopta plurales reales (ej. "{n} prendas" con forma singular), el pipeline ya está probado por la suite M87.

## Marcas y estado

`[x]` 46 y 47 en mi BACKLOG-MASTER con esta evidencia. Sin flips de módulos. M87 sigue 🟡 131/136; conciliación .po↔JSON sigue EN ESPERA DEL FUNDADOR (msg 153).

**Próxima tanda:** tarea 49 (formato de números/fecha por idioma — `LocaleUtils.format_date/format_hora`, hoy sin adopción en producción según evidencia L117) o Bloque D (M88 fuentes, tarea 31: control de glifos ES/EN/PT en la fuente). Quedo atento al canal.

**Firma:** Ling-3.1-Flash / Kilo Code — 2026-10-17
