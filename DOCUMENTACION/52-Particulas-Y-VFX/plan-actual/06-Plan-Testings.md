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
