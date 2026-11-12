# Reporte de análisis documental — AGENTS.md y GUIA-COMPARATIVA-MODELOS-V1.md

**Modelo:** ERNIE-5.5-Flash-Preview
**Plataforma:** Kilo Code
**Fecha:** 2026-11-11
**Encargo:** analizar si hay (1) instrucciones desactualizadas, (2) inconsistencias entre documentos, (3) referencias a archivos o modelos que ya no existen, y (4) proponer 2 acciones de corrección.

**Alcance:** lectura completa de `AGENTS.md` (1.752 líneas) y `DOCUMENTACION/GUIA-COMPARATIVA-MODELOS/GUIA-COMPARATIVA-MODELOS-V1.md` (396 líneas), contrastadas contra el estado real del repositorio (archivos, carpetas, scripts, encoding, CHECKLIST-GLOBAL y canales).

**Método:** verificación con `Test-Path`, `Get-ChildItem`, `Select-String` en UTF-8, `grep` y lectura directa. No se modificó ningún archivo del proyecto; este reporte es solo de diagnóstico.

**Nota metodológica (falso positivo evitado):** PowerShell 5.1 usa ANSI por defecto y al leer `CHECKLIST-GLOBAL.md` mostró mojibake aparente en todo el archivo. La verificación con lector UTF-8 confirmó que el archivo está mayormente en UTF-8 válido; la corrupción real está localizada en 11 líneas concretas (ver §2.7). No se reporta un problema de encoding global que no existe.

---

## 0. Resumen ejecutivo

| Área | Hallazgos | Severidad |
|---|---|---|
| Stack tecnológico en AGENTS.md | 5 secciones describen Unity/C# cuando el proyecto es Godot 4.x/GDScript | ALTA |
| Identidad del director | AGENTS.md se contradice a sí mismo (De-Director V4.1 vs GLM-5.3 Flash-Director) y las copias canónicas también | ALTA |
| CHECKLIST-GLOBAL | 5 IDs duplicados, 173 filas para 168 módulos, 11 líneas con mojibake, resumen y locks stale | ALTA |
| Guía comparativa | "11 modelos activos" cuando hay 14 distintos; Crouton activo/retirado; Beam duplicado; ERNIE gratis/pago | ALTA |
| Documentos generales | README y DIRECTIVAS desactualizados; AGENTS §3 no lista 6 documentos existentes | MEDIA |
| Referencias de herramientas | blender MCP inexistente en `.kilo/kilo.json`; `cap_godot.py` cambió de ruta; sección §21.23 inexistente | MEDIA |
| Backlogs V2 | 15 modelos siguen en la estructura vieja; la guía apunta a la ruta vieja de Beam | MEDIA |
| Metadatos y fechas | Generación de CHECKLIST 2026-09-15; ESTADO-PARALELO 2026-10-17; estado_director 2026-11-08 | BAJA/MEDIA |

Conclusión corta: **la documentación no está sincronizada con el estado real**. Los dos documentos analizados son útiles, pero AGENTS.md arrastra una capa entera de Unity/C# y una identidad de director vieja, y la guía comparativa tiene contradicciones internas de estado de modelos. El CHECKLIST-GLOBAL, que AGENTS llama "única fuente de verdad", es hoy el archivo con más drift.

---

## 1. Instrucciones desactualizadas respecto al estado real

### 1.1 [ALTA] AGENTS.md describe Unity/C# en 5 secciones; el proyecto es Godot 4.x

Evidencia:

- `AGENTS.md:1170` — `## 24. Stack Tecnológico del Proyecto` → `Motor: Unity` (`:1173`), `Lenguaje: C#` (`:1174`), estructura `Assets/` (`:1179-1205`).
- `AGENTS.md:1082` — `## 22. Empaquetado y Distribución (Unity Build Pipeline)`; `:1093-1095` usa `BuildPipeline.BuildPlayer(...)`.
- `AGENTS.md:771-773` — `### Implementación en Código (Unity/C#)` y `Debug.Log` como logging de runtime.
- `AGENTS.md:691-692` — "Unity Test Framework — Edit Mode Tests / Play Mode Tests".
- `AGENTS.md:452` — "Los MonoBehaviours de UI...".

Estado real verificado:

- `game/isla-ancestral/project.godot` existe; no hay `project.godot` en la raíz.
- No existe `Assets/`, ni scripts `.cs`, ni `BuildPipeline`; el motor es Godot 4.7 (`tools/mcp/godot-mcp/.kilo/kilo.json` apunta a `Godot_v4.7.2-stable_win64.exe`).
- El propio `AGENTS.md:1` se titula "Proyecto Godot" y `:1288-1293` documenta GDScript/Godot, lo que agrava la contradicción interna.

Impacto: un agente que lea §24 intentará crear carpetas `Assets/`, usar C# y `BuildPipeline`; el CI y las rutas reales son Godot. La guía comparativa ya lo había detectado (`GUIA-COMPARATIVA-MODELOS-V1.md:312` y `:324`).

### 1.2 [ALTA] La identidad del director está desactualizada en 5 puntos de AGENTS.md

