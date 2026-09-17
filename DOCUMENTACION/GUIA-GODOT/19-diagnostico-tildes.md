# 19 — Diagnóstico y Solución de Tildes (Freeze) del Juego

> **Modelo:** glm-5.3-flash
> **Plataforma:** Kilo Code
> **Fecha:** 2026-09-11
>
> Archivo específico para diagnosticar y solucionar cuando el juego "se tilda"
> (se congela, no abre, o se cierra solo). Compila TODAS las causas documentadas
> y verificadas: Logs 758-814, secciones TILDE 1-4 de
> [`18-impostores-terreno.md`](18-impostores-terreno.md) y PROMPTS-PENDIENTES.md.
> Ante un tildo nuevo, seguir este archivo ANTES de tocar código.

---

## 1. Clasificación del síntoma

| Síntoma | Causa más probable | Ir a |
|---|---|---|
| No abre / pantalla negra al boot | Autoload huérfano o parse error | §3 paso 3 y 7 |
| Tilda unos segundos después de arrancar y se cierra | Autoload de captura con `quit()` programado | §3 paso 3 |
| Tilda al caminar / volar | Streaming voxel o impostor pesado | §3 paso 6 |
| Tilda al mover el mouse (con spam en depurador) | Acción de InputMap inexistente chequeada en `_unhandled_input` | §2 C-11 |
| Se abre pero queda en Debugger Break (parece tildo) | Error de parse/indentación en un script | §3 paso 7 |
| Tilda con capturas automáticas activas | Readback de GPU (`get_image()`) en viewport de km | §2 C-04 |

---

## 2. Causas documentadas (catálogo C-01 a C-11)

### C-01 — Autoload temporal huérfano ⭐ (causa #1 recurrente)
- **Síntoma:** comportamiento extraño al boot, player "tomado", cierre a los ~10-18 s.
- **Causa:** un script de prueba (capturas, bot, diagnóstico) quedó registrado en
  `[autoload]` de `project.godot` después de terminar la tarea. Ya ocurrió 2 veces
  (Log 802: 4 autoloads; Log 814: `CapturaEstadoM09` con `quit()` a los 18 s).
- **Solución:** auditar `[autoload]` y eliminar toda entrada que no sea un sistema
  permanente del juego. Ver §4 para la lista de autoloads legítimos.
- **Prevención:** TODO script temporal debe llevar en su header
  `# TEMPORAL (Módulo): ... Eliminar al finalizar.` y borrarse en el cierre de sesión.

### C-02 — Script como autoload Y también instanciado en escena ⭐ (2ª causa recurrente)
- **Síntoma:** mensajes de boot duplicados (ej.: `[M50] poblando isla...` ×2, Log 814).
- **Causa:** el mismo script registrado como autoload e instanciado en
  `main_island.tscn` → doble ejecución silenciosa (2×109 items de vegetación,
  130 GLB duplicados en memoria).
- **Solución:** dejarlo SOLO en la escena (patrón del Log 802: `VegetationSpawner`
  fuera de autoload). Verificar SIEMPRE `project.godot` antes de instanciar en escena.

### C-03 — `quit()` programado en autoload de prueba
- **Síntoma:** el juego se cierra solo a los N segundos sin error visible.
- **Causa:** scripts de captura llaman `get_tree().quit()` al terminar su tarea
  (Log 814, `CapturaEstadoM09`).
- **Solución:** buscar en el código temporal `get_tree().quit()` y eliminar el
  autoload junto con el script.

### C-04 — TRANSPARENCY_ALPHA en meshes de escala kilométrica
- **Síntoma:** tilda/pérdida masiva de FPS en GPU integrada al volar alto.
- **Causa:** materiales con `TRANSPARENCY_ALPHA` en meshes de km (impostores,
  discos) fuerzan sorting por píxel en cada frame.
