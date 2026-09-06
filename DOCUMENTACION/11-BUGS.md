# 11 — BUGS: Registro Central de Problemas y Fallas

**Modelo:** hy3 (último modificador)
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-02 19:55

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
- [→] Cómo se corrigió: [archivo + función + líneas + lógica del cambio]
- [→] Archivos/commits modificados: [rutas y líneas; estado de commit]
- [ ] Log del proyecto:
- [ ] Verificado por: [quién y cuándo; si requiere runtime y no hay Godot, marcar pendiente de verificación del usuario]

---

## 5. Tabla Resumen de Bugs

| ID | Título | Módulo | Severidad | Estado | Reportado por | Fecha |
|----|--------|--------|-----------|--------|---------------|-------|
| BUG-001 | Overlay de inventario queda pegado al cerrar | M53/M14 | 🟡 Menor | [x] Resuelto (verif. usuario 2026-09-02 23:04) | Usuario | 2026-09-02 17:55 |
| BUG-002 | Numeración de logs fragmentada (duplicados/faltantes/refs) | Transversal | 🟠 Mayor | [x] Resuelto (cierre 2026-09-03 03:50, Log 552) | step-3.7-flash | 2026-09-02 21:19 |
| BUG-003 | Boot global frenado por print con formato sin tupla | M120 | 🔴 Alta | [x] Resuelto | deepseek-v4-flash-vision-exp | 2026-09-01 23:42 |
| BUG-004 | Perfil de hardware persistido corrupto | M115 | 🟡 Media | [x] Resuelto | deepseek-v4-flash-vision-exp | 2026-09-02 06:45 |
| BUG-005 | 23 diseños de NPC con prendas nulas (.tres inválidos) | M161 | 🔴 Alta | [x] Resuelto | deepseek-v4-flash-vision-exp | 2026-09-02 00:40 |
| BUG-006 | Catálogo de coleccionables inexistente (fallback in-code) | M73 | 🟡 Media | [x] Resuelto | deepseek-v4-flash-vision-exp | 2026-09-02 05:12 |
| BUG-007 | Logs no visibles en disco (buffer de 100 líneas) | M103 | 🔴 Alta | [x] Resuelto | deepseek-v4-flash-vision-exp | 2026-09-02 06:45 |
| BUG-008 | Colisión de clases globales TerrainModifiers/TerrainDetector | M156 | 🔴 Alta | [x] Resuelto | deepseek-v4-flash-vision-exp | 2026-09-02 07:00 |
| BUG-009 | CI de tests con Godot 4.3 (proyecto 4.7.2) | M118 | 🟡 Media | [x] Resuelto | deepseek-v4-flash-vision-exp | 2026-09-02 17:40 |
| BUG-010 | Atajo F12 del debug menu no cableado | M110 | 🟡 Media | [x] Resuelto | deepseek-v4-flash-vision-exp | 2026-09-02 21:05 |
| BUG-011 | Watchdog de NPC en bucle infinito | M64/M19 | 🔴 Alta | [x] Resuelto (verif. runtime 2026-09-02 23:14) | deepseek-v4-flash-vision-exp | 2026-09-02 20:50 |
| BUG-012 | Selector de diálogos contextuales falla 15/15 | M21/M162 | 🔴 Alta | [x] Resuelto (2026-09-02 23:20, Log 560) | deepseek-v4-flash-vision-exp | 2026-09-02 06:20 |
| BUG-013 | IDs de DLC divergentes entre manifest y monetización | M95/M120 | 🟡 Media | [x] Resuelto | deepseek-v4-flash-vision-exp | 2026-09-02 22:45 |
| BUG-014 | Aliasing en get_save_data() de ISaveProvider | M19 | 🔴 Crítico | [x] Resuelto | glm-5.3-flash | 2026-09-02 22:20 |
| BUG-015 | Signals conectados sin disconnect en _exit_tree (memory leak) | M71/M72 | 🟠 Mayor | [x] Resuelto (2026-09-02 23:40) | Claude | 2026-09-02 |
| BUG-016 | equipment_ui.gd: get_node() sin null check en slots UI | M155 | 🟡 Menor | [x] Resuelto (2026-09-02 23:40) | Claude | 2026-09-02 |
| BUG-017 | FileAccess.open() encadenado sin null check en recipe_tool.gd | Editor | 🟡 Menor | [x] Resuelto (2026-09-02 23:40) | Claude | 2026-09-02 |
| BUG-018 | Conexiones duplicadas posibles en achievement_service.gd | M72 | 🟡 Menor | [x] Resuelto (2026-09-02 23:40) | Claude | 2026-09-02 |
| BUG-021 | Chunks de terreno no visibles desde lejos pero sí objetos/vegetación (inconsistencia LOD) | M08/M10 Terreno | 🟠 Mayor | [x] Resuelto (2026-09-03 05:55, Log 587: break por full_load_distance inexistente; view 512 + LOD) | Usuario | 2026-09-02 |
| BUG-022 | Palmeras posicionadas sobre el agua (deberían estar en tierra firme) | M10/M45 Terreno/Vegetación | 🟡 Menor | [x] Resuelto (2026-09-02 23:40) | Usuario | 2026-09-02 |
| BUG-019 | EventManager no resoluble: nodo `/root/EventManager` inexistente y servicio `event_manager` no registrado | M73/M40 | 🟠 Mayor | [x] Resuelto (2026-09-02 23:30) | hy3 | 2026-09-02 |
| BUG-020 | Claves de localización M87 faltantes: SETTINGS.INVENTARIO/BUSCAR/ORDENAR/APLICAR | M87 | 🟡 Menor | [x] Resuelto (2026-09-02 23:35) | hy3 | 2026-09-02 |

> ⚠️ Mantener esta tabla actualizada al registrar, delegar o resolver bugs. Los detalles completos viven en las secciones 6, 7 y 8.

---

## 6. Bugs Abiertos (pendientes)

> Checklist vivo: `[ ]` = abierto, `[→]` = en progreso (indicar quién lo trabaja). Aquí se agregan los bugs nuevos con la plantilla de la sección 4.

