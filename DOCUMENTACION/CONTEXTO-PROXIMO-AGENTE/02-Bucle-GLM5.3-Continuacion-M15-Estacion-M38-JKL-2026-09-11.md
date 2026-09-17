# 02-Bucle-GLM5.3-Continuacion-M15-Estacion-M38-JKL-2026-09-11

## Fecha
2026-09-11 (sesión de continuación, 4 ciclos: ~17:15 → ~22:40)

## Identidad del agente que escribió esto

**Modelo:** GLM-5.3 (flagship de Z.ai, 743B, **NO la variante flash**)
**Plataforma:** Kilo Code
**Firma definida por el usuario:** "GLM-5.3 / Kilo Code" — con ese nombre firmá todo.

⚠️ **CRÍTICO para vos (próximo agente):** si sos GLM-5.3 flagship en Kilo Code, continuás ESTA línea de trabajo con ESTE backlog. Si sos OTRO modelo, NO tomes los módulos de esta línea como tuyos — usá tu propio backlog en `DOCUMENTACION/TAREAS-POR-MODELO/<tu-modelo>/`.

## Contexto de la sesión

Sesión de continuación directa de `01-Bucle-GLM5.3-Backlog-Propio-M13-M15-M38-2026-09-11.md` (**leerlo primero**: contiene el perfil de capacidades, el límite solo-texto verificado empíricamente, las decisiones de diseño de M13/M15/M38 de esa sesión y las lecciones de arranque).

El usuario pidió "continuá con todo lo que estabas haciendo" y luego dos veces más "seguí" — esta sesión ejecutó **4 ciclos del bucle** (bloquear → leer → implementar → testear headless → documentar → liberar → siguiente):

| # | Módulo | Iteración | Log | Resultado |
|---|--------|-----------|-----|-----------|
| 1 | M15-Recursos | iter 5 | 821 | ✅ CERRADA — handler estacion_cambio |
| 2 | M38-Economía | iter 5 | 822 | ✅ CERRADA — secciones J/K/L + docs M/N |
| 3 | M38-Economía | iter 5b | 823 | ✅ **COMPLETADO 163/163** — cierre total |
| 4 | M29-Tiempo | iter 1 | 824 | ✅ CERRADA 194/195 — auditoría 47 + semilla H120 |

---

## Ciclo 1: M15-Recursos iter 5 (Log 843) — CERRADA ✅

**Entrada:** el [?] P.2/L.1 heredado de iter 3-4 (el "último [?] lógico barato de la familia M13/M15" según el plan del archivo 01).

**Qué se implementó (`resource_manager.gd`):**
- `_conectar_estacion_cambio()`: conexión idempotente a `GameTime.estacion_cambio` con bandera `_gt_estacion_conectada` (mismo patrón del `dia_cambio` existente). Se llama desde `_registrar_proveedor_guardado()` — mismo punto de arranque.
- `_on_estacion_cambio_m29(_estacion)`: dispara `_evaluar_respawn_global()` (respawn masivo estacional — el FILTRO por estación ya vivía en `ResourceNode.evaluar_respawn()` de la iter 3, NO duplicar) + aviso suave cozy `[M15] estación cambió — recursos estacionales re-evaluados (respawns disponibles: N)` (ítem L.2).
- `_contar_respawns_disponibles()`: cuenta nodos AGOTADOS con ciclo vencido + estación compatible — solo para el aviso.

**Test:** `test_estacion_iter5.gd` (NUEVO, 12 checks): conexión real con `get_connections()` + idempotencia (re-llamar no duplica) + nodo estacional PRIMAVERA (def ad-hoc `temporada_respawn = &"primavera"`) NO respawnea con señal de VERANO y SÍ con PRIMAVERA + nodo "todas" (`piedra_caliza`, `respawn_estacion == -1`) respawnea en cualquier cambio.

**LECCIÓN CLAVE del ciclo:** al testear handlers de señales estacionales, la señal emitida debe ser COHERENTE con el estado del reloj: setear `_mes` Y emitir `emit_signal` (patrón del test oficial M16 `test_crafting.gd` L229). Si solo emitís la señal sin tocar `_mes`, `_evaluar_respawn_global()` lee la estación con `gt.get_estacion()` (derivada de `_mes`) y el test valida un estado imposible que falla.

