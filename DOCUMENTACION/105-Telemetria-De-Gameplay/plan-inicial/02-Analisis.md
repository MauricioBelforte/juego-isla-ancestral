**Modelo:** SWE-1.6
**Plataforma:** DEVIN

# 02-Analisis.md — Módulo 105: Telemetría de Gameplay

## 1. Análisis de los puntos del plan maestro (sección 104)

| # | Punto | Resolución |
|---|---|---|
| 1 | Medir primer tutorial completado | ✅ Evento telemetría: tutorial_first_completion |
| 2 | Medir primer recurso recolectado | ✅ Evento telemetría: resource_first_collected |
| 3 | Medir primera casa | ✅ Evento telemetría: house_first_built |
| 4 | Medir primer NPC | ✅ Evento telemetría: npc_first_interaction |
| 5 | Medir primer puzzle | ✅ Evento telemetría: puzzle_first_completed |
| 6 | Medir primer Sello | ✅ Evento telemetría: seal_first_obtained |
| 7 | Medir primer viaje | ✅ Evento telemetría: travel_first_completed |
| 8 | Medir primera isla | ✅ Evento telemetría: island_first_discovered |
| 9 | Medir primer museo | ✅ Evento telemetría: museum_first_visited |
| 10 | Medir primer festival | ✅ Evento telemetría: festival_first_participated |
| 11 | Medir primer proyecto comunitario | ✅ Evento telemetría: community_project_first_completed |
| 12 | Medir tiempo hasta primer descubrimiento | ✅ Métrica: time_to_first_discovery |
| 13 | Medir tiempo hasta primer viaje | ✅ Métrica: time_to_first_travel |
| 14 | Medir puzzle abandonado | ✅ Evento telemetría: puzzle_abandoned |
| 15 | Medir dificultad percibida | ✅ Encuesta post-puzzle: difficulty_perceived |
| 16 | Medir zonas ignoradas | ✅ Métrica: zones_ignored |
| 17 | Usar datos para mejorar diseño | ✅ Análisis de datos para identificar problemas de diseño |

## 2. Eventos de telemetría

**Eventos clave (17 eventos):**
- tutorial_first_completion: cuando el jugador completa el tutorial por primera vez
- resource_first_collected: cuando el jugador recolecta el primer recurso
- house_first_built: cuando el jugador construye la primera casa
- npc_first_interaction: cuando el jugador interactúa con el primer NPC
- puzzle_first_completed: cuando el jugador completa el primer puzzle
- seal_first_obtained: cuando el jugador obtiene el primer Sello
- travel_first_completed: cuando el jugador hace el primer viaje entre islas
- island_first_discovered: cuando el jugador descubre la primera isla
- museum_first_visited: cuando el jugador visita el primer museo
- festival_first_participated: cuando el jugador participa en el primer festival
- community_project_first_completed: cuando el jugador completa el primer proyecto comunitario
- puzzle_abandoned: cuando el jugador abandona un puzzle sin completar
- difficulty_perceived: encuesta post-puzzle sobre dificultad percibida (1-5)
- zone_entered: cuando el jugador entra en una zona geográfica
- zone_exited: cuando el jugador sale de una zona geográfica
- session_started: cuando el jugador inicia una sesión de juego
- session_ended: cuando el jugador termina una sesión de juego

## 3. Métricas de tiempo

**Métricas de tiempo:**
- time_to_first_discovery: tiempo desde session_started hasta primer descubrimiento importante (ej: primer Sello, primera isla)
- time_to_first_travel: tiempo desde session_started hasta primer viaje entre islas
- time_to_first_house: tiempo desde session_started hasta primera casa construida
- time_to_first_puzzle: tiempo desde session_started hasta primer puzzle completado
- time_to_first_seal: tiempo desde session_started hasta primer Sello obtenido
- session_duration: duración de cada sesión de juego

## 4. Detección de abandonos

**Puzzle abandonado:**
- El jugador inicia un puzzle pero no lo completa
- El jugador sale del área del puzzle sin completarlo
- El jugador no interactúa con el puzzle por X minutos
- Se registra como puzzle_abandoned con timestamp y puzzle_id

**Zonas ignoradas:**
- El jugador nunca entra en ciertas zonas geográficas
- El jugador entra pero sale rápidamente (< 1 minuto)
- Se registra como zone_ignored con zone_id y timestamp

## 5. Dificultad percibida

**Encuesta post-puzzle:**
- Encuesta opcional después de completar un puzzle
- Escala 1-5 (1: muy fácil, 5: muy difícil)
- Pregunta: "¿Qué tan difícil te pareció este puzzle?"
- Se registra como difficulty_perceived con puzzle_id y rating

## 6. Uso de datos para mejorar diseño

**Análisis de datos:**
- Identificar puzzles con alta tasa de abandono → revisar dificultad
- Identificar zonas ignoradas → revisar diseño de esas zonas
- Identificar eventos clave que muchos jugadores no alcanzan → revisar accesibilidad
- Identificar tiempos inusualmente largos para eventos clave → revisar diseño
- Ajustar balance basado en datos reales

## 7. Opt-in y GDPR

**Opt-in explícito:**
- El jugador debe aceptar telemetría explícitamente
- Prompt en primer inicio del juego: "¿Quieres compartir datos anónimos de gameplay para ayudarnos a mejorar el juego?"
- El jugador puede opt-out en cualquier momento desde settings
- Telemetría está deshabilitada por defecto

**GDPR compliance:**
- Datos anonimizados (sin identificadores personales)
- No se recolectan nombres, emails, IPs
- Solo se recolectan datos de gameplay y comportamiento
- El jugador puede solicitar eliminación de sus datos
- Política de privacidad documentada

## 8. Integración con M104 (Analytics)

**Integración:**
- M104 (Analytics) se encarga de envío de datos
- M105 (Telemetría de Gameplay) genera eventos de gameplay
- M105 envía eventos a M104 para batching y envío
- M104 se encarga de anonimización y GDPR compliance
- M104 se encarga de caché local y envío batch

## 9. Integración con M71 (Progresión)

**Integración:**
- M71 (Progresión) puede notificar a M105 cuando ocurren eventos clave
- M105 registra el timestamp del evento
- M105 no afecta la lógica de progresión de M71
- M105 es un observador pasivo de eventos de M71

## 10. Integración con M22 (Historia Principal)

**Integración:**
- M22 (Historia Principal) puede notificar a M105 cuando el jugador completa capítulos
- M105 registra progreso de historia principal
- M105 puede identificar capítulos donde muchos jugadores se atascans

## 11. Integración con M102 (Bug Tracking)

**Integración:**
- Datos de telemetría pueden identificar bugs emergentes
- Si muchos jugadores abandonan un puzzle en el mismo punto → posible bug
- Si tiempos anormales para eventos clave → posible bug de rendimiento
- M105 puede generar issues en M102 basados en patrones de datos
