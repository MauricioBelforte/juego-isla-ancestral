# Log 1024: BUG-042 — las fuentes que eran páginas 404, y el gate que hace que no vuelva a pasar

**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Módulo:** transversal (bug de M46/M88 que afecta a M53 y M87)
**Iteración:** corrección de defecto preexistente + gate nuevo
**Fecha:** 2026-09-19 21:54
**Reserva:** 1024 (protocolo v3 — consumido del pool; quedó con `primero=1023`)

## Resumen

BUG-042 estaba registrado como `[ ] Abierto` desde el 2026-09-15 con la observación de que 3 de las 4
`.ttf` de `assets/fonts/` eran páginas HTML. En este ciclo se **confirmó por medición**, se
**rastreó hasta el commit que lo introdujo**, se **reemplazaron los binarios por las fuentes reales**,
se **cerró la puerta en producción** y se **cableó un gate de CI** para que la clase de fallo no
vuelva a pasar en silencio.

| # | Qué | Resultado |
|---|---|---|
| 1 | Confirmar el defecto por bytes mágicos | **confirmado**: 3 × `0a0a0a0a` = HTML 404 |
| 2 | Rastrear el origen | commit **`dd101d9` (2026-08-30)**, 514 líneas de HTML por archivo, mensaje *"0 errores FreeType"* |
| 3 | Reemplazar los 3 binarios por fuentes reales | Nunito 400/700 (938 glifos c/u) + Fredoka One (228) |
| 4 | Guarda en producción (`theme_ux._try_load_font`) | ahora **mide**; rechaza el falso |
| 5 | Gate de CI `binary-guard` | 1.107 binarios versionados, 28 extensiones |
| 6 | Sondas | 57 checks (Python) + **22 checks ×3** (Godot, 0 `SCRIPT ERROR`) |
| 7 | `fonts.json` de M88 (catálogo ≠ archivos) | **reportado, no tocado** |
| 8 | 3 `.png` que son JPEG/WebP en `tools/mcp/` | **reportado, no tocado** (untracked + gitignored) |

## 1. Confirmación: la extensión miente y el tamaño también

El bug ya estaba descrito, pero un reporte no es una medición. Lo primero fue leer los **primeros
4 bytes** de cada `.ttf`:

| Archivo | bytes mágicos | tamaño | realidad |
|---|---|---|---|
| `FredokaOne-Regular.ttf` | `0a 0a 0a 0a` | 304.724 B | HTML 404 |
| `Nunito-Bold.ttf` | `0a 0a 0a 0a` | 304.688 B | HTML 404 |
| `Nunito-Regular.ttf` | `0a 0a 0a 0a` | 304.727 B | HTML 404 |
| `Nunito-Variable.ttf` | `00 01 00 00` | 276.932 B | **TrueType real** |

Los tres falsos tienen **514 líneas** y su `<title>` es `Page not found · GitHub · GitHub`. El
tamaño (~304 KB) es el detalle que engaña: una fuente de texto de esa familia pesa 130-300 KB, así
que **por peso parecían legítimas**. Solo los bytes mágicos lo delatan.

## 2. Rastreo: entraron el 2026-08-30 y el commit afirma que funcionaban

```
$ git log --oneline -1 -- game/isla-ancestral/scripts/ui/theme/theme_ux.gd
79c1700 Se corrigio el BUG-048: la UI no compilaba en runtime (Log 983)

$ git show --stat dd101d9
dd101d9 Mauricio Belforte 2026-08-30
Se corrigió carga de fuentes TTF en tema UI (§9.48)
- FontFile.load_dynamic_font() reemplaza a load() para carga correcta de fuentes
- Eliminados wrappers .tres que no funcionaban
- 0 errores FreeType en runtime

 .../assets/fonts/FredokaOne-Regular.ttf             | 514 +++++++++++++++++++++
 game/isla-ancestral/assets/fonts/Nunito-Bold.ttf    | 514 +++++++++++++++++++++
 game/isla-ancestral/assets/fonts/Nunito-Regular.ttf | 514 +++++++++++++++++++++
 game/isla-ancestral/assets/fonts/Nunito-Variable.ttf| Bin 0 -> 276932 bytes
 game/isla-ancestral/scripts/ui/theme/theme_ux.gd    |  71 ++-
```

Dos hechos que valen más que el reporte original:

