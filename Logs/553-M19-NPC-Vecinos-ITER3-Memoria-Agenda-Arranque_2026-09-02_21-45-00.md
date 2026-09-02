# Log 553: M19 NPC y Vecinos — iter. 3 (memoria P26, agenda M64, arranque P1)

**Fecha:** 2026-09-02
**Hora:** 21:45
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. 3 de M19 NPC y Vecinos sobre mi núcleo de mudanzas (iter. 2, Log 312): memoria de interacciones (P26), agenda horaria determinista para M64 (P11/P12/P24) y población de arranque (P1). Además, FIX de un bug de aliasing crítico en get_save_data(). 13 ítems marcados [x] → 45/131.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scripts/npc/villager_manager.gd` | +P26: registrar_interaccion()/memoria_de()/memoria_conteo() con cap rotativo 20; entregar_regalo() memorializa; persistencia con purga de huérfanos. +P11/P12/P24: agenda_dia()/actividad_actual() con FRANJAS_DIA (6 franjas del diseño), rutina_diaria del perfil prioriza, PRNG determinista (seed día*100000+hash(id)), 22-06 dormir fijo. +P1: poblar_arranque() deferred (hasta 6 vecinos, snap TerrainLocator, idempotente, headless-safe). **FIX aliasing:** get_save_data() ahora hace deep-copy de TODOS los Dictionary/Array |
| `scripts/npc/test_memoria_agenda.gd` *(nuevo)* | 8 secciones ~35 checks (memoria, cap rotativo, persistencia+huérfanos, agenda determinista, franjas, actividad actual, arranque idempotente) |
| `DOCUMENTACION/19-NPC-Y-Vecinos/plan-actual/05-Checklist.md` | 13 ítems [x] + Notas del Agente |
| `CHECKLIST-GLOBAL.md` / `08-GUIA` / `ESTADO-PARALELO` | M19 reservado → liberado (45/131) |

## Tests (headless Godot 4.7.2)
- `test_memoria_agenda.gd` (M19 iter. 3): **0 fallos**
- Regresión `test_mudanzas.gd` (núcleo iter. 2): **0 fallos**
- Regresiones: test_inventario (M14) 0, test_museo (M37) 0 fallos
- Boot: `[M19] Catálogo de vecinos: 5 perfiles` + `Población de arranque: 5 vecinos activados (P1)`

## Bug crítico corregido: aliasing en get_save_data()
**Causa:** en Godot, Dictionary/Array son por referencia. get_save_data() serializaba `_memoria`, `_hogares`, `_llegadas_pendientes`, etc. SIN `.duplicate(true)` — al hacer `restore_save_data(...)` posterior, el `_clear()` interno vaciaba también el snapshot capturado (el save y el estado compartían los mismos contenedores).
**Síntoma:** round-trip restauraba 0 elementos aunque el save tenía 3.
**Fix:** deep-copy explícito de todos los campos en get_save_data().
**Impacto:** bug latente desde iter. 2 que los tests de mudanzas no detectaban (no hacían restore intermedio). Los demás ISaveProvider del proyecto deberían auditarse con este mismo lente (M22/M32/M59 providers) — recomendación documentada.

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/npc/villager_manager.gd` *(modificado)*
- `game/isla-ancestral/scripts/npc/test_memoria_agenda.gd` *(nuevo)*
- `DOCUMENTACION/19-NPC-Y-Vecinos/plan-actual/05-Checklist.md` *(modificado)*
- `CHECKLIST-GLOBAL.md`, `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md`, `Mensajes entre modelos/ESTADO-PARALELO.md` *(modificados)*
- `Logs/ULTIMO_NUMERO.txt` *(modificado)*
- `Logs/reservas/553-glm-5.3-flash-M19-NPC-Vecinos.txt` *(creado y borrado)*

## Notas técnicas
- La agenda es un CONTRATO de consulta hacia M64 (actividad_actual() por tick, agenda_dia() para planificar) — M19 no patenta IA propia (P23).
- poblar_arranque es deferred y headless-safe: en bootstrap sin escena raíz registra nodos lógicos bajo el manager; con villager.tscn (M161) instanciará la escena con perfil sincronizado.
- La memoria alimenta continuidad narrativa: memoria_conteo(vecino, "regalo") permite diálogos "ya me diste N regalos" (M21/M20).
- El pitfall del aliasing debe agregarse a 07-GUIA §8 en la próxima pasada de mantenimiento de guías.
