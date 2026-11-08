**Modelo:** Reflection Beam 1.0
**Plataforma:** Kilo Code

# Reporte de análisis de escenas .tscn / .tres

**Fecha:** 2026-11-08
**Proyecto:** juego-isla-ancestral
**Ruta analizada:** `game/isla-ancestral/scenes/`

## 1. Alcance del análisis

- Archivos `.tscn` encontrados en `scenes/`: **49**
- Archivos `.tres` encontrados en `scenes/`: **0** (no hay recursos `.tres` directamente en esa carpeta)
- Se excluyeron del análisis los directorios `addons/`, `Obsoletos/`, `.kilo/worktrees/` y backups de codificación.

## 2. Hallazgo (1) — Rutas rotas a recursos faltantes

**Resultado: 0 rutas rotas.** Todos los `res://` referenciados por `ext_resource`/`path` apuntan a archivos existentes en disco (scripts `.gd`, escenas `.tscn`, modelos `.glb`, etc.). Los sidecar `.uid` (Godot 4.4+) también existen para cada `uid://` declarado.

**Observación secundaria (no bloqueante):** se detectaron **16 escenas** cuyo campo `load_steps` declarado no coincide con la cuenta real de recursos (`ext_resource + sub_resource + 1`). Godot recalcula este valor al cargar, pero la inconsistencia ensucia el diff y puede enmascarar errores de carga en versiones estrictas.

| Archivo | Línea | load_steps declarado | Esperado | ext | sub |
|---|---|---|---|---|---|
| scenes/main.tscn | 1 | 6 | 8 | 4 | 3 |
| scenes/main_simple.tscn | 1 | 4 | 7 | 3 | 3 |
| scenes/main_test.tscn | 1 | 8 | 10 | 3 | 6 |
| scenes/main_test2.tscn | 1 | 5 | 7 | 3 | 3 |
| scenes/minimal_test.tscn | 1 | 3 | 2 | 1 | 0 |
| scenes/test_runner.tscn | 1 | 3 | 2 | 1 | 0 |
| scenes/npc/npc_agent.tscn | 1 | 3 | 4 | 1 | 2 |
| scenes/player/Player.tscn | 1 | 9 | 10 | 8 | 1 |
| scenes/terrenos/particulas_agua.tscn | 1 | 2 | 1 | 0 | 0 |
| scenes/terrenos/particulas_arena.tscn | 1 | 2 | 1 | 0 | 0 |
| scenes/terrenos/particulas_barro.tscn | 1 | 2 | 1 | 0 | 0 |
| scenes/terrenos/particulas_ceped.tscn | 1 | 2 | 1 | 0 | 0 |
| scenes/terrenos/particulas_nieve.tscn | 1 | 2 | 1 | 0 | 0 |
| scenes/terrenos/particulas_pavimento.tscn | 1 | 2 | 1 | 0 | 0 |
| scenes/terrenos/particulas_rocas.tscn | 1 | 2 | 1 | 0 | 0 |
| scenes/ui/hud.tscn | 1 | 10 | 11 | 10 | 0 |

Tampoco se detectaron referencias `ExtResource(...)`/`SubResource(...)` a ids no declarados (0 casos).

## 3. Hallazgo (2) — Nodos huérfanos o sin padre

**Resultado: 0 nodos huérfanos.** Para cada escena se reconstruyó la jerarquía a partir del atributo `parent=` de cada `[node]`:

- El nodo raíz no declara `parent` (correcto).
- Todo nodo hijo declara un `parent` que resuelve a un nodo existente (path completo verificado, incluyendo anidamientos como `CameraRig/CameraSpring`).
- No se encontraron nodos sin `type` ni `instance` (0), ni nodos raíz con `parent` declarado (0).

## 4. Hallazgo (3) — Dependencias circulares de instanciación

**Resultado: 0 ciclos.** Grafo de instanciación (escena → escena instanciada vía `instance=ExtResource(...)` de tipo `PackedScene`):

- `scenes/main.tscn` → `scenes/player/Player.tscn`
- `scenes/main_island.tscn` → `scenes/player/Player.tscn`
- `scenes/main_simple.tscn` → `scenes/player/Player.tscn`
- `scenes/main_test.tscn` → `scenes/player/Player.tscn`
- `scenes/main_test2.tscn` → `scenes/player/Player.tscn`
- `scenes/player/Player.tscn` → `assets/3d/media/45-Arte3D_jugador_voxel.glb` (recurso, no escena)

No hay auto-instanciación ni ciclos A→B→A. La única dependencia compartida es `Player.tscn`, instanciada por 5 escenas principales, sin cierre circular.

## 5. Acciones de verificación sugeridas

1. **Corregir los `load_steps` desfasados** en las 16 escenas listadas (línea 1) para que coincidan con `ext+sub+1`, y revalidar con el editor de Godot (abrir cada escena y guardar) para descartar warnings de carga. Priorizar `main.tscn`, `main_island.tscn`, `player/Player.tscn` y `ui/hud.tscn` por ser escenas de producción.
2. **Ejecutar una verificación dinámica en Godot**: abrir el proyecto, correr la escena principal (`main.tscn` / `main_island.tscn`) y revisar la consola (`get_debug_output`) buscando errores de instanciación, nodos huérfanos en runtime y fallos de carga de `Player.tscn`; complementar con un barrido de `godot --headless --check-only` (o el validador del proyecto) sobre todas las `.tscn` de `scenes/`.

## 6. Conclusión final

El conjunto de escenas de `game/isla-ancestral/scenes/` está **íntegro** respecto a los tres puntos auditados: no se detectaron rutas rotas a recursos, ni nodos huérfanos/sin padre, ni dependencias circulares de instanciación. El único hallazgo material es una inconsistencia cosmética/operativa en `load_steps` en 16 archivos (línea 1), que no rompe la carga pero conviene normalizar. Se recomienda aplicar las dos acciones de verificación anteriores antes de considerar el módulo de escenas como cerrado.
