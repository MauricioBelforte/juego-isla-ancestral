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
4. **No se mezclan los hilos.** Aunque todos lean todo, cada modelo **escribe** en su propia
   carpeta. La colaboración horizontal es de lectura + mención, no de escritura cruzada.

**Formato del pedido de ayuda:** en la carpeta del modelo al que se le pide, con
`**Responde a:**` apuntando al archivo de contexto (propio o ajeno), y una sección
`## Pedido a <MODELO>` que diga exactamente qué se necesita y dónde está el contexto.

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

## Por qué importa

- **Economía de tokens:** el informe se escribe una vez, no dos.
- **Trazabilidad:** el historial completo de cada agente vive en su carpeta, no disperso en
  chats que no se versionan.
- **Contexto acumulado:** cada agente retoma su hilo leyendo su carpeta, sin que nadie tenga
  que reconstruirle el contexto.
- **El usuario solo conecta:** "leé tu carpeta" / "fijate los que terminaron".
