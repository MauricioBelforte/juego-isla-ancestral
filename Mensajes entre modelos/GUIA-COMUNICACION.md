# Guía de Comunicación — Protocolo de Mensajes entre Modelos

**Modelo:** atria-Dawn-Preview (director)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-03 20:30:21

> Lectura **obligatoria** para todos los agentes y para el director. Referencia normativa de
> AGENTS.md §10 (Modo Canal) y de los backlogs personales.

---

## Regla de oro

> **El informe detallado se escribe en la carpeta del modelo. Por el chat, solo se avisa.**

Cada palabra que un agente escribe en el chat describiendo lo que hizo es un duplicado del
informe que ya está en su carpeta — y le cuesta al usuario copiarla, pegarla y reenviarla.
El protocolo existe exactamente para evitar eso.

---

## Los tres roles

### 1. El agente, al terminar un ítem

1. Escribe el informe completo en `Mensajes entre modelos/<su-modelo>/` (archivo nuevo
   numerado `NN-AAAA-MM-DD_HH-MM-SS-tema-breve.md`, con firma y `Responde a`), según las
   reglas del canal (AGENTS.md §10.2).
2. Commitea y empuja (con huella §4.3 si cierra iteración).
3. **Por el chat, dice una sola línea:**

   > terminé `[item]`, informe en mi carpeta

   Nada más. Sin veredicto, sin checks, sin commits, sin explicaciones — todo eso ya está en
   el archivo. Si abortó o quedó bloqueado, la línea es:

   > aborté `[item]`: `[motivo de una línea]`. informe en mi carpeta

### 2. El director (Atria)

Cuando el usuario le dice "fijate los que terminaron" o "terminó `<modelo>`":

1. Lee la carpeta del modelo (`git pull` previo) — los archivos nuevos desde la última
   lectura.
2. Procesa: verifica, actualiza CHECKLIST-GLOBAL, registra lo que haga falta.
3. **Responde escribiendo un archivo nuevo en la carpeta del modelo** (nunca por el chat del
   usuario): la devolución, el próximo encargo o la confirmación.
4. Le confirma al usuario, en una línea, qué respondió.

### 3. El usuario

Su único trabajo es conectar los chats:

- Al agente: **"andá a leer tu carpeta en `Mensajes entre modelos/<modelo>/`"** (y `git pull`).
- Al director: **"fijate los que terminaron"** o **"terminó `<modelo>`"**.

Sin copiar prompts largos, sin reenviar informes.

---

## Flujo completo

```
agente trabaja un item
        |
        v
escribe informe en su carpeta  (detalle completo: veredicto, log, checks, commits)
        |
        v
commit + push  (huella 4.3 si cierra iteracion)
        |
        v
chat: "termine [item], informe en mi carpeta"   <-- UNA linea
        |
        v
usuario -> director: "termino <modelo>"
        |
        v
director lee la carpeta, procesa, escribe la respuesta en la misma carpeta
        |
        v
director -> usuario: "respondido" (una linea)
        |
        v
usuario -> agente: "anda a leer tu carpeta"
        |
        v
agente lee la respuesta del director y sigue
```

---

## Ejemplos

### Correcto

> **agente:** terminé M37 exposición arte, informe en mi carpeta
> **usuario → director:** terminó kimi
> **director:** leí el informe (Log 1239, 42/0). Le respondí en su carpeta: avanza con los flujos F/G.
> **usuario → agente:** andá a leer tu carpeta
> **agente:** *(lee el 04 del director y trabaja)*

### Incorrecto (lo que esta guía elimina)

> **agente:** M37 terminado. Hice museum.tscn con 3 ExhibitSlot, el DonationService quedó
> cableado, test 42/0 fallos, commits a1b2c3 d4e5f6, también encontré que el callback de
> M36 tenía un typo y lo arreglé, y faltan los flujos F y G que son 8 items...
> *(+ 40 líneas más que el usuario tiene que copiar y pegar al director, y el director
> tiene que volver a leer)*

---

## Excepciones (cuando sí se habla por el chat)

- **Pregunta que bloquea y no admite espera:** el agente escribe el archivo en su carpeta con
  la pregunta marcada y, por el chat, una línea: **"pregunta en mi carpeta: `[la pregunta]`"**.
  Si la respuesta es corta, el director puede responder por el chat del usuario; si es larga,
  escribe en la carpeta.
- **Error crítico o dato urgente** (crash, bloqueo de otro agente): se avisa por el chat en
  una línea y se documenta en la carpeta.
- **Lo que el usuario pregunte directamente:** si el usuario hace una pregunta en el chat, se
  responde en el chat. Esta rige para los informes de cierre, no para el diálogo.

---

## Colaboración horizontal (todos leen todos los canales)

> Agregado 2026-10-04 por directiva del usuario (atria-dawn-preview / Kilo Code).

**Todos los modelos tienen acceso a TODAS las carpetas de `Mensajes entre modelos/`.** La
carpeta de cada modelo no es privada: es su hilo principal, pero el resto de la flota puede
leerla íntegramente.

Consecuencias prácticas:

1. **Se puede pedir ayuda directa entre modelos.** Si un agente no resuelve algo, el director
   puede escribirle a otro modelo: *"ayudame con X que no puedo resolver; el contexto está en
   el canal de Hy3, archivo NN"*. El modelo consultado lee esa carpeta y responde en la suya o
   en la del consultante.
2. **Se puede referenciar conversaciones ajenas.** En un mensaje a un modelo es válido citar
   archivos de otro canal (`Mensajes entre modelos/Hy3/07-...md`) como contexto — no hace falta
   copiar el contenido.
3. **El director orquesta las capacidades de cada modelo.** Cada modelo tiene fortalezas
   distintas (auditoría, medición empírica, modelado 3D, documentación); el pedido de ayuda va
   al modelo cuya capacidad mejor encaje con el problema.
4. **La escritura SÍ es cruzada: va en la carpeta del RECEPTOR.** Cuando un agente le escribe a
   otro directamente, el mensaje se deja en la carpeta del **receptor** (directiva del fundador,
   ver trampa T-8), no en la propia. Cada carpeta es el hilo de lo que ese modelo **recibe**.

**Formato del pedido de ayuda:** en la carpeta del modelo al que se le pide, con
`**Responde a:**` apuntando al archivo de contexto (propio o ajeno), y una sección
`## Pedido a <MODELO>` que diga exactamente qué se necesita y dónde está el contexto.

### Numeración de mensajes: pool por CANAL (uno propio por carpeta)

> **Cambio de método 2026-10-05 por directiva del usuario** (atria-dawn-preview / Kilo Code).
> Resuelve de raíz la trampa T-8/T-12: las colisiones de numeración, **sin** sacrificar la
> legibilidad de los hilos.

**Regla:** el número de un mensaje entre modelos sale de **
`Mensajes entre modelos/<carpeta>/NUMEROS_DISPONIBLES.txt`** — un listado propio de números
disponibles **para cada canal**. Los **logs** siguen con el pool global
(`Logs/NUMEROS_DISPONIBLES.txt`); logs y mensajes **no** comparten numeración.

**Por qué:** antes cada carpeta tenía su propia secuencia (01, 02, 03…) pero **sin listado**: se
numeraba "a ojo" listando la carpeta, y dos agentes chocaban dentro de la misma carpeta. Con un
pool **propio por canal**, el número se consume una sola vez en ese canal → imposible repetirlo,
y el hilo **sigue siendo consecutivo y legible** (01, 02, 03…).

**Historial (2026-10-05, ida y vuelta en el mismo día):**
- **Mañana:** el fundador pidió que la numeración saliera del **pool global** (mismo pool que los
  logs) para garantizar unicidad total. Funcionó: cero colisiones. **Pero** los hilos quedaron con
  numeración alta y saltarina (1331, 1335, 1336, 1347… en la misma carpeta), difícil de leer.
- **Noche (misma fecha):** el fundador revirtió: **numeración por canal con pool propio**. Los 15
  mensajes con número global se renumeraron a la secuencia de su canal (T-15), y los números se
  devolvieron al pool de logs. Los **logs** (Log 1330, 1342, 1344, 1502…) se quedaron con su
  número global: son del pool de logs.

**Consecuencia:** los números dentro de una carpeta **son consecutivos**. El orden del hilo se
sigue por el número y, ante cualquier duda, por la **fecha/hora** del nombre y el campo
`**Responde a:**`.

### Nombre de archivo: emisor → receptor (directiva del fundador)

> Agregado 2026-10-05 por directiva del usuario: poder ver de un vistazo **quién le escribe a
> quién**, sin abrir el archivo, y detectar comunicación entre modelos sin intervención del
> director.

**Formato:**

```
NN-AAAA-MM-DD_HH-MM-SS-<emisor>-a-<receptor>-tema.md
```

- `<emisor>` y `<receptor>` = **alias corto** de cada modelo (tabla abajo), en minúsculas.
- `-a-` separa emisor y receptor.
- `tema` = descripción breve en ASCII, minúsculas, palabras separadas por guiones.

**Tabla de aliases** (mantenida por el director; si entra un modelo nuevo, se agrega):

| Carpeta | Alias |
|---|---|
| `atria-dawn` (director) | `atria` |
| `atria-dawn-s2` (delegado) | `s2` |
| `DeepSeek-V4.1-Flash` | `deepseek` |
| `Hy3` | `hy3` |
| `agnes-3-flash` | `agnes` |
| `mimo-v2.6-flash-free` | `mimo` |
| `space-bunny-alpha` | `bunny` |
| `kimi-k3` | `kimi` |

**Ejemplos:**

| Archivo | Lectura |
|---|---|
| `1332-...-atria-a-deepseek-td9-2-aprobado.md` | el director → DeepSeek |
| `1329-...-bunny-a-mimo-sb11-sin-cambio.md` | space-bunny → mimo |
| `1333-...-hy3-a-atria-th6-m64-baseline.md` | Hy3 → el director |

**Los archivos anteriores no se renombran** (rompería todas las referencias cruzadas
`**Responde a:**`). La regla aplica a los mensajes **nuevos** a partir de 2026-10-05.

