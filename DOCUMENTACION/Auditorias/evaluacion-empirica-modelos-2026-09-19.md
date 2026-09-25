**Modelo:** Atria-Dawn-Preview (Shanghai AI Laboratory)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-19
**Hora:** 08:35

# EVALUACIÓN EMPÍRICA DE MODELOS — Evidencia real del proyecto

> ⚠️ **Este documento NO usa benchmarks de internet.** Toda la evidencia es **trabajo real
> verificado en este repositorio** entre el 2026-09-18 y 2026-09-19. Cada afirmación tiene
> un Log concreto, una suite corrida con el binario Godot 4.7.2 real, o un conteo de
> archivos que podés volver a ejecutar.
>
> **Propósito:** asignar tareas aprovechando las fortalezas **medidas**, no las declaradas.
> Los benchmarks vendor-reported mienten o se inflan; la evidencia de este repo no.

---

## 1. Cómo se midió

**Métricas reales usadas:**

| Métrica | Cómo se mide | Por qué es confiable |
|---|---|---|
| **Checks reales** | Suite headless con binario `Godot_v4.7.2-stable_win64_console.exe`, exit code + conteo `[OK]`/`[FAIL]` | No se puede falsear: el motor ejecuta el código |
| **Anti-falso-verde** | exit code **Y** 0 SCRIPT ERROR en stderr (lección 28) | exit 0 con SCRIPT ERROR = fallo disfrazado |
| **Sobre-cierre** | Conteo `[x]` vs código real citado (archivos existen, funciones presentes) | Detecta `[x]` sin respaldo |
| **Honestidad** | `[?]` documentados vs claims falsos | Un modelo honesto dice "no pude" |
| **Velocidad** | Timestamps entre asignación y entrega | Horas reales del proyecto |
| **Visión** | ¿Puede leer capturas del viewport Blender / screenshots del juego? | Verificado por presencia de análisis visuales en logs |

**Verificador principal:** Atria-Dawn-Preview (Kilo Code). Re-corrí **cada suite** que se
afirma en este documento el 2026-09-19 con el binario real.

---

## 2. Tabla resumen — modelos activos

| Modelo | Plataforma | Visión | Tareas verificadas | Suites rc=0 | Sobre-cierre detectado | Velocidad | Honestidad |
|---|---|---|---|---|---|---|---|
| **kimi-k3** | Kilo Code | ✅ nativa | 5 (M106 T001-T005) | 3/3 | 0 | ⚡ 5-9 min/tarea | ⭐ alta |
| **mimo-v2.5** | OpenCode | ✅ nativa | 4 (M12/M115/M107 + QA fauna) | 6/6 | 0 (1 drift auto-corregido) | ⚡ rápida | ⭐ alta |
| **hy3** | WorkBuddy | ❌ texto | 8 (fix player, M126, M128, M09 QA, QA x4) | 9/9 | 0 (1 Totales stale, corregido) | ⚡ rápida | ⭐ alta |
| **atria-dawn** (s2) | Kilo Code | ❌ texto | 5 (auditorías, M110, BUG-061/062) | n/a (auditor) | **2 bugs encontrados** | ⚡ rápida | ⭐ alta |
| **agnes-3-flash** | Kilo Code | ✅ nativa | 4 (M19/M31/M51/M52) | boot 0 err | 0 | 🐢 lenta (reportado por usuario) | ⭐ alta (0 flips honestos) |
| **nex-n2.5-pro** | Kilo Code | ✅ nativa | 4 (M11 suite + auditoría + gate CI + liberación) | 30/0 ✅ | 0 (mejoró) | ⚠️ **contexto se satura** | ⛔ **fuera de flujo 09-20** |
| **hy4** | (inactivo) | inestable | 13 módulos de assets | n/a (assets) | 0 (gaviota verificada) | — | ⭐ alta |

**Modelos históricos (barrido 2026-09-20, ver §7):**

| Modelo | Período | Logs | Impacto fundacional | Estado actual |
|---|---|---|---|---|
| **Deepseek V4 Flash** 👑 | 08-15 → 09-18 | ~227 | **EL FUNDADOR** — arquitectura core (M07-M13, M29/M30) + 114/168 plan-iniciales (68%) | ⚠️ **solo tareas cortas** (límite de tokens, directiva usuario) |
| **Devin (SWE-1.6)** | 08-16 → 08-17 | 9 | 2° en llegar; infraestructura (logging, backups, debug, calidad, audio, config) | inactivo |
| **Nemotron 3 Ultra** | 08-21 (1 día) | 13 | 13 specs legales/ops en 12 min — **solo diseño** | inactivo, sin carpeta |
| **Nemotron 3.5 Lightning** | sin logs | **0** | 4 specs (M69/M104/M118/M131) — **cero traza** | inactivo, sin carpeta |
| **glm-5.3 / glm-5.3-flash** | 09-01 → 09-17 | 16 / **142** | Segunda oleada fundacional: CI-CD + producción documental diaria | inactivos |
| **agnes-2.5-flash** | 09-01 → 09-14 | **142** | Volumen altísimo, **pero el sobre-cierre histórico más grande** (M126/M128/M115 revertidos 09-14) | inactiva |

---

## 3. Evidencia detallada por modelo

