**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 144: Después del Lanzamiento

## 1. Tablero post-lanzamiento (RF1 — 9 métricas)
| # | Métrica | Fuente | Frecuencia |
|---|---------|--------|-----------|
| 1 | Reviews (positivas/negativas + temas) | Plataformas + M100 | Semanal |
| 2 | Bugs abiertos por severidad | M102/M122 | Semanal |
| 3 | Rendimiento (FPS p50/p95, crashes) | M105/M122 | Semanal |
| 4 | Economía (precios/inflación/exploits) | M105 | Semanal |
| 5 | Dificultad (abandono en X) | M105 | Semanal |
| 6 | Tutorial (completado, salto) | M105 | Semanal |
| 7 | Onboarding (conversión 30 min) | M105 | Semanal |
| 8 | Retención (D1/D7/D30) | M105 | Semanal |
| 9 | Contenido (más jugado/ignorado) | M105 | Mensual |

## 2. Flujo de parches (RF3)
```
D1-D7:  hotfix P0/P1 (< 72 h) — solo fixes, sin features
Mensual: patch con balance + mejoras + contenido-lite (M95/M120 gates)
Changelog público: siempre (M100) + nota en Steam (M97)
CI: parches pasan gates de M117 (mismo pipeline release)
```

## 3. Priorización semanal (RF2)
| Prioridad | Ejemplo | Decisión |
|-----------|---------|----------|
| P0 | crash, save corrupto, exploit | hotfix < 24-72 h |
| P1 | bloqueo de progresión | hotfix < 72 h |
| P2 | balance/dificultad | patch mensual |
| P3 | mejoras/UX | backlog con evidencia |
- El triaje semanal usa las reglas de M102 (reproducibilidad, logs).

## 4. GATE de contenido nuevo (RF5 — M120)
| Criterio | Umbral |
|----------|--------|
| Base activa (MAU) | ≥ umbral de M120 |
| Reviews | ≥ 80% positivas (rolling 30 días) |
| Retención D30 | ≥ umbral de M120 |
| Presupuesto V2 | comprometido en roadmap (M136) |
- Si pasa → feature DLC/expansión (M120) con su propio plan.

## 5. Mejora de contenido (RF4/RF9)
- Todo contenido < 10% de uso (M105) entra al proceso:
  1. Diagnóstico (telemetría + soporte).
  2. Decisión: mejorar (con target medible en 3 meses) o archivar (nota pública).
  3. Implementación con patch mensual.

## 6. Backups y soporte (RF6/RF7)
- Backups: RPO 24 h para servicios (M107); saves del jugador responsabilidad de M59 (nube).
- Soporte: SLA de primera respuesta ≤ 72 h; base de conocimientos; canal de sugerencias (M100); escalation a P0/P1 del juego.
- Información del soporte: plantillas de respuestas revisadas por M126 (legal).

## 7. Documentación viva (RF8)
| Documento | Actualización |
|-----------|---------------|
| Notas de parche (Steam/página) | En cada parche |
| FAQ / base de conocimientos | Continuo |
| Wiki del juego (M100) | Continuo con moderación |
| Roadmap público (M136) | Trimestral |

## 8. Cadencias y responsables
| Rol | Actividad |
|-----|-----------|
| Dev | Hotfixes < 72 h, patch mensual |
| CM (M100) | Reviews, changelog, FAQ, canal |
| QA (M114) | Regresión de cada parche |
| DATA (M105) | Tablero semanal + reportes |
| OPS (M143) | Backups, monitorización, soporte |

## 9. Qué NO se hace
- No prometer fechas de contenido fuera de roadmap (M136).
- No abrir early-access post-lanzamiento.
- No parches con features sin gates (M117/M142).
- No ignorar reviews negativas: respuesta < 48 h (M100).