**Regresiones 0 fallos:** test_recursos (iter 1), test_recurso_nodo (iter 2), test_recursos_persistencia (iter 3), test_recursos_spawner_runtime (iter 4), M16 test_crafting (consume `estacion_cambio`), M35 test_mineria.

**Resultado:** ítems L.1/L.2 base marcados [x] con evidencia. **M15 queda con SOLO 2 [?] externos: meshes (M45/M47) y área 3×3 (M13).** 75/222.

---

## Ciclo 2: M38-Economía iter 5 (Log 844) — CERRADA ✅

**Entrada:** secciones J-N que la iter 4 (Log 819) dejó PARCIAL por fin de sesión.

**Brechas REALES de código cerradas (antes muertas/ausentes):**

1. **K.4 + I.9 — rebaja 50% por límite diario:** `FACTOR_EXCEDIDO_DIARIO` (0.5) era constante MUERTA y la señal `precio_rebajado` NUNCA se emitía. Ahora `precio_venta_vigente()` aplica el 50% cuando `precio_rebajado_hoy()`, y `registrar_venta()` emite `precio_rebajado(item, antes, después)` UNA sola vez al CRUZAR el límite. Extraje `_precio_venta_base()` (tope 0.6 + estacional + feria + oferta, SIN rebaja) para calcular el "antes" sin mutar estado.
2. **L.1 — índice O(1):** `EconomyPriceCatalog._indice` (Dictionary item_id→PriceDefinition) construido una vez en `get_catalog()`/`_construir_indice()`; `get_price_def()` pasa de O(n) lineal a O(1) con fallback lineal defensivo. Cada cálculo de precio consulta 2-3 veces (base/rareza/temporada/variabilidad).
3. **L.3 — caché de tabla del día:** `_cache_tabla_dia` + `_cache_tabla_valida` en `tabla_del_dia()` — invalidada por `registrar_venta`/`recalcular_tabla_dia`/`aplicar_precios_feria`/`limpiar_precios_feria`/`forzar_estacion`. Consultas con `item_ids` explícito NO usan caché (consulta puntual de tienda).
4. **L.6 + J.8 — caché de amistad + señal M20:** `_cache_desc_amistad[npc] = {nivel, desc}` + `invalidar_cache_amistad(npc)`; `EconomyManager._conectar_senal_amistad_m20()` conecta la señal M20 → `_on_nivel_amistad_cambio` → invalidación. ⚠️ **La señal M20 vive en el DOMINIO `EventBus.progresion`** (`bus.get("progresion")`, clase ProgresionEvents), NO en el autoload Friendship.
5. **L.7 — tope de ventana:** `MAX_ENTRADAS_VENTANA = 120` en `_podar_ventana()` — memoria constante ante picos.
6. **I.10 — DOM-ECO-MERCADO con motivos:** prints en `_ajuste_estacional` (temporada_bono/temporada_penalizacion) y `_ajuste_por_oferta` (oferta_saturada), SOLO cuando el ajuste aplica (día sin ventas no loguea).

**Auditoría con evidencia:** 34 ítems [x] en J/K/L con número de línea/test. Destacado: **anti-arbitraje J.5/J.7 verificado con DATOS REALES** — venta `pico_cobre` (60) < Σ venta de sus materiales (madera 6×3 + cobre 15×4 = 78).

**Docs (ítem M):** `06-Plan-Testings.md` CREADO (pruebas T1-T10 + lista de regresión obligatoria de 12 suites) + `07-Resultados-Testings.md` CREADO. Notas del Agente en `04-Codigo.md`.

**Test:** `test_iter5_jkl.gd` (NUEVO, 33 checks) + 11 suites de regresión 0 fallos (incluye M39 tiendas, M16 crafting, M59 autosave).

---

## Ciclo 3: M38-Economía iter 5b (Log 823) — ✅ COMPLETADO 163/163

**Entrada:** los 2 [ ] restantes (meta-ítems M.6/M.8) + las 2 pruebas que la iter 5 dejó "definidas pero no corridas" por presupuesto de sesión (honestidad de esa iter).

**Qué se ejecutó de verdad:**

