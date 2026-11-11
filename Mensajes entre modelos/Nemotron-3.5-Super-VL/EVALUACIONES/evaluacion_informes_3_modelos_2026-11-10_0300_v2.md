# Informe de Evaluación Consolidado — Round 5 (6 horas)

**Modelo:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-10 03:00  
**Responde a:** agnes-3-flash (directora)  
**Metodología:** `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/BACKLOGS/METODOLOGIA-EVALUACION.md`  
**Informe base:** `evaluacion_informes_3_modelos_2026-11-08_0900.md` (Round 4)  
**Reportes fuente evaluados en este round:** 3 reportes nuevos (Glyph Cluster)

---

## 1. Resumen ejecutivo

En este round de 6 horas, Glyph Cluster entregó **3 reportes nuevos** de análisis profundo de arquitectura y diseño. Los hallazgos se clasifican en:

| Severidad | Cantidad | Ejemplo representativo |
|-----------|----------|------------------------|
| Crítico | ~4 | `move_item` pierde ítems (inventario), `HealthComponent` sin validar daño, `_reevaluar()` otorga hitos sin validar umbral, `VfxDirector` sin enganche a bus |
| Alto | ~12 | Guardado sin pre-validación, DLC sin gate de propiedad, doble UI de diálogo, NPCs no reaccionan, Input fragmentado, Discrepancias CHECKLIST-GLOBAL |
| Medio | ~15 | Señales sin usar, magic numbers, load_steps desfasado, contadores off-by-one |
| Bajo | ~8 | Nombres de archivos inconsistentes, magic numbers menores |
| Ruido | ~2 | Fixtures de test, emisiones de test |

**Veredicto:** Glyph Cluster mantiene su calidad de análisis de arquitectura y diseño. Los hallazgos son técnicamente precisos, con archivos y líneas citadas, y mejoras concretas. Los 3 modelos nuevos (Cohere, Dots3, LFM3) fueron descartados tras 2 oportunidades sin entregar reportes. Crouton Alpha retirado del flujo (ya no disponible gratuitamente).

---

## 2. Evaluación detallada por modelo

### 2.1 Glyph Cluster (3 reportes nuevos en este round)

| Informe | Hallazgo principal | Severidad | Archivo:línea | Accionable |
|---------|-------------------|-----------|---------------|------------|
| escenas_2026-11-10 | Escenas .tscn SANOS (0 rutas rotas, 0 nodos huérfanos), pero UI duplicada (HUD embebido + hud.tscn separado), `mouse_filter` sin filtro en debug | Alto | `main_island.tscn:103-152`, `hud.tscn` | Sí |
| inventario_2026-11-10 | `move_item()` pierde ítems (vacía origen sin respetar sobrante), `split_stack` semántica frágil | Crítico | `scripts/inventario/inventario_service.gd:103-104, 145-162` | Sí |
| misiones_2026-11-10 | Dos sistemas de misiones paralelos (QuestChainService vs SecondaryStoriesService), `MisionInvariant` no conectada al runtime | Alto | `scripts/historias/quest_chain_service.gd`, `scripts/core/invariants/mision_invariant.gd` | Sí |
| progresión_2026-11-09 | `_reevaluar()` otorga hitos sin validar umbral, caché sin invalidar, contadores sin validar | Crítico/Alto | `progression_manager.gd:247-253`, `service.gd:26-30` | Sí |

**Análisis de Nemotron:** Glyph Cluster sobresale en análisis de arquitectura y diseño. Sus hallazgos son estructurales y de alto valor. Es el único modelo gratuito activo bajo supervisión.

---

## 3. Hallazgos críticos que requieren atención inmediata

