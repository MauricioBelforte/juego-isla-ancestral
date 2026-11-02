# Log 2302 - M110 b2: extraccion de DiagnosticExporter, DebugCommands y PanelBase

- Fecha: 2026-11-01 23:52
- Agente: DeepSeek-V4.1-Flash
- Modulo: M110-Debug-Menu
- Rama: RAMA 2 (sin mensajes del director con NN > tracker 492)
- Tipo: refactor con artefacto nuevo + 1 widget de UI + suite nueva

## 1. Punto de partida medido

- Tracker `.ultima-revision-deepseek.txt` = 492. Mensajes de la directora en mi
  carpeta: 488, 490, 492 (NN maximo 492 = tracker). Ninguno con NN > 492.
- BACKLOG-MASTER, seccion (A) COLA ACTIVA (lineas 17-425): marcas EN POSICION
  23 [x] / 0 [ ] / 5 [->]. Los 5 [->] son los items 3, 17, 35, 36 y 102, todos
  con nota de tanda previa (17 es el que trabaje el 2026-11-01 23:33).
  NOTA DE MEDICION: un conteo ingenuo de `[ ]` sobre esa seccion da 49 y de
  `[?]` da 61. Son MENCIONES INLINE dentro de las notas (por ejemplo
  "172 [x] / 53 [ ]"), no marcas de item. El conteo valido exige anclar la marca
  al inicio del item (`^\s*(?:\d+\.|[-*])\s+\[.\]`). Sin ese ancla la COLA
  parece tener 110 items abiertos cuando tiene 0.
- 05-Checklist de M110: 179 [x] / 46 [ ] / 0 [?] = 225. De los 46 pendientes,
  37 ya estaban clasificados (13 cubiertos por la tanda del 23:33, 15 obsoletos
  ya implementados, 9 cubiertos esa misma tanda). Quedaban 9 sin tocar:
  L114, L139, L142, L176, L233, L275, L286, L287, L288.

## 2. Por que esos 9 llevaban tres semanas abiertos

No era falta de tiempo: eran items de REFACTOR, y un item de refactor no se
cierra escribiendo documentacion, se cierra moviendo el codigo. Cuatro de ellos
(L142, L176, L275, L287) describen el MISMO hecho desde cuatro angulos: el
exportador de diagnostico vivia embebido en `debug_menu.gd` (lineas 1352-1438).
Dos mas (L286 y L288) pedian archivos que no existian en la ruta que el
checklist nombra. L139 pedia un boton que llamara a `save_config()`, funcion que
el backend YA tenia desde el 2026-10-27 pero que ningun widget invocaba: el
estado solo se persistia en `_notification(EXIT_TREE)`.

## 3. Entregado

### 3.1 `scripts/debug/diagnostic_exporter.gd` (NUEVO, 5.721 B, 138 lineas)

Extraccion SIN reescritura de logica: `_export_diagnostic_zip()` y
`_do_export_diagnostic()` de `debug_menu.gd` pasaron a un modulo sin estado.

    static func exportar(meta: Dictionary, lineas_consola: Array, vp: Viewport) -> Dictionary

Devuelve `{ok, path, txt_path, error}`. Helpers privados: `_ruta_zip()`,
`_cola_de_logs()` (cola de 200 lineas de `user://output.txt`), `_capturar_png()`
(null en headless, borra el temporal siempre) y `_escribir_txt()`.
Se consume por `preload`, sin `class_name`: M110 ya tuvo colisiones globales
(BUG-091, `TerrainData`).

### 3.2 `scripts/debug/debug_commands.gd` (NUEVO, 5.990 B, 131 lineas)

El `match accion:` de 68 lineas de `ejecutar_comando()` paso a:

    static func ejecutar(host: Node, id: String, cmd: Dictionary, catalogo: Dictionary) -> Dictionary

Los 6 toggles visuales se resuelven por tabla (`ACCIONES_VISUALES`), no por
`match`. Contrato preservado a proposito: devuelve EXACTAMENTE el Dictionary del
host y NO agrega la clave `comando` salvo en `exportar`, que es donde el
original ya la agregaba (varias suites comparan el resultado).

### 3.3 `scripts/debug/panel_base.gd` (NUEVO, 4.729 B, 147 lineas)

Item L288 pide `scripts/debug/panel_*.gd`; solo existian `panels/panel_mundo.gd`
y `panels/panel_entidades.gd`. La base cierra el prefijo que el checklist nombra
Y elimina duplicacion real: `_menu`, `_ultimo`, `_ready()`, `_inyectar_menu()`,
`ultimo_resultado()` y `_llamar()` estaban COPIADOS identicos en los dos paneles.
Los paneles ahora hacen `extends "res://scripts/debug/panel_base.gd"` (por RUTA,
no por `class_name`: un `class_name` nuevo no esta en la cache global de clases
y el preload falla con "Could not resolve script", medido en el primer intento).
`refrescar()` queda en la base y llama a `_actualizar()`; un guardia
`_construido` hace que refrescar fuera del arbol sea no-op en vez de null-deref.

### 3.4 `debug_menu.gd`: los dos delegados

    func ejecutar_comando(id: String) -> Dictionary:
        ...
        return COMANDOS_DEBUG.ejecutar(self, id, cmd, config.get("comandos", {}))

    func _export_diagnostic_zip() -> Dictionary:
        return EXPORTADOR_DIAG.exportar(_build_metadata(), _console_lines, get_viewport())

Se conservan `_export_diag()` y `_do_export_diagnostic()` como alias para no
romper a sus llamadores. El archivo paso de 57.175 B a 51.704 B (-5.471 B).