1. **T7 — descuentos por amistad en 3 niveles REALES** (`test_t7_amistad.gd` NUEVO, 12/12):
   - Niveles 2/3/4 forzados con `VecinoAmistad.aplicar_puntos` sobre el autoload Friendship REAL (umbrales reales de amistad: **20/40/70 puntos → niveles 2/3/4**).
   - Descuentos 5/10/15% EXACTOS con `tela_lino` (60 → 57/54/51).
   - El 5% sobre `madera_roble` (10) se absorbe en el redondeo: `round(9.5) = 10` (half-UP de Godot) — documentado como matemática de enteros del diseño, NO bug.
   - Tope combinado amistad 15% + volumen 15% → clamp 20% (tela 60 → 48).
   - `EconomyManager` CONECTADO a la señal M20 verificado con `get_connections()` + emisión real sin crash.
2. **T9 — rendimiento 5000 transacciones** (`test_t9_rendimiento.gd` NUEVO, 6/6):
   - 5000 tx mixtas (1667 depósitos ×2 + 1667 retiros rechazados SIN_FONDOS + 1666 ventas de mercado con días progresivos) en **0.04 s**.
   - Ventana de oferta: 120 entradas exactas (tope L.7). Historial anillo: 200. 1000 consultas de `tabla_del_dia` cacheadas: **7 ms**. Delta de saldo: +3334 exacto.
3. **M.8 — verificación por hash EJECUTADA:** plan-inicial SHA256 `B7395E50…` (158 ítems, plan original) vs plan-actual `E5EF0038…` (163 ítems): divergencia INTENCIONAL documentada como decisión formal (AGENTS §3: plan-actual refleja el código real; la copia byte a byte SOLO aplica al crear el módulo §11.7 — copiar borraría 6 iteraciones de historial).
4. **M.6 — cerrado con conteo:** 163/163 (el checklist creció de 146 con las iteraciones; los 146 originales están todos cubiertos).

**Regresión del cierre: 14 suites, 0 fallos.**

**Lecciones 5b:**
1. `round()` de Godot es half-UP (`round(9.5)=10`, `round(8.5)=9`): al testear descuentos con precios chicos, el descuento se puede absorber en el redondeo — validar con un precio que lo haga visible.
2. Tests contra autoloads con estado compartido: verificar DELTAS, no valores absolutos (el saldo inicial puede diferir de `SALDO_INICIAL` por corridas previas en la misma sesión de test).
3. Umbrales de amistad: 20/40/70 puntos; `aplicar_puntos` es la vía canónica para forzar niveles en tests.

**RESULTADO: M38-Economía ✅ COMPLETADO — 163/163 [x], 0 [ ], 0 [?].** Trayectoria completa: 6 iteraciones, 4 agentes (Logs 235→538→544→819→822→823). **Esperando QA cruzado §21.8 — verificador: Hy3 por regla (distinto del autor).**

---

## Ciclo 4: M29-Tiempo-Y-Calendario iter 1 (Log 824) — CERRADA ✅ 194/195

**Entrada:** siguiente del BACKLOG-MASTER (47 pendientes). Contexto: núcleo ✅ por ox-alpha (Logs 174/175) + QA cruzado Hy3 (2026-09-01) con hallazgo honesto: "el gap es de MARCADO (47 [ ] del template base sin marcar), no de implementación" — exactamente mi especialidad (auditoría doc↔código).

**Qué se hizo:**

1. **Auditoría de los 47 [ ]** con técnica de evidencia (línea de código / test / data .tres por ítem) → 194/195 [x]. Los ítems de consumo (sección F: rutinas/tiendas/cultivos/fauna/pesca) se marcan por el HOOK operativo de M29 + dueño del contenido identificado; los de data (C/D: eventos, nombres, iconos) por el .tres; los de docs (A/I) por existencia verificada. La sección "Estado real de implementación" (2026-08-28) del propio checklist ya documentaba la mayoría — mi trabajo fue tender el puente formal.
2. **La ÚNICA brecha REAL encontrada: H120 — semilla de tiempo por partida.** `usar_semilla_tiempo = true` existía en `time_config.tres` desde la creación del módulo pero **NADIE la consumía** (grep: 0 usos). Implementada en `game_clock.gd`:
   - `_semilla_partida` generada UNA vez por partida con `randi()` del motor (C56-safe — ver pitfall abajo).
   - `get_semilla_partida()` / `set_semilla_partida(int)` — para M59 y tests.
   - **`valor_diario(ns_consumidor, minimo, maximo)`** — entero determinista del día actual por namespace (misma partida + mismo día + mismo namespace = mismo valor).
   - **`rng_diario(ns_consumidor)`** — RandomNumberGenerator reproducible del día.
   - Hash **FNV-1a 32 bits** (módulo 2^31) sobre `semilla_partida + dia_absoluto + ns_consumidor` — determinista entre sesiones Y entre versiones del motor (hash() de Godot no lo garantiza).
   - Persistencia: `"semilla_partida"` en el save sección "time" — misma secuencia al recargar.
   - Flag `usar_semilla_tiempo`: true = por partida (default), **false = semilla 0 = modo determinista global (tests/QA reproducibles)**.
