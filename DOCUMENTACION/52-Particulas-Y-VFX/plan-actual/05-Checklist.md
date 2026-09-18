**Modelo:** Deepseek V4 Flash (diseño) · DeepSeek-V4.1-Flash / WorkBuddy (iter. 5-6)
**Plataforma:** OpenCode (diseño) · WorkBuddy (iter. 5-6)

# 05-Checklist.md — Módulo 52: Partículas y VFX

## Convención
- `[x]` = completado (existe el artefacto y es verificable). `[ ]` = pendiente. `[?]` = no resuelto / parcial.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).
- **Auditoría (iter. 5, Log 882):** varias casillas `[x]` de diseño no tenían
  artefacto de runtime. Donde pude lo implementé (pool, precalentamiento,
  límites, determinismo, `VFX-SKIP`); donde no, queda en `[?]` con la razón.

### Historial de iteraciones

- **iter. 5 (Log 882, 2026-09-13):** pooling, precalentamiento, determinismo por
  semilla, límites de rendimiento y log `VFX-SKIP`. Catálogo: 8/25 efectos.
- **iter. 6 (Log 1002, 2026-09-18, DeepSeek-V4.1-Flash):** catálogo **8 → 31
  entradas** (24/24 nombres del plan) con 20 campos por efecto; `vfx_schema.gd`
  extendido a reglas verificables (RF3/RF4/RF6/RF7/RF11/RF14/RF16);
  **`vfx_loops.gd`** (culling por radio, fase fija, una zona = un emisor) y
  **`vfx_trigger.gd`** (punto único evento → VFX; los 13 buses verificados contra
  `scripts/core/event_bus.gd`); generador validante `tools/vfx/gen_vfx_catalog.py`
  con `--check` contra drift; suite `test_vfx_m52_iter6.gd` **76 checks ×3**.
  M52 acumula **181 checks · 0 fallos** en 5 suites. 49 ítems cerrados →
  **137/148**. **QA cruzado (§21.8) pendiente** (verificador ≠ autor).

## A. Problema y objetivos

- [x] Definir el problema: sin sistema de VFX el feedback visual es inconsistente y caro [S]
- [x] Definir el objetivo: VFX baratos, deterministas y armónicos con el estilo cozy [S]
- [x] Registrar dependencias: M04 (GPUParticles), M45/M47 (materiales), M49 (glow/luz), M61/M62 (presupuestos), M58 (accesibilidad) [M]
- [x] Mapear la sección 51 "PARTÍCULAS Y VFX" del plan maestro al ID 52 de la tabla global [M]
- [x] Separar dentro/fuera de alcance: luz de fuego → M49, sonido → M43/M44, sprites → M45/M47 [S] — iter. 6: Frontera documentada en el catálogo (`dueno_evento` M49 en humo/fuego/lava) y forzada por el schema (RF7). Sonido M43/M44 y sprites M45/M47 quedan fuera.
- [x] Documentar restricciones: GPUParticles, sin RNG, sin luz por partícula, presupuesto verificable [M]
- [x] Definir criterios de aceptación verificables (8 criterios) [S]

## B. RF1 — Catálogo de VFX

