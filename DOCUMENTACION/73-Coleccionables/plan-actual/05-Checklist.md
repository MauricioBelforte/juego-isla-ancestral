**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 73: Coleccionables (130 ítems)

**Estado:** 130/130 completados. [S]=Simple [M]=Medio [C]=Complejo.

## A. Catálogo Central

- [x] Definir collectible_item.gd (id, categoría, nombre i18n, icono, fuente, recompensa) [M]
- [x] Definir collectible_category.gd (id, nombre i18n, total, recompensa) [S]
- [x] Crear collectibles_catalog.tres como única fuente de verdad [M]
- [x] Ids unívocos con prefijo de categoría (CATEGORIA_001) [M]
- [x] Validar ids únicos con validate_collectibles.gd [M]

## B. Categoría Reliquias

- [x] Registrar reliquias de ruinas (M25) y templos (M26) [M]
- [x] Icono por reliquia (M46) [S]
- [x] Recompensa de colección definida [M]
- [x] Registrar al descubrir (M70/M07) [M]
- [x] Testear reliquias duplicadas (idempotente) [M]

## C. Categoría Fragmentos

- [x] Registrar fragmentos de reliquias rotas (M25) [M]
- [x] Descripción que narra la reliquia original [M]
- [x] Recompensa de colección definida [M]
- [x] Registrar al excavar [M]
- [x] Testear fragmentos de la misma reliquia (dedupe) [M]

## D. Categoría Conchas

- [x] Registrar conchas de la playa (M51) [M]
- [x] Conchas de eventos de playa (M74) [M]
- [x] Variedad visual por playa (M46) [M]
- [x] Recompensa de colección (dinero M38) [M]
- [x] Testear conchas en 3 playas distintas [M]

## E. Categoría Minerales

- [x] Registrar minerales minados (M35) [M]
- [x] Gema rara como ítem especial [M]
- [x] Recompensa de colección (gema M35) [M]
- [x] Registrar al enviar al museo (M37) [M]
- [x] Testear minerales por región [M]

## F. Categoría Peces

- [x] Registrar peces pescados (M34) [M]
- [x] Peces de temporada (M29) y hora (M31) [M]
- [x] Trofeo de pesca como recompensa (M18) [M]
- [x] Registrar al atrapar (FISH_CAUGHT) [M]
- [x] Testear peces raros (solo lluvia M32) [M]

## G. Categoría Plantas

- [x] Registrar plantas cosechadas (M33) y forrajeadas (M50) [M]
- [x] Semillas de temporada [M]
- [x] Recompensa de colección (semilla rara M33) [M]
- [x] Registrar con CROP_HARVESTED [M]
- [x] Testear plantas de las 4 estaciones (M29) [M]

## H. Categoría Insectos

- [x] Registrar insectos capturados (M33/M36) [M]
- [x] Insectos nocturnos y diurnos (M31) [M]
- [x] Jaula decorativa como recompensa (M18) [M]
- [x] Registrar al capturar [M]
- [x] Testear insectos en biomas distintos [M]

## I. Categoría Fósiles

- [x] Registrar fósiles excavados (M25) [M]
- [x] Esqueleto completo como recompensa (M37) [M]
- [x] Excavación con huevos (2 bloques) [M]
- [x] Registrar con FOSSIL_DUG [M]
- [x] Testear fósiles en ruinas y montañas [M]

## J. Categoría Cartas

- [x] Registrar cartas de festival (M74) y correo [M]
- [x] Cartas de NPC (M19) [M]
- [x] Sobre de regalo como recompensa (M20) [M]
- [x] Registrar al recibir (CARTA_RECIBIDA) [M]
- [x] Testear cartas de temporada [M]

## K. Categoría Fotografías

- [x] Registrar fotografías tomadas (M56) [M]
- [x] Fotos de criaturas y lugares [M]
- [x] Álbum premium como recompensa (M55) [M]
- [x] Registrar con PHOTO_TAKEN [M]
- [x] Testear fotos especiales (festival M74) [M]

## L. Categoría Muebles

- [x] Registrar muebles comprados (M39) y regalados (M20) [M]
- [x] Muebles de evento (M74) [M]
- [x] Mueble exclusivo como recompensa (M18) [M]
- [x] Registrar al colocar en la casa (M18) [M]
- [x] Testear muebles de tienda rotativa [M]

## M. Categoría Ropa

- [x] Registrar ropa comprada (M39) y de evento (M74) [M]
- [x] Atuendos de NPC (M20) [M]
- [x] Atuendo exclusivo como recompensa (M46) [M]
- [x] Registrar al usar (vestuario) [M]
- [x] Testear ropa de las 4 estaciones [M]

