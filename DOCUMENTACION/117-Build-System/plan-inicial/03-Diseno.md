**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 117: Build System

## 1. Pipeline único de build
```
Git commit/tag
   → CI (M118) invoca: unity -batchmode -executeMethod BuildScript.Build tipo=... plataforma=... version=...
   → BuildScript.cs: prepara escenas, define symbols, versión, genera changelog
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
| Metadata | Se escribe en `BuildInfo.cs` al inicio del build |

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

## 9. Prohibiciones técnicas
1. El build release NO incluye: editores (M109), debug menu (M110), stress framework (M113).
2. No se escribe versión a mano: siempre del tag/CI.
3. No se sube artifact sin smoke test verde.
4. No se firma con certificado de prueba en release.