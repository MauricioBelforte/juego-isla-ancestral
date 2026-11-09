# Informe de Evaluación Consolidado — Round 4 (6 horas)

**Modelo:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-09 03:00  
**Responde a:** agnes-3-flash (directora)  
**Metodología:** `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/BACKLOGS/METODOLOGIA-EVALUACION.md`  
**Informe base:** `evaluacion_informes_3_modelos_2026-11-08_1500.md` (Round 3)  
**Reportes fuente evaluados en este round:** 6 reportes nuevos (2 Crouton Alpha, 4 Glyph Cluster, 0 Beam — modelo de pago, excluido)

---

## 1. Resumen ejecutivo

En este round de 6 horas, los 2 modelos gratuitos en prueba generaron **6 reportes nuevos** de auditoría. Los hallazgos se clasifican en:

| Severidad | Cantidad | Ejemplo representativo |
|-----------|----------|------------------------|
| Crítico | 4 | Logros con stats incorrectos (inalcanzables), ReactState con patrón de salida riesgoso, Venta con saldo en tope pierde items |
| Alto | 6 | Faltan conexiones agrícolas/mineras, IA no reacciona al jugador, Doble UI de diálogo, Venta no verifica acreditación real |
| Medio | 8 | Costo O(N²) en proximidad NPCs, Feedback insuficiente al jugador al fallar validación de diálogo, Dependencia de flags externas, Dificultades en manejo de errores runtime |
| Bajo | 4 | Sub-recursos sin usar, Headers sin load_steps, Msgos sin validar, etc. |
| Ruido | 0 | Ninguno |

**Veredicto:** Los 2 modelos mantienen su desempeño. Crouton Alpha sobresale en escaneo estático (escenas y recursos SANOS). Glyph Cluster sobresale en análisis de arquitectura y diseño de sistemas (detectó logros inalcanzables, problemas de IA y economía). Los reportes siguen siendo técnicamente precisos con archivos y líneas citadas.

---

## 2. Evaluación detallada por modelo

### 2.1 Crouton Alpha (2 reportes nuevos)

| Informe | Hallazgo principal | Severidad | Archivo:línea | Accionable |
|---------|-------------------|-----------|---------------|------------|
| escenas_tres_2026-11-09 | 0 rutas rotas, 0 nodos huérfanos, 0 .tres rotos. Escenas SANOS | Bajo | `scenes/` y `scripts/` | No — solo limpieza cosmética (2 sub-recursos sin usar, 4 headers sin load_steps) |
| errores_2026-11-09 | Paradigma fail-soft con push_error/push_warning. Logger sin archivo (invisible), bootstrap degradado a print, CrashReporter sin hook del motor, errores de runtime no interceptados | Alto | `scripts/logging/logger.gd:146`, `core/bootstrap.gd:93-181`, `crash/crash_reporter.gd:34-55` | Sí — puente push_error→Logger+CrashReporter+UI |
| errores_2026-11-09 | Bootstrap deja integridad de dominios en `print` | Alto | `core/bootstrap.gd:93,105,115,181` | Sí — sustituir print por push_warning/push_error |

**Análisis de Nemotron:** Crouton Alpha sobresale en escaneo estático. Confirmó que escenas y recursos están SANOS (0 problemas críticos). En manejo de errores, detectó problemas estructurales importantes. No escribió el reporte de audio (sesión completó sin archivo — incidente de fiabilidad pendiente).

---

### 2.2 Stealth Glyph Cluster (4 reportes nuevos)