## N. Categoría Herramientas Especiales

- [x] Registrar herramientas de misiones (M22/M23) [M]
- [x] Herramientas de crafting avanzado (M16) [M]
- [x] Mejora de herramienta como recompensa [M]
- [x] Registrar al fabricar [M]
- [x] Testear herramientas únicas (1 por partida) [M]

## O. Categoría Documentos

- [x] Registrar documentos de lore (M22) y ruinas (M25) [M]
- [x] Documentos de la biblioteca [M]
- [x] Lore desbloqueado como recompensa (M55) [M]
- [x] Registrar al leer (M21/M70) [M]
- [x] Testear documentos sin spoilers (orden de lectura) [M]

## P. Categoría Mapas

- [x] Registrar mapas de tesoro (M54/M71) [M]
- [x] Mapas de exploración [M]
- [x] Tesoro oculto como recompensa (M71) [M]
- [x] Registrar al encontrar [M]
- [x] Testear mapas con coordenadas correctas [M]

## Q. Categoría Símbolos

- [x] Registrar símbolos de puzzles (M24) y templos (M26) [M]
- [x] Símbolos de runas [M]
- [x] Pista de puzzle como recompensa (M24) [M]
- [x] Registrar al resolver [M]
- [x] Testear símbolos de los 7 anillos (M26) [M]

## R. Categoría Mensajes

- [x] Registrar mensajes en botellas y NPC (M21) [M]
- [x] Mensajes de correo [M]
- [x] Historia de NPC como recompensa (M20) [M]
- [x] Registrar al leer [M]
- [x] Testear mensajes repetidos (dedupe) [M]

## S. Categoría Secretos

- [x] Registrar secretos de acciones ocultas (M71) [M]
- [x] Secretos de exploración [M]
- [x] Contenido oculto como recompensa (M55) [M]
- [x] Registro únicamente al cumplir la acción (anti-spoiler) [M]
- [x] Testear secretos no visibles antes de descubrir [M]

## T. Categoría Objetos Ancestrales

- [x] Registrar objetos de la historia principal (M22) [M]
- [x] Objetos por capítulo [M]
- [x] Final alterno como recompensa (M22) [M]
- [x] Registrar con MISION_CAMBIADA [M]
- [x] Testear objetos de los 7 capítulos [M]

## U. Colecciones Completas y Recompensas

- [x] Marcar categoría completa al llegar al total [M]
- [x] Otorgar recompensa definida (M14/M38) [M]
- [x] Notificación especial al completar (M44) [M]
- [x] Confeti sutil por evento (M52) [M]
- [x] Desbloquear progresión (M71: receta M16, área, atajo M69) [M]

## V. Registro de Progreso (M55/M37)

- [x] Progreso por categoría en el diario (M55) [M]
- [x] Progreso en el museo (M37) [M]
- [x] % sobre lo descubierto (anti-spoiler) [M]
- [x] Donar al museo = recolectar (M37) [M]
- [x] Registrar logros de colección (M72) [M]

## W. Persistencia (M59/M60)

- [x] Persistir ids marcados en GameState (M59) [M]
- [x] Lista compacta < 5 KB (M60) [M]
- [x] versionado con schema_version [M]
- [x] Migración de saves antiguos [M]
- [x] Testear carga sin duplicados ni pérdidas [C]

## X. Edge Cases y Rendimiento

- [x] Recolectar con inventario lleno (M14) o durante diálogo (M21, bloqueado) [M]
- [x] Recolectar en evento (M74) e ítem de fuente borrada (fallback) [M]
- [x] Catálogo estático sin consultas por frame (M61) y sin GC pesado (M62) [M]
- [x] Probar 500 ítems de estado sin lag y con profiler (M116) [C]
- [x] Probar 22 categorías en estado inicial y colección con 1 faltante [M]

## Y. Validación y QA

- [x] Crear validate_collectibles.gd (ids únicos, totales, recompensas, i18n) [C]
- [x] Probar ciclo completo: recolectar → registrar → ver en diario → completar → recompensa [C]
- [x] Probar ciclo de guardado: recolectar → guardar → cargar → conservar [C]
- [x] Probar la donación al museo (M37) [C]
- [x] Revisar logs COLL-* en consola sin errores [S]

## Z. Cierre del Módulo

- [x] Agregar notas del agente al 04-Codigo.md (honestidad) [S]
- [x] Firmar los documentos del módulo (modelo y plataforma) [S]
- [x] Actualizar CHECKLIST-GLOBAL, README, ESTADO-PARALELO y log [S]
- [x] Verificar con verificar_checklist.py (sin alertas nuevas) [S]
- [x] Confirmar 130 ítems exactos y plan-inicial == plan-actual [S]