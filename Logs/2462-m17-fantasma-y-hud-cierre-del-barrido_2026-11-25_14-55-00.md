# Log 2462: M17 Construccion — P9d: fantasma y HUD (cierre del barrido de defectos)

**Fecha:** 2026-11-25
**Hora:** 14:55
**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

## Resumen

Ultimo tranche del barrido de la familia de defecto **"el sistema muestra o reporta un estado que ya
no es verdad"** (L102 -> escritura atómica -> cache del fantasma -> aqui). **0 flips** (ningun item
nuevo se cierra; L225 ya quedo anotado en la tanda P9c / Log 2461).

**M17 sigue en 148/175, 0 `[?]`, 0 items inflados.**

## Los tres defectos corregidos

| # | Donde | Que pasaba |
|---|---|---|
| 1 | `BuildGhost.MOTIVOS_OCULTAN` | no incluia el motivo nuevo **`TERRENO_NO_CARGADO`** (L102): el fantasma pintaba una **caja roja flotando** sobre una zona cuyo chunk de terreno todavia no esta cargado (no hay referencia espacial: es el mismo caso que "sin terreno", que si lo oculta). |
| 2 | `BuildGhost.ocultar()` | **no reiniciaba la animacion**: si el fantasma se ocultaba a media escala (0 < e < 1) y se reutilizaba del pool, la caja reaparecia a **escala parcial** y ya **no cuadraba con la huella** de la pieza nueva (el jugador veia una caja mas pequena que el sitio donde iba). |
| 3 | `BuildHudModel.es_temporal(res)` | leia solo la clave `"temporal"` del resultado. Un resultado **armado a mano** (sin esa clave) hacia que el HUD mostrara "RECHAZADO" **sin** el "proba de nuevo", aunque el motivo fuera temporal -> el jugador no reintentaba. |

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `game/isla-ancestral/scripts/construccion/build_ghost.gd` | `MOTIVOS_OCULTAN` += `TERRENO_NO_CARGADO`; `ocultar()` reinicia la animacion (`_animando = false`, `_anim_timer = 0`, `_mesh.scale = Vector3.ONE`). |
| `game/isla-ancestral/scripts/construccion/build_hud.gd` | `es_temporal(res)`: si el resultado no trae la clave, consulta los motivos con `ConstruccionTipos.es_temporal(motivo)`. |
| `game/isla-ancestral/tests/test_m17_fantasma_estado.gd` (NUEVO) | **24 checks** + minimo 12. |
| `DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md` | Nueva seccion **§18**. |
| `Logs/NUMEROS_DISPONIBLES.txt` | **2462** consumido. |

## Verificación (Godot 4.7.2 headless, binario real)

**Suite nueva** `tests/test_m17_fantasma_estado.gd`: **24 checks, 0 fallos, EXIT 0**.
Checks clave: "A1: debe_ocultarse = true con TERRENO_NO_CARGADO (no hay referencia espacial)" ·
"A2: con el terreno sin cargar el fantasma queda OCULTO" · "C1: al ocultar, la escala VUELVE a 1
(no queda a medias)" · "C2: el fantasma REUTILIZADO del pool aparece a escala 1 (cuadra con la
huella)" · "D1/D2: tras ocultar no queda receta ni celdas reportadas (L192)" · "E3: aplicar un
resultado NO crea nodos nuevos (pooling)" · "F2: la linea del HUD pide reintentar en un rechazo
temporal" · "F3: un resultado sin la clave 'temporal' tambien se detecta como temporal (por el
motivo)" · "F5: la linea de un rechazo permanente NO pide reintentar".

**ROJO-VERDE:** revirtiendo los 3 cambios → **4 fallos / EXIT 1** (A1, A2, C1, C2).
Restaurados → 24/0.

**Regresion: 17 suites en verde** (M17 x16 + M59), incluidas `iter2` (99/0), `iter3` (138/0) e
**`iter4` (45/0)** — este ultimo es el que prueba la linea de estado temporal del HUD.

## Lo que NO se hizo (honestidad)

- **0 flips**: ningun item nuevo se cierra en esta tanda (L225 ya quedo anotado en el Log 2461).
- **M20** no se toca (reclamado por GLM-5.3-Flash).
- No se fabrican datos de otros duenos.
- El **barrido queda cerrado** para el nucleo de M17: `build_manager.gd`, `construccion_mundo.gd`,
  `construccion_tipos.gd`, `build_preview.gd`, `build_ghost.gd`, `build_hud.gd` y
  `build_history.gd` auditados con el criterio "el sistema muestra un estado que no es verdad".
