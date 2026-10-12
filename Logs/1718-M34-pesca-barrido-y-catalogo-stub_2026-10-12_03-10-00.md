# Log 1718: M34-Pesca - barrido de verificacion (+2) y hallazgo de catalogo stub

**Fecha:** 2026-10-12
**Hora:** 03:10
**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code

## Resumen

Barrido autorizado por el director (msg 164). **M34: 84 -> 86 `[x]` / 153 (+2).**

## Evidencia base

```
test_fishing.gd             TEST M34 PESCA: 0 fallo(s)
test_fishing_clima.gd       TEST M34 CLIMA: 0 fallo(s)
test_fishing_save_block.gd  TEST FISHING-SAVE-BLOCK: 11 checks, 0 fallo(s)
```

## Verificado y flippado (+2)

| Item | Evidencia |
|---|---|
| G120 catalogo del museo | `FishingManager.get_collection_data()` + `test_fishing.gd:112,119` ("restore recupera coleccion") |
| G123 mejor tamano | `registrar_captura()` persiste `entry["mejor"] = maxf(...)` y se expone en `get_collection_data()` |

## HALLAZGO PRINCIPAL — la mecanica esta, el contenido no

**La mecanica de pesca s\u00ed esta implementada y verificada:**
- FSM de 7 estados en `fishing_session.gd` (IDLE/LANZANDO/ESPERA_PICADA/PICADA/MINIJUEGO/
  CAPTURA/ESCAPE) con senales `estado_cambiado`, `ventana_activa`, `pulsaciones_minijuego`.
- `resolver_especie()` filtra por estacion (M29), franja horaria (M31) y clima (M32),
  aplica bonus de cebo y sistema de pity.
- `registrar_captura()` con seguimiento de mejor tamano; save/load verificado
  (11 checks en `test_fishing_save_block.gd`).

**Pero el CATALOGO es un stub:** `data/balance/fishing.json` tiene **2 peces** (el plan
pide 25), **0 cebos** (pide 4) y **0 canas** (pide 3). Los items P1 (25 especies),
P7 (4 cebos), P8 (3 canas), C61 (.tres de los 25 peces) y C62 (cebos y canas listas)
quedan `[?]` por eso. Verificado leyendo `_cargar_peces()` (carga solo la clave
"peces" del JSON) y el archivo mismo.

## Quedo [?] a proposito (evidencia negativa)

- **Creacion del item pez y entrega a M14** (E95/G115): M34 solo emite
  `captura_exitosa(pez, tamano)`, el contrato. Nadie crea el item ni lo suma al
  inventario.
- **Validacion de agua por voxel** (D69/D70/D71): `es_agua_pescable()` es un
  `return true`, depende de M51.
- **`spot_apunta_desde()`** (J161): devuelve el *primer* spot registrado, no el del
  centro del rayo — con varios spots cercanos hay ambiguedad.
- UI (M53), audio (M42), VFX (M52), accesibilidad (M57), precios (M93/M38).

## Archivos Modificados

- `DOCUMENTACION/34-Pesca/plan-actual/05-Checklist.md` (2 flips + nota)
- `DOCUMENTACION/34-Pesca/plan-actual/04-Codigo.md` (Notas del Agente)
