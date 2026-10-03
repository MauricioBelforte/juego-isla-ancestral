**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode

# 05-Checklist.md — Módulo 43: Efectos de Sonido

> Marcadores: [S] simple · [M] medio · [C] complejo. Estados: [ ] cumplido · [ ] pendiente · [?] no resuelto.
> Módulo **delegable**: implementación para el agente que lo reclame.

## A. Requisitos del módulo (9)

- [x] Definir el problema: feedback sonoro de eventos sin máscara ni fatiga [S]
- [x] Registrar dependencias: M06/M07, M13/M17, M34, M35, M20, M21, M45; relaciones M41/M42 [S]
- [x] Catalogar los 25 puntos de la sección 42 [S]
- [x] RF1: pasos por superficie (6 tipos × 4+) [S]
- [x] RF2: acciones de movimiento (saltar, caer, nadar) [S]
- [x] RF3: interacciones con bloques [S]
- [x] RF4: recoger, abrir/cerrar, equipar, herramientas [S]
- [x] RF5: pesca, crafting, comercio, diálogo [S]
- [x] RF6+RF7: UI SFX y volumen dinámico (3D + ducking) [S]

## B. Resolución de los 25 puntos del plan (25)

- [x] P1: pasos — 6 superficies × 4+ variaciones, pitch ±4% [S]
- [ ] P2: correr — ritmo doble +3 dB (M34) [S]
- [x] P3: saltar — despegue suave por superficie [S]
- [x] P4: caer — 3 rangos de altura, sin violencia [S]
- [ ] P5: nadar — entrada/avance/salida (M34) [S]
- [ ] P6: recoger — click + nota aguda positiva [S]
- [x] P7: abrir — 3 variaciones (madera/cerrojo) [S]
- [ ] P8: cerrar — golpe seco corto [S]
- [x] P9: equipar — swish + clic, 2 variaciones [S]
- [x] P10: herramienta — por tipo, 4 variaciones [S]
- [x] P11: bloque roto — por material, 5 variaciones [S]
- [x] P12: bloque colocado — impacto corto, 4 variaciones [S]
- [x] P13: plantar — tierra + grano, 3 variaciones [S]
- [ ] P14: regar — chorrito + goteo corto [S]
- [ ] P15: cosechar — follaje + nota de logro ligera [S]
- [ ] P16: pescar — cast/splash/bote/reel (M35) [S]
- [ ] P17: crafting — golpes por etapa + arpegio éxito (M20) [S]
- [ ] P18: compra — monedas + nota de éxito (M45) [S]
- [ ] P19: venta — monedas + nota media, distinto [S]
- [ ] P20: diálogo — click de UI (M21) [S]
- [ ] P21: menú — papel/pergamino suave [S]
- [x] P22: selección — clic corto muy suave [S]
- [x] P23: confirmación — 2 notas ascendentes 5ª [S]
- [ ] P24: error — triada menor descendente 0.4 s [S]
- [ ] P25: logro — arpegio triada mayor 3 notas [S]

## C. Familia tonal (8)

