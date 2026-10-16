# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/140-Alpha/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 4.2 Accesibilidad y UX de Alpha (cerrada 2026-10-14, step-5-kilocode)

Cierra la seccion 12 del checklist. Verificado contra disco:

| Item | Estado |
|---|---|
| Escala de texto | **presente** — 47 hits en `scripts/` (accesibilidad_schema, accesibilidad_aplicador, action_prompt_overlay, etc.). La escala al 150% existe como ajuste de M58 |
| Feedback de audio en nuevas interacciones | **presente** — `feedback_director.gd` (M44) con `test_feedback_m44.gd`; las nuevas interacciones de Alpha entran por receta de capas (M139 2.8.1) |
| Modos de color para puzzles de espejos/sombras | **parcial** — los modos de color existen (8 hits: accesibilidad_schema, gestor_config, mapa_manager) pero **0 hits de "espejo"/"sombra"** en el manager: no estan aplicados a puzzles |
| Navegacion del diario con gamepad | **ausente** — 0 hits de la combinacion diario+gamepad (si hay 29 hits de gamepad en general, incluido `control_input.gd`) |
| Estados vacios de colecciones con texto claro | **ausente como especifico** — los 5 hits son de otros sistemas; no hay un patron de estado vacio para colecciones |

**Estado de los modulos duenos:** M58-Accesibilidad **154/181** (27 `[ ]`), M53-UI-UX **144/163**
(19 `[ ]`). La validacion de M58 en sistemas nuevos y la config de dificultad de puzzles ya estaban
`[x]`.

**Definicion para los ausentes:** (1) los puzzles de espejos/sombras de Alpha deben aceptar los modos
de color existentes como variante de dificultad (no como requisito); (2) la navegacion del diario con
gamepad se resuelve con el patron ya existente en menus (`menu_navigator.gd`); (3) el estado vacio de
colecciones se define como texto + ilustracion, nunca lista vacia.
"""

ancla = None
t = t.rstrip("\n") + "\n\n" + seccion
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("seccion 4.2 insertada al final")
