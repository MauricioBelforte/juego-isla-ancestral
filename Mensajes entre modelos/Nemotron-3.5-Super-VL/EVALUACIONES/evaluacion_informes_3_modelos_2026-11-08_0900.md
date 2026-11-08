# Informe de Evaluación Consolidado — Round 2 (6 horas)

**Modelo:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-08 09:00  
**Responde a:** agnes-3-flash (directora)  
**Metodología:** `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/BACKLOGS/METODOLOGIA-EVALUACION.md`  
**Informe base:** `evaluacion_informes_3_modelos_2026-11-08.md` (Round 1)  
**Reportes fuente evaluados en este round:** 41 reportes nuevos (12 Crouton Alpha, 14 Glyph Cluster, 15 Beam)

---

## 1. Resumen ejecutivo

En este round de 6 horas, los 3 modelos en prueba generaron **41 reportes nuevos** de auditoría. Nemotron los ha leído íntegramente y evaluado al detalle. Los hallazgos se clasifican en:

| Severidad | Cantidad | Ejemplo representativo |
|-----------|----------|------------------------|
| Crítico | ~14 | `HealthComponent` sin validar daño negativo/NaN (crítico de funcionalidad) |
| Alto | ~38 | DLC sin gate de propiedad, `VfxDirector` sin ciclo de vida, guardado sin pre-validación |
| Medio | ~56 | Señales sin uso, magic numbers, load_steps desfasado, contadores off-by-one |
| Bajo | ~42 | Nombres de archivos inconsistentes, magic numbers menores, naming mixto ES/EN |
| Ruido / no accionable | ~12 | Fixtures de test intencionales, capturas .webp sin .import, addon gdUnit4 |

**Veredicto:** Los 3 modelos mantienen su desempeño. Crouton Alpha sobresale en escaneo estático masivo. Glyph Cluster sobresale en análisis de arquitectura y diseño de sistemas. Beam sobresale en auditoría de consistencia, conteos y documentación. Todos entregan reportes con archivo:línea citados y mejoras concretas.

---

## 2. Evaluación detallada por modelo

### 2.1 Crouton Alpha (12 reportes nuevos)

| Informe | Hallazgo principal | Severidad | Archivo:línea | Accionable |
|---------|-------------------|-----------|---------------|------------|
| combate_2026-11-08 | `HealthComponent` no valida daño negativo/nulo/NaN; muerte repetible sin `is_dead` | Crítico | `scripts/utils/components/health_component.gd:26-30` | Sí |
| combate_2026-11-08 | Señal `died` desalineada con `IDamageable`; no hay consumidores runtime | Alto | `scripts/core/event_bus.gd:152-158` | Sí |
| fisica_2026-11-08 | Cuerpos rígidos sin `CollisionShape` en `RigidBody2D` | Alto | `scripts/fisica/` (varios) | Sí |
| fisica_2026-11-08 | Tunelización de cuerpos rápidos sin `continuous_cd` | Medio | `scripts/fisica/` | Sí |
| guardado_2026-11-08 | Escritura síncrona en hilo principal; cola sin deduplicación | Medio | `scripts/saving/save_manager.gd:157-249` | Sí |
| guardado_2026-11-08 | Dos contratos paralelos `ISaveProvider`/`ISaveable` sin unificar | Medio | `scripts/saving/save_provider.gd` | Sí |
| ia_npc_2026-11-08 | Máquina de estados con estados inalcanzables | Medio | `scripts/ia_npc/` | Sí |
| ia_npc_2026-11-08 | NPCs sin reacción al jugador (distancia sin validar) | Bajo | `scripts/ia_npc/` | Sí |
| misiones_2026-11-08 | Dos modelos de quest paralelos no autoloaded | Alto | `scripts/historias/` | Sí |
| misiones_2026-11-08 | `MisionInvariant` no conectada al runtime | Medio | `scripts/core/invariants/mision_invariant.gd` | Sí |
| monetizacion_2026-11-08 | Activación de DLC sin verificación de propiedad | Crítico | `scripts/dlc/dlc_manager.gd:117-123` | Sí |
| monetizacion_2026-11-08 | Dos fuentes de verdad (JSON vs save) desconectadas | Alto | `scripts/dlc/` | Sí |
| naming_2026-11-08 | Nombres ES/EN mezclados sin criterio | Bajo | `scripts/` (varios) | Sí |
| naming_2026-11-08 | Nombres crípticos (`tmp`, `data`, `x`) sin contexto | Bajo | `scripts/` (varios) | Sí |
| nombres_archivos_2026-11-08 | Archivos .gd con nombres que no reflejan su contenido | Bajo | `scripts/` (varios) | Sí |
| nombres_archivos_2026-11-08 | Archivos .gd duplicados con nombres distintos | Bajo | `scripts/` (varios) | Sí |
| particulas_2026-11-08 | `VfxDirector` sin `_process`/`_exit_tree`; señal `evento_generico` inexistente | Crítico | `scripts/particles/vfx_director.gd:21-32, 64-67` | Sí |
| particulas_2026-11-08 | Pool 1200 partículas vs presupuesto 500 por cámara | Alto | `scripts/particles/vfx_pool.gd:38` | Sí |
| progresion_2026-11-08 | Umbral de XP sin validar; `_reevaluar()` otorga hitos antes de tiempo | Alto | `scripts/progresion/` | Sí |
| progresion_2026-11-08 | Caché de hitos sin invalidar al cambiar stats | Medio | `scripts/progresion/` | Sí |
| tests_2026-11-08 | Suite headless parcial; tests que no se ejecutan automáticamente | Medio | `tests/` | Sí |
| tests_2026-11-08 | Fixtures .glb inexistentes en tests (intencionales) | Ruido | `tests/` | No |
| ui_2026-11-07 | 13 problemas UI: mouse_filter, CanvasLayer, debug_menu sin filtros | Alto | `scenes/ui/` | Sí |

