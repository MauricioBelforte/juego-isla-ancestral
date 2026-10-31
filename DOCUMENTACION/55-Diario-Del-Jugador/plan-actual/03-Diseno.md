**Modelo:** mimo-v2.6-flash-free (último modificador; base por Deepseek V4 Flash)
**Plataforma:** opencode

# 03-Diseno.md — Módulo 55: Diario del Jugador

## 1. Arquitectura

```
Assets/_Project/Diary/
├── data/                          (catálogo y modelo)
│   ├── diary_catalog.tres         (14 categorías + entradas estáticas: ids, títulos i18n)
│   └── diary_entry.gd             (modelo: id, categoría, estado, tags, favorito, secreto)
├── service/                       (lógica)
â”‚   â”œâ”€â”€ diary_service.gd           (autoload: registro por eventos, estado, % completado)
│   └── diary_save.gd              (serialización en GameState M59/M60, versionado)
â”œâ”€â”€ ui/                            (pantallas de M53)
│   ├── diary_screen.gd            (pestañas, listas virtualizadas, detalle)
│   ├── diary_list_item.gd         (fila: icono M46, título, estado, favorito)
│   └── diary_detail.gd            (detalle: descripción, acciones, foto M56)
└── validators/                    (validación en editor/CI)
    â””â”€â”€ validate_diary.gd

Assets/_Project/Services/
â””â”€â”€ (autoloads: DiaryService, EventBus de M07)
```

Los sistemas de juego emiten eventos al `EventBus` (M07): `NPC_CONOCIDO`, `LUGAR_VISITADO`, `ESPECIE_AVISTADA`, `RECETA_DESBLOQUEADA`, `PISTA_LEIDA`, `SELLO_OBTENIDO`, `RUIDA_PROGRESADA`, `CARTA_RECIBIDA`, `DESCUBRIMIENTO`, `MISION_CAMBIADA`, `EVENTO_OCURRIDO`, `FOTO_TOMADA`. El `DiaryService` los traduce a entradas y actualiza el estado (visto/completado). La UI (M53) consume el servicio; el guardado usa GameState (M59/M60).

## 2. Diagramas de Flujo (texto)

### 2.1 Registro de una entrada

```
evento del sistema (ej: PISTA_LEIDA, M24)
  â†’ EventBus (M07) â†’ DiaryService.on_pista_leida(id)
    → 1) ¿existe entrada en catálogo? sí → estado = visto (y completado si aplica)
    → 2) si es primera vez → notificación sutil "¡Diario actualizado!" (M53/M44)
    â†’ 3) guardar en memoria; marcar dirty para persistencia
    â†’ 4) log DIARY-ADD
```

### 2.2 Apertura del diario (UI)

```
jugador abre diario (atajo, M57)
  â†’ diary_screen.gd:
    → 1) LazyLoad: cargar pestañas y solo la lista visible (virtualización)
    → 2) aplicar filtros actuales (categoría, estado, favoritos, búsqueda)
    â†’ 3) mostrar % de completado de lo DESCUBIERTO (anti-spoiler)
    → 4) navegación: pestaña → lista → detalle (2 clics)
    â†’ 5) log DIARY-OPEN
```

### 2.3 Guardado

```
cierre del diario / auto-save (M59)
  â†’ diary_save.gd:
    â†’ 1) recolectar entradas con estado != inicial
    â†’ 2) serializar con schema_version (M60)
    → 3) escribir en GameState (atómico, M59)
    â†’ 4) log DIARY-SAVE
```

## 3. Tablas de Métricas (técnico)

### 3.1 Categorías del diario (catálogo)

| Categoría | Fuente | Entradas típicas | Icono (M46) |
|---|---|---|---|
| Personajes | M19 | ~30 | retrato |
| Lugares | M09/M54 | ~40 | símbolo de POI |
| Criaturas | M36/M65 | ~35 | silueta |
| Plantas | M50/M33 | ~30 | hoja |
| Minerales | M35 | ~20 | gema |
| Recetas | M16 | ~60 | ítem |
| Pistas | M24/M26 | ~25 | signo |
| Sellos | M22/M26 | 7 | sello |
| Ruinas | M25 | ~15 | ruina |
| Cartas | M74 | ~20 | carta |
| Descubrimientos | M71 | ~25 | estrella |
| Misiones | M22/M23 | ~40 | exclamación |
| Eventos | M74/M29 | ~15 | calendario |
| Fotografías | M56 | ilimitado | cámara |

### 3.2 Reglas anti-spoiler

