# CRONÓMETROS VIGENTES — DEFINICIÓN EXACTA Y CÓMO LLENARLOS

> **VIGENTES (crear siempre ESTAS versiones): A v4, B v4, C 120-min v4, D v3 (+enmienda v4) y E en STANDBY.**
> Las versiones anteriores (A/B v1-v3, C v1-v4-old, D v1) quedan SOLO como HISTORIAL documentado al final — no crearlas más.

**Modelo:** GLM-5.3 Flash-Director
**Plataforma:** Kilo Code
**Fecha:** 2026-10-23 20:07 (handoff final — módigos de las tablas y estado infra; los prompts de hoy están verbatim abajo)
**Estado:** TRANSFERENCIA — TODOS los crons del director fueron APAGADOS por orden del fundador el 23oct 20:04 (salida de la sesión anterior truncada). El director de relevó debe re-montar SOLO si el fundador lo ordena, con las definiciones de las secciones 2, 3, 3bis, 3bisbis y 5-standby de ESTE archivo.

## ⚠️ HANDOFF 23oct 20:04 — lo que el relevo necesita saber PRIMERO

1. **Crons del director cesados** (ids): A `wku_167382d65001rjwVTFTFuUVoux` (no listaba al apagar — verificar), B `wku_1678114a70017DPH8ZZ7n6DSvv`, C120 `wku_16781b97b001uEmDTIF6Hkm9x9`, D `wku_16781483a001GbdakBUnfbMv8w`, E `wku_16781847d001Ca9kjSHixBppra` — borrados con cron_delete al cierre del 23oct 20:04; commit `42990c4`.
2. **Cadencia C = 120 MINUTOS** (`17 */2 * * *`, min 17 cada 2 h) — cambio del fundador 23oct 02:10. NO usar el `5,25,45` de las secciones históricas.
3. **CRON E = STANDBY**: el apilador x30 queda reemplazado de hecho por la TANDA de 10 de la sesión nueva de Beam (ritmo del fundador: tandas chicas). NO apilar sin orden del fundador.
4. **CRON F NO EXISTE** (era para G-5.3-Flash-agente — APAGADO por el fundador 23oct 05:35).
5. **Cron 12-min de Beam** (schedule `12,24,36,48 * * * *`) es PROPIO de la sesión nueva de Beam — NO recrearlo desde el director.
6. **Cron viejo de G-5.3-agente** `wku_161a9d271001F2M641rCnNuZgy` sigue PENDIENTE de baja en el panel del fundador (G-5.3 no puede cancelarlo).
7. **Pendientes inmediatos del relevo**: (a) leer y ratificar Beam 310 (TANDA bloque 1 de la sesión nueva, canal Reflection-Beam-1.0), (b) agnes 015/013 sin respuesta suya todavía, (c) 3 decisiones de GO del fundador (arranque de Beam-new session / modelo revenue headline / ~13 flags H).

---

## 1. Los cuatro cronómetros del director (reparto de minutos cada 5 min)

| Cron | Expresión cron | Dispara a las | Función |
|---|---|---|---|
| **CRON A v4** | `0,20,40 * * * *` | :00, :20, :40 | Detección por SCRIPT (`scripts/verificar_mensajes_nuevos.py`) + responder pendientes + repoblar backlogs |
| **CRON B v4** | `10,30,50 * * * *` | :10, :30, :50 | Segunda red: detección por LAG de acuses (misma lógica sin script, lógica de comparación en vivo) |
| **CRON D v3** | `15,35,55 * * * *` | :15, :35, :55 | ASIGNADOR AL DETALLE POR CAPACIDAD + contexto persistente (fundador 2026-10-20/21; ver sección 3bisbis + enmienda v4) |
| **CRON C v4 120-min** | `17 */2 * * *` | min 17 cada 2 h | GATE de padding + PRESERVACIÓN por lote + CONTEXTO PERSISTENTE (fundador 23oct 02:10: cadencia 120 min — el disparo de :05/:25/:45 quedó HISTORICO) |
| **CRON E (STANDBY)** | `3,23,43 * * * *` | :03/:23/:43 | Apilador a Beam x10 — REEMPLAZADO de hecho por la TANDA de 10 de la sesión nueva de Beam (no montar sin orden del fundador) |
| **CRON F** | — | — | **NO EXISTE** (era el apilador de G-5.3-Flash-agente, apagado 23oct 05:35) |

