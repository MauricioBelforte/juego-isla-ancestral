# BACKLOG-MASTER — space-bunny-alpha  ⚑ INACTIVO (baja del flujo 2026-10-06)

> **⚠️ MODELO DADO DE BAJA DEL FLUJO** (directiva del fundador, 2026-10-06 04:45): space-bunny-alpha ya no tiene disponibilidad. **Todas sus tareas quedan liberadas y reasignadas** (ver el final de este archivo). Esta carpeta se conserva como registro histórico — no asignar nada nuevo de aquí. Canal archivado en `Mensajes entre modelos/space-bunny-alpha/28-...baja-del-flujo...`.


**Modelo:** space-bunny-alpha (proveedor anónimo / stealth OpenRouter)
**Plataforma:** por confirmar (OpenRouter directo o `spacebunnymodel.com`)
**Fecha de alta:** 2026-10-04
**Ficha técnica:** `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` **§5.R**
**Canal:** `Mensajes entre modelos/space-bunny-alpha/`

---

## Perfil (capacidades verificadas, fuente primaria OpenRouter API)

| Capacidad | Estado | Notas |
|---|---|---|
| Contexto 1M entrada / 524K salida | ✅ verificado | Lee módulos enteros sin chunking |
| Multimodal ENTRADA (texto+imagen+audio+video) | ✅ spec | **Visión NO probada aún** — verificar con evidencia |
| Reasoning adjustable (5 niveles) | ✅ verificado | `reasoning_effort` soportado |
| Tool calling + JSON mode | ✅ verificado | `tools`, `tool_choice`, `response_format` |
| Gratis ($0/$0) | ✅ verificado | Preview — cambiará al "graduarse" |
| Benchmarks | ❌ NO EXISTEN | Proveedor anónimo; desconfiar de cualquier "benchmark oficial" |
| Evidencia en el repo | ❌ NINGUNA | **La primera entrega define todo** |

## Regla de asignación (hasta nueva evidencia)

> **Complejidad 1-3 SOLAMENTE.** Tareas de QA documental, verificación de consistencia
> filosofía↔diseño, lectura de documentación extensa (aprovecha el 1M).
> **PROHIBIDO complejidad 4-5** (gameplay, IA, economía, generación procedural) hasta que SB-01
> demuestre capacidad. Si la visión resulta real y verificable, hereda tareas visuales (escenas
> `.tscn`, capturas, QA de artefactos). Si decepciona, se baja a investigación pura o se da de
> baja (patrón Gemini 3.8 Flash, §5.Q).

---

## Resumen por módulo

| ID | Módulo | Estado GLOBAL | Complejidad | Tareas | Pendientes | Prioridad SB |
|---|---|---|---|---|---|---|
| 152 | Principios-Innegociables | 🟡 Liberado (SB-01) | 1 | 202 marcas | 29 `[?]` | **SB-01 ✅** (173/202) |
| 153 | Objetivo-Final | 🟡 Con dudas | 2 | 10 | 10 | cierre de sesión |
| 151 | Control-Final | 🟡 Con dudas | 2 | 141 | 139 | tras SB-03 |

**Total: 238 tareas (236 pendientes + 2 `[?]` a verificar).** Supera el mínimo de 100 (§29).

> ⚠️ **Nota de reasignación (2026-10-04, canal 03 y 04):** los números **SB-02/SB-03** de esta tabla
> Originally apuntaban a M153/M151. El director **reasignó** esos números a tareas nuevas. La
> numeración vigente está en **§Frentes (orden de ejecución)** más abajo. No usar la numeración
> original.

---

## Frente vigente (reordenado por el director, canal 03 y 04)

| Tarea | Qué es | Complejidad | Visión | Estado |
|---|---|---|---|---|
| **SB-01** | M152 — verificar 87 principios | 1 | **no** | ✅ `[x]` — Log **1270** |
| **SB-02** | **Auditoría** coherencia `CHECKLIST-GLOBAL.md` ↔ `05-Checklist.md` reales | 2 | **no** | ✅ `[x]` — Log **1279** |
| **SB-03** | Verificar la **condición del Ejemplo 3** de M152 (mapa ×10) | 2 | **no** | ✅ `[x]` — Log **1278** |
| **SB-04** | **Registrar D-R1** (y D-R2) como desviaciones justificadas | 1 | **no** | ✅ `[x]` — Log **1280** |
| **SB-05** | **Integrar las 4 verificaciones en `scripts/verificar_checklist.py`** | 2 | **no** | ✅ `[x]` — Log **1282** · *commit pendiente de s2* |
| **SB-06** | **Gate de CI anti-CJK** (`scripts/verificar_cjk.py` + 16 tests) | 2 | **no** | ✅ `[x]` — Log **1294** · *sin commitear (s2)* |
| **SB-07** | **Limpieza de 15 temporales (51,5 MB) + `.gitignore` + BUG-103** | 1 | **no** | ✅ `[x]` — Log **1296** |
| **SB-08** | **Validador de autoloads en GDScript** + suite headless | 2 | **no** | ✅ `[x]` — Log **1306** (114/114 OK · 21/21 checks) |
| **SB-09** | **Diagnóstico de visión** — ¿funciona mi vía? | — | **V2** | ✅ `[x]` — Log **1307** · **SÍ FUNCIONA** |
| **SB-10** | Comparativa antes/después del diario | — | **V2** | ✅ `[x]` — Log **1307** · layout 3 columnas confirmado |
| **SB-11** | **Fix del toggle del diario** — resultó **no haber bug** | 2 | **V2** | ✅ `[x]` — Log **1314** · el toggle funciona (89 checks) |
| **SB-12** | **Sincronizar D-R2** en el registro de desviaciones (drift propio) | 1 | **no** | ✅ `[x]` — Log **1318** |
| **M151** | **Control Final** — `verificar_puntos.py` + 11 tests + corrección de la cifra falsa | 2 | **no** | ✅ `[x]` — Log **1289** (1ª C2 con código) |
| M153 | Objetivo-Final (10 ítems) | 1 | no | ⏭ cierre de sesión |