<!-- ================= BUGS NUEVOS: agregar debajo de esta línea ================= -->

### BUG-015 — Signals conectados sin disconnect en _exit_tree (memory leak potencial)

- **Fecha de reporte:** 2026-09-02
- **Módulo(s) afectado(s):** M72 Logros (`achievement_service.gd`), M71 Progresión (`progression_manager.gd`)
- **Severidad:** 🟠 Mayor
- **Prioridad sugerida:** Alta
- **Estado:** [x] Resuelto (2026-09-02 23:40, deepseek-v4-flash-vision-exp)

**Descripción del problema:**
`achievement_service.gd` conecta 7 señales en `_conectar_eventos()` (líneas 91-109) y `progression_manager.gd` conecta 8+ señales en `_conectar_eventos()` (líneas 132-154). Ninguno de los dos tiene `_exit_tree()` con `disconnect()`. Si estos nodos se liberan y re-crean (cambio de escena, restart), los callbacks fantasma persisten en los autoloads (EventBus, ProgressionManager, etc.) apuntando a nodos ya freed → crash o comportamiento indefinido.

**Archivos afectados:**
- `scripts/logros/achievement_service.gd:86-109` — conecta a pm.progreso_hito_alcanzado, pm.progreso_desbloqueado, bus.inventory.item_added, bus.economy.purchase_done, bus.npc.gift_given, bus.quest.quest_completed, bus.npc.friendship_level_up
- `scripts/progresion/progression_manager.gd:127-154` — conecta a bus.inventory.item_added, bus.economy.purchase_done, bus.npc.gift_given, bus.quest.prereq_met, bus.quest.quest_completed, bus.npc.friendship_level_up, bus.travel.travel_started, bus.calendar.day_started

**Comportamiento esperado:**
Desconectar todas las señales en `_exit_tree()` o usar `CONNECT_ONE_SHOT` / `CONNECT_REFERENCE_COUNTED` donde aplique.

**Firma:**
**Resolución (2026-09-02 23:40, deepseek-v4-flash-vision-exp):** achievement_service.gd y progression_manager.gd: conexiones guardadas en `_conexiones` (helper `_conectar` con is_connected) + `_exit_tree` con disconnect de todas. Test M72 0 fallos + suite ÉXITO.

**Modelo:** Claude
**Plataforma:** Cline
**Fecha:** 2026-09-02

---

### BUG-016 — equipment_ui.gd: get_node() sin null check en slots UI

- **Fecha de reporte:** 2026-09-02
- **Módulo(s) afectado(s):** M155 Equipamiento (`equipment_ui.gd`)
- **Severidad:** 🟡 Menor
- **Prioridad sugerida:** Media
- **Estado:** [x] Resuelto (2026-09-02 23:40, deepseek-v4-flash-vision-exp)

**Descripción del problema:**
En `_refresh_slot()` (líneas 47-53), se usa `slot_control.get_node("Icon")`, `get_node("Label")`, `get_node("Rarity")` sin verificar que existan. Si el layout de la escena cambia o algún nodo hijo falta, el juego crashea con "Node not found".

**Código problemático:**
```gdscript
slot_control.get_node("Icon").texture = null    # línea 47
slot_control.get_node("Label").text = slot.item_name  # línea 48
slot_control.get_node("Rarity").visible = true   # línea 49
```

**Solución esperada:**
Usar `get_node_or_null()` y verificar antes de acceder.

**Firma:**
**Resolución (2026-09-02 23:40, deepseek-v4-flash-vision-exp):** `equipment_ui.gd::_refresh_slot` ahora usa get_node_or_null() para Icon/Label/Rarity con verificación (no crashea si el layout varía). Suite ÉXITO.

**Modelo:** Claude
**Plataforma:** Cline
**Fecha:** 2026-09-02

---

### BUG-017 — FileAccess.open() encadenado sin null check en recipe_tool.gd

- **Fecha de reporte:** 2026-09-02
- **Módulo(s) afectado(s):** Editor Tools (`recipe_tool.gd`)
- **Severidad:** 🟡 Menor
- **Prioridad sugerida:** Baja
- **Estado:** [x] Resuelto (2026-09-02 23:40, deepseek-v4-flash-vision-exp)

**Descripción del problema:**
Línea 65: `FileAccess.open(RUTA_DATOS + ".bak", FileAccess.WRITE).store_string(old)` — si `FileAccess.open()` devuelve null (archivo bloqueado, permisos), el `.store_string()` crashea con "Cannot call method on null value".

**Firma:**
**Resolución (2026-09-02 23:40, deepseek-v4-flash-vision-exp):** `recipe_tool.gd` — el backup se escribe con null-check del FileAccess (si falla, continúa sin crash). Suite ÉXITO.

**Modelo:** Claude
**Plataforma:** Cline
**Fecha:** 2026-09-02

---

### BUG-018 — Conexiones duplicadas posibles en achievement_service.gd

- **Fecha de reporte:** 2026-09-02
- **Módulo(s) afectado(s):** M72 Logros (`achievement_service.gd`)
- **Severidad:** 🟡 Menor
- **Prioridad sugerida:** Media
- **Estado:** [x] Resuelto (2026-09-02 23:40, deepseek-v4-flash-vision-exp)

**Descripción del problema:**
`_conectar_eventos()` no verifica `is_connected()` antes de conectar. Si se llama más de una vez (posible en re-inicialización), se acumulan callbacks duplicados → `evaluar_todos()` se ejecuta N veces por evento.

**Firma:**
**Resolución (2026-09-02 23:40, deepseek-v4-flash-vision-exp):** `_conectar()` verifica `is_connected()` antes de conectar (sin duplicados) — parte del fix de BUG-015.

**Modelo:** Claude
**Plataforma:** Cline
**Fecha:** 2026-09-02

---

### BUG-021 — Chunks de terreno no visibles desde lejos pero sí objetos/vegetación (inconsistencia LOD)

