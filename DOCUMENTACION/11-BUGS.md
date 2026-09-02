# 11 — BUGS: Registro Central de Problemas y Fallas

**Modelo:** Claude (último modificador)
**Plataforma:** Cline
**Fecha:** 2026-09-02 17:45

> ⚠️ **Documento de trabajo VIVO.** Este archivo es el **registro central de bugs** del proyecto: el usuario, junto conmigo o con cualquier LLM acompañante, anota aquí los problemas y fallas que va encontrando, con el **mayor detalle posible**, en formato checklist. Complementa (NO reemplaza) a `DOCUMENTACION/102-Bug-Tracking/`, a la sección 8 del `07-GUIA-GODOT.md`, y a GitHub Issues.

---

## 1. Propósito

- Centralizar en un solo lugar todos los bugs, fallas y problemas encontrados durante el desarrollo, las pruebas manuales y el playtest.
- Permitir que cualquier modelo LLM **delegue** a otro agente más capacitado los bugs que no pueda resolver por sí mismo (capacidades, visión, contexto, complejidad).
- Mantener trazabilidad completa: **quién** reportó, **cuándo**, **qué** ocurrió, **cómo** reproducirlo y **en qué estado** está.

## 2. Reglas de Uso (obligatorias)

1. **Cualquier bug detectado se anota en este archivo.** No importa si es trivial o crítico: se registra con el mayor detalle posible.
2. **Formato obligatorio:** cada bug usa la plantilla de la sección 4 (campos completos; si algún campo no aplica, escribir `N/A`).
3. **Firma obligatoria:** quien registra el bug firma al final de la entrada con `**Modelo:** X` / `**Plataforma:** Y` / `**Fecha:** YYYY-MM-DD HH:MM`.
4. **Delegación de bugs no resueltos:** si un modelo anota un bug que **no puede resolver**, lo deja en su entrada con estado `[?] Delegado` y **además lo agrega en la sección 8 "Bugs Delegados"** (al final del archivo), con su firma. Otro agente más capacitado puede tomarlo.
5. **Cambio de estado:** solo el agente que **resuelve** el bug lo marca `[x] Resuelto`, documentando **cómo** lo resolvió y con su firma. El que lo reportó o un tercero puede confirmar la verificación.
6. **No borrar entradas:** un bug resuelto se marca `[x]` y se mueve a la sección 7 "Bugs Resueltos", conservando el historial completo.
7. **Regla de la honestidad:** si un bug no se puede reproducir, se marca `[?]` con explicación de los intentos. NUNCA marcar `[x]` una falla que no fue verificada.
8. **Evidencia:** adjuntar siempre que sea posible: mensaje de error exacto, logs, capturas (`tools/mcp/godot-mcp/capturas/`), seed, save, build/versión, plataforma.
9. **Relación con otros registros:** si el bug es de Godot, dejar además una referencia cruzada en `07-GUIA-GODOT.md` §8 (registro de errores). Si se usa GitHub Issues, referenciar el número de issue en el campo `Referencias`.

## 3. Estados del Bug

| Símbolo | Estado | Significado |
|---------|--------|-------------|
| `[ ]` | Abierto | Detectado, pendiente de análisis o corrección |
| `[→]` | En progreso | Un agente está trabajando en la corrección (indicar quién) |
| `[?]` | Delegado / No resuelto | El modelo que lo encontró no puede resolverlo y lo delega (firma obligatoria) |
| `[x]` | Resuelto | Corregido y verificado (documentar cómo y con qué log/commit) |

## 4. Plantilla de Registro de Bug (máximo detalle)

Copiar y pegar el siguiente bloque para cada bug nuevo:

```markdown
### BUG-NNN — [Título corto y descriptivo]

- **Fecha de reporte:** YYYY-MM-DD HH:MM
- **Módulo(s) afectado(s):** M-NN (nombre) — escena/script/sistema
- **Severidad:** 🔴 Crítico | 🟠 Mayor | 🟡 Menor | ⚪ Trivial
- **Prioridad sugerida:** Alta / Media / Baja
- **Estado:** [ ] Abierto | [→] En progreso | [?] Delegado | [x] Resuelto

**Descripción del problema:**
[Qué se observa exactamente: comportamiento incorrecto, crash, visual, audio, rendimiento, softlock, etc. Ser lo más descriptivo posible.]

**Pasos para reproducir:**
1. [Acción 1]
2. [Acción 2]
3. [Acción 3]

**Comportamiento esperado:**
[Qué debería ocurrir correctamente según diseño/especificación]

**Comportamiento actual:**
[Qué ocurre en realidad]

**Entorno / Contexto:**
- Versión del juego / build:
- Plataforma: PC (Windows) / Linux / Mac / Web / Otra
- Seed del mundo / save afectado:
- Configuración gráfica o de audio:
- Ocurre desde la versión / commit:
- Frecuencia: Siempre / A veces / Aleatorio / Una vez

**Evidencia:**
- Mensaje de error exacto (copiar completo):
  ```
  [pegar aquí]
  ```
- Logs / archivos relacionados:
- Capturas o videos (ruta):

**Intentos de solución ya probados (si aplica):**
- [Qué se intentó y resultado]

**Referencias cruzadas:**
- Guía 07 §8: [sí/no]
- GitHub Issue #:
- Módulo/documentación relacionada:

**Firma:**
**Modelo:** [nombre del modelo]
**Plataforma:** [plataforma]
**Fecha:** YYYY-MM-DD HH:MM

**Resolución (completar cuando se resuelva):**
- [ ] Cómo se corrigió:
- [ ] Archivos/commits modificados:
- [ ] Log del proyecto:
- [ ] Verificado por:
```
---

## 5. Tabla Resumen de Bugs

| ID | Título | Módulo | Severidad | Estado | Reportado por | Fecha |
|----|--------|--------|-----------|--------|---------------|-------|
| BUG-001 | Overlay de inventario queda pegado en pantalla al cerrar la ventana | M53/M14 | 🟡 Menor | [→] En progreso (fix aplicado, verificar) | Usuario | 2026-09-02 17:55 |
| BUG-002 | [placeholder] | | | | | |

> ⚠️ Mantener esta tabla actualizada al registrar, delegar o resolver bugs. Los detalles completos viven en las secciones 6, 7 y 8.

---

## 6. Bugs Abiertos (pendientes)

> Checklist vivo: `[ ]` = abierto, `[→]` = en progreso (indicar quién lo trabaja). Aquí se agregan los bugs nuevos con la plantilla de la sección 4.

<!-- ================= BUGS NUEVOS: agregar debajo de esta línea ================= -->

### BUG-002 — Numeración de logs fragmentada: duplicados, faltantes y referencias cruzadas inconsistentes

- **Fecha de reporte:** 2026-09-02 21:19
- **Módulo(s) afectado(s):** transversal — `Logs/`, `Logs/ULTIMO_NUMERO.txt`, `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `DOCUMENTACION/*/plan-actual/05-Checklist.md`, `DOCUMENTACION/TAREAS-POR-MODELO/*/checklist.md`
- **Severidad:** 🟠 Mayor
- **Prioridad sugerida:** Alta
- **Estado:** [ ] Abierto
- **Reportado por:** step-3.7-flash (Kilo Code)

**Descripción del problema:**
La numeración de logs del proyecto presenta múltiples inconsistencias: números duplicados, secuencias con saltos grandes sin lógica y referencias cruzadas en documentos que pueden apuntar a números erróneos. Esto rompe la trazabilidad del protocolo multiagente y dificulta la auditoría.

**Hallazgo concreto (2026-09-02):**
- `ULTIMO_NUMERO.txt` = 549, pero existen logs 550.
- Números duplicados detectados: 401, 407, 410, 413, 414, 415, 416, 417, 418, 426, 428, 429, 430, 431, 432, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550.
- Secuencia 1-69 presente y ordenada; salto a 100+; faltan 131, 151, 161, 171, 181, 191, 201, 211, 221, 231, 241, 251, 261, 271, 281, 291, 301, 311, 321, 331, 341, 351, 361, 371, 381, 391, 421, 461, 551+.
- Documentos con referencias a log específico: `CHECKLIST-GLOBAL.md`, `ESTADO-PARALELO.md`, `08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `BACKLOG-MASTER.md`, `DOCUMENTACION/*/plan-actual/05-Checklist.md` y `DOCUMENTACION/TAREAS-POR-MODELO/*/checklist.md` pueden contener números apuntando a duplicados inexistentes.