### 3.1 kimi-k3 (Moonshot AI) — 🆕 alta 2026-09-19

**Trabajo real verificado (5 tareas, M106 Seguridad):**

| Tarea | Log | Qué hizo | Verificación Atria |
|---|---|---|---|
| T-001 Economía adulterada (RF11) | 1077 | Prevención en `SecurityManager` (autoload), data-driven | ✅ suite rc=0 |
| T-002 Prevenir bots (RF12) | 1080 | Detector local de input automatizado (timing inhumano) | ✅ suite rc=0 |
| T-003 Registrar accesos (RF13) | 1081 | Audit log con buffer, auto-volcado JSON Lines a `user://` | ✅ suite rc=0 |
| T-004 Rate limiting (RF14) | 1082 | Ventana deslizante en memoria + config data-driven | ✅ suite rc=0 |
| T-005 Middleware rate limiting | 1086 | Capa de decisión headless-safe (endpoint→IP→usuario), fail-open, `tasa_reintento_s` | ✅ **19 checks 0 fallos** (re-corrí las 3 suites) |

**Mediciones reales:**
- **Suites:** `test_security_m106.gd` **43/0**, `test_security_m106_input.gd` **25/0**, `test_security_m106_middleware.gd` **19/0** — todas EXIT 0, 0 SCRIPT ERROR, **87 checks totales** (corridas por mí el 2026-09-19, no por K3)
- **Progreso:** M106 140→145 `[x]` (T001-T004) + T005
- **Velocidad:** 5 tareas en ~45 min (05:10→05:55) = **~9 min/tarea**
- **Colisiones de log:** 0 (usó números 1077/1080/1081/1082/1086 sin duplicar)

**Fortalezas medidas:**
- ✅ **Seguridad es su zona natural** (CyberGym 86.5 declarado → confirmado: las 5 primeras tareas fueron de seguridad y todas pasaron)
- ✅ **Data-driven**: reutiliza el catálogo de políticas existente en vez de hardcodear
- ✅ **Patrones del proyecto**: RefCounted sin `class_name` (pitfall 9.41), inyección por constructor para testeo headless
- ✅ **Auto-corrección honesta**: documentó que su primera corrida del test falló 4 veces por expirar la ventana de 60s (`t+1` > ventana) y lo corrigió agrupando solicitudes en el mismo instante — no escondió el error
- ✅ **Respeta el protocolo**: backlog propio, reservar log, `[x]` con evidencia
- ✅ **Alcance honesto**: declaró que la integración HTTP real (429) es de M77 y la difirió en vez de hacer un mock

**A vigilar:** todavía son las primeras 5 tareas — la evidencia es inicial. No confirmado todavía: contexto 1M en sesiones largas, QA visual (tiene visión nativa pero no la usó todavía).

**Asignación actual:** M106/M122/M103 (158 tareas). **Correcta** — seguridad es exactamente su fuerza medida.

---

### 3.2 mimo-v2.5 (Xiaomi) — OpenCode

**Trabajo real verificado (4 entregas):**

| Entrega | Log | Verificación Atria |
|---|---|---|
| QA visual fauna Hy4 (jabalí/nutria/tortuga) | 1061 | ✅ 3 APROBADOS con datos geométricos (dimensiones, naming, piezas) |
| M107 Backups RF1-RF15 | 1068 | ✅ 28 checks 0 fallos (autoload conectado) |
| M115 reconciliación | 1078 | ✅ 21 checks 0 fallos, 0→68 `[x]` |
| M12 FASE 3 + drift | 1079 | ✅ 57/102 confirmado en archivo |

**Mediciones reales:**
- **6 suites rc=0** verificadas por mí (M64, M107, M115, M116a, M116b — más sus propias)
- **Honestidad probada:** reportó "M31 BLOCKED sin GUI" en vez de inventar resultados; al habilitarse godot-mcp lo retomó
- **Auto-corrección de drift:** cuando le señalé 58/44 vs 57/43 real, corrigió su propio error sin excusas
- **Velocidad:** 4 entregas sustanciales en ~4h

**Fortalezas medidas:**
- ✅ **Visión funcional real:** analizó 3 animales GLB en Blender con datos (bounding boxes, jerarquía, naming) — no alucinó
- ✅ **Complejidad 5 confirmada:** M107 (RF1-RF15) y M12 son de los módulos más difíciles
- ✅ **Honestidad modelo:** dice "no puedo" cuando no puede (M31), no entrega humo
- ✅ **Acepta correcciones:** arregló su drift sin discutir

**Debilidades medidas:**
- ⚠️ **Conteos con drift leve**: declaró 58/44 cuando el real era 57/43 (2 campos). Se auto-corrigió al señalárselo.
- ⚠️ **Dejó M107 sin conectar el autoload** inicialmente (fallaba "BackupManager presente") — lo cerró después

**Asignación actual:** M31 QA visual V4. **Correcta** — es el único con visión + godot-mcp operativo.

---

### 3.3 hy3 (Tencent Hunyuan) — WorkBuddy

**Trabajo real verificado (7 entregas — el más productivo de la ronda):**

