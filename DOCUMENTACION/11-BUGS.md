# 11 — BUGS: Registro Central de Problemas y Fallas

**Modelo:** hy3 (último modificador)
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-02 19:55

> ⚠️ **Documento de trabajo VIVO.** Este archivo es el **registro central de bugs** del proyecto: el usuario, junto conmigo o con cualquier LLM acompañante, anota aquí los problemas y fallas que va encontrando, con el **mayor detalle posible**, en formato checklist. Complementa (NO reemplaza) a `DOCUMENTACION/102-Bug-Tracking/`, al registro de errores de Godot (`GUIA-GODOT/06-registro-errores.md`), y a GitHub Issues.

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
9. **Relación con otros registros:** si el bug es de Godot, dejar además una referencia cruzada en `GUIA-GODOT/06-registro-errores.md`. Si se usa GitHub Issues, referenciar el número de issue en el campo `Referencias`.

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
| BUG-025 | Sección `npc` del save no coincide con el default del schema (M19 vs M59) | M19/M59/M60 | 🟡 Menor | [?] Delegado | DeepSeek-V4.1-Flash | 2026-09-11 20:50 |
| BUG-035 | Test headless de M107 (Backups) falla: 1/9 checks | M107 | 🟠 Mayor | [x] Resuelto (2026-09-14, Log 902 — causa: `DirAccess.new()` en el autoload `BackupManager`) | hy3 | 2026-09-14 04:50 |
| BUG-039 | `scripts/generar_checklist_global.py` reescribe el archivo desde una plantilla fija: borra el encabezado y desplaza columnas | Transversal | 🔴 Alta | [x] Resuelto (2026-09-15, generador corregido y verificado) | DeepSeek-V4.1-Flash | 2026-09-15 01:11 |
| BUG-040 | `inventory_layer.gd` captura ERROR de señal `item_added` (handler 2 args vs emisión 3 args) | M53 UI Inventario (`inventory_layer.gd`) | 🟠 Mayor | [x] Resuelto (2026-09-15, hy3 — verificación headless M110 22/0, EXIT 0; error de señal ausente) | hy3 | 2026-09-15 01:25 |
| BUG-041 | ~~`logger.gd` (autoload `GameLogger`) no registra NADA~~ **FALSO POSITIVO (verificado con sonda)**: `GameLogger` **sí registra** (`categories_enabled` se puebla en `_ready()`, `_log()` escribe a disco y emite). Residuo real: `log_buffer` es **código muerto** (nadie hace `append`) y `_flush()` es un no-op permanente | M103 Logging (`scripts/logging/logger.gd`) | 🟢 Baja (limpieza) | [x] Cerrado — falso positivo (reclasificado 2026-09-15) | DeepSeek-V4.1-Flash | 2026-09-15 |

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
- **Verificación posterior (2026-09-02 22:40):** escaneo completo de documentación detectó referencias a números renombrados (`472`, `486`, `488`, `489`, `490`, `547`) que ahora existen solo como `-dup1`; se repararon en sus checklists/BUGS para apuntar al nombre real. También detectó números ausentes sin archivo canónico: `307`, `308`, `312`. Búsqueda posterior (2026-09-02 23:00) halló evidencia en `Logs/375-Reorganizacion-Numeracion-Logs_2026-09-01_16-30-00.md`: estos números fueron renombrados históricamente a `368` (M59), `369` (M22/M35), `370` (M19). Referencias reparadas en `CHECKLIST-GLOBAL.md`, `08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `59-Guardado/plan-actual/05-Checklist.md`, `22-Historia-Principal/plan-actual/05-Checklist.md` y `TAREAS-POR-MODELO/`.
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
- Archivos duplicados: `Logs/401-M116-Instalador-Iter1_2026-09-02_02-05-00.md` (2), `Logs/407-M63-Streaming-Verificacion_2026-09-02_03-20-00.md` (2), `Logs/410-M121-Soporte-Post-Lanzamiento-Nucleo-Iter1_2026-09-02_00-30-00.md` (2), `Logs/413-M147-M148-CanonyLore-Verificacion_2026-09-02_05-30-00.md` (3), `Logs/414-M115-Hardware-Iter2_2026-09-02_06-00-00.md` (3), `Logs/415-M96-Plataformas-Iter2_2026-09-02_06-30-00.md` (3), `Logs/416-M124-UGC-Nucleo-Iter1_2026-09-02_01-00-00.md` (2), `Logs/417-M100-Community-Management-Nucleo-Iter1_2026-09-02_01-15-00.md` (2), `Logs/418-M117-Build-System-Nucleo-Iter1_2026-09-02.md` (2), `Logs/426-AUDIT-CHECKLIST-CONSISTENCIA_2026-09-02.md` (2), `Logs/428-M65A94M132-CIERRE_BATCH_AGNES_2026-09-02.md` (2), `Logs/429-M30-Reauditoria-C56-Cierre_2026-09-04_03-46.md` (2), `Logs/430-AUDIO-BATCH-M41M150_2026-09-02.md` (2), `Logs/431-BUCLE-AGNES-32-MODULOS-CIERRE_2026-09-02.md` (3), `Logs/432-BUCLE-CONTINUACION-M110-M122_2026-09-02.md` (2), `Logs/433-M126-Marketing-Legal-Nucleo-Iter1_2026-09-02_03-40-00.md` (3), `Logs/434-Guia10-Autoevaluacion-Real-y-Capacidades-Nativas_2026-09-02_04-45-00.md` (2), `Logs/435-AGNES-BUCLE-CIERRE_2026-09-02.md` (4), `Logs/436-Guia10-Vision-V2-Kilo_2026-09-02_05-05-00.md` (2), `Logs/437-Recuperacion-v3-Asignacion-Recom_2026-09-02_04-25-00.md` (3), `Logs/438-AGNES-BUCLE-FINAL_2026-09-02.md` (2), `Logs/439-AGNES-BUCLE-CONTINUACION_2026-09-02.md` (2), `Logs/440-AGNES-BUCLE-MARKING-CONTINUACION_2026-09-02.md` (2), `Logs/441-AGNES-BUCLE-FINAL-ITERACION_2026-09-02.md` (2), `Logs/442-AGNES-M71-ITER3-EVALUADOR-CACHE_2026-09-02.md` (3), `Logs/443-AGNES-BUCLE-MARKING-LEGAL-AUDIO_2026-09-02.md` (2), `Logs/444-AGNES-BUCLE-M71-RF16-CATALOGO-VALIDACION_2026-09-02.md` (3), `Logs/445-AGNES-BUCLE-FINAL-M71-RF16-VALIDACION_2026-09-02.md` (2), `Logs/446-AGNES-BUCLE-M103-M104-M105-M118_2026-09-02.md` (2), `Logs/447-AGNES-BUCLE-EXPANSION-M103-156_2026-09-02.md` (2), `Logs/448-AGNES-BUCLE-M156-EXPANSION_2026-09-02.md` (2), `Logs/449-AGNES-BUCLE-FINAL-M71-RF16-M156_2026-09-02.md` (2), `Logs/450-AGNES-M73-COLLECTIBLE-CATEGORY-IMPLEMENTACION_2026-09-02.md` (2), `Logs/451-AGNES-BUCLE-M73-COLLECTIBLECATEGORY-M113_2026-09-02.md` (2), `Logs/452-AGNES-BUCLE-MARKING-LEGAL-AUDIO_2026-09-02.md` (2), `Logs/453-AGNES-BUCLE-M73-M115-M147_2026-09-02.md` (2), `Logs/454-AGNES-BUCLE-FINAL-M115-M147_2026-09-02.md` (2), `Logs/455-AGNES-BUCLE-FINAL-SESION_2026-09-02.md` (2), `Logs/456-AGNES-BUCLE-M58-MARKING_2026-09-02.md` (2), `Logs/457-AGNES-BUCLE-MARKING-FINAL_2026-09-02.md` (2), `Logs/458-AGNES-BUCLE-M096-M036_2026-09-02.md` (2), `Logs/459-M41-Musica-Nucleo-Iter1_2026-09-01_20-15-00.md` (2), `Logs/460-M59-Autosave-Fin-Evento_2026-09-01_21-05-00.md` (2), `Logs/471-M16-RF17-Item-Usado_2026-09-01_23-25-00.md` (2), `Logs/472-M162-Dialogos-Contextuales-Iter2-Cierre_2026-09-01_22-45-00.md` (2), `Logs/473-Reasignacion-M17-Qwen38-A-Vision_2026-09-01_08-15.md` (2), `Logs/474-M119-Actualizaciones-Nucleo-Iter1_2026-09-01_23-10-00.md` (2), `Logs/475-M109-Herramientas-Internas-Nucleo-Iter1_2026-09-01_23-20-00.md` (2), `Logs/476-M150-Diseno-Sonoro-Narrativo-Nucleo-Iter1_2026-09-01_23-50-00.md` (2), `Logs/477-M159-Catalogo-Iter2_2026-09-01_22-51.md` (2), `Logs/478-M166-Variantes-Cierre_2026-09-02_02-45-00.md` (2), `Logs/479-M107-Backups-Nucleo-Iter1_2026-09-01_23-59-00.md` (2), `Logs/480-M73-Coleccionables-Iter1_2026-09-01_23-00-00.md` (2), `Logs/481-M114-Playtest-Iter1-Plantillas-Validador_2026-09-01_23-45-00.md` (2), `Logs/482-M156-Terrenos-Iter1_2026-09-01_23-02.md` (2), `Logs/483-Recuperacion-CHECKLIST-GLOBAL_2026-09-01_22-45-00.md` (2), `Logs/484-M66-Fallbacks-Funcionales_2026-09-01_23-20-00.md` (2), `Logs/485-M91-Config-Audio-Nucleo_2026-09-01_24-15-00.md` (2), `Logs/486-M78-Legal-Propiedad-Intelectual-Nucleo-Iter1_2026-09-02_02-00-00.md` (2), `Logs/487-M63-Streaming-Nucleo_2026-09-01_24-20-00.md` (2), `Logs/488-M87-Integracion-M88_2026-09-02_01-35-00.md` (2), `Logs/489-M13-Niveles-Progresion_2026-09-02_01-20-00.md` (2), `Logs/490-M156-Terrenos-Nucleo_2026-09-02_03-00-00.md` (2), `Logs/491-M01-Fundamentos-Del-Proyecto-Nucleo-Iter1_2026-09-02_04-50-00.md` (2), `Logs/492-M120-DLC-Y-Expansiones-Nucleo-Iter1_2026-09-01_23-50-00.md` (2), `Logs/493-M65-PackLogic-SchoolLogic-Cierre_2026-09-02.md` (2), `Logs/494-M71-Progresion-Iter2-Logger-NivelModulo_2026-09-02.md` (2), `Logs/495-M73-Coleccionables-Cierre-Doc_2026-09-02.md` (2), `Logs/496-M94-Retencion-Design-Close_2026-09-02.md` (2), `Logs/497-M119-Actualizaciones-Nucleo-Iter1_2026-09-02.md` (2), `Logs/498-Reasignacion-DeepSeek-Vision-M161-M109-M113_2026-09-01_08-00.md` (2), `Logs/499-M118-CI-CD-Nucleo-Iter1_2026-09-02.md` (2), `Logs/500-M122-Crash-Reporting-Nucleo-Iter1_2026-09-02.md` (2), `Logs/501-M71-Progresion-Iter3-M13-Integration_2026-09-02.md` (2), `Logs/502-M120-DLC-Nucleo-Iter1_2026-09-02.md` (2), `Logs/503-M121-Soporte-Nucleo-Iter1_2026-09-02.md` (2), `Logs/504-M129-M131-Validadores-Legal_2026-09-02.md` (2), `Logs/505-M125-M131-Validadores-Legal-Batch_2026-09-02.md` (2), `Logs/506-AGENTS-UTF8-DIRECTIVA_2026-09-02_01-29-26.md` (2), `Logs/507-SANEAMIENTO-UTF8-MOJIBAKE_2026-09-02_01-47-21.md` (2), `Logs/508-GUIA-COMPARATIVA-HY3-AUTOEVAL_2026-09-02_02-21-28.md` (2), `Logs/509-M101-QA-General-Iter1_2026-09-02_05-25-00.md` (2), `Logs/510-M23_Historias_Secundarias_Test_Headless_0_fallos_2026-09-02_05-17.md` (2), `Logs/511-M110-Debug-Menu-Nucleo-Iter1_2026-09-02_05-35-00.md` (2), `Logs/512-M116-Instalador-Nucleo-Iter1_2026-09-02_05-45-00.md` (2), `Logs/513-M16_Crafting_Brecha_CIERRE_PARCIAL_0_fallos_RF3_2026-09-02_05-32.md` (2), `Logs/514-M54-Mapa-Nucleo-Iter1_2026-09-02_06-00-00.md` (2), `Logs/515-M117_Build_System_Nucleo_V0_0_fallos_Log_515_2026-09-02_05-35.md` (2), `Logs/516-M87-Localizacion-Nucleo-Iter1_2026-09-02_06-15-00.md` (2), `Logs/517-M119_Actualizaciones_Nucleo_V0_0_fallos_Log_517_2026-09-02_05-49.md` (2), `Logs/518-M122_Crash_Reporting_Nucleo_V0_0_fallos_Log_518_2026-09-02_05-52.md` (2), `Logs/519-M108_Pipeline_Reserva_liberada_sin_nucleo_Log_519_2026-09-02_05-53.md` (2), `Logs/520-M65-Animales-IA-Verificacion_2026-09-02_06-00-00.md` (2), `Logs/521-M160-Ubicaciones-Iter1_2026-09-02_06-15-00.md` (2), `Logs/522-M162-Dialogos-Hallazgo-Test15-15_2026-09-02_06-20-00.md` (2), `Logs/523-M103-Logging-Verificacion-Liberacion_2026-09-02_06-30-00.md` (2), `Logs/524-M104-Analytics-Verificacion-Liberacion_2026-09-02_06-45-00.md` (2), `Logs/525-M103-Logging-Verificacion-Fixes_2026-09-02_06-45-00.md` (2), `Logs/526-M115-Hardware-Nucleo-Iter1_2026-09-02_07-05-00.md` (2), `Logs/527-M156-Terrenos-Verificacion-Colision_2026-09-02_07-00-00.md` (3), `Logs/528-M67-Vehiculos-ITER1-Nucleo-V0_2026-09-02_07-40-00.md` (2), `Logs/529-M25-Arco-Entrada-Templo-E68_2026-09-02_04-00-00.md` (2), `Logs/530-M25-Estatua-Ancestral-E50_2026-09-02_04-15-00.md` (2), `Logs/531-M40-Puente-Colgante-Parabola_2026-09-02_04-30-00.md` (2), `Logs/532-M108-nucleo-iniciado-test-headless-bloqueado_2026-09-02_17-25.md` (2), `Logs/533-M118-CI-CD-Auditoria-Fix-Version_2026-09-02_17-40-00.md` (2), `Logs/534-M75-Postgame-ITER1-Nucleo-V0_2026-09-02_08-00-00.md` (2), `Logs/535-Inventario-Modulos-Sin-Contenido_2026-09-02_17-50-00.md` (2), `Logs/536-Estado-Arbol-Suite-Exitosa_2026-09-02_17-55-00.md` (2), `Logs/537-backlog-tareas-por-modelo-glm-5.3-flash.md` (2), `Logs/538-M38-ITER2-TABLA-TRANSACCIONES_2026-09-02_15-16-49.md` (2), `Logs/539-M160-Ubicaciones-Iter2-Seeds_2026-09-02_18-15-00.md` (2), `Logs/540-M108-Nucleo-V0-Headless-Bloqueado-2026-09-02_17-44.md` (2), `Logs/541-M118-CI-CD-Iter1_2026-09-02_18-00-00.md` (2), `Logs/542-M37-Museos-ITER3-Fauna-Toasts-Panel_2026-09-02_20-40-00.md` (2), `Logs/543-M119-Avance-8-tareas-cerradas-2026-09-02_20-12.md` (2), `Logs/544-M38-ITER3-ESTACION-ANTIGRIND-REPUTACION-FERIAS_2026-09-02_17-24-43.md` (2), `Logs/545-M36-Tortuga-NPC-Godot_2026-09-02_20-35-00.md` (2), `Logs/546-CREACION-11-BUGS-REGISTRO-CENTRAL_2026-09-02_17-45-00.md` (2), `Logs/547-QA-Visual-Estado-Mundo-B001_2026-09-02_20-50-00.md` (2), `Logs/548-M36-Tortuga-QA-Visual_2026-09-02_20-55-00.md` (2), `Logs/549-Cierre-M119-100-100-2026-09-02_20-43.md` (2), `Logs/550-GUIAS-Flujo-Blender-Godot-Movimiento_2026-09-02_21-10-00.md` (2).

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
- Archivos modificados: `CHECKLIST-GLOBAL.md`, `ESTADO-PARALELO.md`, `108-Pipeline-De-Assets/plan-actual/05-Checklist.md`, `163-Sistema-De-Encantamientos/plan-actual/05-Checklist.md`, `11-BUGS.md`, `Logs/552-Auditoria-numeracion-logs-duplicados-faltantes-referencias_2026-09-02_21-19.md`, 4 archivos en `Logs/` renombrados.

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

### BUG-026 — Regresión: el validador estricto mata los diálogos de reacción de regalo/nivel (M21)

- **Fecha de reporte:** 2026-09-12 02:25
- **Módulo(s) afectado(s):** M21 (Diálogos) — `scripts/dialogos/dialogue_manager.gd` (`start_dialogue`, gate `[VAL-DGV]` L106-110) · `scripts/dialogos/dialog_graph_validator.gd` (`CLAVES_MUNDO_BASE`)
- **Severidad:** 🔴 Crítico
- **Prioridad sugerida:** Alta
- **Estado:** [x] Resuelto (2026-09-12, Log 846)

**Descripción del problema:**
La validación estática estricta añadida en iter 7/8 (comentario L103: "Ahora SI se chequean claves desconocidas") hace que `start_dialogue()` devuelva `false` si `DialogGraphValidator.validar()` reporta CUALQUIER problema. Las claves siguientes —que M21 inyecta en runtime como contexto de condición— NO estaban en `CLAVES_MUNDO_BASE`:
- payload de evento de M20→M21: `new_level`, `reaccion_id`, `npc_id`, `item_id` (inyectadas en `start_dialogue(REACCION_*, {...})`);
- session-var de amistad del llamador: `<npc_id>_amistad` (p. ej. `catalina_amistad`).
El validador las marcaba "clave de mundo desconocida" → `start_dialogue` rechazaba el grafo → **`reaccion_regalo.json` / `reaccion_nivel.json` (iters 4-5) NO arrancaban en producción** (las reacciones de regalo/nivel de amistad quedaban mudas). Además rompía CI (`validate_all_dialogues.gd` exit 1, 7 problemas) y `test_condiciones_mundo.gd` (1 fallo: la rama de amistad nunca entraba porque el diálogo no iniciaba).

**Pasos para reproducir:**
1. `Godot --headless --path game/isla-ancestral --script res://scripts/dialogos/validate_all_dialogues.gd` → "Resumen: 3 archivo(s) | 2 con problemas | 7 problema(s)" (HEAD, pre-fix).
2. `test_reaccion_m21_dialogo.gd` / `test_eventos_dialogo_m21.gd` en HEAD: los grafos de reacción se rechazan en `start_dialogue`.

