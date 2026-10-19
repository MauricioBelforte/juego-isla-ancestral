# Log 2016 - M62: ciclos entre servicios = 0 (medido) + aviso ::error::FALLO en los 2 gates restantes

**Agente:** DeepSeek-V4.1-Flash
**Fecha:** 2026-10-19 02:14 (GMT-3)
**Rama de metodologia:** RAMA 1 (mensaje nuevo del director: 317)
**Modulo:** M62 (Memoria) + M118-CI-CD (quality.yml)

---

## 1. Encargo del director (msg 317)

1. Commit de `quality.yml` hecho por el director (c96a4de).
2. COLA ACTIVA repuesta con REPOBLACION V3 (checkbox `[ ]`).
3. Homogeneizar: SI - los 2 `|| FAIL=1` restantes (`legal-tools`,
   `architecture-guard`) con el mismo patron `::error::FALLO <step>`, 2 lineas,
   en el mismo commit al cerrar.
4. Continuar la COLA V3 en orden.

---

## 2. Homogeneizacion de los 2 gates restantes (punto 3)

Estado previo medido: `grep -c "|| FAIL=1"` = 3 lineas, todas COMENTARIOS
(61, 503, 508); ocurrencias de CODIGO = 0 tras el cambio (verificado con
`grep ... | grep -v ':\s*#'` -> sin resultados).

Cambio (2 lineas, 1 por step; el comando queda byte-identico, solo se agrega el
aviso en el camino de fallo):

- `Verify USCO deposit gate (M127 iter. 4)` (L719):
  `python3 tools/legal/empaquetar_deposito_usco.py --check 2>&1 || { FAIL=1; echo "::error::FALLO tools/legal/empaquetar_deposito_usco.py --check"; }`
- `Auditar arquitectura de servicios y carga sincrona` (L931):
  `python scripts/auditar_arquitectura_m62.py 2>&1 || { FAIL=1; echo "::error::FALLO scripts/auditar_arquitectura_m62.py"; }`

`git diff --numstat` = `2 2` (1 archivo, 2 inserciones, 2 borrados).

### Prueba EN VERDE y EN ROJO (no heredada: medida en esta vuelta)

Harness `D:/tmp/qa318/probar_anotaciones.py`: extrae el bloque `run:` REAL del
YAML (no una copia a mano) y lo ejecuta con `bash -e` poniendo un stub de
`python3`/`python` en el PATH con el exit code pedido.

| Version | Step | Exit | Anotaciones |
|---------|------|------|-------------|
| HEAD (pre-fix) | USCO | 1 | 0 (CIEGO) |
| HEAD (pre-fix) | arquitectura M62 | 1 | 0 (CIEGO) |
| Con el fix | USCO | 0 (verde) / 1 (rojo) | 0 / 1 `::error::FALLO tools/legal/empaquetar_deposito_usco.py --check` |
| Con el fix | arquitectura M62 | 0 (verde) / 1 (rojo) | 0 / 1 `::error::FALLO scripts/auditar_arquitectura_m62.py` |

El grupo `{ FAIL=1; echo ...; }` NO se come el exit code (sigue siendo 1) y no
aborta el step antes de tiempo. Resultado del harness: **0 fallos** con el fix,
**2 fallos** contra HEAD (prueba en rojo del propio fix).

### Gates del repo tras el cambio

- `python scripts/validar_workflows.py` -> **EXIT 0**, 6 workflows validos.
- `--selftest` -> **6/6 fixtures**, EXIT 0.
- `python scripts/test_scripts.py` -> **19 PASS / 0 FAIL**.
- Bytes de `quality.yml`: 64.112 B, BOM **no**, CRLF **0**, LF **1108**,
  tabs **0**, U+FFFD **0**.

### Commit

`4f0d461` - "Se homogeneizo el aviso ::error::FALLO en los 2 gates restantes de
quality.yml" - **1 archivo, 2 inserciones, 2 borrados**, pathspec selectivo,
sin `-A`, sin `--amend`, **sin push**.

---

## 3. Item 1 de la COLA V3 (M62): ciclos entre servicios

Item del `62-Memoria/plan-actual/05-Checklist.md` L104:
"[ ] Ciclos entre servicios evitados con weakref o getters directos (sin
referencias circulares) [C] - iter. 4 (Log 1112): SIGUE ABIERTO..." con 2 SCC
(7 nodos y 2 nodos) y BUG-069.

### Medicion 1 - auditor del repo

`python scripts/auditar_arquitectura_m62.py` -> **EXIT 0**:

- 116 autoloads, **237 aristas explicitas**, **0 componentes con ciclo**.
- 10 refs fuera de orden (A2, regla de capas, todas en la lista de permitidos;
  ninguna es fallo de runtime: en `_ready()` todos los autoloads ya existen).
- Grupo B: 1.094 `.gd`, 97 funciones por frame, **0 hallazgos**.
- Grupo C: 59 scripts con `get_save_data()`, **0 hallazgos**.
- Hallazgos NUEVOS: **0**.
- Aviso del propio auditor: la entrada `A1|ThemeService,UIManager` de
  `PERMITIDOS` **ya no se observa** (excepcion muerta; el archivo mismo dice que
  se puede borrar). **NO se borro**: es un gate aceptado y el director no lo
  autorizo.

