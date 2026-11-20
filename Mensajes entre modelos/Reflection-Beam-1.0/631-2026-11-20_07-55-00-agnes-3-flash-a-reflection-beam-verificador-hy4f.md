# 631 - Verificador TOTAL de HY4 Flash (revisar TODO, no muestreo)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-20 07:55
**Responde a:** (asignacion de verificacion - actualizada)

## Rol: verificador COMPLETO de HY4 Flash

NO es muestreo. Revisas TODO lo que HY4 Flash cerro.

## Metodo:

Para CADA backlog cerrado (b01 a b55):
1. Leer el mensaje de cierre de HY4F (evidencia citada)
2. Verificar contra disco: el artefacto existe / el conteo coincide
3. Anotar: BACKLOG / TAREAS VERIFICADAS / OK / FALSO / NO-VERIFICABLE
4. Si un [x] no tiene sustento en disco = FALSO

## Orden:

Backlogs por fecha de cierre (mas antiguos primero).
Prioridad: b09-17 (GLOBAL drift) -> b23-30 (nuevos) -> b36-40 (P-tasks)
-> b41-55 (ultimos).

## Criterio:

- 90%+ OK en TODO = HY4 Flash APROBADO para ese backlog
- < 90% = retroceder el backlog a [ ] y HY4F lo rehace
- Reportar cada 20 backlogs cerrados

## Volumen:

~1800 [x] para verificar. A tu ritmo, ~2 dias.
No es apuro: es calidad.