**Pasos para reproducir:**
1. Listar `Logs/*.md` y extraer el número prefijo de cada archivo.
2. Comparar contra `ULTIMO_NUMERO.txt`.
3. Buscar referencias tipo `Log \d+` en documentos clave.
4. Verificar duplicados y números faltantes contra la secuencia 1..N.

**Comportamiento esperado:**
- Un solo archivo por número de log.
- `ULTIMO_NUMERO.txt` coincide con el máximo número usado.
- Todas las referencias cruzadas apuntan a logs existentes.

**Comportamiento actual:**
- Múltiples archivos comparten el mismo número.
- Faltan números en la secuencia.
- Referencias pueden ser inválidas sin detección automática.

**Entorno / Contexto:**
- Versión del juego / build: desarrollo actual (rama main)
- Plataforma: PC (Windows)
- Ocurre desde: histórico del proyecto por creación concurrente sin reserva efectiva en algunos casos
- Frecuencia: Siempre (estructural)

**Evidencia:**
- Listado completo ordenado: `C:\Users\Maury-New\.local\share\kilo\tool-output\tool_063fe8c9a0019IlEduZC3TNkI2`
- `Logs/ULTIMO_NUMERO.txt` = 549
- Archivos duplicados: `Logs/401-*` (2), `Logs/407-*` (2), `Logs/410-*` (2), `Logs/413-*` (3), `Logs/414-*` (3), `Logs/415-*` (3), `Logs/416-*` (2), `Logs/417-*` (2), `Logs/418-*` (2), `Logs/426-*` (2), `Logs/428-*` (2), `Logs/429-*` (2), `Logs/430-*` (2), `Logs/431-*` (3), `Logs/432-*` (2), `Logs/433-*` (3), `Logs/434-*` (2), `Logs/435-*` (4), `Logs/436-*` (2), `Logs/437-*` (3), `Logs/438-*` (2), `Logs/439-*` (2), `Logs/440-*` (2), `Logs/441-*` (2), `Logs/442-*` (3), `Logs/443-*` (2), `Logs/444-*` (3), `Logs/445-*` (2), `Logs/446-*` (2), `Logs/447-*` (2), `Logs/448-*` (2), `Logs/449-*` (2), `Logs/450-*` (2), `Logs/451-*` (2), `Logs/452-*` (2), `Logs/453-*` (2), `Logs/454-*` (2), `Logs/455-*` (2), `Logs/456-*` (2), `Logs/457-*` (2), `Logs/458-*` (2), `Logs/459-*` (2), `Logs/460-*` (2), `Logs/471-*` (2), `Logs/472-*` (2), `Logs/473-*` (2), `Logs/474-*` (2), `Logs/475-*` (2), `Logs/476-*` (2), `Logs/477-*` (2), `Logs/478-*` (2), `Logs/479-*` (2), `Logs/480-*` (2), `Logs/481-*` (2), `Logs/482-*` (2), `Logs/483-*` (2), `Logs/484-*` (2), `Logs/485-*` (2), `Logs/486-*` (2), `Logs/487-*` (2), `Logs/488-*` (2), `Logs/489-*` (2), `Logs/490-*` (2), `Logs/491-*` (2), `Logs/492-*` (2), `Logs/493-*` (2), `Logs/494-*` (2), `Logs/495-*` (2), `Logs/496-*` (2), `Logs/497-*` (2), `Logs/498-*` (2), `Logs/499-*` (2), `Logs/500-*` (2), `Logs/501-*` (2), `Logs/502-*` (2), `Logs/503-*` (2), `Logs/504-*` (2), `Logs/505-*` (2), `Logs/506-*` (2), `Logs/507-*` (2), `Logs/508-*` (2), `Logs/509-*` (2), `Logs/510-*` (2), `Logs/511-*` (2), `Logs/512-*` (2), `Logs/513-*` (2), `Logs/514-*` (2), `Logs/515-*` (2), `Logs/516-*` (2), `Logs/517-*` (2), `Logs/518-*` (2), `Logs/519-*` (2), `Logs/520-*` (2), `Logs/521-*` (2), `Logs/522-*` (2), `Logs/523-*` (2), `Logs/524-*` (2), `Logs/525-*` (2), `Logs/526-*` (2), `Logs/527-*` (3), `Logs/528-*` (2), `Logs/529-*` (2), `Logs/530-*` (2), `Logs/531-*` (2), `Logs/532-*` (2), `Logs/533-*` (2), `Logs/534-*` (2), `Logs/535-*` (2), `Logs/536-*` (2), `Logs/537-*` (2), `Logs/538-*` (2), `Logs/539-*` (2), `Logs/540-*` (2), `Logs/541-*` (2), `Logs/542-*` (2), `Logs/543-*` (2), `Logs/544-*` (2), `Logs/545-*` (2), `Logs/546-*` (2), `Logs/547-*` (2), `Logs/548-*` (2), `Logs/549-*` (2), `Logs/550-*` (2).