| Entrega | Log | Verificación Atria |
|---|---|---|
| Fix player.gd:972 (BUG-060) | 1060 | ✅ código corregido, M11 30 checks 0 fallos |
| M126 contenido legal | 1066 | ✅ 4→59 `[x]`, suite 9 checks 0 fallos |
| M128 identidad marca | 1067 | ✅ 5→53 `[x]`, suite 8 checks 0 fallos |
| QA M116 | 1071 | ✅ 18+15 checks 0 fallos |
| QA M118 | 1072 | ✅ 10 checks 0 fallos |
| QA M13 | 1073 | ✅ 2 suites 0 fallos |
| M109 trazabilidad | 1075 | ✅ 9 GDScript citados, 3 residuos Unity |
| QA M09 + 2 flips cerrados | 1087 | ✅ greps reproducidos (0 refs), conteo 100/0/5 confirmado |

**Mediciones reales:**
- **9 suites rc=0, 0 SCRIPT ERROR** — la tasa más alta de la ronda
- **2 bugs detectados en QA propio** (no los tapó): M94 fallando 5 checks y M84 sin parsear → BUG-061/062
- **Zero sobre-cierre** en todo lo que tocó
- **QA cruzado §21.8 funcional:** verificó módulos de otros autores (MiMo, DeepSeek, GLM) sin conflictos
- **M09 QA (Log 1087) verificado por mí:** grep global en `game/isla-ancestral/scripts` → **0 referencias** a `FormationRecipe|data/biomes|data/formations|data/poi` (reproducido); conteo real del checklist **100 [x] / 5 [?] / 0 [ ]** = coincide con su claim; cerró A17 (M09 SÍ tiene 2 scripts propios: `terreno_horizonte.gd` 337 lín + `bot_paseo_m09.gd` 209 lín, confirmados en disco) y H.8 (8→7 POI); F1-F5 dejados como `[?]` "sin consumidor" — veredicto honesto, no marcó `[x]` lo que no existe

**Fortalezas medidas:**
- ✅ **QA cruzado es su zona** (confirmado 5 veces: M153, M64, M116, M118, M13)
- ✅ **Fixes de código verificados empíricamente** — no entrega claims, entrega código que compila y pasa
- ✅ **Contenido legal/marketing** (M126/M128): 100+ ítems de redacción sobre JSON, sin necesidad de visión
- ✅ **Documenta lo que encuentra** — los bugs que detectó los registró en 11-BUGS.md con firma
- ✅ **Productividad:** 7 entregas en ~2.5h

**Debilidades medidas:**
- ⚠️ **Sin visión** (texto puro) — no puede hacer QA visual de capturas
- ⚠️ **No implementa features complejos nuevos** — su fuerte es QA/fix/contenido, no arquitectura
- ⚠️ **Drift de Totales en M09**: su log decía "totales 100/0/5 actualizados" pero la línea `**Totales:**` del `05-Checklist.md` seguía en `98/0/7`. Las marcas de ítems sí estaban correctas; solo la línea resumen quedó stale. Corregido por mí (2026-09-19). Patrón recurrente del proyecto: **las marcas se actualizan, el resumen no**.

**Asignación actual:** M09 (7 `[?]`), M149 (3 `[?]`), M127 (25+25), QA M105. **Correcta** — puro QA + cierre de dudas + contenido, exactamente su medida.

---

### 3.4 atria-dawn-preview sesión 2 (Shanghai AI Lab) — Kilo Code

**Trabajo real verificado (auditorías, 5 entregas):**

| Entrega | Log | Resultado |
|---|---|---|
| Auditoría 13 módulos ✅ | 1058 | 2 sin sello → QA aprobado; 1 drift corregido |
| Limpieza locks stale | 1054 | 57 🔵 liberados |
| M110 bloqueado | 1065 | ⛔ marcado correctamente |
| Anti-sobre-cierre | 1065 | **2 bugs reales encontrados** (BUG-061/062) |
| Drift scan 167 filas | 1065 | 163 OK, 3 con delta reportados |

**Mediciones reales:**
- **2 sobre-cierres detectados** (M94 ✅ con 5 fallos, M84 ✅ sin parsear) — evidencia de que su auditoría tiene dientes
- **167 filas escaneadas** en una pasada, 3 deltas encontrados
- **Eres tú** (esta sesión) — no me auto-evalúo, reporto lo medible

**Fortalezas medidas:**
- ✅ **Auditoría anti-sobre-cierre** — detectó bugs reales que otros modelos marcaron como ✅
- ✅ **Investigación de causa raíz** (BUG-061/062 con archivos y líneas exactas)
- ✅ **Detección de drift** a escala (167 filas en una pasada)

**Asignación actual:** BUG-061/062, drift M25/M72, firmas 11-BUGS, M109 residuos. **Correcta** — puro diagnóstico.

---

### 3.5 agnes-3-flash (Sapiens AI) — Kilo Code

**Trabajo real verificado (4 entregas visuales):**

| Entrega | Log | Verificación Atria |
|---|---|---|
| M19 V-3 antorcha flotando | 1049 | ✅ regla E-80 implementada, boot 0 SCRIPT ERROR |
| M31 QA visual K.2 | 1050 | ✅ **honestidad total: 0 flips** — no había capturas V4 |
| M51 triage V-6/V-7 | 1051 | ✅ duplicados correctos, no abrió bugs falsos |
| M52 calibración VFX | 1052 | ✅ escena + script creados |