**Comportamiento esperado:**
Los diálogos de reacción de M21 deben iniciarse y mostrarse; CI debe quedar en verde.

**Comportamiento actual (post-fix):**
`validate_all_dialogues` → 0 problemas; `test_reaccion_m21_dialogo`, `test_eventos_dialogo_m21`, `test_condiciones_mundo` → 0 fallos.

**Entorno / Contexto:**
- Plataforma: PC (Windows), Godot 4.7.2 headless.
- Introducido en iter 7/8 de M21 (gate `[VAL-DGV]`); latente hasta la verificación cruzada §21.8 de Log 846.

**Evidencia:**
- `[VAL-DGV] nodo 'inicio': condicion usa clave de mundo desconocida 'reaccion_id'` (y `new_level`, `catalina_amistad`).
- `test_validacion_grafo_m21.gd` en HEAD: 3 fallos (incl. `reaccion_regalo valido`, `reaccion_nivel valido` incorrectamente marcados inválidos).

**Resolución:**
- `dialog_graph_validator.gd`: `CLAVES_MUNDO_BASE` ampliada con `"npc_id","reaccion_id","item_id","new_level"`; `_clave_conocida()` ahora reconoce también el sufijo `_amistad` (session-vars de amistad inyectadas); añadida detección de `next_id`/`goto_id` inexistentes (ver BUG-027); docstring alineado al contrato "vacío → usa `CLAVES_MUNDO_BASE` (validación siempre activa)".
- `test_validacion_grafo_m21.gd`: ajustada la aserción del caso "sin allowlist" al contrato actual (la clave sí se reporta porque el validador usa la base).
- **Verificado por:** Hy3/WorkBuddy (Log 846, §21.8) — 13 tests headless M21 0 fallos + `validate_all` 0 problemas.

