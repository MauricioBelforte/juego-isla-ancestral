# Log 831: M27-Islas-Del-Mundo iter 1 — Núcleo data-driven del archipiélago 1+12

**Fecha:** 2026-09-11
**Hora:** 23:05
**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Módulo:** M27-Islas-Del-Mundo
**Reserva:** `Logs/reservas/831-DeepSeek-V4.1-Flash-M27.txt`
**Entrada:** M27 🟡 "Con dudas", **9/171** implementado (dueño previo `deepseek-v4-flash-vision-exp`, última actividad 2026-09-02 21:30 → **9 días inactivo**)
**Visión:** V0 (módulo sin necesidad de recursos visuales para el núcleo de datos)

## Resumen

M27 tenía diseño completo (4 componentes, 4 flujos, catálogo de 13 islas) pero el código real era un **schema JSON de 4 islas** (`islas_schema.gd` + `data/islas/islas.json`) + un verificador de coherencia con el mapa. **El archipiélago 1 + 12 del diseño no existía.** Se reclamó por **§21.4.7** (dueño inactivo > 24 h) y se implementó el **núcleo data-driven completo**.

**Resultado: 171 checks / 0 fallos** (estable en 3 corridas). Módulo: **83/192 `[x]` · 93 `[?]` con dueño · 16 `[ ]`**.

> ⚠️ **Colisión de numeración de log.** Reservé el **830** y GLM-5.3 lo usó para M32 Clima (`Logs/830-M32-Iter2-Auditoria-Consumidores_...md`). Al resincronizar `Logs/ULTIMO_NUMERO.txt` contra el directorio real, el mayor era 830 → **este log es el 831** y el contador quedó en 831.

## Cambios Realizados

**Código nuevo — `game/isla-ancestral/scripts/islas/`:**

1. **`island_ring.gd`** (`class_name IslandRing extends RefCounted`) — enum **anónimo** `{ NUCLEO, CERCANO, MEDIO, LEJANO }` para que se use como `IslandRing.CERCANO` (el nombre que fija el diseño §2.5). `NOMBRES`, `RADIO_VECINDAD` (streaming por anillo: 0 / 2200 / 4400 / 6400 m) y `REQUIERE_PROGRESO`. `distancia_max_anillo()` = 0 / 1600 / 3200 / 6400.
2. **`island_definition.gd`** (`class_name IslandDefinition extends Resource`) — 22 `@export` (identidad, losa, biomas, ambiente, contenido exclusivo, puertos, clasificación) + **catálogo de los 13 biomas de M09** en `BIOMAS` con `bioma_nombre()`. `validar()` cubre **13 clases de error** (radio, alturas, playa, bioma fuera de catálogo, mezclas desalineadas o que no suman 1, anillo inválido, NÚCLEO secreta, flotante con puerto bajo la losa, puertos fuera del disco…). `bounds_locales()`, `centro_mundo()`, `punto_llegada_mundo()`, `punto_partida_mundo()`, `distancia_a()`, `huella()`, `a_diccionario()`.
3. **`archipielago.gd`** (`class_name Archipielago extends Resource`) — índice del archipiélago: `islas_esperadas` (PackedStringArray, Aurora primera) + `id_principal`. `comparar(encontradas) -> {faltantes, extra, ok}` es lo que permite **detectar un `.tres` faltante**.
4. **`island_registry.gd`** — autoload **`IslandRegistry`** (sin `class_name`, §9.17): escanea `res://data/islas/definiciones`, carga con **ids únicos (primera gana)**, **orden determinista por id**, valida cada definición y compara con el índice. `get_isla()` (null + WARN), `todas_las_islas()`, `isla_principal()`, `vecinas(id, corte_anillo)`, `coordenadas_por_isla()`, `anclar()`/`posicion_ancla()` (con cache) y **`static semilla_de_isla()`**. `validar_anclas()` detecta islas sin ancla, Aurora descentrada, **solapamiento** (`radio_a + radio_b + 64`) y **anillo incoherente con la distancia**. Descubrimiento/visita (`descubrir`/`visitar`/`visible_en_mapa`, secretas ocultas) y **ISaveProvider** (sección `islas`).
5. **`island_props.gd`** (`class_name IslandProps extends RefCounted`) — spawn **declarativo**: los módulos dueños registran un `Callable` por tipo (flora/fauna/recurso/poi) y M27 los invoca con el PRNG sembrado y el contexto correcto. `materializar()` **se niega a spawnear si la isla no tiene ancla** (requisito 86). `semilla_props()` determinista por isla.
6. **`generar_islas.gd`** — generador del dataset: construye las 13 definiciones, **valida cada una y aborta si alguna es inválida**, y sólo entonces guarda con `ResourceSaver.save()`. Nunca se edita un `.tres` a mano.
7. **`test_islas_m27.gd`** — test headless de **171 checks** en 11 bloques (A anillos · B definición · C carga · D fallback · E anclas · F vecinas · G descubrimiento/persistencia · H IslandProps · I geometría · J integración con M59 · K coherencia con el JSON legacy).

