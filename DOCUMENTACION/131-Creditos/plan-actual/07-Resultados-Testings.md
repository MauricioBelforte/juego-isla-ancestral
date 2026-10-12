# 07-Resultados-Testings.md — Módulo 131: Créditos

**Modelo:** Ling-3.1-Flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-11
**Contexto:** cierre del encargo M131 (msg 50 del director). Este archivo cubre el gap
DoD detectado por agnes-3-flash (Log 1425: "07-Resultados-Testings.md AUSENTE").

## Entorno de pruebas

- **Binario:** Godot 4.7.2.stable.official (`C:\Temp\godot\godot472.exe`)
- **Modo:** headless (`--headless --path game\isla-ancestral --script res://...`)
- **Fecha de re-corrida:** 2026-10-11 (evidencia fresca; los resultados
  históricos se citan con su fecha original)

## Suite 1 — `scripts/legal/test_credits_m131.gd` (validador + catálogo + anti-drift)

**Resultado: 15 checks / 0 fallos — EXIT=0** (re-corrido 2026-10-11)

| # | Check | Resultado |
|---|---|---|
| 1 | creditos.json cargado | OK |
| 2 | secciones >= 3 (contrato T-104: umbral, no exacto) | OK |
| 3 | data válida (0 errores, CreditsValidator) | OK |
| 4 | reporte OK | OK |
| 5 | sin id detectado (validator) | OK |
| 6 | sin título detectado (validator) | OK |
| 7 | sin entradas detectado (validator) | OK |
| 8 | sin políticas detectado (validator) | OK |
| 9 | catalogo_creditos.tres existe | OK |
| 10 | carga como CreditsCatalog | OK |
| 11 | 7 secciones | OK |
| 12 | 2 idiomas | OK |
| 13 | version 2 | OK |
| 14 | ids secciones == JSON (anti-drift) | OK |
| 15 | politicas == JSON (anti-drift) | OK |

Checks 9-15 agregados 2026-10-11 (E.L58): verifican que el Resource tipado
`data/legal/catalogo_creditos.tres` exista, cargue como `CreditsCatalog` y
coincida con el JSON canónico (anti-drift). Regeneración:
`godot472.exe --headless --path game\isla-ancestral --script res://scripts/legal/generar_catalogo_tres_m131.gd`
(EXIT=0, verificación integrada: 7 secciones, 2 idiomas, version 2).

## Suite 2 — `scripts/legal/test_credits_layer_m131.gd` (pantalla de créditos)

**Resultado: 43 checks / 0 fallos — EXIT=0** (re-corrido 2026-10-11; 42 checks
originales 2026-10-02 + 1 agregado desde entonces). Cubre los 10 ítems de la
Sección D + C38 (contador) + J103/J104/J106.

## Suite 3 — histórica (contexto)

- `test_credits_m131.gd` original: 8 checks / 0 fallos (Hy3, 2026-09-02).
- `test_credits_m131_v2.gd`: conmutación y navegación OK (Hy3, 2026-09-02).
- `test_credits_m131_iter2.gd`: búsqueda y scroll OK (Hy3, 2026-09-02).
- Cierre BUG-081 (mimo, 2026-09-30): `run_tests.py --module m131` → 3 OK / 0 FAIL.

## Ítems NO testeables (9 ítems de audio, sección I)

Los 9 ítems de audio (I.L90-97, I.L99) **no tienen tests** porque no hay
artefacto que testear: 0 archivos de audio en el repo (0 .ogg/.wav/.opus/.mp3).
Los motores M41/M42/M43/M91 existen y pasan sus propios tests (M41 14/0,
M43 15/0). Especificación de cableado punto por punto:
`10-Especificacion-Integracion-Audio.md`. Quedan `[ ]` con dueño
(regla anti-inflación §21.8.2.b: el artefacto citado debe existir).

## Criterios de éxito (definición)

- Todo check debe imprimir `[OK]` y el resumen debe cerrar en `0 fallos`.
- El proceso debe terminar con código de salida 0 (`quit(0)`).
- Los tests headless arrancan el boot completo del juego (autoloads); los
  `WARNING`/`ERROR` de módulos ajenos (M39, M48) son preexistentes y no
  corresponden a M131.

## Conclusión

M131 es **testeable y verde** en su capa de datos, validación y UI. La única
deuda real es el contenido de audio (9 ítems, dueño M41/M42/M43/M91),
documentada con especificación de cableado. El módulo cumple la DoD de
testing (§14) para todo ítem con artefacto en disco.
