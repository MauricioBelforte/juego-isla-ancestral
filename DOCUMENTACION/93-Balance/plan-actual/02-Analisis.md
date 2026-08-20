**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 93: Balance

## 1. Análisis del Dominio

### 1.1 Sistemas que alimentan el balance

| Sistema | Variable | Fuente | Módulo |
|---|---|---|---|
| Economía | Precios compra/venta, moneda (AO) | M38 | Economía |
| Tiendas | Stock, precios, márgenes | M39 | Tiendas |
| Recursos | Abundancia, spawn, rareza | M15 | Recursos |
| Crafting | Recetas, costes, tiempos | M16 | Crafting |
| Construcción | Piezas, costes de materiales | M17 | Construcción |
| Herramientas | Durabilidad, mejoras | M13 | Herramientas |
| Agricultura | Ciclos, rendimientos, precios | M33 | Agricultura |
| Pesca | Probabilidades, precios | M34 | Pesca |
| Minería | Profundidad, minerales, gemas | M35 | Minería |
| Viajes | Coste/tiempo entre islas | M28 | Viajes |
| Amistad | Puntos, umbrales, beneficios | M20 | Amistad |
| Misiones | Recompensas | M22/M23 | Historias |
| Puzzles | Recompensas, tiempos | M24/M26 | Templos |
| Progresión | Desbloqueos, curvas | M71 | Progresión |
| Sellos | Condiciones, esfuerzo, recompensas | M153 | Objetivo Final |
| Tiempo | Día, estaciones, calendario | M29/M30/M31 | Tiempo |

El balance NO es un valor estático: es un **gráfico de dependencias** entre sistemas. Cambiar el precio de un mineral (M35) afecta el crafting (M16), la economía (M38) y las recompensas de misiones (M23). Por eso el balance vive en tablas centrales con **referencias cruzadas explícitas** (cada valor declara a qué módulos afecta).

### 1.2 Filosofía de diseño (M152/M153)

- **Sin grind:** ningún objetivo legítimo (más allá de los de largo plazo) debe requerir repetir la misma acción más de ~4 veces consecutivas para sentirse progreso.
- **Generosidad:** los juegos cozy premian el exceso frugal de recursos por encima de la escasez. Mejor recursos sobrantes que faltantes.
- **Tiempo accesible:** la rutina diaria óptima (regar, cuidar animales, regalos, misiones cortas) debe completarse en menos de 30 minutos reales.
- **Sin castigo por ausencia:** los cultivos no mueren (M33), los regalos no decaen (M20), la amistad no baja por no jugar (M94).
- **Economía protegida (M153):** nada comprable/grindeable puede acelerar la historia principal ni los Sellos más allá del ritmo de contenido curado.

### 1.3 Riesgos típicos detectados en juegos cozy

| Riesgo | Ejemplo | Mitigación en este diseño |
|---|---|---|
| Inflación de premios | Misiones dan 100 AO cuando el ítem top cuesta 1000 → recompensas sin valor | Curvas ancladas: recompensa misión = 5-15% del costo del desbloqueo siguiente |
| Deflación / recursos infinitos | Bucle regar→vender→regar genera AO sin límite | Límite diario de ventas (mercado) + márgenes calculados |
| Grind por rareza | Pez legendario 0.01% → 100 h de espera | Rarezas máx 5%; recompensas de colecciones compensan |
| Exploit de tiempo | Avanzar reloj del sistema | Clocks de juego solo basados en sesión (M29/M30), nunca en reloj real para progresión crítica |
| Picos de dificultad | Puzzle que exige ítem no obtenible | Regla: todo puzzle resoluble con herramientas disponibles al momento del hallazgo |
| Economía rota por venta | Vender pescado raro paga todo el juego | Tope de ventas diarias + precio de compra vs. venta 60-70% |

## 2. Alternativas Consideradas