> **Confirmación de capacidad:** SB-02/03/05 fueron **complejidad 2** (documental y Python puro) y
> las 3 quedaron confirmadas con evidencia. Perfil: **C1 ✔ · C2 ✔ · C2 con GDScript ✘ · C3+ ✘**.
> **Visión: sin evidencia.** No la usé en ninguna de las 6 tareas (todas textuales).
> **Al director le pedí una sola muestra de GDScript** (con test headless) antes de C3, en vez de
> aceptar la promesa: es lo mismo que él hizo bien conmigo (M151 antes que C3).

### ✅ M151 — `scripts/auditoria/verificar_puntos.py` — `[x]` Log **1289**

**Primera tarea con código** (Python puro). Cerré el ítem `[M]` «Definir verificación automática:
puntos sin evidencia = alerta» y **1 `[ ]` → `[x]`**.

**La herramienta valida** los 26 puntos de `03-Diseno.md` §2: presencia (detecta falta **y** sobra),
`id` duplicado, estado válido (glifo `✔`/`⚠`/`✖` o `OK`/`WARN`/`BLOCK`), **evidencia obligatoria**,
**plan de acción con `dueño`/`fecha`/`desc` en cada ⚠/✖**, y con `--cierre`: **0 bloqueantes +
firmas producción y QA**. Modo `--plantilla` emite el esqueleto. **Fail-fast BUG-075 con `exit 3`.**

**11 PASS / 0 FAIL** en `scripts/auditoria/test_verificar_puntos.py` (suite autocontenida: **no toco
`test_scripts.py`, que es de s2**).

**4 hallazgos:**
1. **⚠️ El más grave:** `data/control_final/estado_release.json` está **congelado en «2026-09-02
   18:00»** y **nada lo escribe**. `release-build.yml` **no ejecuta** el gate. Cablesarlo sin
   refrescar la fuente = **falsa seguridad** (trampa 81/100). Dejé ambos como `[?]`:
   gate → **s2**; quién escribe el JSON → **director**.
2. **Deriva diseño↔implementación:** `04-Codigo.md` §1 especifica 4 módulos Python; 3 **no
   existen**. La implementación real es **GDScript** en `game/isla-ancestral/scripts/control_final/`
   (capa distinta: dentro de Godot vs fuera). Documentado en `04-Codigo.md` §5.
3. **La cifra de `## Totales` era FALSA** (14ª vez del patrón H-D): «144 resueltos / 0 pendientes»
   con 139 `[ ]` reales. **Y me agarré a mí mismo:** al añadir mi iteración el conteo pasó a 159 y
   el Totales quedó en 151 — lo detecté con el script de verificación marca-vs-marca y lo corregí
   dos veces. Final: **16 `[x]` · 5 `[?]` · 138 `[ ]` = 159**.
4. La ruta de las iteraciones 1-2 del checklist (`scripts/control_final/…`) omite el prefijo
   `game/isla-ancestral/`. **Casi lo reporté como «2 `[x]` a archivos inexistentes»** — me frené al
   buscar en todo el repo. 4ª vez que aplico *desconfiar de la lectura*.

**Coordinación:** nota a s2 (`atria-dawn-s2/21-...`) para el commit de SB-05 y el territorio de M151.
**s2 commiteó SB-05** (`c2cbbd6`) y **autorizó `scripts/auditoria/`** (`f456a02`), pero
**`scripts/auditoria/` sigue SIN commitear** — asked al director.
**No commiteé nada.** **No implementé** `generar_acta.py`/`importar_telemetria.py`/
`importar_encuestas.py`: dependen de datos que no existen (telemetría 72 h, CSV de encuestas,
criterios de S1) y sería teatro.

### ✅ SB-06 — Gate de CI anti-CJK — `[x]` Log **1294**

**Condición cumplida:** s2 commiteó SB-05. Construí **`scripts/verificar_cjk.py`** +
**`scripts/test_verificar_cjk.py`** (16 PASS / 0 FAIL, suite autocontenida).

**Por qué un gate nuevo y no extender `diagnosticar_mojibake.py`:** aquel busca latin-1 mal
decodificado (`é`); mi caso era **UTF-8 perfectamente válido con CJK dentro de una frase en
español**. Son defectos distintos.

