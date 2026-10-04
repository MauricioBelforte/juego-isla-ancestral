# Modelo: agnes-3-flash
# Plataforma: Kilo Code
# Fecha: 2026-10-03

# Política de Control de Versiones — Isla Ancestral (M06)

**Aplicable a:** Todo el repositorio del proyecto.

---

## A. Repositorio y Remoto

- **Repositorio:** `git` local + `GitHub` remoto. Rama principal: `main`.
- **`.gitignore`:** Godot + Python + OS + respaldos. Ver `docs/version-control-policy.md`.
- **Remoto:** GitHub. Tracking `origin/main`.
- **Prohibido:** `rebase` en main, `force-push` en main. Commits directos a main (proyecto 1 persona).
- **Ramas temporales:** Solo para features de riesgo (voxel, guardado, migraciones, rendimiento). Limpiar tras merge.
- **Backup:** Remoto GitHub + zip mensual local (rotativo, fuera del repo).

## B. Estrategia de Ramas

- `main` — única rama estable. Commits directos.
- `feature/NN-modulo` — módulos grandes de riesgo. Merge a main con PR.
- `hotfix/descripcion` — fix urgente. Merge directo + tag de patch.
- **Auto-revisión pre-commit:** `git status` + `git diff --staged` antes de cada commit.
- **QA cruzado (AGENTS §21.8):** El verificador es un modelo DIFERENTE al autor.
- **Prohibido:** Commits vacíos, mensajes en inglés, secrets en diff.

## C. Mensajes de Commit

- **Idioma:** Español. **Tiempo verbal:** Pasado descriptivo (pasivo/impersonal).
- **Título:** Resumido (≤ 72 chars). **Cuerpo:** Viñetas para cambios múltiples.
- **Protocolo de push (§4.2):** 1) `git log origin/main -1`, 2) `git diff --stat origin/main`,
  3) `git diff origin/main` (detalle), 4) Redactar commit, 5) `git add` + `git commit` + `git push`.
- **LF→CRLF:** Advertencia normal en Windows. No es un error.
- **Secreto/keys:** NUNCA commitear. Si aparecen en diff, `git filter-branch` + rotación de key.
- **Commit fallido:** Corregir con commit NUEVO. Nunca `amend` de un fallido.

## D. Revisión de Código

- **Checklist 5 pasos:** 1) Compila, 2) Sin errores runtime, 3) Flujos críticos OK,
  4) Sin archivos ajenos staged, 5) Mensaje correcto.
- **PR obligatorio:** M08/M09/M10 (voxel), M59 (save), migraciones, M61 (rendimiento).
- **QA cruzado:** Cada 2 semanas, un modelo revisa 3 módulos aleatorios.
- **Tags:** `v0.X.Y` por release. Build = tag + fecha + commit hash.

## E. Versionado y Changelog

- **Semver:** `v0.1.0` (dev) → `v0.5.0` (alpha) → `v0.9.0` (beta) → `v1.0.0` (release).
- **Post-lanzamiento:** `v1.1.0` (contenido), `v1.0.1` (fixes).
- **CHANGELOG.md** en raíz. Formato: Añadido / Cambiado / Corregido / Incompatible.
- **Incompatible:** Breaking changes en saves/config → aviso 2 versiones antes.
- **GameState (M59):** Versionado independiente. Migraciones = documento + changelog + test.

## F. LFS y Assets

- **Git LFS:** NO por ahora. Evaluación: assets > 100 MB (`.wav`, `.png` 4K).
- **Excluidos del repo:** `/.godot/`, `Builds/`, `*.pck`, `__pycache__/`, `scripts/backups/`, logs.
- **Si un binario entra por error:** `git rm --cached <archivo>` + commit. No usar `git filter`.

## G. Backups y Herramientas

- **Respaldo principal:** GitHub remoto (push diario).
- **Local:** Zip mensual rotativo (3 copias) fuera del repo.
- **Pre-cambio grande:** Copia en `Obsoletos/` (AGENTS §5).
- **Recuperación:** `git clone` + `git checkout <commit>`. Si `.git` corrupto: re-clone + re-import commits.
- **`git fsck`:** Mensualmente. Reportar y corregir antes de que crezca.

## H. Integración y Edge Cases

- **M07 usa M06 sin cambios.** No duplicar documentación.
- **Docs + código:** Separar en commits distintos.
- **Espacios en rutas:** Comillas obligatorias en PowerShell.
- **Paths largos:** `git config core.longpaths true` en Windows.
- **plan-inicial vs plan-actual:** NUNCA editar plan-inicial. Solo plan-actual.
- **Conflicto de NUMEROS_DISPONIBLES:** El primero que lee toma el número. El segundo toma el siguiente.
- **Push rechazado:** `git pull --rebase origin main` + resolver + `git push`. NUNCA force-push.

## I. Mantenimiento y Evolución

- **Revisión semestral:** Política de ramas + .gitignore.
- **Auditoría trimestral:** Permisos de acceso al repo.
- **Changelog:** Verificar que refleja cambios significativos.
- **LFS:** Reevaluar cuando el proyecto tenga > 500 MB de assets.
- **Convenciones de commit:** Actualizar si cambian las necesidades.
- **Backups:** Revisión anual. Test de restauración.
