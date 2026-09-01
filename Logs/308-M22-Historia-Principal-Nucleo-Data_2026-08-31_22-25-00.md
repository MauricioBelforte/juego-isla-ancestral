# Log 308: M22 Historia Principal iter. 1 — núcleo data-driven — glm-5.3-flash

**Fecha:** 2026-08-31
**Hora:** 22:25
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen

Iteración 1 del M22 Historia Principal (F5, dificultad 4, V0/V1): grafo de historia data-driven con gating por sellos, requisitos verificables y validador de grafo. Módulo liberado 🟡 37/100.

Nota de coordinación: **M17 Construcción fue reclamado por Qwen3.8 Max (Kilo Code) a las 00:15 UTC** minutos antes de mi reserva; se retiró sin tocar nada del módulo (regla §21.4.2) y se redirigió a M22.

## Cambios Realizados

### data/historia/historia_principal.json (nuevo)
- Grafo v1 con 12 nodos: prólogo + C1-C7 + 4 finales (principal/regresar/guardian/secreto), según 03-Diseno §Arcos y §Secuencia de Templos y Sellos.
- Campos Escena {id, capitulo, titulo, tipo, resumen, requisitos[], siguiente[]}; requisitos: capitulo/sellos/flag/objeto.
- Catálogo de 7 sellos (ceniza×2, mar×2, brisa×3) y flag de apertura del templo.

### scripts/historia/story_manager.gd (nuevo, autoload Historia)
- puede_entrar(id) → {ok, motivos[]} con requisitos verificables (M66): capítulo previo, cantidad de sellos, flag vía WorldState (M21), objeto vía Inventario (M14).
- completar_nodo con re-validación; marcar_sello idempotente que emite EventBus.quest.prereq_met; siguientes_disponibles; finales_alcanzables; capitulo_actual.
- Persistencia ISaveProvider M59: sección "historia" (completados/sellos/final_elegido), restore tolerante.

### scripts/historia/validar_historia.gd (nuevo)
- Validador del grafo (patrón DialogGraphValidator M21): ids únicos, sin huérfanos, sin retroceso de capítulo (DAG), los 4 finales alcanzables desde prólogo, tipos de requisitos conocidos, catálogo sellos consistente → **0 fallos**.

### scripts/historia/test_historia.gd (nuevo)
- 6 grupos: carga del grafo, progresión lineal con motivos, gating de sellos (7/7, idempotencia, desconocidos rechazados), flags WorldState (templo y pistas secretas), elección de final, round-trip de persistencia → **0 fallos**.

### Registro
- Autoload `Historia` agregado a project.godot; caché de clases regenerada.
- Regresión M21 (test_condiciones_mundo.gd): 0 fallos.
- Checklist M22 relevado: 37/100 [x]; fila 22 global → 🟡; registros de coordinación actualizados.

## Archivos Modificados/Creados

- `game/isla-ancestral/data/historia/historia_principal.json` (nuevo)
- `game/isla-ancestral/scripts/historia/story_manager.gd` (nuevo)
- `game/isla-ancestral/scripts/historia/validar_historia.gd` (nuevo)
- `game/isla-ancestral/scripts/historia/test_historia.gd` (nuevo)
- `game/isla-ancestral/project.godot` (autoload Historia)
- `game/isla-ancestral/.godot/global_script_class_cache.cfg` (regenerado)
- `DOCUMENTACION/22-Historia-Principal/plan-actual/04-Codigo.md` (Notas del Agente iter. 1)
- `DOCUMENTACION/22-Historia-Principal/plan-actual/05-Checklist.md` (37/100 + reserva liberada)
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`

## Verificación

- validar_historia.gd: 0 fallos · test_historia.gd: 0 fallos · regresión M21: 0 fallos (Godot 4.5 headless).
