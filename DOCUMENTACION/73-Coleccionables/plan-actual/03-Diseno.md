**Modelo:** minimax-m3-free
**Plataforma:** Kilo Code

# 03-Diseno.md — Módulo 73: Coleccionables

## 1. Arquitectura

```
Assets/_Project/Collectibles/
â”œâ”€â”€ data/
│   ├── collectible_item.gd        (modelo: id, categoría, nombre i18n, icono M46, fuente, recompensa)
│   ├── collectible_category.gd    (modelo: id, nombre i18n, total, recompensa de colección)
│   └── collectibles_catalog.tres  (catálogo central: 22 categorías, ~500 ítems)
â”œâ”€â”€ service/
â”‚   â”œâ”€â”€ collectible_service.gd     (autoload: registro idempotente, progreso, colecciones completas)
â”‚   â””â”€â”€ collectible_save.gd        (persistencia compacta en GameState M59/M60)
â”œâ”€â”€ ui/
│   ├── collection_view.gd         (vista en diario M55: progreso por categoría)
│   └── collection_reward.gd       (notificación de colección completada M44)
â””â”€â”€ validators/
    └── validate_collectibles.gd   (ids únicos, totales, recompensas, i18n, persistencia)
```

`CollectibleService` (autoload) escucha los eventos de recolección (M07) y marca `collected`; expone progreso y eventos de completado a M55 (diario), M37 (museo), M72 (logros) y M71 (desbloqueos). El catálogo es estático; el estado (ids marcados) persiste en GameState (M59/M60) como lista compacta versionada.

## 2. Diagramas de Flujo (texto)

### 2.1 Registro de un coleccionable

```
evento de recolección (M07: ITEM_COLLECTED, FISH_CAUGHT, MINERAL_MINED...)
  â†’ CollectibleService.mark_collected(id):
    → 1) id existe en catálogo? no → ignorar (log COLL-WARN)
    → 2) ya estaba marcado? sí → ignorar (idempotente, sin duplicados)
    â†’ 3) marcar collected=true; registrar en estado (dirty para M59)
    → 4) notificación sutil "¡Nuevo coleccionable!" (M44)
    → 5) si la categoría quedó completa → COLELECTION_COMPLETED (M07)
    â†’ 6) log COLL-ADD
```

### 2.2 Colección completada

```
categoría llega a total
  â†’ CollectibleService._on_category_complete(category):
    → 1) marcar categoría completa (estado)
    → 2) otorgar recompensa: ítem (M14) o dinero (M38)
    → 3) notificación especial (M44) + confeti sutil (M52)
    → 4) desbloquear progresión (M71): receta (M16), área, atajo (M69)
    → 5) logro (M72) vía evento
    â†’ 6) log COLL-COMPLETE
```

### 2.3 Persistencia

```
auto-save (M59) / cierre
  â†’ collectible_save.gd:
    â†’ 1) serializar ids marcados (bitset/lista compacta, M60)
    → 2) guardar con schema_version (migración M60)
    â†’ 3) log COLL-SAVE
```

## 3. Tablas de Métricas (técnico)

### 3.1 Categorías del catálogo (plan maestro sección 72)

| Categoría | Fuente principal | Ítems típicos | Recompensa de colección |
|---|---|---|---|
| Reliquias | M25/M26 | ~25 | ítem raro M14 |
| Fragmentos | M25 | ~20 | receta M16 |
| Conchas | M51/M74 | ~15 | dinero M38 |
| Minerales | M35 | ~20 | gema (M35) |
| Peces | M34 | ~35 | trofeo (M18) |
| Plantas | M33/M50 | ~30 | semilla rara (M33) |
| Insectos | M33/M36 | ~25 | jaula decorativa (M18) |
| Fósiles | M25 | ~15 | esqueleto de museo (M37) |
| Cartas | M74/correo | ~20 | sobre de regalo (M20) |
| Fotografías | M56 | ~30 | álbum premium (M55) |
| Muebles | M39/M20 | ~40 | mueble exclusivo (M18) |
| Ropa | M39/M74 | ~25 | atuendo exclusivo (M46) |
| Herramientas especiales | M22/M16 | ~12 | mejora de herramienta (M16) |
| Documentos | M22/M25 | ~18 | lore desbloqueado (M55) |
| Mapas | M54/M71 | ~10 | tesoro oculto (M71) |
| Símbolos | M24/M26 | ~15 | pista de puzzle (M24) |
| Mensajes | M21 | ~12 | historia de NPC (M20) |
| Secretos | M71 | ~8 | contenido oculto (M55) |
| Objetos ancestrales | M22 | ~10 | final alterno (M22) |
| Colecciones completas | — | 22 | trofeo maestro (M72) |

