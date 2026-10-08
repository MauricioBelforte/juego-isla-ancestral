# Log 1306: SB-08 — Validador de autoloads en GDScript (114/114 OK) + suite headless (21/21)

**Fecha:** 2026-10-05
**Hora:** 04:10:00
**Modelo:** space-bunny-alpha
**Plataforma:** Kilo Code

## Resumen

Mi **primera tarea de GDScript**. Construí el validador de autoloads que pidió el director
(canal 16) y lo verifiqué con el binario **Godot 4.7.2** que había en `C:\Temp\godot\`.

| Artefacto | Resultado |
|---|---|
| `scripts/validadores/validador_autoloads.gd` | **114 autoloads verificados · 114 OK · 0 FALLAN · exit 0** |
| `scripts/validadores/test_validador_autoloads.gd` | **21 checks · 21 OK · 0 FALLAN · exit 0** |

**Sin commit.** El director no commitea `scripts/`… y este está en
`game/isla-ancestral/scripts/`, que es zona de juego. **No commiteo nada: no me lo pidieron.**

## ⚠️ Lo más importante: mi PRIMER verificador dio 6 falsos positivos

La primera versión del validador reportaba **6 autoloads rotos**:
`EventBus`, `TooltipService`, `NotificationService`, `TermsManager`, `combat_island`,
`gem_currency`.

**Esos 6 compilan.** Y lo sé porque el juego los usa en runtime: vi `[DOM-UI]`,
`[NPCManager]`, `[VillagerManager]` funcionando en el log del boot mientras el validador los
declaraba rotos.

**El método que usaba era incorrecto, y el propio Godot me lo dijo:**

```
SCRIPT ERROR: Parse Error: Class "EventBus_" hides a global script class.
```

`GDScript.new()` + `source_code` + `reload()` compila el texto como un script **anónimo**, sin
ruta. Sin ruta no tiene contexto de `class_name`, así que **choca con la clase ya registrada en
el proyecto**. No es un bug del código: era un bug de mi checker.

## Los 3 métodos, medidos (no supuestos)

Usé 4 sondas descartables (`_sonda_1..4.gd`, borradas al terminar) para medir:

| Método | Detecta archivo ausente | Detecta error de sintaxis | Falsos positivos |
|---|---|---|---|
| **A)** `GDScript.new()` + `source_code` + `reload()` | no (necesita VFS) | **sí** | **6 de 114** ❌ |
| **B)** `ResourceLoader.load()` solo | sí | **NO** — devuelve un GDScript igual aunque el `.gd` tenga `func roto(:` | 0 |
| **C)** `ResourceLoader.load()` + `reload()` **sobre el recurso cargado** | sí | **sí** | **0** ✅ |

**El método C es el que quedó.** Verificado con fixture: `.gd` con error de sintaxis →
`Parse error` + `can_instantiate=false`; los 6 falsos positivos → `ERR_ALREADY_IN_USE`, que **no**
es un fallo de compilación (si hubiera compilado mal, nunca habría llegado a estar instanciado
por el proyecto).

**Este es el hallazgo técnico de la tarea:** `load()` solo no alcanza, y el método "obvio" de
compilar el fuente produce falsos positivos. La única combinación correcta es cargar y recargar
**el recurso ya cargado**, que tiene ruta y por lo tanto resuelve el `class_name`.

## Qué hace el validador

Por cada autoload de `[autoload]` en `project.godot`:
1. **Normaliza** el valor: quita el prefijo `*` (singleton) y comillas; valida `res://` y `.gd`.
2. **Existencia**: `ResourceLoader.exists()` o `FileAccess.file_exists()`.
3. **Carga**: `ResourceLoader.load(..., CACHE_MODE_IGNORE)`. Si es `null` → FALLA. Si no es
   `GDScript` → FALLA.
4. **Compilación**: `reload()` sobre el recurso. `ERR_ALREADY_IN_USE` no cuenta como fallo.
5. **Corroborante**: `can_instantiate()`. Si es `false` → FALLA (clase base ausente).

**Extra:** detecta **autoloads que comparten la misma ruta** (sistema duplicado). No es un fallo del
boot, así que se reporta aparte como `AVISO`, no como `FALLA`. El proyecto tiene un par
sospechoso: `Localization → scripts/localization/localization_manager.gd` y
`LocalizationManager → scripts/localizacion/localization_manager.gd` (**el mismo nombre de archivo,
dos directorios distintos**).

**Códigos de salida** (misma convención que `verificar_checklist.py`, BUG-075):
`0` todos OK · `1` alguno falla (reporta la lista completa, no fail-fast en el primero) ·
`3` **detector ciego** (no pude leer `project.godot` → no es «0 fallos», es «no miré»).

## Salida medida (con el binario real)

```
$ "C:\Temp\godot\Godot_v4.7.2-stable_win64_console.exe" --headless \
      --path game/isla-ancestral --script scripts/validadores/validador_autoloads.gd
autoloads verificados: 114 · OK: 114 · FALLAN: 0
== [SB-08] TODOS LOS AUTOLOADS OK ==          exit=0

$ ... --script scripts/validadores/test_validador_autoloads.gd
  OK   quita el prefijo * de singleton
  OK   acepta ruta sin *
  OK   rechaza lo que no es .gd
  OK   rechaza ruta fuera de res://
  OK   autoload valido -> OK
  OK     marca existe=true
  OK     marca compila=true
  OK   ruta inexistente -> FALLA
  OK     motivo menciona 'no existe'
  OK   archivo con error de sintaxis -> FALLA
  OK     el archivo SI existe (no es un falso 'no existe')
  OK   ruta no res:// -> FALLA
  OK     motivo menciona res://
  OK   project.godot inexistente -> no ok
  OK     motivo explica que no existe
  OK   proyecto saboteado -> exit 1
  OK     reporta el autoload con ruta inexistente
  OK     reporta el autoload con error de sintaxis
  OK     NO reporta como fallo el autoload valido
  OK   proyecto limpio -> exit 0
  OK     dice TODOS LOS AUTOLOADS OK
checks: 21 · OK: 21 · FALLAN: 0 (minimo exigido: 9)
== [SB-08] SUITE VERDE ==                    exit=0
```

Los 4 casos que pediste están, y el **caso 4 (sonda rojo) corre el validador como proceso
separado** con `OS.execute` contra un `project.godot` saboteado y comprueba el exit code real.
Los fixtures viven en `res://` (porque el método autoritativo solo existe sobre el VFS) y **se
limpian siempre**, incluso si un check falla.

## Limitación de diseño que declaro

`verificar_autoload()` **no soporta rutas fuera de `res://`**. El método autoritario (`load()`)
solo existe sobre el VFS del proyecto; aceptar rutas de disco exigiría el método A, que ya demostré
que produce falsos positivos. **Prefiero un validador que cubre el caso real sin mentir sobre los
demás** — y el motivo está escrito en el código para que nadie lo "arregle" reintroduciendo el bug.

## Archivos Modificados/Creados

### Creados
- `game/isla-ancestral/scripts/validadores/validador_autoloads.gd` (8.930 bytes) — el validador.
- `game/isla-ancestral/scripts/validadores/test_validador_autoloads.gd` (8.977 bytes) — la suite.
- `Logs/1306-SB08-VALIDADOR-AUTOLOADS-GDSCRIPT_2026-10-05_04-10-00.md` — este log.
- `Logs/1307-SB09-SB10-VISION-VERIFICADA-Y-ENTRADA-POR-POSTMESSAGE_2026-10-05_04-40-00.md` — SB-09/10.
- `Mensajes entre modelos/space-bunny-alpha/17-...` — informe al director.

### Sondas creadas y **borradas** (eran diagnóstico, no entregable)
`_sonda_diagnostico.gd`, `_sonda_2.gd`, `_sonda_3.gd`, `_sonda_4.gd` — sus resultados están en este
log y en el comentario de cabecera del validador. **Borradas: un script de diagnóstico que no se
entrega es ruido.**

### Sin tocar
`CHECKLIST-GLOBAL.md` · `quality.yml` · `.github/workflows/**` · `scripts/test_scripts.py` ·
`project.godot` · los `.gd` de los 114 autoloads · filas `🔵`/`🔴`.

## Mis errores en esta tarea (6)

| # | Error | Detección |
|---|---|---|
| 1 | **El método de chequeo daba 6 falsos positivos** | Contrasté con los `[DOM-UI]`/`[NPCManager]` del log del boot: los 6 autoloads estaban **funcionando** mientras yo los declaraba rotos |
| 2 | Asumí que `ResourceLoader.load()` detectaba errores de sintaxis | La sonda 3 lo disprobó: devolvió `GDScript` para un `.gd` con `func roto(:` |
| 3 | `OS.create_process` no captura stdout | Lo reemplacé por `OS.execute`, que sí devuelve `output` |
| 4 | `ord("ESC")` → `TypeError` (3 letras) | traceback |
| 5 | Desempaquetado de 3 valores en 2 variables → `ValueError` | traceback |
| 6 | Regex `"physical_keycode"` **con comillas**: mi patrón sin comillas dio «0 acciones con tecla de 18» | **El dato me contradijo** (el diario sí tiene tecla 74) → mismo tipo de error que mi E1 en SB-02 |

**E1 y E2 son los que importan:** los dos habrían producido un informe **falso y alarmista** sobre
el estado del proyecto. **Los dos los atrapé porque contrasté el resultado con una fuente
independiente** (el log del boot) en vez de confiar en mi propio checker. Es la misma disciplina de
SB-02 («ante dos lecturas que se contradicen, desconfiar de la lectura») aplicada al código.

## Lo que NO hice

- **No commiteé nada.**
- **No reporté los 6 falsos positivos como bugs.** No son bugs: son errores míos ya corregidos. Los
  detallo arriba para que se vea el método, no el error.
- **No arreglé el par `Localization` / `LocalizationManager`.** No sé si es un duplicado real o dos
  capas distintas; lo reporto como `AVISO` para que su dueño lo decida.
- **CERO afirmaciones visuales.** Esta tarea es 100 % headless.

---

**Firma:** **Modelo:** space-bunny-alpha · **Plataforma:** Kilo Code · **Fecha:** 2026-10-05 04:10:00