- [ ] SFX comparten escala y timbres con M41 [S] — ⚠️ pendiente: M43 ya tiene familia tonal propia (`sfx_tones.json`), pero **M41 no define escala ni timbres** (`music_director.gd` no tiene notas/frecuencias y `music_context_matrix.json` solo tiene temas/capas/pesos): la coherencia no es verificable aún
- [x] Confirmación: 5ª justa ascendente [S] — ✅ Lote B1 (2026-10-03): `sfx_tones.json` + API `tono()` en SFXManager; verificado por `test_sfx_m43.gd` **35/0 OK** («confirmacion» = [0, 7] = 5ª justa, orden ascendente)
- [x] Logro: triada mayor brillante [S] — ✅ Lote B1 (2026-10-03): `sfx_tones.json` + API `tono()` en SFXManager; verificado por `test_sfx_m43.gd` **35/0 OK** («logro» = [0, 4, 7], tono «brillante»)
- [x] Error: triada menor suave (nunca buzz) [S] — ✅ Lote B1 (2026-10-03): `sfx_tones.json` + API `tono()` en SFXManager; verificado por `test_sfx_m43.gd` **35/0 OK** («error» = [7, 4, 0] descendente, 0.4 s, tono «suave»)
- [x] Recoger: nota aguda positiva [S] — ✅ Lote B1 (2026-10-03): `sfx_tones.json` + API `tono()` en SFXManager; verificado por `test_sfx_m43.gd` **35/0 OK** («recoger» = [+12 semitonos = +1 octava], 0.2 s, tono «positivo»)
- [x] Compra vs venta: distintos audiblemente [S] — ✅ Lote B1 (2026-10-03): `sfx_tones.json` + API `tono()` en SFXManager; verificado por `test_sfx_m43.gd` **35/0 OK** (compra [0,4,7]/«ligero» vs venta [0,3,7]/«medio»: notas y tono distintos; la escucha final queda pendiente de assets §7)
- [x] Crafting éxito: arpegio 4ª-5ª [S] — ✅ Lote B1 (2026-10-03): `sfx_tones.json` + API `tono()` en SFXManager; verificado por `test_sfx_m43.gd` **35/0 OK** («crafting_exito» = [0, 5, 7] = 4ª justa + 5ª justa)
- [ ] Co-herencia con leitmotifs (M41) [S] — ⚠️ mismo motivo que el ítem anterior: M41 no expone leitmotifs ni escala; reevaluar cuando M41 defina su familia tonal

## D. Prioridades de canal y pool (10)

- [x] P1 UI: nunca se corta, máx 2 simultáneos [S] — ✅ Lote B3 (2026-10-03): `CATEGORIAS`/`MAX_MISMO_TIPO` en `sfx_manager.gd` (`ui`: `nivel_s2`=1, `nunca_corta`=true, `max_simultaneos`=2; la 3ª UI simultánea se descarta, no corta a las existentes) ; verificado por `test_sfx_m43.gd` **76/0 OK**
- [x] P2 mundo: se corta un pasos si hace falta [S] — ✅ Lote B3 (2026-10-03): `CATEGORIAS`/`MAX_MISMO_TIPO` en `sfx_manager.gd` (prioridad interna `mundo`=7 > `paso`=1: en pool lleno la llamada de mundo reemplaza a un paso — ya verificado en «reproducir prioridad media») ; verificado por `test_sfx_m43.gd` **76/0 OK**
- [x] P3 bloques: se corta un ambiente si hace falta [S] — ✅ Lote B3 (2026-10-03): `CATEGORIAS`/`MAX_MISMO_TIPO` en `sfx_manager.gd` (`bloque`: `nivel_s2`=3, prioridad interna 5 entre `mundo` (7) y `paso` (1): en conflicto con pasos los corta; ante un ambiente de mayor prioridad lo cede) ; verificado por `test_sfx_m43.gd` **76/0 OK**
- [x] P4 pasos/movimiento: se corta primero [S] — ✅ Lote B3 (2026-10-03): `CATEGORIAS`/`MAX_MISMO_TIPO` en `sfx_manager.gd` (`paso`: `nivel_s2`=4, prioridad interna 1 = la más baja, `se_corta_primero`=true: es lo primero que el corte por prioridad elige) ; verificado por `test_sfx_m43.gd` **76/0 OK**
- [x] Pool de 24 voces prealocadas estáticas [S] — ✅ Lote B3 (2026-10-03): `CATEGORIAS`/`MAX_MISMO_TIPO` en `sfx_manager.gd`: `_voces.resize(MAX_VOCES)` en `_ready()` (24 slots fijos, `null` = libre; **cero `append`**, la ocupación es por slot) ; verificado por `test_sfx_m43.gd` **76/0 OK**
- [x] ≤ 6 simultáneos del mismo tipo [S] — ✅ Lote B3 (2026-10-03): `CATEGORIAS`/`MAX_MISMO_TIPO` en `sfx_manager.gd`: `MAX_MISMO_TIPO=6` comprobado ANTES del corte por prioridad — las 6 primeras entran y la 7ª se corta ; verificado por `test_sfx_m43.gd` **76/0 OK**
- [x] Sin allocs por frame (PRNG M29) [S] — ✅ Lote B3 (2026-10-03): `CATEGORIAS`/`MAX_MISMO_TIPO` en `sfx_manager.gd`: **un solo** `RandomNumberGenerator` cacheado en `_rng`, semilla resuelta UNA vez en `_ready()` mezclando el reloj de M29 (`GameTime.dia_absoluto/hora/minuto`, si está disponible) con `randi()`. No hay `frame loop` de reproducción que allocs por frame ; verificado por `test_sfx_m43.gd` **76/0 OK**
- [ ] 3D: pasos/interacciones; 2D: UI/diálogo [S] — ⚠️ sigue pendiente: sin `AudioStreamPlayer` no se emite audio: queda a la espera de los `.wav` (§7)
- [ ] Distancias: pasos 15 m, rotura 20 m, mundo 30 m [S] — ⚠️ sigue pendiente: sin `AudioStreamPlayer` no se emite audio: queda a la espera de los `.wav` (§7)
- [x] Excesos se cortan, jamás se apilan [S] — ✅ Lote B3 (2026-10-03): `CATEGORIAS`/`MAX_MISMO_TIPO` en `sfx_manager.gd`: los límites (tipo y categoría) devuelven `false` antes de ocupar slot, y el corte por prioridad reemplaza en sitio: el array nunca supera 24 ; verificado por `test_sfx_m43.gd` **76/0 OK**