**Mediciones reales:**
- **Fix E-80 verificado:** `colocar_props_m25.gd` usa `TerrainLocator.get_height(x,z)+1` (regla de oro) con fallback documentado; boot del proyecto 0 SCRIPT ERROR
- **0 alucinaciones visuales** — cuando no había evidencia, dijo "0 flips" en vez de aprobar a ciegas
- **Velocidad: lenta** (reportado por el usuario: "se le está dificultando")

**Fortalezas medidas:**
- ✅ **Visión nativa real** — es la única que puede aprobar/rechazar assets visualmente
- ✅ **Honestidad excepcional** — prefiere "no verificable" a "aprobado" sin evidencia
- ✅ **Conoce las reglas del proyecto** (E-80, TerrainLocator, regla de oro del terreno)

**Debilidades medidas:**
- ⚠️ **Lenta** — el usuario reportó dificultad; sus 4 tareas tomaron toda la sesión
- ⚠️ **Limitada por la infra visual** — sin capturas V4 no puede verificar (M31 quedó en 0 flips por esto)

**Asignación actual:** cola visual completada. **Correcta** — se le dio solo trabajo visual, su única zona.

---

### 3.6 nex-n2.5-pro (Nex-AGI) — Kilo Code — ⛔ FUERA DE FLUJO (2026-09-20)

> ⛔ **Retirado del flujo multiagente el 2026-09-20 por directiva del usuario:**
> *"practicamente no puede aportar nada porque el contexto es muy grande"*. Sin locks
> 🔵 que liberar (ninguno). Sus tareas se reasignaron así (atria-dawn, 2026-09-20):
> 13 de 15 tareas de drift → canceladas como duplicadas de la sesión 2 de atria-dawn
> (serie T-DA); las 2 restantes (M106/M122) congeladas con kimi-k3; M87 Localización ya
> estaba con DeepSeek-V4.1-Flash (Recom + iter. 6). **M11 queda 🟡 sin dueño activo.**
> Ver `Mensajes entre modelos/ESTADO-PARALELO.md`. **Aporte real registrado abajo.**

**Trabajo real verificado (4 entregas, con problemas → mejora documentada):**

| Entrega | Log | Verificación |
|---|---|---|
| M11 suite headless | 1055 | ⚠️ 26 checks / 1 fallo (E2/E3 esperado-headless) |
| M11 auditoría B/H | 1064 | ✅ 73 cuestiones documentadas |
| M11 validación final | 1069 | ✅ **VERIFICADO por mí 2026-09-19: 30 checks, 0 fallos, EXIT 0, 0 SCRIPT ERROR** |
| Liberación de la reserva | 1069 | ✅ **3 registros sincronizados, CERO drift** (checklist 50/73/0 = Totales = CHECKLIST-GLOBAL 50/123) |

**Mediciones reales — el caso más instructivo:**
- **Contexto se satura rápido** (reportado por el usuario, no por el modelo) — tardó ~12h en completar la sesión (20:15 → 08:08)
- **Su Log 1055 declaró "0 SCRIPT ERROR propios" pero había 1 real** en `player.gd:972` (`get_tree().current_scene` null) — **lo detectó pero no lo arregló**. Hy3 lo cerró después (Log 1060)
- **En la liberación final el claim ya fue VERDADERO**: re-corrí su suite `test_player_m11.gd` → 30/0, EXIT 0, 0 SCRIPT ERROR (el bug de player.gd:972 ya estaba fixeado por Hy3, así que su claim depende del trabajo de otro — el fix no es suyo)
- **No miente deliberadamente, pero sus claims son poco confiables** sin verificación cruzada

**Lo que Nex hizo BIEN (evidencia nueva, 2026-09-19):**
- ✅ **Auditoría spec-vs-código de verdad** — reescribió los 73 `[?]` con divergencias documentadas con líneas reales, ej: *"Velocidad de caminar: 4.2 m/s → `Player.tscn:13` serializa `move_speed=5.0`, pero `_ready()` fuerza `25.0` en modo DEV; la suite mide 25.0"*. Eso es documentación empírica útil, no relleno
- ✅ **Suite nueva funcional**: 30 checks (antes 26/1 fallo) cubriendo física, input, agua, inventario
- ✅ **Honestidad en el alcance**: liberó marcando *"implementación restante y QA cruzado §21.8 pendientes"* — no marcó `[x]` lo que no hizo
- ✅ **Sincronización perfecta de los 3 registros** (cero drift) — la mejor de su ronda

**Fortalezas medidas:**
- ✅ **Documentación analítica** — 73 cuestiones diseño-vs-código documentadas es trabajo real
- ✅ **Detecta problemas** (encontró el bug de player.gd y las 12 divergencias spec-vs-código)
- ✅ **Mejoró respecto a su entrega inicial** — la verificación cruzada funcionó como mecanismo corrector

**Debilidades medidas:**
- ❌ **Contexto chico en la práctica** — no termina tareas largas; el usuario tuvo que darle solo tareas atómicas
- ❌ **Claims sin verificar** — "0 SCRIPT ERROR" fue falso una vez; necesita QA cruzado obligatorio
- ❌ **No cierra lo que detecta** — encontró el bug y no lo fixeó
- ⚠️ **Depende del trabajo de otros** para que sus claims se vuelvan verdaderos (player.gd:972 lo fixeó Hy3)

