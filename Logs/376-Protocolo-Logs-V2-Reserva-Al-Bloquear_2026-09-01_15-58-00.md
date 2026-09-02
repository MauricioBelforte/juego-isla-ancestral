# Log 376: Protocolo de logs v2 — reserva al bloquear módulo con carpeta Logs/reservas — glm-5.3-flash

**Fecha:** 2026-09-01
**Hora:** 15:58
**Modelo:** glm-5.3-flash
**Plataforma:** Kilo Code

## Resumen

Se implementó la versión 2 del protocolo de numeración de logs (AGENTS.md §6.1), propuesta del usuario: el número de log se **RESERVA al bloquear el módulo** (no al final), y la reserva vive como variable temporal compartida en la carpeta **`Logs/reservas/`** — no en memoria del agente ni como constante en código.

## Motivación

El sprint del 2026-08-31 → 09-01 produjo colisiones masivas de numeración (logs 306-339 duplicados entre agentes; mi Log 327 de M55 quedó enterrado bajo logs 328-339 de otros). Causa raíz: cada agente leía `ULTIMO_NUMERO.txt` al final de su tarea, cuando otros ya habían escrito en paralelo. La reserva en el momento del BLOQUEO hereda la exclusividad que el protocolo ya garantiza (un módulo = un agente).

## Cambios Realizados

### AGENTS.md §6.1 (versión 2, con crédito a la propuesta del usuario)
- **§6.1.a RESERVA** (en el mismo momento de bloquear el módulo): leer N → verificar que N+1 no exista como log NI como reserva → escribir N+1 en ULTIMO_NUMERO.txt → crear `Logs/reservas/{NUMERO}-{AGENTE}-{MODULO}.txt` → anotar "Log reservado: N" en CHECKLIST-GLOBAL/ESTADO-PARALELO/05-Checklist.
- **§6.1.b ESCRITURA** (al finalizar): verificar que {N}-*.md siga libre → escribir el log → **BORRAR la reserva temporal** (se consume).
- **§6.1.c ABORTO**: liberación sin log → borrar reserva, el número queda como hueco inofensivo; reservas huérfanas >48 h pueden ser borradas por el siguiente agente.
- **§6.1.d COLISIÓN**: la verificación de reservas en 6.1.a detecta la carrera; la de 6.1.b absorbe residuales.
- **Semántica v2 de ULTIMO_NUMERO.txt**: contiene el último número **RESERVADO** (no el usado); huecos = inofensivos.
- **§6.3 Reglas de Seguridad** actualizadas: la reserva vive en `Logs/reservas/` (auditable); NUNCA en memoria ni en constantes de código.

### Logs/reservas/ (nueva carpeta)
- `README.md` con el mecanismo y las reglas.
- La carpeta es la variable temporal compartida: cada agente deja su `{NUMERO}-{AGENTE}-{MODULO}.txt` al bloquear y lo borra al escribir su log.

### Correctivo puntual
- `Logs/ULTIMO_NUMERO.txt` corregido de 365 (desactualizado tras la corrección de renumeración del Log 375) al valor real.

## Archivos Modificados/Creados

- `AGENTS.md` (§6.1 reescrita como versión 2 + §6.3 actualizada)
- `Logs/reservas/` (carpeta nueva) + `Logs/reservas/README.md`
- `Logs/reservas/376-glm-5.3-flash-cambio-protocolo-logs-v2.txt` (reserva temporal — se borra al finalizar este log)
- `Logs/ULTIMO_NUMERO.txt` (→ 376)

## Verificación

- La carpeta de reservas existe y es auditable (`Test-Path Logs/reservas` = True).
- Este log es la primera aplicación real del protocolo v2: reservé 376 al aceptar la tarea, escribo con ese número y borro mi reserva al finalizar.
