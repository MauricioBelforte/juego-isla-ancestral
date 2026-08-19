**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 73: Coleccionables

## 1. Arquitectura

```
Assets/_Project/Collectibles/
├── data/
│   ├── collectible_item.gd        (modelo: id, categoría, nombre i18n, icono M46, fuente, recompensa)
│   ├── collectible_category.gd    (modelo: id, nombre i18n, total, recompensa de colección)
│   └── collectibles_catalog.tres  (catálogo central: 22 categorías, ~500 ítems)
├── service/
│   ├── collectible_service.gd     (autoload: registro idempotente, progreso, colecciones completas)
│   └── collectible_save.gd        (persistencia compacta en GameState M59/M60)
├── ui/
│   ├── collection_view.gd         (vista en diario M55: progreso por categoría)
│   └── collection_reward.gd       (notificación de colección completada M44)
└── validators/
    └── validate_collectibles.gd   (ids únicos, totales, recompensas, i18n, persistencia)
```

`CollectibleService` (autoload) escucha los eventos de recolección (M07) y marca `collected`; expone progreso y eventos de completado a M55 (diario), M37 (museo), M72 (logros) y M71 (desbloqueos). El catálogo es estático; el estado (ids marcados) persiste en GameState (M59/M60) como lista compacta versionada.

## 2. Diagramas de Flujo (texto)

### 2.1 Registro de un coleccionable

```
evento de recolección (M07: ITEM_COLLECTED, FISH_CAUGHT, MINERAL_MINED...)
  → CollectibleService.mark_collected(id):
    → 1) id existe en catálogo? no → ignorar (log COLL-WARN)
    → 2) ya estaba marcado? sí → ignorar (idempotente, sin duplicados)
    → 3) marcar collected=true; registrar en estado (dirty para M59)
    → 4) notificación sutil "¡Nuevo coleccionable!" (M44)
    → 5) si la categoría quedó completa → COLELECTION_COMPLETED (M07)
    → 6) log COLL-ADD
```

### 2.2 Colección completada

```
categoría llega a total
  → CollectibleService._on_category_complete(category):
    → 1) marcar categoría completa (estado)
    → 2) otorgar recompensa: ítem (M14) o dinero (M38)
    → 3) notificación especial (M44) + confeti sutil (M52)
    → 4) desbloquear progresión (M71): receta (M16), área, atajo (M69)
    → 5) logro (M72) vía evento
    → 6) log COLL-COMPLETE
```

### 2.3 Persistencia

```
auto-save (M59) / cierre
  → collectible_save.gd:
    → 1) serializar ids marcados (bitset/lista compacta, M60)
    → 2) guardar con schema_version (migración M60)
    → 3) log COLL-SAVE
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