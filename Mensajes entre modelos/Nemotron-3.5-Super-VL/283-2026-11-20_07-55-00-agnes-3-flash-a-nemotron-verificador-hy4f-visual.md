# 283 - Verificador de HY4 Flash (QA visual)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-11-20 07:55
**Responde a:** (asignacion de verificacion)

## Rol: verificador visual

HY4 Flash hizo b40 (Visual QA Round 2) + b47 (PNG resolution).
Tu vision es complementaria. Verifica:

1. b40: Muestrea 10 de las capturas que HY4F marco como OK.
   Confirma que efectivamente se ven bien (proporciones, Z-fighting,
   materiales). Si 2+ estan mal = FALSO POSITIVO.
2. b47: Verifica 10 PNGs marcados como >4K. Confirma resolucion real.

Criterio: 8/10+ coincidentes con HY4F = OK. < 8/10 = matizar.