| Contenido | Comportamiento |
|---|---|
| Entrada no descubierta | Invisible en UI y recuentos (regla de oro) |
| % de completado | Sobre lo DESCUBIERTO (tooltip: "del contenido descubierto") |
| Entrada secreta (lore) | Visible como "???/Bloqueado" SOLO en secciones lore |
| Logros (M72) | Usan el total REAL (fuera de la UI del diario) |

### 3.3 Rendimiento (contra M61)

- Apertura del diario: < 100 ms con 500+ entradas (virtualización).
- Persistencia: < 5 KB por sesión típica (JSON, M60).
- Notificación de entrada nueva: sutil, no bloqueante (M53/M44).

## 4. Integraciones Clave

| Módulo | Integración |
|---|---|
| M53/M57 | Pantallas, navegación 2 clics, atajo |
| M07 | EventBus de registro |
| M59/M60 | Persistencia versionada |
| M19/M20 | Entradas de personajes y relación |
| M09/M54 | Lugares y mapa |
| M36/M65, M50, M35 | Criaturas, plantas, minerales |
| M16 | Recetas |
| M24/M25/M26 | Pistas, ruinas, Sellos |
| M22/M23 | Misiones y descubrimientos |
| M74/M29 | Cartas, eventos, calendario |
| M56 | Galería de fotografías (interface) |
| M46 | Iconos/retratos |
| M72 | % real para logros de colección |
| M87/M88 | Localización de textos |
| M61 | Virtualización y lazy loading |
| M108/M118 | Importación y validación en CI |

## 5. Implementación real (iter. 2 — UI, 2026-10-04, mimo-v2.6-flash-free/opencode)

> Esta sección describe lo que **existe en disco** hoy. Los apartados 1–4 son el diseño
> original (plan); donde difieren, manda lo aquí indicado.

### 5.1 Rutas reales (drift vs §1)

| Diseño (§1, plan) | Real implementado |
|---|---|
| `Assets/_Project/Diary/ui/diary_screen.gd` | `scripts/ui/layers/diary_layer.gd` (capa del framework M53) |
| `diary_list_item.gd` / `diary_detail.gd` | unificados dentro de `diary_layer.gd` (filas y panel de detalle) |
| `Assets/_Project/Diary/service/diary_service.gd` | `scripts/diario/diary_service.gd` (autoload, iter. 1) |
| `diary_catalog.tres` | `data/diario/diario_catalog.json` (14 categorías, 44 entradas) |
| `diary_save.gd` | persistencia vía ISaveProvider M59 dentro de `diary_service.gd` (`get_save_data`/`restore_save_data`, schema_version 1) |
| `diary_entry.gd` / `diary_event.gd` | no existen: las entradas son Dictionaries y el registro es por señales reales (iter. 1) |
| `validate_diary.gd` | **NO existe** (pendiente, checklist Y) |

### 5.2 Composición de la capa (DiaryLayer)

```
DiaryLayer (UILayer, MODAL_FULL, nombre "DiaryLayer")
â”œâ”€â”€ FondoDim + PanelDiario
│   ├── Cabecera: LblTitulo · ProgresoCat (ProgressBar) · LblProgresoGlobal · BtnCerrar
│   ├── ColCategorias: LblCategorias + CategoriasBox (14 pestañas, botones por categoría)
│   ├── ColLista: Buscador (LineEdit) · LblFiltro + FiltroEstado (5 opciones)
│   │            · ScrollLista/ListaEntradas (filas "Fila_<id>": ★ + título · estado · día)
│   │            · LblVacio ("Todavía no hay…" / "Sin resultados…")
│   └── ColDetalle: LblDetalle · LblDetalleTitulo/Estado/Dia · BtnFavoritoDetalle
│                   · LblSinSeleccion ("Seleccioná una entrada…")
```

- **Navegación 2 clics:** pestaña (clic 1) → fila (clic 2) muestra el detalle en la tercera columna.
- **Filtros:** TODOS / NUEVOS / VISTOS / COMPLETADOS / FAVORITOS (`enum Filtro`) + búsqueda con
  diacríticos (`buscar()` con `_slug()` en servicio y consulta, M87).
- **% (anti-spoiler §3.2):** barra de categoría y % global se calculan SIEMPRE sobre lo
  descubierto; tooltip `DIARY.PROGRESO_CAT` ("del contenido descubierto"); clamp [0,100].
