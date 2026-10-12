# Log 1722 - M01 Fundamentos del Proyecto - Indice maestro medido + nucleo endurecido

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy (opencode)
**Fecha:** 2026-10-12 00:59 GMT-3
**Modulo:** M01 - Fundamentos del Proyecto
**Encargo:** mimo-v2.6 (director), canal 177 (2026-10-12 00:29:10) - "M01-Fundamentos (152 pendientes) queda en vos. M01 es 100% documental + GDScript puro - tu nicho exacto." (reasignado desde kimi-k3, inactivo una semana; confirmado por atria-dawn-s3 msg 204).
**Reporte de vuelta:** Mensajes entre modelos/DeepSeek-V4.1-Flash/178-...-deepseek-a-mimo-m01-indice-medido-nucleo-endurecido.md

---

## 1. Hallazgo que cambia el encargo: los 152 "pendientes" NO son tareas

El `plan-actual/05-Checklist.md` de M01 se titula "CHECKLIST DEL PLAN INICIAL GENERICO (152 MODULOS)":
sus 152 items son **modulos completos**, no tareas. Por eso NO se pueden "completar 15-20 por lote"
como pedia el encargo: cada `[x]` exigiria cerrar un modulo entero.

**Regla dura del dueno que gobierna el marcado** (commit `41ff104`, 2026-08-24, del propio
Mauricio Belforte, que **revirtio 68 `[x]` de ESTE MISMO archivo**):

> "Explicacion: [x] significa CODIGO IMPLEMENTADO + TESTING, no solo documentacion"

Consecuencia: flipar `[x]` "porque el modulo ya tiene documentacion" seria **re-inflar un revert
intencional** del dueno (la familia de la trampa 119: un `[x]` inflado). El commit `5e68fbc`
(2026-08-19) habia marcado 68 con ese criterio (documentacion) y `41ff104` los tumbo.

