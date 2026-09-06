**Modelo:** glm-5.3-flash (último modificador; arquitectura real consolidada de iter. 1-6 multiagente)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-04

# 03-Diseno.md — Módulo 71: Progresión (plan-actual, arquitectura REAL vigente)

> ⚠️ Este documento reemplaza al diseño prevista en plan-inicial (`res://progresion/`):
> la implementación real vive en `res://scripts/progresion/` con JSON data-driven
> (no .tres), consolidando iteraciones de 6 agentes (deepseek, minimax, agnes,
> glm-5.3-flash ×3). Solo se describe lo que EXISTE y funciona (tests 0 fallos).

## 1. Arquitectura real

```
res://scripts/progresion/
├── progression_manager.gd    (autoload "ProgressionManager": orquestador)
├── player_profile.gd         (autoload "PlayerProfile": estadísticas/reputación)
└── data/progresion/hitos.json (catálogo data-driven de hitos, 15 hitos)

res://scripts/logros/         (M72: consumo del evaluador M71 — ver su módulo)
```

### ProgressionManager (autoload)
- **Catálogo**: `hitos.json` → `_hitost` (id → {nombre, condicion, recompensas, dominio}).
- **Índice dirty-flag**: `_condiciones_por_hito` (stat_id → hitos que dependen) — reevaluación O(1) por evento.
- **Evaluador**: `evaluar_condicion()` con 10 tipos del vocabulario §3.6 (stat_min, dias_jugados, sello_historia, capitulo_historia, riqueza_acumulada, primera_vez, hito_previo, coleccion_completa, nivel_modulo, compuesta AND/OR/NOT).
- **Predicado puro**: `evaluar_pura(cond, estado)` para tests sin autoloads (agnes iter. 3).
- **Caché de condiciones**: `evaluar_condicion_id()` con `_evaluacion_cache` (máx 64) + `reevaluar_sucias()` (agnes).
- **RF10 imposibles**: `detectar_condiciones_imposibles_estaticas()` (catálogo) y `_dinamicas()` (estado del jugador) — reporte a M66.
- **RF12 títulos**: `_otorgar_titulo()` idempotente desde recompensas tipo "titulo" + API pública + persistencia (glm Log 605).
- **Persistencia M59**: sección "progresion" versionada; deep-copy antialiasing (Log 553); restore SIN re-emisión de señales (§2.3).

### PlayerProfile (autoload)
- Estadísticas totales y del día (`incrementar/set_stat/get_stat`, `reset_dia` vía day_started M29).
- Primeras veces (`primera_vez`/`marcar_primera_vez`) — radar M53.
- Reputación comunitaria: 60% amistad (M20) + 40% contribución (ventas/trueques M38) — nunca bloqueante.
- Guardar/cargar delegado al ProgressionManager (un solo punto de guardado).

## 2. Contratos de señales (tabla emisor → consumidores)

| Señal (emisor: ProgressionManager) | Consumidores | Uso |
|---|---|---|
| `progreso_hito_alcanzado(id, nombre, recompensas)` | M72 (evaluar logros), M53 (notificación), M103 (log DOM-PROG-HITO) | Hito alcanzado, con recompensas para presentación |
| `progreso_desbloqueado(id, tipo, valor)` | M72, M53, M103 | Desbloqueo cosmético/info activado |
| `progreso_primera_vez(actividad_id)` | M53 (radar), M104 | Radar de primeras veces |
| `progreso_resumen_cargado(hitos, desbloqueos)` | M53/M92 (jugador veterano, sin re-emisión) | Carga de partida completada |
| `progreso_titulo_obtenido(titulo_id, nombre)` | M53 (flash de título), M72 | RF12: título otorgado |
| PlayerProfile → ninguna pública | (lectura directa por M71/M72 vía get_stat) | Estadísticas consultables |

**Consumo de entrada** (ProgressionManager escucha): EventBus.inventory.item_added, economy.purchase_done, npc.gift_given, quest.prereq_met/quest_completed, npc.friendship_level_up, travel.travel_started, calendar.day_started; ToolController (M13, vía conectar_tool_controller desde escena).

## 3. Flujos

### 3.1 Evento → hito (event-driven, nunca frame)
```
captura/compra/regalo/sello… → EventBus (dominio)
→ ProgressionManager._stat() → PlayerProfile.incrementar + dirty
→ _reevaluar(stat_id) → solo hitos dependientes (O(1))
→ evaluar_condicion() → marcar_hito() [idempotente]
→ señales → M72 evalúa logros / M53 notifica
```

### 3.2 Carga: jugador nuevo vs veterano
```
restore_save_data(data)
→ hitos conocidos restaurados; desconocidos purgados con log (migración)
→ títulos restaurados (clave opcional v1→v2)
→ profile.cargar() SIN re-emitir señales (§2.3 idempotencia)
→ progreso_resumen_cargado → M53 muestra resumen de veterano
Jugador nuevo: catálogo completo, estadísticas en cero, onboarding M92.
```

### 3.3 Re-evaluación retroactiva y gating
- RF10: condiciones imposibles reportadas a M66 con logs accionables (estáticas en boot + dinámicas por consulta).
- Sellos M22: fuente de verdad §2.2 — M71 SOLO refleja (sello_historia consulta Historia.sello_marcado).

## 4. Restricciones vigentes (cumplidas por el código)
- Godot 4.x GDScript tipado; JSON data-driven (no .tres — decisión iter. 1); sin reloj del SO (días M29); sin red; sin polling por frame; UI desacoplada por señales; módulos estables M19/M21/M29/M30/M32 no tocados.

## 5. Pendientes conocidos (con dueño)
- RF1 registry en .tres (JSON hoy — migración si el volumen lo exige)
- RF8 registro base de logros (M72 lo cubre con su catálogo)
- Contenido de 15 → ~40 hitos (curaduría con M93 balance)
- Consumo UI de hitos_proximos() para sugeridor M53
