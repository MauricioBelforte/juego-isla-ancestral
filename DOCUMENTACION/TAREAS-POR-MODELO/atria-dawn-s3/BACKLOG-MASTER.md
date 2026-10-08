# BACKLOG-MASTER — atria-dawn-s3

**Modelo:** atria-dawn-s3 (Atria-Dawn-Preview)
**Plataforma:** Kilo Code
**Rol:** Supervisor de Ling + auditoría de gobernanza (directiva del fundador, 2026-10-08)

> **Mi rol (aclarado por el fundador el 2026-10-08):** tengo **libertad para buscarle tareas a
> Ling 3.1 Flash**, asignárselas y supervisar su ejecución en paralelo. No necesito pedir
> permiso para hacerla trabajar — **le voy diciendo al director en qué está trabajando Ling**,
> y el director responde sugiriendo tareas para que trabajemos juntas.
>
> **División del trabajo:**
> - **Ling 3.1 Flash** = ejecutora: tabulación voluminosa, auditorías de `[x]`, barridos de
>   plan-actual, recorrido de logs.
> - **Yo (s3)** = supervisora: defino el encargo con criterio, **re-verifico cada claim crudo
>   de Ling con el binario/disco real**, corrijo sus errores de alcance, firmo y reporto.
>
> **Reporto al director** en mi canal (`Mensajes entre modelos/atria-dawn-s3/`) qué le encargué
> a Ling y qué verifiqué; el director sugiere los próximos frentes.
>
> El director me asigna tareas L-NN (sobre modelos) y K-NN (auditorías de independencia §21.8).
> Mi trabajo no es codificar el juego: es determinar qué puede hacer cada modelo con evidencia
> empírica.

## Tareas en curso (Ling bajo mi supervisión)

### L-05 — Ling: auditoría de inflación de `[x]` en 5 módulos — `[→]` EN CURRIDO

- **Qué es:** verificar si los `[x]` de los 5 módulos no-iniciados con más marcas declaradas son
  reales o inflados (patrón BUG-070: "verbo de implementación sin entrega").
- **Módulos:** M156 (234/307), M97 (129/195), M108 (124/205), M121 (123/211), M110 (121/225).
- **Método:** muestra aleatoria de 15 `[x]` por módulo, verificada contra disco con cita
  `archivo:línea`; clasificación ✅/⚠️/❌; veredicto LIMPIO/SOSPECHOSO/INFLADO.
- **Mi parte:** re-verificar los claims crudos de Ling y aplicar la decisión de gobernanza.
- **Nota:** lancé por error un sub-agente con mi propio modelo haciendo el mismo trabajo (no era
  Ling). El fundador pidió no cancelarlo para no perder tokens; cuando entregue lo descarto o
  uso como contraste. **La fuente de verdad es Ling.**

### L-06 — Ling: timestamps stale del GLOBAL — `[→]` EN CURSO

- **Qué es:** detectar todas las filas del CHECKLIST-GLOBAL.md cuya columna "Última actividad"
  está desactualizada vs. el log más reciente que menciona el módulo.
- **Origen:** el patrón lo hallé en M39 (GLOBAL decía 2026-09-17; hy3 re-verificó 2026-10-04,
  Log 1269). Si pasó una vez, puede pasar en más.
- **Mi parte:** re-verificar los stale que Ling reporte contra `Logs/`.

## Tareas completadas

### S-01 — Independencia de verificadores: caso K-01 (kimi-k3 / M37) — `[x]` COMPLETADA Y APROBADA

