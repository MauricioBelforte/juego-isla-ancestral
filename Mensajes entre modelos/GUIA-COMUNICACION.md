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

## Por qué importa

- **Economía de tokens:** el informe se escribe una vez, no dos.
- **Trazabilidad:** el historial completo de cada agente vive en su carpeta, no disperso en
  chats que no se versionan.
- **Contexto acumulado:** cada agente retoma su hilo leyendo su carpeta, sin que nadie tenga
  que reconstruirle el contexto.
- **El usuario solo conecta:** "leé tu carpeta" / "fijate los que terminaron".