### 3.5 `debug_menu_ui.gd`: boton "Guardar Configuracion" (L139)

`BarraConfig` (HBoxContainer) con `BotonGuardarConfig` -> `save_config()` y
`BotonResetConfig` -> `reset_config()`, mas getters para la suite. Fail-closed:
sin backend o sin el metodo no hacen nada y NO escriben en la consola.

## 4. Suite nueva: `test_refactor_m110.gd` (15.769 B, 387 lineas, 49 checks)

6 bloques A-F, `CHECKS_MINIMOS := 49` MEDIDO en verde, `_fin(bloque)` al final
del CUERPO de cada bloque, `_summary()` en `call_deferred` SEPARADO.

El check central es C2/C4: mide la LONGITUD del cuerpo de las dos funciones de
`debug_menu.gd` (<= 12 y <= 4 lineas). Un archivo extraido al lado de una copia
viva es la trampa clasica de este tipo de item, y una comprobacion de "el
archivo existe" no la ve. C6 agrega la prueba de procedencia: la cadena
"accion desconocida" tiene que vivir SOLO en el modulo.

## 5. Evidencia

- Suite nueva: 49 checks / 0 fallos / EXIT 0, x3 corridas consecutivas,
  0 SCRIPT ERROR.
- Regresion completa de M110: 13 suites, 549 checks, 0 fallos, EXIT 0 en las
  13, 0 SCRIPT ERROR. Detalle:
  18 + 75 + 75 + 61 + 22 + 66 + 27 + 17 + 14 + 17 + 53 + 55 + 49 = 549.
- Sondas EN ROJO: 5/5, con restauracion byte-exacta sha256 verificada.
  P1 quitar la delegacion de `ejecutar_comando` -> [FAIL] C3.
  P2 quitar un toggle de ACCIONES_VISUALES -> [FAIL] B6 + B7.
  P3 panel_mundo deja de heredar -> [FAIL] bloque E NO se ejecuto + piso 42<49.
  P4 piso 999 -> [FAIL] piso de checks.
  P5 bloque B sin `_fin` -> [FAIL] bloque B NO se ejecuto.
  Control antes y despues: EXIT 0 / 0 fallos.

## 6. Incidente propio y su correccion (medido, no supuesto)

La PRIMERA corrida de sondas dejo `debug_menu.gd` MUTADO. Causa: mi helper
`escribir()` hacia `open(path,'wb')` in-place y reintentaba 6 veces SIN pausa;
el bloqueo del indexador/AV de Windows (OSError Errno 22) dura mas que eso, los
6 intentos fallaron y la restauracion del `finally` tambien. La sonda detecto y
aborto (exit 2) en vez de seguir, pero el archivo quedo con el defecto inyectado
en la linea 604. Restaurado con una edicion dirigida y verificado: sha256
863f33289c2e1365f2ac3e95ec92d2e3d250b4636358a03732e688e3e79a8ca4, identico al
de la sonda antes de mutar. Correccion del script: escritura a temporal +
`os.replace` (rename atomico) y restauracion con hasta 20 intentos (~30 s).
Re-corrida: 5/5 rojo, todas las restauraciones True.

Leccion para el catalogo: una sonda que muta archivos necesita restauracion
ATOMICA y con insistencia; "reintentar 6 veces" no es una garantia en Windows.

## 7. Defecto propio detectado por mi mismo antes de reportar

En el primer borrador de `debug_commands.gd`, `estadisticas` devolvia el
Dictionary de `metricas_sistema()` CRUDO (mi helper `_delegar` devuelve el dict
del host tal cual). El original hacia `str(metricas_sistema())` DENTRO de
`resultado`. Corregido antes de correr nada, y B8 ahora lo fija explicitamente:
el check exige `ok`, `comando == "estadisticas"` y `fps` dentro de `resultado`.

## 8. Items que este log NO cierra, y por que

- L114 "Integracion M64 (IA)": el dueno declarado en el propio item es M64.
  `toggle_ai_states` marca estado; el dibujado depende de M64. No es mio.
- L233 "Input Map en Project Settings": exigiria editar `project.godot`, que es
  NO TOCAR sin orden explicita. Lo que SI existe (y ya estaba) es el registro
  en runtime: `debug_menu.gd:411` hace `InputMap.add_action()` para
  `debug_menu_toggle` y `debug_menu_close` si faltan. Medido: `project.godot`
  tiene seccion `[input]` pero NINGUNA de las dos acciones. Decision del
  director: o autoriza la edicion de `project.godot`, o el item se reformula
  como "registro en runtime" y se cierra con lo que ya hay.

## 9. Flips PROPUESTOS (no aplicados)

7 items, todos con artefacto en disco y ejercitados por ruta real:
L139, L142, L176, L275, L286, L287, L288.

Aritmetica medida: 179 + 7 = 186 [x]; 46 - 7 = 39 [ ]. M110 quedaria
**186 / 39 / 0 = 225**. Los 39 restantes incluyen los 9 de la tanda del 23:33
(L132-135, L147-149, L243, L263) que siguen esperando tu GO, los 4 del informe
497 (L126, L172, L268, L274) y los 15 obsoletos.

## 10. Estado de cierre

0 commits. 0 push. 0 flips aplicados. 0 sellos automaticos.
Archivos tocados (9): 3 nuevos en `scripts/debug/` (`diagnostic_exporter.gd`,
`debug_commands.gd`, `panel_base.gd`), 2 paneles refactorizados, `debug_menu.gd`,
`debug_menu_ui.gd`, `test_refactor_m110.gd` (nuevo) y este log.
Higiene de bytes verificada en los 8 .gd: LF puro, sin BOM, sin U+FFFD.
