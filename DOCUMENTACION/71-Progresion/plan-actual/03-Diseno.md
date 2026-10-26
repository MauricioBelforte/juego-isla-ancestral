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

## 6. Specs de items degradados (definidos 2026-10-26, Reflection-Beam-1.0 T164)

- **MilestoneDefinition (L58):** schema: `milestone_id`, `nombre_i18n`, `descripcion_i18n`, `condicion`, `recompensas`, `dominio`. Implementación actual: diccionarios en `data/progresion/hitos.json` (sin clase dedicada ni campos i18n dedicados).
- **get_milestone(id) (L63):** contrato API pública O(1) lookup en `_hitost` (hoy solo acceso interno `_hitost[index]` + signals).
- **get_unlock/get_logro/get_titulo (L64):** mismo patrón O(1) por id (hoy inexistentes; acceso por signals).
- **AchievementDefinition (L85):** propiedad de M72; M71 expone evaluador (`evaluar_condicion`/`evaluar_pura`) y señales `progreso_hito_alcanzado`/`progreso_desbloqueado`.
- **Estadísticas mínimas (L99):** items_recolectados, items_crafteados, monedas_ganadas_total, monedas_gastadas_total, trueques_realizados, objetos_vendidos, donaciones, amistades_maximas, sellos, capitulos, dias_jugados — persistidos vía PlayerProfile (`incrementar`/`set_stat`/`get_stat`).
- **Curva temprana (L138):** desbloqueos frecuentes días 1-7 (cada 30-60 min); hoy los 10 hitos 'generales' de hitos.json no tienen frecuencia parametrizada — definir en catálogo.

## 7. Specs de items degradados (definidos 2026-10-26, Reflection-Beam-1.0 T165)

- **Curva media (L139):** desbloqueos espaciados semanas 2-4 (cada 2-4 días de juego).
- **Curva tardía (L140):** desbloqueos selectos post-capítulo 4 orientados a completitud.
- **Todo desbloqueable (L144):** sin elecciones excluyentes permanentes; progresión horizontal no bloquea contenido principal.
- **Flujo condición imposible (L171):** detección estática (`detectar_condiciones_imposibles_estaticas` L422) + dinámica (`_es_condicion_imposible` L434); reporte a M66 con ruta alternativa.
- **Hito reflejo por herramienta/nivel (L194/L195):** `nivel_herramienta_cambio` (L216) + `_evaluar_nivel_modulo_puro` (L351); condiciones `nivel_modulo(herramienta, ref, nivel)` en catálogo.
- **Consumo señal casa (L202/L203/L204):** `EventBus.nivel_casa_cambio(nivel)` (L178); reflejo vía `casa_manager.obtener_nivel_casa()` (duck-typing L371-372, L768-769); condiciones `nivel_modulo(casa, ref, nivel)` en evaluador (genérico) — pendiente en datos.
- **Amistad (L210/L211):** `integrar_amistad` refleja amistad por NPC; stat 'amigos en nivel N' y desbloqueos sociales (trueques únicos, eventos) sin bloquear contenido principal.
- **Sellos/capítulos (L221-L225):** `sello_historia(sello_id)` y `capitulo_historia(capitulo_id)` como condiciones (hoy inexistente en evaluador; reflejo por sello existe en hitos.json: `hito_sello_ceniza_sala1/2`, `hito_sellos_4`).
- **Desbloqueos por sello (L226):** condicionados a sellos con vigilancia M66; 5 finales de M22 como hitos de cierre (hoy 0 en hitos.json).
- **Postgame (L227/L246):** coordinación con M75 para re-priorización de metas; condiciones no cumplibles reportadas a M66.
- **Notificaciones (L250):** señales de hito (L20) sin cola priorizada en M53 — definir contrato.

## 8. Specs de items degradados (definidos 2026-10-26, Reflection-Beam-1.0 T166)

- **Condiciones RefCounted (L267):** condiciones evaluadas como diccionarios puros (`evaluar_pura` L260) sin pool de RefCounted; el patrón del item no está implementado (decisión de diseño: diccionarios puros).
- **02-Analisis.md (L275):** existe en plan-actual con D1-D10 documentadas (verificado Log 623).
- **05-Checklist.md (L279):** existe con 213 ítems (>130); 45 quedan [?] (en curso). Completitud parcial.
- **Prueba condición imposible (L292):** detección estática en editor (`detectar_condiciones_imposibles_estaticas` L422) + ruta alternativa en runtime; prueba dedicada pendiente.
- **Prueba determinismo (L295):** misma partida → mismos hitos en el mismo orden; test dedicado pendiente (test_progresion.gd cubre evaluación/condiciones).
- Consumo UI de hitos_proximos() para sugeridor M53
