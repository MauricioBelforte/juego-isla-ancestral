# Auditoría de arquitectura UI — capas, `mouse_filter` y diálogos

**Modelo:** Glyph Cluster  
**Fecha:** 2026-11-13  
**Alcance:** `game/isla-ancestral/scenes/ui/` y `game/isla-ancestral/scripts/ui/` (con referencias cruzadas necesarias a `scripts/dialogos/ui/` y `scripts/main_island.gd` para evaluar duplicación de diálogo).  
**Método:** inventario de escenas/scripts, revisión de definiciones `CanvasLayer`/`layer`, búsqueda de `mouse_filter` y de referencias a diálogo (`DialogLayer`, `DialogueUI`, `dialog_requested`).

> Nota: en `scenes/ui/` solo existe `hud.tscn`; la mayor parte de la arquitectura UI está implementada por script en `scripts/ui/`.

---

## Resumen ejecutivo

| # | Hallazgo | Severidad | Evidencia principal |
|---|---|---|---|
| 1 | Duplicación de arquitectura de diálogo: capa formal M53 (`DialogLayer`) y fallback M21 (`DialogueUI`) con mecanismos distintos | **Alta** | `scripts/ui/layers/dialog_layer.gd:13,34-36`, `scripts/dialogos/ui/dialogue_ui.gd:19-21`, `scripts/ui/core/ui_manager.gd:480-486`, `scripts/ui/ui_root.gd:41-45`, `scripts/main_island.gd:119-124` |
| 2 | Colisión de orden de `CanvasLayer`: HUD y `UIRoot` comparten `layer = 100` | **Alta** | `scenes/ui/hud.tscn:14-15`, `scripts/ui/ui_root.gd:14,36` |
| 3 | `CanvasLayer` de servicios/overlays sin `layer` explícito (orden implícito por defecto) | **Media** | `scripts/ui/services/notification_service.gd:1`, `scripts/ui/services/tooltip_service.gd:1`, `scripts/ui/hud/action_prompt_overlay.gd:1` vs `scripts/ui/subtitle_manager.gd:74-76` |
| 4 | Uso de `mouse_filter = IGNORE` consistente en HUD/decoración, pero dimmers de capas modales también en `IGNORE` (riesgo de captura de input ambigua) | **Media** | `scenes/ui/hud.tscn:24,29,40,45,52,64,69,84,89,105,110,120,133,138,148`, `scripts/ui/layers/dialog_layer.gd:126`, `scripts/ui/layers/inventory_layer.gd:64`, `scripts/ui/layers/equipment_layer.gd:44`, `scripts/ui/layers/pause_layer.gd:37`, `scripts/ui/layers/diary_layer.gd:120` |
| 5 | Duplicación/variantes de `ActionPromptOverlay` (CanvasLayer stub en `hud/` vs Control en `widgets/`) | **Baja** | `scripts/ui/hud/action_prompt_overlay.gd:1-26`, `scripts/ui/widgets/action_prompt_overlay.gd:1-88`, `scenes/ui/hud.tscn:10,113-121` |

---

## 1. Capas de diálogo duplicadas / coexistencia de dos implementaciones

**Severidad:** Alta

**Descripción:** existen dos implementaciones de presentación de diálogo con responsabilidades solapadas: la capa formal del framework M53 (`DialogLayer`, integrada en pila/foco/pausa de `UIManager`) y el fallback autocontenido M21 (`DialogueUI`, `CanvasLayer` propio). La selección entre una y otra depende de la presencia de `UIRoot`, pero ambas bases de código se mantienen activas.

**Evidencia:**
- `scripts/ui/layers/dialog_layer.gd:5-13` — declara `class_name DialogLayer extends UILayer` como “presentación formal del diálogo M21” integrada al framework M53.
- `scripts/ui/layers/dialog_layer.gd:34-36` — fija `layer_type = UILayerType.Type.MODAL_SIMPLE` y construye UI propia (`_crear_ui`, typing, suscripción a `DialogueManager`/`EventBus`).
- `scripts/dialogos/ui/dialogue_ui.gd:5,19-21` — `class_name DialogueUI extends CanvasLayer`, `layer = 15`, capa autocontenida M21 (no usa `scripts/ui` de M53).
- `scripts/ui/ui_root.gd:10-11,41-45` — `UIRoot` monta `DialogLayer` como hijo (`add_child(dialog_layer)`), conviviendo conceptualmente con el fallback de M21.
- `scripts/ui/core/ui_manager.gd:53-54,480-486` — ante `EventBus.ui.dialog_requested` busca `DialogLayer` y la abre con `push_layer`; si no existe, registra que M21 cubre con su fallback.
- `scripts/main_island.gd:116-124` — si existe `res://scripts/ui/ui_root.gd` retorna sin crear fallback; si no, instancia `DialogueUI` (`add_child(ui)`).