### 3.2 Reglas de colección

| Regla | Valor |
|---|---|
| Registro | idempotente por id unívoco |
| Progreso visible | sobre lo DESCUBIERTO (anti-spoiler) |
| Estado | lista compacta < 5 KB (M60) |
| Recompensa | generosa, nunca bloquea M22 |
| Museo (M37) y diario (M55) | vistas del mismo servicio |

## 4. Integraciones Clave

| Módulo | Integración |
|---|---|
| M07 | Eventos de recolección |
| M37 | Museo: donación y exhibición |
| M55 | Diario: vista de progreso |
| M72 | Logros: colecciones como fuente |
| M71 | Desbloqueos por colección completa |
| M59/M60 | Persistencia compacta versionada |
| M44 | Notificaciones de nuevo ítem y colección |
| M52 | Confeti sutil al completar (evento) |
| M14 | Recompensas de ítem |
| M38 | Recompensas de dinero |
| M16/M33/M34/M35/M36/M50/M25/M22/M56/M74/M21/M24/M26/M39/M20 | Fuentes de ítems |
| M46 | Iconos |
| M87 | Localización |
| M108/M118 | Importación y validación en CI |
## Specs Coleccionables (Beam 487)

### Testear conchas en 3 playas distintas
- Spec: test de conchas en 3 playas distintas (M46). Coherente con M46 (colección) y M27 (islas).

### Gema rara como ítem especial
- Spec: gema rara como ítem especial de colección. Coherente con M14 (recursos) y M73 (colección).

### Testear minerales por región
- Spec: test de minerales por región. Coherente con M14 (recursos) y M73 (colección).

### Peces de temporada y hora
- Spec: peces de temporada (M29) y hora (M31) en colección. Coherente con M34 (pesca) y M73 (colección).

### Trofeo de pesca como recompensa
- Spec: trofeo de pesca como recompensa de colección (M18). Coherente con M34 (pesca) y M18 (NPC).
### Testear peces raros (solo lluvia M32)
- Spec: test de peces raros que solo aparecen en lluvia (M32). Coherente con M34 (pesca) y M73 (colección).

### Semillas de temporada
- Spec: semillas de temporada (M29) en colección. Coherente con M15 (recursos) y M73 (colección).

### Recompensa de colección (semilla rara M33)
- Spec: recompensa de colección (semilla rara M33). Coherente con M15 (recursos) y M73 (colección).

### Testear plantas de las 4 estaciones (M29)
- Spec: test de plantas de las 4 estaciones (M29). Coherente con M15 (recursos) y M73 (colección).

### Insectos nocturnos y diurnos (M31)
- Spec: insectos nocturnos y diurnos (M31) en colección. Coherente con M73 (colección) y M31 (ciclo).
### Jaula decorativa como recompensa (M18)
- Spec: jaula decorativa como recompensa de colección (M18). Coherente con M18 (NPC) y M73 (colección).

### Testear insectos en biomas distintos
- Spec: test de insectos en biomas distintos. Coherente con M73 (colección) y M27 (islas).

### Esqueleto completo como recompensa (M37)
- Spec: esqueleto completo como recompensa de colección (M37). Coherente con M37 (museo) y M73 (colección).

### Excavación con huevos (2 bloques)
- Spec: excavación con huevos (2 bloques) para fósiles. Coherente con M73 (colección) y M08 (terreno).

### Cartas de NPC (M19)
- Spec: cartas de NPC (M19) como coleccionables. Coherente con M19 (amistad) y M73 (colección).
### Sobre de regalo como recompensa (M20)
- Spec: sobre de regalo como recompensa de colección (M20). Coherente con M20 (diálogos) y M73 (colección).

### Testear cartas de temporada
- Spec: test de cartas de temporada (M29). Coherente con M73 (colección) y M29 (tiempo).
### Fotos de criaturas y lugares
- Spec: fotos de criaturas y lugares como coleccionables. Coherente con M73 (colección) y M46 (UI).

### Álbum premium como recompensa (M55)
- Spec: álbum premium como recompensa de colección (M55). Coherente con M55 (diario) y M73 (colección).

### Testear fotos especiales (festival M74)
- Spec: test de fotos especiales de festival (M74). Coherente con M74 (eventos) y M73 (colección).

### Muebles de evento (M74)
- Spec: muebles de evento (M74) como coleccionables. Coherente con M74 (eventos) y M73 (colección).

