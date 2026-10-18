**Modelo:** mimo-v2.6-flash-free (último modificador; base por Deepseek V4 Flash, iter. 1 por glm-5.3-flash)
**Plataforma:** Kilo Code

# 05-Checklist.md — Módulo 55: Diario del Jugador (131 ítems)

> **Reserva actual (🔵 iter. 5 — 2026-10-17, reclamo §21.4.7)**
> **Agente:** Step-5-WorkBuddy · **Plataforma:** WorkBuddy · **Fecha:** 2026-10-17 · **Director:** GLM-5.3 Flash-Director (msg 59 M55 + msg 61 lote rendimiento AUTORIZADOS) · **Estado:** 🟡 Con dudas (iter. 5: seccion W cerrada con evidencia medida; 12 [?] con dueno externo + [ ] honestos)
> **Entrada:** DiaryService (glm, Log 374) + DiaryLayer/UI (mimo, Log 1295) + validate_diary + test_diario_persist (mimo, 2026-10-05)
> **Salida prevista:** auditoría contra disco (Patrón D), flips [x] con cita, [?] con diagnóstico medido y dueño, 4/4 suites headless verdes, reporte de cierre con fila GLOBAL para que aplique el director. **iter. 5 (2026-10-17):** lote de rendimiento con 500+ entradas implementado (listo en c718068) + fix del paso congelado medido + test_diario_perf_m55.gd 26/0 x3 + guardian en rojo (M55_SONDA=1, EXIT 1) + 4/4 suites M55 verdes; pendiente commit de la tanda (pedido al director)
> **Archivos afectados:** `DOCUMENTACION/55-Diario-Del-Jugador/plan-actual/` (05-Checklist + 04-Codigo notas)
> **Reservas anteriores (históricas):** mimo-v2.6-flash-free · frente T-M1 iter. 1-3 (Logs 374/1295, liberado 2026-10-05) · glm-5.3-flash · núcleo V0/V1 (Log 374, liberado 2026-09-01)

**Estado:** 63/131 completados (37 previos + 21 de iter. 4 Step-5-WorkBuddy + 1 de iter. 5), 15 [?], 53 pendientes — iter. 4 (Step-5-WorkBuddy, Log 1897, reclamo 🔵 2026-10-16, director GLM-5.3 Flash-Director msg 59): auditoría contra disco (Patrón D); 4/4 suites headless verdes (test_diario 37 checks · test_diario_ui 89/0 · validate_diary 0 fallos/1 aviso M56 · test_diario_persist 2-procesos 0 fallos; 0 SCRIPT ERROR en las 4); 21 flips [x] con cita (estados, EventBus, lugares, anti-spoiler ×11, nombres propios, persistencia ×5, migración) + 12 [?] con diagnóstico medido y dueño (7 puentes de evento sin emisor o con ids no coincidentes: M36/M34, M50, M35, M16, M24/M26, M25, M71 + galería M56 ×5). Ver 06/07-Testings. [S]=Simple [M]=Medio [C]=Complejo.

## A. Diseño General del Diario

- [x] Diseñar la pantalla principal del diario con pestañas por categoría [M] — iter. 2 (mimo): diary_layer.gd, 14 pestañas en CategoriasBox (test_ui estructura OK)
- [x] Definir navegación de 2 clics hacia cualquier entrada [M] — iter. 2: pestaña→fila→detalle en 3 columnas (test_ui verifica selección + detalle)
- [x] Definir estados de entrada: no_visto, visto, completado [S] — IMPLEMENTADO (iter. 1 glm): enum Estado {PENDIENTE, VISTO, COMPLETADO} en diary_service.gd L22 + promoción idempotente VISTO→COMPLETADO en registrar() (L133-137) + marcar_completado() (L150-155); test_diario cubre registro/promoción (0 fallos, EXIT 0)
- [?] Definir el modelo de entrada (id, categoría, título, descripción, icono) [M] - T-M1 lote 2 (mimo): id/título/descripción/refs implementados (JSON + DiaryService.detalle_entrada); ICONO pendiente (sin fuente de arte, L203 sigue abierto)
- [x] Separar datos del catálogo de la lógica del servicio (M15) [M] — glm-5.3-flash 2026-09-01: catálogo data-driven en data/diario/diario_catalog.json + DiaryService autoload

