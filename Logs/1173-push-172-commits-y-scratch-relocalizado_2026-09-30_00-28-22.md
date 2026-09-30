# Log 1173: push a origin/main + relocalizacion del scratch (decisiones delegadas por el coordinador)

**Fecha:** 2026-09-30
**Hora:** 00:28
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Reserva:** el pool dio **primero=1173** justo antes de reservar (328 libres, sin conflictos de
numeracion). Al cerrar arranca en **1174**.

> **Nota de encoding:** este log se escribe en **ASCII puro** (sin acentos) a proposito, siguiendo la
> leccion que el coordinador documento en su Log 1171: su primera version salio con acentos corruptos
> por el propio pipeline. ASCII elimina la clase de fallo entera. Se verifica a nivel de bytes al cerrar
> (0 bytes no-ASCII).

## Encargo

Cerrado el MERGE-FINAL, el coordinador (atria-dawn) delego **dos decisiones**: (a) **el push** de los
commits acumulados, y (b) **que hacer con el scratch no-versionable** que dejo untracked (105
`Logs/_*.txt`, `probe_*`, `reports/`, 2 `Obsoletos/`). Textual: *"los deje untracked; borrarlos es
decision tuya, no mia"*.

**El estado se movio entre su mensaje y mi medicion.** El coordinador reporto *ahead 165*; al medir yo
el ahead real era **170** (mimo habia commiteado su P-53 en 5 commits), y en el momento del push el tip
ya era `7f5bf6e` (2 commits mas del coordinador). Leccion: **el numero del brief es una foto, no el
estado**. Medir siempre antes de actuar.

## 1. Auditoria previa al push (medida, no a ojo)

| Chequeo | Resultado |
|---|---|
| fast-forward (`origin/main` ancestro de HEAD) | **SI** -> push normal, **sin `--force`** |
| commits a subir | **172** (medidos en el rango `9798ae8..7f5bf6e`) |
| secretos en el rango | **0 reales**. Solo `.env.example` con valores **vacios** (`API_KEY=`) y mejoras de CI. Ningun `ghp_` / `sk-` / `AKIA` / PEM |
| blob mas grande del rango | **0.41 MB** (`tools/legal/auditoria_copyright_glb.json`), muy por debajo del limite de GitHub (100 MB) |
| scratch commiteado por error | **no**: `git log --all -- Logs/_z.txt` = 0 commits |
| encoding del Log 1171 (reescrito por el coordinador) | **verificado**: 0 bytes no-ASCII, sin BOM. Medido con `LC_ALL=C grep -c '[^ -~]'`, **no mirado** |

Remoto: `https://github.com/MauricioBelforte/juego-isla-ancestral.git`, rama `main`.

## 2. Push ejecutado

```
GIT_TERMINAL_PROMPT=0 git push origin main
To https://github.com/MauricioBelforte/juego-isla-ancestral.git
   9798ae8..7f5bf6e  main -> main
--- exit: 0
```

`git rev-list --left-right --count HEAD...origin/main` -> **`0  0`**: repo **sincronizado**, sin
divergencia y sin nada pendiente de subir.

`GIT_TERMINAL_PROMPT=0` se usa a proposito: si el remoto pide credenciales, **falla rapido** en vez de
quedarse colgado esperando input que en un agente no llega.

## 3. Relocalizacion del scratch (convencion Log 853, **NO borrar**)

El `.gitignore` del repo ya define el mecanismo (Log 853):

```
Obsoletos/raiz-temporales-*/
# Scratch temporal ... Se conserva en disco por si alguien lo necesita, no en el historial.
```

Ya existia `Obsoletos/raiz-temporales-20260912`. **Borrar habria sido la opcion equivocada**: la
convencion del propio proyecto es **conservar en disco, fuera del historial**.

**110 entradas movidas** a `Obsoletos/raiz-temporales-20260929/`, preservando la ruta relativa (reversible):

- 105 `Logs/_*.txt` + `Logs/_map_ids.json`
- `game/isla-ancestral/probe_root_tmp.gd`, `game/isla-ancestral/tools/probe_mesh_tmp.gd`
- `game/isla-ancestral/reports/`
- `DOCUMENTACION/39-Tiendas/Obsoletos/`, `Obsoletos/encoding-backup-dirigido/`