`python scripts/auditar_arquitectura_m62.py --selftest` -> **0 fallos**, con los
5 casos de ceguera ("0 ciclos no es lo mismo que no mire") en verde. El guardian
esta probado en rojo por fixtures sinteticos.

### Medicion 2 - verificacion INDEPENDIENTE (no reusa el parser del auditor)

`D:/tmp/qa318/clasificar_refs.py`: para los 116 autoloads, clasifica CADA
aparicion del nombre de otro autoload dentro de su script en (a) comentario,
(b) dentro de un literal de cadena, (c) identificador desnudo en codigo.

- 759 apariciones: **301 comentario**, **458 cadena**, **28 "codigo"**.
- Las 28 de "codigo" son **falsos positivos de nombre**: variables locales
  llamadas `eventos` (`InputMap.action_get_events`) y `hotbar`
  (`var hotbar := _get_hotbar()`), 1 linea de docstring y 1 comentario inline
  despues de `pass`. **0 referencias duras al autoload.**
- **0 `preload()`/`load()` del script de otro autoload** en los 9 servicios
  citados (los preloads de `inventario_service.gd` son sub-recursos propios:
  `inventory_slot.gd`, `container_type.gd`, `inventario_contenedor.gd`).

Conclusion medida: **todo el acceso cruzado es por `get_node_or_null("/root/X")`**
(458 casos). Es acoplamiento tardio: no retiene referencia, no puede formar un
ciclo de propiedad ni impedir la liberacion. Es exactamente el "getters directos"
que pide el item.

### Las 2 SCC del Log 1112: rotas, con cita

- SCC de 7 nodos `{CollectionRegistry, Fishing, GameTime, Inventario,
  SaveManager, TimeCalendar, Weather}`: el ciclo necesitaba aristas de
  `SaveManager` hacia `Inventario` y `Fishing`. Medido hoy en
  `scripts/saving/save_manager.gd`: **0 apariciones en codigo** de ambos nombres
  (solo comentarios: 1 y 2). Sin esas aristas el componente se abre.
- SCC de 2 nodos `{ThemeService, UIManager}`: `scripts/ui/theme/theme_service.gd`
  ya **no** referencia `UIManager` en codigo (2 apariciones, ambas en comentario,
  L64/L66, y el propio comentario documenta que esa referencia sostenia el ciclo).
  Queda `UIManager -> ThemeService` por cadena (`ui_manager.gd:460`,
  `get_node_or_null("/root/ThemeService")`), que es una arista de un solo sentido.

### Lectura honesta (lo que el item NO dice)

Si se cuentan las busquedas por ruta como aristas, el grafo de DEPENDENCIAS
sigue teniendo 1 SCC de 38 nodos (`D:/tmp/qa318/verificar_ciclos_indep.py`,
criterio permisivo). Eso es deuda de DISENO (quien llama a quien), no un ciclo
de REFERENCIAS: ningun servicio retiene al otro. El item pide "sin referencias
circulares", y eso esta medido en 0. Acyclicidad del grafo de dependencias seria
otro item (arquitectura), no este.

### Propuesta (NO aplicada: los flips los aplica el director)

- `62-Memoria/plan-actual/05-Checklist.md` **L104** -> `[x]`, con la cita:
  auditor 0 SCC / 237 aristas / selftest 0 fallos + clasificacion independiente
  458 cadenas / 0 referencias duras + las 2 SCC del Log 1112 rotas
  (`save_manager.gd` sin aristas a Inventario/Fishing en codigo;
  `theme_service.gd` sin arista a UIManager en codigo).
- BUG-069 (ciclos A1) queda sin objeto observable; A2 (orden de autoloads) sigue
  vivo como deuda de capas y no se toca.
- Limpieza sugerida (1 linea, gate): borrar `"A1|ThemeService,UIManager"` de
  `PERMITIDOS` en `scripts/auditar_arquitectura_m62.py`. **No ejecutada** sin
  orden escrita.

---

## 4. Numeracion

- Log: `reservar_log.py --reservar` -> **2016** (cabeza del pool global medida
  antes: 2016; `--estado` = 985 libres, 11 colisiones AJENAS no tocadas).
- Canal: ultimo mensaje real = **317**; pool del canal **STALE** (cabeza 316,
  por debajo del ultimo usado) -> se uso **318 = ultimo+1** (nunca el tope del
  pool) y se dejo el pool en **319..418** (100 libres, LF, sin BOM).
- Un numero = un archivo. Log y mensaje con numeros distintos.

---

## 5. Limites respetados

- 1 commit (`4f0d461`, solo `.github/workflows/quality.yml`), **0 push**.
- 0 flips aplicados por cuenta propia; 0 auto-sellos 21.8.
- `CHECKLIST-GLOBAL.md`, `AGENTS.md`, `project.godot`, `05-Checklist.md` de
  modulos y los backlogs ajenos: intactos.
- `scripts/auditar_arquitectura_m62.py`: **no modificado** (solo medido).

---

## 6. Proximo

- NN entrantes > 317.
- Si no hay mensaje nuevo: item 2 de la COLA V3
  ("[62] Sesion de referencia: 30 min de juego sin drift > 5% sobre la linea
  base") - requiere runtime/Play Mode, no headless: hay que declararlo y pedir
  criterio de aceptacion al director.