**Regla de reparto (vigente tras 23oct 02:10):** A (:00/:20/:40) → B (:10/:30/:50) → D (:15/:35/:55) → C (min 17 de cada 2 h) → E standby :03/:23/:43 (Beat de Beam propio: `12,24,36,48`).

---

## 2bis. CRON C v2 — ⚠️ HISTORIAL (SUPERSEDED por C v3: la Tarea 2 migró al Cron D v2)

Definición original (creado 04:41, id `wku_152778f30001fWRhXBrjKMF1MZ`) — **ya no crear:**

**TAREA 1 — COMMITS DE PRESERVACIÓN** (NUNCA push; el push solo lo ordena el fundador):
- `git status --short` agrupado por AUTOR/PROPÓSITO leyendo mensajes nuevos de la ventana y `Logs/` — un commit = un frente coherente, NUNCA mega-commit de todo.
- Verificación por grupo antes de commit: encoding §28 (fix_encoding.py --dry-run si hay daño), sin secretos, sin binarios no pedidos.
- NO TOCAR: archivos con mtime < 5 min (escritura en vuelo), módulos 🔵 de otro agente, `NUMEROS_DISPONIBLES.txt`. Prohibido push/--force/--amend.
- Mensajes de commit en español, pasado impersonal, viñetas por archivo con atribución. Si nada: "CRON C: nada para preservar".

**TAREA 2 — INVESTIGACIÓN/REPOBLACIÓN INTELIGENTE** (solo modelos activos):
- ACTIVO = escribió en su canal en las últimas 2 horas.
- Backlog < 100 pendientes → `scripts/repoblar_backlog.py` con módulos elegidos por CAPACIDAD: repetida `10-GUIA-COMPARATIVA-MODELOS.md` (Recom, dificultad 1-5) + historial de su canal. Sin delegar por descarte, sin módulos 🔵 ajenos, fuente 05-Checklist reales.
- Reporte: a quién, qué módulos, por qué su capacidad.

---

## 2. CRON A v4 — prompt EXACTO (copiar tal cual en cron_create)

```
CRON A v4 — DETECCIÓN POR SCRIPT (fundador 2026-10-19 02:38: "podes ejecutar un script que detecte si hay nuevos archivos — es porque hay mensajes que leer — tenes que corregir"):

1. EJECUTÁ PRIMERO: `python scripts/verificar_mensajes_nuevos.py` (exit 0 = al día; exit 1 = hay pendientes listados por canal). El script compara mi último acuse (slug `glm-5.3-flash-director-a-`) contra los mensajes de cada agente — sin punteros y sin filtro de receptor. NO LO IGNORES: su salida es la tarea de esta vuelta.
2. Si exit 1: para CADA pendiente listado, leé el archivo COMPLETO y RESPONDE, sacando el número del `NUMEROS_DISPONIBLES.txt` DE ESA CARPETA y borrando el número del pool (el pool lo comparten el agente y yo — regla fundador 02:27). NUNCA inventar números.
3. Si el pool de un canal está desalineado de su secuencia (primer número != máximo+1), sanéalo ANTES de escribir (regla huecos del medio jamás se reutilizan) y reporta la anomalía.
4. Actualiza el puntero .ultima-revision SOLO como estado de lectura (nunca como prueba de respuesta).
5. Escribe respuestas/apuntes/journal SIEMPRE en UTF-8 sin BOM con Python (NUNCA PowerShell Set-Content/>).

CADENCIA — REGLA CERO: solo novedad material. Si el script dice TOTAL sin responder: 0 → respondé 1 línea: 'CRON A: sin mensajes pendientes (script al día)' y cerrá. Si respondiste algo: lista corta de canales y números respondidos.

Reglas: firma GLM-5.3 Flash-Director, español, independencia §21.8, pathspec explícito, numeración SOLO del pool del canal destino.
```

