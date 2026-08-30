**Modelo:** ox-alpha
**Plataforma:** Cline

# 02-Analisis.md — Módulo 105: Telemetría de Gameplay

> **Reescritura 2026-08-29 sobre arquitectura REAL.** El análisis original de DEVIN
> asumía APIs inexistentes; las decisiones se replantearon así:

## 1. Decisiones de arquitectura (por qué cambió el plan)

| Decisión DEVIN (plan original) | Decisión real (este plan) | Motivo |
|---|---|---|
| `class_name GameplayTelemetry` | Autoload `TelemetryDirector` **sin class_name** | §9.41/§9.17 guía Godot: autoload + class_name colisiona; Godot 4.7 reserva "Telemetry" |
| `GameState.get_setting()` | `ConfigFile user://settings/telemetry.cfg` | No existe GameState de settings en el proyecto |
| `ServiceLocator.get_service()` | `ServiceRegistry.get_service("telemetry")` | La capa de servicios real es M07 ServiceRegistry |
| `AnalyticsService.record_event()` | `AnalyticsDirector.registrar_evento(tipo, datos)` | La API real de M104 es esa, con tipos "telemetry"/"metrica" |
| Storage propio `user://telemetry/*.json` | **Sin storage propio** — M104 ya hace batch/agregado/offline | §15 modularidad: no duplicar responsabilidades |
| `session_id` propio generado | Sin session_id propio: M104 ya genera hash SHA256 rotativo 24h | Privacidad: evitar PII-adyacente duplicado |

## 2. Resolución de los 17 puntos

Todos los RF1-RF17 del plan original se mantienen (ver 01-Requerimientos). La resolución
es la implementada en `scripts/telemetry/telemetry_director.gd`:
- RF1-RF11: métodos `track_*_first_*()` con deduplicación por sesión (`_tracked` Dictionary).
- RF12-RF13: métricas `time_to_first_discovery` / `time_to_first_travel`, registradas una sola vez (`_registrar_metrica_hasta`).
- RF14: timer de 1s; abandono si un puzzle iniciado supera 300s (constante `PUZZLE_ABANDONO_SEGUNDOS`).
- RF15: `track_difficulty_perceived(puzzle_id, rating)`; la señal UI la dispara.
- RF16: `enter_zone`/`exit_zone` acumulan duración; `zone_ignored` si <60s (`ZONA_IGNORADA_SEGUNDOS`).
- RF17: todo viaja a M104 (tipos "telemetry" y "metrica") que ya agrega y persiste.

## 3. Integraciones reales

- **M104 (Analytics):** única vía de salida. Inyección de stub posible para tests
  (`analytics_service`). El opt-out de telemetría propaga `establecer_opt_out(true)` a M104.
- **M103 (GameLogger):** logging con `GameLogger.Category.ANALYTICS` (info/debug).
- **UI futura (M53/M91):** señales emitidas para consumo externo: `cambio_opt_in`,
  `evento_rastreado`, `solicitar_encuesta`. El prompt de opt-in y la encuesta son UI, no V0.
- **M71/M22/M102 (plan original):** integraciones diferidas; cuando existan, deben llamar
  a los métodos `track_*` del director (hooks). No son prerequisitos de este módulo.

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