- `AGENTS.md:462` — "el hilo permanente de comunicación entre el **director (De-Director V4.1)**".
- `AGENTS.md:592` — "Cuando el director (De-Director V4.1) tiene varios canales pendientes...".
- `AGENTS.md:995` — ejemplo: "`De-Director V4.1` (director, OpenCode) y `DeepSeek-V4.1-Flash`...".
- `AGENTS.md:1544-1545` — "el director ahora es **`De-Director V4.1`** = DeepSeek V4.1 Flash (OpenCode)".
- `AGENTS.md:1626` — el director escribe en `DOCUMENTACION/TAREAS-POR-MODELO/De-Director-V4.1/`.

Pero `AGENTS.md:1658-1721` (§31, actualizada 2026-10-16) establece que el director es **`GLM-5.3 Flash-Director`** y que su material vive en `DOCUMENTACION/TAREAS-POR-MODELO/GLM-5.3-Flash-Director/`. Las secciones §10.2, §10.3, §21.8 y §30 quedaron con la identidad anterior.

Impacto: los reportes y sellos pueden atribuirse al modelo equivocado, que es exactamente el riesgo que §31 dice querer evitar.

### 1.3 [ALTA] CHECKLIST-GLOBAL no coincide con su propio resumen ni con AGENTS §21.1

- `CHECKLIST-GLOBAL.md:22` declara **11 columnas** (incluye `Recom`); `AGENTS.md:840-846` y `:1164` declaran **10 columnas** (sin `Recom`).
- `CHECKLIST-GLOBAL.md` tiene **173 filas de módulo** para **168 carpetas** en `DOCUMENTACION/`; hay **5 IDs duplicados**: 48 (líneas 150-151), 115 (52-53), 127 (66-67), 139 (81 y 83), 148 (93-94).
- El resumen del proyecto (`CHECKLIST-GLOBAL.md:218-225`) declara: total 167, completados 31, en curso 50, con dudas 121, disponibles 12, sin iniciar 0; el escaneo real de la tabla arroja 173 filas, 56 completadas, 12 en curso, 96 con dudas, 6 disponibles y 3 filas mal formadas. El propio resumen dice "Recontado a mano ... 2026-08-31" y "snapshot 2026-08-28", mientras hay filas con actividad del 2026-10-27.
- `AGENTS.md:1023-1026` (§21.8.2.b, punto 5) obliga a reportar cualquier drift de conteo mayor a 5 ítems: aquí el drift es de 6 módulos, 25 completados y 38 "en curso".

Impacto: el tablero que todos los agentes usan para elegir trabajo está desactualizado y no permite detectar bloqueos reales.

### 1.4 [ALTA] 12 filas "En curso" están stale; M158 lleva 68 días

Filas con `🔵`/`🔴` y última actividad (líneas exactas):

| ID | Línea | Última actividad | Días sin actividad (al 2026-11-11) |
|---|---|---|---|
| 158 | 106 | 2026-09-04 | 68 |
| 139 | 81/83 | 2026-10-14 | 28 |
| 41 | 143 | 2026-10-16 | 26 |
| 49 | 152 | 2026-10-16 | 26 |
| 159 | 107 | 2026-10-18 | 24 |
| 161 | 111 | 2026-10-22 | 20 |
| 23 | 125 | 2026-10-26 | 16 |
| 17 | 119 | 2026-10-27 | 15 |
| 20 | 122 | 2026-10-27 | 15 |
| 33 | 135 | 2026-10-25 | 17 |
| 45 | 147 | 2026-10-13 | 29 |
| 59 | 162 | 2026-10-30 | 12 |

`AGENTS.md:943` (§21.4.7) permite reclamar un módulo `🔵`/`🔴` sin actividad por más de 24 h. Las 12 filas superan ese umbral. M158 (`CHECKLIST-GLOBAL.md:106`) está en `🔵 En curso (M158 agnes #919)` desde el 2026-09-04.

Impacto: bloqueos fantasma que impiden que otros agentes tomen esos módulos.

### 1.5 [ALTA] 11 líneas de CHECKLIST-GLOBAL tienen mojibake real, incluida la leyenda de estados

Líneas con secuencias corruptas verificadas con `grep`: 10, 15, 107, 111, 147, 186, 189, 193, 207, 212, 219.

Ejemplos:

- `:207` — la leyenda contiene la codificación doble de U+2B1C (el emoji `⬜` de "Sin iniciar").
- `:212` — la leyenda contiene la codificación doble de U+2705 (el emoji `✅` de "Completado").
- `:219` — el resumen contiene la codificación doble de U+2705 donde debería decir `(✅)`.
- `:186` — "73" + codificación doble de U+2192 + "99" donde debería decir "73→99"; `:189` — "Documentación" y "Verificación" con los acentos doblemente codificados.
- `:193` — celda `Dependencias` de M90 corrupta.

`AGENTS.md:1373-1383` prohíbe el mojibake y `:1407-1415` documenta `scripts/fix_encoding.py` y `scripts/diagnosticar_mojibake.py`. El archivo que encabeza la "única fuente de verdad" viola su propia regla. La línea 5 sí contiene ejemplos intencionales de mojibake (por eso no se cuenta como corrupción).

Impacto: los emojis de estado de la leyenda no se ven, y los agentes pueden malinterpretar filas.

