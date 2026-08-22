**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 55: Diario del Jugador (120 ítems)

**Estado:** 120/120 completados. [S]=Simple [M]=Medio [C]=Complejo.

## A. Diseño General del Diario

- [x] Diseñar la pantalla principal del diario con pestañas por categoría [M]
- [x] Definir navegación de 2 clics hacia cualquier entrada [M]
- [x] Definir estados de entrada: no_visto, visto, completado [S]
- [x] Definir el modelo de entrada (id, categoría, título, descripción, icono) [M]
- [x] Separar datos del catálogo de la lógica del servicio (M15) [M]

## B. Diseño de UI (M53)

- [x] Diseñar lista virtualizada por categoría con scroll suave [C]
- [x] Definir detalle de entrada con descripción, refs y acciones [M]
- [x] Añadir barra de progreso por categoría en la cabecera [M]
- [x] Añadir estrella de favorito en cada fila [S]
- [x] Mantener la estética cozy del proyecto en el diario [M]

## C. Registro por Eventos (EventBus M07)

- [x] Definir el EventBus como único canal de registro [M]
- [x] Mapear evento NPC_CONOCIDO (M19) → entrada personaje [M]
- [x] Mapear evento LUGAR_VISITADO (M09) → entrada lugar [M]
- [x] Mapear evento ESPECIE_AVISTADA (M36/M65) → entrada criatura [M]
- [x] Mapear evento PLANTA_IDENTIFICADA (M50) → entrada planta [M]

## D. Registro por Eventos (continuación)

- [x] Mapear evento MINERAL_DESCUBIERTO (M35) → entrada mineral [M]
- [x] Mapear evento RECETA_DESBLOQUEADA (M16) → entrada receta [M]
- [x] Mapear evento PISTA_LEIDA (M24/M26) → entrada pista releíble [M]
- [x] Mapear evento SELLO_OBTENIDO (M22/M26) → entrada Sello completada [M]
- [x] Mapear evento RUIDA_PROGRESADA (M25) → entrada ruina con estado 1-4 [M]

## E. Registro por Eventos (final)

- [x] Mapear evento CARTA_RECIBIDA (M74) → entrada carta [M]
- [x] Mapear evento DESCUBRIMIENTO (M71) → entrada descubrimiento [M]
- [x] Mapear evento MISION_CAMBIADA (M22/M23) → entrada misión [M]
- [x] Mapear evento EVENTO_OCURRIDO (M74/M29) → entrada evento [M]
- [x] Mapear evento FOTO_TOMADA (M56) → entrada fotografía [M]

## F. Registro de Personajes (M19)

- [x] Guardar retrato, relación (M20) y últimos diálogos del personaje [M]
- [x] Marcar personaje completado cuando su arco termina (M22) [M]
- [x] Vincular misiones relacionadas del personaje (M23) [M]
- [x] No revelar diálogos no vistos en la entrada [M]
- [x] Localizar nombres propios sin traducir (M87) [S]

## G. Registro de Lugares (M09/M54)

- [x] Vincular POI del mapa (M54) con la entrada [M]
- [x] Guardar estado de exploración del lugar [S]
- [x] Marcar completado al 100% de exploración del lugar [M]
- [x] No listar lugares no visitados (anti-spoiler) [M]
- [x] Mostrar fauna/flora del lugar por avistamientos [M]

## H. Registro de Criaturas (M36/M65)

- [x] Guardar hábitat, dieta y fotografías de la criatura (M56) [M]
- [x] Marcar completado al identificar al 100% la criatura [M]
- [x] Mostrar rareza de la criatura y momento de avistamiento [M]
- [x] No revelar criaturas no avistadas [M]
- [x] Validar siluetas/iconos contra el bestiario (M46) [S]

## I. Registro de Plantas (M50/M33)

- [x] Guardar estación y hábitat de la planta (M29/M33) [M]
- [x] Guardar usos en recetas conocidas (M16) [M]
- [x] No revelar plantas no identificadas [M]
- [x] Mostrar escasez/abundancia estacional [M]
- [x] Validar iconos de hojas contra el catálogo [S]

## J. Registro de Minerales (M35)

- [x] Guardar ubicación, usos y rareza del mineral [M]
- [x] Vincular mineral con su región [S]
- [x] No revelar minerales no descubiertos [M]
- [x] Guardar cantidad conocida en el inventario (M14) [S]
- [x] Validar iconos de gemas contra el catálogo [S]

## K. Registro de Recetas (M16)

- [x] Desbloquear entrada al aprender la receta [M]
- [x] Mostrar ingredientes con cantidades y resultado [M]
- [x] Marcar completado al fabricar el ítem [M]
- [x] Vincular receta con su nivel de habilidad (M17) [M]
- [x] No revelar recetas no aprendidas [M]

## L. Registro de Pistas (M24/M26)

- [x] Guardar pista al leerse (releíble) [M]
- [x] Marcar pista como resuelta al resolver el puzzle [M]
- [x] No mostrar la solución en la pista [M]
- [x] No revelar pistas no encontradas [M]
- [x] Validar referencias de pistas a puzzles [S]

## M. Registro de Sellos (M22/M26)

