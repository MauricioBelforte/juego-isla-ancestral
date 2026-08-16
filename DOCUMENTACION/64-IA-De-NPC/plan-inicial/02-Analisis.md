**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 64: IA de NPC

## 1. Resolución de los 22 puntos del plan maestro

| # | Punto | Resolución |
|---|---|---|
| 1 | Máquina de estados | FSM jerárquica con sub-árbol BT ligero: `Idle → Mover → Actividad → (Interrupción)`; transiciones por eventos del mundo |
| 2 | Navegación | NavigationServer3D + navmesh global del mapa; regiones dinámicas excluyen agua profunda y acantilados |
| 3 | Pathfinding | A\* del servidor (navmesh); replanificación con cooldown 0.5 s si el destino cambia; sin pathfinding por scan manual |
| 4 | Obstáculos dinámicos | NPCs usan `navigation_agent` con avoidance radius; vallas/carretas: RID de obstáculo con prioridad |
| 5 | Prioridades | Agenda = lista ordenada por prioridad: necesidades vitales > trabajo/horario > social > ocio; trivialidades se saltan |
| 6 | Rutinas | Plan diario por NPC (perfiles: granjero, pescador, comerciante, artesano, niño, anciano); creado al spawn con PRNG M29 |
| 7 | Comportamiento social | Saludos al pasar + charlas cortas (M21) en zonas sociales; afinidad por NPC tipo; sin filas infinitas |
| 8 | Comportamiento contextual | Si está lloviendo (M32) → refugio mas cercano; si hace calor (verano) → sombra; viento fuerte → menos camino |
| 9 | Reacción al clima | Lluvia/tormenta/nieve cambian destinos de rutina (indoor vs outdoor) con 2 tick de anticipación |
| 10 | Reacción a estaciones | Otoño: recolectar hojas/mercado; invierno: indoor y fogatas; primavera: festivales (M73); verano: playa |
| 11 | Reacción a obras | El jugador construye (M17): NPCs se acercan a mirar (curiosidad), evitan andamiajes (obstáculo) y comentan |
| 12 | Reacción al jugador | Saludar de cerca; seguir con la mirada; si el jugador destroza (no aplica en cozy) no hay represalias violentas: se alejan con un comentario |
| 13 | Búsqueda de lugares | `POI` registrados en M09/M40: el NPC consulta el catálogo de lugares compatibles con su rol |
| 14 | Horarios | Reloj M31: 06:00 despertar, 08-12 trabajo, 12-13 almuerzo, 13-17 trabajo, 18-20 cena, 20-22 social, 22:30 dormir; variación ±30 min por NPC |
| 15 | Interrupciones | Lectura de eventos (clima, obras, diálogo del jugador) con prioridad de interrupción; el plan vuelve después (memoria de plan) |
| 16 | Recuperación de errores | Si el destino es inalcanzable: 2 reintentos con alternativas → fallback genérico (volver a casa) y log DOM-IA |
| 17 | Fallback | Estado último recurso: `IrACasa` (siempre navegable) o `DetenersePathleísmo`: quedarse quieto 10 s + aviso de teleport suave |
| 18 | Evitar NPC atascados | Detector de stuck (2 s sin progreso de posición) → re-path; si persiste → teletransporte discreto + log |
| 19 | Evitar NPC superpuestos | Avoidance físico + separación radial; interpenetración máxima 0.3 m; ninguno empuja al jugador |
| 20 | Evitar lugares imposibles | Navmesh valida destinos; rutinas nunca piden destinos fuera de navmesh (el mapa de POI incluye capa de caminabilidad) |
| 21 | Optimizar cantidad de agentes | Zona activa ≤ 60 a plena IA; lejanos → simulación parcial (tick 1 s, ver RF9) — presupuesto M61 |
| 22 | Simulación parcial | NPCs fuera de la burbuja del jugador: solo script de receta (estado → actividad por hora + destino flag), sin FSM completa ni pathfinding salvo al ser "reactivados" |

## 2. Decisiones clave

1. **FSM + agenda, no behavior tree puro**: el horario y las prioridades viven en datos (Rutina.tres), la FSM interpreta — fácil de balancear y setear por perfil.
2. **Simulación parcial por burbuja**: 60 plena + resto "receta": NPC lejano no necesita pathfinding continuo; al entrar a la burbuja, se rehidrata plan y se coloca en el destino previsto (sin pop raro: fade de aparición en zona alejada).
3. **Interrupciones con memoria de plan**: el NPC reanuda su rutina exactamente donde la dejó (índice de actividad + tiempo restante).
4. **Determinismo suave por PRNG M29**: rutinas y variaciones reproducibles entre cargas.
5. **Nada violento ni pasivo-agresivo**: reacciones cozy documentadas (curiosidad, comentario, alejarse).

## 3. Alternativas descartadas

- **Behavior trees puros para TODO NPC**: sobre-ingeniería para rutinas deterministas; se usa BT solo en sub-estados de interacción (cocinar, trabajar); descartado como motor central.
- **Simulación completa de todos los NPCs del mundo**: presupuesto inviable (cientos); descartado — simulación parcial obligatoria.
- **Movement de boids para NPCs sociales (flocking)**: crea filas y artificialidad; se usa avoidance del Navigation y destinos escalonados; descartado.