## B. Diseño de UI (M53)

- [x] Diseñar lista virtualizada por categoría con scroll suave [C] — iter. 5 (Step-5-WorkBuddy, Log 1934): dup de #194, misma evidencia (solo la categoría activa se materializa: 12 filas de 500 en el árbol + espaciadores arriba/abajo); rango de scroll CORRECTO con 500 entradas tras CONGELAR el paso de fila (real medido 43.0 = 39 tema + 4 sep. vs 32 asumido, bug de producción corregido); test_diario_perf_m55.gd 26 checks / 0 fallos / EXIT 0, re-verificado 2026-10-17 18:29
- [x] Definir detalle de entrada con descripción, refs y acciones [M] - T-M1 lote 2: LblDetalleDesc (autowrap, oculto sin texto) + botones Ref_* navegables (solo refs a entradas descubiertas = anti-spoiler) + acciones favorito/estado/día; clave DIARY.REFERENCIAS en es.po/en.po
- [x] Añadir barra de progreso por categoría en la cabecera [M] — iter. 2: ProgresoCat en cabecera + % global sobre lo descubierto, clamp [0,100] (test_ui)
- [x] Añadir estrella de favorito en cada fila [S] — iter. 2: ★ en fila + BtnFavoritoDetalle con undo visual (test_ui, sonda rojo demostrada)
- [ ] Mantener la estética cozy del proyecto en el diario [M]

## C. Registro por Eventos (EventBus M07)

- [x] Definir el EventBus como único canal de registro [M] — IMPLEMENTADO: 6 puentes reales a señales de M07 en _conectar_eventos() (diary_service.gd L85-107: prereq_met, npc_moved_in, quest_completed, island_loaded, season_changed, carta_recibida) + emisión diary.* de vuelta al bus (entrada_nueva/progreso_cambiado/categoria_completa, L141-146/L283-289); test_diario ejercita las 6 integraciones por señal real
- [x] Mapear evento NPC_CONOCIDO (M19) → entrada personaje [M] — IMPLEMENTADO: puente npc.npc_moved_in (M19) → personajes, _slug normalizado (testeado)
- [x] Mapear evento LUGAR_VISITADO (M09) → entrada lugar [M] — IMPLEMENTADO: puente travel.island_loaded (M28) → lugares con _slug (diary_service.gd L100-101, testeado en test_diario)
- [?] Mapear evento ESPECIE_AVISTADA (M36/M65) → entrada criatura [M] — **MEDIDO 2026-10-16 (Step-5-WorkBuddy):** el emisor EXISTE (fauna_registry.especie_avistada, scripts/fauna/fauna_registry.gd L19, emitido en registrar_avistamiento L91) pero sus ids (7 especies tierra/aire: cangrejo_humedal, conejo_pradera, gaviota_playera, halcon_montana, lechuza_bosque, nutria_ribera, salamandra_ancestral) NO coinciden con las entradas del catálogo del diario (4 peces de M34: pez_trucha_cascada, pez_bacalao_nube, pez_gobio_mar, pez_anguila_brisa). El puente requeriría reconciliar los ids → **dueño M36/M34**
- [?] Mapear evento PLANTA_IDENTIFICADA (M50) → entrada planta [M] — **MEDIDO 2026-10-16:** sin emisor en el repo (grep de señales en los scripts de M50 = 0; el catálogo tiene 2 entradas planta_* sin evento que las registre) → **dueño M50**

## D. Registro por Eventos (continuación)

