# Log 1711: M27-Islas - barrido de verificacion (+10 items, 414 checks verdes)

**Fecha:** 2026-10-12
**Hora:** 02:10
**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code

## Resumen

Barrido autorizado por el director (msg 158). **M27: 99 -> 109 `[x]` / 192 (+10).**

## Evidencia base

```
test_islas_headless.gd        5 checks, 0 fallos
test_islas_m27.gd           171 checks, 0 fallos
test_islas_m27_iter2.gd     238 checks, 0 fallos
                            ---
                            414 checks, 0 fallos
```

## Verificado y flippado

| Item | Evidencia |
|---|---|
| C54 `init(anclas)` | `island_registry.anclar(id, ancla, semilla_isla)` + `posicion_ancla()` |
| E88 servicio separado | `island_ops.gd`: cola de operaciones independiente de M10 |
| E89 carga con estados | `encolar()` + `progreso()`/`info()`, 5 estados |
| E91 pesos 60/25/10/5 | `PESOS = [0.60, 0.25, 0.10, 0.05]` + `ETAPAS`; tests exactos |
| E101 precarga vecinas | `debe_precargar(pos, isla_actual)` + `vecinas(id)` (K1) |
| E102 descarga por memoria | K9 verde |
| E103 asincrona sin congelar | `MAX_OPS_POR_FRAME = 1` + K2 |
| E105 fallo de carga | `fallar(motivo)` con estado FALLIDA |
| E106 jugador nunca atrapado | K8 respawn cozy |
| E95 no descargar Aurora | `debe_precargar()` excluye la actual; Aurora = `isla_principal()` |

## Quedo [?] a proposito (evidencia negativa)

- **E92/E93/E94**: las senales `isla_cargando`/`isla_cargada`/`isla_descargada` **no
  existen** como signals. El progreso se consulta (`progreso()`/`info()`), no se emite.
  Deuda real de API para quien quiera conectar la UI de viaje.
- **E90**: `IslandPref { PRELOAD, DESCARGA }` no es enum; son constantes `StringName`.
- El resto de los `[?]` (83) son items delegados a otros modulos en sus propias notas
  (M10, M15, M19, M25, M26, M28, M36, M51, M62, M64) o de UI/playtest.

## Archivos Modificados

- `DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/05-Checklist.md` (10 flips + nota)
- `DOCUMENTACION/27-Islas-Del-Mundo/plan-actual/04-Codigo.md` (Notas del Agente)
