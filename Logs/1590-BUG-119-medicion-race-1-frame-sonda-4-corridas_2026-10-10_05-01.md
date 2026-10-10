# Log 1590: BUG-119 — medición de la causa (race de 1 frame, 7 corridas) + propuesta de fix sin implementar

**Fecha:** 2026-10-10
**Hora:** 05:01
**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

## Resumen

Encargo del director (msg 101, 2026-10-10 04:31): **medir con corridas frías/calientes** el warning
`[M163] IncenseSpawner: 0 puntos creados (24 fallas de altura en centro (2320.0, 2300.0))` que aparece
en cada boot del runner, **clasificar la causa** (race / lógica de altura / datos) y **proponer un fix
SIN implementarlo** (la autorización llega después de ver la causa raíz).

Resultado: **causa = RACE de orden de inicialización, ventana de EXACTAMENTE 1 frame**. No es lógica
de altura ni datos/cache. El fix defensivo de 2026-10-08 (retry por frame) funciona en 7/7 boots
medidos; el warning inicial es honesto y por diseño (`incense_spawner.gd:71`), pero confuso como
señal de bug porque se imprime ~30 ms antes del éxito que lo resuelve.

## Cambios Realizados

### 1. Investigación de código (solo lectura)

- `scripts/enchantment/incense_spawner.gd`: `_ready:53` lanza el intento sincrónico (`_spawneear`);
  si queda en 0 puntos arma retry en `_process` (1 probe/frame, timeout 8000 ms, `incense_spawner.gd:42-90`).
  El warning `:138` es el intento INICIAL honesto; al final del retry exitoso imprime por stdout
  `:141` ("6 puntos en montaña"). Las dos salidas van a streams distintos (stderr/stdout) — por eso
  leyendo solo el stderr del runner parece un fallo total.
- `scripts/core/terrain_locator.gd:45-52`: `get_height` devuelve -1 SOLO si `_terrain`/generador no
  está resuelto; luego pregunta al generador analítico (`_get_island_gen().get_height`) — **no lee
  geometría voxel ni cachés**, por diseño no puede haber fallo por "datos faltantes".
- `scripts/main_island.gd:15-27`: `_ready` → `_crear_shaman()` (`:24`) y `_crear_incense_spawner()`
  (`:25`, add_child en `:441`) corren EN EL MISMO FRAME del montaje de la escena.
- `scripts/core/bootstrap.gd:144-168`: en arranque `--script` (runner parent y cada subprocess de
  suite) `current_scene` es null → `change_scene_to_file` (`:168`) → montaje diferido → esa es la
  rama donde ocurre el race. En arranque normal (escena principal precargada) bootstrap omite la
  recarga (`:164-166`) y no hay race (por eso el juego normal siempre spawneó bien).
- `scripts/enchantment/shaman_npc.gd:13-61`: el chaman YA tiene el mismo retry (autorizado msg 74):
  cae a y=35 (fallback de `main_island.gd:430`) y se reposiciona a y=17 al resolverse.
- `tests/run_tests.gd`: cada suite corre como SUBPROCESO con stdout/stderr propios; el warning del
  runner sale del boot del proceso PADRE (mismo camino bootstrap).

### 2. Sonda de medición creada

`game/isla-ancestral/tests/_sonda_bug119.gd` (SceneTree, **no es suite**: no empieza con `test_`,
el discovery del runner la ignora). Mide frame/t de: locator presente, escena montada,
`_terrain` resuelto, `get_height(2320,2300) >= 0` (+valor), spawner con puntos, chaman fuera del
fallback y=35. Se corrió con `--headless --path game\isla-ancestral --script res://tests/_sonda_bug119.gd`.
**Se conserva en `tests/`** como herramienta reutilizable para verificar el fix cuando el director
lo autorice (si prefiere eliminarla, basta borrar el archivo; ningún sistema depende de él).

### 3. Medición: 4 corridas sonda + 3 boots runner previos = 7/7 idénticos

| Corrida | Caché | frame montaje | frame resolución | Δ | Puntos | Fallas | h | chaman y |
|---|---|---|---|---|---|---|---|---|
| Sonda C1 | caliente | 2 (951 ms) | 3 (977 ms) | 26 ms | 6 | 24 | 16 | 17.0 |
| Sonda C2 | caliente | 2 (1484 ms) | 3 (1516 ms) | 32 ms | 6 | 24 | 16 | 17.0 |
| Sonda F1 | **fría** (borrada `.godot/imported`) | 2 (1863 ms) | 3 (1899 ms) | 36 ms | 6 | 24 | 16 | 17.0 |
| Sonda C3 | caliente (tras restaurar import) | 2 (1644 ms) | 3 (1681 ms) | 37 ms | 6 | 24 | 16 | 17.0 |
| runner_bug052_out/err (×2) | caliente | — | — | — | 6 | 24 | — | 17.0 |
| runner_m3_out/err | caliente | — | — | — | 6 | 24 | — | 17.0 |