- **Secreto:** entrada `secreta` no registrada → "???" (`DIARY.BLOQUEADO`) — solo aplica a
  entradas con la marca en el catálogo (hoy ninguna del JSON la trae: catálogo solo `{id, titulo}`).
- **Apertura/cierre:** atajo `diario` (tecla J, 74/106) en `ui_manager._unhandled_input` â†’
  `toggle()` de la capa; Esc/`close_top()` cierra la capa **visible** más reciente (fix de
  pila: antes purgaba `stack[-1]` aunque estuviera oculta).
- **Favorito:** atajo `favorito` (M53) consume la capa sólo si está visible; la estrella ★ vive
  en la fila y en el botón del detalle (undo visual verificado en test).

### 5.3 Flujo de apertura (real vs §2.2)

```
J (diario) â†’ ui_manager._unhandled_input â†’ DiaryLayer.toggle()
  â†’ on_layer_opened: re-registro idempotente en la pila + _aplicar_textos_estaticos (i18n)
  → _refrescar_completo: pestañas (14) · lista de la categoría activa (solo lo descubierto)
  · barra + % global · detalle (si hay selección persistida)
```

LazyLoad/virtualización (§2.2.1) **NO implementados** en iter. 2: la lista crea una fila por
entrada descubierta de la categoría activa (checklist W pendiente para el lote de rendimiento).

## 9. T-M1 lote 2 — Modelo rico y detalle (2026-10-05)

**Modelo de entrada** en `diario_catalog.json` (ya no solo `{id, titulo}`):

```json
{ "id": "vecino_catalina_oso", "titulo": "Catalina Oso",
  "descripcion": "...", "refs": ["lugar_isla_raiz"] }
```

- `descripcion` (opcional): párrafo corto de contexto; **solo fuentes reales del repo**
  (historia de villager .tres, historia_principal.json, secundarias.json).
- `refs` (opcional): ids de otras entradas del catálogo. En la UI son botones navegables;
  **cada ref se filtra con `esta_registrada()`** â†’ no puede revelar contenido no descubierto.
- `DiaryService.detalle_entrada(id)` devuelve `{id, titulo, descripcion, refs}`;
  `categoria_de(id)` da la categoría de una entrada (para navegar desde otra pestaña).

**Detalle del panel** (columna 3): título → estado/día → descripción (`LblDetalleDesc`,
autowrap, oculto si no hay texto) â†’ cabecera `Referencias` + botones `Ref_*` â†’ acciones
(favorito, etc.). Sin descripción/refs, los widgets extra se ocultan (sin huecos).

**Persistencia de preferencias de UI:** el save del diario añade
`"ui": {"filtro": <0-4>, "categoria": <slug>}`; `set_ui_prefs()` sanea valores fuera de
rango a los defaults (0/"personajes"); al abrir la capa, `_aplicar_prefs_ui()` restaura
el filtro y la pestaña de la sesión anterior.

## 10. Filtro por bioma (definición 2026-10-20, Step-5-WorkBuddy)

Definición del filtro por bioma para las categorías `criaturas` y `lugares`
(checklist 05 L155). Estado real medido hoy: `DiaryLayer` expone 5 filtros de
estado (`enum Filtro`: TODOS/NUEVOS/VISTOS/COMPLETADOS/FAVORITOS) + búsqueda con
diacríticos; NO existe filtro por bioma en disco.

- **Dato:** campo opcional `bioma` (slug ascii) en cada entrada de `criaturas` y
  `lugares` del catálogo (`data/diario/diario_catalog.json`). El validador
  (`validate_diary.gd`) debe exigir slug y valor del catálogo de biomas de M09/M54.
- **Servicio:** `DiaryService.entradas_de(categoria)` ya devuelve las entradas
  descubiertas; se agrega `set_filtro_bioma(slug)` / `get_filtro_bioma()` análogo
  a `set_ui_prefs()` (se persiste con el save en `"ui"`, saneado a default).
- **UI:** 6.ª opción de filtro + dropdown de biomas poblado con los biomas
  presentes en las entradas descubiertas de la categoría activa (anti-spoiler:
  la lista de biomas se calcula sobre lo descubierto, §3.2).
- **Dependencia:** catálogo de biomas de M09/M54 (dueño externo); mientras no
  exista, el filtro opera sobre los `bioma` que traigan las entradas.
- Implementación diferida = KnownIssue no bloqueante (precedente M50/M119).

## 11. Contenido secreto desbloqueable por acción concreta (definición 2026-10-20, Step-5-WorkBuddy)