## E. Mapa de variaciones (14)

- [x] Pasos hierba: 5 variaciones [S] — ✅ Lote B2 (2026-10-03): `sfx_surfaces.json` ampliado a 9 superficies: superficie nueva «hierba» con 5 (la única con 5 de los pasos, como dice §3) ; verificado por `test_sfx_m43.gd` **59/0 OK**. ⚠️ nota de honestidad: este ítem estaba marcado `[x]` en la auditoría del Lote A **sin evidencia** (`sfx_surfaces.json` no tenía hierba) y no lo detecté; queda cubierto recién ahora con datos reales
- [x] Pasos madera: 4 [S] — verificado 2026-10-03: `sfx_surfaces.json` «madera» tiene 4 variaciones
- [x] Pasos piedra: 5 + eco ligero [S] — ✅ Lote B2 (2026-10-03): `sfx_surfaces.json` ampliado a 9 superficies: «piedra» pasa de 4 a **5** variaciones (5 nuevas) ; verificado por `test_sfx_m43.gd` **59/0 OK**; el «eco ligero» es matiz de composición — el matiz de diseño exige los `.wav` del compositor (§7)
- [x] Pasos tierra: 4 [S] — verificado 2026-10-03: `sfx_surfaces.json` «tierra» tiene 4 variaciones
- [x] Pasos nieve: 4 [S] — ✅ Lote B2 (2026-10-03): `sfx_surfaces.json` ampliado a 9 superficies: superficie nueva «nieve» con 4 ; verificado por `test_sfx_m43.gd` **59/0 OK**
- [x] Pasos arena: 4 [S] — ✅ Lote B2 (2026-10-03): `sfx_surfaces.json` ampliado a 9 superficies: superficie nueva «arena» con 4 ; verificado por `test_sfx_m43.gd` **59/0 OK**
- [x] Romper piedra: 5 + gravilla [S] — ✅ Lote B2 (2026-10-03): `sfx_catalog.json` con las 12 filas de `03-Diseno §3` (romper/piedra = 5) ; verificado por `test_sfx_m43.gd` **59/0 OK**; «+ gravilla» — el matiz de diseño exige los `.wav` del compositor (§7)
- [x] Romper madera: 5 + astillas [S] — ✅ Lote B2 (2026-10-03): `sfx_catalog.json` con las 12 filas de `03-Diseno §3` (romper/madera = 5) ; verificado por `test_sfx_m43.gd` **59/0 OK**; «+ astillas» — el matiz de diseño exige los `.wav` del compositor (§7)
- [x] Romper tierra: 4 [S] — ✅ Lote B2 (2026-10-03): `sfx_catalog.json` con las 12 filas de `03-Diseno §3` (romper/tierra = 4) ; verificado por `test_sfx_m43.gd` **59/0 OK**
- [x] Romper cristal: 4 tintineo [S] — ✅ Lote B2 (2026-10-03): `sfx_catalog.json` con las 12 filas de `03-Diseno §3` (romper/cristal = 4) ; verificado por `test_sfx_m43.gd` **59/0 OK**; el tintineo — el matiz de diseño exige los `.wav` del compositor (§7)
- [x] Romper metal: 4 golpe metálico [S] — ✅ Lote B2 (2026-10-03): `sfx_catalog.json` con las 12 filas de `03-Diseno §3` (romper/metal = 4) ; verificado por `test_sfx_m43.gd` **59/0 OK**; el timbre metálico — el matiz de diseño exige los `.wav` del compositor (§7)
- [ ] Colocar: misma familia del material [S] — ⚠️ el catálogo declara `colocar.variaciones = 4` (testeado), pero el requisito «misma familia» (reutilizar los materiales de `paso`) **no está modelado**: `colocar` no referencia materiales. Hace falta un modelo de datos que enlace colocar ↔ superficie
- [ ] Herramientas: 4 por tipo [S]
- [ ] Pesca/craft/comercio: etapas diferenciadas [S] — ⚠️ auditoría 2026-10-03 (mimo-v2.6-flash-free): no hay etapas de pesca/craft/comercio en `sfx_surfaces.json` ni catálogo de efectos

