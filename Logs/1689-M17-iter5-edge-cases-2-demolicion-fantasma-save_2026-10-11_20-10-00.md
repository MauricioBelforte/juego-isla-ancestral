# Log 1689: M17 iter. 5 - edge cases restantes (demolicion ordenada, fantasma, save)

**Fecha:** 2026-10-11
**Hora:** 20:10
**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code

## Resumen

Encargo del director (msg 142): los edge cases de M17 que quedaban implementables
sin UI. Tres cerrados. **M17: 69 -> 72 `[x]` / 175.** Las 5 suites quedan en
**452 checks, 0 fallos**.

## Cambios Realizados

### 1. L197 — demolicion de pieza bajo otra pieza

`BuildManager.piezas_apoyadas_en(ancla)` devuelve los ids de las estructuras que
ocupan la celda `y+1` de alguna celda de la pieza de abajo. Si hay alguna,
`demoler_pieza()` rechaza con el nuevo motivo `SOSTIENE_OTRA_PIEZA`
("hay una pieza apoyada arriba (demole la de arriba primero)"), **permanente**
(el jugador tiene que actuar). Determinista: solo usa el indice de ocupacion, asi
funciona igual en headless. El rechazo no devuelve material ni borra nada.

### 2. L192 — cerrar el modo con el fantasma activo

`BuildManager.conectar_fantasma(BuildGhost)` / `fantasma()`. `salir_modo()` llama
`fantasma.devolve_al_pool()`, asi el fantasma se oculta, sale del arbol y no deja
seleccion ni estado a medias. `salir_modo()` sin fantasma conectado no rompe
(headless / UI que no lo usa).

### 3. L193 — guardado a mitad de colocacion

El fantasma es estado de UI: nunca entra en `_estructuras`, asi que
`obtener_estructuras()` y el save solo ven piezas reales. La suite lo verifica con
un fantasma visible a mitad de una colocacion: el save tiene 1 estructura, sin
claves de fantasma/preview, y el round-trip save/load no inventa ni duplica piezas.

## Bug latente corregido

`BuildGhost.ocultar()` no limpiaba `_receta_id`: un fantasma devuelto al pool
seguía reportando la receta anterior, y al reutilizarlo la UI podia mostrar datos
obsoletos. Ahora el fantasma ocioso queda sin pieza (edge case L192: "no queda
estado inconsistente").

## Error propio corregido

El script de flips uso el fragmento `"Demolici"` como ancla y marco el item
**equivocado** (L114, "Demolicion con ventana de confirmacion", que sigue `[ ]`).
Detectado al verificar, revertido y re-aplicado sobre el item correcto (L197).
Leccion: los anclajes de flip deben ser unicos y especificos, nunca prefijos sueltos.

## Verificacion

```
test_construccion.gd         131 checks, 0 fallos, 12 bloques
test_construccion_iter2.gd    99 checks, 0 fallos,  9 bloques
test_construccion_iter3.gd   138 checks, 0 fallos,  9 bloques
test_construccion_iter4.gd    45 checks, 0 fallos,  4 bloques
test_construccion_iter5.gd    39 checks, 0 fallos,  4 bloques   (nueva)
                              ---
                              452 checks, 0 fallos
```

iter5 bloque 1: piso + pared arriba, rechazo del piso con motivo y texto correctos,
sin devolucion de material, demolicion en orden (arriba -> abajo), piezas contiguas
no se bloquean. Bloque 2: fantasma visible -> salir_modo() -> oculto, sin receta, sin
celdas, pool vivo, sin fantasma conectado no rompe. Bloque 3: save con fantasma
activo = solo estructuras reales, round-trip idempotente.

## Archivos Modificados/Creados

- `game/isla-ancestral/scripts/construccion/construccion_tipos.gd` (motivo SOSTIENE_OTRA_PIEZA)
- `game/isla-ancestral/scripts/construccion/build_manager.gd` (piezas_apoyadas_en, fantasma, salir_modo)
- `game/isla-ancestral/scripts/construccion/build_ghost.gd` (ocultar() limpia _receta_id)
- `game/isla-ancestral/scripts/construccion/test_construccion_iter5.gd` (nueva, 39 checks)
- `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md` (3 flips + Totales + nota)
- `DOCUMENTACION/17-Construccion/plan-actual/04-Codigo.md` (Notas del Agente iter. 5)
