**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 117: Build System

## 1. Análisis del dominio
Proyecto Unity single-player con CI (M118), test automático (M112) y gates de calidad (M109/M113/M151). La cadena de builds es el corazón de la entrega: define qué probamos, cómo se versiona y qué se publica. Los 15 puntos del maestro cubren: automatización, 4 tipos de build, versionado, changelog, tests, validadores, packaging, artifacts, firmado, dependencias y smoke test.

## 2. Alternativas consideradas y decisiones

### D1: Motor de automatización
- **A1 (scripts Unity Editor + CI por separado)**: duplicación de lógica.
- **A2 (BuildScript.cs en Assets/Editor + CI llama Unity CLI)**: un solo lugar de verdad; CI (M118) solo orquesta.
- **Decisión:** **A2** — `BuildScript.cs` (Assets/Editor) con `-executeMethod` para cada tipo; CI de M118 ejecuta con parámetros (tipo, plataforma, versión).

### D2: Versionado
- **A1 (versión manual)**: errores humanos, drift.
- **A2 (semver de Git tag + build number automático)**: el número de versión del build se deriva del tag/commit (M142/M143); el changelog se genera del historial.
- **Decisión:** **A2** — formato `MAJOR.MINOR.PATCH(-pre)+build.abc` donde `abc` = contador de CI; la definición de release sigue las reglas de M142.

### D3: tipos de build
- **A1 (un solo build)**: no permite diferencias dev/QA/staging/release.
- **A2 (4 configs del mismo pipeline)**: mismo script, flags por tipo (symbols, debug menu, telemetría, firmado).
- **Decisión:** **A2** — tabla de configs: dev (Debug+menu+PDB), QA (Debug+telemetría+PDB, sin editor), staging (igual a release pero con logs), release (release, firmado, sin debug menu, telemetría anónima on).

### D4: Smoke test
- **A1 (sin smoke test)**: riesgo de build "no arranca" recién en QA manual.
- **A2 (automatizado 60 s headless)**: boot + play + exit 0 (M112/M113) en el mismo runner.
- **Decisión:** **A2** — el smoke corre en el artifact (no solo en el runner) para validar packaging real: inicia, carga mundo de prueba, 60 s de gameplay simulada, salida limpia (exit 0).

### D5: firmado y dependencias
- **A1 (firmado solo al final en M143)**: costoso de arreglar tarde.
- **A2 (firmado en cada release candidate)**: prueba temprana en staging; manifiesto de checksums en cada release.
- **Decisión:** **A2** — firma (Windows signtool + Apple notarize) en staging y release; manifest SHA-256 de cada archivo en todos los builds release.

## 3. Riesgos y mitigaciones
| Riesgo | Prob | Impacto | Mitigación |
|--------|------|---------|------------|
| Build determinístico roto | Media | Alta | Versionado encriptado en git + lock de dependencias |
| Artifact con dependencia faltante | Media | Alta | Manifest validado (RF10) en release |
| Certificado caducado | Baja | Media | Alerta temprana en CI (firmado incluido desde staging) |
| Build lento bloqueando dev | Alta | Media | Nightlies dev; release solo con gate verde |
| Changelog incompleto | Media | Baja | Regla Conventional Commits en PR (M118) |

## 4. Plan de ejecución (fases)
| Fase | Contenido |
|------|-----------|
| **F1 BuildScript** | Script único con 4 configs + parámetros |
| **F2 Versionado** | semver + build + changelog |
| **F3 Gates** | Tests (M112) + validadores (M109/M113) por tipo |
| **F4 Packaging** | Por plataforma (M96) + instalador (M116) + manifest |
| **F5 Release** | Firmado + smoke + artifacts + retención |

## 5. Métricas de éxito
1. Build dev < 30 min, release < 60 min (incremental).
2. 0 builds "no arranca" en QA manual (smoke siempre).
3. Versionado sin drift: tag ↔ build manifest coinciden.
4. Changelog 100% automático (sin entradas manuales).
5. Manifest de dependencias completo (SHA-256) en releases.
6. Smoke test de artifact (no de runner) pasa en 100% de releases.
7. Retención de artifacts según política (dev 7d, staging 30d, release permanente).

## 6. Notas para integración
- Consume M112/M113/M109 como gates; alimenta M118 (CI), M116 (instalador), M142/M143 (release) y M96 (targets).