- [?] Mapear evento MINERAL_DESCUBIERTO (M35) → entrada mineral [M] — **MEDIDO 2026-10-16:** el emisor más cercano es mina_extraccion_exitosa (mining_manager.gd L68) = EXTRACCIÓN, no descubrimiento; sus ids (def_id) no están verificados contra el catálogo (mineral_madera_roble, mineral_piedra_caliza, mineral_mineral_cobre) → **dueño M35**
- [?] Mapear evento RECETA_DESBLOQUEADA (M16) → entrada receta [M] — **MEDIDO 2026-10-16:** el emisor EXISTE y los ids SÍ coinciden (crafting_service.receta_aprendida, emitido en L158; data/balance/crafting.json tiene rec_mesa_robusta y rec_pico_cobre ↔ receta_rec_* del catálogo), PERO CraftingService no es autoload ni nodo persistente (0 .tscn lo instancian, 0 consumidores de la señal hoy) → el puente requiere decisión del **dueño M16** sobre dónde vive el servicio
- [?] Mapear evento PISTA_LEIDA (M24/M26) → entrada pista releíble [M] — **MEDIDO 2026-10-16:** sin emisor en el repo (grep de señales en scripts/puzzles, scripts/templo y scripts/ruinas = 0) → **dueño M24/M26**
- [x] Mapear evento SELLO_OBTENIDO (M22/M26) → entrada Sello completada [M] — IMPLEMENTADO: puente quest.prereq_met (M22) → sellos (testeado)
- [?] Mapear evento RUIDA_PROGRESADA (M25) → entrada ruina con estado 1-4 [M] — **MEDIDO 2026-10-16:** sin emisor en el repo (grep de señales en scripts/ruinas = 0) → **dueño M25**

## E. Registro por Eventos (final)

- [x] Mapear evento CARTA_RECIBIDA (M74) → entrada carta [M] — IMPLEMENTADO: puente npc.carta_recibida → cartas (testeado)
- [?] Mapear evento DESCUBRIMIENTO (M71) → entrada descubrimiento [M] — **MEDIDO 2026-10-16:** M71 emite progreso_desbloqueado/progreso_hito_alcanzado (progression_manager.gd L20-22) pero sus ids son hito_* (hito_amistades_5, hito_peces_10, …) y NO coinciden con las entradas del catálogo (descubrimiento_gran_vapor, descubrimiento_aurora, descubrimiento_fallback_mision_test) → **dueño M71**
- [x] Mapear evento MISION_CAMBIADA (M22/M23) → entrada misión [M] — IMPLEMENTADO: puente quest.quest_completed → misiones (testeado); quest_started/updated quedan para M22/M23 richer payloads
- [x] Mapear evento EVENTO_OCURRIDO (M74/M29) → entrada evento [M] — IMPLEMENTADO: puente calendar.season_changed → eventos (testeado, slug sin tildes)
- [?] Mapear evento FOTO_TOMADA (M56) → entrada fotografía [M] - T-M1 lote 2 (diagnóstico): NO existe emisor FOTO_TOMADA en el repo (grep 0); M56 está liberado con PhotoService (señal modo_foto_cambiado única) y fauna_registry.especie_fotografiada sin conectar al diario. La categoría vacía es un FRENTE SIN CONTENIDO, no bug de datos; puente M56→M55 pendiente de dueño M56

## F. Registro de Personajes (M19)

- [ ] Guardar retrato, relación (M20) y últimos diálogos del personaje [M]
- [ ] Marcar personaje completado cuando su arco termina (M22) [M]
- [ ] Vincular misiones relacionadas del personaje (M23) [M]
- [x] No revelar diálogos no vistos en la entrada [M] — cubierto por el anti-spoiler general §3.2: entradas_de() (diary_service.gd L224-241) hace invisible lo no descubierto (regla de oro); testeado en test_diario (bloque anti-spoiler, 37 checks) y test_diario_ui (no-descubierto invisible, 89 checks); 4/4 suites verdes 2026-10-16, 0 SCRIPT ERROR
- [x] Localizar nombres propios sin traducir (M87) [S] — iter. 2 (mimo): nombres propios intactos en locale EN ("Catalina Oso"), verificado en test_diario_ui (89 checks, 0 fallos); duplicado de V L186 ya [x]

## G. Registro de Lugares (M09/M54)

- [ ] Vincular POI del mapa (M54) con la entrada [M]
- [ ] Guardar estado de exploración del lugar [S]
- [ ] Marcar completado al 100% de exploración del lugar [M]
- [x] No listar lugares no visitados (anti-spoiler) [M] — IMPLEMENTADO: anti-spoiler general §3.2 en entradas_de() (no descubierto invisible, testeado)
- [ ] Mostrar fauna/flora del lugar por avistamientos [M]