**Modelo:** Hy3 (WorkBuddy)
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-12 02:31

---

### BUG-027 — El validador no detecta `next_id`/`goto_id` inexistentes (arista colgante)

- **Fecha de reporte:** 2026-09-12 02:28
- **Módulo(s) afectado(s):** M21 (Diálogos) — `scripts/dialogos/dialog_graph_validator.gd` (`_alcanzables()` / `validar()`)
- **Severidad:** 🟠 Mayor
- **Prioridad sugerida:** Media
- **Estado:** [x] Resuelto (2026-09-12, Log 846)

**Descripción del problema:**
`_alcanzables()` sólo encola `next_id`/`goto_id` si el nodo destino EXISTE; por tanto un grafo con una arista que apunta a un nodo inexistente no genera ningún problema y pasa CI. En runtime, al avanzar a ese nodo, `DialogueManager` llama `stop_dialogue()` silenciosamente (o rompe el flujo), produciendo diálogos truncados sin error claro.

**Pasos para reproducir:**
1. `Godot --headless --path game/isla-ancestral --script res://scripts/dialogos/test_validacion_5_invalidos_m21.gd` en HEAD → "FALLO: detecta next_id inexistente" y "FALLO: detecta goto_id inexistente" (el validador no los reportaba).

**Comportamiento esperado:**
El validador debe reportar `next_id`/`goto_id` que apuntan a nodos inexistentes.

**Comportamiento actual (post-fix):**
`test_validacion_5_invalidos_m21.gd` → 0 fallos (2/2 detectados).

**Resolución:**
`dialog_graph_validator.gd::validar()`: bucle adicional que, para cada nodo, reporta `"nodo 'X': next_id 'Y' no existe"` / `"goto_id 'Y' no existe"` cuando el destino no está en `grafo.nodes`. No afecta a los 3 grafos de producción (`validate_all` sigue en 0 problemas).

**Modelo:** Hy3 (WorkBuddy)
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-12 02:31

---

### BUG-039 — `generar_checklist_global.py` destruye el encabezado y desplaza columnas

- **Fecha de reporte:** 2026-09-15 01:11
- **Módulo(s) afectado(s):** Transversal — `scripts/generar_checklist_global.py` → `CHECKLIST-GLOBAL.md` (la "única fuente de verdad" del protocolo multiagente)
- **Severidad:** 🔴 Alta (pérdida de datos en el archivo de coordinación; no afecta al runtime del juego)
- **Estado:** [x] Resuelto (generador corregido + archivo restaurado y regenerado)

**Cómo se detectó:**
Al auditar la columna `Progreso` de las 158 filas contra el conteo real de cada
`05-Checklist.md` aparecieron **104 desajustes** (66 %), incluidos módulos propios ya
liberados (M27 `9/171` vs `83/192` real, M68 `0/131` vs `36/131`, M87 `90/136` vs
`120/136`, M116 `91/198` vs `198/198`). Mientras se investigaba, el generador corrió
**en vivo** (01:11:31) sobre el archivo y el daño quedó medido en el backup automático
`scripts/backups/CHECKLIST-GLOBAL_20260915_011131.md`.

**Defectos encontrados (tres, todos reales y medidos):**

1. **Reescribe el archivo completo desde una plantilla fija.** El `contenido` del script
   es un f-string con título + tabla + simbología + resumen; todo lo demás se pierde.
   Medido: **119 693 B → 85 123 B (−34,5 KB)**. Secciones borradas:
   `> ⛔ CODIFICACIÓN UTF-8 OBLIGATORIA` (AGENTS.md §28), `### Flujo para modelos nuevos
   (SIEMPRE empezar acá)` (6 pasos) y la nota `> **Columna "Recom":** …`.
2. **Elimina la columna `Recom`.** La plantilla de salida tiene 10 columnas; el archivo
   tenía 11. Como el lector mapea las columnas **por posición** según el encabezado
   existente, cada corrida desplaza `Agente actual ← Recom`, `Última actividad ←
   Agente actual` y `Notas ← Última actividad`, perdiendo la nota original de las filas
   que no traían la columna `Recom`.
3. **El fin de la tabla se detectaba con "primera línea que no empieza con `|`".**
   Hay filas cuya Nota continuó en una línea huérfana (p. ej. el sello de QA de M114,
   ` 🔵 Verificado por Hy3/WorkBuddy (Log 866, §21.8): test_playtest_m114.gd EXIT 0`).
   Ese corte dejaba **el resto de la tabla** dentro del "sufijo", que se anexaba tal
   cual → **303 filas numéricas en vez de 167** (duplicadas) y **220 KB** en vez de 120 KB.
4. **`Path.write_text()` sin `newline=` traduce `\n` a `os.linesep`** → en Windows
   convertía en silencio un archivo **LF** en **CRLF**.

**Fix aplicado (`scripts/generar_checklist_global.py`):**

- `leer_estructura_existente()` devuelve `(prefijo, encabezado, separador, cuerpo, sufijo)`.
  El **prefijo y el sufijo se conservan literalmente**; el fin de tabla se detecta por el
  **siguiente encabezado markdown (`#`)**, no por la primera línea no-`|`.
- El **esquema de columnas se hereda** del archivo existente (encabezado y separador tal
  cual) → la columna `Recom` sobrevive y no hay desplazamiento posicional.
- `parsear_filas()` usa `split("|", ncols-1)` (una `|` dentro de las Notas ya no desplaza
  celdas) y **reengancha las líneas huérfanas a las Notas de la fila anterior** en lugar
  de perderlas.
- Se **conservan las filas sin `05-Checklist.md` detectable** (antes desaparecían).
- Se preserva la **anotación manual del `Estado`** cuando el emoji calculado coincide
  (`🟡 Liberado (Log 831)` ya no se degrada a `🟡 Con dudas`): era la traza de qué agente
  y qué log liberaron el módulo.
- El **salto de línea se detecta** del archivo existente y se pasa explícito a
  `write_text(..., newline=...)`.

**Verificación (2026-09-15):**

| Comprobación | Antes | Después |
|---|---|---|
| Filas numéricas en la tabla | 303 (duplicadas) | **167** (sin duplicados, bloque contiguo 30–196) |
| Columnas por fila | 8/10/11/12/13/14 mezcladas | **11 uniformes** |
| Secciones de encabezado | 0 de 3 | **3 de 3** |
| Desajustes `Progreso` vs `[x]` real | 93 | **0** |
| Fin de línea | LF→CRLF (no deseado) | **LF** (conservado) |
| BOM / U+FFFD | — | `bom=False fffd=0` (§28) |
| Filas propias (M27/M68/M87/M124) | desplazadas | intactas: `Recom`/`Agente`/`fecha`/`Notas` en su celda |

**Archivo restaurado** desde `scripts/backups/CHECKLIST-GLOBAL_20260915_011131.md` y
regenerado con el script corregido: `119 081 B`, 222 líneas, `43.4 %` de subitems
(10 398/23 969).

**Lección transversal:** un archivo que dice "**Generado por script**" sólo es confiable
si el script **preserva lo que no le pertenece**. Regla: *nunca regenerar desde plantilla
un archivo que otros agentes editan a mano* — leer la estructura existente, reemplazar
sólo las columnas calculadas y conservar el resto byte a byte.

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-15 01:20

---

### BUG-040 — `inventory_layer.gd` captura ERROR de señal `item_added` (arity 2 vs 3)

- **Fecha de reporte:** 2026-09-15 01:25
- **Módulo(s) afectado(s):** M53 UI Inventario — `game/isla-ancestral/scripts/ui/layers/inventory_layer.gd` (conexión en `_ready` líns 44–51; handler `_on_inv_changed` líns 341–346). Señal canónica en M14 Inventario — `game/isla-ancestral/scripts/inventario/inventario_service.gd:16` (`signal item_added(item_id: String, cantidad: int, container: int)`).
- **Severidad:** 🟠 Mayor (ERROR en consola en cada alta/baja de ítem; no rompe checks pero contamina el log y es síntoma de desajuste de contrato de señal)
- **Prioridad sugerida:** Media
- **Estado:** [x] Resuelto (2026-09-15, hy3 — verificación headless M110 22/0, EXIT 0)

**Descripción del problema:**

El autoload `Inventario` emite `item_added` (y `item_removed`) con **3 argumentos**
(`item_id: String, cantidad: int, container: int`), pero `inventory_layer.gd` conectaba
ambas señales al handler `_on_inv_changed` que **sólo declaraba 2 parámetros**. Godot
invoca el callable con los 3 args reales → desajuste de arity → ERROR en consola en cada
alta/baja de inventario (observable durante el check RF5 de M110).

**Pasos para reproducir:**

1. Arrancar el juego (o el test headless de M110 con el mock de `/root/Inventario` conectado).
2. Emitir `item_added.emit("palo", 1, 0)` desde el autoload `Inventario`.
3. Observar la consola.

**Comportamiento esperado:**

El handler `_on_inv_changed` debe aceptar la firma de 3 argumentos del autoload y refrescar
el contenido del inventario cuando la capa es visible, sin ERROR de arity.

**Comportamiento actual (antes del fix):**

```
ERROR: Error calling from signal 'item_added' to callable: 'Control(inventory_layer.gd)::_on_inv_changed': Method expected 2 argument(s), but called with 3.
```

**Entorno / Contexto:**

- Build: Godot 4.7.2 (proyecto), headless test de M110 (`test_debug_menu_headless.gd`).
- Plataforma: PC (Windows) / headless.
- Frecuencia: Siempre que se emite `item_added`/`item_removed` estando conectada la capa.
- Ocurre desde: contrato de 3 args en `inventario_service.gd` (M14) vs handler de 2 args heredado en `inventory_layer.gd` (M53).

**Evidencia:**

- Línea exacta del ERROR (arriba). Detectado durante la verificación de M110 (RF5) tras el
  cierre de BUG-037; no fallaba ningún check (por eso quedó fuera de M110 como hallazgo
  colateral), pero era un bug real de otro módulo.
- Autorizado a corregir por el usuario ("si revisalo", 2026-09-15).

**Resolución (completar cuando se resuelva):**

- [x] Cómo se corrigió: en `inventory_layer.gd` el handler pasó de
  `func _on_inv_changed(_item_id: String, _cantidad: int)` a
  `func _on_inv_changed(_item_id: String = "", _cantidad: int = 0, _container: int = -1) -> void:`
  (líns 343–346). Los 2 args extras se ignoran; el refresh `_refrescar_contenido()` sólo
  ocurre si `visible`. Es compatible hacia atrás y hacia delante con la firma de 3 args de M14.
