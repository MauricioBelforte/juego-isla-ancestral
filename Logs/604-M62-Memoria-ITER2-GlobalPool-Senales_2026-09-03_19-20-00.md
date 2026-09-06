# Log 604: M62 Memoria — iter. 2 GlobalPool (auditoría de señales + estados)

**Fecha:** 2026-09-03
**Hora:** 19:20
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen
Iter. 2 de M62 Memoria: GlobalPool con API única completa y estados correctos — obtener() ACTIVA el nodo, devolver() lo ESTACIONA con auditoría de señales (desconecta conexiones entrantes), fallback honesto queue_free y drenar_familia(). 5 ítems marcados [x] → 23/150.

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `scripts/rendimiento/memoria/global_pool.gd` | obtener() activa (proceso on/visible); devolver() estaciona (proceso off/invisible) + _auditar_senales() desconecta get_incoming_connections; fallback queue_free con return false si lleno; +drenar_familia() |
| `scripts/rendimiento/memoria/test_pool_iter2.gd` *(nuevo)* | 14 checks: API única round-trip, auditoría de señales, fallback honesto, drenar_familia/liberar_todo |
| `DOCUMENTACION/62-Memoria/plan-actual/05-Checklist.md` | 5 ítems [x] + Notas del Agente |
| `CHECKLIST-GLOBAL.md` / `ESTADO-PARALELO.md` | M62 iter. 2 Liberado (23/150) |

## Tests (headless Godot 4.7.2)
- `test_pool_iter2.gd`: **0 fallos** (14 checks)
- Regresión: `test_memoria_m62.gd` **26 checks, 0 fallos** (núcleo iter. 1 intacto)

## Hallazgos técnicos
1. **get_incoming_connections()** es la API correcta para auditar conexiones ENTRANTES de un nodo (las que otros le conectaron a él) — clave para estacionar ítems sin retener callbacks colgantes.
2. liberar_todo() en un SceneTree de test acumula pools de checks anteriores — los checks de "vaciar todo" deben usar >= o filtrar por familia.

## Archivos Modificados/Creados
- `game/isla-ancestral/scripts/rendimiento/memoria/global_pool.gd` *(modificado)*
- `game/isla-ancestral/scripts/rendimiento/memoria/test_pool_iter2.gd` *(nuevo)*
- `DOCUMENTACION/62-Memoria/plan-actual/05-Checklist.md` *(modificado)*
- `CHECKLIST-GLOBAL.md`, `Mensajes entre modelos/ESTADO-PARALELO.md` *(modificados)*
- `Logs/ULTIMO_NUMERO.txt` *(→ 604)*
- `Logs/reservas/604-...txt` *(creado y borrado)*

## Pendientes con dueño
- Contadores por sistema voxel/audio/texturas (instrumentar M08/M43/M47)
- Test de leaks con teleport ×10 (mundo real M08/M09)
- Presupuestos por preset M90 (800 MB voxel / 200 MB pool en Alta)
