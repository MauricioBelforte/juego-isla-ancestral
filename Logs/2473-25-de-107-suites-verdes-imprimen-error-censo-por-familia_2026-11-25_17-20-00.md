# Log 2473: 25 de 107 suites verdes imprimen ERROR — censo por familia

**Fecha:** 2026-11-25
**Hora:** 17:20
**Modelo:** Deepseek V4.1 Flash-DeepAI
**Plataforma:** DeepAI

## Por qué

El gate (`quality.yml`) solo mira el exit code. Un `SCRIPT ERROR` aborta y no rompe el exit; un
`ERROR:` tampoco. Ya encontré un caso real de esta familia (`test_stream.gd`, format string roto
que dejaba el mensaje del check vacío). Esto mide **cuánto de esa familia queda** en el gate.

## Método

1. Censo previo sobre las **107 suites del workflow** (`out/_tmp_ruido.json`): exit code +
   conteo de `SCRIPT ERROR`, `String formatting error` y `ERROR:` por suite.
2. Re-ejecución de las **25 suites que salen verdes imprimiendo `ERROR:`**, clasificando cada
   línea por marca conocida (`tools/_tmp_error_familias.py`, temporal, borrado al terminar).

## Resultado global

```
107 suites        -> 0 rojas, 0 timeouts
  con SCRIPT ERROR      -> 0
  con format error      -> 0
  con ERROR: y exit 0   -> 25  (64 lineas)
```

## Familias de las 64 líneas

| Familia | Líneas | Suites | Veredicto |
|---|---|---|---|
| `get_node()` con ruta absoluta fuera del árbol | 14 | 5 | Ruido del engine: `get_node_or_null("/root/…")` sobre un nodo instanciado sin `add_child` (p.ej. `scripts/time/game_clock.gd:51`) |
| FreeType / `_ensure_cache_for_size` | 12 | 1 | Test negativo deliberado (BUG-042: fuentes binarias inválidas) |
| Test negativo deliberado (JSON inválido, save corrupto, `.tres` faltante, slot de versión futura) | ~24 | 9 | Correcto: el test provoca el error y verifica el manejo |
| `N resources still in use at exit` | 8 | 8 | Fuga real al salir (menor, pero el gate no la mira) |
| Otros (thread-safety, Timer fuera del árbol, `SHFileOperation`, telemetría) | 6 | 5 | Ver hallazgos |

## Hallazgos que valen seguir

1. **Thread-safety en `/root/DataStore`** — `scripts/datos/test_datos_m60_iter3.gd` (verde) imprime:
   `ERROR: /root/DataStore: The caller thread can't call the function get_node_or_null() on this node.`
   Alguna ruta llama a `get_node_or_null` desde un hilo worker: en juego eso devuelve `null` en
   silencio y la lógica cae al fallback sin avisar. **No lo toqué**: `DataStore`↔`SaveManager` está
   declarado `PERMITIDOS` (BUG-069) y el módulo no es mío. Para el dueño de M60/persistencia.
2. **`tests/test_m17_categorias.gd`**: `ERROR: Unable to start the timer because it's not inside the
   scene tree.` El `Timer` no arranca, así que un check basado en timeout puede ser vacuamente verde.
   M17 está reclamado por `minimax-m3-1-flash`: reportado, no tocado.
3. **8 suites dejan recursos vivos al salir** (`2` a `5 resources still in use`). No rompe nada hoy,
   pero es la señal más barata de detectar leaks en headless.

## Corrección de un falso hallazgo propio

En la primera captura vi mojibake (`vÃƒÂ¡lido`, `archipiÃƒÂ©lago`) y pensé en un bug de encoding del
juego. Verificado contra la fuente: `save_loader.gd:137` y `island_registry.gd:100` están en UTF-8
correcto. El mojibake era de **mi captura** (consola cp1252 + `Tee-Object`). Descartado.

## Recomendación (para el director, no aplicada)

Que el paso de tests del workflow trate como **rojo** estas tres marcas (`SCRIPT ERROR`,
`String formatting error`, `resources still in use`) y deje el resto como aviso. Es un cambio de
`run_tests.py` (M118, de atria) de ~10 líneas; hoy el 100% de las suites pasaría el filtro salvo
las 8 de recursos.

## Archivos

- Evidencia temporal (gitignored): `out/_tmp_ruido.json`, `out/_tmp_error_familias.json`, `out/_tmp_error_familias.log`.
- Script temporal borrado: `tools/_tmp_error_familias.py`.
- Sin cambios en código ni en workflows.