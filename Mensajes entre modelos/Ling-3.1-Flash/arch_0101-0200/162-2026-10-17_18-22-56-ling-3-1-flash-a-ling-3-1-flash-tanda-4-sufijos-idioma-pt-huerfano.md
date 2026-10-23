# 162 — Tanda 4: control de sufijos de idioma (tarea 50) — PT huérfano en runtime

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-17 18:22:56
**Responde a:** Ling-3.1-Flash - 161-2026-10-17_18-16-04-ling-3-1-flash-a-ling-3-1-flash-tanda-3-formatos-locale-timecalendar.md

Vuelta del cronómetro V2: sin mensajes nuevos del director → backlog (§2), Bloque H tarea 50 (control report-only).

## Control de sufijos (es/en/pt) por sistema

| Sistema | Archivos | Estado |
|---------|----------|--------|
| JSON `data/localizacion/` | `strings_{es,en,pt}.json` | **3/3 sistemático** (147/147/148 claves) |
| `.po` `locales/` | `es.po`, `en.po` | **2/2 sistemático** — coherente con el runtime |
| Otros | outputs de test en `Godot/app_userdata/` (m87_val_ex*_*.po) | no versionados |

## HALLAZGO (tarea 50): `strings_pt.json` es HUÉRFANO en runtime

- Runtime M87 (autoload "Localization", `scripts/localization/localization_manager.gd`):
  - L15: `LOCALES_SOPORTADOS := ["es", "en"]` — **solo 2 idiomas en runtime**.
  - `_cargar_catalogos` (L35-42): lee `res://locales/{locale}.po` → solo es.po/en.po. **pt.po no existe**.
  - `set_locale("pt")` → RECHAZADO con warning (L98-101).
  - `_sugerir_locale_so` (L77-81): un jugador con SO en portugués no recibe sugerencia de pt.
  - `get_locale_display_name` → `LocaleUtils.get_nombre_nativo` (solo es/en — Tanda 3).
- Tests lo afirman: `test_localization.gd:75` "2 idiomas soportados"; `test_localizacion_iter2.gd:144` "es+en disponibles (selector M53/M110)".
- `strings_pt.json` (148 claves, paridad 0/1 con ES — Tanda 1) **no lo lee NINGÚN código de producción**: el sistema JSON-autoload fue eliminado por bug104 (2026-10-08); hoy solo tests M74 lo usan como fuente de datos.
- **Impacto jugador: el juego NO se puede jugar en portugués** pese a tener el catálogo PT completo y versionado.

## Ruta para habilitar PT (decisión director/fundador)

1. Crear `locales/pt.po` (236 msgids — el contenido ya existe en `strings_pt.json`: 121 claves comunes + 25 solo-JSON normalizadas, Tanda 1), o
2. Extender `_cargar_catalogos` para leer JSON como fuente de pt.
- Toca la conciliación .po↔JSON actualmente bloqueada por el fundador (msg 153, opciones A/B/C) — coordinar con esa decisión.
- Bloque I pendiente relacionado: tarea 48 (scope del 3er idioma).

## Estado

Tarea 50 marcada [x] en BACKLOG-MASTER con esta evidencia (nota: el texto original de la tarea dice "sufixes", preservado). Sin cambios fuera de mi nicho. Próxima tanda: tarea 48 (scope 3er idioma — análisis/insumo para el director) o lo que ordene el director.

**Firma:** Ling-3.1-Flash / Kilo Code — 2026-10-17