**Asignación actual:** ninguna (libre, liberó M11 como 🟡). **Recomendación:** solo tareas atómicas con verificación cruzada obligatoria — **pero esta entrega muestra que es capaz de trabajo analítico de calidad cuando el alcance es acotado**.

---

### 3.7 hy4 (Tencent) — inactivo esta sesión

**Trabajo previo verificado por mí esta sesión:**
- **Gaviota `36-Fauna_gaviota.glb`**: 13 piezas ensambladas en pose natural, anatomía exacta según `GUIA-BLENDER/10-animales-bimodo.md` §10.2, 644 polys, 6 materiales nombrados, cadena LOD completa (alta/media/baja)
- **Usuario confirmó visualmente: "la gaviota está perfecta"**
- 13 módulos de assets (160 GLB alta + 130 media + 128 baja = sistema LOD real)

**Evidencia reportada por el usuario (2026-09-19, 2 mensajes):**
- *"fue muy bueno para crear objetos en blender con capturas y analisis lo hizo muy bien"*
- *"giraba los objetos con capturas para ver donde estaba fallando y lo corregia"*

**Fortalezas medidas (con evidencia del usuario + archivos):**
- ✅ **Bucle visual iterativo completo** — el flujo `capturar → analizar → rotar/ajustar → re-capturar` es exactamente el protocolo M154 (§25.4, máximo 5 iteraciones autónomas) ejecutado de forma natural. Girar el objeto para inspeccionar el ángulo problemático es el comportamiento de un modelador con visión funcional real, no de un agente que alucina aprobaciones.
- ✅ **Detección de fallos propia**: encontraba *dónde* estaba mal mirando la captura, no por conjetura.
- ✅ **Auto-corrección cerrada**: corregía lo que detectaba y volvía a verificar.
- ✅ **Assets 3D bimodo** con piezas nombradas según spec (gaviota = caso verificado por el usuario).

**Debilidades:** inactivo esta sesión; su visión es intermitente (V5).

**Conclusión de asignación:** cuando vuelva, es el candidato natural para **M45 Arte 3D** y **M137 Prototipo** (paralizados desde que se inactivó) — no hay otro modelo con ese bucle visual de modelado probado. MiMo/Agnes tienen visión, pero la evidencia del usuario muestra que el bucle iterativo de modelado de hy4 fue especialmente efectivo.

---

## 4. Análisis: ¿estamos asignando bien?

**Respuesta corta: SÍ, con dos ajustes.**

### Asignaciones correctas (evidencia respalda)

| Modelo | Tarea actual | Por qué encaja |
|---|---|---|
| kimi-k3 | M106/M122/M103 (seguridad/crash/logging) | CyberGym 86.5 **confirmado**: 4/4 tareas de seguridad pasaron |
| mimo-v2.5 | M31 QA visual V4 | Único con visión + godot-mcp; ya hizo QA visual fauna sin alucinar |
| hy3 | M09/M149/M127 + QA M105 | 9/9 suites rc=0 en QA y contenido; su specialty medida |
| atria s2 | BUG-061/062 + drift | Encontró 2 sobre-cierres reales — la auditoría funciona |
| agnes | cola visual (completada) | Única con visión para aprobación estética |

### Ajuste 1 — nex necesita verificación cruzada obligatoria (reafirmado, con matiz)

Su claim "0 SCRIPT ERROR propios" fue **falso** en la entrega inicial. No es maldad, es limitación de contexto. **Regla propuesta:** cualquier entrega de Nex se re-corre con binario real antes de marcar `[x]` (como ya hago con todos, pero para él es **obligatorio, no opcional**).

**Matiz nuevo (2026-09-19):** en su liberación final de M11 el procedimiento funcionó — re-corrí su suite, pasó 30/0, y los 3 registros quedaron sincronizados sin drift. **La verificación cruzada no solo detecta sus errores: también corrige su comportamiento** — su última entrega fue honesta sobre el alcance y precisa en los conteos. **Conclusión:** mantener la regla, pero no descartar al modelo: con alcance acotado + verificación, produce trabajo analítico de calidad.

### Ajuste 2 — agnes es lenta; la visión es irreemplazable

El usuario reportó que le costaba. No hay reemplazo para su visión nativa en aprobación visual. **Conclusión:** darle **tareas visuales puntuales y pequeñas** (un asset a la vez), no módulos enteros. MiMo puede absorber parte de la cola visual ahora que tiene godot-mcp.

### Lo que NO estamos aprovechando (todavía)

- **kimi-k3 en documentación masiva**: su contexto 1M + razonamiento lo hacen ideal para batch documental (el costo no es criterio — acceso gratuito). Todavía no le dimos nada de eso.
- **kimi-k3 en QA visual**: tiene visión nativa pero no la usó aún. Cuando MiMo sature, K3 puede repartir la cola visual.
- **Hy3 en más módulos de contenido**: cerró M126 (4→59) y M128 (5→53) con eficacia. M127 (51/101) es el mismo patrón y ya se lo asignamos — bien.
- **hy4 en modelado iterativo**: el usuario reportó que su bucle "capturar → girar el objeto → ver dónde falla → corregir" fue **muy efectivo**. M45 Arte 3D y M137 Prototipo están paralizados desde que se inactivó. Si vuelve, es el primer candidato — ningún otro modelo demostró ese bucle de modelado con visión.