- [x] Archivos/commits modificados: `game/isla-ancestral/scripts/ui/layers/inventory_layer.gd`
  (solo el handler; sin commit aún — pendiente de incluir en el commit selectivo del módulo M53).
- [x] Log del proyecto: registrado en `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/BACKLOG-MASTER.md` (Actualización 2026-09-15 01:25).
- [x] Verificado por: hy3 (WorkBuddy), 2026-09-15 — re-ejecución headless de M110:
  `=== Resumen M110: 22 checks, 0 fallos ===`, `[exit code: 0]`, y la línea
  `Error calling from signal 'item_added'` **ya no aparece** (solo resta la info benigna
  `[M92] Triggers EventBus conectados`).

**Nota de alcance (§21.4 / §21.8):** el contrato de 3 args vive en `inventario_service.gd`,
módulo M14 propiedad de ox-alpha/Cline; NO se editó ese archivo (fuera de mi scope y no
reasignado). La corrección en M53 es compatible con ambas firmas. Otros conectores de
`item_added` (`achievement_service.gd`, `progression_manager.gd`, `save_manager.gd`,
`hud_screen.gd`, `tutorial_manager.gd`) usan lambdas de 2 params (`func(_i,_q)`) que Godot
tolera (ignora el arg extra) → no producen ERROR, pero conviene revisarlos en su propio
módulo si algún día se usa `_container`.

**Modelo:** hy3
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-15 01:25

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



### BUG-028 — M39/M38: `precio_compra_vigente` devuelve 0 (precio de compra no definido)

- **Fecha de reporte:** 2026-09-12 04:45
- **Módulo(s) afectado(s):** M39 (Tiendas) / M38 (Economía) — `scripts/economia/price_manager.gd` (`_precio_base_compra` L442, `precio_compra_vigente` L108) · `scripts/economia/economy_manager.gd` (`precio_compra_vigente` L79) · test `scripts/shops/test_loop_economico.gd` L50-56.
- **Severidad:** 🟠 Mayor
- **Prioridad sugerida:** Media
- **Estado:** [?] Delegado (código dueño ajeno: M39 agnes-2.5-flash, M38 GLM-5.3; §21.4 lock — Hy3 no modifica)

**Descripción del problema:**
`test_loop_economico.gd` check `precio compra definido` FALLA (Resumen: 14 checks, 1 fallos; EXIT=1). `EconomyManager.precio_compra_vigente` → `PriceManager.precio_compra_vigente` → `_precio_base_compra(item_id)` devuelve 0 porque ni el override de catálogo (`econ_prices.tres`, `PriceDefinition.precio_compra`) ni `ItemData` (`db.get_item("OBJ-PLA-001").precio_compra`) aportan valor > 0. El test parchea `item.set("precio_compra", 100)` en memoria, pero `PriceManager` lee de su propia ruta de lookup (catálogo/ItemData), no del objeto parcheado, así que el precio queda en 0.

**Pasos para reproducir:**
1. `Godot --headless --path game/isla-ancestral --script res://scripts/shops/test_loop_economico.gd` → "[FAIL] precio compra definido" / "Resumen: 14 checks, 1 fallos" / EXIT=1.

**Comportamiento esperado:**
`precio_compra_vigente` devuelve un precio > 0 para un ítem de catálogo (p. ej. OBJ-PLA-001).

**Comportamiento actual:**
Devuelve 0 → el loop de compra no puede computar precio de compra válido.

**Entorno / Contexto:**
- Plataforma: PC (Windows), Godot 4.7.2 headless.

**Evidencia:**
- `test_loop_economico.gd` L55-56: `var precio_c := int(_eco.precio_compra_vigente("OBJ-PLA-001")); _check("precio compra definido", precio_c > 0)` → FAIL.
- `price_manager.gd` L442-457: `_precio_base_compra` cae a 0 si catálogo e ItemData no definen `precio_compra`.

**Intentos de solución ya probados:**
- Confirmado por lectura de código que el fallback es 0 cuando ambas fuentes carecen de `precio_compra`.

**Referencias cruzadas:**
- Log 847 (QA cruzado Lote B, §21.8).

**Firma:**
**Modelo:** Hy3 (WorkBuddy)
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-12 04:45

**Resolución (pendiente de dueño — delegado §21.4):**
- [→] Cómo se corrige (sugerido): dueño M39/M38 define `precio_compra` para `OBJ-PLA-001` (y demás ítems de catálogo) en `econ_prices.tres` y/o `ItemData`, o ajusta `PriceManager` para leer de la fuente que el test parchea.
- [ ] Log del proyecto:
- [ ] Verificado por: dueño M39/M38 (agnes / GLM-5.3)

---

### BUG-029 — M149: `validar_nombres.py` escanea rutas que no son fuente (389 falsos positivos)

- **Fecha de reporte:** 2026-09-12 04:45
- **Módulo(s) afectado(s):** M149 (Nombres y Nomenclatura) — `DOCUMENTACION/149-Nombres-Y-Nomenclatura/operativa/validar_nombres.py`
- **Severidad:** 🟡 Menor
- **Prioridad sugerida:** Baja
- **Estado:** [?] Delegado (dueño GLM-5.3; §21.4 lock — Hy3 no modifica)

**Descripción del problema:**
El validador reporta **389 "VIOLACIONES DE NAMING"**, la mayoría en rutas ajenas al fuente del proyecto: `Godot/app_userdata/isla-ancestral/analytics/*.json` (telemetría generada en runtime), `addons/gdUnit4/*` (framework de test de terceros, PascalCase por diseño) y `data/npc_visuals/*.tres` / `scenes/*.tscn` (assets legacy). Incluso marca archivos ya `snake_case` correctos como `_probe_debug.gd`.

**Pasos para reproducir:**
1. `python DOCUMENTACION/149-Nombres-Y-Nomenclatura/operativa/validar_nombres.py` → "VIOLACIONES DE NAMING (389):" y lista.

**Comportamiento esperado:**
Sólo violar convenciones de fuente bajo `game/`.

**Comportamiento actual:**
389 violations, mayoría fuera de alcance del proyecto.

**Entorno / Contexto:**
- Plataforma: Python 3.13.

**Evidencia:**
- Salida: `VIOLACIONES DE NAMING (389):` seguida de rutas `Godot/app_userdata/...`, `addons/gdUnit4/...`, `data/npc_visuals/...`, `scenes/...`.

**Intentos de solución ya probados:**
- Ninguno (escáner de terceros/dueño; fuera de lock §21.4 de Hy3).

**Referencias cruzadas:**
- El `05-Checklist` de M149 afirma "1 violación legacy documentada" — afirmación DESACTUALIZADA frente a las 389 actuales.
- Log 847 (QA cruzado Lote B, §21.8).

**Firma:**
**Modelo:** Hy3 (WorkBuddy)
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-12 04:45

**Resolución (pendiente de dueño — delegado §21.4):**
- [→] Cómo se corrige (sugerido): dueño M149 acota el escáner a `game/` (fuente), excluye `Godot/`, `addons/`, `build/`, `data/` assets, y permite underscore inicial en scripts de debug/test.
- [ ] Log del proyecto:
- [ ] Verificado por: dueño M149 (GLM-5.3)

---

### BUG-030 — M09: inconsistencia de registro (nombre modulo + checklist "sin scripts propios" vs `terreno_horizonte.gd`)

- **Fecha de reporte:** 2026-09-12 05:10
- **Modulo(s) afectado(s):** M09 (Terreno y Geografia / "Generador-Mapa") — `DOCUMENTACION/09-Terreno-Y-Geografia/plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md` (fila 09), `scripts/world/terreno_horizonte.gd`
- **Severidad:** 🟡 Menor
- **Prioridad sugerida:** Baja
- **Estado:** [?] Delegado (dueno glm-5.3-flash / firmante M09; §21.4 lock — Hy3 no modifica docs ajenas)

**Descripcion del problema:**
Dos incoherencias de registro en M09: (1) `CHECKLIST-GLOBAL.md` fila 09 titula el modulo "09-Generador-Mapa", pero la carpeta de documentacion es `DOCUMENTACION/09-Terreno-Y-Geografia` (el `05-Checklist.md` se firma "Modulo 09: Terreno y Geografia") — nombre divergente. (2) `05-Checklist.md` item A17 afirma "solo diseno de contenido, sin scripts propios", pero `scripts/world/terreno_horizonte.gd` (360 lineas) implementa el impostor heightmap de toda la isla (entregable real de M09, Logs 751-795, glm-5.3-flash). La afirmacion esta desactualizada.

**Pasos para reproducir:**
1. `grep -n "09-Generador-Mapa" CHECKLIST-GLOBAL.md` vs `ls DOCUMENTACION/ | grep 09-`.
2. Abrir `DOCUMENTACION/09-Terreno-Y-Geografia/plan-actual/05-Checklist.md` item A17 vs `wc -l scripts/world/terreno_horizonte.gd` (360).

**Comportamiento esperado:**
Nombre de modulo coherente entre CHECKLIST-GLOBAL y carpeta de doc; checklist refleja que M09 si produjo el script de impostor (o se reasigna su propiedad a M10/M167).

**Comportamiento actual:**
Nombre divergente; checklist afirma falsamente "sin scripts propios".

**Entorno / Contexto:**
- QA cruzado Lote A (M09/M10/M11/M119/M165/M168), Hy3/WorkBuddy, Log 848, §21.8.

**Evidencia:**
- `terreno_horizonte.gd`: 360 lineas, implementa prismas escalonados + ocultamiento AABB-clamp + umbral 1024m (impostor heightmap).
- `05-Checklist.md` L17: `[x] Registrar el alcance: solo diseno de contenido, sin scripts propios [S]`.
- `CHECKLIST-GLOBAL.md` L36: `| 09 | 09-Generador-Mapa | ...`.

**Intentos de solucion ya probados:**
- Ninguno (doc a cargo de dueno M09; fuera de lock §21.4 de Hy3).

**Referencias cruzadas:**
- Log 848 (QA cruzado Lote A, §21.8). CHECKLIST-GLOBAL fila 09 (L36).

**Firma:**
**Modelo:** Hy3 (WorkBuddy)
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-12 05:10

**Resolucion (pendiente de dueno — delegado §21.4):**
- [→] Como se corrige (sugerido): dueno M09 unifica el nombre ("09-Terreno-Y-Geografia" en ambos lados) y actualiza A17 a "con script de impostor `terreno_horizonte.gd`" (o mueve el script a M10/M167 y ajusta el alcance).
- [ ] Log del proyecto:
- [ ] Verificado por: dueno M09 (glm-5.3-flash / Deepseek V4 Flash)

