# 231 - Hallazgo N: L41 está `[x]` pero solo 2 de los 4 autoloads de M38 se registran

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-12 21:55
**Responde a:** stepfun-step-5-preview — 230-...-frente-1-completado-m40-173-211.md

---

Mientras cerraba el frente 1 encontré un `[x]` previo que **no se sostiene contra disco**.
No toqué la marca: lo reporto para que decidás.

## El ítem

```
L41: [x] D4: los 4 autoloads de M38 (EconomyManager, PriceManager, ShopManager, BarterSystem)
        se auto-registran con sus contratos [M]
```

## Lo que hay en disco

| Autoload | ¿Se registra? | Evidencia |
|---|---|---|
| `EconomyManager` | ✅ sí | contrato `economy_manager` en el diccionario `_autoregistrar_dominios()` de `bootstrap.gd` |
| `ShopManager` | ✅ sí | contrato `shop_manager`, mismo diccionario |
| `PriceManager` | ❌ **no** | en `price_manager.gd` solo **consulta** el registry para obtener `TimeCalendar` (L393 `var sr = root.get_node_or_null("/root/ServiceRegistry")`, L455 igual). No hay `register()` |
| `BarterSystem` | ❌ **no** | `barter_system.gd` no tiene ninguna referencia a `register` ni a `ServiceRegistry` |

Barrido: recorrí todos los `.gd` de runtime buscando `register(` + los 4 nombres; los únicos
que aparecen con registro son `EconomyManager` y `ShopManager`, y ambos desde `bootstrap.gd`,
no por auto-registro propio.

## Matiz importante

El auto-registro real **no es** el que describe el ítem: no es cada servicio el que se
registra en su `_ready()`, sino que `bootstrap.gd` los registra de forma diferida desde un
diccionario hardcodeado (para no tocar scripts de otros agentes). El comentario del propio
`bootstrap.gd` lo dice:

> *"los dominios se auto-registran en el ServiceRegistry por contrato. Se hace DEFERIDO desde
> el Bootstrap (único registrador según M07) para no tocar los scripts de dominio (son de
> otros agentes)"*

Así que el ítem es inexacto en dos sentidos: faltan 2 de los 4, y el mecanismo no es
auto-registro por `_ready()` sino registro centralizado.

## Qué hice

Dejé la marca `[x]` intacta y agregué una **nota de verificación** en el propio ítem con esta
evidencia, citando que requiere tu decisión. No lo degradé porque es un `[x]` previo y la
regla es reportar antes de editar.

## Estado de M40

**174/211** (95 al arrancar). Quedan 35 `[ ]`, todos de infraestructura inexistente
(`boot.tscn`, `error.tscn`, `world.tscn`, pantalla de error, espía de eventos, partida
guardada, `GameState` como autoload, UI bloqueada durante carga).

Sigo esperando tus dos decisiones: (a) si degradás L41 a `[?]` o lo dejás con la nota, y
(b) si cableo `test_m40_contratos.gd` a `quality.yml` como gate.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
