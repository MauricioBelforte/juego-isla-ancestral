# BUG-118 — Aislamiento de la race de init (M91 / M41)

**Fecha:** 2026-10-07
**Verificador:** Hy3 / WorkBuddy (Hunyuan) — tercero §21.8
**Canal fuente:** `67-2026-10-07_00-58-11-atria-a-hy3-barrido-aceptado-no-hay-rojo-866-a-familia-fraudulenta-asigno-bug-118.md`
**Estado:** Diagnóstico puro, read-only. NO se aplicó ningún fix. Dueño del fix: M91 (mimo) / M41 (DeepSeek).

---

## Veredicto corto

La atribución original del bug — *"race de init M41/M91: si M41 (MusicDirector) no está
listo al arrancar, el check 'default Music 0.7' da 2 fallos; con M41 listo = 0/0"* — **NO se
reproduce tal como está escrita**. El test SÍ es flaky, pero la causa raíz **no es
`MusicDirector` (M41)**. Es que `test_audio_config.gd` lee el estado de `AudioConfig` en un
`call_deferred("_run")` que puede ejecutarse **antes** de que `AudioConfig._ready()` haya
poblado `_volumenes` y aplicado los dB a `AudioServer`. `MusicDirector` es un **correlato de
timing**, no el culpable.

---

## Entorno de reproducción

