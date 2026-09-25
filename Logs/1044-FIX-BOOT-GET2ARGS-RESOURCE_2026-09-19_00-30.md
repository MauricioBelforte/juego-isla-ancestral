# Log 1044: Fix de boot del proyecto — .get() de 2 args sobre Resource (3 sitios)

**Fecha:** 2026-09-19
**Hora:** 00:30
**Modelo:** Atria-Dawn-Preview (Shanghai AI Laboratory)
**Plataforma:** Kilo Code

## Resumen

El proyecto **no arrancaba limpio**: tres llamadas `.get(clave, default)` con 2 argumentos sobre
variables tipadas como `Resource` provocaban `Parse Error: Too many arguments for "get()" call.
Expected at most 1 but received 2`, lo que rompía la compilación en cascada
(`Failed to compile depended scripts`) y contaminaba **todos** los runs headless del repositorio
con errores ajenos a los módulos bajo prueba (falso-verde / falso-rojo para cualquier agente).

Causa raíz: `Resource` extiende `Object`, y `Object.get()` admite **1 solo** argumento. Los
autoescribieron acceso tipo `Dictionary.get(clave, default)`. Todos los sitios ya tenían un guard
`!= null` explícito, así que el segundo argumento era redundante.

## Cambios Realizados

1. `game/isla-ancestral/scripts/ia_npc/npc_agent.gd:199` — `profile.get("job", "")` →
   `profile.get("job")` (el guard de la línea anterior ya asegura non-null).
2. `game/isla-ancestral/scripts/ia_npc/npc_agent.gd:205` — `pp.get("job", "")` → guard explícito
   `pp.get("job") != null and str(pp.get("job")) == my_job` (mismo patrón que la línea 198).
3. `game/isla-ancestral/scripts/ia_npc/npc_needs.gd:41-43` — `cfg.get("rate", actual)` ×3 →
   lectura en `var v` + `if v != null: campo = v`, conservando exactamente la semántica de
   fallback del original.

## Verificación

Binario real: `D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe`
```
--headless --path game/isla-ancestral --quit --script res://scripts/world/test_ramps_color_m49.gd
```
- **Antes:** `SCRIPT ERROR: Parse Error` ×3 (npc_needs.gd:41/42/43) + npc_agent.gd:199/205 +
  `Failed to compile depended scripts` + `Failed to load script npc_agent.gd`.
- **Después:** **0 SCRIPT ERROR, 0 Parse Error, 0 Compile Error, 0 "Failed to load"** en todo el
  boot. El run completa: villagers se registran/desregistran, analytics `sesion_fin` correcto.
  Solo quedan warnings benignos de limpieza (66 ObjectDB leaked at exit, 9 resources in use —
  leaks de shutdown, no de boot).

## Notas

- **Zona ajena:** `scripts/ia_npc/` es territorio M64 (MiMo V2.5, 🔵 en curso). Toqué 2 archivos
  por necesidad de desbloqueo sistémico del boot — **no cambia features de M64**, solo reparación
  de sintaxis. MiMo debe hacer `git pull`/releer antes de seguir para no pisar el fix.
- `validate_lighting_m49.gd` aún tiene SUS 3 parse errors de type-inference (env/path/ambient) —
  tarea delegada a hy3 (es bug del validador, no del feature). No toqué ese archivo.
- Quedan los warnings de leak de shutdown (ObjectDB/resources) — registrado como observación
  menor, no bloquea.

## Archivos Modificados

- `game/isla-ancestral/scripts/ia_npc/npc_agent.gd` (2 edits)
- `game/isla-ancestral/scripts/ia_npc/npc_needs.gd` (1 edit)
