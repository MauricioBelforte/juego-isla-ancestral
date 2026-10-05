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
│   ├── diary_service.gd           (autoload: registro por eventos, estado, % completado)
│   └── diary_save.gd              (serialización en GameState M59/M60, versionado)
├── ui/                            (pantallas de M53)
│   ├── diary_screen.gd            (pestañas, listas virtualizadas, detalle)
│   ├── diary_list_item.gd         (fila: icono M46, título, estado, favorito)
│   └── diary_detail.gd            (detalle: descripción, acciones, foto M56)
└── validators/                    (validación en editor/CI)
    └── validate_diary.gd

Assets/_Project/Services/
└── (autoloads: DiaryService, EventBus de M07)
```

Los sistemas de juego emiten eventos al `EventBus` (M07): `NPC_CONOCIDO`, `LUGAR_VISITADO`, `ESPECIE_AVISTADA`, `RECETA_DESBLOQUEADA`, `PISTA_LEIDA`, `SELLO_OBTENIDO`, `RUIDA_PROGRESADA`, `CARTA_RECIBIDA`, `DESCUBRIMIENTO`, `MISION_CAMBIADA`, `EVENTO_OCURRIDO`, `FOTO_TOMADA`. El `DiaryService` los traduce a entradas y actualiza el estado (visto/completado). La UI (M53) consume el servicio; el guardado usa GameState (M59/M60).

## 2. Diagramas de Flujo (texto)

### 2.1 Registro de una entrada

```
evento del sistema (ej: PISTA_LEIDA, M24)
  → EventBus (M07) → DiaryService.on_pista_leida(id)
    → 1) ¿existe entrada en catálogo? sí → estado = visto (y completado si aplica)
    → 2) si es primera vez → notificación sutil "¡Diario actualizado!" (M53/M44)
    → 3) guardar en memoria; marcar dirty para persistencia
    → 4) log DIARY-ADD
```

### 2.2 Apertura del diario (UI)

```
jugador abre diario (atajo, M57)
  → diary_screen.gd:
    → 1) LazyLoad: cargar pestañas y solo la lista visible (virtualización)
    → 2) aplicar filtros actuales (categoría, estado, favoritos, búsqueda)
    → 3) mostrar % de completado de lo DESCUBIERTO (anti-spoiler)
    → 4) navegación: pestaña → lista → detalle (2 clics)
    → 5) log DIARY-OPEN
```

### 2.3 Guardado

```
cierre del diario / auto-save (M59)
  → diary_save.gd:
    → 1) recolectar entradas con estado != inicial
    → 2) serializar con schema_version (M60)
    → 3) escribir en GameState (atómico, M59)
    → 4) log DIARY-SAVE
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
├── FondoDim + PanelDiario
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
- **Apertura/cierre:** atajo `diario` (tecla J, 74/106) en `ui_manager._unhandled_input` →
  `toggle()` de la capa; Esc/`close_top()` cierra la capa **visible** más reciente (fix de
  pila: antes purgaba `stack[-1]` aunque estuviera oculta).
- **Favorito:** atajo `favorito` (M53) consume la capa sólo si está visible; la estrella ★ vive
  en la fila y en el botón del detalle (undo visual verificado en test).

### 5.3 Flujo de apertura (real vs §2.2)

```
J (diario) → ui_manager._unhandled_input → DiaryLayer.toggle()
  → on_layer_opened: re-registro idempotente en la pila + _aplicar_textos_estaticos (i18n)
  → _refrescar_completo: pestañas (14) · lista de la categoría activa (solo lo descubierto)
  · barra + % global · detalle (si hay selección persistida)
```

LazyLoad/virtualización (§2.2.1) **NO implementados** en iter. 2: la lista crea una fila por
entrada descubierta de la categoría activa (checklist W pendiente para el lote de rendimiento).