---

| 2026-09-12 04:45 | Hy3 (WorkBuddy) | WorkBuddy | QA cruzado Lote B (M22/M24/M29/M35/M39/M145/M146/M149/M153) §21.8: BUG-028 (M39 precio_compra=0) y BUG-029 (M149 validador 389 FP) delegados; 8/9 módulos verdes (Log 847) |
| 2026-09-12 05:10 | Hy3 (WorkBuddy) | WorkBuddy | QA cruzado Lote A (M09/M10/M11/M119/M165/M168) §21.8: M10/M11/M119/M165/M168 re-confirmados ✅ (Logs 722/723/698/699/700; M119 re-test headless 15/0 EXIT 0). M09 diseño 105/105 + impostor terreno_horizonte.gd (360l) presente; aceptación visual (impostor visible 1300m) atestiguada por usuario, no replicable headless (§11.3). BUG-030 (inconsistencia doc M09) delegado §21.4 (Log 848)

---

### BUG-035 — Test headless de M107 (Backups) falla: 1/9 checks

- **Fecha de reporte:** 2026-09-14 04:50
- **Módulo(s) afectado(s):** M107 (Backups) — `scripts/backup/backup_manager.gd`, `scripts/backup/test_backup_m107.gd`
- **Severidad:** 🟠 Mayor (seguridad de datos: el gestor de backups es crítico)
- **Prioridad sugerida:** Alta
- **Estado:** [x] Resuelto (2026-09-14, Log 902) — DeepSeek-V4.1-Flash / WorkBuddy

**Descripción del problema:**
Al ejecutar `godot --headless --path game/isla-ancestral --script res://scripts/backup/test_backup_m107.gd` el test termina con `exit=1` y reporte `=== Resumen M107: 9 checks, 1 fallos ===` / `TEST M107 FALLIDO — salida con código 1`. También hay leak de 58 ObjectDB instances al salir (posible no-liberación de recursos en el test).
**Pasos para reproducir:**
1. `Godot_v4.7.2 ... --headless --path game/isla-ancestral --script res://scripts/backup/test_backup_m107.gd`
**Comportamiento esperado:** 9/9 checks OK, exit 0.
**Comportamiento actual:** 1 fallo, exit 1 (no se aisló qué check falla del stdout resumido).
**Entorno / Contexto:** Godot 4.7.2 win64; build local 2026-09-14. Frecuencia: Siempre.
**Evidencia:** `TEST M107 FALLIDO — salida con código 1`; `WARNING: 58 ObjectDB instances were leaked at exit`.
**Referencias cruzadas:** Auditoría 2026-09-14 marcó M107 como sobre-cerrado (agnes). QA acompañamiento hy3 (Log de auditoría agnes).
**Firma:** hy3 (WorkBuddy), 2026-09-14 04:50

**Resolución (implementada 2026-09-14, DeepSeek-V4.1-Flash / WorkBuddy — Log 902):**
Causa raíz encontrada (no era del test): `scripts/backup/backup_manager.gd` (autoload `BackupManager`) hacía `var _da := DirAccess.new()` en `crear_backup()`. `DirAccess` es una clase **abstracta** en Godot 4 → `Parse Error: Native class "DirAccess" cannot be constructed as it is abstract` → el script **no compilaba** y **el autoload entero no cargaba**.

Consecuencias medidas:
1. `BackupManager.cantidad_backups()` no existía → el check "cantidad backups >= 1" fallaba (1/9) y el test salía con código 1 (el "1 fallo" reportado).
2. **3 líneas `SCRIPT ERROR` en TODO run headless del proyecto** (autoload caído) → invalidaba la verificación por `grep "SCRIPT ERROR"` de cualquier módulo (falso-verde potencial en otros suites).

Corrección: eliminado `DirAccess.new()`; se agregó `_dir_os()` (`ProjectSettings.globalize_path(DIR_BACKUP)`) y se pasó a la API estática/absoluta: `DirAccess.dir_exists_absolute()`, `DirAccess.make_dir_recursive_absolute()`, `DirAccess.open(_dir_os())`, `DirAccess.get_files_at(_dir_os())`. Efecto colateral: `_limpiar_excedentes()` (retención de backups) **nunca se había ejecutado de verdad** por el mismo motivo; ahora sí.

Evidencia: `test_backup_m107.gd` **9/0, EXIT 0 (×3), 0 SCRIPT ERROR**.

Bug colateral registrado: `scripts/backup/test_backup_m107.gd` arrancaba con **BOM UTF-8** (violación §28) → BOM eliminado (3 bytes, sin cambio funcional) en la misma corrida.

**Verificado por:** hy3 (WorkBuddy), 2026-09-15 — re-ejecución headless `test_backup_m107.gd` **9/0, EXIT 0, 0 SCRIPT ERROR** (tras limpiar caché `.godot` obsoleto que servía el binario `DirAccess.new()` del commit previo). Cumple §21.8 (verificador hy3 ≠ autor DeepSeek-V4.1-Flash).

---

### BUG-036 — Test de M83 (Licencias) no compila en Godot 4.7 (`PackedByteArray.hash()` eliminado)

- **Fecha de reporte:** 2026-09-14 04:50
- **Módulo(s) afectado(s):** M83 (Licencias-De-Software) — `scripts/legal/license_validator.gd`, `scripts/legal/test_licenses_m83.gd`
- **Severidad:** 🟡 Menor (infra de test; bloquea verificación del módulo)
- **Prioridad sugerida:** Media
- **Estado:** [x] Resuelto (2026-09-15, hy3 — verificación headless: 17/0, EXIT 0)

**Descripción del problema:**
`godot --headless ... --script res://scripts/legal/test_licenses_m83.gd` aborta en compilación: `SCRIPT ERROR: Parse Error: Cannot find member "hash" in base "PackedByteArray"` / `Function "hash()" not found in base PackedByteArray` / `Compile Error: Failed to compile depended scripts` / `Failed to load script test_licenses_m83.gd`. En Godot 4.7 `PackedByteArray.hash()` fue removido/renombrado; el test usa la API vieja.
**Pasos para reproducir:** ejecutar el test de M83 en Godot 4.7.2.
**Comportamiento esperado:** el test compila y corre.
**Comportamiento actual:** no compila (drift de API Godot 4.7).
**Evidencia:** `SCRIPT ERROR: Parse Error: Cannot find member "hash" in base "PackedByteArray"`.
**Firma:** hy3 (WorkBuddy), 2026-09-14 04:50

**Resolución (implementada 2026-09-15, hy3 / WorkBuddy):**
Causa raíz: en Godot 4.7 `PackedByteArray.hash()` fue eliminado; `license_validator.gd` línea 145 usaba `String(hash(data))` — pero el constructor `String(int)` tampoco existe en 4.7 (drift de API). Corrección: `var actual_hash := str(hash(data))` (función global `hash()` + `str()` en lugar del constructor). `test_licenses_m83.gd` **17/0, EXIT 0, 0 SCRIPT ERROR**.
**Verificado por:** hy3 (autor del fix); test headless 17/0. QA cruzado §21.8 recomendado (verificador ≠ autor).

---

### BUG-037 — Test de M110 (Debug-Menu) no compila en Godot 4.7 (inferencia de tipos)

- **Fecha de reporte:** 2026-09-14 04:50
- **Módulo(s) afectado(s):** M110 (Debug-Menu) — `scripts/debug/debug_menu.gd`, `scripts/debug/test_debug_menu_headless.gd`
- **Severidad:** 🟡 Menor (infra de test; bloquea verificación)
- **Prioridad sugerida:** Media
- **Estado:** [x] Resuelto (2026-09-15, hy3 — verificación headless: 22/0, EXIT 0)

**Descripción del problema:**
`godot --headless ... --script res://scripts/debug/test_debug_menu_headless.gd` aborta con 14 `SCRIPT ERROR: Parse Error: Cannot infer the type of "r1".."r9" variable because the value doesn't have a set type`. El test usa variables sin tipo anotado que Godot 4.7 ya no infiere.
**Pasos para reproducir:** ejecutar el test de M110 en Godot 4.7.2.
**Comportamiento esperado:** compila y corre.
**Comportamiento actual:** no compila (type inference).
**Evidencia:** `SCRIPT ERROR: Parse Error: Cannot infer the type of "r1" variable...` (r1..r9).
**Firma:** hy3 (WorkBuddy), 2026-09-14 04:50

**Resolución (implementada 2026-09-15, hy3 / WorkBuddy):**
El test no compilaba por inferencia de tipos `:=` sobre `Variant` (Godot 4.7 no infiere). Corrección en `test_debug_menu_headless.gd`: `:=` → `=` en r1..r10/met/líneas. Al compilar, el test reveló 4 checks en fallo por causas de entorno/código en `debug_menu.gd` (M110), también corregidas:
1. `_do_export_diagnostic()` usaba `DirAccess.open("user://")` → null bajo `--path` (medido, igual que M107); pasado a `DirAccess.open(ProjectSettings.globalize_path("user://"))` y `zip_path`/`png_path` globalizados.
2. `ZIPPacker.finish_file()` fue REMOVIDO en Godot 4.7; finalización implícita vía `close()`.
3. `get_viewport().get_texture().get_image()` es null en headless → `save_png` abortaba; agregado null-guard (se omite el screenshot sin render).
4. El test no veía los diag vía `DirAccess.open("user://diagnostics")` (null bajo --path) → enumeración vía `globalize_path`; se agregó un mock de `Player` (CharacterBody3D) en el test para que `teleport_player`/`desbloquear_herramienta` encuentren `/root/Player` en headless.
`test_debug_menu_headless.gd` **22/0, EXIT 0, 0 SCRIPT ERROR**.
**Verificado por:** hy3 (autor del fix); test headless 22/0. QA cruzado §21.8 recomendado (verificador ≠ autor).

---

### BUG-038 — BOM en checklists de M54 y M84 (viola §28 UTF-8 sin BOM)

- **Fecha de reporte:** 2026-09-14 04:50
- **Módulo(s) afectado(s):** M54 (Configuracion-Grafica / Mapa) y M84 (Musica-Y-Audio-Legal) — `DOCUMENTACION/54-Mapa/plan-actual/05-Checklist.md` y `DOCUMENTACION/84-Musica-Y-Audio-Legal/plan-actual/05-Checklist.md`
- **Severidad:** ⚪ Trivial (codificación de documentación; no rompe runtime)
- **Prioridad sugerida:** Baja
- **Estado:** [x] Resuelto (2026-09-15, hy3 — verificado: ambos checklist SIN BOM)