### Cómo reservar (obligatorio)

```bash
python scripts/reservar_mensaje.py <carpeta-receptor> <tema> [--emisor <carpeta-emisor>]
```

El script:
1. verifica que la carpeta del receptor exista (si no, lista las disponibles);
2. **lista los últimos mensajes** de esa carpeta para que el emisor sepa a cuál responde;
3. **toma el siguiente número del pool DE ESA CARPETA** (`NUMEROS_DISPONIBLES.txt` del canal) y
   lo borra (consumido para ese canal);
4. **crea el archivo** en la carpeta del receptor, con el nombre emisor→receptor y una
   plantilla con `**Modelo:**`, `**Plataforma:**`, `**Fecha:**` y `**Responde a:**` ya puestos.

El emisor solo tiene que **completar el cuerpo**. Si el número libre ya existe en la carpeta
destino (alguien commiteó sin pasar por el script), toma el siguiente automáticamente.

**No numerar a mano.** Si tu plataforma no puede correr el script, lista la carpeta destino,
elige un número **que no exista** ahí, y al terminar de escribirlo informa el número en tu
mensaje para que el coordinador lo descuente del pool.

---

## Trampa: doble asignación del mismo frente

> Agregado 2026-10-04 por atria-dawn-preview / Kilo Code (caso TerrainData, Log 1261).

**Síntoma:** el director asigna el mismo frente a dos modelos en archivos distintos (a uno a las
04:58, al otro a las 05:42) sin recordar la primera asignación. El segundo modelo llega y el
frente ya está fixeado.

**Lo que NO hay que hacer:** duplicar el fix. Dos fixes sobre el mismo archivo = conflicto de
edición + trabajo tirado + riesgo de pisarse.

**Lo que SÍ hay que hacer (protocolo):**

1. **El agente que llega segundo:** verifica de forma independiente el fix del primero
   (autor ≠ verificador, cruce §21.8 válido) y **cierra la deuda residual** que el primero no
   alcanzó. En el caso TerrainData, DeepSeek verificó el rename de agnes **y** encontró que el
   consumidor vivo (el provider M08) seguía roto por sus propios parse errors — lo fixeó y cerró
   el frente de verdad.
2. **El director:** antes de asignar un frente, **revisar los canales** de los modelos activos por
   si el frente ya fue encargado. La regla práctica: si el frente lleva más de 30 minutos
   asignado, asumir que está en marcha.

**Por qué es trampa:** el segundo agente podría (a) duplicar el trabajo, (b) reportar "ya estaba
resuelto" y cerrar sin verificar (falso verde), o (c) pisar el fix del primero. La opción (b) es
la más peligrosa: valida sin mirar.

**Registro del caso:** `Mensajes entre modelos/DeepSeek-V4.1-Flash/12-...` (verificación +
deuda residual) y `13-...` (cierre del frente por el director).

---

## Trampa: fraude de sello por log equivocado (familia Log 866)

> Agregado 2026-10-04 por atria-dawn-preview / Kilo Code (caso M130, Log 1272 de Hy3).

**Síntoma:** la columna Notas de `CHECKLIST-GLOBAL.md` (o el `05-Checklist.md`) cita
**"✅ Verificado por `<MODELO>` (Log `<NNN>`, §21.8)"** y el sello es **inválido** porque el
Log NNN, aunque existe, **no es un re-verify de ese verificador**: es un cierre del propio
autor, o un log de otro módulo. El sello §21.8 exige **verificador ≠ autor** y la cita
parece cumplirse sin cumplirlo.

**Casos detectados (4, todos del mismo origen):** M125, M79, M132 y M130 citaban
"Verificado por Hy3/WorkBuddy (Log 866, §21.8)". El Log 866 real es
`866-AGNES-ROUND3-CIERRE-MULTIPLE` — un **cierre de agnes**, no un re-verify de Hy3. Hy3
detectó el patrón de memoria tras el primer caso y lo cazó en los 4.

**Por qué es trampa:** la regla de independencia §21.8 queda aparentemente satisfecha
(hay una cita con verificador y número de log) pero **nadie verificó**. Es la forma más
silenciosa de falso verde: un `[x]` de QA que nunca existió.

**Protocolo — antes de aceptar cualquier "Verificado por X (Log NNN)":**

1. **Abrir el Log NNN** (existe en `Logs/`).
2. **Confirmar que es del verificador citado** (firma `**Modelo:**` adentro).
3. **Confirmar que es un re-verify / QA §21.8**, no un cierre o implementación del autor.
4. Si falla cualquiera de los 3 → el sello es **inválido**; eliminar el span y dejar el
   módulo en 🟡 hasta un re-verify independiente real.

**Por qué importa:** en los 4 casos los módulos figuraban "verificados" y arrastraban
sobre-cierre o deuda real. Hy3, como verificador independiente, es la defensa natural —
pero **el director debe aplicar el protocolo también** al leer la tabla global.

---

## Por qué importa

- **Economía de tokens:** el informe se escribe una vez, no dos.
- **Trazabilidad:** el historial completo de cada agente vive en su carpeta, no disperso en
  chats que no se versionan.
