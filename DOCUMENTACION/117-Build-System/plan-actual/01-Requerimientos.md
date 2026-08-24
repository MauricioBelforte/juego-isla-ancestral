**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 117: Build System

## 1. Problema
Sin un **build system automatizado**, cada build de desarrollo/QA/staging/release es manual, propenso a errores (versión equivocada, tests sin correr, artifact incompleto) y no reproducible. Para el proyecto (Unity + CI de M118) se necesita una cadena de builds definida: tipos de build, versionado, changelog, tests, validadores, packaging, artifacts, firmado, dependencias y smoke test.

## 2. Objetivo del módulo
Documentar y diseñar el **sistema de builds** del proyecto: automatización completa (dev/build semanal, QA, staging, release), versionado semver-coherente con M142/M143, changelog generado, ejecución de tests (M112) y validadores (M109/M151), packaging por plataforma (M96), subida y guardado de artifacts, firmado de ejecutables y smoke test automático de cada build.

## 3. Alcance (derivado del plan maestro: sección 116 "BUILD SYSTEM")
1. **Automatizar builds** — pipeline único (Unity CLI + CI de M118).
2. **Builds de desarrollo** — nightly con PDB/símbolos y Debug Menu (M110).
3. **Builds de QA** — build de testing con logging y Telemetría (M104/105).
4. **Builds staging** — réplica de release (sin debug menu) para validación final.
5. **Builds release** — build final firmado con versionado (M143).
6. **Número de versión** — semver + build metadata, coherente con M142.
7. **Changelog** — generado automáticamente (Conventional Commits).
8. **Ejecutar tests** — test suite (M112) en cada build de CI.
9. **Ejecutar validadores** — DataValidator (M109) y stress (M113) en gates.
10. **Packaging** — Windows/macOS/Deck (M96): zip/instalador (M116), estructura correcta.
11. **Subir artifacts** — a storage (GitHub Releases o similar) automático.
12. **Guardar builds** — retención y rotación de builds antiguos.
13. **Firmar ejecutables** — código de firma (Windows) y notarización (macOS).
14. **Validar dependencias** — checksum/lista de archivos del build.
15. **Smoke test** — arranque y 60 s de gameplay headless por build.

## 4. Requisitos funcionales (RF)
| RF | Descripción |
|----|-------------|
| RF1 | Pipeline único de build (script + CI M118) |
| RF2 | 4 tipos de build (dev, QA, staging, release) con configs distintas |
| RF3 | Versionado semver automático con build number |
| RF4 | Changelog generado por commits |
| RF5 | Tests automáticos en todo build de PR/nightly/release |
| RF6 | Validadores (DataValidator + gates) en release |
| RF7 | Packaging por plataforma target (M96) |
| RF8 | Artifacts subidos y retenidos con política |
| RF9 | Firmado (Windows signtool + apple notarize) |
| RF10 | Validación de dependencias (checksum manifest) |
| RF11 | Smoke test automático (boot + play 60 s + exit 0) |
| RF12 | Reproducibilidad: un commit → un build determinístico |

## 5. Criterios de aceptación (DoD del módulo)
1. Los 15 puntos del plan maestro están documentados con su diseño.
2. Pipeline único ejecutable con un comando (dev/QA/staging/release).
3. Versionado semver automático y coherente (M142 M143).
4. Changelog generado de Conventional Commits.
5. Tests y validadores corren en todas las etapas (M112).
6. Packaging por plataforma verificado (Windows/macOS/Deck).
7. Artifacts en storage con retención definida.
8. Firmado aplicado en release (Windows + macOS).
9. Manifest de dependencias validado en release.
10. Smoke test pasa (0 crashes) en todos los builds de release.

## 6. Restricciones
- **Aplican:** M112 (tests), M113 (stress gates), M109 (validators), M110 (debug menu — solo dev/QA), M116 (instalador), M118 (CI/CD), M96 (plataformas), M142/M143 (release).
- Los builds de release NO incluyen Debug Menu ni herramientas de editor (M109/M110).
- Tiempo máximo de build release: 60 min (objetivo con incremental).

---

## Módulos Relacionados

> **Referencia rápida para codificación.** Al trabajar en este módulo, consulta la documentación de estos módulos relacionados.

### Depende de (necesito su documentación)

| Módulo | Qué aporta a este módulo |
|--------|--------------------------|
| **M116** — Instalador | Build system sobre instalador |

### Usado por (otros módulos que referencian este)

| Módulo | Qué usa de este módulo |
|--------|------------------------|
| **M083** — Licencias de Software | Licencias en build |
| **M118** — CI/CD | CI/CD |
| **M119** — Actualizaciones | Actualizaciones |
| **M123** — Modding | Modding |

### Relacionados laterales (mismo dominio)

| Módulo | Relación |
|--------|----------|
| **M083** — Licencias de Software | Este módulo lo necesita |
| **M116** — Instalador | Depende de este módulo |
| **M118** — CI/CD | Este módulo lo necesita |
| **M119** — Actualizaciones | Este módulo lo necesita |
| **M123** — Modding | Este módulo lo necesita |