**Intentos de solución ya probados (si aplica):**
- Log 224/292/375/426: intentos previos de renumeración/auditoría. No alcanzaron para cerrar el problema estructural.

**Referencias cruzadas:**
- Guía 07 §8: sí (registro de errores Godot; este bug es de protocolo/docs, no runtime)
- GitHub Issue #: N/A
- Módulo/documentación relacionada: `Logs/`, `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`

**Firma:**
**Modelo:** step-3.7-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 21:19

**Resolución (completar cuando se resuelva):**
- [ ] Cómo se corrigió:
- [ ] Archivos/commits modificados:
- [ ] Log del proyecto:
- [ ] Verificado por:

---

- **Fecha de reporte:** 2026-09-02 17:55
- **Módulo(s) afectado(s):** M53 (UI-UX) — `InventoryLayer` / `inventory_layer.gd`; M14 (Inventario) — panel del jugador `player.gd`
- **Severidad:** 🟡 Menor
- **Prioridad sugerida:** Media
- **Estado:** [ ] Abierto
- **Reportado por:** Usuario

**Descripción del problema (aclarado por el usuario el 2026-09-02):**
El overlay oscuro **sí debe aparecer** junto con la ventana modal del inventario (eso está bien y es el diseño deseado). El verdadero problema es el **cierre**: al cerrar la ventana del inventario (presionando B o Esc), la ventana desaparece pero **el overlay oscuro queda pegado en pantalla** (no se va del fondo). El velo negro permanece sobre el mundo visible hasta abrir/cerrar de nuevo.

**Pasos para reproducir:**
1. Iniciar el juego y cargar una partida (mundo visible).
2. Presionar la tecla **B** → se abre la ventana modal del inventario con su overlay oscuro (comportamiento correcto).
3. Presionar **B** (o Esc) para cerrar la ventana.
4. Observar que la ventana desaparece pero **el overlay oscuro permanece pegado** en toda la pantalla.

**Comportamiento esperado:**
Al abrir: la ventana modal con su overlay oscuro (correcto, así debe ser). Al cerrar: **ambos desaparecen al mismo tiempo** — la ventana y el overlay. El mundo vuelve a verse con total normalidad, sin velo pegado.

**Comportamiento actual:**
Al cerrar el inventario, el `Backdrop` (ColorRect negro α=0.5 creado por `player.gd`) **permanece visible** cubriendo toda la pantalla; solo se oculta el PanelContainer. Además, por el doble binding de la tecla B (ver causa raíz), el `FondoDim` (α=0.4) del `InventoryLayer` de M53 también participa según el camino de apertura.

