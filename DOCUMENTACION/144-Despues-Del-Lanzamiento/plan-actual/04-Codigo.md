**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 144: Después del Lanzamiento

## 1. Archivos involucrados

### 1.1 Nuevos (proyección post-lanzamiento)
| Archivo | Propósito |
|---------|-----------|
| `scripts/postlaunch/pipeline_patch.ps1` | Orquesta hotfix/patch (mismo BuildScript M117) |
| `scripts/postlaunch/postlaunch_report.py` | Tablero semanal (9 métricas desde M105/M102) |
| `docs/postlaunch/runbook-d1-d30.md` | Runbook de la ventana caliente (D1-D30) |
| `docs/postlaunch/plantillas/plantilla-changelog.md` | Plantilla de changelog público |

### 1.2 Modificados (proyección)
| Archivo | Cambio |
|---------|--------|
| `ComunidadManager` (M100) | Notas de parche públicas + responderse reviews |
| `DataAnalytics` (M105) | Exports de las 9 métricas a dashboard |
| `BugPipeline` (M102) | Label post-launch y severidad D1-D30 |
| `RoadmapManager` (M136) | Reportes mensuales de post-lanzamiento |

## 2. Funciones clave
```python
# postlaunch_report.py
def generar_tablero(semana): -> Tablero
  # reviews (plataformas), bugs (M102), perf (M122),
  # economía, dificultad, tutorial, onboarding, retención, contenido (M105)
def marcar_contenido_ignorado(umbral=0.10): -> list
  # contenido con uso < 10% → proceso mejorar/archivar
# pipeline_patch.ps1
Invoke BuildScript tipo=HOTFIX|PATCH version=...   # M117
Invoke changelog --desde ultimo_tag               # Conventional Commits
```

## 3. Datos / config
| Dato | Ubicación | Sistema |
|------|-----------|---------|
| Métricas semanales | Dashboard export (JSON) | M105 |
| Bugs por severidad | Issue tracker (M102) | M102 |
| Reviews | Plataformas (Steam/EGS) + M100 | M100 |
| Changelogs | Git tags + docs | M117 |
| Plantillas de soporte | docs/soporte | M121 |

## 4. Tests / QA (M114 — post-launch)
| Prueba | Criterio |
|--------|----------|
| Regresión por parche | Suite M112 completa en cada patch |
| Hotfix sin features | Gate: diff solo de fixes (M142) |
| Cambio de balance | Simulación de economía/dificultad (M93/M113) |
| Changelog | Completitud frente al diff (M117) |

## 5. CI / gates
- Hotfix < 72 h → pipeline acortado pero con smoke test (M117).
- Patch mensual → pipeline completo (M117) con gates de M113.
- Reporte del tablero → artifact cada lunes (M104).

## 6. Notas de integración
- Reutiliza por completo la cadena de M117/M142/M143; el post-lanzamiento es "M144 operando esa cadena con cadencia".
- Los datos de M105 y reviews de M100 son la materia prima; M102 el tracker.
- El GATE de contenido (M120) se evalúa aquí con evidencia del tablero.