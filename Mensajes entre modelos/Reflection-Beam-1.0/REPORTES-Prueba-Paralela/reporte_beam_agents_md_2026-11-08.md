# Reporte de análisis: AGENTS.md vs estado real del proyecto

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-08
**Archivo analizado:** `AGENTS.md` (raíz del proyecto)
**Archivo contrastado:** `CHECKLIST-GLOBAL.md` (raíz del proyecto)

---

## 1. Referencias a archivos que ya no existen

Se verificaron las rutas con prefijo explícito (`DOCUMENTACION/`, `Mensajes `, `Logs/`, `scripts/`, `.kilo/`, `docs/`, `Obsoletos/`) citadas en `AGENTS.md`.

- **Única referencia rota detectada:** `scripts/world/mundo_raiz.gd` (citada en `AGENTS.md` §26, "Módulos de Terreno e Islas"). El archivo **sí existe**, pero en `game/isla-ancestral/scripts/world/mundo_raiz.gd` (raíz del proyecto Godot), no en la raíz del repositorio. La referencia asume la raíz del repo como base, lo que la vuelve inencontrable para un agente que parta del repositorio.
- El resto de rutas con prefijo (`DOCUMENTACION/06-GUIA-DE-CONEXION-VISION.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `DOCUMENTACION/11-BUGS.md`, `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md`, `Mensajes entre modelos/GUIA-COMUNICACION.md`, `Logs/NUMEROS_DISPONIBLES.txt`, `.kilo/command/bucle.md`, etc.) **existen**.
- Muchas referencias aparecen como nombres sueltos (ej. `01-Requerimientos.md`, `BACKLOG-MASTER.md`, `INDICE.md`) sin base de ruta; son válidas solo por contexto implícito (`DOCUMENTACION/{ID}/plan-actual/`, `DOCUMENTACION/TAREAS-POR-MODELO/...`). Esto no es una rotura, pero genera ambigüedad.

**Conclusión parcial:** 1 referencia efectivamente desalineada con la estructura real (`scripts/world/mundo_raiz.gd`).

---

## 2. Instrucciones desactualizadas respecto al estado real del proyecto

| # | Sección / Línea AGENTS.md | Instrucción actual | Estado real del proyecto | Desfase |
|---|---|---|---|---|
| 2.1 | §3, línea 53 | "La raíz del proyecto solo contiene `AGENTS.md`, `README.md`, `CHECKLIST-GLOBAL.md`, y configuraciones generales." | La raíz contiene además `DOCUMENTACION/`, `Mensajes entre modelos/`, `Logs/`, `scripts/`, `game/`, `tools/`, `docs/`, `.kilo/`, `.claude/`, etc. | Desactualizado |
| 2.2 | §24 (Stack Tecnológico) | Declara motor **Unity**, lenguaje **C#**, namespaces `IslaAncestral.*`, estructura `Assets/` con `MonoBehaviours`, `ScriptableObject`, `Unity Test Framework (NUnit)`. | El proyecto es **Godot 4.x** (GDScript), ubicado en `game/isla-ancestral/` con `project.godot`; los tests son Godot/GdUnit. | Desactualizado (plantilla Unity sin adaptar) |
| 2.3 | §22 (Empaquetado) | "Unity Build Pipeline" con `BuildPipeline.BuildPlayer()`. | Exportación Godot (`export_presets.cfg`, builds en `build/`). | Desactualizado |
| 2.4 | §14 (Testings) | "Unity Test Framework (NUnit) para Edit Mode y Play Mode tests". | GdUnit4 / suites Godot headless (ver `CHECKLIST-GLOBAL.md` y `scripts/run_tests.*`). | Desactualizado |
| 2.5 | §21.6 (Finalización) | "El proyecto se considera completo cuando los **100 módulos** (o el total definido) estén `✅`." | `CHECKLIST-GLOBAL.md` tiene IDs hasta **168** (173 filas, 168 IDs únicos). | Desactualizado (subestima el total) |
| 2.6 | §10.2 (Modo Canal) | Ejemplo de canales: `Hy3/`, `DeepSeek-V4.1-Flash/`, `agnes-3-flash/`, `mimo-v2.6-flash-free/`, `kimi-k3/`. | Existen ~20+ canales activos (`Reflection-Beam-1.0`, `DS-V4.1-Flash-Opencode`, `Step-5-WorkBuddy`, `atria-dawn-s2/s3`, `GLM-5.3-Flash-Director`, etc.). | Desactualizado (ejemplo incompleto) |
| 2.7 | §31 (Director) | Identifica al director como `GLM-5.3 Flash-Director`. | `CHECKLIST-GLOBAL.md` header firma "Modelo: glm-5.3-flash (último modificador)". | Inconsistencia menor de nombre |

---

## 3. Inconsistencias entre AGENTS.md y CHECKLIST-GLOBAL.md

1. **Conteo de módulos:** AGENTS.md §21.6 habla de "100 módulos"; CHECKLIST-GLOBAL.md tiene 173 filas / 168 IDs únicos (máx. ID 168). El "total definido" no está sincronizado.
2. **Unicidad de IDs (§11 de AGENTS.md):** AGENTS.md exige que el ID del módulo sea único y tomado de CHECKLIST-GLOBAL.md como fuente de verdad. CHECKLIST-GLOBAL.md contiene **IDs duplicados**: 48, 115, 127, 139, 148 (5 IDs repetidos). Viola la propia regla.
3. **Filas malformadas (columnas):** Varias filas tienen número de columnas distinto al esperado (11 en vez de 12, o 13). Ejemplos:
   - `| 22 | 22-Historia-Principal | ... | 80/91 | Alta | 4 | 21, 28 | — | 2026-10-31 02...` (11 columnas)
   - `| 53 | 53-UI-UX | ✅ Sello-módulo-deuda ... | 159/165 | Media | 3 | 45, 46 | — | 202...` (11 columnas)
   - `| 75 | 75-Postgame | ✅ | 43/130 | — | 3 | 22 | — | 2026-10-26 08:40 |**🟡 Liberado...` (11 columnas)
   - `| 85 | 85-Modelos-3D-Legal | 🟡 Completado — 🔻 DoD §21.6 violada...` (11 columnas)
   - `| 87 | 87-Localizacion | ✅ Completado (QA §21.8) | 140/140 | Media | 3 | 53,86 | — | 2026-...` (11 columnas)
   - `| 112 | 112-Testing-Automatico | 🟡 Con dudas | 228/232 | 221/225 | Alta | 3 | 111 | — | 2026-10-27 07:20 |` (13 columnas)
   - `| 151 | 151-Control-Final | 🟡 Con dudas | 156/167 | 155/167 | Media | 2 | 142 | — | mimo-v...` (13 columnas)
   AGENTS.md §21.1 define una tabla de 10 columnas canónicas; CHECKLIST-GLOBAL.md usa 11 (agrega "Recom") y además tiene drift de columnas.
4. **Estado del proyecto vs. DoD:** AGENTS.md §21.6 exige que un módulo `✅` tenga todos los subitems `[x]` y haya pasado QA cruzado. CHECKLIST-GLOBAL.md contiene filas `✅` con `[ ]` abiertos (ej. M75 "43/130", M85 "DoD violada: 25 [ ]", M112 con `[ ]`), contradiciendo la DoD definida en AGENTS.md.
5. **Tabla de ejemplo en AGENTS.md (§21.1):** muestra 10 columnas sin la columna "Recom", que sí existe y es usada operativamente en CHECKLIST-GLOBAL.md. Desfase de esquema documentado.

---

## 4. Acciones de corrección sugeridas

1. **Actualizar AGENTS.md §24, §22 y §14 para reflejar el stack real (Godot 4.x / GDScript / GdUnit4 / export Godot)**, eliminando referencias a Unity, C#, `MonoBehaviours`, `ScriptableObject` y `BuildPipeline.BuildPlayer()`. También corregir §3 (raíz del proyecto) y §21.6 (total de módulos: 168 IDs, no 100), y la ruta de `scripts/world/mundo_raiz.gd` → `game/isla-ancestral/scripts/world/mundo_raiz.gd`.
2. **Sanear CHECKLIST-GLOBAL.md:** eliminar IDs duplicados (48, 115, 127, 139, 148), normalizar filas con número de columnas incorrecto (22, 53, 75, 85, 87, 112, 151), y re-bajar a `🟡` los módulos `✅` que tienen `[ ]` abiertos, para cumplir la DoD de AGENTS.md §21.6. Regenerar la tabla con `scripts/generar_checklist_global.py` tras la limpieza y verificar con `scripts/verificar_checklist.py`.

---

## Conclusión final

`AGENTS.md` es un documento extenso y mayormente vigente en su núcleo metodológico (protocolo multiagente, numeración de logs, firmas, codificación UTF-8), pero arrastra **plantillas de un proyecto Unity** (§14, §22, §24) que no corresponden a Isla Ancestral (Godot 4.x), contiene un **conteo de módulos desactualizado** (100 vs. 168 reales) y una **ruta de archivo desalineada** (`scripts/world/mundo_raiz.gd`). Por su parte, `CHECKLIST-GLOBAL.md` —declarada fuente de verdad— presenta **drift estructural** (IDs duplicados, filas con columnas faltantes/sobrantes, módulos `✅` con `[ ]` abiertos) que contradice la DoD definida en AGENTS.md §21.6. Se recomienda ejecutar las dos acciones de corrección sugeridas para restaurar la consistencia documental antes de continuar con el trabajo de la flota.