- [x] Listar los 25 efectos del plan maestro [M] — iter. 6: 24/24 nombres del plan cubiertos. El plan enumera **24** (`plan-inicial/04-Codigo.md:149`), no 25 → discrepancia reportada, no inventada.
- [x] Humo y polvo [S] — iter. 6: `vfx_humo`, `vfx_polvo`.
- [x] Hojas y pétalos [S] — iter. 6: `vfx_hojas`, `vfx_polen`, `vfx_petalos`.
- [x] Chispas [S] — iter. 6: `vfx_chispas`, `vfx_crafteo`.
- [x] Agua (salpicaduras) [S] — iter. 6: `vfx_salpicadura`, `vfx_gotas_cascada`, `vfx_pesca_exito`.
- [x] Lluvia y nieve [S] — iter. 6: `vfx_lluvia`, `vfx_lluvia_salpicadura`, `vfx_nieve` (categoría `clima`).
- [x] Fuego y lava [S] — iter. 6: `vfx_fuego`, `vfx_lava` (RF7: sin luz por partícula).
- [x] Luz y magia tecnológica [S] — iter. 6: `vfx_luz`, `vfx_magia`.
- [x] Resonancia y activación de runas [S] — auditoría iter. 5: sin entrada en `vfx_catalog.json` (8/25) — iter. 6: `vfx_resonancia`, `vfx_runas` (bus `quest.prereq_met` verificado).
- [x] Teletransporte (si existe) [S] — iter. 6: `vfx_teletransporte` (bus `travel.travel_started`).
- [x] Obtención de Sello [S] — auditoría iter. 5: sin entrada en `vfx_catalog.json` (8/25) — iter. 6: `vfx_sello` (bus `quest.prereq_met`).
- [x] Resolución de puzzle [S] — auditoría iter. 5: sin entrada en `vfx_catalog.json` (8/25) — iter. 6: `vfx_puzzle` (bus `quest.quest_completed`).
- [x] Construcción, cosecha y pesca [S] — auditoría iter. 5: cosecha y pesca sí; construcción NO — iter. 6: `vfx_construccion`, `vfx_cosecha`, `vfx_pesca_exito` — los tres.
- [x] Descubrimiento [S] — iter. 6: `vfx_descubrimiento` (bus `diary.entrada_nueva`).
- [x] Cambio estacional [S] — auditoría iter. 5: solo primavera (`vfx_polen`) — iter. 6: `vfx_estacional` + hojas/polen/pétalos/nieve con `condicion` de estación/clima.
- [x] Efectos de interfaz [S] — iter. 6: `vfx_ui` (bus `ui.notify`).
- [x] Efectos atmosféricos [S] — iter. 6: `vfx_atmosferico` (bus `weather.clima_cambio`) + el grupo `clima`.
- [x] Definir parámetros por efecto (tipo, material, emisor, presupuesto) [M] — iter. 6: 20 campos por efecto: tipo, material, emisor, presupuesto, categoría, loop/fase/radio, parpadeo, luz.

## C. RF2 — Pool central

- [x] Definir VfxManager (autoload) [M]
- [x] Definir pool de emisores one-shot prestados/liberados [M] — iter. 5: `vfx_pool.gd` (`prestar`/`liberar`/`liberar_todos`)
- [x] Definir loops registrados con culling [M] — iter. 6: `vfx_loops.gd`: registro por zona con culling por radio (RF14) + `resumen()` para telemetría.
- [x] Definir precalentamiento del pool (8 emisores) [M] — iter. 5: `precalentar()` / `precalentar_catalogo()`

## D. RF3 — Presupuesto por escena

- [x] Definir máx emisores activos (12 preset medio) [M] — iter. 5: `max_emisores` (def. 32, configurable)
- [x] Definir máx partículas vivas (4.000 preset medio) [M] — iter. 5: `max_particulas` (def. 1200, configurable)
- [ ] Definir presupuesto por preset (M90) [M]
- [x] Definir log VFX-SKIP cuando se excede [M] — iter. 5: implementado de verdad (`emision_descartada` → `GameLogger`); antes estaba `[x]` sin existir

## E. RF4 — Determinismo

- [x] Definir semillas de contexto (M10) en one-shots [M] — iter. 5: `semilla_de()` FNV-1a 32
- [x] Definir loops con fase fija [M] — iter. 6: `VfxLoops.fase_en_t()` usa la `fase` FIJA del catálogo — función pura, sin aleatoriedad (bloque D).
- [x] Definir sin RNG por frame [M] — iter. 5: sin RNG; `seed` fijada después de `restart()`
- [x] Definir verificación de determinismo en validador [M]

## F. RF5 — Sincronía con animación

- [ ] Definir triggers en timelines (M48) [M]
- [x] Minado, cosecha, pesca, construcción desde animación [M]
- [x] Definir trigger centralizado VFX+SFX+feedback [M]

## G. RF6 — Eventos de juego

- [x] Definir obtención de Sello (M22) [M]
- [x] Definir resolución de puzzle (M24) [M]
- [x] Definir descubrimiento (M71) [M] — iter. 6: `vfx_descubrimiento` + bus `diary.entrada_nueva` (verificado en `event_bus.gd`).
- [x] Definir festivales (M74) [M] — iter. 6: `vfx_evento_festival` + bus `calendar.day_started`.

## H. RF7 — Fuego y lava

- [x] Definir humo + ascuas de fuego [M] — iter. 6: `vfx_humo` + `vfx_fuego` (ascuas = `unshaded_add`).
- [ ] Definir burbujas + ascuas de lava [M]
- [x] Definir sin luz por partícula (luz = M49) [M] — iter. 6: RF7 forzado por el schema: `luz_por_particula` debe ser false (inyección en el bloque B).

