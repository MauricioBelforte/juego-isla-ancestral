**Modelo:** muse-spark-1.3-contributor
**Plataforma:** Cline

# BACKLOG MASTER — muse-spark-1.3-contributor (curado por ENCAJE)

> Backlog personal segun `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`.
> **Fuente de tareas:** `[ ]` / `[?]` de los `05-Checklist.md` de cada modulo (fuente de verdad).
> Relevo autorizado por el usuario (2026-09-14): ox-alpha ya no esta en el proyecto; tomo su reserva M111.
> Hallazgo critico (Log 891): el 05-Checklist de M111 dice 174/209 pero Hy3 YA implemento las 35 utilidades
> (Log 771) — el checklist quedo sin sincronizar. Mi iteracion 1 = verificar codigo-real vs checklist + tests.

> **Curacion v1 (2026-09-14):** backlog ordenado por encaje real con mis fortalezas declaradas
> (`10-GUIA-COMPARATIVA-MODELOS.md` §5.K/§18): *flujos agenticos largos, coding con tool calling fiable,
> instrucciones largas sin deriva, auditoria multi-archivo con evidencia, QA headless, validacion,
> tooling/CI, V0*. Debilidades que **excluyen** tareas: aprobacion visual final (V2 sin verificar en host),
> generacion de assets 3D, Blender/bpy sin demostrar, razonamiento `"max"` (no disponible en mi tier).

**Modulos asignados:** 6 · **Iteraciones cerradas:** 2 (M111 Log 909, M117 Log 941)
**Estado:** A1 (M111) cerrado 209/209. A2 (M117) iter. 2 cerrada con 20 `[?]` de dueno externo.
**Siguiente en cola (encaje ALTO, V0, verificable headless):** A3 (M122 Crash-Reporting, 80 pendientes).

> REGLA OBLIGATORIA — CODIFICACION UTF-8
> Todos los archivos del proyecto DEBEN guardarse en UTF-8 sin BOM. NUNCA en cp1252/ANSI.
> Ver AGENTS.md seccion 28 para detalles y herramientas de reparacion.

## Criterio de encaje (3 niveles)

| Nivel | Que es | Mi rol |
|-------|--------|--------|
| **A — Nucleo de especialidad** | Codigo, validacion, auditoria multi-archivo, tests headless, tooling/CI, datos estructurados | **Ejecuto de punta a punta** (codigo + test + log) |
| **B — Sistemas con criterio de diseno** | Gameplay con logica + decision de diseno; documentacion tecnica | Ejecuto la **parte tecnica/verificable**; la decision la dejo `[?]` con dueno |
| **C — Visual / arte / audio / contenido** | Animacion, VFX, arte, marketing, narrativa, musica | **NO soy aprobador visual.** Puedo hacer plumbing data-driven pero la aprobacion final es de otro especialista / usuario |

---

## Nivel A — Nucleo de especialidad (tomar primero)

Ordenados por encaje, no por fila global.

| # | ID | Modulo | Estado | Progreso | Pend. | Por que encaja | Subcarpeta |
|---|----|--------|--------|----------|-------|----------------|------------|
| A1 | 111 | 111-Codigo-De-Calidad | ✅ CERRADO iter. 1 (Log 909) — 209/209, 35/35 personales, pendiente QA cruzado §21.8 | 209/209 (checklist sincronizado) | 0 | **Auditoria codigo-real vs checklist + tests: mi fortaleza #1** | `111-Codigo-De-Calidad/checklist.md` |
| A2 | 117 | 117-Build-System | 🟡 Con dudas acumuladas (iter. 2 cerrada, Log 941) | 92/110 (18 [?] modulo con dueno) | 20 [?] externos | Tooling/packaging empaquetado, gates, manifest SHA-256, smoke tests | `117-Build-System/checklist.md` |
| A3 | 122 | 122-Crash-Reporting | Con dudas | 185/265 | 80 | Validadores, sanitizacion, hashing, offline/cache, diseno-tecnico verificable | `122-Crash-Reporting/checklist.md` |
| A4 | 63 | 63-Cargas-Y-Streaming | Liberado | 16/101 | 85 | Pantalla de carga, streaming, validacion headless | `63-Cargas-Y-Streaming/checklist.md` |
| A5 | 68 | 68-Transporte-Y-Navegacion | Con dudas | 36/131 | 85 + 10 [?] | Grafo .tres, dijkstra, persistencia waypoints: data-driven + headless | `68-Transporte-Y-Navegacion/checklist.md` |
| A6 | 26 | 26-Templo-Subterraneo | Disponible | 8/119 | 110 + 1 [?] | Sistema con checkpoints/save atomico/testeable (parte tecnica) | `26-Templo-Subterraneo/checklist.md` |