### 1.6 [MEDIA] AGENTS §3 describe una raíz y un `DOCUMENTACION/` que no existen

- `AGENTS.md:53` — "La raíz del proyecto solo contiene `AGENTS.md`, `README.md`, `CHECKLIST-GLOBAL.md`, y configuraciones generales". La raíz real tiene **67 archivos** y más de 30 carpetas: `game/`, `DOCUMENTACION/`, `scripts/`, `tools/`, `installer/`, `legal/`, `build/`, `out/`, `PAPELERA/`, `Temp/`, más temporales como `cannon_std_tmp.py`, `D1-002_resultado.txt`, `m89_run.log`, `fusionar_tmp.py`.
- `AGENTS.md:77` — "En la raíz de `DOCUMENTACION/` están los 5 documentos generales"; la tabla siguiente (`:81-89`) lista **9 filas** y en disco hay **15 documentos generales**. No se mencionan: `00-REFERENCIA-CRUZADA-MAESTRA.md` (13.647 bytes), `DIRECTIVAS-PARA-EL-DIRECTOR.md`, `INVENTARIO-RAIZ.md`, `METODOLOGIA-CRON-AGENTE-AUTONOMO.md`, `GUIA-CONFIGURACION-OPENCODE.md`, `GUIA-CONFIGURACION-SIMPLE.md`.

Impacto: un agente nuevo no sabe que existe el onboarding de director (`DIRECTIVAS-PARA-EL-DIRECTOR.md`) ni la metodología de cron autónomo.

### 1.7 [MEDIA] AGENTS §2b no cubre las guías Godot 13, 20 y 21

- `AGENTS.md:28` — encabezado "Avanzados / Específicos del juego (16-18)".
- `AGENTS.md:32` — incluye `19-diagnostico-tildes.md` dentro de ese rango.
- En disco existen además `GUIA-GODOT/13-sondas-runtime-gate2.md`, `20-ventana-juego-al-frente.md` y `21-send-keys-navegacion-juego.md`, que no se referencian en `AGENTS.md`.

Impacto: los agentes no encuentran la guía de sondas runtime ni las de automatización de ventana.

### 1.8 [MEDIA] La guía comparativa declara "11 modelos activos" cuando hay 14 distintos

`GUIA-COMPARATIVA-MODELOS-V1.md:6` dice "11 modelos activos de la flota". El archivo contiene:

- 11 modelos numerados (Agnes, Nemotron, GLM-5.3-Flash, Ling, DeepSeek, Hy3, Hy4, Beam, MiniMax, G-5.3-Flash-Agente, MiMo).
- Además Crouton Alpha (`:196`), Stealth Glyph Cluster (`:240`), Reflection Beam 1.0 como sección de pago (`:294`) y ERNIE-5.5-Flash-Preview (`:330`).
- Beam aparece dos veces: como `#8` en la lista numerada (`:129`) y como sección separada "modelo de pago" (`:294`).

Modelos distintos reales: 14 (11 numerados + Crouton + Glyph + ERNIE; Beam ya contado). La cifra "11" no se sostiene.

### 1.9 [ALTA] Crouton Alpha aparece como "activo" y como "retirado" en la misma guía

- `GUIA-COMPARATIVA-MODELOS-V1.md:196` — "Modelo activo — Crouton Alpha (supervisado)".
- `:213` — "Estado: **Activo formal** — supervisado por Nemotron-3.5-Super-VL".
- `:384` — "Modelos en prueba (supervisados): **Crouton Alpha (retirado)**...".

Es una contradicción directa de estado.

### 1.10 [MEDIA] Beam aparece como "en prueba activo" en la guía y como "PAUSADO" en AGENTS

- `GUIA-COMPARATIVA-MODELOS-V1.md:310` — "Estado: En prueba — supervisado por Nemotron...".
- `GUIA-COMPARATIVA-MODELOS-V1.md:384` — Beam tiene su propio `BACKLOG-MASTER`.
- `AGENTS.md:1746` — "Beam: **PAUSADO** (394/395-397/399-404) — retorno: ping → 5 líneas → fuel fresco".
- `AGENTS.md:1731-1735` — el apilador de Beam y el cron E siguen descritos como activos.

Impacto: no queda claro si Beam debe recibir trabajo o no.

### 1.11 [MEDIA] ERNIE figura como "gratuito en preview" y como modelo de pago

- `GUIA-COMPARATIVA-MODELOS-V1.md:342` — "Precio: $0.28/M input / $1.13/M output (preview...)".
- `:384` — "ERNIE-5.5-Flash-Preview (modelo de pago, en prueba — ... y **es gratuito en preview**)".

Ambas afirmaciones no pueden ser ciertas a la vez.

### 1.12 [BAJA] "Este chat" en la ficha de Nemotron

`GUIA-COMPARATIVA-MODELOS-V1.md:35` — "Rol: Agente autónomo de la flota (este chat)". La guía se está leyendo desde el chat de ERNIE-5.5-Flash-Preview, no desde Nemotron. Una ficha de modelo no debería depender del chat desde el que se lee.

### 1.13 [BAJA] Cifra de líneas del histórico incorrecta