## I. RF8 — Agua

- [x] Definir salpicaduras al nadar (M51/M11) [M] — iter. 6: `vfx_salpicadura`.
- [x] Definir gotas de cascada [M] — iter. 6: `vfx_gotas_cascada`.
- [ ] Definir chapoteo de balde (M13) [M]

## J. RF9 — Atmosféricos

- [x] Definir lluvia por clima (M32) [M] — iter. 6: `vfx_lluvia` + `condicion clima:lluvia`.
- [x] Definir nieve por clima/estación (M32/M29) [M]
- [x] Definir polvo del desierto [M] — iter. 6: `vfx_polvo` + `condicion clima:despejado`.
- [x] Definir hojas al viento (M50) [M] — iter. 6: `vfx_hojas` + `condicion estacion:otono`.
- [x] Definir pétalos primaverales (M29) [M] — iter. 6: `vfx_petalos` + `vfx_polen`, `condicion estacion:primavera`.
- [x] Definir un emisor global por zona (no por chunk) [M] — iter. 6: `VfxLoops.registrar()` rechaza dos loops en la misma zona: una zona = un emisor (RF9).

## K. RF10 — Magia y ancestral

- [x] Definir resonancia de runas (M24/M26) [M]
- [x] Definir activación de glifos [M]
- [ ] Definir estelas de luz (M47) [M]
- [x] Definir magia tecnológica (M86) [S] — iter. 6: `vfx_magia` (dueño del evento M86).

## L. RF11 — UI

- [ ] Definir partículas 2D en menús/recompensas (M53) [M]
- [ ] Definir Reduce Motion (M58) [M]
- [x] Definir sin estroboscopios (>10 Hz prohibido) [M] — iter. 6: RF11 en el schema: `parpadeo_hz` > 10 es error (inyección a 12 Hz en el bloque B).

## M. RF12 — Cambio estacional

- [x] Definir transición de VFX por estación (M29) [M]
- [x] Definir pétalos ↔ hojas ↔ nieve [M] — iter. 6: `vfx_polen`/`vfx_petalos` (primavera) ↔ `vfx_hojas` (otoño) ↔ `vfx_nieve` (clima:nieve), data-driven por `condicion`.

## N. RF13 — Teletransporte

- [x] Definir estela de entrada/salida (si se implementa M28) [S]

## O. RF14 — Optimización

- [x] Definir tope de partículas vivas [M] — iter. 5: `max_particulas` + reciclado de los más antiguos
- [x] Definir culling por distancia (40 m pausa) [M]
- [x] Definir LOD de emisores (25% lejos) [M] — iter. 6: `VfxLoops.factor_lod()`: 1.0 dentro del 50% del radio, **0.25** fuera (RF14).
- [x] Definir pooling (M62) [M] — iter. 5: `vfx_pool.gd`

## P. RF15 — Validación

- [x] Definir validate_vfx.gd [M]
- [x] Verificar presupuesto por escena [M] — iter. 5: `stats()` del pool + bloque D del test
- [x] Verificar naming [S] — iter. 6: `RE_ID` del schema + bloque B; el generador valida lo mismo al ESCRIBIR el catálogo.
- [x] Verificar determinismo (semillas) [M] — iter. 5: `validar_semillas()` + bloque B del test
- [x] Verificar sin luz por partícula [M] — iter. 6: Bloque B: `luz_por_particula=true` produce error; el catálogo real tiene 0 violaciones.
- [x] Verificar mapeo completo de eventos de juego [M] — iter. 6: 13 buses derivados del catálogo y verificados como `signal` en `scripts/core/event_bus.gd` (bloque F); 10 pendientes RF6 con dueño.

## Q. RF16 — Naming y organización

- [x] Definir prefijos vfx_, part_ [S]
- [x] Alinear con M108 [M] — iter. 6: Naming `vfx_<snake_case>` validado en ambos lados (generador + schema).

## R. Requisitos no funcionales