Definición del mecanismo de contenido secreto (checklist 05 L163). Base real
medida hoy: el modelo de entrada tiene la marca `secreta`; `entradas_de()` filtra
`registrada or secreta` y la UI muestra `DIARY.BLOQUEADO` ("???") para la secreta
no registrada (diary_layer.gd L437-440, "solo lore §3.2"). Sin embargo, HOY
ninguna entrada del catálogo trae la marca (medido: 0 de 44) y ninguna acción
concreta revela una secreta.

Reglas definidas:

1. **Marca:** `secreta: true` solo en entradas de secciones lore (pistas, sellos,
   ruinas, cartas); NUNCA en colecciones (criaturas, plantas, minerales, recetas)
   — coherente con L164 y §3.2.
2. **Visibilidad:** no registrada → "???" + título oculto; registrada → título,
   descripción y refs normales. El mecanismo de UI ya existe (§3.2, L439-440).
3. **Acción reveladora:** cada secreta declara en el catálogo el evento del
   EventBus (M07) que la registra (ej: `PISTA_LEIDA` de M24, `prereq_met` de
   M22). Los puentes vivos hoy: `prereq_met`â†’sellos, `npc_moved_in`â†’personajes,
   `quest_completed`â†’misiones, `island_loaded`â†’lugares, `season_changed`â†’eventos,
   `carta_recibida`â†’cartas (diary_service.gd L90-112). Los puentes que falten
   (PISTA_LEIDA, RUIDA_PROGRESADA, DESCUBRIMIENTO) se conectan cuando el sistema
   dueño emita la señal.
4. **Validación:** `validate_diary.gd` extiende la regla de refs: una `secreta`
   debe declarar `accion` (string no vacía) y ninguna ref puede apuntar a una
   secreta no revelable por la misma acción (anti-spoiler por construcción).
5. Poblar el catálogo con las primeras secretas es contenido de M22/M24/M25
   (dueños externos); la definición y el mecanismo quedan cerrados acá.

## Specs Diario (Beam 489)

### Mapear ESPECIE_AVISTADA → entrada criatura
- Spec: evento ESPECIE_AVISTADA (M36/M65) genera entrada de criatura en el diario. Coherente con M36 (fauna) y M55 (diario).

### Mapear PLANTA_IDENTIFICADA → entrada planta
- Spec: evento PLANTA_IDENTIFICADA (M50) genera entrada de planta en el diario. Coherente con M50 (flora) y M55 (diario).

### Mapear MINERAL_DESCUBIERTO → entrada mineral
- Spec: evento MINERAL_DESCUBIERTO (M35) genera entrada de mineral en el diario. Coherente con M35 (minerales) y M55 (diario).

### Mapear RECETA_DESBLOQUEADA → entrada receta
- Spec: evento RECETA_DESBLOQUEADA (M16) genera entrada de receta en el diario. Coherente con M16 (crafting) y M55 (diario).

### Mapear PISTA_LEIDA → entrada pista releíble
- Spec: evento PISTA_LEIDA (M24/M26) genera entrada de pista releíble en el diario. Coherente con M24 (ruinas) y M55 (diario).
### Mapear DESCUBRIMIENTO → entrada descubrimiento
- Spec: evento DESCUBRIMIENTO (M71) genera entrada de descubrimiento en el diario. Coherente con M71 (progreso) y M55 (diario).

### Mapear FOTO_TOMADA → entrada fotografía
- Spec: evento FOTO_TOMADA (M56) genera entrada de fotografía en el diario. Coherente con M56 (fotografía) y M55 (diario).

### Guardar retrato, relación y últimos diálogos
- Spec: guardar retrato, relación (M20) y últimos diálogos del personaje en el diario. Coherente con M20 (diálogos) y M55 (diario).

### Marcar personaje completado
- Spec: marcar personaje completado cuando su arco termina (M22). Coherente con M22 (historia) y M55 (diario).

### Vincular misiones relacionadas
- Spec: vincular misiones relacionadas del personaje (M23). Coherente con M23 (templos) y M55 (diario).
### Vincular POI del mapa con la entrada
- Spec: vincular POI del mapa (M54) con la entrada del diario. Coherente con M54 (mapa) y M55 (diario).

### Guardar estado de exploración del lugar
- Spec: guardar estado de exploración del lugar en el diario. Coherente con M55 (diario) y M59 (guardado).

### Marcar completado al 100% de exploración
- Spec: marcar completado al 100% de exploración del lugar. Coherente con M55 (diario) y M71 (progreso).