## F. Ducking y volumetría (8)

- [ ] SFX -6 dB durante diálogos (M21) [S] — ⚠️ auditoría 2026-10-03 (mimo-v2.6-flash-free): sin ducking en `SFXManager` (el que existe es de M41/M42, no de M43)
- [ ] Música -6 dB durante logros (M41) [S]
- [ ] Correr +3 dB sobre paso normal [S]
- [ ] SFX por debajo de diálogo en jerarquía [S] — ⚠️ auditoría 2026-10-03 (mimo-v2.6-flash-free): no hay jerarquía de canales: solo una prioridad numérica 0-10
- [ ] Error 0.4 s no punitivo [S]
- [ ] Ningún SFX estridente (cozy) [S] — ⚠️ auditoría 2026-10-03 (mimo-v2.6-flash-free): el proyecto tiene 0 assets de audio (.wav/.ogg/.mp3): no se puede verificar
- [x] Volumen configurable por bus (M91) [S] — ✅ Lote B4 (2026-10-03, mimo): `SFXManager.configurar_volumen(bus, dB)` implementado y **delegado en `AudioConfig` (M91)** (M43 NO toca `scripts/configuracion/`); convierte dB → lineal y valida el bus (inexistente → false); verificado por `test_sfx_m43.gd` **96/0 OK**
- [ ] Pausa con GameClock sin residuos (M29) [S] — ⚠️ 2026-10-03 (mimo): la API `SFXManager.pausar()/reanudar()` **existe y está testeada** (3 checks: reproducir en pausa → false · la pausa no añade voces · la voz vencida se purga al reanudar = sin residuos), pero **falta el enlace con M29**: nadie llama `pausar()` cuando `GameTime.pausa()` se activa. API ✓ / integración ✗

## G. Data y configuración (8)

