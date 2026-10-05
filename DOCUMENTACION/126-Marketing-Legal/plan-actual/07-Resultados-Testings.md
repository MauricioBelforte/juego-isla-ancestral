# 07 — Resultados de Testings (M126 Marketing-Legal)

**Verificación cruzada §21.8 independiente** — verificador **Hy3 / WorkBuddy** ≠ autor
(**agnes-2.5-flash**; cierre final **agnes-3-flash**, Log 981). Asignada como T-H4 por el
director (file 34): agnes no puede sellarlo por sobre-cierre SB-02.

## Entorno

- Binario: Godot 4.7.2 headless (`C:/Temp/godot/godot472.exe`)
- Comando: `godot472 --headless --path game/isla-ancestral --script res://scripts/legal/test_marketing_legal_m126.gd`
- Fecha: 2026-10-05

## Resultado

| Métrica | Valor |
|---------|-------|
| Exit code | 0 |
| Checks | 9 |
| Fallos | 0 |
| SCRIPT ERROR | 0 |
| Resumen nombrado | `=== Resumen M126: 9 checks, 0 fallos ===` |
| Cierre test | `TEST M126 OK — todos los checks pasaron` |

No es falso verde: el runner nombró la cantidad de checks y afirmó 0 fallos antes del
exit 0 (el `_run` no abortó).

## Qué se verificó

- **Código existe y coincide con la documentación:** `scripts/legal/marketing_legal_validator.gd`
  (`class_name MarketingLegalValidator`, `validar()`) y `scripts/legal/test_marketing_legal_m126.gd`
  referenciados en `04-Codigo.md` (L102-L105) y cableados al gate duro `quality.yml`.
- **Tests corren y pasan:** 9/0, EXIT 0 (corroborado en esta QA, y en Log 981 / Log 1027).
- **Logs y firmas presentes:** Log 981 (cierre agnes-3-flash), Log 1027 (re-QA atria-dawn,
  mantiene 🟡 con 1 flip + 1 reparación), Log 1066 (reconciliación Hy3 contenido 4→59).
- **Este artifact:** creado por la QA §21.8 (antes faltaba en el módulo).

## Conclusión

M126 cumple §21.8: verificador independiente del autor, código documentado y consistente,
tests en verde. **Sello: ✅ Verificado por Hy3/WorkBuddy (Log 1303, §21.8, verificador ≠
autor agnes).** Módulo sube a ✅ Completado (101/101).
