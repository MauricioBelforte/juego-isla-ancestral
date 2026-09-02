**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code
**Última actualización:** 2026-09-01

# SESIÓN DE HITO — M139 Pre-Alpha (definida + plantilla)

## Contexto del hito

- **Objetivo:** Aurora completa, NPC con rutinas, economía AO+tiendas, construcción, Templo de Brisa, Gran Vapor a Coral, audio global, save v3 + menú, métricas.
- **Módulos esperados operativos:** la mayoría de la base de producción (M08-M70) sin polish artístico.
- **Áreas del QA-CHECKLIST:** **regresión completa de TODAS las áreas** (01-27) + sesión exploratoria.

## Criterios de entrada

1. Build M139 etiquetada con smoke aprobado.
2. Suite M112 en verde (CI).
3. M138 con su DoD de QA cumplido.

## Sesión a ejecutar

1. **Smoke:** QA-SMOKE.md.
2. **Regresión por áreas:** QA-CHECKLIST completo (01-27) dividido en 2-3 sesiones numeradas (máx 2 h por sesión).
3. **Exploratorio (2 × 1 h):** jugar libre 1 h con semilla 42 y 1 h con semilla aleatoria; probar todos los sistemas de pase en la frontera (viajar, dormir, votar/fiesta si existe).
4. **M114 (optativa):** si el equipo define playtesting en este hito → reglas de QA-PLAYTEST-BRIDGE.md (EA.1/EA.2).

## Criterios de salida

- [ ] **0 bugs críticos/altos abiertos** (M102).
- [ ] Suite M112 en verde sobre la misma build.
- [ ] 100% de áreas del QA-CHECKLIST cubiertas con resultado (sin ítems sin probar de áreas habilitadas).
- [ ] Sesión documentada con plantilla + firma.

## Plantilla de la sesión

```markdown
**Sesión QA #NN — Hito M139 (Pre-Alpha)**
**Fecha:** YYYY-MM-DD HH:MM
**Build:** {commit} — 0.3.0-pre
**Tester:** {Agente/Modelo/Plataforma}
**Semilla del mundo (M10):** 42 + aleatoria
**Versión Godot:** 4.7.2
**Áreas cubiertas:** 01-27 (subsesión NN de NN)
**Smoke test:** Aprobado / Rechazado

## Resultados por ítem (tabla QA-SESSION.md estándar, todas las áreas)
## Bugs encontrados
| Issue | Severidad | Categoría | Reproducible | Estado | Dueño |
|-------|-----------|-----------|--------------|--------|-------|
| ... | ... | ... | ... | ... | ... |

## Conversión a M112
| Issue | Test creado | Archivo | Estado |
|-------|-------------|---------|--------|

## Conclusión
- DoD de QA del hito: CUMPLE / NO CUMPLE (0 críticos/altos requeridos)
- Bloqueos: ...
- Métricas: ...
**Firma:** {Modelo} / {Plataforma} — {fecha}
```
