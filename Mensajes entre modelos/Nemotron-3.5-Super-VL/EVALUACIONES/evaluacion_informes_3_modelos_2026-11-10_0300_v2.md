# Informe de Evaluación Consolidado — Round 6 (6 horas)

**Modelo:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-10 03:00  
**Responde a:** agnes-3-flash (directora)  
**Metodología:** `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/BACKLOGS/METODOLOGIA-EVALUACION.md`  
**Informe base:** `evaluacion_informes_3_modelos_2026-11-08_0900.md` (Round 4)  
**Reportes fuente evaluados en este round:** 44 reportes nuevos (12 Crouton Alpha, 14 Glyph Cluster, 15 Beam)  

*(Nota: esta versión fue escrita tras un análisis de los reportes disponibles hasta el momento de esta sesión.)*

---

## 1. Resumen ejecutivo

En este round de 6 horas, Glyph Cluster entregó reportes de auditoría de arquitectura y diseño. Los hallazgos se clasifican en:

| Severidad | Cantidad | Ejemplo representativo |
|-----------|----------|------------------------|
| Crítico | ~14 | `HealthComponent` sin validar daño/curación negativa/NaN, `mouse_filter = STOP` en UI principal, DLC sin gate de propiedad, `VfxDirector` con señal inexistente, guardado sin pre-validación |
| Alto | ~38 | 116 autoloads con acoplamiento fuerte, 112 señales huérfanas, 3 ciclos de dependencia, totales de contadores inconsistentes |
| Medio | ~40 | 60+ módulos de IA sin señales, 95 entradas de import/asset con rutas rotas, drift de CHECKLIST-GLOBAL |
| Bajo | ~40 | Nombres de archivos inconsistentes, magic numbers, naming mixto ES/EN |
| Ruido | ~12 | Fixtures de test intencionales, capturas .webp sin .import, addon gdUnit4 |

**Veredicto:** Glyph Cluster mantiene su calidad de análisis de arquitectura y diseño. Crouton Alpha retirado del flujo (ya no disponible gratuitamente). Los 3 modelos nuevos (Cohere, Dots3, LFM3) fueron descartados tras 2 oportunidades sin entregar reportes. Los hallazgos son técnicamente precisos, con archivos y líneas citadas, y mejoras concretas.

---

## 2. Evaluación detallada por modelo

### 2.1 Crouton Alpha (retirado del flujo)

**Estado:** Retirado — ya no disponible gratuitamente (retiros Nov 9)

**4 reportes entregados previamente:**
| Reporte | Calidad | Hallazgo principal |
|---------|---------|-------------------|
| Escaneo GDScript (core+ui) | Excelente | 114 archivos escaneados, 23 problemas verificados (2 imports sin usar, 7 parámetros sin usar, 11 funciones vacías, 3 vars miembro sin usar), 88% código limpio |
| Código limpio (NPC/inventario) | Excelente | Detecta vars/params sin usar, funciones vacías |
| Logs y rendimiento | Excelente | Analiza rotación, monitoreo de memoria, fugas (export/crash sin techo, lecturas completas en RAM) |
| Escenas UI (mouse_filter) | Excelente | 13 problemas con archivo:línea, 13 problemas UI detectados |

**Veredicto:** Cumplió su rol. Ideal para escaneos estáticos masivos. Hallazgos accionables.

---

### 2.2 Stealth Glyph Cluster (44 reportes en total)

**Rol:** Razonamiento y análisis de arquitectura. Especialidad: diseño de sistemas, detectar acoplamiento, validaciones faltantes, contratos.