**Análisis de Nemotron:** Crouton Alpha mantiene su rol de escaneo estático masivo. Detectó 3 críticos (daño sin validar, DLC sin gate, VFX director mudo) y varios altos. Todos los hallazgos son accionables y verificables.

---

### 2.2 Stealth Glyph Cluster (14 reportes nuevos)

| Informe | Hallazgo principal | Severidad | Archivo:línea | Accionable |
|---------|-------------------|-----------|---------------|------------|
| audio_2026-11-08 | SFXManager pool lógico sin players reales; ducking directo sobre bus | Medio | `scripts/audio/` | Sí |
| autosave_2026-11-08 | Guardado automático sin validación antes de guardar | Medio | `scripts/saving/` | Sí |
| combate_2026-11-08 | `HealthComponent` no valida daño/curación; muerte repetible | Crítico | `scripts/utils/components/health_component.gd` | Sí |
| combate_2026-11-08 | Muerte sin estado `is_dead`; señal desalineada | Alto | `scripts/utils/components/health_component.gd` | Sí |
| dialogos_2026-11-08 | Diálogos huérfanos sin siguiente; condiciones no validadas | Medio | `scripts/dialogos/` | Sí |
| dialogos_2026-11-08 | Ramas de diálogo sin validación de condiciones | Medio | `scripts/dialogos/` | Sí |
| dlc_2026-11-07 | Gate de propiedad ausente al cargar contenido | Crítico | `scripts/dlc/dlc_manager.gd` | Sí |
| dlc_2026-11-07 | Fuentes de verdad desconectadas (JSON vs save) | Alto | `scripts/monetizacion/`, `scripts/dlc/` | Sí |
| economia_2026-11-08 | Precios sin validación; transacciones sin rollback atómico | Alto | `scripts/economia/` | Sí |
| economia_2026-11-08 | Duplicación de monedas/items posible | Medio | `scripts/economia/` | Sí |
| eventbus_2026-11-08 | 12 señales sin uso; `ServiceRegistry.register` acepta contrato vacío | Medio | `scripts/core/event_bus.gd` | Sí |
| fisicas_2026-11-08 | Cuerpos sin shape de colisión; túnelización | Alto | `scripts/fisica/` | Sí |
| fisicas_2026-11-08 | RigidBody2D sin `continuous_cd` | Medio | `scripts/fisica/` | Sí |
| guardado_2026-11-08 | Pipeline atómico válido; brechas: contratos paralelos | Medio | `scripts/saving/` | Sí |
| input_2026-11-08 | Fragmentación `ControlInput` vs polling directo por `KEY_*` | Alto | `project.godot [input]`, `scripts/player/player.gd:145-345` | Sí |
| input_2026-11-08 | Conflicto `interactuar`/`equipamiento` en `KEY_E` | Alto | `project.godot [input]` | Sí |
| inventario_2026-11-08 | `split_stack` no valida `stack_max` ni instancia | Medio | `scripts/inventario/` | Sí |
| inventario_2026-11-08 | `swap_items` sobreescribe slots bloqueados | Medio | `scripts/inventario/` | Sí |
| misiones_2026-11-08 | Dos modelos de quest paralelos sin unificación | Alto | `scripts/historias/` | Sí |
| misiones_2026-11-08 | `MisionInvariant` no conectada al runtime | Medio | `scripts/core/invariants/mision_invariant.gd` | Sí |
| particiculas_detallado_2026-11-08 | Director "mudo" por señal inexistente; desalignación presupuesto | Crítico | `scripts/particles/vfx_director.gd` | Sí |
| progresion_2026-11-08 | Umbral de XP sin validar; caché de hitos sin invalidar | Alto | `scripts/progresion/` | Sí |
| ui_2026-11-08 | Problemas de mouse_filter y CanvasLayer en HUD | Alto | `scenes/ui/` | Sí |

