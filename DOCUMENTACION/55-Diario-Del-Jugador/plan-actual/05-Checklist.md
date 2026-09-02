**Modelo:** glm-5.3-flash (último modificador; documentación base por Deepseek V4 Flash)
**Plataforma:** Kilo Code

# 05-Checklist.md — Módulo 55: Diario del Jugador (131 ítems)

> **Reserva actual (LIBERADA 🟡)**
> **Agente:** glm-5.3-flash · **Plataforma:** Kilo Code · **Fecha:** 2026-09-01 12:25 · **Estado:** 🟡 Liberado (iter. 1 núcleo V0/V1, Log 374 — renumerado desde 327, ver Log 375)
> **Entrada:** M07 ✅ + M22 ✅ + M19 ✅ + M28 ✅ + M29 ✅ (emiten las señales consumidas) · **Salida:** DiaryService autoload + catálogo 14 categorías JSON + registro por eventos reales + anti-spoiler + persistencia M59
> **Archivos afectados:** `scripts/diario/diary_service.gd`, `data/diario/diario_catalog.json`, `scripts/diario/test_diario.gd`, `scripts/core/event_bus.gd` (dominio diary), `project.godot`

**Estado:** 7/131 completados (iter. 1 núcleo: catálogo, 6 mapeos de eventos reales, anti-spoiler, favoritos/búsqueda, persistencia). [S]=Simple [M]=Medio [C]=Complejo.

## A. Diseño General del Diario

- [ ] Diseñar la pantalla principal del diario con pestañas por categoría [M]
- [ ] Definir navegación de 2 clics hacia cualquier entrada [M]
- [ ] Definir estados de entrada: no_visto, visto, completado [S]
- [ ] Definir el modelo de entrada (id, categoría, título, descripción, icono) [M]
- [x] Separar datos del catálogo de la lógica del servicio (M15) [M] — glm-5.3-flash 2026-09-01: catálogo data-driven en data/diario/diario_catalog.json + DiaryService autoload

## B. Diseño de UI (M53)

- [ ] Diseñar lista virtualizada por categoría con scroll suave [C]
- [ ] Definir detalle de entrada con descripción, refs y acciones [M]
- [ ] Añadir barra de progreso por categoría en la cabecera [M]
- [ ] Añadir estrella de favorito en cada fila [S]
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
- [ ] Mapear evento FOTO_TOMADA (M56) → entrada fotografía [M]

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

- [ ] Definir filtro por categoría (pestañas) [S]
- [ ] Definir filtro por estado (nuevo/visto/favorito) [M]
- [ ] Definir filtro por bioma para criaturas/lugares [M]
- [ ] Definir búsqueda por texto localizado [M]
- [ ] Testear búsqueda con diacríticos (M87) [M]

## S. Completado y Contenido Secreto

- [ ] Calcular % de completado por categoría sobre lo DESCUBIERTO [M]
- [ ] Calcular % global del diario [M]
- [ ] Diseñar contenido secreto desbloqueable por acción concreta [M]
- [ ] Mostrar "???" SOLO en secciones lore (nunca en colecciones) [M]
- [ ] Validar que el % nunca supere 100 por corrupción de datos [M]

## T. Releer, Favoritos y Acciones

- [ ] Permitir releer pistas, recetas y cartas desde el diario [S]
- [ ] Permitir marcar/desmarcar favoritos con undo visual [S]
- [ ] Navegar al lugar en el mapa (M54) desde la entrada [M]
- [ ] Mantener la posición de scroll al volver del detalle [S]
- [ ] No bloquear la acción al cerrar el diario (M57) [S]

## U. Persistencia (M59/M60)

- [ ] Persistir el diario en GameState con schema_version [M]
- [ ] Migrar versiones de guardado antiguas [M]
- [ ] Cargar el diario al iniciar sin duplicados [M]
- [ ] Guardar en subida de nivel y cierre correcto [M]
- [ ] Manejar persistencia corrupta con defaults [M]

## V. Localización (M87/M88)

- [ ] Localizar todos los textos del diario por claves i18n [M]
- [ ] Localizar nombres propios sin traducción [S]
- [ ] Dar soporte a plurales [S]
- [ ] Testear el diario en 3 idiomas sin desbordes de UI [M]
- [ ] Validar claves i18n con validate_diary.gd [M]

## W. Rendimiento y Edge Cases (M61/M62)

- [ ] Abrir el diario en < 100 ms con 500+ entradas [C]
- [ ] Virtualizar listas largas (SOLO visible en el árbol) [C]
- [ ] Cargar perezosamente categorías no visibles (LazyLoad) [M]
- [ ] Usar pooling de filas de lista (M62) [C]
- [ ] Manejar texto muy largo con wrap y tooltip completo [M]

## X. Rendimiento y Edge Cases (final)

- [ ] Manejar categoría vacía con mensaje amistoso [S]
- [ ] Manejar búsqueda sin resultados [S]
- [ ] Manejar icono faltante con fallback genérico [S]
- [ ] No emitir VFX en el diario (hábito estricto, M52) [S]
- [ ] Probar el diario con Reduce Motion activo (M58) [M]

## Y. Validación y QA

- [ ] Crear validate_diary.gd (mapeo, i18n, persistencia, rendimiento) [C]
- [ ] Probar ciclo completo: descubrir → registrar → ver → guardar → recargar [C]
- [ ] Probar anti-spoilers: sin descubrir nada, diario vacío correcto [M]
- [ ] Probar 14 categorías con al menos 1 entrada cada una [M]
- [ ] Revisar logs DIARY-* en consola sin errores [S]

## Z. Cierre del Módulo

- [ ] Probar persistencia entre sesiones (guardar → salir → cargar) [C]
- [ ] Probar migración de versión antigua de guardado [C]
- [ ] Documentar plan de testings automáticos del diario [M]
- [ ] Agregar notas del agente al 04-Codigo.md (honestidad) [S]
- [ ] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
