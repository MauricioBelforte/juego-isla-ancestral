**Modelo:** mimo-v2.6-flash-free (último modificador; base por Deepseek V4 Flash, iter. 1 por glm-5.3-flash)
**Plataforma:** Kilo Code

# 05-Checklist.md — Módulo 55: Diario del Jugador (131 ítems)

> **Reserva actual (🔵 iter. 1 — 2026-10-04 17:55)**
> **Agente:** mimo-v2.6-flash-free · **Plataforma:** opencode · **Fecha:** 2026-10-04 17:55 · **Estado:** 🟡 Liberado 2026-10-04 (iter. 2 UI cerrada — lote 1 del frente T-M1; entregado con pendientes honestos en W/B/V/Y/Z, ver Notas del Agente en 04-Codigo.md; reclamo 🔵 original: frente T-M1 del canal 12 tras cerrar M53)
> **Entrada:** M53 ✅ (UI framework: capas + settings_audio_layer cerrados hoy) + M07 EventBus + señales M19/M22/M28/M29 + DiaryService iter. 1 (glm, Log 374)
> **Salida prevista:** UI del diario (capa nueva sobre el framework M53) + registro por eventos + persistencia M59; tests y docs plan-actual al cierre
> **Archivos afectados:** `scripts/ui/layers/` (capa nueva), `scripts/diario/`, `locales/*.po`, `DOCUMENTACION/55-Diario-Del-Jugador/plan-actual/`
> **Reserva anterior (histórica):** glm-5.3-flash · iter. 1 núcleo V0/V1 (Log 374, liberado 2026-09-01)

**Estado:** 37/131 completados (8 previos + 29 de iter. 2), 3 [?], 91 pendientes — iter. 2 UI (mimo, Log 1295): capa DiaryLayer + i18n 36 claves + test_diario_ui 89/0 con sonda rojo; +4 [x] del lote 2 (L26/L189/L209/L217) verificados por hy3 en QA §21.8 (Log 1503). Ver 06/07-Testings. [S]=Simple [M]=Medio [C]=Complejo.

## A. Diseño General del Diario

- [x] Diseñar la pantalla principal del diario con pestañas por categoría [M] — iter. 2 (mimo): diary_layer.gd, 14 pestañas en CategoriasBox (test_ui estructura OK)
- [x] Definir navegación de 2 clics hacia cualquier entrada [M] — iter. 2: pestaña→fila→detalle en 3 columnas (test_ui verifica selección + detalle)
- [ ] Definir estados de entrada: no_visto, visto, completado [S]
- [?] Definir el modelo de entrada (id, categoría, título, descripción, icono) [M] - T-M1 lote 2 (mimo): id/título/descripción/refs implementados (JSON + DiaryService.detalle_entrada); ICONO pendiente (sin fuente de arte, L203 sigue abierto)
- [x] Separar datos del catálogo de la lógica del servicio (M15) [M] — glm-5.3-flash 2026-09-01: catálogo data-driven en data/diario/diario_catalog.json + DiaryService autoload

## B. Diseño de UI (M53)

- [ ] Diseñar lista virtualizada por categoría con scroll suave [C]
- [x] Definir detalle de entrada con descripción, refs y acciones [M] - T-M1 lote 2: LblDetalleDesc (autowrap, oculto sin texto) + botones Ref_* navegables (solo refs a entradas descubiertas = anti-spoiler) + acciones favorito/estado/día; clave DIARY.REFERENCIAS en es.po/en.po
- [x] Añadir barra de progreso por categoría en la cabecera [M] — iter. 2: ProgresoCat en cabecera + % global sobre lo descubierto, clamp [0,100] (test_ui)
- [x] Añadir estrella de favorito en cada fila [S] — iter. 2: ★ en fila + BtnFavoritoDetalle con undo visual (test_ui, sonda rojo demostrada)
- [ ] Mantener la estética cozy del proyecto en el diario [M]

## C. Registro por Eventos (EventBus M07)

