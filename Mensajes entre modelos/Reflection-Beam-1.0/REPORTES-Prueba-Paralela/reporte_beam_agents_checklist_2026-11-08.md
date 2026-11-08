**Modelo:** reflection/beam-free
**Plataforma:** Kilo
**Fecha:** 2026-11-08

# Reporte: Análisis de AGENTS.md vs CHECKLIST-GLOBAL.md (Isla Ancestral)

## 1. Resumen ejecutivo

Se revisaron `AGENTS.md` (raíz) y `CHECKLIST-GLOBAL.md` (raíz) contra el estado real del repositorio (Godot 4.x, estructura `DOCUMENTACION/`, canales en `Mensajes entre modelos/`, scripts en `scripts/`). Se detectaron instrucciones desactualizadas, inconsistencias entre ambos archivos y referencias a artefactos inexistentes. El bloque más grave es la sección de stack tecnológico de `AGENTS.md` (§9, §14, §18, §22, §24), que describe Unity/C# mientras el proyecto es Godot/GDScript.

## 2. Instrucciones desactualizadas en AGENTS.md (respecto al estado real)

| # | Sección / Líneas | Contenido desactualizado | Estado real del proyecto |
|---|---|---|---|
| D1 | §9 (líneas ~451-455) | Habla de `MonoBehaviours`, `ScriptableObject`, patrones MVC/MVP/ECS para Unity | Proyecto es Godot 4.x; la UI se implementa con escenas `.tscn` y GDScript (ver `DOCUMENTACION/GUIA-GODOT/`) |
| D2 | §14 (líneas ~555-565) | "Unity Test Framework (NUnit) para Edit Mode y Play Mode tests" | Tests reales son suites GDScript headless (`test_*.gd`) ejecutadas por `run_tests.gd` (M112) |
| D3 | §18 (líneas ~610-650) | Logging persistente a archivo fuera de `Assets/`, rotación Unity | Logging real es `Logger` GDScript + `LogRotator` (M103), con `user://` y suites Godot 4.7 |
| D4 | §22 (líneas ~870-900) | `BuildPipeline.BuildPlayer`, `.exe` + `_Data/`, Addressables/AssetBundles | Build real usa `export_presets.cfg` + `build_installer.bat`/`setup_windows.ps1` (M116/M117) |
| D5 | §24 (líneas ~920-1010) | Stack completo Unity: URP/HDRP, PhysX, UI Toolkit/Canvas, namespaces `IslaAncestral.*`, convenciones C# | Stack real: Godot 4.x, GDScript, VoxelTools, autoloads, escenas `.tscn` |
| D6 | §19 (líneas ~580-590) | Indica crear/mover hilos resueltos a `Mensajes entre modelos/RESUELTOS/` | La carpeta `Mensajes entre modelos/RESUELTOS/` **no existe** en el repo (verificado `Test-Path` = False) |
| D7 | §10.2/§10.3 (líneas ~460-616) | Nombran al director como `De-Director V4.1` | §31 y §32 (líneas ~1180-1260) indican que el director actual es `GLM-5.3 Flash-Director` (relevo 2026-10-16) |

## 3. Inconsistencias entre AGENTS.md y CHECKLIST-GLOBAL.md

| # | AGENTS.md | CHECKLIST-GLOBAL.md | Inconsistencia |
|---|---|---|---|
| I1 | §31/§32: director actual = `GLM-5.3 Flash-Director` | Header línea 2: `**Modelo:** glm-5.3-flash (último modificador)`; línea 4: `**Última generación automática:** 2026-09-15` | Identidad y fecha de generación desactualizadas vs. el relevo del director y el contenido (menciona 2026-10-23) |
| I2 | §10.3 tabla de prioridad de canales (líneas ~597-615) lista `step-5-kilocode` como "Kilo Code dado de baja 2026-10-15" | Fila 109: `Recom: Step-5-WorkBuddy`; filas 17/20/33/59/117 referencian `Step-5`/`Step-5-WorkBuddy` | Convive un canal `step-5-kilocode` (dado de baja) con `Step-5-WorkBuddy` (activo); la tabla global no deja claro cuál es el frente vigente |
| I3 | §7/§21: `CHECKLIST-GLOBAL.md` es "única fuente de verdad" del estado global | Filas con columnas desalineadas (p. ej. fila 02 `164/172 | 165/172` sin emoji de Estado; fila 46 `101/110 | 101/110` sin Estado) y 5 IDs duplicados (48, 115, 127, 139, 148) | El propio archivo que debe ser fuente de verdad tiene drift de formato y duplicados |
| I4 | §21.2: estados `⬜/🟢/🔵/🔴/🟡/✅` y DoD §21.6 | Filas con estados compuestos (`🟡 Con dudas (iter. 1)`, `✅ Completado (QA §21.8)`) y filas duplicadas con estado distinto (115: `🟡` vs `🟢`; 127: `🟡` vs `🟢`; 139: `🟡` vs `🔵`; 148: `🟡` vs `🟡`) | La simbología estricta del protocolo no se cumple en el tablero |
| I5 | §21.8: QA cruzado por modelo distinto al autor | Varias filas citan sellos inválidos luego revocados (ej. fila 119 "Log 866 inválido", fila 114 "Sello Log 866 inválido") | El tablero acumula historial de sellos inválidos sin limpieza, dificultando la auditoría |