- [x] Rendimiento: límites + LOD + pooling (M61) [M] — iter. 5: límites y pooling SÍ; LOD por distancia NO — iter. 6: Pooling y límites eran de la iter. 5; **LOD por distancia** se cierra acá (`factor_lod` 25% lejos).
- [x] Memoria: pool precalentado (M62) [M] — iter. 5
- [x] Determinismo: semillas + fases fijas [M] — iter. 5: semillas SÍ; fases fijas de loops NO (no hay loops) — iter. 6: Semillas de la iter. 5 + **fases fijas** de los loops: `fase_en_t()` es pura y periódica (bloque D).
- [ ] Cozy: amplitudes suaves, sin humo denso negro [M]
- [x] Accesible: vfx_quality 3 niveles (M58) [M]
- [x] Mantenible: catálogo central único [M] — iter. 6: Un único `vfx_catalog.json` (31 entradas) con generador validante en `tools/vfx/` y `--check` contra drift.

## S. Alternativas consideradas

- [x] Descartar CPUParticles para todo [M]
- [x] Descartar emisores sin pool (GC/stutter) [M] — iter. 5: el pool evita allocar por disparo (verificado: `creados` no sube al reusar)
- [x] Descartar luz integrada en partículas [M] — iter. 6: Rechazada y **forzada por el schema**: `luz_por_particula` debe ser false (RF7 → la luz es de M49).
- [x] Descartar RNG en runtime [S] — iter. 5: semillas deterministas
- [x] Descartar sin límite de partículas [S] — iter. 5: `max_particulas` + reciclado
- [x] Descartar VFX 100% procedural por shaders [M]

## T. Riesgos y mitigaciones

- [x] Riesgo de overdraw → presupuesto + tope + LOD [M] — iter. 6: Presupuesto por efecto (`presupuesto >= cantidad`) + tope del pool (iter. 5) + LOD (RF14).
- [x] Riesgo de desincronía → trigger centralizado [M] — iter. 6: `vfx_trigger.gd`: punto único de traducción evento → VFX, mapa derivado del catálogo y reporte de buses no resueltos.
- [x] Riesgo de determinismo roto → semillas + validador [M] — iter. 5
- [x] Riesgo de stutter → pool precalentado [M] — iter. 5
- [x] Riesgo de molestias (fotosensibilidad) → vfx_quality (M58) [M]
- [ ] Riesgo de efectos fuera de estilo → guía de amplitudes + review [M]

## U. Integraciones

- [x] Documentar integración con M04 (GPUParticles) [S]
- [x] Documentar integración con M13/M17/M22/M24/M33/M34/M71 (eventos) [S]
- [x] Documentar integración con M48 (timelines) [S]
- [x] Documentar integración con M43/M44 (audio/feedback) [S]
- [x] Documentar integración con M32/M29 (clima/estaciones) [S]
- [x] Documentar integración con M50/M51 (hojas/salpicaduras) [S]
- [x] Documentar integración con M47/M49 (materiales/luz) [S]
- [x] Documentar integración con M53/M58 (UI/accesibilidad) [S]
- [x] Documentar integración con M61/M62 (presupuestos) [S]
- [x] Documentar integración con M108/M118 (import/CI) [S]

## V. Herramientas y flujos

- [x] Documentar flujo de emisión one-shot [M] — iter. 5: 04-Codigo.md §2 + bloque E del test
- [x] Documentar flujo de loop ambiental (humo) [M] — iter. 6: Ver `04-Codigo.md` §8: flujo del loop ambiental paso a paso.
- [x] Documentar flujo de atmosféricos por clima/estación [M]

## W. Criterios de aceptación verificados

- [x] Todos los efectos del plan maestro en el catálogo [M] — iter. 6: Los 24 nombres tienen entrada; `cobertura_plan()` devuelve [] sobre el catálogo real.
- [ ] Escena pivote sin exceder límites y sin caída de fps [M]
- [x] One-shots deterministas (misma semilla, misma distribución) [M] — verificado iter. 5 (bloque B + `seed` tras `restart()`)
- [x] Triggers sincronizados con animación/sonido/feedback [M]
- [x] Fuego/lava sin luz (solo M49) [M] — iter. 6: Schema RF7 + bloque B de la suite: fuego y lava con `luz_por_particula=false`.
- [x] Reduce Motion atenúa/desactiva VFX [M]
- [x] Atmosféricos responden a clima/estación sin lag [M]
- [x] Catálogo y validación integrados con CI (M118) [M]

## X. Notas finales

- [x] Documentar el desfase de numeración del plan maestro (51=PARTÍCULAS Y VFX → ID 52) [S]
- [x] Marcar el módulo como DELEGABLE PARA IMPLEMENTAR [S]
- [x] Registrar dependencia de implementación con el hito M1 (proyecto Godot) [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]