| Decisión de diseño | Razón |
|---|---|
| **Lee el `.gitignore`** | `.venv/`, `node_modules/`, `Obsoletos/` ya están ahí. **No hardcodear una lista paralela**: se desactualiza |
| Excluye `.claude/skills/` | Contenido de **terceros** (AGENTS.md §27): los skills traen CJK legítimo |
| Solo extensiones de texto | Los binarios pueden tener CJK en metadatos sin que sea defecto |
| **Ilegible = defecto reportado**, no se salta | Un gate que traga errores es peor que no tener gate (trampa 91/100) |
| **Ilegible NO aborta el escaneo** | Si abortara, 1 archivo roto perdería el reporte de 7.400 |
| Marcador inline `cjk-gate: allow` | Las excepciones quedan **visibles y greppables**, no en una lista global |
| `exit 3` = detector ciego | Misma convención BUG-075; un `exit 0` sobre árbol no recorrido sería OK falso |

**Resultado contra el repo:** 7.432 archivos escaneados · **58 con CJK (220 caracteres)** · **9
ilegibles** · exit 1. **Elworst archivo es `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` (40)** — el
que el usuario tiene abierto. **Y `145-Diseno-De-Experiencia/03-Diseno.md` L52 (`└──自由`) sigue sin  [cjk-gate: allow: cita del bug CJK de M145]
arreglarse desde SB-01.**

> ⚠️ **Aviso de cableado:** el gate hoy **FALLA**. Si se cablea a `quality.yml` sin limpiar, el
> pipeline queda rojo de inmediato. Orden correcto (igual que con el generador): **limpiar → cablear**.

**⚠️ El gate cazó un bug DEL PROPIO GATE:** mi comentario prometía excluir `.kilo/worktrees` y el
código **no lo excluía** → 7.832 archivos de más y conteos triplicados. Lo encontré **corriendo el
gate contra el repo real**, no con los tests. Misma clase que el check muerto de
`verificar_checklist.py` — y era mío.
**Mis tests encontraron 2 bugs de lógica más:** `ruta_ignorada` no distinguía directorio/archivo, y
`leer_gitignore` perdía el anclaje de `/build/`.

**Exentas con marcador (10 líneas):** las que **citan** el bug de M145 (`自由`) en mi Log 1270,  [cjk-gate: allow: cita del bug CJK de M145]
mi canal 02, el `05-Checklist` y el apéndice de M152, mi Log 1294 y mi informe 12. **El archivo
`03-…` del director también cita ese bug** y quedó sin marcar: **no lo toco porque es suyo** (le
reporto en el canal 12).


### ✅ SB-07 — Limpieza de temporales + BUG-103 + prevencion — `[x]` Log **1296**

**Autorizado por el director** (canal `14`): borrar los `_*.txt` de la raiz y registrar los 3
`Logs/` ilegibles como hallazgo.

**a) Borre 15 temporales = 51,5 MB.** Con **4 guardas** antes de cada uno: untracked (no se
pierde historial), raiz + `_` + `.txt`, sin referencias en scripts/workflows/codigo/docs, y sin
run en vuelo (el mas nuevo tenia 1 h 15 de antiguedad). Eran stdout de `godot --headless`.
**Omitidos: 0.** Inventario en `borrados_sb07.json`.

**b) Registre BUG-103** en `DOCUMENTACION/11-BUGS.md` (§5 tabla + §6 entrada + §9 historial;
**ninguna marca previa tocada**). **Diagnostico clave: los 3 logs estan en cp1252, NO es
mojibake** — decodifican completo como cp1252. Por eso la correccion es un **transcodificado sin
perdida**, no una recuperacion (relevante: AGENTS.md §28.1 prohibe `errors="replace"`). Origen
probable: **redireccion `>` de PowerShell** (regla T-9). **No lo arregle:** el director los deja
como historicos.

**c) Prevencion:** agregue `_*.txt` a `.gitignore`. **La causa era que la regla existente solo
cubria `tmp_*.txt` y `_tmp_*.txt`.** Verificado: `check-ignore` matchea en `.gitignore:176`, y
**ningun archivo versionado matchea el patron** (no oculto nada trackeado).

**d) Correccion a un dato del director:** el bug de M145 **esta en DOS archivos** (L52 de
`plan-inicial/03-Diseno.md` **y** de `plan-actual/03-Diseno.md`). Arreglar solo uno deja el gate
en rojo.

**Estado del gate tras la limpieza:** ilegibles **9 -> 3** · CJK 58 -> 60 archivos (subida
**buena**: su `10-GUIA` bajo 40 -> 33 con su limpieza, y aparecio su archivo 14 con 28 por citar
las corrupciones que corrigio).

**Pendientes que reporte:**
- `_chk.json`, `_chk2.json`, `_chk3.json` son **`.json`, no `.txt`** -> fuera de la autorizacion;
  pido decision.
- **No puse `cjk-gate: allow` en archivos ajenos** (su `14-…` con 28, su `03-…` con 4, M145, los
  6 backlogs de otros modelos, `Logs/904-HY4`): el marcador es una **declaracion de intencion** y
  no puedo afirmar que su cita sea intencional sin saberlo.


### ✅ SB-08 — Validador de autoloads (GDScript) — `[x]` Log **1306`

