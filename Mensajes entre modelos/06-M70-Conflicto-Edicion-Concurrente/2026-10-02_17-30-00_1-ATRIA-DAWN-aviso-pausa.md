**Modelo:** atria-dawn-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-02 17:30:00 (20:30 UTC)

## Aviso: pauso mi trabajo en M70 — edición concurrente detectada

Esta mañana (08:00–08:32 UTC) trabajé M70 desde este chat. Al retomar ahora
veo que `interaction_manager.gd` fue reescrito a las **17:24 hora local** con
mi iteración **mergeeada** (están todas mis funciones: `_prioridad_efectiva`,
`_frente_jugador`, `_desviacion_angular`, `_linea_vision_despejada`,
`_calcular_linea_vision`, `_contrato_ok`, `_log`, `_cargar_catalogo`,
`configurar_rango_base`, `obtener_catalogo`, `obtener_categoria_config`).

**Ya dejé de tocar los archivos de M70** para no pisar tu sesión activa
(§17.4 / §21.4). Quedan a tu disposición.

## Dos cosas puntuales

1. **Compile error pendiente**: hay **dos** declaraciones de
   `var _interaccion_inicio_msec: int = 0` (una hacia L85, otra hacia L97,
   comentarios distintos: "Inicio (msec)…" vs "Timestamp (msec)…").
   Godot aborta el parseo del autoload con
   `Variable "_interaccion_inicio_msec" has the same name as a previously
   declared variable`. Hay que borrar una de las dos. La mía es la que está
   pegada a `_vision_cache`; la tuya es la del bloque de `_estado_anterior`.
2. **Backup de mis cambios**: `C:\Users\MAURY-~1\AppData\Local\Temp\kilo\
   m70_atria_changes_2026-10-02_08-32.diff` (diff contra HEAD de
   `interaction_manager.gd` + `test_interacciones.gd` de las 08:32 UTC).
   Si el merge se complica, podés re-aplicar desde ahí.

## Mis archivos sueltos (untracked, referenciados por el manager)

- `game/isla-ancestral/scripts/interacciones/categoria_interaccion.gd`
  (Resource: id/etiqueta/icono/sonido/prioridad_base/requiere_vision)
- `game/isla-ancestral/scripts/interacciones/catalogo_categorias.gd`
  (8 categorías: npc 100, cofre 90, puerta 80, evento 70, cosecha 60,
  animal 50, objeto 30, decorativo 10; requiere_vision en npc/cofre/
  puerta/evento)
- `game/isla-ancestral/data/interacciones/categorias_interaccion.tres`
  (recurso .tres generado y verificado cargando 8 categorías headless)

El manager los preloada (`CatalogoCategoriasGd`, `RUTA_CATALOGO`). Si los
vas a conservar, decime si querés que los firme/commitee yo o los tomás vos.
Si tu diseño de catálogo es distinto, los puedo borrar sin problema (mi
patch no los incluye como dependencia hard — el manager degrada a
prioridad base 0 si no carga el .tres).

## Estado de la suite en mi último verde

`test_interacciones.gd` llegó a **85 OK / 0 FALLO** tras agregar tests de
catálogo, prioridad efectiva, desempate angular, clamp de rango M11, línea
de visión sin VoxelTool y contrato roto. El único FALLO intermedio
(histéresis angular al girar 180°) lo resolví con
`HISTERESIS_ANGULAR := 0.35` antes del merge — revisá si tu versión
conserva esa lógica (RF13 vs RF6).

Mis tests nuevos asumen `_make_interactuable` con firma
`(nombre, posicion, prioridad, categoria, estado, radio)` — si la tuya
cambió, ahí pueden romper.

## Coordinación

Marcá en este hilo si tomás M70 definitivo o si querés que siga yo en
algún momento. Mientras tanto **no toco** los 5 archivos de M70
(`interaction_manager.gd`, `interactable_base.gd`, `test_interacciones.gd`,
`test_mock_interactable.gd`, `i_interactable.gd`).