- **Solución:** material **opaco** + fade binario (visible/oculto por distancia).
  Ver `18-impostores-terreno.md` **TILDE 3**.

### C-05 — `VoxelTool.get_voxel` fuerza generación sincrónica (regla crítica — TILDE 2)
- **Síntoma:** freeze de varios segundos o permanente al consultar un voxel.
- **Causa:** `get_voxel` sobre un chunk no generado obliga a Godot a generarlo
  EN el main thread, sincrónicamente.
- **Solución:** NUNCA llamar `get_voxel` en paths de streaming/spawn. Usar
  polling del chunk materializado (señal / `_block_loaded`) o cache de alturas
  del generador (`get_height(x,z)` del TerrainLocator).

### C-06 — Noise por voxel en vez de por columnas (TILDE 1)
- **Síntoma:** tildes al generar terreno nuevo (caminar hacia zona no generada).
- **Causa:** llamar el generador de noise voxel-por-voxel (~millones de llamadas).
- **Solución:** generación **por columnas** (~80× menos llamadas): calcular la
  altura de la columna una vez y rellenar los voxels verticales con ese valor.

### C-07 — Jugador más rápido que el streaming (suelo fantasma — TILDE 4 + PARTE 3)
- **Síntoma:** caídas al vacío o freeze al aterrizar en zona nueva.
- **Causa:** el jugador llega al chunk antes de que exista física.
- **Solución:** suelo fantasma temporal + verificación de voxel real al spawn +
  liberar física recién cuando el chunk del spawn materializa (Log 802).

### C-08 — Timer fijo para el streaming (TILDE 2/4)
- **Síntoma:** freeze esporádico cuando el timer dispara generation sincrónica.
- **Causa:** asumir que "en X ms ya está el chunk".
- **Solución:** verificación de voxel real con polling, no timers fijos.

### C-09 — Parse error / indentación rota → Debugger Break parece tildo
- **Síntoma:** "no abre" o ventana congelada en el editor con el Debugger abierto.
- **Causa:** un edit que rompió la indentación de un bloque (`while`/`for`)
  desalineado (Log 805: `terreno_horizonte.gd:163`).
- **Solución:** leer el Parser Error exacto del depurador, corregir el bloque
  completo (no solo la línea), re-verificar sintaxis antes de relanzar.

### C-10 — Impostor pesado: overdraw de paredes dobles
- **Síntoma:** tildo al volar con la GPU integrada saturada.
- **Causa:** paso fino (32 m) + 4 paredes por celda siempre → decenas de miles
  de triángulos invisibles simultáneos.
- **Solución:** paso 64 m + paredes SOLO en acantilados reales (vecino ≥2 m más
  bajo) + ocultamiento binario <400 m del player (Log 802).

### C-11 — Acción de InputMap inexistente consultada por evento
- **Síntoma:** spam de errores en el depurador al mover el mouse (idea #5 de
  PROMPTS-PENDIENTES): `ui_manager.gd` chequea `ocultar_hud` que no existe.
- **Causa:** `event.is_action_pressed("accion")` sobre acción no registrada.
- **Solución:** registrar la acción en `project.godot` o guardar con
  `InputMap.has_action("x")` antes de consultarla.

---

## 3. Protocolo de diagnóstico (seguir EN ORDEN)