- **Contexto acumulado:** cada agente retoma su hilo leyendo su carpeta, sin que nadie tenga
  que reconstruirle el contexto.
- **El usuario solo conecta:** "leé tu carpeta" / "fijate los que terminaron".

---

## Trampas operacionales de la jornada 2026-10-04

Cinco trampas nuevas, todas con caso real. **El que arranca una sesión debe leerlas** — son
errores que ya le costaron tiempo a la flota.

### T-1 — Trampa del pool: usar un número de log sin borrarlo

**Caso:** Hy3 tomó el **1276** para su re-verify de M43 diciendo *"no toqué
NUMEROS_DISPONIBLES.txt porque ya estaba consumido en el working tree"*. Pero no estaba
consumido de la **lista**: seguía siendo la cabeza. space-bunny-alpha lo tomó legítimamente
(leyó la primera línea y la borró, protocolo §6.1.a correcto) → **dos logs 1276**.

**Regla:** §6.1.a no tiene excepciones. **El número se consume BORRÁNDOLO de
NUMEROS_DISPONIBLES.txt.** Si lo usás sin borrarlo, generás colisión aunque te parezca que
"ya no está". Si creés que un número ya se consumió, **verificá con Get-Content
Logs/NUMEROS_DISPONIBLES.txt** antes de usarlo.

**Resolución cuando pasa:** el de menor timestamp conserva el número; el otro toma la cabeza
actual del pool. El director lo resuelve y deja nota en el log renombrado.

### T-2 — Trampa del commit con index sucio (varios agentes en main)

**Caso:** s2 commiteó 36da09f con git add -- <path> explícito, pero el commit incluyó un
**rename ajeno** que otro agente (DeepSeek) había dejado stagedado. git add -- <path> **no
saca del index lo que ya estaba stagedado** — el commit se lleva TODO el index.

**Regla:** antes de CADA commit, ejecutar git diff --cached --name-only. Si hay archivos
ajenos stagedados → git reset -- <path> (sin tocar el working tree) y recién entonces tu
git add. Con varios agentes commiteando a main en paralelo, esto pasa seguido.

**Autorreporte:** el agente que comete el error lo reporta en su canal (como hizo s2) — no se
oculta, se documenta y se instala la corrección.

### T-3 — Trampa del parser del GLOBAL: contains('✅') en celda de estado

**Caso:** el estado de un módulo puede ser 🟡 Con dudas (Log 1130 ✅) — **contiene el emoji
✅** sin estar completo. Un parser por contains('✅') lo cuenta como módulo ✅ y reporta
violaciones de DoD que no existen (space-bunny-alpha marcó **18** violaciones en vez de **8**
por esto).

**Regla:** el estado se parsea por el **emoji inicial de la celda**, nunca por contains().

**Parientes:** los estados también llevan texto entre paréntesis (✅ Completado (P-36),
✅ Re-verificado (iter. 1)), así que tampoco sirve startswith('✅') estricto sin trim.

### T-4 — Trampa del --script headless: no asumir falso positivo

**Caso:** godot --headless --check-only --script foo.gd **no carga autoloads**, así que
"Identifier not found: EventBus" parecía falso positivo. s2 sospechó que su gate inflaba la
cuenta. **DeepSeek lo midió con sonda:** de 16 archivos que usan EventBus., solo 5 fallaban;
los otros 11 ya usaban la convención del proyecto get_node_or_null("/root/EventBus")
(172 archivos). **Eran rezagados reales de la convención. Falsos positivos: 0.**

**Regla:** "no carga autoloads" es **sospecha inicial, no veredicto**. Cada caso se decide con
sonda empírica (contar cuántos archivos del proyecto usan la convención vs. el identificador
bare). Un gate estricto bien aplicado **encuentra bugs reales** — no se afloja sin medir.

### T-5 — Trampa de editar el GLOBAL por número de línea

**Caso:** un informe citó "fila L43 = 103-Logging". Al aplicar el fix por número de línea, no
coincidía: el GLOBAL cambia de longitud con cada edición y los números de línea se mueven.

**Regla:** localizar filas del GLOBAL **por ID de módulo** (Select-String -Pattern "^\| 103 \|"),
nunca por número de línea reportado por otro agente.

**Pariente:** el encabezado del GLOBAL tiene **11 columnas** (hay una columna Recom entre
Dependencias y Agente actual) — auditar contra el encabezado real del archivo, no contra
el número que diga el encargo.

### T-6 — Trampa del EOL del GLOBAL: 53 filas "cambiadas" con contenido identico

**Caso:** despues de varias ediciones de la flota, el working tree del GLOBAL mostro **53 filas
modificadas** (106 lineas en `git diff`). Al compararlas byte a byte, **el contenido era
identico**: lo unico que cambio fue la terminacion de linea (CRLF -> LF). Resultado: CR-suelto
bajo de **218 a 170** y el invariante del director se rompio sin que nadie hubiera cambiado
una palabra.

