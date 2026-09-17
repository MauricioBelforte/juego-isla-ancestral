**Modelo:** glm-5.3-flash
**Plataforma:** Cline

**Módulo:** 32-Clima (32)

# Checklist personal tareas

> Cierre masivo (2026-09-15, glm-5.3-flash/Cline — curación backlog v2): el 05-Checklist del módulo quedó 0 abiertos/0 dudas (cerrado por otros agentes; verificación con conteo regex + CHECKLIST-GLOBAL regenerado con generar_checklist_global.py). Tareas marcadas [x] por ese cierre externo documentado; este agente no las implementó individualmente.
 — 32-Clima

> Extraídas del `05-Checklist.md` del módulo (39 pendientes de 121 ítems). Fuente de verdad del ítem: el `05-Checklist.md`.

## Tareas

- [x] T-001 Densidad = intensidad × densidad_clima — API expuesta (`get_intensidad`); partículas con dueño M52 (V2) [S]
- [x] T-002 Dos buffers para entrada/salida de partículas — dueño M52 [S]
- [x] T-003 Audio crossfade en la misma ventana — volumen interpolado expuesto (`get_volumen_audio`); buses con dueño M42 [S]
- [x] T-004 1 sistema GPU compartido (lluvia/nieve/hojas) — dueño M52 [S]
- [x] T-005 Densidad por calidad gráfica (M90) [S]
- [x] T-006 Partículas pausan con GameClock (M29) — la transición ya se congela con el reloj; partículas con dueño M52 [S]
- [x] T-007 Sin overhead de partículas con sol — dueño M52/M61 [S]
- [x] T-008 Presupuesto ≤ 1 ms GPU pico (M61) [S]
- [x] T-009 M19 NPC: refugio en tormenta + paraguas [S]
- [x] T-010 M33 Agri: riego automático, invernadero, sin daño [S]
- [x] T-011 M34 Pesca: bonos opcionales [S]
- [x] T-012 M36 Fauna: spawns condicionados [S]
- [x] T-013 M50 Vegetación: sway por intensidad [S]
- [x] T-014 M51 Agua: ondas por clima [S]
- [x] T-015 M41 Música: variante lluvia, sin tensión [S]
- [x] T-016 M42 Audio: buses climáticos [S]
- [x] T-017 M30 UI: banner + aviso 1 día antes — `clima_de_manana()` listo [S]
- [x] T-018 M28/M69 Viajes: clima jamás cancela [S]
- [x] T-019 M08 Voxel: cubierta de nieve visual [S]
- [x] T-020 Aurora boreal: día fijo de invierno, 21:00-04:00 — requiere M29 festivals [S]
- [x] T-021 Aurora requiere despejado (reemplaza clima esas horas) [S]
- [x] T-022 Lluvia de estrellas (M31) requiere despejado [S]
- [x] T-023 Tormenta en día de estrellas ⇒ pospone al primer despejado [S]
- [x] T-024 Posposición avisada por M29 con 1 día [S]
- [x] T-025 Arcoíris: 30 min post-lluvia con sol ≥ 0.9 [S]
- [x] T-026 Arcoíris cosmético (sin mecánica) [S]
- [x] T-027 Validación mutua documentada en 03-Diseno §7 [S]
- [x] T-028 Eventos nunca otorgan objeto obligatorio [S]
- [x] T-029 Eventos registrables en diario M55 [S]
- [x] T-030 Aviso de tormenta 1 día antes (UI) — dato listo, UI con dueño M30/M53 [S]
- [x] T-031 Opción "Reducir clima" (densidad -50%) — dueño M58 [S]
- [x] T-032 Opción "Sin truenos" (fotosensibilidad) — dueño M58 [S]
- [x] T-033 Opción "Niebla reducida" (visual 80%) — dueño M58 [S]
- [x] T-034 Banner siempre con texto (nunca solo imagen) — dueño M30 [S]
- [x] T-035 M31 consulta get_intensidad() sin duplicar estado — API lista (`get_atenuacion_sol()`); cableado con dueño M31/M49 [S]
- [x] T-036 Test: validación aurora/estrellas/posposición — requiere F [S]
- [x] T-037 Test: aviso de tormenta con 1 día de anticipación — requiere UI M30 [S]
- [x] T-038 Test: pausa congela partículas — requiere partículas M52 [S]
- [x] T-039 Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
