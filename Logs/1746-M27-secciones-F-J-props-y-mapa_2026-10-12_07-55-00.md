# Log 1746: M27 - secciones F y J (contrato de props y mapa), 118 -> 121

**Fecha:** 2026-10-12
**Hora:** 07:55
**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code

## Resumen

Encargo del director (msg 193, a eleccion): **secciones F y J de M27**.
**M27: 118 -> 121 `[x]` / 192 (+3).**

## F112 — contrato con M50

`IslandProps.materializar()` pasa a los spawners (`_contexto()`, L115-133):

- `items`: `isla.flora_endemica` / `fauna_endemica` / `recursos_exclusivos` / `puzzles`
- `bounds`: `isla.bounds_locales()`
- `centro`: `isla.centro_mundo()`
- `semilla_props(isla)` derivada por isla (determinista)

El filtro por bioma y la colocacion real son del spawner de M50 — limite documentado.

## J169/J170 — mapa y secretos

| Item | Evidencia |
|---|---|
| Mapa marca descubiertas y visitadas | `esta_descubierta()` / `esta_visitada()` + senal `isla_descubierta`; `descubrir()` devuelve true solo la primera vez |
| Secretos ocultos hasta descubrirlos | `visible_en_mapa(id)` en false mientras sea secreta y no descubierta |

Tests propios en `test_islas_m27.gd`:
```
visible_en_mapa(secreta) == false sin descubrir
visible_en_mapa(secreta) == true tras descubrir
visible_en_mapa(inexistente) == false
```

## Los 5 restantes

| Item | Limite |
|---|---|
| Spawn fauna endemica | contexto se pasa; colocacion de M36 |
| Spawn recursos exclusivos | idem, M15 |
| Spawn POI (muelle, plaza, faro...) | idem, M64 |
| Props no se generan en el mar | recorte contra el agua del spawner / M51 |
| Ningun contenido exclusivo se pierde | acceso por otras vias, de otros modulos |

## Suites

```
test_islas_m27.gd           171 checks, 0 fallos
test_islas_m27_iter2.gd     238 checks, 0 fallos
```

## Archivos Modificados

- `DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/05-Checklist.md` (3 flips)
- `DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/04-Codigo.md` (Notas del Agente)

Encoding verificado: sin BOM, sin mojibake, 33132 bytes.
