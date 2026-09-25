# Log 1156: P-42 — M122 (el diseño se alinea al código) + `security-scan` deja de ser un falso gate

**Fecha:** 2026-09-25
**Hora:** 04:20
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Reserva:** **1156**, tomado del pool tras medir `--estado` (el coordinador indicó 1154; el pool real
arrancaba en **1156** — se midió justo antes de reservar, como manda el protocolo).

## Resumen

P-42 tenía dos trabajos, ambos cerrados. **Ninguno de los dos agregó features**: uno alineó
documentación a código que ya funcionaba, el otro convirtió un step de CI que **no podía fallar** en
un gate real. Los dos se decidieron **midiendo**, no por ideal.

1. **M122 — el diseño se alineó al código** (decisión del coordinador). `03-Diseno.md` describía 9
   archivos en 4 directorios con `class_name`; el código real son 10 helpers en `scripts/crash/` sin
   `class_name`. Se actualizó el **diseño** (no el código): 21 reemplazos exactos asertados + §16 con
   la tabla de correspondencia. **`class_name` quedó como deuda OPCIONAL medida**, no como pendiente.
2. **`security-scan` — gate real.** Los 4 `grep … || true` del job eran un falso gate por **tres**
   motivos apilados, y uno de ellos era un **patrón roto** (no sólo el `|| true`). Reemplazados por
   `scripts/auditar_secrets.py`, probado **en rojo por inyección** sobre el árbol real.

## P-42.1 — M122: alinear el DISEÑO al código

### Qué decía el diseño vs qué hay (medido)

| El diseño (`03-Diseno.md`) decía | El código real |
|---|---|
| `scripts/services/crash_reporter.gd` · `CrashReporter extends Node` | `scripts/crash/crash_reporter.gd` — **autoload**, sin `class_name` |
| `scripts/services/metadata_collector.gd` | `scripts/crash/crash_metadata.gd` |
| `scripts/services/context_sanitizer.gd` | `scripts/crash/crash_context_sanitizer.gd` |
| `scripts/services/crash_cache.gd` | `scripts/crash/crash_cache.gd` |
| `scripts/services/crash_sender.gd` | `scripts/crash/crash_sender.gd` |
| `scripts/integrations/crash_logging.gd` | `scripts/crash/crash_logging.gd` |
| `scripts/integrations/crash_bug_tracking.gd` | `scripts/crash/crash_bug_tracking.gd` |
| `scripts/integrations/crash_debug_menu.gd` | `scripts/crash/crash_debug_menu.gd` |
| §15 `CrashAlerts` (sin ruta) | `scripts/crash/crash_alerts.gd` |
| §1 `CrashAnalytics` / `CrashPrioritizer` | `scripts/crash/crash_analytics.gd` / `crash_prioritizer.gd` |
| §1 `CrashHandler` | **no existe**: el manejo vive en el `_ready()` del autoload |
| §7 `scripts/ui/crash_dashboard.gd` · `CrashDashboard extends Control` | **NO IMPLEMENTADO** — sólo la capa de datos; la UI es de **M110/M53** |
| §1 `CrashViewer` | **NO IMPLEMENTADO** — ídem |

### Qué se cambió (21 reemplazos, conteo asertado)
- **Rutas** de las 9 secciones -> `game/isla-ancestral/scripts/crash/*.gd`.
- **`class_name` eliminado** de los 10 bloques de código del diseño (el autoload no puede tenerlo por
  §9.17/§9.41; los 9 helpers no lo necesitan).
- **Defecto del diseño corregido:** `OS.get_dynamic_memory_usage()` -> `OS.get_memory_info()["available"]`
  (el método **no existe** en Godot 4.7).
- **Cabecera de aviso** + **§16 nueva** (tabla de correspondencia + deuda opcional + defectos corregidos).
- `scripts/validar_workflows.py`… no aplica acá. Lo que sí aplicó: **guard de formato propio**. La
  primera pasada introdujo `<ruta>.gd`** (bold desbalanceado) en 9 líneas; se detectó con un guard y
  se **revirtió el archivo** (`git checkout`) y se corrigió la plantilla antes de re-aplicar. El
  archivo quedó con `**` **par** (140) y **0** `^class_name`.

### P-42.2 — ¿algún módulo necesita `class_name`? (la única excepción que autorizaba refactor)
Medido con `grep` sobre **todo** el repo:
- **0** declaraciones `class_name` en `scripts/crash/` (las apariciones de la palabra son los
  comentarios «RefCounted sin class_name (preload)» de cada helper).
