**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 30: Reloj en Tiempo Real

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://data/ui/w_reloj.tres` | Data | Config: formato 12h/24h, posición, colores por estación |
| `res://ui/hud/w_reloj.gd` | Script | Widget HUD que muestra hora/fecha/estación (lee GameClock M29) |
| `res://ui/hud/w_reloj.tscn` | Escena | UI del reloj |
| `res://ui/hud/hud.gd` | Script | HUD principal (M53) — contenedor |
| `res://tests/caso_reloj.tscn` | Test | Escenario de pruebas de límites de fecha (M112) |
| `res://tests/caso_reloj_tests.gd` | Test | Suite: fin de día/mes/año, estación, cumpleaños, persistencia, anti-exploit |

## 2. Contrato de datos (API consumida de M29)

| Método/señal | Uso en M30 |
|---|---|
| `GameClock.get_hora()` | Hora HH:MM para el widget |
| `GameClock.get_fecha()` | Fecha (día, mes, estación, año) |
| `GameClock.get_estacion()` | Ícono y color del widget |
| `EventBus.time.hora_cambio(hora)` | Actualizar label HH:MM (sin polling) |
| `EventBus.time.dia_cambio(DiaInfo)` | Actualizar fecha + aviso de eventos del día |
| `EventBus.time.estacion_cambio(estacion)` | Cambiar ícono/color + aviso UI |
| `EventBus.time.evento_activado(EventoPeriodico)` | Badge de evento en el reloj |
| `GameState.M29` | Lectura de fecha/hora persistida al cargar |

## 3. Regla de oro (anti-exploit, se documenta y se testea)

> **Ningún sistema de gameplay lee el reloj del sistema operativo.** La única fuente de tiempo es `GameClock` (interna, determinista, inmune a `Time.get_unix_time_from_system()`).

- El widget solo ESCRIBE (display), nunca produce tiempo.
- Adelantar/retroceder el reloj del SO no produce ninguna ventaja (0 código depende de él).
- El mundo se congela offline (M29): no hay tiempo real parcial ni castigos por ausencia (pilar anti-FOMO).

## 4. Pendientes de implementación (dueño: AGENTE DELEGADO)

| Pendiente | Nota |
|---|---|
| Implementar `w_reloj.gd` + `w_reloj.tscn` | Sigue el patrón UI de M53; usa solo la API de M29 |
| Implementar `caso_reloj_tests.gd` | 10 casos de límites (tabla de M112 abajo) |
| Conectar con HUD principal (M53) | El widget se agrega al HUD en la vertical slice (M138) |
| Localización (M57) | Nombres de días/meses/estaciones desde data localizable |
| Test estático anti-reloj-SO | Script que escanea `Time.get_*` en código de gameplay (M111) |

## 5. Tabla de pruebas de límites (para M112)

| # | Caso | Entrada | Esperado |
|---|---|---|---|
| 1 | Tick normal | 1 s real | +1 min de juego, HH:MM actualiza |
| 2 | Fin de día | 23:59 → 00:00 | `dia_cambio`, fecha avanza |
| 3 | Fin de mes | día 28 → mes+1 día 1 | `mes_cambio`, sin error |
| 4 | Fin de año | día 336 → año+1 | año avanza, sin overflow |
| 5 | Cambio de estación | último día Verano | `estacion_cambio` + aviso |
| 6 | Cumpleaños | fecha exacta vecino | `evento_activado` |
| 7 | Persistencia | guardar 14:32 → cargar | 14:32 exacto |
| 8 | Retroceder SO | `Set-SystemTime -1d` | sin efecto en juego |
| 9 | Adelantar SO | `Set-SystemTime +1mes` | sin efecto en juego |
| 10 | Ausencia | 7 días reales sin jugar | estado congelado al volver |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 07:20:00
**Estado:** Parcial (documentación de diseño completa; implementación delegada)

### Lo que hice
- Resolví los 20 puntos de la sección 29 del plan maestro (todos en 02-Analisis.md).
- Documenté la política anti-exploit completa (regla de oro + 4 reglas operativas).
- Diseñé el widget de reloj y la tabla de 10 pruebas de límites de fecha.

### Lo que NO hice (honestidad obligatoria)
- Implementar código: el módulo es intencionalmente **delegable** (depende de M29 implementado). Dueño: AGENTE DELEGADO → hito M1/prototipo.

### Recomendaciones para el próximo agente
- Implementar después de que GameClock (M29) exista; el contrato de API está fijado arriba.
- El test 8/9 (reloj del SO) es barato de automatizar en M112 (Windows: `Set-SystemTime`).
- No agregar ningún uso real del tiempo del SO sin pasar por decisión del GDD (pilar anti-FOMO).