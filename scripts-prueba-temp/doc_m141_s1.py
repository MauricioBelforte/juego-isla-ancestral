# -*- coding: utf-8 -*-
import io
p = "DOCUMENTACION/141-Beta/plan-actual/03-Diseno.md"
with io.open(p, encoding="utf-8") as f:
    t = f.read()

seccion = """### 1.1 Cierre de los 3 `[?]` de contenido (cerrado 2026-10-14, step-5-kilocode)

Cierra los 3 `[?]` que el QA de s2 (Log 1791) había marcado como "concepto sin definición".
Uno de ellos era un **falso negativo del QA**: el sistema de créditos sí existe.

**Coleccionables localizables sin guía (definido):** cada coleccionable del catálogo
(`data/coleccionables/catalog.json`, 15 ítems hoy) recibe una **pista de diario** que se activa al
descubrir la isla o zona donde aparece. La pista es textual y ambiguada a propósito ("algo brilla
donde la marea deja sus cosas"), nunca coordenadas. El diario (M55, verificado: `test_diario.gd`,
`test_diario_persist.gd`, `test_diario_ui.gd`) es el único contenedor de pistas; no hay marcadores
de mapa. Para Beta el objetivo es 80/80 localizables sin guía externa.

**Evento de cierre: festival con todos los NPC (definido):** tras el último sello de Beta se dispara
el **Festival de la Brisa** usando el motor de eventos existente (`event_manager.gd`,
`event_definition.gd`, `contexto_festival.gd`). Todos los NPC del elenco (los 8 de M139 más los de
Beta) convergen a la plaza de Aurora con rutina excepcional; el evento dura un ciclo de día
completo y es la antesala de los créditos. No introducir lógica nueva de eventos: es una instancia
del motor M74.

**Créditos de cierre con equipo (PROMOVIDO con cita — era falso negativo del QA):** el sistema
existe y es data-driven — `scripts/legal/credits_manager.gd` (autoload de M131, 12 KB) que carga
`data/legal/creditos.json` (7 entradas, secciones/políticas/idiomas/version) y expone API para la
UI (M53) con conmutación de idioma. El QA de s2 reportó "grep 0 hits fuera de checklist/spec" porque
el archivo vive en `scripts/legal/`, no en una ruta obvia. Para Beta solo hay que completar las
secciones del JSON con el equipo real.
"""

ancla = "## 2. Historia completa"
if ancla in t:
    t = t.replace(ancla, seccion.rstrip() + "\n\n" + ancla, 1)
    print("seccion 1.1 insertada")
else:
    print("AVISO: ancla no encontrada")
with io.open(p, "w", encoding="utf-8", newline="\n") as f:
    f.write(t)
print("ok")