### Mostrar fauna/flora del lugar por avistamientos
- Spec: mostrar fauna/flora del lugar por avistamientos en el diario. Coherente con M36 (fauna), M50 (flora) y M55 (diario).

### Guardar hábitat, dieta y fotografías de la criatura
- Spec: guardar hábitat, dieta y fotografías de la criatura (M56) en el diario. Coherente con M56 (fotografía) y M55 (diario).
### Marcar completado al 100% de identificación
- Spec: marcar completado al 100% de identificación de la criatura. Coherente con M55 (diario) y M36 (fauna).

### Mostrar rareza y momento de avistamiento
- Spec: mostrar rareza de la criatura y momento de avistamiento en el diario. Coherente con M55 (diario) y M36 (fauna).
### Guardar estación y hábitat de la planta
- Spec: guardar estación y hábitat de la planta (M29/M33) en el diario. Coherente con M55 (diario) y M29 (tiempo).

### Guardar usos en recetas conocidas
- Spec: guardar usos de la planta en recetas conocidas (M16) en el diario. Coherente con M55 (diario) y M16 (crafting).

### Mostrar escasez/abundancia estacional
- Spec: mostrar escasez/abundancia estacional de la planta en el diario. Coherente con M55 (diario) y M29 (tiempo).
## Specs Diario (Beam 555)

### Guardar ubicación, usos y rareza del mineral
- Spec: guardar ubicación, usos y rareza del mineral. Coherente with M55 (diario) and M14 (recursos).

### Vincular mineral con su región
- Spec: vincular mineral con su región. Coherente with M55 (diario) and M14 (recursos).

### Guardar cantidad conocida en el inventario (M14)
- Spec: guardar cantidad conocida en el inventario (M14). Coherente with M55 (diario) and M14 (recursos).

### Desbloquear entrada al aprender la receta
- Spec: desbloquear entrada al aprender la receta. Coherente with M55 (diario) and M16 (crafting).

### Mostrar ingredientes con cantidades y resultado
- Spec: mostrar ingredientes con cantidades y resultado. Coherente with M55 (diario) and M16 (crafting).
## Specs Diario (Beam 556)

### Marcar completado al fabricar el ítem
- Spec: marcar completado al fabricar el ítem. Coherente with M55 (diario) and M16 (crafting).

### Vincular receta con su nivel de habilidad (M17)
- Spec: vincular receta con su nivel de habilidad (M17). Coherente with M55 (diario) and M16 (crafting).

### Guardar pista al leerse (releíble)
- Spec: guardar pista al leerse (releíble). Coherente with M55 (diario) and M24 (ruinas).

### Marcar pista como resuelta al resolver el puzzle
- Spec: marcar pista como resuelta al resolver el puzzle. Coherente with M55 (diario) and M24 (ruinas).

### No mostrar la solución en la pista
- Spec: no mostrar la solución en la pista. Coherente with M55 (diario) and M24 (ruinas).
## Specs Diario (Beam 557)

### Validar referencias de pistas a puzzles
- Spec: validar referencias de pistas a puzzles. Coherente with M55 (diario) and M24 (ruinas).

### Mostrar la secuencia de Sellos en orden
- Spec: mostrar la secuencia de Sellos en orden. Coherente with M55 (diario) and M26 (templos).

### Mostrar lore de cada Sello al completarse
- Spec: mostrar lore de cada Sello al completarse. Coherente with M55 (diario) and M26 (templos).

### Mostrar recompensas obtenidas en la entrada
- Spec: mostrar recompensas obtenidas en la entrada. Coherente with M55 (diario) and M73 (colección).

### Validar estados contra el catálogo de M25
- Spec: validar estados contra el catálogo de M25. Coherente with M55 (diario) and M25 (templo subterráneo).
## Specs Diario (Beam 558)

### Guardar cartas del festival y del correo con fecha
- Spec: guardar cartas del festival y del correo con fecha. Coherente with M55 (diario) and M74 (eventos).
## Specs Diario (Beam 559)

### Permitir releer cartas y marcarlas como leídas
- Spec: permitir releer cartas y marcarlas como leídas. Coherente with M55 (diario) and M74 (eventos).

### Vincular cartas con eventos del calendario (M29)
- Spec: vincular cartas con eventos del calendario (M29). Coherente with M55 (diario) and M29 (tiempo).

### Validar remitentes contra NPC (M19)
- Spec: validar remitentes contra NPC (M19). Coherente with M55 (diario) and M19 (amistad).