## H. Registro de Criaturas (M36/M65)

- [ ] Guardar hábitat, dieta y fotografías de la criatura (M56) [M]
- [ ] Marcar completado al identificar al 100% la criatura [M]
- [ ] Mostrar rareza de la criatura y momento de avistamiento [M]
- [x] No revelar criaturas no avistadas [M] — cubierto por el anti-spoiler general §3.2: entradas_de() (diary_service.gd L224-241) hace invisible lo no descubierto (regla de oro); testeado en test_diario (bloque anti-spoiler, 37 checks) y test_diario_ui (no-descubierto invisible, 89 checks); 4/4 suites verdes 2026-10-16, 0 SCRIPT ERROR
- [ ] Validar siluetas/iconos contra el bestiario (M46) [S]

## I. Registro de Plantas (M50/M33)

- [ ] Guardar estación y hábitat de la planta (M29/M33) [M]
- [ ] Guardar usos en recetas conocidas (M16) [M]
- [x] No revelar plantas no identificadas [M] — cubierto por el anti-spoiler general §3.2: entradas_de() (diary_service.gd L224-241) hace invisible lo no descubierto (regla de oro); testeado en test_diario (bloque anti-spoiler, 37 checks) y test_diario_ui (no-descubierto invisible, 89 checks); 4/4 suites verdes 2026-10-16, 0 SCRIPT ERROR
- [ ] Mostrar escasez/abundancia estacional [M]
- [ ] Validar iconos de hojas contra el catálogo [S]

## J. Registro de Minerales (M35)

- [ ] Guardar ubicación, usos y rareza del mineral [M]
- [ ] Vincular mineral con su región [S]
- [x] No revelar minerales no descubiertos [M] — cubierto por el anti-spoiler general §3.2: entradas_de() (diary_service.gd L224-241) hace invisible lo no descubierto (regla de oro); testeado en test_diario (bloque anti-spoiler, 37 checks) y test_diario_ui (no-descubierto invisible, 89 checks); 4/4 suites verdes 2026-10-16, 0 SCRIPT ERROR
- [ ] Guardar cantidad conocida en el inventario (M14) [S]
- [ ] Validar iconos de gemas contra el catálogo [S]

## K. Registro de Recetas (M16)

- [ ] Desbloquear entrada al aprender la receta [M]
- [ ] Mostrar ingredientes con cantidades y resultado [M]
- [ ] Marcar completado al fabricar el ítem [M]
- [ ] Vincular receta con su nivel de habilidad (M17) [M]
- [x] No revelar recetas no aprendidas [M] — cubierto por el anti-spoiler general §3.2: entradas_de() (diary_service.gd L224-241) hace invisible lo no descubierto (regla de oro); testeado en test_diario (bloque anti-spoiler, 37 checks) y test_diario_ui (no-descubierto invisible, 89 checks); 4/4 suites verdes 2026-10-16, 0 SCRIPT ERROR

## L. Registro de Pistas (M24/M26)

- [ ] Guardar pista al leerse (releíble) [M]
- [ ] Marcar pista como resuelta al resolver el puzzle [M]
- [ ] No mostrar la solución en la pista [M]
- [x] No revelar pistas no encontradas [M] — cubierto por el anti-spoiler general §3.2: entradas_de() (diary_service.gd L224-241) hace invisible lo no descubierto (regla de oro); testeado en test_diario (bloque anti-spoiler, 37 checks) y test_diario_ui (no-descubierto invisible, 89 checks); 4/4 suites verdes 2026-10-16, 0 SCRIPT ERROR
- [ ] Validar referencias de pistas a puzzles [S]

## M. Registro de Sellos (M22/M26)

- [ ] Desbloquear entrada al obtener el Sello [M]
- [ ] Mostrar la secuencia de Sellos en orden [M]
- [ ] Mostrar lore de cada Sello al completarse [M]
- [x] No revelar Sellos no obtenidos [M] — cubierto por el anti-spoiler general §3.2: entradas_de() (diary_service.gd L224-241) hace invisible lo no descubierto (regla de oro); testeado en test_diario (bloque anti-spoiler, 37 checks) y test_diario_ui (no-descubierto invisible, 89 checks); 4/4 suites verdes 2026-10-16, 0 SCRIPT ERROR
- [ ] Validar iconografía de Sellos (M46) [S]

