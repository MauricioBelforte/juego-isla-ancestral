# Log 2476: El binario exportado llevaba los tests — receta medida para sacarlos

**Fecha:** 2026-11-25
**Hora:** 18:10
**Modelo:** Deepseek V4.1 Flash-DeepAI
**Plataforma:** DeepAI

## Por qué

Venía de dos rondas de auditoría del gate. La pregunta que quedaba abierta (msg 007, KnownIssue para
M127): el preset exporta con `all_resources`, así que el juego publicado lleva **todo el material de
tests** dentro. Faltaba la receta con números, no una opinión.

## Qué se midió

Export real del preset **Windows** (Godot 4.7.2), dos veces: una con el filtro actual y otra con el
propuesto. Mismo comando, misma máquina.

| Medida | Actual | Propuesto |
|---|---|---|
| Export | `rc=0` | `rc=0` |
| `.exe` | 124,52 MB | 120,47 MB (−4,05 MB) |
| Rutas `res://tests/` en el binario | 174 | **0** |
| Suites fuera de `tests/` (`scripts/**/test_*.gd`) | presentes | ausentes |
| `scenes/test_runner.tscn` | presente | ausente |
| Arranque headless | `exit=0`, 303 líneas | `exit=0`, 291 líneas |
| Errores críticos al arrancar | 3 (fuentes BUG-042) | los mismos 3 |

Filtro:

```ini
exclude_filter="Godot/*,addons/gdUnit4/*,tests/*,scenes/test_runner.tscn,*test_*.gd,*qa_*.gd"
```

## Lo que hubo que averiguar antes

- **`scenes/test_runner.tscn` no lo referencia nadie**: su único `ext_resource` es
  `res://tests/run_tests.gd` y solo aparece en `.godot/editor/editor_layout.cfg` (estado del editor,
  no se empaqueta). Por eso hay que excluir la escena **junto** con `tests/*`: si se excluye solo la
  carpeta, el export queda con una dependencia rota.
- **`*test_*.gd` hace falta**: hay suites fuera de `tests/` (`scripts/stream/test_stream.gd`,
  `scripts/time/test_calendario.gd`, ...). Con solo `tests/*` seguían viajando.

## Falsos hallazgos que descarté en el camino

- Vi `ERROR: Can't open file from path 'res://assets/fonts/Nunito-Regular.ttf'` en el arranque y
  pensé en un bug de empaquetado de fuentes. No: esos `.ttf` son los **archivos de relleno de
  BUG-042** (magic `0a0a0a0a`, no son fuentes válidas). El error aparece igual en el binario actual y
  en el recortado: no es consecuencia del filtro.
- El primer export del baseline terminó con `0xC0000005` pero escribió el `.exe` completo; al
  repetirlo dio `rc=0` con el **mismo tamaño** (124,52 MB), así que fue un crash de salida, no del
  empaquetado. No lo cuento como hallazgo.

## Estado

- `export_presets.cfg` quedó **restaurado** (verificado: 4/4 presets con el filtro original) y sin
  diffs en `git status`. No se aplicó nada: es config de build.
- La receta completa, con el comando para reproducirla, está en
  `BACKLOGS/PROPUESTA-exportar-sin-material-de-tests.md`.
- Artefactos borrados (`out/exp`, copias del preset).