1. **Los 3 falsos entraron con 514 líneas cada uno** — exactamente las líneas de la página 404. El
   commit los agregó *y* afirmó "0 errores FreeType en runtime". La afirmación era falsa desde el
   primer día.
2. **`Nunito-Variable.ttf` entró como binario** en el mismo lote: de 4 descargas, 1 salió bien.
   Es la prueba de que la causa fue *una descarga fallida*, no un archivo inventado.

El defecto vivió **19 días** (2026-08-30 → 2026-09-19) y **ningún test se puso rojo**, incluido el
suite del módulo dueño: `scripts/fonts/test_fonts_m88.gd` (11 checks, verde) prueba el **catálogo**
—ids, familias, licencias— y **nunca llama a `load()` sobre un archivo**. Falso verde estructural: el
test no tocaba la capa donde estaba el bug.

## 3. Las fuentes reales

Ninguna decisión de licencia nueva: `ASSETS-LICENSE.md` ya declara **A003 Nunito** y **A004 Fredoka
One**, ambas **SIL OFL 1.1**, con `THIRD-PARTY-NOTICES.md` apuntando a los repos upstream. El trabajo
fue **reparar la descarga**, no elegir fuentes.

Origen elegido, y por qué:

- **Nunito**: `google/fonts/ofl/nunito/Nunito[wght].ttf` (variable, `wght 200..1000`), del que se
  instanciaron los pesos estáticos 400 y 700 con `fontTools.varLib.instancer`. Se fijaron
  `name`/`OS/2.usWeightClass` y se guardó **sin `fvar`** (estático de verdad).
  - **Validación cruzada con el propio repo:** la `Nunito-Variable.ttf` que ya estaba en
    `assets/fonts/` es **byte-idéntica** al upstream canónico (`sha256 bb55a5ca…`). Eso confirma que
    el origen elegido es el que el proyecto ya había usado bien una vez.
- **Fredoka One**: la familia actual de Google Fonts es `Fredoka` (variable, ejes `wdth`+`wght`), que
  **no es** la `Fredoka One` registrada. Se recuperó el binario estático original del historial de
  `google/fonts` en el commit `be2838a2` → `ofl/fredokaone/FredokaOne-Regular.ttf` (`00010000`,
  43.500 B, `family='Fredoka One'`). Así el archivo coincide con la licencia ya registrada en vez de
  introducir una familia nueva.

Cobertura medida con `fontTools`:

| Fuente | glifos | tildes | `ñ/Ñ` | `¡¿@#$` | cirílico |
|---|---|---|---|---|---|
| `Nunito-Regular.ttf` | 938 | OK | OK | OK | OK |
| `Nunito-Bold.ttf` | 938 | OK | OK | OK | OK |
| `FredokaOne-Regular.ttf` | 228 | OK | OK | OK | no aplica (display latina) |

`sha256` **antes → después**:

```
FredokaOne-Regular.ttf   14c7df8d37a75553…  ->  58faf312483569be7c1bfee95c905c7a…
Nunito-Bold.ttf          1a242bd07ac9af4d…  ->  d6e5eb784bb819f3384c5e880e6e8f3b…
Nunito-Regular.ttf       7be2e0e269671b6b…  ->  e81d084d5679de275b035b73c16e8b30…
```

Los 4 `.import` quedaron **sin cambios** (los parámetros de importación no dependen del contenido) y
Godot reimportó las 3 fuentes sin un solo `FreeType` en el log.

## 4. La puerta en producción: el cargador aceptaba basura

El commit `dd101d9` introdujo, junto con los archivos falsos, el cargador que los acepta:

```gdscript
var err := font_file.load_dynamic_font(path)
if err == OK:
    return font_file as Font      # ← sobre una página HTML, err == OK
```

`load_dynamic_font()` devuelve **`OK`** con un HTML con extensión `.ttf`. O sea: el código de error
**no** distingue una fuente de una página web. Arreglar los 3 archivos de hoy no cierra la clase de
fallo; la puerta tenía que aprender a medir:

```gdscript
if font_file.get_string_size("A", HORIZONTAL_ALIGNMENT_LEFT, -1, 16).x <= 0.0:
    push_warning("ThemeUx: " + path + " no es una fuente valida (no mide texto) — se usa la de reserva")
    return fallback_font
```

`theme_ux.gd` está limpio y su último cambio era del usuario (BUG-048), así que se editó y se
commiteó con pathspec sin riesgo de barrer trabajo ajeno.

## 5. El gate de CI y las dos sondas