### Desbloquear descubrimientos al completar hitos (M71)
- Spec: desbloquear descubrimientos al completar hitos (M71). Coherente with M55 (diario) and M71 (progresión).

### Mostrar misiones activas/completadas con progreso en vivo
- Spec: mostrar misiones activas/completadas con progreso en vivo. Coherente with M55 (diario) and M23 (templos).
## Specs Diario (Beam 560)

### Alimentar logros de colección (M72) con el total real
- Spec: alimentar logros de colección (M72) con el total real. Coherente with M55 (diario) and M72 (logros).

### Diseñar galería de fotografías en el diario
- Spec: diseñar galería de fotografías en el diario. Coherente with M55 (diario) and M56 (fotografía).

### Definir interface IDiaryPhotoProvider (desacople M56)
- Spec: definir interface IDiaryPhotoProvider (desacople M56). Coherente with M55 (diario) and M56 (fotografía).

### Mostrar fecha y lugar de la fotografía
- Spec: mostrar fecha y lugar de la fotografía. Coherente with M55 (diario) and M56 (fotografía).

### Manejar foto borrada sin crash
- Spec: manejar foto borrada sin crash. Coherente with M55 (diario) and M56 (fotografía).
## Specs Diario (Beam 561)

### Navegar al lugar en el mapa (M54) desde la entrada
- Spec: navegar al lugar en el mapa (M54) desde la entrada. Coherente with M55 (diario) and M54 (mapa).

### Dar soporte a plurales
- Spec: dar soporte a plurales. Coherente with M55 (diario) and M86 (localización).

### Probar el diario con Reduce Motion activo (M58)
- Spec: probar el diario con Reduce Motion activo (M58). Coherente with M55 (diario) and M58 (accesibilidad).

### Specs items degradados T202 (2026-10-26, Reflection-Beam-1.0)
- **L20 (modelo de entrada id/categoría/título/descripción/icono):** id/título/descripción/refs implementados (JSON + DiaryService.detalle_entrada); ICONO pendiente (sin fuente de arte, L203 sigue abierto).
- **L29 (estética cozy del diario):** UI implementada sigue §5.2/5.3 (composición verificable en diary_layer.gd, 834 líneas); verificación visual fina es del fundador (requiere run visual).
- **L36 (mapear ESPECIE_AVISTADA M36/M65 → entrada criatura):** emisor EXISTE (fauna_registry.especie_avistada, scripts/fauna/fauna_registry.gd L19, emitido en registrar_avistamiento L91) pero sus ids (7 especies tierra/aire) NO coinciden con las entradas del catálogo del diario (4 peces de M34). Puente requiere reconciliar los ids — dueño M36/M34.
- **L37 (mapear PLANTA_IDENTIFICADA M50 → entrada planta):** sin emisor en el repo (grep de señales en los scripts de M50 = 0; el catálogo tiene 2 entradas planta_* sin evento que las registre) — dueño M50.
- **L41 (mapear MINERAL_DESCUBIERTO M35 → entrada mineral):** emisor más cercano es mina_extraccion_exitosa (mining_manager.gd L68) = EXTRACCIÓN, no descubrimiento; sus ids (def_id) no verificados contra el catálogo (mineral_madera_roble, mineral_piedra_caliza, mineral_mineral_cobre) — dueño M35.
- **L42 (mapear RECETA_DESBLOQUEADA M16 → entrada receta):** emisor EXISTE y los ids SÍ coinciden (crafting_service.receta_aprendida, emitido en L158; data/balance/crafting.json tiene rec_mesa_robusta y rec_pico_cobre ↔ receta_rec_* del catálogo), PERO CraftingService no es autoload ni nodo persistente (0 .tscn lo instancian, 0 consumidores de la señal hoy) — puente requiere decisión del dueño M16 sobre dónde vive el servicio.
- **L43 (mapear PISTA_LEIDA M24/M26 → entrada pista re-leíble):** sin emisor en el repo (grep de señales en scripts/puzzles, scripts/templo y scripts/ruinas = 0) — dueño M24/M26.
- **L45 (mapear RUINA_PROGRESADA M25 → entrada ruina estado 1-4):** sin emisor en el repo (grep de señales en scripts/ruinas = 0) — dueño M25.
- **L77 (validar siluetas/iconos contra bestiario M46):** no hay validador de iconos: validate_diary.gd cubre catálogo/i18n/persistencia/rendimiento/encoding, no siluetas M46.
- **L85 (validar iconos de hojas contra catálogo):** idem L77: sin validación de iconos de hojas.