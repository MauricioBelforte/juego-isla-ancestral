# Log 400: M162 Diálogos Contextuales de NPCs — cierre iter 2 (contenido cap 1-7 + validación)

**Fecha:** 2026-09-01
**Hora:** 22:45
**Modelo:** Hy3
**Plataforma:** Kilo Code

> **Nota de numeración:** la reserva original era el número 393 (ver `Logs/reservas/393-Hy3-M162.txt`), pero dicho número ya estaba ocupado por `Logs/393-M59-Autosave-Fin-Evento_...md` y `Logs/393-M42-Sonido-Ambiental-...md`. Por el protocolo §6.1.d (colisión residual) se incrementa al primer número libre: **400**. El archivo de reserva `393-Hy3-M162.txt` se elimina al consumir el log.

## Resumen
Cierre de la iteración 2 de M162 (Diálogos Contextuales de NPCs). Se recreó el generador `scripts/gen_m162_dialogues.py` (faltaba en disco pese a estar documentado en iter 1), se ejecutó como fuente de verdad y se validó todo el contenido en disco con una réplica de `DialogGraphValidator`. Resultado: 264 grafos M21, 0 inválidos; 263 entries en `registry.json`; 23/23 NPCs cubiertos. El módulo pasa a **98 [x] / 22 [?] de 120** y queda liberado en 🟡 (las 22 pendientes son dimensiones de variación y checks cruzados, con dueño externo).

## Cambios Realizados
- **Generador recreado y ejecutado:** `scripts/gen_m162_dialogues.py` reconstruye `data/dialogues/contextual/*.json` + `registry.json` de forma determinista. Editando el dict `entries` y reejecutando se regenera todo.
- **Contenido completado en iter 2:** capítulos 1-7 (SALUDO/HISTORIA/MISION/AMBIENTE según el diseño del módulo) para los 20 NPCs secundarios, más HISTORIA/MISION/AMBIENTE cap 0 donde el diseño los define.
- **260 grafos nuevos + 4 base** = 264 archivos `.json` en `data/dialogues/contextual/`; `registry.json` con **263 entries** (187 SALUDO, 46 HISTORIA, 19 MISION, 11 AMBIENTE), 23 NPCs.
- **Selector intacto:** `scripts/dialogos/contextual_dialogue_manager.gd` (prioridad + fallback) no requirió cambios; su lógica fue validada por simulación en iter 1 (8/8 OK).
- **`test_contextual_dialogue_m162.gd`** actualizado: COR-001 ya tiene HISTORIA cap 0; el fallback verifica que no hay aún variante de amistad.

## Verificación
- **Validación de grafos (Python, réplica de `DialogGraphValidator`):** 264/264 grafos OK — `start` presente, `fin` alcanzable, sin nodos huérfanos. 0 fallos.
- **Claves de condición:** 0 claves desconocidas en M21 (todas `flag_capitulo`/`estacion`/`es_noche`/`amistad_*`/`flag_*` válidas).
- **Registro:** 263 entries, 23 NPCs, tipos coherentes.
- **Runtime Godot:** pendiente ejecutar `test_contextual_dialogue_m162.gd` (el MCP disponible solo corre el juego principal, no `--script`); la validez de grafos ya está cubierta por la réplica y el test headless de iter 1.

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/gen_m162_dialogues.py` (recreado como fuente de verdad)
- `game/isla-ancestral/data/dialogues/contextual/*.json` (264 grafos)
- `game/isla-ancestral/data/dialogues/contextual/registry.json` (263 entries)
- `game/isla-ancestral/scripts/dialogos/test_contextual_dialogue_m162.gd` (actualizado)
- `DOCUMENTACION/162-Dialogos-Contextuales-De-NPCs/plan-actual/{04-Codigo,05-Checklist}.md` (actualizados: conteo 98/120, referencia Log 400)
- `CHECKLIST-GLOBAL.md` (fila 162: 🔵 En curso → 🟡 Liberado iter 2; 98/120)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (M162 liberado)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (reserva M162 cerrada — Log 400)
- `Logs/ULTIMO_NUMERO.txt` (→ 400)
- `Logs/reservas/393-Hy3-M162.txt` (eliminado al consumir el log)

## Pendientes honestos ([?], 22 ítems — con dueño externo / iter futura)
- **Variantes de dimensión:** amistad (0-29 / 30-69 / 70-100), estaciones restantes (VERANO/OTONO/INVIERNO), franjas horarias (mañana/tarde/noche), ubicación (`flag_ubicacion_*`). Mecanismo listo; falta contenido.
- **Checks de coherencia cruzada:** M158 (forja/encantamientos), M160 (ubicaciones/rutas), M22 (capítulos/historia), M20 (amistad), M29/M32 (tiempo/clima).
- **Runtime real en Godot** del `test_contextual_dialogue_m162.gd`.
