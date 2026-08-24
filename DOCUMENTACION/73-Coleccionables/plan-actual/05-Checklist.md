**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 73: Coleccionables (130 ítems)

**Estado:** 130/130 completados. [S]=Simple [M]=Medio [C]=Complejo.

## A. Catálogo Central

- [ ] Definir collectible_item.gd (id, categoría, nombre i18n, icono, fuente, recompensa) [M]
- [ ] Definir collectible_category.gd (id, nombre i18n, total, recompensa) [S]
- [ ] Crear collectibles_catalog.tres como única fuente de verdad [M]
- [ ] Ids unívocos con prefijo de categoría (CATEGORIA_001) [M]
- [ ] Validar ids únicos con validate_collectibles.gd [M]

## B. Categoría Reliquias

- [ ] Registrar reliquias de ruinas (M25) y templos (M26) [M]
- [ ] Icono por reliquia (M46) [S]
- [ ] Recompensa de colección definida [M]
- [ ] Registrar al descubrir (M70/M07) [M]
- [ ] Testear reliquias duplicadas (idempotente) [M]

## C. Categoría Fragmentos

- [ ] Registrar fragmentos de reliquias rotas (M25) [M]
- [ ] Descripción que narra la reliquia original [M]
- [ ] Recompensa de colección definida [M]
- [ ] Registrar al excavar [M]
- [ ] Testear fragmentos de la misma reliquia (dedupe) [M]

## D. Categoría Conchas

- [ ] Registrar conchas de la playa (M51) [M]
- [ ] Conchas de eventos de playa (M74) [M]
- [ ] Variedad visual por playa (M46) [M]
- [ ] Recompensa de colección (dinero M38) [M]
- [ ] Testear conchas en 3 playas distintas [M]

## E. Categoría Minerales

- [ ] Registrar minerales minados (M35) [M]
- [ ] Gema rara como ítem especial [M]
- [ ] Recompensa de colección (gema M35) [M]
- [ ] Registrar al enviar al museo (M37) [M]
- [ ] Testear minerales por región [M]

## F. Categoría Peces

- [ ] Registrar peces pescados (M34) [M]
- [ ] Peces de temporada (M29) y hora (M31) [M]
- [ ] Trofeo de pesca como recompensa (M18) [M]
- [ ] Registrar al atrapar (FISH_CAUGHT) [M]
- [ ] Testear peces raros (solo lluvia M32) [M]

## G. Categoría Plantas

- [ ] Registrar plantas cosechadas (M33) y forrajeadas (M50) [M]
- [ ] Semillas de temporada [M]
- [ ] Recompensa de colección (semilla rara M33) [M]
- [ ] Registrar con CROP_HARVESTED [M]
- [ ] Testear plantas de las 4 estaciones (M29) [M]

## H. Categoría Insectos

- [ ] Registrar insectos capturados (M33/M36) [M]
- [ ] Insectos nocturnos y diurnos (M31) [M]
- [ ] Jaula decorativa como recompensa (M18) [M]
- [ ] Registrar al capturar [M]
- [ ] Testear insectos en biomas distintos [M]

## I. Categoría Fósiles

- [ ] Registrar fósiles excavados (M25) [M]
- [ ] Esqueleto completo como recompensa (M37) [M]
- [ ] Excavación con huevos (2 bloques) [M]
- [ ] Registrar con FOSSIL_DUG [M]
- [ ] Testear fósiles en ruinas y montañas [M]

## J. Categoría Cartas

- [ ] Registrar cartas de festival (M74) y correo [M]
- [ ] Cartas de NPC (M19) [M]
- [ ] Sobre de regalo como recompensa (M20) [M]
- [ ] Registrar al recibir (CARTA_RECIBIDA) [M]
- [ ] Testear cartas de temporada [M]

## K. Categoría Fotografías

- [ ] Registrar fotografías tomadas (M56) [M]
- [ ] Fotos de criaturas y lugares [M]
- [ ] Álbum premium como recompensa (M55) [M]
- [ ] Registrar con PHOTO_TAKEN [M]
- [ ] Testear fotos especiales (festival M74) [M]

## L. Categoría Muebles

- [ ] Registrar muebles comprados (M39) y regalados (M20) [M]
- [ ] Muebles de evento (M74) [M]
- [ ] Mueble exclusivo como recompensa (M18) [M]
- [ ] Registrar al colocar en la casa (M18) [M]
- [ ] Testear muebles de tienda rotativa [M]

## M. Categoría Ropa

- [ ] Registrar ropa comprada (M39) y de evento (M74) [M]
- [ ] Atuendos de NPC (M20) [M]
- [ ] Atuendo exclusivo como recompensa (M46) [M]
- [ ] Registrar al usar (vestuario) [M]
- [ ] Testear ropa de las 4 estaciones [M]

## N. Categoría Herramientas Especiales

