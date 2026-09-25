# 11 — BUGS: Registro Central de Problemas y Fallas

**Modelo:** Atria-Dawn-Preview (último modificador)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-19 (Log 1048)

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
| BUG-042 | Tres de los cuatro `.ttf` de `assets/fonts/` no son fuentes sino páginas HTML «Page not found · GitHub» (descargas 404 guardadas con extensión `.ttf`). `load()` devuelve un `FontFile` NO nulo con datos vacíos: FreeType «Error loading font: ''» y métricas 0.0 px, así que el fallo es silencioso | M46/M88 (fuentes) — afecta a M53 (UI) y M87 (tipografía) | 🟠 Mayor | [x] Resuelto (2026-09-19, Log 1024 — 3 fuentes reales verificadas + gate de bytes mágicos en CI + guarda de medición en `theme_ux._try_load_font`) | DeepSeek-V4.1-Flash | 2026-09-15 |
| BUG-052 | **434 .glb de `assets/3d` sin atribución de copyright por-archivo** (claim M127 Log 1022 verificado empírico: 0 de 694 .glb versionados tiene sidecar/extras GLB/catálogo por-archivo; el +16 sobre el techo 418 son respaldos Obsoletos, no assets nuevos) | M166/M09 (pipeline de exportación) — deuda declarada M127 | 🟠 Mayor | [ ] Abierto — verificado y cuantificado por agnes-3-flash (Log 1035); fix = pipeline (dueño M166/M09) | agnes-3-flash (Kilo Code) | 2026-09-18 20:40 |
| BUG-053 | QA visual orbitales: 7 artefactos (V-1..V-7) en M16/M19/M25/M33/M51 — **TRIAJE 2026-09-19 (Log 1049-1052, agnes-3-flash): V-3 (antorcha_pared flota 30 cm) RESUELTO** (regla E-80 `scripts/ruinas/colocar_props_m25.gd` + test 11/11 + captura antes/después en `capturas/19-Muelle/`); V-1/V-2/V-4/V-5 (mesh) [?] Delegado a Hy4 (V5, no disponible hasta mañana); V-6/V-7 = **duplicado** de issue documentado M167/M51 iter. 5 (no se abre bug nuevo) | M16/M19/M25/M33/M51 — mallas: Hy4 (Blender); decisión estética M154 (usuario) | 🟠 Mayor | [?] Delegado (V-3 resuelto; ver §8) | agnes-3-flash (Kilo Code) | 2026-09-19 03:10 |
| BUG-051 | CI: job `godot-lint` era un no-op completo (`--script` sin script + `\|\| true`) | M111/M83 (CI) | 🟠 Mayor | **[x] Resuelto (2026-09-18, Log 1039)** — gate duro real con colector de preloads + `--check-only` + `\|\| FAIL=1`; verificado por inyección | Atria-Dawn-Preview | 2026-09-18 21:07 |
| BUG-054 | M39↔M15: **13 referencias rotas (8 item_ids inexistentes)** en las 3 tiendas oficiales — `catalogo_venta` Y `catalogo_recompra` | M39 (glm activo) / M15 | 🟠 Mayor | [?] Delegado (ver §6 y §8) | Atria-Dawn-Preview | 2026-09-18 |
| BUG-055 | **Corrección de BUG-050**: el SCRIPT ERROR `.size()` sobre Callable NO está en `catalogo_tiendas.gd:63` — está en `test_logros.gd:291` (`_ach.desbloqueados`, propiedad inexistente) | M72 (test propio) | 🟡 Menor | [?] Delegado a M72 (agnes-3-flash) | Atria-Dawn-Preview | 2026-09-18 |
| BUG-056 | **7 scripts del repo no compilaban** (Python-ismos y indentación) — hallados por el gate nuevo de BUG-051 | M73/M131/M155/tests | 🟠 Mayor | **[x] Resuelto (2026-09-18, Log 1039)** — fixes mecánicos; el gate los habría encontrado antes | Atria-Dawn-Preview | 2026-09-18 |
| BUG-058 | `validar_nombres.py` (M149) inunda con **1128 falsos positivos** (847 de `Godot/app_userdata` runtime + ~280 de `addons/`) + deriva real: **41 `.tres`** `LOC-*`/`NPC-*` violan el snake_case documentado | M149 / M160 / M161 / M118 | 🟡 Menor | ✅ **Resuelto (fix exclusiones, Log 1092, hy3 2026-09-19)** — `validar_nombres.py` ahora excluye `Godot/`/`app_userdata/`/`addons/` + modo `--staged`; reporta 45 violaciones reales (no flood). Deriva LOC-/NPC- queda en M160/M161 (no bloquea cierre M149) | hy3 | 2026-09-19 |
| BUG-059 | M126 + M128: **~33 citas colgantes** a `03-Diseno.md` §1.X–§3.9 que **no existen** (vestigio de los sellos ✅ fabricados por agnes-2.5-flash). M128: ~15 ítems con diseño **inexistente** + contradicción app icon 512 vs 1024. **Ampliado (2026-09-20):** sweep global 168 módulos → **8 fantasmas adicionales en 5 módulos** (M71, M80, M86, M108, M127). Ver sub-entradas más abajo | M126 / M128 / M71 / M80 / M86 / M108 / M127 | 🟡 Menor | [?] Delegado — dueño M126/M128 (original). **8 nuevos:** fixes asignados por atria-dawn a dueños de cada módulo (M127 → DeepSeek; M71/M80/M86/M108 → sus dueños). Sweep: mimo-v2.5 (P-04) | atria-dawn + mimo-v2.5 | 2026-09-19 / 2026-09-20 |
| BUG-060 | player.gd: current_scene null en _create_hotbar_hud() (crash potencial) | M11 | 🟢 Mayor | [x] Resuelto | hy3 | 2026-09-19 |
| BUG-057 | `buildings_save_provider.gd` no restaura estructuras al cargar (no-op silencioso mientras M17 no exista) | M17/M59 | 🟡 Menor | [?] Delegado (by design hasta que M17 implemente `restaurar_estructuras`) — ver §6 | Atria-Dawn-Preview | 2026-09-18 |
| BUG-067 | M103 Logging: el presupuesto de frame (**< 0,5 % = 83,35 µs**) **NO se cumple para una llamada que ESCRIBE** — medido **512 µs** (≈6× el frame completo); **99 % del coste es consola+formato (`print`)**, 1 % disco. Además `03-Diseno.md` §10 Regla 5 (buffer + flush periódico) **contradice** §3 (`print` a consola **y** < 0,5 %): bajo tubería un `print` cuesta ~35× más que a archivo, así que ambas cosas no pueden ser ciertas a la vez | M103 Logging (decisión de diseño) — escala a **M61** (Rendimiento) y **M110** (consola in-game) | 🟠 Mayor | [→] **Delegado a DeepSeek-V4.1-Flash** (M103 es 🔵 suyo; mensaje en `Mensajes entre modelos/2026-09-20_02-18-09_1-DEEPSEEK-BUG067-M103-logger-delegacion.md`) — atria-dawn solo midió/documentó, no parcheó. Pendiente confirmación de recepción | DeepSeek-V4.1-Flash (delegado por Atria-Dawn-Preview) | 2026-09-20 |
| BUG-068 | `hardware` y `HardwareManager` son el **mismo script** (`scripts/hardware/hardware_manager.gd`) registrado como **dos autoloads**: Godot crea **una instancia por entrada** (medido: `instance_id` distintos y `a == b` falso), asi que el arranque parsea `hardware_profiles.json` dos veces y registra el servicio dos veces. **Ninguno de los dos nombres se usa** (0 referencias a `/root/hardware`, 0 a `/root/HardwareManager`): peso muerto duplicado y trampa latente | M115 Hardware (config) | 🟡 Menor | [ ] Abierto — fix de 1 linea: borrar una de las dos entradas de `[autoload]`. Detectado por `scripts/auditar_arquitectura_m62.py` (regla A3, Log 1112) | DeepSeek-V4.1-Flash | 2026-09-20 |
| BUG-069 | Grafo de servicios (autoloads): **2 componentes ciclicas** — `{CollectionRegistry, Fishing, GameTime, Inventario, SaveManager, TimeCalendar, Weather}` (7 nodos) y `{ThemeService, UIManager}` — mas **9 referencias** a un autoload declarado DESPUES, alcanzables desde `_ready()`. ⚠️ **Medido: NO es un fallo de runtime** (en `_ready()` Godot 4.7.2 ya instancio todos los autoloads; solo `_init()` falla, y falla para cualquier destino, no por el orden). Es violacion de la regla de capas de `service_registry.gd` y fragilidad de inicializacion | M62 (arquitectura) — involucra M41-M44, M59, M63, M69, M91 | 🟡 Menor (deuda arquitectonica, sin fallo medido) | [ ] Abierto — detectado por `scripts/auditar_arquitectura_m62.py` (reglas A1/A2, Log 1112); el gate los tiene en lista de permitidos para que **ninguno nuevo** pase | DeepSeek-V4.1-Flash | 2026-09-20 |
| BUG-071 | **El fix de BUG-051 no está en el repositorio**: `HEAD` conserva el no-op (`godot --headless --script` sin script + `\|\| true`) porque el hunk que lo reescribe vive **solo en el worktree**. Su generador `tools/quality/gen_colector_sintaxis.py` (3 278 B) **no está versionado**: no está en el árbol de `HEAD` y lo matchea `.gitignore:129` `gen_*.py` (la negación `!tools/quality/gen_colector_sintaxis.py` existe solo en el worktree). **Doble consecuencia:** (a) BUG-051 figura `[x] Resuelto (Log 1039)` sin artefacto versionado que lo respalde; (b) al commitear el worktree, el paso `Generate syntax collector` falla en checkout limpio (`Errno 2`) -> job `godot-lint` en ROJO y el gate «duro verificado por inyección» **nunca llega a ejecutarse en CI** | M111 Código de Calidad / M83 (CI) — `quality.yml`, `tools/quality/`, `.gitignore` | 🟠 Mayor | [x] **Resuelto (2026-09-20, commit `11ac4d9`, atria-dawn)** — el `.py` está versionado (+95), la negación está en `.gitignore:130`, el no-op **desapareció** de `quality.yml` (0 ocurrencias de `--script 2>&1 \|\| true`) y el gate real corre; generador verificado (**855 preloads**, salida **byte-idéntica** `91d6f337…`) | DeepSeek-V4.1-Flash (reportado a Atria-Dawn-Preview) | 2026-09-20 |

> ⚠️ Mantener esta tabla actualizada al registrar, delegar o resolver bugs. Los detalles completos viven en las secciones 6, 7 y 8.

---

| BUG-072 | CI/CD sin implementar: despliegue itch.io, email a stakeholders, validación firebelley; 3 citas § fantasma | M118 | 🟠 Mayor | [ ] Abierto — revertido ✅→🟡 (4 marcas [x]→[ ]), Totales 102/4/0; BUG registrado por hy3 (Log 1125) | hy3 | 2026-09-19 |
| BUG-078 | **El CI ejecuta 8 scripts que NO estan versionados** (`godot --headless --script <ruta>` sobre archivos que no existen en el repo): M11 + 5 de M64 + M116 + M117. En un checkout limpio `godot` sale con **EXIT 1** (`File not found`) -> el job `godot-lint` queda ROJO. Introducido por `0fb0141` (2) y por `11ac4d9` (6) — **el propio commit que arreglaba BUG-051**, que era el mismo defecto | M83 (CI) — `.github/workflows/quality.yml` | 🔴 Critica | [ ] Parcial — M11 versionado (`5ce3aa9`); los 7 ajenos en `DEUDA_CONOCIDA` de `validar_workflows.py` | DeepSeek-V4.1-Flash | 2026-09-20 |
| BUG-076 | **`quality.yml`: 21 `\|\| true` y dos jobs que NUNCA pueden fallar** (`code-quality-script:78` y `formatting-check:107`: su unico check termina en `\|\| true`) pese a estar en el `needs:` del gate duro `summary` | M83 (CI) / M111 Codigo de Calidad | 🟠 Mayor | [ ] Abierto — reportado, NO tocado (es M83/M111) | DeepSeek-V4.1-Flash | 2026-09-20 |
| BUG-077 | **`quality.yml` era YAML INVALIDO**: un `name:` con `: ` sin comillas (linea 597) hacia que GitHub rechazara el archivo COMPLETO -> los 10 jobs del CI apagados ~3 h. Defecto propio de `1582ac2` | M83 (CI) — `.github/workflows/quality.yml` | 🔴 Critica | [x] **Resuelto** (`f1142e6`) + gate `validar_workflows.py` (`8f7d90f`) | DeepSeek-V4.1-Flash | 2026-09-20 |

## 6. Bugs Abiertos (pendientes)

> Checklist vivo: `[ ]` = abierto, `[→]` = en progreso (indicar quién lo trabaja). Aquí se agregan los bugs nuevos con la plantilla de la sección 4.

<!-- ================= BUGS NUEVOS: agregar debajo de esta línea ================= -->
### BUG-078 — El gate de CI ejecuta 8 scripts que NO estan en el repositorio

- **Fecha de reporte:** 2026-09-20 09:10
- **Modulo(s) afectado(s):** M83 (CI) — `.github/workflows/quality.yml`, job `godot-lint`.
  Duenos de los archivos faltantes: **M11** (1), **M64** (5), **M116** (1), **M117** (1).
- **Severidad:** 🔴 Critica — en un checkout limpio el job falla y con el `needs:` del
  `summary` se cae el gate duro. El repo queda en verde solo en la maquina donde los
  archivos existen por casualidad.
- **Introducido por:** `0fb0141` (2026-09-17, M116/M117) y `11ac4d9` (2026-09-20 02:50,
  M64 x5 + M11). **El segundo es el commit que arreglaba BUG-051** — «el fix del gate
  `godot-lint` no estaba versionado» — o sea: **el fix del bug reintrodujo el bug 6 veces**,
  en el mismo job y en el mismo commit.
- **Estado:** [ ] Parcialmente resuelto. M11 versionado en `5ce3aa9`; los otros 7 quedan
  declarados en `DEUDA_CONOCIDA` de `scripts/validar_workflows.py`, que **falla** ante
  cualquier cita nueva sin versionar.

**Que pasa.** El job `godot-lint` ejecuta, entre otros:

```
godot --headless --script scripts/player/test_player_m11.gd 2>&1 || FAIL=1
godot --headless --script scripts/ia_npc/test_navegacion_m64.gd 2>&1 || FAIL=1
...
```

y esos archivos **no estan en el repositorio**. Verificado con la unica medicion que sirve
—`ls` miente, porque el archivo si esta en el disco del autor—:

| comando | resultado |
|---|---|
| `git cat-file -e HEAD:game/isla-ancestral/scripts/player/test_player_m11.gd` | **no existe** |
| `git log -S'test_player_m11' -- .` | nunca se commiteo el archivo (solo la cita) |

**Efecto medido, no inferido.** `godot --headless --script <ruta inexistente>` sale con
**EXIT 1**:

```
ERROR: Attempt to open script 'res://scripts/player/test_player_m11.gd' resulted in error 'File not found'.
ERROR: Can't load script: scripts/player/test_player_m11.gd
```

Con `|| FAIL=1` y el `exit $FAIL` del job, eso es el job en **ROJO**. Y como el primer
archivo faltante corta la cadena, los otros 7 ni siquiera llegan a informar su propio
estado: **un rojo que oculta 7 rojos mas**.

**Barrido completo (68 citas `--script` en los 6 workflows):**

| workflow | cita | dueno |
|---|---|---|
| quality.yml | `scripts/player/test_player_m11.gd` | M11 — **resuelto** |
| quality.yml | `scripts/ia_npc/test_navegacion_m64.gd` | M64 |
| quality.yml | `scripts/ia_npc/test_social_m64.gd` | M64 |
| quality.yml | `scripts/ia_npc/test_rendimiento_m64.gd` | M64 |
| quality.yml | `scripts/ia_npc/test_persistencia_m64.gd` | M64 |
| quality.yml | `scripts/ia_npc/test_ia_npc_m64_iterN.gd` | M64 |
| quality.yml | `scripts/build/test_instalador_m116.gd` | M116 |
| quality.yml | `scripts/build/test_build_m117.gd` | M117 |

Ademas `scripts/editor/_colector_sintaxis.gd` no esta versionado **a proposito**: lo genera
`tools/quality/gen_colector_sintaxis.py` en un paso previo del mismo job. Ese caso va en
`CITAS_PERMITIDAS`, no en la deuda.

**Gate agregado.** `scripts/validar_workflows.py` (regla 5): toda cita `--script` de un
workflow debe existir en `HEAD` (`git cat-file -e`, **no** `os.path.exists`). Trae
`CITAS_PERMITIDAS`, `DEUDA_CONOCIDA` (reportada como aviso, para no apagar el CI por deuda
de otro dueno) y **marca como problema una entrada de deuda que ya este resuelta**, para que
la lista no envejezca en silencio. `--selftest`: 6/6, con el fixture de la cita sin versionar
probado en rojo.

**Por que importa mas de lo que parece.** Es la **trampa 98** y es la **tercera vez** en este
repo: BUG-051 y BUG-071 fueron lo mismo. La leccion que ya estaba escrita en el skill
—«antes de cerrar un bug cuyo cierre se apoya en un gate, corre `git cat-file -e HEAD:<ruta>`
sobre cada archivo que ese gate ejecuta»— **no se aplico al escribir el fix de BUG-051**.

**Firma:** DeepSeek-V4.1-Flash / WorkBuddy — 2026-09-20

### BUG-077 — `quality.yml` era YAML INVALIDO: el CI entero estuvo apagado ~3 h

- **Fecha de reporte:** 2026-09-20 04:45
- **Modulo(s) afectado(s):** M83 (CI) — `.github/workflows/quality.yml`, linea 597
- **Severidad:** 🔴 Critica (todo el CI del proyecto sin ejecutarse, con el repo en verde)
- **Introducido por:** **DeepSeek-V4.1-Flash / WorkBuddy**, commit `1582ac2` (M62 iter. 4, Log 1112), 2026-09-20 01:14:03. **Defecto propio, autoreportado.**
- **Estado:** [x] **Resuelto** — commit `f1142e6` (comilla el valor). Gate que lo hace imposible: `scripts/validar_workflows.py` + job `checklist-orchestrator` (commit `8f7d90f`).

**Que pasaba.** El archivo **no parseaba como YAML**:

```
    name: Architecture Guard (M62: servicios y carga sincrona)
```

El `: ` dentro del valor, sin comillas, hace que YAML lo lea como un mapeo anidado.

**Evidencia — dos parsers independientes, misma linea y columna:**

| parser | salida |
|--------|--------|
| PyYAML | `mapping values are not allowed here` — linea 597, col 34 |
| js-yaml | `bad indentation of a mapping entry (597:34)` |

**Por que es Critica y no un detalle.** Cuando el YAML de un workflow no parsea, **GitHub rechaza el archivo completo**. No falla un job: **dejan de correr los 10** — `godot-lint`, `test-suite`, `legal-tools`, `encoding-guard`, `log-protocol`, `binary-guard`, `architecture-guard`, `summary`… Desde 01:14 hasta 04:45 el CI **entero** estaba apagado y el repo seguia en verde. Es la version CI de **BUG-075**: la misma ceguera, un nivel mas arriba.

**Por que vivio ~3 h.** **Nada en el repo validaba los workflows.** Ni un script, ni un test, ni un gate. El unico que miraba el archivo era GitHub, y su respuesta no llega al repo.

**Gate agregado.** `scripts/validar_workflows.py`: parsea cada workflow, exige `jobs` no vacio, `runs-on` por job, y que **cada nombre en `needs:` exista** (trampa 98 — un gate que cita algo inexistente no es un gate). Exit **1** si hay un problema real, **3** si no puede mirar (sin carpeta / sin workflows / sin parser). Trae `--selftest` con 4 fixtures y el job lo corre **antes** del gate. Verificado: selftest 4/4, validacion real 6/6.

**Firma:** DeepSeek-V4.1-Flash / WorkBuddy — 2026-09-20

### BUG-076 — `quality.yml`: 21 `|| true` y dos jobs que NUNCA pueden fallar, cableados al gate duro

- **Fecha de reporte:** 2026-09-20 04:20
- **Modulo(s) afectado(s):** M83 (CI) / M111 Codigo de Calidad — `.github/workflows/quality.yml`
- **Severidad:** 🟠 Mayor (falso verde en el gate duro: dos de sus requisitos son infalsables)
- **Detectado por:** DeepSeek-V4.1-Flash / WorkBuddy — hallazgo colateral mientras auditaba el fix de BUG-075.
- **Estado:** [ ] Abierto — **reportado, NO tocado** (es M83/M111, no mio). Dueno: por asignar.

**Que pasa.** Dos jobs del workflow tienen **un solo step de check, y termina en `|| true`**, asi que el job **no puede fallar nunca**. Y los dos estan en el `needs:` del job `summary`, que es el gate duro:

| job | linea | su unico check |
|-----|-------|----------------|
| `code-quality-script` | `quality.yml:78` | `godot --headless --script scripts/editor/code_quality_check.gd 2>&1 \|\| true` |
| `formatting-check` | `quality.yml:107` | `godot --headless --check-only 2>&1 \|\| true` |

Ademas, el `echo "… (exit code: $?)"` que sigue al `|| true` reporta **siempre 0**: `$?` es el de la lista, no el de `godot`. O sea que el log *afirma* que el check paso.

**Alcance medido.** `grep -c "|| true" .github/workflows/quality.yml` = **21**. No todos son defectos (los `! grep … || true` del `security-scan` son correctos por construccion), pero los dos jobs de la tabla si lo son: **ningun resultado de `godot` puede hacerlos fallar**.

**Por que importa.** El `summary` chequea `needs.code-quality-script.result != "success"`, y esa condicion es **vacua**: el job siempre da success. Es la familia del detector ciego (trampa 91) y del `|| true` (trampa 81): un gate que no puede fallar no es un gate, es un adorno con forma de gate.

**Precedente en el propio archivo.** `quality.yml:310` (iter. 3, Log 1014) tiene el comentario: *«GATE DURO - se quito `|| true`. El test es … `|| true` lo dejaba sin [efecto]»*. Ya se hizo una vez, para un step; nunca se hizo el barrido de los demas.

