# Log 1821: M74-Eventos auditada completa (59 `[?]`: 1 promo) — consumidores con duck-typing roto/dormido

**Fecha:** 2026-10-13
**Hora:** 20:35
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Auditoría de los 59 `[?]` de M74-Eventos (encargo del director mimo, msg 280/285 + reenvío de s3),
mismo método Patrón D que M27 (Log 1819). Commit `b9ba71e`.

## Resultado

- **1 promovido** (`[?]`→`[x]`): ítem M154 (Visión del Agente) —
  `DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md` marca V1/V2/V4/V5 como OPERATIVAS (tabla de estado
  verificada 2026-08-22/25) y la verificación en vivo es que esta sesión de Kilo Code tiene los
  tools `mcp__screen__*` conectados (V2 activa hoy).
- **58 permanecen `[?]`** con explicación de qué falta en cada línea.
- Conteos: **227 `[x]` / 0 `[ ]` / 58 `[?]`** = 285; línea Totales actualizada (226→227 / 59→58).

## Hallazgo principal: tres consumidores de recompensa con duck-typing roto o dormido

`scripts/eventos/recompensa_def.gd` implementa la entrega por duck-typing contra `/root`, pero los
tres destinos cruzados no existen en producción (los métodos solo están definidos en el test
`test_event_manager_verificacion.gd`):

| Recompensa | Llamada en M74 | Realidad en disco | Efecto |
|---|---|---|---|
| AMISTAD (M20) | `fs.sumar_puntos()` (L95-97) | `friendship_service.gd` NO expone `sumar_puntos` ni `modificar` (API real: `get_puntos`, `registrar_evento`; `aplicar_puntos` vive en `VecinoAmistad`) | cae al `push_warning`, **no entrega** |
| PROGRESO (M71) | `prog.registrar_progreso_evento()` (L103-109) | el método solo existe en el test (L77) | hook dormido, el propio comentario lo admite ("hasta entonces NO se marca entregada") |
| COLECCIÓN (M37) | `museo.registrar_recuerdo()` (L110+) | el método solo existe en el test (L71) | hook dormido |

Es deuda de integración real, no inflación: el cable existe en un extremo solo.

## Otros patrones

- **Variante cubierta ante tormenta es un stub**: `_on_clima_cambio` (event_manager.gd L176-186)
  imprime y hace `pass` ("la UI consumiría esta señal"); la recompensa compensatoria al cancelar SÍ
  existe y está testeada (L272-283), pero nadie la dispara por fallo de escena de M63.
- **Recinto faltante** no crashea (test_barrido_m74.gd L139 + `load()` null-safe L84);
  **recinto corrupto** sin prueba.
- **QA manual pendiente** (ítems 51-57: Play Mode, Profiler, flujo extremo a extremo): no verificable
  por disco, quedan `[?]` con esa nota.
- **Ítem 59** sigue bloqueado por regresiones ajenas documentadas en el propio ítem
  (`event_bus.gd` parse error + `vehicle_manager.gd` autoload roto).

## Archivos Modificados/Creados

- `DOCUMENTACION/74-Eventos/plan-actual/05-Checklist.md` (59 `[?]` auditados, 1 promo, Totales;
  commit `b9ba71e`)
- `Logs/1821-...md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (1821 consumido)
- `scripts-prueba-temp/audit_m74_b*.py` (scripts de anotación por bloque)

## Pendiente

M34-Pesca (54 `[?]`) y M11-Personaje (51 `[?]`) — mismos bloques de 10.