---

## 3. CRON B v4 — prompt EXACTO (copiar tal cual en cron_create)

```
CRON B v4 — DETECCIÓN POR LAG DE RESPUESTA (fallo corregido 2026-10-19 02:36: el puntero mintió y las vueltas 131-133 de DS-OC quedaron horas sin acuse):

Para CADA canal de 'Mensajes entre modelos/' (agnes-3-flash, DS-V4.1-Flash-Opencode, Hy3, DeepSeek-V4.1-Flash, Step-5-WorkBuddy, Ling-3.1-Flash, G-5.3-Flash-Agente):
1. NN_MAX_DE_ÉL = el número más alto de archivo con mensaje cuyo emisor NO soy yo (todo slug que no empiece por `glm-5.3-flash-director-a-`). Sin filtro de receptor: si el emisor no soy yo, es mensaje de él.
2. MI ÚLTIMO ACUSE = el número más alto de archivo con slug `glm-5.3-flash-director-a-`.
3. LAG = NN_MAX_DE_ÉL - ÚLTIMO_ACUSE_MÍO. Si LAG > 0 hay mensajes SIN RESPONDER: leerlos COMPLETOS y responderles sacando el número del pool `NUMEROS_DISPONIBLES.txt` de esa carpeta (regla fundador: el pool lo comparten el agente y yo) — NUNCA inventar número. CONSUMIR el número en el MISMO acto de escribir (borrarlo del pool en el mismo script; entre tomar y escribir puede entrar otro mensaje y duplicar).
4. NO confíe en .ultima-revision para decidir responder: el puntero es solo estado de lectura, no prueba de acuse (fallo demostrado 02:36).
5. Tras responder: actualizar puntero SOLO de lectura.

CADENCIA — REGLA CERO: solo novedad material (mensajes respondidos en esta vuelta o anomalías de pool/numeración). Si LAG=0 en todos: 1 línea 'sin faltantes' y cerrar.
Reglas: numeración via NUMEROS_DISPONIBLES.txt del canal (consumir), UTF-8 §28 sin BOM con Python (NUNCA PowerShell), firma GLM-5.3 Flash-Director, independencia §21.8.
```

> Nota: este prompt es la versión v3 refinada (la que cubre el caso del literal que disparaba con caracteres BOM/encoding corrupto de la plataforma). El texto funcional es el mismo criterio del doc `METODO-DETECCION-V3-LAG.md`.

---

## 3bis. CRON C v4-120-min — VIGENTE (gate + preservación + contexto persistente)

- **Schedule vigente (fundador 23oct 02:10): `17 */2 * * *`** (min 17 de cada 2 h; cadencia 120-min). Última montaje hoy: id `wku_16781b97b001uEmDTIF6Hkm9x9` (cesado 20:04).
- ⚠️ La cadencia `5,25,45` del prompt de abajo quedo HISTORICA; al re-montar usa `17 */2 * * *` y titula el prompt **"CRON C v4 — GATE DE PADDING + PRESERVACIÓN + CONTEXTO PERSISTENTE (fundador 23oct)"**, añadiendo como PASO 0-bis: leer `Logs/estado_director.json` (contexto persistente, igual que A/B/D).
- PROMPT EXACTO para cron_create (con las 2 enmiendas de arriba):

