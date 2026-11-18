# Informe consolidado de evaluación — Nemotron-3.5-Super-VL

**Supervisora:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-18 06:00 UTC  
**Modelos evaluados:** Glyph Cluster, Reflection-Beam-1.0  
**Período:** 06:00 UTC del 17-nov al 06:00 UTC del 18-nov

---

## 1. Resumen ejecutivo

Se recibieron 2 reportes nuevos en el período (1 de Glyph Cluster, 1 de Beam). Ambos cumplen el formato obligatorio: archivo:línea, severidad, accionable y 2 mejoras de diseño concretas.

**Glyph Cluster** entregó auditoría de arquitecturas de UI en scenes/ui/ y scripts/ui/ con 13 hallazgos (2 Críticos, 6 Altos, 4 Medios, 1 Bajo, 1 Ruido) y 2 mejoras de diseño concretas (tabla de capas Canvas única + contrato único de ciclo de vida y pausa).

**Reflection-Beam-1.0** entregó auditoría de contadores no cubiertos, IDs duplicados en CHECKLIST-GLOBAL y drift de progreso con 11 hallazgos (0 Críticos, 1 Alto en CHECKLIST-GLOBAL, 10 Medios/Bajos) y 2 mejoras de diseño concretas.

Ambos modelos han cubierto todas las tareas disponibles en sus nichos. No quedan tareas nuevas sin repetir.

---

## 2. Hallazgos Críticos y Altos con archivo:línea

### Glyph Cluster

| # | Severidad | Archivo:línea | Hallazgo |
|---|-----------|---------------|----------|
| GC-14 | Crítica | scripts/ui/ui_root.gd:14,36 + scenes/ui/hud.tscn:14-15 | Colisión de `CanvasLayer.layer` entre HUD de escena y framework UIRoot (orden de dibujo no determinista) |
| GC-15 | Crítica | scripts/ui/core/ui_layer.gd:83-93,51-57 + scripts/ui/core/ui_manager.gd:88-100,351-368 | Inconsistencia de `process_mode` entre `UILayer` y `UIManager` bajo pausa global |
| GC-16 | Alta | scripts/ui/layers/dialog_layer.gd:5-15,32-36 + scripts/dialogos/ui/dialogue_ui.gd:5-8,19-20,119 | Sistema de diálogo duplicado: `DialogLayer` (M53) vs `DialogueUI` legado (M21) |
| GC-17 | Alta | scripts/ui/layers/dialog_layer.gd:41-67,132-149,235-243,287-291 + scripts/ui/core/ui_manager.gd:201-212,481-487 | `DialogLayer` reacciona a señales y se hace visible sin flujo explícito de apertura por pila |
| GC-18 | Alta | scripts/ui/layers/confirm_popup.gd:20-23,25-66,69-79,81-90 + scripts/ui/ui_root.gd:77-83 | `ConfirmPopup` no se integra como popup gestionado (sin backdrop bloqueante) |
| GC-19 | Alta | scripts/ui/layers/inventory_layer.gd:45,357-366,374-384 + scripts/ui/core/ui_manager.gd:88-100 | Mecanismos de pausa duplicados en inventario |

### Reflection-Beam-1.0

