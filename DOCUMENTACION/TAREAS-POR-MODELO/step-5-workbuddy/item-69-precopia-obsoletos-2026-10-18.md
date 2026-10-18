# Pre-copia de `Obsoletos/` — ítem 69 del BACKLOG (respaldo §5 antes de refactors grandes)

**Agente:** Step-5-WorkBuddy · **Fecha:** 2026-10-18 · **Evidencia:** Log 1980
**Tarea:** "Pre-copia de `Obsoletos/` antes de refactors grandes (§5) — 6 [S]"
**Interpretación declarada:** la tanda no recibió un refactor concreto para respaldar, así que
trabajé lo que el ítem pide *antes* de un refactor: (1) medir si la red de seguridad §5 existe de
verdad y (2) dejar la herramienta que la aplica. No inventé un refactor para tener algo que copiar.

---

## 1. El hallazgo: `Obsoletos/` es 65,7 % disco local, no respaldo

Medido el 2026-10-18 03:2x sobre los 732 archivos de `Obsoletos/` (22.631.175 B ≈ 21,6 MiB),
clasificados con `git status --porcelain --ignored -z --untracked-files=all` contra `git ls-files`:

| Estado | Archivos | % | Bytes |
|---|---|---|---|
| versionado | 251 | 34,3 % | 6.123.232 |
| **ignorado** | **384** | **52,5 %** | **16.350.666** |
| sin seguimiento | 97 | 13,3 % | 157.277 |
| **FUERA DE GIT (ignorado + sin seguimiento)** | **481** | **65,7 %** | **16.507.943** |

Las reglas que los ocultan (`.gitignore` de la raíz):

| Regla | Archivos |
|---|---|
| `:246 Obsoletos/raiz-temporales-*/` | 344 |
| `:9 *.import` | 16 |
| `:220 out/` | 13 |
| `:92 .workbuddy-ai/` | 8 |
| `:90 .kilo/` | 3 |
| `:243 Obsoletos/libvoxel-TMP-*/` | 1 |

Consecuencia medida: un `git clean -fdx`, un clone nuevo, o la pérdida de esta máquina, se lleva
**2 de cada 3 archivos** de la carpeta que AGENTS.md §5 define como la última línea de defensa
antes de un refactor grande. Y los 97 sin seguimiento son los más frescos de todos: son los
`encoding-backup-*` que los agentes produjeron **hoy y ayer** (`encoding-backup-20261018_005227`
con 87 archivos, `encoding-backup-2026-10-18_01-11-22`, `encoding-backup-20261017_003530`,
`encoding-backup-manual-lote1-20261017_003841`). Hoy a las 00:52 se respaldó material de
`game/isla-ancestral/data/items/*.tres` y ese respaldo no está en ningún lado más que acá.

Complemento (recencia por mtime): 104 archivos tocados en las últimas 24 h, 18 en los 7 días,
381 en los 30 días, 229 hace más de 30. **La §5 se está usando todos los días** — el problema no
es que no se respalde, es que lo que se respalda no queda en el repo.

## 2. Segundo hallazgo: la nomenclatura §5 se cumple en el 18,7 %

§5 pide `AAAA-MM-DD_HH-MM-SS_nombre_archivo.extension`. Medido:

- **32** archivos con el sello completo en el **nombre** (incluidos los 2 respaldos del propio
  `.gitignore`, que al aplicarse la regla literal quedan `2026-10-10_18-37-19_.gitignore`, con
  doble guion bajo: la convención no prevé respaldar archivos que empiezan con punto).
- **105** con el sello en el **nombre de la carpeta** (p. ej. `2026-10-10_01-49-00_glb-respaldos-assets-3d/`).
- **595 (81,3 %) sin sello en ningún nivel**: carpetas como `backlog-cura-20260915-glm53flash/`,
  `encoding-backup-20260902_014555/`, `raiz-temporales-20260929/` (esta última con 193 archivos) o
  el `CHECKLIST-GLOBAL-backup-pre-reconciliacion-2026-10-02_03-40-13.md` suelto en la raíz.

