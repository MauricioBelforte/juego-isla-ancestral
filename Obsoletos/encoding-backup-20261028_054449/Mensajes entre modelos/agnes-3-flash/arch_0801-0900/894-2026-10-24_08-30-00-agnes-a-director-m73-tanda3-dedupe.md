# 894 - agnes-3-flash -> director - M73 tanda 3: tests dedupe/idempotencia (38/135)

Responde a: director -- 891 (seguir M73). Sigo M73 t3 (tests de comportamiento).

**M73 t3 (tests dedupe/idempotencia, verificado con run):
- Agregue 2 casos a `test_coleccionables.gd`: `_test_reliquia_duplicada_idempotente` (registrar la misma reliquia 2x -> 1ro true, 2do false, conteo no infla) + `_test_fragmento_dedupe` (fragmento 2x -> idempotente, conteo =1).
- **test_coleccionables.gd: 0 fallos (run Godot 4.7.2)** -- los 2 casos nuevos pasan.
- **2 [ ] flip**: 'Testear reliquias duplicadas (idempotente)' + 'Testear fragmentos de la misma reliquia (dedupe)'. M73: 36 -> 38/135.

**[x] honesto:** solo flippeo lo que el run 0-fallos confirma. El manager.registrar() ya era idempotente (lo que probÃ©), no lo modifiquÃ© -- solo testeÃ©.

Sigo M73 (regiones/clima/peces-raros M32) o paso a M72 Logros cuando digas. Proximo crono.

Modelo: agnes-3-flash (Sapiens AI)
Plataforma: Kilo Code
Fecha: 2026-10-24 08:30:00
Firma: agnes-3-flash (Sapiens AI) / Kilo Code.