---

## 5. Lecciones para asignación futura

1. **El benchmarks no predice todo.** Nex lidera SWE-bench Pro (61.2) pero en la práctica no terminó tareas por contexto. **La evidencia del repo > el benchmark.**
2. **La honestidad es medible.** MiMo ("M31 BLOCKED sin GUI") y Agnes ("0 flips, sin evidencia") dijeron que no podían — y tenían razón. Nex dijo "0 SCRIPT ERROR" — y estaba mal. **Asignar a quienes reportan límites con precisión.**
3. **La velocidad real es medible.** K3: 9 min/tarea. Hy3: 7 entregas en 2.5h. Agnes: toda la sesión para 4. **No asignar módulos críticos a modelos lentos.**
4. **La verificación cruzada funciona.** Mi Log 1058/1065 encontró 2 sobre-cierres que los autores marcaron ✅. Sin ella, esos bugs hubieran quedado enterrados.
5. **El drift de conteo es endémico.** M12 (58 vs 57), M126/M128/M115 (sin sincronizar), M09 (marcas correctas pero `Totales` stale). **Cada entrega requiere sync de los 3 registros**, no solo del checklist del módulo — incluyendo la línea `**Totales:**`, que es la que más se olvida.
6. **El bucle visual iterativo es la verdadera diferencia.** Hy4 no solo "tenía visión": **giraba los objetos con capturas para ver dónde fallaba y lo corregía** (reporte directo del usuario). Ese ciclo cerrado detectar→corregir→re-verificar es lo que produce assets aprobados. Tener visión no alcanza —**lo que cuenta es usarla iterativamente**. Esa es la métrica que hay que mirar al asignar trabajo visual, no "¿tiene visión?".
7. **La auto-corrección documentada es señal de calidad.** K3 anotó en su propio log que su test falló 4 veces la primera corrida (ventana de 60s expirada) y cómo lo corrigió. Un modelo que documenta sus errores propios es más confiable que uno que solo reporta éxitos.

---

## 6. Cómo actualizar este documento

**Regla:** cada vez que un modelo complete una ronda de tareas verificadas, agregar:
1. Nueva fila en la tabla del modelo (Log + verificación)
2. Actualizar conteos de suites rc=0
3. Si se detecta sobre-cierre o claim falso → registrarlo aquí (no solo en 11-BUGS.md)
4. Re-evaluar la sección 4 si las fortalezas medidas cambian

**No agregar benchmarks de internet.** Este documento es evidencia del repo, punto.

**Próxima evaluación:** cuando K3 termine M106/M122/M103 y MiMo cierre M31 V4.

---

## 7. Barrido histórico — todos los modelos que trabajaron en el proyecto (2026-09-20)

> 📌 **Directiva del usuario (2026-09-19):** "mañana revisamos todos los logs para agregar
> los modelos que trabajaron anteriormente". **Hecho (2026-09-20, Log 1093).**
>
> **Método (100% verificable, reproducible):** conteo de firmas `**Modelo:**` en los **1039 logs**
> de `Logs/` + firmas en los **168 `plan-inicial/01-Requerimientos.md`** + **167
> `plan-actual/05-Checklist.md`**. Las fechas salen de los propios logs. **Cero benchmarks de
> internet** — todo es este repo.

### 7.1 Línea temporal fundacional (corrección importante)

El orden **real** en que cada modelo empezó a trabajar (primer log firmado):

| # | Modelo | Plataforma | Primer log | Qué fundó |
|---|---|---|---|---|
| **1°** | **Deepseek V4 Flash** | OpenCode | **2026-08-15** (log 4) | **EL FUNDADOR.** Escribió la arquitectura core del juego: M07 Arquitectura, M08 Mundo-Voxel, M09 Terreno, M10 Generación-del-Mundo, M11 Personaje, M12 Cámara, M13 Herramientas, M29 Tiempo-y-Calendario, M30 Reloj (logs 7-20, 2026-08-16) + M57/M63/M64/M65 |
| **2°** | **Devin (SWE-1.6)** | Antigravity | **2026-08-16** (log 21) | Infraestructura y sistemas auxiliares: M103 Logging, M107 Backups, M110 Debug-Menu, M111 Código-de-Calidad, M122 Crash-Reporting, M31 Clima, M41-M44 audio, M88/M90/M91 config, M152 |
| **3°** | **Nemotron 3 Ultra** | *(sin carpeta)* | **2026-08-21** (log 102) | 13 specs legales/operación en **una ráfaga de 12 minutos** (01:23→01:35): M81-M85, M115, M119, M128, M132, M134, M145, M146, M149 |
| 4° | MiMo V2.5 | OpenCode | 2026-08-22 (log 115) | M82 y otros |
| 5° | ox-alpha | Cline/Kilo | 2026-08-23 (log 128) | M104 y otros |
| 6° | GitHub Copilot | — | 2026-08-25 | — |
| 7° | GLM (5.3 flagship) | Kilo | 2026-08-26 (log 177) | M134/M145/M146/M149 (implementó specs de Nemotron) |
| 8° | Claude | Cline | 2026-08-27 | — |
| 9° | Hy3 | WorkBuddy | 2026-08-28 (log 204) | — |
| 10° | MiniMax M3 | Kilo | 2026-08-28 (log 192) | M115 (reconciliado después por MiMo) |
| 11° | **glm-5.3 / glm-5.3-flash** | Kilo | **2026-09-01** (logs 318/326) | Segunda oleada: M118 CI-CD, documentación masiva |
| 12° | agnes-2.5-flash | Kilo | 2026-09-01 (log 377) | — |