**Fix propuesto.** Patron acumulativo que el propio archivo ya usa en `test-suite` y `architecture-guard`: `FAIL=0` … `|| FAIL=1` … `exit $FAIL`. Si algun check es no bloqueante a proposito, declararlo con un comentario y **sacarlo del `needs:` del `summary`** — no dejarlo contando como requisito del gate duro.

**Firma:** DeepSeek-V4.1-Flash / WorkBuddy — 2026-09-20

### BUG-075 — CHECKLIST-GLOBAL.md quedó en 0 bytes: la fuente de verdad global se vació sin detección

- **Fecha de reporte:** 2026-09-20 03:00
- **Módulo(s) afectado(s):** `CHECKLIST-GLOBAL.md` (fuente de verdad del protocolo multiagente, §21) — medido 0 bytes, mtime 03:00:38; `git status` lo reportaba como `M` mientras `HEAD` conservaba 164 820 B (167 filas).
- **Severidad:** 🔴 Crítica (infraestructura — el orquestador completo quedó ciego)
- **Prioridad sugerida:** Alta
- **Estado:** [x] Restaurado por DeepSeek-V4.1-Flash (byte-exacto desde HEAD, sha256 verificado idéntico); **sin commitear** (el archivo volvió a coincidir con HEAD). **Falta el gate de detección.**
- **Reportado por:** DeepSeek-V4.1-Flash (WorkBuddy) — verificado por atria-dawn
- **Modelo:** Atria-Dawn-Preview
- **Plataforma:** Kilo Code
- **Fecha:** 2026-09-20 06:55

**Efecto real, no supuesto.** `scripts/verificar_checklist.py` no podía parsear la tabla y **no se quejaba**: un parser que no itera devuelve «0 problemas», indistinguible de «no hay datos» — **familia de la trampa 91 (detector ciego)**. Esta es la clase de fallo silencioso que hace que un orquestador entero opere sobre un estado inexistente sin saberlo.

**Pérdida permanente.** Las ediciones sin commitear de otros agentes **no son recuperables**. Se midieron 3 copias: `HEAD` (164 820 B), `.kilo/worktrees/phase-judge` (163 410 B) y `.workbuddy-ai/tmp/reg_backup` (147 185 B) — las tres traen la misma fila 62 stale, **ninguna conserva el rewrite que el worktree tenía a las 01:12**.

**Causa raíz (hipótesis).** Escritura truncada por un agente paralelo — un `write` que vació el archivo antes de que otro proceso lo leyera/commiteara. Es el **7º incidente de infra por agentes paralelos** en este ciclo (pool de logs corrupto, 5 colisiones de numeración, 11-BUGS pisado, commits cruzados).

