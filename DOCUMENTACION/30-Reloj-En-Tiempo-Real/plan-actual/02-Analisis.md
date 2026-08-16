**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 30: Reloj en Tiempo Real

## 1. Análisis de los puntos del plan maestro (sección 29)

| # | Punto | Resolución |
|---|---|---|
| 1 | ¿Tiempo real? | ✅ **NO** — el mundo usa su propio reloj comprimido (GameClock M29) |
| 2 | Dependencia del reloj del sistema | ❌ Ninguna del gameplay. Solo se usa para mostrar la "hora del PC" como dato cosmético en título (opcional) |
| 3 | Comportamiento offline | ✅ El mundo se congela (no pierde días al ausentarse) |
| 4 | Adelantar reloj | ✅ Sin efecto: el juego no lee la hora del SO |
| 5 | Retroceder reloj | ✅ Idem: sin efecto |
| 6 | Evitar exploits | ✅ La única fuente de tiempo es GameClock (interna, determinista) |
| 7 | Evitar castigos | ✅ No hay penalización por ausencia (regla cozy) |
| 8 | Eventos mensuales | ✅ Los dispara el calendario interno, no el real |
| 9 | Sincronización | ✅ Interna por tick (delta real para precisión de duración, M29) |
| 10 | Zona horaria | ✅ No aplica: no hay hora real jugable; se ignora |
| 11 | Horario de verano | ✅ No aplica (sin hora real) |
| 12 | Cambio de zona horaria | ✅ Sin impacto |
| 13 | Fallback sin reloj correcto | ✅ GameClock no depende del OS; fallback automático |
| 14 | Pruebas de fecha | ✅ Suite de tests: tick normal, día 336→año 2 (M112) |
| 15 | Pruebas de año nuevo | ✅ Test del cambio de año (sin error de overflow) |
| 16 | Pruebas de fin de mes | ✅ Test día 28→mes siguiente |
| 17 | Pruebas de años bisiestos | ✅ No aplica (año fijo de 336 días) — documentado |
| 18 | Recuperación de errores | ✅ Si el tick se corrompe, reinicia el día desde el último guardado (M59) |
| 19 | Protección contra manipulación accidental | ✅ Hora interna intocable desde scripts externos (solo API GameClock) |
| 20 | Experiencia offline | ✅ El jugador retoma donde estaba (persistencia M29) |

## 2. Decisión central: ¿tiempo real o no?

**NO.** Justificaciones (alineadas al plan de producción y GDD):

1. **Cozy sin presión:** tiempo real obliga a "entrar todos los días" (FOMO). Prohibido por el pilar anti-FOMO del proyecto (M94).
2. **Sin exploits:** el reloj interno es determinista e inmune a la manipulación del SO.
3. **Ritmo del juego:** el bucle (día 24 min) da 2,5 días por hora de sesión; alcanza para el ritmo cozy sin exigir frecuencia real.
4. **Portabilidad:** sin zonas horarias, sin sincronización con servidor (single-player), sin edge cases de DST.

## 3. Alternativas consideradas (y descartadas)

- **Tiempo real parcial (eventos cada 24 h reales):** descartado por FOMO y por complejidad de sincronización.
- **Tiempo real cosmético (saludo "buenas tardes"):** descartado por inconsistencia narrativa (el jugador ve de noche cuando es de día real).
- **Tiempo real solo para registro (stats):** innecesario en v1.0; se evalúa en post-v1.0 para analytics (M105) si hace falta.

## 4. Qué queda de este módulo

El módulo se reduce a: display (reloj UI) + política anti-exploit + pruebas de límites de fecha. El GameClock (M29) hace el trabajo pesado.

| Entregable | Detalle |
|---|---|
| Reloj UI | Widget HUD: hora HH:MM + fecha + estación (lee API M29) |
| Política anti-exploit | Documentada (punto 6 del análisis) |
| Suite de pruebas de fecha | Tests de límites para M112 |
| Nada de tiempo real | Sin OS, sin zona horaria, sin DST |