- **Qué era:** verificar si el trabajo de kimi-k3 (#1 del catálogo, 3 días sin auditoría) tenía
  evidencia real o era claims.
- **Veredicto:** 30/36 `[x]` verificados, código real (85 checks/0 fallos/EXIT 0 reproducido por
  mí), pero trazabilidad de claims (Log 1253 inexistente, trampa 58, canal vacío, RF5/C.12 sin
  marcar).
- **Decisión del director registrada:** "el código de kimi resiste; lo que falló fue la
  trazabilidad". Recordatorio obligatorio al regreso = trazabilidad, no supervisión de código.
- **Corrección a Ling:** su drift #4 (`quality.yml` inexistente) era falso — existe en
  `.github/workflows/`.
- **Entregable:** `S-01-independencia-verificadores.md` (esta carpeta). Metodología K-01/K-02/K-03
  documentada ahí.

## Tareas en curso

### Candidato 2 — Módulos 🟡 de modelos inactivos — `[x]` COMPLETADA (espera aprobación director)

- **Qué era:** auditar los módulos 🟡 de modelos inactivos para determinar si están colgados o
  terminados (método A, read-only).
- **Universo:** 117 🟡 en el GLOBAL; **88 sin actividad desde septiembre**; 29 activos en octubre.
- **Clasificación:** 9 a ≤5 ítems de cerrar (categoría A), 12 a 6-20, 22 a 21-60, y **45 que nunca
  despegaron** (>60 ítems faltantes, varios a 0-20% implementado). "Colgado" es engañoso para el 51%.
- **Top 5:** M149 (99/100, 3 [?] humanos), M167 (113/114, drift doc real radio 256 vs 2560), M39
  (180/181, test 1000 tx nunca implementado — hy3 re-verifyó 2026-10-04, Log 1269, timestamp del
  GLOBAL stale), M65 (89/90, dep externa M08), M36 (226/228, 2 KnownIssue).
- **Recomendación:** M149 y M65 flipeables vía DoD KnownIssue (precedente M153); M39 y M167
  necesitan 1 ítem real de trabajo cada uno (asignable a Ling bajo mi supervisión); los 45 no
  iniciados deberían reclasificarse (decisión del director).
- **Corrección de método:** mi primer filtro de 🟡 tuvo falsos positivos (el emoji aparece también
  en el texto de Notas, "mantiene 🟡" — M145/M146 salieron como colgados siendo ✅). Corregido
  filtrando por columna Estado. El conteo final (88) es el confiable.
- **Entregable:** `C2-modulos-amarillos-modelos-inactivos.md` (esta carpeta).
- **Evidencia:** informe en `Mensajes entre modelos/atria-dawn-s3/15-*`.

### L-04 — Encadenamiento de sellos §21.8 por verificador (Hy3) — `[x]` COMPLETADA (espera aprobación director)

- **Qué era:** mapear y auditar el encadenamiento de sellos §21.8 por verificador en
  `CHECKLIST-QA-SEALS.md`, tras el episodio de la mañana (Hy3 agregó 7 sellos y bajó M78/M112).
- **Universo:** 64 sellos limpios vigentes (53 de la tabla − M78 revocado + 12 bajo "Notas QA").
- **Concentración:** **Hy3 40/64 = 62.5%**; segundo verificador agnes-3-flash 8 (12.5%), 5× menos.
  Top-2 = 75%. Sin segundo verificador con masa crítica.
- **Monocultura confirmada:** regla formal (verificador ≠ autor por sello) se cumple en los 64,
  pero el espíritu §21.8 ("distintos modelos detectan errores distintos") está violado. Hy3 es el
  único verificador de la familia Legal (10 sellos, 100%) y autor del propio registro protegido.
- **Doble rol M153 (lo más grave):** Hy3 cerró M153 (Log 1053, "✅ Completado por hy3") y el mismo
  día se otorgó el sello (Log 1056) argumentando que "autor" = GLM (escribió el código en 08-28).
  Mi análisis: el cierre ES autoría de iteración; §21.8 inhabilita auto-verificarse. Atenuantes:
  cierre honesto (10 [ ] KnownIssue reales, 0 fabricados) + re-verif posterior de mimo. Daño bajo,
  precedente malo.
- **Corrección al director:** M150 NO depende de M151 (depende de M149); solo M153 → M151.
  M151 no tiene sello §21.8 en el registro.
- **Umbral propuesto:** >50% = monocultura. 4 reglas operativas (autor = quien firma el cierre;
  verificador explícito obligatorio en cada fila; familia Legal prioridad de redistribución;
  Hy3 inhabilitado hasta bajar de 32 sellos).
- **4 ✅ sin sello (oportunidad de redistribución sin tocar a Hy3):** M38 y M131 → agnes-3-flash;
  M111 y M119 → DeepSeek.
- **Entregable:** `L-04-encadenamiento-sellos-hy3.md` (esta carpeta).
- **Evidencia:** informe en `Mensajes entre modelos/atria-dawn-s3/14-*`.

### K-02 — Auditoría de independencia §21.8 sobre 9 módulos flipeados a ✅ — `[x]` COMPLETADA Y APROBADA

- **Qué era:** el director flipeó 9 módulos a ✅; riesgo de colisión autor=verificador es el más
  alto del proyecto. Delegada a Ling, supervisada por mí.
- **Veredicto:** **9/9 independencia verificada, 0 violaciones, 0 noticias rojas.** Ningún ✅ con
  sello ilegítimo — el riesgo de colisión no se materializó.
- **Mi verificación independiente:** 25 logs citados (0 faltantes), firmas de 9 verificadores
  leídas, 6 suites en disco, estado real de los 9 en GLOBAL (solo M44/M150/M153 ✅), M63 ausente
  de QA-SEALS confirmado, Log 1056 (M153 H-5) abierto y confirmado.
- **M63 (caso crítico) limpio:** el re-sello principal fue de Hy3 (no agnes-3 como presumía el
  director); agnes-2.5 ≠ agnes-3 confirmado por firmas; el autor DeepSeek se abstuvo de
  auto-sellarse (Log 1192).
- **4 hallazgos de registro:** H-1 (M63 sin registrar en QA-SEALS — dueño hy3), H-4 (solo 3/9 en
  ✅; M106 y M14 bajados a 🟡 por DoD), H-5 (M153: hy3 cerró y selló la 1ª vuelta con argumento
  implementador-vs-cerrador confirmado por el usuario — el caso a vigilar), H-6 (M44, timestamp
  cronológicamente inconsistente).
- **Corrección a la pista del director:** M52 y M106 SÍ están en QA-SEALS (filas 18 y 70).
- **Entregable:** `K-02-independencia-9-modulos.md` (esta carpeta).
- **Evidencia:** aviso en `Mensajes entre modelos/atria-dawn-s3/6-*`.

- **Qué es:** el director flipeó 9 módulos a ✅; riesgo de colisión autor=verificador o sello
  fraudulento es el más alto del proyecto.
- **Módulos:** M44, M150, M153, M106, M60, M52, M14, M63, M89.
- **Caso crítico:** M63 — Hy3 invalidó el Log 856 (agnes-2.5-flash, descatalogada, fraudulento) y
  agnes-3 re-selló. Verificar que el re-sello sea legítimo y que agnes-2.5 ≠ agnes-3.
- **3 preguntas por módulo:** (a) verificador ≠ autor del cierre, (b) sello existe con firma,
  (c) evidencia real y trazable.
- **Regla de oro:** una independencia violada = noticia roja = el director revierte el flip.
- **Delegación:** Ling ejecuta la tabulación; yo spot-checko las cadenas sensibles (sobre todo
  M63, que lo hago yo por criterio de identidades).
- **Entregable:** `DOCUMENTACION/TAREAS-POR-MODELO/atria-dawn-s3/K-02-independencia-9-modulos.md`.

### K-03 — Auditoría de los flips del director (M25, M24) — `[x]` COMPLETADA

- **Qué era:** auditar las 3 acciones de director del día: reversión de M25 (flip ✅→🟡),
  progreso de M24 (34→43), y su propio proceso §21.8.
- **Veredicto:** **sin problemas byte-level.** Reversión de M25 bien aplicada (fila 🟡 limpia,
  marcas 122/0/0 intactas). M24 limpio (conteo 43/84/1=128 exacto, 3 archivos citados existen).
- **Mi verificación independiente:** regex propio en ambos checklists, fila del GLOBAL,
  existencia de los 27 archivos citados de M25 (24 faltan), 17 `[x]` con "Implementar", 24
  `.glb` reales (corrigiendo el 108 de agnes), Log 1416 y Log 1065 leídos.
- **Error de proceso del director encontrado (ya admitido y revertido):** el flip de M25 aceptó
  una auditoría de **conteo** (agnes) como evidencia de **DoD §21.6**. Agravante: pasó por alto
  **dos banderas previas suyas** — Log 1065 y su nota L176-178 en el propio `05-Checklist.md`
  ("El módulo NO puede pasar a ✅").
- **Recomendación dada:** antes de flip a ✅, grep de banderas previas en el `05-Checklist.md`.
- **Entregable:** `K-03-auditoria-director.md` (esta carpeta).
- **Evidencia:** aviso en `Mensajes entre modelos/atria-dawn-s3/9-*`.

### K-04 — Re-auditoría del volumen de agnes-3-flash (M120, M100, M113, M85, M131) — `[x]` COMPLETADA

- **Qué era:** re-auditar los 5 veredictos DoD de agnes (4 DEUDA REAL + 1 INFLADO), porque ella
  se había equivocado con M25 (auditoría de conteo aceptada como DoD).
- **Veredicto:** **agnes está CORRECTA — 5/5 conteos exactos, 5/5 clasificaciones correctas.**
  Después de M25, esta vez sí llegó a la profundidad DoD. Su error fue de alcance, no de criterio.
- **M85 (INFLADO):** sus 4 degradaciones son legítimas — `add_license`, `add_credit`,
  `generate_credits_text`, `save_build_credits` = 0 hits en todo `scripts/`. Imprecisión
  cosmética: su nota dice "4 funciones" pero el patrón abarca 5 (`generate_credits_web` también).
- **M131 (DEUDA REAL):** mi propio globo falló por alcance (12 de 19 "inexistentes") —
  `credits_layer.gd` y `credits_manager.gd` SÍ existen en `scripts/ui/layers/` y `scripts/legal/`.
  Corregí y corrí la suite citada: **43 checks / 0 fallos / EXIT 0**. 24 `[x]` citan código real
  y funcional; la deuda es periférica. "DEUDA REAL" no implica "sin implementación".
- **GLOBAL:** las 5 filas byte-consistentes con los veredictos y conteos.
- **Entregable:** `K-04-re-auditoria-volumen-agnes.md` (esta carpeta).
- **Evidencia:** aviso en `Mensajes entre modelos/atria-dawn-s3/12-*`.

### F-25 — Frentes del mensaje 25 (M119 doc, M167 doc+fix, M65, C3-c) — `[x]` COMPLETADO (informe 26 enviado)

- **Qué era:** los 4 frentes que el director ordenó en el mensaje 25 del canal.
- **M119 saneo doc (SIN flip):** suite re-corida por mí (**15 checks / 0 fallos / EXIT 0**) +
  `update_manager.gd` y `test_updates_m119.gd` verificados en disco. Los **9 `[ ]`** marcados como
  **KnownIssue no bloqueante DoD con dueño** (patrón **M131** — M153 quedó **revocado**, regla
  nueva: ✅ exige 0 `[?]` y 0 `[ ]`). T-022 y T-049..T-056 **no cerrables**: verifiqué que
  `03-Diseno.md` §2 no tiene secciones `UpdateDownloader`/`RollbackManager`. Nota stale 1B
  corregida (109/9/0). Totales intacta. M119 queda **🟡 109/118**.
- **M167 (frente 19):** Log 1442 re-verificado en disco (claims exactos) + **3 fallbacks
  adicionales con centro viejo que el Log 1442 no cubrió, fixeados por mí**: L56/57 (mesa),
  L72 (recursos) y **L420 (chamán — bug real: ignoraba sus propias `sh_x`/`sh_z` y mandaba a la
  esquina vieja)**. Grep final 0 hardcodes, parse EXIT 0. P-39 cerrado en plan-actual;
  afirmación de caminos primarios corregida (era cierta para primarios, incompleta para
  fallbacks). M167 queda 113/1/0.
- **M65/BUG-080:** descartado por orden del director ("no hace falta que hagas nada").
- **C3-c:** `C3-c-no-iniciados-reclasificacion.md` — **51** 🟡 colgados >60 faltantes (no 45:
  recalculado hoy), ~59% sin agente. Propuesta: reclasificar como ⬜ "Sin iniciar". Para el
  fundador.
- **Entregables:** `plan-actual/05-Checklist.md` de M119 y M167; `main_island.gd` (3 fixes);
  `C3-c-no-iniciados-reclasificacion.md`.
- **Evidencia:** informe `Mensajes entre modelos/atria-dawn-s3/26-*`.

### F-27 — Frentes A y B del mensaje 27 (M39 header, M38/M111 rutas) — `[x]` COMPLETADO (informe 28 enviado)

- **Frente A (M39 header):** L6 de `plan-actual/05-Checklist.md` corregida de
  `🔵 En curso — cierre glm-5.3-flash` a `✅ Completado (QA §21.8 DeepSeek Log 1450)`.
  **CRLF preservado** (verifiqué bytes). Conteo re-verificado: 181/0/0, sin azul residual.
- **Frente B (M38 + M111 rutas):** secciones "Rutas — estado real" añadidas a ambos
  `plan-actual/04-Codigo.md`, sin eliminar ni modificar contenido existente.
  - **M38:** 3 scripts en otra ruta (`shop_manager` en `scripts/shops/`), 2 inexistentes
    (`shop_definition`, `economy_validation` — ambos "Pendiente", sin claims falsos), catálogo
    real es `data/economy/econ_prices.tres`, ofertas en `data/economia/barter/` con **otros
    nombres**. CRLF preservado.
  - **M111:** de 16 archivos del árbol §1: 6 bien citados, 6 en otra ruta (todos en
    `scripts/utils/` o `scripts/editor/`), **3 inexistentes** (`observer`, `lint_runner`,
    `structs`). Tabla §11 marca "IMPLEMENTACIÓN INMEDIATA" → drift de árbol planificado, sin
    claims falsos. LF preservado.
- **Lección recibida:** el director me aclaró que un cambio de alcance doc→código requiere su OK
  previo (por lo de `main_island.gd` en M167). La próxima vez consulto primero.
- **Evidencia:** informe `Mensajes entre modelos/atria-dawn-s3/28-*`.

## Reglas del director (canal s3, mensaje 01, 05, 08 y 10)

- No asigno tareas a la flota, no toco `CHECKLIST-GLOBAL.md`, no decido altas/bajas.
- Read-only sobre checklists ajenos; mis notas van en mis entregables.
- Sin `quality.yml`, sin `interaction_manager.gd` (cuarentena BUG-117), sin push.
- Tengo acceso al binario Godot (`C:\Temp\godot\godot472.exe`) — re-correr suites cuando la
  evidencia sea dudosa.
- El log de mis entregables lo reserva quien ejecutó (Ling) o el director, no yo.
