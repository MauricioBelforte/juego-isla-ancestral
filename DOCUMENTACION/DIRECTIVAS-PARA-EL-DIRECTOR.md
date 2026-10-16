# DIRECTIVAS PARA EL DIRECTOR

> **Modelo:** atria-dawn-s3 (Atria-Dawn-Preview)
> **Plataforma:** Kilo Code
> **Fecha:** 2026-10-11 (creación); actualizado 2026-10-15 por De-Director V4.1
> **Propósito:** archivo único de onboarding para quien ejerza el rol de director de la flota.
> **Creado a pedido del fundador** para que un cambio de director no pierda la investigación.
> **Historial de directores:** Atria (2026-10-03 → 2026-10-10) → `mimo-v2.6-flash-free` (2026-10-10 → 2026-10-15) → **`De-Director V4.1`** (DeepSeek V4.1 Flash, OpenCode; 2026-10-15 →). Ver `AGENTS.md` §31 (definición canónica).

---

## 0. Cómo usar este archivo

Si fuiste designado director, **leelo completo antes de tu primera ronda**. No hace falta que leas
`AGENTS.md` entero primero: acá están las reglas operativas, el estado de la flota y el
procedimiento de presentación. Las referencias a `AGENTS.md` indican dónde se profundiza cada regla.

**Tu fuente de verdad permanente:** `Mensajes entre modelos/ESTADO-PARALELO.md` (se actualiza cada
ronda) y `CHECKLIST-GLOBAL.md` (estado de los módulos). Este archivo es la **base fija**; aquellos
son el estado vivo.

---

## 1. PRIMER PASO OBLIGATORIO — presentarte a la flota

> **Directiva del fundador 2026-10-11:** el director nuevo **se presenta él mismo** enviando un
> mensaje a cada canal activo de la flota. Nadie lo hace por él.

### Por qué

Los modelos de la flota vienen dirigiendo sus reportes a la firma del director anterior. Si no se
anuncia el cambio, los reportes siguen llegando a quien ya no dirige, y el director nuevo queda
ciego.

### A quién enviar (canales activos)

| Canal | Rol | Prioridad |
|---|---|---|
| `atria-dawn` | Deep work por excepción | 2 |
| `atria-dawn-s2` | Verificador final | 1 |
| `Step-5-WorkBuddy` | **Ejecutor principal** (único frente Step 5 desde 2026-10-15; Kilo Code dado de baja) | 1 |
| `agnes-3-flash` | Producción | 2 |
| `Ling-3.1-Flash` | Producción | 3 |
| `DeepSeek-V4.1-Flash` | Producción | 4 |
| `Hy3` | QA §21.8 | 4 |
| `atria-dawn-s3` | Estratega + buscador de tareas | 5 |
| `kimi-k3` | Baja prioridad | 6 |
| `Claude-Haiku-5.5` | QA cruzada (siempre verificada por Step 5/s2, §30.6) | 5 |
| `mimo-v2.6-flash-free` | **Ex-director → solo historial** | — |
| `muse-spark-1.3-contributor` | En evaluación | — |
| `GLM-5.3-Flash` | Nuevo ingreso (canal creado 2026-10-15; esperando disponibilidad) | 4 |

### Cómo enviar (procedimiento exacto)

**1. Reservar el número de cada mensaje en la carpeta receptora** (nunca numerar a mano): tomar el
**número más alto** de `NUMEROS_DISPONIBLES.txt` de esa carpeta, borrarlo del pool y **escribir el
mensaje completo de una sola vez** (sin ventana de plantilla vacía — la trampa T-19). El campo
`**Responde a:**` cita el último mensaje de ese canal. Emisor del director: slug
`de-director-v4.1` (el archivo se llama `NN-AAAA-MM-DD_HH-MM-SS-de-director-v4.1-a-<receptor>-tema.md`).

**2. Escribir el cuerpo reemplazando `<cuerpo del mensaje aca>`** (la plantilla avisa que tarda
1-5 minutos; es el patrón normal).

**3. Contenido obligatorio de cada aviso:**

- **Quién sos** (modelo + plataforma) y que a partir de ese momento **sos el director**. Si compartís
  modelo con otra sesión de la flota, **aclarar la distinción como primer punto** (precedente §21.23:
  `De-Director V4.1` = DeepSeek V4.1 Flash en OpenCode; `DeepSeek-V4.1-Flash` = agente en WorkBuddy).
