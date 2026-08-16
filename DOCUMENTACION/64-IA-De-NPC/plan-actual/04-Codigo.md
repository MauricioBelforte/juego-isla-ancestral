**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 64: IA de NPC

## 1. Archivos involucrados (previstos)

| Archivo | Tipo | Rol |
|---|---|---|
| `res://src/ia/npc_director.gd` | Autoload | Autoridad única: burbuja, simulación parcial, presupuesto |
| `res://src/ia/npc_fsm.gd` | Componente | Máquina de estados + memoria de plan |
| `res://src/ia/npc_agenda.gd` | Componente | Rutinas por perfil + interrupciones |
| `res://src/ia/npc_navigation.gd` | Componente | NavigationAgent3D + avoidance + stuck |
| `res://src/ia/npc_planner.gd` | Util | Planificador de destinos (POI + clima/estación) |
| `res://data/ia/rutinas/*.tres` | Data | Perfiles de rutina (6+) |
| `res://data/ia/poi_catalog.gd` | Data/util | Catálogo de lugares caminables |
| `res://src/ia/simulacion_parcial.gd` | Util | Receta de estado para NPCs lejanos |

## 2. API pública

```
NPCDirector (autoload/único):
  registrar_npc(npc) / desregistrar_npc(npc)
  burbuja_activa(pos) -> Array[NPC]
  señales: npc_interrumpido(npc, motivo), npc_stuck(npc)
NPC (componentes integrados):
  estado() -> String; objetivo_actual() -> String
  interrumpir(motivo) / reanudar_plan()
  recomputar_navmesh_delta()          # M08/M17
```

## 3. Suscripciones e integración

- M31/M32: `fase_cambio` / `estado_clima` → `npc_planner.ajustar_destinos()` (indoor/outdoor).
- M17: `navmesh_modificada` → los NPCs cercanos re-planean con cooldown.
- M21: `dialogo_iniciado` → NPC paramos y mirando; `dialogo_terminado` → reanudar.
- M69/M28 (fast travel/vapor): NPCs fuera de la isla → receta activada; al regresar se rehidratan.
- M73 (festivales): agenda especial de día festivo (+P10).
- M29: pausa congelada (procesa igual pero sin físico).

## 4. Pendientes de implementación (dueño: AGENTE DELEGADO)

| Pendiente | Nota |
|---|---|
| NPCDirector + burbuja + simulación parcial | Requiere M19 (NPCs base) y M61 (presupuesto) |
| FSM + agenda + navegación | Con NavigationServer3D del motor |
| 6 perfiles de rutina + POI | Data (se puede prototipar con 2 perfiles) |
| Interrupciones clima/obras/jugador | Con señales de M32/M17/M21 |
| Tests M112 y QA M114 | Presupuesto y vida del pueblo |

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17 00:40:00
**Estado:** Documentación de diseño completa (módulo delegable; bloqueado por M19/M61)

### Lo que hice
- 22/22 puntos de la sección 63 resueltos.
- FSM con memoria de plan, 6 perfiles de rutina, simulación parcial por burbuja (≤60 plena).
- Reglas de anti-atascos, anti-solapamiento, fallbacks y presupuesto (M61).

### Lo que NO hice (honestidad obligatoria)
- Implementar: requiere M19 (NPCs base) y presupuestos M61 (GPT-5 en curso). Dueño: AGENTE DELEGADO.
- Perfiles de datos pendientes de balanceo (prototipo con 2 perfiles).

### Recomendaciones para el próximo agente
- La burbuja (64 m) es el corazón del presupuesto: probarla en la ciudad con 120+ NPCs.
- Validar que tras una interrupción el plan se reanuda (no empiece de cero): test específico.
- No implementar flocking social: usar destinos escalonados + avoidance.