**Impacto:** dos canales/UI de diálogo con lógica de presentación, input y estilos potencialmente divergentes; mayor coste de mantenimiento y riesgo de bugs al modificar uno sin el otro (p. ej. typing, opciones, integración con pausa/foco). La coexistencia es intencional como fallback, pero arquitectónicamente es una duplicación estructural.

---

## 2. Orden incorrecto / ambiguo de `CanvasLayer` (HUD y raíz UI en el mismo `layer`)

**Severidad:** Alta

**Descripción:** el HUD de escena y la raíz de capas UI declaran el mismo índice de canvas (`100`). En Godot, nodos `CanvasLayer` con igual `layer` se ordenan por posición en el árbol; si ambos existen como roots de canvas separados, el resultado visual (HUD sobre modales o modales sobre HUD) queda acoplado a la estructura de montaje, no a una política explícita.

**Evidencia:**
- `scenes/ui/hud.tscn:14-16` — `[node name="HUDScreen" type="CanvasLayer"]`, `layer = 100`, script `hud_screen.gd`.
- `scripts/ui/ui_root.gd:14,36` — `class_name UIRoot extends CanvasLayer`, `layer = 100` en `_ready()`; además monta como hijos internos múltiples capas modales (`DialogLayer`, `PauseLayer`, `MenusLayer`, `ConfirmPopup`, inventario, etc.) en `_build_layers()` (`ui_root.gd:41-129`).
- `scripts/ui/subtitle_manager.gd:52,71-76` — crea su propio `CanvasLayer` con `layer = 90` (debajo de 100), lo que muestra intención de estratificación explícita en ese caso.
- `scripts/dialogos/ui/dialogue_ui.gd:20-21` — fallback `DialogueUI` fija `layer = 15` (muy por debajo), coherente como overlay propio pero separado del stack M53.

**Impacto:** posible solapamiento incorrecto entre HUD y capas modales según cómo se instancie la escena HUD respecto a `UIRoot` (p. ej. HUD tapando controles modales o modales quedando detrás de elementos HUD). La ambigüedad de orden es un riesgo de regresión visual difícil de detectar sin convención única.

---

## 3. `CanvasLayer` sin índice de capa explícito

**Severidad:** Media

**Descripción:** varios servicios/overlays UI extienden `CanvasLayer` sin asignar `layer`, confiando en el valor por defecto (1). Esto los sitúa muy por debajo de HUD/UIRoot (`100`) y de subtítulos (`90`), lo que puede ser correcto o no según el diseño, pero no queda documentado en código y es frágil ante cambios de composición.

**Evidencia:**
- `scripts/ui/services/notification_service.gd:1` — `extends CanvasLayer` (sin `layer =` en el archivo).
- `scripts/ui/services/tooltip_service.gd:1` — `extends CanvasLayer` (sin `layer =` en el archivo).
- `scripts/ui/hud/action_prompt_overlay.gd:1` — `extends CanvasLayer` (stub que añade `Label` hijos; sin `layer`).
- Contraste intencional: `scripts/ui/subtitle_manager.gd:76` asigna `layer = 90`; `scripts/ui/ui_root.gd:36` y `scenes/ui/hud.tscn:15` asignan `100`; `scripts/dialogos/ui/dialogue_ui.gd:21` asigna `15`.

**Impacto:** orden de dibujado implícito y dependiente del default del motor; riesgo de que tooltips/notificaciones/overlays queden ocultos tras otras capas o aparezcan en planos inesperados al reestructurar la escena.

---

## 4. `mouse_filter`: patrón mayormente correcto en HUD, con dimmers modales en `IGNORE`

**Severidad:** Media

**Descripción:** el HUD y elementos decorativos usan `MOUSE_FILTER_IGNORE` para no bloquear interacción del juego, lo cual es adecuado. Sin embargo, varios fondos/dimmers de capas modales también se marcan como `IGNORE`, lo que puede dejar la captura de clics dependiente de otros controles del panel (no del fondo completo).

**Evidencia (uso adecuado / passthrough intencional):**
- `scenes/ui/hud.tscn:24,29,40,45,52,64,69,84,89,105,110,120,133,138,148` — contenedores y widgets del HUD en `mouse_filter = 2` (`MOUSE_FILTER_IGNORE`), evitando bloquear input de mundo.
- `scripts/ui/ui_root.gd:142-143` — `_agregar_widget_hud` fuerza `widget.mouse_filter = Control.MOUSE_FILTER_IGNORE` para widgets `Control`.
- `scripts/ui/overlays/subtitulo_overlay.gd:38,45` — overlay y panel de subtítulos en `MOUSE_FILTER_IGNORE` (decorativo/accesibilidad sin intercepción).
- `scripts/ui/widgets/action_prompt_overlay.gd:88` — overlay de prompts en `MOUSE_FILTER_IGNORE`.

