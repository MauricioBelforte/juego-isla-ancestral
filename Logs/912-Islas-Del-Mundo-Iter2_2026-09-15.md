# Log 912 — M27 Islas del Mundo, iteración 2

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-15
**Módulo:** 27-Islas-Del-Mundo (A5)
**Reserva:** `Logs/reservas/912-DSV41F-M27.txt` (borrada al cerrar)
**Reclamo:** no aplica — la iter. 1 (Log 831) es de este mismo agente.
**Entrada:** `83 [x] · 93 [?] · 16 [ ] = 192`
**Salida:** `99 [x] · 93 [?] · 0 [ ] = 192` (+16 `[x]`, 0 `[?]` nuevos)

---

## 1. Cómo apareció

M27 estaba `🟡 Liberado (iter. 1 ✅)` con **16 `[ ]` propios** que la iter. 1 nunca
tocó, agrupados en tres bloques:

- **K — 9 edge cases.** La iter. 1 implementó el núcleo *data-driven* (definición,
  registro, props) pero **nada de la lógica de operaciones**: qué pasa si viajás
  mientras otra isla se descarga, si el barco se hunde, si el muelle salió sobre
  agua, si el guardado cae en medio de una carga, si el streaming se queda sin
  memoria.
- **A — 4 requisitos.** Catalogar y resolver los puntos de la **sección 26** del
  plan maestro (identidad de cada isla: distancia, clima, flora, fauna, NPC,
  arquitectura, música, puzzles, recompensa, narrativa).
- **M — 3 documentos.** Verificar que `01-Requerimientos.md`, `02-Analisis.md` y
  `03-Diseno.md` estén realmente completos.

**Por qué se pudo cerrar sin M10 y sin M63:** los tres bloques son **lógica pura**.
No necesitan anclas reales (M10 no existe) ni streaming (M63): necesitan una
*decisión* verificable. Eso es exactamente lo que este agente hace bien.

**Lo que NO se tocó:** los **93 `[?]`** siguen intactos y con dueño — el bloque
**E** (`IslandLoading`, 19 ítems) es de M63/M61; las anclas, de M10; el mapa, de
M54; los ids de contenido, de M50/M36/M15/M23/M19; el viaje en barco, de M28.

---

## 2. Qué se implementó (la parte verificable headless)

| Archivo | Qué resuelve | Ítems |
|---|---|---|
| `scripts/islas/island_ops.gd` | `IslandOps`: cola de operaciones de isla — 4 etapas con pesos 60/25/10/5, prioridad viaje>carga>descarga>precarga, **idempotencia por (tipo, isla)**, una sola operación en curso, cancelación por id y por isla | K2, K6 (base) |
| `scripts/islas/island_travel_guard.gd` | `IslandTravelGuard`: los 9 edge cases como decisiones puras sobre una vista de islas | K1–K9 |
| `scripts/islas/island_design_catalog.gd` | `IslandDesignCatalog`: los **26** puntos de la §26 con grupo, estado y resolución declarada + `claves_localizacion()` para M87 | A (4) |
| `scripts/islas/test_islas_m27_iter2.gd` | Suite headless de 8 bloques con marcador `_fin` y guardián anti-falso-verde | — |

### Los 9 edge cases, en una línea cada uno

| K | Decisión que codifica | Clave del diseño |
|---|---|---|
| K1 | Al navegar el borde se precarga la vecina **1 operación por frame** y con margen declarado → `no_congela` | `MAX_OPS_POR_FRAME == 1` es deliberado |
| K2 | Si el **destino** se está descargando, el viaje se **encola**, no se cancela | cancelar dejaría chunks a medio liberar |
| K3 | A pie en el mar: salvavidas dentro del radio de seguridad, respawn cozy fuera | radio 1200 m |
| K4 | Sin ancla → `ancla_pendiente` con `espera_coherente: true` → **esperar**, no bloquear | M10 puede no haber anclado aún |
| K5 | Si el muelle cayó sobre agua, `punto_seguro()` proyecta al interior del disco | `radio - playa - 1`, porque el borde exacto cae fuera por redondeo float |
| K6 | `cancelar_viaje()` limpia **ese destino**; `limpio` es por destino, no global | cancelar coral no declara libre la cola de verde |
| K7 | Guardar con cola o carga en curso → `esperar: true`, nunca `puede_guardar` | un guardado a medias pierde estado |
| K8 | `respawn_cozy()` a la isla más cercana, sobre tierra firme | cozy: nunca perder al jugador |
| K9 | `descarga_forzada()` LRU que **nunca** descarga la principal ni la actual; sólo toca `cargada` | el estado de partida es de M59 |

### Los 26 puntos de la §26

