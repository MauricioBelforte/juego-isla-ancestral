# Log 1879 - M118-CI-CD - Fix del YAML invalido de quality.yml (CI rojo: 47 runs rechazados)

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-15 23:55:00 (GMT-3)
**Encargo:** mensaje 264 del director (De-Director V4.1 - DeepSeek V4.1 Flash / OpenCode)
**Modulo:** M118-CI-CD
**Responde a:** 264-2026-10-15_23-00-02-de-director-v4.1-a-deepseek-v4.1-flash-m64-12-flips-aprobados-commit-ok-siguiente-m118.md

## 0. Alcance

El director pidio 4 cosas en el msg 264:

1. M124: aceptado, nada que hacer. [sin accion]
2. M64: 12 flips aprobados -> **los aplica EL** (no toco el checklist). Verificar
   drift de conteo despues de su edicion y reportarlo.
3. Commit autorizado: Log 1870 + msg 262 + tracker (sin push). **[HECHO: 7274c3d]**
4. SIGUIENTE TAREA: M118-CI-CD, CI rojo. Diagnosticar el ScannerError L286-287 de
   `quality.yml`, corregirlo sin cambiar el diseno de gates, correr headless las
   suites afectadas con antes/despues, y cerrar el 1 pendiente de M118 si cae
   dentro del fix.

Limites fijados por el director: NO flip de M118 (lo decide el fundador); NO tocar
`CHECKLIST-GLOBAL.md`; un modulo a la vez; reporte en este canal (Patron D, REGLA CERO).

## 1. Diagnostico del CI rojo (medido, no inferido)

### 1.1 El error literal

Parser YAML (PyYAML, el mismo que usa el validador del repo):

    ScannerError
    while scanning a simple key
      in ".github/workflows/quality.yml", line 286, column 1
    could not find expected ':'
      in ".github/workflows/quality.yml", line 287, column 1

Validador propio del repo (`python scripts/validar_workflows.py`), ANTES del fix:

    [FALLO] quality.yml
       YAML INVALIDO en linea 287, col 1: could not find expected ':'
    [FALLO] 1 PROBLEMA(S) en los workflows.
    EXIT_BEFORE = 1

Coincide exactamente con lo reportado por el fundador (ScannerError L286-287).

### 1.2 Causa raiz (NO es un `:` sin comillas: es una DESINDENTACION)

El job `test-suite` tiene un unico bloque `run: |` que arranca en **L178**
(`cd game/isla-ancestral` / `FAIL=0` / lista de suites). Su contenido va indentado
**10 espacios**.

Las lineas **281-304** (24 lineas) quedaron **desindentadas a columna 0**:

    280|ind=10|          godot --headless --script scripts/legal/test_copyright_m127.gd ...
    281|ind= 0|# M90 iter. 2: graphics_config + su suite headless (85 checks ...
    ...
    304|ind= 0|godot --headless --script scripts/ui/test_layer_type_m53.gd 2>&1 || FAIL=1
    305|ind=10|          # Run M111 quality-utils test: ...

Consecuencia: un escalar de bloque YAML **termina en cuanto aparece una linea menos
indentada que su indentacion**. La L281 (col 0) cierra el bloque; 281-304 dejan de
ser contenido del `run:` y pasan a ser YAML de nivel raiz. Las lineas de comentario
(281-285) se ignoran; la primera linea de contenido real (286, `godot --headless ...`)
es un escalar plano en la raiz -> el scanner busca el `:` de una clave y no lo
encuentra -> error.

Por eso el error apunta a 286-287 pero **el defecto real son las 24 lineas 281-304**:
el scanner solo reporta el PRIMER error, y los comandos perdidos (286, 292, 299, 300,
304) ya no formaban parte de ningun `run:`.

### 1.3 Dato de higiene: EOL

Las 24 lineas 281-304 son las **unicas 24 lineas con LF suelto** del archivo
(1036 CRLF + 24 LF = 1060). Es la firma de una insercion automatizada que escribio
sin indentacion y sin CRLF. El resto del archivo es CRLF.

## 2. Fix aplicado

Archivo: `.github/workflows/quality.yml`
Cambio: **prefijo de 10 espacios a las 24 lineas 281-304**. Nada mas.