```
CRON C v4 — GATE DE PADDING + PRESERVACIÓN (fundador 2026-10-19 07:40-07:50; corre a :05/:25/:45 — entre A (:00/:20/:40) y B (:10/:30/:50), sin solaparse; SIN tarea de investigación — esa es del Cron D v2 (:15/:35/:55)).

PASO 0 — GATE DE PADDING (SIEMPRE primero): `python scripts/verificar_padding_pools.py` — normaliza a 3 cifras los NUMEROS_DISPONIBLES.txt y los .ultima-revision de TODOS los canales (exit 1 = corrigió algo → reporta qué corrigió en 1 línea).

TAREA 1 — COMMITS DE PRESERVACIÓN (NUNCA push; push solo fundador):
1. `git status --short` y agrupá por AUTOR/PROPÓSITO (atribución leyendo mensajes nuevos de la ventana y Logs/). Un commit = un frente coherente, NUNCA mega-commit de todo lo que falta.
2. Verificá cada grupo antes de commit: encoding §28 (fix_encoding.py --dry-run si hay daño), sin secretos, sin binarios/capturas no pedidos.
3. NO TOCAR: archivos con mtime < 5 min (escritura en vuelo), módulos 🔵 de otro agente, NUMEROS_DISPONIBLES.txt.
4. Commits en español, pasado impersonal, viñetas con atribución. Prohibido push/--force/--amend/commits ajenos sin revisar.
5. Nada nuevo: 1 línea 'CRON C: nada para preservar'.

Reglas: numeración por pool del canal destino (3 cifras) consumida al escribir, UTF-8 Python sin BOM LF (NUNCA PowerShell), firma GLM-5.3 Flash-Director, español, pathspec explícito, independencia §21.8.
```

## 3bisbis. CRON D v3 — VIGENTE (asignador al detalle + contexto persistente)

- **PASO 0 (SIEMPRE primero)**: LEE `Logs/estado_director.json` — qué agente dijo qué, qué frentes agotados, qué trampas registradas, qué dijo el fundador. Sin esto está ciego.
- Schedule `15,35,55 * * * *` (:15/:35/:55). id vigente: `wku_15d5883b5001RKmh5bAfpNPvdw`.
- PROMPT EXACTO para cron_create:

```
CRON D v2 — ASIGNADOR AL DETALLE POR CAPACIDAD (fundador 2026-10-20 03:16: "la investigación tiene que ser al detalle, no es delegar por delegar sino analizar las capacidades y el trabajo que hay disponible para hacer, para que siempre tengan los modelos 100 tareas disponibles limpias"; corre a :15/:35/:55 — entre B (:10/:30/:50) y A (:20/:40/:00), sin solaparse).

UNA SOLA TAREA — ANÁLISIS EN DOS DIRECCIONES Y ASIGNACIÓN:
1. ACTIVO = agente que escribió en su canal en las últimas 2 h (corroborá con `python scripts/verificar_mensajes_nuevos.py`). Para cada activo cuyo backlog tenga menos de 100 pendientes contables, ANÁLISIS EN DOS DIRECCIONES:
   a) CAPACIDAD DEL AGENTE: repasá `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` (Recom + dificultad 1-5) y el HISTORIAL DE SU CANAL: qué frentes cerró bien, qué nichos demostró con QA/medición, qué le bloqueó. Su historial de tandas exitosas define su asignación.
   b) TRABAJO REAL DISPONIBLE: los 05-Checklists de los módulos candidatos y VERIFICÁ que los ítems [ ] sigan accionables HOY (no cerrados ya por otra tanda, no bloqueados por assets/vision/dueños ausentes, no [?]). Un ítem obsoleto NO es tarea limpia.
2. ASIGNÁ solo el cruce: nicho demostrado + trabajo disponible. Ejecutá con `python scripts/repoblar_backlog.py <carpeta> <módulos>` (fuente: solo 05-Checklist reales). Objetivo: 100 pendientes LIMPIAS (auditables, con fuente comentada). Si el mejor match requiere módulos 🔵 ajenos, saltalo y documentalo.
3. Si el agente activo ya está 100+ y productivo: NO toques nada — 'Nombre: al día (N pendientes), sin repoblación'.
4. Reporte 1-3 líneas por agente: a quién, qué módulos, POR QUÉ encaja.
5. PULIDO: si detectás ítems sucios en un backlog ya existente (cerrados en el 05 pero marcados [ ]; obsoletos; duplicados), limpiálos.

Reglas: numeración por pool del canal destino (3 cifras) consumida al escribir, UTF-8 Python sin BOM LF (NUNCA PowerShell), firma GLM-5.3 Flash-Director, español, pathspec explícito, independencia §21.8, NUNCA push.
```

### Ids actuales verificados (para borrar si se recrea desde cero)

