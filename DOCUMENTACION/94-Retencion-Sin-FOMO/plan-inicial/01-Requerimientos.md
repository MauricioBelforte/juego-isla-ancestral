**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 01-Requerimientos.md — Módulo 94: Retención sin FOMO

## 1. Problema
El juego necesita retener jugadores a largo plazo **sin mecánicas FOMO** (Fear of Missing Out): sin castigar ausencias, sin recompensas obligatorias diarias, sin contenido que expire y deje al jugador en desventaja. El diseño debe motivar con objetivos voluntarios, metas de largo plazo, colecciones, construcción, relaciones, misterios y postgame, cuidando la salud mental del jugador (M152) y la diversión sostenida (M93).

## 2. Objetivo del módulo
Diseñar el sistema de **retención amable** de "Isla Ancestral": objetivos por temporalidad (diario/semanal/mensual), eventos repetibles, descubrimientos inesperados, metas a largo plazo y postgame, **sin ninguna mecánica que obligue a iniciar sesión** ni penalice el descanso.

## 3. Alcance (derivado del plan maestro: sección 93 "RETENCIÓN SIN FOMO")
1. **Objetivos diarios** — misiones livianas voluntarias con recompensa moderada.
2. **Objetivos semanales** — encargos de la isla con recompensa mayor.
3. **Objetivos mensuales** — metas estacionales con recompensa de colección.
4. **Evitar castigar el ausentarse** — el mundo sigue el tiempo del jugador, sin pérdida de progreso.
5. **Evitar recompensas obligatorias diarias** — nada que se pierda si no se juega.
6. **Permitir completar contenido posteriormente** — misiones/eventos reintentables o acumulables.
7. **Crear descubrimientos inesperados** — sorpresas del mundo que motivan volver (M148 es apoyo).
8. **Crear eventos repetibles** — festividades (M74) con variantes que no expiran.
9. **Crear metas de largo plazo** — sellos, museo, ciudad, exploración total.
10. **Crear colecciones** — 100% completable sin límite de tiempo (M73).
11. **Crear proyectos de construcción** — invernadero, islas, casas (M17/M65/M68).
12. **Crear relaciones** — amistad con hitos de largo plazo (M20).
13. **Crear misterios** — arcos narrativos que se descubren sin prisa (M22/M148).
14. **Crear postgame** — contenido después del Sello 6 y epílogo (bonus de M22).
15. **Evitar mecánicas para forzar login** — prohibición formal: sin streak, sin contenido exclusivo temporal, sin penalización por no jugar.

## 4. Requisitos funcionales (RF)
| RF | Descripción |
|----|-------------|
| RF1 | Tablero de objetivos diarios/semanales/mensuales (voluntarios) con reseteo rotatorio y sin pérdida de recompensas no cobradas |
| RF2 | Regla anti-castigo: 0 penalizaciones por ausencia (casas no se degradan, cultivos no mueren por ausentarse, amistad no decae) |
| RF3 | Regla anti-FOMO: 0 recompensas exclusivas por fecha; todo logro de evento se puede repetir o compensar |
| RF4 | Eventos repetibles con variantes (M74) y recompensas por progreso acumulable |
| RF5 | Descubrimientos inesperados en el mundo (sorpresas, cometas, misiones ocultas) sin ventana temporal |
| RF6 | Metas de largo plazo (sellos, museo, ciudad, exploración) con seguimiento visible |
| RF7 | Colecciones 100% completables sin límite de tiempo (M73) |
| RF8 | Postgame: contenido extra tras el epílogo (nuevas variantes, desafíos, misterio final) |
| RF9 | Diario de recompensas: lo que no se cobró queda acumulado hasta cobrarlo (M55) |
| RF10 | Telemetría de "juega sin prisa": medir sesiones libres y retención sin FOMO (M104) |

## 5. Criterios de aceptación (DoD del módulo)
1. Tablero de objetivos funcionando con los 3 plazos sin obligatoriedad.
2. Auditoría anti-FOMO: scan de 100% de mecánicas sin streak/pérdida/expiración de recompensas.
3. Eventos repetibles jugables 3+ veces sin repetición exacta (variantes).
4. Recompensas no cobradas disponibles al regresar (test de ausencia simulada 7 días → 0 pérdida).
5. Postgame con ≥ 5 horas de contenido nuevo tras el Sello 6.
6. Métricas de retención sin FOMO recolectando (M104) sin forzar login.
7. Documentación plan-actual actualizada y firmada.

## 6. Restricciones
- **Aplican:** M93 (balance/diversión — las recompensas moderadas), M74 (eventos), M73 (colecciones), M22 (historia/postgame), M71 (progresión), M20/M21 (relaciones/NPC), M17/M65/M68 (construcción), M55 (diario), M59 (save — la ausencia se mide por días de juego, no calendario real), M104 (telemetría).
- Prohibido terminar: streak rewards, contenido exclusivo temporal, penalizaciones por ausencia, avisos "¡Vuelve o lo pierdes!".
- El calendario de eventos sigue el día de juego (M29/M74): el tiempo real no penaliza.
- Normas explícitas de diseño en el equipo (M152).

## 7. Dependencias
- M93 (Balances/diversión ✅), M74 (Eventos ✅), M73 (Colecciones ✅), M22/M23 (Historia/Misiones ✅), M71 (Progresión ✅), M20 (Relaciones ✅), M17/M65/M68 (Construcción ✅), M55 (Diario ✅), M59 (Save ✅), M104 (Telemetría ✅), M148 (Lore — apoyo a descubrimientos).

## 8. Entregables del módulo
1. Tablero de objetivos (diario/semanal/mensual) conectado a M55.
2. Motor de eventos repetibles con variantes (M74 extendido).
3. Sistema de recompensas acumuladas (sin expiración).
4. Auditoría anti-FOMO (script de scan + código de revisión).
5. Contenido de postgame (≥ 5 h) especificado.