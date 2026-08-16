**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 06: Control de Versiones

## 1. Estado actual del repo (verificado)

| Aspecto | Valor |
|---|---|
| Repositorio | `git init` 2026-08-15, rama `main` |
| Remoto | `origin` → https://github.com/MauricioBelforte/juego-isla-ancestral.git |
| Commits | 26d4bd2 (repo inicial) · e044c29 (base completa) · b09a57e (M01) · e534ca2 (M04) · 7dbe1b6 (M05) |
| .gitignore | versión actual: Unity, Python, SO, /scripts/backups/ + excepciones Logs/Obsoletos/DOCUMENTACION |

## 2. Estrategia de ramas

```
main                          ← rama estable, siempre jugable/documentable
├── feature/NN-modulo          ← una por módulo grande (uso temporal)
├── hotfix/descripcion         ← fix urgente sobre main
└── (sin develop: 1 persona)
```

Reglas:
- Todo commit va a `main` directo tras auto-revisión, EXCEPTO módulos de riesgo (voxel, guardado, migraciones, rendimiento) que usan `feature/` + PR.
- `hotfix/` se mergea a main con mensaje `fix:` y se taggea un patch.
- Las ramas temporales se borran después del merge.
- **Prohibido:** rebase/force-push sobre `main`, commits vacíos, mensajes en otro idioma.

## 3. Auto-revisión pre-commit (1 persona + agentes)

Checklist obligatorio antes de cada commit:
1. `git status` y `git diff` revisados (nada raro entra).
2. Sin archivos binarios/secretos; `.gitignore` cubre generados.
3. Mensaje en español, pasado descriptivo, cuerpo con viñetas si >1 cambio.
4. Convenciones del módulo M05 aplicadas si hay código.
5. Si afecta saves/compatibilidad: aviso en changelog + log.

QA cruzado (AGENTS §21.8): tras cada módulo `✅`, un segundo modelo verifica antes de liberar como definitivo.

## 4. Versionado de builds (semver)

| Etapa | Tag | Ejemplo build |
|---|---|---|
| Prototipo | v0.1.0 | `v0.1.0-dev` |
| Vertical slice | v0.2.0 | `v0.2.0-slice` |
| Alfa interna | v0.3.0 | `v0.3.0-alpha` |
| Beta cerrada | v0.4.0 | `v0.4.0-beta` |
| Lanzamiento | v1.0.0 | `v1.0.0` |
| Contenido post | v1.1.0 / v1.2.0 | — |
| Fix | +patch | — |

- Tag en GitHub = release con nombre + descripción + changelog.
- El build exportado lleva la versión en el nombre del directorio (`Builds/v1.0.0/`).

## 5. Changelog (nuevo archivo raíz `CHANGELOG.md`)

```
Formato (Keep a Changelog reducido):
## [Versión] - fecha
### Añadido
### Cambiado
### Corregido
### Incompatible (breaking) ← secciones para saves/config
```

Historial inicial a registrar: commit raíz (repo+README), base completa (62 archivos), M01 (visión), M04 (motor Godot), M05 (lenguaje), y este M06.

## 6. Backups

- **Remoto:** GitHub es el respaldo principal (push por módulo).
- **Local:** zip mensual de la carpeta completa (excluyendo `.git` y `Library/.godot`) en un directorio fuera del repo; conservar 3 rotativos.
- **Pre-cambio grande:** `Obsoletos/` del protocolo (AGENTS §5).

## 7. Herramientas y reglas de límites

- Scripts del protocolo (`scripts/`) versionados y testimoniados (test_scripts.py obligatorio antes de usarlos en producción, AGENTS §21.9).
- Assets de audio/imagen < 100 MB totales → sin LFS. Si superan: activar Git LFS solo para extensiones binarias concretas (`*.wav`, `*.png` grandes) con política documentada.
- `/.godot/`, `Builds/`, `__pycache__/`, `*.pck` en .gitignore.**