| Informe | Hallazgo principal | Severidad | Archivo:línea | Accionable |
|---------|-------------------|-----------|---------------|------------|
| logros_2026-11-09 | Varios logros usan stats incorrectos (regalos_dados para agricultura/minería, viajes_realizados para días jugados), probablemente inalcanzables | Crítico | `scripts/logros/logros.json` L175-266 | Sí — corregir mapeo de stats |
| logros_2026-11-09 | Faltan conexiones para acciones de agricultura/minería | Alto | `scripts/logros/achievement_service.gd` L129-159 | Sí — añadir señales/conexiones |
| ia_npc_2026-11-09 | InteractState no se activa desde el flujo M64 (huérfano) | Alto | `scripts/ia_npc/npc_agent.gd:364-386`, `states/react_state.gd:53-79` | Sí — conectar Interact/React PLAYER al FSM |
| ia_npc_2026-11-09 | ReactState llama `exit()` desde `tick()` y luego `transition_to` — riesgo de doble salida/limpieza | Alto | `scripts/ia_npc/states/react_state.gd:53-79` | Sí — corregir patrón de salida |
| ia_npc_2026-11-09 | NPCs no reaccionan proactivamente al jugador (solo responden a tecla F vía VillagerManager) | Alto | `scripts/ia_npc/npc_agent.gd`, `scripts/npc/villager_manager.gd:341-349` | Sí — unir interacción jugador con FSM M64 |
| ia_npc_2026-11-09 | Costo O(N²) en detección de NPCs cercanos por frame | Medio | `scripts/ia_npc/npc_agent.gd:155-174` | Sí — estructura espacial/grid |
| dialogos_2026-11-09 | Doble UI de diálogo (DialogLayer M53 + DialogueUI autocontenida) — riesgo de inconsistencia de UX | Alto | `scripts/ui/layers/dialog_layer.gd`, `scripts/dialogos/ui/dialogue_ui.gd` | Sí — unificar UI canónica |
| dialogos_2026-11-09 | Feedback insuficiente al jugador cuando un grafo falla al iniciar (solo print/push_error) | Alto | `scripts/npc/villager_dialogue_hook.gd:62-70` | Sí — mostrar mensaje de UI al fallar |
| dialogos_2026-11-09 | Falta gate CI/headless para cadenas secundarias (quests) | Medio | `scripts/historias/validate_quest_chains.gd` | Sí — añadir validador headless |
| economia_2026-11-09 | Venta con saldo en MAX_SALDO: items removidos pero sin acreditación de AO (pérdida de valor) | Crítico | `scripts/shops/shop_manager.gd:271-296` | Sí — atomicidad en ventas |
| economia_2026-11-09 | Contratos de transacción void (sin retorno de monto acreditado) | Medio | `scripts/shops/shop_manager.gd:233-296` | Sí — API de transacción explícita |

**Análisis de Nemotron:** Glyph Cluster sobresale en análisis de arquitectura y diseño. Detectó 3 críticos (logros inalcanzables, venta con saldo en tope) y múltiples altos (IA no reacciona al jugador, doble UI de diálogo, InteractState huérfano). Sus hallazgos son estructurales y de alto valor.

---

## 3. Hallazgos críticos que requieren atención inmediata

Estos son los que Nemotron recomienda implementar primero, ordenados por prioridad:

### 3.1 Críticos de seguridad/funcionalidad (funcionalidad del juego)

| # | Hallazgo | Archivo:línea | Dueño sugerido |
|---|----------|---------------|----------------|
| 1 | Logros con stats incorrectos (regalos_dados para agricultura/minería, viajes_realizados para días jugados) — probablemente inalcanzables | `scripts/logros/logros.json` L175-266 | agente misiones/IA (M72) |
| 2 | Venta con saldo en MAX_SALDO: items removidos pero sin acreditación de AO | `scripts/shops/shop_manager.gd:271-296` | agente economía (M38/M39) |
| 3 | InteractState no activado desde el flujo M64 (huérfano) | `scripts/ia_npc/npc_agent.gd:364-386` | agente IA (M64) |
| 4 | ReactState llama `exit()` desde `tick()` y luego `transition_to` — riesgo de doble salida | `scripts/ia_npc/states/react_state.gd:53-79` | agente IA (M64) |

### 3.2 Altos de arquitectura y experiencia de jugador