Verificado:

- `find Obsoletos/raiz-temporales-20260929 -type f` -> **188 archivos** preservados (las entradas de
  directorio contenian varios archivos cada una).
- `git check-ignore -v` -> **`.gitignore:209:Obsoletos/raiz-temporales-*/`** los cubre.
- El destino **no aparece** en `git status`.

**Antes de mover se midio que ninguno estaba referenciado**: grep acotado a `DOCUMENTACION/` + `Logs/`
sobre los 105 nombres -> **0 hits**. Eran residuo puro.

### Cuidado con los ignores a ciegas (medido)

Un patron ancho habria sido un error:

- `Logs/_*` matchea **5 archivos TRACKEADOS** (ver seccion 4).
- `probe*` matchea **7 archivos legitimos** (skills `godot-3d-lighting` / `godot-master`,
  `scripts/debug/_probe_debug.gd`).

La convencion del repo usa **rutas especificas** (p. ej. `game/isla-ancestral/_probe_col.gd`), no
patrones anchos. Por eso la solucion elegida es la carpeta-convencion, no una regla nueva de `.gitignore`.

## 4. Hallazgo: 5 scratch YA versionados (limpieza incompleta)

`Logs/_d39.txt` (959 B), `Logs/_estado39.txt` (2210 B), `Logs/_t39_test_loop_economico.txt` (26 KB),
`Logs/_t39_test_tiendas.txt` (25 KB), `Logs/_t39_test_tiendas_iter_glm.txt` (36 KB).

El commit `78c83da` ("limpieza de Logs/ scratch versionado: 34 borrados") **los toco pero los trunco en
vez de borrarlos** (`Bin 53712 -> 959 bytes`): siguen en `HEAD`, **~91 KB de scratch inconsistente** en
el repo. Ninguno esta referenciado en docs ni logs.

**Queda pendiente** y **no lo commiteo yo**: sacarlos requiere un `git rm --cached` + commit, y en este
momento **mimo esta activo commiteando** (trampas 114/115: indice compartido y resets ajenos). Es
decision de contenido versionado -> va al flujo del coordinador o a una tarea propia con el arbol quieto.

## 5. Estado final

- **Arbol sucio: 118 -> 9.** Los 9 restantes **no son mios**:
  - `Logs/NUMEROS_DISPONIBLES.txt` (M) -> pool, lo commitea el coordinador.
  - 4 `.tres` de vecinos (M) + `mercedes_lince.tres` (??) + `narrative_sound.gd` (M) -> **mimo** (P-53).
  - `scripts/auditar_flotacion_glb.py` + `tools/legal/flotacion_glb.json` (??) -> **agnes** (P-54, 2 archivos).
- **Push NEGATIVO deja de aplicar**: `origin/main == HEAD == 7f5bf6e`, **ahead 0**.
- Pool: reservado **1173**; al cerrar arranca en **1174**.

## Lecciones

1. **El numero del brief es una foto, no el estado.** El coordinador dijo 165; eran 170, y 172 al
   pushear. Medir siempre justo antes de actuar (ya estaba en las reglas duras para el pool; aplica a todo).
2. **Una impresion visual no es un diagnostico** (trampa 118 del coordinador). Verifique el encoding del
   Log 1171 con `LC_ALL=C grep -c '[^ -~]'`, no mirandolo. Mi canal de salida puede mostrar UTF-8 como
   cp1252 y hacerme "ver" mojibake que no existe.
3. **Antes de mover o borrar en masa: (a) comprobar que nada lo referencia, (b) buscar la convencion que
   el proyecto ya tiene.** El repo ya tenia `Obsoletos/raiz-temporales-*/`; inventar una regla nueva
   habria sido peor que seguir la existente.
4. **Un patron de ignore ancho se verifica contra lo TRACKEADO antes de proponerlo.** `Logs/_*` habria
   "ignorado" 5 archivos ya versionados y `probe*` 7 archivos legitimos.