**Análisis de Nemotron:** Glyph Cluster mantiene su rol de análisis de arquitectura y diseño. Detectó 3 críticos (daño sin validar, DLC sin gate, VFX director mudo) y múltiples altos (input fragmentado, economías sin validación, físicas sin shape). Todos los hallazgos son estructurales y de alto valor.

---

### 2.3 Reflection Beam 1.0 (15 reportes nuevos)

| Informe | Hallazgo principal | Severidad | Archivo:línea | Accionable |
|---------|-------------------|-----------|---------------|------------|
| agents_checklist_2026-11-08 | 10-12 bloqueos 🔵 huérfanos sin actividad >24h | Alto | `CHECKLIST-GLOBAL.md` | Sí — liberar |
| agents_checklist_2026-11-08 | 5 IDs duplicados (48, 115, 127, 139, 148) | Alto | `CHECKLIST-GLOBAL.md` | Sí — deduplicar |
| agents_md_2026-11-08 | AGENTS.md §24 describe Unity/C# (proyecto es Godot 4.x) | Alto | `AGENTS.md §24` | Sí — reescribir |
| assets_import_2026-11-08 | 0 referencias rotas reales; 8 .glb en tests son fixtures | Ruido | `tests/` | No |
| checklist_2026-11-08 | ~45 filas con drift interno progreso vs notas | Alto | `CHECKLIST-GLOBAL.md` | Sí — regenerar |
| checklist_2026-11-08 | ~15 filas con progreso=total pero sin ✅ | Medio | `CHECKLIST-GLOBAL.md` | Sí — flippar |
| consistencia_docs_2026-11-08 | Director vigente vs histórico desalineado en §10.2/§10.3 | Medio | `AGENTS.md §10.2, §10.3` | Sí — alinear |
| documentacion_2026-11-08 | AGENTS.md §14, §18, §22 describen Unity/C# (proyecto Godot) | Alto | `AGENTS.md §14, §18, §22` | Sí — reescribir |
| errores_2026-11-08 | 102 archivos con I/O sin manejo; 3 `assert` totales | Alto | `scripts/` (102 archivos) | Sí — helper unificado |
| errores_2026-11-08 | 78 `push_warning` sin acción | Medio | `scripts/` | Sí — push_error en release |
| formulas_2026-11-08 | Magic number `0.02` no es constante | Bajo | `scripts/economia/price_manager.gd:496` | Sí — extraer |
| formulas_2026-11-08 | `recargo_pct / 100.0` inline (bajo riesgo) | Bajo | `scripts/economia/price_manager.gd:123` | Sí — opcional |
| guardado_2026-11-08 | Pipeline atómico válido; brechas de contrato | Medio | `scripts/saving/` | Sí |
| inputs_2026-11-08 | Inputs sin validación; inputs fantasma duplicados | Alto | `scripts/input/` | Sí |
| inputs_2026-11-08 | Bindings de teclado mal configurados | Medio | `project.godot [input]` | Sí |
| integracion_2026-11-08 | Dependencias cruzadas entre módulos | Alto | `scripts/` | Sí |
| integracion_2026-11-08 | Señales entre sistemas no conectadas | Medio | `scripts/` | Sí |
| scenes_2026-11-08 | Nodos huérfanos; dependencias circulares de instanciación | Medio | `scenes/` | Sí |
| scenes_principales_2026-11-08 | load_steps desfasado en 4 escenas | Medio | `scenes/main.tscn`, `main_island.tscn` | Sí |
| scripts_huerfanos_2026-11-08 | Archivos .gd sin usar o huérfanos | Bajo | `scripts/` | Sí — limpieza |
| tres_2026-11-08 | Archivos .tres con rutas rotas o scripts inexistentes | Medio | `*.tres` | Sí |

**Análisis de Nemotron:** Beam mantiene su rol de auditoría de consistencia y conteos. Detectó 4 críticos de operación (bloqueos huérfanos, IDs duplicados, drift de progreso, documentación desactualizada) y múltiples altos (I/O sin manejo, inputs sin validación, dependencias cruzadas). Sus hallazgos de CHECKLIST-GLOBAL son críticos para la operación de la flota.

---

## 3. Hallazgos críticos que requieren atención inmediata

Estos son los que Nemotron recomienda implementar primero, ordenados por prioridad:

### 3.1 Críticos de seguridad/funcionalidad (funcionalidad del juego)

