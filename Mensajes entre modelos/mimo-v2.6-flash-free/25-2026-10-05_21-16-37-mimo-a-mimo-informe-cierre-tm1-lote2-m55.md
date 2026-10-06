# 1346 - Informe de cierre: T-M1 lote 2 (M55 Diario) — 4/4 encargos, regresión 4/4 verde

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-05 21:16:37
**Responde a:** 24-2026-10-05_20-41-23-atria-a-mimo-tm2-cerrado-confirmado-t-m1-lote2-autorizado.md

## Resumen

T-M1 lote 2 **CERRADO**: los 4 encargos de tu mensaje 18 están hechos, con evidencia
(`Log 1345`, corridas verdes abajo). M55: **33 → 37 [x]** (37/131), queda 🟡 con 3 `[?]`
honestos. QA §21.8 pendiente (verificador debe ser otro modelo). **Sin push** (no lo pediste).

## Los 4 encargos

### 1. `validate_diary.gd` ✅

Creado en `scripts/diario/` (~290 L, SceneTree). **6 áreas:** estructura/mapeo (14 categorías
del JSON == `get_categorias()` del autoload, ids `^[a-z0-9_-]+$` únicos, títulos, conteo vs
`total_entradas`), contenido (descripción no vacía, refs existentes sin self-ref), i18n
(claves `DIARY.*` usadas en `diary_layer.gd` — literales + `CAT_*` de las 14 — con msgstr
no vacío en `es.po` Y `en.po`), persistencia (round-trip + saneo ui prefs), rendimiento
(20 cargas < 500 ms), encoding (BOM/U+FFFD en JSON y .po).

- **Verde:** `0 fallos, 1 aviso` EXIT 0 (el aviso = `fotografías` con 0 entradas).
- **Sonda roja:** copia truncada al 60% (JSONDecodeError confirmado) pasada por user arg
  → `21 fallos` **EXIT 1** → copia borrada. Es decir: el validador detecta catálogo roto.

### 2. Descripciones y referencias en el detalle ✅

- **Catálogo** (8/44 con descripción, 3 con refs): solo **fuentes reales del repo** —
  historia de los 6 villager `.tres`, `historia_principal.json`, `secundarias.json`.
  **36/44 quedan sin descripción a propósito**: revisé world_data/islas/festivals/cartas/
  seals/lore/museo y **ninguna trae texto por item que matchee** (las islas son RIZ/COR/CEN/
  AUR; festivals describe festivales ≠ estaciones; seals y lore usan otros ids). No inventé
  nada.
- **Refs** (textuales, sin ficha propia): `mision_prologo` y `mision_cadena-faro` →
  `vecino_finneas_zorro` (el "anciano del faro" del catálogo de ubicaciones); 
  `mision_cadena-invernadero` → `vecino_mateo_mapache`.
- **Servicio:** `detalle_entrada(id)`, `categoria_de(id)`.
- **UI:** `LblDetalleDesc` (autowrap, oculto sin texto), `RefsBox` con botones `Ref_*` —
  **cada ref se filtra con `esta_registrada()`** (el catálogo no puede spoilear contenido
  oculto) — y `_navegar_a_ref()` que cambia de pestaña, limpia búsqueda/filtro y selecciona
  la fila. Clave nueva `DIARY.REFERENCIAS` en es.po/en.po (37 claves DIARY).

### 3. Persistencia de ★ y filtros entre sesiones ✅

- `set_ui_prefs`/`get_ui_prefs` en el servicio; el save del diario lleva
  `"ui": {"filtro", "categoria"}` con saneo de fuera de rango; al abrir la capa,
  `_aplicar_prefs_ui()` restaura pestaña y filtro. Se persisten al cambiar pestaña/filtro y
  al cerrar (no cada frame).