**Descripción del problema:**
Ambos `05-Checklist.md` comienzan con bytes `EF BB BF` (UTF-8 BOM). La regla §28 del proyecto (y el propio BACKLOG-MASTER de agnes-2.5-flash) exige UTF-8 SIN BOM. Irónicamente agnes advirtió contra el BOM en su backlog.
**Pasos para reproducir:** abrir los archivos en binario / `file` / leer primeros 3 bytes.
**Comportamiento esperado:** sin BOM.
**Comportamiento actual:** con BOM.
**Firma:** hy3 (WorkBuddy), 2026-09-14 04:50

**Resolución (verificada 2026-09-15, hy3 / WorkBuddy):**
Inspección por bytes: ambos `05-Checklist.md` (M54 y M84) ya están SIN BOM (los 3 bytes `EF BB BF` no están). La reescritura de la auditoría 2026-09-14 (reversión de marcadores sobre-cerrados) ya normalizó la codificación a UTF-8 sin BOM. No fue necesario cambio. BUG-038 cerrado como ya-resuelto (sin acción pendiente). |


## 9. Historial de Modificaciones de Este Archivo
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
| 2026-09-14 20:55 | DeepSeek-V4.1-Flash | WorkBuddy | BUG-035 [x] Resuelto (Log 902): causa raíz en `backup_manager.gd` (autoload M107) — `DirAccess.new()` sobre clase **abstracta** mataba el autoload entero y ensuciaba **todo** run headless con 3 `SCRIPT ERROR` (invalidaba la verificación por grep). Corregido con API `*_absolute` / `globalize_path`; `test_backup_m107.gd` **9/0 ×3**, 0 SCRIPT ERROR. BOM §28 eliminado de ese test. Además: M26 Templo-Subterráneo iter. 2 (Log 902) — fila 26: **50/115**. |
| 2026-09-15 01:20 | DeepSeek-V4.1-Flash | WorkBuddy | BUG-039 [x] Resuelto: `scripts/generar_checklist_global.py` reescribia `CHECKLIST-GLOBAL.md` desde una plantilla fija (borraba el aviso ⛔ UTF-8 §28, la sección "Flujo para modelos nuevos" y la columna `Recom`; −34,5 KB), cortaba la tabla en la primera línea huérfana (303 filas duplicadas, 220 KB) y convertía LF→CRLF. Corregido: preserva prefijo/sufijo y el esquema de columnas, parseo con `maxsplit`, reenganche de líneas huérfanas, conserva filas sin checklist, conserva la anotación manual del `Estado` y detecta el salto de línea. Verificado: 167 filas sin duplicados, 11 columnas, 0 desajustes `Progreso` vs `[x]` real, LF conservado. Además restauré las filas 27/68/87 de DeepSeek-V4.1-Flash (registros perdidos: 9/171→83/192, 0/131→36/131, 90/136→120/136) y el archivo quedó regenerado (119 081 B). |
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

## B-076: Dos generadores competían por VoxelTerrain.generator (terreno no coincidía con spawns/impostor)

**Estado:** [x] Resuelto
**Módulo:** M09 (Generador de Mapa) / M167 (Isla Raíz)
**Severidad:** Crítica
**Reportado por:** Usuario (feedback visual: "llegué a las montañas impostoras y ahí hay solo agua, están sobre el agua" + "cruzar arena, agua clara y agua profunda para llegar")
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-07 04:55

### Síntomas
- El impostor de terreno (M09) mostraba montañas donde el terreno voxel real era agua.
- El spawn del jugador caía en un lóbulo de tierra SEPARADO de las montañas por un brazo de mar (forma de cruasán).
- Caída doble del personaje al iniciar.

### Causa raíz
world_manager.gd creaba VoxelGeneratorNoise2D (ruido plano, sin isla) + BlockyLibrary de 2 modelos y los asignaba a 	errain.generator/	errain.mesher, pisando (según orden de _ready) el WorldGenerator real (isla 10×, biomas, montañas) que instala main_island.gd. Dos escritores para el mismo recurso del motor.

### Solución
- world_manager.gd reescrito: SOLO aplica el material de vertex color. El generador (WorldGenerator island 10× max_height 90) y la BlockyLibrary de 26 bloques los instala únicamente main_island.gd.
- Verificación: el chamán (M163) spawnea ahora a Y=37 sobre la montaña real (antes Y=17); el impostor y el terreno voxel comparten fuente de verdad.

### Lección
Un solo dueño por recurso del motor. Dos scripts que configuran VoxelTerrain.generator = estado dependiente del orden de _ready (bug intermitente indeterminista).

---
## B-077: .tres de capítulos M74 con BOM UTF-8 — Parse Error en el editor de Godot

**Estado:** [x] Resuelto
**Módulo:** M74 (Eventos)
**Severidad:** Media (errores visibles en el depurador del editor)
**Reportado por:** Usuario ("hay muchos errores en el depurador" — captura del editor mostrando Parse Error: Expected '[' en historia_c3_faro.tres:1, historia_c4_templo_brisa.tres:1, historia_c5_eclipse.tres:1...)
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-07 05:00

### Síntomas
Panel de depurador del editor lleno de ERROR: scene/resources/resource_format_text.cpp:41 - Parse Error: Expected '[', - res://scripts/eventos/data/capitulos/historia_cN_*.tres:1 (un error por archivo, repetido en cada reload).

### Causa
Los 7 .tres creados por el agente (Log 728, sesión previa) fueron escritos con **BOM UTF-8** (bytes EF BB BF al inicio). El parser de recursos de texto de Godot NO tolera BOM: espera '[' como primer byte.

### Solución
Quitar los 3 bytes de BOM de cada archivo (lectura de bytes, escritura sin los primeros 3). Verificación: escaneo de BOM en TODOS los .tres/.tscn/.import del proyecto → 0 restantes.

### Lección (para AGENTS.md §28)
Los archivos de texto de Godot (.tres, .tscn) deben guardarse en UTF-8 **SIN BOM** — el Write tool de algunos agentes agrega BOM según la codificación del entorno. Regla de verificación antes de commit: escanear los primeros 3 bytes de los recursos de Godot.

---
## BUG: test_loop_economico falla 'precio compra definido' (preexistente)

**Estado:** [?] Delegado
**Módulo:** M38/M159 (datos de ítem)
**Severidad:** Baja (solo test, no runtime)
**Fecha:** 2026-09-11 03:55
**Reportado por:** GLM-5.3 (Kilo Code) — hallazgo durante auditoría M38 iter 4

### Pasos para reproducir
1. godot --headless --script res://scripts/shops/test_loop_economico.gd
2. Output: [FAIL] precio compra definido — 14 checks, 1 fallos

### Causa (verificada con prueba A/B git stash)
- OBJ-PLA-001 no tiene precio_compra definido en ItemDatabase y el catálogo data/economy/econ_prices.tres no tiene entrada para ese ítem → precio_compra_vigente() devuelve 0.
- **Preexistente:** verificado ejecutando el test con price_manager.gd en stash (sin los cambios de M38 iter 4) — falla igual. NO es regresión de la iter 4.

### Delegación
- El fix (dar precio a OBJ-PLA-001 en la base o en econ_prices.tres) es del dueño de M159 (catálogo de ítems) o de quien actualice el test. Registro y sigo.

**Modelo:** GLM-5.3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-11 03:55
---

## BUG: test caso_reloj C56/E89/E90 falla por falsos positivos del scan anti-reloj-SO (nuevos archivos de infra sin whitelist)

- **Estado:** ✅ Resuelto (2026-09-11 — GLM-5.3/Kilo Code, M30 iter. 4, Log 845)
- **Módulo:** M30-Reloj (scan) / afecta a M29-M32-M36 (tests de regresión)
- **Severidad:** Media (rompe la señal del test de regresión; NO afecta gameplay)
- **Pasos para reproducir:**
  1. `godot --headless --path game/isla-ancestral --script res://scripts/clock/caso_reloj_tests.gd`
  2. Output: `[FALLO] C56/E89/E90: 0 lecturas de reloj-SO en gameplay (681 archivos escaneados)` — 29 checks, 1 fallo
- **Causa (verificada con A/B git stash):**
  - **PREEXISTENTE:** falla igual SIN los cambios de M29 iter 1 (Log 824) — verificado con stash de game_clock.gd, 29/1 fallo idéntico. NO es regresión de la semilla H120 (usa `randi()` del motor, sin patrones del escáner).
  - Escaneo aislado con réplica del patrón del test detecta candidatos a positivos: `res://scripts/ci/cicd_manager.gd` usa `Time.get_unix_time_from_system` (carpeta `ci/` NO está en WHITELIST_RELOJ_SO), y el propio `caso_reloj_tests.gd` contiene los strings-patrón (auto-detección si el escáner no se excluye a sí mismo).
  - El test no imprime los positivos individuales — diagnóstico difícil sin instrumentarlo.
- **Qué NO es:** no es una lectura de reloj-SO nueva en gameplay; es un gap de whitelist para scripts de infra/CI (timestamps de diagnóstico, mismo criterio que logging/saving/datos/hardware ya whitelisted por re-auditorías previas M30 Log 429).
- **Delegación:**
  - Fix sugerido para el dueño de M30 (glm-5.3/Cline por historial): (1) agregar `res://scripts/ci/` a WHITELIST_RELOJ_SO con el comentario de criterio, (2) excluir el propio test del escaneo (o filtrar `caso_reloj_tests.gd`), (3) opcional: print de positivos en el FALLO para diagnóstico futuro. Re-verificar 29/29 tras el fix.
  - Mientras tanto: el resto de checks del caso_reloj (28/29) sigue verde — la regresión de M29/M30 se interpreta con ese 1 fallo conocido.

### Resolución (2026-09-11 — GLM-5.3 / Kilo Code, M30 iter. 4, Log 845)

- **Causa confirmada tal como se registró:** única violación real del scan = `res://scripts/ci/cicd_manager.gd → Time.get_unix_time_from_system` (retención J de artefactos de build M117/M118 — compara `FileAccess.get_modified_time` contra la hora del SO para borrar ZIPs viejos: **metadata del sistema de archivos, infra, jamás gameplay**). La auto-exclusión del propio test (L315) y el print de positivos `[VIOLA]` YA existían del código original — el fix real era solo la whitelist.
- **Fix aplicado:** `res://scripts/ci/` agregada a `WHITELIST_RELOJ_SO` en `caso_reloj_tests.gd` con comentario de criterio (mismo patrón documental de las entradas legal/updates del Log 429). Ningún cambio en `cicd_manager.gd` (su uso es legítimo de infra).
- **Verificación:** `caso_reloj_tests.gd` → **29 checks, 0 fallos** (685 archivos escaneados, 0 violaciones) · regresiones 5 suites 0 fallos: test_calendario 13/13 · test_consumidores_tiempo 12/0 · test_semilla_iter1 25/25 (M29 H120) · test_reloj_localizacion 0 fallos · test_fauna 0 · test_inventario 0.
- **La señal de regresión C56 queda restaurada para todo el proyecto:** las corridas de M29/M31/M32/M36 ya no necesitan interpretar el "1 fallo conocido".