**Por que es peligroso:** git marca cada linea como eliminada+agregada, el diff se vuelve
ilegible (53 filas de ruido), y cualquier conteo o invariant de EOL que mantenga el director
queda invalidado. Ademas, `git diff --ignore-cr-at-eol` **no siempre** vacia el diff (si las
lineas tienen `\r` en posiciones internas o el cambio es LF->CRLF puro), lo que hace pensar
que hay cambios de contenido cuando no los hay.

**Regla:** quien edite `CHECKLIST-GLOBAL.md` debe **preservar la codificacion de fin de linea
del archivo**. El invariant del director es **CRLF=231 / CR-suelto=147 / NUL=0** (CR-suelto
bajo de 218 a 147 tras T-A3+T-A4 de agnes, 2026-10-05). Despues de cada
edicion:

> **Nota (2026-10-05):** los 14 CR sueltos que bajaron de 161 a 147 fueron **normalizados a CRLF
> por T-A4** (`4efee73`, realineacion de columnas de agnes). **Eso es aceptable y beneficioso**:
> el CRCRLF suelto es un artefacto historico no intencional, y unificar a CRLF es mas sano para el
> archivo. **La normalizacion CRCRLF->CRLF esta permitida**; lo que nunca se permite es
> **romper** un CRLF (perder el `\r` o el `\n`).

```python
data = open("CHECKLIST-GLOBAL.md","rb").read()
crlf = data.count(b"\r\n")
cr   = data.count(b"\r") - crlf
assert (crlf, cr) == (231, 218)
```

Si el conteo cambio y el contenido no, **restaurar con `git checkout -- CHECKLIST-GLOBAL.md`**
(es seguro: el diff es puro EOL) y re-aplicar la edicion con el EOL correcto.

**Diagnostico para detectarlo:** si `git diff --stat` muestra `N insertions / N deletions` con
N grande y `--word-diff` no muestra cambios de palabras, es EOL.

### T-7 — Trampa del check muerto: comparacion exacta de strings en enums de celda

**Caso:** el check de `verificar_checklist.py` que valida "no `[x]` en modulos con estado
`🟡`/`⬜`" llevaba **todo el proyecto** sin dispararse ni una vez. Causa:

```python
# ANTES — NUNCA era True:
if x > 0 and estado_declarado in ("⬜", "🟢"):   # "🟢 Disponible" != "🟢"
if dudas > 0 and estado_declarado == "✅":        # "✅ Completado (P-36)" != "✅"
```

El estado del GLOBAL siempre lleva texto despues del emoji (`🟢 Disponible`, `✅ Completado
(P-36)`, `🟡 Con dudas (Log 1130 ✅)`), asi que la comparacion exacta fallaba para **todas** las
filas. El check estaba **100 % inactivo** mientras el script reportaba "SIN ALERTAS". Cuando el
fix (extraer el **emoji inicial**) se aplico, el default paso de **2 a 44 alertas — todas
reales**.

**Regla:** cualquier campo del GLOBAL que contenga un emoji debe parsearse por el **emoji
inicial de la celda**, nunca por comparacion exacta ni por `contains()`. `contains()` es peor
aun: `🟡 Con dudas (Log 1130 ✅)` **contiene** `✅` y cuenta un modulo 🟡 como ✅.

**Leccion general (la mas importante de la guia):** un check que nunca dispara **no es un check
que pasa — es un check muerto**. Si un validador reporta 0 alertas durante semanas, vale la
pena preguntarse si alguna vez pudo disparar. El "verde" sostenido es sospechoso, no
tranquilizador.

### T-8 — Coordinacion horizontal: se escribe en la carpeta del RECEPTOR (directiva del fundador)

**Regla (confirmada por el fundador 2026-10-04):** cuando un agente le escribe a otro
directamente —coordinacion horizontal, no un informe al director—, el mensaje va en la
**carpeta del RECEPTOR**, numerado como respuesta a su ultimo archivo.

**Ejemplo correcto:** space-bunny-alpha le escribe a s2 sobre el commit de SB-05 y el
territorio M151 -> el archivo va en `atria-dawn-s2/22-...coordinacion-sb05-commit-y-m151.md`
(respuesta al canal 20 de s2), **no** en la carpeta de space-bunny.

**Por que no en la carpeta del emisor:** el receptor tiene que poder encontrar los mensajes
dirigidos a el sin escanear todas las carpetas; el director los ve igual (todos leen todos los
canales).

**⚠️ La trampa (es la que nos costo dos colisiones hoy):** al escribir en una carpeta AJENA,
**hay que listar la carpeta destino antes de numerar**. El emisor no conoce el estado de esa
carpeta y es facil chocar con un numero que el receptor (o el director) ya uso.

**✅ RESUELTA de raiz (2026-10-05, directiva del usuario):** la numeracion de mensajes **salio
del pool global** (`Logs/NUMEROS_DISPONIBLES.txt`) y se reserva con
`scripts/reservar_mensaje.py`, que lista la carpeta destino, toma el numero del pool y crea el
archivo. Ver la seccion "Numeración de mensajes: pool GLOBAL" arriba. La regla de "listar antes
de numerar" sigue siendo necesaria **para saber a qué archivo se responde** (`**Responde a:**`),
pero el número en sí ya no puede chocar: el pool es la unica fuente de números del proyecto.

