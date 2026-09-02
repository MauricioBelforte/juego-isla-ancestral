# Log 384: M23 Historias Secundarias iter. 1 — núcleo motor + validador — glm-5.3-flash

**Fecha:** 2026-09-01
**Hora:** 17:05
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen

Iteración 1 del M23 Historias Secundarias (F7/Narrativa, V0/V1): SecondaryStoriesService autoload con motor de cadenas data-driven del esquema del diseño (pasos hablar/explorar/puzzle/entregar), validador anti-repetición y 4 cadenas ejemplo. Módulo liberado 🟡 22/104.

## Cambios Realizados

### secondary_stories_service.gd (nuevo, autoload Historias)
- Motor de cadenas: iniciar_cadena (gating ocultas/postgame), reportar_paso (valida tipo + evidencia con _slug), reportar_entrega (consume objeto del inventario M14), _completar_cadena (consecuencia → WorldState M21 flags, recompensa.diario → M55, recompensa.cosmetico → quest_updated, señales quest_started/quest_completed que M55/M71 ya consumen).
- Ocultas: invisibles en cadenas_disponibles() hasta iniciarse. Postgame: requiere final_elegido de M22.
- Validador anti-repetición (§regla dura): contexto >= 10 chars, pasos >= 3, tipos conocidos, ids de paso únicos, recompensa/consecuencia presentes, títulos únicos → validar_cadenas() ejecutable headless.
- Persistencia ISaveProvider M59 sección "secondary_stories" (activas + completadas, huérfanas purgadas).

### data/historias/secundarias.json (nuevo)
- 4 cadenas ejemplo: cadena-faro (diseño §esquema original, 4 pasos mixtos), cadena-invernadero (entrega con objeto), cadena-epilogo-plaza (postgame tras final M22), cadena-secretta-luciernagas (oculta).

### test_historias.gd (nuevo)
- Carga, validador (catálogo base limpio), cadena completa con rechazo de tipo incorrecto + consecuencia aplicada + registro en M55, entrega con/sin objeto, ocultas, postgame bloqueado/abierto, persistencia con huérfana → **0 fallos**.

### Registro
- Regresiones: test_diario M55 0 fallos, test_progresion M71 0 fallos, test_historia M22 0 fallos.
- Checklist: 22 ítems [x]. Progreso 0→22/104.
- Nota de integración: el diario_catalog.json de M55 recibió las entradas "mision_cadena-*" de las 2 cadenas con recompensa de diario (coherencia M23→M55).

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/historias/secondary_stories_service.gd` (nuevo)
- `game/isla-ancestral/data/historias/secundarias.json` (nuevo)
- `game/isla-ancestral/scripts/historias/test_historias.gd` (nuevo)
- `game/isla-ancestral/data/diario/diario_catalog.json` (+2 entradas de misiones M23)
- `game/isla-ancestral/project.godot` (autoload Historias)
- `DOCUMENTACION/23-Historias-Secundarias/plan-actual/04-Codigo.md` (Notas del Agente iter. 1)
- `DOCUMENTACION/23-Historias-Secundarias/plan-actual/05-Checklist.md` (22/104 + reserva liberada)
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`

## Verificación

- test_historias.gd: 0 fallos · regresiones M55/M71/M22: 0 fallos (Godot 4.5 headless).

## Nota de protocolo

Aplicación del protocolo v2 (§6.1): número 384 reservado al BLOQUEAR el módulo (reserva en Logs/reservas/ + "Log reservado: 384" en CHECKLIST/ESTADO-PARALELO); la reserva se BORRA al escribir este archivo.
