**Modelo:** DeepSeek-V4.1-Flash / WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-13

# 06-Plan-Testings.md — Módulo 52: Partículas y VFX (iter. 5)

Plan de pruebas de la iteración 5 (parte **no visual**): pooling,
precalentamiento, determinismo por semilla, límites de rendimiento y log
`VFX-SKIP`. Todos los casos se ejecutan en **headless** (Godot 4.7.2).

## 1. Comandos

```bash
GODOT="D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"

# Suite de la iteración 5 (instancia nodos reales)
"$GODOT" --headless --path game/isla-ancestral --script res://scripts/particles/test_vfx_pool_m52.gd

# Suite heredada (funciones puras)
"$GODOT" --headless --path game/isla-ancestral --script res://scripts/particles/test_vfx_catalog_headless.gd
"$GODOT" --headless --path game/isla-ancestral --script res://scripts/particles/test_vfx_factory_headless.gd
"$GODOT" --headless --path game/isla-ancestral --script res://scripts/particles/test_vfx_director_headless.gd
```

> **Filtrar siempre la salida.** Godot headless arranca todos los autoloads
> (`[Bootstrap] DOM-INF integridad OK…`); hay que aislar `Resumen M52` y
> comprobar que no aparezca `SCRIPT ERROR`.

## 2. Casos de prueba

| CP | Qué se verifica | Método | Evidencia esperada |
|----|-----------------|--------|--------------------|
| CP-01 | `nuevo_emisor()` devuelve un `GPUParticles3D` configurado | bloque A | nodo no nulo, `amount`/`one_shot`/`lifetime` correctos |
| CP-02 | **`draw_pass_1` asignado y `mesh` inexistente** | bloque A | `draw_pass_1 != null`, `not ("mesh" in gp)` |
| CP-03 | **`crear()` devuelve nodo** (antes `null` por el bug de `mesh`) | bloque A | no nulo + añadido al contenedor |
| CP-04 | `crear()` posiciona y deja emitiendo | bloque A | `position == pedida`, `emitting` |
| CP-05 | Color `#F4E04D` parseado; hex inválido → blanco | bloque A | canales ≈ 0.9568/0.8784 |
| CP-06 | `semilla_de()` estable para la misma entrada | bloque B | dos llamadas → mismo int |
| CP-07 | Semilla distinta por índice y por evento | bloque B | valores distintos |
| CP-08 | Secuencia reproducible (sin azar del motor) | bloque B | dos series iguales |
| CP-09 | `validar_semillas()` acepta buena / rechaza vacía, repetida y no-int | bloque B | `""` vs motivo |
| CP-10 | `precalentar()` crea N emisores **sin emitir** | bloque C | creados = 3, `emitting == false` |
| CP-11 | `prestar()` **reutiliza** (no allocar por disparo) | bloque C | `creados` no sube al reusar |
| CP-12 | `prestar()` fija la semilla determinista | bloque C | `seed == semilla_de(id, 1)` |
| CP-13 | `liberar()` devuelve al pool; doble liberar → `false` | bloque C | activos/libres coherentes |
| CP-14 | Ids distintos no se mezclan | bloque C | emisor nuevo por id |
| CP-15 | Id vacío → descarte con motivo `id vacío` | bloques C/F | `null` + `ultimo_descarte` |
| CP-16 | `max_emisores`: al desbordar **recicla el más antiguo** | bloque D | `activos == max`, `reciclados ≥ 1`, `c == a` |
| CP-17 | `max_particulas`: VFX que solo ya no cabe → descarte | bloque D | `null` + `MOTIVO_PARTICULAS` |
| CP-18 | `max_particulas`: recicla activos para hacer hueco | bloque D | `particulas_activas() <= tope` |
| CP-19 | Director: disparo real **crea el emisor** en el contenedor | bloque E | hijos = 1, posición y `emitting` |
| CP-20 | Director: evento inexistente → `false` y fallo contado | bloque E | `fallos() == 1` |
| CP-21 | Director: `actualizar()` devuelve los agotados al pool | bloque E | `liberados ≥ 1`, `activos == 0` |
| CP-22 | Director: `finalizar()` no deja nodos huérfanos | bloque E | `pool.nodos()` vacío |
| CP-23 | **Señal `emision_descartada` emitida con id y motivo** | bloque F | 2 capturas con motivo correcto |
| CP-24 | Motivo `sin cupo de emisores` sin robar emisor ajeno | bloque F | `creados ≤ 1`, partículas 0 |
| CP-25 | `motivos()` agrega por causa; `stats()` los incluye | bloque F | dict con conteos |
| CP-26 | **Director cuenta el `VFX-SKIP`** (`skips()`) | bloque F | `skips() == 1` con pool diminuto |
| CP-27 | `vaciar()` resetea motivos y `ultimo_descarte` | bloque F | `{}` y `""` |
| CP-28 | Anti-falso-verde: los 6 bloques cierran con `_fin()` | `_run()` | 6 checks "bloque X completó" |
| CP-29 | Suite heredada del catálogo (esquema) | `test_vfx_catalog_headless.gd` | 4 checks · 0 fallos |
| CP-30 | Suite heredada de la factory (parámetros) | `test_vfx_factory_headless.gd` | 8 checks · 0 fallos |
| CP-31 | Suite heredada del director (dispatch) | `test_vfx_director_headless.gd` | 4 checks · 0 fallos |