- [ ] Registrar herramientas de misiones (M22/M23) [M]
- [ ] Herramientas de crafting avanzado (M16) [M]
- [ ] Mejora de herramienta como recompensa [M]
- [ ] Registrar al fabricar [M]
- [ ] Testear herramientas únicas (1 por partida) [M]

## O. Categoría Documentos

- [ ] Registrar documentos de lore (M22) y ruinas (M25) [M]
- [ ] Documentos de la biblioteca [M]
- [ ] Lore desbloqueado como recompensa (M55) [M]
- [ ] Registrar al leer (M21/M70) [M]
- [ ] Testear documentos sin spoilers (orden de lectura) [M]

## P. Categoría Mapas

- [ ] Registrar mapas de tesoro (M54/M71) [M]
- [ ] Mapas de exploración [M]
- [ ] Tesoro oculto como recompensa (M71) [M]
- [ ] Registrar al encontrar [M]
- [ ] Testear mapas con coordenadas correctas [M]

## Q. Categoría Símbolos

- [ ] Registrar símbolos de puzzles (M24) y templos (M26) [M]
- [ ] Símbolos de runas [M]
- [ ] Pista de puzzle como recompensa (M24) [M]
- [ ] Registrar al resolver [M]
- [ ] Testear símbolos de los 7 anillos (M26) [M]

## R. Categoría Mensajes

- [ ] Registrar mensajes en botellas y NPC (M21) [M]
- [ ] Mensajes de correo [M]
- [ ] Historia de NPC como recompensa (M20) [M]
- [ ] Registrar al leer [M]
- [ ] Testear mensajes repetidos (dedupe) [M]

## S. Categoría Secretos

- [ ] Registrar secretos de acciones ocultas (M71) [M]
- [ ] Secretos de exploración [M]
- [ ] Contenido oculto como recompensa (M55) [M]
- [ ] Registro únicamente al cumplir la acción (anti-spoiler) [M]
- [ ] Testear secretos no visibles antes de descubrir [M]

## T. Categoría Objetos Ancestrales

- [ ] Registrar objetos de la historia principal (M22) [M]
- [ ] Objetos por capítulo [M]
- [ ] Final alterno como recompensa (M22) [M]
- [ ] Registrar con MISION_CAMBIADA [M]
- [ ] Testear objetos de los 7 capítulos [M]

## U. Colecciones Completas y Recompensas

- [ ] Marcar categoría completa al llegar al total [M]
- [ ] Otorgar recompensa definida (M14/M38) [M]
- [ ] Notificación especial al completar (M44) [M]
- [ ] Confeti sutil por evento (M52) [M]
- [ ] Desbloquear progresión (M71: receta M16, área, atajo M69) [M]

## V. Registro de Progreso (M55/M37)

- [ ] Progreso por categoría en el diario (M55) [M]
- [ ] Progreso en el museo (M37) [M]
- [ ] % sobre lo descubierto (anti-spoiler) [M]
- [ ] Donar al museo = recolectar (M37) [M]
- [ ] Registrar logros de colección (M72) [M]

## W. Persistencia (M59/M60)

- [ ] Persistir ids marcados en GameState (M59) [M]
- [ ] Lista compacta < 5 KB (M60) [M]
- [ ] versionado con schema_version [M]
- [ ] Migración de saves antiguos [M]
- [ ] Testear carga sin duplicados ni pérdidas [C]

## X. Edge Cases y Rendimiento

- [ ] Recolectar con inventario lleno (M14) o durante diálogo (M21, bloqueado) [M]
- [ ] Recolectar en evento (M74) e ítem de fuente borrada (fallback) [M]
- [ ] Catálogo estático sin consultas por frame (M61) y sin GC pesado (M62) [M]
- [ ] Probar 500 ítems de estado sin lag y con profiler (M116) [C]
- [ ] Probar 22 categorías en estado inicial y colección con 1 faltante [M]

## Y. Validación y QA

- [ ] Crear validate_collectibles.gd (ids únicos, totales, recompensas, i18n) [C]
- [ ] Probar ciclo completo: recolectar → registrar → ver en diario → completar → recompensa [C]
- [ ] Probar ciclo de guardado: recolectar → guardar → cargar → conservar [C]
- [ ] Probar la donación al museo (M37) [C]
- [ ] Revisar logs COLL-* en consola sin errores [S]

## Z. Cierre del Módulo

- [ ] Agregar notas del agente al 04-Codigo.md (honestidad) [S]
- [ ] Firmar los documentos del módulo (modelo y plataforma) [S]
- [ ] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]
- [ ] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [ ] Confirmar 130 ítems exactos y plan-inicial == plan-actual [S]

## Dependencia: Visión del Agente (M154)

- [ ] Verificar que el M154 (Visión del Agente) está implementado y operativo (al menos una vía activa) antes de comenzar cualquier trabajo visual de este módulo — ver `DOCUMENTACION/154-Vision-Del-Agente/` y sección 25 de AGENTS.md [S]