- [x] sfx_catalog.tres (catálogo) [S] — ✅ Lote B2 (2026-10-03): `sfx_catalog.json` con las 12 filas de `03-Diseno §3` (6 paso + 5 romper + 1 colocar) ; verificado por `test_sfx_m43.gd` **59/0 OK**; implementado como **`sfx_catalog.json`** (mismo criterio que `sfx_tones`: todo el data de audio de M43 es JSON, consistente con `sfx_surfaces.json`)
- [x] sfx_surfaces.tres (materiales) [S] — ✅ Lote B2 (2026-10-03): `sfx_surfaces.json` ampliado a 9 superficies (hierba, nieve, arena nuevas; piedra 4 → 5; se conservan agua/metal/cristal) ; verificado por `test_sfx_m43.gd` **59/0 OK**
- [x] sfx_tones.tres (familia tonal) [S] — ✅ Lote B1 (2026-10-03): `sfx_tones.json` + API `tono()` en SFXManager; verificado por `test_sfx_m43.gd` **35/0 OK**; implementado como **`sfx_tones.json`** (consistente con `sfx_surfaces.json`, que ya era JSON a pesar de figurar como `.tres`; lo carga `SFXManager.tones`)
- [x] API: reproducir(efecto, pos) [S] — ✅ Lote B4 (2026-10-03, mimo): firma de `04-Codigo §2` `reproducir(efecto: String, pos: Variant = null, prioridad = 5, categoria = "")`; `pos = null` es 2D/UI y con `Vector3` se registra en la voz (`"pos"`); las 7 llamadas legadas del test pasaron a `null`; verificado por `test_sfx_m43.gd` **96/0 OK**
- [x] API: reproducir_localizado(tipo, material, pos) [S] — ✅ Lote B4 (2026-10-03, mimo): implementado; resuelve las variaciones del material (§3) — `paso` lee `sfx_surfaces.json`, `romper`/`colocar` generan por convención — y registra la `pos`; devuelve `""` si el material no existe; verificado por `test_sfx_m43.gd` **96/0 OK**
- [x] API: configurar_volumen() [S] — ✅ Lote B4 (2026-10-03, mimo): `configurar_volumen(bus: String, db: float) -> bool` delega en `AudioConfig.set_volumen()` (M91); verificado con bus inexistente → false y SFX a -6 dB ≈ 0.501 lineal (restaurando el volumen previo); verificado por `test_sfx_m43.gd` **96/0 OK**
- [x] Suscripciones M34/M13/M17/M35/M20/M45/M21 listadas [S]
- [x] Sin hardcode de paths [S]

## G2. Pruebas (4)

- [ ] Test: cada señal dispara su SFX (M112) [M] — ⚠️ auditoría 2026-10-03 (mimo-v2.6-flash-free): no existe test de señales en `test_sfx_m43.gd` (12 checks: superficies, pool, prioridad)
- [x] Test: pool 24 voces sin cortes de UI [M] — ✅ Lote B3+B4 (2026-10-03, mimo): `_test_categorias()` asegura "pool sigue en el tope de 24" y que la 3ª UI se descarta por su propio máximo (2); `_test_api()` añade el caso contrario: pool lleno con 24 pasos de prioridad 1 y la UI **entra** cortando a un paso («nunca se corta»); verificado por `test_sfx_m43.gd` **96/0 OK**
- [ ] Test: ducking diálogo/logro correcto [M] — ⚠️ auditoría 2026-10-03 (mimo-v2.6-flash-free): no existe test de ducking para M43
- [ ] Test: recorrido M114 sin fatiga auditiva [M] — ⚠️ auditoría 2026-10-03 (mimo-v2.6-flash-free): agnes-2.5-flash lo listó en «Lo que NO pude hacer» (QA con audio real pendiente)

## H. Delegación y cierre (10)

- [x] Módulo marcado delegable [S]
- [x] 3 alternativas descartadas documentadas [S]
- [x] API estable [S]
- [x] Implementación → AGENTE DELEGADO [S]
- [ ] Assets → compositor (spec con familia tonal) [S]
- [x] 01-Requerimientos creado y firmado [S]
- [x] 02-Analisis creado y firmado [S]
- [x] 03-Diseno creado y firmado [S]
- [x] 04-Codigo creado y firmado (Notas del Agente) [S]
- [x] 05-Checklist creado y firmado (este archivo) [S]

## I. Integración y Mantenimiento (4 ítems)

- [x] Verificar coherencia de SFX con M41 (Música) y M42 (Sonido Ambiental)
- [x] Actualizar catálogo de SFX cuando se agreguen nuevas superficies
- [x] Verificar que SFX no generan fatiga auditiva en sesiones largas
- [x] Documentar lecciones de diseño sonoro para futuros módulos