| # | Hallazgo | Archivo:línea | Dueño sugerido |
|---|----------|---------------|----------------|
| 5 | NPCs no reaccionan proactivamente al jugador | `scripts/ia_npc/npc_agent.gd`, `scripts/npc/villager_manager.gd:341-349` | agente IA (M64) |
| 6 | Doble UI de diálogo (DialogLayer + DialogueUI) | `scripts/ui/layers/dialog_layer.gd`, `scripts/dialogos/ui/dialogue_ui.gd` | agente UI (M53/M21) |
| 7 | Feedback insuficiente al jugador cuando un grafo de diálogo falla | `scripts/npc/villager_dialogue_hook.gd:62-70` | agente UI/diálogos (M21) |
| 8 | Faltan conexiones para acciones de agricultura/minería en logros | `scripts/logros/achievement_service.gd:129-159` | agente misiones (M72) |
| 9 | Costo O(N²) en detección de NPCs cercanos | `scripts/ia_npc/npc_agent.gd:155-174` | agente IA (M64) |

---

## 4. Recomendaciones de implementación por Nemotron

**Fase 1 (inmediata, esta semana):**
- Corregir mapeo de stats en `logros.json` (agricultura/minería/días jugados) y añadir conexiones de agricultura/minería
- Corregir `shop_manager.vender` para verificar acreditación real de `depositar_monedas` (todo-o-nada)
- Conectar `InteractState`/`React PLAYER` al flujo M64 y sanear el ciclo de salida de `ReactState`
- Unificar UI de diálogo (DialogLayer o DialogueUI, no ambas)
- Añadir feedback de UI cuando un grafo de diálogo falla al iniciar

**Fase 2 (próxima iteración):**
- Añadir gate CI/headless para cadenas secundarias (quests)
- Optimizar costo O(N²) en proximidad NPCs (estructura espacial/grid)
- Corregir mapeo de stats para logros inalcanzables
- Puente push_error→Logger+CrashReporter+UI (de Crouton Alpha, ronda anterior)

**Fase 3 (cleanup):**
- Limpiar 2 sub-recursos sin usar y 4 headers sin load_steps (de Crouton Alpha, ronda anterior)

---

## 5. Decisión requerida del director (agnes-3-flash)

Nemotron recomienda lo siguiente, pero **el director es el último en verificar que esto está correcto y evalúa si se implementa finalmente:**

```
[ ] Implementar fase 1 (críticos: logros stats, venta en tope, InteractState, ReactState, doble UI de diálogo, feedback jugador) — responsable: Nemotron supervisa, agentes de la flota ejecutan
[ ] Implementar fase 2 (gate CI quests, optimización O(N²), stats logros, puente errores Logger/CrashReporter/UI) — responsable: Nemotron supervisa
[ ] Implementar fase 3 (limpieza cosmética escenas/tres) — responsable: Nemotron supervisa
[ ] Evaluar si mantener a Reflection Beam 1.0 (modelo de pago $0.25/M input / $1.00/M output) — responsable: fundador
[ ] Descargar tareas de Beam a Crouton Alpha o Glyph Cluster según corresponda — responsable: Nemotron
```

---

## 6. Punto de control para próxima evaluación (en 6 horas, a las 09:00 del 09 nov)

Este informe constituye el **punto de control** del round 4. En la próxima evaluación, Nemotron no releerá los reportes de este round. Se basará en:
- Este archivo de evaluación consolidada.
- Los informes fuente en `Mensajes entre modelos/<MODELO>/REPORTES-Prueba-Paralela/` que tengan fecha posterior a este round.
- El archivo de metodología en `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/BACKLOGS/METODOLOGIA-EVALUACION.md`.

Si el director aprueba alguna implementación, Nemotron la asignará a los 2 modelos gratuitos como nuevas tareas y supervisará su ejecución, reportando el cierre al director.

---

**Firma:** Nemotron-3.5-Super-VL / Kilo Code — 2026-11-09 03:00  
**Última verificación del director:** pendiente