3. **Test:** `test_semilla_iter1.gd` (NUEVO, 25 checks 0 fallos): determinismo, namespaces independientes, secuencia rng reproducible, semilla viaja en save y se restaura, valor depende del día absoluto, señales API G, 17 métodos públicos completos, nombres del config (H119: Lunes/Floración/Primavera), formatos 12/24h (B42), ventana aviso 24h (C59).
4. **1 [?] honesto:** "Flecha indicadora en el HUD" (sección D) — widget visual que apunta al evento, UI de M53; M29 expone `evento_proximo` y `formatear_hora()`, pero la flecha no existe y soy solo-texto (§16 guía 10).

**BUG PREEXISTENTE encontrado, verificado con A/B git stash y registrado en 11-BUGS.md:**
`caso_reloj_tests.gd` (M30) falla 1/29 checks: `[FALLO] C56/E89/E90: 0 lecturas de reloj-SO en gameplay (681 archivos escaneados)`. **Verificado: falla IGUAL sin mis cambios** (stash de game_clock.gd → 29/1 idéntico). Causa: el scan anti-reloj-SO de M30 marca falsos positivos — `scripts/ci/cicd_manager.gd` usa `Time.get_unix_time_from_system()` y la carpeta `ci/` NO está en `WHITELIST_RELOJ_SO`; el propio test contiene los strings-patrón. Fix sugerido delegado al dueño de M30: (1) agregar `res://scripts/ci/` a la whitelist con comentario de criterio, (2) excluir el propio test del escaneo, (3) print de positivos en el FALLO. Mi semilla NO dispara el scan (usa `randi()`).

**Pitfalls NUEVOS de la iteración (todos documentados en el registro J del checklist M29):**
1. **`namespace` como nombre de parámetro = parse error** en Godot 4.7 ("Expected parameter name") — usar `ns_consumidor` o similar.
2. **`String.utf8()` NO existe** — es `to_utf8_buffer()` (Array de bytes iterable con `for ch in ...`).
3. **PowerShell 5.1 `Set-Content` introduce BOM UTF-8 en archivos .gd** tras ediciones masivas — saneamiento §28 (quitar BOM + re-test) tras CADA edición masiva con PowerShell. Detectado y corregido en `game_clock.gd` (re-test 25/25 tras saneamiento).
4. **La regla de oro C56 (cero reloj-SO en gameplay) aplica TAMBIÉN a la entropía de semillas:** usar `randi()` global del motor, jamás `Time.get_unix_time_from_system()` — el escáner de M30 lo detecta aunque el código corra una sola vez por partida. Mi primera versión usaba Time.get_unix y el scan la marcó; corregida a randi().

**Regresiones 0 fallos:** test_calendario 13/13 · test_consumidores_tiempo OK · M59 autosave · M15 estación (Log 843) · M35 minería · M38 tabla_dia 29/0 · caso_reloj 28/29 (el 1 = bug preexistente arriba).

**Resultado: M29 🟡 194/195 [x], 1 [?] con dueño (M53). QA cruzado §21.8 posible (Hy3).**

---

## Archivos modificados en la sesión (ruta completa desde raíz del repo)

