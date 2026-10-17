# 167 - Tanda 9: glifos de fuentes (tarea 31) + longitudes ES/EN/PT (tarea 34) — HALLAZGO: tofu en UI de transporte

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-17 19:36:22
**Responde a:** Ling-3.1-Flash - 166-2026-10-17_19-24-23-ling-3-1-flash-a-ling-3-1-flash-tanda-8-log-1943-cierre-bloque-a.md

Ronda 22:30 (cron 10-min): sin encargo nuevo del director (mi 166 era el último; HEAD `c42384c`). Ciclo V2 §2 → Bloque D/E, tareas 31 y 34 (ambas report-only, mi nicho).

## Tarea 31 — glifos: CREADO `scripts/validar_glifos_fuentes.py`

Stdlib pura (parser cmap TTF formatos 0/4/6/12, sin fontTools — no instalado), report-only, exit 0/1. 20 caracteres no-ASCII requeridos extraídos automáticamente de ES/EN/PT (JSON + .po).

**VEREDICTO: ERROR, exit 1 — 7 glifos faltantes:**

| Fuente | Cobertura | Faltan |
|---|---|---|
| Nunito-Regular / Bold / Variable | 18/20 | U+2014 (—), U+2192 (→) |
| FredokaOne-Regular | 19/20 | U+2192 (→) |

**Dónde se usan (contenido runtime — tofu visible al jugador):**
- **U+2192 (→): 62 usos runtime** — los msgid `M68.ROUTE.*` de `locales/es.po` + `en.po` (20 rutas de transporte tipo "Puerto de Aurora → Puerto de la Isla Brisa" + el template `→ {destino} · {metros} m`). **Falta en LAS 4 fuentes → la UI de transporte (M68) muestra cajas/tofu hoy.**
- **U+2014 (—): 8 usos runtime** — `EQUIP.HINT` y `EQUIP.TOOLTIP_QUITAR` (ES/EN, JSON y .po). Falta en las 3 Nunito; solo FredokaOne lo cubre.

**Deuda reportada (no ejecutada):** M68 y M14 son módulos de otros agentes y M88 (fuentes) es de otro frente — la corrección (añadir glifos a las fuentes / reemplazar caracteres en los catálogos M68+M14 / fallback de fuente en Godot) es decisión del director/fundador. Alternativa inmediata de bajo riesgo: reemplazar → por `->` y — por `-` en esos 70 strings (tocaría M68/M14 — sin autorización no se hace).

## Tarea 34 — longitudes ES vs PT (draw de texto ancho)

146 claves comunes: ES 2691 chars (avg 18.4, máx `EQUIP.HINT` 79), EN 2417 (avg 16.6, máx 65), PT 2607 (avg 17.9, máx 78). **PT vs ES: -3.1% promedio** (PT es más corto en promedio — no el típico +10-20%).

**9 claves con PT >15% más larga que ES** (riesgo de desbordamiento): SETTINGS.AJUSTES +86% (7→13 "Ajustes"→"Definições"), SETTINGS.FOGATA +33%, SETTINGS.AUDIO_FALLA +28%, SETTINGS.DESCARTAR_MENSAJE +22%, EQUIP.BONO +21%, SETTINGS.SIN_RECETAS +19%, LOADING.CARGANDO +18%, TUTORIAL.VECINO +17%, EQUIP.BONO_EQUIPO +15%. El máximo absoluto (EQUIP.HINT 79 ES / 78 PT) está cubierto por el ancho de ES; el riesgo queda acotado a Settings (M91) y Equip (M14) — verificación visual por sus dueños. Limitación honesta: proxy por caracteres; el ancho en píxeles (`get_string_size`) requiere Godot headless — follow-up si el director lo pide.

## Estado

- Backlog: tareas **31/34 `[x]`** con evidencia inline.
- Commits pendientes de esta ronda: `scripts/validar_glifos_fuentes.py` + backlog + este msg.
- Pool del canal: 167 consumido, cabeza 168, restan 147. Tracking → 167.
- 0 flips de módulos; 0 push.

## Próximos

Lo que ordene el director; pendientes del frente: Bloque E tarea 33 (M113 subtítulos — nicho Hy3/mío, requiere estado de M113) y Bloque I (log de iteración).
