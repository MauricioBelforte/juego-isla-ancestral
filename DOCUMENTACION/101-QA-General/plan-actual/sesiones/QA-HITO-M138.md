**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code
**Última actualización:** 2026-09-01

# SESIÓN DE HITO — M138 Vertical Slice (definida + plantilla)

## Contexto del hito

- **Objetivo:** una experiencia pequeña pulida de inicio a fin (esquina de Aurora, Finneas, una misión, un puzzle, audio, UI, autosave).
- **Módulos esperados operativos:** M137 + M16, M19, M20, M21, M22, M24, M25, M26 (parciales), M59, M89/M53 (menús mínimos).
- **Áreas del QA-CHECKLIST a cubrir:** 01-11 (áreas 01-06 completas del core + 08 crafting, 10 NPC, 11 diálogos, 12 templos/puzzles de la slice, 14 tiempo, 24 anti-softlock/guardado).

## Criterios de entrada

1. Build M138 etiquetada con smoke aprobado.
2. Suite M112 en verde.
3. M137 (hito anterior) con su DoD de QA cumplido.

## Sesión a ejecutar

1. **Smoke:** QA-SMOKE.md.
2. **E2E de la slice (obligatorio, 1-2 h):** la experiencia completa de la slice de inicio a fin, sin usar debug menu (solo en el último repaso).
3. **Guiado:** áreas 01-06, 08, 10, 11, 12 (solo la slice), 14, 24.
4. **Regresión core:** áreas modificadas desde M137 (QA-REGRESION.md).

## Criterios de salida

- [ ] La slice se completa de inicio a fin **sin workarounds** (sin teletransporte para avanzar).
- [ ] 0 bugs críticos; altos con dueño y fecha.
- [ ] El guardado/carga durante la slice no pierde el progreso (área 24).
- [ ] Sesión documentada (plantilla + firma); suite M112 en verde.

## Plantilla de la sesión

```markdown
**Sesión QA #NN — Hito M138 (Vertical Slice)**
**Fecha:** YYYY-MM-DD HH:MM
**Build:** {commit} — 0.2.0-dev
**Tester:** {Agente/Modelo/Plataforma}
**Semilla del mundo (M10):** 42
**Versión Godot:** 4.7.2
**Áreas cubiertas:** 01-06, 08, 10, 11, 12, 14, 24
**Smoke test:** Aprobado / Rechazado

## Resultados por ítem
| ID | Área | Resultado | Bug (issue M102) | Notas |
|----|------|-----------|------------------|-------|
| ... | ... | ... | ... | ... |

## Recorrido E2E de la slice
| Paso de la slice | Resultado | Notas |
|------------------|-----------|-------|
| 1. Arranque/Aurora | [x] | ... |
| 2. Finneas | [x] | ... |
| ... | ... | ... |

## Bugs encontrados | Issue | Severidad | Categoría | Reproducible | Estado |

## Conclusión
- DoD de QA del hito: CUMPLE / NO CUMPLE
- Bloqueos: ...
- Métricas: ...
**Firma:** {Modelo} / {Plataforma} — {fecha}
```