- [ ] Definir el EventBus como único canal de registro [M]
- [x] Mapear evento NPC_CONOCIDO (M19) → entrada personaje [M] — IMPLEMENTADO: puente npc.npc_moved_in (M19) → personajes, _slug normalizado (testeado)
- [ ] Mapear evento LUGAR_VISITADO (M09) → entrada lugar [M]
- [ ] Mapear evento ESPECIE_AVISTADA (M36/M65) → entrada criatura [M]
- [ ] Mapear evento PLANTA_IDENTIFICADA (M50) → entrada planta [M]

## D. Registro por Eventos (continuación)

- [ ] Mapear evento MINERAL_DESCUBIERTO (M35) → entrada mineral [M]
- [ ] Mapear evento RECETA_DESBLOQUEADA (M16) → entrada receta [M]
- [ ] Mapear evento PISTA_LEIDA (M24/M26) → entrada pista releíble [M]
- [x] Mapear evento SELLO_OBTENIDO (M22/M26) → entrada Sello completada [M] — IMPLEMENTADO: puente quest.prereq_met (M22) → sellos (testeado)
- [ ] Mapear evento RUIDA_PROGRESADA (M25) → entrada ruina con estado 1-4 [M]

## E. Registro por Eventos (final)

- [x] Mapear evento CARTA_RECIBIDA (M74) → entrada carta [M] — IMPLEMENTADO: puente npc.carta_recibida → cartas (testeado)
- [ ] Mapear evento DESCUBRIMIENTO (M71) → entrada descubrimiento [M]
- [x] Mapear evento MISION_CAMBIADA (M22/M23) → entrada misión [M] — IMPLEMENTADO: puente quest.quest_completed → misiones (testeado); quest_started/updated quedan para M22/M23 richer payloads
- [x] Mapear evento EVENTO_OCURRIDO (M74/M29) → entrada evento [M] — IMPLEMENTADO: puente calendar.season_changed → eventos (testeado, slug sin tildes)
- [?] Mapear evento FOTO_TOMADA (M56) → entrada fotografía [M] - T-M1 lote 2 (diagnóstico): NO existe emisor FOTO_TOMADA en el repo (grep 0); M56 está liberado con PhotoService (señal modo_foto_cambiado única) y fauna_registry.especie_fotografiada sin conectar al diario. La categoría vacía es un FRENTE SIN CONTENIDO, no bug de datos; puente M56→M55 pendiente de dueño M56

## F. Registro de Personajes (M19)

- [ ] Guardar retrato, relación (M20) y últimos diálogos del personaje [M]
- [ ] Marcar personaje completado cuando su arco termina (M22) [M]
- [ ] Vincular misiones relacionadas del personaje (M23) [M]
- [ ] No revelar diálogos no vistos en la entrada [M]
- [ ] Localizar nombres propios sin traducir (M87) [S]

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
- [ ] No revelar criaturas no avistadas [M]
- [ ] Validar siluetas/iconos contra el bestiario (M46) [S]

## I. Registro de Plantas (M50/M33)

- [ ] Guardar estación y hábitat de la planta (M29/M33) [M]
- [ ] Guardar usos en recetas conocidas (M16) [M]
- [ ] No revelar plantas no identificadas [M]
- [ ] Mostrar escasez/abundancia estacional [M]
- [ ] Validar iconos de hojas contra el catálogo [S]

## J. Registro de Minerales (M35)

- [ ] Guardar ubicación, usos y rareza del mineral [M]
- [ ] Vincular mineral con su región [S]
- [ ] No revelar minerales no descubiertos [M]
- [ ] Guardar cantidad conocida en el inventario (M14) [S]
- [ ] Validar iconos de gemas contra el catálogo [S]

## K. Registro de Recetas (M16)

- [ ] Desbloquear entrada al aprender la receta [M]
- [ ] Mostrar ingredientes con cantidades y resultado [M]
- [ ] Marcar completado al fabricar el ítem [M]
- [ ] Vincular receta con su nivel de habilidad (M17) [M]
- [ ] No revelar recetas no aprendidas [M]

## L. Registro de Pistas (M24/M26)

- [ ] Guardar pista al leerse (releíble) [M]
- [ ] Marcar pista como resuelta al resolver el puzzle [M]
- [ ] No mostrar la solución en la pista [M]
- [ ] No revelar pistas no encontradas [M]
- [ ] Validar referencias de pistas a puzzles [S]