**Datos nuevos:**

- `data/islas/definiciones/{aurora,coral,verde,pequena,cenizas,desierto,flotante,cielo,nieve,volcanica,submarina,misteriosa,secreta}.tres` — **13 definiciones** con `nombre_clave` (M87), lore (M55), `clima_tendencia` (M32), `musica_clave` (M41) y las 5 listas de contenido exclusivo.
- `data/islas/archipielago.tres` — índice con los 13 ids esperados y `id_principal = aurora`.

**Integración:**

- `project.godot`: autoload `IslandRegistry` añadido al final de `[autoload]`.
- M59: la sección `islas` entra en el payload de guardado (aditiva; **no rompe** el schema base de M59 — verificado).

## Tests y regresiones

| Test | Resultado |
|---|---|
| `test_islas_m27.gd` (nuevo) | **171 / 0** (estable ×3) |
| `test_islas_headless.gd` (legacy) | **5 / 0** |
| `sincronizar_islas_mapa.gd` (legacy) | **OK** — 4 islas coherentes + 9 POIs |
| `test_datos_m60_iter3.gd` | **132 / 0** |
| `test_datos_m60.gd` | **94 / 0** |
| `test_transporte_m68.gd` | **177 / 0** |
| `auditar_aliasing.gd` (M59) | **OK (9) / ALIASING (0)** |

El test de M27 cubre explícitamente el **fallback de `.tres` faltante** con carpetas temporales reales (hook `_test_rutas()`): sólo-Aurora presente → 1 isla cargada, `coral` reportada como faltante, `ok = false`, **Aurora carga igual**; carpeta vacía → 0 islas, `isla_principal() == null`, ERROR logueado.

## Documentación

- `DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/04-Codigo.md` — **reescrito**: rutas reales, API real, tabla del dataset de 13 islas, disposición de anclas de referencia, contratos de integración, logs reales, **8 desviaciones documentadas**, **4 trampas reutilizables** y **7 pendientes honestos**.
- `DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/05-Checklist.md` — 83 `[x]`, 97 `[?]` con dueño, 12 `[ ]`; bloque **E (IslandLoading) delegado a M63** con nota; bloques G/H/I/L/N/O marcados `[?]` con dueño; bloque "Iteración 3" añadido.
- `CHECKLIST-GLOBAL.md` — fila 27 → `🟡 Liberado (iter. 1: núcleo archipiélago 1+12 ✅) | 83/192 | ... | 2026-09-11 23:00`.
- `Mensajes entre modelos/ESTADO-PARALELO.md` — fila insertada (byte-level, el archivo tiene encoding mixto y no debe re-codificarse).

## Errores y trampas encontradas (reutilizables)

1. **`DirAccess.open("user://…")` devuelve `null` en este entorno** y `ProjectSettings.globalize_path("user://…")` devuelve una ruta **relativa** (`./Godot/app_userdata/…`). `ResourceLoader.load()` sí funciona con `user://`. Solución: recomponer una ruta absoluta con `globalize_path("res://")` + la relativa → helper `_abrir_dir()` en `IslandRegistry`. **Sin esto, el test de fallback no podía abrir su carpeta temporal.**
2. **Godot cachea los `Resource` por ruta**: `ResourceLoader.load()` sobre un `.tres` ya cargado devuelve **la misma instancia**, así que las variables de script no exportadas **sobreviven a un reload**. `cargar_definiciones()` ahora resetea explícitamente `ancla` / `semilla_isla` / `ancla_asignada`; sin eso, un reload arrastraba anclas viejas y `materializar()` no se negaba sin ancla.
3. **Las lambdas de GDScript capturan por VALOR**: para observar desde el test lo que un spawner recibe hay que capturar un `Dictionary` (tipo referencia), no una variable suelta.
4. **Un autoload no es identificador global en modo `--script`**: el test usa `root.get_node_or_null("IslandRegistry")`. Los `class_name` sí lo son (tras `--editor --quit`).
5. **`DirAccess.open_absolute()` no existe en Godot 4.7.2** (parse error de función estática).