**Casos del dia:** tres colisiones por esto (Hy3 28x2, s2 19, s2 20x2) — todas por numerar sin
listar primero.

**Responsabilidad del director:** cuando se detecta un duplicado, renumera el archivo **mas
reciente** y, si el archivo cita su propio numero en el header, lo corrige para que coincida
con el nombre.

---

### T-9 — Trampa de la redireccion `>` de PowerShell: fuente de falsos positivos

**Caso:** space-bunny-alpha (5ª vez en 2 sesiones). Al capturar la salida de un proceso con
comando > archivo.txt desde PowerShell, el archivo se escribio en **UTF-16**. Python lo abrio
con UnicodeDecodeError, y el agente **casi reporto un crash del CLI como resultado real del
repo**. Mismo patron: Get-Content sin -Encoding UTF8, os.path.isfile transitorio, y esta
redireccion.

**Sintomas:** un resultado que parece del repo (crash, exit code, archivo vacio, mojibake) que
en realidad es un artefacto de como se leyo o escribio.

**Reglas:**
1. Para capturar salida de un proceso a archivo: **subprocess desde Python**, nunca > de
   PowerShell (que ademas impone UTF-16 y CRLF).
2. Para leer archivos del repo: Get-Content -Encoding UTF8 o [System.IO.File]::ReadAllText
   con encoding explicito. **Nunca** Get-Content a secas en este proyecto (mezcla UTF-16/UTF-8
   segun la version de PowerShell).
3. **Ante dos lecturas que se contradicen, desconfiar de la lectura, no del archivo.**

**Familia:** T-1 (pool), T-5 (numeros de linea) y T-9 (lectura) comparten la misma raiz: el
agente confia en su propia lectura antes que en el estado real del repo.

---
### T-10 -- Trampa del mojibake documentado: los literales disparan el gate que reparas

**Caso:** atria-dawn-s2 (Log 1300, 2026-10-05). Reparo 3 mojibakes reales en archivos de agentes
(space-bunny x2, atria-dawn x1) y **describio los bytes corruptos con literales mojibake** en su
aviso. Como ese aviso NO esta en `Logs/` (que `diagnosticar_mojibake.py` excluye), **sus
literales dispararon el gate que acababa de arreglar**. Cai por el clone limpio. Reescrito con
notacion `U+XXXX`.

**Regla:**
1. Para **documentar mojibake fuera de `Logs/`**, usar **siempre notacion Unicode**
   (`U+00C3+U+00A9`), nunca el literal corrupto. Dentro de `Logs/` los literales son
   legitimos (el verificador los excluye).
2. Lo mismo aplica a **cualquier documento, canal o checklist** que cite bytes corruptos como
   evidencia: la cita se convierte en una nueva instancia del defecto.

**Familia:** T-9 (redireccion de PowerShell como fuente de mojibake) y T-10 (documentar el
mojibake lo propaga). Ambas comparten raiz: el entorno de escritura es cp1252 y lo que escribis
no es lo que queres decir.

**Recurrencia (atria-dawn-s2, 2026-10-05, canales 31 y 34):** la regla escrita arriba NO
fue suficiente. El fallo no fue olvidar la notacion — fue **escribir la notacion correcta
Y el literal entre parentesis como "ejemplo"**: `U+00C2 U+00A7 (U+00C2U+00A7, doble-codificado)`.
El literal entre parentesis es el que dispara el gate, aunque la notacion este bien al lado.

**Refuerzo de la regla (version 2):**
1. La notacion `U+XXXX` es **lo unico** que se escribe. **Nunca** se anade el literal
   corrupto "para ilustrar", ni entre parentesis, ni entre backticks, ni en un bloque
   de codigo. Ni siquiera cuando se esta documentando el propio error.
2. El verificador de CI no lee intenciones: matchea bytes. Un "ejemplo" es una
   instancia nueva del defecto, punto.
3. Si hace falta mostrar la secuencia corrupta, usar **bytes hex** (`C2 A7`), que son
   ASCII puro y no disparan nada.

---
### T-11 -- Trampa del byte NUL: el invariante silencioso que nadie media

**Caso:** atria-dawn (2026-10-05). El `CHECKLIST-GLOBAL.md` tenia un **byte `\x00`** en la fila
M43 (`5×\x00 fallo(s)`) introducido por el Log 1025 (2026-09-18). Estuvo presente en **25
commits** sin que ningun agente lo detectara, porque todos los medidores de invariante contaban
CRLF / CR / LF pero **nunca NUL**. Lo encontro el invariante extendido (`NUL=1`).

**Como se cazo:** al ampliar el conteo del invariante a NUL, salio `NUL=1` en offset 189832.
Valor reconstruido contra el Log 1025 (las 5 suites non-iter6 pasaban con 0 fallos):
`5×\x00 fallo(s)` -> `5×0 fallo(s)`. Sin la fuente, un byte NUL en medio de un numero es
**indistinguible de un digito perdido para siempre**.

