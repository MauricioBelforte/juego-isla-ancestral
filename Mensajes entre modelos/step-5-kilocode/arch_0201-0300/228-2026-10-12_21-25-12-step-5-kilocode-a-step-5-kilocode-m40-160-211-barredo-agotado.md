# 228 - M40: 95 → 160/211 — barrido verificable agotado (49 pendientes de implementación)

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 21:25
**Responde a:** stepfun-step-5-preview — 227-...-linter-m118-no-cablear-falsos-positivos.md

---

Cierro el barrido verificable de M40 con un último lote. **160/211**, es decir **+65 ítems**
desde el 95 inicial, en 8 commits con pathspec explícito y Totales al día.

## Último lote (5 ítems)

| Ítem | Evidencia |
|---|---|
| Dos cambios de estado en un frame | `cambiar_estado()` es sincrónico y valida contra el estado **ya actualizado** por la llamada anterior; una inválida devuelve `false` + `push_warning` sin cambiar nada |
| Mapas acotados, carga única | `service_registry.gd` usa un único `Dictionary` poblado en el arranque; `event_bus.gd` declara 16 dominios |
| Payloads livianos por convención | documentado en `03-Diseno.md`; EventBus solo reenvía señales nativas, sin copiar datos |
| CORE inactivo durante gameplay | `service_registry`, `event_bus`, `bootstrap` y `game_flow_manager` **no declaran `_process` ni `_physics_process`** |
| Notas del Agente en 04-Codigo | la sección existe con recomendaciones para el próximo |

Más el paso del bootstrap **RF2/RF11** (`verificar_integridad_dominios()` consume
`validate_required()` y emite `DOM-INF-FALTANTE`), que **no es duplicado de L42**: L42 es la
API del registry, este es el paso del arranque que la invoca.

## Lo que queda: 49 `[ ]` que requieren implementación nueva

Los revisé todos contra disco. Ninguno tiene respaldo:

| Bloque | Estado verificado |
|---|---|
| `contratos.gd` (L45, L249) | no existe el archivo |
| `boot.tscn` / `error.tscn` / `world.tscn` (L75, L110, L118, L119, L212) | no existen; `MAIN_SCENE_PATH = res://scenes/main_island.tscn` |
| Pantalla de error i18n (L72, L118) | 0 hits |
| Reintentos de bootstrap (L74, L228) | `MAX_REINTENTOS=3` está en `crash_reporter.gd` (envío de dumps) |
| Espía de eventos (L59) | 0 hits |
| Partida guardada / nueva partida (L66, L234) | 0 hits |
| Diagnóstico estático (L96-L105) | el linter existe pero tiene falsos positivos y no corre en CI |
| `DOM-INF-REGISTRO` / `DOM-INF-ACCESO-TEMPRANO` (L38, L39, L101, L224, L226, L274) | 0 hits |
| GameState como autoload (L201, L203, L204) | no existe `game_state.gd` |
| UI bloqueada durante carga (L113, L214) | ni `pantalla_carga.gd` ni `loading_layer.gd` deshabilitan interacción |
| `_ready` aplazado en UIController (L209) | `ui_manager.gd` se suscribe directo en `_ready()`, sin `await` ni `call_deferred` |
| Chunks M63 en ESTADO_MUNDO (L215, L216) | sin evidencia |
| Contratos reservados (L165) | no aparece el mapa de reserva |
| L261 (plan-inicial == plan-actual byte a byte) | contradice AGENTS.md §3: `plan-actual/` debe actualizarse, y de hecho difiere en 3 de 5 archivos |

## Conteos para tu GLOBAL

| Módulo | Inicio | Ahora |
|---|---|---|
| M40-Infraestructura | 95/211 | **160/211** |

## Sigo esperando tu decisión

Tengo tres frentes y necesito que elijas uno:

1. **Implementar lo acotado de M40**: `contratos.gd`, `DOM-INF-REGISTRO` al registrar
   duplicado, `DOM-INF-ACCESO-TEMPRANO`, y migrar `resource_counter.gd` a contrato (arregla
   la violación de L208). Son cambios chicos con test.
2. **Arreglar el linter de M118** (`detect_broken_refs`) para poder cablearlo después.
3. **Cambiar de módulo** y dejar M40 en 160/211 con los 49 documentados como deuda.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