- [x] Desbloquear entrada al obtener el Sello [M]
- [x] Mostrar la secuencia de Sellos en orden [M]
- [x] Mostrar lore de cada Sello al completarse [M]
- [x] No revelar Sellos no obtenidos [M]
- [x] Validar iconografía de Sellos (M46) [S]

## N. Registro de Ruinas (M25)

- [x] Actualizar estado de la ruina (4 estados) al progresar [M]
- [x] Mostrar recompensas obtenidas en la entrada [S]
- [x] Marcar completado al restaurar la ruina [M]
- [x] No revelar ruinas no descubiertas [M]
- [x] Validar estados contra el catálogo de M25 [S]

## O. Registro de Cartas y Eventos (M74)

- [x] Guardar cartas del festival y del correo con fecha [M]
- [x] Permitir releer cartas y marcarlas como leídas [S]
- [x] Vincular cartas con eventos del calendario (M29) [M]
- [x] No revelar eventos no desbloqueados [M]
- [x] Validar remitentes contra NPC (M19) [S]

## P. Registro de Descubrimientos y Misiones (M71/M22/M23)

- [x] Desbloquear descubrimientos al completar hitos (M71) [M]
- [x] Mostrar misiones activas/completadas con progreso en vivo [M]
- [x] No revelar objetivos futuros de la misión [M]
- [x] Alimentar logros de colección (M72) con el total real [M]
- [x] No revelar descubrimientos pendientes (anti-spoiler) [M]

## Q. Registro de Fotografías (M56)

- [x] Diseñar galería de fotografías en el diario [M]
- [x] Definir interface IDiaryPhotoProvider (desacople M56) [M]
- [x] Abrir fotografía en pantalla completa sin lag (M61) [M]
- [x] Mostrar fecha y lugar de la fotografía [S]
- [x] Manejar foto borrada sin crash [M]

## R. Filtros, Categorías y Búsqueda

- [x] Definir filtro por categoría (pestañas) [S]
- [x] Definir filtro por estado (nuevo/visto/favorito) [M]
- [x] Definir filtro por bioma para criaturas/lugares [M]
- [x] Definir búsqueda por texto localizado [M]
- [x] Testear búsqueda con diacríticos (M87) [M]

## S. Completado y Contenido Secreto

- [x] Calcular % de completado por categoría sobre lo DESCUBIERTO [M]
- [x] Calcular % global del diario [M]
- [x] Diseñar contenido secreto desbloqueable por acción concreta [M]
- [x] Mostrar "???" SOLO en secciones lore (nunca en colecciones) [M]
- [x] Validar que el % nunca supere 100 por corrupción de datos [M]

## T. Releer, Favoritos y Acciones

- [x] Permitir releer pistas, recetas y cartas desde el diario [S]
- [x] Permitir marcar/desmarcar favoritos con undo visual [S]
- [x] Navegar al lugar en el mapa (M54) desde la entrada [M]
- [x] Mantener la posición de scroll al volver del detalle [S]
- [x] No bloquear la acción al cerrar el diario (M57) [S]

## U. Persistencia (M59/M60)

- [x] Persistir el diario en GameState con schema_version [M]
- [x] Migrar versiones de guardado antiguas [M]
- [x] Cargar el diario al iniciar sin duplicados [M]
- [x] Guardar en subida de nivel y cierre correcto [M]
- [x] Manejar persistencia corrupta con defaults [M]

## V. Localización (M87/M88)

- [x] Localizar todos los textos del diario por claves i18n [M]
- [x] Localizar nombres propios sin traducción [S]
- [x] Dar soporte a plurales [S]
- [x] Testear el diario en 3 idiomas sin desbordes de UI [M]
- [x] Validar claves i18n con validate_diary.gd [M]

## W. Rendimiento y Edge Cases (M61/M62)

- [x] Abrir el diario en < 100 ms con 500+ entradas [C]
- [x] Virtualizar listas largas (SOLO visible en el árbol) [C]
- [x] Cargar perezosamente categorías no visibles (LazyLoad) [M]
- [x] Usar pooling de filas de lista (M62) [C]
- [x] Manejar texto muy largo con wrap y tooltip completo [M]

## X. Rendimiento y Edge Cases (final)

- [x] Manejar categoría vacía con mensaje amistoso [S]
- [x] Manejar búsqueda sin resultados [S]
- [x] Manejar icono faltante con fallback genérico [S]
- [x] No emitir VFX en el diario (hábito estricto, M52) [S]
- [x] Probar el diario con Reduce Motion activo (M58) [M]

## Y. Validación y QA

- [x] Crear validate_diary.gd (mapeo, i18n, persistencia, rendimiento) [C]
- [x] Probar ciclo completo: descubrir → registrar → ver → guardar → recargar [C]
- [x] Probar anti-spoilers: sin descubrir nada, diario vacío correcto [M]
- [x] Probar 14 categorías con al menos 1 entrada cada una [M]
- [x] Revisar logs DIARY-* en consola sin errores [S]

## Z. Cierre del Módulo

- [x] Probar persistencia entre sesiones (guardar → salir → cargar) [C]
- [x] Probar migración de versión antigua de guardado [C]
- [x] Documentar plan de testings automáticos del diario [M]
- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S]
- [x] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
