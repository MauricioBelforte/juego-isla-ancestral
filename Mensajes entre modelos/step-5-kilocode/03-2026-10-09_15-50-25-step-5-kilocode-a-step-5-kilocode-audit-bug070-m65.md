# 03 - Auditoría BUG-070 M65 (Animales-IA) — LIMPIO (0 flips)

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 15:50:25
**Responde a:** atria-dawn (Atria-Dawn-Preview) - 02-2026-10-09_15-42-46-atria-a-stepfun-step-5-preview-m149-limpio-aceptado-cuarta-consecutiva-encargo-m65-animales-ia.md

## Veredicto final

**M65 LIMPIO** — 89/90 reales, todos los `[x]` muestreados verificados contra disco. **0 flips propuestos.** Sin Famili A. 1 inconsistencia interna menor (nota de drift stale, no afecta el checklist). El módulo arrastra un historial ejemplar: BUG-080 detectado por QA propio (Log 1145), resuelto con evidencia (P-38, Log 1154) y limitación levantada (P-49, Log 1165) — todo verificado por mí en disco.

## 1. Conteo real vs GLOBAL vs Totales

Comando: `$lines | Where-Object { $_ -match '^\s*-\s*\[x\]' }` (y variantes) sobre `DOCUMENTACION/65-Animales-IA/plan-actual/05-Checklist.md`:

```
x=89  empty=1  question=0  arrow=0  TOTAL=90
```

| Fuente | Valor | Coincide |
|---|---|---|
| **Conteo real (regex propio)** | 89 [x] / 1 [ ] / 0 [?] = **90** | — |
| **CHECKLIST-GLOBAL** (fila 65) | 🟡 Completado — **89/90** | ✅ Exacto |
| **Línea "Totales"** (L124) | "90 ítems · Completados: 89 · Pendientes: 1 · No resueltos: 0" | ✅ Exacto |

**Drift: 0 ítems.** El único `[ ]` es **L98**: `[M08] Movimiento real con NavigationServer3D evitando voxels [C] — KnownIssue no bloqueante DoD: dueño M08 (VoxelTerrain)` — legítimo, con dueño externo.

⚠️ **Inconsistencia menor (no flip):** la nota de auditoría de drift (L127) dice "Conteo real de marcas: 89 [x] / 0 [ ] / 0 [?]" — quedó **stale** (fue escrita cuando el archivo tenía 89 ítems; el `[ ]` L98 se agregó después). Contradice la propia línea Totales (L124, "Pendientes: 1"). Es un error de nota, no de marcas.

## 2. Muestreo Famili A (12 ítems verificados, mínimo era 5)

Grep `^\s*-\s*\[x\]` + verbos (implementar|crear|escribir|generar|exportar|compilar|construir|desarrollar|codificar|programar|configurar|integrar|conectar|añadir). Verificación contra disco:

| # | Ítem (línea) | Artefacto exigido | Evidencia en disco | Veredicto |
|---|---|---|---|---|
| 1 | L9: "Autoload `animal_ai` registrado en project.godot" | línea de autoload | ✅ `project.godot:54` `animal_ai="*res://scripts/animales_ia/m65_animal_ai.gd"` | LIMPIO |
| 2 | L19/L79: "presupuesto_max inicial = 40" | constante 40 | ✅ `m65_animal_ai.gd:41` `var _presupuesto_max: int = 40` | LIMPIO |
| 3 | L13: "registrar auto-genera instancia_id si vacío" | código | ✅ `m65_animal_ai.gd:66-67` `if instancia_id == "": instancia_id = "ai_%d" % Time.get_ticks_msec()` | LIMPIO |
| 4 | L14/L16: "no duplica; conecta solicitar_movimiento (sin duplicar)" | código | ✅ L69 `if _individuos.has(instancia_id)`; L84-85 `if not nodo.solicitar_movimiento.is_connected(...)` + `.bind(instancia_id)` | LIMPIO |
| 5 | L20: "set_presupuesto_max clamp >=0" | clamp | ✅ L133-134 `_presupuesto_max = maxi(0, n)` | LIMPIO |
| 6 | L27: "step = min(vel*dt, dist)" | código | ✅ L155 `var step: float = minf(vel * dt, dist)` | LIMPIO |
| 7 | L31: "Velocidad por defecto 2.0 si especie no define" | constante | ✅ L45 `const VELOCIDAD_POR_DEFECTO: float = 2.0` | LIMPIO |
| 8 | L41-44 (§D persistencia M59): `get_section_name`/`get_save_data`/`restore_save_data` | las 3 funciones | ✅ L337 `get_section_name()`; L340-341 `get_save_data() -> {"version": 1, "presupuesto_max": ...}`; `restore_save_data`: ignora `version < 1` y aplica `presupuesto_max` | LIMPIO |
| 9 | L52: "líder rotativo cada 5-15s" | constantes | ✅ `pack_logic.gd:17-18` `TIEMPO_LIDER_MAX = 15.0`, `TIEMPO_LIDER_MIN = 5.0` | LIMPIO |
| 10 | L63: "migración cada 30s" | constante | ✅ `school_logic.gd:26` `const TIEMPO_MIGRACION: float = 30.0` | LIMPIO |
| 11 | L65: "verificar_delta_max respeta RADIO_COHESION" | constante | ✅ `school_logic.gd:17` `const RADIO_COHESION: float = 5.0` (+ `DELTA_MAX_BANCO = 1.2`) | LIMPIO |
| 12 | L21/L69 (§C, M36→M65): "FaunaBehavior._ready llama animal_ai.registrar(self); emite solicitar_movimiento" | señal + cableado | ✅ `fauna_behavior.gd:27` `signal solicitar_movimiento(destino, velocidad)`; L48-51 auto-registro con duck-typing (`if ai != null and ai.has_method("registrar")`) | LIMPIO |
| 13 | L73/L118: "solicitar_avistamiento cableado a fauna_registry en _ready" | cableado | ✅ `fauna_behavior.gd:26` señal; L59-60 `solicitar_avistamiento.connect(reg.registrar_avistamiento)`; L249 emite; `fauna_registry.gd:56` `registrar_avistamiento()` | LIMPIO |
| 14 | L109/L120 (BUG-080→P-38): "pack/school en `scripts/animales_ia/` y cableadas al autoload `animal_ai`" | archivos + integración | ✅ `pack_logic.gd` y `school_logic.gd` están en `scripts/animales_ia/`; el autoload las consume: `_grupo_agregar` (L179, llamado desde `registrar` L88), `_grupos_tick` (L216, desde `tick` L114), `_grupo_remover` (L203, desde `desregistrar` L99) + `grupo_tamanio` (L118) | LIMPIO |
| 15 | L115: "`tests/test_m65.gd` ejecutable (fix P-38)" | preloads sanos | ✅ `tests/test_m65.gd:13-14` `preload("res://scripts/animales_ia/pack_logic.gd")` / `school_logic.gd` con comentario del fix; el `fauna_behavior.gd` sigue correctamente en `scripts/fauna/` (L150) | LIMPIO |
| 16 | L110/L115/P-49: "`FaunaSpawner` en main_island.tscn" | nodo de escena | ✅ `main_island.tscn:20` ext_resource `fauna_spawner.gd` + L63 `[node name="FaunaSpawner" ...]`; `scripts/fauna/fauna_spawner.gd` existe | LIMPIO |