**Código GDScript:**
- `game/isla-ancestral/scripts/resources/resource_manager.gd` (M15 iter 5: +`_gt_estacion_conectada`, +`_conectar_estacion_cambio`, +`_on_estacion_cambio_m29`, +`_contar_respawns_disponibles`)
- `game/isla-ancestral/scripts/resources/test_estacion_iter5.gd` (NUEVO, 12 checks)
- `game/isla-ancestral/scripts/economia/price_manager.gd` (M38 iter 5: +cachés L.3/L.6, +rebaja K.4, +`_precio_venta_base`, +tope L.7, +prints I.10, +invalidación por estación)
- `game/isla-ancestral/scripts/economia/economy_manager.gd` (+`_conectar_senal_amistad_m20`, +`_on_nivel_amistad_cambio`)
- `game/isla-ancestral/scripts/economia/economy_price_catalog.gd` (+`_indice` O(1), +`_construir_indice`)
- `game/isla-ancestral/scripts/economia/test_iter5_jkl.gd` (NUEVO, 33 checks)
- `game/isla-ancestral/scripts/economia/test_t7_amistad.gd` (NUEVO, 12 checks)
- `game/isla-ancestral/scripts/economia/test_t9_rendimiento.gd` (NUEVO, 6 checks)
- `game/isla-ancestral/scripts/time/game_clock.gd` (M29 iter 1: +semilla H120 — 6 funciones nuevas + persistencia + hook en _ready; BOM saneado)
- `game/isla-ancestral/scripts/time/test_semilla_iter1.gd` (NUEVO, 25 checks)

**Documentación:**
- `DOCUMENTACION/15-Recursos/plan-actual/05-Checklist.md` (sección R + L.1/L.2 + Reserva)
- `DOCUMENTACION/15-Recursos/plan-actual/04-Codigo.md` (Notas del Agente iter 5)
- `DOCUMENTACION/38-Economia/plan-actual/05-Checklist.md` (J/K/L/M/N con evidencia + registros O/P de iter 5/5b + header ✅)
- `DOCUMENTACION/38-Economia/plan-actual/06-Plan-Testings.md` (NUEVO — pruebas T1-T10 + regresión obligatoria)
- `DOCUMENTACION/38-Economia/plan-actual/07-Resultados-Testings.md` (NUEVO + corridas 5b)
- `DOCUMENTACION/38-Economia/plan-actual/04-Codigo.md` (Notas del Agente iter 5 y 5b)
- `DOCUMENTACION/29-Tiempo-Y-Calendario/plan-actual/05-Checklist.md` (47 ítems auditados con evidencia + sección J registro iter 1 + firma)
- `DOCUMENTACION/29-Tiempo-Y-Calendario/plan-actual/04-Codigo.md` (Notas del Agente iter 1)
- `DOCUMENTACION/11-BUGS.md` (2 bugs preexistentes con A/B — ver sección Bugs)
- `DOCUMENTACION/08-GUIA-ORDEN-DE-IMPLEMENTACION.md` (filas M38 ✅ y M15 🟡; M29 no tenía fila)
- `CHECKLIST-GLOBAL.md` (filas 15 🟡, 29 🟡 — fila 29 reconstruida porque tenía mojibake y una celda extra de un agente anterior —, 38 ✅)
- `Mensajes entre modelos/ESTADO-PARALELO.md` (entradas de las 4 iteraciones)

**Logs:** 821, 822, 823, 824 — todos con reserva previa protocolo v2 §6.1.a y borrado de la reserva al consumir.

---

## Estado actual de la línea (al cerrar esta sesión)

| Módulo | Estado | Progreso | Qué falta | Log |
|---|---|---|---|---|
| M38-Economía | ✅ **COMPLETADO** | 163/163 | **SOLO QA cruzado §21.8** (Hy3 por regla). Puntos verificables en Notas del Agente del 04-Codigo.md | 823 |
| M29-Tiempo | 🟡 | 194/195 | 1 [?] flecha HUD (UI M53). QA cruzado §21.8 posible | 824 |
| M15-Recursos | 🟡 | 75/222 | SOLO 2 [?] externos: meshes (M45/M47), área 3×3 (M13). Todo lo lógico CERRADO | 821 |
| M13-Herramientas | 🟡 | 84/120 | Verificación in-game V1 (USUARIO), puntería fina. Dueños externos: M16 mesa, M33 parcelas, M45 animación, M53 prompt F | 815 (sesión previa) |

**0 bloqueos 🔵 huérfanos míos.** Todos los módulos liberados con los 4 registros sincronizados (guía 08 / 05-Checklist / CHECKLIST-GLOBAL / ESTADO-PARALELO).

---

## Bugs preexistentes registrados en 11-BUGS.md (NO míos, con A/B verificado)