| Cron | id (vigente desde 2026-10-21 17:28, recreados tras truncado de mensajes) |
|---|---|
| A v4 | `wku_15f8212f4001Zv9L8njuCCakhl` |
| C v4 | `wku_15f822a60001ZFhLlGmbYa47DI` |
| B v4 | `wku_15f824660001nilBMVsndFrWLJ` |
| D v3 | `wku_15f8264bf001vXjxuqDtReCHyL` |

Historial de ids anteriores (apagados 2026-10-21 17:24 por orden del fundador y recreados 17:28 tras truncado): A v4 `wku_15d5ab6a9001p20ji1BJIp9D2F`, C v4 `wku_15d60a8e1001rg814LLmNSZVQn`, B v4 `wku_15d60e50f001Nr5BslLXZji6sM`, D v3 `wku_15d5883b5001RKmh5bAfpNPvdw`.

## 4. Cómo crearlos (receta de relleno)

**Si tenés el tool de calendario de tu plataforma (Kilo Code):**
1. `cron_create` con `cron = "0,20,40 * * * *"` y el prompt EXACTO de la sección 2 → es el Cron A. Anotá el `id` devuelto.
2. `cron_create` con `cron = "10,30,50 * * * *"` y el prompt EXACTO de la sección 3 → es el Cron B. Anotá el `id`.
3. Verificar con `cron_list` que ambos quedaron con next-fire en las franjas correctas (A en :00/:20/:40, B en :10/:30/:50).
4. Para borrar o corregir: `cron_list` → tomar el id → `cron_delete` → `cron_create` con la nueva definición (NUNCA editar mentalmente el que corre; borrar y recrear).

**Cuotas y límites del sistema:** máximo 10 tareas programadas por sesión; una tarea vence a los 7 días de creada (recrearla después); los disparos esperan a que la sesión esté inactiva (no interrumpen una vuelta en curso).

**Si sos un AGENTE de flota sin tool de cron:** el cronómetro por especialidad se crea/apaga con instrucciones del fundador o del director en tu canal — guía de relleno para agentes: `Mensajes entre modelos/G-5.3-Flash-Agente/COMO-CREAR-TU-CRONOMETRO.md`. Reglas iguales: leer canal primero, reportar en cada vuelta (REGLA CERO), nunca agotar la cola (backlog 100+).

---



### ⚠️ CONTEXTO PERSISTENTE (fundador 2026-10-21 07:26):

TODOS los cronómetros (A v4, B v4, C v4, D v3) leen `Logs/estado_director.json` como paso 0.
Este archivo guarda: qué agente dijo qué, qué frentes están agotados, qué trampas registradas, qué acuses mandé.
Sin esto, los crons están ciegos al contexto de la sesión y repiten errores o aceptan standbys falsos.

ACCION: después de cualquier interacción con un agente o el fundador, actualizar `Logs/estado_director.json`.
### ⚠️ NOTA DE ETIQUETADO (fundador 2026-10-21 03:13)

El orden CRONOLÓGICO de disparo no es secuencial por letra:

| Orden temporal | Cron | Horario | Phase |
|---|---|---|---|
| 1º | A | :00/:20/:40 | Detecta + responde |
| 2º | C | :05/:25/:45 | Gate padding + preserva |
| 3º | B | :10/:30/:50 | Doble red detecta |
| 4º | D | :15/:35/:55 | Asigna backlog |

Las letras NO van A-B-C-D en el tiempo porque:
- C preserva items que A acaba de escribir (needed los poco tiempo despues).
- B re-verifica lo que A detectó (doble red por diseño).
- D asigna AL FINAL del ciclo (después de que B/C confirmaron que la flota está estable).

Cada response del director DEBE etiquetarse con el cron que disparó esa vuelta (revisar el receipt del task para confirmar).

## 5. Invariantes que NO se negocia en ningún cron

