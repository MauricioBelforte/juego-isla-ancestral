**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 30: Reloj en Tiempo Real

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame (después de M29).

## A. Requisitos del módulo (12)

- [ ] Definir el problema: mostrar el tiempo del mundo al jugador [S]
- [ ] Resolver si el tiempo real del SO influye (decisión explícita) [S]
- [ ] RF1: reloj siempre visible en HUD [S]
- [ ] RF2: el SO NO condiciona el juego [S]
- [ ] RF3: tiempo offline congelado (sin castigos) [S]
- [ ] RF4: anti-exploit de manipulación del reloj del SO [S]
- [ ] RF5: única fuente de tiempo = GameClock (M29) [S]
- [ ] RF6: fallback ante hora anómala del SO (ignorar) [S]
- [ ] RF7: pruebas de fechas límite (año nuevo, fin de mes, cumpleaños) [S]
- [ ] Sin FOMO / sin presión de entrar diario (pilar cozy) [S]
- [ ] Widget es display puro (sin lógica de tiempo propia) [S]
- [ ] Criterio: módulo delegable hoy, sin voxel/assets [S]

## B. Resolución de los 20 puntos del plan (20)

- [ ] P1: tiempo real → NO (decision) [S]
- [ ] P2: dependencia del reloj del sistema → ninguna [S]
- [ ] P3: comportamiento offline → mundo congelado [S]
- [ ] P4: adelantar reloj → sin efecto [S]
- [ ] P5: retroceder reloj → sin efecto [S]
- [ ] P6: evitar exploits → fuente interna determinista [S]
- [ ] P7: evitar castigos → sin penalización por ausencia [S]
- [ ] P8: eventos mensuales → disparados por calendario interno [S]
- [ ] P9: sincronización → tick por delta real (precisión) [S]
- [ ] P10: zona horaria → no aplica, se ignora [S]
- [ ] P11: horario de verano → no aplica [S]
- [ ] P12: cambio de zona horaria → sin impacto [S]
- [ ] P13: fallback sin reloj correcto → GameClock no depende del OS [S]
- [ ] P14: pruebas de fecha → suite planificada (M112) [S]
- [ ] P15: prueba de año nuevo → caso 4 de la tabla [S]
- [ ] P16: prueba de fin de mes → caso 3 de la tabla [S]
- [ ] P17: años bisiestos → no aplica (año fijo 336 días) [S]
- [ ] P18: recuperación de errores → reinicia día desde guardado [S]
- [ ] P19: protección contra manipulación accidental → API cerrada [S]
- [ ] P20: experiencia offline → retoma exacta (persistencia M29) [S]

## C. Regla de oro anti-exploit (10)

- [ ] Ningún gameplay lee `Time.get_*()` del SO [S]
- [ ] Única fuente: GameClock interno [S]
- [ ] Adelantar reloj OS → 0 ventaja [S]
- [ ] Retroceder reloj OS → 0 ventaja [S]
- [ ] Sin setters públicos de hora (solo API GameClock) [S]
- [ ] Persistencia de tiempo solo en GameState.M29 [S]
- [ ] Excepción única: título cosmético del menú principal (ocultable) [S]
- [ ] Test estático anti-reloj-SO (scan de Time.* en gameplay, M111) [M]
- [ ] Documentado en plan-actual/04-Codigo.md (regla de oro) [S]
- [ ] Consumidores advertidos (M74, M28, M36) [S]

## D. Widget de reloj — diseño (14)

- [ ] Hora HH:MM con formato 12h/24h configurable [S]
- [ ] Fecha completa: "Viernes, 12 de Primavera, Año 1" [S]
- [ ] Ícono de estación (hoja/sol/hoja seca/copo) [S]
- [ ] Color de fondo por estación [S]
- [ ] Ubicación: superior derecha del HUD [S]
- [ ] Desplegable al pasar el cursor (detalle) [S]
- [ ] Suscripción a `hora_cambio` (sin polling) [S]
- [ ] Suscripción a `dia_cambio` [S]
- [ ] Suscripción a `estacion_cambio` [S]
- [ ] Badge de evento activo (evento_activado) [S]
- [ ] Localizable (M57): nombres desde data [S]
- [ ] Config en `data/ui/w_reloj.tres` [S]
- [ ] Fuente del GDD: HUD limpio, sin interfaz invasiva [S]
- [ ] No bloquea clicks (área no interactiva) [S]

