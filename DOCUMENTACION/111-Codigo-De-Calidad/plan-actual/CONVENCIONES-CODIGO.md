# CONVENCIONES-CODIGO.md — Convenciones de código del proyecto Isla Ancestral

**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-21
**Responde a:** GLM-5.3 Flash-Director — msg 142 (encargo: crear el doc citado por la fila 111 del CHECKLIST-GLOBAL, hoy ausente del árbol)
**Módulo:** 111-Codigo-De-Calidad

---

## 1. Alcance y fuentes

Este documento **consolida convenciones ya vigentes**; no inventa contenido nuevo. Cada
sección cita su fuente. Si una convención de aquí contradice al código o a otro documento
del repo, manda el repo: reportar la contradicción, no "arreglarla" en silencio.

| Sección | Fuente |
|---|---|
| 2. Codificación de archivos | `AGENTS.md` §28 (+ §28.1, Log 852) |
| 3. Convenciones GDScript | `DOCUMENTACION/GUIA-GODOT/01-gdscript-errores-comunes.md` (catálogo completo, 34+ secciones) |
| 4. Diagnóstico de tildes | `DOCUMENTACION/GUIA-GODOT/19-diagnostico-tildes.md` (causas C-01 a C-11) |
| 5. Convenciones del protocolo multiagente | `AGENTS.md` §21, §18, §10; directivas del director |
| 6. Scripts temporales y capturas | `AGENTS.md` §24 (convención de scripts temporales) y GUIA-GODOT/19 C-01 |

> **Nota de stack (verificada 2026-10-21):** `AGENTS.md` §24 describe un stack Unity/C#
> que **no es el vigente**. El motor real del proyecto es **Godot 4.7.2 con GDScript**
> (`game/isla-ancestral/project.godot`). Las convenciones de código de este documento son
> las de GDScript/Godot; la parte Unity/C# de AGENTS §24 queda como histórico.

---

## 2. Codificación de archivos (AGENTS §28)

1. **UTF-8 sin BOM** en todo archivo de texto versionado (`.md`, `.gd`, `.py`, `.json`,
   `.tscn`, `.tres`, `.cfg`, `.txt`).
2. **Nunca escribir en cp1252/ANSI.** Si la plataforma del agente guarda por defecto en
   cp1252, no tocar el repo hasta reconfigurarla. Un agente que genera mojibake daña el
   proyecto tanto como uno que borra código.
3. **Al editar un archivo existente, preservar su codificación Y sus EOL.** Medir los EOL
   por bytes antes de escribir (hay archivos CRLF y LF en el mismo repo); no normalizar.
4. **EOL por tipo de archivo (convención medida del repo):**
   - `Logs/` → **ASCII puro (verificado por bytes) + CRLF + sin BOM**.
   - Mensajes y reportes de canal (`Mensajes entre modelos/`) → **UTF-8 sin BOM + LF**.
   - Resto: el que ya tenga el archivo (medir, no asumir).
5. **Herramientas del proyecto** (usarlas, no reescribirlas):
   - `python scripts/fix_encoding.py --dry-run` informa sin escribir; sin `--dry-run`
     repara con respaldo automático en `Obsoletos/encoding-backup-<timestamp>/`.
   - `python scripts/diagnosticar_mojibake.py` verifica en estricto (EXIT 1 si queda).
   - `scripts/verificar_bom.py` verifica BOM.
   - Están separadas a propósito: si una sola herramienta detecta *y* repara, un falso
     positivo de detección se convierte en escritura destructiva silenciosa.
6. **Cuatro lecciones que ya costaron caro (§28.1) — no repetir:**
   - Nunca usar `errors="replace"` al decodificar: fue lo que creó los U+FFFD que el
     Log 507 declara irrecuperables. Si un tramo no decodifica, es texto legítimo
     (portugués `você`, español `diseño`): dejarlo intacto, no adivinar.
   - Los caracteres de control C1 (`U+0080`–`U+009F`) son PARTE de un token mojibake,
     no ruido.
   - El mojibake puede estar aplicado 2, 3 o más veces: una o dos pasadas no alcanzan.
   - Un U+FFFD puede venir disfrazado como `ï¿½`: contar las secuencias camufladas antes
     de asumir que una reparación "crea" reemplazos.
7. **Exclusiones deliberadas** (NO "arreglar"): `AGENTS.md` (documenta el síntoma con
   ejemplos), `scripts/verify_final.py`, `scripts/fix_coordinacion.py`,
   `scripts/fix_emoji3.py` (tienen literales mojibake en sus tablas de reemplazo) y
   `Logs/` (registro histórico).
8. **Detección temprana:** `Á`, `â€` o `Â` en un diff = archivo guardado en cp1252.
   Corregir inmediatamente.

---

## 3. Convenciones GDScript (Godot 4.7.2)

Catálogo completo con ejemplos: `GUIA-GODOT/01-gdscript-errores-comunes.md`. Resumen de
las reglas de oro (la sección entre paréntesis es la de la guía):