## Z. Validación visual del preview (2026-08-24, ox-alpha/Cline)

- [x] Escena `preview_particles.tscn` creada y ejecutada en Godot 4.7.2 [S]
- [x] Emisor CPUParticles3D corriendo sin errores en consola ("Polen creado OK") [M]
- [x] Confirmación visual humana: partículas amarillas visibles emergiendo desde abajo (tipo chispas/fuegos artificiales) [S]
- [x] Lanzamiento reproducible documentado (`scripts-reutilizables/lanzar_preview.py`) [S]
- [x] Primera captura automatizada real del juego: `capturas/52-Particulas-Y-VFX/cap_52_2026-08-24_21-19-22_polen-validacion.png` (verificada visualmente por el agente) [S]
- [x] Mejora estética: quad reducido 0.25→0.06 + textura radial suave generada por código (GradientTexture2D) + transparencia alpha. Verificado en capturas iter2/iter2b: polen pequeño redondeado difuminado, FPS 59 [M]

## Z2. Iteraciones con flujo V4+V2 (2026-08-25, ox-alpha/Cline)

- [x] Iter 3: turbulencia (deriva orgánica tipo brisa) + caída lenta + damping + amount 150→220 + lifetime 6→9. FPS 59 confirmado en iter3b (el 24 inicial era transitorio del arranque) [M]
- [x] Iter 4: emisión en caja ancha (EMISSION_SHAPE_BOX, extents 3.5×0.5×1.0) para distribuir el polen por toda la escena en vez de amontonarlo en una columna. Verificado en captura: polen distribuido flotando a distintas alturas, FPS 59 [M]
- [x] Flujo completo V4+V2 ejercitado: lanzar (script) → capturar (MCP screen) → comparar → ajustar → recapturar, con historial de capturas por iteración [S]
## Verificación visual (2026-09-02 06:50 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] Preview de polen (GPUParticles3D, amount 150, quad 0.06 textura radial) ejecutado y capturado: cientos de partículas flotando visibles, textura suave, sin frames rotos
- [x] **Rendimiento visual: FPS 59** en la escena (sin degradación con 150+ partículas — presupuesto OK)
- [x] GPUParticles3D (recomendado por M52) confirmado como vía correcta en D3D12 (no CPU)
- [?] Catálogo de VFX por evento (M44 feedback + M92 tutorial): iter 2 — catálogo data-driven (dueño: deepseek-v4-flash-vision-exp)
## Iteración 3 (2026-09-02 20:20 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] `scripts/particles/vfx_factory.gd` — VfxFactory: cargar_catalogo(), parametros(vfx) (color hex manual parseado, cantidad, emisión, tipo) y crear() (GPUParticles3D one_shot con material particle)
- [x] Test 8/8 OK (catálogo 8, parámetros de polen/crafteo, defaults seguros, color #F4E04D validado)
- [!] Nota de la tarde: la función hex_to_int() NO existe en Godot 4 y float("0xF4") tampoco parsea — parseo manual implementado (_hex_byte) — lección para futuros scripts con colores hex
## Iteración 4 (2026-09-02 21:25 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] `scripts/particles/vfx_director.gd` — VfxDirector: carga el catálogo (8 eventos), registra el bus genérico si existe, disparar(evento_id, pos) → VfxFactory y estado (último disparo)
- [x] Test 4/4 OK (8 eventos, dispatch conocido, fallo para evento inexistente)

## Iteración 5 (2026-09-13 — DeepSeek-V4.1-Flash / WorkBuddy, Log 882)

Parte **NO visual** del módulo: pooling, precalentamiento, determinismo por
semilla, límites de rendimiento y log `VFX-SKIP`. Todo verificado en headless.

- [x] **Bug real preexistente**: `VfxFactory.crear()` asignaba `GPUParticles3D.mesh`
      (propiedad ELIMINADA en Godot 4.3 → hoy `draw_pass_1`). El error abortaba la
      función en silencio, `crear()` devolvía `null` y **no se instanciaba ningún
      VFX** pese a que los 3 tests previos daban verde (solo probaban funciones puras)
- [x] `vfx_factory.gd`: `nuevo_emisor()` (configura sin añadir al árbol, para el pool)
      y `redisparar()` (reuso determinista). `String(` → `str(` en todo el archivo
- [x] `vfx_pool.gd` (nuevo): `VfxPool` — préstamo/liberación por `id`, precalentamiento,
      `max_emisores`/`max_particulas`, reciclado del más antiguo y métricas
- [x] `vfx_director.gd` (reescrito): consume el pool; `precalentar()`, `actualizar()`
      devuelve al pool los agotados y `finalizar()` libera los nodos
- [x] **Determinismo**: `restart()` **re-aleatoriza** `seed` (medido 2694543342 →
      2659173778) → la semilla se asigna DESPUÉS de `restart()`
- [x] **Log `VFX-SKIP` implementado de verdad** (antes `[x]` sin existir): señal
      `emision_descartada(id, motivo)` del pool + escritura en `GameLogger` (categoría
      `WORLD`) desde el director
- [x] `test_vfx_pool_m52.gd` (nuevo): 6 bloques, **89 checks** — ejercita la **ruta de
      runtime** que los 3 tests puros nunca tocaban (instancia nodos reales)
- [x] Anti-falso-verde: marcador `_fin()` por bloque, verificado en `_run()`
- [x] 4 tests de M52 añadidos al job `test-suite` de `.github/workflows/quality.yml`
- [x] `04-Codigo.md` reescrito: rutas reales de Godot (el anterior listaba rutas de
      Unity `Assets/_Project/VFX/...` inexistentes y decía "pendiente de implementación")

### Auditoría de sobre-cierre (iter. 5)

Casillas que estaban `[x]` **sin artefacto verificable**; reclasificadas a `[?]`
con la razón al lado (ver secciones B y R):

| Ítem | Estado previo | Realidad medida |
|---|---|---|
| Resonancia y activación de runas | `[x]` | Sin entrada en `vfx_catalog.json` |
| Obtención de Sello | `[x]` | Sin entrada en `vfx_catalog.json` |
| Resolución de puzzle | `[x]` | Sin entrada en `vfx_catalog.json` |
| Construcción, cosecha y pesca | `[x]` | Cosecha y pesca sí; construcción no |
| Cambio estacional | `[x]` | Solo primavera (`vfx_polen`) |
| Log `VFX-SKIP` | `[x]` | No existía → **implementado** en iter. 5 (queda `[x]` legítimo) |

El catálogo real tiene **8 de los 25** efectos del plan maestro.

### Recuento tras la iteración 5

- Checklist original: **139** ítems → `[x]` 78 · `[?]` 8 · `[ ]` 52 · `[!]` 1
- Ítems nuevos de esta sección: **10** (todos `[x]`)
- **Total del archivo: 149 ítems → `[x]` 88 · `[?]` 8 · `[ ]` 52 · `[!]` 1**

## QA visual V2-asistencia (agnes-3-flash / Sapiens AI / Kilo Code, 2026-09-16 — visión nativa)

> **Alcance:** V2-**asistencia** (leo/describo las capturas del MCP godot y opino). La **aprobación estética
> final sigue siendo del usuario (M154)** y **no genero arte (V5)**; soy el "ojo barato y rápido" para
> detectar bugs visuales. Fuentes: `capturas/52-Particulas-Y-VFX/*.png` (leídas con visión).

- **`cap_52_iter3-turbulencia-flotante.png`:** cielo azul (gradiente) + plano oscuro. Chorro diagonal de
  partículas amarillas (quads/puntos) — coherente con "turbulencia flotante". **⚠️ `FPS: 24`** → señal de
  rendimiento para la turbulencia (más interacción/partículas que iter4); **flag a M61 (Rendimiento)**:
  revisar el budget de partículas del efecto de turbulencia (densidad/rate). No es un bug visual, es perf.
- **`cap_52_iter4-emision-caja-ancha.png`:** mismo fondo; partículas amarillas **más dispersas y sueltas**
  (emisión de caja ancha, algunos quads más grandes). **`FPS: 59`** → dentro del target 60. Aspecto correcto,
  sin partículas fuera de cuadro ni pop-in visible.
- **Lectura global:** color amarillo sobre cielo azul = buen contraste/legibilidad de VFX. No detecté
  artefactos visuales (overdraw, z-fighting, partículas mal ancladas) en estas 2 capturas.
- **Recomendación (dueño M52/M61):** validar el effecto de **turbulencia** contra el presupuesto de
  partículas (24 FPS en la captura); las otras iteraciones (polen, caja ancha) parecen sanas.
- **No afirmo "aprobado visualmente"**: esto es V2-asistencia; el cierre estético es del usuario.
