**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 29: Tiempo y Calendario

## 1. Carácter del Componente

Módulo **totalmente delegable para implementación** por otro agente: es un servicio puro (sin voxel, sin assets, sin física). Implementable en cuanto exista el esqueleto del proyecto (M1) y el ServiceLocator (M07), o incluso en paralelo con su propio scaffolding mínimo.

**06-Plan-Testings.md:** NO aplica hoy (la edición de tests unitarios del GameClock se implementa junto con M112 Testing Automático — el cron de fechas se cubre ahí). Se recomienda incluir tests del calendario (bisiesto no aplica: años de 336 días fijos).

## 2. Archivos involucrados (implementación)

### Scripts
| Archivo | Propósito | Estado |
|---|---|---|
| `scripts/time/game_clock.gd` | Servicio GameClock — autoridad del tick de tiempo. Registro como autoload | ✅ Implementado |
| `scripts/time/time_calendar.gd` | Fachada unificada (autoload "TimeCalendar"). Expone API pública: `get_hora()`, `get_minuto()`, `get_estacion()`, `es_de_dia()`, `es_noche()`, `formatear_hora()`, `obtener_eventos_hoy()`, `obtener_proximos_eventos()`. Conecta a GameClock para sincronizar cache. Implementa ISaveProvider (M59) | ✅ Implementado |
| `scripts/time/festival_data.gd` | `FestivalData` (class_name): datos de eventos periódicos. 4 festivales estacionales, 1 anual, 2 visitas semanales, 2 eventos mensuales, cumpleaños jugador. Cargado desde `festivals.tres`. Métodos: `obtener_todos_eventos()`, `obtener_eventos_fecha()`, `obtener_proximos_eventos()` | ✅ Implementado |
| `scripts/time/time_config.gd` | Configuración de constantes temporales (loadado como `time_config.tres`) | ✅ Implementado |

### Datos
| Archivo | Propósito |
|---|---|
| `data/time/time_config.tres` | Constantes de duración (knobs): min_por_dia, dias_por_mes, meses_por_anio, hora_amanecer, hora_atardecer, etc. |
| `data/time/festivals.tres` | Festivales + cumpleaños (contenido M74) |

## 3. Contratos de integración

- **Registro:** `ServiceRegistry.register("game_clock", game_clock)` (M07).
- **Salida:** señales `dia_cambio`, `hora_cambio`, `estacion_cambio`, `evento_activado` → EventBus.time (M07).
- **Persistencia:** `GameState.M29 = { fecha, hora, eventos_visitados, proximo_evento }` (M59).
- **Consumidores:** M30 (reloj UI), M31 (iluminación), M33 (cultivos), M19 (NPC rutinas), M74 (eventos), M36 (fauna).

## 4. Pendientes del módulo (con dueño)

| Pendiente | Dueño |
|---|---|
| Implementación del servicio GameClock + tests unitarios | **AGENTE DELEGADO** (módulo delegable) |
| Calibración de duración del día (24 min) por playtest | M114 (playtest) |
| Contenido de festivales (planos, decoración, diálogos) | M74 + M21 (contenido) |
| Nombres de meses/días finales | M149 (nomenclatura) |
| Integración con la cama (avance temporal) | M31 (cama) |

## 5. Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 06:40:00
**Estado:** Completado (diseño; implementación delegada)

### Lo que hice
- Resolví los 24 puntos de la sección 28 del plan maestro.
- Diseñé el servicio GameClock con API completa y calendario de Aurora (día 24 min, mes 28 días, año 336 días, 4 estaciones).
- Catálogo de eventos periódicos completo (diario → anual) con regla anti-frustración (repetibles).
- Contrato de persistencia y tabla de consumidores.

### Lo que NO pude hacer (honestidad obligatoria)
- Implementar el servicio → queda para el agente delegado (es el propósito de este módulo).
- Contenido de festivales → M74/M21.
- Nombres finales de meses → M149.