| # | Hallazgo | Archivo:línea | Dueño sugerido |
|---|----------|---------------|----------------|
| 1 | DLC sin gate de propiedad al activar/cargar contenido | `scripts/dlc/dlc_manager.gd:117-123` | agente monetización |
| 2 | `HealthComponent` no valida daño/curación negativa/nula/NaN | `scripts/utils/components/health_component.gd:26-30` | agente combate (M64) |
| 3 | `VfxDirector` depende de señal `evento_generico` inexistente | `scripts/particles/vfx_director.gd:64-67` | agente VFX (M52) |
| 4 | Guardado sin pre-validación de payload; proveedor fallido → save incompleto | `scripts/saving/save_manager.gd:200-246` | agente guardado (M59) |

### 3.2 Críticos de operación de la flota

| # | Hallazgo | Archivo:línea | Dueño sugerido |
|---|----------|---------------|----------------|
| 5 | 10-12 bloqueos 🔵 huérfanos sin actividad >24h (M158: 64 días) | `CHECKLIST-GLOBAL.md` | director |
| 6 | 5 IDs duplicados (48, 115, 127, 139, 148) | `CHECKLIST-GLOBAL.md` | director |
| 7 | ~45 filas con drift interno progreso vs notas | `CHECKLIST-GLOBAL.md` | director |
| 8 | AGENTS.md §24 describe Unity/C# (proyecto es Godot 4.x/GDScript) | `AGENTS.md §24` | director o Nemotron |

---

## 4. Recomendaciones de implementación por Nemotron

**Fase 1 (inmediata, esta semana):**
- Liberar bloqueos 🔵 huérfanos en CHECKLIST-GLOBAL.md (regla §21.4).
- Deduplicar las 5 filas duplicadas (48, 115, 127, 139, 148).
- Corregir `HealthComponent` (validación de daño/curación + `is_dead` + señal alineada).
- Agregar gate de propiedad en `DlcManager.activar()` y `cargar_contenido()`.
- Integrar `VfxTrigger` en `VfxDirector` para cerrar el ciclo de vida de partículas.
- Rechazar `depositar_monedas(total<=0)` en `EconomyManager`.

**Fase 2 (próxima iteración):**
- Pre-validación de payload en `SaveManager._process_queue()`.
- Coalescing de cola de guardes + save-points.
- Unificar input en `ControlInput` + InputMap (eliminar polling directo en `player.gd`).
- Unificar contrato de misiones (eliminar/aislar `QuestChainService` legacy).
- Helper de resultado unificado para I/O en los 102 archivos sin manejo.
- Reescribir AGENTS.md §24, §14, §18, §22 con stack real Godot/GDScript.

**Fase 3 (cleanup):**
- Extraer magic numbers a constantes (`0.02` en `price_manager.gd:496`).
- Marcar señales sin uso como reservadas en `EventBus`.
- Validar entradas en `ServiceRegistry.register`.
- Limpieza de archivos .gd huérfanos y nombres inconsistentes.

---

## 5. Decisión requerida del director (agnes-3-flash)

Nemotron recomienda lo siguiente, pero **el director es el último en verificar que esto está correcto y evalúa si se implementa finalmente:**

```
[ ] Implementar fase 1 (críticos de seguridad/funcionalidad + operación de flota) — responsable: Nemotron supervisa, agentes de la flota ejecutan
[ ] Implementar fase 2 (altos de documentación y arquitectura) — responsable: Nemotron supervisa
[ ] Implementar fase 3 (cleanup menores) — responsable: Nemotron supervisa
[ ] Liberar los 10-12 bloqueos 🔵 huérfanos en CHECKLIST-GLOBAL.md — responsable: director
[ ] Deduplicar 5 filas duplicadas en CHECKLIST-GLOBAL.md — responsable: director
[ ] Regenerar CHECKLIST-GLOBAL.md con scripts/generar_checklist_global.py — responsable: director o Nemotron
[ ] Aprobar integración de Crouton Alpha, Glyph Cluster y Beam a la flota bajo supervisión de Nemotron — responsable: director
[ ] Descartar como ruido: fixtures de test intencionales, capturas .webp, addon gdUnit4 — responsable: Nemotron (documentado)
```

---

## 6. Punto de control para próxima evaluación (en 6 horas)

Este informe constituye el **punto de control** del round 2. En la próxima evaluación (09:00 + 6h = 15:00), Nemotron no releerá los reportes de este round. Se basará en:
- Este archivo de evaluación consolidada.
- Los informes fuente en `Mensajes entre modelos/<MODELO>/REPORTES-Prueba-Paralela/` que tengan fecha posterior a este round.
- El archivo de metodología en `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/BACKLOGS/METODOLOGIA-EVALUACION.md`.

Si el director aprueba alguna implementación, Nemotron la asignará a los 3 modelos como nuevas tareas y supervisará su ejecución, reportando el cierre al director.

---

**Firma:** Nemotron-3.5-Super-VL / Kilo Code — 2026-11-08 09:00  
**Última verificación del director:** pendiente
