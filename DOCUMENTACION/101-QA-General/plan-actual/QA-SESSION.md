**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code
**Última actualización:** 2026-09-01

# QA-SESSION.md — Plantilla de Sesión de QA (Módulo 101)

> **Uso:** una copia de esta plantilla por sesión. Se guarda en `sesiones/{M1XX-NOMBRE}/sesion-{NN}-{fecha}.md`. La **fuente de verdad de bugs es M102 (GitHub Issues)**: esta plantilla solo RECAPITULA los issues encontrados, no los reemplaza.

## Plantilla (reemplazar los campos marcados)

```markdown
**Sesión QA #NN — Hito M1XX**
**Fecha:** YYYY-MM-DD HH:MM
**Build:** {commit hash} — {versión semver (ej: 0.1.0-dev)}
**Tester:** {Agente (Modelo/Plataforma) | Humano (nombre)}
**Semilla del mundo (M10):** {semilla usada}
**Versión Godot:** 4.x.y
**Áreas cubiertas:** {NN Área — nombre; ...}
**Smoke test (QA-SMOKE.md):** Aprobado / Rechazado (si Rechazado, la sesión termina aquí)

## Resultados por ítem

| ID | Área | Resultado | Bug (issue M102) | Notas |
|----|------|-----------|------------------|-------|
| {NN.MM} | {Nombre} | [x] / [ ] / [?] | {#issue o —} | {nota breve} |
| ... | ... | ... | ... | ... |

## Bugs encontrados

| Issue M102 | Severidad | Categoría | Reproducible | Estado | Dueño |
|------------|-----------|-----------|--------------|--------|-------|
| #{n} | {crítica/alta/media/baja} | {categoría M102} | Sí (n/n intentos) / NO REPRODUCIDO | Abierto / En fix / Cerrado | {agente dueño} |

## Conversión a M112 (RF10)

| Issue | Convertido a test | Archivo (test M112) | Estado |
|-------|-------------------|---------------------|--------|
| #{n} | Sí / No | res://tests/... | pendiente/creado |

## Evidencias

- Adjuntadas en los issues (screenshot, extracto M103, diagnóstico M110 RF20, crash ID M122 si aplica).

## Conclusión

- **DoD de QA del hito:** CUMPLE / NO CUMPLE (según QA-RELEASE-CRITERIA.md)
- **Bloqueos para el siguiente hito:** {lista de issues bloqueantes}
- **Métricas (RF11):** {bugs totales/abiertos/cerrados por severidad; top áreas; tasa de regresión; % de ítems checklist verificados}

**Firma:** {Modelo} / {Plataforma} — {fecha}
```

## Campos obligatorios (no omitir)

1. **Build identificable:** commit + versión. Sin build identificable, la sesión NO es válida.
2. **Semilla:** la semilla concreta usada (determinismo, RF de 01-Requerimientos).
3. **Resultado por ítem:** usar los IDs de `QA-CHECKLIST.md` (formato `NN.MM`).
4. **Bugs:** siempre con referencia al issue M102 — nunca solo texto libre.
5. **Conclusión:** DoD CUMPLE/NO CUMPLE + bloques + métricas + firma.

## Duración esperada

- **Smoke:** < 15 min (QA-SMOKE.md).
- **Sesión de área (1 área):** < 2 horas.
- **Sesión de hito (regresión completa):** según el plan del hito (M139+), con pausas; se puede dividir en 2-3 sesiones numeradas.