### Recomendaciones para el próximo agente (implementador)
- Usar la API pública del 03-Diseno sin modificarla (los consumidores están diseñados contra ella).
- El reloj NO debe correr offline ni retroceder; solo avanza en sesión con pausas explícitas.
- Incluir tests: cambio de día/semana/mes/estación/año y eventos (día 336 → año 2).
## Notas del Agente — Iteración 1 (auditoría 47 pendientes + semilla H120)

**Modelo:** GLM-5.3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-11 21:20 → 22:30
**Estado:** Completado (194/195, 1 [?] dueño M53)
**Log:** 824

### Lo que hice

- **Auditoría de los 47 [ ]** que Hy3 detectó como "gap de marcado" en su QA del 2026-09-01: cada ítem verificado contra el código real (línea/test) y marcado con evidencia. La sección "Estado real de implementación" del propio checklist (2026-08-28) ya documentaba la mayoría — mi trabajo fue tender el puente formal entre template base y estado real.
- **Cerré la ÚNICA brecha real encontrada:** H120 semilla de tiempo por partida (`usar_semilla_tiempo` era una flag muerta en config).
  - `GameClock._semilla_partida` + `_asegurar_semilla_partida()` (randi() del motor — C56-safe).
  - `valor_diario(ns_consumidor, minimo, maximo)` — entero determinista del día por namespace.
  - `rng_diario(ns_consumidor)` — RandomNumberGenerator reproducible del día.
  - Hash FNV-1a 32 bits: semilla_partida + dia_absoluto + namespace (estable entre sesiones).
  - Persistencia: `"semilla_partida"` en el save sección "time" (get_save_data/restore_save_data).
  - Flag `usar_semilla_tiempo` del config: true = por partida (default), false = 0 = determinista global para tests/QA.
- `test_semilla_iter1.gd` NUEVO: 25 checks (determinismo, namespaces independientes, secuencias reproducibles, semilla en save, día-dependencia, señales G, API 17 métodos, nombres, formatos, ventana aviso).

### Lo que NO pude hacer (honestidad obligatoria)

- **[?] Flecha indicadora en el HUD (ítem D):** widget visual de M53 — M29 expone `evento_proximo` y `formatear_hora()`, pero la flecha no existe y soy solo-texto (§16 guía 10).
- **El bug C56 del caso_reloj es PREEXISTENTE** (A/B git stash: falla igual sin mis cambios): el scan anti-reloj-SO marca falsos positivos de scripts de infra nuevos (`scripts/ci/cicd_manager.gd` usa Time.get_unix_time_from_system y `ci/` no está en la whitelist; el propio test contiene los strings-patrón). Registrado en 11-BUGS.md con fix sugerido para el dueño de M30. Mi semilla NO dispara el scan (usa randi()).

### Decisiones

1. **Entropía vía randi() global del motor, no Time.* :** la primera versión usaba `Time.get_unix_time_from_system()` y el escáner C56 la marcó — regla de oro del módulo: el gameplay NUNCA lee el reloj del SO, ni siquiera una vez por partida. randi() es la fuente idiomática de Godot 4.
2. **FNV-1a 32 bits con módulo 2^31:** hash determinista entre sesiones (el hash() de Godot puede cambiar entre versiones del motor); 31 bits evita overflows en multiplicaciones de consumidores.
3. **API aditiva:** valor_diario/rng_diario se AÑADEN al contrato estable G — cero rupturas para consumidores (verificado por regresiones).
4. **Los ítems F (consumo) se marcan por el HOOK, no por el contenido:** M29 entrega señales/consultas; la rutina/cultivo/pesca es contenido de M19/M33/M34 — cada ítem documenta quién consume qué.

### Recomendaciones para el próximo agente

- El dueño de M30 debería aplicar el fix del bug C56 (whitelist `scripts/ci/` + excluir el propio test del scan + print de positivos) — 15 min de trabajo, desbloquea la señal limpia de la regresión de tiempo.
- M29 está listo para QA cruzado §21.8 (Hy3): reproducir con test_semilla_iter1 (25/25) + test_calendario (13/13) + verificar el [?] único con el equipo de UI.
- Consumidores futuros de la semilla: usar `GameTime.valor_diario("<tu_modulo>", min, max)` para variación diaria determinista (respawn de peces M34, eventos ambientales M74, etc.).
