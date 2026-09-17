# Isla Ancestral — Post-Lanzamiento Checklist Operacional

_Generado automaticamente por `tools/postlaunch/generate_postlaunch_checklist.py` el 2026-09-02T19:01:54.313309_

## Politicas generales

- **reportes_automaticos**: data-driven, sin redaccion manual
- **frecuencia_minima_diaria**: salud_general, bugs, rendimiento, economia, soporte, comunidad
- **frecuencia_minima_semanal**: retencion, versionado
- **alertas_inmediatas**: crash, review_bombing, exploit_economia

## Checks por categoria

### Salud General del Juego

- **Frecuencia minima**: diaria

| ID | Titulo | Dueno | Frecuencia | SLA / Umbral | Metricas |
|----|--------|-------|------------|--------------|----------|
| `rev_001` | Monitoreo de reviews en Steam/EGS/GOG | M97 marketing | [DIARIA] | 24h respuesta | rating_promedio, rating_ultima_semana, numero_reviews |
| `rev_002` | Clasificacion automatica de reviews por tema | M101 QA | [DIARIA] | NLP sobre texto de review | - |
| `rev_003` | Respuesta a reviews < 48 h | M100 community | [DIARIA] | 48h | - |
| `rev_004` | Deteccion de review bombing | M106 security | [REAL-TIME] | spike detection sobre rating/tiempo | - |

### Triage de Bugs Post-Lanzamiento

- **Frecuencia minima**: diaria

| ID | Titulo | Dueno | Frecuencia | SLA / Umbral | Metricas |
|----|--------|-------|------------|--------------|----------|
| `bug_001` | Triage continuo (P0-P3) | M102 crash | [DIARIA] | - | abiertos_P0, abiertos_P1, cerrados_semana |
| `bug_002` | Regresion por parche | M112 testing | [-] | comparar tests antes/despues de cada release | - |
| `bug_003` | Label post-launch en el tracker | M143 monitor | [-] | - | - |
| `bug_004` | Informe semanal de bugs abiertos/cerrados | M143 monitor | [SEMANAL] | - | - |

### Rendimiento en Produccion

- **Frecuencia minima**: diaria

| ID | Titulo | Dueno | Frecuencia | SLA / Umbral | Metricas |
|----|--------|-------|------------|--------------|----------|
| `perf_001` | Telemetria de FPS p50/p95 | M105 telemetry | [DIARIA] | - | fps_p50, fps_p95, fps_p99 |
| `perf_002` | Monitoreo de crashes (1k sesiones) | M122 crash | [-] | <0.1% crash rate | - |
| `perf_003` | Comparacion de perf entre parches | M96 plataformas | [-] | - | - |
| `perf_004` | Reporte de memoria en sesiones largas | M62 memoria | [-] | <2GB tras 4h de sesion | - |

### Economia en Produccion

- **Frecuencia minima**: diaria

| ID | Titulo | Dueno | Frecuencia | SLA / Umbral | Metricas |
|----|--------|-------|------------|--------------|----------|
| `eco_001` | Inflacion / deflacion detectable | M38 economia | [DIARIA] | variacion <5% semanal | - |
| `eco_002` | Distribucion de moneda entre jugadores | M38 economia | [SEMANAL] | - | - |
| `eco_003` | Detectar exploits de duplicacion | M106 security | [-] | - | - |

### Retencion Voluntaria (sin FOMO)

- **Frecuencia minima**: semanal

| ID | Titulo | Dueno | Frecuencia | SLA / Umbral | Metricas |
|----|--------|-------|------------|--------------|----------|
| `ret_001` | Dias promedio entre sesiones (libre) | M94 retencion | [SEMANAL] | - | - |
| `ret_002` | Sesiones sin objetivo obligatorio cumplido | M94 retencion | [SEMANAL] | >80% sesiones son libres | - |
| `ret_003` | Tasa de retorno voluntario (no forzado) | M94 retencion | [SEMANAL] | - | - |

### Soporte al Jugador

- **Frecuencia minima**: diaria

| ID | Titulo | Dueno | Frecuencia | SLA / Umbral | Metricas |
|----|--------|-------|------------|--------------|----------|
| `sup_001` | Tickets de soporte < 24 h | M100 community | [-] | 24h primera respuesta | - |
| `sup_002` | FAQ actualizada con problemas frecuentes | M100 community | [SEMANAL] | - | - |
| `sup_003` | Discord/forum con moderadores activos | M100 community | [-] | - | - |

### Gestion de Comunidad

- **Frecuencia minima**: diaria

| ID | Titulo | Dueno | Frecuencia | SLA / Umbral | Metricas |
|----|--------|-------|------------|--------------|----------|
| `com_001` | Anuncios oficiales de parches | M100 community | [-] | - | - |
| `com_002` | Eventos tematicos mensuales (M74) | M100 community | [-] | - | - |
| `com_003` | Destacar creations de la comunidad (M124) | M100 community | [-] | - | - |

### Versionado y Parches

- **Frecuencia minima**: por_parche

| ID | Titulo | Dueno | Frecuencia | SLA / Umbral | Metricas |
|----|--------|-------|------------|--------------|----------|
| `ver_001` | Politica de versionado semver | M118 CI-CD | [POR EVENTO] | - | - |
| `ver_002` | CHANGELOG.md generado automaticamente | M118 CI-CD | [-] | - | - |
| `ver_003` | Hotfix path < 24 h para criticos | M143 monitor | [-] | 24h P0 | - |

### Pipeline de Hotfix

- **Frecuencia minima**: por_bug

| ID | Titulo | Dueno | Frecuencia | SLA / Umbral | Metricas |
|----|--------|-------|------------|--------------|----------|
| `fix_001` | Criterio de escalamiento a hotfix (P0) | M122 crash | [-] | - | - |
| `fix_002` | Branch hotfix aislado de main | M118 CI-CD | [-] | - | - |
| `fix_003` | Test de regresion obligatorio antes de merge | M112 testing | [-] | - | - |