`TOTAL_PLAN := 26`, medidos sobre `DOCUMENTACION/00-PLAN-INICIAL/Plan-inicial-minimo.md`
líneas **796–821**. Cobertura: **15 resueltos** por código M27 (isla principal,
satélites, anillos, distancia, navegación, playa, puertos, biomas, flora, fauna,
recursos, música, arquitectura, puzzles, recompensa), **7 declarativos** (el
catálogo declara la intención de diseño; no hay sistema que consumir todavía) y
**4 externos** con dueño citado (M19, M23, M28).

---

## 3. Causa raíz — hallazgos medidos

### 3.1 El guardián anti-falso-verde: **se probó, no se dio por bueno** (crítico)

El proyecto tiene un modo de fallo dominante: **un error de script aborta la
función en silencio**. El bloque no corre, sus checks no se cuentan y la suite
sale "verde" con menos checks. No basta con *tener* un guardián: hay que
**demostrar que atrapa**.

Procedimiento ejecutado:

1. Sonda inyectada al abrir el bloque D: `var nulo: Node = null` + `nulo.get_name()`.
2. Corrida:

```
SCRIPT ERROR: Cannot call method 'get_name' on a null value.
[FIN] A. IslandOps (+46 checks)
[FIN] B. K1 precarga + K2 viaje (+30 checks)
[FIN] C. K3 náufrago + K8 respawn cozy (+28 checks)
[FIN] E. K6 cancelación limpia + K7 guardado (+22 checks)
...
  [FALLO] los 8 bloques se completaron (sin abortos silenciosos) — bloques que no terminaron: ["D"]
=== Resumen M27 iter.2: 210 checks, 1 fallos ===
```

3. **238 → 210 checks** (−28, exactamente el bloque D) y la suite **FALLA**
   nombrando el bloque. Sonda retirada; vuelta a 238/0.

Sin el guardián esa corrida habría reportado "0 fallos" con un bloque entero sin
ejecutar. **Ese** era el falso verde.

### 3.2 La guardia no podía cumplir su propia promesa de K9 (hueco real, corregido)

K9 promete: *"descarga forzada por memoria baja **sin perder estado de partida**"*.
El test lo verificaba con `snapshot_estado()`… y **fallaba**. Diagnóstico:

- `registro_desde_definicion()` **fijaba** `"descubierta": false, "visitada": false`.
- `vista_desde_registry()` construía la vista desde el registry pero **no leía**
  `esta_descubierta()`/`esta_visitada()`.

Resultado: el estado de partida **nunca entraba en la vista**, así que "descargar
sin perder estado" era **inverificable** — la guardia no tenía nada que perder.
La promesa era decorativa.

**Corregido:**

- `vista_desde_registry()` lee el estado de M59 por duck-typing (`has_method`).
- Nuevo `sincronizar_estado_partida(reg) -> int`: refresca `descubierta`/`visitada`
  **sin tocar** la caché (`cargada`/`ultimo_uso`); devuelve cuántas islas cambiaron.
- El test ahora prueba el **camino completo**: M59 descubre → sincroniza → la
  guardia lo ve → descarga forzada → el estado sigue intacto.

### 3.3 El checklist decía 24 puntos y el plan tiene 26

Medido sobre el plan maestro: la §26 tiene **26** puntos (líneas 796–821), no 24.
`IslandDesignCatalog` codifica 26 y **`validar()` falla si el plan deja de tener
26**: no acepta en silencio un plan distinto al que codifica. `informe()` expone
el desajuste explícitamente (`plan_dice` vs `plan_tiene`) para que se vea sin
tener que abrir el plan.

### 3.4 Sin M10 las 13 islas reales están sin ancla (medido, no supuesto)

El registry real no tiene anclas (M10 no existe): las 13 islas están en (0,0,0).
La guardia **no crashea**: `estado_destino()` devuelve `ancla_pendiente` con
`espera_coherente: true`, y `evaluar_viaje()` devuelve `accion: "esperar"` — no
"bloquear". Verificado en el bloque H con el autoload real (13/13 sin ancla).

### 3.5 Asimetría de descubrimiento en M59 (hallazgo, dueño M59/M54)

```
esta_descubierta(id) = _descubiertas.has(id) or id == ISLA_PRINCIPAL_ID
```

La isla principal está descubierta **por definición**, pero `islas_descubiertas()`
**no la lista** (devuelve sólo el set explícito). Cualquier consumidor que compare
ambas fuentes ve un desajuste: `esta_descubierta(aurora) == true` con
`islas_descubiertas() == []`. Hoy obliga a que la guardia sincronice contra el
registry y **no** contra la lista.

### 3.6 Trampas de GDScript medidas en esta iteración

1. **`as` liga más flojo que `==`.** `x == ["coral"] as Array[String]` se parsea
   como `(x == ["coral"]) as Array[String]` →
   `Parse Error: Invalid cast. Cannot convert from "bool" to "Array[String]"`.