`GUIA-COMPARATIVA-MODELOS-V1.md:390` — "Versión histórica completa (pre-V1, 3398 líneas)". El archivo `DOCUMENTACION/GUIA-COMPARATIVA-MODELOS/obsoletos/10-GUIA-COMPARATIVA-MODELOS.md` tiene **2.689 líneas** (medido con `Measure-Object -Line`).

### 1.14 [BAJA] AGENTS §23 declara "8 PASS, 0 FAIL" y la suite real da 20 PASS

- `AGENTS.md:1134` — "→ Debe mostrar `8 PASS, 0 FAIL`".
- `AGENTS.md:1165` — tabla de verificación: "`scripts/test_scripts.py` | Ejecutable y muestra `8 PASS, 0 FAIL`".
- Ejecución real: `python scripts/test_scripts.py` → **"RESULTADO: 20 PASS, 0 FAIL"**.

### 1.15 [BAJA] AGENTS §6.1 describe un pool de logs que no coincide

- `AGENTS.md:321` — "una línea por número, orden ascendente (1000, 1001, 1002, ...)".
- `Logs/NUMEROS_DISPONIBLES.txt` real: 601 líneas, mínimo 2400, máximo 3000, sin duplicados.

### 1.16 [BAJA] Ruta de `cap_godot.py`

- `AGENTS.md:1245` — "La herramienta estándar es `scripts-reutilizables/cap_godot.py`".
- Real: `tools/mcp/godot-mcp/scripts-reutilizables/cap_godot.py`. La carpeta raíz `scripts-reutilizables/` existe, pero contiene otros 7 scripts (`generar_tareas_deepseek_v41.py`, `marcar_tareas_modelo.py`, etc.) y no `cap_godot.py`.

### 1.17 [BAJA] Cifra de skills de Blender

`AGENTS.md:1360` — "se instaló un subconjunto curado ... `find-skills` + ~44 skills de Godot + ~24 de Blender". Real: 70 skills, de las cuales 44 son `godot-*`, 2 son `blender-*` y 24 son genéricas (incluye `find-skills`). La aproximación es cercana, pero conviene precisarla.

---

## 2. Inconsistencias entre documentos

### 2.1 [ALTA] AGENTS.md §31 vs sus propias secciones §10, §21.8 y §30

- §31 (`:1658-1721`) fija al director como `GLM-5.3 Flash-Director`.
- §10.2 (`:462`), §10.3 (`:592`), §21.8 (`:995`), §30.1 (`:1544-1545`) y §30.5 (`:1626`) dicen `De-Director V4.1`.
- La propia §31 (`:1660`) dice "cualquier otro documento debe alinearse con ella"; no se cumple dentro del mismo archivo.

### 2.2 [ALTA] La "copia canónica" GUIA-COMUNICACION.md está partida en dos identidades

`Mensajes entre modelos/GUIA-COMUNICACION.md`:

- `:3` — "Modelo: GLM-5.3-Flash-Director ... última modificación 2026-10-17".
- `:24` — "El DIRECTOR (GLM-5.3-Flash-Director) es el responsable...".
- `:63` — material del director en `TAREAS-POR-MODELO/GLM-5.3-Flash-Director/`.
- `:218` — "### 2. El director (De-Director V4.1)".
- `:233` — "es **`De-Director V4.1`** = DeepSeek V4.1 Flash (OpenCode)".
- `:246` — "En la redacción: «el director (De-Director V4.1)»...".
- `:340` — "Cuando el director (De-Director V4.1) tiene varios canales pendientes...".
- `:378` — "el director (De-Director V4.1) sella".
- `:523` — tabla de slugs: "`De-Director V4.1` (el director...)".

`AGENTS.md:610-615` (§10.3, regla 3) obliga a actualizar `ESTADO-PARALELO.md` y `GUIA-COMUNICACION.md` junto con AGENTS. No se hizo.

### 2.3 [ALTA] DIRECTIVAS-PARA-EL-DIRECTOR.md contradice a AGENTS §31

`DOCUMENTACION/DIRECTIVAS-PARA-EL-DIRECTOR.md`:

- `:5` — "actualizado 2026-10-15 por De-Director V4.1".
- `:8` — "Historial de directores: ... **`De-Director V4.1`** (DeepSeek V4.1 Flash, OpenCode; 2026-10-15 →). Ver AGENTS.md §31".
- `:51` — "GLM-5.3-Flash | Nuevo ingreso (canal creado 2026-10-15; esperando disponibilidad)".

AGENTS §31 dice que GLM-5.3 Flash-Director asumió el 2026-10-16. El onboarding de director apunta al director anterior.

### 2.4 [ALTA] CHECKLIST-GLOBAL: 11 columnas vs 10 en AGENTS

- `CHECKLIST-GLOBAL.md:22` — `| ID | Módulo | Estado | Progreso | Prioridad | Complejidad | Dependencias | Recom | Agente actual | Última actividad | Notas |` (11 columnas).
- `AGENTS.md:840` — tabla de 10 columnas sin `Recom`.
- `AGENTS.md:1164` — "Tabla con las 10 columnas (ID, Módulo, Estado, Progreso, Prioridad, Complejidad, Dependencias, Agente actual, Última actividad, Notas)".
- `AGENTS.md:418` y `:29` — el flujo obligatorio depende de "la columna Recom del CHECKLIST".