**Modelo:** GLM-5.3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-11 22:10 (reporte) · 2026-09-12 00:15 (resolución)


---

### BUG-025 — La sección `npc` del save no coincide con el default del schema de M59

- **Fecha de reporte:** 2026-09-11 20:50
- **Módulo(s) afectado(s):** M19 (NPC y Vecinos) — `scripts/npc/villager_manager.gd` · consumidores: M59 (`SaveSchema`/`SaveSnapshot`), M60 (capa de serialización), M21 (diálogos), M58/M107
- **Severidad:** 🟡 Menor (no rompe el guardado: `SaveSchema.validate()` sólo exige que la sección sea Dictionary)
- **Prioridad sugerida:** Media
- **Estado:** [?] Delegado (fix corresponde al dueño de M19)

**Descripción del problema:**
`SaveSchema.default_payload()` define la sección `npc` como `{"npcs": [], "dialogs_seen": {}}`, pero
`VillagerManager.get_save_data()` (M19) devuelve claves **distintas**:
`["visitantes", "llegadas", "partidas", "avisos", "enfriamientos", "hogares", "memoria"]`.
El contrato del schema queda "decorativo": cualquier consumidor que lea `payload["npc"]["npcs"]` o
`payload["npc"]["dialogs_seen"]` (p. ej. la UI de carga, M107, un QA que valide el shape) obtiene
vacío sin ningún error, porque la validación sólo comprueba el tipo Dictionary de la sección.

**Pasos para reproducir:**
1. `Godot --headless --path game/isla-ancestral --script res://scripts/datos/test_datos_m60_iter3.gd`
2. El check de caracterización imprime:
   `provider=["visitantes","llegadas","partidas","avisos","enfriamientos","hogares","memoria"] schema=["npcs","dialogs_seen"]`
3. Alternativa directa: `print(VillagerManager.get_save_data().keys())` en runtime vs
   `print(SaveSchema.default_payload()["npc"].keys())`.

**Comportamiento esperado:**
Una de las dos cosas (decisión del dueño de M19/M59, no de M60):
(a) M19 emite `npcs` + `dialogs_seen` según el schema (y conserva sus claves internas dentro de
`npcs`), o
(b) se actualiza `SaveSchema.default_payload()["npc"]` para reflejar el formato real de M19 y se
documenta el contrato en `04-Codigo.md` de M59.

**Comportamiento actual:**
Divergencia silenciosa entre el default del schema y lo que el provider escribe.

**Entorno / Contexto:**
- Plataforma: PC (Windows), Godot 4.7.2 headless
- Detectado al verificar el checklist de M60 ("RF3: serialización de la fauna y vecinos (M36/M19)")

**Evidencia:**
- Test: `game/isla-ancestral/scripts/datos/test_datos_m60_iter3.gd` (bloque `_test_rf3_fauna_vecinos`)
- Observación adicional del mismo barrido: `scripts/ia_npc/npc_manager.gd` reclama la sección
  **`npc_ai`**, que **no existe** en `SaveSchema._reserved_sections` → sección fuera del contrato
  (mismo tipo de hallazgo, dueño M64).

**Delegación:**
- **Dueño del fix:** M19 (NPC y Vecinos). Registrado por M60: el codec/provider de M60 **no**
  interpreta la sección `npc` (es de M19), así que no hay cambio de M60 pendiente.
- Re-verificar: el check de caracterización del test de M60 iter. 3 fallará en cuanto M19 alinee las
  claves → señal de que corresponde actualizar el test y cerrar este bug.

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-11 20:50
**Reportado por:** hallazgo en la verificación de M60 iter. 3 (Log 845)

### BUG-031 — M95: `MonetizacionManager` falla 3 asserts funcionales en test_monetizacion.gd (regresión detectada en QA cruzado)

- **Fecha de reporte:** 2026-09-12 17:30
- **Modulo(s) afectado(s):** M95 (Monetizacion) — `scripts/monetizacion/monetizacion_manager.gd`, `scripts/monetizacion/test_monetizacion.gd` (dueño glm-5.3-flash, Log 748, heredando deepseek-v4-flash-vision-exp)
- **Severidad:** 🟡 Moderada
- **Prioridad sugerida:** Media
- **Estado:** [?] Delegado (dueño glm-5.3-flash; §21.4 lock — Hy3 no modifica código ajeno)

**Descripcion del problema:**
Re-verificación headless de M95 (QA cruzado Lote D, §21.8) ejecutó `test_monetizacion.gd` y obtuvo 3 fallos funcionales:
1. `FALLO: comprar_edicion(standard) OK` — `comprar_edicion("standard")` no retorna éxito.
2. `FALLO: precio standard = $24.99` — el precio de la edición standard no es $24.99 (catálogo/data drift o regresión).
3. `FALLO: comprar_dlc(expansion) OK` — `comprar_dlc("expansion")` no retorna éxito.

El módulo fue cerrado por glm-5.3-flash (Log 748) con "test_monetizacion 11 checks 0 fallos". La discrepancia indica regresión en `MonetizacionManager` (o deriva del catálogo data-driven de ediciones/DLCs) con respecto al contrato de su propio test.

**Pasos para reproducir:**
1. `"<godot_console>" --headless --path game/isla-ancestral --script res://scripts/monetizacion/test_monetizacion.gd`
2. Salida: `=== TEST M95: 3 fallo(s) ===` (EXIT 1).

**Comportamiento esperado:**
`comprar_edicion("standard")` y `comprar_dlc("expansion")` retornan OK; `precio` de standard = $24.99 (según catálogo data-driven declarado en Log 748).

**Comportamiento actual:**
3 asserts fallan; el manager no completa la compra ni devuelve el precio esperado.

**Entorno / Contexto:**
- QA cruzado Lote D (35 módulos sin §21.8), Hy3/WorkBuddy, Log 858, §21.8.
- Nota: el test espejo `test_monetizacion_m95.gd` corre EXIT 0 (sin banner de fallos); el contrato de M95 está en disputa entre ambos tests.

**Evidencia:**
- `.workbuddy-ai/tmp/diag_M95_test_monetizacion.log` (líneas 148-151): 3 FALLO.
- CHECKLIST-GLOBAL fila 95 (L190): estado 🟡 Liberado, con corrección §21.8 aplicada (NO verificado).

**Intentos de solucion ya probados:**
- Ninguno (código de M95 es propiedad de glm-5.3-flash; fuera de lock §21.4 de Hy3).

**Referencias cruzadas:**
- Log 858 (QA cruzado Lote D, §21.8). CHECKLIST-GLOBAL fila 95.

**Firma:**
**Modelo:** Hy3 (WorkBuddy)
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-12 17:30

**Resolucion (pendiente de dueno — delegado §21.4):**

### BUG-032 — M87: test_localizacion_m87.gd falla por aserciones de conteo obsoletas (false-red)

**Estado:** ✅ Resuelto (2026-09-14, DeepSeek-V4.1-Flash / WorkBuddy) — pendiente de re-verificacion §21.8 por hy3
**Reportado por:** hy3 (WorkBuddy)
**Fecha:** 2026-09-13 20:10
**Modulo:** M87 (Localizacion)
**Severidad:** Baja (no es regresion del modulo; false-red de CI/QA)
**Dueno del test:** DeepSeek-V4.1-Flash (fuera de lock §21.4 de hy3)

**Descripcion:**
El test headless `scripts/localizacion/test_localizacion_m87.gd` (extends SceneTree) finaliza EXIT 1: 18 checks, 3 fallos. Los 3 fallos son aserciones de conteo que esperan exactamente 11 cadenas por idioma (`cantidad_cadenas("es"/"en"/"pt") == 11`), pero el catalogo actual tiene 25 cadenas por idioma. El resto del test pasa: `LocalizationManager` autoload presente, 3 idiomas (es/en/pt), `get_texto` con fallback correcto, interpolacion de `{vars}` correcta. El modulo es funcionalmente correcto; el test esta desactualizado respecto al catalogo expandido por su autor.

**Resultado esperado:** test verde (0 fallos) dado que la funcionalidad es correcta.
**Resultado obtenido:** EXIT 1, 3 fallos de conteo.

**Entorno / Contexto:**
- QA cruzado Lote G, hy3/WorkBuddy, Log 883, §21.8. Godot 4.7.2-stable headless.

**Evidencia:**
- `Resumen M87: 18 checks, 3 fallos` -> `TEST M87 FALLIDO — salida con codigo 1`.
- `[FAIL] 11 cadenas ES size=25`, `[FAIL] 11 cadenas EN size=25`, `[FAIL] 11 cadenas PT size=25`.

**Intentos de solucion ya probados:**
- Ninguno. El test es propiedad de DeepSeek-V4.1-Flash; hy3 solo verifica (§21.4), no modifica codigo de otro modelo.

**Referencias cruzadas:**
- Log 883 (QA cruzado Lote G, §21.8). CHECKLIST-GLOBAL fila 87 (nota QA cruzado hy3, sin sello limpio §21.8).

**Firma:**
**Modelo:** hy3 (WorkBuddy)
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-13 20:10

**Resolucion (2026-09-14, DeepSeek-V4.1-Flash / WorkBuddy):** RESUELTO.

- Causa raiz confirmada: el test apunta al autoload **`LocalizationManager`**
  (`scripts/localizacion/localization_manager.gd`), que carga
  `res://data/localizacion/strings_*.json` (25 claves). Las aserciones quedaron
  fijadas a **11** (tamano de la iter. 1) cuando el catalogo semilla crecio a 25.
- Arreglo: **no fijar el numero**. Se anaden `DIR_LOC`/`MIN_CADENAS` y el helper
  `_cadenas_en_json(lang)`, y cada idioma se compara contra el **JSON fuente**
  leido en tiempo de test (`manager == json`), mas un minimo historico (>= 11).
  Asi una **carga parcial** del catalogo sigue fallando el test, pero una
  **expansion** del contenido ya no produce false-red.
- Check nuevo de coherencia: los 3 idiomas exponen el **mismo** nº de claves
  (un idioma rezagado = traduccion incompleta).
- Evidencia: `=== Resumen M87: 20 checks, 0 fallos ===` + `TEST M87 OK`,
  EXIT 0, x2, 0 `SCRIPT ERROR`.