## 4. Referencias a archivos o modelos que ya no existen (o no existen aún)

| # | Referencia en AGENTS.md | Verificación |
|---|---|---|
| R1 | §19: `Mensajes entre modelos/RESUELTOS/` (carpeta a crear al resolver hilos) | No existe en el repo (Test-Path = False). Solo se menciona como convención. |
| R2 | §27: skills en `.claude/skills/` (existe) pero §24/§9/§14/§18/§22 referencian artefactos Unity (`Assets/`, `BuildPipeline`, `ScriptableObject`) | No hay carpeta `Assets/` ni pipeline Unity; el proyecto usa `scenes/`, `scripts/`, `export_presets.cfg`. |
| R3 | §10.3: lista canales `muse-spark-1.3-contributor`, `kimi-k3`, `GLM-5.3-Flash` (existen) pero también `step-5-kilocode` marcado como dado de baja | La carpeta existe pero el frente activo es `Step-5-WorkBuddy`; la convivencia genera ambigüedad. |
| R4 | §32: `DOCUMENTACION/TAREAS-POR-MODELO/GLM-5.3-Flash-Director/SUCESION-HERENCIA-24oct.md` y `Logs/estado_director.json` | Ambos existen (Test-Path = True), pero no hay validación de que estén actualizados a la fecha actual (2026-11-08). |
| R5 | §21.9: scripts `generar_checklist_global.py`, `verificar_checklist.py`, `test_scripts.py` | Existen; sin embargo `CHECKLIST-GLOBAL.md` no parece regenerado desde 2026-09-15 (header), por lo que la tabla global está stale respecto a los `05-Checklist.md`. |

## 5. Acciones de corrección sugeridas (2)

1. **Sincronizar la identidad del director y la metadata del tablero global.** Actualizar el header de `CHECKLIST-GLOBAL.md` (`**Modelo:** GLM-5.3 Flash-Director`, `**Última generación automática:**` con fecha real 2026-11-08) y corregir en `AGENTS.md` §10.2/§10.3 las referencias a `De-Director V4.1` para que coincidan con §31/§32. Además, eliminar o fusionar las filas duplicadas (IDs 48, 115, 127, 139, 148) y normalizar las columnas desalineadas (fila 02, fila 46, fila 112, fila 151) para que el tablero vuelva a ser fuente de verdad confiable.

2. **Reemplazar el bloque Unity/C# de AGENTS.md por el stack real de Godot.** Reescribir §9, §14, §18, §22 y §24 para describir GDScript, VoxelTools, escenas `.tscn`, tests headless Godot, `export_presets.cfg` y el pipeline de M116/M117. Además, crear la carpeta `Mensajes entre modelos/RESUELTOS/` (o eliminar la referencia de §19) y regenerar `CHECKLIST-GLOBAL.md` con `python scripts/generar_checklist_global.py` para cerrar el drift entre tabla y `05-Checklist.md`.

## 6. Conclusión final

`AGENTS.md` conserva un bloque heredado de Unity que ya no corresponde al proyecto (Godot 4.x) y referencias internas inconsistentes sobre la identidad del director. `CHECKLIST-GLOBAL.md` acumula duplicados, drift de columnas y metadata stale (última generación 2026-09-15) que contradicen su rol de fuente de verdad. La prioridad de corrección es: (a) alinear identidad del director y fecha de generación del tablero, y (b) sustituir el stack Unity por Godot y regenerar el checklist global. Con esas dos acciones se elimina la mayor parte del drift detectado.