## M. Registro de Sellos (M22/M26)

- [ ] Desbloquear entrada al obtener el Sello [M]
- [ ] Mostrar la secuencia de Sellos en orden [M]
- [ ] Mostrar lore de cada Sello al completarse [M]
- [ ] No revelar Sellos no obtenidos [M]
- [ ] Validar iconografía de Sellos (M46) [S]

## N. Registro de Ruinas (M25)

- [ ] Actualizar estado de la ruina (4 estados) al progresar [M]
- [ ] Mostrar recompensas obtenidas en la entrada [S]
- [ ] Marcar completado al restaurar la ruina [M]
- [ ] No revelar ruinas no descubiertas [M]
- [ ] Validar estados contra el catálogo de M25 [S]

## O. Registro de Cartas y Eventos (M74)

- [ ] Guardar cartas del festival y del correo con fecha [M]
- [ ] Permitir releer cartas y marcarlas como leídas [S]
- [ ] Vincular cartas con eventos del calendario (M29) [M]
- [ ] No revelar eventos no desbloqueados [M]
- [ ] Validar remitentes contra NPC (M19) [S]

## P. Registro de Descubrimientos y Misiones (M71/M22/M23)

- [ ] Desbloquear descubrimientos al completar hitos (M71) [M]
- [ ] Mostrar misiones activas/completadas con progreso en vivo [M]
- [ ] No revelar objetivos futuros de la misión [M]
- [ ] Alimentar logros de colección (M72) con el total real [M]
- [ ] No revelar descubrimientos pendientes (anti-spoiler) [M]

## Q. Registro de Fotografías (M56)

- [ ] Diseñar galería de fotografías en el diario [M]
- [ ] Definir interface IDiaryPhotoProvider (desacople M56) [M]
- [ ] Abrir fotografía en pantalla completa sin lag (M61) [M]
- [ ] Mostrar fecha y lugar de la fotografía [S]
- [ ] Manejar foto borrada sin crash [M]

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

- [ ] Persistir el diario en GameState con schema_version [M]
- [ ] Migrar versiones de guardado antiguas [M]
- [ ] Cargar el diario al iniciar sin duplicados [M]
- [ ] Guardar en subida de nivel y cierre correcto [M]
- [ ] Manejar persistencia corrupta con defaults [M]

## V. Localización (M87/M88)

- [x] Localizar todos los textos del diario por claves i18n [M] — iter. 2: 19 claves DIARY.* ×2 idiomas + _aplicar_textos_estaticos al abrir; test EN (Close/Characters) sin claves crudas
- [x] Localizar nombres propios sin traducción [S] — iter. 2: "Catalina Oso" intacto en locale EN (test_ui)
- [ ] Dar soporte a plurales [S]
- [ ] Testear el diario en 3 idiomas sin desbordes de UI [M]
- [x] Validar claves i18n con validate_diary.gd [M] - T-M1 lote 2: extrae DIARY.* de diary_layer.gd (literales + CAT_* de las 14 categorías) y exige msgid con msgstr no vacío en es.po Y en.po (37 claves); corrida verde

## W. Rendimiento y Edge Cases (M61/M62)

- [ ] Abrir el diario en < 100 ms con 500+ entradas [C]
- [ ] Virtualizar listas largas (SOLO visible en el árbol) [C]
- [ ] Cargar perezosamente categorías no visibles (LazyLoad) [M]
- [ ] Usar pooling de filas de lista (M62) [C]
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
- [ ] Probar migración de versión antigua de guardado [C]
- [x] Documentar plan de testings automáticos del diario [M] — 06-Plan-Testings.md creado (iter. 2)
- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S] — Notas del Agente iteración 2 (2026-10-04) en 04-Codigo.md
- [ ] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]

## Dependencia: Visión del Agente (M154)

- [x] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
**Totales:** 131 ítems · Completados: 37 · Pendientes: 91 · No resueltos: 3.

> **Agregado por auditoría de drift (atria-dawn-preview / Kilo Code, 2026-09-20, bloque 1C):**
> este archivo no tenía línea de Totales. Conteo real de marcas: 8 [x] / 123 [ ] / 0 [?].
> Las marcas no se tocaron.