### Mueble exclusivo como recompensa (M18)
- Spec: mueble exclusivo como recompensa de colección (M18). Coherente con M18 (NPC) y M73 (colección).
## Specs Coleccionables (Beam 520)

### Probar 500 ítems de estado sin lag y con profiler (M116)
- Spec: probar 500 ítems de estado sin lag y con profiler (M116). Coherente con M73 (colección) y M116 (profiling).

### Crear validate_collectibles.gd (ids únicos, totales, recompensas, i18n)
- Spec: crear validate_collectibles.gd (ids únicos, totales, recompensas, i18n). Coherente con M73 (colección) y M112 (testing).
## Specs Coleccionables (Beam 546)

### Registrar al colocar en la casa (M18)
- Spec: registrar al colocar en la casa (M18). Coherente with M73 (colección) and M18 (NPC).

### Testear muebles de tienda rotativa
- Spec: testear muebles de tienda rotativa. Coherente with M73 (colección) and M18 (NPC).

### Atuendos de NPC (M20)
- Spec: atuendos de NPC (M20). Coherente with M73 (colección) and M20 (diálogos).

### Atuendo exclusivo como recompensa (M46)
- Spec: atuendo exclusivo como recompensa (M46). Coherente with M73 (colección) and M46 (texturas).

### Testear ropa de las 4 estaciones
- Spec: testear ropa de las 4 estaciones. Coherente with M73 (colección) and M29 (tiempo).
## Specs Coleccionables (Beam 547)

### Herramientas de crafting avanzado (M16)
- Spec: herramientas de crafting avanzado (M16). Coherente with M73 (colección) and M16 (crafting).

### Mejora de herramienta como recompensa
- Spec: mejora de herramienta como recompensa. Coherente with M73 (colección) and M16 (crafting).

### Testear herramientas únicas (1 por partida)
- Spec: testear herramientas únicas (1 por partida). Coherente with M73 (colección) and M16 (crafting).

### Documentos de la biblioteca
- Spec: documentos de la biblioteca. Coherente with M73 (colección) and M22 (historia).

### Lore desbloqueado como recompensa (M55)
- Spec: lore desbloqueado como recompensa (M55). Coherente with M73 (colección) and M55 (diario).
## Specs Coleccionables (Beam 548)

### Registrar al leer (M21/M70)
- Spec: registrar al leer (M21/M70). Coherente with M73 (colección) and M21 (historia).

### Testear documentos sin spoilers (orden de lectura)
- Spec: testear documentos sin spoilers (orden de lectura). Coherente with M73 (colección) and M22 (historia).

### Mapas de exploración
- Spec: mapas de exploración. Coherente with M73 (colección) and M54 (mapa).

### Tesoro oculto como recompensa (M71)
- Spec: tesoro oculto como recompensa (M71). Coherente with M73 (colección) and M71 (progresión).

### Testear mapas con coordenadas correctas
- Spec: testear mapas con coordenadas correctas. Coherente with M73 (colección) and M54 (mapa).
## Specs Coleccionables (Beam 549)

### Registrar símbolos de puzzles (M24) y templos (M26)
- Spec: registrar símbolos de puzzles (M24) y templos (M26). Coherente with M73 (colección) and M24 (ruinas).

### Símbolos de runas
- Spec: símbolos de runas. Coherente with M73 (colección) and M24 (ruinas).

### Pista de puzzle como recompensa (M24)
- Spec: pista de puzzle como recompensa (M24). Coherente with M73 (colección) and M24 (ruinas).

### Testear símbolos de los 7 anillos (M26)
- Spec: testear símbolos de los 7 anillos (M26). Coherente with M73 (colección) and M26 (templos).
## Specs Coleccionables (Beam 550)

### Mensajes de correo
- Spec: mensajes de correo. Coherente with M73 (colección) and M55 (diario).

### Historia de NPC como recompensa (M20)
- Spec: historia de NPC como recompensa (M20). Coherente with M73 (colección) and M20 (diálogos).

### Registrar al leer
- Spec: registrar al leer. Coherente with M73 (colección) and M21 (historia).

### Testear mensajes repetidos (dedupe)
- Spec: testear mensajes repetidos (dedupe). Coherente with M73 (colección) and M55 (diario).

### Secretos de exploración
- Spec: secretos de exploración. Coherente with M73 (colección) and M27 (islas).
## Specs Coleccionables (Beam 551)

### Contenido oculto como recompensa (M55)
- Spec: contenido oculto como recompensa (M55). Coherente with M73 (colección) and M55 (diario).