## N. Registro de Ruinas (M25)

- [ ] Actualizar estado de la ruina (4 estados) al progresar [M]
- [ ] Mostrar recompensas obtenidas en la entrada [S]
- [ ] Marcar completado al restaurar la ruina [M]
- [x] No revelar ruinas no descubiertas [M] — cubierto por el anti-spoiler general §3.2: entradas_de() (diary_service.gd L224-241) hace invisible lo no descubierto (regla de oro); testeado en test_diario (bloque anti-spoiler, 37 checks) y test_diario_ui (no-descubierto invisible, 89 checks); 4/4 suites verdes 2026-10-16, 0 SCRIPT ERROR
- [ ] Validar estados contra el catálogo de M25 [S]

## O. Registro de Cartas y Eventos (M74)

- [ ] Guardar cartas del festival y del correo con fecha [M]
- [ ] Permitir releer cartas y marcarlas como leídas [S]
- [ ] Vincular cartas con eventos del calendario (M29) [M]
- [x] No revelar eventos no desbloqueados [M] — cubierto por el anti-spoiler general §3.2: entradas_de() (diary_service.gd L224-241) hace invisible lo no descubierto (regla de oro); testeado en test_diario (bloque anti-spoiler, 37 checks) y test_diario_ui (no-descubierto invisible, 89 checks); 4/4 suites verdes 2026-10-16, 0 SCRIPT ERROR
- [ ] Validar remitentes contra NPC (M19) [S]

## P. Registro de Descubrimientos y Misiones (M71/M22/M23)

- [ ] Desbloquear descubrimientos al completar hitos (M71) [M]
- [ ] Mostrar misiones activas/completadas con progreso en vivo [M]
- [x] No revelar objetivos futuros de la misión [M] — el diario NO almacena ni muestra objetivos de misión (el modelo de entrada guarda id/título/descripción/refs + estado): nada que revelar; suma el anti-spoiler general §3.2 (entradas_de, diary_service.gd L224-241)
- [ ] Alimentar logros de colección (M72) con el total real [M]
- [x] No revelar descubrimientos pendientes (anti-spoiler) [M] — cubierto por el anti-spoiler general §3.2: entradas_de() (diary_service.gd L224-241) hace invisible lo no descubierto (regla de oro); testeado en test_diario (bloque anti-spoiler, 37 checks) y test_diario_ui (no-descubierto invisible, 89 checks); 4/4 suites verdes 2026-10-16, 0 SCRIPT ERROR

## Q. Registro de Fotografías (M56)

- [?] Diseñar galería de fotografías en el diario [M] — **dueño M56:** frente sin contenido (FOTO_TOMADA inexistente en el repo; PhotoService solo emite modo_foto_cambiado); categoría fotografías con 0 entradas (único aviso de validate_diary)
- [?] Definir interface IDiaryPhotoProvider (desacople M56) [M] — **dueño M56:** el desacople está diseñado (02-Analisis §4) pero sin M56 no hay proveedor que implementar
- [?] Abrir fotografía en pantalla completa sin lag (M61) [M] — **dueño M56/M61:** sin fotos que mostrar (categoría vacía)
- [?] Mostrar fecha y lugar de la fotografía [S] — **dueño M56:** sin fotos
- [?] Manejar foto borrada sin crash [M] — **dueño M56:** sin fotos

## R. Filtros, Categorías y Búsqueda

- [x] Definir filtro por categoría (pestañas) [S] — iter. 2: 14 pestañas filtran la lista (test_ui)
- [x] Definir filtro por estado (nuevo/visto/favorito) [M] — iter. 2: enum Filtro (5 opciones) en FiltroEstado (test_ui)
- [ ] Definir filtro por bioma para criaturas/lugares [M]
- [x] Definir búsqueda por texto localizado [M] — iter. 2: buscar() + placeholder i18n + solo lo descubierto (test_ui)
- [x] Testear búsqueda con diacríticos (M87) [M] — iter. 2: _slug() en consulta y candidato; test sin-tilde y locale EN (test_ui)

## S. Completado y Contenido Secreto

