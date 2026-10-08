# Log 1279: SB-02 — Auditoría de coherencia CHECKLIST-GLOBAL.md ↔ 05-Checklist.md (NO FIX)

**Fecha:** 2026-10-04
**Hora:** 18:10:00
**Modelo:** space-bunny-alpha
**Plataforma:** Kilo Code

> **NOTA DE NUMERACIÓN (honestidad).** Este log se escribió originalmente como
> `1276-SB02-AUDITORIA-COHERENCIA-GLOBAL-2026-10-04_18-10-00.md`, porque leí la primera línea del
> pool (`Logs/NUMEROS_DISPONIBLES.txt`) y esa línea era **1276** — número que tomé y borré como
> manda el protocolo §6.1.a. **Resultó haber una COLISIÓN**: el agente **Hy3 / WorkBuddy** tomó el
> mismo 1276 para su re-verify de M43 (`Logs/1276-m43-reverify-21.8_2026-10-04.md`, que es legítimo y
> no se toca). El director resolvió la colisión reserving el **1279** del pool y renombrando este
> archivo a `1279-SB02-...`. Ajusto el header interno para que el número del título coincida con el
> del nombre de archivo y con el número efectivamente consumido del pool.
>
> **Lección (ya conocida por mí y escrita en el Log 1270):** el sistema de "leer la primera línea y
> borrarla" **no es atómico** entre agentes. Dos agentes que leen en el mismo instante toman el mismo
> número. El riesgo es real aunque el protocolo lo dé por resuelto. **Propuesta al director:** que
> la reserva sea una operación atómica (lock con `mkdir`, o que el propio
> `generar_checklist_global.py`/`verificar_checklist.py` numeren), porque con 20+ agentes las
> colisiones van a seguir apareciendo.

## Resumen

Auditoría de las 4 verificaciones del encargo (canal `03` §SB-02) sobre las **167 filas** de
`CHECKLIST-GLOBAL.md` y los **167** `05-Checklist.md` de `DOCUMENTACION/*/plan-actual/`.

> ⚠️ **RESTRICCIÓN CUMPLIDA:** tarea de **AUDITORÍA, NO FIX**. No se editó `CHECKLIST-GLOBAL.md`
> ni ningún `05-Checklist.md`. Los únicos archivos escritos son este log, el informe del canal y
> los scripts de auditoría en mi carpeta personal. Invariante de EOL del GLOBAL verificada **sin
> modificar**: `EOL=CRLF · BOM=False · CR-suelto=218` (idéntico al estado que el director declaró).

**Resultado:**

| Verificación | Resultado |
|---|---|
| (1) Drift de progreso `N/M` | **0 filas** — el GLOBAL es la fuente correcta en las 167 |
| (2) Filas mal formadas | **58 de 167 (34,7 %)** — 18 faltan celdas · 40 sobran · 6 sin `\|` final |
| (3) Violaciones DoD §21.6 | **8 módulos `✅` con trabajo pendiente** (3 con `[?]` + 5 con `[ ]`) |
| (3) `🔵`/`🔴` colgados >24 h | **0** (hay 4 en curso, todos con actividad reciente) |
| (4) Bloques `Totales` que mienten | **14 bloques en 13 módulos** (+2 falsos positivos de mi parser, ver §4) |

## Cambios Realizados

### (1) Drift de progreso: 0 — hallazgo POSITIVO

Las **167** celdas `Progreso` del GLOBAL coinciden exactamente con el conteo real de marcas
`[x]` de su `05-Checklist.md`. Verificado en las 167, sin excepción. El generador
(`scripts/generar_checklist_global.py`) está haciendo su trabajo; **el GLOBAL no es el problema**.

### (2) 58 filas mal formadas — 2 causas distintas

El encabezado real tiene **11 columnas** (el encargo decía 10): hay una columna **`Recom`**
insertada entre `Dependencias` y `Agente actual`. Audité contra el encabezado leído del archivo,
no contra el número del encargo.

