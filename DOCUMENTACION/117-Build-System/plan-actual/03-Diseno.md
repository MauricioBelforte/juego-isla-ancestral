**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 117: Build System

## 1. Pipeline único de build
```
Git commit/tag
   → CI (M118) invoca: unity -batchmode -executeMethod BuildScript.Build tipo=... plataforma=... version=...
   → BuildScript.cs _(diseno heredado)_: prepara escenas, define symbols, versión, genera changelog
   → Tests (M112) + Validators (M109/M113) por tipo de build
   → Packaging (M96 + M116) + Manifest SHA-256
   → Firmado (Windows/macOS) en staging/release
   → Smoke test del artifact (60 s headless)
   → Sube artifacts + reporte → storage/releases
```

## 2. Tipos de build (configs)
| Tipo | Symbols | Debug Menu (M110) | Telemetría (M104) | PDB/símbolos | Firmado | Uso |
|------|---------|-------------------|-------------------|--------------|---------|-----|
| DEV | DEBUG | Sí | No | Sí | No | Dev/nightly |
| QA | DEBUG | Sí | Sí | Sí | No | QA/playtest |
| STAGING | RELEASE_CHANNEL | No | Sí (anónimo) | No | Sí | Validación final |
| RELEASE | RELEASE | No | Sí (anónimo) | No | Sí | M143 |

## 3. Versionado y changelog
| Elemento | Regla |
|----------|-------|
| Versión | `MAJOR.MINOR.PATCH` de tag git + `-build.<n>` del contador CI |
| Ejemplo | `1.0.0-build.142` en RC (M142); `1.0.0` en release final (M143) |
| Changelog | Generado de Conventional Commits desde el tag anterior |
| Metadata | Se escribe en `scripts/core/build_info.gd` al inicio del build |

## 4. Gates por tipo
| Tipo | Tests M112 | Validador M109 | Stress M113 (rápido) |
|------|-----------|----------------|----------------------|
| DEV | ∪ | no | no |
| QA | ∪ | sí | sí (save+chunk) |
| STAGING | ∪ | sí | sí (gate) |
| RELEASE | ∪ | sí | sí (gate completo, pre-run) |

## 5. Packaging por plataforma (M96/M116)
| Plataforma | Artifact |
|-----------|----------|
| Windows x64 | ZIP + instalador (M116) + manifest |
| macOS (Apple Silicon) | .app + zip firmado/notarizado |
| Linux (Proton check) | ZIP + notas de compatibilidad |
| Steam Deck | Mismo target Windows/Steam + DeckCheck (M96) |
- El manifiesto SHA-256 incluye todos los archivos y dependencias (RF10).

## 6. Firmado
| Plataforma | Herramienta | Cuándo |
|-----------|-------------|--------|
| Windows | `signtool.exe` + cert | staging y release |
| macOS | `notarytool` + staples | staging y release |
| Fallback | Sin firmar en dev/QA (documentado) | — |

## 7. Smoke test del artifact (RF11)
1. Descomprime/instala el artifact (no el runner).
2. Boot a menú principal (M89) < 60 s.
3. Nuevo juego con semilla fija, un día de juego headless.
4. Guarda + carga el save (M59).
5. Salida limpia (`Application.Quit` exit 0).
- Falla → bloquea el release (no sube artifacts).

## 8. Retención de artifacts
| Tipo | Retención |
|------|-----------|
| DEV | 7 días (rotación automática) |
| QA | 30 días |
| STAGING | 30 días |
| RELEASE | permanente (M143 requiere preservación) |

### Specs items degradados T194 (2026-10-26, Reflection-Beam-1.0)
- **L46 (firmado staging):** T-012 externo (cert CA + runner; dueño M116/infra).
- **L75 (regla commits en PR M118):** T-018 decisión M118 (dueño M118).
- **L82 (suite completa nightly):** T-020 testing/quality/dev-build/release-build SIN schedule (backup.yml y bug_metrics.yml sí lo tienen) (dueño M118).
- **L89 (gates stress rápido QA M113):** T-023 diseño; suite operativa dueño M113.
- **L90 (gates stress completo pre-release):** T-024 diseño; suite operativa dueño M113.
- **L96 (packaging por plataforma M96):** T-025 solo preset Windows verificado (dueño M96).
- **L98 (.app macOS + zip):** T-027 sin preset macOS (dueño M96).
- **L118 (acceso permisos por rol M118):** T-037 decisión GitHub envs (dueño M118).
- **L122 (firmado Windows signtool):** T-038: installer/code_signing.bat existe y pide CERT_PFX/CERT_PASSWORD; sin certificado y sin flag enable=false (HMAC firmar_artefacto() de cicd_manager.gd es integridad, no code signing) (dueño M116/infra).
- **L123 (firmado macOS notarytool + staple):** T-039 sin preset/runner (dueño M96/infra).
- **L141 (paso nueva partida semilla fija):** T-044 (dueño M118).
- **L143 (paso guardado + carga M59):** T-045 (dueño M118).
- **L144 (paso salida limpia exit 0):** T-046 (dueño M118).
- **L146 (smoke QA/staging/release):** T-048 (dueño M118).
- **L164 (gestión keystores/certificados centralizada):** T-050 sin store central (dueño M118/M96).