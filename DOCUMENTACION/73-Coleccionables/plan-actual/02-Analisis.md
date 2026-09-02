**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code

# 02-Analisis.md — Módulo 73: Coleccionables

## 1. Análisis del Dominio

El dominio de los coleccionables de Aurora se descompone en seis subsistemas:

### 1.1 Catálogo central
- **Dominio:** un catálogo estático (`collectibles_catalog.tres`) con las 22 categorías del plan maestro; cada ítem: `id` (unívoco, tipo `CATEGORIA_001`), nombre y descripción (claves i18n M87), icono (M46), fuente (M34/M35/M33/M36/M25/M22/M74/M56/M39...), recompensa de colección.
- **Clave:** el catálogo es la ÚNICA fuente de verdad; ningún sistema hardcodea nombres.

### 1.2 Registro por eventos
- **Dominio:** los sistemas emiten eventos (M07): `ITEM_COLLECTED(id)`, `FISH_CAUGHT(id)`, `CROP_HARVESTED`, `MINERAL_MINED`, `FOSSIL_DUG`, `PHOTO_TAKEN`... `CollectibleService` traduce a `mark_collected(id)`.
- **Clave:** id unívoco → marca `collected=true`; si ya estaba → se ignora (sin duplicados). El registro es idempotente.

### 1.3 Progreso y colecciones completas
- **Dominio:** por categoría: `n/total` y `completa`. Al llegar a `total`, la categoría se marca completa: recompensa (catálogo), notificación (M44) y evento `COLLECTION_COMPLETED` (M07) para logros (M72).
- **Clave:** el total por categoría es del catálogo (estático); el jugador NO ve los ítems no descubiertos (anti-spoiler como M55); el progreso visible es el de lo descubierto.

### 1.4 Coordinación con museo (M37) y diario (M55)
- **Dominio:** el museo (M37) muestra las colecciones donadas; el diario (M55) tiene la sección de coleccionables con progreso. Ambos leen el mismo `CollectibleService`.
- **Clave:** sin duplicar datos: museo y diario son vistas del mismo estado.

### 1.5 Recompensas y desbloqueos
- **Dominio:** al completar: recompensa inmediata (ítem M14, dinero M38) + desbloqueo permanente (M71: área, receta M16, atajo M69) + logro (M72).
- **Clave:** recompensas generosas (cozy); nunca bloquean la historia principal (M22).

### 1.6 Persistencia y validación
- **Dominio:** el estado de colecciones (ids marcados) persiste en GameState (M59/M60) versionado; `validate_collectibles.gd` verifica: ids únicos, totales correctos, recompensas resolubles, claves i18n existentes.
- **Clave:** tamaño del estado: ~500 ítems → bitset/lista compacta (< 5 KB).

## 2. Alternativas Consideradas

| Alternativa | Veredicto | Motivo |
|---|---|---|
| Ítems duplicados por sistema (cada uno con su registro) | **Descartado** | Catálogo central único |
| Mostrar ítems no descubiertos | **Descartado** | Anti-spoiler (como M55): invisibles |
| Registro manual en cada escena | **Descartado** | Eventos M07 → servicio único |
| Progreso duplicado en museo y diario | **Descartado** | Mismo servicio, vistas distintas |
| Recompensas que bloquean la historia | **Descartado** | Cozy: generosas y no bloqueantes |
| Estado grande (objeto completo por ítem) | **Descartado** | Lista compacta de ids (M60) |

## 3. Decisiones del Módulo

1. **Catálogo central** (`collectibles_catalog.tres`) con 22 categorías y ids unívocos.
2. **Registro idempotente por eventos** (M07) con anti-duplicados.
3. **Progreso visible sobre lo descubierto** (anti-spoiler, como M55).
4. **Colecciones completas → recompensa + evento** para M72 (logros) y M71 (desbloqueos).
5. **Museo (M37) y diario (M55) como vistas** del mismo servicio.
6. **Persistencia compacta** en GameState (M59/M60).

## 4. Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---|---|---|
| Duplicados por doble recolección | Media | Medio | Registro idempotente por id unívoco |
| Totales inconsistentes con el catálogo | Baja | Medio | Validador de totales |
| Spoilers en el diario | Media | Medio | Anti-spoiler (invisibles, como M55) |
| Recompensas rotas (recurso inexistente) | Baja | Medio | Validador de recompensas |
| Colecciones que no persisten | Baja | Alto | GameState versionado (M59/M60) |
| Categorías olvidadas del plan maestro | Baja | Medio | Checklist de 22 categorías en el catálogo |