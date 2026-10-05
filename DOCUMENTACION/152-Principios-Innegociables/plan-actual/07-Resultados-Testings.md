# 07 — Resultados de Testings (M152 Principios Innegociables)

**Verificación cruzada §21.8 independiente** — verificador **Hy3 / WorkBuddy** ≠ autor
(**agnes-2.5-flash**; liberación SB-01 a cargo de **space-bunny-alpha**, Log 1270). Asignada
como **T-H5** por el director (file 36): Hy3 re-verifica el módulo porque la fila de GLOBAL
citaba un sello fraudulento "Log 866" (Log 866 = cierre AGNES, no Hy3).

## Entorno

- Binario: Godot 4.7.2 headless (`C:/Temp/godot/godot472.exe`)
- Comando: `godot472 --headless --path game/isla-ancestral --script res://scripts/principios/test_principios_m152.gd`
- Fecha: 2026-10-05

## Resultado

| Métrica | Valor |
|---------|-------|
| Exit code | 0 |
| Checks | 12 |
| Fallos | 0 |
| SCRIPT ERROR | 0 |
| Resumen nombrado | `=== Resumen M152: 12 checks, 0 fallos ===` |
| Cierre test | `TEST M152 OK — todos los checks pasaron` |

No es falso verde: el runner nombró la cantidad de checks (`_checks`) y afirmó `_fallos == 0`
antes del `quit(0)`; el `_run` no abortó. No hay `SCRIPT ERROR` que corte la ejecución (solo
WARNING benignos de M39 sobre item_id inexistentes y fugas de ObjectDB a la salida, que no afectan
el exit 0).

## Qué se verificó

- **Código existe y coincide con la documentación:** `scripts/principios/principios_auditor.gd`
  (`class_name PrincipiosAuditor`, `validar()`, `reporte()`) y `data/principios.json` (8 principios
  + `auditoria.prohibido_totalmente`) — núcleo real citado en `04-Codigo.md` (L558) como
  "validable por código". El test `test_principios_m152.gd` los precarga y valida.
- **Tests corren y pasan:** 12/0, EXIT 0 (corroborado en esta QA). Cobertura: carga de
  `principios.json` (8 principios, claves `sin_fomo`/`guardados_confiables`/`salud_jugador`/
  prohibiciones), validación de data real (0 errores) y detección de errores (sin id, duplicado,
  sin reglas, sin prohibiciones).
- **Logs y firmas presentes:** Log 1270 (SB-01, space-bunny-alpha, verificación de los 87 `[ ]`
  originales → 173 `[x]` + 29 `[?]`) y Log 1309 (esta re-verify Hy3, §21.8). Firma del verificador
  independiente: Hy3 / WorkBuddy ≠ autor agnes-2.5-flash → cumple §21.8.
- **Este artifact** se crea en la QA §21.8 (antes faltaba en el módulo).

## Conclusión

M152 cumple §21.8 en lo que respecta a la verificación cruzada: verificador independiente del
autor, código documentado y consistente, tests en verde reales. **Sello válido: ✅ Verificado por
Hy3/WorkBuddy (Log 1309, §21.8, verificador ≠ autor agnes).** El módulo **queda 🟡 201/202**
(1 `[?]` = D-R2, decisión del fundador sobre la ampliación ×10 del mapa), listo para subir a ✅
cuando el fundador decida D-R2. La fila de GLOBAL se corrigió: el sello "Log 866" era fraudulento
(Log 866 = cierre AGNES) y se reemplazó por la nota 🔶 con Log 1309.