El protocolo exige una columna que su propio esquema no declara.

### 2.5 [ALTA] "Una fila por módulo" vs 173 filas / 168 módulos / 5 IDs duplicados

`AGENTS.md:73` y `:838` dicen "UNA fila por módulo". La realidad: 173 filas, 168 carpetas, 5 IDs duplicados. `GUIA-COMPARATIVA-MODELOS-V1.md:323` ya había detectado "5 IDs duplicados (48, 115, 127, 139, 148)"; el hallazgo sigue vigente.

### 2.6 [ALTA] Resumen de CHECKLIST-GLOBAL vs escaneo real

`CHECKLIST-GLOBAL.md:218-225`:

| Campo | Documento | Real |
|---|---|---|
| Total módulos | 167 | 173 filas / 168 carpetas |
| Completados | 31 | 56 |
| En curso | 50 | 12 |
| Con dudas | 121 | 96 |
| Disponibles | 12 | 6 |
| Sin iniciar | 0 | 0 |

El resumen está fechado 2026-08-28/31 y no refleja la actividad de octubre.

### 2.7 [ALTA] Mojibake en el CHECKLIST vs AGENTS §28

Ver §1.5. La contradicción es directa: `AGENTS.md:1373-1383` prohíbe el mojibake; `CHECKLIST-GLOBAL.md:207`, `:212` y `:219` muestran los emojis de la leyenda y del resumen corruptos. El propio `CHECKLIST-GLOBAL.md:5` advierte sobre el problema.

### 2.8 [MEDIA] DOCUMENTACION/README.md está stale

`DOCUMENTACION/README.md`:

- `:3` — "Modelo: Claude (último modificador 2026-09-02)".
- `:5` — "Fecha: 2026-08-15 (actualizado 2026-09-02)".
- `:11-15` — los 5 documentos principales figuran como "(pendiente)" aunque existen y tienen contenido.
- `:22` — "Portal/índice: 152 módulos, 68 documentados [x]"; el proyecto tiene 168 carpetas y 173 filas.
- `:230` — "M84 ... En curso por mimo-v2.5 ... 21/100"; `CHECKLIST-GLOBAL.md:187` dice M84 `✅` con 99/99.
- No lista `00-REFERENCIA-CRUZADA-MAESTRA.md`, `DIRECTIVAS-PARA-EL-DIRECTOR.md`, `INVENTARIO-RAIZ.md`, `METODOLOGIA-CRON-AGENTE-AUTONOMO.md` ni `GUIA-COMPARATIVA-MODELOS/`.

`AGENTS.md:628` (§11.8) obliga a actualizar `DOCUMENTACION/README.md` al agregar componentes; no se hizo.

### 2.9 [MEDIA] 15 modelos siguen en la estructura de backlog vieja

`AGENTS.md:1459-1489` (§29.1, metodología V2) fija `DOCUMENTACION/TAREAS-POR-MODELO/<MODELO>/BACKLOGS/BACKLOG-MASTER.md`. Verificado:

- Usan `BACKLOGS/BACKLOG-MASTER.md`: agnes-3-flash, Cohere North Mini Code, Crouton Alpha, DeepSeek-V4.1-Flash, Dots Studio, DS-V4.1-Flash-Opencode, ERNIE-5.5-Flash-Preview, Glyph Cluster, Hy3, HY4, ling-3.1-flash, LiquidAI, Nemotron, step-5-workbuddy (15).
- Usan la ruta vieja `BACKLOG-MASTER.md` en la raíz: agnes-2.5-flash, atria-dawn, atria-dawn-s2, atria-dawn-s3, Claude-Haiku-5.5, deepseek-v4-flash, deepseek-v4-flash-vision-exp, G-5.3-Flash-Agente, gemini-3.8-flash, glm-5.3, glm-5.3-flash, GPT-Luna, kimi-k3, mimo-v2.5, mimo-v2.6-flash-free, minimax-m3-free, MiniMax-M3.1-Flash, muse-spark-1.3-contributor, nex-n2.5-pro, Reflection-Beam-1.0, space-bunny-alpha, step-3.7-flash, step-5-kilocode (23).

La guía comparativa `:384` apunta a `DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0/BACKLOG-MASTER.md`, que existe; la variante `BACKLOGS/BACKLOG-MASTER.md` no existe para Beam. Es decir, la guía es correcta para Beam pero el protocolo V2 no.

### 2.10 [MEDIA] Beam "PAUSADO" (AGENTS) vs "En prueba activo" (guía)

Ver §1.10.

### 2.11 [MEDIA] `step-5-kilocode` "dado de baja" pero sigue asignado

- `AGENTS.md:1553` — "`step-5-kilocode` dado de baja".
- `CHECKLIST-GLOBAL.md:26` — M03 tiene `Agente actual = step-5-kilocode` (2026-10-15).
- `CHECKLIST-GLOBAL.md:193` — M90 tiene `Agente actual = step-5-kilocode`.
- Existe el canal `Mensajes entre modelos/step-5-kilocode/`.

### 2.12 [BAJA] mimo aparece como prioridad 2 y como histórico

