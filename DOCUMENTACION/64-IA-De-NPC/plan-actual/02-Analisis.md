**Modelo:** MiMo V2.5
**Plataforma:** OpenCode

# 02-Analisis.md — Módulo 64: IA de NPC

## 1. Análisis del Dominio

La IA de NPC en un juego cozy tipo Stardew Valley no necesita comportamientos complejos de combate ni pathfinding perfecto. Necesita:

- **Rutinas diarias creíbles:** El NPC despierta, va a trabajar, come, se socializa, vuelve a casa y duerme. Las rutinas deben ser visibles por el jugador (el NPC "vive" en el pueblo).
- **Reacciones ambientales:** Lluvia → busca refugio. Noche → vuelve a casa. Evento → participa.
- **Socialización básica:** Saludos, charlas breves, reagrupación por proximidad.
- **Navegación robusta:** Que no se atasquen entre ellos ni se queden bloqueados.
- **Rendimiento:** Máximo 60 NPCs con IA completa; el resto en modo ligero.

## 2. Alternativas Evaluadas

| Alternativa | Ventajas | Desventajas | Veredicto |
|-------------|----------|-------------|-----------|
| FSM simple (Idle/Walk/Work) | Fácil de implementar | Poco creíble, sin reacciones | ❌ Rechazada |
| Behavior Trees | Muy potente, escalable | Complejo para un juego cozy, overkill | ❌ Rechazada |
| GOAP (Goal-Oriented AI) | Flexible, autónomo | Complejo, difícil de debuggear | ❌ Rechazada |
| FSM jerárquica + Rutinas | Balance entre complejidad y creibilidad | Requiere diseño de rutinas | ✅ Seleccionada |
| Utility AI | Decisiones ponderadas | Costoso en CPU, innecesario | ❌ Rechazada |

## 3. Decisión: FSM Jerárquica + Sistema de Rutinas

### Arquitectura propuesta

```
NPCManager (autoload)
├── NPCAgent[] (por cada NPC activo)
│   ├── HFSM (FiniteStateMachine jerárquica)
│   │   ├── Root
│   │   │   ├── Idle (esperando)
│   │   │   ├── Movement (navegando)
│   │   │   ├── Working (en su trabajo)
│   │   │   ├── Socializing (charlando)
│   │   │   ├── Eating (comiendo)
│   │   │   ├── Sleeping (durmiendo)
│   │   │   ├── Reacting (reaccionando a evento)
│   │   │   └── Interacting (hablando con jugador)
│   │   └── Sub-estados (por ejemplo: Movement tiene Walk, Run, Avoid)
│   ├── Routine (agenda diaria)
│   ├── Needs (hambre, energía, social)
│   └── Blackboard (datos compartidos: posición del jugador, clima, etc.)
└── NavigationAgent3D (pathfinding)
```

### Flujo de decisión

1. Cada tick (1-2 veces por segundo para NPCs normales):
   - El NPC evalúa su estado actual (HFSM)
   - Consulta la rutina del día (¿debería estar en otro lugar?)
   - Consulta el entorno (lluvia, noche, evento)
   - Si algo cambia → transición de estado
   - Si nada cambia → continuar estado actual

2. Las transiciones son suaves (el NPC no "teletransporta"):
   - Primero termina la animación actual
   - Luego se mueve al nuevo destino
   - Finalmente ejecuta la nueva acción

## 4. Análisis de Rendimiento

| Componente | Costo estimado | Optimización |
|-----------|---------------|-------------|
| FSM tick (60 NPCs) | ~4 ms/frame | Batch update, no todos los ticks |
| Pathfinding (NavigationServer3D) | ~2 ms/frame | Solo NPCs que se mueven |
| Detección de obstáculos | ~1 ms/frame | PhysicsServer3D, no RayCast por NPC |
| Social proximity | ~0.5 ms/frame | Grid espacial, no O(n²) |
| **Total** | **~7.5 ms/frame** | **Dentro del presupuesto de M61** |

### Simulación parcial (NPCs lejanos)

| Distancia | Nivel de simulación | Actualizaciones |
|-----------|--------------------|-----------------| 
| < 30 m | Completo (HFSM + pathfinding + animaciones) | 2×/segundo |
| 30-60 m | Medio (solo rutina, sin pathfinding continuo) | 1×/segundo |
| 60-100 m | Ligero (solo posición en mapa, sin IA) | 1×/5 segundos |
| > 100 m | Dormido (sin simulación) | Solo al acercarse |

## 5. Integración con Otros Módulos

| Módulo | Tipo de integración |
|--------|---------------------|
| M19 (NPC) | Consuma datos de NPCs (position, home, job) |
| M29/M30 (Tiempo) | Consulta hora/día para rutinas |
| M31/M32 (Clima/Estaciones) | Reacciones ambientales |
| M21 (Diálogos) | El NPC inicia diálogos según estado |
| M61 (Rendimiento) | Respeta presupuesto de agentes |
| M65 (Animales IA) | Mismo sistema pero simplificado |
| M08 (Mundo Voxel) | NavigationServer3D consume navmesh |
