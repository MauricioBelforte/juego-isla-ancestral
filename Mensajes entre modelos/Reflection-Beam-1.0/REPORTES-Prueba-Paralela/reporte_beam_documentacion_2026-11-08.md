# Reporte de Análisis de Documentación — AGENTS.md vs CHECKLIST-GLOBAL.md vs GUIA-COMPARATIVA-MODELOS-V1.md

**Modelo:** Reflection Beam 1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08
**Archivo analizado (AGENTS.md):** `AGENTS.md` (1752 líneas)
**Archivo analizado (guía):** `DOCUMENTACION/GUIA-COMPARATIVA-MODELOS/GUIA-COMPARATIVA-MODELOS-V1.md` (227 líneas)
**Archivo analizado (coordinador):** `CHECKLIST-GLOBAL.md`

---

## 1. Resumen ejecutivo

Se detectaron **3 categorías de problemas** en la documentación del proyecto `game/isla-ancestral`:

1. **Instrucciones desactualizadas** respecto al estado real del proyecto (motor Unity/C# cuando el proyecto es Godot 4.x/GDScript; conteo de "100 módulos" cuando existen 168+).
2. **Inconsistencias de esquema y roles** entre `AGENTS.md` y `CHECKLIST-GLOBAL.md` (columna `Recom` no documentada; director vigente vs director histórico).
3. **Referencias a archivos inexistentes** (principalmente la guía histórica `obsoletos/10-GUIA-COMPARATIVA-MODELOS.md` que en disco lleva prefijo de timestamp).

---

## 2. (1) Instrucciones desactualizadas respecto al estado real del proyecto

### 2.1 Stack tecnológico incorrecto (Unity/C# vs Godot)

- **AGENTS.md §24 (líneas 1170-1222)** declara:
  - `Motor: Unity (versión LTS más reciente recomendada)` (línea 1173)
  - `Lenguaje: C# (.NET Standard 2.1 / .NET Framework)` (línea 1174)
  - `IDE recomendado: Visual Studio 2022 / Rider` (línea 1175)
  - Convenciones de código C# (`IslaAncestral.[Sistema]`, PascalCase, `[SerializeField]`) (líneas 1217-1222)
- **Estado real:** el proyecto es Godot 4.x con GDScript (ver `DOCUMENTACION/GUIA-GODOT/`, `scripts/world/mundo_raiz.gd`, módulos 08-Mundo-Voxel, 09-Terreno-Y-Geografia, etc.). La carpeta raíz es `game/isla-ancestral/` y todos los módulos referencian `.gd`, `.tscn`, `.tres`.
- **Impacto:** un agente nuevo podría escribir código C#/Unity siguiendo §24, rompiendo el proyecto. También §14 (líneas 684-719) menciona "Unity Test Framework — Edit Mode Tests / Play Mode Tests" y §18 (líneas 771-791) "Unity/C#", §22 (líneas 1082-1111) "Unity Build Pipeline" — todos desactualizados respecto al stack real.

### 2.2 Conteo de módulos desactualizado

- **AGENTS.md §21.6 (línea 971):** "El proyecto se considera completo cuando **los 100 módulos** (o el total definido) estén `✅`."
- **Estado real:** `CHECKLIST-GLOBAL.md` contiene módulos hasta el ID 168 (`168-Plantilla-De-Isla`) y referencias a 167-Isla-Raiz. Hay al menos 168+ módulos, no 100.

### 2.3 Director vigente vs director histórico

- **AGENTS.md §10.2 (línea 462):** "Modo Canal — hilo permanente director <-> agente … entre el **director (De-Director V4.1)** y cada agente activo."
- **AGENTS.md §10.3 (línea 592):** tabla de prioridad con encabezado "Cuando el director (De-Director V4.1) tiene varios canales pendientes…"
- **AGENTS.md §31 (líneas 1658-1666):** el director vigente es **`GLM-5.3 Flash-Director`** (GLM-5.3-Flash, Kilo Code), desde 2026-10-16; `De-Director V4.1` (DeepSeek V4.1 Flash) solo dirigió 2026-10-15 → 2026-10-16.
- **Inconsistencia interna:** §10.2 y §10.3 siguen nombrando al director como `De-Director V4.1`, mientras §31 (canónico según el propio texto) lo define como `GLM-5.3 Flash-Director`. Un agente que lea §10.2 antes que §31 puede dirigir sus reportes al canal equivocado.

### 2.4 Prioridad de canales desactualizada

- **AGENTS.md §10.3 (líneas 597-608):** lista `Step-5-WorkBuddy` como "único frente Step 5 (Kilo Code dado de baja 2026-10-15)" y `kimi-k3`, `muse-spark-1.3-contributor`, `GLM-5.3-Flash` como "resto de modelos activos".
- **Estado real (guía comparativa V1, líneas 196-203):** los modelos en integración son `Crouton Alpha`, `Stealth Glyph Cluster` y `Reflection Beam 1.0` (supervisados por Nemotron-3.5-Super-VL); los demás (Atria-Dawn-Preview, Kimi K3, Claude Haiku 5.5, StepFun Step 5, Nemotron 3 Ultra, etc.) están en `obsoletos/`. La guía V1 ya no considera a `kimi-k3`, `muse-spark` ni `GLM-5.3-Flash` como activos de la flota principal, mientras AGENTS.md §10.3 los sigue listando.

---

## 3. (2) Inconsistencias entre AGENTS.md y CHECKLIST-GLOBAL.md

### 3.1 Esquema de columnas no coincide

- **AGENTS.md §21.1 (línea 840):** tabla de ejemplo con 10 columnas: `ID | Módulo | Estado | Progreso | Prioridad | Complejidad | Dependencias | Agente actual | Última actividad | Notas`.
- **CHECKLIST-GLOBAL.md (línea 22):** tabla real con **11 columnas**, incluyendo una columna adicional `Recom` (modelo recomendado) entre `Dependencias` y `Agente actual`.
- **Impacto:** AGENTS.md no documenta la columna `Recom`, que es la que los agentes usan para elegir módulos (§29.1 punto 3: "Buscar tareas pendientes en los plan-actual/ de los módulos que te corresponden (por tu Recom)"). Falta actualizar §21.1 con la columna `Recom`.

### 3.2 Duplicación de filas en CHECKLIST-GLOBAL

- **CHECKLIST-GLOBAL.md (línea 53):** fila duplicada para M115 (`115-Hardware`) — una 🟡 (78/104, Recom agnes-3-flash) y otra 🟢 (78/104, Recom deepseek-v4-flash).
- **CHECKLIST-GLOBAL.md (línea 67):** fila duplicada para M127 (`127-Copyright-Del-Juego`) — una 🟡 (76/100) y otra 🟢 (76/100).
- **Inconsistencia:** el protocolo §21.4 regla 1 dice "UN módulo por agente a la vez", pero la tabla tiene dos filas para el mismo ID, lo que rompe la unicidad de la fuente de verdad.

### 3.3 Progreso con formato inconsistente

- **CHECKLIST-GLOBAL.md (línea 49):** M112 tiene `228/232 | 221/225` (dos valores de progreso separados por `|`).
- **CHECKLIST-GLOBAL.md (línea 46):** M11 tiene `91/123` pero la columna Progreso aparece dos veces en el encabezado (la tabla real tiene 11 columnas pero algunas filas tienen 12 celdas). Drift de formato que `verificar_checklist.py` debería detectar.

### 3.4 Estado global vs estado declarado en notas

- **CHECKLIST-GLOBAL.md M01 (línea 24):** Estado `🟡 Con dudas`, Progreso `73/152`, pero la nota dice "26/152" (medición DeepSeek msg 252). Drift entre la columna Progreso y el conteo real documentado en la nota. AGENTS.md §21.9 punto 2 (`verificar_checklist.py`) está diseñado para detectar este tipo de drift, pero no se ha aplicado.

---

## 4. (3) Referencias a archivos o modelos que ya no existen

### 4.1 Archivo histórico con nombre incorrecto

- **Guía comparativa V1 (línea 221):** "Versión histórica completa (pre-V1, 3398 líneas): `obsoletos/10-GUIA-COMPARATIVA-MODELOS.md` (respaldo del 2026-11-04)."
- **Estado real en disco:** el archivo NO existe en `DOCUMENTACION/OBSOLETOS/10-GUIA-COMPARATIVA-MODELOS.md`. El archivo real es `DOCUMENTACION/OBSOLETOS/2026-10-25_18-19-14_10-GUIA-COMPARATIVA-MODELOS.md` (con prefijo de timestamp).
- **Impacto:** cualquier agente que siga la referencia de la guía V1 no encontrará el archivo histórico.

### 4.2 Modelos listados como activos que ya no lo son

- **AGENTS.md §10.3 (líneas 607-608):** lista `kimi-k3`, `muse-spark-1.3-contributor`, `GLM-5.3-Flash` como "resto de modelos activos (si hay alguno más trabajando)".
- **Guía comparativa V1 (líneas 200-204):** "Los modelos no listados arriba (Atria-Dawn-Preview, Kimi K3, Claude Haiku 5.5, StepFun Step 5, Nemotron 3 Ultra, Thinking Machines Inkling, Poolside Laguna S 2.1) están en la versión histórica completa (`obsoletos/10-GUIA-COMPARATIVA-MODELOS.md`)."
- **Inconsistencia:** la guía V1 ya movió a `kimi-k3` y `muse-spark` a histórico, pero AGENTS.md §10.3 los sigue listando como activos. Además, `GLM-5.3-Flash` (rol agente) fue relevado por `GLM-5.3 Flash-Director` (§31), por lo que su canal agente es histórico.

### 4.3 Referencia a `IDENTITY.md` compartido (WorkBuddy)

- **AGENTS.md §7 (línea 431):** "Trampa del `IDENTITY.md` compartido (WorkBuddy, detectada 2026-10-03): WorkBuddy comparte un único archivo `IDENTITY.md` entre todos sus chats."
- **Verificación:** no se encontró `IDENTITY.md` en la raíz del proyecto ni en la carpeta del proyecto. Es una referencia a un archivo externo a la plataforma, no del repo. No es un error grave, pero es una referencia a un artefacto no versionado que un agente no puede verificar.

### 4.4 Backlogs personales V2 — estructura asumida

- **AGENTS.md §29.1 (líneas 1459-1489):** asume que cada carpeta `TAREAS-POR-MODELO/<MODELO>/` contiene `BACKLOGS/BACKLOG-MASTER.md` + `01-Backlog-(tema).md` + `00-Backlog-Original-PreSplit.md`.
- **Verificación en disco:** la carpeta `DOCUMENTACION/TAREAS-POR-MODELO/` existe y contiene ~30+ subcarpetas de modelos, pero no se verificó que todas tengan la estructura `BACKLOGS/` con los 3 archivos. La guía V1 (línea 215) confirma que "Beam tiene su propio BACKLOG-MASTER en `DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0/BACKLOG-MASTER.md`", pero la estructura real del canal de Beam muestra archivos numerados 601-626 en `Mensajes entre modelos/Reflection-Beam-1.0/` (no en `TAREAS-POR-MODELO/`). Posible desfase entre la estructura documentada y la real.

---

## 5. Acciones de corrección sugeridas

### Acción 1 — Actualizar AGENTS.md §24 (Stack Tecnológico) y secciones Unity-relacionadas

**Problema:** §24, §14, §18 y §22 asumen Unity/C# cuando el proyecto es Godot 4.x/GDScript.
**Corrección sugerida:**
- Reescribir §24 para reflejar: Motor Godot 4.x, lenguaje GDScript, IDE Godot Editor / VS Code con extensión Godot, estructura de carpetas Godot (`scenes/`, `scripts/`, `assets/`, `resources/`), testing con GdUnit4 o el runner propio del proyecto (`res://tests/run_tests.gd`).
- Reemplazar menciones de "Unity Test Framework" en §14 por el runner de tests del proyecto.
- Reemplazar §22 (Unity Build Pipeline) por el pipeline de exportación de Godot (`export_presets.cfg`, `godot --headless --export-release`).
**Evidencia:** módulos 07-Arquitectura-General, 08-Mundo-Voxel, 09-Terreno-Y-Geografia, 10-Generacion-Del-Mundo, 117-Build-System, 118-CI-CD.

### Acción 2 — Sincronizar AGENTS.md con CHECKLIST-GLOBAL.md (esquema, conteo, director)

**Problema:** AGENTS.md §21.1 no documenta la columna `Recom`; §21.6 dice "100 módulos"; §10.2/§10.3 nombran al director como `De-Director V4.1` (stale).
**Corrección sugerida:**
- Actualizar §21.1 para incluir la columna `Recom` en la tabla de ejemplo y documentar su uso (modelo recomendado por módulo).
- Cambiar "los 100 módulos" por "el total de módulos definido en CHECKLIST-GLOBAL.md (actualmente 168+)".
- Reemplazar en §10.2 y §10.3 "director (De-Director V4.1)" por "director (GLM-5.3 Flash-Director)" y actualizar la tabla de prioridades de canales con los modelos vigentes según la guía comparativa V1.
- Corregir en `CHECKLIST-GLOBAL.md` las filas duplicadas (M115, M127) y el drift de progreso (M01, M11, M112), ejecutando `python scripts/verificar_checklist.py` y `python scripts/generar_checklist_global.py --dry-run` para validar.
**Evidencia:** CHECKLIST-GLOBAL.md líneas 22, 24, 46, 49, 53, 67; AGENTS.md líneas 462, 592, 840, 971.

---

## 6. Conclusión final

La documentación del proyecto es **extensa y detallada**, pero acumula **capas de instrucciones históricas** (Unity/C#, director De-Director V4.1, 100 módulos) que ya no reflejan el estado real (Godot 4.x, director GLM-5.3 Flash-Director, 168+ módulos). La inconsistencia más crítica para la operación diaria es el **desfase del stack tecnológico en §24** (un agente nuevo podría escribir C#/Unity) y el **desfase del director en §10.2/§10.3** (reportes podrían ir al canal equivocado). La referencia rota a `obsoletos/10-GUIA-COMPARATIVA-MODELOS.md` (línea 221 de la guía V1) es un error menor pero fácil de corregir (el archivo real lleva prefijo de timestamp). Se recomienda aplicar las dos acciones de corrección sugeridas antes de que nuevos agentes se incorporen al proyecto.

**Firma:** Reflection Beam 1.0 / Kilo Code — 2026-11-08
""",
    "filePath": "D:\\Escritorio\\PORTFOLIO\\Proyectos para GitHub\\PROYECTOS OPENCODE\\juego-isla-ancestral\\Mensajes entre modelos\\Reflection-Beam-1.0\\REPORTES-Prueba-Paralela\\reporte_beam_documentacion_2026-11-08.md"
}