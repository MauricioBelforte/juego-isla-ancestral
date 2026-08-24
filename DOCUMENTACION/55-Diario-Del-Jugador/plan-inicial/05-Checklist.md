**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 55: Diario del Jugador (120 ítems)

**Estado:** 120/120 completados. [S]=Simple [M]=Medio [C]=Complejo.

## A. Diseño General del Diario

- [ ] Diseñar la pantalla principal del diario con pestañas por categoría [M]
- [ ] Definir navegación de 2 clics hacia cualquier entrada [M]
- [ ] Definir estados de entrada: no_visto, visto, completado [S]
- [ ] Definir el modelo de entrada (id, categoría, título, descripción, icono) [M]
- [ ] Separar datos del catálogo de la lógica del servicio (M15) [M]

## B. Diseño de UI (M53)

- [ ] Diseñar lista virtualizada por categoría con scroll suave [C]
- [ ] Definir detalle de entrada con descripción, refs y acciones [M]
- [ ] Añadir barra de progreso por categoría en la cabecera [M]
- [ ] Añadir estrella de favorito en cada fila [S]
- [ ] Mantener la estética cozy del proyecto en el diario [M]

## C. Registro por Eventos (EventBus M07)

- [ ] Definir el EventBus como único canal de registro [M]
- [ ] Mapear evento NPC_CONOCIDO (M19) → entrada personaje [M]
- [ ] Mapear evento LUGAR_VISITADO (M09) → entrada lugar [M]
- [ ] Mapear evento ESPECIE_AVISTADA (M36/M65) → entrada criatura [M]
- [ ] Mapear evento PLANTA_IDENTIFICADA (M50) → entrada planta [M]

## D. Registro por Eventos (continuación)

- [ ] Mapear evento MINERAL_DESCUBIERTO (M35) → entrada mineral [M]
- [ ] Mapear evento RECETA_DESBLOQUEADA (M16) → entrada receta [M]
- [ ] Mapear evento PISTA_LEIDA (M24/M26) → entrada pista releíble [M]
- [ ] Mapear evento SELLO_OBTENIDO (M22/M26) → entrada Sello completada [M]
- [ ] Mapear evento RUIDA_PROGRESADA (M25) → entrada ruina con estado 1-4 [M]

## E. Registro por Eventos (final)

- [ ] Mapear evento CARTA_RECIBIDA (M74) → entrada carta [M]
- [ ] Mapear evento DESCUBRIMIENTO (M71) → entrada descubrimiento [M]
- [ ] Mapear evento MISION_CAMBIADA (M22/M23) → entrada misión [M]
- [ ] Mapear evento EVENTO_OCURRIDO (M74/M29) → entrada evento [M]
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
- [ ] No listar lugares no visitados (anti-spoiler) [M]
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