- `git diff`: **1 solo hunk** `@@ -281,24 +281,24 @@`, 24 inserciones / 24 deleciones.
  Cero cambios en suites, umbrales, gates, jobs o `needs:`.
- Bytes: 64533 -> 64773 (+240 = 24 lineas x 10 espacios).
- CRLF: 1036 -> 1036 (sin cambio). BOM: no. LF sueltos: 24 -> 24 (las mismas lineas
  siguen en LF; NO se normalizo el EOL del archivo).
- sha256 del archivo corregido: `0463ceb2731384e94317dd6e362c39235a25823769f96b6bb1b3e50ca5153c31`

Para medir el EXIT_BEFORE se restauro el blob de HEAD sobre el worktree y despues se
volvio a copiar el archivo corregido; el sha256 volvio a dar el mismo valor (el
restore no dejo residuo).

## 3. Antes / despues (comando + salida + exit code)

| # | Comando | ANTES | DESPUES |
|---|---------|-------|---------|
| 1 | `python scripts/validar_workflows.py` | `quality.yml YAML INVALIDO en linea 287, col 1` -> **EXIT 1** | `6 workflow(s) validos: YAML parseable, jobs con runs-on, needs coherentes y toda cita --script versionada.` -> **EXIT 0** |
| 2 | `yaml.safe_load(quality.yml)` (PyYAML) | `ScannerError` L286/287 | **PARSE OK** - 12 jobs: godot-lint, formatting-check, test-suite, legal-tools, security-scan, encoding-guard, binary-guard, log-protocol, architecture-guard, checklist-orchestrator, release-gate, summary |

El validador 1 tambien comprueba (y ahora pasa) que cada `--script <ruta>.gd` citado
en el workflow este **versionado en HEAD** (`git cat-file -e`): las 3 suites Godot del
bloque recuperado existen en el repo, no solo en el disco.

## 4. Suites afectadas: corridas headless

"Antes" = el gate no corria NUNCA: con el YAML invalido GitHub **rechaza el archivo
completo** (no falla un job: no arranca ninguno). Las 5 lineas perdidas (286, 292, 299,
300, 304) son los 5 comandos recuperados. "Despues" = corridos ahora con el binario
real Godot 4.7.2 (`--headless`, exit del PROCESO).

Binario: `D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe`
MODO B (BUG-091): `--import` previo -> EXIT 0.

| Comando (desde `game/isla-ancestral`) | EXIT | SCRIPT ERROR | Resultado |
|---|---|---|---|
| `godot --headless --script scripts/settings/test_graphics_config.gd` | 0 | 0 | `RESUMEN M90 GRAPHICS: 85 checks, 0 fallos, 6 bloques` / `PASS` |
| `godot --headless --script scripts/core/test_m40_contratos.gd` | 0 | 0 | `OK - 19 checks, 4 bloques, 0 fallos` |
| `godot --headless --script scripts/ui/test_layer_type_m53.gd` | 0 | 0 | `OK - 10 checks, 4 bloques, 0 fallos` |

| Comando (desde la raiz) | EXIT | Resultado |
|---|---|---|
| `python tools/ci/cross_module_linter.py` | 0 | `1065 archivos .gd`, `408 class_name, 146 autoloads`, `OK. Sin ciclos ni referencias rotas.` |
| `python tools/ci/test_cross_module_linter.py` | 0 | `OK - 9 checks, 0 fallos` |

Total recuperado: **114 checks de suite + 1065 archivos analizados por el linter**,
0 fallos, 0 SCRIPT ERROR, exit 0 en los 5 comandos.

Observacion (no bloqueante, NO la arreglo sin orden): en las 3 corridas Godot aparece
al final `ERROR: Failed to retrieve non-existent singleton 'AnimationService'.` El exit
del proceso sigue siendo 0 y el gate (`|| FAIL=1`) no lo ve; es ruido preexistente del
bootstrap/cierre, no del fix.

## 5. Origen y magnitud (medido con `gh`)

`gh run list --workflow=quality.yml --limit 100`:

- 100 runs listados: **94 failure / 6 success**.
- Ultimo run **verde**: **2026-10-07T07:17:22Z** (`d9534a0a`, 4m41s).
- Primer run con **duracion 0s** (firma de "GitHub rechaza el workflow completo"):
  **2026-10-12T23:34:20Z** (`40543103`, run 38322833161).
- **47 runs consecutivos con 0s** desde entonces, hasta el ultimo
  **2026-10-14T07:13:22Z** (`d2efb964` = `origin/main`, run 38526929167).
- El run inmediatamente anterior a la transicion (2026-10-12T22:29:08Z, `47af7658`)
  duro 405s: era un fallo de job, no un rechazo de archivo.

Commit que introdujo el defecto, hallado con
`git log -S "M90 iter. 2: graphics_config" -- .github/workflows/quality.yml`:

    **9e8e37d** - 2026-10-12 20:31:07 -0300 - "Se bajo el piso de checks de la suite
    de graphics_config y se agrego su gate a CI"

El push que lo publico es **40543103** (2026-10-12 20:33:29 -0300, mismo lote, 2m22s
despues); el primer run rechazado es ese mismo push. Es decir: **el CI de quality.yml
lleva muerto (no "rojo por fallos": RECHAZADO) 47 pushes / ~32 horas**, desde el lote
del 2026-10-12 20:31.

## 6. M118: el unico pendiente

`05-Checklist.md` de M118: **105 [x] / 1 [?] / 0 [ ] = 106**. El unico pendiente es
**L199** `[?]` "Validacion en GitHub Actions real" (primero CASO A "infra externa no
disponible"; luego reclasificado por Ling como "deuda externa, no flippable como exito"
con la medicion ROJA 3/3).

El fix SI cae dentro de ese pendiente: la causa del rojo no era deuda externa sino
**un defecto del propio workflow** (9e8e37d), y queda corregido y verificado localmente.
Lo que NO puedo cerrar yo: la validacion real requiere un **push** y un run verde en
GitHub. Por eso **no aplico ningun flip** (ademas de la orden explicita "NO flip de M118:
lo decide el fundador"). Queda como candidato a cierre **tras el proximo push con el fix**.

## 7. Commit de esta corrida

**NO commiteado**: `quality.yml` + Log 1879 + informe 265 + `BACKLOG-MASTER.md` + tracker.
El msg 264 solo autorizo el commit del trabajo de M64. Pido autorizacion explicita para
los paths de M118. Nota de riesgo: el fix vive hoy SOLO en el worktree; si otro agente
hace `git checkout -- .github/workflows/quality.yml` el CI sigue muerto. Si el director
prefiere, puede commitearlo el mismo (es su archivo de control).

## 8. Higiene y limites

- 0 ediciones a `CHECKLIST-GLOBAL.md`, `AGENTS.md`, `project.godot`, ni a ningun
  `05-Checklist.md` de modulo.
- 0 auto-sellos sec21.8 (no se pidio sello; verificador != autor igualmente).
- **`quality.yml`: SI editado, pero por ORDEN EXPLICITA del director (msg 264 sec. 4.2) y
  solo para reparar un YAML invalido.** No se toco ningun gate, suite, umbral, job ni
  `needs:`; no se normalizo el EOL.
- Pool de logs: reservado **1879** (cabeza medida justo antes = 1879; despues = 1880).
  **Pool NO commiteado.**
- Canal: informe **265** (ultimo + 1; el pool del canal esta stale en 252).
- 8 colisiones de pool AJENAS conocidas (1290, 1468, 1547, 1559, 1585, 1645, 1698, 1726)
  reportadas sin tocar.
- Sondas temporales: ninguna creada dentro del repo; la evidencia vive en `/tmp`.
- Log ASCII puro verificado por bytes; sin BOM; LF.

## 9. Pendiente del director

1. Aplicar los 12 flips de M64 (los aplica el) y avisarme si hay drift de conteo.
2. Autorizar (o no) el commit de: `quality.yml` + `Logs/1879-*` + informe 265 +
   `BACKLOG-MASTER.md` + tracker -> 264. (Sin push sin orden.)
3. Decidir sobre M118 L199: el defecto esta corregido; el cierre necesita push + run verde.
4. Decidir si el ruido `AnimationService` del bootstrap entra como BUG.
