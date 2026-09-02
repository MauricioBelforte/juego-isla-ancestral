**Modelo:** deepseek-v4-flash-vision-exp
**Plataforma:** Kilo Code
**Última actualización:** 2026-09-01

# QA-PLAYTEST-BRIDGE.md — Coordinación con M114 (Playtesting) (Módulo 101)

> **Propósito:** el puente entre QA interna (módulo 101) y playtesting externo (módulo 114). Define qué sesiones son de cada tipo y cómo fluyen los hallazgos entre ambos.

## 1. División de roles

| Aspecto | QA interna (M101) | Playtesting (M114) |
|---|---|---|
| Quién | Agentes + tester interno | Jugadores externos |
| Qué busca | Bugs, regresiones, errores técnicos | Diversión, claridad, balance, frustración |
| Canal de hallazgos | Issues M102 con plantilla técnica | Cuestionario/captura de sesión de M114 |
| Resultado | DoD de QA por hito | Señales de diseño + bugs reportados |

## 2. Reglas del puente

### EA.1 — Build saneada (obligatoria)
Una sesión de **M114 nunca arranca sobre una build que falló el smoke de M101** (QA-SMOKE.md). El flujo es: QA entregue la build con smoke aprobado → recién entonces M114 recluta jugadores.

### EA.2 — Re-chequeo de hallazgos (obligatoria)
Los hallazgos de M114 **sin repro técnico** (ej: "esto me pareció confuso") se re-checkean en la siguiente sesión de QA interna como ítem del QA-CHECKLIST (se agrega al área correspondiente con prefijo `PT-` y nota de origen M114).

### EA.3 — Flujo de hallazgos técnicos de M114
Todo hallazgo técnico de M114 (crash, bug reproducible, texto roto) se convierte en **issue M102** con:
- ítem de QA-CHECKLISTID referenciado (si existe),
- severidad según M102,
- **sin** pasos técnicos de QA: los reproduce la QA interna (reproducción técnica).

### EA.4 — Señales de diseño → ítems de área
Las señales de diseño de M114 (ej: "el primer tutorial no explica el inventario") pasan a ítems del QA-CHECKLIST (área 25 Tutorial): QA interno verifica el ítem explícito en la siguiente sesión.

### EA.5 — Momentos del ciclo de hito
```
Build smoke OK (M101) → sesiones M114 (si el hito define playtesting)
  → hallazgos M114 → issues M102 técnicos + señales → QA-CHECKLIST actualizado
  → regresión M101 del área tocada → DoD de QA del hito (M101)
```

## 3. Qué NO toca el puente

- No modifica el diseño del módulo M114 (cuestionarios, métricas de diversión): solo consume sus salidas.
- No reemplaza los criterios de entrada/salida del hito: los define M101 en `sesiones/QA-HITO-M1XX.md` y M114 los respeta (enlace del ítem "Criterios de entrada/salida de M114" del checklist).
- M101 entrega **builds saneadas**; M114 entrega **hallazgos priorizados**.