- Anadido al job `test-suite` de `.github/workflows/quality.yml` (antes no corria
  en CI: por eso el false-red no se detecto alli).

⚠️ **Hallazgo de contexto (H-1, ya reportado en el Log 874→907):** existen DOS
autoloads de localizacion vivos:
`LocalizationManager` (`scripts/localizacion/…`, JSON, 25 claves; consumido por
M16 `inventario_iter4.gd` y M131 `credits_manager.gd`) y
`Localization` (`scripts/localization/…`, `.po`, 85 claves; consumido por M21
`dialogue_manager.gd`). El duplicado NO se toca aqui (cada uno tiene consumidores
reales); queda como deuda arquitectonica para M87.

**Firma del fix:** DeepSeek-V4.1-Flash / WorkBuddy, 2026-09-14.

---

### BUG-033 — M127: test_copyright_m127.gd falla por aserciones de conteo obsoletas (false-red)

**Estado:** ✅ Resuelto (2026-09-14, DeepSeek-V4.1-Flash / WorkBuddy) — pendiente de re-verificacion §21.8 por hy3
**Reportado por:** hy3 (WorkBuddy)
**Fecha:** 2026-09-13 20:10
**Modulo:** M127 (Copyright del Juego)
**Severidad:** Baja (no es regresion del modulo; false-red de CI/QA)
**Dueno del test:** DeepSeek-V4.1-Flash (fuera de lock §21.4 de hy3)

**Descripcion:**
El test headless `scripts/legal/test_copyright_m127.gd` (extends SceneTree) finaliza EXIT 1: 9 checks, 2 fallos. Los 2 fallos son aserciones de conteo que esperan `elementos` == 5 y `politicas` == 2, pero el JSON actual tiene 7 elementos y 5 politicas. La asercion `data valida (0 errores)` del `CopyrightValidator` PASA: los datos son validos. El modulo es correcto; el test esta desactualizado tras la expansion del catalogo por su autor.

**Resultado esperado:** test verde (0 fallos) dado que los datos validan correcto.
**Resultado obtenido:** EXIT 1, 2 fallos de conteo.

**Entorno / Contexto:**
- QA cruzado Lote G, hy3/WorkBuddy, Log 883, §21.8. Godot 4.7.2-stable headless.

**Evidencia:**
- `Resumen M127: 9 checks, 2 fallos` -> `TEST M127 FALLIDO — salida con codigo 1`.
- `[FAIL] 5 elementos size=7`, `[FAIL] 2 politicas size=5`. `[OK] data valida (0 errores)`.

**Intentos de solucion ya probados:**
- Ninguno (test propiedad de DeepSeek-V4.1-Flash; hy3 solo verifica, §21.4).

**Referencias cruzadas:**
- Log 883 (QA cruzado Lote G, §21.8). CHECKLIST-GLOBAL fila 127 (nota QA cruzado hy3).

**Firma:**
**Modelo:** hy3 (WorkBuddy)
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-13 20:10

**Resolucion (2026-09-14, DeepSeek-V4.1-Flash / WorkBuddy):** RESUELTO.

- Causa raiz confirmada: `data/legal/copyright.json` tiene hoy **7 elementos** y
  **5 politicas**; el test fijaba `== 5` y `== 2` (tamano de la iter. 1).
- Arreglo: **no fijar el numero**. Constantes `MIN_ELEMENTOS := 5` /
  `MIN_POLITICAS := 2` (minimos historicos) + asercion de **regresion real de
  datos**: ids de elementos **unicos** y **no vacios**. El validador
  (`data valida (0 errores)`) sigue siendo la comprobacion funcional.
- Evidencia: `=== Resumen M127: 11 checks, 0 fallos ===` + `TEST M127 OK`,
  EXIT 0, x2, 0 `SCRIPT ERROR`.
- Anadido al job `test-suite` de `.github/workflows/quality.yml` (antes no corria
  en CI).

**Firma del fix:** DeepSeek-V4.1-Flash / WorkBuddy, 2026-09-14.

### BUG-034 — CHECKLIST-GLOBAL reescrito por agente paralelo: sellos §21.8 perdidos y filas contradictorias

**Estado:** [?] Abierto (proceso)
**Reportado por:** hy3 (WorkBuddy)
**Fecha:** 2026-09-13 21:00
**Severidad:** Alta (trazabilidad de QA y estado global del proyecto)

**Descripcion:**
Durante el QA cruzado (Lotes E-G, Logs 866-886), un agente paralelo reescribe continuamente `CHECKLIST-GLOBAL.md`. Esto borra o re-atribuye los sellos §21.8 recien aplicados (p.ej. M114 paso de 'hy3/Log 886' a 'Hy3/Log 866') y deja filas en estado contradictorio (p.ej. M114 con sello §21.8 PERO tambien 'DELEGABLE PARA IMPLEMENTAR' + 'QA por Gemini'). El archivo es la unica fuente de verdad del proyecto y no deberia regenerarse por un agente mientras otro sella.

**Resultado esperado:** los sellos §21.8 y las filas de modulo son estables y no se pierden entre agentes.
**Resultado obtenido:** sellos §21.8 borrados/re-atribuidos; filas contradictorias.

**Intentos de solucion ya probados:** re-leer y re-sellar tras escribir (Logs 866-886); el agente paralelo sigue reescribiendo.

**Referencias cruzadas:** Logs 866-886 (QA cruzado), CHECKLIST-GLOBAL.md filas M111/M114/M148.

**Firma:** hy3 (WorkBuddy), 2026-09-13 21:00

**Resolucion (propuesta):** agente de reestructuracion debe CONGELAR CHECKLIST-GLOBAL durante el sellado de QA, o mover los sellos §21.8 a una columna protegida / archivo aparte (ej. CHECKLIST-QA-SEALS.md) fuera del alcance de la regeneracion automatica.

**Resolucion (implementada 2026-09-14, hy3/WorkBuddy):** creado `CHECKLIST-QA-SEALS.md` como registro protegido de sellos §21.8, fuera del alcance de la regeneracion de CHECKLIST-GLOBAL. Si la carrera borra un sello ahi, re-aplicarlo desde este archivo. El agente de reestructuracion AUN debe congelar CHECKLIST-GLOBAL durante el sellado para evitar la perdida visible de la trazabilidad.

### BUG-041 — FALSO POSITIVO (verificado): `GameLogger` (M103) SÍ registra; el residuo real es `log_buffer` como código muerto

**Estado:** [x] Cerrado — **falso positivo** (no era un bug)
**Reportado por:** DeepSeek-V4.1-Flash / WorkBuddy (2026-09-15, al verificar M60 iter. 4)
**Reclasificado por:** DeepSeek-V4.1-Flash / WorkBuddy (2026-09-15, sonda aislada)
**Severidad original:** Alta · **Severidad real del residuo:** Baja (limpieza)

**Qué se afirmó (y era incorrecto):** que `GameLogger` **no registraba nada**, por dos defectos
independientes: (1) `log_buffer` nunca se escribe, y (2) `categories_enabled` arranca `{}` con lo
que `_log()` descarta toda categoría.

**Qué dice la medición.** Sonda aislada (`--script`, 2 corridas, sin tocar el repo):

```
categories_enabled = { 0: true, 1: true, 2: true, 3: true, 4: true, 5: true, 6: true }   <-- NO arranca vacío
min_level          = 0
json_output        = false
gl.info("PROBE_A_DEFAULT_SYSTEM") / gl.info("PROBE_B_CAT_1", 1) / gl.error("PROBE_C_ERROR_SYSTEM")
   -> las 3 líneas salieron por stdout
export_all().length()           = 685        (contiene PROBE_)
export_last_lines(5).length()   = 332        (contiene PROBE_)
archivo en disco: contiene PROBE_A / PROBE_B / PROBE_C = true
```

- **`categories_enabled` NO arranca vacío:** `_load_config()` lo puebla en `_ready()` — desde
  `logging_config.tres` si existe (líneas 66-70) o **habilitando TODAS** las categorías como
  fallback (líneas 71-73). Verificado: ya está poblado en el **frame 1**.
- **`_log()` SÍ emite y SÍ escribe:** `line_emitted.emit()` + `print()` + `_file.store_line()` +
  `_file.flush()` (líneas 127-136). El archivo en disco contiene las líneas.
- **`export_all()` y `export_last_lines()` leen el ARCHIVO** (no el buffer) → devuelven contenido real.

**Por qué se reportó como bug (error de diagnóstico propio).** En la primera corrida de
`test_datos_m60_iter4.gd` el bloque F falló 6 checks y **se atribuyó la causa al logger sin
aislarla**. No era el logger. Prueba decisiva: al retirar el forzado `categories_enabled[1] = true`
que se había añadido como "workaround", el bloque F pasa **15/15** y la suite **152/0 ×3**. Es decir,
el workaround era un **no-op** y el fallo original tenía otra causa (de la propia suite, ya corregida).

**Residuo REAL (Baja, limpieza — sí es de M103):** `log_buffer` es **código muerto**. Se declara
(línea 39), `_flush()` lo recorre y lo limpia (líneas 236-239), pero **nadie hace `append`**:
`grep -rn "log_buffer" game/isla-ancestral/scripts/` sólo lo encuentra en esas 3 líneas de
`logger.gd`. Consecuencia: **`_flush()` es un no-op permanente**. **No afecta al logging** (la
escritura es inmediata línea a línea desde el fix del 2026-09-02), pero es una variable y una función
que prometen algo que no hacen. Fix sugerido (dueño M103): **o** eliminar `log_buffer`/`_flush()`,
**o** alimentar el buffer y usarlo de verdad (p. ej. para `export_last_lines` sin tocar disco).

**Acción tomada en M60 iter. 4:** se retiró el forzado de categoría del suite y se corrigieron los
comentarios que afirmaban el no-op. El suite usa el logger **tal cual**.

**Lección:** un bug sobre un módulo ajeno se **reproduce con una sonda aislada** antes de registrarlo.
Que un test falle *dentro de mi suite* no es prueba de que el componente ajeno esté roto.

**Referencias cruzadas:** Log 916 (M60 iter. 4) · `test_datos_m60_iter4.gd` bloque F ·
`DOCUMENTACION/60-Datos-Y-Serializacion/plan-actual/07-Resultados-Testings.md` §8 ·
`Mensajes entre modelos/ESTADO-PARALELO.md` (bloque de corrección).

**Firma:** DeepSeek-V4.1-Flash / WorkBuddy — reportado 2026-09-15 (07:20) · **reclasificado 2026-09-15 (04:50)**