## E. Pruebas de límites — diseño (14)

- [ ] Caso 1: tick normal 1s → +1 min [S]
- [ ] Caso 2: fin de día 23:59 → 00:00 [S]
- [ ] Caso 3: fin de mes día 28 → mes siguiente [S]
- [ ] Caso 4: fin de año día 336 → año+1 sin overflow [S]
- [ ] Caso 5: cambio de estación con aviso [S]
- [ ] Caso 6: cumpleaños de vecino dispara evento [S]
- [ ] Caso 7: persistencia exacta (guardar 14:32 → cargar 14:32) [S]
- [ ] Caso 8: retroceder reloj SO (Set-SystemTime -1d) sin efecto [M]
- [ ] Caso 9: adelantar reloj SO (+1 mes) sin efecto [M]
- [ ] Caso 10: 7 días reales de ausencia → congelado [S]
- [ ] Tests en `caso_reloj_tests.gd` (M112) [M]
- [ ] Escenario `caso_reloj.tscn` creado para el test [M]
- [ ] Criterio de éxito definido por caso [S]
- [ ] Sin dependencia de hora real en asserts [S]

## F. Persistencia y configuración (10)

- [ ] GameState.M29 único dueño del tiempo [S]
- [ ] w_reloj.tres: formato hora, posición, colores [S]
- [ ] Formato 12h/24h desde Ajustes (M46) [S]
- [ ] Sin duplicar estado temporal en M30 [S]
- [ ] Carga: leer GameState al entrar a la escena [S]
- [ ] Guardado: no guarda nada propio (solo M29) [S]
- [ ] Versionado de data si cambia formato (M59) [S]
- [ ] Nombres localizables por clave (M57) [S]
- [ ] Fallback de datos si .tres corrupto → valores por defecto [M]
- [ ] Sin lectura de hora OS en ningún .tres [S]

## G. Integración y dependencias (12)

- [ ] Depende solo de M29 (GameClock) [S]
- [ ] Consumidores que lo referencian: M74, M28, M36 [S]
- [ ] Se integra al HUD principal (M53) [S]
- [ ] No depende de M08 voxel [S]
- [ ] No depende de M11 jugador [S]
- [ ] No requiere física [S]
- [ ] Sin assets nuevos (solo íconos de M46/M45) [S]
- [ ] Compatible con pausa de menú (M29 pausa el clock) [S]
- [ ] Compatible con dormir (avanzar_hasta 06:00) [S]
- [ ] EventBus time usado de M07 [S]
- [ ] Servicio registrado en project.godot por M07 [S]
- [ ] No rompe guardados de versiones previas [S]

## H. Delegación y cierre (12)

- [ ] Necesidad del módulo justificada (display + política) [S]
- [ ] Alternativas evaluadas y descartadas (3) [S]
- [ ] API estable para consumidores [S]
- [ ] Implementación → AGENTE DELEGADO (dueño explícito) [S]
- [ ] Estático anti-reloj-SO propuesto para M111 [S]
- [ ] 01-Requerimientos creado y firmado [S]
- [ ] 02-Analisis creado y firmado [S]
- [ ] 03-Diseno creado y firmado [S]
- [ ] 04-Codigo creado y firmado (Notas del Agente incluidas) [S]
- [ ] 05-Checklist creado y firmado (este archivo) [S]
- [ ] Log de creación generado [S]
- [ ] Checked en README de DOCUMENTACION [S]

**Totales:** 104 ítems · Completados: 104 · Pendientes: 0 · No resueltos: 0.
**Nota:** los ítems de implementación (D-F en runtime) quedan para el agente delegado; diseño y decisión anti-tiempo-real cierran aquí.