1. **BUG C56 (caso_reloj 28/29):** scan anti-reloj-SO de M30 marca falsos positivos — `scripts/ci/cicd_manager.gd` sin whitelist + el propio test contiene los strings-patrón. Fix delegado al dueño de M30 (~15 min: whitelist `res://scripts/ci/` + auto-exclusión + print de positivos). Registrado 2026-09-11 22:10.
2. **BUG test_loop_economico (M39):** `OBJ-PLA-001` sin precio en ItemDatabase ni econ_prices.tres (registrado en la sesión anterior, Log 819). Fix del dueño M159.

## ⚠️ Agents activos Y colisiones detectadas al cierre de esta sesión

1. **DeepSeek-V4.1-Flash (WorkBuddy) trabajaba M60-Datos-Y-Serializacion** con reserva 825 activa al momento del cierre — NO tocar M60 ni el número 825 sin verificar `Logs/reservas/`.
2. **COLISIÓN de log 844:** WorkBuddy escribió `Logs/844-WorkBuddy-M18BIS-Casona.md` usando el mismo número que yo ya había consumido (`822-M38-Iter5-Secciones-JKL-Docs...`). Caso residual del protocolo §6.1.d: ambos archivos existen con nombres distintos y las referencias cruzadas de cada documentación apuntan al suyo — NO renombrar nada. Lección reforzada: **SIEMPRE usar el bucle completo de verificación §6.1.a (archivo log + reserva + ULTIMO_NUMERO), nunca asumir que el número está libre aunque lo hayas leído hace minutos.**
3. WorkBuddy también había consumido 816-818 en tiempo real durante la sesión anterior — el protocolo v2 funciona, pero con agentes rápidos en paralelo las colisiones residuales ocurren.

---

## Decisiones tomadas (para no re-debatirlas)

1. **Señal `precio_rebajado` en el CRUCE del límite (`registrar_venta`), no en la consulta:** `precio_venta_vigente` la llama la UI repetidamente — emitir ahí sería spam por render. Un disparo por cruce es el contrato §5 correcto.
2. **El "antes" del aviso usa `_precio_venta_base()` extraído:** evita mutar `_ventas_hoy` temporalmente (primera versión descartada — frágil).
3. **Caché de amistad por NPC (nivel+desc), no por (npc, ítem):** el descuento aplica igual a todos los ítems del NPC; por pareja desperdiciaría memoria.
4. **Prints DOM-ECO-MERCADO solo cuando el ajuste aplica:** día sin ventas o ítem sin temporada no loguea (ruido cero).
5. **Aviso M15 L.2 = print con conteo:** la UI del aviso es de M53; el print deja el hook funcional.
6. **Entropía de semilla vía `randi()` del motor, NO Time.*:** regla de oro C56 — el gameplay nunca lee el reloj del SO, ni siquiera una vez por partida.
7. **FNV-1a propio (módulo 2^31) en vez de hash() de Godot:** estabilidad entre sesiones y versiones del motor.
8. **API aditiva en M29:** `valor_diario`/`rng_diario` se AÑADEN al contrato G — cero rupturas.
9. **M.8 copia byte-a-byte NO APLICA:** plan-actual divergió por N iteraciones (protocolo §3); copiar borraría el historial — verificado por hash y documentado.
10. **Ítems F (consumo) marcados por HOOK + dueño:** M29 entrega señales/consultas; el contenido es de M19/M33/M34/M08/M28/M36 — cada ítem documenta quién consume qué.

---

## Lecciones y pitfalls de la sesión (memoria colectiva)

**GDScript / Godot 4.7.2:**
1. `namespace` como nombre de parámetro = parse error ("Expected parameter name").
2. `String.utf8()` no existe — es `to_utf8_buffer()`.
3. `_ = expr` no es válida (asignación descartada).
4. `round()` es half-UP: `round(9.5)=10` — descuentos con precios chicos se pueden absorber.
5. Señal + estado coherentes en tests estacionales: setear `_mes` Y emitir (patrón test_crafting L229).
6. Señales del contrato en EVENTOS, no en consultas puras.
7. Nivel de amistad de NPC desconocido = **1** (no 0) en `FriendshipService.get_nivel`.
8. Umbrales de amistad: 20/40/70 puntos → niveles 2/3/4; `aplicar_puntos` para tests.
9. Regla C56 aplica también a entropía de semillas: `randi()`, jamás Time.get_unix.
10. Tests contra autoloads compartidos: DELTAS, no absolutos.

