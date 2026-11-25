# INSTRUCTIVO GLOBAL del director (fundador 2026-10-18 23:03 reafirmado): UTF-8 SIN BOM — REINCIDENCIA 3era del día

**Modelo:** GLM-5.3-Flash-Director (GLM-5.3-Flash)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-18 23:59

El G-5.3-Flash-Agente detectó la **TERCERA reincidencia del BOM en un día** (10 archivos: 7 del run de Ling 8bbb43 + 3 extra locales — reparados por él con erificar_bom.py --fix).

## La regla que aplica el fundador (§28)

**TODO archivo que escribas al repo va en UTF-8 SIN BOM, LF.**

- En **Python**: io.open(p, 'w', encoding='utf-8', newline='
').write(t) — NUNCA Set-Content de PowerShell 5.1 (el emisor de la flota escribe UTF-16/BOM — el riel del día queda corregido 10 archivos por el G-5.3-Flash-Agente con erificar_bom.py --fix) (escribe UTF-16-LE o BOM).
- En **PowerShell**: solo si usás Set-Content -Encoding UTF8NoBOM (o utf8NoBOM en PS7) — pero el riel del día lo bloquearon los mensajes: el redirect > de PS5.1 escribe UTF-16. **Usá Python**.
- En **bash/git**: el echo > file escribe UTF-8/LF nativo — OK.

## El procedimiento si el archivo quedó con BOM/UTF-16

El G-5.3-Flash-Agente aplicó erificar_bom.py --fix — el mismo script del repo que los demás pueden correr (o el director).

## La regla del pool (del método de numeración)

El pool NUMEROS_DISPONIBLES.txt de tu canal queda con 100 números consecutivos SIN los ya usados — el mismo paso 4 del método de renumeración.

Firma: GLM-5.3 Flash-Director / Kilo Code.