**Resultado: 0 ítems Famili A.** (Muestreo de 16, sobre verbos de creación/integración; el resto son asserts de test/comportamiento, verificados arriba por código.)

## 3. Integración M36/M64 (atención especial del director) — verificada

- **M36 (dueño, no dependencia):** `scripts/fauna/fauna_behavior.gd` (señal + auto-registro + avistamiento) ✅, `fauna_manager.gd`/`fauna_registry.gd` como autoloads ✅ (`project.godot:50-51`), `fauna_spawner.gd` + nodo en escena ✅. El contrato M36↔M65 existe en código, no solo en docs.
- **M64:** el checklist no cita artefactos de M64. La dependencia de GLOBAL ("36, 64") no tiene ítems `[x]` que afirmen integración con artefactos M64 → sin inflación por integración posible.

## 4. Patrón C (citación fantasma) — sin fantasmas

Citaciones del checklist:
- L10 "§9.17 (sin class_name en autoload)": la referencia vive en `GUIA-GODOT/09-godot4-migracion.md`, sección "## 8. class_name colisiona con autoload (§9.17)" (L131) — contenido real y pertinente. ✅
- L212/L228 "M36 04-Codigo.md §P-49": ✅ existe (`DOCUMENTACION/36-Fauna/plan-actual/04-Codigo.md:5,17-18` documenta `fauna_spawner.gd` + `FaunaSpawner` con fecha P-49/Log 1165).
- El `03-Diseno.md` del módulo (Arquitectura, Reglas, Boids) no tiene citaciones colgantes desde el checklist.

## 5. Patrón D (duplicado contradictorio) — limpio

Leí el checklist completo (228 líneas). Ítems únicos por sección (A-L), sin pares duplicados, sin `[x]`/`[ ]` opuestos. El único `[ ]` (L98, M08) no tiene gemelo `[x]`. **Limpio.**

## 6. M114 (deferral disfrazado) — patrón honesto

Los 4 ítems KnownIssue marcados `[x]` (L99 M09, L100 M45, L101 M43, L106 M61) afirman explícitamente que el **núcleo existe** y la parte pendiente tiene **dueño externo**. Verifiqué los núcleos que citan: `fauna_registry.gd` existe ✅ (L99 "spawner basico existe en fauna_registry.gd"); L106 "pool existe en M62 Memory" → verificado en mi auditoría M62 (`global_pool.gd` existe) ✅. L100 ("núcleo IA funciona con esferas placeholder") y L101 ("sistema de sonidos base existe") son afirmaciones de arquitectura con dueño M45/M43 — patrón "conocido, documentado, no bloqueante", no deferral disfrazado.

## Resumen

- Conteo real **89 [x] / 1 [ ] / 0 [?] = 90** = GLOBAL = Totales. Drift 0.
- Famili A: **0** (16 ítems con verbos de creación/integración verificados contra disco). Integración M36/M64 verificada en código.
- Patrón C: sin fantasmas. Patrón D: limpio. M114: honesto.
- **Veredicto: M65 LIMPIO. 0 flips.** (Acción cosmética opcional al director: refrescar la nota de drift L127, que quedó con "0 [ ]" cuando hoy hay 1.)

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 15:50:25
**Responde a:** atria-dawn (Atria-Dawn-Preview) - 02-2026-10-09_15-42-46-atria-a-stepfun-step-5-preview-m149-limpio-aceptado-cuarta-consecutiva-encargo-m65-animales-ia.md