- **Godot 4.7.2 real**: `C:\Temp\godot\Godot_v4.7.2-stable_win64_console.exe` (también en
  `D:\ISLA ANCESTRAL\`). Es el binario del proyecto; no el 4.3/4.5 de la limitación vieja.
- **Proyecto**: `game/isla-ancestral`. Para no tocar el repo, los experimentos corrieron sobre
  una copia de solo lectura en `C:\Temp\ia_bug118\game\`.
- **Comando base (baseline)**:
  ```
  Godot_v4.7.2-stable_win64_console.exe --headless \
    --path game/isla-ancestral \
    --script res://scripts/audio/test_audio_config.gd
  ```
- **Orden de autoloads** (`game/isla-ancestral/project.godot`, sección `[autoload]`):
  `AudioConfig` = línea 86, `DataStore` = 87, `MusicDirector` = **99**.
  ⇒ `AudioConfig` SIEMPRE se inicializa ANTES que `MusicDirector`.

---

## Experimentos (evidencia medida)

Cada escenario se corrió 3 veces con el binario 4.7.2. Resumen:

| Escenario | Fixture | Resultado (x3) |
|---|---|---|
| **A — Baseline** (todo encendido) | comando base | **136 checks, 0 fallos, exit 0** (estable, 5/5) |
| **B — M41 DESACTIVADO** | comento `MusicDirector=...` en `project.godot` | **136 checks, 0 fallos, exit 0** |
| **C — AudioConfig DESACTIVADO** | comento `AudioConfig=...` | 19 checks, **17 fallos** (buses inexistentes) |
| **D — AudioConfig._ready AWAIT 1 frame** | `await get_tree().process_frame` al inicio de `_ready` (race forzada) | 136 checks, **73 fallos** |
| **F — MusicDirector._ready AWAIT 1 frame** (AudioConfig intacto) | `await get_tree().process_frame` al inicio de `_ready` | **136 checks, 0 fallos, exit 0** |

**Lectura de la evidencia:**

1. El baseline es estable 0/0 en esta máquina → el test no es flaky por default acá.
2. **Desactivar M41 NO reproduce la falla** (escenario B = 0/0). La afirmación literal
   *"M41 no listo → 2 fallos"* es falsa.
3. Retrasar SOLO `AudioConfig._ready` rompe el test (73 fallos, escenario D) → el test depende
   de que `AudioConfig` ya esté listo cuando corre `_run`.
4. Retrasar SOLO `MusicDirector._ready` (con AudioConfig intacto) deja el test en 0/0
   (escenario F) → **M41 no puede ser la causa**, porque está ordenado DESPUÉS de AudioConfig
   (86 < 99). Un M41 lento no puede retrasar a AudioConfig.

---

## Causa raíz (archivo:línea)

- `game/isla-ancestral/scripts/audio/test_audio_config.gd:28-29`
  ```gdscript
  func _init() -> void:
      call_deferred("_run")
  ```
  `_run()` (líneas 31-45) lee el estado de `AudioConfig` **sin garantizar que el autoload
  terminó de inicializar**.

- `test_audio_config.gd:73`
  ```gdscript
  _check(absf(ac.get_volumen("Music") - 0.7) < 0.01, "default Music 0.7 (diseño §3)")
  ```
  `get_volumen("Music")` devuelve `float(_volumenes.get("Music", 0.0))`
  (`audio_config_service.gd:129-130`). Si `_volumenes` está vacío (porque `_ready()` de
  AudioConfig no corrió todavía), devuelve `0.0` ≠ `0.7` → **FALLO**.

- `test_audio_config.gd:77`
  ```gdscript
  _check(absf(AudioServer.get_bus_volume_db(idx) - linear_to_db(0.7)) < 0.1,
      "Music aplicado en AudioServer (db)")
  ```
  Si `_aplicar_volumen()` no corrió, el bus Music queda en `0.0 dB` (default del engine) ≠
  `linear_to_db(0.7)` → **FALLO**.

- `game/isla-ancestral/scripts/audio/audio_config_service.gd:52-55`
  ```gdscript
  func _ready() -> void:
      _crear_buses()
      _cargar_config()
      _registrar_proveedor_guardado()
  ```
  Es `_ready()` el que puebla `_volumenes` y aplica los dB, vía
  `_cargar_config()` (línea 74, `_volumenes = DEFAULTS.duplicate()`) →
  `_aplicar_todo()` (línea 100) → `_aplicar_volumen()` (líneas 105-113,
  `AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(vol, 0.0001)))`).

- **Mecanismo:** `call_deferred` encola `_run` en la lista de diferidos del `SceneTree`; los
  `_ready()` de los autoloads también se procesan en la ventana de arranque. En corridas donde el
  diferido de `_run` se ejecuta antes de que `AudioConfig._ready()` complete (timing de la
  máquina / orden de inicialización / algún autoload pesado corriendo al lado), `_volumenes`
  está vacío y el bus Music no tiene `0.7 dB` → fallan las líneas 73 y 77. Es una **carrera de
  inicialización del harness del test**, no un bug de lógica de M41.

- **Por qué apareció M41 como culpable (corrección de la atribución):** en el entorno donde
  agnes/s2 lo observó, un `MusicDirector._ready()` lento (lee
  `res://data/audio/music_context_matrix.json` vía I/O de archivo, `music_director.gd:27-33`)
  desplazó el timing de toda la cadena de autoloads lo suficiente para que `_run` le ganara la
  carrera a `AudioConfig._ready()`. Pero como AudioConfig (#86) está antes que MusicDirector
  (#99), M41 solo puede **correlacionar** con la falla, nunca **causarla**. Confirmado
  empíricamente en el escenario F: retrasar solo M41 deja el test en verde.

---

## Nota sobre el conteo "2 fallos"

El fixture que retrasa TODO `AudioConfig._ready` da 73 fallos (todos los buses faltan). La
observación original de *"2 fallos"* corresponde a un **estado parcial** donde `_crear_buses()`
había corrido (buses existen) pero `_cargar_config()`/`_aplicar_volumen()` aún no (Music en
`0.0` y dB default). En `--script` el punto exacto donde el diferido de `_run` intercala con la
cadena de `_ready` varía, de ahí el conteo inconstante. La causa raíz es la misma: el test asume
`AudioConfig` ya inicializado.

---

## Fix propuesto (NO aplicado — dueño M91/M41, mimo/DeepSeek)

Hacer que el test **espere a `AudioConfig`** antes de leer su estado (tolerante al arranque).

### (A) Hacer `_run` tolerante al arranque — RECOMENDADO
En `test_audio_config.gd`, esperar a que `AudioConfig` esté listo antes de validar defaults:

```gdscript
func _run() -> void:
    await _esperar_audio_config()
    _test_buses_creados()
    _test_volumenes_default()
    # ... resto igual

func _esperar_audio_config() -> void:
    for i in range(30):
        var ac := root.get_node_or_null("AudioConfig")
        if ac != null and not ac._volumenes.is_empty():
            return
        await get_tree().process_frame
    push_warning("[M91] AudioConfig no estuvo listo tras 30 frames; el test puede fallar")
```

> Acoplar al campo privado `_volumenes` no es ideal. Mejor: que `AudioConfig` emita una señal
> `inicializado` al final de `_ready()` y el test haga `await ac.inicializado` (sin acoplar al
> detalle interno). Es la variante limpia de (A).

### (B) Forzar orden de init
Mover la lógica a un `Node` autoload, o hacer `await get_tree().process_frame` una sola vez en
`_init()` antes de `call_deferred("_run")`. Menos robusto que (A): sigue dependiendo de "un
frame alcanza" y no garantiza que todos los autoloads terminaron.

La opción **(A)** cierra la race de raíz sin tocar M41.

---

## Restricciones respetadas

- **Read-only sobre el código del repo.** Los experimentos usaron una copia en
  `C:\Temp\ia_bug118\game\` (el repo no se modificó).
- No se aplicó ningún fix.
- No se editó `CHECKLIST-GLOBAL.md`, `quality.yml`, `interaction_manager.gd` ni `11-BUGS.md`.
- Sin commit / sin push.
- **CI no se ve afectada:** `test_audio_config.gd` no está cableado en
  `.github/workflows/quality.yml` (verificado por grep: 0 coincidencias en `quality.yml` y en
  `.github/`). Coincide con el registro de BUG-118.

## Recomendación para el director
Corregir la línea de BUG-118 en `11-BUGS.md`: la causa no es "race de init M41/M91" sino
"race de init del harness de test vs `AudioConfig`". El fix sugerido (línea 190) de *"forzar
orden de init o hacer el check tolerante al arranque"* es correcto, pero el objetivo debe ser
**AudioConfig**, no MusicDirector.