### 2.1 Fuente de valores: `Spreadsheet externo` vs. `Recursos del juego`
| Criterio | Spreadsheet | Recursos `.tres`/`.json` en el juego |
|---|---|---|
| Edición rápida | Excelente (Google Sheets) | Media (editor) |
| Versionado en repo | Malo (archivos binarios/propietarios) | Excelente (diff por línea) |
| Validación automática | Necesita script externo | `validate_balance.gd` directo |
| Runtime | Imposible sin export | Carga nativa |
| **Decisión** | **Recursos `.json` en `data/balance/`** — single source of truth, versionable y validable. El spreadsheet de diseño se mantiene SOLO como vista de trabajo (se exporta a JSON) |

### 2.2 Modelo de moneda
Se mantiene una única moneda **AO** (de M38). Rechazado: múltiples monedas (complejidad extra sin beneficio en juego single-player cozy).

### 2.3 Curvas de progresión: lineales vs. exponenciales vs. logarítmicas
Se usan curvas **mixtas**: lineales para la rutina diaria (ingreso estable), logarítmicas para metas largas (Sellos, colecciones), nunca exponenciales (generan grind para alcanzarlas). Diferencias clave: en cozy, el jugador debe siquiera *sentir* progreso en cada sesión (logarítmica suave), mientras exponencial pura desmotiva al 80% del recorrido.

### 2.4 Anti-exploit: detección en runtime vs. simulación offline
Se elige **simulación offline en editor** (`simulate_economy.gd`): escenarios de 60/180/365 días de juego simulados, que validan que ningún bucle de jugador (regar+vender, pescar+vender, minar+craftear) produzca AO superior a la tasa de diseño, sin costo de runtime. Validación por CI (M118).

## 3. Decisiones Tomadas

1. **Single source of truth:** `data/balance/*.json` (schema versionado) + editor de diseño externo como vista.
2. **Referencias cruzadas:** cada entrada declara `afecta: [M15, M16, M38...]`.
3. **Curvas mixtas** (lineal rutina / logarítmica metas largas); prohibido exponencial.
4. **Rarezas tope 5%** para contenido raro (peces, gemas, mutaciones).
5. **Márgenes de venta:** venta = 55-70% del precio de compra; tiendas con tope de compra diario (M39).
6. **Sellos equilibrados por "bloques de progreso"** (M153): cada Sello exige completar un bloque curado (núcleo + contenido opcional), nunca grind repetitivo.
7. **Tiempo objetivo:** rutina diaria < 30 min; sesión de juego libre de 1-2 h con progreso garantizado.
8. **Métricas de desvío:** M105 mide AO/día, tiempo por actividad, % de jugadores que mantienen rutina semana 1, etc.; el desvío > 20% vs simulación dispara revisión de balance.
9. **Versionado semántico de balance:** bump de `balance_version` cuando cambian valores; log de cambios (`CHANGELOG` de balance).
10. **Anti-FOMO (M94):** ningún recurso de temporada es imprescindible para completar colecciones; todo regresa en ciclos (M29).

## 4. Integración con Otros Módulos

| Módulo | Qué consume de Balance | Qué aporta a Balance |
|---|---|---|
| M38 Economía | Precios, márgenes, límites | Reglas de emisión de AO |
| M20 Amistad | Umbrales, puntos | Capacidad de regalar |
| M153 Sellos | Condiciones, esfuerzo | Objetivos máximos del juego |
| M105 Telemetría | Qué medir | Valores reales de jugadores |
| M114 Playtest | Sesiones de ajuste | Feedback de percepción |
| M118 CI/CD | Gate de validación | Ejecución de `validate_balance.gd` |
| M59 Guardado | Nada (balance no persiste) | — |
| M16 Crafting | Costes de recetas | Recetas nuevas |

## 5. Edge Cases Identificados

1. **Jugador que vende todo** — la economía no se rompe por márgenes y topes diarios.
2. **Jugador que no vende nada** — el almacenamiento (M14) tiene límites; sin penalización.
3. **Ausencia de 30 días** — nada empeora; contenido de estación espera el próximo ciclo (M29).
4. **Multi-jugador de un save** — single-player; ausencia irrelevante.
5. **Creación de ítems raros** — probabilidades nunca caen bajo 0.5% y se garantizan por "pity" (cada X intentos sin éxito, sube la chance).
6. **Diferencia de habilidad** — puzzles con ayudas (M58/M24) que nivelan el tiempo de resolución sin dar la solución gratis.