2. **El orden de evaluación de los argumentos muerde.**
   `_check("…", ops.iniciar() == ops.pendientes()[0]["id"])` falla aunque el
   código esté bien: `iniciar()` saca la operación de `pendientes()`, así que la
   segunda lectura ve **otro** elemento.
3. **Un empate de distancia hace que "la más cercana" dependa del orden de
   iteración.** En la disposición de referencia, `nieve` y `volcanica` están
   exactamente a 5636 m de (0,0,9000). El test usa puntos **inequívocos**.
4. **`get_node_or_null()` no existe en `SceneTree`.** En modo `--script` el script
   **es** el árbol → hay que usar `root.get_node_or_null(...)`. El error es de
   parseo, no de runtime.

### 3.7 El separador `||` dentro de `Notas` desalinea `CHECKLIST-GLOBAL.md`

Al escribir la fila 27 usé `||` para separar la nota nueva de la histórica: en
markdown eso crea una **celda vacía** y la fila pasó de 11 a **15 celdas**.
Normalizado a `·`. De paso reparé la fila **68**, con el mismo drift que había
dejado mi propio cierre de M68. Verificado contra HEAD: **0 filas nuevas con
exceso**. Regla para los próximos registros: **usar `·`, no `||`**.

### 3.8 `CHECKLIST-GLOBAL.md` vuelve a tener BOM (3.ª vez)

Lo encontré **con BOM** al abrir la iteración. `git show HEAD:` no lo tiene y mi
Log 906 lo había dejado `bom=False`. Lo quité al registrar (verificado después:
`bom=False`, CRLF 221, 0 `fffd`). El generador **preserva** el fin de línea
existente: si alguien lo pasa a CRLF, queda CRLF.

---

## 4. Fix aplicado

| Fix | Archivo | Qué |
|---|---|---|
| Vista refleja el estado de partida | `island_travel_guard.gd` | `vista_desde_registry()` lee M59 por duck-typing + nuevo `sincronizar_estado_partida(reg)` |
| Proyección de K5 | `island_travel_guard.gd` | `maxf(1.0, radio - playa - 1.0)`: proyectar exactamente a `interior` dejaba el punto **fuera** del disco por redondeo (`188.000003 > 188`) |
| Contabilidad por bloque | `test_islas_m27_iter2.gd` | `_ini()` fija `_checks_marca`: antes el primer bloque reportaba `+48` incluyendo los 2 checks previos |
| 8 paréntesis faltantes | `island_design_catalog.gd` | 8 `out.append(_p(...))` sin el cierre exterior → `Parse Error` |
| Registro del catálogo | `--editor --quit` | `class_name` nuevos invisibles a `--script` hasta regenerar la caché de clases |

---

## 5. Verificación

```
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral --script res://scripts/islas/test_islas_m27_iter2.gd
```

| Corrida | Checks | Fallos | EXIT | `SCRIPT ERROR` | Bloques |
|---|---|---|---|---|---|
| 1 | 238 | 0 | 0 | 0 | 8/8 |
| 2 | 238 | 0 | 0 | 0 | 8/8 |
| 3 | 238 | 0 | 0 | 0 | 8/8 |

`-- checks por bloque: { "A": 46, "B": 30, "C": 28, "D": 28, "E": 22, "F": 25, "G": 27, "H": 29 }`
(+2 previos +1 guardián = 238)

**Regresiones:**

| Suite | Resultado |
|---|---|
| `test_islas_m27.gd` (iter. 1) | **171 checks / 0 fallos**, `EXIT 0` |
| `test_islas_headless.gd` (legacy) | **5 checks / 0 fallos**, `EXIT 0` |
| `sincronizar_islas_mapa.gd` | 4/4 islas coherentes + 9/9 POIs, `EXIT 0` |

**Verificación del checklist con la herramienta del proyecto:**

```
scripts/verificar_checklist.py → M27: [x] 99 · [ ] 0 · [?] 93   (sin inconsistencias)
```

**Higiene de bytes (§28):** los 4 archivos nuevos — `bom=False`, LF, 0 `fffd`.
`CHECKLIST-GLOBAL.md` — `bom=False` (quitado), CRLF 221, 0 `fffd`.

---

## 6. Trabajo colateral

- `06-Plan-Testings.md` y `07-Resultados-Testings.md` creados (no existían).
- Test cableado en `.github/workflows/quality.yml` junto a `test_islas_m27.gd` y
  `sincronizar_islas_mapa.gd`.
- `04-Codigo.md`: nuevas secciones **2.6–2.8** (API real de las 3 clases + tabla
  de reglas que codifican), trampas **5–8**, 3 pendientes honestos nuevos, y
  "Notas del Agente — iter. 2".
