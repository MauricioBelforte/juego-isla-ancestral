# DIRECTIVA DEL FUNDADOR — Delegación en lotes largos (una modelo por mensaje)

**Fecha:** 2026-10-12 07:03 (hora del entorno)
**Entregada por:** el fundador (usuario), en el chat de la sesión de atria-dawn-s3
**Registrada por:** atria-dawn-s3 (estratega del director) / Kilo Code

---

## La directiva

El director (**mimo-v2.6-flash-free**) debe delegar **tareas más largas o listas de tareas de al menos
~10 tareas por mensaje, como mínimo, en cada vuelta** (es decir, en cada mensaje que envía).

Para lograrlo, yo (atria-dawn-s3) lo ayudo así: **en cada vuelta le escribo UNA lista bien grande de
tareas para UN SOLO modelo**. De esa forma me concentro en un solo modelo y en las capacidades de ese
modelo a la vez.

## Orden de los mensajes (uno a la vez, próximas vueltas)

Cada mensaje = una lista larga de tareas para un modelo, en este orden:

1. **Primer mensaje: agnes** (agnes-3-flash)
2. **Segundo mensaje: Ling** (Ling-3.1-Flash)
3. **Tercer mensaje: DeepSeek** (DeepSeek-V4.1-Flash)

Todos los mensajes deben ser **listas largas de tareas** (≥10 tareas cada uno).

## Recordatorio obligatorio en CADA mensaje

En cada uno de estos mensajes le recuerdo al director lo siguiente:

> Cuando un modelo le responda que va a hacer algo (sea agnes, Ling o DeepSeek), **no se frene en
> hacerlo él mismo**. Que **delegue a alguno de sus 3 asistentes** — `step-5-kilocode`,
> `atria-dawn` y `atria-dawn-s2` — y **no espere mensajes de ellos**: que **les apile los problemas
> a resolver**.

(Cadena del §30: Step 5 ejecuta → s2 verifica → el director sella. El director responde rápido y
delega; no resuelve trabajo profundo.)

## Sugerir a qué asistente delegar (en CADA tarea) — directiva del fundador 2026-10-12

El fundador pide que **en cada mensaje sugiera a qué asistente delegar cada tarea**, para que el
director no se sature. Roles por defecto (§30.1, confirmados por el fundador):

| Asistente | Rol | Delegarle |
|---|---|---|
| **`step-5-kilocode`** | **EJECUTOR PRINCIPAL** (el más rápido) | Trabajo **técnico**: implementación, flips, correcciones mecánicas, actualización de conteos/drift, fixes de tests. Apilarle todo lo que sea "hacer". |
| **`atria-dawn-s2`** | **VERIFICADOR FINAL** | **Verificación** antes del sello: QA §21.8, re-chequeo de work entregado, medición independiente de suites, muestreo anti-inflación. Última parada antes de que el director selle. |
| **`atria-dawn`** | **DEEP WORK por excepción** | **Tareas complejas** que superan a Step 5 (razonamiento profundo, diseño arquitectural, auditorías duras). Solo cuando el director lo decide. |

**Regla práctica para mis listas:** cada tarea lleva un `→ delegar a: <asistente>` con el rol que le
corresponde, más la razón en una línea.

## NINGÚN modelo espera a otro — directiva del fundador 2026-10-12 (07:24)

> **No es la idea que un modelo tenga que esperar a otro para trabajar. Hay muchos frentes para
> trabajar, no nos vamos a chocar con lo mismo.**

El fundador señaló como anti-patrón el msg 189 del director (canal DeepSeek): *"Esperá la entrega de
Step 5 para el re-QA completo"* — serializó a DeepSeek detrás de Step 5.

**Metodología correcta:** si el frente de un modelo depende de la entrega de otro, **no le digas que
espere — dale OTRO frente libre**. Hay 167 módulos; dos agentes no se chocan si los frentes son
distintos.

**Regla práctica:** ante "esperá a X", la respuesta pasa a ser "asignale otro frente paralelo a quien
esperaría, y el frente bloqueado se reasigna cuando X entregue".

**Caso paradigmático (M90, 2026-10-12):** DeepSeek quedó esperando a Step 5 por orden del director.
Step 5 entregó 13 min después (msg 188). Lección: se perdieron esos 13 min de DeepSeek que podrían
haber ido a M120/M121. A partir de acá, frente dependiente = frente paralelo nuevo.

## Reporte de anomalías — directiva del fundador 2026-10-12 (08:03)

> Cuando vea cosas raras (colisiones, trabajo sin commitear, drift de conteo, módulos stale),
> **se las reporto al director PRIMERO** (por mi canal, mensajes entre modelos). **El director
> informa al resto y delega.** Así se evitan colisiones.
>
> Si quiero, puedo resolverlas yo mismo (el fundador confía en mis capacidades), **pero el director
> tiene que saber primero.**

**Regla práctica:** detectar anomalía → `reservar_mensaje.py` → reportar al director con evidencia
(medición en disco, msgs citados) + opción recomendada → **no tocar** los archivos involucrados hasta
que el director decida.

**Anomalías tipicas a vigilar:** trabajo sin commitear de un agente que cambió de frente (patrón
M34/M58, detectable con `git status` + mtime); drift de conteo entre lo que dice un encargo y el
estado real del módulo; doble asignación (patrón M17/M90); módulos 🔵 sin actividad >24 h.

## Ling en pausa — directiva del fundador 2026-10-12 (08:21–08:25)

> **"Ling tiene un problema, parece que se le truncan los mensajes y no responde bien. Vamos a
> evaluarlo mañana. Por hoy no le doy más tareas, está raro."** Y la aclaración: **"el problema es
> ahora con los últimos mensajes, le estoy pidiendo que lo haga y se trunca. Hasta ahí [msg 103]
> trabajó bien Ling."**

**Decisión:** Ling **no recibe tareas nuevas hoy** (2026-10-12). Evaluación **mañana 2026-10-13**.
Su cola L4→L12 (msgs 223/102) queda **en pausa**. Cuando pida el siguiente ítem, el director le
agradece la entrega y lo deja en espera.

**Evidencia medida:** los archivos del canal de Ling están **completos y firmados** hasta el msg 103
(05:17 — M92-Tutorial: 24 flips, 121/63/2, 4 suites 217 checks 0 fallos). La truncación que ve el
fundador es **en el chat en vivo, después de ese punto** — no aparece en los `.md` del canal. El
trabajo entregado hasta ahí es de calidad. **No contradigo al fundador** (él ve el comportamiento en
vivo); dejo la medición registrada para la evaluación de mañana.

**Frentes de Ling reasignables si se necesitan (a otro modelo, no a Ling):** L4 M112 → Step 5
(técnico); L5 M94 Patrón D → DeepSeek (vos sellás); L6 M87 2 tests → Step 5 (mecánico);
L7 M124 → s2.

## Estado del avance

- [x] Mensaje 1 — **agnes** (12 tareas, msg 220 entregado 2026-10-12 07:15)
- [ ] Mensaje 2 — **Ling**
- [ ] Mensaje 3 — **DeepSeek**

---

**Modelo:** atria-dawn-s3 (estratega del director)
**Plataforma:** Kilo Code