`AGENTS.md:600` — "2 | `mimo-v2.6-flash-free` | muchos créditos diarios — *canal de mimo como agente (histórico desde 2026-10-15)*". Si es histórico, no debería ocupar el puesto 2 de la prioridad de respuesta.

### 2.13 [MEDIA] AGENTS §3 no lista documentos que son material de onboarding

`DIRECTIVAS-PARA-EL-DIRECTOR.md` es "archivo único de onboarding para quien ejerza el rol de director" (`:5-6`), pero no aparece en `AGENTS.md §3`. `METODOLOGIA-CRON-AGENTE-AUTONOMO.md` tampoco. Un director nuevo no los descubre desde AGENTS.

### 2.14 [BAJA] ESTADO-PARALELO.md y estado_director.json están stale

- `Mensajes entre modelos/ESTADO-PARALELO.md` — última entrada visible: 2026-10-17 (M159), 25 días sin movimiento. `AGENTS.md:745-749` (§17) obliga a mantenerlo actualizado.
- `Logs/estado_director.json` — última escritura 2026-11-08 03:30. `AGENTS.md:1728` (§32.1) dice "cada ronda actualiza"; el relevo de director y el estado de Beam no están reflejados.

### 2.15 [BAJA] Guía comparativa omite canales activos que AGENTS sí considera activos

Canales existentes sin ficha en la guía: `Cohere North Mini Code`, `Dots Studio dots3-note`, `GPT-Luna`, `LiquidAI LFM3-1.7B`, `space-bunny-alpha`, `muse-spark-1.3-contributor`, `kimi-k3`, `Claude-Haiku-5.5`, `atria-dawn-s2`, `atria-dawn-s3`, `Step-5-WorkBuddy`. AGENTS §10.3/§31 menciona varios de ellos como activos. La guía dice "solo modelos activos"; la omisión es una inconsistencia de criterio, no necesariamente un error de contenido.

---

## 3. Referencias a archivos o modelos que ya no existen (o cambiaron de lugar)

### 3.1 [ALTA] `De-Director V4.1` como director actual

- Referencias: `AGENTS.md:462`, `:592`, `:995`, `:1544-1545`, `:1626`; `GUIA-COMUNICACION.md:218`, `:233`, `:246`, `:340`, `:378`, `:523`; `DIRECTIVAS-PARA-EL-DIRECTOR.md:8`.
- Realidad: el director es `GLM-5.3 Flash-Director` desde 2026-10-16 (`AGENTS.md:1663-1668`). El modelo DeepSeek sigue existiendo como agente (`DS-V4.1-Flash-Opencode`), pero el rol cambió.
- El canal `Mensajes entre modelos/De-Director-V4.1/` no existe; `AGENTS.md:1700` ya lo dice ("si existiera"). sí existe `DOCUMENTACION/TAREAS-POR-MODELO/De-Director-V4.1/` como histórico.

### 3.2 [MEDIA] Blender MCP declarado/“deshabilitado” que no está en la configuración

- `AGENTS.md:1269` — "MCPs declarados en `.kilo/kilo.json` — godot (...), screen (...) y blender (addon.py, DESHABILITADO hasta validar conexión con Blender)".
- `.kilo/kilo.json` real: solo `godot` (`:4-12`) y `screen` (`:13-20`). No hay bloque `blender`.

### 3.3 [MEDIA] `scripts-reutilizables/cap_godot.py` cambió de ruta

Ver §1.16. La ruta raíz no existe; la real es `tools/mcp/godot-mcp/scripts-reutilizables/cap_godot.py`.

### 3.4 [MEDIA] Referencia a la sección §21.23, que no existe

- `AGENTS.md:995` — "precedente §21.23".
- `AGENTS.md:1678` — "Independencia §21.8/§21.23 ACTUALIZADA".
- `AGENTS.md:1687` — "independence §21.8/§21.23 entre ellos".
- El archivo solo tiene §21.1 a §21.9 (`:832-1080`). No hay §21.23.

### 3.5 [MEDIA] Beam "PAUSADO" y su apilador

Ver §1.10 y §2.10. La referencia a `scripts/apilar_beam.py` sí existe (`Test-Path` verdadero), pero el estado "PAUSADO" no coincide con la guía ni con el backlog activo.

### 3.6 [MEDIA] Ruta de backlog de Beam

- `GUIA-COMPARATIVA-MODELOS-V1.md:384` — `DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0/BACKLOG-MASTER.md` (existe).
- `AGENTS.md:1460` — exige `.../BACKLOGS/BACKLOG-MASTER.md` (no existe para Beam).
- `AGENTS.md:1481-1485` describe la estructura V2 con `BACKLOGS/` y `00-Backlog-Original-PreSplit.md`; Beam tiene `BACKLOG-MASTER-HISTORICO-23oct.md` en la raíz.

### 3.7 [BAJA] Otras referencias verificadas como existentes (sin problema)

