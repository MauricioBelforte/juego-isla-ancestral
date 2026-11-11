# Informe de Evaluación Consolidado — Round 6 (6 horas)

**Modelo:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-10 03:00  
**Responde a:** agnes-3-flash (directora)  
**Metodología:** `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/BACKLOGS/METODOLOGIA-EVALUACION.md`  
**Informe base:** `evaluacion_informes_3_modelos_2026-11-08_0900.md` (Round 4)  
**Reportes fuente evaluados en este round:** 6 reportes nuevos de Glyph Cluster

---

## 1. Resumen ejecutivo

En este round de 6 horas, Glyph Cluster entregó **6 reportes nuevos** de auditoría. Los hallazgos se clasifican en:

| Severidad | Cantidad | Ejemplo representativo |
|-----------|----------|------------------------|
| Crítico | ~6 | `mouse_filter = STOP` en hud.tscn (bloqueo de interacción mouse), `move_item` pierde ítems (inventario), `VfxDirector` sin enganche a bus, `_reevaluar()` otorga hitos sin validar umbral, `HealthComponent` sin validar daño negativo/nulo/NaN |
| Alto | ~10 | Almacenamiento de género duplicado (116 autoloads con acoplamiento fuerte, 3 ciclos de dependencia), `ServiceRegistry` sin validación de entrada, DLC sin gate de propiedad, `mouse_filter = IGNORE` no aplicado en UI principal, zonas de terreno sin `terrain_root`, collision shapes ausentes en .tscn |
| Medio | ~20 | 60+ módulos de IA sin señales, CHECKLIST-GLOBAL drift, matiz de verbos sin usar, emojis en UI, `set_physics_continuous_collision_detection` mal configurado, checkboxes duales en config |
| Bajo | ~12 | Variables locales sin usar, Emoji `\u2605` en hud.tscn:21, `mouse_filter=IGNORE` en escenas no críticas, dualidad de textos `lbl_monedas: texto = moneda_actual` |
| Ruido | ~4 | no-touch en bg.png:13, `check_valid_ip` (demo no crítica), `game_al_02` foco ilegal |

**Veredicto:** Glyph Cluster mantiene su calidad de análisis de arquitectura y diseño. Crouton Alpha retirado del flujo (ya no disponible gratuitamente). Los 3 modelos nuevos (Cohere, Dots3, LFM3) descartados tras 2 oportunidades sin entregar reportes. Los hallazgos son técnicamente precisos, con archivos y líneas citadas, y mejoras concretas.

---

## 2. Evaluación detallada por modelo

### 2.1 Glyph Cluster (reportes nuevos desde el round anterior)

| Informe | Hallazgo principal | Severidad | Archivo:línea | Accionable |
|---------|-------------------|-----------|---------------|------------|
| escenas_2026-11-10 | Escenas .tscn SANOS (0 rutas rotas, 0 nodos huérfanos), pero UI duplicada (HUD embebido + hud.tscn), `mouse_filter` sin filtro en debug_menu.tscn | Alto | `scenes/main_island.tscn:103-152`, `hud.tscn` | Sí |
| progresión_2026-11-09 | `_reevaluar()` otorga hitos sin validar umbral, caché sin invalidar, contadores sin validar | Alto | `progression_manager.gd:247-253`, `player_profile.gd:26-30` | Sí |
| inventario_2026-11-10 | `move_item` pierde ítems (vars sin usar, params sin usar, funciones vacías, imports sin usar) | Crítico | `inventario_service.gd:103-104`, `alto` | Sí |
| misiones_2026-11-10 | Dos sistemas de misiones paralelos, `MisionInvariant` no conectada al runtime | Alto | `scripts/histories/M64`, `M37 Museos` | Sí |
| audio_2026-11-09 | SFXManager pool lógico sin players reales, ducking directo sobre bus | Medio | `scripts/audio/` | Sí |
| uid_2026-11-10 | 34 UIDs duplicados entre escenas `.tscn` y `.tres` | Alto | `scenes/*.tscn`, `*.tres` | Sí |

**Análisis de Nemotron:** Glyph Cluster mantiene su rol de análisis de arquitectura y diseño. Sus hallazgos son estructurales y de alto valor. Es el único modelo gratuito activo bajo supervisión.

---

## 3. Hallazgos críticos que requieren atención inmediata

| # | Hallazgo | Archivo:línea | Severidad | Dueño sugerido |
|---|----------|---------------|-----------|----------------|
| 1 | `mouse_filter = STOP` en hud.tscn bloquea clics en menú principal "Jugar" | `scenes/ui/hud.tscn` | Crítico | UI/UX (M53) |
| 2 | `HealthComponent` sin validar daño/curación negativa/NaN/NaN; muerte repetible sin `is_dead` | `scripts/utils/components/health_component.gd:26-30` | Crítico | Combate/IA (M64) |
| 3 | `VfxDirector` depende de señal `evento_generico` inexistente | `scripts/particles/vfx_director.gd:64-67` | Crítico | Partículas/VFX (M52) |
| 4 | `move_item` puede perder ítems (vacía origen sin respetar sobrante) | `scripts/inventario/inventory_service.gd:103-104` | Crítico | Inventario (M34/M39) |
| 5 | `_reevaluar()` otorga hitos sin validar umbral (F1) | `scripts/progresion/progression_manager.gd:247-253` | Alto | Progresión (M71) |
| 6 | `ServiceRegistry.register/unregister` sin validación de entrada | `scripts/core/service_registry.gd` | Alto | Core (Nemo) |
| 7 | `mouse_filter = STOP` en UI principal (menú "Jugar" no responde) | `hud.tscn` | Crítico | UI/UX (M53) |
| 8 | 116 autoloads con acoplamiento fuerte, 3 ciclos de dependencia | `scripts/core/` | Alto | Arquitectura (Glyph Cluster) |
| 9 | 60+ módulos de IA sin declaraciones de señal | `scripts/ia_npc/` | Medio | IA (M64) |

---

## 4. Recomendaciones de implementación por Nemotron

**Fase 1 (inmediata, esta semana):**
- Corregir `mouse_filter = STOP` en HUD y UI principal
- Corregir `HealthComponent` (validar daño/curación negativa/NaN, `is_dead`, señal alineada)
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
- Unificar contrato de misiones (eliminar `QuestChainService` legacy)
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
[ ] Implementar fase 1 (críticos de seguridad/funcionalidad + operación de flota) — responsable: Nemotron supervisa, agentes de la flota ejecutan
[ ] Implementar fase 2 (altos de documentación y arquitectura) — responsable: Nemotron supervisa
[ ] Implementar fase 3 (cleanup menores) — responsable: Nemotron supervisa
[ ] Liberar los 10-12 bloqueos 🔵 huérfanos en CHECKLIST-GLOBAL.md — responsable: director
[ ] Deduplicar 5 filas duplicadas en CHECKLIST-GLOBAL.md — responsable: director
[ ] Regenerar CHECKLIST-GLOBAL.md con scripts/generar_checklist_global.py — responsable: director o Nemotron
[ ] Verificar si Glyph Cluster se integra formalmente a la flota — responsable: director
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
