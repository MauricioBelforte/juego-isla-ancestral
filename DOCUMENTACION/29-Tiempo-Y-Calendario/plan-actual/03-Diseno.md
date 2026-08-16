**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 29: Tiempo y Calendario

## 1. GameClock — API pública (servicio en ServiceLocator)

```
GameClock (servicio, autoload registrado en ServiceRegistry)
├── senial dia_cambio(DiaInfo)                      # 1× por día de juego
├── senial hora_cambio(hora)                        # cada hora de juego
├── senial estacion_cambio(estacion)                # 1× por estación
├── senial evento_activado(EventoPeriodico)
├── metodo get_hora()        -> Hora                   # 00:00-23:59
├── metodo get_fecha()       -> Fecha                  # dia/mes/año
├── metodo get_estacion()    -> ESTACION
├── metodo get_semana_dia()  -> DIAS_SEMANA
├── metodo pausa() / resume()
├── metodo avanzar_hasta(hora)                      # dormir (M31 cama)
├── metodo es_de_dia()       -> bool                # 06:00-19:59
└── metodo proximos_eventos() -> [EventoPeriodico]
```

## 2. Convenciones del calendario de Aurora

| Concepto | Valor |
|---|---|
| Día real == minuto de juego | 1 s real = 1 min juego (1:40) |
| Día de juego | 24 min (14 h día = 06:00-19:59, 8 h noche = 20:00-05:59) |
| Semana | 7 días |
| Mes | 28 días (4 semanas) |
| Año | 12 meses = 336 días ≈ 5,6 h de sesión real por año |
| Estaciones | 4 (3 meses c/u): Primavera, Verano, Otoño, Invierno |
| Año 1 | Fundación del refugio (lore M22) |

## 3. Eventos periódicos (ciclo completo)

| Ciclo | Evento | Nota |
|---|---|---|
| Diario | Reapertura de tiendas, rutinas NPC, cultivos, pesca renovada | Hooks M33/M36/M19 |
| Semanal | Visitante nuevo (M27/M28), feria del mercado menor | Llega en el Gran Vapor |
| Mensual | Mercado especial (M39), luna de cosecha | Anunciado 3 días antes |
| Estacional | Festival estacional: Flores (Prim.), Cosecha (Ver.), Viento (Oto.), Nieve (Inv.) | 3 días de duración, repetible |
| Anual | Festival de las Luces (fin de año) | El grande: luces en el pueblo, regalos, cierre de ciclo |
| Cumpleaños | 1 por vecino registrado (M19) | Regalo + gorra de cumpleaños (M74) |

## 4. Regla anti-frustración (cozy roja)

- Todo evento importante es **repetible** (anual, no único).
- Si el jugador se pierde un festival → espera al próximo año, pero el contenido NUNCA se destruye: ítems de evento, misiones y recompensas se reactivan.
- El reloj NO corre offline ni con el juego cerrado → no existe "te perdiste 3 días".
- Los cambios de estación se anuncian 1 día antes (aviso en UI) → el jugador puede preparar cultivos/cosechas.

## 5. Transiciones temporales

1. **Avance natural:** tick cada segundo real (minuto de juego); se pausa en menús/diálogos/carga.
2. **Dormir (cama):** `avanzar_hasta(06:00)` si duerme de noche → día siguiente; se pulsa el evento `amanecer_siguiente()`.
3. **Nunca retroceder:** el reloj solo avanza (sin manipulación hacia atrás; el tiempo es unidireccional en mitad de sesión).
4. **Guardado:** en GameState.M29 se persiste `fecha_hora` + `eventos_visitados` + `proximo_evento` (M59). Al recargar, el reloj retoma exactamente donde quedó (sin días fantasma).

## 6. Calendario UI (datos para M74/M30)

- Calendario de mes: día actual marcado, íconos por evento (festival, cumpleaños, mercado, visita).
- Próximos 7 días: lista compacta en el panel diario (diario del jugador M55).
- Notificación de evento próximo: aviso 24 h (en juego) antes + flecha en el HUD.
- Iconografía por estación (hoja, sol, hoja seca, copo).

## 7. Impactos en otros sistemas (resumen)

- M31 consume `fase_del_dia()` para iluminación/sky.
- M33 consume estación para qué crece y avisos de helada.
- M08: la nieve de invierno se aplica como variante estacional de superficie (hook `estacion_cambio`).
- M19/M64: rutinas por hora (`get_hora()`), feria cerrada los domingos.
- M36/M37: fauna y museo respetan estación (especies estacionales).