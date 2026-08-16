# Log 15 — Creación del Componente 12: Cámara

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16 05:10:00

## Descripción breve

Se documentó el **Módulo 12 — Cámara** en `DOCUMENTACION/12-Camara/`. Se resolvieron los 20 puntos de la sección 11 del plan maestro: 5 modos de cámara (Explore, Build, Dialog, Cutscene, Minimap), spring-arm con colisión contra bloques (nunca atraviesa), zoom de 3 niveles (2.5/5/8 m), transiciones con fade, shake solo narrativo y minimapa 2D con texturas del generador (0 coste de render).

## Archivos creados

| Archivo | Contenido |
|---|---|
| `plan-inicial/01-Requerimientos.md` | 8 RF + 4 criterios |
| `plan-inicial/02-Analisis.md` | 20 puntos resueltos; descartes (orbit libre, FPS, Timeline) |
| `plan-inicial/03-Diseno.md` | 5 modos + reglas de activación, spring-arm, minimapa, diálogo, presupuesto |
| `plan-inicial/04-Codigo.md` | Archivos previstos, contratos, pendientes, Notas del Agente |
| `plan-inicial/05-Checklist.md` | **100 ítems**, 100 completados |
| `plan-actual/*` | Espejo vigente |

## Cambios colaterales

- `CHECKLIST-GLOBAL.md`: M12 → 🟢 Disponible, 100/100.
- `DOCUMENTACION/README.md`: componente 12 registrado.
- `Logs/ULTIMO_NUMERO.txt` → 15.

## Decisiones

- Cámara tras el hombro derecho con yaw = dirección del personaje (sin orbit libre, anti-mareo).
- FOV 70° fijo; sin motion blur ni DOF; MSAA 4x.
- Spring-arm: raycast con separación mínima de 0.8 m (nunca dentro del bloque).
- Minimapa con texturas de biomas de M10 (sin cámara render).
- Shake solo narrativo (amplitud ≤ 0.15 m, ≤ 0.5 s).
- Cinemáticas complejas → post-v1.0 (4 expansiones); en v1.0 fade + planos fijos.