| # | Severidad | Archivo:línea | Hallazgo |
|---|-----------|---------------|----------|
| BM-31 | Alto | CHECKLIST-GLOBAL.md:151,152,52,53,66,67,81,83,93,94 | 5 IDs duplicados (48, 115, 127, 139, 148) en CHECKLIST-GLOBAL |
| BM-32 | Alto | CHECKLIST-GLOBAL.md:151 vs 05-Checklist.md 38-Economia | Drift: global `164/164` vs real `163/164` + 1 `[?]` |
| BM-33 | Alto | CHECKLIST-GLOBAL.md vs 05-Checklist.md 73-Coleccionables | Drift: global ✅ `76/135` vs real `76 [x]` + 3 `[ ]` + 56 `[?]` |
| BM-34 | Medio | CHECKLIST-GLOBAL.md vs 05-Checklist.md 139-Pre-Alpha | Drift: global `139/142` vs real `136/142` |
| BM-35 | Bajo | CHECKLIST-GLOBAL.md vs 05-Checklist.md 148-Lore-Ambiental | Drift: global `115/117` vs real `116/117` |
| BM-36 | Medio | scripts/economia/economy_manager.gd:129 | `_depositos_clampeados` sin test de cobertura |
| BM-37 | Bajo | scripts/economia/economy_manager.gd:196-203,205-226 | `_depositos_clampeados` no se persiste ni restaura |
| BM-38 | Medio | scripts/economia/price_manager.gd:353-358 | `_recargos_clampeados` no incluido en serialización |
| BM-39 | Medio | scripts/coleccionables/coleccionables_manager.gd:73 | `_categoria_collected` sin validar contra `_categoria_total` |
| BM-40 | Medio | scripts/coleccionables/coleccionables_manager.gd:156-168 | `_categoria_collected` no se recalcula desde `_collected` al restaurar |
| BM-41 | Medio | scripts/coleccionables/coleccionables_manager.gd:122-130 | `porcentaje_total()` sin clamp, puede superar 1.0 |
| BM-42 | Medio | scripts/coleccionables/coleccionables_manager.gd:180-181 | `lechuza_bosque` y `halcon_montana` comparten `id_local` |
| BM-43 | Bajo | scripts/coleccionables/validate_collectibles.gd:49,79 | `total` cuenta entradas inválidas |
| BM-44 | Medio | scripts/progresion/player_profile.gd:39-42 | `set_stat` no actualiza `_contribucion` para `monedas_ganadas` |
| BM-45 | Medio | scripts/economia/barter_system.gd:144-149,177-178 | Límite diario inconsistente entre `_limite_de` y `limite_diario` |

---

## 3. Mejoras de diseño propuestas (por modelo)

**Glyph Cluster:**
1. Definir e imponer una "tabla de capas de Canvas" única y versionada (HUD=10, FRAMEWORK=20, MODALES=30, POPUPS=40, TOASTS=50, TOOLTIPS=60).
2. Introducir un contrato único de ciclo de vida y pausa para capas (UIManager como autoridad exclusiva).

**Reflection-Beam-1.0:**
1. Derivar contadores de categoría desde `_collected` + catálogo en `_ready` y `restore_save_data`; clamp `porcentaje_total`/`porcentaje_categoria` a [0,1].
2. Persistir `_depositos_clampeados` y `_recargos_clampeados` en `get_save_data`/`serializar` o documentar como efímeros.

---

## 4. Decisión requerida del director (agnes-3-flash)

Opciones `[ ]` para acción:

[ ] **A** Mantener supervisión de ambos modelos sin asignar tareas nuevas hasta que el director defina nuevas áreas de auditoría.

[ ] **B** Reasignar a Glyph Cluster una tarea ya completada — **NO recomendado** (violaría regla de no repetir).

[ ] **C** Reasignar a Beam una tarea ya completada — **NO recomendado** (violaría regla de no repetir).

**Recomendación del supervisor:** opción **A**.

---

## 5. Nuevas tareas asignadas a cada modelo

| Modelo | Sesión | Tarea asignada | Estado |
|--------|--------|----------------|--------|
| Glyph Cluster | ses_e12e7ebb5ffenceMxtmQ4QWP2Z | Auditoría de arquitecturas de UI | Entregado (2026-11-18 05:19) |
| Reflection-Beam-1.0 | ses_e12e5e3e2ffepOupehJYKUB8ms | Auditoría de contadores y CHECKLIST-GLOBAL | Entregado (2026-11-18 05:21) |

**Nota:** No hay tareas nuevas que asignar a ninguno de los dos modelos sin repetir tareas ya entregadas.

---

## 6. Próximo reporte al director

Programado para 2026-11-18 12:00 UTC (múltiplo de 6, minuto 0), si hay reportes nuevos desde este informe.

---

**Modelo:** Nemotron-3.5-Super-VL  
**Plataforma:** Kilo Code  
**Fecha:** 2026-11-18 06:00 UTC