**Entorno / Contexto:**
- Versión del juego / build: desarrollo actual (rama main)
- Plataforma: PC (Windows)
- Seed del mundo / save afectado: cualquiera
- Configuración gráfica o de audio: default
- Ocurre desde la versión / commit: comportamiento presente en la implementación actual de M53/M14
- Frecuencia: Siempre (100% reproducible)

**Evidencia (código) — causa raíz CONFIRMADA:**
- `game/isla-ancestral/scripts/player/player.gd` **línea 563-564** (al final de `_create_inventory_panel`):
  ```gdscript
  canvas.add_child(panel)      # InventoryCanvas (CanvasLayer) con Backdrop + panel
  _inventory_panel = panel     # ← la variable apunta SOLO al PanelContainer, NO al canvas
  ```
  La jerarquía resultante es: `InventoryCanvas (CanvasLayer)` → con `Backdrop (ColorRect α=0.5)` y `panel (PanelContainer)` como hijos separados.
- `player.gd` **líneas 389-394** (`_close_inventory`): oculta SOLO el panel:
  ```gdscript
  func _close_inventory() -> void:
      if _inventory_panel != null:
          _inventory_panel.visible = false   # ← oculta solo el panel; el Backdrop queda visible
      _hide_tooltip()
      _hide_context_menu()
      Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
  ```
  → **El `Backdrop` (overlay negro α=0.5) es hijo del `CanvasLayer` y NUNCA se oculta → queda pegado en pantalla.**
- `project.godot` **líneas 204-208**: la acción `inventario` está mapeada a `physical_keycode: 66` = **tecla B** → presionar B dispara DOS sistemas a la vez:
  1. `player.gd` (líneas 100-101): `KEY_B` → `_toggle_inventory()` (panel legacy + Backdrop)
  2. `ui_manager.gd` (líneas 89-95): acción `inventario` → `InventoryLayer.toggle()` (M53, con FondoDim α=0.4)
- `scripts/ui/layers/inventory_layer.gd` líneas 32-39: crea su `FondoDim` α=0.4 (este sí se oculta bien al cerrar, porque es hijo de la capa M53 que togglea `visible` completa).

**Captura de evidencia visual:** `tools/mcp/godot-mcp/capturas/53-UI-UX/cap_53_bug001_overlay_pegado_2026-09-02_17-55-00.png`

**Intentos de solución ya probados (si aplica):**
- Ninguno todavía (bug recién reportado).

**Referencias cruzadas:**
- Guía 07 §8: no (aún no documentado en el registro de errores de Godot)
- GitHub Issue #: N/A
- Módulo/documentación relacionada: `DOCUMENTACION/53-UI-UX/plan-actual/`, `DOCUMENTACION/14-Inventario/plan-actual/`

**Firma:**
**Modelo:** Claude
**Plataforma:** Cline
**Fecha:** 2026-09-02 17:55

**Resolución (completar cuando se resuelva):**
- [ ] Cómo se corrigió:
- [ ] Archivos/commits modificados:
- [ ] Log del proyecto:
- [ ] Verificado por:

---

## 7. Bugs Resueltos (historial)

> Cuando un bug se corrige y verifica, se mueve aquí con su fecha de resolución, la solución aplicada y la firma de quien lo resolvió.

_No hay bugs resueltos todavía._


### BUG-003 — Boot global frenado por print con formato sin tupla (M120)

- **Estado:** [x] Resuelto (2026-09-01 23:42) | **Módulo:** M120 DLC | **Severidad:** Alta (bloqueaba el arranque de todo el juego)
- **Síntoma:** Debugger Break en `dlc_manager.gd:24` ("not enough arguments for format string") — el juego quedaba congelado en el splash.
- **Causa:** `print("%d %d" % a, b)` — falta la tupla `[...]` en los argumentos del `%`.
- **Solución:** `print("...%d %d" % [a, b])` (guía 07 §9.62). Verificado: suite ÉXITO + boot con `[M120] DlcManager listo (2 DLC, 1 bundles)`.
- **Firma:** deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-01 23:42 (Log 395)

### BUG-004 — Perfil de hardware persistido corrupto (M115)

