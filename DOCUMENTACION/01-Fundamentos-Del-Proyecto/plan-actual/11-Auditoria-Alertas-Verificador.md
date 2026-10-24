# 11 — Auditoría de las 42 alertas de `verificar_checklist.py` (clasificación por causa raíz)

**Módulo:** M01 Fundamentos Del Proyecto · **Iteración:** 11
**Fecha:** 2026-10-24 · **Autor:** DeepSeek-V4.1-Flash (WorkBuddy)
**Herramienta:** `scripts/auditar_alertas_verificador.py` (nueva) + `scripts/test_auditar_alertas_verificador.py` (41 checks / 0 fallos / EXIT 0 ×3, piso 41 medido)
**Alcance:** diagnóstico. **0 flips, 0 ediciones a `CHECKLIST-GLOBAL.md`, 0 commits.**

---

## 1. Qué se midió

El gate `scripts/verificar_checklist.py` corre hoy con **EXIT 1 y 42 alertas**. Publica el texto de cada alerta pero **no dice de qué familia es**: un drift de progreso real, un síntoma de fila mal formada y un falso positivo categórico del propio gate salen todos con el mismo `❌`.

Esta auditoría **no reimplementa el gate**: lo importa (`import verificar_checklist`), consume su lista de alertas y clasifica cada una contra la fila cruda de la tabla. Si el gate cambia la redacción de una alerta, el clasificador **falla en voz alta** (`exit 2`, «alerta sin clasificar») en vez de devolver una tabla incompleta y verde.

**Resultado: 42 de 42 alertas clasificadas. 0 sin clasificar. EXIT 0.**

## 2. Clasificación

| Clase | Alertas | Qué es en realidad |
|---|---|---|
| `drift_progreso_obsoleto` | **15** | La celda *Progreso* quedó vieja. Drift normal de quien trabajó el módulo sin actualizar el GLOBAL. |
| `drift_estado_sobrescrito` | **10** | La celda *Estado* fue **sobrescrita con el progreso**: el emoji se perdió y el valor nuevo quedó en la celda equivocada. |
| `estado_disponible_con_avance` | **7** | **Falso positivo categórico del gate.** `🟢` = «disponible para reclamar», no «sin empezar». |
| `colgado_timestamp_en_celda_equivocada` | **4** | La fecha **está** en la fila, en otra columna, por desplazamiento posicional. |
| `colgado_actividad_vencida` | **2** | **Reales.** `🔵` sin actividad desde hace 10 y 50 días. |
| `colgado_sin_timestamp` | **2** | 1 estructural (celda vacía por desplazamiento), 1 real (fila restaurada sin datos). |
| `drift_progreso_con_texto_anexo` | **1** | El número es **correcto**; la celda tiene prosa pegada y el gate compara por igualdad de cadena. |
| `cobertura_fila_sin_checklist` | **1** | La fila `157` no tiene checklist en disco. |
| **Total** | **42** | |

**Lectura en una línea:** de las 42 alertas, **8 no señalan ningún defecto de progreso** (7 `🟢` + 1 prosa anexa) y **5 son síntomas de filas mal formadas** (4 «ilegible» + M59). Quedan **26 drifts reales**, **2 bloqueos colgados reales** (M139, M158), **1 dato faltante real** (M104) y **1 fila sin checklist** (157): 8 + 5 + 26 + 2 + 1 + 1 = 42. Y **15 de los 26 drifts** tienen además el bloque `Totales` del propio checklist incoherente: arreglar el GLOBAL solo no reconcilia el módulo.

## 3. `drift_estado_sobrescrito` — 10 (el emoji se perdió y el valor está en la celda equivocada)

En estas filas la celda *Estado* contiene un número `x/y` en vez de un emoji. **El valor correcto ya está en la fila**, en la celda equivocada, en 6 de los 10 casos.