**`scripts/verificar_binarios.py`** — lee los bytes mágicos y los compara con lo que la extensión
promete. Decisiones de diseño que salieron de medir, no de suponer:

- **Alcance = archivos versionados** (`git ls-files`), no el árbol completo. Motivo medido: el
  escaneo del árbol encontró **3 `.png` que no son PNG** (1 JPEG, 2 WebP) bajo
  `tools/mcp/*/capturas/`, pero están **untracked y gitignoreados** — son capturas locales de MCP,
  no assets del repo. Un gate que falla por un archivo ignorado es un gate que alguien va a
  neutralizar. Se agregó `--todos` para revisarlos a pedido.
- **AND dentro de cada firma.** `.webp` y `.wav` empiezan los dos con `RIFF` y solo difieren en los
  bytes 8-11. La primera versión de `firma_ok()` recorría los pares con un OR y **dejaba pasar un WAV
  con extensión `.webp`**. Lo encontró la sonda (no una hipótesis) y se corrigió: cada firma es un
  conjunto de pares que deben cumplirse **juntos**, y hay una lista de firmas alternativas.
- **Clasificación explícita de texto disfrazado**: HTML / XML / JSON / `TEXTO 404` / `TEXTO PLANO`,
  para que el informe diga *qué* es el archivo, no solo que está mal.

**`scripts/test_verificar_binarios.py`** (57 checks, ×3, exit 0) — prueba por inyección:

- `firma_ok()` por extensión, con el caso RIFF ambiguo;
- `clasificar_texto()` distingue HTML/XML/JSON de un binario real;
- `salta_dir()` respeta los directorios fuera de alcance;
- árbol temporal con buenos y malos: halla **exactamente** los malos y **deja pasar** los buenos (si
  siempre fallara, no serviría);
- **inyección**: se muta la tabla de firmas para que acepte el HTML como `.ttf` y se exige que la
  detección cambie; al restaurar, vuelve a rechazarlo.

**`game/isla-ancestral/scripts/fonts/test_fuentes_binarias_bug042.gd`** (**22 checks ×3, 0
`SCRIPT ERROR`**) — prueba la cadena **real de producción**, leyendo las rutas del propio
`theme_ux.gd` (no hardcodeadas):

- A: las 3 rutas existen y cargan.
- B: **miden texto** (`"Jugar"@16 px = 38.0 px`) — `load()` no nulo no alcanza.
- C: tildes, `ñ/Ñ`, `¡¿` miden > 0.
- D: la escala es monótona (24 px > 16 px).
- E: **control negativo** — escribe un HTML con extensión `.ttf` en `user://` y demuestra en vivo
  `err=0 (OK)` con `ancho=0.0 px`.
- F: la medición discrimina real (38.0 px) de falso (0.0 px).
- G: la guarda de producción `_try_load_font` **rechaza** el falso y devuelve la reserva.

Guardas anti-falso-verde, siguiendo las trampas ya documentadas: `_fin()` por bloque (un
`SCRIPT ERROR` aborta la función en silencio), piso de checks (22, el real medido en verde) y
`_summary()` en un `call_deferred` aparte.

**Prueba por inyección de la guarda de producción:** se revirtió `_try_load_font` al `err == OK`
original y la sonda **falló como debía**:

```
[FAIL] RECHAZA el HTML disfrazado y devuelve la reserva
       devolvio ():<FontFile#-9223371861046325785> en vez de la reserva
=== Resumen BUG-042: 22 checks, 1 fallos ===   (EXIT=1)
```

Archivo restaurado y comprobado por `sha256` (`4047b4c6…`).

**Cableado en CI** (`quality.yml`): job nuevo **`binary-guard`** (4 pasos, sin un solo `|| true`) y
la sonda de fuentes en `test-suite` con `|| FAIL=1`. Verificado: 10 jobs, `needs:` sin referencias
colgantes, `summary` lo incluye, `bash -n` del bloque modificado OK, y los 2 comandos del job nuevo
simulados en local con `rc=0`.

**La sonda funciona sin caché de importación.** Se apartaron los 4 `.fontdata` de
`.godot/imported/` y la sonda siguió verde: importante porque el job `test-suite` **no** corre
`--import`, así que en un checkout limpio el probe no puede depender de esa caché.

## 6. Ediciones ajenas en `quality.yml` (trampa 70, variante mismo archivo)

