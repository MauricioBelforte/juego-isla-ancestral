# METODOLOGÍA — AGENTE AUTÓNOMO DE BACKLOG CON CRONÓMETRO (patrón "Nemotron")

**Modelo:** GLM-5.3-Flash (agente) | **Plataforma:** Kilo Code | **Fecha:** 2026-10-25 20:15
**Origen:** orden directa del fundador 25oct ("que trabaje autónomo... primero crea el md de cómo automatizar un agente").
**Aplica a:** cualquier agente de la flota que trabaje por nicho propio con gestión propia de su cola (primera aplicación: Nemotron-3.5-Super-VL; precedente: Beam pero SIN carpeta `tareas/` — el agente marca checks directo en sus archivos de backlog).

---

## 1) Idea central

Un agente autónomo necesita 4 piezas:

1. **Cronómetro** — el motor: un cron de la plataforma (ej. Kilo) que dispara el agente cada N minutos con UN prompt fijo (el ciclo, sección 3). El agente nunca espera instrucción humana para arrancar.
2. **Backlog Master tipo checklist** — SU único punto de entrada de trabajo: un índice de BACKLOGS ENUMERADOS (B-0, B-1, ...) con checks. El cronómetro SIEMPRE lo lee primero.
3. **Backlogs de detalle enumerados** (uno por familia de nicho) — archivos separados, también tipo checklist. El Master referencia estos; el agente abre el backlog que toque y marca los ítems [x] AHÍ MISMO.
4. **Canal de mensajes** — donde deja SUS REPORTES al cerrar cada ítem/tanda, y de donde lee (AL FINAL del ciclo) si el director le escribió.

Cuando el backlog de detalle se agota (todos sus ítems [x]), el agente marca **el check del backlog COMPLETO en el Master** y salta al siguiente backlog de la cola.

## 2) Estructura de carpetas (mínima)

```
DOCUMENTACION/TAREAS-POR-MODELO/<AGENTE>/
├── BACKLOG-MASTER.md            ← checklist de backlogs (B-0..B-6) + perfil + reglas
├── CRONOMETRO-<AGENTE>.md       ← prompt del cron + ciclo + safety
├── B-0-CALIBRACION.md           ← gate de entrada (si corresponde)
├── B-1-<NICHO-PRINCIPAL>.md     ← el nicho donde el modelo es mejor, PRIMERO
├── B-2-<NICHO-2>.md             ← siguiente por capacidad
├── B-3-...md
├── tareas/                      ← OPCIONAL (solo si el nicho exige tandas TASCHE — Beam)
└── scripts-prueba/              ← scripts de apoyo del agente

Mensajes entre modelos/<AGENTE>/
├── NUMEROS_DISPONIBLES.txt      ← pool 3 cifras del canal
├── 01-...-apertura-protocolo.md ← apertura + reglas
└── NNN-...-a-<director>-reporte-....md  ← reportes de tanda (autónomos)
```

## 3) El ciclo del cronómetro (prompt fijo del cron)

Cada disparo del cron ejecuta ESTE bucle (el prompt del cronómetro lo contiene literal):

1. **Leer `CRONOMETRO-<AGENTE>.md`** (auto-refresh de reglas y estado).
2. **Leer `BACKLOG-MASTER.md`** → tomar el PRIMER backlog no agotado según el ORDEN fijado (el orden apunta a lo que el modelo mejor hace — nunca reordenar sin el director).
3. **Abrir el backlog de detalle** y tomar el SIGUIENTE ítem [ ] (orden de encima hacia abajo; tipos de ítem hierven por prefijo: V-, D-, I-, G-, W-, P-).
4. **Ejecutar el ítem** respetando el patrón de su riel (visión/doc/код...); cada output deja EVIDENCIA en disco o en el canal (ruta citada).
5. **Marcar el ítem [x] en el backlog de detalle** con: fecha + evidencia (ruta del reporte/archivo generado). Si el ítem no se puede hacer: `[?]` + razón honesta (1 línea) + notificación en el reporte de cierre.
6. **Cierre de tanda (cada N ítems o al agotar el backlog):** escribir UN reporte en `Mensajes entre modelos/<AGENTE>/` dirigido al director con: ítems cerrados (ids), evidencia, hallazgos, `hecho=N skip=N fail=N`.
7. **Actualización del Master:** si el backlog de detalle quedó 100% [x], marcar [x] en su fila del Master y saltar al siguiente.
8. **ÚLTIMO del ciclo (solo si sobra presupuesto del disparo):** revisar si hay mensajes nuevos del director en el canal y RESPONDERLOS (numeración último+1). La regla es **trabajo primero, respuesta al final** — el director interrumpe solo lo urgente.

## 4) Reglas de oro (todas heredadas de la flota · AGENTS.md)

- UTF-8 sin BOM, español, firma completa en cada archivo (Modelo/Plataforma/Fecha/Responde a).
- Numeración de canal: último NNN + 1, número borrado del pool de la carpeta al usarse.
- Citas textuales o nada (flip/documento con L# textual; paráfrasis prohibida).
- NO tocar módulos 🔵/🔴 ni colas de otros agentes (anti-duplicado por (módulo, L#) cuando aplique).
- Produce-first con grep previo de duplicados (trampa M31 3x); Totales de 05: NUNCA.
- Sin push/commits sin orden expresa. Sin auto-sello QA (§21.8).
- Autonomía: el agente NO consulta antes de cada ítem — consulta por excepción (bloqueo, ambigüedad, daño posible) y sigue con el resto de la tanda mientras.
- Honestidad: ítem no resuelto = `[?]` + motivo. Nunca [x] por hacer.
- Al agotarse TODO el backlog: reportar "backlog vacío" en el canal y QUEDARSE EN ESPERA (el director repone; el cron sigue disparando pero no inventa trabajo).

## 5)Safety del cronómetro

- Ventana horaria del cron (frecuencia y horario la fija el fundador en su plataforma; ej. Beam: cada 12-30 min).
- Hard stops del ciclo: (a) error del motor/plataforma ≥2 veces seguidas → reportar y parar; (b) bloqueo legal/moral (credentials, datos personales) → NO tocar, reportar; (c) pedido EXPLÍCITO del director/fundador de pausar → obedecer y anotar en el cronómetro.
- El reporte de cierre es lo que desbloquea el siguiente encargo del director (REGLA CERO).

## 6) Qué devuelve esto al proyecto

- Trabajo por nicho a ritmo de máquina, con evidencia en disco y reportes en canal — sin humanos en el medio.
- El director solo: (1) lee reportes, (2) repone fuel aprobando investigaciones (B-I-type), (3) deriva hallazgos a dueños, (4) sella.
- Escalable: cualquier agente nuevo de la flota se monta con esta plantilla en <1 hora (cambiar nombre, nichos y hacer los backlogs de detalle).

---

Firma: GLM-5.3-Flash (agente / Kilo Code) — metodología creada por orden directa del fundador 25oct. Primera aplicación operativa: `DOCUMENTACION/TAREAS-POR-MODELO/Nemotron-3.5-Super-VL/` (CRONOMETRO + BACKLOG-MASTER + rieles B-*).
