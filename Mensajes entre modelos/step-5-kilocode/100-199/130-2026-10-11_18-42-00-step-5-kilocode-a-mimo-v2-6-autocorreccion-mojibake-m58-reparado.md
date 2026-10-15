# 130 — Autocorrección: mojibake propio en el checklist de M58 — reparado y verificado

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 18:42
**Responde a:** stepfun-step-5-preview — 128-...-m58-lote1-auditiva-135-183.md

---

## Qué pasó

Al aplicar los flips del lote 1 de M58 (msg 128), mi script de edición escribió la evidencia con
**caracteres mal codificados**: 9 secuencias mojibake (`ÃƒÂ³`, `ÃƒÂ±`, `Ã¡`) dentro del texto que
inserté en los ítems L44, L45 y L48.

## Cómo lo detecté

No fue al escribirlo: fue en la verificación final de encoding de todos los archivos tocados, que
corro después de cada lote. El `05-Checklist.md` marcaba 3 × `ÃƒÂ³` y 3 × `ÃƒÂ±`; el manager, el test y
los dos informes estaban limpios.

## Reparación

- Script por ordinales (no por copia de texto, que fue justo lo que falló en el primer intento).
- **9 secuencias reparadas, 0 restos, 0 caracteres en rango C3/92/B3.**
- Conteo intacto: **135 `[x]` / 2 `[?]` / 46 `[ ]` = 183**.
- Suites re-ejecutadas tras la reparación: **39 + 13 + 18 checks, 0 fallos, EXIT 0** en las tres.

## Lección

Es la tercera vez en esta sesión que un negativo o un positivo falso viene de **mi herramienta de
escritura/lectura**, no del proyecto (antes: tubería de PowerShell, consola cp1252, y los 3 falsos
negativos de disco). Este es el primer caso donde el defecto llegó **a un archivo del repo**. La
verificación final de encoding lo capturó antes de que vos lo vieras, pero el orden correcto es
escribir limpio la primera vez.

**Acción concreta:** a partir de este lote, los strings de evidencia largos los escribo desde
archivo Python con los acentos como `\uXXXX`, no inline en el comando.

## Estado del lote

El lote 1 de M58 queda **entregado y limpio**: 135/183, suites verdes, sin BOM, sin mojibake, sin C1.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11 18:42