1. **Detección sin puntero y sin filtro de receptor** — el puntero solo es lectura; el slug del receptor se ignora (casos Hy3 259 / agnes-a-director 767-772).
2. **Número SIEMPRE del pool de la carpeta destino**, consumido en el mismo acto de escribir (100 números consecutivos libres, sin BOM, huecos del medio jamás se reutilizan).
3. **Escritura SIEMPRE Python UTF-8 sin BOM LF** — prohibido `>`, `Set-Content` (escribe UTF-16/BOM) y herramienta que corrompa UTF-8.
4. **REGLA CERO**: el cron reporta solo novedad material; si todo está al día, una línea y cerrar.
5. **Firma**: `GLM-5.3 Flash-Director / Kilo Code` (para crons del director) o la firma propia del agente (para crons de flota).
6. **Respuesta SIEMPRE en español.**## 2ter. CRON C v4 — VIGENTE (gate + preservación; la investigación migró al Cron D)

- Schedule `5,25,45 * * * *` (:05/:25/:45). id vigente: `wku_15328f93e001PhUjkn0a77455W`.
- PROMPT EXACTO para cron_create:

```
CRON C v4 — GATE DE PADDING + PRESERVACIÓN (fundador 2026-10-19 07:40-07:50; corre a :05/:25/:45 — entre A (:00/:20/:40) y B (:10/:30/:50), sin solaparse; SIN tarea de investigación — esa migra al Cron D).

PASO 0 — GATE DE PADDING (SIEMPRE primero): `python scripts/verificar_padding_pools.py` — normaliza a 3 cifras los NUMEROS_DISPONIBLES.txt y los .ultima-revision de TODOS los canales (exit 1 = corrigió algo → reporta qué corrigió en 1 línea).

TAREA 1 — COMMITS DE PRESERVACIÓN (NUNCA push; push solo fundador):
1. `git status --short` y agrupá por AUTOR/PROPÓSITO (atribución leyendo mensajes nuevos de la ventana y Logs/). Un commit = un frente coherente, NUNCA mega-commit de todo lo que falta.
2. Verificá cada grupo antes de commit: encoding §28 (fix_encoding.py --dry-run si hay daño), sin secretos, sin binarios/capturas no pedidos.
3. NO TOCAR: archivos con mtime < 5 min (escritura en vuelo), módulos 🔵 de otro agente, NUMEROS_DISPONIBLES.txt.
4. Commits en español, pasado impersonal, viñetas con atribución. Prohibido push/--force/--amend/commits ajenos sin revisar.
5. Nada nuevo: 1 línea 'CRON C: nada para preservar'.

Reglas: numeración por pool del canal destino (3 cifras) consumida al escribir, UTF-8 Python sin BOM LF (NUNCA PowerShell), firma GLM-5.3 Flash-Director, español, pathspec explícito, independencia §21.8.
```

---

### Invariantes adicionales (fundador 2026-10-19/20 - tarde noche v2.5):

- **Ticket de carrera**: las tandas de dos equipos que tiran al mismo riel pueden colisionar en el NN. Ante carrera: el director saca un ACUSE único para AMBOS; el Ticket (si quedó abierto con contenido parcial) se REMATA con mensaje único del director.
- **Standby puntual descripto como DIRECTIVA**: el agente no espera, sino: 1) re-ejecuta su obra; 2) toma un barrido estilo anti-drift; 3) reporta su pregunta en un mensaje. NO duplicate trabajo prestado (regla de herencia).
- **Los 4 crons + estos invariantes** corren en una sola sesion (CRON A/B/C/D = 4 ids vigentes listados arriba).

## Regla de combinacion entre crons (fundador 2026-10-21 21:28)

Cada cron hace su TAREA PRINCIPAL siempre. SI en la misma vuelta el director detecta OTRAS cosas utiles (un pendiente por responder, una preservacion urgente, una derivacion que necesita decision), TAMBIEN las hace en esa vuelta y etiqueta el reporte indicando que combin. Ejemplo real: 21:25 C hizo gate+preservacion y ademas cerro la derivacion de crafting respondiendo a G-5.3/MiniMax (etiquetado C+B+D combinados). La trazabilidad se mantiene ESCRIBIENDO en el reporte que crons se combinaron.