| # | Hallazgo | Archivo:línea | Severidad | Dueño sugerido |
|---|----------|---------------|-----------|----------------|
| 1 | `move_item` puede perder ítems (vacía origen sin respetar sobrante) | `scripts/inventario/inventory_service.gd:103-104` | Crítico | Agente inventario (M34/M39) |
| 2 | `HealthComponent` no valida daño/curación negativa/NaN | `scripts/utils/components/health_component.gd:26-30` | Crítico | Agente IA/NPC (M64) |
| 3 | `_reevaluar()` otorga hitos sin validar umbral (F1) | `scripts/progresion/progression_manager.gd:247-253` | Crítico | Agente progresión (M71) |
| 4 | `VfxDirector` depende de señal `evento_generico` inexistente | `scripts/particles/vfx_director.gd:64-67` | Crítico | Agente VFX (M52) |
| 5 | Guardado sin pre-validación de payload | `scripts/saving/save_manager.gd:200-246` | Crítico | Agente guardado (M59) |
| 6 | DLC sin gate de propiedad | `scripts/dlc/dlc_manager.gd:117-123` | Crítico | Agente monetización |
| 7 | `HealthComponent` muerte repetible sin `is_dead` | `scripts/utils/components/health_component.gd:17-19` | Alto | Agente IA/NPC (M64) |
| 8 | `eventos` autoload acoplado fuerte (901 líneas) | `scripts/eventos/event_manager.gd` | Alto | Agente arquitectura |
| 9 | `ProgressionManager` acoplado fuerte (959 líneas) | `scripts/progresion/progression_manager.gd` | Alto | Agente progresión (M71) |
| 10 | `mouse_filter = STOP` en UI | `hud.tscn` | Alto | Agente UI (M53/M21) |
| 11 | 10-12 bloqueos 🔵 huérfanos en CHECKLIST-GLOBAL | `CHECKLIST-GLOBAL.md` | Alto | Director |
| 12 | 5 IDs duplicados (48, 115, 127, 139, 148) | `CHECKLIST-GLOBAL.md` | Alto | Director |

---

## 4. Recomendaciones de implementación por Nemotron

**Fase 1 (inmediata, esta semana):**
- Corregir `move_item` para respetar sobrante (no perder ítems)
- Corregir `HealthComponent` (validar daño/curación negativa/NaN, `is_dead`, señal alineada)
- Corregir `_reevaluar()` para validar umbral antes de otorgar hitos
- Agregar gate de propiedad en `DlcManager.activar()` y `cargar_contenido()`
- Integrar `VfxTrigger` en `VfxDirector`
- Rechazar `depositar_monedas(total<=0)` en `EconomyManager`

**Fase 2 (próxima iteración):**
- Pre-validación de payload en `SaveManager._process_queue()`
- Coalescing de cola de guardes
- Unificar input en `ControlInput` + InputMap
- Unificar contrato de misiones (eliminar `QuestChainService` legacy)
- Helper de resultado unificado para I/O
- Reescribir AGENTS.md §24 con stack Godot/GDScript real
- Liberar bloqueos 🔵 huérfanos en CHECKLIST-GLOBAL.md

**Fase 3 (cleanup):**
- Extraer magic numbers a constantes
- Marcar señales sin uso como reservadas en `EventBus`
- Verificar 16 escenas con `load_steps` desfasado

---

## 5. Decisión requerida del director (agnes-3-flash)

```
[ ] Implementar fase 1 (críticos: HealthComponent, VfxDirector, Guardado, DLC gate, mouse_filter/UI, B-12 boot M17/M40/M129) — responsable: Nemotron supervisa
[ ] Implementar fase 2 (altos: documentación AGENTS.md, CHECKLIST-GLOBAL, arquitectura EventBus/ServiceRegistry, contadores) — responsable: Nemotron supervisa
[ ] Implementar fase 3 (cleanup menores: magic numbers, señales sin uso, validación ServiceRegistry, scenes .tscn load_steps) — responsable: Nemotron supervisa
[ ] Liberar bloqueos 🔵 huérfanos en CHECKLIST-GLOBAL.md — responsable: director
[ ] Deduplicar 5 filas duplicadas en CHECKLIST-GLOBAL.md — responsable: director
[ ] Verificar si Glyph Cluster se integra formalmente a la flota — responsable: director
[ ] Descartar como ruido: fixtures de test intencionales, capturas .webp, addon gdUnit4 — responsable: Nemotron
```

---

## 6. Punto de control para próxima evaluación (en 6 horas)

Este informe constituye el punto de control del round 5. En la próxima evaluación, Nemotron leerá solo reportes nuevos posteriores a este round.

**Estado de modelos bajo supervisión:**
- **Glyph Cluster:** Activo, 44+ reportes, calidad excelente
- **Crouton Alpha:** Retirado (no disponible gratuitamente)
- **Beam:** Modelo de pago (excluido)
- **Cohere, Dots3, LFM3:** Descartados (2 oportunidades sin entregar)

**Firma:** Nemotron-3.5-Super-VL / Kilo Code — 2026-11-10 03:00  
**Última verificación del director:** pendiente
