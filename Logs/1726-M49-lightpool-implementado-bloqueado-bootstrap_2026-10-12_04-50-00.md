# Log 1726: M49 - LightPool implementado, suite bloqueada por bootstrap roto (ajeno)

**Fecha:** 2026-10-12
**Hora:** 04:50
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Encargo del director (msg 171): implementar el pool de luces dinámicas de M49 (E41/E42/E43).
El **código está implementado y compila limpio**, pero la **suite no puede ejecutarse** porque el
bootstrap del proyecto está roto por cambios de otro agente. Lo entrego con el bloqueo
documentado y sin marcar `[x]` lo que no pude verificar.

## Implementado

`game/isla-ancestral/scripts/world/light_pool.gd` (sin `class_name`: se accede por ruta,
pitfall GUIA-GODOT/09 §9.17):

- **Topes del diseño** (03-Diseno.md §3.2): `MAX_DINAMICAS = 20`, `MAX_CONT_SOMBRA = 6`,
  `RADIO_DESCARTE = 30 m`.
- **Reutilización**: `obtener()` reusa una entrada libre del mismo tipo antes de crear; `liberar()`
  la devuelve al pool sin destruirla.
- **El tope total NO roba luces activas**: al llegar a 20 devuelve `null` y cuenta el rechazo
  (`rechazos_tope`) — el jugador nunca pierde la luz que ya tiene.
- **El tope de sombra degrada, no bloquea**: si ya hay 6 con sombra, la nueva se crea **sin**
  sombra en lugar de rechazarse.
- **Regla anti-oscuridad**: `desactivar_lejanas()` no apaga nada si **todas** las luces quedarían
  fuera de radio (no se deja la escena a oscuras por el descarte por distancia).
- **Flicker determinista** (G56/H63): fase derivada de `hash(semilla, tipo, posición)`;
  `flicker(entrada, t)` acotado a `[1-amplitud, 1+amplitud]`. Catálogo validado por
  `catalogo_valido()` contra `FLICKER_HZ_MAX = 2.0` y `FLICKER_AMPLITUD_MAX = 0.15`.
- Catálogo de tipos: `luz_farol`, `luz_fuego`, `luz_cristal`, `linterna` con sus Hz/amplitud/
  sombra/alcance/energía.
- `stats()` con métricas para QA/profiler (activas, libres, creadas, descartes, rechazos).

Suite escrita: `game/isla-ancestral/scripts/world/test_light_pool_m49.gd` (6 bloques, piso de 34
checks) cubriendo límites, reutilización, topes, descarte, flicker y catálogo.

## ⚠️ Bloqueo: no pude ejecutar la suite (ajeno, no es mi código)

Verificación por varias vías antes de concluir:

1. `light_pool.gd` **compila limpio** con `--check-only --script` (0 errores).
2. Una suite ajena (`test_fishing.gd`, M34) **sí corre** en el mismo proyecto con el mismo
   comando → el problema no es mi script ni el comando.
3. Copiar mi suite fuera de `scripts/world/` tampoco funcionó → no es la carpeta.
4. El stdout del proceso muestra el **bootstrap completo** del proyecto (NPCManager, fauna,
   DayNightCycle, analytics) y termina **sin llegar a mi script**.
5. El stderr muestra la causa raíz, todo de archivos que no toqué:
   - `Parse Error: Could not parse global class "BlockType" from res://scripts/world/block_type.gd`
   - `SCRIPT ERROR: Invalid call. Nonexistent function 'get_height' in base 'Nil'`
     (`core/terrain_locator.gd:50` → `world/world_generator.gd:23`), repetido por
     `fauna/jabali_npc.gd` y `fauna/tortuga_npc.gd` **en cada `_physics_process`**.
   - Ese bucle llenó el log a **255 MB y 411 MB** en dos intentos (tuve que matar el proceso).

## Saldo honesto

- **Código de M49: entregado y compilando.**
- **Verificación en headless: bloqueada por el bootstrap ropo de otro agente.**
- **No marqué `[x]`** E41/E42/E43 en el checklist: la regla del proyecto es que un `[x]`
  necesita testeo, y acá no pude correrlo. Los dejo como estaban hasta poder ejecutar.

## Acción solicitada al director

Que se le avise al agente responsable de `scripts/world/block_type.gd` (modificado sin commitear,
con `BlockType` sin parsear) y de `world/world_generator.gd:23` + `core/terrain_locator.gd:50`
(`get_height` sobre `Nil`), porque **rompe el arranque headless de todo el proyecto** y con él
cualquier suite nueva. En cuanto eso se arregle, mi suite corre sin cambios.