**Totales Nivel A:** M111 35 items a verificar contra codigo real (Hy3 Log 771) + M117 53 + resto por auditar.
**Compromiso minimo verificado para este backlog v1:** auditoria M111 con evidencia + tests headless de utils,
mas M117 en la siguiente iteracion (regla: minimo 100 tareas por modelo; M122 aporta 80).

---

## NO TOCAR — modulos con agente activo (regla §21.4)

Ninguno de mis 6 modulos tiene `Agente actual` distinto de vacio al 2026-09-14 (M111: reserva huerfana de
ox-alpha, fuera del proyecto por directiva del usuario → relevo con nota).

---

## Cola de trabajo inmediata (encaje ALTO, primera iteracion M111)

| Orden | Modulo | Tarea | Que es | Por que yo |
|-------|--------|-------|--------|-----------|
| 1 | 111 | T-001 | Crear tests unitarios (M112) para utils M111 | Tests headless de codigo existente |
| 2 | 111 | T-002 | Crear tests de integracion (M112) para interfaces M111 | Tests headless de contratos |
| 3 | 111 | T-003..T-004 | Convenciones de grupos de nodos + layers fisica/render | Estandares verificables contra proyecto |
| 4 | 111 | T-005..T-013 | Patrones State/Observer/Factory/Command/Strategy + composicion + componentes | Auditoria codigo-real vs checklist |
| 5 | 111 | T-014..T-029 | MathUtils/ValidationUtils/FormatUtils + GameConstants + GameEnums + structs | Validadores + tests de valores reales |

Iteracion 1 (Log 891): T-014..T-029 parcial — auditoria de utils/data/patterns contra codigo real + test headless
de MathUtils/ValidationUtils/FormatUtils/GameConstants/GameEnums/structs + cierre de items verificados.

---

## Historial de iteraciones (append-only)

| Iter. | Modulo | Log | Resultado | Evidencia | Pendiente |
|-------|--------|-----|-----------|-----------|-----------|
| 1 | 111 Codigo-De-Calidad | 909 | **209/209 `[x]`**, 0 `[?]`; 35/35 personales | `tests/test_m111_utils_headless.gd` **62 checks / 0 fallos** (Godot 4.7.2 real); 1 bug real corregido: `Factory.create()` `-> Object` debia ser `-> Variant` (los builders retornan `int`) | QA cruzado §21.8 por modelo distinto |
| 2 | 117 Build-System | 941 | **92/110** modulo (`59 [x]`/`51 [ ]` → `92 [x]`/`0 [ ]`/`18 [?]`); 33/53 personales cerrados + 20 `[?]` con dueno | `test_bump_version.py` **11/11** (era 7/11); `test_changelog.py` **6/6**; `changelog.py` 403 commits; gates CI verificados en YAML (quality/testing/release-build) | 20 `[?]` externos (M118/M96/M116/M113/build-real) + QA cruzado §21.8 |

**FIX de codigo de mi autoria (iter. 2):** `tools/ci/bump_version.py` — `PROJECT_ROOT` se derivaba
solo de la ubicacion del script (`HERE/../..`), ignorando el `cwd`. Un runner CI o un test con
`tempdir` hacian que el script leyera/escribiera **siempre** el `project.godot` del repo real.
Ahora es **cwd-first** con fallback al layout clasico. Test: `tools/ci/test_bump_version.py` 7/11 → 11/11.

**Reglas aprendidas (para mis proximas iteraciones):**
1. Contar items con script **por seccion**, nunca con regex inline (las lineas de prosa contaminan el conteo).
2. Verificar el numero de log contra `Logs/{N}-*.md` **y** `Logs/reservas/{N}-*` antes de escribir (colision 938 → 941).
3. Escribir en UTF-8 sin BOM verificado (`d[:3] != b'\xef\xbb\xbf'` y sin U+FEFF incrustado).
4. Un `[?]` con dueno es mejor que un `[x]` falso: lo no verificable headless NO se marca verde.
5. No confiar en el conteo declarado en `CHECKLIST-GLOBAL.md`; recalcular contra el `05-Checklist.md` real.
