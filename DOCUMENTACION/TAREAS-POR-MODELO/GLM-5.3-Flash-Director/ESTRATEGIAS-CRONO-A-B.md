# ESTRATEGIAS DEL CRON A y CRON B (fundador 2026-10-18 06:10/05:23 — LÉER SIEMPRE AL ARRANCAR)

**Modelo:** GLM-5.3-Flash-Director (GLM-5.3-Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-18 06:15
**Origen:** directiva del fundador 05:23 ("hace un fallback o tené una segunda estrategia") — el caso Hy3 259 que me salté por el filtro `hy3-a-hy3`.

## CRONOGRAMA (sin solaparse)

| Cron | Minutos | Estrategia | ID |
|---|---|---|---|
| **A** | :00/:10/:20/:30/:40/:50 | LECTURA POR PUNTEROS | `wku_14e44c0c` |
| **B** | :05/:15/:25/:35/:45/:55 | VERIFICACIÓN CRUZADA FULL | `wku_14e45030` |

## CRON A (estrategia primaria, :00/:10/...)

1. **Punteros `.ultima-revision`** por canal: agnes=766, DS=114, Ling=14, Hy3=261, DeepSeek-WB=309, Step-5=77, G-Agente=42/49 (mirearse al boot).
2. **TODO archivo .md nuevo con prefijo > puntero** = mensaje a leer — **SIN FILTRAR POR EL SLUG DEL RECEPTOR** (el caso Hy3 259 con slug `hy3-a-hy3` pero contador PARA MÍ).
3. Ahora que el filtro no aplica: los slugs `hy3-a-hy3` y `-a-director` — CUALQUIER formato CUENTA.
4. Cuerpo completo, varios por canal, respuesta al canal con el helper.

## CRON B (verificación cruzada, :05/:15/...)

1. **BARRIDO FULL SIN PUNTEROS**: listar TODO el `.md` de cada canal, comparando contra mi riel de procesado. El que no esté registrado → leerlo y responder.
2. **El matching del contenido**: los archivos con 'GLM-5.3' o 'director' en sus primeras 10 líneas — CUALQUIER slug (no solo `-a-glm-5.3-flash-director-`; los `hy3-a-hy3`, `agnes-a-agnes` cuentan como cruces).
3. **El CROSS-CHECK cerrado**: los archivos con acuse tuyo faltante → leerlos y responderles.

## LAS REGLAS DEL CRON B (la cobertura)

- El 90% de los ciclos NO hay novedad — reporta una línea "sin faltantes" y cerrás.
- Con novedad: LEER COMPLETO, RESPONDER, y reportar al fundador SOLO material.
- La numeración SIEMPRE vía `scripts/proximo_numero.py <canal> --consume`.

## LAS REGLAS FIJAS DE AMBOS (del cron V2.2)

- UTF-8 (§28) sin BOM (nunca Set-Content/redirect de PS — usar Python).
- Firma: GLM-5.3-Flash-Directo (o G-5.3-Flash-Agente — según siendo director o el agente).
- Pathspec explícito (sin `-A` sobre WIP ajeno).
- Independencia §21.8/§21.23 (DeepSeek-WB y DS-OpenCode no QA mutuo; lo de GLM y G-Agente lo verifican Hy3/agnes).
- REGLA CERO, numeración último+1. Archivo por cientos cuando un canal pone >100 .md suelto.
- Fundador: SOLO novedad material.

## EL CASO QUE MOTIVÓ EL FALLBACK (registrado para el riel)

El 259 de Hy3 (2026-10-17 21:15, 12 líneas): el slug era `hy3-a-hy3-recordatorio-delegar-tareas.md` y el contenido decía "Pasé a revisar mi canal y no había mensajes nuevos del director... si tenés tareas de verificación cruzada / QA / cierre §21.8 para M21 u otro módulo, delegámelas por acá". **Era PARA MÍ el director** (la delegación con evidencia medida) — pero mi scan lo descartó por el nombre. Corridó el retraso: 21:15 → 05:23 (8 horas de retraso). El fundador lo excluyó en el 04:20 y ordena "hace un fallback o tené una segunda estrategia" → implementado como Cron B.

## LOS ERRORES QUE NO PUEDEN REPETIRSE (del riel del día)

1. Filtro por el slug del receptor → NO (el Receptor no decide, la fecha y el hilo sí).
2. La numeración a mano → NO (el helper `proximo_numero.py` SIEMPRE).
3. Los `>` Set-Content de PS → NO (Python UTF-8 sin BOM SIEMPRE — el caso her_017 UTF-16-LE).
4. `-A` sobre WIP ajeno → NO (pathspec explícito SIEMPRE).
5. Respondel los mensajes tarde → reducirlo con el doble-check del Cron B.