**PowerShell 5.1:**
11. `Set-Content` introduce BOM UTF-8 en .gd tras ediciones masivas → saneamiento §28 + re-test SIEMPRE.
12. `"$i:"` dentro de strings falla (`:` tras variable) — usar `("L" + $i + ":")` o `${i}:`.
13. `Start-Process` rompe rutas con espacios si no se entrecomillan los ArgumentList individualmente con `` `" `` .
14. Filtrar output de tests con `Where-Object { $_ -match '...' }` tras capturar con `Out-String` — el output directo se trunca visualmente.

**Protocolo multiagente:**
15. SIEMPRE el bucle completo §6.1.a para reservar logs — con WorkBuddy activo hubo colisión real en 822.
16. Tests de scan (como C56) tardan 1-2 min (escanean 681 archivos) — timeout generoso y de a uno.
17. A/B git stash es la herramienta para demostrar preexistencia de un fallo (usada 2 veces esta sesión).
18. Filas de CHECKLIST-GLOBAL pueden venir con mojibake y celdas desplazadas de agentes anteriores (fila 29) — reconstruir la fila completa en UTF-8 limpio al bloquear.

---

## Cómo ejecutar TODOS los tests de esta sesión

```powershell
$godot = "D:\ISLA ANCESTRAL\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe"
$game = "<raíz-del-repo>\game\isla-ancestral"
# NOTA: --script NO ejecuta autoloads visuales; los tests SceneTree SÍ bootean los
# autoloads (ResourceManager, GameTime, Inventario, SaveManager, EconomyManager,
# Friendship, TimeCalendar...) — por eso los tests usan root.get_node_or_null.
# Si un test usa una clase NUEVA: `& $godot --headless --path $game --import` primero.

# ── Tests NUEVOS de esta sesión (los 4 ciclos) ──
& $godot --headless --path $game --script res://scripts/resources/test_estacion_iter5.gd   # M15 iter5 — 12 checks
& $godot --headless --path $game --script res://scripts/economia/test_iter5_jkl.gd        # M38 iter5 — 33 checks
& $godot --headless --path $game --script res://scripts/economia/test_t7_amistad.gd       # M38 5b T7 — 12 checks
& $godot --headless --path $game --script res://scripts/economia/test_t9_rendimiento.gd   # M38 5b T9 — 6 checks
& $godot --headless --path $game --script res://scripts/time/test_semilla_iter1.gd        # M29 iter1 — 25 checks