### 3.1 Inferencia de tipos y booleanos
- `:=` con `clamp()` u otras expresiones mixtas, con `null`/Variant, o con métodos que
  retornan Variant: no infiere el tipo esperado (§6.1-§6.3, §28). Ante la duda, anotar
  el tipo explícito.
- `bool(Variant)` con Nil **crashea** en Godot 4.7.2 (§6.4/§30). Colateral peligroso:
  la suite headless que aborta por eso **nunca termina** (§30.1) — el resumen va en un
  `call_deferred` separado del de la corrida.
- `bool(null)` → "Invalid call. Nonexistent 'bool' constructor" (§30).

### 3.2 Nombres reservados y class_name
- `type` es palabra reservada (§7).
- `class_name` colisiona con clases nativas de Godot 4.7 (§16, ej. `Logger`), con el
  nombre de un autoload (§11) y con el `const X := preload(mismo script)` en tests (§25).
- Las inner classes de un autoload no son visibles fuera (§22): extraer a su propio
  archivo con `class_name` global.
- Anotar tipos con el `class_name` de OTRO script falla en headless (§23).
- Un autoload referenciado como global dentro de un `--script` no resuelve (§24); un
  autoload puede no estar resuelto en el `_ready()` de un nodo de escena (§26, P-52).

### 3.3 Instanciación y datos
- `set_script()` sobre `RefCounted.new()` **NO inicializa las variables del script**
  (quedan sin declarar → "Invalid access to property"). Forma correcta:
  `var ScriptCtrl: GDScript = load(...); var c: RefCounted = ScriptCtrl.new()`
  (lección de M67, Notas del Agente iter. 1; documentada en
  `67-Vehiculos/plan-actual/04-Codigo.md`).
- `JSON.parse_string()` convierte **todos** los números a `float` (§29): castear con
  `int()`/`float()` al consumir.
- `Vector3.xz` es property read-only y NO pasa por dispatch de Variant (§27, P-52).
- Las lambdas capturan por **VALOR** (§18): no reflejan mutaciones posteriores.

### 3.4 Formato de strings y prints
- `print()` con dos argumentos y un solo format → "not enough arguments for format
  string" (§19). Con un solo argumento, agrupar en array: `"%d y %d" % [a, b]`.
