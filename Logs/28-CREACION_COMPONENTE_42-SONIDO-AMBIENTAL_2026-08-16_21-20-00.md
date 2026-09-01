# Log 28 — Creación del Componente 42: Sonido Ambiental (delegable)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-16
**Hora:** 21:20

## Descripción breve

Se documentó el **Módulo 42 — Sonido Ambiental** en `DOCUMENTACION/42-Sonido-Ambiental/` como módulo **delegable**. Define el paisaje sonoro de Aurora: banco por bioma (13+1), fuentes posicionales 3D, capas por hora/clima que suman (no reemplazan) y volumetría contenida — todo bajo presupuesto de ≤ 11 buses y ≤ -18 LUFS.

## Archivos creados

| Archivo | Contenido |
|---|---|
| `plan-inicial/01-Requerimientos.md` | 7 RF + NFR (cozy, rendimiento, oclusión) + 5 criterios |
| `plan-inicial/02-Analisis.md` | 25/25 puntos de la sección 41 resueltos; 3 alternativas descartadas |
| `plan-inicial/03-Diseno.md` | Arquitectura, mapa banco→bioma completo, capas de estado, presupuesto de fuentes, QA |
| `plan-inicial/04-Codigo.md` | Archivos previstos, API, pendientes + Notas del Agente |
| `plan-inicial/05-Checklist.md` | **109 ítems**, 109 completados |
| `plan-actual/*` | Espejo vigente (5 archivos) |

## Cambios colaterales

- `CHECKLIST-GLOBAL.md`: M42 → 🟢 Disponible, 109/109, marcado **DELEGABLE PARA IMPLEMENTAR**.
- `DOCUMENTACION/README.md`: componente 42 registrado.
- `Logs/ULTIMO_NUMERO.txt` → 24.

## Decisiones

- **Capas que suman:** banco de bioma + capas de clima (M32) + capas de hora (M31) — coherente y sin ambigüedades de cruce de contextos.
- **Presupuesto duro:** ≤ 11 buses activos (6 ambientales 2D + 3 posicionales + 2 fauna + interior), pool estático sin allocs por frame (M61).
- **Interiores con reverb propio:** cueva 1.5 s, templo 1.2 s — personalidad acústica sin IA compleja.
- **Fauna con horas de actividad** (M31): aves de día, grillos de noche — refuerzan el ciclo.
- **Volumetría:** ambientes ≤ -18 LUFS, música -16, diálogos +6 dB sobre música.