**Decision tomada:** NO aplicar flips (ademas, regla del encargo: "NO apliques flips de marca por tu
cuenta"). Se **mide** el estado real y se **propone** al director. En su lugar se hizo el trabajo
legitimo del modulo: rellenar los 2 documentos vacios (huecos reales) y endurecer el nucleo GDScript.

---

## 2. Mapeo item <-> carpeta (NO documentado hasta ahora)

El `05-Checklist.md` numera los modulos `M01..M152`, pero las carpetas van `01..168`. El mapeo
medido es:

> item `**M##**` <-> carpeta `DOCUMENTACION/{##+1:03d}-{Nombre}`

Ejemplos verificados: `M007 Mundo Voxel` -> `08-Mundo-Voxel`; `M087 Fuentes Tipograficas` ->
`88-Fuentes-Tipograficas`; `M152 Objetivo Final` -> `153-Objetivo-Final`.

---

## 3. Medicion del indice (152 items)

Script de medicion en `.workbuddy-ai/tmp/` (no versionado). Fuente de cada conteo: el
`05-Checklist.md` de CADA componente (no una tabla derivada) + la fila de `CHECKLIST-GLOBAL.md`.

| Metrica | Valor medido |
|---|---|
| Items parseados del 05-Checklist de M01 | **152** |
| Resuelven a una carpeta de componente | **152** |
| Nombre item <-> carpeta coincide | **149** (3 difieren) |
| Checklists propias 100% cerradas ([?]=0 y [ ]=0) | **22** |
| De esos, con fila GLOBAL en `OK-Completado` | **21** |
| En curso ([x]>0 y [ ]>0) | **88** |
| Sin iniciar ([x]=0 y [?]=0) | **1** (`M045 Arte 2D` -> `46-Arte-2D`) |
| Suma de los 152 sub-checklists | **14334 [x] / 1241 [?] / 6421 [ ] = 21996** |

**Los 21 candidatos a `[x]`** (checklist cerrada Y GLOBAL completado), para que los aplique el
director: M006 M007 M031 M037 M038 M077 M078 M083 M085 M096 M097 M100 M101 M110 M112 M124 M132
M133 M134 M135 M151.

**NO propuesto:** `M024 Ruinas` (cerrado 122/122 pero GLOBAL `Con dudas (deuda implementacion)`).

**3 desajustes de nombre item<->carpeta:** `M131`->`132-Produccion-De-Equipo`;
`M151`->`152-Principios-Innegociables`; `M152`->`153-Objetivo-Final`.

---

## 4. Documentos vacios rellenados (huecos reales, 0 bytes)

`plan-actual/06-Plan-Testings.md` y `plan-actual/07-Resultados-Testings.md` existian **vacios
(0 bytes) desde 2026-08-26** (un archivo de 0 bytes no es un plan: es un hueco; trampa 100).
Se escribieron con las cifras MEDIDAS:

- `06`: objetivo/alcance, herramienta, suites, guardian de 3 capas, metodo de medicion del indice,
  criterios de aceptacion, que NO cubre.
- `07`: entorno, resultado global x3, desglose por bloque, sondas en rojo, medicion del indice +
  propuesta de flips, integridad de bytes, pendientes.

**No tocado:** `plan-inicial/06` y `07` siguen 0 bytes (son el plan historico; se deja constancia).

---

## 5. Nucleo GDScript endurecido

`scripts/proyecto/test_fundamentals_m01.gd` (75 -> 107 lineas) - **3 capas anti-falso-verde**:

1. `BLOQUES = ["datos","validator","errores"]` + `_fin("X")`: nombra el bloque que no cerro.
2. `CHECKS_MINIMOS := 8` (piso **MEDIDO** en verde, no estimado).
3. `_summary()` en su **propio `call_deferred`** (registrado en `_init` junto a `_run`): si `_run()`
   aborta, la cola diferida sigue y el resumen corre con codigo 1 (trampa 61). `_run()` ya NO llama a
   `quit()`.

**Evidencia verde (3 corridas):** `8 checks, 0 fallos`, `EXIT 0`, determinista. La suite original NO
tenia guardian (contaba `_checks` pero sin piso ni marcadores).

**Evidencia ROJA (2 sondas de inyeccion, borradas tras medir):**

| Sonda | Inyeccion | Medido |
|---|---|---|
| A | aborto de **runtime** al inicio del bloque `errores` (`var _n: Node = null; _n.free()`) | `[FAIL] el bloque 'errores' NO se ejecuto` + `[FAIL] solo 4 checks (minimo 8)` -> `4 checks, 2 fallos` **EXIT 1** |
| B | piso subido 1 (`CHECKS_MINIMOS := 9`) | `[FAIL] solo 8 checks (minimo 9)` -> `8 checks, 1 fallos` **EXIT 1** |

La sonda usa error de **runtime** (no de parseo): un Parse Error mataria el script y el "rojo" seria
falso (trampa AU).

**sha256 del test:** `bf8ba7464d43c642091462663b323ce6fe779be38d1aaca48a961a8b24148c2a` (LF, sin BOM,
3725 B).

---

## 6. Higiene de bytes

| Archivo | BOM | EOL | NUL | FFFD |
|---|---|---|---|---|
| `test_fundamentals_m01.gd` | No | LF (107) | 0 | 0 |
| `plan-actual/06-Plan-Testings.md` | No | CRLF (102) | 0 | 0 |
| `plan-actual/07-Resultados-Testings.md` | No | CRLF (103) | 0 | 0 |

Log 1722: ASCII puro (verificado por bytes).

---

## 7. Limites de esta corrida

- **0 commits / 0 push** (desde 2026-10-11 los commits son de `atria-dawn`; no se pidio).
- **0 flips aplicados** (los propone el director; regla del encargo + regla `41ff104`).
- **NO** se toco `CHECKLIST-GLOBAL.md`, `quality.yml` ni `AGENTS.md`.
- **NO** se toco ningun archivo de los 152 modulos del indice (zona ajena).
- La suite **no esta cableada en `quality.yml`** (0 citas a `test_fundamentals_m01` en los 6
  workflows): se reporta, no se toca el CI.

---

## 8. Reportes ajenos (medidos, no tocados)

- **Colisiones de pool de logs (7, todas ajenas):** 1290, 1468, 1547, 1559, 1585, 1645, 1698.
  `reservar_log.py --estado` las reporta; no se renombra un log ajeno.
- **`SCRIPT ERROR` ajeno que ensucia el conteo de cualquier suite:** `Parse Error: Could not parse
  global class "BlockType" from "res://scripts/world/block_type.gd"` +
  `Invalid access to property or key 'detection_interval' on a base object of type 'RayCast3D'`
  (terrain_detector). Familia de la trampa AF (medir el commit, no el worktree).
- **`verificar_checklist.py`**: exit 1 con 20 alertas pre-existentes; **ninguna** introducida por
  este cambio (M01 sigue 0/152 y coincide con su fila GLOBAL).

---

## 9. Numeracion

- Pool de logs: head medido justo antes = **1722** -> consumido 1722 (head -> 1723).
- Canal DeepSeek: ultimo = 177 -> reporte propio = **178**.
- Tracker `.ultima-revision-deepseek.txt`: 173 -> **177**.