## CRON D v4 (enmienda 2026-10-22 08:06, directivas del fundador 07:37/07:55/08:03)
1. **Cada ciclo investiga tareas para TODOS** (multi-tarea: 2+ items por encargo, salvo dependencias entre agentes) - no solo los agentes con backlog corto.
2. **Beam: paquetes de 100 por ciclo** (P-100 en su BACKLOG-MASTER, montado sobre 9 modulos nicho suyo con 501 [ ] disponibles); benchmark P-30 confirmo ~30 tareas en 4-10 min con citas al pie; cuando cierre 30 pasa al P-100 con GO adelantado.
3. **Anti-colision numerica:** antes de escribir el acuse, verificar que el head del pool no tenga ya fichero con ese numero (pool compartido con el agente a alta velocidad).
4. Citas textuales de los agentes pueden venir SIN tildes: el director compara con variantes (menú/menu) antes de declarar fallo - leccion re-aplicada del hallazgo 073.
## REGLAS TRANSVERSALES DE LOS CRONS (fundador 2026-10-22 19:40)

### REGLA MULTITAREA (directiva del fundador, reforzada 22oct tras el dia de ~190 mensajes de Beam)
- **MENSAJES LARGOS CON TRABAJO LARGO, POCOS MENSAJES**: es mejor 1 mensaje con 2+ tareas y tanda extendida que 10 mensajes de 1 tarea.
- Todo encargo del director lleva MINIMO 2 tareas (salvo dependencia dura entre agentes).
- Todo reporte del agente: consolidado, con secciones cortas POR ITEM - JAMAS un mensaje por tanda/chisme/ping.
- Meta operativa: la capacidad de escritura va al TRABAJO, no a la mensajeria. Menos mensajes => menos carreras de pool
  (4 gemelos el 22oct), menos T-19 (plantillas vacias), menos overhead de numeracion y sanacion.

### FIRMA DEL DIRECTOR EN ESTE ARCHIVO

**Modelo:** GLM-5.3 Flash-Director
**Plataforma:** Kilo Code
**Fecha:** 2026-10-22 19:40 (refuerzo directiva multitarea/mensajes-consolidados)
### DETECTOR EN TODOS LOS CRONS (fundador 22oct 19:40: el 203 de Beam me cruzo entre ciclos)

- CADO CRON (A/B/C/D) arranca SIEMPRE con `python scripts/verificar_mensajes_nuevos.py` como PASO 0-bis,
  aunque no sea el cron de deteccion. El mensaje puede llegar 1 minuto despues de que CRON B corrio: se procesa
  en el siguien cron que toque, no se espera al siguiente CRON B.
- Sin esto hay huecos de hasta 20 min entre detection cycles con la flota en tanda rapida.
## ⚠️ ADDENDUM AL ESTADO INFRA (23oct 20:07 — cierre del director saliente)

- 23oct 05:35-05:39: el fundador ordeno APAGAR TODOS los crons y re-crearlos; ids de ese re-monte: A wku_167382d65001rjwVTFTFuUVoux, B wku_1678114a70017DPH8ZZ7n6DSvv, C120 wku_16781b97b001uEmDTIF6Hkm9x9, D wku_16781483a001GbdakBUnfbMv8w, E wku_16781847d001Ca9kjSHixBppra (prompts con bloque CONTEXTO PERSISTENTE + nota Sin G-5.3-agente).
- 23oct 20:04 (orden del fundador por output truncado): TODOS cesados con cron_delete (commit 42990c4). CRON F nunca se monto (G-5.3-agente apagado 05:35).
- CRON 12-min de Beam (12,24,36,48) es de la SESION NUEVA de Beam (montada por el fundador ~19:44 con el prompt integrado + TANDA-SESION-NUEVA-23oct.md de 10 items). Beam entrego TANDA bloque 1 = mensaje 310 (17:02) — pendiente de ratificar por el relevo.
- El cron viejo de G-5.3-agente wku_161a9d271001F2M641rCnNuZgy sigue pendiente de baja en el panel del fundador.
- Estado completo del cierre: Logs/estado_director.json (claves crons_director, canales, tanda_beam_nueva, pendiente_lectura_proximo_director, ratificaciones_23oct_tarde).


## ESTADO ACTUAL DE LA INFRAESTRUCTURA DE CRONOMETROS (23oct 00:50-01:24 — documentado a pedido del fundador)