No es un defecto grave (las carpetas fechadas se entienden), pero rompe la promesa de la regla:
no se puede ordenar `Obsoletos/` por fecha ni saber de un vistazo qué respaldo es de qué.

## 3. Tercer hallazgo: 6 respaldos de 0 bytes

Todos dentro de `raiz-temporales-*` (ignorados): `raiz-temporales-20260912/tmp_orig_s6.txt` y
cinco en `raiz-temporales-20260929/Logs/` (`_c39m.txt`, `_chk_g08.txt`, `_grep39.txt`,
`_m39dry.txt`, `_m39dry2.txt`). Un respaldo vacío es un respaldo que miente: ocupa lugar en el
índice mental de "esto está guardado" sin guardar nada.

## 4. Lo que SÍ dejé hecho: `scripts/precopia_obsoletos.py`

Aplica §5 de forma verificable en un comando. Antes de escribir una línea lo verifiqué tres veces
con el binario real (Python 3.13.12):

1. **`--dry-run`** sobre 2 archivos de prueba → imprime destino `Obsoletos/AAAA-MM-DD_HH-MM-SS_<contexto>/`,
   2 archivos, 30 bytes, y no escribe nada. Exit 0.
2. **corrida real** con `--destino-base` de prueba → copia los 2 archivos conservando la
   estructura, escribe `MANIFIESTO.txt` (SHA-256 + tamano por archivo) y verifica
   **2/2 por tamaño**. Exit 0.
3. **aborto por ancla faltante** → pide un archivo inexistente y **no copia nada**: Exit 1 con la
   ruta listada. Comprobado que la corrida abortada no dejó carpeta nueva.

Detalles de diseño que importan:

- **Aborta antes de copiar** si cualquier ruta pedida no existe (regla del repo: "si un ancla
  desapareció, ABORTAR"). Una pre-copia parcial silenciosa es peor que ninguna.
- **No sobrescribe** un destino existente: si la carpeta ya está, Error y Exit 1.
- **Manifiesto obligatorio**: sin él no se puede auditar que la copia esté completa.
- **Aviso final** recordando que el respaldo hay que commitearlo para que sobreviva.

Uso:

```
python scripts/precopia_obsoletos.py --contexto "pre-refactor-M17" --dry-run -- <rutas...>
python scripts/precopia_obsoletos.py --contexto "pre-refactor-M17" -- <rutas...>
```

**No ejecuté ninguna pre-copia sobre archivos vivos del proyecto**: no hubo refactor ordenado esta
vuelta y respaldar "por las dudas" llenaría `Obsoletos/` de más material sin dueño.

## 5. Lo que pido al director

1. **Decidir sobre los 481 archivos fuera de git.** Mi recomendación: commitear los 97 sin
   seguimiento (157.277 B, son de esta semana) y tratarlos como lo que son. Para los 384 ignorados
   haría falta tocar `.gitignore` (archivo protegido) o un `git add -f` selectivo; lo dejo a tu
   criterio. **Sin tu autorización no commiteé nada.**
2. **Ratificar o corregir la convención §5**: ¿carpeta con sello `AAAA-MM-DD_HH-MM-SS_contexto/`
   alcanza (es lo que hace el script), o se exige el sello en cada archivo? La regla literal hoy
   no se puede cumplir respaldando un `.gitignore`.
3. **Adoptar `scripts/precopia_obsoletos.py`** como paso previo obligatorio de los refactors
   grandes. Está sin commitear; te paso los paths cuando autorices.

## 6. Límites de esta tanda

- 0 commits · 0 push · 0 archivos de proyecto modificados · 0 borrados.
- 0 ediciones a `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`, `project.godot`, ni a los
  `05-Checklist.md` de ningún módulo.
- Archivos creados: `scripts/precopia_obsoletos.py` (nuevo, sin commitear), este informe y el Log
  1980. Las pruebas del script se hicieron contra `.workbuddy-ai/tmp/` (gitignored, `.gitignore:92`).
- Nota de carrera compartida: al abrir la vuelta el head del pool de Logs era **1979** y cuando
  reservé ya estaba consumido por otro agente → tomé **1980** (verificado libre antes de escribir).