Secuencia constante en TODAS: frame 1 `locator` presente (sin terreno) → frame 2 la escena monta,
chaman spawneado en y=35 (fallback), spawner ejecuta el intento sincrónico → **24 fallas → warning
stderr** → frame 3 `TerrainLocator._process` ya resolvió `_terrain` → `get_height = 16` → retry del
spawner crea los 6 puntos (stdout) y el chaman se reposiciona a y=17. **Nunca** hubo el warning de
timeout de 8000 ms (se consume ~0,4 % del presupuesto).

Evidencia: `TEMP/opencode/sonda119_{c1,c2,c3,f1}_{out,err}.txt`, `runner_bug052_{out2,err2}.txt`,
`runner_m3_{out,err}.txt`.

### 4. Clasificación de la causa (entregable)

- **RACE de orden de inicialización — CONFIRMADO.** La ventana es 1 frame: `_crear_incense_spawner`
  (main_island `_ready`) corre antes de que `TerrainLocator._terrain` se resuelva (se resuelve en su
  propio `_process`, al frame siguiente al montaje). `get_height = -1` = "nodo sin resolver", no
  altura inválida.
- **NO es lógica de altura:** al resolverse, h=16 en el centro de la montaña — coherente con el
  chaman (y=17 = h+1) y con la verificación histórica "Y esperada ~17" (11-BUGS L228).
- **NO son datos ni caché:** la corrida fría (caché de importaciones borrada, 1056→0 archivos) se
  comporta **frame idéntico** a las calientes; además `get_height` consulta el generador analítico,
  no la geometría voxel. El factor correlacionado con "cada boot del runner" es `--script`, no la
  caché: TODOS los boots `--script` pasan por `change_scene_to_file` (bootstrap.gd:168).
- Nota de confusión (origen del reporte): el warning va a **stderr** y el éxito a **stdout** —
  leyendo solo el stderr del runner se ve "0 puntos creados" y no se ve "6 puntos en montaña".

### 5. Estado del entorno tras la medición

- Corrida F1 borró `game/isla-ancestral/.godot/imported`; la runtime NO la regenera (medido: errores
  `Cannot open file ... .scn` masivos). Restaurada con `godot --headless --path ... --import`
  (RC 0): 974 archivos / 10,4 MB (las 82 diferencias vs el conteo previo de 1056 eran huérfanos).
  Verificación: sonda C3 con **0** errores `Cannot open file` → entorno sano.
- Lección nueva para la guía: **borrar `.godot/imported` en Windows requiere regenerar con
  `--import`**; el flag `--quit-after`/runtime no lo hace (documentar en GUIA-GODOT si se confirma
  con el director).

### 6. Propuesta de fix (SIN IMPLEMENTAR — espera autorización, msg 101)

- **Opción A (causa raíz, toca flujo de carga sensible):** en `main_island.gd::_ready`, posponer
  `_crear_shaman()` y `_crear_incense_spawner()` (y cualquier spawn que dependa de TerrainLocator)
  hasta que `get_height(centro) >= 0` (un frame de espera / patrón M50). Elimina el intento fallido,
  el warning y el transitorio y=35. Riesgo: `main_island.gd` es zona de carga crítica — requiere
  runner completo + gate templos.
- **Opción B (cosmético, mínima y local):** en `incense_spawner.gd`, cuando el retry queda armado,
  degradar el warning inicial a `print` (o moverlo al timeout). Mismo tratamiento opcional en
  `shaman_npc.gd`. No cambia flujos; solo elimina la señal falsa de bug. Riesgo: casi nulo.
- **Opción C (dejar como está):** el warning es honesto y documentado (`incense_spawner.gd:71`);
  el runner convive con él. Riesgo: sigue confundiendo reportes (costó este round trip).
- **Recomención:** Opción B ahora (señal limpia en runners) + evaluar A como mejora de flujo si el
  director quiere eliminar también el transitorio y=35 del chaman.
- Discrepancia a cargo del director: `11-BUGS.md` tiene BUG-119 como `[x] Resuelto 2026-10-08`
  (sección 7), pero el msg 99 lo listó como "nuevo". La medición confirma que el fix de 2026-10-08
  funciona; lo que queda es ruido del warning (Opción B) o el fix de causa raíz (Opción A). No toqué
  la entrada del bug ni ninguna marca de checklist (READ-ONLY).

## Archivos Modificados/Creados

- `game/isla-ancestral/tests/_sonda_bug119.gd` — CREADO (sonda de medición, no es suite).
- `game/isla-ancestral/.godot/imported/` — borrada y regenerada (caché de importaciones, no versionada).
- `Logs/NUMEROS_DISPONIBLES.txt` — 1590 consumido (protocolo §6.1.a).
- `DOCUMENTACION/TAREAS-POR-MODELO/mimo-v2.6-flash-free/BACKLOG-MASTER.md` — reserva de log 1590 anotada.
- NO se tocó ningún script de producción, ningún `11-BUGS.md` (más allá de lo ya hecho en M3), ninguna
  marca de checklist, ningún canal ajeno. Sin commits/stage/push.
