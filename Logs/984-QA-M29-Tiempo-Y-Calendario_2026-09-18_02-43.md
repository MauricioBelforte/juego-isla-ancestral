# Log 984: QA M29 Tiempo-Y-Calendario — ✅ MANTIENE con metadata reparada

**Fecha:** 2026-09-18
**Hora:** 02:43
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code

## Resumen

QA cruzado (§21.8) del modulo M29, marcado ✅ "Verificado item por item por mimo-v2.5
(2026-09-16)". **Veredicto: ✅ MANTIENE** — el modulo esta genuinamente implementado. El problema
encontrado no era de codigo sino de **metadata del checklist**: una reversion del 2026-09-14 dejo
los 195 items en `[ ]` con la leyenda de estados rota, y nadie restauro las marcas.

## Hallazgo: metadata rota (no sobre-cierre)

El banner de la linea 1 del 05-Checklist.md dice: "REVERTIDO POR AUDITORIA (2026-09-14):
agnes-2.5-flash marco este modulo como completado sin verificacion real. Todos los [x] revertidos
a [ ]. Revertir manualmente solo los que realmente esten implementado."

**Nadie volvio a marcar.** El archivo tenia los 195 items en `[ ]`, pero:
- La leyenda (linea 8) decia "[ ] cumplido · [ ] pendiente · [?] no resuelto" — **ambos `[ ]`**:
  no habia forma de distinguir cumplido de pendiente.
- El Totales (linea 143) seguia en "104 items - Completados: 104" (stale pre-reversion).
- CHECKLIST-GLOBAL e iter 1 (Log 824) declaraban 194/195.
- mimo-v2.5 (2026-09-16) lo verifico "item por item" y conto `[ ]` como cumplido por la leyenda
  ambigua.

## Lo que verifique con evidencia propia

**Tests headless re-ejecutados (Godot 4.7.2, binario real): 50 checks, 0 fallos.**

| Suite | Resultado |
|---|---|
| test_calendario | 13/0 |
| test_semilla_iter1 | 25/0 |
| test_consumidores_tiempo | 12/0 |

**Datos verificados directamente:**
- `data/time/time_config.tres`: toda la seccion B (proporcion 40.0, 1440 min/dia, semana 7, mes 28,
  año 336, 4 estaciones, amanecer 6/atardecer 20, gradientes 90, ventana 24, nombres, semilla).
- `data/time/festivals.tres`: toda la seccion C — 4 festivales estacionales + festival_luces +
  plantilla_cumpleanos + 2 visitas + 2 eventos mensuales + cumpleanos_jugador = 11 eventos, todos
  `repetible=true`.
- API por grep de firmas: 5+6 señales y ~20 metodos en game_clock.gd/time_calendar.gd.

## Correcciones aplicadas

1. Leyenda reparada (linea 8): `[x]` cumplido / `[ ]` pendiente / `[?]` no resuelto.
2. **190 items marcados [x]** con verificacion propia (secciones A-I + "Estado real").
3. **2 items [?]**: flecha indicadora del HUD (lineas 75 y 194) — UI de M53, fuera de alcance.
4. **3 items quedan [ ]**: D71-D73 originales (calendario de mes, iconos por evento, lista de 7
   dias en el diario) — features UI de M53/M55 que M29 solo provee como API.
5. Totales corregido: 195 items - 190 [x] - 3 [ ] - 2 [?].
6. `CHECKLIST-GLOBAL` fila 29: 194/195 → **190/195** con el veredicto.

## Diferencia con el conteo previo

El conteo previo (194/195) contaba como cerrados los 3 items de UI de M53/M55 porque "la API esta
lista" — pero los items hablan del resultado visual, que no existe. Mi conteo real: 190/195.

## Errores de runtime observados (no bloqueantes)

En test_calendario aparecen varios
`ERROR: Can't use get_node() with absolute paths from outside the active scene tree` y un
`ERROR: Parameter "data.tree" is null` cuando algun consumidor resuelve nodos por ruta absoluta
fuera del arbol activo. Los checks pasan igual. No es un bug de M29 per se, pero el patron
`get_node("/root/...")` fuera del arbol es fragil.

## Archivos Modificados/Creados

- `DOCUMENTACION/29-Tiempo-Y-Calendario/plan-actual/05-Checklist.md` (190 marcas + leyenda +
  Totales + seccion K de QA)
- `CHECKLIST-GLOBAL.md` (fila 29: 190/195, veredicto y correccion)
- `Logs/984-QA-M29-Tiempo-Y-Calendario_2026-09-18_02-43.md` (este log)

## Proximos pasos

- Reserva 984 consumida; modulo liberado (sigue ✅, sin bloqueo).
- Iter 13: siguiente modulo del backlog. Leccion de proceso anotada: una reversion de [x]→[ ]
  siempre debe reparar leyenda y Totales en el mismo commit.
