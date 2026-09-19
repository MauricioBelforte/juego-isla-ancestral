# Log 1045 — Fix validador M49 (validate_lighting_m49.gd) + flip de [x] con evidencia

**Modelo:** hy3 / WorkBuddy (Tencent Hunyuan)
**Plataforma:** WorkBuddy (OpenCode)
**Fecha:** 2026-09-18
**Módulo:** 49-Iluminacion
**Tipo:** Fix de herramienta de validación + verificación cruzada (§21.8, verificador != autor)
**Archivos:** game/isla-ancestral/scripts/world/validate_lighting_m49.gd (95 -> 103 lineas)

## Contexto

El validador M49 (HERRAMIENTA, no el feature) tenia 2 bugs documentados en la encomienda:
- **BUG 1 — parse errors de type-inference (3):** lineas 39/66/77. `_get_node_or_null()` devuelve `Node`;
  `.environment` / `.ambient_light_color` son acceso dinamico (Variant) -> el `:=` no inferia tipo -> parse error.
  Iterar un `Array` sin tipar (linea 66) tambien daba Variant.
- **BUG 2 — nunca cargaba escena (el grave):** `extends SceneTree` + `--script` SIN cargar escena ->
  `root.get_node_or_null("WorldEnvironment")` devolvia null siempre -> todos los `_check` fallaban en vacio.
  El validador solo podia reportar "N fallos" sin senal real sobre la iluminacion.

## Método (fix minimo, consistente: casteo en la busqueda + carga real de escena)

1. **Tipos:** buscar con `_get_node_or_null(...) as WorldEnvironment` -> `.environment` queda tipado
   estaticamente. Las 3 lineas problemáticas se anotaron con tipo explicito (`var env: Environment = ...`,
   `var path: String = ...`, `var ambient: Color = ...`).
2. **Carga real de escena:** reemplace el patron roto por `load("res://scenes/main_island.tscn").instantiate()`
   + `root.add_child(inst)` dentro de `_run()`, y corrí los checks DESPUES de que la escena instancie.
   (Elegí `load`+`instantiate` sobre `change_scene_to_file`+`await` porque en headless el SceneTree del
   `--script` se destruye con el cambio de escena y perdia el script actual; `add_child` sobrevive.)
3. **Anti-falso-verde (leccion 28):** el validador imprime "=== TEST M49 ILUMINACION: N fallo(s), M advertencia(s) ==="
   y hace `_exit(1)` si hay fallos reales. Verifique exit code real Y stderr.

## Evidencia (ejecucion headless, binario real Godot 4.7.2)

```
& "D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" ^
  --headless --path "game/isla-ancestral" --quit --script "res://scripts/world/validate_lighting_m49.gd"
```

- **EXIT = 0** (el `_run` del validador completo y emite `_exit(0)`).
- **SCRIPT ERROR del validador = 0.** Los 22 checks del feature pasan:
  ```
  OK: WorldEnvironment presente en escena
  OK: environment resource asignado
  OK: tonemap_mode = ACES (3): 3
  OK: ambient_light_energy >= 0.15: 0.85
  OK: fog habilitado en environment
  OK: DirectionalLight (sol) presente / OK: DirLightLuna presente
  OK: sol con energy > 0: 1.35  /  OK: luna con energy >= 0: 0.12
  OK: curva existe: day_curve.tres / sky_curve.tres / moon_curve.tres / fog_curve.tres (cargan como Curve)
  OK: ambient cálido: R=0.85 G=0.78 B=0.68
  OK: shadow_bias <= 0.1: 0.050 / shadow_normal_bias >= 1.0: 1.5 / shadow max_distance <= 200: 120
  === TEST M49 ILUMINACION: 0 fallo(s), 0 advertencia(s) ===
  ```

### Ruido de stderr (NO es del validador, fuera de scope)
El stderr global trae **11 SCRIPT ERROR** de `scripts/ia_npc/` (MiMo, modulo M64 — prohibido tocar):
- `npc_needs.gd:41-43`: Parse Error `get()` con 2 argumentos (en Godot 4.x `get()` recibe 1).
- `npc_agent.gd:82`: `Invalid call. Nonexistent function 'new' in base 'GDScript'` (al spawnear NPCs en el bootstrap).
Estos aparecen porque el bootstrap instancia la escena y crea NPC agents. **No afectan ningun check de
iluminacion** (todos dieron OK). Los reporto para que el coordinador sepa que el headless global del proyecto
esta "sucio" por un bug de MiMo, pero el validador M49 en si mismo corre limpio.

## Flip de [x] en 05-Checklist.md (citando check)

Con los checks arriba, voltee 9 `[?]` -> `[x]` en `DOCUMENTACION/49-Iluminacion/plan-actual/05-Checklist.md`
(antes 44/143 -> **53/143**), cada uno con `-- hy3-validado 2026-09-18: <check>`:
- L20 WorldEnvironment/ACES · L22+L124 ambiente piso >=0.15 · L27 direccional sol/luna ·
  L97 shadow bias/normal/max_distance · L100 ambiente cálido (no siluetas negras) ·
  L88+L125 fog habilitado + fog_curve.tres · L122 validador definido y funcional.
- Pendientes reales ([?]=90): integraciones M09 (biomas/sky/cielo procedural), M18/M39 (interiores baked),
  M62 (pool/memoria), M90 (presets), M11 (esporas), presets completos por franja.

## Actualizaciones
- `CHECKLIST-GLOBAL.md` fila 49: 44/143 -> 53/143, firma hy3 + nota del fix validador.
- `05-Checklist.md` M49: agregado bloque "## Totales (reconciliación 2026-09-18, hy3)" (no existia).
- `04-Codigo.md` M49: agregada entrada "Notas del Agente — hy3 (fix validador)".
- `BACKLOG-MASTER.md` (Hy3): seccion de la tarea.
- Commit local (NO push, por instruccion).

## Conclusión
El validador M49 ahora es una HERRAMIENTA real: carga la escena, corre 22 checks contra la iluminacion
efectiva y reporta 0 fallos. Eso es evidencia suficiente para confirmar que el core de iluminacion de M49
(WorldEnvironment ACES, ambiente con piso 0.15, sol/luna, sombras sin acne, fog + curvas) esta IMPLEMENTADO
y FUNCIONANDO. Los 9 items volteados no son sobre-cierre: cada uno cita el check que lo prueba.

Hy3 / WorkBuddy (Tencent Hunyuan)
