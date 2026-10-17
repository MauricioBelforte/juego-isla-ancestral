# CRON DEL DIRECTOR — METODOLOGÍA V2 (2026-10-17) — estado: APAGADO por el fundador

**Modelo:** GLM-5.3-Flash-Director (GLM-5.3-Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-17 04:35 (reescribe la receta del 2026-10-16; el fundador apagó el cron y anunció cambio metodológico total)

## Estado actual

- **APAGADO** el 2026-10-17 ~04:25 por directiva del fundador ("apaga el cronometro, tus fallos
  me llevaron a plantear esto" + "vamos a cambiar totalmente la metodologia de trabajo").
- El disparo rezagado de las 04:25 fue el último; la tarea `wku_147c69473001ydzHI7Qe642cVb`
  (cron `*/5 * * * *`) fue ELIMINADA con `cron_delete` (no con `cancel_wakeup`: los cron tasks
  viven en otra herramienta — lección registrada).
- Reactivación: SOLO cuando el fundador lo ordene, con el ciclo de 3 pasos de abajo.

## El cron v2 del director (3 pasos, en este orden — nunca cortar)

1. **RESPONDER MENSAJES de los modelos** (primera instancia, SIEMPRE): escanear los canales,
   responder con numeración de hilo (último + 1, borrar SOLO ese número del pool del canal;
   pools NO se commitean — gitignoreados).
2. **VERIFICAR LOS BACKLOGS** (`DOCUMENTACION/TAREAS-POR-MODELO/<MODELO>/BACKLOG-MASTER.md`):
   cada uno debe tener tareas `[ ]` por hacer (100+ disponibles); si queda corto, AGREGAR tareas
   por nicho con evidencia (GUIA-COMPARATIVA 10 + estado real del proyecto).
3. **RECORDATORIO:** si un modelo con tareas disponibles pasa MUCHO tiempo sin avanzar ni
   responder → escribirle un recordatorio en su canal (una sola vez por ciclo, sin spamear).

## Cómo crearlo (cuando el fundador ordene reactivarlo)

Herramienta `cron_create` de Kilo Code. Prompt (pegar tal cual):

```
BUCLE DEL DIRECTOR V2 (fundador 2026-10-17 — 3 pasos EN ORDEN):
[1] RESPONDER MENSAJES: escanear 'Mensajes entre modelos/<canal>/ ' — todo mensaje nuevo NO
    procesado dirigido a mí (GLM-5.3 Flash-Director) se responde primero (numeración último+1,
    borrar SOLO ese número del pool del canal; pools gitignoreados). Sin mensajes: continuar.
[2] BACKLOGS DE FLOTA: verificar que cada 'DOCUMENTACION/TAREAS-POR-MODELO/<MODELO>/BACKLOG-MASTER.md'
    tenga tareas por hacer (100+); agregar tareas si queda corto (nicho + GUIA-COMPARATIVA +
    estado del proyecto). Actualizar el backlog y la fila GLOBAL según los reportes de cierre.
[3] RECORDATORIOS: si un modelo con tareas disponibles pasa mucho tiempo sin avanzar ni
    responder → escribirle UN recordatorio en su canal.
Reglas fijas: UTF-8 (§28), firma GLM-5.3 Flash-Director, commits con pathspec explícito
(sin -A sobre WIP ajeno), independencia §21.8/§21.23, REGLA CERO de reportes, reserva 🔵 de
módulos §21.3 en los 4 registros. Fundador: SOLO novedad material.
```

## Lección del apagado (para no repetir)

- El ciclo anterior (4 bloques, 5 min) mezcló la reactividad con el trabajo propio y dejó un
  informe de DS-Opencode (24) sin acuse ~3.5 h mientras el modelo esperaba en su canal.
- La nueva cadencia pone "responder mensajes" como PASO 1 ABSOLUTO y elimina el trabajo de
  fondo del director (delegar o dejar previsto en backlog, no ejecutar).
- Si el fundador pide otra cadencia, cambiar el cron `*/5 * * * *` por la que indique.

**Firma:** GLM-5.3 Flash-Director (GLM-5.3-Flash) / Kilo Code — 2026-10-17.
