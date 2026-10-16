# Log 1875: Regla de numeración de mensajes corregida — manda la secuencia del hilo

**Fecha:** 2026-10-15
**Hora:** 22:20
**Modelo:** GLM-5.3-Flash
**Plataforma:** Kilo Code

## Resumen

Por directiva directa del fundador (chat, 2026-10-15), se reformuló la regla de numeración de mensajes entre modelos para eliminar la ambigüedad que hizo fallar a GLM-5.3-Flash en su primera respuesta de canal: la regla anterior ("tomar el número más alto del pool") es solo un atajo válido cuando el pool refleja la secuencia del hilo; en un canal recién abierto con pool sobredimensionado induces a numerar por encima de `último + 1` y romper la consecutividad del hilo.

## La regla corregida (ahora vigente)

**El número de un mensaje SIEMPRE es el siguiente consecutivo del canal:** `NN = (último NNN- de mensaje en la carpeta) + 1`.

Puntos clave:
1. Prohibido numerar por debajo del último mensaje existente (huecos del medio — síntoma DeepSeek 113, 2026-10-11).
2. Prohibido numerar por encima de `último + 1` (sobrantes de pool sobredimensionado — síntoma real GLM-5.3-Flash 150, 2026-10-15: canal en el 01 con pool 2..150 → respuesta en 150, corregida por el fundador a 02).
3. Al escribir, se borra del pool SOLO el número usado.
4. Los números del pool por encima de `último + 1` se ignoran para el hilo (reserva del pool, no candidatos).
5. Ante discrepancia pool ↔ hilo (pool vacío, huecos, sobrantes), avisar al director para saneo; mientras tanto, numerar con `último + 1`.

## Cambios Realizados

- `Mensajes entre modelos/GUIA-COMUNICACION.md`: se sustituyó el bloque "REGLA DEL NÚMERO MÁS ALTO (directiva del fundador 2026-10-11)" por "REGLA DE NUMERACIÓN — MANDA LA SECUENCIA DEL HILO", con el orden de decisión práctico (6 pasos), los dos síntomas reales (DeepSeek 113 y GLM 150) y la regla de discrepancias. Se agregó firma de actualización 2026-10-15 (GLM-5.3-Flash / Kilo Code).
- `AGENTS.md` §10.2 (regla 4, "Numeración de mensajes: pool por CANAL"): misma reforma en espejo — descripción del helper alineada ("el número que corresponde a la secuencia del hilo") y blockquote con la regla, el atajo condicionado, el caso del canal nuevo y el protocolo de discrepancia.
- NO se modificó `scripts/reservar_mensaje.py` ni su suite (`test_reservar_mensaje_colision.py`, 18/18 PASS): el helper sigue tomando el más alto del pool, lo que es correcto SI el pool está saneado (contiene `último + 1` como número más alto del hilo). La regla documental cubre el caso del pool sobredimensionado que el script no puede distinguir. Queda señalado como deuda potencial si el director quiere blindar también el script.

## Archivos Modificados/Creados

- `Mensajes entre modelos/GUIA-COMUNICACION.md` (regla + firma)
- `AGENTS.md` (§10.2, regla 4)
- `Logs/NUMEROS_DISPONIBLES.txt` (consumo del 1875)

## Lección registrada

La regla del "número más alto" (2026-10-11) fue creada para curar el síntoma de numerar POR DEBAJO del último mensaje (huecos del medio). Su redacción omitió el límite superior: en un canal nuevo con pool pre-cargado, "el más alto" rompe la consecutividad por arriba. La regla correcta es simétrica y simple: el hilo manda (`último + 1`), el pool se consume y se sana, nunca se numera fuera de rango.

**Firma:** GLM-5.3-Flash / Kilo Code — Log 1875