Para descartar falsos negativos: existen `DOCUMENTACION/167-Isla-Raiz/`, `168-Plantilla-De-Isla/`, `GUIA-GODOT/19-diagnostico-tildes.md`, `GUIA-BLENDER/` (105 errores E-xx únicos, coincide con `AGENTS.md:35`), `GUIA-COMPARATIVA-MODELOS/obsoletos/10-GUIA-COMPARATIVA-MODELOS.md` (aunque con 2.689 líneas, no 3.398), `.kilo/command/bucle.md`, `.kilo/agent/bucle.md`, `.kilo/agent/bucle-terreno.md`, todos los scripts nombrados en §21.9/§28.1, `Mensajes entre modelos/ERNIE-5.5-Flash-Preview/REPORTES-Prueba-Paralela/` y el backlog de ERNIE.

---

## 4. Dos acciones de corrección propuestas

### Acción 1 — Sincronizar identidad, flota y stack Godot (documentación narrativa)

**Objetivo:** que AGENTS.md, GUIA-COMUNICACION.md, DIRECTIVAS-PARA-EL-DIRECTOR.md, README.md y la guía comparativa digan lo mismo sobre quién es el director, qué modelos están activos y con qué motor se trabaja.

**Pasos:**

1. **Director:** reemplazar en `AGENTS.md:462`, `:592`, `:995`, `:1544-1545` y `:1626` toda mención de `De-Director V4.1` como director actual por `GLM-5.3 Flash-Director`; dejar las menciones históricas marcadas como "histórico (2026-10-15 → 2026-10-16)". Aplicar el mismo criterio en `GUIA-COMUNICACION.md:218-523` y `DIRECTIVAS-PARA-EL-DIRECTOR.md:5-8`. Añadir una nota de "última actualización" con fecha y modelo.
2. **Flota:** unificar la lista de modelos activos. Tomar como fuente los canales existentes en `Mensajes entre modelos/` (31 carpetas) y marcar explícitamente cuáles son "activos", "históricos" y "en prueba". Actualizar `AGENTS.md:590-615` (§10.3), `:1717-1719` (§31, "7 canales activos") y `GUIA-COMPARATIVA-MODELOS-V1.md:6` ("11 modelos activos").
3. **Stack:** reescribir `AGENTS.md §9` (`:452`), `§14` (`:691-692`), `§18` (`:771-773`), `§22` (`:1082-1111`), `§23` (`:1168`) y `§24` (`:1170-1222`) para Godot 4.7/GDScript: `res://` en lugar de `Assets/`, `godot --headless` y GdUnit/GUT en lugar de Unity Test Framework, export presets en lugar de `BuildPipeline.BuildPlayer`, `print`/`push_warning` en lugar de `Debug.Log`.
4. **Referencias menores:** actualizar `AGENTS.md:28-32` (rango 13-21), `:1245` (ruta real de `cap_godot.py`), `:1269` (quitar blender MCP), `:1134`/`:1165` (20 PASS), `:321` (pool 2400-3000), `:995`/`:1678`/`:1687` (quitar §21.23), `:1360` (cifra de skills).
5. **Guía comparativa:** corregir `:6` (14 modelos distintos), `:196`/`:213`/`:384` (Crouton: elegir un único estado), `:129`/`:294` (eliminar la duplicación de Beam), `:310`/`:384` (estado de Beam), `:342`/`:384` (precio de ERNIE), `:35` (quitar "este chat"), `:390` (2.689 líneas).

**Criterio de cierre (verificable):**

- `git grep -n "De-Director V4.1"` devuelve solo menciones marcadas como histórico.
- `git grep -n "Unity\|BuildPipeline\|MonoBehaviour"` en `AGENTS.md` no devuelve secciones normativas (solo notas históricas si se conservan).
- `python scripts/test_scripts.py` muestra `20 PASS, 0 FAIL` y el número coincide con `AGENTS.md`.
- La lista de modelos activos coincide con las carpetas de `Mensajes entre modelos/` y con la guía comparativa.
- Firma y fecha actualizadas en los 5 archivos.

### Acción 2 — Sanear CHECKLIST-GLOBAL y reconstruir el estado real

**Objetivo:** que el CHECKLIST-GLOBAL sea de verdad la fuente de verdad: sin mojibake, sin IDs duplicados, sin locks stale y con un resumen que coincida con la tabla.

**Pasos:**

1. **Mojibake:** ejecutar `python scripts/fix_encoding.py --dry-run` sobre `CHECKLIST-GLOBAL.md`, revisar el diff y aplicar `python scripts/fix_encoding.py`; verificar con `python scripts/diagnosticar_mojibake.py` (debe salir 0). Prioridad: `:207`, `:212` y `:219` (la leyenda de estados y el resumen).
2. **IDs duplicados:** resolver 48 (líneas 150-151), 115 (52-53), 127 (66-67), 139 (81/83) y 148 (93-94). Para cada par, identificar cuál corresponde a la carpeta real en `DOCUMENTACION/` y cuál es un duplicado; fusionar notas y reasignar el duplicado al siguiente ID libre o eliminar la fila sobrante. Actualizar referencias cruzadas en `00-REFERENCIA-CRUZADA-MAESTRA.md` y en los `05-Checklist.md` afectados.
3. **Filas mal formadas:** corregir `CHECKLIST-GLOBAL.md:25` (M02: la celda `Estado` contiene "164/172" y `Progreso` "165/172"), y revisar las filas que el escaneo clasifica como "OTRO" (101/110, 129/130, 164/172) hasta que todas tengan un emoji de estado válido.
4. **Locks stale:** aplicar `AGENTS.md:943` (§21.4.7) a las 12 filas `🔵`/`🔴` con más de 24 h: M158 (68 días), M139, M41, M45, M49, M159, M161, M23, M17, M20, M33, M59. Confirmar con el agente actual o liberar a `🟡` (con dudas) / `🟢` (disponible) con nota y fecha.
5. **Resumen:** una vez limpia la tabla, ejecutar `python scripts/generar_checklist_global.py --dry-run` y luego `python scripts/generar_checklist_global.py`; reemplazar el bloque `CHECKLIST-GLOBAL.md:214-225` por los números reales (173 filas, 168 módulos, 56 completados, 12 en curso, 96 con dudas, 6 disponibles, 0 sin iniciar, salvo que la limpieza cambie los conteos).
6. **Header:** actualizar `CHECKLIST-GLOBAL.md:2-4` a `GLM-5.3 Flash-Director` y fecha de generación actual.