- `05-Checklist.md`: banner de cierre + sección "Iteración 4" con el detalle.
  El historial usa **viñetas simples, no `[x]`** (convención de M68/M26): meter
  `[x]` en el historial infla el denominador del verificador.
- `CHECKLIST-GLOBAL.md`: fila 27 → `🟡 Liberado (iter. 2 ✅) | 99/192`.
- `ESTADO-PARALELO.md`: bloque M27 `BLOQUEADO` → `CERRADO` + aviso final.
- `BACKLOG-MASTER.md`: fila A5 cerrada (99/192, 93/0), fila de ciclo 15, cola
  inmediata reescrita, y corregida la cifra de pendientes de A2/M68 (61 → 47).

---

## 7. Hallazgos secundarios (no resueltos, son de otros)

1. **M60 fue revertido entero por la auditoría del 2026-09-14** (`0/196`, fila
   `🟢 Disponible`): el banner dice *"agnes-2.5-flash marcó este módulo como
   completado sin verificación real. Todos los `[x]` revertidos a `[ ]`"*.
   **La reversión se llevó también mis iter. 2/iter. 3 (Log 825), que sí tenían
   test headless.** Revertir en bloque es correcto como reacción al sobre-cierre,
   pero deja 196 ítems a 0 incluyendo trabajo verificado. Dueño: quien reabra M60
   (es mi módulo A1) — hay que **re-marcar selectivamente** lo realmente
   implementado, no dejarlo en 0.
2. **Asimetría de M59** (ver 3.5) — dueño M59/M54.
3. **Los 4 puntos externos de la §26** (M19, M23, M28) siguen sin implementación:
   el catálogo los tiene atribuidos y listos para cerrar.
4. **`IslandOps`/`IslandTravelGuard` no las llama nadie.** Son lógica pura
   verificada; sin M63 (streaming) y M28 (barco) no tienen efecto en runtime.
   **No es un módulo terminado: es un módulo con la lógica de sus edge cases
   terminada.**

---

## 8. Lección transversal

**Una promesa que no se puede verificar no es una promesa: es un comentario.**
K9 decía "descargar sin perder el estado de partida" y el test pasaba por el
camino equivocado: verificaba que la guardia no perdía un estado que **nunca
había tenido**. El fallo no estaba en el código, estaba en que el estado no
llegaba nunca a la estructura que lo custodiaba.

La segunda lección: **el guardián anti-falso-verde hay que probarlo**. Un
mecanismo de seguridad no verificado es una creencia. Inyectar el fallo a
propósito (238 → 210 checks, bloque nombrado, `EXIT 1`) convierte la creencia en
evidencia.

---

## 9. Cierre del ciclo

- [x] Reserva `Logs/reservas/912-DSV41F-M27.txt` **borrada**.
- [x] `Logs/ULTIMO_NUMERO.txt` = **913** (lo tomó `glm-5.3-flash` para M66).
- [x] Fila 27 de `CHECKLIST-GLOBAL.md` → `🟡 Liberado (iter. 2 ✅) | 99/192`.
- [x] `05-Checklist.md` de M27 → 99 `[x]` / 0 `[ ]` / 93 `[?]`.
- [x] Checklist personal (`TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/27-Islas-Del-Mundo/checklist.md`)
      regenerado.
- [x] `ESTADO-PARALELO.md` con el bloque de cierre + aviso final.
- [x] `BACKLOG-MASTER.md` con la fila de ciclo 15 y la cola reescrita.
- [x] Memoria (`MEMORY.md` + log diario) y skill actualizados.
- [ ] ⏳ **QA cruzado §21.8 pendiente** (verificador ≠ autor).
- [ ] ⏳ Commits: **nada de esta iteración está commiteado** (junto con cientos
      de archivos de agentes paralelos).

---

## 10. Pendientes

| Pendiente | Dueño | Nota |
|---|---|---|
| Cablear `IslandOps` al streaming (`_process`, 1 op/frame) | M63 | la cola existe; el consumidor no |
| Consultar `evaluar_viaje()` antes de zarpar y `cancelar_viaje()` al abortar | M28 | el barco no pregunta todavía |
| Anclas reales + `re-roll` de 8 intentos | M10 | la guardia ya funciona con y sin anclas |
| Resolver la asimetría `esta_descubierta` vs `islas_descubiertas()` | M59/M54 | obliga a sincronizar contra el registry |
| Re-verificar y re-marcar selectivamente M60 (revertido a 0/196) | A1 (este agente) | incluye mis iter. 2/iter. 3 |
| Los 4 puntos externos de la §26 | M19 / M23 / M28 | atribuidos en el catálogo |
| QA cruzado §21.8 de M27 iter. 2 | otro modelo | verificador ≠ autor |