**Fix pendiente (gate).** Todo parser del proyecto que itere sobre un archivo debe fallar cuando el archivo esté vacío o no contenga filas: `if len(filas) == 0: exit 1`. Aplica como mínimo a `scripts/verificar_checklist.py` y `scripts/generar_checklist_global.py`. **Dueño:** atria-dawn (mi especialidad —AutomationBench #1—).

**Firma:** Atria-Dawn-Preview / Kilo Code — 2026-09-20 06:55

### BUG-071 — El fix de BUG-051 no está en el repositorio: `quality.yml` sigue con el no-op y su generador no está versionado

- **Fecha de reporte:** 2026-09-20 02:40
- **Módulo(s) afectado(s):** M111 Código de Calidad / M83 (CI) — `.github/workflows/quality.yml`
  (job `godot-lint`), `tools/quality/gen_colector_sintaxis.py`, `.gitignore`.
- **Severidad:** 🟠 Mayor (marca de cierre sin artefacto en el repo + CI rojo al commitear el worktree)
- **Detectado por:** DeepSeek-V4.1-Flash / WorkBuddy — hallazgo cruzado durante M127 iter. 4 (Log 1119),
  al reparar de forma aditiva el worktree de `quality.yml`. **No lo arreglo: es de atria-dawn.**

**Qué pasa.** BUG-051 figura **`[x] Resuelto (2026-09-18, Log 1039)`** con un «gate duro real …
verificado por inyección». Pero ese fix **no está en el repositorio**: vive **solo en el worktree, sin commitear**.

**Evidencia (medida, no inferida).**

1. `git show HEAD:.github/workflows/quality.yml` — el job `godot-lint` conserva **el no-op textual** que
   BUG-051 describe: `godot --headless --script` **sin script** + `|| true`. La palabra `colector` aparece
   **0 veces** en `HEAD` y **4 veces** en el worktree.
2. `git log -S'gen_colector_sintaxis' -- .github/workflows/quality.yml` -> **sin resultados**: ningún
   commit introdujo nunca el fix.
3. El generador **no está versionado**: `git ls-files tools/quality/` = vacío;
   `git cat-file -e HEAD:tools/quality/gen_colector_sintaxis.py` -> `fatal: … exists on disk, but not in 'HEAD'`.
4. **Por qué**: `.gitignore:129` tiene `gen_*.py` (regla para scripts desechables), que lo matchea. La
   negación `!tools/quality/gen_colector_sintaxis.py` (línea 130) está redactada **solo en el worktree**
   (`.gitignore` = ` M`, sin commitear). Con esa negación presente, `git add --dry-run` responde
   `add 'tools/quality/gen_colector_sintaxis.py'` -> **es agregable: simplemente nadie lo agregó.**
5. El artefacto generado `game/isla-ancestral/scripts/editor/_colector_sintaxis.gd` (56 961 B) tampoco
   está trackeado — **correcto**, es generado; lo que falta versionar es su **generador**.

**Doble consecuencia.**

- **(a) Hoy, en `HEAD`:** BUG-051 está marcado `[x] Resuelto` sin artefacto versionado que lo respalde.
  Mismo patrón que la trampa 95: la marca es honesta en la intención, pero el artefacto citado no existe
  en el repositorio.
- **(b) Si se commitea el worktree tal cual:** el paso `Generate syntax collector`
  (`python tools/quality/gen_colector_sintaxis.py --proyecto game/isla-ancestral`) falla en un checkout
  limpio con `Errno 2: No such file or directory` -> **job `godot-lint` en rojo en cada push/PR**, y el
  gate que BUG-051 declara **nunca llega a ejecutarse** (el `|| FAIL=1` no se alcanza).

**Fix (1 línea, NO aplicado por mí — dueño atria-dawn).** `git add tools/quality/gen_colector_sintaxis.py`
(la negación de `.gitignore` ya está redactada en el worktree) **+** commitear el hunk de `quality.yml` que
reescribe el job `godot-lint`.

**Nota de honestidad.** Un commit selectivo previo (2026-09-19) **excluyó a propósito** este hunk ajeno
para no absorber trabajo de atria-dawn. Excluir era correcto; la consecuencia, dos días después, es que el
fix sigue sin entrar. **No lo commiteo yo**: la autoría y la decisión son de atria-dawn.

**Resolución (2026-09-20, commit `11ac4d9` — atria-dawn).** El fix llegó **ese mismo día**:
`tools/quality/gen_colector_sintaxis.py` **versionado** (+95 líneas), la negación
`!tools/quality/gen_colector_sintaxis.py` agregada a `.gitignore` (+1) y el job `godot-lint` reescrito
(+47/−6) — el no-op `godot --headless --script 2>&1 || true` **desapareció** (0 ocurrencias en `HEAD`).
**Verificado midiendo el efecto, no el código:** el generador se ejecutó sobre el repo real →
`Colector generado (855 preloads)`, exit 0, y la salida quedó **byte-idéntica** a la previa
(SHA-256 `91d6f33794488066…`) → determinista. **Tiempo entre el reporte y el fix: ~1 hora.** La lección
que queda es la de la trampa 98: `git cat-file -e HEAD:<ruta>` sobre **cada archivo que un gate ejecuta**,
antes de cerrar un bug cuyo cierre se apoya en ese gate.

### BUG-068 — `hardware` y `HardwareManager`: el mismo script como dos autoloads (dos instancias vivas)

- **Fecha de reporte:** 2026-09-20 01:00
- **Módulo(s) afectado(s):** M115 Hardware (config) — `game/isla-ancestral/project.godot`
  sección `[autoload]` (entradas `hardware` y `HardwareManager`), ambas apuntando a
  `game/isla-ancestral/scripts/hardware/hardware_manager.gd`.
- **Severidad:** 🟡 Menor (desperdicio duplicado + trampa latente; no rompe nada hoy)
- **Detectado por:** DeepSeek-V4.1-Flash / WorkBuddy — auditor nuevo
  `scripts/auditar_arquitectura_m62.py`, regla **A3** (iter. 4 de M62, Log 1112).

**Qué pasa.** `project.godot` registra el MISMO archivo dos veces, con dos nombres distintos. Godot
crea **una instancia por entrada**, así que no son el mismo objeto.

**Evidencia (medida, no inferida).** Banco de pruebas propio con 2 autoloads apuntando al mismo
script, Godot 4.7.2 headless:

```
Gamma    instance_id=27363640780  contador=42
GammaDos instance_id=27430749646  contador=42
son el MISMO objeto? false
```

Y en el repo, los dos nombres están **sin usar**:

```
grep -rn --include=*.gd '"/root/hardware"'        scripts  ->  0
grep -rn --include=*.gd '"/root/HardwareManager"' scripts  ->  0
```

**Impacto.** El arranque hace el trabajo dos veces: `_ready()` de `hardware_manager.gd` llama a
`_cargar_perfiles()` (parseo de `hardware_profiles.json`) y a `_registrar_servicio()` dos veces. La
segunda registración dispara el `push_warning` de `ServiceRegistry.register()` («ya está
registrado, sobrescribiendo»), así que una de las dos instancias queda inalcanzable por el
registro. Además es una trampa: si alguien empieza a usar `/root/hardware` y otro código usa
`/root/HardwareManager`, estarán hablando con **dos objetos distintos con estado independiente**.

**Fix propuesto (1 línea).** Borrar una de las dos entradas de `[autoload]` (queda
`HardwareManager`, que es el nombre que usa el resto del proyecto para servicios). Antes de
borrar, confirmar que nada la resuelve por el nombre corto — hoy: 0 usos.

---

### BUG-069 — Grafo de servicios: 2 componentes cíclicas y 9 referencias fuera de orden

- **Fecha de reporte:** 2026-09-20 01:00
- **Módulo(s) afectado(s):** M62 Memoria (arquitectura de servicios) — toca
  `scripts/museum/collection_registry.gd`, `scripts/fishing/fishing_manager.gd`,
  `scripts/inventario/inventario_service.gd`, `scripts/saving/save_manager.gd`,
  `scripts/time/*`, `scripts/clima/weather_service.gd`, `scripts/ui/theme/theme_service.gd`,
  `scripts/ui/core/ui_manager.gd`. Regla origen: `scripts/core/service_registry.gd` §Reglas
  («un servicio NO puede depender de otro de nivel superior»).
- **Severidad:** 🟡 Menor (deuda arquitectónica; **no hay fallo de runtime medido**)
- **Detectado por:** DeepSeek-V4.1-Flash / WorkBuddy — auditor nuevo
  `scripts/auditar_arquitectura_m62.py`, reglas **A1** (ciclos) y **A2** (orden), Log 1112.

**A1 — 2 componentes fuertemente conexas** (111 autoloads, 213 referencias explícitas):

1. `{CollectionRegistry, Fishing, GameTime, Inventario, SaveManager, TimeCalendar, Weather}` — 7 nodos.
2. `{ThemeService, UIManager}` — 2 nodos.

Se reporta la SCC y no cada ciclo suelto a propósito: esa componente contiene decenas de ciclos
distintos y enumerarlos no aporta nada (además de volver inestable cualquier lista de permitidos).

**A2 — 9 referencias a un autoload declarado DESPUÉS**, alcanzables desde `_ready()`
(la más grande: `SaveManager` #8 → `Fishing` #45, delta +37; una sola es directa en `_ready`:
`UIManager` #19 → `ControlInput` #24).

**⚠️ Lo que NO es este bug (importa).** La hipótesis inicial era que A2 producía un **null
silencioso** (`get_node_or_null` no avisa y la rama se saltaba). **Se midió y es falso.** Banco de
pruebas con 2 autoloads, Godot 4.7.2 headless:

```
Alfa (indice 0) -> /root/Beta (indice 1) desde _init()   -> <Object#null>
   + ERROR: Can't use get_node() with absolute paths from outside the active scene tree.
Alfa (indice 0) -> /root/Beta (indice 1) desde _ready()  -> Beta:<Node#27011319242>
Alfa (indice 0) -> /root/Beta (indice 1) DIFERIDO 2 frame -> Beta:<Node#27011319242>
```

Es decir: en `_ready()` Godot 4.7.2 **ya instanció todos los autoloads**, así que la búsqueda
**acierta** aunque el destino se declare después. Y la falla desde `_init()` no depende del orden:
`/root/...` no resuelve ahí para **ningún** destino. Se deja escrito para que nadie «arregle» un
crash que no existe ni cite este bug como causa de un fallo de arranque.

**Impacto real.** El grafo deja de ser acíclico y el orden de declaración pasa a ser carga
estructural: la corrección depende hoy de un detalle de implementación del motor (que los
`_ready()` se difieran a después de agregar todos los autoloads). Cualquier dependencia que se
mueva a `_init()`, o cualquier lectura durante la construcción de otro servicio, rompe. Es deuda
arquitectónica, no un defecto funcional.

**Fix propuesto.** Romper los ciclos donde sea barato: `Fishing` → `CollectionRegistry` ya ocurre
dentro de `entrega_museo()` (evento), así que se puede invertir a una señal de `EventBus`; y
`ThemeService` ⇄ `UIManager` puede quedar en una sola dirección si `ThemeService` publica un
`theme_changed` en vez de consultar a `UIManager`. El gate los tiene en lista de permitidos
(`PERMITIDOS`, con este ID) para que **ningún ciclo nuevo** entre: al arreglar uno, hay que borrar
su entrada (el auditor avisa cuáles quedaron obsoletas).

---


### BUG-067 — M103 Logging: una llamada que escribe NO cabe en el frame budget, y el diseño se contradice

- **Fecha de reporte:** 2026-09-19 22:50
- **Módulo(s) afectado(s):** M103 Logging (`game/isla-ancestral/scripts/logging/logger.gd`, hot path
  `_log()` línea 117) y su documentación `DOCUMENTACION/103-Logging/plan-actual/03-Diseno.md` (§3 y
  §10 Regla 5). Escala a **M61** (Rendimiento) y **M110** (Debug Menu / consola in-game).
- **Severidad:** 🟠 Mayor (rendimiento + contradicción de diseño)
- **Detectado por:** DeepSeek-V4.1-Flash / WorkBuddy — suite nueva
  `scripts/logging/test_m103_frame_budget.gd`, creada en la iter. 2 para cerrar por **medición** el
  ítem L199 del checklist («Definir impacto máximo en frame budget < 0,5 %»). Log 1109.

#### Qué se midió (medición propia, no cita)

`RONDAS := 5` intercaladas, `ITERACIONES := 200` por variante, **mínimo por variante** (trampa 78: un
benchmark de una sola pasada y en orden fijo miente). Godot 4.7.2 headless, salida a **tubería**:

```
-- presupuesto: 0.50% de 16.67 ms (60 FPS) = 83.35 us por frame
     gate is_level_enabled ....... 0.140 us
     llamada FILTRADA ............ 1.110 us   (caben 75 por frame en el 0.5%)
     solo disco (store+flush) .... 4.925 us
     llamada que ESCRIBE (total).. 512.310 us   (caben 0 por frame en el 0.5%)
-- ATRIBUCION del coste de escribir: disco=1%  resto(consola+formato)=99%
```

Sonda aislada de atribución (`N := 50`, escritura a **archivo** para no medir la tubería):
`print()` **430,8 µs (86 %)** · `FileAccess` + `flush` **11,4 µs (2 %)** · sin `flush` **1,4 µs**.

#### Las dos consecuencias

1. **Una llamada que escribe no cabe en el frame**: ~512 µs contra los **83,35 µs** del 0,5 %. Lo que
   mantiene el coste fuera del frame es el **gate por nivel** (`is_level_enabled()`, 0,14 µs): una
   llamada **filtrada** cuesta ~1,1 µs y caben ~75 por frame. Es decir, **el coste no está en el
   disco sino en la consola**, y por eso el «buffer de escritura» que pedía el diseño (§10 Regla 5)
   **no habría cambiado nada** — de ahí que se cierre el ítem como innecesario.
2. **El diseño se contradice a sí mismo**: §3 pide **a la vez** «Logger escribe a consola (`print`)»
   **y** «< 0,5 % de frame budget»; §10 Regla 5 pide «buffer de escritura» + «flush periódico (cada
   1 s o 100 líneas)». Bajo una tubería (`|`) un `print()` cuesta **~35× más** que a un archivo
   (~430 µs vs ~15 µs), de modo que **ambas afirmaciones no pueden ser ciertas simultáneamente**
   cuando la salida está redirigida. La implementación real hace lo contrario de la Regla 5 (flush
   **por línea**, deliberado, por crash-proof) y su coste medido es el **1 %** del coste de escribir.

#### Por qué NO se parchea `logger.gd`

El hallazgo es de **calibración y de diseño**, no un defecto funcional. Tocar el hot path alteraría
el contrato **crash-proof** (las líneas tienen que estar en disco al momento; es lo que necesitan el
QA por logs y el volcado pre-crash de M122) y podría romper las 4 suites y los consumidores. La
decisión es de **M61/M110**.

#### Recomendación (para M61/M110)

- **Gate de consola por nivel**: no `print`-ear en release para niveles por debajo de WARNING, o
  `print` acotado (p. ej. sólo las últimas N líneas por frame). Ya existe el precedente: la
  atribución demuestra que la consola es el 99 % del coste.
- **Modo «escribir sin `flush`»**: el propio `logger.gd` ya lo soporta (medido: 1,4 µs frente a
  4,9 µs con `flush`). Suficiente cuando no se necesita crash-proof línea a línea.
- **No añadir el buffer de 100 líneas**: la medición lo descarta como solución (ataca el 1 %, no el
  99 %).

#### Referencias cruzadas

`game/isla-ancestral/scripts/logging/test_m103_frame_budget.gd` (9 checks) ·
`game/isla-ancestral/scripts/logging/logger.gd` (`_log()`) ·
`DOCUMENTACION/103-Logging/plan-actual/04-Codigo.md` §7 ·
`DOCUMENTACION/103-Logging/plan-actual/07-Resultados-Testings.md` ·
`Logs/1109-…` · `DOCUMENTACION/103-Logging/plan-actual/05-Checklist.md` (ítems L135/L136/L199/L227).

**Firma:**
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-19

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

---

### BUG-058 — `validar_nombres.py` (M149) inunda con falsos positivos + deriva de convención en 41 `.tres`

- **Fecha de reporte:** 2026-09-19
- **Módulo(s) afectado(s):** M149 Nombres-Y-Nomenclatura (`operativa/validar_nombres.py`),
  M160 (datos/locations), M161 (data/npc_visuals), M118 (CI hooks)
- **Severidad:** 🟡 Menor (la herramienta funciona, pero **no es usable como gate CI** mientras
  inunde con ruido; y la convención documentada ya no describe el repo real)
- **Prioridad sugerida:** Media
- **Estado:** Parcialmente resuelto (actualizado por hy3 2026-09-24). (a) **[x] M149 `validar_nombres.py` + hook pre-commit:** RESUELTO (hy3, Log 1092); verificado empíricamente 2026-09-24 — `EXCLUDE_DIRS = ("Godot", "app_userdata", "addons")` en `operativa/validar_nombres.py` L38, `operativa/pre-commit-naming` existe, M149 cerrado 🟢 99/100 (1 `[?]` externo legítimo en A.13). El flood de 1128 falsos positivos desapareció. (b) **[?] M160/M161 (convención LOC-/NPC-, 41 `.tres`):** SIN MOVIMIENTO al 2026-09-24 — sin decisión de renombrar ni ampliación de `code-conventions.md` §3; sigue delegado (renombrar 41 `.tres` rompería referencias; fuera de alcance V0). No bloquea el cierre de M149.

**Descripción — dos problemas relacionados:**

**(a) Falsos positivos por falta de exclusiones.** `validar_nombres.py` reporta **1128
violaciones** al ejecutarse sobre el repo. Desglose (medido por mí, 2026-09-19):

| Origen | Cuenta | Naturaleza |
|---|---|---|
| `Godot/app_userdata/isla-ancestral/analytics/lote_*.json` | **847** | Salida de telemetría en tiempo de ejecución — **no es fuente del repo** |
| `addons/gdUnit4/**` (PascalCase.gd) | **~280** | Terceros — no aplica la convención del proyecto |
| `Godot/editor_settings-4.7.tres` | 1 | Config del editor |
| **Arbol fuente real** | **~50** | Ver (b) |

El validador solo excluye `Obsoletos/`. **Sin excluir `Godot/`, `app_userdata/` y `addons/`, su
output es 95% ruido** y no puede usarse como gate (el item E.14 de M149 lo delega a M118; cuando
M118 lo cablee, esto romperá el pipeline).

**(b) Deriva real de convención en 41 `.tres`.** Excluyendo terceros/runtime, quedan ~50
violaciones reales. Las significativas:

- **20 `data/locations/<ISO>/LOC-<ISO>-<TIP>-<NNN>.tres`** (M160) y **21
  `data/npc_visuals/<ISO>/NPC-<ISO>-<NNN>-<rol>.tres`** (M161) — añadidas en el commit del
  **2026-09-02**. Violan el snake_case documentado en `code-conventions.md` §2, PERO siguen un
  patrón de ID de datos legítimo y consistente que **la convención no cubre** (§3 solo documenta
  `item_<cat3>_<sub3>_<NNN>` de M159).
- **9 escenas snake_case** en `scenes/` (`hud.tscn`, `villager.tscn`, `npc_agent.tscn`,
  `caso_reloj.tscn`, `bench_scene_a.tscn`, `captura_playa.tscn`, `gaviota_demo_parada.tscn`,
  `prueba_arquitectura.tscn`, `ruina_preview.tscn`) — `villager.tscn` ya estaba documentado como
  deuda M19/M04; las demás son scenes de test/preview/demo que la convención permite en snake pero
  el validador no distingue (falsa positive o deuda, según se lea).
- **4 scripts:** `_probe_col.gd`, `scripts/debug/_probe_debug.gd` (ambos desde 2026-09-01),
  `scripts/editor/_colector_sintaxis.gd` (mío, Log 1039 — prefijo `_` para tooling privado),
  `tests/.../test_ia_npc_m64_iterN.gd` (WIP sin commitear de MiMo, sufijo camelCase `iterN`).

**Por qué no es sobre-cierre de M149:** los items C.14 y D.10 claimaban "scripts 100% snake_case ✓"
y ".tres 100% snake_case ✓" — **eran ciertos el 2026-08-28** cuando GLM los verificó; la deriva
vino después (commits 2026-09-01/02 y míos). Por eso los dejé `[x]` con **nota de staleness** y no
los revertí: la verificación existió, lo stale es el resultado. Si el proyecto quiere conteo
"vigente al día de hoy", esos dos ítems pasan a `[?]`.

**Fix propuesto (dueño M149/M118):**
1. `validar_nombres.py`: añadir exclusiones `Godot/`, `app_userdata/`, `addons/`; y aceptar
   prefijo `_` en scripts de tooling (`_probe_*.gd`, `_colector_*.gd`).
2. `code-conventions.md` §3: ampliar IDs de datos con los patrones reales
   `LOC-<ISO>-<TIP>-<NNN>` y `NPC-<ISO>-<NNN>-<rol>` (o decidir renombrar 41 archivos —
   **cuidado: renombrar .tres rompe referencias**; documentar y dejar a M160/M161).
3. Cuando M111/M118 cableen el hook (item E.14), ejecutarlo post-fix (a) o el CI queda roto.

**Resolución (hy3 / WorkBuddy, Log 1092, 2026-09-19):**
- **(a) FIX COMPLETADO:** `operativa/validar_nombres.py` añade `EXCLUDE_DIRS = ("Godot", "app_userdata", "addons")` en `es_violacion()` + modo `--staged` (solo archivos staged). Verificado por hy3: árbol completo → **45 violaciones reales** (4 `.gd` scripts + 32 `LOC-`/`NPC-` `.tres` + 9 `.tscn` legacy), **0 SCRIPT ERROR**; `--staged` → `OK` exit 0. El flood de 1128 falsos positivos desapareció.
- **(b) Hook pre-commit CREADO:** `operativa/pre-commit-naming` (bash, bloqueante) invoca `validar_nombres.py --staged` resolviendo la raíz del repo con `git rev-parse --show-toplevel`. Cierra el item E.15 de M149. Instalación: `cp operativa/pre-commit-naming .git/hooks/pre-commit`.
- La deriva LOC-/NPC- (decisión de convención en M160/M161) **NO se tocó** — renombrar 41 `.tres` rompería referencias y excede el alcance V0; queda delegada. No bloquea el cierre de M149 (100/100).

**Firma:**
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-19

---

### BUG-059 — M126 + M128: ~33 citas colgantes a secciones de `03-Diseno.md` que no existen

- **Fecha de reporte:** 2026-09-19
- **Módulo(s) afectado(s):** M126 Marketing-Legal, M128 Identidad-De-Marca (checklists
  `plan-actual/05-Checklist.md`)
- **Severidad:** 🟡 Menor (no afecta código ni runtime — los ítems afectados ya están `[ ]`
  correctamente; es **deuda de documentación** que afirma tener diseño cuando no lo tiene)
- **Prioridad sugerida:** Media (impacta la confianza en TODAS las notas KnownIssue del repo)
- **Estado:** [?] Delegado — dueño **M126/M128** (documentación). Las citas se corrigieron con
  notas de re-referencia (no se borró el texto original); el estado de los ítems no cambia.

**Descripción:** las notas "KnownIssue no bloqueante DoD: ... documentada en `03-Diseno.md` §X.Y"
citaban secciones **inexistentes**. Patrón idéntico en ambos módulos (vestigio de los sellos ✅
fabricados por agnes-2.5-flash, revertidos el 2026-09-14):

- **M126:** el checklist cita `03-Diseno.md §3.1`–`§3.9` (influencers, contratos, giveaways,
  screenshots, FTC, etc.). El archivo tiene **solo §1 (Estructura), §2 (Sistema de revisión legal)
  y §3 (Pruebas)** — las subsecciones §3.1–§3.9 **no existen**. El contenido sustantivo que esas
  notas afirma documentar está parcialmente en §1 (árbol de cobertura) y §2 (plantilla de
  `marketing_legal_review.md` con decisiones ✅/❌).
- **M128:** el checklist cita `§1.1`–`§1.10` y `§2.1`–`§2.6`. El archivo tiene **§1–§5** con otra
  estructura. Verificación item por item (tabla completa en el checklist de M128):
  - ✅ contenido real mal numerado: paleta hex (citada §1.1, real **§3**); clear space + min size
    (citado §2.3, real **§2**).
  - ⚠️ parcial: formatos PNG/SVG (citado §2.4, **§4** lista los archivos pero no menciona AI).
  - ❌ **fabricados** (no existen en ningún lado del módulo): jerarquía tipográfica, swatches,
    licencias de fuentes, registro de dominio, email corporativo, proveedores POD, criterios de
    testing, press kit, versionado del manual, cease & desist, monitoreo de trademark, lockup
    horizontal, variantes light/dark, test de legibilidad.
  - ❌ **contradicción:** el app icon es **512x512** según checklist/`04-Codigo.md` pero
    **1024x1024** según `03-Diseno.md` §2 (tabla "Tamaño Mínimo").

**Por qué importa:** estas notas eran la "evidencia" que justificaba dejar ítems como
casi-terminados. Al ser colgantes, **no hay tal diseño** — los ítems están más lejos de lo que el
checklist sugiere. Cualquier agente que planee cerrar M126/M128 pensando "solo falta ejecución,
el diseño ya está" **va a encontrar que el diseño no existe** para ~15 ítems de M128.

**Fix propuesto (dueño M126/M128):**
1. Ya hecho parcialmente por mí: notas de re-referencia al inicio de ambos checklists (M126:
   mapa a §1/§2; M128: tabla item-por-item). **No borré las notas originales** (trazabilidad).
2. Pendiente: cuando M126/M128 se retomen, **escribir de verdad** el diseño faltante en
   `03-Diseno.md` (sección de tipografía en M128; §3.1-§3.9 reales en M126) o borrar las citas
   falsas.
3. **Resolución de la contradicción del app icon** (512 vs 1024): alinear antes de producir
   (dueño M46/M128). Godot/Steam requieren 1024+.

**Firma:**
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-19

---

#### BUG-059-NEW — Sweep global: 8 fantasmas adicionales en 5 módulos (2026-09-20)

- **Fecha de reporte:** 2026-09-20
- **Módulo(s) afectado(s):** M71-Progresion, M80-Legal-Privacidad, M86-IA-Generativa,
  M108-Pipeline-De-Assets, M127-Copyright-Del-Juego
- **Severidad:** 🟡 Menor (deuda de documentación — citas internas a secciones inexistentes
  en el propio `03-Diseno.md` del módulo; no afecta código ni runtime)
- **Prioridad sugerida:** Baja (los fixes son de documentación, no bloquean gameplay)
- **Estado:** [?] Delegado — dueños de cada módulo (asignados por atria-dawn)

**Descripción:** sweep de solo lectura (BUG-059 ampliado) sobre los 168 módulos con
`03-Diseno.md`. Se extrajeron todas las citaciones `§X.Y` y se cruzaron contra las
secciones reales (headers `## X.Y`). Clasificación:

| Categoría | Cantidad | Definición |
|-----------|----------|------------|
| TRUE_PHANTOM | **8** | Cita a sección que NO existe en el propio `03-Diseno.md` del módulo |
| CROSS_REF | 20 | Cita válida a `AGENTS.md §21.8`/`§9`/`§8` u otro documento externo |
| FALSE_POSITIVE | 17 | Sección existe pero mi regex no la detectó (formato diferente) |

**Los 8 fantasmas confirmados:**

| # | Módulo | Cita | Detalle |
|---|--------|------|---------|
| 1 | **M71-Progresion** | §2.2 | §2 es tabla plana sin subsecciones; el doc se cita a sí mismo |
| 2 | **M71-Progresion** | §2.3 | Idem — §2 no tiene `### 2.3` |
| 3 | **M71-Progresion** | §3.6 | Dice "10 tipos del vocabulario §3.6" pero §3 solo tiene 3.1, 3.2, 3.3 |
| 4 | **M80-Legal-Privacidad** | §9 | No hay `## 9`. El "9" es número de fila dentro de la tabla de §2 |
| 5 | **M80-Legal-Privacidad** | §13 | No hay `## 13`. El "13" es fila de "Contacto" en la tabla de §2 |
| 6 | **M86-IA-Generativa** | §12 | El archivo termina en `## 8`. §12 no existe |
| 7 | **M108-Pipeline-De-Assets** | §6 | Solo tiene §1-§3. §6 no existe |
| 8 | **M127-Copyright-Del-Juego** | §2.3 | §2 no tiene subsecciones (ya documentado en iter. 4 de DeepSeek) |

**Hallazgo adicional:** el `03-Diseno.md` de M127 tiene la numeración rota — hay dos
`## 1` y dos `## 3` en el mismo archivo. DeepSeek debe corregirlo en su próxima iter
(M127 está 🔵 suyo).

**Fix (asignado por atria-dawn, no ejecutado por mimo — solo lectura):**
- M127 → DeepSeek-V4.1-Flow (activo en M127)
- M71 → dueño de M71
- M80 → dueño de M80
- M86 → dueño de M86
- M108 → dueño de M108

**Firma:**
**Modelo:** mimo-v2.5
**Plataforma:** OpenCode
**Fecha:** 2026-09-20


### BUG-061 — M94 Retencion-Sin-FOMO: suite falla 5 checks estando marcado ✅ (sobre-cierre)

- **Estado:** [x] Resuelto (2026-09-19, Log 1083) — ver §7 | **Módulo:** M94 Retencion-Sin-FOMO | **Severidad:** 🔴 Crítico (sobre-cierre de un módulo ✅)
- **Síntoma:** el módulo figura `✅ Completado 135/135` (ACT 2026-09-02, sin sello §21.8), pero
  su suite `scripts/motivacion/test_motivacion_m94.gd` re-corrida con binario real el
  2026-09-19 daba **EXIT 1 — 38 checks, 5 fallos**:
  - `[FAIL] diarios = 3 size=0` — los retos diarios devuelven 0 en lugar de 3
  - `[FAIL] semanales = 2 size=0`
  - `[FAIL] mensuales = 2 size=0`
  - `[FAIL] progreso parcial no completa`
  - `[FAIL] progreso a 10 completa`
- **Causa raíz (VERIFICADA):** **PRODUCCIÓN ROTA** — el catálogo `data/motivacion/objetivos.json`
  usaba un esquema divergente del que lee el código. El manager (`motivacion_manager.gd`),
  la clase canónica (`objetivo_data.gd`: `plazo`, `cantidad_requerida`, `recompensa_id`,
  `recompensa_cantidad`) y la suite son consistentes entre sí y con el diseño
  (`03-Diseno.md` §3 y `04-Codigo.md` §3: 3 diarios + 2 semanales + 2 mensuales). El JSON
  "v2" en cambio tenía `cadencia: "diario_suave"` (los 7), `target_min` y `recompensa` como
  string único con coma — campos que **no existen en ningún .gd**. Consecuencia:
  `objetivo.get("plazo","")` → "" en los 7 → `objetivos_por_plazo()` devolvía [] en los tres
  plazos; y `data.get("cantidad_requerida",1)` → fallback 1 → el primer `registrar_progreso`
  completaba de inmediato. El ítem de checklist 209 del módulo celebra ese JSON "v2" como
  entregable: se escribió sin verificar contra el código (sobre-cierre).
- **Acción realizada:** se reescribió `objetivos.json` al esquema canónico (plazo +
  cantidad_requerida + recompensa_id/recompensa_cantidad), respetando la distribución 3/2/2
  documentada en `04-Codigo.md` §3 y los umbrales que asume la suite (madera=10,
  regalar_regalo=1). No se tocó código ni test.
- **Verificación:** re-corrido con binario real → **EXIT 0 — 38 checks, 0 fallos**.
- **Firma:**
  **Modelo:** Atria-Dawn-Preview
  **Plataforma:** Kilo Code
  **Fecha:** 2026-09-19

### BUG-062 — M84 Musica-Y-Audio-Legal: la suite de test no parsea (✅ no re-validable)

- **Estado:** [x] Resuelto (2026-09-19, Log 1085) — ver §7 | **Módulo:** M84 Musica-Y-Audio-Legal | **Severidad:** 🟠 Mayor
- **Síntoma:** el módulo figura `✅ Completado 99/99` ("Completado por mimo-v2.5 2026-09-18:
  tests edge cases"), pero `scripts/legal/test_audio_licenses_m84.gd` **no compila**:
  `SCRIPT ERROR: Parse Error: The variable type is being inferred from a Variant value, so
  it will be typed as Variant. (Warning treated as error.)` en las líneas **75 y 94** —
  EXIT 1, 4 script errors. La suite no se puede re-correr, así que el ✅ es **no verificable**
  hoy.
- **Causa:** mismo patrón que BUG-048 (`is Tween` sobre var inferida) — Godot 4.7 estricto
  rechaza la inferencia de tipo desde un valor Variant en esas dos líneas del test.
- **Acción:** fixear las 2 líneas del test (tipar explícitamente) y re-correr; el módulo
  subyacente puede estar perfecto, pero hoy no hay evidencia runtime.
- **Acción realizada:** se tipó `var tracks: Array = data.get("tracks", [])` en las líneas 75
  y 94 (la inferencia `:=` desde un valor Variant — `Dictionary.get()` retorna Variant — es
  rechazada por Godot 4.7 estricto). No se tocó lógica del test.
- **Verificación:** re-corrido con binario real → **EXIT 0 — 15 checks, 0 fallos**. El módulo
  subyacente queda validado en runtime (la suite ahora compila y pasa).
- **Firma:**
  **Modelo:** Atria-Dawn-Preview
  **Plataforma:** Kilo Code
  **Fecha:** 2026-09-19


## 7. Bugs Resueltos (historial)

> Cuando un bug se corrige y verifica, se mueve aquí con su fecha de resolución, la solución aplicada y la firma de quien lo resolvió.

### BUG-062 — M84 Musica-Y-Audio-Legal: la suite de test no parseaba (✅ no re-validable)

- **Estado:** [x] Resuelto (2026-09-19, Log 1085) | **Módulo:** M84 Musica-Y-Audio-Legal | **Severidad:** 🟠 Mayor
- **Reportado por:** Atria-Dawn-Preview (auditoría batería anti-sobre-cierre, Log 1065, 2026-09-19)
- **Síntoma:** el módulo figuraba `✅ Completado 99/99` ("Completado por mimo-v2.5 2026-09-18:
  tests edge cases"), pero `scripts/legal/test_audio_licenses_m84.gd` no compilaba:
  `Parse Error: The variable type is being inferred from a Variant value, so it will be typed
  as Variant. (Warning treated as error.)` en las líneas 75 y 94 — EXIT 1, 4 script errors.
- **Causa raíz:** patrón BUG-048 — `var tracks := data.get("tracks", [])`; `Dictionary.get()`
  retorna Variant y la inferencia `:=` es rechazada por Godot 4.7 con warnings-como-errores.
- **Solución:** tipar explícitamente `var tracks: Array = data.get("tracks", [])` en ambas
  líneas. Sin cambios de lógica.
- **Archivos:** `game/isla-ancestral/scripts/legal/test_audio_licenses_m84.gd`, `DOCUMENTACION/11-BUGS.md`.
- **Verificación:** `Godot --headless --script res://scripts/legal/test_audio_licenses_m84.gd`
  → **EXIT 0 — 15 checks, 0 fallos**. El ✅ de M84 ahora sí está respaldado por evidencia runtime.
- **Firma:**
  **Modelo:** Atria-Dawn-Preview
  **Plataforma:** Kilo Code
  **Fecha:** 2026-09-19

### BUG-061 — M94 Retencion-Sin-FOMO: suite fallaba 5 checks (JSON con esquema divergente)

- **Estado:** [x] Resuelto (2026-09-19, Log 1083) | **Módulo:** M94 Retencion-Sin-FOMO | **Severidad:** 🔴 Crítico (sobre-cierre de un módulo ✅)
- **Reportado por:** Atria-Dawn-Preview (auditoría batería anti-sobre-cierre, Log 1065, 2026-09-19)
- **Síntoma:** `test_motivacion_m94.gd` EXIT 1 con 5 fallos (`diarios=3 size=0`, `semanales=2 size=0`,
  `mensuales=2 size=0`, `progreso parcial no completa`, `progreso a 10 completa`) estando el módulo
  marcado `✅ 135/135` sin sello §21.8.
- **Causa raíz:** el catálogo `data/motivacion/objetivos.json` usaba un esquema divergente del que
  lee el código (`cadencia`/`target_min`/`recompensa`-string-con-coma, los 7 como `diario_suave`,
  sin campo `plazo`). `motivacion_manager.gd` lee `plazo` y `cantidad_requerida`, así que
  `objetivos_por_plazo()` devolvía [] y el umbral caía al fallback 1. Código, clase canónica
  (`objetivo_data.gd`), suite y diseño (03-Diseno §3, 04-Codigo §3) eran consistentes entre sí; el
  JSON era el artifact aislado (celebrado como "v2" en el ítem 209 del checklist del módulo).
- **Solución:** se reescribió `objetivos.json` al esquema canónico (`plazo`, `cantidad_requerida`,
  `recompensa_id`, `recompensa_cantidad`), con la distribución 3 diarios + 2 semanales + 2 mensuales
  documentada en `04-Codigo.md` §3 y los umbrales que asume la suite (madera=10, regalar_regalo=1).
  No se modificó código ni test.
- **Archivos:** `game/isla-ancestral/data/motivacion/objetivos.json`, `DOCUMENTACION/11-BUGS.md`.
- **Verificación:** `Godot --headless --script res://scripts/motivacion/test_motivacion_m94.gd`
  → **EXIT 0 — 38 checks, 0 fallos**.
- **Firma:**
  **Modelo:** Atria-Dawn-Preview
  **Plataforma:** Kilo Code
  **Fecha:** 2026-09-19

### BUG-058 — Autoload M107 roto: `ZIPWriter` (Godot 3) → `ZIPPacker` (Godot 4) + 6 warnings Variant→error

- **Estado:** [x] Resuelto (2026-09-19, Log 1077) | **Módulo:** M107 (Backups) — impacto **transversal: stderr de TODOS los runs headless** | **Severidad:** 🔴 Crítico
- **Reportado por:** Hy3 (Log 1072, QA de M118, 2026-09-19 04:50) — "7 SCRIPT ERROR en stderr, todos de `scripts/backup/backup_manager.gd` (autoload roto, no relacionado con M118)". Código original de mimo-v2.5 (Log 1068).
- **Resuelto por:** kimi-k3 (Moonshot AI) / Kilo Code | **Fecha:** 2026-09-19 04:50
- **Documentado como:** E-22 en `GUIA-GODOT/06-registro-errores.md`

- **Síntoma:** Todo run headless (`--headless --path game/isla-ancestral --script ...`) arrancaba con:
  ```
  SCRIPT ERROR: Parse Error: Identifier "ZIPWriter" not declared in the current scope.
    at: GDScript::reload (res://scripts/backup/backup_manager.gd:125)
  ERROR: Failed to instantiate an autoload, script '.../backup_manager.gd' does not inherit from 'Node'.
  ```
  El boot NO abortaba, pero el autoload BackupManager no cargaba y stderr quedaba contaminado →
  cualquier test headless era **falso-verde potencial** (lección 28).

- **Causa raíz (3 capas):**
  1. `ZIPWriter` es clase de **Godot 3**; en 4.x es `ZIPPacker` (parse error de identificador).
  2. `open()` era **estático** en Godot 3; en 4.x es de instancia (`ZIPPacker.new()` + `open()`,
     `APPEND_CREATE` → `APPEND_ADDINZIP`).
  3. `write_file(path, bytes)` de Godot 3 → en 4.x: `start_file(path)` + `write_file(bytes)`.
  4. Además 6 líneas `var x := cat.get("destino", ...)` inferían Variant → **warning tratado como
     error** (proyecto con warnings-as-errors) → parse error adicional tras arreglar lo anterior.

- **Resolución:**
  - [x] Cómo se corrigió: `scripts/backup/backup_manager.gd` — `zip_available()` usa
    `ClassDB.class_exists(&"ZIPPacker")`; `_comprimir_directorio()` instancia
    `var writer := ZIPPacker.new()` + `writer.open(zip_path, ZIPPacker.APPEND_ADDINZIP)`;
    `_agregar_dir_a_zip()` usa `start_file()` + `write_file()` (patrón de `cicd_manager.gd` M118);
    las 6 inferencias Variant → `var destino_cat: String = str(cat.get(...))` y
    `var comprimir: bool = bool(cat.get(...))`.
  - [x] Archivos modificados: `game/isla-ancestral/scripts/backup/backup_manager.gd` (5 sitios). Pendiente de commit (push negativo por instrucción).
  - [x] Log del proyecto: Log 1077 (kimi-k3, 2026-09-19).
  - [x] Verificado por: kimi-k3 con binario Godot 4.7.2 headless — boot check + suite M106:
    **EXIT 0, 0 SCRIPT ERROR en stderr, autoload BackupManager carga sin parse error**.
    No se tocó ninguna otra lógica de M107 (fix quirúrgico de compilación).

---

### BUG-052 — Boot del proyecto roto: `.get()` de 2 args sobre `Resource` (3 archivos, 5 sitios)

- **Estado:** [x] Resuelto (2026-09-19, Log 1044) | **Módulo:** M64 (IA de NPC) — impacto **transversal: todo el proyecto** | **Severidad:** 🔴 Crítico
- **Reportado por:** atria-dawn-preview / Kilo Code (descubierto al auditar la evidencia del Log 1042 de hy3)
- **Modelo:** Atria-Dawn-Preview | **Plataforma:** Kilo Code | **Fecha:** 2026-09-19 00:30

- **Síntoma:** Todo run headless del proyecto (`--headless --path game/isla-ancestral --script ...`)
  arrancaba con:
  ```
  SCRIPT ERROR: Parse Error: Too many arguments for "get()" call. Expected at most 1 but received 2.
    at: GDScript::reload (res://scripts/ia_npc/npc_needs.gd:41)
    at: GDScript::reload (res://scripts/ia_npc/npc_needs.gd:42)
    at: GDScript::reload (res://scripts/ia_npc/npc_needs.gd:43)
  SCRIPT ERROR: Compile Error: Failed to compile depended scripts.
  ERROR: Failed to load script "res://scripts/ia_npc/npc_agent.gd" with error "Compilation failed".
  ```
  **Impacto:** cualquier agente que corriera un test headless veía errores ajenos a su módulo
  (falso-rojo), o —peor— un test que reportaba "0 fallos" mientras el stderr contenía `SCRIPT
  ERROR` (falso-verde, lección 28). La evidencia del Log 1042 de hy3 ("0 SCRIPT ERROR") era
  inválida por este motivo.

- **Causa raíz:** `Resource` extiende `Object`, y `Object.get()` admite **1 solo** argumento.
  Los sitios usaban el patrón de `Dictionary.get(clave, default)`. En los 3 archivos las variables
  receptoras estaban tipadas como `Resource` (perfil de NPC, config de necesidades), por lo que el
  parser rechazaba el segundo argumento. Como `npc_needs.gd` era dependencia de `npc_agent.gd`,
  la compilación fallaba en cascada.

- **Solución:** aplicar el guard `!= null` explícito en vez del argumento default, preservando la
  semántica de fallback original:
  1. `scripts/ia_npc/npc_agent.gd:199` — `profile.get("job", "")` → `profile.get("job")`
     (el guard de la línea 198 ya asegura non-null).
  2. `scripts/ia_npc/npc_agent.gd:205` — `pp.get("job", "")` → guard explícito
     `pp.get("job") != null and str(pp.get("job")) == my_job` (mismo patrón que línea 198).
  3. `scripts/ia_npc/npc_needs.gd:41-43` — `cfg.get("rate", actual)` ×3 → lectura en `var v` +
     `if v != null: campo = v`.
  No se cambió ninguna feature: solo sintaxis + guards equivalentes.

- **Verificación:** binario real Godot 4.7.2, `--script res://scripts/world/test_ramps_color_m49.gd`:
  **0 SCRIPT ERROR / 0 Parse Error / 0 Compile Error / 0 "Failed to load"** en todo el boot (antes:
  5 parse errors + cascada). Suite de M64 re-corrida: `test_ia_npc_m64_iterN.gd` →
  **82 checks, 0 fallos, EXIT 0** (sin regresión en el módulo del dueño, MiMo V2.5).
  Residuo benigno: 66 ObjectDB leaked at exit + 9 resources in use (leaks de shutdown, no de boot).

- **Zona ajena:** `scripts/ia_npc/` es territorio 🔵 de MiMo V2.5 (M64). Se editó por necesidad de
  desbloqueo sistémico del boot, sin tocar features. Alerta dejada en `ESTADO-PARALELO.md`
  (sección 2026-09-19 00:30) para que MiMo relea antes de seguir y no pise el fix.

- **Lección para el registro (GUIA-GODOT):** si una variable está tipada como `Resource`/`Object`,
  **no** usar `.get(clave, default)` — es el método de `Dictionary`. Usar `.get(clave)` + guard
  `!= null`, o `get_property_list`/acceso directo a la propiedad. El parse error no aparece en el
  archivo del caller sino como "Failed to compile depended scripts", lo que despista.

### BUG-051 — CI: job `godot-lint` era un no-op completo (lint de GDScript inefectivo)

- **Estado:** [x] Resuelto (2026-09-18, Log 1039) | **Módulo:** M111/M83 (CI) | **Severidad:** 🟠 Mayor
- **Síntoma:** `.github/workflows/quality.yml:33` ejecutaba `godot --headless --script 2>&1 || true`
  — **sin ningún script**. Godot falla con error de uso, el `|| true` lo silencia, y el paso
  "Check for Godot parser errors" nunca valida nada. El job `godot-lint` **nunca podía fallar**.
- **Causa raíz:** el paso de CI invocaba `--script` **sin especificar script alguno** (uso
  inválido de la CLI) y el error de uso resultante era silenciado por `|| true` → el gate era
  un no-op completo: ningún parseo de GDScript se validaba jamás. De fondo, un segundo paso
  ("Run GDScript Linter") corría `code_quality_check.gd` (`@tool EditorScript`) en headless,
  donde tampoco puede ejecutarse, también tapado con `|| true`.
- **Solución:** 3 piezas nuevas:
  1. `tools/quality/gen_colector_sintaxis.py` — genera `scripts/editor/_colector_sintaxis.gd` con un
     `preload` por cada .gd del proyecto (830; excluye `.godot/`, `addons/` terceros, `Godot/` y a
     sí mismo). `preload` fuerza el parseo a tiempo de compilación.
  2. `quality.yml` job `godot-lint`: pasos nuevos `Setup Python`, `Generate syntax collector` e
     `Import project resources` (`--import` construye la caché de class_names; sin él, un checkout
     limpio da ~19 falsos positivos). El paso de check ahora usa
     `godot --headless --check-only --script res://scripts/editor/_colector_sintaxis.gd 2>&1 || FAIL=1`
     — **gate duro**.
  3. Se retiró el paso "Run GDScript Linter" (`code_quality_check.gd` es `@tool extends
     EditorScript`; no corre headless; era un segundo no-op silencioso con `|| true`).
- **Verificación (binario real, Godot 4.7.2):** árbol limpio → **EXIT 0**; error de sintaxis
  inyectado → **EXIT 1** nombrando el archivo exacto; fresh checkout + `--import` → **EXIT 0**.
- **Detalles técnicos y calleones sin salida documentados:** ver la entrada de BUG-051 en §6.
- **Firma:** Atria-Dawn-Preview / Kilo Code — 2026-09-18 (Log 1039)

### BUG-056 — 7 scripts del repo no compilaban (hallados por el gate nuevo de BUG-051)

- **Estado:** [x] Resuelto (2026-09-18, Log 1039) | **Módulo:** M73/M131/M155/tests | **Severidad:** 🟠 Mayor
- **Síntoma:** 7 scripts con errores de sintaxis REALES que arrastraban versionados: nadie los había
  parseado nunca (la mayoría son `load()`-bajo-demanda o tests gdUnit4 que no corren en CI).
- **Los 7 y sus fixes:**
  | Script | Error | Fix |
  |---|---|---|
  | `scripts/coleccionables/collectible_category.gd:66` | docstring estilo Python `"""..."""` | `##` docstring |
  | `scripts/coleccionables/collectible_category.gd:60` | comprensión de listas `[String(t) for t in tags]` (Python) | bucle `for` |
  | `scripts/legal/audio_legal_manager.gd:195` | 1 espacio en vez de tab | tab |
  | `scripts/legal/test_credits_m131_v2.gd:72` | `ok := ...` (redeclaración sin `var`) | `ok = ...` |
  | `tests/unit/interfaces/test_i_{damageable,interactable,saveable}.gd` | `class CustomX` declarada DENTRO de una función (GDScript no lo permite) | clase movida a ámbito de archivo |
  | `tests/unit/player/test_equipment_manager.gd:133+` | 76 líneas con espacio+tab en vez de tab | tabs |
- **Verificación:** `--check-only` sobre el colector: **830/830 EXIT 0** después de los fixes (antes
  EXIT 1). La prueba de inyección de BUG-051 confirma que el gate los habría detectado.
- **Firma:** Atria-Dawn-Preview / Kilo Code — 2026-09-18 (Log 1039)

### BUG-001 — Overlay de inventario queda pegado al cerrar (M53/M14)

- **Fecha de reporte:** 2026-09-02 17:55
- **Módulo(s) afectado(s):** M53 (UI-UX) — `InventoryLayer` / `inventory_layer.gd`; M14 (Inventario) — panel del jugador `player.gd`
- **Severidad:** 🟡 Menor
- **Prioridad sugerida:** Media
- **Estado:** [x] Resuelto (verificado visualmente por el usuario 2026-09-02 23:04)
- **Reportado por:** Usuario
- **Causa raíz:** `player.gd` guardaba `_inventory_panel` apuntando **solo al PanelContainer**, no
  al `CanvasLayer` (`InventoryCanvas`) cuyo hijo es el `Backdrop` (ColorRect α=0.5); por eso
  `_close_inventory()` al ocultar `_inventory_panel.visible = false` dejaba el velo visible. Factor
  agravante: doble binding de la tecla B en `project.godot` (acción `inventario` → 66) que disparaba
  a la vez el panel legacy de M14 y el `InventoryLayer` de M53.

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
- **Causa raíz:** el diseño M73 es data-driven, pero el catálogo JSON nunca se generó/elaboró; el sistema caía al fallback embebido en código, contradiciendo el contrato de catálogo externo.
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
- **Causa raíz:** colisión de `class_name` globales — dos pares de clases con el mismo nombre (`TerrainModifiers`/`TerrainDetector`) vivían en carpetas distintas (la antigua `scripts/terrain/` y la vigente `scripts/terrenos/`); Godot registra los `class_name` en el ámbito global, así que el parseo fallaba al resolver la base.
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
- **Causa raíz:** el script del debug menu nunca implementaba `_unhandled_input()` (ni ningún handler de input), así que el atajo F12 no se procesaba por más que la acción estuviera mapeada.
- **Solución:** implementado `_unhandled_input` con `KEY_F12` (protección de viewport) + check ampliado.
- **Firma:** deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-02 21:05 (Log 549)
---

### BUG-013 — IDs de DLC divergentes entre manifest y monetización (M95/M120)

- **Estado:** [x] Resuelto (2026-09-02 22:45) | **Módulo:** M95 (Monetización) / M120 (DLC) | **Severidad:** 🟡 Media
- **Causa raíz:** el `dlc_manifest.json` de M120 (ids `isla_hielo`/`pack_aurora`) y el `dlc.json` de monetización M95 (ids `dlc_expansion`/`dlc_cosmetico`) definían **IDs distintos** para los mismos DLC → la carga por id fallaba / inconsistencia entre catálogos.
- **Solución:** unificar los IDs al **manifest M120** (fuente de verdad de carga). Se agregó `scripts/dlc/sincronizar_dlc.gd` — verificador de coherencia DLC (manifest ↔ monetización) que comprueba que ambos catálogos coincidan; 2/2 OK.
- **Verificado por:** deepseek-v4-flash-vision-exp / Kilo Code — 2026-09-02 22:45 (iter 2 de M95; checklist `DOCUMENTACION/95-Monetizacion/plan-actual/05-Checklist.md` líns. 214-216).
- **Firma:**
  **Modelo:** deepseek-v4-flash-vision-exp (resolución) / hy3 (reconstrucción del registro)
  **Plataforma:** Kilo Code / WorkBuddy
  **Fecha:** 2026-09-02 22:45
- **Nota de integridad:** la entrada de detalle original de BUG-013 fue inadvertidamente descartada durante una reorganización concurrente de la sección 8; este bloque fue reconstruido por hy3 (WorkBuddy, 2026-09-02) a partir del checklist de M95 y del script `sincronizar_dlc.gd`, sin inventar pasos de reproducción. Si falta información, completar desde la fuente.

### BUG-014 — Aliasing en get_save_data() de ISaveProvider (M19 VillagerManager)

- **Fecha de reporte:** 2026-09-02 21:45
- **Módulo(s) afectado(s):** M19 (villager_manager.gd get_save_data) — patrón transversal en ISaveProviders
- **Severidad:** 🔴 Crítico (corrupción silenciosa de saves)
- **Prioridad sugerida:** Alta
- **Estado:** [x] Resuelto

**Causa raíz:** en Godot, `Dictionary` y `Array` son tipos **por referencia**. `get_save_data()`
serializaba `_memoria`/`_hogares`/etc. sin copiar, de modo que el snapshot y el estado vivo
compartían los mismos contenedores; el `_clear()` interno de `restore_save_data()` vaciaba también
el snapshot capturado → el round-trip restauraba 0 elementos aunque el save tenía datos (corrupción
silenciosa de saves).

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
**Causa raíz:** el gate `[VAL-DGV]` de `start_dialogue()` (iter 7/8 de M21) rechaza el grafo si
`DialogGraphValidator.validar()` reporta **cualquier** problema, pero las claves que M21 inyecta en
runtime como contexto de condición (payload de evento M20→M21: `new_level`, `reaccion_id`,
`npc_id`, `item_id`; y la session-var `<npc_id>_amistad`) **no estaban en `CLAVES_MUNDO_BASE`** →
el validador las marcaba "clave de mundo desconocida" y los diálogos de reacción quedaban mudos en
producción, además de romper CI y `test_condiciones_mundo.gd`.

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

**Causa raíz:** `_alcanzables()` sólo encola `next_id`/`goto_id` **si el nodo destino existe**; por tanto una arista que apunta a un nodo inexistente no genera ningún problema de validación y pasa CI (falso negativo). En runtime el avance a ese nodo termina en `stop_dialogue()` silencioso → diálogos truncados sin error claro.

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

**Causa raíz (4 defectos del generador, todos medidos):** (1) reescribía `CHECKLIST-GLOBAL.md`
**desde una plantilla fija**, borrando el encabezado y secciones escritas a mano (−34,5 KB);
(2) la plantilla de salida tenía **10 columnas vs 11 del archivo** → como el lector mapea por
posición, cada corrida desplazaba `Agente actual ← Recom`, `Última actividad ← Agente` y
`Notas ← Última actividad`; (3) el fin de tabla se detectaba con "primera línea que no empieza
con `|`", y al haber notas continuadas en líneas huérfanas el resto de la tabla se anexaba como
"sufijo" → **303 filas duplicadas** en vez de 167; (4) `Path.write_text()` sin `newline=`
traducía LF→CRLF en Windows.

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

**Causa raíz:** desajuste de **arity** en el contrato de señal: el autoload `Inventario` (M14)
emite `item_added`/`item_removed` con **3 argumentos** (`item_id, cantidad, container`), pero el
handler `_on_inv_changed` de `inventory_layer.gd` (M53) sólo declaraba **2 parámetros** → Godot
invoca el callable con los 3 args reales y emite `ERROR: Method expected 2 argument(s), but called
with 3` en cada alta/baja de ítem (contaminaba el log; no rompía checks, por eso quedó como hallazgo
colateral de la verificación M110).

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


### BUG-060 — player.gd: `_create_hotbar_hud()` accede a `current_scene` sin null-check (crash potencial)

- **Fecha de reporte:** 2026-09-19 02:55
- **Módulo(s) afectado(s):** M11 (Personaje del Jugador) — `game/isla-ancestral/scripts/player/player.gd`, función `_create_hotbar_hud()` (líneas 972-979)
- **Severidad:** 🟢 Mayor (crash en runtime si el Player se instancia antes de que la escena actual esté lista)
- **Prioridad sugerida:** Alta
- **Estado:** [x] Resuelto

**Causa raíz:** `_create_hotbar_hud()` desreferenciaba `get_tree().current_scene` (L972 y L978)
**sin null-check**: si el nodo Player se instancia antes de que `SceneTree.current_scene` apunte
a una escena válida (transición de escenas o arranque `--script` headless previo al
`change_scene`), `current_scene` es `null` y Godot lanza error al desreferenciarlo.

**Descripción del problema:**
En `_create_hotbar_hud()`, las líneas 972 y 978 invocan `get_tree().current_scene.get_node_or_null("UI")` y `get_tree().current_scene.add_child(canvas)` sin verificar que `current_scene` sea no-nulo. Si el nodo Player se instancia/inicia antes de que `SceneTree.current_scene` apunte a una escena válida (transición de escenas o arranque con `--script`), `current_scene` es `null` y Godot lanza error al desreferenciar `null` (crash del nodo / SCRIPT ERROR).

**Pasos para reproducir:**
1. Instanciar `player.gd` (Player) donde `get_tree().current_scene == null` (escena aún no cargada, o `--script` headless previo al `change_scene`).
2. Llamar a `_create_hotbar_hud()` (vía `_ready` o el flujo de HUD).
3. Observar el error al desreferenciar `current_scene`.

**Comportamiento esperado:**
El HUD del hotbar sólo se crea con una escena actual válida; si no, se omite sin crashear (defensa temprana).

**Comportamiento actual (pre-fix):**
`current_scene` nulo -> `get_node_or_null` / `add_child` sobre `null` -> error de runtime / crash.

**Entorno / Contexto:**
- Godot 4.7.2 (stable, win64).
- Detectado por hy3 en la suite headless M11 (Log 1055) y re-verificado por Atria (confirma sin fix).
- Frecuencia: depende del orden de instanciación del Player vs. la escena; en juego real puede ocurrir en transiciones.

**Evidencia:**
- `player.gd:972` `var ui := get_tree().current_scene.get_node_or_null("UI")` (sin guard).
- `player.gd:978` `get_tree().current_scene.add_child(canvas)` (sin guard).

**Referencias cruzadas:**
- Log 1055 (suite M11, nex-n2.5-pro) — fallo E2/E3 atribuido a "headless sin mundo"; NOTA: el fix de este bug NO elimina E2/E3 (ese es VoxelTerrain no autoload en `--script`, artefacto headless independiente, confirmado inalterado en re-run).
- Atria re-verificó que el bug de `current_scene` seguía sin fix.

**Firma:**
**Modelo:** hy3 / WorkBuddy (Tencent Hunyuan)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-19 02:55

**Resolución:**
- [x] Cómo se corrigió: en `player.gd` `_create_hotbar_hud()` se captura `var current_scene := get_tree().current_scene` al inicio y se agrega guard temprano `if current_scene == null: push_warning(...); return`. Las dos desreferencias (L972 y L978) usan la variable local `current_scene` ya validada. Patrón defensivo consistente con `_verificar_rect_hotbar()` en el mismo archivo.
- [x] Archivos/commits modificados: `game/isla-ancestral/scripts/player/player.gd` (líneas 972-979 -> 971-981 con guard). Pendiente de commit (push negativo por instrucción).
- [x] Log del proyecto: Log 1060 (hy3, 2026-09-19).
- [x] Verificado por: hy3 con binario Godot 4.7.2 headless. M11 suite: 26 checks, 1 fallo (E2/E3 headless-only, inalterado), 0 SCRIPT ERROR. M64 suite (regresión): 82 checks, 0 fallos, EXIT 0, 0 SCRIPT ERROR. El fix no introduce nuevos SCRIPT ERROR.

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
- **Estado:** [x] Resuelto (dueño M39 glm-5.3-flash — causa raíz: id inexistente, NO precio; Log 1017)

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

**Resolución (dueño M39 — causa raíz id inexistente, NO precio):**
- [x] Cómo se corrigió: la investigación con el mapa real de ids (`scripts/reporte_ids_items.py`, 111 `.tres`) demostró que **`OBJ-PLA-001` no existe**: `item_obj_pla_001.tres` contiene `id = "OBJ-CUA-007"`. El "precio 0" era síntoma, no causa: `_precio_base_compra` devuelve 0 para un id fantasma por diseño defensivo correcto. Fix en `game/isla-ancestral/scripts/shops/test_loop_economico.gd`: fixture migrado a **`OBJ-PLA-002`** (existe, precio_compra=30 en su `.tres`) + nuevo check `"item OBJ-PLA-002 existe en ItemDatabase"` (guardián anti-falso-verde: si el id desaparece, el test lo dice en vez de pasar trivial). 0 restantes `OBJ-PLA-001` en el test (verificado por conteo Python).
- [x] Archivos/commits modificados: `game/isla-ancestral/scripts/shops/test_loop_economico.gd` (migración OBJ-PLA-001 → OBJ-PLA-002 en 8 sitios + 1 check nuevo); `scripts/reporte_ids_items.py` (sección CRUCE econ_prices vs items/ para futuros diagnósticos); sin commit aún.
- [x] Log del proyecto: 1017 (este log).
- [x] Verificado por: glm-5.3-flash (Cline), 2026-09-18 — `scripts/run_shops_tests.bat`: **test_tiendas EXIT=0 + test_loop_economico EXIT=0 (15 checks, 0 fallos, "LOOP ECONOMICO OK") + test_tiendas_iter_glm EXIT=0**.

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

### BUG-053 — QA visual orbitales: 7 artefactos M16/M19/M25/M33/M51 (delegado a M154/dueños de módulo)

- **Fecha de reporte:** 2026-09-18 20:40
- **Módulo(s) afectado(s):** M16 Crafting, M19 NPCs, M25 Ruinas-Templos, M33 Agricultura, M51 Agua-Interfaz (M154 aprobación final)
- **Severidad:** 🟠 Mayor (V-3 `antorcha_pared` flota 30 cm = alta; el resto media/baja)
- **Prioridad sugerida:** Media (pendiente de aprobación estética del usuario M154 + H12 M166)
- **Estado:** [?] Delegado — agnes-3-flash verificó y documentó (V1/V2-asistencia); no toca mallas/GLB (V5 = Hy4)

**Descripción del problema (resumen V-1..V-7, evidencia completa en Log 1035):**
V-1 M16: hoja de `hacha_piedra` media/baja como vela semitransparente (decimate/blend, familia E-23).
V-2 M19: brazo-cuajado del `npc_base_v5` colado al torso (perfil).
V-3 M25: `antorcha_pared` (3 variantes) z_min +0.295/+0.34 — única cota positiva del repo (694 glb auditados): flota ~30 cm si se posiciona sobre terreno; en el set de captura va montada en pared (E-80).
V-4 M19: `npc_sentado_v3` con pieza gris flotando tras la cabeza + anillo a la cintura.
V-5 M33: `espantapajaros` con escalón en la cintura del torso (2 cajas desplazadas).
V-6 M51: shore-fade blanco cubriendo demasiada arena (issue conocido M167, CONFIRMADO en iter. 2026-09-06).
V-7 M51: orilla con banda de espuma blanca estática/borde duro; palmeras de banca se ven flotando sobre la banda.

**Por qué agnes-3-flash no lo resuelve:** corrección de mallas/GLB es V5 (Hy4/Blender) y la aprobación estética es del usuario (M154). Lo que sí quedó hecho: verificación empírica (26 capturas leídas + 694 glb medidos en z), lista de evidencia por captura y propuesta de fix por item.
**Firma:** agnes-3-flash (Sapiens AI) / Kilo Code, 2026-09-18 20:40

**Resolución del triage (2026-09-19, agnes-3-flash / Kilo Code, Logs 1049-1052):**
- **V-3 RESUELTO (bug de posicionamiento, no de malla):** `antorcha_pared` no está instanciada
  en el juego (busqueda por repo: solo ficha + reporte); el bug era LATENTE. Fix: regla de
  colocación E-80 nueva en M25 — `scripts/ruinas/colocar_props_m25.gd` (z_base =
  `TerrainLocator.get_height(x,z)+1` por regla de oro; pieza montada: `y = z_base + altura_montaje
  - z_min_asset`, con z_min medido o por datos del Log 1035: alta 0.295 / media-baja 0.340).
  Verificado: `test_colocar_props_m25.gd` headless **11/11 OK, EXIT 0, 0 SCRIPT ERROR** (binario
  Godot 4.7.2 real) + captura in-engine antes/después en
  `tools/mcp/godot-mcp/capturas/19-Muelle/cap_19M-AntorchaPared_antes-despues_2026-09-19_02-46-17.png`.
- **V-1 / V-2 / V-4 / V-5: [?] DELEGADO a Hy4** (corrección de mallas: vela-silueta de
  `hacha_piedra` M16, brazo colado de `npc_base_v5` M19, piezas flotantes de `npc_sentado_v3`
  M19, escalón de `espantapajaros` M33). Hy4 (artista Blender V5) no está disponible hasta
  mañana — se retoman en su turno con esta evidencia. No requieren código.
- **V-6 / V-7: DUPLICADO, sin bug nuevo.** V-6 = KnownIssue M167 "shore-fade enmascara demasiada
  arena" + ítem `[ ]` "Confirmación estética final del usuario" de M51 (iter. 5, Log 750; la
  captura `shorefade_azul` 18:22 es del minuto anterior al release de iter. 5). V-7 = capturas
  PRE-iteración-5 (16:23, estado de iter. 3) + tinte somero declarado de iter. 5. Documentado en
  `DOCUMENTACION/51-Agua/plan-actual/05-Checklist.md` (sección "Triage V-6/V-7", Log 1051).
- **Firma del triage:** agnes-3-flash (Sapiens AI) / Kilo Code, 2026-09-19 03:10

### BUG-052 — Deuda de copyright de .glb: 434/418 explicados, fix del pipeline pendiente

- **Fecha de reporte:** 2026-09-18 20:40 (ampliación del hallazgo M127, Log 1022; no existía entrada .glb previa en §6/§8 — verificación por búsqueda `glb|copyright|M127`)
- **Módulo(s) afectado(s):** M166/M09 (pipeline de exportación), deuda declarada por M127 en `tools/legal/asset_metadata_scope.json` (baseline SIN_ATRIBUCION `**/assets/3d/**/*.glb` max 418)
- **Severidad:** 🟠 Mayor (legal/distribución)
- **Estado:** [ ] Abierto — dueños M166/M09. Verificación empírica COMPLETA por agnes-3-flash (Log 1035).

**Verificación (Log 1035):** 694 .glb versionados auditados uno por uno (sidecars + extras GLB + catálogos `data/legal` + git). **CON copyright: 0 · SIN: 694 · AMBIGUO: 0.** Origen de los 694: propio (pipeline Blender MCP, generator "Khronos glTF Blender I/O v4.2.83", commits "Belforte Pipeline Blender->Godot"). El claim "434" = 418 activos + 16 respaldos `media/Obsoletos/` (2026-09-04) — el crecido 418→434 NO son assets nuevos. Atribución propuesta: "Isla Ancestral Team — © 2026 — Propietaria" (copyright.json `assets_visuales` + NOTICE.md). Fix sugerido: embeder `asset.copyright`/`asset.license` en el exportador glTF del pipeline + sidecar obligatorio para imports de terceros.
**Firma:** agnes-3-flash (Sapiens AI) / Kilo Code, 2026-09-18 20:40


### BUG-074 — Duplicación de numeración: dos entradas distintas comparten "BUG-071"

- **Fecha de reporte:** 2026-09-20 02:50
- **Módulo(s) afectado(s):** `DOCUMENTACION/11-BUGS.md` (registro central) — referencias
  cruzadas hacia BUG-071 desde otros documentos/logs quedan ambiguas.
- **Severidad:** 🟡 Menor (no afecta código ni gameplay; sí afecta trazabilidad)
- **Prioridad sugerida:** Media
- **Estado:** [ ] Abierto — delegado a hy3 y DeepSeek-V4.1-Flash (dueños de ambas entradas)
- **Reportado por:** Atria-Dawn-Preview (Kilo Code)
- **Modelo:** Atria-Dawn-Preview
- **Plataforma:** Kilo Code
- **Fecha:** 2026-09-20 02:50

**Qué pasa.** El registro central contiene **dos encabezados `### BUG-071` distintos**:

1. Línea ~160: *"El fix de BUG-051 no está en el repositorio: `quality.yml` sigue con
   el no-op y su generador no está versionado"* — M111/M83 — reportada por
   **DeepSeek-V4.1-Flash / WorkBuddy** (Log 1119), 2026-09-20 02:40.
2. Línea ~3634: *"CI/CD sin implementar: despliegue itch.io, email a stakeholders,
   validación firebelley; 3 citas § fantasma"* — M118 — reportada por
   **hy3 / WorkBuddy** (Log 1125), 2026-09-19 05:30.

**Causa raíz.** hy3 registró su BUG-071 el 09-19; DeepSeek-V4.1-Flash registró el
suyo el 09-20 **sin re-leer el registro completo**, asumiendo que 071 estaba
libre. Misma clase de error que BUG-002 (numeración fragmentada) y que las
colisiones de logs de la temporada (1095/1097/1100/1103/1111).

**Resolución propuesta (delegada).** No puedo renombrar entradas ajenas:
1. **DeepSeek-V4.1-Flash** renombra su entrada (la más reciente) si fuera necesario; **resolución final abajo**
   y actualiza toda referencia cruzada en sus logs/docs.
2. hy3 mantiene BUG-071 (primera asignación, 09-19).
3. Ambos confirman en `Mensajes entre modelos/ESTADO-PARALELO.md`.

**RESOLUCIÓN FINAL (atria-dawn, coordinador, 2026-09-20).** DeepSeek-V4.1-Flash
midió los commits: el suyo (ed39d5b, 02:35:36) es **17 min anterior** al de hy3
(939d974, 02:52:35), de modo que la prioridad por fecha de commit favorece a
DeepSeek, no a hy3 (la premisa original de esta entrada estaba invertida).

Decisión:
1. **BUG-071 = DeepSeek-V4.1-Flash** (fix de BUG-051 no versionado) — definitivo.
2. **BUG-072 = hy3** (M118 CI/CD sin implementar) — renombrar su entrada.
3. **BUG-074 = este meta-bug** (renumerado desde 072 para no chocar con el 072
   de hy3; BUG-073 ya estaba tomado por el bug real de `fd is null` en M53).

Acción pendiente: **hy3** renombra su `### BUG-071` (M118) a `### BUG-072` y
actualiza referencias en su Log 1125 y donde cite el número. DeepSeek no toca
nada (su entrada ya es 071 canónico).

**Firma:** Atria-Dawn-Preview / Kilo Code — 2026-09-20 02:50 (resolución 06:50)


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
| 2026-09-18 20:40 | agnes-3-flash | Kilo Code | Ampliación del hallazgo M127 (Log 1022): registro BUG-052 (deuda de copyright de .glb verificada empírico: 0 de 694 glb versionados con atribución por-archivo; claim 434 = 418 activos + 16 respaldos Obsoletos) y BUG-053 [?] Delegado (7 artefactos visuales V-1..V-7 en M16/M19/M25/M33/M51; el destacado: `antorcha_pared` flota 30 cm). Evidencia y conteos exactos en Log 1035 + `tools/legal/auditoria_copyright_glb.json` + `tools/legal/flotacion_glb.json`. |
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

---

## BUG-042: las fuentes de `assets/fonts/` son páginas HTML 404, no fuentes

**Severidad:** 🟠 Mayor · **Módulo dueño:** M46/M88 (fuentes) · **Afecta a:** M53 (UI), M87 (tipografía)
**Estado:** Abierto — reportado por **DeepSeek-V4.1-Flash / WorkBuddy** (M87 iter. 6, Log 920, 2026-09-15)

### Qué se observó

Al construir el analizador de encaje de texto de M87 (medición real con las métricas de la fuente),
las medidas salían **0.0 px** para la fuente del juego, mientras que la fuente por defecto del tema
medía con normalidad. La causa no era la API ni el modo headless.

### Qué dice la medición

```
Nunito-Regular.ttf       bytes= 304727  imprimibles= 99.8%  magic= 0a0a0a0a
Nunito-Bold.ttf          bytes= 304688  imprimibles= 99.8%  magic= 0a0a0a0a
FredokaOne-Regular.ttf   bytes= 304724  imprimibles= 99.8%  magic= 0a0a0a0a
Nunito-Variable.ttf      bytes= 276932  imprimibles= 26.7%  magic= 00010000   <- única VÁLIDA

head -c 300 assets/fonts/Nunito-Regular.ttf
  \n\n\n\n\n\n\n\n<!DOCTYPE html>\n<html\n  lang="en"\n  data-color-mode="auto" ...

grep -oE "<title>[^<]*</title>" assets/fonts/Nunito-Regular.ttf
  <title>Page not found · GitHub · GitHub</title>
```

- Un TTF real empieza con el magic `00 01 00 00` (sfnt) o `OTTO`. Los tres archivos corruptos
  empiezan con **`0a 0a 0a 0a`** (saltos de línea) y son **99,8 % texto imprimible**: son
  **páginas HTML de GitHub**, concretamente la pantalla **«Page not found»**. Se intentó descargar
  las fuentes desde URLs de GitHub que devolvían 404 y se guardó la respuesta con extensión `.ttf`.
- `Nunito-Variable.ttf` **sí es una fuente válida** (`00 01 00 00`) y mide correctamente
  (`Jugar`@16 = 37×23 px). No figura en `data/fonts/fonts.json`.

### Por qué es grave (fallo silencioso)

`load("res://assets/fonts/Nunito-Regular.ttf")` **no devuelve `null`**: devuelve un `FontFile`
no nulo pero **sin datos**. Las consecuencias se propagan sin ruido:

- FreeType emite `Error loading font: '' (face_index=0)` y
  `Condition "!_ensure_cache_for_size(fd, size, ffsd)" is true. Returning: 0.0`.
- **Todas las métricas son 0.0** → cualquier medición de texto (encaje, desborde, expansión) da
  «cabe», y el texto se renderiza con la fuente de reserva del motor.
- Un `if fuente != null` **no detecta el problema**: el objeto existe. La comprobación correcta es
  **medir** (`get_string_size(...).x > 0`), no comprobar la referencia.

### Estado en el resto del proyecto

`data/fonts/fonts.json` (M88) declara **`tiene_archivo: false` en las CUATRO fuentes**
(`museo_moderno`, `texto_cozy`, `script_isla`, `mono_debug`), así que la **metadata es honesta**:
el módulo sabe que no hay archivos. El problema es que **los archivos físicos existen y engañan**
a quien haga `load()` directo, y que `Nunito-Variable.ttf` (la única fuente real) **no está
declarada** en ese catálogo.

### Fix sugerido (dueño M46/M88)

1. **Borrar o reemplazar** los tres `.ttf` corruptos por los binarios reales de Nunito/Fredoka
   (OFL), verificando el magic `00 01 00 00` **antes** de commitear.
2. **Declarar** `Nunito-Variable.ttf` en `data/fonts/fonts.json` con `tiene_archivo: true` y su ruta,
   o descartarlo si no es la fuente elegida.
3. **Guardar la puerta**: al cargar una fuente, exigir `get_string_size("A").x > 0` y avisar si no
   (una fuente que carga pero no mide es peor que una ausente).
4. Chequeo de CI sugerido: ningún `.ttf` del repo debe empezar con `<!DOCTYPE` ni con `0a`.

### Referencias cruzadas

`Logs/920-M87-Localizacion-Iter6_2026-09-15.md` · `scripts/localization/analizador_layout.gd`
(`medir()` documenta la trampa de medición) · `test_localizacion_iter6.gd` bloques A6/A7 (dejan la
evidencia en cada corrida) · `Mensajes entre modelos/ESTADO-PARALELO.md`.

**Firma:** DeepSeek-V4.1-Flash / WorkBuddy — reportado 2026-09-15 (Log 920)

## BUG-043: bioma "snow" inalcanzable en el generador de la isla (checks en orden incorrecto)

- **Fecha de reporte:** 2026-09-17 04:55
- **Modulo(s) afectado(s):** M10 (Generación del Mundo) — `scripts/world/island_generator.gd:188-209`; efecto visible en M09/M167 (terreno de la Isla Raíz)
- **Severidad:** 🟡 Menor (visual — la nieve nunca aparece pese a existir el bloque)
- **Prioridad sugerida:** Media
- **Estado:** [?] Delegado (requiere visto bueno del usuario sobre el perfil visual del terreno — Log 791 restauró max_height 40 / boost 1.0 tras rechazar el terreno escalado)
- **Reportado por:** atria-dawn (Shanghai AI Laboratory) / Kilo Code — QA M10, Log 945

**Descripcion del problema:**
`_get_biome(x, z)` clasifica los biomas por altitud con dos umbrales calculados sobre
`max_height` (40 nominal): mountain cuando `h > 0.65*40 = 26` y snow cuando
`h > 0.8*40 = 32`. El check de **mountain se evalúa primero** (línea 198) y el de snow
después (línea 202), así que toda posición alta vuelve "mountain" y el bioma "snow"
es **código muerto**. El bloque SNOW (BlockType.SNOW = 26) existe y está registrado en
la VoxelBlockyLibrary de `main_island.gd:131`, pero el generador nunca lo produce.

**Evidencia (test nuevo, `scripts/world/test_generacion_m10_atria.gd`):**
muestreo de 2000 posiciones en espiral dentro del 55% interior con el config de
runtime (semilla 42, radio 2560, max_height 40, boost 1.0):
`mountain=80, snow=0`, **altura máxima real = 38 > 32**. Es decir, existen posiciones
que deberían clasificarse como nieve y se clasifican como montaña.

**Pasos para reproducir:**
1. `Godot --headless --path game/isla-ancestral --script res://scripts/world/test_generacion_m10_atria.gd`
2. El test falla con: "bioma snow alcanzable: snow=0/2000 — causa única: el check de
   mountain (26) va ANTES que el de snow (32)".

**Comportamiento esperado:**
Posiciones con `h > 32` deberían ser bioma "snow" (superficie BlockType.SNOW).

**Solucion propuesta:**
En `island_generator.gd:188-209`, invertir el orden de los checks (snow antes que
mountain) para que el umbral más alto gane:
```gdscript
if height > max_height * 0.8:
    return "snow"
if height > max_height * 0.65:
    return "mountain"
```
**Caveat:** esto hace que nieve aparezca en las cumbres — cambio visual que el usuario
debe aprobar, porque el perfil del terreno se congeló deliberadamente (Log 791).

**Notas:**
- No es un crash ni afecta al gameplay; es contenido (nieve) que nunca se genera.
- Cadenas relacionadas: M09 (Log 944) documentó que el generador no consume las recetas
  de biomas de M09; este bug es otra consecuencia de que la lógica de biomas es
  ad-hoc del generador en vez de data-driven.

## BUG-044: modulo M12 Camara — dos sistemas paralelos; el documentado es codigo muerto

- **Fecha de reporte:** 2026-09-18
- **Modelo:** Atria-Dawn-Preview
- **Plataforma:** Kilo Code
- **Reportado por:** agente (QA cruzado M12, Log 955)
- **Modulo:** M12 Camara
- **Severidad:** Alta (arquitectura)
- **Estado:** [?] Delegado

### Sintoma

El `05-Checklist.md` del M12 firme 102/102 items como cumplidos, afirmando comportamiento en
runtime: 5 modos de camara (Explore/Build/Dialog/Cutscene/Minimap), zoom de 3 niveles (2.5/5/8 m),
shake narrativo, fade centralizado, minimapa 128x128, FOV 70 fijado, limitador de rotacion
240 grados/s. **Ninguno de esos comportamientos existe en la escena que el juego ejecuta.**

### Causa raiz

Existen dos sistemas de camara paralelos:

1. **`scripts/camera/camera_rig.gd`** (267 lineas, CameraRig.tscn, camera_mode.gd, camera_spring.gd):
   implementa todo lo que el modulo documenta. Pero **jamais se instancia en la escena principal**
   (`run/main_scene = res://scenes/main_island.tscn`). Solo esta cableado en `scenes/main.tscn` +
   `scripts/main.gd`, escena que no es la principal y no tiene ninguna referencia entrante desde
   ningun .gd ni .tscn del proyecto. **Es codigo muerto.**

2. **`scripts/follow_camera.gd`** (109 lineas, instanciada en `main_island.tscn:70-73`): la camara
   que realmente corre el juego. Un solo modo, zoom continuo 4-20 m por scroll, yaw de orbit libre
   del mouse, colision por voxel raycast, sin shake, sin fade, sin minimapa, sin FOV fijado.

Ademas, los contratos de integracion documentados (seccion 3 de `04-Codigo.md`) no existen:
`EventBus.ui.camera_mode`, `EventBus.ui.shake_requested`, `camera_mode_changed`,
`camera_state` en GameState.M12 tienen **0 menciones** en todo el codigo del proyecto. Y de los 6
archivos previstos en la seccion 2, solo existen 2 (camera_mode.gd, camera_spring.gd); faltan
camera_fade.gd, camera_shake.gd, minimap_view.gd y data/camera/camera_settings.tres (carpeta
inexistente — la config real es el autoload GameSettings).

### Pasos para reproducir

1. Abrir `game/isla-ancestral/project.godot`: `run/main_scene = "res://scenes/main_island.tscn"`.
2. Abrir `scenes/main_island.tscn`: el nodo camara es un Camera3D plano con
   `scripts/follow_camera.gd`. No hay ningun nodo CameraRig en la escena.
3. Buscar `CameraRig|camera_rig` en todos los .tscn: aparece en `main.tscn` y `CameraRig.tscn`
   solamente.
4. Buscar `set_mode(|camera_mode_changed|shake_requested|fade_screen|transition_finished` en
   todos los .gd: **0 resultados** (fuera del propio camera_rig.gd).

### Impacto

- Todo el M12 (documentado como OK por un QA anterior) es especificacion, no implementacion.
- `camera_spring.gd` (colision spring-arm) duplica la logica de colision de follow_camera.gd.
- Los modulos consumidores M13 (hotbar), M15, M17 (modo Build), M21 (Dialog), M22 (Cutscene) no
  tienen ninguna camara de modo con la que integrarse.

### Por que no lo resuelve este agente

Requiere una decision de diseno del **usuario**: conservar `camera_rig.gd` (integrandolo en
main_island.tscn y reimplementando fade + minimapa ausentes) o conservar `follow_camera.gd`
(reescribiendo toda la documentacion del M12 para describir lo que realmente hay). Ambas opciones
implican descartar trabajo ya hecho. Ademas, al integrar el rig se romperia temporalmente el hito
M1 (la unica camara jugable hoy es follow_camera.gd).

### Documentacion de soporte

- `DOCUMENTACION/12-Camara/plan-actual/05-Checklist.md` — 53 items flagueados, seccion QA anexada.
- `DOCUMENTACION/12-Camara/plan-actual/04-Codigo.md` — seccion "Notas del Agente (2026-09-18)".
- `Logs/955-QA-M12-Camara_*.md`.

## ACTUALIZACION BUG-028 — causa raiz encontrada (atria-dawn / Kilo Code, Log 982, 2026-09-18)

- **Modelo:** Atria-Dawn-Preview
- **Plataforma:** Kilo Code

El reporte original de Hy3 (2026-09-12) decia "loop compra roto". **La causa real es mucho mas
simple: el item_id `OBJ-PLA-001` NO EXISTE en ItemDatabase.**

- `data/items/item_obj_pla_001.tres` contiene `id = "OBJ-CUA-007"` (nombre de archivo e id interno
  discordantes — ver BUG-046 abajo; 12 items del catalogo M159 tienen este problema).
- `ItemDatabase.get_item("OBJ-PLA-001")` devuelve **null** (verificado por diagnostico headless
  propio: `scripts/economia/test_diag_m38_atria.gd`).
- Como el item no existe, el test (L50-53) no puede inyectarle el precio, y la consulta devuelve 0.
- El check falla SIEMPRE, independientemente del estado de la economia. **El "loop compra roto"
  era un artefacto del test.**
- **Agravante (falso-verde):** con precio 0 la compra es gratis, y los checks `compra: saldo
  bajado` (`saldo <= 10000`) y `anti-arbitraje (saldo <= inicial)` pasan de forma trivial sin que
  el saldo se mueva. El test no valida el loop economico real.

El comentario "Fix M39" en `price_manager._precio_base_compra` sugeria que el bug se habia
arreglado; el bug nunca estuvo en PriceManager.

**Fix propuesto:** cambiar `OBJ-PLA-001` por un item_id existente (ej. `madera_roble`) en
test_loop_economico.gd, o crear el item `OBJ-PLA-001` en M159. Recomiendo lo segundo (ver BUG-046).

## BUG-046: catalogo M159 — 12 items con id interno discordante del nombre de archivo

- **Fecha de reporte:** 2026-09-18
- **Modelo:** Atria-Dawn-Preview
- **Plataforma:** Kilo Code
- **Reportado por:** agente (QA M38, Log 982)
- **Modulo:** M159 Catalogo-De-Objetos (data/items/)
- **Severidad:** Media (mantenimiento; causa raiz de BUG-028)
- **Estado:** [?] Delegado

### Sintoma

Doce archivos `.tres` de `data/items/` tienen un `id` interno cuya categoria NO coincide con el
prefijo del nombre del archivo:

| Archivo | id interno |
|---|---|
| item_obj_pla_001.tres | OBJ-CUA-007 |
| item_obj_ban_001.tres | OBJ-MES-007 |
| item_obj_cam_001.tres | OBJ-MES-009 |
| item_obj_cam_002.tres | OBJ-MES-010 |
| item_obj_est_001.tres | OBJ-MES-008 |
| item_obj_est_002.tres | OBJ-CUA-008 |
| item_obj_esp_001.tres | OBJ-CUA-003 |
| item_obj_esp_002.tres | OBJ-CUA-004 |
| item_obj_luz_001.tres | OBJ-CUA-006 |
| item_obj_rel_001.tres | OBJ-CUA-005 |
| item_obj_sil_001.tres | OBJ-MES-005 |
| item_obj_sil_002.tres | OBJ-MES-006 |

(Nota: el resto del catalogo — 99 archivos — SI coincide; los otros "discordantes" detectados en
el escaneo eran solo diferencias de mayusculas/guion_vs_guion_bajo, falsos positivos.)

### Impacto

- Cualquier referencia por nombre de archivo (convencion comun en tests y en scripts de otros
  modulos) resuelve un id distinto al esperado. BUG-028 es el caso concreto.
- Mantiene la ilusion de que `OBJ-PLA-001` existe (el archivo esta) cuando el id real es otro.

### Fix sugerido

Renombrar los `id` internos para coincidir con el stem del archivo, o renombrar los archivos.
Requiere verificacion de referencias cruzadas en todo `scripts/` y `data/` (grep por cada id).

## BUG-047: M38 — items solo-vendibles con precio_venta anulado (devuelve 0)

- **Fecha de reporte:** 2026-09-18
- **Modelo:** Atria-Dawn-Preview
- **Plataforma:** Kilo Code
- **Reportado por:** agente (QA M38, Log 982)
- **Modulo:** M38 Economia
- **Severidad:** Alta (contenido del juego inalcanzable)
- **Estado:** [?] Delegado (codigo dueño: M38 GLM-5.3/glm-5.3-flash — §21.4 lock)

### Sintoma

5 de las 15 entradas de `data/economy/econ_prices.tres` declaran `precio_compra = 0` con
`precio_venta > 0` (items no comprables, solo vendibles por el jugador). En runtime,
`precio_venta_vigente` devuelve **0** para todos ellos, anulando el precio declarado:

| item | precio_venta declarado en .tres | precio_venta en runtime |
|---|---|---|
| fragmento_ancestral | 75 | **0** |
| talisman_ancestral | 200 | **0** |
| pico_cobre | 60 | **0** |
| hacha_cobre | 55 | **0** |
| caja_almacenamiento | 40 | **0** |

### Causa raiz

`price_manager._precio_venta_base()` (price_manager.gd:161-164) deriva el precio de venta del de
compra (`TOPE_VENTA_SOBRE_COMPRA = 0.6`) y hace early return 0 cuando `precio_compra <= 0`,
ignorando el `precio_venta` del override del catalogo.

Doble confirmacion: `EconomyPriceCatalog._validate()` (economy_price_catalog.gd:49) tiene la
guarda `and e.precio_compra > 0`, por lo que el catalogo NO valida estos items (no detecta que su
precio_venta quedara sin aplicar).

### Agravante: el bug esta consagrado en los tests

`test_iter5_jkl` verifica `[OK] venta pico_cobre (0) < materiales (69)` — codifica el valor roto
(0) como expectativa. El check del anti-arbitraje crafting (J.151) pasa trivialmente (0 < 69
siempre) en lugar de validar la regla real (60 < 78).

### Pasos para reproducir

1. `godot --headless --path game/isla-ancestral --script res://scripts/economia/test_diag_m38_atria.gd`
2. Salida: `ref fragmento_ancestral -> compra=0 venta=0` (deberia ser venta=75).

### Fix propuesto

En `_precio_venta_base`, antes del early return por compra<=0, consultar el `precio_venta` del
override del catalogo y usarlo si es > 0. Requiere actualizar test_iter5_jkl (su check "venta
pico_cobre (0)" debe pasar a 60) y revisar J.151 con los valores reales.

## BUG-048: UI no compila en runtime (parse errors en theme_ux / dialog_layer)

- **Fecha de reporte:** 2026-09-18
- **Modelo:** Atria-Dawn-Preview
- **Plataforma:** Kilo Code
- **Reportado por:** agente (QA M38, Log 982 — hallazgo colateral)
- **Modulo:** M53 UI-UX / M145 (scripts/ui/)
- **Severidad:** Critica (la UI no carga en runtime)
- **Estado:** [?] Delegado (M53 esta 🔵 En curso por otro agente — §21.4 lock)

### Sintoma

En TODAS las ejecuciones headless del proyecto (cualquier test que carga el arbol de escenas):

```
SCRIPT ERROR: Parse Error: Expression is of type "Node" so it can't be of type "Tween".
   at: GDScript::reload (res://scripts/ui/theme/theme_ux.gd:168)
SCRIPT ERROR: Compile Error: Failed to compile depended scripts.
ERROR: Failed to load script "res://scripts/ui/theme/theme_service.gd" with error "Compilation failed".
SCRIPT ERROR: Invalid call. Nonexistent function 'new' in base 'GDScript'.
   at: _ready (res://scripts/ui/theme/theme_service.gd:18)
SCRIPT ERROR: Parse Error: Function "_on_node_entered" has the same name as a previously declared function.
   at: GDScript::reload (res://scripts/ui/layers/dialog_layer.gd:269)
ERROR: Failed to load script "res://scripts/ui/layers/dialog_layer.gd" with error "Parse error".
SCRIPT ERROR: Invalid call. Nonexistent function 'new' in base 'GDScript'.
   at: UIRoot._build_layers (res://scripts/ui/ui_root.gd:41)
```

### Impacto

- `ui_root.gd._build_layers` falla → **la UI del juego no se construye en runtime**.
- Aparece en cada arranque del juego y en cada test headless que carga `main_island.tscn`.
- Bloquea la verificacion visual del loop economico (ShopUI) y de cualquier flujo con dialogo.

### Por que no lo resuelve este agente

M53 UI-UX esta 🔵 En curso (otro agente, §21.4). El error es de parseo/compilacion de GDScript —
probablemente un rebase o edicion a mitad de un refactor de la capa theme/layers. Corresponde al
dueño de M53; si el estado 🔵 lleva mas de 24h sin actividad, otro agente puede reclamarlo.

## RESOLUCION BUG-048 — atria-dawn / Kilo Code (Log 983, 2026-09-18)

- **Modelo:** Atria-Dawn-Preview
- **Plataforma:** Kilo Code
- **Estado:** [x] RESUELTO

### Causa raiz

Dos problemas independientes:

1. **`scripts/ui/theme/theme_ux.gd:168`** — `for child in node.get_children(): if child is Tween:`.
   Godot 4.7 infiere el tipo estatico de `child` como `Node` (porque `get_children()` devuelve
   `Array[Node]`), y la comprobacion `child is Tween` da **parse error** porque Tween es
   RefCounted, no Node. Esto cascaba: theme_ux.gd no compilaba → theme_service.gd no podia
   resolver la clase `ThemeUx` → `ThemeUx.new()` fallaba con "Nonexistent function 'new' in base
   'GDScript'" → todo script que tocara el tema fallaba al cargar.

2. **`scripts/ui/layers/dialog_layer.gd:122` y `:269`** — la funcion `_on_node_entered` estaba
   **declarada dos veces** (merge/rebase mal resuelto). La de la linea 122 era la version antigua
   (asigna `_text_label.text = texto` directo, sin typing effect ni pausa de reloj); la de la 269
   es la completa (M53 D: pausa el reloj, opciones, `_iniciar_typing`).

### Solucion

- `theme_ux.gd`: iterar por indice con tipado `Variant` explicito
  (`var child: Variant = node.get_child(i)`) — evita la inferencia de Node y deja la
  comprobacion `is` para runtime.
- `dialog_layer.gd`: eliminada la version duplicada de la linea 122 (con comentario explicativo);
  se conserva la version completa de la seccion "M53 D".

### Verificacion

Re-ejecucion headless (Godot 4.7.2, binario real) con `test_loop_economico.gd` (carga el arbol
completo con `main_island.tscn`):

- ANTES: `SCRIPT ERROR: Parse Error ... theme_ux.gd:168` +
  `theme_service.gd` "Compilation failed" + `dialog_layer.gd:269` funcion duplicada +
  `ui_root.gd:41` "Nonexistent function 'new'" → la UI NO se construcia.
- DESPUES: 0 errores de parseo; `[DOM-UI] UIRoot: capas montadas (dialogo=true pausa=true
  menus=true confirm=true crafting=true inventario=true tienda=true equipamiento=true diario=true
  carga=true)` — la UI se monta completa.

test_loop_economico sigue dando 14 checks / 1 fallo (BUG-028, no relacionado con este fix — es
de M38/M159, sigue delegado).

### Archivos modificados

- `game/isla-ancestral/scripts/ui/theme/theme_ux.gd` (func `_get_all_tweens`)
- `game/isla-ancestral/scripts/ui/layers/dialog_layer.gd` (func duplicada eliminada)
---

## BUG-049: `reservar_log.py` CIEGO a los numeros de 1, 2 y 4+ digitos (98 logs invisibles)

- **Fecha de reporte:** 2026-09-18 03:30
- **Modulo(s) afectado(s):** Transversal — `scripts/reservar_log.py` (guardian de reservas de `Logs/`)
- **Severidad:** 🟠 Mayor
- **Prioridad sugerida:** Alta
- **Estado:** [x] Resuelto

**Descripcion del problema:**
Los dos regex del guardian exigian **exactamente 3 digitos**:

```python
RE_LOG = re.compile(r'^(\d{3})-.*\.md$')
RE_RES = re.compile(r'^(\d{3})-.*\.txt$')
```

Con el protocolo v3 (`Logs/NUMEROS_DISPONIBLES.txt` = **1000-1500**) **todo log nuevo tiene 4
digitos**, asi que a partir de 1000 el guardian queda ciego. Y no era solo el futuro: tambien
quedaban fuera los logs de **1 y 2 digitos** que ya existian en `Logs/`.

**Pasos para reproducir:**
1. `python scripts/reservar_log.py --estado` → informa `reservas/*.txt : 0`.
2. `ls Logs/reservas/` → hay `1000-atria-dawn-M13-QA.txt`.
3. Contar `Logs/*.md` aplicando cada regex por separado.

**Comportamiento esperado:**
`--estado` debe ver TODOS los logs y TODAS las reservas, y detectar `RESERVA DOBLE` / `COLISION`
para cualquier numero, no solo para los de 3 digitos.

**Comportamiento actual (medido, Log 986):**

```
--estado  ANTES :  Logs/*.md : 860 numeros     reservas/*.txt : 0
--estado  DESPUES: Logs/*.md : 958 numeros     reservas/*.txt : 1
```

→ **98 logs** y **1 reserva** eran invisibles al guardian. `RESERVA DOBLE` y `COLISION` no se
evaluaban para ninguno de esos numeros: el script parecia sano (`Sin conflictos de numeracion`)
mientras no miraba casi una decima parte de `Logs/`.

**Entorno / Contexto:**
- Plataforma: PC (Windows), Python 3.13
- Ocurre desde: creacion del script (Log 975, commit `c5f588d`)
- Frecuencia: Siempre

**Evidencia:**
- `Logs/reservas/1000-atria-dawn-M13-QA.txt` existia y `--estado` informaba `reservas/*.txt : 0`.
- Conteo directo por regex: `\d{3}` → **860** archivos; `\d+` → **958** archivos.
- Con el fix, `--estado` sigue dando **0 conflictos** (no hay colisiones reales hoy), pero ahora las
  mira todas.

**Intentos de solucion ya probados (si aplica):**
- Se detecto al verificar el cierre del ciclo de M127 (no por un test, sino por **desconfiar de un
  "0"**: `reservas/*.txt : 0` contradecia un `ls` que mostraba un archivo).

**Referencias cruzadas:**
- Guia 07 §8: no
- Modulo/documentacion relacionada: trampa **72** del skill `isla-ancestral-ciclo-modulo`;
  `.workbuddy-ai/memory/MEMORY.md` §Reglas duras ("Reservar log = `reservar_log.py`").

**Firma:**
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-18 03:30

**Resolucion (completar cuando se resuelva):**
- [→] Como se corrigio: `scripts/reservar_log.py` — los dos regex pasan a `^(\d+)-.*\.(md|txt)$`,
  con un comentario que explica por que `\d{3}` era el bug (para que nadie lo "optimice" de vuelta).
- [→] Archivos/commits modificados: `scripts/reservar_log.py` (2 regex + 5 lineas de comentario).
- [x] Log del proyecto: **Log 986** (M127 iter. 3) — hallado en la verificacion final del ciclo.
- [x] Verificado por: el autor, **por medicion** (`--estado` 860 → 958; `reservas` 0 → 1) y
  confirmando que con el fix el veredicto sigue siendo `Sin conflictos de numeracion`.

**Hallazgo relacionado — NO corregido (decision de protocolo, no unilateral):**
`--reservar` sigue asignando `max(ULTIMO_NUMERO, Logs/*.md, reservas/*.txt) + 1` y **no toca**
`Logs/NUMEROS_DISPONIBLES.txt`. Con el fix, `siguiente_libre()` devuelve **1001** (porque atria
reservo 1000) — y **1001 sigue listado** en `NUMEROS_DISPONIBLES.txt`. Un agente que siga el
protocolo v3 tomaria 1001 del archivo, y otro que use `--reservar` tambien: **colision**. Integrar
`--reservar` con la lista v3 es una decision de protocolo → se **reporta**, no se rediseña solo.

## BUG-050: M39 Tiendas — `catalogo_tiendas.gd` llama `.size()` a un Callable (SCRIPT ERROR al boot) + catálogo M39 referencia item M15 inexistente `piedra_caliza`

> ⚠️ **CORREGIDO por atria-dawn (2026-09-18, Log 1039):** la atribución del `.size()` sobre Callable
> es **ERRÓNEA** — el error está en `test_logros.gd:291` (M72), no en `catalogo_tiendas.gd:63`.
> Ver **BUG-055**. La parte de `piedra_caliza` SÍ es real, pero es 1 de **13 referencias rotas**
> (ver **BUG-054**).

- **Fecha de reporte:** 2026-09-18 19:15
- **Modulo(s) afectado(s):** M39 Tiendas (`scripts/shops/catalogo_tiendas.gd`), M15 Items (`piedra_caliza`)
- **Severidad:** 🟠 Mayor (emite `SCRIPT ERROR` en **todo** boot de autoloads; contamina cada run headless)
- **Prioridad sugerida:** Media-Alta
- **Estado:** [?] Delegado (dueño M39, en curso por glm — no lo corrijo para no pisar su trabajo)

**Descripción del problema:**
Al bootear el proyecto (cualquier test `--headless` que levante autoloads) se emite:
```
SCRIPT ERROR: Invalid call. Nonexistent function 'size' in base 'Callable'.
   at: push_warning (core/variant/variant_utility.cpp)
   GDScript backtrace (most recent call first):
       [0] _validar_tienda (res://scripts/shops/catalogo_tiendas.gd:63)
       [1] _registrar_validada (res://scripts/shops/catalogo_tiendas.gd:68)
       [2] _registrar_tienda_general (res://scripts/shops/catalogo_tiendas.gd:116)
       [3] _registrar_tiendas_oficiales (res://scripts/shops/catalogo_tiendas.gd:26)
       [4] _ready (res://scripts/shops/catalogo_tiendas.gd:19)
```
Además: `WARNING: [M39] 'tienda_general': item_id inexistente en M15: piedra_caliza` — el catálogo M39
referencia un `item_id` que no existe en el catálogo de M15.

**Lectura (agnés, sin corregir):** `catalogo_tiendas.gd:63` llama `.size()` sobre algo que en runtime
es un **Callable** (no un Array) → `Callable.size()` no existe. Probablemente una lista de validadores
/ campos quedó como Callable (o una señal) y se itera con `.size()`. Y `piedra_caliza` es un `item_id`
huérfano (M15 no lo define) → el validador de tienda lo reporta.

**Pasos para reproducir:**
1. `godot --headless --path game/isla-ancestral --script res://scripts/logros/test_logros.gd` (cualquier
   test que bootee autoloads).
2. Ver el `SCRIPT ERROR` de `catalogo_tiendas.gd:63` + el warning de `piedra_caliza`.

**Causa probable (hipótesis para glm):** en `_validar_tienda` (línea 63) se itera una colección de
validadores/campos que quedó como `Callable` (o una señal) y se usa `.size()` sobre ella; y el catálogo
M39 trae `piedra_caliza` sin contraparte en M15.

**Referencias cruzadas:** detectado durante la verificación de M72 Logros (Log 1021, agnes-3-flash).
El core de M72 es inexistente para este bug (afecta a M39/M15).

**Firma:**
**Modelo:** agnes-3-flash (Sapiens AI)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-18 19:15

**Delegación:** [?] **M39 (glm-5.3-flash, en curso)** — es su módulo y su código. Corregir el
`catalogo_tiendas.gd:63` (`.size()` sobre Callable) y reconciliar `piedra_caliza` con el catálogo M15
(o removerlo). Verificado por el verificador §21.8.

---

### CORRECCIÓN DE ATRIBUCIÓN (atria-dawn, 2026-09-18, Log 1039) — BUG-055

**El SCRIPT ERROR `.size()` sobre Callable NO está en `catalogo_tiendas.gd:63`.** Reproducido con
binario real (Godot 4.7.2 headless, `--script res://scripts/logros/test_logros.gd`):

```
SCRIPT ERROR: Invalid call. Nonexistent function 'size' in base 'Callable'.
   at: _test_guardado_carga_rf9_rn8 (res://scripts/logros/test_logros.gd:291)
   GDScript backtrace (most recent call first):
       [0] _test_guardado_carga_rf9_rn8 (res://scripts/logros/test_logros.gd:291)
       [1] _run (res://scripts/logros/test_logros.gd:48)
```

- `catalogo_tiendas.gd:63` (la línea del backtrace de agnes) ejecuta `push_warning(...)` y funciona
  correctamente: emite 11 warnings de items inexistentes y **no** genera SCRIPT ERROR. El backtrace
  reportado por agnes mezcló dos bloques de output adyacentes (el warning con el error de otro test).
- La causa real: `test_logros.gd:291` hace `_ach.desbloqueados.size()`, pero `AchievementService`
  (`scripts/logros/achievement_service.gd`) declara la variable como **`_desbloqueados`** (privada,
  línea 44) con accessor público `get_desbloqueados()` (línea 352). El nombre sin guion resuelve a un
  Callable (resolución dinámica de Godot sobre `Node`) → `.size()` falla.
- **Fix propuesto:** `var before: int = _ach.get_desbloqueados().size()`.
- **Delegación:** [?] **M72** (agnes-3-flash, Log 1021) — es su test. Ver BUG-055.
- **Lo que SÍ es real de BUG-050:** `piedra_caliza` es un item_id huérfano en M15 — pero es solo 1 de
  **13 referencias rotas** (ver BUG-054). Y el warning de la línea 63 funciona, no es un error.

---

## BUG-051 — CI: el job `godot-lint` es un no-op completo (lint de GDScript inefectivo)

**Estado:** [?] Delegado
**Modulo:** M111 (Codigo de Calidad) / M83 (CI de licencias)
**Severidad:** Media

### Pasos para reproducir

1. Abrir `.github/workflows/quality.yml`.
2. Ver el job `godot-lint` (lineas 10-34), paso "Check for Godot parser errors".
3. La linea 33 contiene: `godot --headless --script 2>&1 || true`

### Causa

El comando `--script` **no tiene ningun script**. Godot falla con error de uso y el
`|| true` lo silencia. El paso **nunca valida nada** y el job `godot-lint` **nunca puede
fallar**. La linea 28 (`code_quality_check.gd`) tambien lleva `|| true`.

### Evidencia

- `.github/workflows/quality.yml:33` (sin script).
- Log 1027 (atria-dawn, 2026-09-18) seccion 5.

### Contexto

Descubierto durante el re-QA de M126 al auditar los 52 gates del workflow. Los 9 gates
sin `|| FAIL=1` SI son duros (GH Actions usa `set -e` por defecto), pero este job es la
excepcion real: es un no-op disfrazado de gate de lint.

**Firma:**
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-18 21:07

**Delegación original:** [?] **M111/M83** — decidir que script de lint debe ejecutar el paso
(`scripts/editor/code_quality_check.gd` en `|| true` de la linea 28 es el candidato
natural) y remover el `|| true` para que el gate sea real.

---

### RESOLUCIÓN BUG-051 (atria-dawn, 2026-09-18, Log 1039) — [x] CERRADO

**No delegado: cerrado directamente** (mi especialidad: tooling/CI + verificación).

**Mecanismo del gate real** (3 piezas nuevas):

1. **`tools/quality/gen_colector_sintaxis.py`** — genera `scripts/editor/_colector_sintaxis.gd`:
   un `extends SceneTree` con un `const _gN := preload("res://...")` por **cada** .gd del proyecto
   (excluye `.godot/`, `addons/` terceros —gdUnit4/zylann.voxel—, `Godot/` y al propio colector).
   Como `preload` fuerza el parseo en tiempo de compilación, basta un `--check-only` sobre el
   colector para validar los 830 scripts en una pasada.
2. **`--import`** antes del check: en un checkout limpio (sin `.godot`), `--check-only` no resuelve
   `class_name`s entre archivos y emite ~19 falsos positivos. `godot --headless --import` construye
   la caché y el check queda limpio. **Verificado empíricamente**: fresh+import → EXIT 0; fresh sin
   import → EXIT 1 falso positivo.
3. **`|| FAIL=1`** en el paso "Check for Godot parser errors" de `.github/workflows/quality.yml`
   (job `godot-lint`) + paso `Setup Python` + `Generate syntax collector` + `Import project
   resources`. El job `godot-lint` ahora SIRVE.

**También se retiró el paso "Run GDScript Linter"** (ejecutaba
`scripts/editor/code_quality_check.gd`, un `@tool extends EditorScript`, vía `--script` con
`|| true`): no puede correr headless (requiere el editor) y era un segundo no-op silencioso. El
job `code-quality-script` ya cubre ese script (también con `|| true`; su conversión a gate duro es
decisión de M111/M107 — la QA de M111 Log 1032 documentó que su exit 1 es preexistente de
`backup_manager`/M107 + 68 leaks ObjectDB).

**Verificación del gate (binario real, Godot 4.7.2):**

| Escenario | Salida |
|---|---|
| Árbol limpio (830 scripts) | **EXIT 0** |
| Error de sintaxis inyectado (`func` anidado) | **EXIT 1** — nombra `res://scripts/editor/_test_sintaxis_roto.gd` |
| Checkout fresco + `--import` | **EXIT 0** |

**Hallazgo colateral (BUG-056):** el gate recién creado encontró **7 scripts que no compilaban**
en el repo (Python-ismos + indentación). Resueltos en el mismo log (ver §7).

**Anti-falso-verde descartado durante la investigación** (documentado para que nadie lo repita):
- `GDScript.new() + reload()` aislado → 487 falsos positivos (dependencias no resueltas).
- `load()` devuelve el script roto (no null) con 0 métodos compilados — no sirve como señal.
- `reload()` sobre scripts ya cargados devuelve `ERR_ALREADY_IN_USE` (22) — no es fallo de compile.
- `.new()` sobre un script roto cuelga/aborta el proceso.
- `get_script_method_list()` devuelve 0 para scripts válidos nunca instanciados (build_info.gd).
- `--check-only` SIN `--script` **ejecuta el juego** (el flag se ignora) — era ese el comportamiento
  que hacía parecer que "validaba y pasaba".

**Firma de resolución:**
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-18 (Log 1039)

---

### BUG-054 — M39↔M15: 13 referencias rotas (8 item_ids inexistentes) en las tiendas oficiales

- **Fecha de reporte:** 2026-09-18
- **Módulo(s) afectado(s):** M39 Tiendas (`scripts/shops/catalogo_tiendas.gd`), M15 Recursos
  (`data/items/*.tres` → `ItemDatabase`)
- **Severidad:** 🟠 Mayor (las 3 tiendas oficiales referencian items que NO existen — toda compra
  fallaría en runtime)
- **Prioridad sugerida:** Alta
- **Estado:** [?] Delegado — dueño **M39 (glm-5.3-flash, reserva Log 1004, activo)**. No lo corrijo:
  el archivo tiene cambios sin commit y glm está trabajando sobre él.

**Descripción (corrección de mi Log 1026):** mi Log 1026 decía "13 items inexistentes". La cifra
exacta: **13 referencias (shop, item) rotas, que corresponden a 8 item_ids únicos** inexistentes en
M15. M15 define 111 items (bloques: `wood`, `stone`, `planks`... + ids `OBJ-*`); NINGUNO de los 8
ids usados por M39 existe.

**Las 13 referencias rotas (validadas con script sobre los 111 .tres de M15):**

| Tienda | item_ids inexistentes |
|---|---|
| `tienda_general` | `madera_roble`, `piedra_caliza`, `baya_roja`, `fibra_algodon`, `mineral_cobre`, `pergamino_rec_tela_lino` (venta) + `fragmento_ancestral` (recompra) |
| `herreria` | `herramienta_basica`, `mineral_cobre`, `piedra_caliza` |
| `mercader_viajero` | `fragmento_ancestral`, `baya_roja`, `mineral_cobre`, `madera_roble` |

**Causa raíz:** M39 se escribió con ids en español (`madera_roble`, `piedra_caliza`...) que nunca
tuvieron contraparte en el catálogo M15/M159 (que usa `OBJ-*` y nombres de bloques en inglés). El
validador de glm (Log 1004) solo avisa —no bloquea— y ademas **solo valida `catalogo_venta`, no
`catalogo_recompra`** (gap adicional: las recompras rotas no se detectan en absoluto).

**Evidencia:** boot headless emite 11 warnings `[M39] '<tienda>': item_id inexistente en M15: <id>`
(11 = entradas de `catalogo_venta`; las recompras no se validan). Confirmado leyendo
`catalogo_tiendas.gd:59-63` y los 111 `.tres` de `data/items/`.

**Orden de autoloads (importante para el fix):** `project.godot` carga `ItemDatabase` (línea 33)
**antes** que `CatalogoTiendas` (línea 66). El comentario de glm en `catalogo_tiendas.gd:34-35`
("el orden de autoloads no garantiza el DB en el boot") es **incorrecto** — el DB sí está
disponible, así que la validación podría ser DURA (bloquear el boot) en vez de warning.

**Fix propuesto para M39:**
1. Mapear los 8 ids a los reales de M15 (o crear los `.tres` faltantes en M15 si el diseño los
   necesita — `fragmento_ancestral` ya aparece en M38 `econ_prices.tres`, ver BUG-047).
2. Extender `_validar_tienda` para validar también `catalogo_recompra` (mismo loop).
3. Considerar promover el check a error (el orden de autoloads lo permite).

**Sub-hallazgo `mercader_viajero` (NO es bug):** mi Log 1026 flaggeó "mercader_viajero sin
`npc_duenio_id` (relación M19 rota)". Verificación: **es una excepción de diseño explícita y
validada**. `catalogo_tiendas.gd:138` pasa `npc_id=""` y `_validar_tienda` lo permite solo para
`MERCADER_VIAJERO` (línea 43), exigiendo en cambio `dias_aparicion_mercader > 0` (línea 45; el
mercader define 3). El comentario del archivo (líneas 33-34) lo documenta. Conclusión: la relación
M19 no aplica al mercader rodante — **cerrado como no-bug**.

**Firma:**
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-18

---

### BUG-055 — `test_logros.gd:291` llama `.size()` sobre Callable (corrección de BUG-050)

- **Fecha de reporte:** 2026-09-18
- **Módulo(s) afectado(s):** M72 Logros (`scripts/logros/test_logros.gd:291`)
- **Severidad:** 🟡 Menor (no afecta al juego; ensucia toda corrida headless con 1 SCRIPT ERROR)
- **Prioridad sugerida:** Media
- **Estado:** [?] Delegado — dueño **M72 (agnes-3-flash, Log 1021)**.

**Descripción:** ver "CORRECCIÓN DE ATRIBUCIÓN" en la entrada de BUG-055 arriba (sección 6, junto a
BUG-050). Resumen: `_ach.desbloqueados` no existe (es `_desbloqueados`, privado; el accessor público
es `get_desbloqueados()`). Godot resuelve el nombre dinámico a un Callable → `.size()` falla.

**Fix propuesto:** `var before: int = _ach.get_desbloqueados().size()`.

**Firma:**
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-18

---

### BUG-057 — `buildings_save_provider.gd` no restaura estructuras al cargar (no-op silencioso)

- **Fecha de reporte:** 2026-09-18
- **Módulo(s) afectado(s):** M17 Construcción (no implementado), M59 Guardado
  (`scripts/datos/buildings_save_provider.gd:58-67`), M60 (EstructurasCodec)
- **Severidad:** 🟡 Menor (el guardado funciona; el restore es incompleto **por diseño**)
- **Prioridad sugerida:** Baja (bloqueada por M17)
- **Estado:** [?] Delegado — dueño **M17/M59**. No es accionable hasta que M17 exista.

**Descripción:** `restore_save_data()` busca por duck-typing un autoload/nodo que exponga
`obtener_estructuras()` + `restaurar_estructuras()`. Como M17 (Construcción) no está implementado
(11/175 en CHECKLIST-GLOBAL), `fuente()` devuelve `null` y el restore retorna en la línea 62
**sin restaurar nada ni avisar**. Resultado: la sección "buildings" del save se escribe pero
siempre se carga vacía.

**Confirmación por código** (`buildings_save_provider.gd:58-67`):
```gdscript
func restore_save_data(data: Dictionary) -> void:
	var lista := EstructurasCodec.desde_seccion(data)
	var f := fuente()
	if f == null:
		return                      # ← silent no-op; `lista` se descarta
	if not f.has_method(METODO_RESTAURAR):
		push_warning(...)           # ← este aviso SÍ existe, pero solo si hay fuente
		return
	f.call(METODO_RESTAURAR, lista)
```

**No es un bug de M60:** el propio header del archivo (líneas 14-16) documenta que el restore es
no-op "Así el guardado funciona desde hoy y M17 se enchufa sin tocar M60". Es una decisión de
diseño explícita y honesta. Se registra para que M17 sepa que **debe** exponer
`restaurar_estructuras(lista)` al implementarse, y para que M59/M60 tengan el seguimiento.

**Fix (cuando M17 exista):** implementar `obtener_estructuras()` y `restaurar_estructuras()`
en el autoload de M17; el provider los encuentra solo por duck-typing.

**Firma:**
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-18

---

## RESOLUCION BUG-042 — DeepSeek-V4.1-Flash / WorkBuddy (Log 1024, 2026-09-19)

**Estado:** `[x] Resuelto`. La descarga corrupta se reemplazo por los binarios reales y la clase de
fallo quedo **gateada**: no puede volver a pasar en silencio.

### Origen del defecto (rastreado hasta el commit)

Los tres `.ttf` falsos entraron en el repo el **2026-08-30** en el commit `dd101d9` ("Se corrigió
carga de fuentes TTF en tema UI (§9.48)"), que los agrego con **514 lineas de HTML cada uno** y cuyo
mensaje afirma *"0 errores FreeType en runtime"*. Ese mismo lote agrego `Nunito-Variable.ttf` **como
binario** (276.932 B): de las cuatro descargas, una salio bien y las otras tres guardaron la
respuesta 404 de GitHub con extension `.ttf`. El defecto vivio **19 dias** sin que ningun test se
pusiera en rojo — incluido el suite de M88, porque `test_fonts_m88.gd` prueba el **catalogo** (ids,
familias, licencias) y **nunca carga un archivo de fuente**. Falso verde estructural: el test no
tocaba la capa donde estaba el bug.

### Que se cambio

1. **Los 3 binarios ahora son fuentes reales.** Nunito Regular/Bold (instancias estaticas
   `wght=400/700` derivadas con `fontTools` de `google/fonts/ofl/nunito/Nunito[wght].ttf`) y Fredoka
   One Regular (`google/fonts@be2838a2/ofl/fredokaone/FredokaOne-Regular.ttf`). Ambas familias ya
   estaban declaradas con licencia **SIL OFL 1.1** en `ASSETS-LICENSE.md` (A003/A004) y
   `THIRD-PARTY-NOTICES.md`: no hubo decision de licencia nueva.

   - El origen elegido quedo **validado por el propio repo**: la `Nunito-Variable.ttf` que ya estaba
     en `assets/fonts/` es **byte-identica** (`sha256 bb55a5ca…`) al upstream canonico.
   - Cobertura medida: **938 glifos** por instancia de Nunito (tildes, `ñ/Ñ`, `¡¿`, cirilico);
     Fredoka One 228.
   - `sha256` **antes** (HTML 404): `FredokaOne 14c7df8d…` · `Nunito-Bold 1a242bd0…` ·
     `Nunito-Regular 7be2e0e2…`. **Despues** (TrueType `00010000`): `58faf312…` · `d6e5eb78…` ·
     `e81d084d…`.

2. **Guarda en produccion** (`game/isla-ancestral/scripts/ui/theme/theme_ux.gd::_try_load_font`).
   El cargador hacia `if err == OK: return font_file`, y `load_dynamic_font()` **devuelve OK sobre
   una pagina HTML**. Ahora exige que la fuente **mida**: si `get_string_size("A", …, 16).x <= 0`
   avisa y cae a la fuente de reserva. Es la diferencia entre "el asset de hoy esta bien" y "un
   asset malo manana no puede pasar desapercibido".

3. **Gate de CI nuevo** (job `binary-guard` en `quality.yml`). `scripts/verificar_binarios.py` lee
   los **bytes magicos** de los binarios **versionados** (`git ls-files`) y los compara con lo que su
   extension promete: 1.107 archivos, 28 extensiones. Detecta el caso "texto disfrazado"
   (HTML/XML/JSON/404) y exige **AND dentro de cada firma** — si no, un WAV con extension `.webp`
   pasaria, porque los dos empiezan con `RIFF` y solo difieren en los bytes 8-11 (bug real que
   encontro la sonda, no una hipotesis).

4. **Dos sondas.** `scripts/test_verificar_binarios.py` (57 checks, con prueba por inyeccion de la
   tabla de firmas) y `game/isla-ancestral/scripts/fonts/test_fuentes_binarias_bug042.gd`
   (**22 checks ×3, 0 `SCRIPT ERROR`**), esta ultima cableada en el job `test-suite` y probada
   **sin cache de importacion** para que funcione en un checkout limpio de CI.

### El modo de fallo, medido en cada corrida (no citado)

```
load_dynamic_font("user://…ttf_que_es_html")  ->  err = 0 (OK)   ancho = 0.0 px
fuente real                                    ->  "Jugar"@16 px = 38.0 px
```

**`err == OK` y la referencia no nula no prueban nada: solo la medicion prueba.** El bloque G
comprueba que `theme_ux._try_load_font` **rechaza** el falso y devuelve la reserva. Y la sonda esta
**probada por inyeccion**: revirtiendo la guarda al `err == OK` original, el bloque G falla con
`devolvio ():<FontFile#…> en vez de la reserva` (verificado; archivo restaurado y comprobado por
`sha256`).

### Hallazgo lateral (no tocado)

`game/isla-ancestral/data/fonts/fonts.json` (M88) declara **4 fuentes placeholder**
(`museo_moderno`, `texto_cozy`, `script_isla`, `mono_debug`) con `tiene_archivo: false`, que **no
corresponden** a los archivos reales de `assets/fonts/` (Nunito / Fredoka One). La metadata es
honesta respecto de si misma, pero **el catalogo y los archivos no describen lo mismo**. No se toco:
es diseño de M88 y `test_fonts_m88.gd` fija el contenido actual (`museo_moderno` con licencia
`OFL`). Queda para su dueño.

### Reportado, NO parcheado

El guard encontro ademas **3 `.png` que no son PNG** (1 JPEG, 2 WebP) bajo `tools/mcp/*/capturas/`,
**untracked y gitignoreados** (capturas locales de MCP, no assets del repo). Por eso el gate audita
los **versionados** y no el arbol completo: un PNG mal etiquetado en un directorio ignorado no debe
tumbar la puerta.

### Referencias cruzadas

`Logs/1024-Bug042-Fuentes-Reales-Gate-Binarios_2026-09-19_21-54-56.md` ·
`scripts/verificar_binarios.py` · `scripts/test_verificar_binarios.py` ·
`game/isla-ancestral/scripts/fonts/test_fuentes_binarias_bug042.gd` ·
`game/isla-ancestral/scripts/ui/theme/theme_ux.gd` · `.github/workflows/quality.yml` (job
`binary-guard`) · `ASSETS-LICENSE.md` (A003/A004) · `Mensajes entre modelos/ESTADO-PARALELO.md`.

**Firma:**
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-19

### BUG-063 — M69 Fast-Travel: `**Totales:**` declara 143/143 completado (claim de cierre falso)

- **Fecha de reporte:** 2026-09-19 22:47
- **Módulo(s) afectado(s):** M69 Fast-Travel — documentación (`plan-actual/05-Checklist.md`)
- **Severidad:** 🟠 Mayor
- **Prioridad sugerida:** Media
- **Estado:** [x] Resuelto (parche de documentación; sin impacto en runtime)

**Descripción del problema:**

La línea `**Totales:**` de `DOCUMENTACION/69-Fast-Travel/plan-actual/05-Checklist.md`
decía textualmente:

> `**Totales:** 143 ítems · Completados: 143 · Pendientes: 0 · No resueltos: 0.`

Es un **claim de cierre total del módulo**. El conteo real de marcas en el mismo
archivo es **18 `[x]` / 130 `[ ]` / 2 `[?]` = 150 ítems** (no 143). El módulo está 🟡
con 18/150 en CHECKLIST-GLOBAL, que sí reflejaba el número correcto; **solo la
documentación local mentía**.

El impacto real es de coordinación: cualquier agente (o el usuario) que abra el
checklist de M69 lee "módulo completo, 0 pendientes" y puede tomar decisiones
equivocadas — p. ej. no reclamarlo creyéndolo cerrado, o listarlo como dependencia
satisfecha. Es el mismo modo de fallo de los sobre-cierres que BUG-059 (M126/M128),
pero acá el claim no venía de marcas infladas sino de **una sola línea de resumen
desconectada de la realidad del archivo**.

**Pasos para reproducir:**
1. Abrir `DOCUMENTACION/69-Fast-Travel/plan-actual/05-Checklist.md`.
2. Leer la línea 194 (antes de la corrección): "Completados: 143 · Pendientes: 0".
3. Contar las marcas: 18 `[x]`, 130 `[ ]`, 2 `[?]`.

**Comportamiento esperado:** la línea de Totales debe coincidir con el conteo de
marcas del archivo (regla de drift de la sección 21.3 / DoD 21.6).

**Comportamiento actual (antes del fix):** la línea declaraba 100% de completitud
sobre un archivo con 18/150 reales.

**Evidencia:**
- Conteo con regex anclado a línea sobre el archivo pre-fix: `(?m)^\s*[-*] \[x\]` → 18;
  `\[ \]` → 130; `\[\?\]` → 2.
- Autor original del claim: **Nemotron 3.5 Lightning / Cline** (firma L1-L2 del
  archivo). El barrido histórico (Log 1093, §7) ya había registrado que Nemotron 3.5
  Lightning escribió 4 plan-iniciales **sin ningún log de respaldo** — M69 figura
  entre ellos. La leyenda de marcadores del propio archivo (L6) también está rota:
  dice "[ ] cumplido · [ ] pendiente" en vez de "[x] cumplido", síntoma de que el
  autor nunca llegó a usar `[x]` de forma consistente.
- CHECKLIST-GLOBAL fila 69: `🟡 Con dudas | 18/150` — correcto, no requiere cambios.

**Causa raíz:** el autor escribió la línea de resumen declarando el diseño cerrado
(consistente con la nota de L195: "diseño, mapa y reglas cierran aquí") sin que las
marcas del archivo reflejaran eso — muy probablemente la línea se redactó antes de
empezar a marcar y nunca se reconcilió.

**Intentos de solución ya probados (si aplica):** n/a — detectado en la primera pasada
del barrido de drift.

**Referencias cruzadas:**
- Guía 07 §8: no (no es un error de Godot).
- Relacionado: BUG-059 (claims falsos en M126/M128), BUG-061/BUG-062 (sobre-cierres
  verificados por este mismo modelo en Logs 1083/1085), Log 1093 §7 (Nemotron 3.5
  Lightning sin logs).
- Log del descubrimiento y corrección: `Logs/1104-drift-totales-lote4_2026-09-19_22-50-33.md` (lote 4 del barrido de drift).

**Firma:**
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-19 22:47

**Resolución:**
- [x] Cómo se corrigió: se reescribió la línea 194 de
  `DOCUMENTACION/69-Fast-Travel/plan-actual/05-Checklist.md` al formato canónico
  (`**Totales:** 150 ítems · Completados: 18 · Pendientes: 130 · No resueltos: 2.`)
  con una nota de auditoría firmada que documenta el claim original y el conteo real.
  **Las marcas `[x]`/`[ ]`/`[?]` no se tocaron** (regla del barrido: solo se corrige
  la línea Totales).
- [x] Archivos modificados: `DOCUMENTACION/69-Fast-Travel/plan-actual/05-Checklist.md`
  (1 línea reescrita + nota). Sin commit (push negativo por directiva del usuario).
- [x] Log del proyecto: 1099 (lote 4 del barrido de drift).
- [x] Verificado por: conteo post-fix re-ejecutado sobre el archivo — 18/130/2 = 150,
  consistente con CHECKLIST-GLOBAL y con la nueva línea.
---


### BUG-064 — M156 Terrenos-Y-Movimiento: `**Totales:**` declara 299/299 completado (claim de cierre falso)

- **Fecha de reporte:** 2026-09-19 22:59
- **Módulo(s) afectado(s):** M156 Terrenos-Y-Movimiento — documentación (`plan-actual/05-Checklist.md`)
- **Severidad:** 🟠 Mayor
- **Prioridad sugerida:** Media
- **Estado:** [x] Resuelto (parche de documentación; sin impacto en runtime)

**Descripción del problema:**

La línea `**Totales:**` de `DOCUMENTACION/156-Terrenos-Y-Movimiento/plan-actual/05-Checklist.md`
decía textualmente:

> `**Totales:** 299 items - Completados: 299 - Pendientes: 0`

Es un **claim de cierre total del módulo**. El conteo real de marcas en el mismo
archivo es **206 `[x]` / 99 `[ ]` / 2 `[?]` = 307 ítems** (no 299). El módulo está 🟡
con 206/307 en CHECKLIST-GLOBAL, que sí reflejaba el número correcto; **solo la
documentación local mentía**.

Mismo modo de fallo que BUG-063 (M69): una línea de resumen que declara 100% de
completitud sobre un archivo con 67% real. Cualquier agente que abriera el checklist
leía "módulo completo, 0 pendientes" y podía tomar decisiones equivocadas — no
reclamarlo creyéndolo cerrado, o listarlo como dependencia satisfecha de M08/M09/M10.

**Pasos para reproducir:**
1. Abrir `DOCUMENTACION/156-Terrenos-Y-Movimiento/plan-actual/05-Checklist.md`.
2. Leer la línea 384 (antes de la corrección): "Completados: 299 - Pendientes: 0".
3. Contar las marcas: 206 `[x]`, 99 `[ ]`, 2 `[?]`.

**Comportamiento esperado:** la línea de Totales debe coincidir con el conteo de
marcas del archivo (regla de drift de la sección 21.3 / DoD 21.6).

**Comportamiento actual (antes del fix):** la línea declaraba 100% de completitud
sobre un archivo con 206/307 reales.

**Evidencia:**
- Conteo con regex anclado a línea sobre el archivo pre-fix: `(?m)^\s*[-*] \[x\]` → 206;
  `\[ \]` → 99; `\[\?\]` → 2.
- CHECKLIST-GLOBAL fila 156: `🟡 Con dudas | 206/307` — correcto, no requiere cambios.
- El módulo tiene actividad reciente de glm-5.3-flash (iteraciones de terreno); el
  claim probablemente quedó de una iteración en la que el checklist era más chico y
  estaba completamente marcado, y nunca se reconcilió tras agregar ítems nuevos.

**Causa raíz:** la línea de resumen no se reconcilió tras agregar ítems al checklist
(299 → 307) ni tras dejar ítems pendientes. Misma clase de descuido que BUG-063.

**Intentos de solución ya probados (si aplica):** n/a — detectado en la primera pasada
del barrido de drift.

**Referencias cruzadas:**
- Guía 07 §8: no (no es un error de Godot).
- Relacionado: **BUG-063** (M69, claim idéntico "Pendientes: 0" falso), BUG-059
  (claims falsos M126/M128), BUG-061/BUG-062 (sobre-cierres, Logs 1083/1085).
- Log del descubrimiento y corrección: `Logs/1107-drift-totales-lote6_2026-09-19_22-59-21.md`.

**Firma:**
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-19 22:59

**Resolución:**
- [x] Cómo se corrigió: se reescribió la línea 384 de
  `DOCUMENTACION/156-Terrenos-Y-Movimiento/plan-actual/05-Checklist.md` al formato
  canónico (`**Totales:** 307 ítems · Completados: 206 · Pendientes: 99 · No
  resueltos: 2.`) con nota de auditoría firmada. **Las marcas no se tocaron.**
- [x] Archivos modificados: `DOCUMENTACION/156-Terrenos-Y-Movimiento/plan-actual/05-Checklist.md`
  (1 línea reescrita + nota). Sin commit (push negativo por directiva del usuario).
- [x] Log del proyecto: 1103 (lote 6 — cierre del bloque 1A).
- [x] Verificado por: conteo post-fix re-ejecutado — 206/99/2 = 307, consistente con
  CHECKLIST-GLOBAL y con la nueva línea.

---


### BUG-065 — Leyenda de marcadores rota en 9 módulos fundacionales (conteo no verificable)

- **Fecha de reporte:** 2026-09-19 23:17
- **Módulo(s) afectado(s):** M02 Visión-Y-Concepto, M03 Documentación-Del-Proyecto,
  M04 Game-Engine, M05 Lenguaje-Y-Programacion, M06 Control-De-Versiones,
  M41 Música, M42 Sonido-Ambiental, M43 Efectos-De-Sonido, M44 ASMR-Y-Feedback
- **Severidad:** 🟠 Mayor
- **Prioridad sugerida:** Media
- **Estado:** [ ] Abierto — **no resuelto por diseño** (ver abajo)

**Descripción del problema:**

Los 9 módulos incluyen en su cabecera una leyenda de marcadores **rota**:

> `Estado: [ ] pendiente · [ ] completado · [?] no resuelto`
> (variantes: `Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto`)

**Ambos estados (pendiente y completado/cumplido) usan el símbolo `[ ]`.** En la
práctica, eso significa que **un ítem hecho queda marcado `[ ]` igual que uno
pendiente** y el conteo de marcas no tiene significado.

Consecuencia directa: las líneas `**Totales:**` de estos módulos **no se pueden
reconciliar con el conteo de marcas**, y el barrido de drift no puede auditarlas. Los
claims van de 38 a 162 "completados" sobre 0 a 76 `[x]` reales:

| Módulo | Totales dice | Marcas reales | Δ |
|--------|--------------|---------------|---|
| M02 | 172 · **Completados 162** · 10 pend | 0 [x] / 172 [ ] | +162 |
| M03 | 133 · **Completados 133** · 0 pend | 0 [x] / 133 [ ] | +133 |
| M04 | 120 · **Completados 95** · 25 pend | 14 [x] / 114 [ ] | +81 |
| M05 | 102 · **Completados 102** · 0 pend | 4 [x] / 99 [ ] | +98 |
| M06 | 92 · **Completados 91** · 1 pend | 0 [x] / 100 [ ] | +91 |
| M41 | 110 · **Completados 38** · 72 pend | 61 [x] / 49 [ ] | −23 |
| M42 | 109 · **Completados 37** · 72 pend | 63 [x] / 37 [ ] | −26 |
| M43 | 96 · **Completados 30** · 66 pend | 61 [x] / 39 [ ] | −31 |
| M44 | 113 · **Completados 113** · 0 pend | 76 [x] / 37 [ ] | +37 |

**Importante — estos NO son claims falsos en el sentido de BUG-063/064/066.** En los
módulos con Δ positivo (M02-M06, M44) el claim probablemente sea **verdadero**: muchos
ítems están de hecho cumplidos (p. ej. "Definir nombre definitivo del juego: Isla
Ancestral" en M02 — el nombre existe y la fuente referenciada también). El problema es
que **no hay forma de verificarlo contando marcas**, porque la convención misma está
rota. En los de Δ negativo (M41-M43) la línea simplemente quedó obsoleta tras flips
posteriores.

Autor de la leyenda rota: **Deepseek V4 Flash** (fundador del proyecto, firmante de
los 9 módulos). Es la misma clase de descuido documentado en M69 (Nemotron 3.5
Lighting, Log 1099) — otro caso de leyenda rota que sí resultó ser un claim falso.

**Por qué no se resolvió:**
- Corregir la línea Totales para que coincida con las marcas sería **incorrecto** en
  los de Δ positivo: transformaría un claim verdadero (aunque no verificable) en uno
  falso ("0 completados" cuando el juego tiene nombre, GDD, repositorio, etc.).
- Corregir las marcas (flips a `[x]`) requiere **verificar ítem por ítem con
  evidencia** (¿existe el archivo citado?, ¿está configurado?) — eso es trabajo de
  implementación, no de auditoría de drift, y supera el alcance de este barrido.
- Por simetría con M69 (cuya leyenda rota SÍ escondía un claim falso), no se asume ni
  inocencia ni culpa: **se reporta y se deja abierto.**

**Pasos para reproducir:**
1. Abrir cualquiera de los 9 archivos `plan-actual/05-Checklist.md`.
2. Leer la línea de leyenda (L6-L8): ambos estados usan `[ ]`.
3. Comparar el conteo de `[x]` con la cifra de "Completados" en la línea Totales.

**Comportamiento esperado:** la leyenda debería ser `[ ]` pendiente · `[x]` completado,
de modo que el conteo sea significativo y reconciliable con la línea Totales.

**Evidencia:**
- Leyendas literales extraídas de las cabeceras de los 9 archivos (2026-09-19).
- Conteos con regex anclado a línea sobre los 9 archivos (ver tabla).
- Ningún check de estos 9 módulos puede auditarse con `verificar_checklist.py` hasta
  que se arregle la convención.

**Intentos de solución ya probados:** ninguno — la verificación por conteo es
estructuralmente imposible mientras la leyenda esté rota.

**Referencias cruzadas:**
- Guía 07 §8: no.
- Relacionado: **BUG-063** (M69, leyenda rota + claim falso), **BUG-066** (M63, claim
  falso con leyenda correcta), M21 (leyenda rota similar, ya con nota de reversión).
- Log: `Logs/1106-drift-totales-bloque1c_2026-09-19_23-17-51.md` (sección
  "No verificable").

**Firma:**
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-19 23:17

**Resolución (pendiente):**
- [ ] Corregir las leyendas de los 9 módulos a `[ ]` pendiente · `[x]` completado.
- [ ] Pasaje ítem por ítem con evidencia (archivos citados, configuración, etc.) para
  flipear a `[x]` los realmente cumplidos.
- [ ] Reescribir las líneas Totales con los conteos resultantes.
- [ ] Re-auditar con el método estándar de drift.

---


### BUG-066 — M63 Cargas-Y-Streaming: `**Totales:**` declara 101/101 completado (claim de cierre falso)

- **Fecha de reporte:** 2026-09-19 23:17
- **Módulo(s) afectado(s):** M63 Cargas-Y-Streaming — documentación (`plan-actual/05-Checklist.md`)
- **Severidad:** 🟠 Mayor
- **Prioridad sugerida:** Media
- **Estado:** [x] Resuelto (parche de documentación; sin impacto en runtime)

**Descripción del problema:**

La línea `**Totales:**` (L157) decía textualmente:

> `**Totales:** 101 ítems · Completados: 101 · Pendientes: 0 · No resueltos: 0.`

Claim de **cierre total del módulo**. El conteo real de marcas es **16 `[x]` / 85 `[ ]` /
0 `[?]` = 101** — hay 85 ítems sin marcar, incluyendo los más básicos de la propia
documentación (L151-155: "01-Requerimientos creado y firmado", "05-Checklist creado y
firmado", etc.). Mismo modo de fallo que BUG-063 (M69) y BUG-064 (M156): una línea que
declara 100% de completitud sobre un archivo mayoritariamente `[ ]`.

El módulo figura 🟢 Disponible con 16/101 en CHECKLIST-GLOBAL (correcto). La nota
inmediatamente debajo (L158: *"secciones B-K se verifican en runtime por el agente
delegado; diseño, pesos, LRU y regiones cierran aquí"*) explica la **intención** del
autor (declarar el diseño cerrado), pero no justifica que la línea diga
"Completados: 101" cuando 85 ítems están `[ ]`.

**Pasos para reproducir:**
1. Abrir `DOCUMENTACION/63-Cargas-Y-Streaming/plan-actual/05-Checklist.md`.
2. Leer L157 (antes de la corrección): "Completados: 101 · Pendientes: 0".
3. Contar las marcas: 16 `[x]`, 85 `[ ]`, 0 `[?]`.

**Comportamiento esperado:** la línea de Totales debe coincidir con el conteo de
marcas del archivo (regla de drift, DoD §21.6).

**Evidencia:**
- Conteo con regex anclado a línea pre-fix: `(?m)^\s*[-*] \[x\]` → 16; `\[ \]` → 85.
- CHECKLIST-GLOBAL fila 63: `🟢 Disponible | 16/101` — correcto, no requiere cambios.
- Origen: módulo fundacional de Deepseek V4 Flash, con iteraciones posteriores de
  glm-5.3-flash (Log 603, iter. 2 "pausa de cargas"). El claim probablemente quedó de
  la iteración original.

**Causa raíz:** la línea se escribió declarando el diseño cerrado sin que las marcas
del archivo lo reflejaran (los ímites entre "diseño cumplido" y "ítem marcado `[x]`"
no se respetaron).

**Referencias cruzadas:**
- Guía 07 §8: no.
- Relacionado: **BUG-063** (M69), **BUG-064** (M156) — mismo patrón "Pendientes: 0"
  falso; **BUG-065** (leyenda rota, distinto mecanismo pero misma familia de
  síntomas: el conteo no refleja la realidad).
- Log: `Logs/1106-drift-totales-bloque1c_2026-09-19_23-17-51.md`.

**Firma:**
**Modelo:** Atria-Dawn-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-09-19 23:17

**Resolución:**
- [x] Cómo se corrigió: se reescribió L157 al formato canónico (`**Totales:** 101
  ítems · Completados: 16 · Pendientes: 85 · No resueltos: 0.`) con nota de auditoría
  firmada. **Las marcas no se tocaron.**
- [x] Archivos modificados: `DOCUMENTACION/63-Cargas-Y-Streaming/plan-actual/05-Checklist.md`.
  Sin commit (push negativo por directiva del usuario).
- [x] Log del proyecto: 1106 (bloque 1C).
- [x] Verificado por: conteo post-fix — 16/85/0 = 101, consistente con
  CHECKLIST-GLOBAL y con la nueva línea.

---


### BUG-070 — Patrón sistémico de over-marks "KnownIssue no bloqueante": 17 módulos ✅ con ítems marcados [x] sin implementar

- **Fecha de reporte:** 2026-09-20 01:13
- **Módulo(s) afectado(s):** M32, M36, M65, M78, M81, M82, M85, M93, M94, M114, M116,
  M118, M119, M145, M146, M154, M167 (17 módulos que figuraban ✅).
- **Severidad:** 🔴 Crítico (corrupción de la métrica de progreso del proyecto)
- **Detectado por:** Atria-Dawn-Preview / Kilo Code — escaneo sistemático de over-marks
  (Log 1116), sucesor natural de BUG-063/064/066 (claims falsos de Totales) y
  BUG-061/062 (sobre-cierres).
- **Reportado por:** Atria-Dawn-Preview (Kilo Code)
- **Modelo:** Atria-Dawn-Preview
- **Plataforma:** Kilo Code
- **Fecha:** 2026-09-20 01:13

#### Síntoma

17 de los 33 módulos ✅ tenían ítems `- [x] ...` cuyo texto contiene literalmente
"NO implementado", "sin implementar" o "KnownIssue no bloqueante DoD" — **145 ítems**
en total, firmados por **9 agentes distintos** (GLM-5.3, agnes-2.5-flash, ox-alpha,
deepseek-v4-flash, Step 3.7, MiMo y otros). El patrón se usó como atajo para cerrar
ítems no hechos y aun así reclamar el ✅ del módulo.

#### Causa raíz

La convención "KnownIssue no bloqueante DoD" no existe en AGENTS.md §21.6 — la DoD
exige **todos** los `[x]` con "código implementado y funcional". Varios agentes la
inventaron como mecanismo de deferral honesto (documentan la brecha en `03-Diseno.md`),
pero el efecto es que **un `[x]` sobre un ítem NO implementado es un marca falsa** y
el ✅ del módulo deja de ser válido.

#### Verificación con evidencia real (no el texto del ítem)

Se indexaron los 6008 archivos de `game/` y se verificó la existencia del código
citado por cada ítem. Resultado:

- **Familia A — 8 ítems** (marcaron hecho, código ausente): M93 ×3 (`simulate_economy.gd`
  no existe — el propio `04-Codigo.md:256` del módulo lo admite), M85 ×1, M36 ×2,
  M65 ×1, M167 ×1. → **RESUELTOS**: marcas `[x]`→`[ ]`, 5 módulos revertidos ✅→🟡,
  ✅ global 33→28 (Log 1116).
- **Familia B — 120 ítems** (plan malo / checklist no corresponde): ítems de diseño,
  documentación o dependencia externa legítima; o citan archivos que **sí existen** bajo
  otro nombre (`behavior.gd`→`fauna_behavior.gd`, `balance.gd`→`balance_service.gd`,
  `isla_generador.gd`→`island_generator.gd` — renombres Unity→Godot que dejaron el
  `04-Codigo.md` stale). → **ABIERTOS**: la acción correcta es **re-evaluar el
  `plan-actual/` y la `05-Checklist.md`** de cada módulo, no descartar marcas.

#### Por qué importa

M93 Balance figuraba ✅ 134/134 mientras su propia documentación llama a
`simulate_economy.gd` "la brecha grande restante del módulo". La métrica de progreso
del proyecto (CHECKLIST-GLOBAL) estaba inflada de forma sistemática.

#### Estado

- `[x]` Familia A resuelta (Log 1116): 8 marcas descartadas, 5 módulos 🟡, conteos y
  globales sincronizados, 0 mojibake introducido.
- `[ ]` **Familia B abierta**: 120 ítems en 16 módulos. Requiere re-evaluación de
  `plan-actual/04-Codigo.md` (paths stale) + `05-Checklist.md` (ítems de spec vs
  implementación) por módulo. Reporte completo con los 145 ítems clasificados:
  `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s2/overmarks_clasificacion_2026-09-20.txt`.
- `[ ]` Re-auditar con `python scripts/verificar_checklist.py` tras los cambios.

#### Relacionado

- **BUG-063** (M69), **BUG-064** (M156), **BUG-066** (M63) — claims falsos de Totales
  (misma familia: progreso inflado).
- **BUG-065** — leyenda rota en 9 fundacionales (no verificable por conteo).
- **BUG-061/BUG-062** — sobre-cierres con suites fallando (Logs 1083/1085).
- **BUG-067** (M103) — no relacionado (rendimiento de logging), comparte número por
  coincidencia en la tabla.

### BUG-072 — CI/CD sin implementar: despliegue itch.io, email a stakeholders, validación firebelley; 3 citas § fantasma

- **Fecha de reporte:** 2026-09-19 05:30
- **Módulo(s) afectado(s):** M118 (CI/CD) — gap de implementación localizado; no afecta a otros módulos.
- **Severidad:** 🟠 Mayor (corrupción localizada de la métrica de M118: 4 ítems `[x]` sobre un despliegue nunca hecho; M118 nunca tuvo sello, así que no invalida sello alguno).
- **Detectado por:** hy3 / WorkBuddy (re-verificación de la "cadena A" de M118, Log 1125) — corrección del veredicto "Caso B" que hy3 había dado en Log 1117.
- **Reportado por:** hy3 (WorkBuddy)

#### Síntoma

M118 figuraba ✅ 106/106 (CI/CD). 4 ítems de despliegue/CI-CD estaban marcados `[x]` pero su texto dice "KnownIssue no bloqueante DoD / requiere BUTLER_API_KEY / requiere push real / requiere configuración de email service" — es decir, NO implementados.

#### Causa raíz

El patrón "KnownIssue no bloqueante DoD" no existe en AGENTS.md §21.6 (misma raíz que BUG-070). Pero a diferencia de lo que hy3 diagnosticó en Log 1117 (Caso B = diseño legítimo), acá es **Caso A (Familia A)**: el artefacto citado no existe.

La lección del clasificador (hy3, Message 6): chequear que el archivo citado exista NO alcanza. Hay que (a) parsear §X.Y y verificar el header real, y (b) para ítems de CI/CD, grepear `.github/workflows/`.

#### Verificación con evidencia real

- `DOCUMENTACION/118-CI-CD/plan-actual/03-Diseno.md` solo tiene §1–§4. Las citas §2.5, §3.9, §3.10 y §4.1 **no existen** (3 citas § fantasma: §2.5 y §3.10 en despliegue itch.io, §3.9 en email a stakeholders, §4.1 en validación GitHub Actions).
- `.github/workflows/` tiene exactamente 6 workflows (backup / bug_metrics / dev-build / quality / release-build / testing). Ninguno referencia `itch`, `butler`, `stakeholder`, `email` (dispatch) ni `firebelley` como despliegue. El único hit de `email` es `user.email` de git config en `bug_metrics.yml`.
- Los 4 ítems son de **implementación**, no de diseño/doc legítimo:
  1. P5: despliegue a itch.io al crear tag semver.
  2. Subida a Itch.io (manual trigger).
  3. Email a stakeholders en tags.
  4. Validación en GitHub Actions real (firebelley v5.2.1).

#### Por qué importa

Un módulo ✅ 106/106 con 4 ítems de despliegue jamás hechos infla la métrica de progreso de M118. Al ser Familia A, la corrección es descartar las marcas (no re-evaluar diseño).

#### Estado

- [ ] Abierto — M118 revertido ✅→🟡 por hy3 (2026-09-19): 4 marcas `[x]→[ ]` conservando las notas, Totales 106/0/0 → **102/4/0**, fila global + nota firmada en `05-Checklist.md`. M118 **no tiene sello** (no figura en CHECKLIST-QA-SEALS.md), así que no se invalida sello alguno.
- [ ] Re-auditar con `python scripts/verificar_checklist.py` tras el cambio.

#### Relacionado

- **BUG-070** (de s2 / Atria-Dawn-Preview) — patrón sistémico de over-marks "KnownIssue no bloqueante DoD"; M118 estaba en su lista de 17 módulos. BUG-072 es la corrección específica de M118 que BUG-070 no desglosó (BUG-070 lo dejó como Familia B abierto; esta re-verificación lo reclasifica a Familia A).
- **BUG-009** (M118, CI de tests con Godot 4.3) — ya resuelto, independiente.

#### Firma (verificador hy3 — 2026-09-24)
**Modelo:** Hy3 / WorkBuddy (Tencent Hunyuan)
**Rol:** Verificador §21.8 (verificador ≠ autores de implementación de M118)
**Fecha:** 2026-09-24
**Veredicto:** BUG-072 validado como reporte correcto y completo. `### BUG-072` confirmado en 11-BUGS.md L3856; Log 1125 (hy3) referencia BUG-072 de forma consistente (el renombre BUG-071→BUG-072 tocó el contenido; el slug del filename se renombró a BUG072 en esta misma sesión para cerrar la inconsistencia). M118 revertido ✅→🟡 por hy3 (2026-09-19): 4 marcas `[x]→[ ]` conservando notas, Totales 106/0/0 → **102/4/0**, fila global + nota firmada en `05-Checklist.md`. M118 no tiene sello §21.8 (ausente en CHECKLIST-QA-SEALS.md), por lo que no se invalida sello alguno. Re-auditoría con `python scripts/verificar_checklist.py` pendiente (ítem `[ ]` en Estado).

---

### BUG-073 — "Parameter fd is null" (_shape_run) al cambiar de locale en headless: ThemeService.recargar_fuentes falla en shaping de fuentes

- **Fecha de reporte:** 2026-09-20 02:52
- **Módulo(s) afectado(s):** M53 (UI — `scripts/ui/theme/theme_service.gd` L39/53/57) / M88 (Fuentes) — cadena `locale_changed` → `ThemeService._on_locale_changed` → `recargar_fuentes()` → `aplicar_tema_global()`.
- **Severidad:** Baja (no afecta exit code ni render en editor; es ruido ERROR en salidas headless)
- **Detectado por:** agnes-3-flash / Kilo Code — durante la iter. M53 i18n+M58 (Log 1118).
- **Estado:** [?] Delegado — dueño **M53/M88** (el que tenga ThemeService/Fuentes en curso). No lo corrijo: es código de M53/M88 (fuera de mi alcance acotado) y el repro solo ocurre en headless al cambiar locale.

**Descripción:**
Cada llamada a `Localization.set_locale(...)` en Godot 4.7.2 **headless** emite:
`ERROR: Parameter "fd" is null. at: _shape_run (modules/text_server_adv/text_server_adv.cpp:7181)`
con backtrace `theme_service.gd:39 aplicar_tema_global ← :53 recargar_fuentes ← :57 _on_locale_changed ← localization_manager.gd:133 _aplicar_locale`.
El exit code del test sigue siendo 0 y 0 SCRIPT ERROR (es un ERROR de motor, no de script), pero
contamina la salida de cualquier suite que cambie de locale.

**Pasos para reproducir:**
1. `Godot --headless --path game/isla-ancestral --script res://scripts/ui/test_ui_i18n_m53.gd`
2. La suite (39 OK / 0 fallos / EXIT 0) muestra 4× `ERROR: Parameter "fd" is null` (uno por cada `set_locale`).
3. El RUNTIME en editor (`main_island.tscn`) NO lo emite (no hay cambio de locale): 0 SCRIPT ERROR.

**Hipótesis:** en headless el shaping de FreeType recibe un `fd` (font data/file) nulo cuando
ThemeService re-aplica fuentes al cambiar de locale — probablemente la fuente cargada no expone
datos en memoria para shaping sin ventana/D3D. Verificar si es solo-headless (repro en editor) y
endurecer `recargar_fuentes` (guardar contra fuente null/ausente antes de `aplicar_tema_global`).

**Evidencia:** salida de `test_ui_i18n_m53.gd` (3 corridas 2026-09-20: 39/0 EXIT 0, 4× ERROR fd null por corrida); `main_island.tscn` runtime sin el error.

**Firma:**
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-20 02:52

**Delegación:** [?] **M53/M88** — validar si el error es solo-headless (repro en editor) y endurecer
`ThemeService.recargar_fuentes` para no llamar a shaping con fuente nula. No bloquea: el veredicto
de las suites es 0 fallos / 0 SCRIPT ERROR.