| id | módulo | GLOBAL dice | checklist real | celda *Estado* | celda *Progreso* | valor correcto en la fila | *Totales* del checklist | L |
|---|---|---|---|---|---|---|---|---|
| 10 | 10-Generacion-Del-Mundo | 88/106 | **90/106** | `90/106` | `88/106` | **sí** (celda Estado) | ok | 34 |
| 16 | 16-Crafting | 178/203 | **187/203** | `188/203` | `178/203` | no | **INCOHERENTE** | 110 |
| 40 | 40-Infraestructura | 175/211 | **180/211** | `180/211` | `175/211` | **sí** | ok | 143 |
| 48 | 48-Animacion | 36/123 | **43/123** | `36/123` | `36/123` | no | **INCOHERENTE** | 152 |
| 68 | 68-Transporte-Y-Navegacion | 99/131 | **103/131** | `103/131` | `99/131` | **sí** | ok | 172 |
| 72 | 72-Sistema-De-Logros | 93/185 | **108/200** | `104/196` | `93/185` | no | **INCOHERENTE** | 176 |
| 77 | 77-Online-Y-Red | 82/130 | **108/130** | `108/130` | `82/130` | **sí** | ok | 181 |
| 108 | 108-Pipeline-De-Assets | 127/205 | **202/205** | `202/205` | `127/205` | **sí** | ok | 45 |
| 138 | 138-Vertical-Slice | 120/131 | **128/131** | `128/131` | `120/131` | **sí** | ok | 81 |
| 156 | 156-Terrenos-Y-Movimiento | 221/307 | **222/307** | `221/307` | `221/307` | no | **INCOHERENTE** | 105 |

**Propuesta (decisión del director, la tabla es suya):** en las 6 recuperables, mover el valor de *Estado* a *Progreso* y reponer el emoji. En las 4 no recuperables, escribir el valor medido de la columna «checklist real».

**Aviso honesto:** el emoji original **no es recuperable del archivo** (fue sobrescrito). La columna `emoji DoD` de la tabla completa es una **reconstrucción por regla** (`[?]`/`[ ]` → 🟡; todo `[x]` → ✅), no una restauración. Si el estado previo tenía información que la regla no captura (deuda externa, QA pendiente), hay que tomarlo de `git log -S`.

## 4. `drift_progreso_obsoleto` — 15 (la celda *Estado* conserva su emoji)

| id | módulo | GLOBAL dice | checklist real | *Totales* del checklist | L |
|---|---|---|---|---|---|
| 11 | 11-Personaje-Del-Jugador | 75/123 | **78/123** | ok | 47 |
| 15 | 15-Recursos | 190/219 | **205/219** | **INCOHERENTE** | 97 |
| 17 | 17-Construccion | 104/175 | **126/175** | **INCOHERENTE** | 120 |
| 20 | 20-Sistema-De-Amistad | 80/148 | **81/149** | ok | 123 |
| 23 | 23-Historias-Secundarias | 71/105 | **73/105** | ok | 126 |
| 24 | 24-Templos-Y-Puzzles | 126/128 | **127/128** | **INCOHERENTE** | 127 |
| 27 | 27-Islas-Del-Mundo | 135/192 | **137/192** | **INCOHERENTE** | 130 |
| 45 | 45-Arte-3D | 155/171 | **157/171** | **INCOHERENTE** | 148 |
| 50 | 50-Vegetacion | 129/142 | **131/142** | **INCOHERENTE** | 154 |
| 62 | 62-Memoria | 127/150 | **145/150** | ok | 35 |
| 93 | 93-Balance | 134/134 | **137/139** | **INCOHERENTE** | 197 |
| 104 | 104-Analytics | 107/119 | **111/119** | **INCOHERENTE** | 40 |
| 139 | 139-Pre-Alpha | 133/142 | **139/142** | **INCOHERENTE** | 84 |
| 161 | 161-Diseno-Visual-De-NPCs | 126/138 | **134/138** | **INCOHERENTE** | 112 |
| 162 | 162-Dialogos-Contextuales-De-NPCs | 81/120 | **84/120** | **INCOHERENTE** | 113 |

**Tres casos no son «el GLOBAL quedó viejo», son «el módulo creció»** — cambió el **denominador**, no solo el numerador:

| módulo | total GLOBAL | total hoy | ítems agregados |
|---|---|---|---|
| 20-Sistema-De-Amistad | 148 | **149** | +1 |
| 72-Sistema-De-Logros | 185 | **200** | +15 |
| 93-Balance | 134 | **139** | +5 |

En estos tres, copiar el numerador sin corregir el denominador deja la fila mintiendo de otra forma.

## 5. `estado_disponible_con_avance` — 7: falso positivo categórico del gate

| id | módulo | `[x]` | estado |
|---|---|---|---|
| 33 | 33-Agricultura | 112 | `🟢 Disponible` |
| 56 | 56-Fotografia | 60 | `🟢 Disponible` |
| 115 | 115-Hardware | 78 | `🟢 Disponible` |
| 127 | 127-Copyright-Del-Juego | 76 | `🟢 Disponible` |
| 137 | 137-Prototipo | 118 | `🟢 Disponible` |
| 142 | 142-Release-Candidate | 129 | `🟢 Disponible` |
| 143 | 143-Lanzamiento | 111 | `🟢 Disponible` |

La regla del gate es:

```python
if x > 0 and emoji_estado in ("⬜", "🟢"):
    alertas.append("... tiene {x} items [x] pero su estado global es ...")
```

Pero `AGENTS.md` define dos ejes **ortogonales**:

| Emoji | Significado (AGENTS.md) |
|---|---|
| `🟢` | **Disponible (puede ser reclamado)** |
| `⬜` | Sin empezar |
| `🔵` / `🔴` | En curso (reclamado) |
| `✅` | Completado (DoD 21.6) |

`🟢` es el estado del **eje de reclamo**, no del **eje de avance**. Un módulo con 78/104 ítems hechos y sin dueño activo **debe** estar `🟢`. La regla lo trata como `⬜` y por eso estas 7 alertas **no se pueden cerrar sin mentir**: o se cambia el estado real del módulo, o se cambia el gate.

**Propuesta (el gate es compartido: no lo toqué):** excluir `🟢` de la comparación de avance — la condición correcta es `emoji_estado == "⬜"` y, si se quiere cubrir el eje de reclamo, una regla aparte (p. ej. `🟢` con `[?]` es legítimo; `🟢` con 0 ítems hechos es sospechoso).

## 6. Los 8 bloqueos colgados: 6 son síntoma, 2 son reales

| id | módulo | motivo del gate | fecha en la fila | celdas de la fila | clase |
|---|---|---|---|---|---|
| 17 | 17-Construccion | timestamp ilegible | **2026-10-21 20:30** (celda 8) | **10 de 11** | síntoma: falta la celda *Recom*, todo corre una columna |
| 20 | 20-Sistema-De-Amistad | timestamp ilegible | **2026-10-22 04:20** (celda 8) | **10 de 11** | síntoma: idem |
| 41 | 41-Musica | timestamp ilegible | **2026-10-16 20:20** (celda 8) | 11 de 11 | síntoma: un nombre de agente ocupa *Dependencias*; la fecha cae en *Agente actual* |
| 49 | 49-Iluminacion | timestamp ilegible | **2026-10-16 18:30** (celda 8) | 11 de 11 | síntoma: falta la celda *Agente actual* y *Notas* tiene un `\|` interno |
| 59 | 59-Guardado | sin timestamp | **2026-10-23 21:20** (celda 8) | **13 de 11** | síntoma: celda *Última actividad* vacía + 2 `\|` internos en *Notas* |
| 104 | 104-Analytics | sin timestamp | — | 11 de 11 | **real**: fila restaurada 2026-10-18 con todo `—` |
| 139 | 139-Pre-Alpha | sin actividad desde 2026-10-14 02:20 | 2026-10-14 02:20 | 11 de 11 | **real**: 10 días |
| 158 | 158-Herramientas-Y-Desbloqueo-De-Zonas | sin actividad desde 2026-09-04 03:50 | 2026-09-04 03:50 | 11 de 11 | **real**: 50 días |

Los cuatro «timestamp ilegible» **no son bloqueos colgados**: la fecha está en la fila y el gate no puede leerla porque el parser mapea **por posición**. Mismo origen que el hallazgo estructural de la §7.