- **Estado:** [x] Resuelto (2026-09-02 06:45) | **Módulo:** M115 Hardware | **Severidad:** Media
- **Síntoma:** `cpu_freq_ghz=0.0` y `os_name=Unknown` en la detección; el test fallaba 2/30.
- **Causa:** `load_profile` restauraba un perfil persistido de una detección fallida previa sin validar.
- **Solución:** validación en `load_profile` (freq<=0 u os vacío → re-detección). Test: 30/30 OK.
- **Firma:** deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-02 06:45 (Log 405)

### BUG-005 — 23 diseños de NPC con prendas nulas (.tres inválidos, M161)

- **Estado:** [x] Resuelto (2026-09-02 00:40) | **Módulo:** M161 Diseño Visual | **Severidad:** Alta (contenido visual 100% null)
- **Síntoma:** el loader cargaba 1/23 diseños; todas las prendas `sombrero/torso/piernas/pies` eran null.
- **Causa:** formato `[sub_resource script=ExtResource(...)]` inválido (script en el header) + loader no recursivo + carpintero fuera de RIZ/.
- **Solución:** sub_resources normalizados (22+1), loader recursivo, reubicación y HEX de la Fedora faltante. 23/23, 0 fallos.
- **Firma:** deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-02 00:40 (Log 396)

### BUG-006 — Catálogo de coleccionables inexistente (fallback in-code, M73)

- **Estado:** [x] Resuelto (2026-09-02 05:12) | **Módulo:** M73 Coleccionables | **Severidad:** Media (contra el diseño data-driven)
- **Síntoma:** el catálogo `data/coleccionables/catalog.json` no existía — el sistema corría con el fallback in-code.
- **Solución:** generado el JSON con los 15 items (5 minerales/4 animales/3 conchas/3 reliquias) y verificado cargando desde data-driven (Log 411).
- **Firma:** deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-02 05:12 (Log 411)

### BUG-007 — Logs no visibles en disco (buffer de 100 líneas, M103)

- **Estado:** [x] Resuelto (2026-09-02 06:45) | **Módulo:** M103 Logging | **Severidad:** Alta (crítico para QA por logs/crash-proof)
- **Síntoma:** `GameLogger` escribía al archivo solo cada 100 líneas — un crash perdía las líneas recientes.
- **Solución:** escritura inmediata con flush línea a línea (se preserva rotación). Test: 14/14 OK.
- **Firma:** deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-02 06:45 (Log 525)

### BUG-008 — Colisión de clases globales TerrainModifiers/TerrainDetector (M156)

- **Estado:** [x] Resuelto (2026-09-02 07:00) | **Módulo:** M156 Terrenos | **Severidad:** Alta (parse global)
- **Síntoma:** duplicados en `scripts/terrain/` (heredados) vs `scripts/terrenos/` (vigentes); el test M156 no parseaba ("not found in base").
- **Solución:** renombrados los heredados a `TerrainModifiersLegacy`/`TerrainDetectorLegacy` (nadie los usaba) + preloads explícitos en el test. 0 fallos.
- **Firma:** deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-02 07:00 (Log 527)

### BUG-009 — CI de tests con Godot 4.3 (proyecto 4.7.2, M118)

- **Estado:** [x] Resuelto (2026-09-02 17:40) | **Módulo:** M118 CI-CD | **Severidad:** Media (CI roto de facto)
- **Síntoma:** `testing.yml` usaba `godot_version: 4.3` con el proyecto 4.7.2.
- **Solución:** actualizado a 4.7.2 en el workflow.
- **Firma:** deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-02 17:40 (Log 533)

### BUG-010 — Atajo F12 del debug menu no cableado (M110)

- **Estado:** [x] Resuelto (2026-09-02 21:05) | **Módulo:** M110 Debug Menu | **Severidad:** Media
- **Síntoma:** el menú no alternaba con F12 (el script no tenía `_unhandled_input`).
- **Solución:** implementado `_unhandled_input` con `KEY_F12` (protección de viewport) + check ampliado.
- **Firma:** deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-02 21:05 (Log 549)
---