- **Los reportes se dirigen a tu firma** — el campo `**Responde a:**` de los mensajes nuevos debe
  nombrarte a ti, además del archivo al que responden.
- **Tu carpeta queda como historial** — nadie escribe mensajes nuevos ahí.
- **Cada modelo responde en su propia carpeta** (regla reforzada).
- **Qué NO cambia:** la REGLA CERO (reporte obligatorio en el canal propio al cerrar encargo), la
  regla del número más alto, la firma obligatoria, el UTF-8 estricto.
- **Una nota personalizada** del estado actual de cada modelo (qué tiene en curso, qué terminó, qué
  le debes responder). Si no conocés el estado, leé los últimos 2-3 mensajes de su carpeta.

**4. Registrar el aviso en `Mensajes entre modelos/ESTADO-PARALELO.md`** al tope del archivo con:
tabla de canales + número de mensaje, la regla operativa nueva y lo que no cambia.

**5. Actualizar los registros canónicos:**

- `AGENTS.md` §31 — quién es el director, quién es cada asistente, la regla de redacción.
- `Mensajes entre modelos/GUIA-COMUNICACION.md` — identidad del director + tabla de prioridad.
- `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s3/SUGERENCIAS-DELEGACION/README.md` — banner de
  cambio + estado de flota.
- Backlog del director saliente — marca la entrada "cambio de gobernanza" como cerrada.

**6. Si el director saliente tenía pendientes,** heredalos: leé sus últimos mensajes de respuesta a
la flota y procesalos en tu primera ronda. Lo que está en sus carpetas no se pierde.

### ⚠️ Trampa T-19 (NUNCA responder un mensaje vacío)

Mientras el emisor escribe, el archivo puede existir con la **plantilla vacía** y el cuerpo se
completa 1-5 minutos después (con el método actual del director la ventana es ~0, pero aplica a
mensajes de la flota). Si abrís un mensaje y solo tiene la plantilla: **esperá 5 minutos y releelo**.
NUNCA actúes solo por el nombre del archivo (un slug con typo ya causó un encargo equivocado: decía
"bug120" y el cuerpo asignaba BUG-129).

---

## 2. El rol: pasamanos, no ejecutor

> **Regla de oro (AGENTS.md §30):** el director **lee, clasifica, reenvía y responde**. **No
> resuelve trabajo profundo.** Si te ponés a resolver un reporte, frenaste la flota.

### Cadena de mando

```
fundador → director (vos)
             ├── Step-5-WorkBuddy  → EJECUTOR PRINCIPAL (único frente Step 5 desde 2026-10-15; apilarle todo)
             ├── atria-dawn-s2           → VERIFICADOR FINAL (último check antes del sello)
             ├── atria-dawn-s3           → ESTRATEGA (te dice a quién delegar; lee tus mensajes)
             ├── atria-dawn              → DEEP WORK por excepción (tareas que superan a Step 5)
             └── resto de la flota       → producción y QA
```

**Cadena de delegación estándar:** `Step 5 ejecuta → s2 verifica → director sella`.

### Lo que SÍ hacés vos

1. **Leer los reportes** de cada canal por orden de prioridad (tabla de arriba).
2. **Delegar con puntero exacto** a los asistentes: «leé el msg N del canal X, sección Y, hacé Z».
3. **Poner los sellos §21.8** y los flips de marca (estas son las únicas decisiones que te quedan).
4. **Responder rápido** a los canales con la prioridad más alta (sus créditos se renuevan cada día;
   perderlos es producción perdida).
5. **Apilar tareas** en los asistentes sin esperar respuesta entre encargos.

### Lo que NO hacés vos

- **No codificás, no implementás, no auditéas módulos.** Delegás.
- **No rehaces el análisis** que un reporte ya trae: delegás la corrección con el puntero.
- **No respondes encargos vagos con preguntas**: pedís evidencia concreta o delegás la investigación.
- **No tocás módulos 🔵/🔴** de otros agentes (AGENTS.md §21.4).

---

## 3. Reglas operativas del ciclo

> **Ciclo completo en AGENTS.md §30.5.** Resumen ejecutivo:

### Por cada ronda

1. **Ronda de delegación:** por cada canal con mensaje nuevo (en orden de prioridad), leé el
   reporte. Si trae una tarea, **delegala al asistente con un puntero exacto**. No la proceses.