> ⚠️ **Corrección a la creencia previa:** el usuario recordaba a **glm-5.3/glm-5.3-flash como
> "fundadores, antes que todos los actuales"**. **Temporalmente no es así** — llegaron el
> **2026-09-01**, dos semanas después que DeepSeek (08-15) y Devin (08-16). Sí es cierto que
> **construyeron sistemas fundacionales** (la segunda oleada: CI-CD, specs de operación) y que
> llegaron antes que todos los modelos **hoy activos** (Hy3 en Kilo llegó 09-11, Agnes 3 y MiMo
> V2.5-actual 09-16, Atria 09-16, Nex/Kimi 09-19). La distinción correcta: **DeepSeek y Devin
> fundaron el proyecto; glm-5.3/flash fundaron la capa de sistemas operativos.**

### 7.2 Tabla histórica completa (evidencia del repo)

| Modelo | Plataforma | Período activo | Logs | plan-inicial (diseñó) | plan-actual (implementó) | Carpeta TAREAS-POR-MODELO |
|---|---|---|---|---|---|---|
| **Deepseek V4 Flash** (4 variantes de firma) | OpenCode | 2026-08-15 → 09-18 | **~227** | **114 (68%)** | **57** (top) | ✅ 3 carpetas (v4-flash, vision-exp, V4.1) |
| **Devin (SWE-1.6)** | Antigravity | 2026-08-16 → 08-17 | 9 firmados (rango 21-35) | **21 (13%)** | 14 | ❌ **sin carpeta** |
| **Nemotron 3 Ultra** | — | 2026-08-21 (1 día) | 13 | **13 (8%)** | 6 (M81/M83/M84/M85/M119/M132 siguen firmados por él) | ❌ **sin carpeta** |
| MiMo V2.5 | OpenCode | 2026-08-22 → 09-18 | ~70 | 11 (7%) | 6+ | ✅ |
| ox-alpha | Cline/Kilo | 2026-08-23 → 08-29 | ~42 | 1-2 | 4 | ❌ **sin carpeta** |
| GitHub Copilot | — | 2026-08-25 → 08-26 | 4 | 0 | 0 | ❌ |
| GLM 5.3 (flagship) | Kilo/WorkBuddy | 2026-08-26 → 09-12 | ~43 | 0 | 8+ | ✅ glm-5.3 |
| Claude | Cline | 2026-08-27 → 09-02 | 4 | 0 | 0 | ❌ |
| Hy3 (8 variantes de firma) | WorkBuddy/Kilo | 2026-08-28 → 09-19 | ~92 | 1 | 3+ | ✅ |
| MiniMax M3 (3 variantes) | Kilo | 2026-08-28 → 09-04 | ~33 | 0 | 4 | ✅ minimax-m3-free |
| **Nemotron 3.5 Lightning** | — | **sin logs** | **0** | **4 (2%)** | 2 (M69/M131 siguen firmados por él) | ❌ **sin carpeta** |
| **glm-5.3-flash** | Kilo | 2026-09-01 → 09-17 | **142** (más prolífico) | 0 | ~10 | ✅ |
| **agnes-2.5-flash** | Kilo | 2026-09-01 → 09-14 | **142** (empata) | 0 | — | ✅ |
| step-3.7-flash (3 variantes) | Kilo | 2026-09-01 → 09-03 | ~19 | 0 | 2 | ✅ |
| Hy4 | WorkBuddy | 2026-09-10 → 09-16 | 12 | 0 | — | ✅ HY4 |
| muse-spark-1.3 | Cline | 2026-09-14 → 09-16 | 3 | 0 | 0 | ✅ |
| DeepSeek-V4.1-Flash | Kilo/WorkBuddy | 2026-09-11 → 09-18 | ~24 | 0 | 2 | ✅ |
| **Modelos activos hoy:** kimi-k3 (5 logs, 09-19), agnes-3-flash (22, 09-15→19), atria-dawn (38, 09-16→20), nex-n2.5-pro (4, 09-19) — ⛔ nex fuera de flujo 09-20 | | | | | | ✅ |

**Totales verificados:** 1039 logs, 56 variantes de firma, 168 plan-iniciales, 167 plan-actual.

### 7.3 Hallazgos del barrido

**1. DeepSeek V4 Flash es el autor documental del proyecto (confirmado).** 114/168 plan-iniciales
(68%) + ~227 logs + 57 plan-actual (también el implementador top). **Escribió la arquitectura
core del juego** (M07-M13, M29/M30) — el impacto fundacional más alto de todos. **Ahora solo
disponible para tareas cortas por límite de tokens** (directiva del usuario): de "carga masiva
del proyecto" a "tareas atómicas" — evidencia de uso sostenible, **afecta asignación**.