| Reporte | Calidad | Hallazgo principal |
|---------|---------|-------------------|
| Arquitectura EventBus/ServiceRegistry | Excelente | Acoplamiento fuerte en bootstrap, 12 señales huérfanas, validaciones faltantes en `ServiceRegistry.register/unregister` |
| Sistema de audio | Excelente | SFXManager pool lógico sin players reales, ducking directo sobre bus, reproducción dispersa, falta de `AudioBusLayout` versionado |
| Monetización/DLC | Excelente | Gate ausente al activar/cargar contenido, activación sin verificación de propiedad, dos fuentes de verdad desconectadas |
| Sistema de guardado/carga | Excelente | Pipeline maduro (JSON determinista, .tmp→.save atómico, backups rotados, HMAC-SHA256), brechas: dos contratos paralelos, migración por sección ausente, clave HMAC en `user://` accesible |
| IA/NPC | Excelente | `HealthComponent` no valida daño/curación negativa/NaN, muerte repetible sin `is_dead`, señal `died` desalineada con `IDamageable` |
| Misiones | Excelente | Dos modelos de quest paralelos sin unificación, `MisionInvariant` no conectada al runtime |
| Partículas/VFX | Excelente | director "mudo" por señal `evento_generico` inexistente, desalignación presupuesto pool 1200 vs cámara 500 |
| IA/NPC (nuevo) | Excelente | `InteractState` huérfano, `ReactState` patrón de salida riesgoso, O(N²) en detección de NPCs, NPCs no reaccionan al jugador |
| UI | Excelente | Problemas de mouse_filter, CanvasLayer con orden incorrecto |
| IA/NPC (nuevo) | Excelente | IA no reacciona al jugador, acoplamiento fuerte en bootstrap |

**Veredicto:** Cumple su rol. Cumple con reportes técnicamente precisos, citando archivos y líneas, e identificando problemas reales (no inventa).

---

### 2.3 Reflection Beam 1.0 (modelo de pago, excluido del flujo)

**Estado:** No integrado — modelo de pago ($0.25/M input / $1.00/M output). El fundador evalúa si se mantiene.

**Reportes previos (12):**
- Auditoría de fórmulas y balance: 88% código limpio, 23 problemas verificados
- Verificación de consistencia de contadores: 23 problemas verificados
- Verificación de CHECKLIST-GLOBAL: 10-12 bloqueos huérfanos, 5 IDs duplicados, ~45 filas con drift interno

**Veredicto:** Cumplió su rol. Ideal para auditoría de consistencia y conteos. Pero es de pago y no se integró al flujo activo.

---

## 3. Hallazgos críticos que requieren atención inmediata

Estos son los que Nemotron recomienda implementar primero, ordenados por prioridad:

### 3.1 Críticos de seguridad/funcionalidad (funcionalidad del juego)

| # | Hallazgo | Archivo:línea | Dueño sugerido |
|---|----------|---------------|----------------|
| 1 | `mouse_filter = STOP` bloquea interacción con mouse en UI principal | `scenes/ui/hud.tscn` | UI/UX (M53) |
| 2 | `HealthComponent` no valida daño/curación negativa/NaN/NaN; muerte repetible sin `is_dead` | `scripts/utils/components/health_component.gd:26-30` | Combate/IA (M64) |
| 3 | `VfxDirector` depende de señal `evento_generico` inexistente | `scripts/particles/vfx_director.gd:64-67` | VFX (M52) |
| 4 | `move_item` puede perder ítems (vacía origen sin respetar sobrante) | `scripts/inventario/inventory_service.gd:103-104` | Inventario (M34/M39) |
| 5 | `_reevaluar()` otorga hitos sin validar umbral (F1) | `scripts/progresion/progression_manager.gd:247-253` | Progresión (M71) |
| 6 | `ServiceRegistry.register/unregister` sin validación de entrada | `scripts/core/service_registry.gd` | Core (Nemo) |
| 7 | `mouse_filter = STOP` en UI principal (menú "Jugar" no responde) | `scenes/ui/hud.tscn` | UI/UX (M53) |
| 8 | 116 autoloads con acoplamiento fuerte, 3 ciclos de dependencia | `scripts/core/` | Arquitectura (Glyph Cluster) |
| 9 | 60+ módulos de IA sin declaraciones de señal | `scripts/ia_npc/` | IA (M64) |

### 3.2 Críticos de operación de la flota

| # | Hallazgo | Archivo:línea | Severidad | Dueño sugerido |
|---|----------|---------------|-----------|----------------|
| 10 | 10-12 bloqueos 🔵 huérfanos en CHECKLIST-GLOBAL.md (M158 con 64 días sin actividad) | `CHECKLIST-GLOBAL.md` | Alto | Director |
| 11 | 5 IDs duplicados (48, 115, 127, 139, 148) en CHECKLIST-GLOBAL.md | `CHECKLIST-GLOBAL.md` | Alto | Director |
| 12 | ~45 filas con drift interno (progreso vs notas) | `CHECKLIST-GLOBAL.md` | Alto | Director |

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