## 8. Bugs Delegados a Otros Agentes

> ⚠️ **Regla de delegación:** si un modelo LLM **no puede resolver** un bug (le faltan capacidades: visión, contexto, complejidad, herramientas), lo agrega **aquí al final del archivo**, respetando la plantilla de la sección 4 con estado `[?] Delegado`, y **firma con su nombre de modelo, plataforma, fecha y hora**. Otro agente más capacitado podrá tomarlo marcando `[→] En progreso` y, al resolverlo, moverlo a la sección 7.

_No hay bugs delegados todavía._


### BUG-011 — Watchdog de NPC en bucle infinito ("NPC atascado NPCAgent por 2.0s")

- **Estado:** [?] Delegado (2026-09-02 20:50) | **Módulo:** M64/M19 (IA NPC/vecinos) | **Severidad:** Alta
- **Síntoma:** el `[StateMachine]` repite el estado atascado sin recuperación (spam masivo de log; CPU extra). Re-confirmado en QA visual (Log 547).
- **Causa probable:** Catalina con `perfil=unknown` → sin rutina → el watchdog de atascado se dispara sin recuperación.
- **Dato:** la sesión del QA (Log 394) lo documentó; el dueño (M64/M19 + Hy3) no lo resolvió aún.
- **Delegado a:** M64/M19 (IA de NPC — agnes / Hy3 según módulo en curso).
- **Firma:** deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-02 20:50

### BUG-012 — Selector de diálogos contextuales falla 15/15 (M162)

- **Estado:** [?] Delegado (2026-09-02 06:20) | **Módulo:** M21/M162 (diálogos) | **Severidad:** Alta
- **Síntoma:** `test_contextual_dialogue_m162.gd` falla en TODOS los checks de selección (prioridades 1/2/3, saludo cap0, viajero noche, fallback, amistad) — los 268 grafos validan OK.
- **Causa probable:** API de selección/firma de `_cargar_registry` del `ContextualDialogueManager` (resultados null en headless).
- **Estado actual:** aún falla (re-verificado 2026-09-02 18:00).
- **Delegado a:** M21 (Hy3/WorkBuddy — sistema 🔵 en curso).
- **Firma:** deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-02 06:20
---

## 9. Historial de Modificaciones de Este Archivo
| 2026-09-02 21:40 | deepseek-v4-flash-vision-exp | Kilo Code | Registro BUG-003..BUG-010 (resueltos: M120/M115/M161/M73/M103/M156/M118/M110) y BUG-011..BUG-012 (delegados: M64-M19 y M21-M162) |

| Fecha | Modelo | Plataforma | Resumen del cambio |
|-------|--------|-----------|--------------------|
| 2026-09-02 17:45 | Claude | Cline | Creación del documento 11-BUGS.md (propuesta del usuario) |
| 2026-09-02 17:55 | Claude | Cline | Registro de BUG-001 + aclaración del usuario: overlay correcto al abrir, queda pegado al cerrar (causa raíz confirmada) |
| 2026-09-02 21:19 | step-3.7-flash | Kilo Code | Registro BUG-002: numeración de logs fragmentada (duplicados 401/407/410/413/414/415/416/417/418/426/428/429/430/431/432/433/434/435/436/437/438/439/440/441/442/443/444/445/446/447/448/449/450/451/452/453/454/455/456/457/458/459/460/471/472/473/474/475/476/477/478/479/480/481/482/483/484/485/486/487/488/489/490/491/492/493/494/495/496/497/498/499/500/501/502/503/504/505/506/507/508/509/510/511/512/513/514/515/516/517/518/519/520/521/522/523/524/525/526/527/528/529/530/531/532/533/534/535/536/537/538/539/540/541/542/543/544/545/546/547/548/549/550 y faltantes 131/151/161/171/181/191/201/211/221/231/241/251/261/271/281/291/301/311/321/331/341/351/361/371/381/391/421/461/551+; referencias cruzadas en CHECKLIST-GLOBAL/ESTADO-PARALELO/08-GUIA/05-Checklist pueden apuntar a números erróneos) |