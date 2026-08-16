**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 06: Control de Versiones

## 1. Análisis de los 21 puntos del plan maestro (sección 5)

| # | Punto | Estado | Resolución |
|---|---|---|---|
| 1 | Crear repositorio Git | ✅ Hecho | `git init` 2026-08-15; rama main; 4 commits |
| 2 | Crear .gitignore | ✅ Hecho | Unity + Python + SO + respaldos; verificar reglas Godot (.godot/) |
| 3 | Estrategia de ramas | ✅ Definida | §2 (main + feature por módulo + hotfix) |
| 4 | Rama principal | ✅ `main` | Protección remota pendiente (GitHub) |
| 5 | Ramas de features | ✅ Definida | `feature/NN-nombre-modulo` |
| 6 | Ramas de hotfix | ✅ Definida | `hotfix/descripcion` |
| 7 | Mensajes de commit | ✅ En uso | Español, pasado descriptivo, cuerpo con viñetas |
| 8 | Política de PRs | ✅ Definida | PR directo a main con auto-revisión (1 persona); QA cruzado del protocolo como revisión |
| 9 | Git LFS | ✅ Evaluado | NO por ahora: assets Godot pequeños; evaluar si entran builds/audio 4K |
| 10 | Repositorio remoto | ✅ Hecho | GitHub: MauricioBelforte/juego-isla-ancestral |
| 11 | Backups del repo | ⬜ Pendiente | Backup local mensual (zip) + GitHub como remoto |
| 12 | Protección de ramas | ⬜ Pendiente | Activar protección de `main` en GitHub (ci nunca, PR nunca para 1 persona — evaluar) |
| 13 | Revisión de código | ✅ Definida | Auto-revisión con checklist §3 + QA cruzado AGENTS §21.8 |
| 14 | Tags de releases | ⬜ Pendiente | Semver desde v0.1.0 (prototipo M1) |
| 15 | Versiones del juego | ✅ Definida | Semver + nombre de build (dev/alpha/beta/v1.0) |
| 16 | Changelog | ⬜ Pendiente | Crear `CHANGELOG.md` raíz con el historial actual |
| 17 | Cambios incompatibles | ⬜ Pendiente | Regla: sección "breaking" en changelog + aviso (saves!) |
| 18 | Migraciones | ⬜ Pendiente | Regla: documento por migración (GameState versionado M59) |
| 19 | Herramientas internas | ✅ Documentado | scripts/ del protocolo (generar/verificar checklist) |
| 20 | Assets pesados | ✅ Evaluado | Solo Resources/ de Godot; LFS si >100 MB total |
| 21 | Archivos generados | ✅ En uso | .gitignore excluye .godot/, builds, __pycache__, backups |

## 2. Análisis: ¿PR o commits directos?

Proyecto de 1 persona + agentes IA: los PR agregan fricción sin valor de revisión humana real. **Decisión:** commits directos a `main` con auto-revisión pre-commit (git status/diff antes de commitear, AGENTS §4.2), y **QA cruzado del protocolo** (AGENTS §21.8) como revisión entre modelos. Los PR se reservan para features grandes de riesgo (nuclear: voxel, guardado, migraciones de versión).

## 3. Análisis de versionado

Semver clásico del juego:
- `v0.x.y`: prototipos (M1 → v0.1.0), vertical slice (v0.2.0), alfa (v0.3.0), beta (v0.4.0).
- `v1.0.0`: lanzamiento.
- Post: `v1.1.0` contenido nuevo; `v1.0.1` fixes.
- Tag por release + nombre amigable (`alpha-1`).

Los saves llevan su propio versionado de GameState (M59) independiente del build: un save nunca se rompe sin migración.

## 4. Riesgos

| Riesgo | Mitigación |
|---|---|
| Rebases/force-push que pierden trazabilidad | Prohibido en main; usar merge commits limpios |
| Secrets en repo | .gitignore + regla de no commitear; revisar con git diff |
| Branch muertas | Eliminar tras merge; regla de limpieza |
| Pérdida de repo local | Backup mensual + remoto GitHub verificado |