**Regla:**
1. Todo medidor de invariante debe contar **NUL** ademas de CRLF/CR/LF. Un solo byte NUL en un
   archivo de texto es siempre corrupcion, nunca intencional.
2. Al corregirlo, **verificar el valor original** contra el log o commit que lo introdujo
   (`git show <commit>:<archivo>` + diff contra el parent). Nunca inventar el digito.
3. El NUL es invisible para `git diff`, para lectores de texto y para la mayoria de los editores
   -- es el defecto mas silencioso del proyecto.

**Familia:** T-5 (numeros de linea) y T-6 (EOL del GLOBAL). Las tres son "el invariante que
deberias medir y no medias". Un invariante que no cuenta un tipo de byte no es un invariante.

---
### T-12 -- Trampa de la numeracion por carpeta: colisiones eternas

**Caso:** atria-dawn (2026-10-05). En una sola jornada, **11 colisiones de numeracion** en los
canales: 3 el dia anterior (T-8), 6 en la mañana (Hy3 34/36, space-bunny 09/12/13, DeepSeek 28,
s2 27) y 5 mas esa tarde (DeepSeek 38/39, agnes 41/42/43, mimo 20/21, space-bunny 23/24). El
director cayo **dos veces** en la misma trampa en la misma sesion.

**Causa de raiz:** la numeracion era **por carpeta** — cada canal reiniciaba su secuencia
(01, 02, 03...). Numerar requeria "listar la carpeta destino y elegir el siguiente libre", una
accion humana facultativa. Con 7+ agentes escribiendo en simultaneo, alguien siempre numeraba a
ojo. La regla T-8 documentaba el problema pero **no lo eliminaba**: pedirles a los agentes que
tengan cuidado no escala.

**Solucion estructural (directiva del usuario 2026-10-05):** la numeracion de mensajes **salio
del pool global** (`Logs/NUMEROS_DISPONIBLES.txt`), el mismo de los logs. Un numero se consume
una sola vez en todo el proyecto -> **es imposible que se repita**. El helper
`scripts/reservar_mensaje.py` automatiza la reserva. Ver seccion "Numeración de mensajes: pool
GLOBAL".

**Leccion general:** cuando una trampa se repite una y otra vez, la respuesta no es *recordar la
regla* ni *tener mas cuidado*. Es **cambiar el proceso para que el error sea imposible**. Si la
misma trampa aparece 3 veces, hay que eliminarla estructuralmente.

**Familia:** T-8 (coordinacion horizontal) y T-1 (pool de logs). Las tres son el mismo defecto:
un recurso compartido (numeros) con asignacion no atomica.

---

### T-13 -- Trampa de compartir numero entre log y mensaje

**Caso:** atria-dawn (2026-10-05). Hy3 cerró la re-verificación de M53 con **dos archivos**:
el mensaje al director (`Mensajes entre modelos/Hy3/1341-...-m53-reverificacion.md`) **y** el log
de QA (`Logs/1341-hy3-qa21.8-m53-reverificacion_...md`), **ambos con el número 1341**. Hy3
reservó 1341 con el helper para el mensaje y, al escribir el log, reutilizó el mismo número "porque
es la misma tarea". El verificador del pool lo marcó como cruce.

**Causa de raiz:** ambigüedad de identificación. Cuando un agente cita "Log 1341" o "mensaje 1341"
hay que aclarar cuál, y cualquier busqueda por número devuelve dos archivos. El pool unificado
existe justamente para que un número identifique **una sola cosa**.

**Regla:** **un número del pool = un archivo.** Si una tarea necesita log **y** mensaje, se
reservan **dos** números (uno para cada). El helper `reservar_mensaje.py` sirve para ambos: toma el
siguiente número del pool y crea el archivo con la plantilla — también para logs, llamándolo dos
veces.

**Resolucion del caso:** el log se renombró a **1342** (numero ya consumido del pool y libre de
archivo), se actualizó el header (`# Log 1342:`) y la unica referencia cruzada (el mensaje que lo
citaba). Detectado por `scripts/verificar_pool_numeros.py`.

---

### T-14 -- Trampa del pool corrupto: BOM + CRLF hacen invisibles numeros

**Caso:** atria-dawn (2026-10-05). agnes truncó `NUMEROS_DISPONIBLES.txt` con un script y lo
restauró con `git show HEAD:`. El restore dejó el archivo con **BOM (`EF BB BF`) + CRLF**. DeepSeek
lo cazó midiendo bytes: `git show HEAD:` daba `31 33 34 31 0A` ("1341\n", sano) y el archivo en
disco daba `EF BB BF 31 33 34 32 0D` (BOM + "1342\r").

**Consecuencia real:** con el BOM delante, la **primera línea quedaba invisible** para el
asignador (`isdigit()` falla con `\ufeff1342`) → **hueco fantasma**: al reservar, el helper saltó el
1342 y consumió el 1343. Además, un agente que leyera "la primera línea" a mano podía tomar un
número que el script no veía.

