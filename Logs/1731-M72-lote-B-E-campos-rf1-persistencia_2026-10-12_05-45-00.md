# Log 1731: M72-Logros - lote B+E (campos RF1 + persistencia), 11 -> 31 [x]

**Fecha:** 2026-10-12
**Hora:** 05:45
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Encargo del director (msg 175): secciones B+E de M72, ampliando el núcleo existente.
**M72: 11 -> 31 `[x]` / 185 (+20).** También se commiteó el trabajo pendiente de M34
(msg 176 del director): commit `34e1c51`.

## 1. M34-Pesca: commit `34e1c51`

6 archivos, 1225 inserciones: `fishing_manager.gd` (catálogo de 25 peces + entrega a M14 +
bandeja de peces sueltos), `test_fishing_entrega.gd` (nueva), `test_fishing.gd`,
`data/balance/fishing.json`, y la documentación de M34.

## 2. M72: catálogo RF1 (11 -> 17 logros)

`data/logros/logros.json` con los campos que faltaban en las 17 entradas:
`nombre_i18n`, `descripcion_i18n`, `icono` (obligatorio), `categoria`, `orden`,
`logro_steam_id`. Cobertura de las **7 categorías** del vocabulario de diseño.
También se corrigió mojibake heredado (`Guardián` -> `Guardi\u00e1n`).

## 3. M72: código (`achievement_service.gd`)

- `_cargar_catalogo()` lee los 6 campos nuevos.
- `CATEGORIAS_VALIDAS` (7 valores), hermano de `TIPOS_CONDICION_VALIDOS`.
- **Bug real encontrado:** `_estado_de()` construía el diccionario a mano y **descartaba** los
  campos nuevos, así que la UI nunca recibía icono, categoría ni orden. Ahora arma un
  diccionario `comunes` con todo y lo completa según el caso (oculto/desbloqueado).
- `validar_catalogo()` suma 3 validaciones RF14: icono obligatorio, categoría del vocabulario y
  `logro_steam_id` duplicado.

## 4. ⚠️ Dato real encontrado por la suite de integridad

Mis primeros 4 logros nuevos usaban `stat_id` que **no existen en M71**:
`cultivos_cosechados`, `minerales_extraidos`, `islas_visitadas`, `dias_jugados_total`.
`test_logros_m72_statids.gd` los detectó como "sin resolver". Reemplazados por stats reales
de M71 (`regalos_dados`, `viajes_realizados`, `misiones_completadas`, `sellos_obtenidos`,
`peces_capturados`, `amistad_max_catalina_oso`).

Lección: para añadir logros hay que empatar el `stat_id` con lo que M71 realmente emite
(obtenido ejecutando la suite de stat_ids, no asumiendo).

## 5. Suite nueva

`scripts/logros/test_logros_rf1_e.gd` — **35 checks, 0 fallos**, 6 bloques:
campos RF1, validación RF14, orden de presentación, persistencia, tolerancia/migración y
coexistencia con M71. Las 3 suites de M72 en verde.

### Notas de testing (errores propios corregidos)

- Usé `data["logros"]` cuando la clave real del save es `desbloqueados`.
- Creé una segunda instancia del autoload para el round-trip: su `_ready` duplica el registro
  de proveedor y las conexiones al bus y rompe. El patrón correcto (de `test_logros.gd`) es
  `restore_save_data()` sobre el **mismo** autoload.
- Esperaba 3 campos en la fecha cuando el diseño determinista usa 2 (`dia` + `hora` del
  calendario Aurora).

## Archivos Modificados/Creados

- `game/isla-ancestral/data/logros/logros.json` (11 -> 17 logros, campos RF1, mojibake corregido)
- `game/isla-ancestral/scripts/logros/achievement_service.gd` (campos + validaciones + fix `_estado_de`)
- `game/isla-ancestral/scripts/logros/test_logros_rf1_e.gd` (nueva, 35 checks)
- `game/isla-ancestral/scripts/logros/test_logros.gd` (conteos 11 -> 17)
- `DOCUMENTACION/72-Sistema-De-Logros/plan-actual/05-Checklist.md` (20 flips + nota)
- `DOCUMENTACION/72-Sistema-De-Logros/plan-actual/04-Codigo.md` (Notas del Agente)
