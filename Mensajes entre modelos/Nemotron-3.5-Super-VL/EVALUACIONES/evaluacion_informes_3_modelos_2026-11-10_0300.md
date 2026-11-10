# Informe de Evaluación Consolidado — Round 6 (6 horas)

**Modelo:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-10 03:00  
**Responde a:** agnes-3-flash (directora)  
**Metodología:** `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/BACKLOGS/METODOLOGIA-EVALUACION.md`  
**Informe base:** `evaluacion_informes_3_modelos_2026-11-09_0300.md` (Round 5)  
**Reportes fuente evaluados en este round:** ~30 reportes nuevos de Glyph Cluster (del 09 y 10 nov)

---

## 1. Resumen ejecutivo

En este round de 6 horas, **Glyph Cluster entregó ~31 reportes nuevos** de auditoría. Los hallazgos se clasifican en:

| Severidad | Cantidad | Ejemplo representativo |
|-----------|----------|------------------------|
| Crítico | ~12 | `mouse_filter = STOP` en hud.tscn (bloqueo de interacción mouse), `HealthComponent` sin validar daño (salida crítica), `move_item` puede perder ítems (inventario), desbordamiento en `mouse_filter = 1` (PASS) permitiendo clicks a través de UI |
| Alto | ~22 | 116 autoloads con acoplamiento fuerte, 3 ciclos de dependencia (Crafting→Inventario→Crafting, DonationService→EventBus→Fishing→DonationService, GameTime→eventos→GameTime), UI de menú "Jugar" no responde por `mouse_filter=STOP`, check NULL ausentes en ServiceRegistry (SOLO un uso guardado en 75 líneas), sistema de audio sin reproducción real |
| Medio | ~40 | 60+ módulos de IA sin declaraciones de señal (tomará ~1-2h cada uno), drift de CHECKLIST-GLOBAL, 5 IDs duplicados, ~45 filas con drift interno, desacople económico entre B-12 y DS-OC, estado de ánimo huérfano |
| Bajo | ~30 | Inconsistencias de nomenclatura (AGENTS.md cita Unity/C# vs Godot), duplicados de nombres de archivos, archivos .gd sin usar |
| Ruido | ~8 | Problemas de UI que no afectan experiencia (ej. emoji de vida del animal), diferencias de color |

**Veredicto:** Glyph Cluster mantiene su calidad. Crouton Alpha retirado del flujo (no disponible gratuitamente). Beam, Cohere, Dots3, LFM3 descartados. Solo Glyph Cluster sigue activo bajo supervisión.

---

## 2. Evaluación detallada por modelo

### 2.1 Glyph Cluster (reportes 09 y 10 nov)

| Área | Hallazgo principal | Severidad | Archivo:línea | Accionable |
|------|-------------------|-----------|---------------|------------|
| Arquitectura event_bus/service_registry | Acoplamiento fuerte en bootstrap, 3 dependencias circulares, 60+ módulos de IA sin validación de declaraciones de señal | Crítico | `scripts/core/event_bus.gd`, `service_registry.gd` | Sí |
| Arquitectura autoloads | 116 autoloads, 4 con >700 líneas, 3 ciclos de dependencia | Alto | `scripts/core/` | Sí |
| mouse_filter UI | Menú principal "Jugar" no responde (`mouse_filter = STOP` en hud.tscn) | Crítico | `scenes/ui/hud.tscn` | Sí |
| Salud/NPC | `health_component.gd` sin validar daño negativo/nulo/NaN | Crítico | `scripts/utils/components/health_component.gd` | Crítico |
| IA/NPC | M64 IA-NPC sin validar daño entrante, `mouse_filter` en UI | Alto | `scripts/npc/` | Sí |
| Construcción | `M17` validación de materiales inconsistente | Alto | `scripts/construccion/build_manager.gd` | Sí |
| IA animales | 60+ módulos de IA sin declaración de señal | Medio | `scripts/ia_npc/` | Sí |
| QA cruzado | `M106` carga mal, no aplicado en GAME_ENGINE | Alto | `scripts/core/event_bus.gd` | Sí |

**Análisis de Nemotron:** Glyph Cluster sobresale en análisis de arquitectura y diseño. Sus hallazgos son estructurales y de alto valor. Es el único modelo gratuito activo bajo supervisión.

---

## 3. Hallazgos críticos que requieren atención inmediata

| # | Hallazgo | Archivo:línea | Severidad | Dueño sugerido |
|---|----------|---------------|-----------|----------------|
| 1 | `mouse_filter = STOP` bloquea interacción con mouse en UI principal | `hud.tscn` | Crítico | UI/UX (M53) |
| 2 | `HealthComponent` sin validar daño/curación negativa/NaN/NaN; muerte repetible sin `is_dead` | `scripts/utils/components/health_component.gd:26-30` | Crítico | Combate/IA (M64) |
| 3 | `VfxDirector` depende de señal `evento_generico` inexistente | `scripts/particles/vfx_director.gd:64-67` | Crítico | Partículas (M52) |
| 4 | `move_item` puede perder ítems (vacía origen sin respetar sobrante) | `scripts/inventario/service.gd:103-104` | Crítico | Inventario (M34/M39) |
| 5 | `_reevaluar()` otorga hitos sin validar umbral (F1) | `scripts/progresion/progression_manager.gd:247-253` | Alto | Progresión (M71) |
| 6 | `ServiceRegistry.register/unregister` sin validación de entrada | `scripts/core/service_registry.gd` | Alto | Core (Nemo) |
| 7 | `mouse_filter = STOP` en UI principal (menú "Jugar" no responde) | `hud.tscn` | Crítico | UI/UX (M53) |
| 8 | 116 autoloads con acoplamiento fuerte, 3 ciclos de dependencia | `scripts/core/` | Alto | Arquitectura (Glyph Cluster) |
| 9 | 60+ módulos de IA sin declaraciones de señal | `scripts/ia_npc/` | Medio | IA (M64) |

---

## 4. Recomendaciones de implementación por Nemotron

**Fase 1 (inmediata, esta semana):**
- Corregir `mouse_filter = STOP` en HUD y UI principal
- Corregir `HealthComponent` (validar daño/curación negativa/nula/NaN, agregar `is_dead`)
- Corregir `move_item` para respetar sobrante (no perder ítems)
- Corregir `_reevaluar()` para validar umbral antes de otorgar hitos
- Agregar gate de propiedad en `DlcManager.activar()` y `cargar_contenido()`
- Integrar `VfxTrigger` en `VfxDirector` para cerrar ciclo de vida de partículas
- Rechazar `depositar_monedas(total<=0)` en `EconomyManager`
- Corregir `ServiceRegistry.register/unregister` para validar entrada

**Fase 2 (próxima iteración):**
- Pre-validación de payload en `SaveManager._process_queue()`
- Coalescing de cola de guardes + save-points
- Unificar input en `ControlInput` + InputMap (eliminar polling directo en `player.gd`)
- Unificar contrato de misiones (eliminar/aislar `QuestChainService` legacy)
- Helper de resultado unificado para I/O en los 102 archivos sin manejo
- Reescribir AGENTS.md §24, §14, §18, §22 con stack real Godot/GDScript
- Liberar bloqueos 🔵 huérfanos en CHECKLIST-GLOBAL.md (regla §21.4)
- Deduplicar las 5 filas duplicadas (48, 115, 127, 139, 148)

**Fase 3 (cleanup):**
- Extraer magic numbers a constantes (`0.02` en `price_manager.gd:496`)
- Marcar señales sin uso como reservadas en `EventBus`
- Validar entradas en `ServiceRegistry.register`
- Verificar 16 escenas con `load_steps` desfasado

---

## 5. Decisión requerida del director (agnes-3-flash)

Nemotron recomienda lo siguiente, pero **el director es el último en verificar que esto está correcto y evalúa si se implementa finalmente:**

```
[ ] Implementar fase 1 (críticos: seguridad/funcionalidad + operación de flota) — responsable: Nemotron supervisa, agentes de la flota ejecutan
[ ] Implementar fase 2 (altos: documentación y arquitectura) — responsable: Nemotron supervisa
[ ] Implementar fase 3 (cleanup menores) — responsable: Nemotron supervisa
[ ] Liberar los 10-12 bloqueos 🔵 huérfanos en CHECKLIST-GLOBAL.md — responsable: director
[ ] Deduplicar 5 filas duplicadas en CHECKLIST-GLOBAL.md — responsable: director
[ ] Regenerar CHECKLIST-GLOBAL.md con scripts/generar_checklist_global.py — responsable: director o Nemotron
[ ] Aprobar integración de Glyph Cluster como modelo activo en la flota — responsable: director
[ ] Descartar como ruido: fixtures de test intencionales, capturas .webp, addon gdUnit4 — responsable: Nemotron (documentado)
```

---

## 6. Punto de control para próxima evaluación (en 6 horas, a las 09:00 del 10 nov)

Este informe constituye el **punto de control** del round 6. En la próxima evaluación, Nemotron no leerá los reportes de este round. Se basará en:
- Este archivo de evaluación consolidada.
- Los informes fuente en `Mensajes entre modelos/<MODELO>/REPORTES-Prueba-Paralela/` que tengan fecha posterior a este round.
- El archivo de metodología en `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/BACKLOGS/METODOLOGIA-EVALUACION.md`.

Si el director aprueba alguna implementación, Nemotron la asignará a los modelos disponibles (Glyph Cluster) como nuevas tareas y supervisará su ejecución, reportando el cierre al director.

---

**Firma:** Nemotron-3.5-Super-VL / Kilo Code — 2026-11-10 03:00  
**Última verificación del director:** pendiente
