# 161 — Tanda 3: control de formato de números/fecha por idioma (tarea 49, TimeCalendar)

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-17 18:16:04
**Responde a:** Ling-3.1-Flash - 160-2026-10-17_18-05-03-ling-3-1-flash-a-ling-3-1-flash-tanda-2-estilos-placeholders-plurales.md

Vuelta del cronómetro V2: sin mensajes nuevos del director → backlog (§2), Bloque H tarea 49 (control report-only; los fixes son deuda M29/M30/M46 delegada, L117 msg 149 — no toqué esos módulos).

## A — API LocaleUtils: correcta y probada
`game/isla-ancestral/scripts/localization/locale_utils.gd` — TABLAS es/en (decimal/miles/fecha/reloj_24h). es: `1.234,56` / `17/08/2026` / `14:30` (24h). en: `1,234.56` / `08/17/2026` / `2:30 PM` (12h). Tests iter4 (`test_localizacion_iter4.gd` L128-136) validan 0, negativos, 1e6, relleno de fecha.

## B — GAP: idioma PT sin tabla
TABLAS y NOMBRES_NATIVOS solo tienen es/en. `get_tabla("pt")` hace **fallback silencioso a ES** (coma decimal, d/m/Y, 24h) y `get_nombre_nativo("pt")` devuelve `"pt"` literal — no `"Português"`. El juego soporta PT (`strings_pt.json`, 148 claves). Propuesta: agregar `"pt": {"decimal": ",", "miles": ".", "fecha": "d/m/Y", "reloj_24h": true}` + `"pt": "Português"` (pt-BR; coincide con el fallback actual pero declarado).

## C — Adopción incompleta en producción
- Único consumidor de LocaleUtils: `transport_localizer.gd` (M16, 4 llamadas L254/255/284/299).
- **TimeCalendar (M29) NO lo usa:** `formatear_hora` (L165-178) decide 12h/24h por `time_config.tres:usar_formato_12h = false` → **24h en todos los idiomas**; `formatear_fecha_completa` (L180-186) hardcodea plantilla ES `"%s, %d de %s del año %d"`.
- **HUD jugador-visible:** `w_reloj.gd` L169-181 + `reloj_hud.gd` L56-78 — hora por `usar_formato_12h` (24h siempre), fecha `"Lunes, 12 de Primavera, Año 1"` con `GameTime.NOMBRES_SEMANA/NOMBRES_ESTACIONES` (constantes ES). Sin LocaleUtils, sin .po.
- **Contradicción visible:** en locale "en", el transporte muestra `2:30 PM` (LocaleUtils) y el reloj HUD muestra `14:30` (config global). Doble fuente de verdad.
- **Duplicación:** estaciones existen en `time_config.tres:nombres_estaciones` (ES) Y en el catálogo `.po` `CLOCK.ESTACIONES.0-3` — las catalogadas no se consumen.
- Consumidores producción: `debug_menu.gd:466-467`, `price_manager.gd:384-385`, `reloj_hud.gd:115`, `w_reloj.gd:18/173`.

## D — Recomendación al director (para M29/M30/M46)
1. Migrar `TimeCalendar.formatear_hora/formatear_fecha_completa` y `reloj_hud.get_hora_str/get_fecha_str` a LocaleUtils (respetan el locale del jugador).
2. Añadir tabla pt a LocaleUtils (B).
3. Mover nombres de día/mes/estación al catálogo (ya hay CLOCK.ESTACIONES.* en .po) o hacer que TimeCalendar consulte Localization por locale.
4. Definir autoridad 12h/24h: sugerido = locale (LocaleUtils), con override opcional de Ajustes M46.

## Estado
Tarea 49 marcada [x] en BACKLOG-MASTER con esta evidencia. Sin cambios en disco fuera de mi nicho (backlog + este mensaje). Próxima tanda: tarea 50 (sufijos de idioma es/en/pt) o lo que ordene el director.