**Causa de raiz:** dos vertientes, ambas mías:
1. El restore de agnes introdujo BOM+CRLF (su plataforma escribe así).
2. **Mi propio arreglo lo empeoró:** usé
   `[System.IO.File]::WriteAllLines($p, $out, [System.Text.Encoding]::UTF8)` — ese encoding
   **escribe BOM**, y `WriteAllLines` usa `Environment.NewLine` (CRLF en Windows). Mi script de
   borrado del 1502 reintrodujo BOM+CRLF en un pool que DeepSeek había dejado limpio. Regla: para
   escribir archivos planos en este proyecto desde PowerShell, usar **siempre**
   `New-Object System.Text.UTF8Encoding($false)` (sin BOM) y normalizar a `\n` explicitamente, o
   directamente Python con `newline="\n"`.

**Solucion:** `scripts/verificar_pool_numeros.py` ahora valida no solo los cruces sino **la salud
del propio archivo** (sin BOM, CR=0). Si la verificacion falla, el pool no se puede usar hasta
normalizarlo (`python scripts/verificar_pool_numeros.py` sale 1).

**Leccion:** el invariante del pool no es solo "los numeros no se repiten" — es también "el
archivo se lee igual desde cualquier lenguaje". Un BOM es invisible para un humano y mortal para
un script.

**Familia:** T-11 (byte NUL silencioso) y §28 (codificacion UTF-8 obligatoria). Las tres son
"invariantes que nadie media hasta que rompen algo".

---

### T-15 -- Trampa del pool global para mensajes: unicidad a costa de legibilidad

**Caso:** atria-dawn (2026-10-05, ida y vuelta en el mismo dia). Por la mañana, para matar las
colisiones de numeracion (T-8/T-12), pase los mensajes al **pool global** (el mismo de los logs).
Funciono: cero colisiones. Pero los hilos quedaron asi:

```
atria-dawn-s2/  1331-...  1335-...  1336-...  1347-...
Hy3/            1333-...  1339-...  1341-...
```

Numeros altos y saltarinos **dentro de la misma carpeta**. El fundador lo revirtio esa misma
noche: *"no me gusta esa numeracion alta"* → **pool por canal**.

**Causa de raiz:** soluciones el mismo problema de dos formas opuestas:
- Pool global: unicidad total, pero el hilo pierde consecutividad (un hilo se lee
  1331, 1335, 1336, 1347).
- Pool por canal sin listado: legible, pero colisiona (T-8/T-12).

**La solucion intermedia (la que quedo):** pool **por canal** con listado propio
(`NUMEROS_DISPONIBLES.txt` dentro de cada carpeta). Conserva la consecutividad del hilo **y** la
asignacion atomica del pool. Un numero se consume una sola vez **en ese canal**.

**Migracion (2026-10-05, ejecutada por el director):** los 15 mensajes con numero global se
renumeraron a la secuencia de su canal por orden cronologico (s2: 37-40, DeepSeek: 41-45,
Hy3: 47-49, agnes: 48, mimo: 24-25). Las referencias `**Responde a:**` se reescribieron
automaticamente (script). Los **logs** se quedaron con su numero del pool global (Log 1330, 1342,
1344, 1502): ellos SI son del pool global. Los numeros 1329-1348 volvieron al pool de logs.

**Leccion general:** cuando un invariante se puede garantizar de dos formas, **la forma que
mejora la vida del lector del hilo** (numeracion consecutiva) suele ser la correcta, siempre que
no rompa el invariante. Un invariante que se cumple **a costa de** la legibilidad es una
solucion a medias. Y: si una directiva hay que revertirla en menos de 24 horas, esta bien —
mientras este documentado el por que de ambas.

---
---

**Firma de actualización:** **Modelo:** atria-dawn-preview · **Plataforma:** Kilo Code ·
**Fecha:** 2026-10-06 00:35 · **Actualización:** (1) numeración de mensajes pasa al **pool por canal** (un `NUMEROS_DISPONIBLES.txt` por carpeta; el global quedó SOLO para logs — el fundador revirtió el pool global la misma noche, T-15); (2) nombre de archivo con **emisor → receptor**
(`NN-...-<emisor>-a-<receptor>-tema.md`) para ver de un vistazo quién le escribe a quién
(directiva del fundador); (3) T-11 (byte NUL) y T-12 (numeración por carpeta) agregadas. Historial: sección "Trampas operacionales de la jornada
2026-10-04" (T-1 a T-8), con casos reales de Hy3, space-bunny-alpha, s2 y DeepSeek-V4.1-Flash. T-6/T-7 anadidos a las 22:40 (EOL del GLOBAL + check muerto). T-8 anadido a las 23:50: coordinacion horizontal en carpeta del RECEPTOR (directiva del fundador) + trampa de numerar sin listar. T-9/T-10 anadidos 2026-10-05 (redireccion PowerShell + mojibake documentado). T-13/T-14 anadidos 2026-10-05 23:55 (numero compartido log+mensaje; pool con BOM/CRLF), mas `scripts/verificar_pool_numeros.py` como verificador permanente del pool. T-15 anadido 2026-10-06 00:35 (pool global para mensajes revertido: unicidad a costa de legibilidad) + renumeracion de los 15 mensajes globales a sus canales.