**Evidencia (dimmers/fondos modales en `IGNORE`, revisar intención):**
- `scripts/ui/layers/dialog_layer.gd:126` — fondo oscurecido (`ColorRect` “FondoDim”) con `mouse_filter = Control.MOUSE_FILTER_IGNORE`.
- `scripts/ui/layers/inventory_layer.gd:64` — dim en `MOUSE_FILTER_IGNORE`.
- `scripts/ui/layers/equipment_layer.gd:44` — dim en `MOUSE_FILTER_IGNORE`.
- `scripts/ui/layers/pause_layer.gd:37` — dim en `MOUSE_FILTER_IGNORE`.
- `scripts/ui/layers/diary_layer.gd:120` — dim en `MOUSE_FILTER_IGNORE` (además de otros elementos decorativos en `539`).

**Impacto:** si el diseño espera que el dimmer bloquee clics al mundo o cierre el modal al pulsar fuera, `IGNORE` impide esa captura; si se espera passthrough, es correcto. La heterogeneidad sugiere falta de convención explícita para “scrim” modal vs. fondo no interactivo.

---

## 5. Variantes de `ActionPromptOverlay` (arquitectura no unificada)

**Severidad:** Baja

**Descripción:** coexisten una implementación de widget `Control` usada por la escena HUD y un stub `CanvasLayer` en `scripts/ui/hud/`, lo que puede inducir confusión sobre cuál es la fuente de verdad.

**Evidencia:**
- `scenes/ui/hud.tscn:10,113-121` — instancia `ActionPromptOverlay` como `Control` (`unique_name_in_owner`, `mouse_filter = 2`) con script `res://scripts/ui/widgets/action_prompt_overlay.gd`.
- `scripts/ui/widgets/action_prompt_overlay.gd:1,88` — `extends Control`, `class_name ActionPromptOverlay`, lógica de prompts por dispositivo y `mouse_filter = IGNORE`.
- `scripts/ui/hud/action_prompt_overlay.gd:1-26` — `extends CanvasLayer` con API mínima (`set_prompts/add_prompt/clear_prompts`) que crea `Label` hijos; sin `layer` explícito.

**Impacto:** riesgo de mantenimiento (editar el stub creyendo que afecta al HUD real) y de registro/orden si el stub se instancia por error como capa independiente.

---

## Conclusión

La arquitectura UI del módulo presenta una base clara (HUD en escena, `UIRoot` como contenedor de capas modales M53, y estratificación parcial con subtítulos en `layer 90`), pero con **riesgos arquitectónicos relevantes**: (1) **duplicación del flujo de diálogo** entre `DialogLayer` (M53) y `DialogueUI` (M21) mantenida como fallback operativo, y (2) **ambigüedad de composición visual** por compartir `layer = 100` entre `HUDScreen` y `UIRoot`, reforzada por `CanvasLayer` auxiliares sin `layer` explícito. En `mouse_filter`, el HUD y los overlays decorativos aplican correctamente `IGNORE`, aunque los dimmers de varias capas modales también lo usan, lo que exige validar la semántica de bloqueo de input prevista.

## Mejoras concretas propuestas

1. **Unificar la política de capas y diálogo (contrato de composición):**
   - Definir un mapa de capas explícito y único (p. ej. HUD base, subtítulos, UI modal, tooltips/notificaciones, loading/debug) y asignar `layer` en **todos** los `CanvasLayer` (`ui_root.gd`, `hud.tscn`/`HUDScreen`, `notification_service.gd`, `tooltip_service.gd`, `hud/action_prompt_overlay.gd`, etc.) para eliminar ambigüedades de orden.
   - Formalizar el fallback de diálogo: documentar y encapsular la decisión “`UIRoot` presente ⇒ solo `DialogLayer`; ausente ⇒ `DialogueUI`” en un único punto (factory/bootstrap) y marcar una de las implementaciones como legacy con plan de convergencia, evitando que nuevas features se implementen en ambas.

2. **Normalizar la semántica de `mouse_filter` para modales y limpiar variantes de overlay:**
   - Establecer convención: contenedores HUD/decorativos en `IGNORE`; scrim/modal bloqueante en `STOP` (o el filtro que corresponda al comportamiento deseado) y controles interactivos en `STOP/PASS` según necesidad. Revisar y alinear los dimmers de `dialog_layer.gd:126`, `inventory_layer.gd:64`, `equipment_layer.gd:44`, `pause_layer.gd:37`, `diary_layer.gd:120` con esa convención.
   - Retirar o consolidar el stub `scripts/ui/hud/action_prompt_overlay.gd` (CanvasLayer) si la implementación canónica es `scripts/ui/widgets/action_prompt_overlay.gd` (Control usado en `scenes/ui/hud.tscn`), para evitar duplicación de componentes y capas huérfanas.