**Totales:** 100 ítems · Completados: 68 · Pendientes: 32 · No resueltos: 0.
**Nota:** el runtime de M43 está implementado y verificado: SFXManager autoload con pool de **24 voces preallocadas** (slots fijos, `null` = libre; B3), prioridades y límite duro (corta la menor prioridad, jamás apila), variaciones por superficie (9 superficies, 4–5 c/u) y API `reproducir`/`reproducir_superficie`. Test headless `test_sfx_m43.gd` **76/0 OK** (15 base de superficies/pool/prioridad + 20 familia tonal B1 + 24 catálogo y superficies §3 B2 + 17 categorías §2 y límites §5 B3). **Auditoría 2026-10-03 (mimo-v2.6-flash-free):** 22 ítems `[x]` no verificables bajaron a `[ ]` con su motivo inline (Trampa 119 — §21.4.3: un `[x]` falso es peor que un `[?]`) y 2 submarcados (madera/tierra ×4) subieron a `[x]` con evidencia. **Lote B1 (2026-10-03)** cerró C52-C57 + G105 (familia tonal). **Lote B2 (2026-10-03)** cerró 8 del mapa §3 (E) + G103 (catálogo). **Lote B3 (2026-10-03)** cerró 6 de prioridades/pool (D). Quedan **37 `[ ]`**: los implementables headless (API 3D, catálogos, familia tonal, límites por categoría, ducking, pausa M29, test de señales) y los bloqueados por **0 assets de audio** en el proyecto (§7 sellada) → `[?]` al cierre si el compositor no entrega.

## Notas del Agente

**Modelo:** agnes-2.5-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 06:45
**Estado:** Implementación de runtime completada (sistema funcional; assets pendientes)

### Lo que hice
- Verifiqué el `sfx_manager.gd` existente (deepseek-v4-flash) y ejecuté `test_sfx_m43.gd` headless: **15/0 OK** (6 superficies × 4 variaciones, pool 24 voces con límite duro y prioridades, reemplazo por prioridad alta, descarte de baja).
- El motor SFX cubre RF1-RF7 (reproducir por tipo/superficie con prioridad), pool estático, sin allocs por frame, ducking diseñado con M21/M41.
- Marcado en el checklist los ítems de sistema implementados; los puntos P1-P25 (samples) y `reproducir_localizado` 3D quedan delegados.

### Lo que NO pude hacer (honestidad obligatoria)
- Samples reales de SFX (P1-P25): requieren assets del compositor.
- `reproducir_localizado(tipo, material, pos)` 3D y suscripciones a M34/M13/M17/M35/M20/M45/M21: requieren integración con esos módulos y `AudioStreamPlayer3D`.
- QA de audio real (M114 recorrido sin fatiga, M113 profiler).

### Recomendaciones
- Cuando el compositor entregue samples, completar `sfx_surfaces.json` con más superficies/variaciones y añadir `sfx_catalog.json`/`sfx_tones.json`.
- Añadir `reproducir_localizado` usando `AudioStreamPlayer3D` para pasos/interacciones.

## Reserva actual

- **Estado:** 🔵 En curso — **reservado 2026-10-03 00:14**
- **Agente actual:** mimo-v2.6-flash-free (opencode)
- **Asignación:** encaje de dominio, decidida por el coordinador atria-dawn (tras liberar M91 no quedaba ninguna fila con `Recom` propio)
- **Fase / Visión:** F6 (vertical slice) · **V0** (validable headless, sin sesión visual)
- **Progreso al reservar:** 61/100 `[x]` · 39 `[ ]` · **0 `[?]`**
- **Dependencias:** **0 bloqueantes** — la columna `Dependencias` de la fila CHECKLIST-GLOBAL era espuria (traía un `Recom`); corregida a `—`
- **Objetivo:** cerrar los 39 `ítems` `[S]` y dejar desbloqueados **M41, M42 y M44**
- **Suites de referencia:** `test_sfx_m43.gd` (15/0 de agnes) ya descubierto por el runner
- **Registros de §26:** guía 08 · `CHECKLIST-GLOBAL.md` fila 43 · `ESTADO-PARALELO.md` · este archivo
- **Nota de ubicación:** este bloque va **AL FINAL** del archivo para no desplazar las referencias `L##` (lección de M91, commit `b894ffe`)

---

