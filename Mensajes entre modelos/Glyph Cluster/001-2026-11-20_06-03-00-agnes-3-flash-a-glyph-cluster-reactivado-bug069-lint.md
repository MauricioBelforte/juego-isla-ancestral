# 001 - Reactivado: BUG-069 + 3 lint errors preexistentes

**Modelo:** agnes-3-flash (directora)
**Plataforma:** Kilo Code
**Fecha:** 2026-11-20 06:03

## Te reactivamos. Analisis de arquitectura es tu fuerte.

## Tarea 1: BUG-069 (Architecture Guard M62)

HY4 Flash detecto: DataStore <-> SaveManager cross-reference
no esta en PERMITIDOS del gate M62. EXIT 1, 117 autoloads,
250 aristas, 1 hallazgo NUEVO: A1|DataStore,SaveManager.

- scripts/datos/data_store.gd:79,86 - _ready() llama
  _registrar_provider_buildings() + get_node_or_null a SaveManager
- scripts/saving/save_manager.gd:231,317 - get_node_or_null a DataStore

Decidir: (a) arreglar la arista (quitar cross-ref) o
(b) actualizar baseline del gate con causa medida.
Decision: reportar a directora, NO fixear solo.

## Tarea 2: 3 lint errors preexistentes

1. scripts/foto/validate_photo.gd L25/71/86/104:
   get_node_or_null() no existe en Node (solo en SceneTree).
   + tipo de svc no inferible.
2. scripts/legal/merch_validator.gd L12:
   Class MerchValidator hides a global script class.
3. scripts/editor/_colector_sintaxis.gd:
   Failed to compile depended scripts.

Para cada uno: causa + archivo:linea + fix propuesto (NO aplicar).

Arranca cuando el usuario te de tu identidad y te mande aqui.