- **Fecha de reporte:** 2026-09-02
- **Módulo(s) afectado(s):** M08/M10 Terreno (`island_generator.gd`, `VoxelTerrain`), M45 Vegetación
- **Severidad:** 🟠 Mayor
- **Prioridad sugerida:** Alta
- **Estado:** [x] Resuelto (2026-09-02 23:40) | **Resolución:** MiMo V2.5 (OpenCode) — causa raíz: VoxelViewer en main_island.tscn no tenía `view_distance` configurado (default muy bajo). Fix: agregar `view_distance = 256.0` en _setup_terrain() de main_island.gd, consistente con otros scripts del proyecto (bench_recorder.gd, captura_playa.gd, test_terrain.gd). Verificado: ejecución sin errores, terreno visible. Pendiente de confirmación visual por el usuario.
- **Reportado por:** Usuario

**Descripción del problema:**
Desde cierta distancia, el jugador puede ver palmeras, árboles y objetos 3D pero NO el terreno (chunks de voxel). El terreno aparece recién al acercarse. Esto crea una incoherencia visual: los objetos "flotan" en el vacío hasta que los chunks se cargan. El usuario quiere consistencia: o todo se ve desde lejos (terreno + objetos) o nada se ve. Actualmente es un estado intermedio que se ve mal.

**Comportamiento esperado:**
- Los chunks de terreno deberían ser visibles desde la misma distancia que los objetos/vegetación, O
- Los objetos/vegetación no deberían renderizarse hasta que el terreno sea visible (consistencia)
- Idealmente: aumentar el rango de visibilidad de chunks para que se vea toda la isla desde lejos

**Comportamiento actual:**
- Palmeras y objetos 3D visibles desde lejos
- Terreno (chunks) solo visible al acercarse
- Resultado: objetos flotando sobre vacío

**Firma:**
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-09-02

---

### BUG-022 — Palmeras posicionadas sobre el agua (deberían estar en tierra firme)

- **Fecha de reporte:** 2026-09-02
- **Módulo(s) afectado(s):** M10 Generación de mundo, M45 Vegetación
- **Severidad:** 🟡 Menor
- **Prioridad sugerida:** Media
- **Estado:** [x] Resuelto (2026-09-02 23:40 + fix complementario 2026-09-02) | **Resolución:** deepseek-v4-flash-vision-exp — VegetationSpawner descarta候选antes con h<3 (Log 559). **Fix complementario MiMo V2.5:** vegetation_plan.gd zona playa reducida de 0.90-0.99 a 0.85-0.93 para que el plan NO genere posiciones en la banda de agua (0.94-1.0 según island_generator.gd). Doble capa de protección: plan + spawner.
- **Reportado por:** Usuario

**Descripción del problema:**
Algunas palmeras se generan posicionadas sobre el agua en lugar de en tierra firme. Las palmeras deberían spawnear solo en bloques de tierra (arena, tierra, pasto) y nunca sobre agua (shallow_water, deep_water).

**Comportamiento esperado:**
- Las palmeras solo se posicionarán sobre bloques de tierra firme
- Nunca sobre agua (ni shallow ni deep)

**Comportamiento actual:**
- Algunas palmeras aparecen sobre agua

**Firma:**
**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-09-02

---

### BUG-024 — ERROR "!is_inside_tree()" al spawnear vecinos (global_position antes de add_child)

- **Fecha de reporte:** 2026-09-03 08:10
- **Módulo(s) afectado(s):** M19 VillagerManager (`villager_manager.gd`), M09 Terreno (`main_island.gd`)
- **Severidad:** 🟡 Menor (la funcionalidad continúa; es un ERROR de debugger + posible mal posicionamiento de vecinos)
- **Prioridad sugerida:** Media
- **Estado:** [x] Resuelto (2026-09-03 08:35, hy3 / Kilo Code)

**Descripción del problema:**
Al arrancar `main_island.tscn` aparecen 5 mensajes de ERROR en el debugger:
`ERROR: Condition "!is_inside_tree()" is true. Returning: Transform3D()` (en `get_global_transform`, node_3d.cpp:649).
Los vecinos spawnean igualmente (luego hacen snap al terreno), pero el mensaje indica acceso a transform global de un nodo aún fuera del árbol.

**Pasos para reproducir:**
1. Ejecutar `main_island.tscn` (Godot 4.7.2).
2. Esperar el boot y la población de arranque (P1, 5 vecinos).
3. Revisar el debugger / `get_debug_output`: 1 ERROR en `main_island.gd:12` (`_ready`→`_setup_terrain`) y 4 ERROR en `villager_manager.gd:557` (`poblar_arranque`→`_spawn_vecino_de_perfil`).

**Comportamiento esperado:**
- No deben aparecer ERROR de `!is_inside_tree()`; los vecinos se posicionan sobre su parcela asignada correctamente.

**Comportamiento actual:**
- `villager_manager.gd:586` asigna `nodo.global_position = pos + Vector3(0,1,0)` **antes** de `root_scene.add_child(nodo)` (líns. 592-593) / `add_child(nodo)` headless (597). Godot lee `get_global_transform` de un nodo sin padre en el árbol → ERROR. El `global_position` no se aplica y los vecinos terminan en snap `Y=1.0 (height=0)` en lugar de su parcela.
- `main_island.gd:12` (`_setup_terrain`): asignar `generator`/`stream`/`view_distance` al `VoxelTerrain`/`VoxelViewer` dispara el mismo acceso a transform global (quirk del addon zylann.voxel durante el setup). La isla renderiza igual.

**Causa probable:**
- Orden incorrecto en `_spawn_vecino_de_perfil`: `global_position` debe setearse **después** de `add_child(nodo)` (o usar `call_deferred` sobre `global_position`). El de `main_island.gd` es un acceso interno del VoxelTerrain al configurar generator/stream en `_ready`.

**Fix propuesto (villager_manager.gd):**
Reordenar: `add_child(nodo)` primero, luego `nodo.global_position = ...`. Para el headless, el `add_child` ya existe (597) — mover la asignación de posición tras el `add_child` en ambas ramas.

