# Guía - CONTEXTO-PROXIMO-AGENTE

## Objetivo

Esta carpeta existe para generar contexto detallado de cada sesión de trabajo, de forma que cuando otro agente deba continuar las tareas, tenga toda la información necesaria sin tener que reconstruir el estado desde cero.

---

## Regla de uso

Cuando el usuario solicite expresamente generar el contexto de la sesión, el agente debe:

1. Leer esta guía.
2. Crear un nuevo archivo enumerado dentro de esta carpeta, con un nombre descriptivo de la sesión/tarea.
3. Escribir en ese archivo todo el contexto sumamente detallado de lo trabajado en la sesión, incluyendo:
   - Objetivo de la sesión
   - Decisiones tomadas
   - Cambios realizados en archivos (con rutas y contenido relevante)
   - Estado actual del sistema
   - Tareas pendientes o bloqueos encontrados
   - Cualquier información que el próximo agente necesite para continuar

---

## Formato de archivos

- **Nombre:** `NN-descripcion-sesion-AAAA-MM-DD.md`
  - `NN` = número secuencial (leer el último número de archivo en la carpeta para continuar).
  - `descripcion-sesion` = breve descripción del objetivo o tema de la sesión.
  - `AAAA-MM-DD` = fecha de la sesión.

- **Contenido mínimo:**
  - Título y fecha
  - Objetivo de la sesión
  - Resumen detallado de lo realizado
  - Archivos modificados/creados con su propósito
  - Estado actual y próximos pasos sugeridos

---

## Ejemplo de archivo

```
# 01-Correccion-bug-dialogo-npc-2026-09-09

## Fecha
2026-09-09

## Objetivo de la sesión
Corregir el bug por el cual algunos NPC no iniciaban el diálogo con el jugador al presionar la tecla de interacción.

## Trabajo realizado
- Se identificó que el problema estaba en `game/isla-ancestral/scripts/ia_npc/npc_agent.gd`: el NPC consumía `EventBus.npc.gift_given` con un nombre de clase incorrecto y nunca despachaba el hook de diálogo.
- Se corrigió la referencia para usar la clase exacta `GiftEvaluator.Clase` y se agregó un fallback cuando el perfil del NPC era `unknown`.
- Se actualizó `DOCUMENTACION/19-NPC-Y-Vecinos/plan-actual/05-Checklist.md` marcando el ítem como completado.
- Se ejecutó `godot --headless res://scenes/test_runner.tscn` y los tests pasaron con 0 fallos.

## Archivos modificados
- `game/isla-ancestral/scripts/ia_npc/npc_agent.gd`
- `DOCUMENTACION/19-NPC-Y-Vecinos/plan-actual/05-Checklist.md`

## Estado actual
El diálogo de NPC vuelve a funcionar en local. Pendiente probar con la población completa de 35 NPCs en la isla de prueba.

## Próximos pasos sugeridos
- Ejecutar la prueba de humo en `M19` con todos los perfiles cargados.
- Continuar con los pendientes de `M21` relacionados a UI de diálogo y nombres de hablante.
```

---

## Notas importantes

- Cada archivo debe ser autocontenido: cualquier agente que lo lea debe poder entender qué pasó y por qué, sin necesitar acceso a conversaciones previas.
- Incluir paths absolutos o relativos claros según el estándar del proyecto.
- Si hay errores conocidos o deuda técnica, documentarlos explícitamente en `Estado actual` o `Próximos pasos sugeridos`.