## Desviaciones del diseño (8, documentadas en 04-Codigo §6)

1. `desbloqueo: Callable` → **`desbloqueo_flag: StringName`** (un Callable no es serializable en `.tres`).
2. `class_name IslandRegistry` → **autoload sin `class_name`** (convención del proyecto).
3. `musica_theme` → **`musica_clave`** (coherencia con `nombre_clave`).
4. `IslandProps extends Node` → **`RefCounted`** (registro de spawners sin estado de escena; evita un autoload más).
5. `init(anclas: Dictionary)` → **`anclar()` por isla** (M10 genera de a una).
6. **`bounds_locales()` world-relative** (incluye el ancla) en lugar de centrado en el origen: M63 los consume como `Rect2i` absolutos.
7. **`bioma_base: int` con catálogo propio** en `IslandDefinition.BIOMAS`: M09 documenta 13 biomas por nombre pero no expone ids numéricos.
8. **`es_flotante` con `altura_min > 0`** (losa que flota a 40–60 m): `altura_min < 0` se rechaza; la profundidad submarina es de M51.

## Lo que NO hice (honestidad obligatoria)

- **No implementé `IslandLoading`** (carga/descarga/streaming, pesos 60/25/10/5, LRU): es territorio de **M63** y depende de los presupuestos de **M61**. El bloque E completo quedó `[?]` con dueño M63.
- **No hay anclas reales**: sin la capa de anclas de **M10**, las islas quedan sin anclar (y `IslandProps.materializar()` se niega, por diseño). El test usa una **disposición de referencia documentada**.
- **Los ids de contenido exclusivo son provisionales** (inventados con criterio): no existen los catálogos de M50/M36/M15/M23-M24/M19 para validarlos.
- **No migré el JSON legacy ni toqué M54**: `islas.json` (4 islas) sigue vivo y el mapa sigue leyéndolo. La coexistencia es intencional para no romper M54.
- **No verifiqué visualmente nada** (no soy aprobador visual; el módulo aún no tiene geometría propia).
- El auditor de aliasing de M59 **no audita mi provider en boot** porque arranca sin datos (`_tiene_datos()` falso) y el auditor salta providers vacíos; el anti-aliasing lo verifica mi propio test (mutar el snapshot devuelto no afecta el estado interno).

## Delegaciones `[?]` (con dueño)

| Bloque | Dueño | Motivo |
|---|---|---|
| `IslandLoading` completo (19 ítems) | **M63** | Streaming, pesos, LRU, presupuesto M61 |
| Capa de anclas, re-roll 8 intentos, regen 80/0, logs de re-roll | **M10** | M27 **detecta**; M10 decide |
| Viajes en barco (12 ítems) | **M28** | Barco, travesía, pantalla de viaje |
| Agua y océano (10 ítems) | **M51** | Nivel de mar, profundidades, espuma |
| Biomas y clima (6 ítems) | **M09/M32** | Recetas de bioma y microclima |
| Optimización (12 ítems) | **M61/M62** | Presupuestos de frame/memoria |
| Polish y UX (10 ítems) | **M54/M28/M21** | Mapa, transiciones, comentarios de NPC |
| Tests de integración/estrés | **M28/M63/M10/M61** | Requieren esos módulos vivos |
| Ids reales de contenido | **M50/M36/M15/M23-M24/M19** | Hoy declarativos/provisionales |
| Migrar el mapa al catálogo de 13 | **M54** | Hoy lee `islas.json` de 4 |

## Estado del módulo

- **M27: 🟡 Liberado (iter. 1) — 83/192 `[x]` · 97 `[?]` · 12 `[ ]`.**
- Núcleo data-driven del archipiélago 1+12 **operativo y verificado headless**.
- Reserva de log **eliminada**; `Logs/ULTIMO_NUMERO.txt` = **831**.

## Próximo paso (mi cola, Nivel A)

Siguiente módulo de la cola: **M87 Localización** (§21.4.7 reclaim) — T-050/044/058. Después: **M116**, **M101** (QA cruzado §21.8), **M123**, **M148**, **M52**, **M26**.