`quality.yml` tenía **41+/6− sin commitear de otros agentes** (fix de BUG-051 en `godot-lint` de
atria-dawn, y suites M64/M11 en `test-suite`). Un `git commit` normal se las habría llevado puestas.

Se usó el procedimiento de staging por bytes, y esta vez sobre un archivo con **dos** regiones
ajenas distintas: normalizar HEAD y worktree a LF, exigir que **las 5 anclas** aparezcan exactamente
una vez en **ambas** versiones, aplicar la **misma** transformación a las dos, comprobar que el delta
coincide (+1.994 en las dos), escribir el worktree = `HEAD + mío`, `git add`, `git commit -- <ruta>`,
y restaurar el worktree = `ajeno + mío`.

Resultado verificado:

```
[main 7a1a3b3] fix(ci): gate de integridad de binarios (bytes magicos) + sonda de fuentes BUG-042
 1 file changed, 43 insertions(+), 2 deletions(-)          <- solo lo mio

git diff --stat  ->  41 insertions(+), 6 deletions(-)      <- solo lo ajeno, intacto

gen_colector_sintaxis   en el commit: no (bien)   en el worktree: SI (bien)
test_player_m11         en el commit: no (bien)   en el worktree: SI (bien)
test_navegacion_m64     en el commit: no (bien)   en el worktree: SI (bien)
```

## 7. Reportado, no parcheado

- **`data/fonts/fonts.json` (M88)**: declara 4 fuentes placeholder (`museo_moderno`, `texto_cozy`,
  `script_isla`, `mono_debug`) con `tiene_archivo: false` que **no corresponden** a los archivos
  reales de `assets/fonts/` (Nunito / Fredoka One). La metadata es honesta respecto de sí misma,
  pero **el catálogo y los archivos no describen lo mismo**. No se tocó: es diseño de M88 y
  `test_fonts_m88.gd` fija el contenido actual. **Sugerencia para su dueño:** o el catálogo declara
  los archivos reales, o los placeholders se retiran.
- **3 `.png` que son JPEG/WebP** en `tools/mcp/*/capturas/`: untracked + gitignored, no son assets
  del repo. El guard los ve con `--todos`.
- **`test_fonts_m88.gd` sigue sin cargar un archivo.** El gate de fuentes ahora existe, pero el
  suite del módulo dueño mantiene su punto ciego. No se tocó (módulo de otro agente).

## 8. Estado del pool y de la numeración

- **Al reservar:** **478 libres** (`primero=1023`).
- **Al cerrar:** **407 libres** (`primero=1094`) y `Sin conflictos de numeracion`. La diferencia no
  es mía: otros agentes consumieron números en paralelo entre la reserva y el cierre.

La **colisión ajena 1013** (M128 de agnes vs M14 de atria-dawn) y las **2 reservas heredadas** del
mecanismo retirado en `2ac8b4b` (`1017-glm-5.3-flash-M39.txt`, `1022-atria-dawn-M127-QA.txt`) que
`--estado` reportaba al empezar **ya no aparecen**: las resolvieron sus dueños. **No toqué ninguna
de las tres** en ningún momento.

## 9. Qué queda pendiente

- **QA cruzado §21.8** de este ciclo (verificador ≠ autor). El cambio toca código de producción
  (`theme_ux.gd`), un guard nuevo y dos sondas.
- Conseguir la `Fredoka One` **completa** no aplica: la del historial de `google/fonts` ya es la
  estática completa (228 glifos, sin subset).
- El catálogo `fonts.json` de M88 (punto 7).

## Archivos tocados

| Archivo | Cambio |
|---|---|
| `game/isla-ancestral/assets/fonts/{Nunito-Regular,Nunito-Bold,FredokaOne-Regular}.ttf` | 3 binarios falsos → fuentes reales |
| `game/isla-ancestral/scripts/ui/theme/theme_ux.gd` | `_try_load_font` mide en vez de confiar en `err` |
| `game/isla-ancestral/scripts/fonts/test_fuentes_binarias_bug042.gd` | **nuevo** (22 checks ×3) |
| `scripts/verificar_binarios.py` | **nuevo** (guard de bytes mágicos) |
| `scripts/test_verificar_binarios.py` | **nuevo** (57 checks + inyección) |
| `.github/workflows/quality.yml` | job `binary-guard` + sonda en `test-suite` |
| `DOCUMENTACION/11-BUGS.md` | BUG-042 → `[x] Resuelto` + sección de resolución |

**Firma:**
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-19 21:54