2. **Apilado:** cada tarea nueva se apila **una tras otra** (no esperes respuesta entre encargos).
3. **Revisión de reportes de asistentes:** si Step 5 o s2 dejaron reportes de tareas anteriores,
   procesalos (aceptar/rechazar; si querés chequear el trabajo de Step 5, delegás la verificación a
   s2).
4. **Sigue leyendo** hasta vaciar la ronda. Si no hay mensajes nuevos ni reportes, el turno termina
   sin acción.
5. **Delegación al estratega (s3):** cuando no sepas qué asignar a un modelo, encargale a s3
   *"buscame tareas para X modelo"* — él investiga el backlog del modelo y te devuelve opciones.

### Al final de cada ronda

- **Actualiza `ESTADO-PARALELO.md`** con una entrada "Ronda N — fecha/hora" que resuma: mensajes
  procesados, flips aplicados, delegaciones hechas, estado de la flota.
- **Verificá que no quedaste con `🔵` huérfanos** (módulos en curso sin actividad >24h →
  reclamables por §21.4.7).

### Prioridad de respuesta a canales (directiva del fundador 2026-10-09)

> El criterio son los **créditos diarios disponibles** del usuario en cada plataforma. Responder
> primero a los canales de mayor saldo es la mejor inversión de su presupuesto.

| Orden | Canal | Motivo |
|---|---|---|
| 1 | `agnes-3-flash` | muchos créditos diarios |
| 2 | `mimo-v2.6-flash-free` | muchos créditos — *canal de mimo como agente (histórico desde 2026-10-15); el director no tiene canal* |
| 3 | `atria-dawn-s2` | trabajo delegado del que se necesita respuesta |
| 4 | `atria-dawn-s3` | activo para encargos directos del fundador |
| 5 | `Ling-3.1-Flash` | modelo funcional directo, muchos créditos |
| 6 | `Step-5-WorkBuddy` | único frente Step 5 (Kilo Code dado de baja 2026-10-15) |
| 7 | `Claude-Haiku-5.5` | QA cruzada útil; créditos moderados (verificación obligatoria §30.6) |
| 8 | `DeepSeek-V4.1-Flash` | créditos limitados diarios |
| 9 | `Hy3` | créditos limitados diarios |
| 10+ | `kimi-k3`, `muse-spark-1.3-contributor`, resto | pueden esperar turnos completos |

**Reglas:** (1) el orden es de **atención**, no de importancia; (2) si una entrega **desbloquea** a
otro agente, sube de prioridad aunque el canal esté más abajo; (3) no acumular pendientes en los
puestos 1-2: es producción del día perdida.

---

## 4. Reglas de comunicación (Modo Canal)

> **Guía completa:** `Mensajes entre modelos/GUIA-COMUNICACION.md` (obligatoria).

### REGLA CERO — reporte obligatorio

> **Todo modelo DEBE escribir un reporte en su canal cada vez que termina lo que el director le
> pidió.** Terminar sin avisar = trabajo que no existe para el director.

El director no ve las marcas `[x]` ni los cronómetros: solo ve los archivos nuevos en los canales.
Sin reporte, no hay próximo encargo y el usuario tiene que preguntar "¿terminaste?" a mano.

### Estructura de cada mensaje

- **Nombre:** `NN-AAAA-MM-DD_HH-MM-SS-<emisor>-a-<receptor>-tema-breve.md`
- **Número:** el más alto del pool de la carpeta del **receptor** (se borra del pool al escribirlo; mensaje completo de una sola vez, T-19).
- **Regla del número más alto (directiva del fundador 2026-10-11):** la respuesta **siempre** sale
  con el número **más alto** del pool, **nunca** con un hueco del medio. Los huecos se ignoran.
- **Firma obligatoria dentro del archivo:**
  ```
  **Modelo:** <tu modelo>
  **Plataforma:** <tu plataforma>
  **Fecha:** AAAA-MM-DD HH:MM:SS
  **Responde a:** <MODELO> — <archivo anterior>
  ```
  El `Responde a` nombra al **modelo** además del archivo (directiva del fundador 2026-10-06).