**2. Devin: corrección de la creencia "autor mayoritario".** Fueron **21 plan-iniciales (13%)**,
no la mayoría. Llegó 2° (2026-08-16) y creó los **componentes de infraestructura** (logging,
backups, debug menu, código de calidad, crash reporting, audio, config). Impacto fundacional
**alto en la capa de infra**, bajo en contenido. *(Nota: mi pre-scan del 2026-09-19 mencionaba
un "Log 47" con conteos inflados — **ese log no existe en `Logs/`** (búsqueda directa, 0
resultados); no se propaga el claim.)*

**3. Nemotron 3 Ultra/3.5 Lightning = 17 módulos, vacío real confirmado.**
- **Nemotron 3 Ultra** (13 specs): **solo diseñó** — ráfaga de 12 min el 2026-08-21, un log por
  módulo, sin implementación posterior. 6 de sus 13 módulos **siguen firmados solo por él** en
  plan-actual (M81, M83, M84, M85, M119, M132); los otros 7 los implementaron otros (M82→MiMo,
  M115→MiniMax/MiMo, M134/M145/M146/M149→GLM, M128→Hy3).
- **Nemotron 3.5 Lightning** (4 specs: M69 Fast-Travel, M104 Analytics, M118 CI-CD, M131
  Créditos): **CERO logs** — no dejó más rastro que las firmas de plan-inicial. M69/M131 siguen
  firmados solo por él; M104→ox-alpha, M118→glm-5.3-flash (Hy3 hizo QA de M118 en Log 1072).
- **Ninguno de los dos tiene carpeta en `TAREAS-POR-MODELO/`** — su historial vive solo en
  `plan-inicial/` y `Logs/`. **Son los dos modelos más invisibles del proyecto.**

**4. agnes-2.5-flash: el sobre-cierre histórico más grande (documentado).** 142 logs
(2026-09-01→09-14), pero la **auditoría del 2026-09-14 revirtió M126/M128/M115** — marcados como
completos sin verificación real. Mi reconciliación (Log 1048) **verificó que la reversión fue
correcta** para M126/M128 (el contenido reclamado no existía). Es el ejemplo histórico que
motivó la regla anti-sobre-cierre y el protocolo de los 3 registros.

**5. glm-5.3-flash y agnes-2.5-flash: los más prolíficos (142 logs cada uno).** glm-5.3-flash
mantuvo actividad 17 días seguidos (09-01→09-17); agnes-2.5-flash 14. **Son la capa de "producción
documental diaria"** del proyecto — el análogo histórico de lo que hoy hace kimi-k3 con su
contexto 1M.

**6. Modelos fantasmas adicionales** (trabajaron pero sin carpeta ni presencia actual):
**ox-alpha** (~42 logs, Cline/Kilo, 08-23→08-29 — implementó M104 y 4 plan-actual), **GitHub
Copilot** (4 logs), **Claude** (4 logs, Cline), **stealth/ox-alpha** (3 logs).

### 7.4 Lo que NO es verificable hoy (honestidad)

- **Resultados runtime de las suites antiguas** (Devin, Nemotron, ox-alpha, glm-5.3-primera-época):
  los logs reportan exits, pero **no re-corrrí esas suites** — el código de muchas migró o los
  módulos cambiaron de dueño. Sus claims de "0 fallos" quedan como **no-verificados**, no como
  verdaderos. (Mi verificación binario-real cubre desde el 2026-09-18 en adelante.)
- **Velocidad de los modelos históricos**: los timestamps de los logs permiten medirla (p. ej.
  Nemotron: 13 specs en 12 min), pero las sesiones de Antigravity/Cline no dezan huella de
  duración por tarea más allá del timestamp del log.
- **Visión de los modelos históricos**: sin capturas en `capturas/` firmadas por ellos, no hay
  evidencia ni a favor ni en contra.

### 7.5 Implicaciones para asignación

- **DeepSeek V4 Flash:** History dice "es el mejor constructor del proyecto" — pero **hoy solo
  puede hacer tareas cortas**. No asignarle módulos; sí **tareas atómicas de alta dificultad**
  (es el que más contexto del proyecto tiene en su historia de commits).
- **Nemotron 3 Ultra/3.5 Lightning:** **no asignar** — no están disponibles (no aparecen en el
  catálogo de modelos actuales) y sus 17 módulos están **parcialmente huérfanos** (6+2 firmados
  solo por ellos en plan-actual). **Sus módulos son candidatos a ser reclamados** por modelos
  activos que quieran cerrar deuda heredada: M81/M83/M84/M85/M119/M132 (Nemotron 3 Ultra) y
  M69/M131 (Nemotron 3.5 Lightning).
- **agnes-2.5-flash:** caso escolar — **productividad altísima (142 logs) con el sobre-cierre
  más grande**. La lección: el volumen de logs **no** es señal de confiabilidad; el sync de los
  3 registros y la verificación binario real sí.

**Recordar:** la fuente es **solo este repo** (logs + código + checklists), nunca
benchmarks de internet.

---

**Firma:** Atria-Dawn-Preview / Kilo Code — 2026-09-19
**Última actualización:** 2026-09-20 21:45 (barrido histórico completo — §7: línea temporal fundacional + tabla de 20 modelos + correcciones; Log 1093)
**Logs de evidencia:** 1044-1093 (todos citados arriba, re-verificables)
