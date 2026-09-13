# Log 876: `.github/` versionado + bug hallado y corregido en `bug_metrics.yml`

**Fecha:** 2026-09-13
**Hora:** 18:14
**Modelo:** Hy3 / WorkBuddy
**Plataforma:** WorkBuddy (WorkBuddy AI)

## 0. Contexto

Al cerrar el Log 875 se reportó que **`.github/` estaba ignorado**
(`.gitignore:113`) y nunca versionado, exactamente el mismo riesgo que tenía
`docs/`. El usuario decidió versionarlo:

> *"si no son archivos que ocupan mucho espacio y como me decís son necesarios
> sí los versionamos."*

## 1. Inventario y verificación previa

8 archivos / **52 KB** (no ocupan espacio relevante):

| Archivo | Bytes | Líneas |
|---------|-------|--------|
| `.github/ISSUE_TEMPLATE/bug_report.md` | 1.246 | 65 |
| `.github/create_labels.sh` | 3.122 | 56 |
| `.github/workflows/backup.yml` | 4.789 | 109 |
| `.github/workflows/bug_metrics.yml` | 9.508 | 283 |
| `.github/workflows/dev-build.yml` | 3.863 | 132 |
| `.github/workflows/quality.yml` | 5.745 | 164 |
| `.github/workflows/release-build.yml` | 5.011 | 150 |
| `.github/workflows/testing.yml` | 2.662 | 93 |

Controles antes de versionar (todos OK):

- **Sin secretos.** Solo referencias a `secrets.GITHUB_TOKEN` y
  `secrets.GDRIVE_{TOKEN,CLIENT_ID,CLIENT_SECRET}` (GitHub Secrets, nunca
  valores literales). `create_labels.sh` usa `gh` autenticado.
- **Sin rutas locales ni nombres de usuario** (0 hits de `C:/Users`, `D:/`,
  `/home/*`).
- **UTF-8 válido, 0 U+FFFD** en los 8 archivos.
- Los `.github/` anidados (`tools/mcp/godot-mcp/**`, incluidos los de
  `node_modules`) siguen cubiertos por `.gitignore:83`, así que quitar el patrón
  genérico **no destapa nada**.

## 2. Cambios realizados

### 2.1 `.gitignore` + versionado (commit `a49c8b0`)

```diff
-.github/
+# `.github/` (raíz) SÍ se versiona: plantillas de issues y workflows de CI (M102).
```

`git log --all -- .github/` pasó de vacío a tener commit. Se marcó
`create_labels.sh` con modo **100755** (ejecutable).

### 2.2 `.gitattributes` (commit `a49c8b0`)

```gitattributes
.github/create_labels.sh text eol=lf
```

Con `core.autocrlf=true`, un clone en Windows deja el `.sh` con CRLF y revienta
al ejecutarlo en CI/Linux o en Git Bash (`\r: command not found`). Alcance
deliberadamente **mínimo (un archivo)** para no renormalizar los otros 3 `.sh`
versionados y no generar ruido a los agentes en paralelo.

### 2.3 M102 — nota en el plan actual (commit `a49c8b0`)

`DOCUMENTACION/102-Bug-Tracking/plan-actual/04-Codigo.md`: se agregó que los
artefactos de CI (`bug_report.md`, `create_labels.sh`, `bug_metrics.yml`)
también están versionados desde hoy.

### 2.4 BUG REAL: `bug_metrics.yml` no arrancaba (commit `c1da859`)

Validando los workflows con `yaml.safe_load` apareció:

```
ScannerError: while scanning an alias
  in "<unicode string>", line 147, column 1:
    **Generado:** {now.strftime('%Y- ...
```

**Causa:** el paso `run: |` exige que *todas* sus líneas estén indentadas al
menos como la primera (10 espacios). El Markdown del f-string
(`md = f'''# Bug Metrics Dashboard…`) estaba en **columna 0**, así que YAML daba
por cerrado el bloque y al toparse con `**Generado:**` interpretaba `*` como el
inicio de un **alias**, que es sintaxis YAML.

**Corrección:** reindentar 67 líneas (147–267) *solo las que estaban en columna
0*. YAML descuenta esos 10 espacios al materializar el bloque, así que bash y
Python vuelven a ver el Markdown en columna 0 y el `.md` generado queda
exactamente igual.

**Trampa que costó un intento:** reindentar *todas* las líneas del rango rompe
el Python — las líneas de código ya están a 10 espacios y al sumarles 10 más
quedan con sangría inválida (`IndentationError` en `for cat, count in
sorted(...)`). Primera pasada hecha así → restaurada desde backup y repetida con
el filtro `solo columna 0`.

**Verificación posterior:**
- `yaml.safe_load` OK en los 6 workflows (backup 1 job, bug_metrics 1, dev-build
  4, quality 6, release-build 4, testing 3).
- El Python del heredoc **compila** (239 líneas).
- Diff: 67 inserciones / 67 borraciones, sin ningún otro cambio.

### 2.5 `backup.yml` usaba `actions/checkout@v3` (commit `02f0893`)

Inventario de acciones usadas:

| Acción | Usos |
|--------|------|
| `actions/checkout@v4` | 15 |
| `actions/upload-artifact@v4` | 9 |
| `firebelley/godot-export@v5.2.1` | 6 |
| `firebelley/setup-godot@v2` | 4 |
| `actions/setup-python@v5` | 2 |
| `actions/cache@v4` | 2 |
| `softprops/action-gh-release@v2` | 1 |
| `actions/download-artifact@v4` | 1 |
| **`actions/checkout@v3`** | **1** ← el problema |

Era el único caso: `v3` corre sobre Node 16 y GitHub **falla automáticamente**
esas ejecuciones, así que el backup diario (que además es la red de seguridad
del §5 de AGENTS.md) nunca habría funcionado. Un solo cambio de línea a `v4`.

## 3. Archivos modificados/creados

**`a49c8b0`** — `.gitignore` (M), `.gitattributes` (A),
`DOCUMENTACION/102-Bug-Tracking/plan-actual/04-Codigo.md` (M),
`.github/` completo (8 A).

**`c1da859`** — `.github/workflows/bug_metrics.yml` (M, 67 líneas reindentadas).

**`02f0893`** — `.github/workflows/backup.yml` (M, 1 línea: `checkout@v3`→`v4`).

## 4. Consecuencia práctica

Los workflows **nunca se habían ejecutado** porque no estaban en el repositorio.
Ahora que sí lo están, van a correr en el próximo push. `bug_metrics.yml`
habría fallado de inmediato; `testing`/`quality`/`dev-build`/`release-build`
están sintácticamente bien, pero **no se ha verificado que pasen** (requieren
Godot y el export template en el runner).

## 5. Próximos pasos sugeridos

1. Vigilar la primera ejecución de los 6 workflows tras el push.
2. Las acciones de GitHub ya están todas en versiones con Node 20 (checkout v4,
   setup-python v5, upload/download-artifact v4, cache v4). Quedan dos de
   tercero sin revisar: `firebelley/godot-export@v5.2.1` (6 usos) y
   `firebelley/setup-godot@v2` (4 usos) — son las que construyen el juego, así
   que conviene confirmar que siguen mantenidas.
3. Retomar: 14 módulos sobre-cerrados · 329 rutas `.cs` inexistentes ·
   4 referencias ambiguas de `Logs/` + Log 723 fantasma.