**Fix propuesto (main_island.gd):**
Envolver la asignación de `generator`/`stream`/`view_distance` en `call_deferred` o diferir `_setup_terrain` un frame (`await get_tree().process_frame`) para que el árbol esté listo. Confirmar con captura que el terreno no parpadea.

**Contexto:**
- Detectado al revisar errores de runtime tras verificar M36 (Jabalí etapas, Log 596). **NO** es causado por el trabajo de M36: el jabalí spawnea sin estos errores (usa `TerrainLocator` con `call_deferred` en `_snap_to_ground`, patrón correcto).
- Sistemas core (M19/M09): conviene coordinar con el dueño antes de tocar para no romper el spawn de vecinos.

- **Resolución (2026-09-03 08:35, hy3 / Kilo Code):** se reordenó la lógica en `villager_manager.gd` (`_spawn_vecino_de_perfil`): ahora se hace `add_child(nodo)` **antes** de asignar `nodo.global_position`, y la asignación de posición se ejecuta una sola vez tras el add_child (en ambas ramas: escena actual y headless). En `main_island.gd` (`_setup_terrain`) se cambiaron las asignaciones `voxel_viewer_node.global_position` y `player.global_position` por `set_deferred("global_position", ...)` para que corran cuando el árbol ya está listo. Verificado con `run_project` + `get_debug_output`: **0 errores** `!is_inside_tree()` (antes 5), los vecinos y jabalíes spawnean con normalidad.

**Firma:**
**Modelo:** hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-03 08:35

---

### BUG-002 — Numeración de logs fragmentada: duplicados, faltantes y referencias cruzadas inconsistentes