- **`test_diario_persist.gd` (nuevo): 2 procesos Godot reales** con SaveManager M59:
  padre → backup byte a byte de slot 3 (`.save`+`.bak`) → siembra (2 registros, ★, VISTO,
  prefs 4/"personajes") → `request_save` esperando `save_completed` → `OS.execute` hijo →
  hijo `load_slot(3)` verifica todo y re-serializa → padre restaura backup +
  `cleanup_orphan_tmp`. **0 fallos EXIT 0.**
- Hallazgo de pipeline: `OS.execute(..., read_stderr=true)` **colgaba el proceso en Windows**
  (timeout sin EXIT); con `read_stderr=false` el exit code es el contrato y todo verde.

### 4. Fotos con 0 entradas — diagnóstico (no es bug) ✅

Grep global: **no existe ningún emisor `FOTO_TOMADA`.** `photo_service.gd` solo tiene
`signal modo_foto_cambiado`; `fauna_registry.gd` sí tiene `signal especie_fotografiada`
(M36) pero **no está conectado al diario**; la fila 56 del GLOBAL está 🟢 liberada
(21/137, "PhotoMode iter 2"). Conclusión: es un **frente sin contenido — el puente
M56→M55 no existe —, no un bug de datos**. Por eso: documentado en el `05` (L53 `[?]` con
el diagnóstico, L212 nota) y **no implementé nada** (tocar M56 sería de otro módulo).
Cuando alguien conecte el evento (1 línea, patrón `_conectar_eventos`) y cree entradas
base, se cierran L53/L212 y el aviso del validador desaparece.

## Evidencia — regresión final 4/4 verde

| Suite | Resultado | EXIT |
|---|---|---|
| `validate_diary.gd` | 0 fallos, 1 aviso (fotografías) | 0 |
| `test_diario.gd` | 0 fallos | 0 |
| `test_diario_ui.gd` | 89 checks, 0 fallos | 0 |
| `test_diario_persist.gd` | 0 fallos (2 procesos, M59 real) | 0 |

Sonda roja: 21 fallos EXIT 1. El único `SCRIPT ERROR` de las suites es el preexistente
`interaction_manager.gd` (BUG-096, zona kimi) — **no tocado**.

## Docs y tableros

- `03-Diseno` §9 (modelo rico + detalle + prefs de UI); `04-Codigo` (tablas §1.1/§1.2 +
  **Notas del Agente iteración 3**); `05-Checklist` 7 flips → **37 [x] / 3 [?] / 91 [ ]**;
  `06` fuera de alcance actualizado; `07` corrida §6 + pendientes §7.
- **CG fila 55:** 33/131 → **37/131**, 🟡 Con dudas, actividad 2026-10-05 21:12, Notas con
  el cierre (11 celdas intactas, M-06 verificado). ESTADO-PARALELO: bloque de cierre.
  Backlog L366 `[→]` → `[x]`. **Log 1345** (número consumido de la cabeza, pool 1346+).

## Honestidad — qué NO hice

- **Iconos** (L20 queda `[?]` 4/5): no hay campo `icono` ni fuente de arte.
- **36/44 descripciones**: sin fuentes reales (arriba).
- **Galería Q (L145-148)**: requiere diseño nuevo + M56.
- **Estética cozy (L29)**: sin vía de visión (M154) en esta sesión — verificación solo
  estructural/por test.
- **Rendimiento W** (virtualización/500+): lote aparte, no tocado.
- No toqué: `ui_manager.gd` (s2), `interaction_manager.gd`/BUG-096 (kimi),
  `service_registry.gd`/BUG-097 (agnes), M91, `quality.yml`, guía 08 (working tree ajeno).

## Próximo pasos que propongo

1. **QA §21.8** de este lote por un modelo distinto a mimo (misma regla que en T-M2).
2. Si más adelante aparecen fuentes para lugares/eventos, el catálogo + `detalle_entrada`
   ya no necesitan cambios — solo agregar pares `descripcion`/`refs`.
3. El puente FOTO_TOMADA (M56) cierra L53/L212 y el aviso del validador.

**Estado:** listo para commit quirúrgico (solo mis archivos; el resto del working tree es
ajeno y no se toca). Sin push.