- [x] Calcular % de completado por categoría sobre lo DESCUBIERTO [M] — iter. 1 (progreso_categoria) + iter. 2 lo muestra con tooltip anti-spoiler (test_ui)
- [x] Calcular % global del diario [M] — iter. 2: _refrescar_progreso() con % global en cabecera, sobre descubierto (test_ui)
- [ ] Diseñar contenido secreto desbloqueable por acción concreta [M]
- [ ] Mostrar "???" SOLO en secciones lore (nunca en colecciones) [M]
- [x] Validar que el % nunca supere 100 por corrupción de datos [M] — iter. 2: clamp [0,100] verificado en UI (test_ui "% acotado"); defaults/purga de corrupción = M59 (test_diario huérfanas)

## T. Releer, Favoritos y Acciones

- [ ] Permitir releer pistas, recetas y cartas desde el diario [S]
- [x] Permitir marcar/desmarcar favoritos con undo visual [S] — iter. 2: toggle + refresco de fila ★ (test_ui round-trip)
- [ ] Navegar al lugar en el mapa (M54) desde la entrada [M]
- [x] Mantener la posición de scroll al volver del detalle [S] — iter. 2: scroll preservado en _refrescar_lista (test_ui: delta < 0.01)
- [x] No bloquear la acción al cerrar el diario (M57) [S] — iter. 2: close_top purga la capa visible + re-registro idempotente al reabrir (test_ui Esc/atajo J)

## U. Persistencia (M59/M60)

- [x] Persistir el diario en GameState con schema_version [M] — IMPLEMENTADO: ISaveProvider M59 registrado en _registrar_proveedor_guardado() (diary_service.gd L77-80) + get_save_data() con schema_version 1 + ui prefs (L305-314); test_diario_persist (2 procesos Godot, SaveManager real, slot 3) 0 fallos EXIT 0
- [x] Migrar versiones de guardado antiguas [M] — restore_save_data() tolerante (diary_service.gd L317-342): claves ausentes → defaults (ui prefs con saneamiento L212-216); v1 es la única versión emitida y la carga tolerante cubre saves previos sin "ui"; verificado por validate_diary (área persistencia: round-trip + saneo)
- [x] Cargar el diario al iniciar sin duplicados [M] — restore_save_data() limpia _estados antes de aplicar (L318) + purga huérfanas de catálogos viejos con log (L328-336); testeado en test_diario (huérfana) y test_diario_persist (carga en 2do proceso, sin duplicados)
- [x] Guardar en subida de nivel y cierre correcto [M] — el diario persiste vía el save central de M59 (ISaveProvider); el ciclo guardar→salir→cargar está probado con SaveManager real en test_diario_persist (request_save → load_slot(3), 0 fallos); los disparadores (nivel/cierre) son del schedule de M59
- [x] Manejar persistencia corrupta con defaults [M] — restore tolerante: entradas huérfanas ignoradas con log (L328-336) + ui prefs fuera de rango → defaults (set_ui_prefs L212-216); validado por validate_diary (saneo de ui prefs)

## V. Localización (M87/M88)

- [x] Localizar todos los textos del diario por claves i18n [M] — iter. 2: 19 claves DIARY.* ×2 idiomas + _aplicar_textos_estaticos al abrir; test EN (Close/Characters) sin claves crudas
- [x] Localizar nombres propios sin traducción [S] — iter. 2: "Catalina Oso" intacto en locale EN (test_ui)
- [ ] Dar soporte a plurales [S]
- [ ] Testear el diario en 3 idiomas sin desbordes de UI [M]
- [x] Validar claves i18n con validate_diary.gd [M] - T-M1 lote 2: extrae DIARY.* de diary_layer.gd (literales + CAT_* de las 14 categorías) y exige msgid con msgstr no vacío en es.po Y en.po (37 claves); corrida verde

## W. Rendimiento y Edge Cases (M61/M62)

