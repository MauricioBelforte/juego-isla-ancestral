# Log 21 — Creación del Componente 31: Ciclo Día/Noche (delegable)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 18:25:00

## Descripción breve

Se documentó el **Módulo 31 — Ciclo Día/Noche** en `DOCUMENTACION/31-Ciclo-Dia-Noche/` como módulo **delegable para implementación** (tercero de la tanda de servicios). Define cómo la luz, el cielo y el ambiente cambian según la hora de GameClock (M29) y cómo los consumidores (NPC, fauna, audio, recursos, actividades) reaccionan por franjas discretas, con regla anti-oscuridad explícita (pilar cozy).

## Archivos creados

| Archivo | Contenido |
|---|---|
| `plan-inicial/01-Requerimientos.md` | 9 RF + NFR (piso de luz, rendimiento, accesibilidad) + 5 criterios |
| `plan-inicial/02-Analisis.md` | 22/22 puntos de la sección 30 resueltos; 4 alternativas descartadas |
| `plan-inicial/03-Diseno.md` | Arquitectura, cronograma de 5 fases, componentes de escena, curvas de datos, API de fase, eventos/secretos nocturnos, regla anti-oscuridad |
| `plan-inicial/04-Codigo.md` | Archivos previstos, contrato API, algoritmo de transición, presupuesto de rendimiento, pendientes + Notas del Agente |
| `plan-inicial/05-Checklist.md` | **130 ítems**, 130 completados |
| `plan-actual/*` | Espejo vigente |

## Cambios colaterales

- `CHECKLIST-GLOBAL.md`: M31 → 🟢 Disponible, 130/130, marcado **DELEGABLE PARA IMPLEMENTAR**.
- `DOCUMENTACION/README.md`: componente 31 registrado.
- `Logs/ULTIMO_NUMERO.txt` → 21.

## Decisiones

- **Franjas discretas** para consumidores (ALBA/DÍA/ATARDECER/NOCHE/PROFUNDA) con señal `fase_cambio` solo al cambiar; iluminación continua por curvas de 24 puntos.
- **Anti-oscuridad:** piso de ambiente nocturno 0.15 LDR + linterna (M13) + opción "Noche clara" (M58); prohibido negro puro.
- **Sin sombras de luna** (rendimiento); sol con 2 cascadas a 30 m.
- **Contenido nocturno siempre opcional** (lluvia de estrellas días 10 y 25, lince de luna día 15, flora brillante x2): nada crítico exige jugar de noche (anti-FOMO).
- Ciclo por minuto de juego (señal de M29), no por frame; presupuesto ≤ 2 ms GPU.