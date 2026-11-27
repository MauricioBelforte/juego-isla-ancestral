# Propuesta: exportar el juego sin el material de tests (medida, no estimada)

**Modelo:** Deepseek V4.1 Flash-DeepAI
**Plataforma:** DeepAI
**Fecha:** 2026-11-25 18:05
**Estado:** propuesta verificada — **no aplicada** (el preset es config de build; decide el fundador/director)

## Problema

Los 4 presets de `game/isla-ancestral/export_presets.cfg` usan `export_filter="all_resources"` con
`exclude_filter="Godot/*"`. O sea: el binario que se publica lleva **el framework de tests completo**
— las 146+ suites del proyecto, las 173 suites de `tests/` y los 516 archivos de `addons/gdUnit4/`.

## Solución propuesta (una línea por preset)

En los **4** presets (`[preset.0]` Web, `[preset.1]` Windows, `[preset.2]` Linux, `[preset.3]` SteamOS):

```ini
exclude_filter="Godot/*,addons/gdUnit4/*,tests/*,scenes/test_runner.tscn,*test_*.gd,*qa_*.gd"
```

Por qué cada patrón:

| Patrón | Qué saca | Por qué es seguro |
|---|---|---|
| `addons/gdUnit4/*` | El framework GNU/GdUnit4 (516 archivos) | Solo lo usa el runner de tests, no el juego |
| `tests/*` | Las 173 suites de `tests/` | Ningún script de producción las carga |
| `scenes/test_runner.tscn` | La escena runner (3 líneas) | Su único `ext_resource` es `res://tests/run_tests.gd`; si se excluye `tests/*` sin excluir esta escena, el export queda con una dependencia rota. **Ningún otro archivo la referencia** (verificado: solo aparece en `.godot/editor/editor_layout.cfg`, que es estado del editor y no se empaqueta) |
| `*test_*.gd` | Las suites que viven fuera de `tests/` (`scripts/**/test_*.gd`) | Son suites headless (`extends SceneTree`), no código de juego |
| `*qa_*.gd` | Las herramientas de QA (`qa_*.gd`) | Idem |

> ⚠️ Si algún día se agrega un runner de tests DENTRO del juego (p. ej. un menú de debug que corra
> suites), esta propuesta deja de valer: habría que excluir solo las suites, no el runner.

## Medición (2026-11-25, preset Windows, Godot 4.7.2, mismo comando que usa el CI)

| Medida | Preset actual | Con el filtro nuevo |
|---|---|---|
| Resultado del export | `rc=0` | `rc=0` |
| Tamaño del `.exe` | **124,52 MB** | **120,47 MB** (−4,05 MB, −3,3 %) |
| Rutas `res://tests/` dentro del binario | **174** | **0** |
| `res://scripts/stream/test_stream.gd` en el binario | presente | **ausente** |
| `res://scenes/test_runner.tscn` | presente | **ausente** |
| Arranque headless (`--headless --quit-after 90`) | `exit=0`, 303 líneas | `exit=0`, 291 líneas |
| Errores críticos al arrancar | 3 (fuentes BUG-042) | **los mismos 3** |

Los 3 errores comunes son preexistentes y **no** los causa el filtro:
`ERROR: Can't open file from path 'res://assets/fonts/Nunito-Regular.ttf'` (idem `Nunito-Bold` y
`FredokaOne-Regular`). Son los `.ttf` de relleno de **BUG-042** (magic `0a0a0a0a`, no son fuentes
válidas); la única válida es `Nunito-Variable.ttf`. O sea: el tema cae a la fuente por defecto en el
juego exportado, igual antes y después de este cambio.

## Lo que NO se midió

- Solo se exportó el preset **Windows**. Los otros 3 comparten la misma línea de filtro, pero no se
  exportaron (Web/Linux necesitan sus plantillas; el cambio es literalmente el mismo string).
- No se probó el juego con ventana (sin display en este entorno): el arranque verificado es headless.
- No se midió el efecto en el **tamaño del .pck de Web/Linux** (proporcional, no medido).

## Cómo verificarlo si alguien lo aplica

```powershell
$g = 'D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe'
& $g --headless --path game/isla-ancestral --export-release 'Windows' (Join-Path $PWD 'out/isla.exe')
# luego, sobre el .exe: buscar 'res://tests/' -> debe dar 0
```

Y arrancar el binario con `--headless --quit-after 90`: debe salir 0 con los mismos 3 errores de
fuentes de siempre.