| Tipo | Filas | Causa | Consecuencia al parsear por posición |
|---|---:|---|---|
| **Faltan celdas** (10 en vez de 11) | **18** | la columna `Recom` (o alguna) está vacía y se colapsó | `Agente actual` y `Última actividad` se leen **desplazados** |
| **Sobran celdas** (12 a 19) | **40** | pipes `\|` **sin escapar** dentro de la columna `Notas` | `Agente actual` y `Última actividad` reciben **basura** |
| — de las cuales **ni siquiera terminan en `\|`** | **6** | L41, L65, L101, L187, L199, L201 | no se pueden parsear igual por ningún método |

Filas más graves (más celdas de sobra):
- **L52 `111-Codigo-De-Calidad`: 19 celdas (+8)**
- **L46 `106-Seguridad`: 17 celdas (+6)**
- **L57 `116-Instalador`: 15 celdas (+4)**
- **L70 `128-Identidad-De-Marca`: 14 celdas (+3)**
- 9 filas con 13 celdas, 13 con 12 celdas.

**Peor caso illustrate:** L30 `01-Fundamentos` tiene `Agente actual='DeepSeek'` y
`Última actividad='minimax-m3 (Kilo Code)'` — **la fecha y el modelo están en columnas
equivocadas**. Cualquier herramienta que lea el GLOBAL por posición está leyendo basura en esas
58 filas.

**Nota sobre el conteo:** con la convención que respeta las filas que no terminan en `|` (la que
usa el script principal) son **58**. Con `split('|')[1:-1]` a secas son **54**. La discrepancia
la explican exactamente las 6 filas sin pipe final. **Esa ambigüedad ES el problema**: dos
parsers razonables dan dos números distintos.

### (3) Estado vs marcas — 8 violaciones de la DoD §21.6

La DoD §21.6 exige que un módulo solo sea `✅` cuando **todos** sus sub ítems están `[x]`.

**`✅` con `[?]` (3):**

| Fila | Módulo | `[?]` | Nota |
|---:|---|---:|---|
| L43 | `103-Logging` | 6 | `✅ Re-verificado (iter. 1)` |
| L46 | `106-Seguridad` | 12 | `✅ Completado (P-36)` |
| L64 | `122-Crash-Reporting` | 11 | `✅ Completado (P-36)` |

**`✅` con `[ ]` pendientes (5):**

| Fila | Módulo | `[ ]` |
|---:|---|---:|
| L74 | `131-Creditos` | **10** |
| L139 | `36-Fauna` | 2 |
| L172 | `65-Animales-IA` | 1 |
| L193 | `85-Modelos-3D-Legal` | 1 |
| L115 | `167-Isla-Raiz` | 1 (tiene sello §21.8 de hy3) |

**`🔵`/`🔴` en curso: 4, ninguna colgada** (todas con actividad ≤24 h). Sin hallazgos.

### (4) 14 bloques `Totales` que contradicen el conteo real (patrón H-D)

**Confirmados a mano** con `verificar_totales.py` (reimprime la línea exacta, el conteo real y la
celda del GLOBAL). En **todos** estos casos **el GLOBAL es correcto** y lo que miente es el bloque
`Totales` dentro del propio `05-Checklist.md`:

| Módulo | Línea | Declara | Real | GLOBAL (correcto) |
|---|---:|---|---|---|
| `02-Vision-Y-Concepto` | L231 | Compl. 162 · Pend. 10 | **0 `[x]` · 172 `[ ]`** | `0/172` |
| `03-Documentacion-Del-Proyecto` | L177 | Compl. 133 · Pend. 0 | **0 `[x]` · 133 `[ ]`** | `0/133` |
| `04-Game-Engine` | L169 | 120 ítems · Compl. 95 | **128 · 14 `[x]` · 114 `[ ]`** | `14/128` |
| `05-Lenguaje-Y-Programacion` | L137 | 102 ítems · Compl. 102 | **103 · 4 `[x]` · 99 `[ ]`** | `4/103` |
| `104-Analytics` | L152 | 100 ítems · Compl. 100 | **117 · 49 `[x]` · 68 `[ ]`** | `49/117` |
| `115-Hardware` | L222 | Compl. 68 · Pend. 3 | **69 `[x]` · 33 `[?]` · 2 `[ ]`** | `69/104` |
| `126-Marketing-Legal` | L24 **y** L300 | L24: 102/102 · L300: 101 ítems, Compl. 59 | **101 `[x]` · 0 pendientes** | `101/101` |
| `38-Economia` | L417 | Compl. 158 · No res. 6 | **164 `[x]` · 0 `[?]`** | `164/164` |
| `41-Musica` | L139 | Compl. 38 · Pend. 72 | **61 `[x]` · 49 `[ ]`** | `61/110` |
| `42-Sonido-Ambiental` | L138 | 109 ítems · Compl. 37 | **100 · 63 `[x]` · 37 `[ ]`** | `63/100` |
| `44-ASMR-Y-Feedback` | L160 | 113 ítems · Compl. 113 | **113 · 76 `[x]` · 37 `[ ]`** | `76/113` |
| `54-Mapa` | L230 | Compl. 130 · Pend. 47 | **133 `[x]` · 44 `[ ]`** | `133/177` |
| `91-Configuracion-De-Audio` | L324 | Compl. 206 · Pend. 32 | **207 `[x]` · 1 `[?]` · 31 `[ ]`** | `207/239` |

**Casos más graves — el archivo se contradice a sí mismo:**
- **`02-Vision`**: dice «162 completados» cuando **las 172 marcas están `[ ]`**.
- **`03-Documentacion`**: dice «133 completados, 0 pendientes» cuando **las 133 están `[ ]`**.
- **`44-ASMR`**: dice «113 completados, 0 pendientes» cuando hay **37 pendientes**.
- **`126-Marketing-Legal`**: **dos bloques `Totales` contradictorios** (L24 dice 102/102, L300 dice
  101 ítems con 59 completados); el real es 101 `[x]` y 0 pendientes.

**Módulos con más de un bloque `Totales` (3):** `104-Analytics` (L152, L171), `126-Marketing-Legal`
(L24, L300), `129-Merchandising` (L86, L183 — **idénticos y correctos**, no es drift).

## Archivos Modificados/Creados

### Creados (todos en mi carpeta — nada del GLOBAL ni de los checklists)
- `Logs/1279-SB02-AUDITORIA-COHERENCIA-GLOBAL-2026-10-04_18-10-00.md` — este log.
- `DOCUMENTACION/TAREAS-POR-MODELO/space-bunny-alpha/scripts-prueba/auditar_global.py` — auditoría
  automatizada de las 4 verificaciones. **Solo lectura**: nunca escribe en el repo.
- `.../scripts-prueba/verificar_totales.py` — reimprime línea `Totales` + conteo real + celda del
  GLOBAL, para separar **drift real de falso positivo del parser**.
- `.../scripts-prueba/desglose_malformadas.py` — desglosa las 58 filas por tipo.
- `.../scripts-prueba/contar_malformadas.py` — explica la discrepancia 58 vs 54 entre parsers.
- `DOCUMENTACION/TAREAS-POR-MODELO/space-bunny-alpha/BACKLOG-MASTER.md` — §Frente vigente con
  SB-01/02/03/04 (el director reasignó los números SB-02/SB-03).
- `Mensajes entre modelos/space-bunny-alpha/05-2026-10-04_18-10-00-sb02-auditoria-global.md` —
  informe al director.

### Modificados
- `Logs/NUMEROS_DISPONIBLES.txt` — **1276 tomado y borrado** — pero en colisión con Hy3; el director reasignó este log al **1279** (consumido del pool, cabeza actual **1280**).

### Explícitamente NO tocados (por restricción del director)
`CHECKLIST-GLOBAL.md` · los 167 `05-Checklist.md` · `quality.yml` · filas `🔵`/`🔴` ·
`M53` (mimo) · `M130` (Hy3).

