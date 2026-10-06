# Log 1378 - M59 - Cola de bugs, bug 2: BUG-108 (restore de inventario robusto)

- Modelo: DeepSeek-V4.1-Flash
- Plataforma: WorkBuddy
- Fecha: 2026-10-06 16:45
- Agente: deepseek-v4.1-flash
- Modulo: M59 (saving) - cola de bugs derivada de M59 (BUG-108 pertenece a M14/inventario)
- Autorizacion: mensaje 51 del director (atria-Dawn-Preview / Kilo Code), seccion 4, orden 1->8
- Log reservado: 1378 (protocolo v3, AGENTS.md 6.1.a; el pool quedo con primero=1379)
- Estado: COMMIT LOCAL, SIN PUSH (la cola no se empuja sin autorizacion expresa)

## 1. Contexto

El director autorizo (msg 51) ejecutar la cola de bugs BUG-108..115 del modulo M59
en orden estricto, con sonda nueva por bug y regresion sobre las suites vivas de M59
despues de CADA bug, un commit por bug o por grupo coherente, sin tocar quality.yml,
sin tocar DOCUMENTACION/11-BUGS.md (es de s3/Ling, va en commit conjunto) y sin push
sin autorizacion.

Este log cubre el bug 2 de la cola: BUG-108 (el bug 1, BUG-111, esta en el Log 1377).

## 2. BUG-108 - dos defectos medidos

Reporte original: "Restore de inventario: clave de seccion no numerica -> contenedor 0
+ sin validar stack_max. Corrupcion de inventario en carga - el jugador pierde items."

### Defecto A - clave de seccion no numerica mapea a BOLSILLO (contenedor 0)

`InventarioService.restore_save_data()` hacia:

    for id in data:
        var c := int(id)
        if contenedores.has(c):
            ...contenedores[c].deserializar(lista)

`int()` sobre una cadena NO numerica devuelve 0 en GDScript. Como 0 es el id valido de
BOLSILLO, un save corrupto o ajeno con una clave como "basura" o "inventory" escribia
su contenido en el BOLSILLO del jugador, y `deserializar` empieza vaciando TODOS los
slots del contenedor: el contenido real del bolsillo se perdia EN SILENCIO.

MEDIDO (sonda en ROJO, antes del fix): bolsillo con 5 copper_ore + restore de
{"basura": [{"slot":0,"id":"crystal","n":3}]} -> copper_ore pasa a 0 y aparece crystal.

### Defecto B - la carga no acota la cantidad al stack_max del item

`ContenedorInventario.deserializar()` validaba que el item existiera en el catalogo y
que cantidad > 0, pero NO acotaba al stack_max. `validate_quantities()` ya existe y
acota, pero NO se llamaba en la ruta de carga. Un save manipulado o de una version
antigua con n=9999 cargaba el slot con 9999 (invariante del contenedor roto).

MEDIDO (sonda en ROJO, antes del fix): crystal (apilable, stack_max=50) con n=9999 ->
se cargaba 9999; ancient_crystal (NO apilable, tope 1) con n=5 -> se cargaba 5.

## 3. Fix aplicado (2 archivos)

### game/isla-ancestral/scripts/inventario/inventario_service.gd (+33/-5 aprox)

- Nuevo helper `_seccion_a_contenedor(id) -> int`: convierte la clave a id SOLO si es
  un entero valido (TYPE_INT; TYPE_FLOAT solo si es entero exacto; TYPE_STRING solo si
  `is_valid_int()`); si no, devuelve -1.
- `restore_save_data()` usa el helper; si la clave es invalida (c<0) o el contenedor no
  existe, emite push_warning y CONTINUA (no escribe). Tambien valida que la seccion sea
  Array antes de deserializar.

### game/isla-ancestral/scripts/inventario/inventario_contenedor.gd (+7)

- En `deserializar()`, tras validar item_id y cantidad>0, se acota con `_stack_max_de()`
  (que ya respeta `apilable`: no apilable -> tope 1). Si cantidad > tope, push_warning y
  se recorta a tope.

## 4. Sonda nueva (probada en rojo)

Archivo: game/isla-ancestral/scripts/inventario/test_inventario_restore_robusto.gd
- 12 checks. Piso `CHECKS_MINIMOS := 10` (MEDIDO en verde = 12; si un bloque aborta en
  silencio el resumen sale con EXIT 1 en vez de un "0 fallos" enganoso).
- Cubre: (A) clave no numerica no clobbea el bolsillo; control de clave '0' valida que
  SI escribe; clave '99' fuera de rango ignorada; (B) clamp apilable 9999->50 y no
  apilable 5->1.
- VERDE: 12 checks, 0 fallos, EXIT 0 x3.
- ROJO probado (revirtiendo el fix a HEAD): 12 checks, 4 fallos, EXIT 1. Los valores
  medidos en rojo coinciden con lo predicho: "medido 9999" y "medido 5", y el bolsillo
  pierde copper_ore / recibe crystal.

## 5. Regresion (despues del fix, todo verde)

- test_rotate_m59.gd          : 43 checks, 0 fallos
- test_slots_m59.gd           : 22 checks, 0 fallos
- test_autosave_m59.gd        : 0 fallos
- test_fishing_save_block.gd  : 11 checks, 0 fallos
- test_save_collect_robust.gd : 10 checks, 0 fallos (sonda del Log 1377)
- test_inventario.gd          : 0 fallos (M14)
- test_inventario_iter5.gd    : 0 fallos (M14)
- test_inventario_restore_robusto.gd : 12 checks, 0 fallos (nueva)
- test_m62_pureza_save.gd     : 59 checks, 0 fallos (M62)

Nota: "9 resources still in use at exit" es un aviso benigno de apagado de Godot, no un
fallo de test (todas las suites salen EXIT 0 con 0 fallos).

## 6. Observaciones de canal (no tocadas)

- El pool de logs reporta 2 colisiones de numeracion AJENAS: 1290 y 1368 (dos archivos
  con el mismo numero, de otros autores). Por regla (AGENTS.md 6.1) se REPORTAN, no se
  tocan. Requiere decision del director.
- DOCUMENTACION/11-BUGS.md: NO tocado (espera commit conjunto con s3/Ling).

## 7. Estado y pendientes

- Commit local del fix + sonda + este log. SIN PUSH.
- Pendiente: continuar la cola con BUG-109 (tope de tamano antes de
  FileAccess.get_file_as_string en save_loader.gd).
- Pendiente: reporte al director por grupos (1-4, luego 5-8) segun lo indicado.