- **Un `%` literal dentro del string de formato rompe el `%`** ("unsupported format
  character"): escapar como `%%`. Caso real corregido 2026-10-21 en
  `game/isla-ancestral/scripts/vehiculos/test_vehiculos.gd:146` ("40% vel max" → el
  check corría igual porque el error no es fatal, pero el mensaje de fallo salía roto).
  Pendiente: proponer el alta de esta variante en GUIA-GODOT/01 §19.

### 3.5 Ciclo de vida y escenas
- `add_child` durante `_ready()` y `change_scene_to_file()` en `_ready()` causan
  "Parent node busy" (§13/§14).
- Comentarios markdown `** **` dentro de un `.gd` rompen el parse (§8).
- Mezcla de espacios/tabs: GDScript exige coherencia; **el repo usa tabs** en `.gd`
  (§21). Un solo error de parse en un script de autoload frena el boot completo.
- `@export` no acepta inner classes como tipo de Array (§9).
- Un script debe extender el mismo tipo que el nodo que lo lleva (§10).
- `String.compress()` no existe (§17); `Object.has()` no existe en Godot 4 (§20).

### 3.6 Verificar que un .gd compila
- Los DOS métodos que mienten están documentados en §31 (SB-11): leerla antes de
  confiar en un "compila ok". Un parse error en autoload deja el boot roto aunque el
  resto del archivo parezca sano.

### 3.7 Git en Windows
- `git checkout -- archivo` falla con "unable to unlink" en Windows (§33).

---

## 4. Diagnóstico de tildes (GUIA-GODOT/19) — resumen operativo

Ante un tildo/freeze, **leer `GUIA-GODOT/19-diagnostico-tildes.md` antes de tocar
código**. Causas documentadas:

| Causa | Síntoma | Fix |
|---|---|---|
| C-01 ⭐ | Autoload temporal huérfano (script de prueba registrado en `project.godot`) | Auditar `[autoload]`; eliminar todo lo que no sea sistema permanente |
| C-02 ⭐ | Mismo script como autoload Y en escena (doble ejecución) | Dejarlo SOLO en la escena; verificar `project.godot` antes de instanciar |
| C-03 | `quit()` programado en autoload de prueba | Eliminar el autoload y el script |
| C-04 | `TRANSPARENCY_ALPHA` en meshes de escala km | Material opaco + fade binario |
| C-05 | `VoxelTool.get_voxel` fuerza generación sincrónica | NUNCA en paths de streaming/spawn; usar polling o cache de alturas |
| C-06 | Noise por voxel en vez de por columnas | Generar por columnas (~80× menos llamadas) |
| C-07 | Jugador más rápido que el streaming (suelo fantasma) | Suelo fantasma temporal + verificación de voxel real al spawn |
| C-08 | Timer fijo para el streaming | Verificación por polling, no timers |
| C-09 | Parse error / indentación rota (Debugger Break parece tildo) | Leer el Parser Error exacto y corregir el bloque completo |
| C-10 | Impostor pesado: overdraw de paredes dobles | Paso 64 m + paredes solo en acantilados reales |
| C-11 | Acción de InputMap inexistente consultada por evento | `InputMap.has_action("x")` antes de consultar |

Protocolo en orden: matar el proceso → leer el log del último boot → auditar
`[autoload]` → correr el juego y contar mensajes clave → verificar Parser Errors →
aislar por sistema → re-verificar sintaxis antes de relanzar.

**Lección maestra (Log 814):** después de cada push, verificar que `project.godot` no
arrastre autoloads de prueba. Es la causa #1 de los "tildes misteriosos" del proyecto.

---

## 5. Convenciones duras del protocolo multiagente

### 5.1 Numeración y mensajes
- Un número = un archivo. Derivar el próximo del **máximo de archivos existentes + 1**
  en la carpeta destino (nunca del tope del pool: el head almacenado puede estar stale).
- Colisión de numeración con otro agente: reportar, no tocar el archivo ajeno.
- Mensajes: UTF-8 sin BOM + LF, en la carpeta propia del canal, con cabecera
  `**Responde a:**`.

### 5.2 Logs
- Reservar con `python scripts/reservar_log.py --reservar --agente <agente> --modulo <M##>`,
  midiendo el head de `Logs/NUMEROS_DISPONIBLES.txt` **justo antes**.
- Contenido: **ASCII puro (verificado por bytes) + CRLF + sin BOM**.
- Nombre: `Logs/<NN>-<desc>_<AAAA-MM-DD_HH-MM-SS>.md`.

### 5.3 Anti-falso-verde (suites de test)
- Guardia de 3 capas: `_fin(bloque)`/`_WB_BLOQUES` + `CHECKS_MINIMOS` **medido en
  verde** (nunca estimado) + `_summary()` en un `call_deferred` **separado** del de la
  corrida (si va junto, un aborto de runtime CUELGA la suite en vez de fallarla).
- Probar el guardián **EN ROJO por inyección** antes de confiar en él.
- Un `SCRIPT ERROR` que aborta una función = falso verde: la suite publica "0 fallos"
  sin haber corrido las aserciones.
- Un OK no se hereda: re-verificar en cada vuelta.

### 5.4 Medir antes de escribir la cifra
- Contar por **prefijo de línea** (`^- \[[x? ] ]`); los regex sueltos cuentan marcas
  citadas dentro del prose y fabrican drifts fantasma.
- Verificar suites con el **binario real** (`Godot_v4.7.2-stable_win64_console.exe
  --headless --path game/isla-ancestral --script res://...`), nunca con `which`.
- Un parser por posición o por ventana fija fabrica cifras falsas: validar el contador
  contra un caso conocido antes de publicar.

### 5.5 Marcas y QA (§21.8)
- `[x]` = código + testing. Flips de `[ ]`/`[?]` solo con **cita real** (archivo, línea,
  evidencia medida).
- **Nunca auto-sello**: el verificador ≠ el autor (§21.8.4/§21.23).
- Verbos de documentación ("Definir", "Diseñar", "Documentar") se cierran con el
  documento en disco; verbos de implementación ("Crear", "Implementar") requieren el
  código.

### 5.6 Commits
- NUNCA commitear ni pushear sin autorización explícita del director.
- Worktree **compartido**: jamás `git add -A`; usar pathspec selectivo y `add`+`commit`
  encadenados; si un ancla de patch desapareció, abortar.
- Un commit ajeno puede barrer cambios staged: verificar después.

### 5.7 Archivos protegidos
- NO TOCAR sin orden explícita: `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`,
  `project.godot`, ni el backlog/mensajes de otro modelo.

---

## 6. Scripts temporales y capturas

- Los scripts auxiliares van en `scripts-prueba/` (un solo uso) o
  `scripts-reutilizables/` (estables, prefijos `cap_`, `lanzar_`, `ver_`, `analizar_`,
  `run_`), **nunca en el root** del componente (AGENTS §24).
- **Prevención C-01:** todo script temporal registrado como autoload debe llevar en su
  header `# TEMPORAL (Módulo): ... Eliminar al finalizar.` y borrarse al cerrar la
  sesión. Después de cada push, verificar que `project.godot` no arrastre autoloads de
  prueba.
- Capturas: `tools/mcp/godot-mcp/capturas/{ID-Modulo}-Nombre/`, nomenclatura
  `cap_{ID}_{AAAA-MM-DD_HH-MM-SS}[_nota].png`; nunca sobrescribir; conservar al menos la
  anterior y la actual por módulo. La carpeta está gitignored.

---

## 7. Pendientes de este documento

- Linkear desde la fila 111 del `CHECKLIST-GLOBAL.md` (el dead-link que originó este
  encargo). Decisión del director.
- Proponer el alta de la variante "`%` literal dentro del string de formato" en
  `GUIA-GODOT/01` §19 (sección 3.4 de este documento).