**Los dos reales que necesitan dueño:** `M139` (10 días) y `M158` (50 días). `M158` lleva casi dos meses `🔵`: o se libera a `🟢`, o se reasigna. `M104` no tiene datos de actividad en la fila y su módulo sí está trabajado (111/119): la fila se restauró sin la fecha.

## 7. Hallazgo estructural: 40 de 168 filas están mal formadas

Medido con el propio gate (`--estructura`):

| Métrica | Valor |
|---|---|
| Filas de la tabla | 168 |
| Columnas del encabezado | 11 |
| Filas con celdas de más | **35** |
| Filas con celdas de menos | **5** |
| Filas que no terminan en `\|` | **27** |
| **Total mal formadas** | **40** |
| Filas con la celda *Estado* sobrescrita por un progreso | **15** |
| Filas con el emoji de estado destruido (mojibake) | **4** (45, 83, 159, 161) |

Las dos causas del desalineado, medidas en las filas afectadas:

1. **`|` sin escapar dentro de *Notas*** → celdas de más. Es la causa de las 35.
2. **Celda faltante** (típicamente *Recom* o *Agente actual*) → celdas de menos y todo corre una columna a la izquierda.

Consecuencia: el parser asigna `Agente actual` = fecha y `Última actividad` = prosa, y de ahí salen los 4 «timestamp ilegible».

**Propuesta:** realinear las 40 filas a 11 celdas (escapando `|` como `\|`). Es trabajo del director: la tabla es su archivo. El auditor da la lista exacta con línea y conteo en `--json`.

## 8. Puntos ciegos del gate que esta auditoría detectó (no los arreglé)

1. **`🟢` mal tipado como estado de avance** (§5): 7 alertas imposibles de cerrar sin mentir.
2. **Emoji de estado destruido por mojibake** en 4 filas (45, 83, 159, 161). `estado_emoji()` devuelve basura y **ambas** comprobaciones de DoD 21.6 pasan en silencio. Medido: hoy **no oculta ninguna alerta** (los estados reales son `🔵`/`🟡`, que no entran en las reglas), pero si una de esas filas fuera `✅` con `[?]`, el gate la dejaría pasar. Es ceguera **latente**, no un falso negativo activo.
3. **Prosa dentro de una celda numérica** (M73): el gate compara por igualdad de cadena, así que `63/135` + prosa se reporta como drift aunque el número sea correcto.
4. **`Totales` del checklist**: **50 de 167** checklists tienen su bloque `**Totales:**` en desacuerdo con el conteo real de marcas (**63 bloques** en total: un checklist puede tener más de uno). De las 26 alertas de drift, **15** caen en un módulo con este defecto: el GLOBAL y el checklist mienten a la vez.

## 9. Lo que NO hice (y por qué)

| No hice | Motivo |
|---|---|
| Editar `CHECKLIST-GLOBAL.md` | Archivo prohibido sin orden explícita. La tabla es del director. |
| Editar `verificar_checklist.py` | Gate compartido ya aceptado: modificarlo exige el procedimiento §21.8 y su autorización. |
| Aplicar los 26 drifts | Los aplica el director (regla vigente: los flips los propone el agente, los aplica él). |
| Commit / push | Sin autorización en esta vuelta. |

## 10. Reproducibilidad

```bash
python scripts/auditar_alertas_verificador.py                     # resumen por clase
python scripts/auditar_alertas_verificador.py --md RUTA.md --json RUTA.json
python scripts/test_auditar_alertas_verificador.py                # 41 checks, piso 41
```

Guardas de la herramienta: `exit 2` si alguna alerta queda sin clasificar (ceguera), `exit 3` si el gate no produce ninguna alerta. La suite prueba **en rojo** las dos: inyecta una alerta desconocida y exige `exit 2`; y con `--piso 9999` exige `exit 2` por piso no alcanzado. Restauración byte-exacta por sha256 de `CHECKLIST-GLOBAL.md` y `verificar_checklist.py` verificada al final de cada corrida.