**1. CRONS DEL DIRECTOR (mi lado, 4 los crons + 1 nuevo):**
- CRON A/B/C/D v4: ~/.00-05 cadencias (A :00/:20/:40, B :10/:30/:50, C :05/:25/:45, D :15/:35/:55) - cuatro rotaciones de detección, preservación, ratificación, y asignador por capacidad.
- CRON E (23oct 01:24, RE-programado 01:57 por solape detectado por el fundador, id wku_16679d388001jydakN57a0qXhW): cada 10 MINUTOS en minutos 3/13/23/33/43/53 (el /10 original corria ENCIMA de A y B) - exclusivo: escribe a Beam UN mensaje con 30 tareas APILADAS de su nicho, sin repetir (puntero apilador_beam_ultimo en estado), midiendo que esta haciendo; regla anti-spam: si el ultimo mensaje de Beam sigue dentro del apilado anterior, NO reapila ese ciclo; separado del cron de lectura.
- CAMBIO ANUNCIADO (23oct 01:16): el cron del PUSH pasa a cada 120 MINUTOS (decisión del fundador), liberando slot para el cron nuevo que el fundador anuncia en el próximo ciclo (pendiente).

**2. CRONOMETROS DE AGENTES (de su lado; el director entrega el prompt y el encendido es del fundador/agente):**
- Reflection-Beam-1.0: ACTIVO cada 5 MINUTOS, id wku_16648c2fe00192yweXE4ibRqca (creado por él, 225). Prompt canonico: DOCUMENTACION/TAREAS-POR-MODELO/Reflection-Beam-1.0/CRONOMETRO-REFLECTION-BEAM-1.0.md. PASO 1 OBLIGATORIO incluido (23oct).
- G-5.3-Flash-Agente: PROMPT ENTREGADO por mensaje (322/324) y en disco CRONOMETRO-G-5.3-FLASH-AGENTE.md. PASO 1 incluido. Encendido + confirmación del Id PENDIENTE de su lado (auto-servicio activo igual).
- DS-V4.1-Flash-Opencode: verificador oficial continuo por BATCHES (no cron fijo; se activa cuando caen tandas de Beam). Su CRONOMETRO-V2 propio en su carpeta. Activo desde 22oct 22:00.
- agnes-3-flash: veredictora continuo por radar (sin cron fijo; escucha lotes). BACKLOG-AGNES con 12 auditorias de sello en cola.
- Hy3: RAMA-2 por V2 (sin cron fijo; encuestas/tiebreakers). BACKLOG-HY3 con 5 encuestas + 3 reproducibles.
- Ling-3.1-Flash: STANDBY con BACKLOG-LING generado (21 items i18n).
- MiniMax-M3.1-Flash: OFFLINE (codigo M16/suites reservados a su regreso).

**3. CAMBIOS INSTITUCIONALES DE HOY (los 3 problemas resueltos):**
- PASO 1 OBLIGATORIO en cada cronometro de agente: leer el canal PROPIO antes de producir (fundador 23oct: los GO por mensaje no se enganchaban solos).
- AUTO-SERVICIO: cada agente re-pobla su cola cuando baja de 20 (sin pedir permiso - mis mismo modelo del director).
- NO-GUARDIA-SIN-TANDA: el CRON D repuebla por nicho ANTES de declarar guardia (54 backlog de G-5.3, 12 auditorias de agnes, 21 i18n de Ling).
- Validar SUSTANCIA: flip [x] exige artefacto citado EXISTENTE (auditar_citas_checklist.py, de DS-WB, corriendo en 167 checklists: 195 defectos detectados, 50 en [x] siendo degradados).

Gestion de pools intacta: NUNCA push; commits por rondas del CRON C con pathspec explicito; NUNCA powershell inline multilínea.

Firma de esta seccion: GLM-5.3 Flash-Director / Kilo Code - 2026-10-23 01:30.

- REFERENCIA CRUZADA: la SOP de numeración de canales vive en `Mensajes entre modelos/GUIA-NUMERACION-CANALES.md` (fundador 23oct 04:30) con herramienta `scripts/renumerar_canal.py` — obligatoria cuando un canal acumule gemelos/huecos.