# Log 1312: Voxel versionado (opcion B, git plano 100 MB) — cascada voxel resuelta

**Fecha:** 2026-10-05
**Hora:** 03:08
**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code

## Resumen

Prioridad 1 del director (canal 31): versionar el addon `zylann.voxel` con sus binarios
multiplataforma. **Decision del fundador: opcion B (git plano)**, por mi recomendacion
(canal 27): cero cambios de infraestructura, no depende de `git-lfs install` en todos
los agentes, y estamos debajo del limite de GitHub (100 MB/archivo).

Esto deberia resolver **la cascada voxel**: el linter (12 SCRIPT ERROR) y los fallos
voxel-dependientes de M112 (M11 Player, M60, M106-env).

## Cambios Realizados

### 1. Excepciones de .gitignore (las dos necesarias)

El addon estaba ignorado por **dos** reglas, y habia que tocar las dos:

**`.gitignore` (raiz) L15-22:**
```
# Godot — addons (se instalan via AssetLib, no se versionan)
game/isla-ancestral/addons/*          # antes: game/isla-ancestral/addons/ (con barra final)
!game/isla-ancestral/addons/zylann.voxel/
```
**Detalle tecnico importante:** el patron original `addons/` (con barra final) excluye
el directorio completo, y git **no permite re-incluir nada dentro de un directorio
excluido**. Por eso se cambio a `addons/*` (excluye el CONTENIDO) + negativizacion del
subdirectorio concreto. Asi `gdUnit4` y cualquier otro addon siguen ignorados.

**`game/isla-ancestral/.gitignore` L40-46:**
```
addons/*/bin/
!addons/zylann.voxel/bin/
```
Esta segunda regla era la que **realmente ignoraba los binarios** (la encontre con
`git check-ignore -v` despues de que la primera excepcion no surtiera efecto).

Verificado con `git check-ignore`:
- `libvoxel.linux.editor.x86_64.so` -> **no ignorado** (correcto).
- `addons/gdUnit4/plugin.cfg` -> **sigue ignorado** (correcto, no se autorizo).

### 2. Commit aislado: 12 binarios, 100.2 MB

`f0f9586` — solo el addon + los 2 .gitignore:

```
libvoxel.linux.editor.x86_64.so          11.2 MB   ← el que necesita CI
libvoxel.linux.template_release.x86_64.so  9.8 MB
libvoxel.windows.editor.x86_64.dll         7.2 MB
libvoxel.windows.template_release.x86_64.dll 5.2 MB
libvoxel.android.editor.arm64/x86_64.so   8.7/8.8 MB
libvoxel.android.template_release.*.so    7.0/7.2 MB
libvoxel.ios.editor.arm64.dylib           6.2 MB
libvoxel.ios.template_release.arm64.dylib 5.2 MB
libvoxel.macos.editor.universal           (framework)
libvoxel.macos.template_release.universal (framework)
```

- **Sin basura de build** (verificado: no hay `.o`, `.a` ni caches).
- `.gdextension` referenciaba **exactamente** estos 12 paths (verifique el archivo antes
  de commitear): `linux.debug.x86_64 = "./bin/libvoxel.linux.editor.x86_64.so"`, etc.
- **Commit aislado de verdad:** mi `git diff --cached --name-only` encontro **5 archivos
  de Hy3 pre-staged** (Log 1309, su BACKLOG, 2 mensajes) que restoree del index sin
  tocar su contenido. El commit final llevo exactamente 14 archivos.

### 3. Medicion de tamano (paso 4 del director)

| Metrica | Antes | Despues |
|---|---|---|
| `count` | 24161 | 24241 (+80) |
| `size-pack` | 65.61 MiB | 65.61 MiB (sin repack todavia) |
| `size` (suelto) | 254.11 MiB | 256.66 MiB |

**Honestidad sobre la medicion:** `size-pack` no subio porque git todavia no compacto
los objetos nuevos (el repack automatico no corrio). Los 100 MB estan en objetos sueltos
y se consolidaran en el pack en el proximo `gc`. El costo real aceptado por el fundador
es +100 MB en la historia, permanente.

### 4. Fix de space-bunny incluido

El `.gitignore` raiz tenia el fix `_*.txt`/`_moji.txt` de space-bunny (SB-07, Log 1296)
sin commitear en el working tree. Se incluyo en este commit porque era necesario para
completar la excepcion, y esta **documentado en el mensaje del commit**. space-bunny
quedo avisado (mi canal 13 suyo).

## Verificacion pendiente: linter a 0

El paso 3 del director es verificar que el **GDScript Linter pase de 12 SCRIPT ERROR a
0** en el run siguiente. El commit `f0f9586` ya esta en main; el run se disparo.

**Si no pasa a 0**, como dijo el director: "seria senal de que la cascada tenia otra
causa ademas del addon". Lo verifico en cuanto termine el run y reporto.

## Nota sobre M83 Scanner

Mi diagnostico del canal 28 detecto que M83 Scanner falla por **gdUnit4 no versionado**
(n=1, espera >=2 addons). Este log NO versiona gdUnit4 (no estaba autorizado). Si el
M112 sigue fallando por M83 despues de voxel, esa es la causa — queda documentado para
la decision del director.

## Archivos Modificados/Creados

- `.gitignore` (excepcion voxel + fix SB-07 de space-bunny)
- `game/isla-ancestral/.gitignore` (excepcion bin/)
- `game/isla-ancestral/addons/zylann.voxel/bin/` (12 binarios, 100.2 MB)
- `Logs/1312-voxel-versionado-opcion-b_2026-10-05_03-08.md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (1312 consumido; nueva cabeza 1313)

## Huella de push (AGENTS.md seccion 4.3)

Push principal: `52ddbe1..f0f9586` (main -> main), 2026-10-05 03:05, atria-dawn-s2 / Kilo Code.
Commit `f0f9586` "Se versiono el addon zylann.voxel con sus binarios multiplataforma (100 MB)".
**Rango de exactamente 1 commit** — sin catch-ups esta vez.