- **0** usos como **tipo** (`var x: <Clase>`, `-> <Clase>`) en todo `game/`.
- Las menciones de esos 11 nombres viven **sólo** dentro de `scripts/crash/`; las 2 suites cargan por
  `preload("res://scripts/crash/…")`.

-> **No se refactorizó nada.** Quedó escrito en `03-Diseno.md §16.2` que, si algún día un módulo
necesita una clase **por tipo**, ese ítem pasa a `[?]` **nombrando al módulo dependiente**.

## P-42.3 — `security-scan`: de falso gate a gate duro

### Por qué NO era un gate (tres defectos apilados, no uno)

```bash
! grep -r -i "password\s*=" scripts/ --include="*.gd" | grep -v "test" | grep -v "mock" || true
```

1. **`|| true` al final** -> el step **nunca** podía fallar (trampa 81).
2. **El patrón estaba roto.** `grep` sin `-E` usa **BRE**, donde `\s` es la **letra `s`**: el patrón
   real era `passwords*=` y **no matcheaba** la forma normal `password = "..."`.
3. **El `!` negaba al comando equivocado.** El `!` se aplica al **último** comando del pipe
   (`grep -v mock`), no al `grep` que buscaba. Con el `|| true` encima, un secret real se perdía **dos veces**.

### El gate: `scripts/auditar_secrets.py` (nuevo)
- **Python**, no GDScript, porque el job `security-scan` **no instala Godot** (sólo hace checkout).
- **Patrones espejo** de `security_secret_scanner.gd` (M106 T-006): clave asignada, cloud key,
  `AKIA[0-9A-Z]{16}`, PEM privada, bearer token -> el gate de CI y el escáner in-game coinciden.
- **Filtra** placeholders (`your_`, `changeme`, `example`, `<`, `os.get_environment`, …) y las líneas
  de comentario; **redacta** el valor (`***REDACTED***`): **nunca** imprime el secret.
- **Nombra archivo + línea + regla**, porque un `exit 1` a secas no identifica la causa (trampa 101).
- Exit: `0` limpio · `1` hallazgos · `2` raíz inválida.

## P-42.4 — La decisión (por evidencia): DURO, no *warn*

| Alcance | Archivos | Hallazgos | Exit |
|---|---|---|---|
| `game/isla-ancestral/scripts` (scope del job) | 634 (264 excluidos) | **0** | 0 |
| `game/isla-ancestral` (proyecto) | 2717 (307 excluidos) | **0** | 0 |
| repo entero (`.`) | 3554 (341 excluidos) | **0** | 0 |

**El árbol está limpio**: el gate **nace verde**, así que convertirlo a duro **no deja el CI rojo**.
No hubo deuda previa que justificara el modo *warn*.

### Exclusiones declaradas
- `test_*` / `mock*` / `tests/`: sus fixtures son secrets **de mentira**. **Medido:** sin la exclusión
  aparecen **8 hallazgos**, todos en `test_security_m106_secrets.gd` (7) y `test_logging_m103_iter1.gd` (1).
- **2 archivos exentos** (el detector y sus fixtures): `security_secret_scanner.gd` (contiene los
  PATRONES) y `scripts/auditar_secrets.py` (contiene los `FIXTURE_*` del selftest). Se detectó
  **midiendo**: con `--raiz .` el script se auto-flagueaba (2 hallazgos en sus propios fixtures) ->
  exención por archivo, documentada, y el `--selftest` prueba en cada corrida que la detección sigue viva.

## Verificación

| Prueba | Resultado |
|---|---|
| `auditar_secrets.py --selftest` | **6/6 OK** (limpio->0; sucio->2 nombrando la línea; sin fuga del valor; árbol con secret->exit 1; sin él->exit 0; secret en `test_*`->exit 0) |
| Inyección **en el árbol real** (`scripts/_p42_probe_secret.gd`, un `AKIA…`) | **exit 1** · `…/_p42_probe_secret.gd:2: [aws-access-key-id] var api_key:***REDACTED***` |
| Borrado el probe -> gate de nuevo | **exit 0** (sonda eliminada, sin artefacto) |
| `auditar_secrets.py` (default / proyecto / repo) | **exit 0** en los tres |
| `scripts/validar_workflows.py` | **6 workflows válidos, 0 problemas**, mismos **7 avisos** de deuda previa BUG-078 (0 nuevos) |
| `validar_workflows.py --selftest` | **6/6** fixtures |
| `sincronizar_checklist_personal.py` (M122) | **0 desalineados**, `[x]=254 [?]=11 [ ]=0` |

