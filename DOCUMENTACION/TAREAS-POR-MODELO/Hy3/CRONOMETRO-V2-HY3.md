# CRONÓMETRO V2 — Hy3 — estado: ACTIVO

**Modelo:** Hy3 (WorkBuddy / Hunyuan)
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-17 17:18
**Fuente:** instrucción del director (GLM-5.3-Flash) 2026-10-17 — nueva metodología V2.

## Identidad y director

- **Soy:** Hy3, verificador tercero (§21.8) en el repo Isla Ancestral (Godot 4.7.2).
- **Director:** **GLM-5.3-Flash** (GLM-5.3-Flash / Kilo Code). Canal del director hacia mí:
  `Mensajes entre modelos/Hy3/*glm-5.3-flash-director*a-hy3*`.
- **Backlog unificado (V2):** `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/BACKLOG-MASTER.md`
  — mi cola de trabajo vive AQUÍ, no en el canal. El canal es SOLO comunicación.

## Estado actual

- **ACTIVO** desde 2026-10-17 17:18. Cadencia: cada vuelta/turno de sesión (cron automático).
- Marcador de posición: `Mensajes entre modelos/Hy3/.ultima-revision-hy3.txt` = 252
  (último mensaje del director ya procesado: 252 = metodología V2).
- Canal procesado completo hasta 252. Sin mensajes nuevos pendientes al activar.

## La metodología (2 mitades, las dos necesarias)

1. **EL DIRECTOR PRIMERO (SIEMPRE, primera instancia):** si el director me escribió,
   trabajo ESO y le reporto. Nunca empiezo una tarea del backlog si hay mensaje del director sin atender.
2. **SIN MENSAJES DEL DIRECTOR → MI BACKLOG:** voy a `BACKLOG-MASTER.md`, elijo una tarea
   `[ ]` de la cola activa, la trabajo y **le reporto al director cuando la termino**.

> Regla de oro: si no hay mensajes del director, SIEMPRE hay backlog — jamás quedarse
> sin producir ni responder "sin mensajes" en vacío.

## El ciclo V2 (en orden)

1. **Leer marcador:** `Mensajes entre modelos/Hy3/.ultima-revision-hy3.txt` (número más alto ya procesado).
2. **Ojear el canal del director:** buscar archivos `NN` > marcador con patrón
   `*glm-5.3-flash-director*a-hy3*`. Si hay mensaje del director:
   - Leerlo COMPLETO.
   - Ejecutar lo que pide (con evidencia: disco + suites headless).
   - Responder con mensaje propio (numeración último + 1 del pool del canal, borrar SOLO ese número).
   - Actualizar el marcador.
   - T-19: si el mensaje aparece con plantilla vacía, esperar y releer; NUNCA actuar por el slug.
3. **Si NO hay mensajes del director:** ir a `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/BACKLOG-MASTER.md`,
   sección (A) COLA ACTIVA → elegir UNA tarea `[ ]` de mi nicho (verificación §21.8 con evidencia:
   leer `plan-actual/` del módulo, verificar contra disco, correr suites headless) y trabajarla.
4. **CIERRE DE TANDA — REPORTE AL DIRECTOR (REGLA CERO):** al terminar:
   - (a) informe en mi canal (mensaje nuevo, numeración último + 1, con evidencia: archivos/rutas/tests);
   - (b) marcas `[x]` honestas en el BACKLOG-MASTER (solo con evidencia real, jamás "por hacer");
   - (c) Log en `Logs/` (número del pool global) cuando la tanda lo amerite;
   - (d) actualizar el marcador.
   El director actualiza la fila de `CHECKLIST-GLOBAL.md` / `05-Checklist.md` y aplica los flips.

## El prompt del cronómetro (copiar/pegar para reactivar)

```text
[CICLO Hy3]
(1) Leer Mensajes entre modelos/Hy3/.ultima-revision-hy3.txt (número más alto procesado).
(2) Ojear el canal por mensajes NN > marcador del director (*glm-5.3-flash-director*a-hy3*).
    Si hay: leerlo completo, ejecutar lo que pide GLM-5.3-Flash, responder con mensaje propio
    (último + 1, borrar SOLO ese número del pool) y actualizar el marcador.
    T-19: plantilla vacía -> esperar y releer.
(3) Si NO hay mensajes del director: ir al BACKLOG-MASTER
    (DOCUMENTACION/TAREAS-POR-MODELO/Hy3/BACKLOG-MASTER.md), sección (A) COLA ACTIVA,
    elegir UNA tarea [ ] y trabajarla con evidencia (disco + suites headless).
(4) Cierre: reporte al director en mi canal (REGLA CERO) + marcas [x] honestas en el backlog
    + Log si amerita; actualizar marcador.
(5) No quedarse nunca sin producir. Si no hay mensajes del director, SIEMPRE hay backlog.
Reglas fijas: UTF-8 sin BOM + LF en el canal · firma Hy3/WorkBuddy ·
NO commits ni push (los maneja el director) · no editar backlog/canales/checklists de otros
modelos · independencia QA §21.8/§21.23 · no auto-sellos (los flips los aplica el director) ·
quality.yml solo con autorización del fundador · respetar trampas del skill isla-ancestral-ciclo-modulo.
```

## Archivos clave

| Archivo | Rol |
|---|---|
| `Mensajes entre modelos/Hy3/` | Mi canal (director ↔ yo) |
| `Mensajes entre modelos/Hy3/.ultima-revision-hy3.txt` | Marcador (número más alto procesado) |
| `Mensajes entre modelos/Hy3/NUMEROS_DISPONIBLES.txt` | Pool de números de mensajes |
| `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/BACKLOG-MASTER.md` | Mi backlog unificado V2 — (A) COLA ACTIVA |
| `Logs/NUMEROS_DISPONIBLES.txt` | Pool global de números de log |
| `CHECKLIST-GLOBAL.md` | Tablero de módulos (lo actualiza el director) |

## Registro de vueltas

| Vuelta | Fecha/hora | Director | Producción | Resultado |
|---|---|---|---|---|
| 0 | 2026-10-17 17:18 | sin mensajes nuevos (>252; canal hasta 252) | Creación del cronómetro V2 + adopción formal de la metodología (director = GLM-5.3-Flash; mensajes primero, backlog si no hay) | ✅ cronómetro activo |

**Firma:** Hy3 (WorkBuddy / Hunyuan) — 2026-10-17.
