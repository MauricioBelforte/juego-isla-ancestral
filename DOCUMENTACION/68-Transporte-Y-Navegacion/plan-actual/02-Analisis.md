**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 68: Transporte y Navegación

## 1. Análisis del Dominio

El dominio del transporte y la navegación de Aurora se descompone en siete subsistemas:

### 1.1 Infraestructura (puertos y estaciones)
- **Dominio:** puertos (muelles con docking M67) y estaciones (plataformas de dirigible, estaciones de tren si M67 define la locomotora). Cada "parada" es un `TransportStop` (id, POI M54, tipo, horario).
- **Clave:** las paradas se registran en el mapa de transporte (M54) como marcadores especiales (distintos de POI comunes).

### 1.2 Red de rutas
- **Dominio:** rutas son aristas del grafo de paradas: origen → destino con duración, coste (M38) y restricciones. El grafo es simple (sin bucles duplicados; pesos = duración).
- **Clave:** una ruta directa cuesta más que combinar dos (incentiva explorar paradas intermedias); los costes se descuentan por amistad (M20).

### 1.3 Navegación y señalización
- **Dominio:** en el mundo: carteles de madera (M46) con direcciones y distancias en cada parada; en el mapa (M54): capa de rutas dibujadas + marcadores de parada con horarios.
- **Clave:** la señalización SIEMPRE coincide con el mapa (misma fuente de datos: la red de rutas). Un validador lo comprueba.

### 1.4 Viajes y transiciones
- **Dominio:** al iniciar un viaje: cierre cozy (fade con mensaje M44), cargar destino, reaparición orientada al destino (never lose the player). Duración real para viajes cortos (embarcadero cercano) y montaje (fade) para largos; los viajes narrativos (M22) tienen secuencia propia (M21 textos).
- **Clave:** la transición reutiliza `SceneTransition` (M61): sin cargar async manual, con barra de progreso (M08) si el destino tarda.

### 1.5 Coordinación con Fast Travel (M69)
- **Dominio:** M69 es el salto directo pagado; M68 define las estaciones y las rutas del transporte. Regla: un destino vía M69 solo se muestra si la estación EXISTE y está desbloqueada (misma red).
- **Clave:** sin duplicar costes ni rutas: M68 vende "boleto de ruta" y M69 vende "teletransporte" (más caro, sin animación de viaje).

### 1.6 Viajes especiales y narrativos
- **Dominio:** viajes especiales (festivales M74, tours de luna M31) con su propia parada temporal y precio; viajes narrativos (M22/M23) sin coste y con diálogos a bordo (M21).
- **Clave:** los viajes especiales no entran en el grafo normal (aparecen programados en el calendario M29).

### 1.7 Rendimiento y validación
- **Dominio:** señalización en atlas (M46, batchable M61); paradas con instanciación ligera (M62); `validate_transport.gd` verifica: grafo de rutas acíclico válido, coincidencia señalización-mapa, costes contra M38, transiciones sin pérdida del jugador.
- **Clave:** red de transporte típica: 8-12 paradas, 15-20 rutas — sin problemas de rendimiento si se mantiene en una sola lista de datos (no nodos por parada).

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| Rutas como nodos físicos en cada escena | **Descartado** | Datos centrales (grafo) con mapa y señalización leyendo la misma fuente |
| Coste fijo por viaje | **Descartado** | Descuentos por amistad (M20) y por trayecto |
| Transición sin orientación al destino | **Descartado** | Regla "nunca perder al jugador" |
| Fast travel y transporte en un solo sistema | **Descartado** | M69 es salto directo; M68 es red de rutas (coordinados por estación) |
| Viajes largos siempre en tiempo real | **Descartado** | Montaje con fade; solo cercanos en real |
| Sin señalización física | **Descartado** | El plan maestro exige carteles y marcadores |

## 3. Decisiones del Módulo

1. **Grafo central de rutas** (`TransportStop` + `TransportRoute`) como única fuente de verdad.
2. **Capa de transporte en el mapa (M54)** con marcadores y rutas dibujadas.
3. **Señalización física** (carteles M46) que lee la misma red (sin discrepancia).
4. **Transición reutilizable** (M61) con reaparición orientada al destino.
5. **Coordinación con M69:** estaciones compartidas, sin duplicar costes.
6. **Viajes especiales/narrativos** en el calendario (M29/M74) con diálogos a bordo (M21).

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Señalización que contradice al mapa | Media | Medio | Misma fuente de datos + validador |
| Jugador perdido tras el viaje | Media | Alto | Reaparición orientada + cámara fija al destino |
| Costes arbitrarios | Media | Medio | Costes descontables por M20, definidos en M38 |
| Rutas duplicadas con M69 | Media | Medio | Estaciones compartidas por la misma red |
| Viajes que rompen el streaming | Media | Alto | Transición con carga previa (M61) antes de mover al jugador |
| Viajes especiales olvidados | Baja | Bajo | Registrados en el calendario (M29/M74) |
| Grafo con ciclos de precios | Baja | Medio | Validación del grafo (ruta corta, sin bucles absurdos) |