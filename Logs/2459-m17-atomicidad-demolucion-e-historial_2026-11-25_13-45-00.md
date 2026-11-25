# Log 2459: M17 Construccion — P9b: la misma clase de defecto en DEMOLER y en las 6 ramas del historial

**Fecha:** 2026-11-25
**Hora:** 13:45
**Modelo:** minimax-m3-1-flash
**Plataforma:** DeepAI Code (pi)

## Resumen

Continuación directa de la P9 (Log 2458). La P9 arregló la **colocación**; al seguir el barrido de
la misma clase de defecto — *"reporta éxito sin hacer el trabajo"* — aparecieron **más rutas con
exactamente el mismo problema**, y una era la peor de todas.

**M17 sigue en 148/175, 0 `[?]`, 0 ítems inflados.** Esta tanda no agrega ítems: los corrige.

## Defectos encontrados y corregidos

| Ruta | Qué pasaba | Ahora |
|---|---|---|
| `demolir_pieza()` | el borrado devolvía 0 y la pieza **se daba de baja igual**, con los materiales **devueltos** → el voxel quedaba **huérfano** en el mundo (visible, pero sin pieza: "no hay ninguna pieza en esa celda" → no se podía demoter nunca) | motivo `NO_SE_PUDO_BORRAR`: la pieza **sigue en su sitio**, no se devuelve nada |
| `undo` de colocar | borrado fallido + `_baja_estructura()` + costo devuelto → huérfano | la pieza sigue, el costo no se devuelve |
| `redo` de colocar | escritura fallida + `_alta_estructura()` → pieza en la lógica **sin voxel** | no se registra, no se descuenta |
| `undo` de demoler | escritura fallida + `_alta_estructura()` → ídem + se re-descontaba el costo | no se registra, no se descuenta |
| `redo` de demoler | borrado fallido + `_baja_estructura()` + material devuelto → huérfano | la pieza sigue, no se devuelve nada |
| `undo`/`redo` de almacenar | igual que colocar/demoler | igual |
| `undo`/`redo` de mover | `_baja_estructura()` del origen **antes** de escribir → si la escritura fallaba, **la pieza se perdía** | se escribe el destino **antes** de dar de baja el origen; si falla, la pieza **sigue donde estaba** |

## Cambios Realizados

| Archivo | Cambio |
|---|---|
| `game/isla-ancestral/scripts/construccion/construccion_tipos.gd` | Motivo nuevo **`NO_SE_PUDO_BORRAR`** (TEMPORAL + texto de HUD), simétrico de `NO_SE_PUDO_ESCRIBIR`. |
| `game/isla-ancestral/scripts/construccion/build_manager.gd` | Helpers `_fallo_de_mundo(operados)` y `_fallo_mundo(motivo, detalle)`; **orden corregido en las 7 rutas**: primero la operación en el mundo, después el estado interno. Si la operación falla, no se tocan estructura, inventario ni historial. |
| `game/isla-ancestral/tests/test_m17_atomicidad_escritura.gd` | Ampliada de 24 a **33 checks** (sección F: demolición + las 6 ramas del historial). |
| `DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md` | Nueva sección **§16**. |
| `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md` | Nota de **L167** actualizada (33 checks + cobertura de demolición/historial). |
| `Logs/NUMEROS_DISPONIBLES.txt` | **2459** consumido. |

## Principio aplicado (el mismo en todas las rutas)

> **Primero la operación en el mundo; después el estado interno.**
> Si la operación en el mundo falla, no se toca ni la estructura, ni el inventario, ni el historial.

Y el criterio de fallo es explícito, para no romper el modo lógico:

```gdscript
func _fallo_de_mundo(operados: int) -> bool:
	return _mundo.tiene_terreno() and operados <= 0
```

En **modo lógico** (sin terreno) nunca es un fallo: ahí el mundo es nulo **por diseño** y la pieza
vive solo en la lógica de M17.

## Evidencia (Godot 4.7.2 headless, binario real)

- Suite `tests/test_m17_atomicidad_escritura.gd` → **33 checks, 0 fallos, EXIT 0**.
  El terreno falso permite **romperlo en caliente** (`terreno.roto = true` → el voxel tool deja de
  responder), que es el escenario realista: el terreno se rompe *después* de colocar.
- **ROJO-VERDE:** con `_fallo_de_mundo()` stubbeada a `false` → **4 fallos / EXIT 1** (se ve el
  comportamiento viejo). Restaurada → 33/0.
- **Regresión: 15 suites en verde** (M17 ×14 + M59 28/0).

## Checks nuevos (texto literal)

- "F2: demoler con el borrado fallido -> motivo NO_SE_PUDO_BORRAR"
- "F3: la pieza SIGUE en su sitio (no queda un voxel huerfano)"
- "F4: NO se devuelven materiales si la demolicion no ocurrio"
- "F5: deshacer con el borrado fallido -> motivo NO_SE_PUDO_BORRAR"
- "F6: al no poder deshacer, la pieza sigue en su sitio"
- "F8: deshacer una demolicion con la escritura fallida -> motivo NO_SE_PUDO_ESCRIBIR"
- "F9: al no poder deshacer, la pieza NO se registro (no queda en la logica sin voxel)"

## Lo que NO se hizo (honestidad)

- **M20** no se toca (reclamado por GLM-5.3-Flash).
- No se fabrican datos de otros dueños.
- Los 27 `[ ]` de M17 son de otros módulos (mapa de propiedad de `04-Codigo.md`).
- El barrido de la clase de defecto se limitó al **núcleo de M17** (manager, mundo, historia,
  validador): **no se auditaron todavía** `build_ghost.gd`, `build_hud.gd` ni `build_preview.gd`
  con el mismo criterio — queda como siguiente paso.
- El estado del historial tras un undo fallido: la entrada ya fue movida a la pila de redo por
  `BuildHistory.undo_ultimo()` (contrato previo, no tocado aquí). Con el guard, el fallo deja la
  pieza en su sitio y la entrada en redo, asi que el jugador puede reintentar con "rehacer".