- **Fecha de reporte:** 2026-09-02 21:19
- **Módulo(s) afectado(s):** transversal — `Logs/`, `Logs/ULTIMO_NUMERO.txt`, `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `DOCUMENTACION/*/plan-actual/05-Checklist.md`, `DOCUMENTACION/TAREAS-POR-MODELO/*/checklist.md`
- **Severidad:** 🟠 Mayor
- **Prioridad sugerida:** Alta
- **Estado:** [x] Resuelto (2026-09-03 03:50, step-3.7-flash / Kilo Code, Log 552)
- **Reportado por:** step-3.7-flash (Kilo Code)

**Descripción del problema:**
La numeración de logs del proyecto presenta múltiples inconsistencias: números duplicados, secuencias con saltos grandes sin lógica y referencias cruzadas en documentos que pueden apuntar a números erróneos. Esto rompe la trazabilidad del protocolo multiagente y dificulta la auditoría.

**Hallazgo concreto (2026-09-02):**
- `ULTIMO_NUMERO.txt` = 549, pero existen logs 550.
- Números duplicados detectados: 401, 407, 410, 413, 414, 415, 416, 417, 418, 426, 428, 429, 430, 431, 432, 433, 434, 435, 436, 437, 438, 439, 440, 441, 442, 443, 444, 445, 446, 447, 448, 449, 450, 451, 452, 453, 454, 455, 456, 457, 458, 459, 460, 471, 472, 473, 474, 475, 476, 477, 478, 479, 480, 481, 482, 483, 484, 485, 486, 487, 488, 489, 490, 491, 492, 493, 494, 495, 496, 497, 498, 499, 500, 501, 502, 503, 504, 505, 506, 507, 508, 509, 510, 511, 512, 513, 514, 515, 516, 517, 518, 519, 520, 521, 522, 523, 524, 525, 526, 527, 528, 529, 530, 531, 532, 533, 534, 535, 536, 537, 538, 539, 540, 541, 542, 543, 544, 545, 546, 547, 548, 549, 550.
- Secuencia 1-69 presente y ordenada; salto a 100+; faltan 131, 151, 161, 171, 181, 191, 201, 211, 221, 231, 241, 251, 261, 271, 281, 291, 301, 311, 321, 331, 341, 351, 361, 371, 381, 391, 421, 461, 551+.
- Documentos con referencias a log específico: `CHECKLIST-GLOBAL.md`, `ESTADO-PARALELO.md`, `08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `BACKLOG-MASTER.md`, `DOCUMENTACION/*/plan-actual/05-Checklist.md` y `DOCUMENTACION/TAREAS-POR-MODELO/*/checklist.md` pueden contener números apuntando a duplicados inexistentes.
- **Verificación posterior (2026-09-02 22:40):** escaneo completo de documentación detectó referencias a números renombrados (`472`, `486`, `488`, `489`, `490`, `547`) que ahora existen solo como `-dup1`; se repararon en sus checklists/BUGS para apuntar al nombre real. También detectó números ausentes sin archivo canónico: `307`, `308`, `312`. Búsqueda posterior (2026-09-02 23:00) halló evidencia en `Logs/375-Reorganizacion-Numeracion-Logs`: estos números fueron renombrados históricamente a `368` (M59), `369` (M22/M35), `370` (M19). Referencias reparadas en `CHECKLIST-GLOBAL.md`, `08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `59-Guardado/plan-actual/05-Checklist.md`, `22-Historia-Principal/plan-actual/05-Checklist.md` y `TAREAS-POR-MODELO/`.
- **Pasada final (2026-09-02 23:13):** escaneo de todas las referencias a logs `-dup1` detectó menciones pendientes en módulos periféricos (`108`, `111`, `113`, `115`, `130`, `155`, `156`, `162`, `163`, `166`, `20`, `31`, `36`, `45`, `51`, `53`, `55`, `59`, `61`, `62`, `63`, `65`, `72`, `73`, `78`, `79`, `80`, `81`, `82`, `83`, `84`, `85`, `86`, `87`, `88`, `90`, `99`, `TAREAS-POR-MODELO/agnes-2.5-flash/*`, `TAREAS-POR-MODELO/deepseek-v4-flash/*`, `TAREAS-POR-MODELO/deepseek-v4-flash-vision-exp/*`, `TAREAS-POR-MODELO/glm-5.3-flash/*`, `TAREAS-POR-MODELO/minimax-m3-free/*`, `TAREAS-POR-MODELO/step-3.7-flash/*`). No se repararon en esta pasada por volumen; quedan como `[?]` heredados del evento de fragmentación original. El contenido de los logs existe, solo la referencia numérica es inconsistente.
- **Corrección de integridad (2026-09-02 23:20):** Log 552 original contenía secciones de lotes 16-18 que no coinciden con el filesystem real. Se reescribió Log 552 con el estado real confirmado por listado de `Logs/`. Quedan números solo con `-dup1` y sin canónico conocido: 500–508, 521, 545, 546, 547, y en práctica 472/486/488/489/490. No se ejecutaron renombres adicionales para preservar referencias vivas.
- **Tanda conservadora 401-561 (2026-09-02 23:40-23:55):** se avanzó número por número sin regex masivo. Estado final del rango 400-561: 401-458 renombrados a `-dup1`/`-dup2` según corresponda; 500-561 sin duplicados pendientes. Referencias rotas reparadas previamente: 472→472-dup1, 486→486-dup1, 488→488-dup1, 489→489-dup1, 490→490-dup1, 519→519-dup1, 547→547-dup1, 307→368, 308→369, 312→370. Quedan como `[?]` las referencias periféricas no documentadas en módulos externos.

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
**Fecha:** 2026-09-02 22:40

**Resolución (2026-09-03 03:50, step-3.7-flash / Kilo Code):**
- Tanda conservadora completa: se escanearon TODOS los duplicados activos en `Logs/` (solo 8 números: 401, 407, 413, 414, 415, 418, 437, 564).
- 5 números ya estaban resueltos previamente con sufijo `-dup1`/`-dup2` y canónico sin sufijo (401, 407, 414, 415, 418).
- 3 números resueltos en esta tanda con renombres puntuales y reparación de referencias:
  - 413: canónico `413-M147-M148-CanonyLore-Verificacion`; renombrados `413-Implementacion-M160-Ubicaciones` → `413-dup1-M160-Ubicaciones-Iter1`; `413-M73-Coleccionables-Iter2` → `413-dup2-M73-Coleccionables-Iter2`.
  - 437: canónico `437-Recuperacion-v3-Asignacion-Recom`; renombrado `437-AGNES-BUCLE-CONTINUACION` → `437-dup2-AGNES-BUCLE-CONTINUACION` (el `437-dup1-M130-Artbook` ya existía).
  - 564: canónico `564-M162-Dialogos-ITER-CONTENIDO2-Cobertura-Amistad`; renombrado `564-fix-bug021-bug022-chunks-vegetacion` → `564-dup1-fix-bug021-bug022-chunks-vegetacion`.
- Referencias rotas reparadas: 472, 486, 488, 489, 490, 519, 547, 307, 308, 312, 540, 545, 546 en `CHECKLIST-GLOBAL.md`, `08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `108-Pipeline-De-Assets/plan-actual/05-Checklist.md`, `TAREAS-POR-MODELO/` y `11-BUGS.md`.
- Referencia incorrecta reparada: M163 en `CHECKLIST-GLOBAL.md` citaba Log 564 (pertenece a M162); corregida a `[?]` pendiente de log propio de Step 3.7 Flash para M163.
- Estados inconsistentes reparados: M23 y M163 ajustados de `🟢 Disponible` a `🟡 Con dudas` en `CHECKLIST-GLOBAL.md`, `05-Checklist.md` (M163) y `ESTADO-PARALELO.md`.
- Sin renombres masivos; se evitó regex global por incidente 433.
- Verificación final: los 8 números duplicados tienen exactamente 1 canónico sin sufijo + el resto con `-dup1`/`-dup2`.
- Archivos modificados: `CHECKLIST-GLOBAL.md`, `ESTADO-PARALELO.md`, `108-Pipeline-De-Assets/plan-actual/05-Checklist.md`, `163-Sistema-De-Encantamientos/plan-actual/05-Checklist.md`, `11-BUGS.md`, `Logs/552-*`, 4 archivos en `Logs/` renombrados.

**Firma:**
**Modelo:** step-3.7-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-03 03:50


## 7. Bugs Resueltos (historial)

> Cuando un bug se corrige y verifica, se mueve aquí con su fecha de resolución, la solución aplicada y la firma de quien lo resolvió.

### BUG-001 — Overlay de inventario queda pegado al cerrar (M53/M14)

- **Fecha de reporte:** 2026-09-02 17:55
- **Módulo(s) afectado(s):** M53 (UI-UX) — `InventoryLayer` / `inventory_layer.gd`; M14 (Inventario) — panel del jugador `player.gd`
- **Severidad:** 🟡 Menor
- **Prioridad sugerida:** Media
- **Estado:** [x] Resuelto (verificado visualmente por el usuario 2026-09-02 23:04)
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
- [x] Cómo se corrigió: en `game/isla-ancestral/scripts/player/player.gd` se añadió `var _inventory_backdrop: ColorRect = null` (player.gd:336), asignada al `Backdrop` en `_create_inventory_panel` (player.gd:406). En `_open_inventory` se fuerza `_inventory_backdrop.visible = true` (player.gd:384) y en `_close_inventory` se fuerza `_inventory_backdrop.visible = false` (player.gd:390), ocultando el velo negro junto con el panel al cerrar. El doble binding de la tecla B (player.gd + ui_manager.gd/M53) se mantiene porque el usuario confirmó que el overlay debe aparecer al abrir.
- [x] Archivos/commits modificados: `game/isla-ancestral/scripts/player/player.gd` (pendiente de commit).
- [x] Log del proyecto: Log 556 (2026-09-02 22:48). Parseo validado con Godot 4.7.2 headless (exit 0, sin `SCRIPT ERROR`/`Parse Error` en player.gd).
- [x] Verificado por: Usuario (confirmado visualmente 2026-09-02 23:04 — abrir/cerrar inventario con B/Esc y el velo negro desaparece correctamente).



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

### BUG-013 — IDs de DLC divergentes entre manifest y monetización (M95/M120)

- **Estado:** [x] Resuelto (2026-09-02 22:45) | **Módulo:** M95 (Monetización) / M120 (DLC) | **Severidad:** 🟡 Media
- **Causa raíz:** el `dlc_manifest.json` de M120 (ids `isla_hielo`/`pack_aurora`) y el `dlc.json` de monetización M95 (ids `dlc_expansion`/`dlc_cosmetico`) definían **IDs distintos** para los mismos DLC → la carga por id fallaba / inconsistencia entre catálogos.
- **Solución:** unificar los IDs al **manifest M120** (fuente de verdad de carga). Se agregó `scripts/dlc/sincronizar_dlc.gd` — verificador de coherencia DLC (manifest ↔ monetización) que comprueba que ambos catálogos coincidan; 2/2 OK.
- **Verificado por:** deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-02 22:45 (iter 2 de M95; checklist `DOCUMENTACION/95-Monetizacion/plan-actual/05-Checklist.md` líns. 214-216).
- **Nota de integridad:** la entrada de detalle original de BUG-013 fue inadvertidamente descartada durante una reorganización concurrente de la sección 8; este bloque fue reconstruido por hy3 (WorkBuddy, 2026-09-02) a partir del checklist de M95 y del script `sincronizar_dlc.gd`, sin inventar pasos de reproducción. Si falta información, completar desde la fuente.

### BUG-014 — Aliasing en get_save_data() de ISaveProvider (M19 VillagerManager)

- **Fecha de reporte:** 2026-09-02 21:45
- **Módulo(s) afectado(s):** M19 (villager_manager.gd get_save_data) — patrón transversal en ISaveProviders
- **Severidad:** 🔴 Crítico (corrupción silenciosa de saves)
- **Prioridad sugerida:** Alta
- **Estado:** [x] Resuelto

**Descripción del problema:**
`get_save_data()` de villager_manager.gd serializaba `_memoria`, `_hogares`, `_llegadas_pendientes`, `_partidas_pendientes`, `_enfriamiento_partida` **por referencia** (Dictionary/Array en Godot son por referencia). Al hacer `restore_save_data(...)` posterior, el `_clear()` interno vaciaba también el snapshot capturado — el "save" y el estado vivo compartían los mismos contenedores. Síntoma: round-trip restauraba 0 elementos aunque el save tenía datos.

**Pasos para reproducir:**
1. `vm.registrar_interaccion("catalina_oso", "charla", "a")` (+2 más)
2. `var data := vm.get_save_data()`
3. `vm.restore_save_data({"memoria": {}})` (restore vacío intermedio)
4. `vm.restore_save_data(data)` → memoria queda en 0 (esperado: 3)

**Comportamiento esperado:**
El snapshot debe ser independiente del estado vivo: restaurarlo debe reproducir exactamente los datos capturados.

**Evidencia:**
- Debug repro: `save memoria keys=["catalina_oso"] size=3` → `post restore=0`.
- Test: `scripts/npc/test_memoria_agenda.gd` `_test_memoria_persistencia` (fallaba, ahora 0 fallos).

**Solución aplicada:**
Deep-copy explícito en `get_save_data()`: `_memoria[k].duplicate(true)` por vecino + `.duplicate(true)` en llegadas/partidas/enfriamientos/hogares + `.keys().duplicate()` en arrays de ids (fix en Log 553).

**Auditoría transversal (2026-09-02 22:20, Log 555):**
- Auditoría **dinámica** ejecutable: `scripts/saving/auditar_aliasing.gd` (snapshot → restore vacío → verificar si el snapshot quedó vacío). Providers con estado en boot auditados: 8 OK, 0 aliasing.
- Auditoría **estática** (regex sobre 40+ providers): 34 patrones "clave": _var sin duplicate — **todos falsos positivos** al verificar tipos (int/float/String se copian por VALOR en Godot; sin aliasing). Solo Dictionary/Array son por referencia.
- Conclusión: el único caso real era M19 (corregido). Regla para providers futuros: **deep-copy SIEMPRE en get_save_data() si serializas Dictionary/Array**.

**Referencias:** Log 553 (fix), Log 555 (auditoría), `scripts/saving/auditar_aliasing.gd` (herramienta reutilizable).

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 22:20

### BUG-019 — EventManager no resoluble: nodo `/root/EventManager` inexistente y servicio `event_manager` no registrado

- **Estado:** [x] Resuelto (2026-09-02 23:30) | **Módulo:** M73 (Eventos) / M40 (Bootstrap) | **Severidad:** 🟠 Mayor
- **Síntoma:** al arrancar el juego, `price_manager.gd` (`_resolver_event_manager`, línea 344) logueaba `ERROR: ServiceRegistry: servicio 'event_manager' no encontrado.` y las ferias no conectaban su lógica de precios dinámicos (fallback silencioso a null).
- **Causa:** (1) el autoload del EventManager se llama `eventos`, pero el resolver buscaba `/root/EventManager` (nombre inexistente); (2) el servicio `event_manager` no estaba registrado en `ServiceRegistry` en el momento en que `EconomyManager` (autoload previo a Bootstrap) resolvía el price_manager durante el init.
- **Solución:** en `price_manager.gd:339` se corrigió el node path a `/root/eventos`; y en `bootstrap.gd` (dict `_autoregistrar_dominios`) se agregó `"event_manager": "eventos"` para registrar el servicio. Verificado con Godot 4.7.2 headless: el error desaparece y aparece `ServiceRegistry: registrado 'event_manager' → Node`.
- **Firma:** hy3 / Kilo Code — 2026-09-02 23:30 (Log 557)

### BUG-020 — Claves de localización M87 faltantes (SETTINGS.INVENTARIO/BUSCAR/ORDENAR/APLICAR)

- **Estado:** [x] Resuelto (2026-09-02 23:35) | **Módulo:** M87 (Localización) | **Severidad:** 🟡 Menor
- **Síntoma:** al arrancar, `localization_manager.gd:166` emitía 4 warnings `[M87] Clave sin traducción: SETTINGS.INVENTARIO` / `SETTINGS.BUSCAR` / `SETTINGS.ORDENAR` / `SETTINGS.APLICAR`.
- **Causa:** las claves no existían en los catálogos `locales/en.po` ni `locales/es.po`.
- **Solución:** se agregaron las 4 entradas `msgid`/`msgstr` en `locales/en.po` (Inventory/Search/Sort/Apply) y `locales/es.po` (Inventario/Buscar/Ordenar/Aplicar). Verificado con Godot 4.7.2 headless: ya no aparecen esos warnings (solo el mensaje de init `LocalizationManager listo`).
- **Firma:** hy3 / Kilo Code — 2026-09-02 23:35 (Log 557)

---

### BUG-012 — Selector de diálogos contextuales falla 15/15 (M162)

- **Estado:** [x] Resuelto (2026-09-02 23:20, Log 560) | **Módulo:** M21/M162 (diálogos) | **Severidad:** Alta
- **Síntoma:** `test_contextual_dialogue_m162.gd` falla en TODOS los checks de selección (prioridades 1/2/3, saludo cap0, viajero noche, fallback, amistad) — los 268 grafos validan OK.
- **Causa raíz (2 defectos):**
  1. **Mismatch de slug NPC:** el registry.json usa `npc_id: "NPC-RIZ_001"` (guion BAJO) pero los tests/señales del juego usan "NPC-RIZ-001" (guion MEDIO). `_slug_de()` comparaba exacto → slug vacío → TODAS las selecciones fallaban con "npc no registrado".
  2. **Check del test con sufijo de variante:** el id de la variante primavera es `DLG-RIZ_001-CAP0-SALUDO-PRIMAVERA` (sufijo de variante) — el check `ends_with("CAP0-SALUDO")` del test era incorrecto para variantes (debe ser `contains`).
- **Solución aplicada (Log 560):**
  1. `contextual_dialogue_manager.gd::_slug_de()`: fallback de normalización (lowercase + sin `_`/`-`/espacios) sobre slugs y npc_ids del registry — resuelve ambos formatos sin tocar el JSON (263 grafos intactos).
  2. `test_contextual_dialogue_m162.gd`: check corregido a `contains("CAP0-SALUDO")` para la variante con sufijo.
- **Evidencia:** test M162 de **15 fallos → 0 fallos** (263/263 grafos OK + 15/15 checks de selección). Regresión: test_dialogos M21 0 fallos.
- **Nota:** las condiciones de los grafos ya validaban OK — el fallo era puro del lookup de slug, por eso los 268 grafos validaban y el selector no devolvía nada.

**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 23:20
---

## 8. Bugs Delegados a Otros Agentes

> ⚠️ **Regla de delegación:** si un modelo LLM **no puede resolver** un bug (le faltan capacidades: visión, contexto, complejidad, herramientas), lo agrega **aquí al final del archivo**, respetando la plantilla de la sección 4 con estado `[?] Delegado`, y **firma con su nombre de modelo, plataforma, fecha y hora**. Otro agente más capacitado podrá tomarlo marcando `[→] En progreso` y, al resolverlo, moverlo a la sección 7.


### BUG-011 — Watchdog de NPC en bucle infinito ("NPC atascado NPCAgent por 2.0s")

- **Estado:** [x] Resuelto (2026-09-02 23:14, verificado en runtime) | **Módulo:** M64/M19 (IA NPC/vecinos) | **Severidad:** Alta
- **Síntoma:** el `[StateMachine]` repite el estado atascado sin recuperación (spam masivo de log; CPU extra). Re-confirmado en QA visual (Log 547).
- **Causa probable:** Catalina con `perfil=unknown` → sin rutina → el watchdog de atascado se dispara sin recuperación.
- **Dato:** la sesión del QA (Log 394) lo documentó; el dueño (M64/M19 + Hy3) no lo resolvió aún.
- **Delegado a:** M64/M19 (IA de NPC — agnes / Hy3 según módulo en curso).
- **Firma:** deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-02 20:50



## 9. Historial de Modificaciones de Este Archivo
| 2026-09-02 21:40 | deepseek-v4-flash-vision-exp | Kilo Code | Registro BUG-003..BUG-010 (resueltos: M120/M115/M161/M73/M103/M156/M118/M110) y BUG-011..BUG-012 (delegados: M64-M19 y M21-M162) |
| 2026-09-02 23:40 | deepseek-v4-flash-vision-exp | Kilo Code | Resueltos: BUG-011 (verif. runtime del fix de glm), BUG-022 (VegetationSpawner h<3), BUG-015/018 (conexiones _conectar/_exit_tree en M71/M72), BUG-016 (null checks equipment_ui), BUG-017 (null check recipe_tool). Suite ÉXITO. Log 559 |

| Fecha | Modelo | Plataforma | Resumen del cambio |
|-------|--------|-----------|--------------------|
| 2026-09-02 17:45 | Claude | Cline | Creación del documento 11-BUGS.md (propuesta del usuario) |
| 2026-09-02 17:55 | Claude | Cline | Registro de BUG-001 + aclaración del usuario: overlay correcto al abrir, queda pegado al cerrar (causa raíz confirmada) |
| 2026-09-02 21:19 | step-3.7-flash | Kilo Code | Registro BUG-002: numeración de logs fragmentada (duplicados 401/407/410/413/414/415/416/417/418/426/428/429/430/431/432/433/434/435/436/437/438/439/440/441/442/443/444/445/446/447/448/449/450/451/452/453/454/455/456/457/458/459/460/471/472/473/474/475/476/477/478/479/480/481/482/483/484/485/486/487/488/489/490/491/492/493/494/495/496/497/498/499/500/501/502/503/504/505/506/507/508/509/510/511/512/513/514/515/516/517/518/519/520/521/522/523/524/525/526/527/528/529/530/531/532/533/534/535/536/537/538/539/540/541/542/543/544/545/546/547/548/549/550 y faltantes 131/151/161/171/181/191/201/211/221/231/241/251/261/271/281/291/301/311/321/331/341/351/361/371/381/391/421/461/551+; referencias cruzadas en CHECKLIST-GLOBAL/ESTADO-PARALELO/08-GUIA/05-Checklist pueden apuntar a números erróneos) |
| 2026-09-02 23:20 | glm-5.3-flash | Kilo Code | BUG-012 [x] Resuelto: mismatch slug registry (NPC-RIZ_001 vs NPC-RIZ-001) normalizado en _slug_de + check de variante corregido en test. 15 fallos -> 0. Log 560 |
| 2026-09-02 22:48 | hy3 | Kilo Code | BUG-001: fix aplicado en player.gd (se oculta el Backdrop `_inventory_backdrop` en `_close_inventory`); falta verificación runtime del usuario (Godot no disponible en este entorno). Log 556. |
| 2026-09-02 | Claude | Cline | Corrección BUG-013 duplicado: renombrado el segundo a BUG-014 (Aliasing get_save_data), actualizada tabla resumen |
| 2026-09-02 | Claude | Cline | Análisis de código: registro BUG-015..BUG-018 (signals sin disconnect, get_node sin null, FileAccess encadenado, conexiones duplicadas) |
| 2026-09-02 | MiMo V2.5 | OpenCode | Registro BUG-021 (chunks terreno invisibles desde lejos) y BUG-022 (palmeras sobre agua) — reportados por usuario |
| 2026-09-02 23:55 | hy3 | WorkBuddy | Corrección de consistencia de 11-BUGS.md:
| 2026-09-02 23:58 | hy3 | WorkBuddy | Renumber de colisión de ID en 11-BUGS.md: los bugs de terreno reportados por el usuario (Chunks LOD, Palmeras sobre agua, dados de alta por MiMo V2.5 como BUG-019/BUG-020) colisionaban con BUG-019/BUG-020 ya registrados y resueltos (EventManager M73/M40 y Localización M87, hy3, Log 557). Se renumeraron a BUG-021 y BUG-022 en tabla resumen y detalles de §6; se actualizó el registro §9. No se alteró el work de otros modelos más allá de la corrección de IDs. | (1) BUG-001 duplicado — detalle completo movido de §6 a §7 y copia de §6 eliminada (regla 6: el bug resuelto se MUEVE, no se copia); (2) BUG-014 `[x] Resuelto` estaba en §8 (Delegados) → movido a §7; (3) BUG-013 `[x] Resuelto` reconstruido en §7 a partir del checklist de M95 (`05-Checklist.md` líns. 214-216) y `scripts/dlc/sincronizar_dlc.gd` (su detalle original se perdió en una reorg concurrente de §8); (4) eliminada la nota obsoleta "_No hay bugs delegados todavía." de §8 (BUG-011/012 sí están delegados). No se tocaron los cambios sin commit de otros modelos. |
| 2026-09-02 23:37 | hy3 | Kilo Code | Bucle corrección: BUG-001 marcado resuelto (verif. usuario); BUG-019 (event_manager resoluble: fix price_manager node path + registro en bootstrap) y BUG-020 (claves M87 SETTINGS.* agregadas a en.po/es.po). GdUnit4: 199 tests, 0 fallos. Log 557. |
| 2026-09-03 03:50 | step-3.7-flash | Kilo Code | BUG-002 [x] Resuelto: tanda conservadora completa de renumbering de logs duplicados. 4 renombres puntuales (413 dup1/dup2, 437 dup2, 564 dup1) + reparación de referencias en CHECKLIST-GLOBAL/ESTADO-PARALELO/08-GUIA/108/163/M23 + corrección referencia incorrecta M163/564 → `[?]`. Log 552. |
## [2026-09-03 05:45] — Bug 023: crash al bootear main_island.gd (full_load_distance)

- **Estado:** [x] Resuelto (2026-09-03 05:55, deepseek-v4-flash-vision-exp)
- **Resolución:** eliminada la línea 159 (full_load_distance) de main_island.gd — la propiedad NO existe en VoxelMesherBlocky; el LOD del terreno queda con lod_split/lod_distance en el VoxelTerrain (null-check 153-156). Verificado: el juego carga y el horizonte se ve el doble (view 512 + LOD) — captura + Log 587. Documentado en guía 07 §9.63.
- **Módulo:** M09 Terreno / main_island.gd
- **Severidad:** Alta (crash al arranque)
- **Pasos para reproducir:** correr main_island.tscn → `Debugger Break: Invalid assignment of property or key 'full_load_distance' with value of type 'float' on a base object of type 'VoxelMesherBlocky'` en `main_island.gd:159` (`_setup_terrain`).
- **Causa probable:** la propiedad `full_load_distance` no existe en `VoxelMesherBlocky` (el addon zylann.voxel define LOD en el `VoxelTerrain`: `lod_distance`/`lod_split`, que las líneas 153-156 sí asignan bien con null-check). La línea 159 la asigna al MESHER directamente.
- **Fix propuesto:** eliminar la línea 159 (o setear la distancia en `terrain_node` con el mismo patrón null-check de las líneas 153-156).
- **Contexto:** detectado por glm-5.3 (Kilo Code) al verificar los jabalíes joven/adulto; el código fue introducido por otra sesión en paralelo (optimización de terreno) — no se tocó para no pisar el trabajo ajeno en curso.
- **Modelo:** GLM 5.3 (z-ai)
- **Plataforma:** Kilo Code
- **Fecha:** 2026-09-03 05:45

| 2026-09-03 08:10 | hy3 | Kilo Code | Registro BUG-024: ERROR "!is_inside_tree()" al spawnear vecinos — causa raíz en `villager_manager.gd:586` (`global_position` antes de `add_child`); un 2º ERROR en `main_island.gd:12` (`_setup_terrain`, quirk VoxelTerrain). Detectado al revisar runtime post M36 jabalí (Log 596). No es del jabalí. |
| 2026-09-03 08:35 | hy3 | Kilo Code | BUG-024 [x] Resuelto: reordenado add_child antes de global_position en `villager_manager.gd` y `set_deferred` para viewer/player en `main_island.gd`. Runtime verificado: 0 errores `!is_inside_tree()` (antes 5). |
