**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code
**Última actualización:** 2026-09-01

# SESIÓN DE HITO — M137 Prototipo (definida + plantilla)

> Este archivo define la sesión de QA del hito M137 (Prototipo) y la plantilla a completar cuando exista el build M137. Criterios tomados de 03-Diseno.md §2.5 y de `QA-RELEASE-CRITERIA.md`.

## Contexto del hito

- **Objetivo:** núcleo jugable mínimo divertido — mundos voxel, movimiento, herramienta, inventario mínimo.
- **Módulos esperados operativos:** M08, M09, M10, M11, M12, M13, M14 (+ M15/M16 parciales).
- **Áreas del QA-CHECKLIST a cubrir:** 01, 02, 03, 04, 05, 06, 07 (+ 08 si crafting mínimo existe).

## Criterios de entrada (para arrancar la sesión)

1. Existe una build M137 etiquetada (commit + versión).
2. El smoke test (QA-SMOKE.md) pasó sobre esa build exacta.
3. La suite M112 (tests del core) está en verde.

## Sesión a ejecutar

1. **Smoke:** QA-SMOKE.md (7 pasos, < 15 min).
2. **Guiado (áreas 01-07):** recorrer el QA-CHECKLIST de cada área; mínimo ítems obligatorios: 01.01-01.06, 03.01-03.04, 04.01-04.02, 05.01-05.05, 06.01-06.06, 07.01-07.03.
3. **Exploratorio (30-45 min):** libre por el mundo con la semilla 42 — el bucle "recoger→construir→recoger" por 20 minutos sin que nada rompa.

## Criterios de salida (DoD de hito, resumen ejecutivo)

- [ ] **Sin bugs críticos** abiertos de áreas 01-07 (M102).
- [ ] Loop básico jugable: recolecté, crafteé (si existe), construí 1 estructura, guardé y cargué.
- [ ] Smoke aprobado + suite M112 en verde sobre la misma build.
- [ ] Sesión documentada con plantilla QA-SESSION.md + firma.
- [ ] Flujos estables (§16 AGENTS.md) sin regresión.

## Plantilla de la sesión (copiar a `sesiones/M137-PROTOTIPO/sesion-01-{fecha}.md`)

```markdown
**Sesión QA #01 — Hito M137 (Prototipo)**
**Fecha:** YYYY-MM-DD HH:MM
**Build:** {commit} — 0.1.0-dev
**Tester:** {Agente/Modelo/Plataforma | Humano}
**Semilla del mundo (M10):** 42
**Versión Godot:** 4.7.2
**Áreas cubiertas:** 01 Mundo voxel, 02 Generación, 03 Jugador, 04 Cámara, 05 Herramientas, 06 Inventario, 07 Recursos
**Smoke test:** Aprobado / Rechazado

## Resultados por ítem
| ID | Área | Resultado | Bug (issue M102) | Notas |
|----|------|-----------|------------------|-------|
| 01.01 | Mundo | [x] | — | sin errores en consola |
| ... | ... | ... | ... | ... |

## Bugs encontrados
| Issue | Severidad | Categoría | Reproducible | Estado |
|-------|-----------|-----------|--------------|--------|

## Conclusión
- DoD de QA del hito: CUMPLE / NO CUMPLE
- Bloqueos: ...
- Métricas: ...
**Firma:** {Modelo} / {Plataforma} — {fecha}
```