## 4 falsos positivos MIOS que casi reporto (autocrítica)

El script automático.markó **16** bloques `Totales`; **2 son culpa del parser, no del repo**,
y las detecté verificando a mano antes de reportar:

1. **`103-Logging` L244** — mi parser tomó el `158 ítems (diseño A–M)` **parcial**; la línea
   declara `158 + 21 = **179 ítems** · Estado: **173 [x] · 6 [?] · 0 [ ]**`, que **cuadra
   perfecto**. Falso positivo.
2. **`104-Analytics` L171** — `**Totales:** Diseño: 100 ítems (documentado por B1) ·
   Implementación: 14 ítems completados` es un bloque con **semántica distinta** (diseño vs
   implementación), no un total único. Mi parser no lo puede interpretar. Falso positivo.

Además, **3 errores más de mi script** que inflaban o deformaban el informe:

| # | Error mío | Impacto en el informe | Cómo lo detecté |
|---|---|---|---|
| E1 | parseaba `**Totales:**` con `nums[0]=total, nums[1]=completados` pero comparaba `nums[0]` contra `real[x]` | reportaba **127** "Totales que mienten" en vez de 16 | un caso decía «202 completados» y el real era `173 [x]` — no cuadraba ni por casualidad |
| E2 | contaba la **tabla-leyenda** (§21.2, 7 filas con ID no numérico) como módulos | 7 filas mal formadas falsas | `filas de datos` = 174 pero solo hay 167 checklists |
| E3 | buscaba `✅` con `contains()` en la celda de estado | marcaba **18** violaciones DoD en vez de 8: los estados `🟡 Con dudas (Log 1130 ✅)` contienen `✅` | un `🟡` no puede violar DoD de `✅`; el filtro debía ser el **emoji inicial** |
| E4 | regex con alternación sin agrupar: `no resueltos\|sin resolver[^0-9]*(\d+)` | el grupo de captura solo aplicaba a la 2ª rama → `group(1) is None` → crash | traceback al ejecutar |

**Los 4 los atrapó la disciplina de verificar antes de reportar, no el script.** Un script que
reporta 127 hallazgos cuando hay 14 es peor que no tener script: entrena al director a ignorar
el informe. Guardo el mismo criterio de SB-01: **la cifra que no puedo defender con la línea
exacta del archivo, no se reporta.**

## Lo que NO hice (honestidad)

- **No arreglé nada.** Los 58+8+14 = **80 hallazgos** son de los fixes del director o de
  agnes-3-flash (Log 1186 ya hizo un pase de 6 filas).
- **No verifiqué que los `[x]` sean correctos**, solo que **los números** cuadren. Que un `[x]`
  sea merecido es otra auditoría (y de otro modelo).
- **No audité `plan-inicial/`** ni la calidad de los ítems: solo coherencia de números y estructura.
- **Cero afirmaciones visuales** (SB-02 es 100 % documental, sin visión).

## Recomendaciones para el director (por prioridad)

1. **Escapar los pipes de la columna `Notas`** (40 filas) o mover `Notas` al final con un
   delimitador que no sea `|`. Es la causa raíz de que el GLOBAL sea frágil de parsear — y el
   invariante de EOL que te preocupa es el mismo tipo de fragilidad estructural.
2. **Completar las 18 filas con 10 celdas** (columna `Recom` o agente/actividad vacíos).
3. **Bajar a `🟡` los 8 módulos `✅` con trabajo pendiente**, o resolver los `[?]`/`[ ]`.
4. **Regenerar los 14 bloques `Totales`** (el GLOBAL ya está bien; el que miente es el checklist).
   Ojo: `126-Marketing-Legal` tiene **dos** bloques contradictorios.
5. **Agregar al script `verificar_checklist.py` del proyecto** las 4 verificaciones de este log,
   para que el drift no vuelva: es exactamente lo que falla entre sesiones.