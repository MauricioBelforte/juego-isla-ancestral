# Log 1776: QA 21.8 M164-Isla-De-Combate-Endgame — sello DENEGADO (gem_save_provider nunca registrado)

**Fecha:** 2026-10-12
**Hora:** 21:00
**Modelo:** Atria-Dawn-Preview (atria-dawn-s2)
**Plataforma:** Kilo Code

## Resumen

Ejecutada la QA cruzada 21.8 del modulo M164-Isla-De-Combate-Endgame por encargo del
director (mimo-v2.6, mensaje 337 del canal atria-dawn-s2, primer item del lote).
Veredicto: **SELLO DENEGADO**. El runtime esta verde (81 checks, 0 fallos, EXIT 0) y la
mayoria de los artefactos existen, pero el muestreo detecto **2 fallos materiales**:

1. **L31** afirma "provider gemas_m164 en SaveManager" — **falso**: `gem_currency.gd`
   implementa el contrato ISaveProvider (get_section_name/get_save_data/restore_save_data)
   pero **nunca llama a `SaveManager.register_provider()`**. La clase `GemSaveProvider`
   existe en disco pero es **codigo muerto**: nadie la instancia (0 call sites en todo el
   proyecto). Todos los demas servicios del juego se auto-registran en `_ready()`
   (patron duck-typed ISaveProvider); gem_currency es la unica excepcion.
2. **L154** afirma la integracion M59 con "gem_save_provider + combat_island_save_provider"
   — la mitad es falsa: `combat_island_system.gd` SI registra su provider
   (`_registrar_provider()` llamado desde `_ready()` L38), pero la parte de gemas no esta
   cableada.

Ademas: **drift de Totales** (el director lo pidio verificar). Totales dice 130 items /
128 completados, pero las marcas reales son **127 [x] / 2 [?] / 0 [ ] = 129**. Causa
raiz: el encabezado de la seccion G dice "(10)" pero solo tiene 9 items (L136-144).

Por 21.8.2.b regla 3 (2+ fallos de 5 muestreados deniegan el sello): **SELLO DENEGADO**.

## Cambios Realizados

- **Solo lectura sobre M164** (QA 21.8): no se modifico el checklist del modulo. Los flips
  de L31/L154 a `[?]` quedan pendientes de la orden del director (30.2 regla 4).
- Conteo de marcas: 127 [x] / 2 [?] / 0 [ ]. Totales (L160) dice "130 items, Completados:
  128, No resueltos: 2, Pendientes: 0" -> **drift +1 en total y +1 en completados**.
- Causa raiz del drift: seccion G "Tienda y NPCs (10)" tiene solo 9 items (L136-144).
- Runtime: `test_combat_m164_atria.gd` en Godot headless -> **81 checks, 0 fallos, EXIT 0**.
- Muestreo ampliado (12 items con verbos de creacion): **2 fallos**, 10 OK.
- Verificacion del mecanismo de registro de providers: `save_snapshot.gd:27`
  `register_provider()` es la unica via de inscription; `save_manager.gd` no tiene
  auto-descubrimiento (greps de `get_children`/root-iteration no dan nada). Se listaron
  **todos los call sites de `register_provider` del proyecto**: 40+ servicios se
  auto-registran (`weather_service`, `economy_manager`, `game_clock`, etc.).
  `gem_currency.gd` **no aparece en la lista**; `combat_island_system.gd:183` SI.
- Intento de probe runtime para listar las secciones registradas en SaveManager: el probe
  como escena principal arranca el juego completo y queda colgado en el loop de camara
  (follow_camera.gd). Se descarto esa via; el analisis estatico (call sites + ausencia de
  auto-descubrimiento) es concluyente por si solo.

## Muestreo detallado (12 items)

| Linea | Item | Veredicto |
|-------|------|-----------|
| L26 | Crear GemCurrency.gd como autoload | OK (3609 B + project.godot:133) |
| L27-L30 | get_gems/add_gems/spend_gems/has_gems | OK (1 hit cada uno) |
| **L31** | **provider gemas_m164 en SaveManager** | **FALSO — 0 call sites, GemSaveProvider muerto** |
| L33-L36 | valor_cambio_por_tier T1=1/T2=2/T3=3/T4=5 | OK (gem_currency.gd:62-68) |
| L37-L40 | rango_gemas_categoria (1,2)/(2,3)/(3,5)/(5,15) | OK (gem_currency.gd:73-80) |
| L11 | EnemyCatalog 11 entradas | OK (9 mobs + 2 jefes; HP/atk/gemas coinciden con D.1-D.11) |
| L12 | CombatReward 6 entradas | OK (2 skins, titulo, decoracion, herramienta, montura) |
| L49/L63 | zone_catalog + _zonas_por_defecto + _desbloqueadas | OK (unlock_zone L35, persistente) |
| **L154** | **Integrar M59: gem_save_provider + combat_island_save_provider** | **MEDIO FALSO — combat_island SI registra (L183), gem NO** |
| L155/L156 | round-trip verificado | OK a nivel objeto (test L104-111, L218-227); no via SaveManager |
| L50/L53/L56 | spawners por zona | OK como diseno: `m164_zonas_spec.md` existe con los valores citados; `scripts/combat/spawners/` NO existe (los items dicen "implementacion = proxima iteracion" — honesto) |

Los 2 [?] (L41 monetizacion Steam, L42 paquetes de gemas) son honestos y legitimos:
decision de diseno del usuario (M126), fuera de alcance del juego actual.

## Observaciones no bloqueantes

- L186 (nota iter 1) dice "Todos marcados [ ] sin falsos-verdes" — stale: hoy hay 0 [ ].
- La nota de auditoria T de agnes (L188) dice "70 [x] verificados" — corresponde a la
  jornada 2026-10-06, no al estado actual (127 [x] hoy).

## Archivos Modificados/Creados

- `Mensajes entre modelos/atria-dawn-s2/338-2026-10-12_20-59-29-s2-a-s2-m164-qa-sello-denegado-gem-save-no-cableado.md`
  (cuerpo del informe de QA, antes plantilla vacia)
- `Logs/NUMEROS_DISPONIBLES.txt` (consumo del numero 1776)
- `Logs/1776-2026-10-12_21-00-09-qa-m164-sello-denegado-gem-save.md` (este log)

## Pendiente

- Decision del director sobre la degradacion de L31 y L154 a `[?]`.
- Correccion del drift de Totales (130/128 -> 129/127) y del encabezado de seccion G
  (10 -> 9).
- Siguiente item del lote: M26-Templo.