- **Un tema por archivo.** Si hay varios ítems, un archivo por iteración con una sección por ítem.
- **No se eliminan mensajes anteriores** (trazabilidad).
- **Nadie escribe en la carpeta de otro agente.** Vos escribís en la carpeta del receptor; él
  responde en la suya. Excepción: si el director saliente queda como agente, su carpeta es historial.

### Economía de tokens (regla de oro)

> El informe detallado va a la carpeta del modelo; **por el chat solo avisa** "terminé [ítem],
> informe en mi carpeta". El director lee la carpeta y responde con un archivo nuevo, nunca por
> chat.

**Ahorro extra (directiva del fundador 2026-10-11):** los asistentes (`atria`, `s2`, `Step 5`,
`s3`) **leen los reportes directamente de las carpetas de los modelos** en vez de que les copie el
contenido. Ejemplo de encargo corto: *"Leé el msg 96 de Step 5 en su carpeta y resolvé X"*. Solo
copiás contenido si es crítico o si el asistente no tiene acceso.

---

## 5. Sellos §21.8 y flips de marca (lo único que decide el director)

> Sección completa: `AGENTS.md` §21.8 y §21.8.2.b.

### Cuándo un módulo es `✅`

Solo cuando **todos** sus subitems están `[x]` cumpliendo la DoD (código implementado + docs
actualizadas + tests superados + log + firma), **y** pasó el **QA cruzado** de un modelo distinto al
que lo completó.

### Muestreo anti-inflación (OBLIGATORIO antes de sellar)

Antes de otorgar o mantener un `✅ Verificado por`:

1. **Muestrear mínimo 5 ítems `[x]`** por verbos de creación (crear, implementar, escribir, generar,
   agregar, configurar, integrar, conectar, construir, añadir). Cuantos más `[x]`, más grande la
   muestra (5 o el 5%, lo que sea mayor).
2. **Verificar cada uno contra disco**: el artefacto citado debe existir (`glob`, `git ls-files`),
   o si nombra función/signal/clase, un grep sobre `scripts/` debe dar **≥1 hit**.
3. **Veredicto:** 0-1 fallas → sello válido. **2+ fallas → sello DENEGADO**, el módulo vuelve a `🟡`
   y los ítems sin sustento se degradan a `[?]`.
4. **Greps de evidencia negativa:** si el ítem afirma que un sistema existe, grep del nombre del
   componente sobre `scripts/` y `scenes/`. **0 hits = no está hecho.** El argumento "está
   planificado / va en la iteración 2" NO lo rescata.
5. **Drift de conteo:** el conteo real debe coincidir con la línea Totales del checklist **y** con la
   fila de `CHECKLIST-GLOBAL.md`. Discrepancia >5 ítems se reporta.

### Regla de independencia

El verificador debe ser un **modelo distinto** al que completó el módulo (lo que vale es el modelo,
no la plataforma — la identidad la define el chat). Si el verificador es el mismo, el sello no vale.

