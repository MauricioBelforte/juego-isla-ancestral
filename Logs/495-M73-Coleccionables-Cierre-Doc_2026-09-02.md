# Log 415: M73 Coleccionables — cierre de documentación e integración

**Fecha:** 2026-09-02
**Hora:** 00:45
**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code

## Resumen
Cierre de M73 iter 1: infraestructura completa y funcional, catálogo expandido a 15 items, integración con M36 fauna_registry verificada. Checklist actualizado con 12 items [x] (infraestructura). Items de contenido restantes como [?] con dueño claro.

## Cambios Realizados

### Documentación actualizada
- `DOCUMENTACION/73-Coleccionables/plan-actual/05-Checklist.md`: 2 -> 12 items marcados [x].
- `DOCUMENTACION/73-Coleccionables/plan-actual/04-Codigo.md`: notas del agente agregadas.

### Estado del módulo
- **Código runtime:** 4 scripts + test (completo, 44/44 OK)
- **Datos:** fallback in-code 15 items en 4 categorías (minerales, animales, conchas, reliquias)
- **Autoload:** `coleccionables` registrado en project.godot
- **Integración M36:** especie_avistada -> registro automático (conejo_pradera -> animales_001)
- **Persistencia M59:** sección "coleccionables", versión 1, purga de huérfanos

## Tests
- **M73 test:** 44 OK / 0 fallos
- **M36 regresión:** 59 OK / 0 fallos
- **M65 regresión:** 9 OK / 0 fallos
- **M71 regresión:** 13 OK / 0 fallos
- **M94 regresión:** 38 OK / 0 fallos
- **Boot runtime:** ServiceRegistry completo, 0 errores

## Pendientes con dueño claro
- M35 minería: llamar registrar_por_fuente("mineria", id_local) al extraer
- M34 pesca: conectar señal FISH_CAUGHT
- M33 agricultura: conectar señal CROP_HARVESTED
- M56 fotografía: conectar señal PHOTO_TAKEN
- M74 eventos: registrar performances
- M55 diario: consumir obtener_collected_ids() para UI
- M37 museo: donar -> registrar automáticamente
- M72 logros: conectar categoria_completed
- Catálogo completo 22 categorías x ~500 items (M93 contenido)
- Iconos M46

## Decisiones
1. **id_global compuesto** = categoria_id_local: evita colisiones y mantiene orden semántico
2. **Doble API de registro**: registrar(id_global) + registrar_por_fuente(fuente, id_local)
3. **Mapa hard-coded especie->id** en _on_especie_avistada: funciona para iter 1, mejorar en iter 2 leyendo especie.id_local directo
4. **Recompensa solo se emite**: categoria_completed emitida, M14/M38 deben consumirla
5. **Fallback in-code**: si catalog.json no existe, usa 15 items de ejemplo (4 categorías)