# ── Regresión obligatoria de los módulos tocados ──
& $godot --headless --path $game --script res://scripts/resources/test_recursos.gd              # M15 iter1
& $godot --headless --path $game --script res://scripts/resources/test_recurso_nodo.gd          # M15 iter2
& $godot --headless --path $game --script res://scripts/resources/test_recursos_persistencia.gd # M15 iter3
& $godot --headless --path $game --script res://scripts/resources/test_recursos_spawner_runtime.gd # M15 iter4
& $godot --headless --path $game --script res://scripts/crafting/test_crafting.gd               # M16
& $godot --headless --path $game --script res://scripts/mineria/test_mineria.gd                  # M35
& $godot --headless --path $game --script res://scripts/economia/test_m38_economia_smoke.gd
& $godot --headless --path $game --script res://scripts/economia/test_edge_cases_precio.gd
& $godot --headless --path $game --script res://scripts/economia/test_topos_banda.gd
& $godot --headless --path $game --script res://scripts/economia/test_minorista_mayorista.gd
& $godot --headless --path $game --script res://scripts/economia/test_tabla_dia_transacciones.gd
& $godot --headless --path $game --script res://scripts/economia/test_mercado_estacion_ferias.gd
& $godot --headless --path $game --script res://scripts/economia/test_barter.gd
& $godot --headless --path $game --script res://scripts/economia/test_iter4_brechas.gd
& $godot --headless --path $game --script res://scripts/shops/test_tiendas.gd                   # M39
& $godot --headless --path $game --script res://scripts/saving/test_autosave_m59.gd              # M59
& $godot --headless --path $game --script res://scripts/time/test_calendario.gd                  # M29 núcleo 13 checks
& $godot --headless --path $game --script res://scripts/time/test_consumidores_tiempo.gd         # M29 consumidores
# ⚠️ LENTO (scan de 681 archivos, 1-2 min) Y con 1 fallo PREEXISTENTE conocido (bug C56, 11-BUGS.md):
& $godot --headless --path $game --script res://scripts/clock/caso_reloj_tests.gd                # M30 — 28/29 esperado
```

**Sumbado esperado de la sesión: 5 tests nuevos = 88 checks 0 fallos. Regresiones: ~26 suites, todas 0 fallos salvo caso_reloj 28/29 (bug preexistente documentado).**

---

## Por dónde seguir (próximo agente GLM-5.3 — en este orden)

1. **Verificación anti-colisión SIEMPRE antes de bloquear** (el usuario lo pidió explícitamente): `Logs/reservas/` + `CHECKLIST-GLOBAL.md` (fila del módulo sin 🔵 de otro) + `Mensajes entre modelos/ESTADO-PARALELO.md` + el `05-Checklist.md` del módulo. Al cierre de esta sesión DeepSeek-V4.1-Flash tenía M60 con reserva 825.
2. **QA cruzado §21.8 pendiente de esta línea (verificador: Hy3 por regla, distinto del autor):**
   - M38 ✅ (Log 823): reproducibles en <10 s — test_t7_amistad (12/12), test_t9_rendimiento (6/6), señal `precio_rebajado` cruzando límite (4 ventas de madera_roble), índice O(1) vs lineal, conexión señal M20 con `EventBus.progresion.nivel_amistad_cambio.get_connections()`.
   - M29 🟡 (Log 824): test_semilla_iter1 (25/25) + test_calendario (13/13) + revisar el único [?] (flecha HUD, dueño M53).
   - M15 iter 5 (Log 843): `GameTime.estacion_cambio.get_connections()` en runtime.
3. **Siguiente del backlog propio** (`DOCUMENTACION/TAREAS-POR-MODELO/glm-5.3/BACKLOG-MASTER.md`): **M153-Objetivo-Final (10 pend)** → **M30-Reloj (2 pend)** → M31-Ciclo-Dia-Noche (132) → M32-Clima (37) → M34-Pesca (144) → M145/M146/M149 (diseño, pocos ítems) → M18-Casas (122) → M35-Minería (82) → M28/M37/M71/M72/M158.
   - ⚠️ **M18-Casas:** WorkBuddy tiene M18-BIS activo (log 844 colisionado) — verificar ESTADO-PARALELO antes de tocar.
4. **M93-Balance:** EN ESPERA histórica de glm-5.3-flash (Cline, reserva del 2026-09-01 sin log de iter 3 → probablemente huérfana; las 24h+ pasaron). Verificar si flash la retomó; si no, ES reclamable — backlog `TAREAS-POR-MODELO/glm-5.3/93-Balance/checklist.md` (64 tareas). Ver `Logs/258/263/333` para el núcleo previo.
5. **Consumidores futuros de la semilla M29:** cuando toques M34-Pesca/M74-Eventos, usar `GameTime.valor_diario("<tu_modulo>", min, max)` para variación diaria determinista — es el patrón canónico nuevo.

## Pendiente del USUARIO (no resuelto por ser visual/decisiones propias)

- **V1 verificación in-game del cableado M13→M15** (de la primera sesión): tecla 2 (hacha) → mirar árbol `madera_roble` → golpear con E. El headless valida la cadena; falta el "feel".
- Verificación visual opcional del respawn estacional (M15 iter 5): avanzar el calendario en juego a otra estación y ver el print `[M15] estación cambió`.
- El QA cruzado de M38/M29 requiere sesión de Hy3 (WorkBuddy) — el usuario debe abrirle sesión a ese modelo.

---

**Modelo:** GLM-5.3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-11 22:45
**Estado:** Sesión cerrada por el usuario. **4 ciclos completados** (M15 iter 5 ✅ Log 843, M38 iter 5 ✅ Log 844, **M38 iter 5b ✅ COMPLETADO 163/163 Log 823**, M29 iter 1 ✅ 194/195 Log 824). 5 tests nuevos (88 checks, 0 fallos), ~26 suites de regresión 0 fallos (caso_reloj 28/29 con bug preexistente A/B-verificado y registrado), 0 bloqueos huérfanos, 2 bugs preexistentes registrados en 11-BUGS.md, 1 colisión de log documentada (822/WorkBuddy). **M38-Economía es el PRIMER módulo completado por esta línea GLM-5.3** — esperando QA cruzado §21.8 por Hy3.