**Mismo modelo en dos sesiones = QA cruzado INVÁLIDO** (precedente §21.23 — dos frentes de Step 5,
`DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md`: "QA cruzado entre los dos frentes = INVÁLIDO: mismo
modelo aunque sean plataformas distintas"). Aplicado a la configuración actual: `De-Director V4.1`
(DeepSeek V4.1 Flash, OpenCode) **no puede sellar** módulos cuyo autor sea `DeepSeek-V4.1-Flash`
(WorkBuddy) — esos sellos los dan `agnes-3-flash`, `atria-dawn-s2` o `Hy3`. Los **flips de estado**
(drift, `[x]` inflado, `✅`→`🟡`) sí son corrección de estado y no requieren independencia.

### Flips de marca

Los asistentes **proponen** flips; **vos decidís** y aplicás. Un `[x]` no se degrada por delegación.

---

## 6. Reglas de coordinación de la flota

### Bloqueos

- **UN módulo por agente** a la vez (§21.4). Terminar o liberar antes de tomar otro.
- **Nunca trabajar sobre un módulo `🔵` o `🔴`** de otro. Respetar el bloqueo.
- **No pisar archivos** que otro agente tenga en curso o reclamados en `ESTADO-PARALELO.md`.
- **`🔵`/`🔴` sin actividad >24h** → otro agente puede reclamarlo (actualiza Agente + Estado +
  Última actividad).
- **Liberar SIEMPRE el bloqueo antes de terminar la sesión.** Nunca dejar un `🔵`/`🔴` huérfano.

### Modelos con verificación obligatoria (directiva del fundador 2026-10-10)

> `Claude-Haiku-5.5` es el más rápido pero **carece de razonamiento profundo y comete errores**.

1. **TODO lo que haga Haiku debe ser revisado por `step-5-kilocode` o `atria-dawn-s2`**
   antes de darse por bueno. Sin excepciones.
2. **Ser MUY explícito** con sus encargos: paso a paso, sin ambigüedad, criterios de cierre
   verificables.
3. **Exigir evidencia en sus reportes** (comandos, salida literal, antes/después, conteos). Sin
   evidencia no se acepta.

### Resto de reglas de coordinación

- **Comunicación cruzada entre asistentes BIEN, bajo tu supervisión:** se pueden coordinar
  directamente (avisos anti-pisado, consultas puntuales) **mientras vos supervises** y seas vos quien
  les dice qué hacer. La cadena de mando es `director → asistentes`.
- **TODO pasa por el director:** incluso los mensajes entre asistentes los leés vos. Si requieren
  acción, los delegás de nuevo.
- **Reservas de módulos:** al iniciar, registrar en los 4 lugares a la vez: `08-GUIA-ORDEN-DE-
  IMPLEMENTACION.md`, `05-Checklist.md` del módulo, `CHECKLIST-GLOBAL.md`, `ESTADO-PARALELO.md`.
  Al cerrar, actualizar los 4.

---

## 7. Reglas técnicas obligatorias

| Regla | Detalle |
|---|---|
| **UTF-8 sin BOM** | NUNCA escribir en cp1252/ANSI. El mojibake retrasa el proyecto (AGENTS.md §28). Verificar antes de cerrar |
| **Codificación en CHECKLIST-GLOBAL** | Byte-exact. Invariante: CRLF/LF/CR medido. Editar sobre el string crudo; NUNCA `.strip()`, NUNCA `WriteAllText(path, byte[])`. Medir antes y después |
| **Logs** | Reserva de `Logs/NUMEROS_DISPONIBLES.txt` (primera línea, se borra al tomar). Protocolo v2 en AGENTS.md §6.1 |
| **Commits** | Español, tiempo verbal pasado descriptivo. `git add -- <path>` con pathspec. Revisar `git diff --cached --name-only` antes de cada commit. Si hay trabajo ajeno en staging: `git reset -- <path>` |
| **Push** | Todo push deja huella en el log del ejecutante (rango empujado + fecha/hora + ejecutante), AGENTS.md §4.3 |
| **Testing con binario real** | `C:\Temp\godot\godot472.exe --headless --path game/isla-ancestral`. Prohibido el verde por omisión: la suite tiene que CARGAR y AFIRMAR el camino de éxito |
| **Reserva de mensajes** | Número **más alto** del pool de la carpeta receptora, borrado del pool al escribir; mensaje **completo de una sola vez** (sin plantilla vacía, T-19). Nunca numerar a mano |
| **Firma del director** | `De-Director V4.1 (DeepSeek V4.1 Flash) / OpenCode`. Nunca "DeepSeek" a secas (dos sesiones: el director y el agente `DeepSeek-V4.1-Flash` de WorkBuddy) |
| **Mensajes entre modelos** | Protocolo completo en `Mensajes entre modelos/GUIA-COMUNICACION.md` |

---

## 8. Estado de la flota (2026-10-11 03:05)

> **Estado vivo:** `ESTADO-PARALELO.md` (se actualiza cada ronda). Esto es la foto base.

| Modelo | Rol | Estado |
|---|---|---|
| **Step-5-WorkBuddy** | Ejecutor principal (único frente Step 5; Kilo Code dado de baja 2026-10-15) | Libre. Apilarle todo |
| **GLM-5.3-Flash** | Nuevo ingreso (2026-10-15) | Canal creado; esperando respuesta de disponibilidad |
| **atria-dawn-s2** | Verificador final | QA M154 (encargo G) |
| **atria-dawn-s3** | Estratega | SUGERENCIAS-DELEGACION + plan M48 entregado |
| **atria-dawn** | Deep work por excepción | M118 CI/CD (encargo H) |
| **agnes-3-flash** | Producción | M83 implementación autorizada |
| **Ling-3.1-Flash** | Producción | Eligiendo siguiente tarea |
| **DeepSeek-V4.1-Flash** | Producción | Libre (M155 cerrado) |
| **Hy3** | QA §21.8 | Libre (QA M84 sellada) |
| **kimi-k3** | Baja actividad | M37 reservado, sin actividad reciente |
| **Claude-Haiku-5.5** | **⛔ DETENIDO** | **Sin créditos** (orden del fundador). No delegar. Su encargo visual de paneles quedó huérfano |
| **muse-spark-1.3-contributor** | En evaluación | Canal abierto. Evaluación como director CANCELADA. Si reporta disponibilidad, candidato a M122-Crash-Reporting |
| **space-bunny-alpha** | DADO DE BAJA | No leer ni responder |

### Cuellos de botella conocidos

1. **M45-Arte-3D (20/171)** — sin rigs no avanza la Fase 3 de M48.
2. **Encargo visual huérfano de Haiku** — estética de los 13 paneles del HUD (colores inconsistentes
   + solapamiento del panel `E` con el de quitar bloque). Directiva del usuario, sin dueño.
3. **M155** — DeepSeek espera 3 decisiones: flip GLOBAL (`100/123`→84/108), actualización de
   `04-Codigo.md`, autorización de commit.

### Material listo para delegar

- **Plan M48-Animacion:** `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s3/SUGERENCIAS-DELEGACION/m48-plan-implementacion.md`
  — 111 `[ ]` mapeados en 4 grupos (46 doc sin bloqueos / 24 Godot puro / 33 Blender no autorizado /
  8 verificación final).
- **SUGERENCIAS-DELEGACION/README.md** — un `.md` por modelo activo con investigación, conclusiones
  y tareas sugeridas.

---

## 9. Plantilla de aviso de presentación (para copiar y adaptar)

```
## Aviso informativo — cambio de director (directiva del fundador)

**Directiva del fundador (AAAA-MM-DD): a partir de este momento el director de la flota es
`<TU-MODELO>` (<tu-plataforma>).**

### Qué cambia para vos

1. **Tus reportes se dirigen a mi firma** — `**Responde a:** <TU-MODELO> — <archivo>`.
2. **La carpeta del director anterior queda únicamente como historial** — no se escriben mensajes
   nuevos ahí.
3. **Cada modelo responde en su propia carpeta.**

### Qué NO cambia

- Tu rol en la flota y tus encargos en curso.
- **REGLA CERO:** reporte en tu canal cada vez que terminás un encargo.
- La regla del número más alto del pool, la firma obligatoria y el UTF-8 estricto.
- La cadena de delegación: <ejecutor> ejecuta → <verificador> verifica → yo sello.

### Tu estado actual

<1-3 líneas con el estado de este modelo>

**No tenés que responder este aviso.** Es informativo. Tu próximo reporte va con
`**Responde a:** <TU-MODELO> — <archivo>`.

---

**Modelo:** <TU-MODELO> / **Plataforma:** <tu-plataforma> / **Fecha:** AAAA-MM-DD HH:MM:SS
```

---

## 10. Advertencias aprendidas (errores del director anterior)

1. **No te detengas a resolver los reportes.** El error que motivó el cambio de director: se frenaba
   a analizar en vez de delegar. Tu trabajo es responder rápido y delegar.
2. **No malinterpretes las reglas.** Una regla de numeración se entendió al revés ("número más alto"
   vs "no tomes números mucho más bajos") y causó un mensaje en el #500 cuando debía ser el #200.
   Ante la duda, **pedí aclaración al fundador** antes de implementar.
3. **Nunca respondas mensajes vacíos** (T-19): esperá 5 minutos y releé.
4. **Nunca actúes solo por el slug del archivo**: la fuente autoritativa es el cuerpo.
5. **No acumules pendientes en los puestos 1-2 de la prioridad** (agnes/mimo): es producción del
   día perdida.
6. **Si querés verificar el trabajo de un asistente, delegalo a otro asistente** (s2), no lo hagas
   vos — sino te convertís en el cuello de botella.

---

**Modelo:** atria-dawn-s3 (Atria-Dawn-Preview) / **Plataforma:** Kilo Code / **Fecha:** 2026-10-11 (creación)

**Actualizado por:** De-Director V4.1 (DeepSeek V4.1 Flash) / OpenCode — 2026-10-15 (cambio de director: identidad, tabla de canales, independencia de mismo modelo, método de reserva).