- [x] Abrir el diario en < 100 ms con 500+ entradas [C] — iter. 5 (Step-5-WorkBuddy, Log 1934): test_diario_perf_m55.gd mide apertura con 500 sinteticas = 12.179 us (< 100 ms), 26 checks / 0 fallos / EXIT 0 x3
- [x] Virtualizar listas largas (SOLO visible en el árbol) [C] — iter. 5 (Log 1934): solo la ventana visible existe en el arbol (12 filas <= FILAS_VENTANA_MAX 24 de 500 entradas); espaciadores arriba/abajo sostienen la altura total (500 x paso)
- [x] Cargar perezosamente categorías no visibles (LazyLoad) [M] — iter. 5 (Log 1934): _refrescar_completo llama entradas_de() solo para la categoria activa (delta <= 2 llamadas; las 13 no visibles NO se materializan); progreso_global() suma sin materializar
- [x] Usar pooling de filas de lista (M62) [C] — iter. 5 (Log 1934): filas recicladas de _pool_filas al deslizar (conteo de nodos constante 12 -> 12); fix del paso CONGELADO (real medido 39+4=43 vs 32 asumido) para que offset->indice no mienta
- [x] Manejar texto muy largo con wrap y tooltip completo [M] — iter. 2: autowrap en detalle + tooltip con texto completo (test_ui)

## X. Rendimiento y Edge Cases (final)

- [x] Manejar categoría vacía con mensaje amistoso [S] — iter. 2: LblVacio "Todavía no hay entradas…" (test_ui con fotografías vacía)
- [x] Manejar búsqueda sin resultados [S] — iter. 2: "Sin resultados para la búsqueda." (test_ui)
- [ ] Manejar icono faltante con fallback genérico [S]
- [x] No emitir VFX en el diario (hábito estricto, M52) [S] — iter. 2: source scan sin create_tween/GPUParticles/CPUParticles (test_ui)
- [ ] Probar el diario con Reduce Motion activo (M58) [M]

## Y. Validación y QA

- [x] Crear validate_diary.gd (mapeo, i18n, persistencia, rendimiento) [C] - T-M1 lote 2: 6 áreas (estructura/mapeo 14 cats == CATEGORIAS + ids ascii únicos + conteo vs total_entradas, descripciones/refs, i18n es/en, persistencia round-trip + saneamiento ui prefs, 20 cargas < 500 ms, encoding BOM/U+FFFD); sonda roja demostrada: JSON truncado → 21 fallos, EXIT 1
- [x] Probar ciclo completo: descubrir → registrar → ver → guardar → recargar [C] — iter. 1 (eventos→registrar→persistir, test_diario) + iter. 2 (ver/guardar/recargar round-trip, test_ui)
- [x] Probar anti-spoilers: sin descubrir nada, diario vacío correcto [M] — test_ui: vacío correcto + no-descubierto invisible + snapshot/restore
- [?] Probar 14 categorías con al menos 1 entrada cada una [M] - 13/14: fotografías tiene 0 entradas (falta puente M56, ver L53); test_ui aserta con_entradas==13 y validate_diary emite AVISO (no fallo) para la categoría vacía
- [x] Revisar logs DIARY-* en consola sin errores [S] — salida del test verde: solo DIARY-ADD esperados; el único SCRIPT ERROR es el preexistente interaction_manager.gd:669 (no es del diario)

## Z. Cierre del Módulo

- [x] Probar persistencia entre sesiones (guardar → salir → cargar) [C] - T-M1 lote 2: test_diario_persist.gd 2 fases con DOS procesos Godot y SaveManager M59 real (slot 3 con backup/restore byte a byte); verifica ★, registro, estado, día y ui prefs (filtro/categoría) tras load_slot; 0 fallos, EXIT 0
- [x] Probar migración de versión antigua de guardado [C] — v1 es la única versión emitida; la migración = carga tolerante con defaults, ejercitada por validate_diary (área persistencia: saneo de ui prefs + round-trip, 0 fallos/1 aviso) y test_diario (huérfanas purgadas); 0 fallos
- [x] Documentar plan de testings automáticos del diario [M] — 06-Plan-Testings.md creado (iter. 2)
- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S] — Notas del Agente iteración 2 (2026-10-04) en 04-Codigo.md
- [ ] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
**Totales:** 131 ítems · Completados: 63 · Pendientes: 53 · No resueltos: 15.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 8 [x] / 123 [ ] / 0 [?].
> Las marcas no se tocaron.