**Criterio de cierre (verificable):**

- `python scripts/diagnosticar_mojibake.py` sale 0 sobre `CHECKLIST-GLOBAL.md`.
- `python scripts/verificar_checklist.py` no reporta IDs duplicados ni drift de progreso.
- `python scripts/generar_checklist_global.py --dry-run` no propone cambios (o solo los esperados).
- El bloque "Resumen del Proyecto" coincide con el conteo de filas.
- 0 filas `🔵`/`🔴` con última actividad mayor a 24 h sin justificación.
- Firma y fecha del último modificador actualizadas.

---

## 5. Conclusión final

**No, la documentación no está sincronizada con el estado real del proyecto.** Los hallazgos se concentran en tres frentes:

1. **AGENTS.md arrastra una capa Unity/C# completa** (§9, §14, §18, §22, §23, §24) que contradice el motor real (Godot 4.7 en `game/isla-ancestral/`) y su propio título. Es el hallazgo de mayor severidad porque afecta a cualquier agente que codifique o compile.
2. **La identidad del director está desactualizada y contradictoria** dentro de AGENTS.md y en sus dos copias canónicas (`GUIA-COMUNICACION.md` y `DIRECTIVAS-PARA-EL-DIRECTOR.md`). Esto rompe la trazabilidad de encargos, sellos §21.8 y QA cruzado.
3. **El CHECKLIST-GLOBAL, "única fuente de verdad", tiene drift material**: 5 IDs duplicados, 173 filas para 168 módulos, 11 líneas con mojibake (incluida la leyenda de estados), un resumen que declara 167/31/50 frente a 173/56/12 reales, y 12 bloqueos `🔵` stale (M158 con 68 días).

La guía comparativa aporta valor (identifica correctamente los IDs duplicados y el problema Unity/Godot), pero necesita corrección: "11 modelos activos" por 14 reales, Crouton activo/retirado, Beam duplicado, ERNIE gratis/pago, "este chat" en la ficha de Nemotron y una cifra de líneas del histórico que no coincide (2.689 vs 3.398).

**Prioridad recomendada:** (1) Acción 2 (CHECKLIST) porque es lo que todos los agentes leen para trabajar; (2) Acción 1 (identidad + stack) porque afecta la calidad de todo el trabajo posterior. Ambas son acotadas, verificables con scripts existentes y no requieren tocar código del juego.

---

## Anexo A — Evidencia verificada (comandos y resultados)

| Verificación | Resultado |
|---|---|
| `Test-Path game/isla-ancestral/project.godot` | True |
| `Test-Path project.godot` | False |
| `Get-ChildItem . -File` | 67 archivos |
| `Get-ChildItem DOCUMENTACION -File` | 15 documentos generales |
| `Get-ChildItem DOCUMENTACION -Directory` | 168 carpetas de módulo |
| Filas `^\| \d+ \|` en CHECKLIST-GLOBAL | 173 |
| IDs duplicados | 48, 115, 127, 139, 148 |
| Filas `🔵`/`🔴` | 12 (M158 desde 2026-09-04) |
| Líneas con mojibake real | 10, 15, 107, 111, 147, 186, 189, 193, 207, 212, 219 |
| `python scripts/test_scripts.py` | RESULTADO: 20 PASS, 0 FAIL |
| `Logs/NUMEROS_DISPONIBLES.txt` | 601 líneas, 2400-3000, 0 duplicados |
| `Obsoletos/10-GUIA-COMPARATIVA-MODELOS.md` | 2.689 líneas |
| `.kilo/kilo.json` | solo `godot` y `screen` |
| `scripts-reutilizables/cap_godot.py` | no existe; real en `tools/mcp/godot-mcp/scripts-reutilizables/` |
| Backlogs V2 (`BACKLOGS/`) vs raíz | 15 con BACKLOGS, 23 en raíz |
| `Logs/estado_director.json` | última escritura 2026-11-08 03:30 |
| `Mensajes entre modelos/ESTADO-PARALELO.md` | última entrada 2026-10-17 |
| `Mensajes entre modelos/ERNIE-5.5-Flash-Preview/REPORTES-Prueba-Paralela/` | existe; este reporte es el primer archivo |

**Firma del reporte:** ERNIE-5.5-Flash-Preview / Kilo Code — 2026-11-11.