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

## Decisiones de diseno aplicadas (Reflection-Beam-1.0, 2026-10-23, GO del fundador)

### H21 — Mapeo de las 9 metricas de M144 a sus fuentes (Opcion A para V1)

| # | Metrica M144 | Fuente actual | Capturada por M105? | Accion V1 |
|---|-------------|---------------|---------------------|-----------|
| 1 | Reviews (positivas/negativas + temas) | Plataformas (Steam) + M100 | NO | M97 (Steam API) o M100 (comunidad). No requiere M105. |
| 2 | Bugs abiertos por severidad | M102/M122 | NO | M102 (Bug Tracking) + M122 (Crash Reporting). No requiere M105. |
| 3 | Rendimiento (FPS p50/p95, crashes) | M105/M122 | PARCIAL | M105 emite session_duration (proxy de FPS). M122 captura crashes. Gap: FPS p50/p95 no se captura. Instrumentar en M105 o M122 (V2). |
| 4 | Economia (precios/inflacion/exploits) | M105 | PARCIAL | M105 emite eventos de transaccion (si se instrumenta). Actualmente NO se emiten. Gap: agregar track_economia() en M105 (V2). |
| 5 | Dificultad (abandono en X) | M105 | SI | M105 emite puzzle abandon (abandono >300s). Capturada. |
| 6 | Tutorial (completado) | M105 | SI | M105 emite track_tutorial_first_completed(). Capturada. |
| 7 | Onboarding (tiempo a primera accion) | M101 | NO | M101 (QA General) o M105 (instrumentar session_started + primera accion). Gap: agregar track_onboarding() en M105 (V2). |
| 8 | Retencion (D1/D7/D30) | M105 | PARCIAL | M105 emite session_started/session_ended. Retencion se calcula post-hoc (no en tiempo real). Gap: definir formula de retencion (sesiones por dia). |
| 9 | Contenido (engagement por isla) | M105 | PARCIAL | M105 emite enter_zone/exit_zone. Engagement por isla se deriva. Gap: agregar track_isla_visitada() en M105 (V2). |

Decision: Opcion A (minima) para V1. M105 captura 4 de 9 directamente (dificultad, tutorial, retencion parcial, contenido parcial). Las otras 5 se capturan por M97/M102/M122/M93/M101 (no requieren M105). Opcion B (completa) para V2: agregar 3 hooks en M105 (track_economia, track_onboarding, track_isla_visitada). Costo: ~2h.

## Notas Paquete-H (GO fundador 23oct 20:25, ratificado director 315)
- **PAQ-4 (H21)**: **Opcion A** — V1 con las 4 metricas que M105 captura; las otras 5 anotadas con modulo dueno (Reviews->M100/M97, Bugs->M102/M122, Rendimiento->M105/M122, Economia->M93, Onboarding->M101) y marca "V2". Actualiza la tabla 9-metricas (lineas 83-93) — ya documentada arriba. Cita canonica: "GO FUNDADOR 23oct 20:25: «sí, me gustan las recomendaciones» (via director 315)".