1. **Matar el proceso colgado** (ver §5) y NO relanzar todavía.
2. **Leer el log del último boot** — `Logs/output.txt` y el log del proyecto en
   `%APPDATA%\Godot\app_userdata\Isla Ancestral\logs\`. Si el freeze ocurrió
   ANTES de que Godot pudiera escribir, el log no dejará rastro (pista en sí misma:
   el freeze es temprano, en el boot).
3. **Auditar `[autoload]` de `game/isla-ancestral/project.godot`**:
   - ¿Hay scripts con "TEMPORAL" o de captura/bot/diagnóstico? → eliminarlos.
   - ¿Alguno está TAMBIÉN instanciado en `main_island.tscn`? → quitar del autoload.
4. **Correr el juego vía MCP** (`run_project`) y **contar mensajes clave**:
   - `[M50] poblando isla...` debe aparecer **1 vez** (2 veces = C-02).
   - `[BOT] Desactivado (modo humano)` debe aparecer (si activa el bot solo, C-01).
   - Cualquier `[CAP-` / autoload de prueba = C-01/C-03.
5. **Verificar errores de parse** en `get_debug_output` — un Parser Error deja
   el juego en Debugger Break que parece tildo (C-09).
6. **Aislar por sistema** si el tildo es en juego: deshabilitar
   `TerrenoHorizonte` / impostor en la escena y relanzar. Si mejora → C-04/C-10;
   si no → C-05/C-06 (streaming voxel).
7. **Re-verificar sintaxis completa** del archivo tocado antes de cada relanzamiento.

---

## 4. Autoloads legítimos (referencia — lo que NO debe borrarse)

Los sistemas permanentes del juego registrados en `[autoload]` (EventBus,
ServiceRegistry, SaveManager, TimeCalendar, ItemDatabase, EconomyManager,
LocalizationManager, HardwareManager, CiCdManager, BotPaseoM09 en modo humano,
MundoRaiz, etc.). **Cualquier autoload que no esté en esta lista y sea de
captura/bot/diagnóstico es sospechoso.** La lista completa y vigente vive en
`project.godot` — al dudar, comparar con `git diff HEAD -- project.godot`.

---

## 5. Comandos útiles (PowerShell)

```powershell
# Ver el proceso Godot colgado y su memoria
Get-Process godot* -ErrorAction SilentlyContinue |
  Select-Object Id, ProcessName, WorkingSet64

# Matarlo (el freeze suele dejar 1.5-2 GB de RAM reservada)
Get-Process godot* -ErrorAction SilentlyContinue | Stop-Process -Force

# Leer el final del log del último boot del usuario
Get-Content "$env:APPDATA\Godot\app_userdata\Isla Ancestral\logs\godot.log" -Tail 50

# Ver el spam de boot capturado por el proyecto (Logs/output.txt)
Get-Content Logs\output.txt -Tail 80
```

---

## 6. Checklist rápido de 10 puntos (ante cualquier tildo)

1. [ ] Proceso matado (`Stop-Process -Force`)
2. [ ] Log del último boot leído (¿escribió algo? ¿dónde quedó?)
3. [ ] `[autoload]` auditado — sin temporales/capturas/bots activos
4. [ ] Sin scripts duplicados (autoload + escena)
5. [ ] `get_debug_output` sin Parser Errors
6. [ ] `poblando isla` ×1 en el boot
7. [ ] Impostor con material opaco, paso 64 m, paredes condicionales
8. [ ] Sin `get_voxel` en paths de streaming/spawn
9. [ ] Generación de terreno por columnas
10. [ ] Boot verificado vía MCP antes de avisar al usuario (regla AGENTS.md §12.1)

---

## Registro de tildes resueltos

| Fecha | Causa | Fix | Log |
|---|---|---|---|
| 2026-09-08 | 4 autoloads huérfanos + VegetationSpawner duplicado | Limpieza de autoloads | 802 |
| 2026-09-09 | Indentación rota del `while` en `_crear_tiles()` | Parser Error corregido | 805 |
| 2026-09-10 | Overdraw del impostor (paso 32 m + paredes ×4) | Paso 64 m + paredes condicionales | 802 |
| 2026-09-10 | `CapturaEstadoM09` (quit a los 18 s) + VegetationSpawner otra vez | Autoloads eliminados, scripts temporales borrados | 814 |

> Lección maestra (Log 814): **después de cada push, verificar que
> `project.godot` no arrastre autoloads de prueba.** Es la causa #1 de los
> "tildes misteriosos" de este proyecto — ocurrió dos veces con el mismo patrón.