### Objetos por capítulo
- Spec: objetos por capítulo. Coherente with M73 (colección) and M22 (historia).

### Final alterno como recompensa (M22)
- Spec: final alterno como recompensa (M22). Coherente with M73 (colección) and M22 (historia).

### Testear objetos de los 7 capítulos
- Spec: testear objetos de los 7 capítulos. Coherente with M73 (colección) and M22 (historia).

### Otorgar recompensa definida (M14/M38)
- Spec: otorgar recompensa definida (M14/M38). Coherente with M73 (colección) and M14 (recursos).
## Specs Coleccionables (Beam 552)

### Notificación especial al completar (M44)
- Spec: notificación especial al completar (M44). Coherente with M73 (colección) and M44 (UI).

### Confeti sutil por evento (M52)
- Spec: confeti sutil por evento (M52). Coherente with M73 (colección) and M52 (partículas).

### Desbloquear progresión (M71: receta M16, área, atajo M69)
- Spec: desbloquear progresión (M71: receta M16, área, atajo M69). Coherente with M73 (colección) and M71 (progresión).

### Progreso por categoría en el diario (M55)
- Spec: progreso por categoría en el diario (M55). Coherente with M73 (colección) and M55 (diario).

### % sobre lo descubierto (anti-spoiler)
- Spec: % sobre lo descubierto (anti-spoiler). Coherente with M73 (colección) and M55 (diario).
## Specs Coleccionables (Beam 553)

### Registrar logros de colección (M72)
- Spec: registrar logros de colección (M72). Coherente with M73 (colección) and M72 (logros).

### Migración de saves antiguos
- Spec: migración de saves antiguos. Coherente with M73 (colección) and M59 (guardado).

### Recolectar con inventario lleno (M14) o durante diálogo (M21, bloqueado)
- Spec: recolectar con inventario lleno (M14) o durante diálogo (M21, bloqueado). Coherente with M73 (colección) and M14 (recursos).

### Recolectar en evento (M74) e ítem de fuente borrada (fallback)
- Spec: recolectar en evento (M74) e ítem de fuente borrada (fallback). Coherente with M73 (colección) and M74 (eventos).

### Catálogo estático sin consultas por frame (M61) y sin GC pesado (M62)
- Spec: catálogo estático sin consultas por frame (M61) y sin GC pesado (M62). Coherente with M73 (colección) and M61 (rendimiento).
## Specs Coleccionables (Beam 554)

### Probar 22 categorías en estado inicial y colección con 1 faltante
- Spec: probar 22 categorías en estado inicial y colección con 1 faltante. Coherente with M73 (colección) and M112 (testing).

### Probar ciclo completo: recolectar → registrar → ver en diario → completar → recompensa
- Spec: probar ciclo completo: recolectar → registrar → ver en diario → completar → recompensa. Coherente with M73 (colección) and M55 (diario).

### Probar ciclo de guardado: recolectar → guardar → cargar → conservar
- Spec: probar ciclo de guardado: recolectar → guardar → cargar → conservar. Coherente with M73 (colección) and M59 (guardado).

### Confirmar 130 ítems exactos y plan-inicial == plan-actual
- Spec: confirmar 130 ítems exactos y plan-inicial == plan-actual. Coherente with M73 (colección) and AGENTS.md §11.

### Specs items degradados T256 (2026-10-26, Reflection-Beam-1.0)
- **L79 (testear fósiles en ruinas y montañas):** spec definida.

### Specs items degradados T057/T058/T073/T074 (2026-10-26, Reflection-Beam-1.0)
- **Semillas de temporada (L60):** spec definida — semillas de temporada para coleccionables (M15/M29).
- **Cartas de NPC (M19) (L84):** spec definida — cartas de NPC como coleccionables (M19/M73).
- **Muebles de evento (M74) (L100):** spec definida — muebles de evento (M74/M73).
- **Atuendos de NPC (M20) (L108):** spec definida — atuendos de NPC (M20/M73).
- **Mapas de exploración (L132):** spec definida — mapas de exploración (M27/M73).
- **Símbolos de runas (L140):** spec definida — símbolos de runas (M26/M73).
- **Mensajes de correo (L148):** spec definida — mensajes de correo (M21/M73).
- **Registrar al leer (L150):** spec definida — registrar al leer (M21/M73).
- **Secretos de exploración (L156):** spec definida — secretos de exploración (M27/M73).
- **Objetos por capítulo (L164):** spec definida — objetos por capítulo (M22/M73).