**Mi primera tarea de GDScript**, verificada con el binario real (`C:\Temp\godot\`). No hizo
falta coordinar con s2.

| Artefacto | Resultado |
|---|---|
| `game/isla-ancestral/scripts/validadores/validador_autoloads.gd` | **114 autoloads · 114 OK · exit 0** |
| `.../test_validador_autoloads.gd` | **21 checks · 21 OK · exit 0** |

**⚠️ Mi primer verificador dio 6 falsos positivos** (`EventBus`, `TooltipService`,
`NotificationService`, `TermsManager`, `combat_island`, `gem_currency`). **Esos 6 compilan** — lo
supe porque el log del boot mostraba `[DOM-UI]`/`[NPCManager]` funcionando mientras mi validador los
declaraba rotos. El propio Godot lo dijo: `Parse Error: Class "EventBus_" hides a global script
class` (un `GDScript` **anónimo** no tiene contexto de `class_name`).

**Los 3 métodos medidos con sondas descartables:**

| Método | Detecta ausente | Detecta sintaxis | Falsos positivos |
|---|---|---|---|
| A) `source_code` + `reload()` | no | sí | **6 de 114** ❌ |
| B) `load()` solo | sí | **NO** | 0 |
| **C) `load()` + `reload()` sobre el recurso cargado** | sí | **sí** | **0** ✅ |

**Solo C es correcto**, y el motivo quedo escrito en la cabecera del validador para que nadie lo
"arregle" reintroduciendo el bug.

**Extra:** detecta **autoloads que comparten ruta** (sistema duplicado). Encontré
`Localization → scripts/localization/localization_manager.gd` y
`LocalizationManager → scripts/localizacion/localization_manager.gd` (mismo archivo, dos directorios).
**No lo toco: no sé si es duplicado o dos capas.** Propietario: quien loJpueda decidir.

### ✅ SB-09 / SB-10 — Mi visión FUNCIONA — `[x]` Log **1307`

| Capacidad | Estado |
|---|---|
| Capturar pantalla / ventana / guardar | ✅ |
| **Analizar lo que veo** | ✅ |
| **Entregar teclado** (`PostMessage`) | ✅ |
| **Click de ratón** | ❌ **no tengo** |

**El diario abre con J** (confirmé que `diario` tiene `"physical_keycode":74` en `project.godot`) y
el **layout de 3 columnas** de mimo renderiza: Categorías (10, con `Personajes` resaltado) ·
Buscar en + Filtro · Detalle con «Elegí una entrada para ver su detalle».

**⚠️ Hallazgo de método:** mi primer intento (`SetForegroundWindow` + `keybd_event`) **no
funcionó**. Podía haber reportado «el diario no abre» como bug, **pero probé una segunda tecla**
(`B` = inventario) y tampoco funcionó → el problema era **mi inyección**, no el diario. Después
`PostMessage` funcionó al primer intento. **Un control negativo evitó un bug fantasma.**

**No verificado:** J **no cierra** el diario (ni ESC). El único cierre es el botón «Cerrar», al que
**no llego sin click**. No lo reporto como bug porque no sé si el diseño era toggle o botón.

**Observaciones del render (hipótesis, no diagnósticos):** el agua se ve **blanca** (no azul), hay
**triángulos verde oscuro planos** sobre la pradera (sugieren quads o geometría sin grosor), y el
**FPS es 59-60** (dentro de presupuesto).

**Limitación para C3:** mi QA visual llega hasta «se ve roto / no se ve roto» y **no** hasta
«lo arreglé y te muestro el antes/después», porque **no puedo hacer click**.

**Perfil actualizado:** C1 ✔ · C2 ✔ · **C2 GDScript ✔ (binario real + suite headless)** ·
**V2 visión ✔ (capturas reales)** · C3 **?**.


### ✅ SB-11 — el toggle del diario: **no hay bug** — `[x]` Log **1314`

Me asignaron «J no cierra el diario → arreglalo». **Fui a verificar antes de tocar nada y la
conclusion del encargo era falsa.**

**4 puntos de evidencia:**
1. `project.godot` → accion `diario` con `"physical_keycode":74` = 'J'.
2. `ui_manager.gd:150-155` llama `dia_layer.toggle()`.
3. `diary_layer.gd:274-278` → `if visible: close() else: open()`.
4. **El test que ya estaba en el repo lo prueba y pasa:**
   `=== TEST M55 DIARIO UI: 89 checks, 0 fallo(s) ===` exit=0. `test_diario_ui.gd` L251-256 manda
   `InputEventAction("diario")` **dos veces** verificando abrir/cerrar.

**No toque `ui_manager.gd` ni `diary_layer.gd`** (son de mimo/s2 y el codigo es correcto). Aviso a
`mimo-v2.6-flash-free/19-...`.

**Mi observacion de runtime era un artefacto mio:** la misma J funciono **una vez** (abrio) y dejo de
funcionar despues; ESC con el juego recien arrancado tampoco hizo nada. `PostMessage` deja de
entregar teclas cuando el juego cambia de modo de entrada.

**Registre 2 BUGs que SI son reales** (Log 1314): **BUG-104** (autoloads `Localization` /
`LocalizationManager` sobre el mismo archivo base, dirs duplicadas) y **BUG-105** (el **agua se
renderiza blanca**, con captura real; **no afirmo la causa**).

**Agregue §31 a `GUIA-GODOT/01`** con el hallazgo de los 3 metodos de chequeo de compilacion.

**Mi error grande: acepte la conclusion del encargo sin contrastarla con el codigo.** El codigo y un
test de 89 checks ya existentes la refutaban en dos minutos de lectura.

### ✅ SB-12 — Sincronizar D-R2 (drift en un archivo MIO) — `[x]` Log **1318**

No habia encargo nuevo, pero al revisar mi carpeta encontre que **tres documentos de M152 se
contradecían**: el `05-Checklist.md` y `resolucion_pendiente_m152.md` (agnes, Log 1313) tenian D-R2
**aprobada por el fundador**, mientras **`desviaciones_justificadas.md` — mi archivo de SB-04 —
seguia diciendo «PENDIENTE de aprobacion»**.

**Sincronizado** (5 cambios): la celda «Aprobado por», la fecha, el titulo de la seccion, las
tareas P1/P2 marcadas `ABIERTA` (el plan de cierre es de M22/M160/M167, fuera de M152) y una nota
de sincronizacion. **Las 3 fuentes coinciden ahora.**

**No reescribi la aprobacion:** la atribuccion dice **fundador**, relayed por el director,
registrada por agnes con su Log. Podia haber escrito «aprobado por space-bunny» y habria sido
**simular aprobacion** (lo que prohibe la DoD 21.6).

### ⚠️ LECCION DE PROCESO que me llevo

**No volvi a revisar mis propios archivos cuando cambio el estado que registran.** Entregue
`desviaciones_justificadas.md` con D-R2 «PENDIENTE» (correcto entonces) y nunca volvi. Lo mismo
con `11-BUGS.md` (BUG-103/104/105), `GUIA-GODOT/01` §31 y mi §14 de `04-Codigo.md` de M151.

**Regla:** *un documento que registro es un documento que tengo que volver a revisar cuando cambia
el estado que registra.* Si no, **mi archivo pasa a ser la fuente de drift** — que es lo que critico
en los demas.

**Pendiente de aplicar:** revisar los 4 archivos de arriba contra el estado real y reportarlo.

### Estado de M152 (cerrado por el fundador)

**202 `[x]` · 0 `[?]` · 0 `[ ]`** · `Totales` 202/0 coincide con el conteo real · D-R1 y D-R2
aprobadas · registro sincronizado · **QA §21.8 pendiente de Hy3 (T-H5)** · `🟡` → `✅` cuando selle.

**No lo sello yo:** soy el autor del analisis (SB-01), no el verificador. La §21.8 pide
verificador ≠ autor.


### ✅ SB-13 — Re-verificacion de los 4 registros que cree — `[x]` (Log 1318 Ampliado)

**Por que existe:** en el canal 23 me comprometi a revisar los documentos que registro cuando
cambia el estado que registran. **No lo habia hecho.** Sin encargo nuevo, lo hago.

| Registro | Estado real | Veredicto |
|---|---|---|
| `desviaciones_justificadas.md` (D-R1/D-R2) | Fundador; D-R2 APROBO la ampliacion parcial 2026-10-05; checklist `[x]`; M152 **202/0/0** | OK |
| `11-BUGS.md` (BUG-103/104/105) | los 3 registrados y **los 3 `[ ] Abierto`** | OK (son bugs reales sin cerrar) |
| `GUIA-GODOT/01` §31 | existe con `ERR_ALREADY_IN_USE`, el error real de Godot, la tabla de 3 metodos y la regla de proceso | OK |
| `04-Codigo.md` M151 (mi seccion) | **estaba como `## 5.`, chocando con la `## 5.` preexistente** | **CORREGIDO -> `## 6.`** |

**El fix:** verifique primero que **nada** referencia la seccion (las 18 coincidencias de
"04-Codigo.md + seccion N" del repo son de **otros modulos**) y que `## 6.` estaba libre.
Renumeré **solo el encabezado**, contenido intacto, con nota de por que. Headings ahora:
1,2,3,4,5,6 — sin duplicados.

### ⚠️ T-8 vs mimo: contradiccion de convencion que debe arbitrar el director

`GUIA-COMUNICACION.md` **T-8** (directiva del fundador 2026-10-04): la coordinacion horizontal
**va en la carpeta del RECEPTOR**, y **cita mi mensaje a s2 como el ejemplo correcto**.

mimo me dijo lo contrario (su canal 21 y 24): escribir en **mi** carpeta y avisarle.

**Sigo T-8** (es del fundador y la guia cita mi caso), pero lo consulto. **Lo que T-8 si confirma:**
el aviso previo a mimo estaba bien hecho — *"Gracias por el aviso previo"*, textual de el.

**Y la trampa que T-8 ya nombra:** la colision del 19 no fue por escribir en su carpeta, fue por
**numerar sin confirmar el numero libre** (liste su carpeta, pero entre mi listado y mi escritura
el escribio su propio 19). El la resolvió renumerando el suyo (19->20). **No hay conflicto pendiente.**

### ⚠️ 4a vez que un check armado a mano me da una senal falsa

Tres verificaciones minhas dieron `False` sobre archivos **correctos** (2 en §31, 1 en M151) porque
buscaba cadenas mal escritas. Es **T-5** de la propia guia. **Lo correcto es verificar por
tijera**: que la celda *contenga* lo que debe, sin reconstruir la frase.

### 📌 REGLA DE PROCESO (obligacion, no buena intencion)

*Un documento que registro es un documento que tengo que volver a revisar cuando cambia el estado
que registra.* Si no, **mi archivo pasa a ser la fuente de drift**, que es lo que critico en los
demas. Cada vez que registre algo en `11-BUGS.md`, `GUIA-GODOT`, un `desviaciones*.md` o una
`## Notas del Agente`, **anoto en mi backlog revisarlo** cuando el estado cambie.

### ⚠️ Nota de numeración de canal

Había **dos archivos `06-`** (el mío de SB-03/04 y el del director). Renombré **el mío** a `07-`
para no tocar el suyo. Numeración vigente: 08 (SB-05) · 09 (director) · **10 (M151, próximo 11)**.

### ✅ SB-05 — 4 verificaciones en `scripts/verificar_checklist.py` — `[x]` Log **1282**

**Restricciones del director cumplidas:** 15 PASS / 0 FAIL (10 previos + 5 nuevos, sin tocar ningún
test existente) · checks nuevos **opt-in** (`--estructura`/`--totales`/`--todos`) para no cambiar
el default · no toqué `generar_checklist_global.py` ni el GLOBAL ni los checklists · **sin commit**
(`scripts/` es de s2).

| Función nueva | Verificación | Flags |
|---|---|---|
| `estado_emoji()` | Fix **E3**: solo el emoji inicial del estado | (usada por los checks existentes) |
| `analizar_estructura_tabla()` | **(2)** filas mal formadas + sin pipe final, con **E2** y BUG-075 heredado | `--estructura` |
| `parsear_totales()` + `detectar_totales_incoherentes()` | **(4)** `Totales` vs conteo real, campo por campo (**E1**), regex agrupadas (**E4**) | `--totales` |

**Dry-run medido:** default `exit=1 · 44 alertas` · `--todos` `exit=1 · 116 alertas`
(55 filas mal formadas + 15 `Totales`).

**⚠️ Hallazgo principal: el fix E3 despertó un check que estaba MUERTO.** El check
`[x]` con estado `⬜`/`🟢` usaba igualdad exacta (`"🟢 Disponible" in ("⬜","🟢")` → nunca True) y
**nunca disparaba**. Al arreglarlo: **44 módulos con `[x]` pero estado `🟢 Disponible`**, los 44
verificados a mano. El peor: **`03-Documentacion-Del-Proyecto` con 117 `[x]` y progreso `0/133`**.
Añadí además el check que faltaba: `✅` con items `[ ]` (DoD §21.6).

**Impacto CI declarado:** el exit code **no cambia** (ya era 1), pero el volumen pasa **2 → 44**.
Si el pipeline parsea el stdout en vez del exit code, hay que saberlo.

**Riesgo encontrado y NO tocado:** `generar_checklist_global.py` parsea por posición sin validar el
encabezado → con pipes sin escapar en `Notas` puede **escribir columnas corridas** sobre la fuente
de verdad. Mientras las 55 filas mal formadas sigan ahí, **correr el generador es riesgoso**.

### ⚠️ Nota de numeración de canal

Había **dos archivos `06-`** (el mío de SB-03/04 y el del director). Renombré **el mío** a `07-`
para no tocar el suyo. Siguiente número libre: **09**.

### 🔴 RESTRICCIONES RESPETADAS ( canal 03 §SB-02 y 04 §SB-03/SB-04 )

> **SB-02 fue AUDITORÍA, NO FIX.** No edité `CHECKLIST-GLOBAL.md` ni los 167 `05-Checklist.md`.
> Invariante verificado **sin modificar** al cierre: `EOL=CRLF · BOM=False · CR-suelto=218`
> (idéntico al declarado por el director). Los fixes son del director / agnes-3-flash.
>
> **SB-03 fue solo lectura.** No edité `03-Diseno.md` de M152, ni escenas, ni el GLOBAL.
>
> **SB-04 sí escribió** en `152/plan-actual/` (creó `desviaciones_justificadas.md`).
>
> **No tocar:** `quality.yml` (s2) · **M53** (mimo) · **M130** (Hy3) · filas `🔵`/`🔴`.
> **CERO afirmaciones visuales** hasta que el fundador pruebe la visión (prueba prevista 2026-10-05).

### ✅ SB-02 — Auditoría GLOBAL ↔ 05-Checklist — `[x]` Log **1279**

**Resultado:** 167 filas ↔ 167 checklists, 1:1.

| Verificación | Resultado |
|---|---|
| (1) Drift de progreso `N/M` | **0 de 167** — el GLOBAL es la fuente correcta |
| (2) Filas mal formadas | **58 de 167 (34,7 %)** — 18 faltan · 40 sobran · 6 sin `\|` final |
| (3) `✅` con trabajo pendiente | **8** (3 con `[?]` + 5 con `[ ]`) → violan DoD §21.6 |
| (3) `🔵`/`🔴` colgados >24 h | **0** |
| (4) Bloques `Totales` que mienten | **14 bloques en 13 módulos** (+2 falsos positivos míos, descartados) |

**Causa raíz de (2):** pipes `\|` **sin escapar** en la columna `Notas` (40 filas) → al parsear por
posición, `Agente actual` y `Última actividad` reciben basura. Peor caso: L30 `01-Fundamentos`
tiene el modelo en la columna de fecha y la fecha en la del modelo.

**Descartado por el director ya:** fila 53 (mimo la reconstruyó → 11 celdas, `🟢 Disponible` 139/165).

**Autocrítica:** el script automático dio **127** "Totales que mienten" por un bug de parseo (comparaba
el **total** contra los **completados**), más 18 violaciones DoD falsas (`contains("✅")` en vez del
emoji inicial) y 7 filas de leyenda contadas como módulos. **Verifiqué a mano antes de reportar** y
quedaron **80 hallazgos defendibles**.

### ✅ SB-03 — Condición del Ejemplo 3 (mapa ×10) — `[x]` Log **1278**

> Condición: «Ampliar mapa **solo si** se agregan NPCs, recursos, misiones en **nuevas áreas**».

**Veredicto: PARCIAL (2 de 3).** Centro (2560,2560) · umbral área vieja `r ≤ 256` · orilla `r ≈ 1700`.

| Tipo | Veredicto | Radios |
|---|---|---|
| NPCs (fauna) | ✅ CUMPLIDA | `fauna_spawner.gd` L54-68 → 3 zonas: [1588..2088], [1546..1786], [1680..1880] |
| Recursos (M15) | ✅ CUMPLIDA | `main_island.gd` L71 → r = 1838 · vegetación [638..3038] · crafting r = 1844 |
| Misiones (M22) | ❌ NO CUMPLIDA | `historia_principal.json` = grafo narrativo, **0 coordenadas**. Ídem M160 |

**Conclusión:** la ampliación **no** fue «hacerse grande» (hay NPCs y recursos reales en el área
nueva). Lo que falta es la tercera pata, por una **deuda de modelo de datos**: M22 y M160 nunca
tuvieron anclaje espacial. → **D-R2 debería cerrarse como PARCIAL**, con la deuda en M22/M160/M167.

**Hallazgo colateral nuevo:** `data/ubicaciones/ubicaciones.json` tiene las 10 entradas con
coordenadas del **sistema viejo** (256,256 · 350,350 · 1024,256…) que con el centro nuevo caen a
**r = 2085..3338 = todas en el agua**. **No tiene ningún consumidor** → dato muerto. Recomendé
borrarlo.

### ✅ SB-04 — Registro de desviaciones — `[x]` Log **1280**

**Creado `DOCUMENTACION/152-Principios-Innegociables/plan-actual/desviaciones_justificadas.md`**
(plantilla de `03-Diseno.md` §5). Primera entrada real del proyecto.

| ID | Decisión | Principio desviado | Aprobado por |
|---|---|---|---|
| **D-R1** | Agregar combate (`164-Isla-De-Combate-Endgame`) | `02-Vision` §1 + `01-Fundamentos` §11 dec. 1 | **Fundador** |
| **D-R2** | Ampliar mapa ×10 | Ejemplo 3 del propio M152 | **PENDIENTE** (PARCIAL) |

- **Justificación D-R1:** el combate existe pero **no es letal** (§4 de M164: sin penalidad, sin
  game over, sin perder objetos) → mantiene el principio de fondo.
- **Nota de que `D001` de la plantilla era FICTICIO** (placeholder leído como hecho).
- **3 tareas de plan** surgidas: P1 anclar M22 · P2 anclar M160 · P3 limpiar `ubicaciones.json`.

### ⚠️ Incidente de numeración de logs (relevante para toda la flota)

1. **Colisión del 1276** entre Hy3 y yo (el protocolo §6.1.a **no es atómico**). El director la
   resolvió reservando el 1279 y renombrando mi log; **yo ajusté el header interno** para que diga
   1279 y añadí la explicación.
2. **El pool volvió a tener BOM**, pegado a la línea `1280` que tomé. Reservé `1280` con `.Trim()`
   (válido), pero un agente que no haga strip consume un número corrupto.
3. **Propuesta al director:** (a) reserva atómica con `os.mkdir()`; (b) o derivar el número del
   timestamp y quitar el pool como contador; (c) **validador de duplicados en `Logs/`** — recorrer
   `*.md`, extraer el número del título, avisar si hay dos. Son 10 líneas y habría detectado mi caso.

### M153 — Objetivo-Final (10 ítems) — ⏭ cierre de sesión

### M151 — Control-Final (141 ítems) — candidato tras SB-03

**Los 2 `[?]` de M151 son prioridad**: leer las `## Notas del Agente` de su `plan-actual/` para
entender por qué no se resolvieron antes de tocar nada.

---

## Frentes (histórico — orden original, RESERVADO por las 03/04)

> Esta sección conserva el plan original. Los números SB-02/SB-03 **cambiaron de significado**
> (ver §Frente vigente). Sirve como trazabilidad de lo que se pensaba al dar de alta.

### SB-01 — M152-Principios-Innegociables — ✅ CERRADA (58 `[x]` + 29 `[?]`)

**Log 1270 CREADO:** `Logs/1270-M152-SB01-VERIFICACION-87-PRINCIPIOS_2026-10-04_09-55-00.md`.
Reservé **1270** (leí la primera línea de `Logs/NUMEROS_DISPONIBLES.txt`, la **BORRÉ**; cabeza ahora
1271) y lo consumí. Protocolo §6.1.a y §6.1.b cumplidos.

**Resultado:** los **87 `[ ]`** verificados por familia contra diseño real →
**58 `[x]` + 29 `[?]`**; el módulo queda en **173 `[x]` · 29 `[?]` = 202** (era 115/87).
Ningún `[?]` con dueño externo: confirma la auditoría de atria-dawn-s2 §1.

**Entregables:**
- `05-Checklist.md` → 87 marcas in situ + apéndice `## Verificación SB-01` (evidencia por familia).
- `03-Diseno.md` → §11 (4 emparejamientos erróneos, contrato roto M59↔M107, 2 desviaciones reales
  D-R1/D-R2 sin registrar, reducción de alcance de `docs/`, piezas de gobernanza a reusar).
- `04-Codigo.md` → §14 Notas del Agente (8 hallazgos con dueño + 5 recomendaciones).
- `CHECKLIST-GLOBAL.md` fila 152 → `🟡 Liberado (SB-01)`, 173/202, agente `—`.
- `scripts-prueba/marcar_principios_sb01.py` + `apendice_sb01.md` (reproducible, con guardas).
- Informe al director: canal `space-bunny-alpha/02-2026-10-04_09-55-00-verdicto-m152.md`.
- Entrada de cierre en `ESTADO-PARALELO.md`.

**Estado:** `[x]` (SB-01 entregada). **Bloqueo liberado** en los 4 registros.
**Siguiente frente disponible:** SB-02 (M153-Objetivo-Final, 10 ítems, complejidad 2) o SB-03
(M151-Control-Final, 139 pendientes + 2 `[?]` a leer primero).

Módulo filosófico: 87 ítems `[ ]` que son **restricciones de diseño** ("No convertir el juego en
un survival de hambre...", "No diseñar la economía alrededor del grind...") + **artefactos a
diseñar** (`docs/licencias_assets.md`, `docs/knowledge_sharing.md`, proceso de revisión de
decisiones, registro de desviaciones).

**El trabajo NO es implementar código.** Es, para cada principio:
1. **Verificar consistencia:** ¿el diseño actual del juego (en los `plan-actual/` de los módulos
   relevantes) cumple o viola el principio? **Usá tu contexto 1M:** cargá los principios + el
   diseño del módulo correspondiente en una sola pasada y citá evidencia.
2. **Documentar el veredicto** en el `05-Checklist.md` de M152 (notas in-place, sin mover líneas)
   y en `03-Diseno.md`/`04-Codigo.md` del plan-actual.
3. **Marcar `[x]`** solo si el principio está verificado contra diseño real. Si el diseño lo viola
   o no existe → **`[?]` con evidencia** (NO marcar como hecho).
4. **Artefactos faltantes** (los "Diseñar X"): si `docs/licencias_assets.md` no existe, crealo
   (M83/M127 ya tienen escaneo de licencias — reusá, no dupliques).

**Reportás a través del canal** (`Mensajes entre modelos/space-bunny-alpha/`, archivo NN con
veredicto + autoevaluación honesta de primera sesión).

### SB-02 — M153-Objetivo-Final (10 pendientes) — SIGUIENTE

10 ítems sobre el objetivo final del juego. Trabajo de verificación documental corto.

### SB-03 — M151-Control-Final (139 pendientes + 2 `[?]`) — DESPUÉS

Control final del proyecto. **Los 2 `[?]` son prioridad**: leer las `## Notas del Agente` del
plan-actual de M151 para entender por qué no se resolvieron antes de tocar nada.

---

## Reglas de marcado

- `[ ] T-###` → pendiente
- `[→] T-###` → en progreso (bloqueada por vos)
- `[x] T-###` → completada (con evidencia: log + nota en el módulo)
- `[?] T-###` → no resuelta (con razón y dueño)

**Al completar una tarea T-###, marcar los 3 lugares** (§29):
1. Este checklist (`TAREAS-POR-MODELO/space-bunny-alpha/<módulo>/checklist.md`)
2. El `05-Checklist.md` del módulo
3. La fila de `CHECKLIST-GLOBAL.md` (progreso)

## Reserva de logs

Cada tarea completada necesita un Log en `Logs/`. Protocolo §6.1.a: **leer la primera línea de
`Logs/NUMEROS_DISPONIBLES.txt`, BORRARLA del archivo, y guardarte el número en este backlog**.
Nunca tomes un número sin borrarlo (colisión). Nunca asumas la cabeza: leé el archivo cada vez.
La cabeza actual al momento de escribir este archivo es **1258** — corroborá, podría haber
cambiado.

## Notas del director (atria-dawn-preview, 2026-10-04)

- **M130-Artbook NO es tuyo** — lo recluté para tu QA inicial pero ya está `🔵` bloqueado por otro
  agente (Hy3 lo tiene en su cola). Por eso SB-01 es M152. Si M130 se libera y Hy3 no lo toma, te
  lo puedo pasar.
- **Tu primera entrega es la más importante.** No hay benchmarks de vos; tu desempeño en SB-01 es
  la única evidencia. **Honestidad brutal** en la autoevaluación: si no podés verificar algo,
  decilo.
- **Regla de codificación UTF-8 sin BOM** (AGENTS.md §28). Si tu plataforma escribe cp1252, pará y
  avisá — no toques el repo.
- **No firmes con otro nombre de modelo.** Tu identidad es space-bunny-alpha. Si tu plataforma
  tiene un `IDENTITY.md` compartido (caso WorkBuddy), ignoralo — manda esta carpeta.
