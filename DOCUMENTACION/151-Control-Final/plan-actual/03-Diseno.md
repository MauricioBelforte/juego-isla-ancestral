**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 151: Control Final

## 1. Arquitectura general
El Control Final es un **proceso de auditoría**, no un sistema de runtime. Se organiza como:

```
[Evidencias] ──▶ [Semaforizador (26 puntos)] ──▶ [Acta de Control Final] ──▶ M144
   ├─ Encuestas (≥10, diversión 1-5)                  ├─ ✔ (requiere evidencia)
   ├─ Sesiones observadas (3/frente)                  ├─ ⚠ (plan de acción)
   ├─ Telemetría 72 h (M143/M104/M105)                └─ ✖ (bloqueante)
   ├─ Profiling (M61-M63, dudas)
   └─ Docs admin (contratos, licencias, PI)
```

## 2. Mapa de los 26 puntos → evidencia requerida
| # | Punto | Evidencia principal |
|---|-------|---------------------|
| 1 | Identidad propia | Propuesta de juego (M147) + benchmark vs 3 pares |
| 2 | Bucle principal divertido | Encuestas diversión ≥ 4/5 + 3 sesiones observadas |
| 3 | Construir divertido | Encuesta + sesión de construcción 30 min |
| 4 | Explorar divertido | Encuesta + mapa de descubrimientos (M28/M50) |
| 5 | Puzzles divertidos | Encuesta + tasa de rendición < 15% (M93) |
| 6 | NPC interesante | Encuesta + guión revisado (M21/M23) |
| 7 | Economía funciona | Simulación M93: sin quiebras en 40 h; precio/día sano |
| 8 | Progresión funciona | Matriz de sellos/habilidades verificada (M71) |
| 9 | Mundo vivo | Rutinas/eventos sin huecos en 7 días de simulación (M25/M74) |
| 10 | Estaciones con propósito | Efectos estacionales en cultivos/eventos (M33) |
| 11 | Clima con propósito | Clima altera gameplay (lluvia/helada) (M32) |
| 12 | Música refuerza zonas | Playlist por zona auditable (M41) + test auditivo |
| 13 | Audio refuerza acciones | Matriz de SFX por interacción (M42/M44) |
| 14 | Gráficos coherentes | Guía de estilo (M06/M49) + screenshots por zona |
| 15 | Voxels eficientes | Presupuesto técnico (M08/M11/M61): draw calls, memoria |
| 16 | Guardado confiable | 30 ciclos + 0 reportes de save (M59/M60/M66) |
| 17 | Rendimiento aceptable | Telemetría 72 h: fps p99, crash < 0.5% (M61-M63) |
| 18 | Accesibilidad contemplada | Checklist M58 100% verificado |
| 19 | Localización contemplada | Checklist M87 100% verificado |
| 20 | Contratos documentados | Índice de contratos (ubicación + estado) |
| 21 | Licencias documentadas | Índice de licencias de assets/herramientas |
| 22 | PI documentada | Registros de marca/nombre/logo archivados |
| 23 | Página de tienda preparada | Store publicada y verificada (M149) |
| 24 | Soporte preparado | Canales activos + SLA operativo (M152) |
| 25 | Actualización preparada | Pipeline hotfix/patcheo probado (M142/M143) |
| 26 | Plan post-lanzamiento | Hoja de ruta M144 aprobada |

## 3. Flujo de evaluación
```
Por cada punto:
1. Evidencia recolectada (S2) → vinculada en el acta
2. Criterio objetivo (definido en S1) → ✔ / ⚠ / ✖
3. ⚠/✖ → plan de acción con dueño y fecha (S3)
4. Acta firmada (producción + QA) e indexada (S4/S5)
```

## 4. Plantilla del acta (semaforizador)
```json
{
  "acta": "CONTROL-FINAL-1.0",
  "fecha": "YYYY-MM-DD",
  "juego": "Isla Ancestral",
  "puntos": [
    {"id": 1, "nombre": "Identidad propia", "estado": "✔",
     "evidencia": "docs/identidad-benchmark.md",
     "planAccion": null},
    {"id": 7, "nombre": "Economía funciona", "estado": "⚠",
     "evidencia": "simulacion-m93.pdf",
     "planAccion": {"dueño": "QA", "fecha": "2026-09-15", "desc": "Ajuste de precio de temporada"}}
  ],
  "firmas": ["produccion", "qa"]
}
```

## 5. Reuniones del proceso
| Sesión | Asistentes | Salida |
|--------|------------|--------|
| Kickoff (S1) | Producción + QA + diseño | Criterios de los 26 puntos |
| Relevamiento (S2) | QA + soporte | Evidencias recolectadas |
| Evaluación (S3) | Producción + diseño + QA | Semáforo preliminar |
| Cierre (S4) | Producción + QA + legal | Acta firmada + ⚠ con dueños |

## 6. Qué NO se hace en Control Final
- No se implementa ni corrige nada en el juego (solo documenta y planifica).
- No se reabren decisiones cerradas (canon M147) salvo riesgo de calidad P0.
- No se agregan ítems nuevos al checklist del plan maestro (es auditoría).