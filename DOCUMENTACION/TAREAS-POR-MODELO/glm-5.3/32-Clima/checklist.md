**Modelo:** glm-5.3
**Plataforma:** Kilo Code

**Módulo:** 32-Clima (32)

# Checklist personal tareas — 32-Clima

> Extraídas del `05-Checklist.md` del módulo (37 pendientes de 121 ítems). Fuente de verdad del ítem: el `05-Checklist.md`.

## Tareas

- [ ] T-001 Densidad = intensidad × densidad_clima — API expuesta (`get_intensidad`); partículas con dueño M52 (V2) [S]
- [ ] T-002 Dos buffers para entrada/salida de partículas — dueño M52 [S]
- [ ] T-003 Audio crossfade en la misma ventana — volumen interpolado expuesto (`get_volumen_audio`); buses con dueño M42 [S]
- [ ] T-004 Densidad por calidad gráfica (M90) [S]
- [ ] T-005 Partículas pausan con GameClock (M29) — la transición ya se congela con el reloj; partículas con dueño M52 [S]
- [ ] T-006 Sin overhead de partículas con sol — dueño M52/M61 [S]
- [ ] T-007 Presupuesto ≤ 1 ms GPU pico (M61) [S]
- [ ] T-008 M19 NPC: refugio en tormenta + paraguas [S]
- [ ] T-009 M33 Agri: riego automático, invernadero, sin daño [S]
- [ ] T-010 M34 Pesca: bonos opcionales [S]
- [ ] T-011 M36 Fauna: spawns condicionados [S]
- [ ] T-012 M50 Vegetación: sway por intensidad [S]
- [ ] T-013 M51 Agua: ondas por clima [S]
- [ ] T-014 M41 Música: variante lluvia, sin tensión [S]
- [ ] T-015 M42 Audio: buses climáticos [S]
- [ ] T-016 M30 UI: banner + aviso 1 día antes — `clima_de_manana()` listo [S]
- [ ] T-017 M28/M69 Viajes: clima jamás cancela [S]
- [ ] T-018 M08 Voxel: cubierta de nieve visual [S]
- [ ] T-019 Aurora boreal: día fijo de invierno, 21:00-04:00 — requiere M29 festivals [S]
- [ ] T-020 Aurora requiere despejado (reemplaza clima esas horas) [S]
- [ ] T-021 Lluvia de estrellas (M31) requiere despejado [S]
- [ ] T-022 Tormenta en día de estrellas ⇒ pospone al primer despejado [S]
- [ ] T-023 Posposición avisada por M29 con 1 día [S]
- [ ] T-024 Arcoíris: 30 min post-lluvia con sol ≥ 0.9 [S]
- [ ] T-025 Arcoíris cosmético (sin mecánica) [S]
- [ ] T-026 Validación mutua documentada en 03-Diseno §7 [S]
- [ ] T-027 Eventos nunca otorgan objeto obligatorio [S]
- [ ] T-028 Eventos registrables en diario M55 [S]
- [ ] T-029 Aviso de tormenta 1 día antes (UI) — dato listo, UI con dueño M30/M53 [S]
- [ ] T-030 Opción "Reducir clima" (densidad -50%) — dueño M58 [S]
- [ ] T-031 Opción "Sin truenos" (fotosensibilidad) — dueño M58 [S]
- [ ] T-032 Opción "Niebla reducida" (visual 80%) — dueño M58 [S]
- [ ] T-033 Banner siempre con texto (nunca solo imagen) — dueño M30 [S]
- [ ] T-034 M31 consulta get_intensidad() sin duplicar estado — API lista (`get_atenuacion_sol()`); cableado con dueño M31/M49 [S]
- [ ] T-035 Test: validación aurora/estrellas/posposición — requiere F [S]
- [ ] T-036 Test: aviso de tormenta con 1 día de anticipación — requiere UI M30 [S]
- [ ] T-037 Test: pausa congela partículas — requiere partículas M52 [S]