## 3. Casos NO cubiertos (declarado)

| Tema | Por qué no se prueba |
|---|---|
| Calidad visual (amplitudes, colores, densidades) | Requiere visión fiable; no disponible en este host |
| `Reduce Motion` / `vfx_quality` (M58) | No implementado en M52 |
| Loops registrados con culling / LOD por distancia | No implementados |
| Presupuesto por preset (M90) | No implementado |
| `vfx_trigger.gd` (VFX + SFX + feedback) | No implementado |
| Atmosféricos por clima/estación (M32/M29) | No implementado |
| Partículas 2D de UI (M53) | No implementado |

---

## 6. Plan de la iteración 6 (Log 1002)

Objetivo: cerrar el catálogo, hacer **verificables** las reglas del plan e
implementar loops, LOD y el disparo centralizado.

| # | Caso | Cómo se prueba | Criterio |
|---|------|----------------|----------|
| 6.1 | Catálogo real válido | `SCHEMA.validar_catalogo(config)` | 0 errores, `version == 2`, 31 entradas |
| 6.2 | Cobertura del plan | `SCHEMA.cobertura_plan()` | `[]` (24/24) |
| 6.3 | Reglas por inyección | 16 mutaciones del catálogo | cada una produce el error esperado (RF3/RF4/RF6/RF7/RF11/RF14/RF16) |
| 6.4 | Loops: una zona = un emisor | `registrar()` 2× la misma zona | la segunda devuelve `false` |
| 6.5 | Culling por radio | `cantidad_efectiva()` a 0 / 35 / 41 | 40 / 10 (25%) / 0 |
| 6.6 | LOD | `factor_lod()` cerca y lejos | 1.0 / 0.25 |
| 6.7 | Fase fija (RF4) | `fase_en_t()` 2×, `t=0`, `t` y `t+periodo` | iguales / igual a la fase declarada / periódica |
| 6.8 | Trigger: mapa derivado | `construir(catalogo)` | 13 buses |
| 6.9 | Trigger: conexión real | `conectar(stub)` + `emit` | 13 conectados, 0 faltantes, el callback recibe |
| 6.10 | Trigger: reporta faltantes | `conectar(stub parcial)` | 11 faltantes **nombrados** |
| 6.11 | Trigger: condiciones | `disparar()` con contexto de estación | otoño 2 ids, primavera 3 |
| 6.12 | Buses contra el EventBus real | leer `event_bus.gd` y buscar `signal <n>(` | los 13 existen; `evento_generico` NO |
| 6.13 | Guardián anti-falso-verde | inyectar un `return` tras el bloque B | exit 2 + bloques faltantes nombrados + `INVALIDO` |

**Determinismo:** las suites se corren 3 veces y deben dar el mismo resultado.
**Piso:** `CHECKS_MINIMOS = 60`; por debajo, el resultado es `INVALIDO` aunque no
haya fallos (un helper roto no puede producir un verde).
