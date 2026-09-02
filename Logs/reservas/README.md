# Logs/reservas/ — Variables temporales de reserva de números de log

Mecanismo del protocolo v2 (AGENTS.md §6.1, propuesta del usuario + glm-5.3-flash 2026-09-01).

## Cómo funciona

1. Al **BLOQUEAR un módulo**, el agente reserva su número de log: lee `ULTIMO_NUMERO.txt` (N), verifica que `{N+1}` no exista ni como log ni como reserva, escribe N+1 en `ULTIMO_NUMERO.txt`, y crea acá el archivo:
   `{NUMERO}-{AGENTE}-{MODULO}.txt` con contenido: `numero / agente / plataforma / modulo / fecha`.
2. Al **ESCRIBIR el log** (`Logs/{NUMERO}-...md`), **BORRA su archivo de reserva de esta carpeta** (la variable temporal se consume).
3. Si **libera sin log** (aborto/hueco), también borra la reserva y anota "log reservado N no usado".

## Reglas

- El nombre del archivo lleva el número: ordenable y auditable sin abrirlo.
- Reserva huérfana (sin log asociado) con más de 48 h: el siguiente agente puede borrarla y reusar el número.
- NUNCA guardar el número solo en memoria del agente ni como constante en código.