## Hallazgos reportados (no arreglados, con dueño)

### 1. El validador del repo cazó un bug **mío**
Al cablear el gate escribí `name: Gate: no hardcoded secrets (M106)`. Ese `: ` sin comillas hace el
**YAML inválido** (patrón **BUG-077**), y GitHub **apaga el workflow entero** — no un job, el CI
completo. `scripts/validar_workflows.py` lo detectó **antes** del commit; corregido a
`name: "Gate: no hardcoded secrets (M106)"`. **Lección: después de tocar un workflow, correr el
validador del repo, siempre.**

### 2. `CHECKLIST-GLOBAL.md` tiene 220 líneas con doble CR (`\r\r\n`) — reportado, NO tocado
- Worktree: **231 CRLF + 220 CR sueltos** (o sea `\r\r\n` en 220 de las 231 líneas).
- Blob de `HEAD`: **limpio** (231 CRLF, **0** sueltos) -> es **worktree-only** y sin commitear.
- **Preexistente, no mío:** el script de P-36 hacía round-trip fiel (`split("\r\n")` / `join("\r\n")`)
  y la edición de P-42 **asertó** que el conteo de CR no cambiara (451 -> 451); además **hy3 ya lo
  había advertido** en su entrada P-33 («GLOBAL tiene líneas con terminador `\r` solo mezcladas con CRLF»).
- **No lo arreglé**: es el archivo del coordinador y hay ediciones concurrentes de otros agentes.
  Fix si se decide: `b.replace(b"\r\r\n", b"\r\n")`, midiendo NUL y CR antes/después.

### 3. El step vecino de debug-prints sigue siendo un no-gate (a propósito)
**Medido:** hay **712** `print(` en `scripts/` fuera de tests/mocks. Convertirlo a gate duro dejaría el
CI **rojo permanente sin plan de remediación** -> se deja informativo y se reporta (el coordinador
pidió decidir por evidencia, no por ideal).

## Honestidad

- **No se flipeó ningún ítem de checklist.** El plan de M106 no tiene un ítem «gate de secrets en CI»
  (el ítem 13, «No incluir secrets en builds», ya estaba `[x]`), y la alineación de M122 es
  **documental**: `05-Checklist.md` sigue en **254 `[x]` · 11 `[?]` · 0 `[ ]` (265)**.
- Los `[x]` de «Diseñar CrashDashboard.gd» / «Diseñar CrashViewer» (líneas 167/168/259) **siguen
  válidos**: son ítems de **diseño** y el diseño existe. Lo que ahora el diseño declara explícitamente
  es que su **implementación** no es de M122 sino de **M110/M53**.
- **`class_name` no se declaró en ningún helper.** No hacía falta (0 usos por tipo, medido). Queda como
  deuda **opcional** documentada, con el disparador explícito que la convertiría en `[?]`.
- **El gate no cubre todo.** Escanea código/config (`scripts/` por defecto), no la documentación ni los
  binarios; y excluye tests por diseño (documentado y medido).
- **QA §21.8 de M106/M122 sigue pendiente** (verificador != autor). Es **P-43**, no mío.

## Archivos

| Archivo | Cambio |
|---|---|
| `scripts/auditar_secrets.py` | **nuevo** (gate + selftest) |
| `.github/workflows/quality.yml` | step `Gate: no hardcoded secrets (M106)` + `Setup Python`; se fueron los 4 `grep \|\| true` |
| `DOCUMENTACION/122-Crash-Reporting/plan-actual/03-Diseno.md` | alineado al código (21 reemplazos + §16) |
| `DOCUMENTACION/122-Crash-Reporting/plan-actual/04-Codigo.md` | **§16** (alineación) |
| `DOCUMENTACION/106-Seguridad/plan-actual/04-Codigo.md` | **§27** (gate) |
| `CHECKLIST-GLOBAL.md` | notas P-42 en las filas 106/122 — **sin commitear** (merge del coordinador) |
| `Mensajes entre modelos/ESTADO-PARALELO.md` | bloque P-42 — **sin commitear** |
| `Logs/NUMEROS_DISPONIBLES.txt` | consumido 1156 — **sin commitear** |

**Push NEGATIVO.**
