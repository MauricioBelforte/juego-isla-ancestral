# Auditoría de Contadores de Tests Automáticos — Módulo 112-Testing-Automatico

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-18 22:40:45

## Alcance

- Runner: `game/isla-ancestral/tests/run_tests.gd` (v2c).
- Checklist: `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md`.
- Scripts de soporte: `scripts/test_scripts.py`, `scripts/verificar_checklist.py`.
- Auditoría de contadores de cobertura, suites, off-by-one, drift declarado vs real, validación de entrada en runners.

## Hallazgos

### A. Runner (run_tests.gd)

1. `game/isla-ancestral/tests/run_tests.gd:100-102` — `LANE_SERIE_EXPLICITA` contiene `res://scripts/vehiculos/test_vehiculos.gd`, pero `_descubrir()` solo barre `res://tests` salvo que `_incluir_modulos()` sea true (L148, env/flag). Por defecto la suite no se descubre → silencio. **Severidad: Medio.** Accionable: mover la suite a `tests/` o activar inclusión por defecto con medición de tiempo.

2. `game/isla-ancestral/tests/run_tests.gd:348-358` — `_checks_total` solo se incrementa en suites OK (L350); suites fallidas no aportan sus checks al total. Drift del contador de tests totales. **Severidad: Medio.** Accionable: sumar checks de todas las suites ejecutadas, no solo las OK.

3. `game/isla-ancestral/tests/run_tests.gd:453-456` — GdUnit4 se trata como un bloque único: si falla, `_suites_ok` no incluye ninguno, pero `_gdunit_dirs.size()` suites se cuentan como descubiertas. Drift de conteo suites OK/descubiertas. **Severidad: Medio.** Accionable: reportar por directorio GdUnit o ajustar el criterio de OK por suite.

4. `game/isla-ancestral/tests/run_tests.gd:361-397` (`_analizar_salida`) — si el texto contiene varios patrones ("N checks, M fallos", "passed=N failed=M", etc.), solo el primero que matchea se usa (if/else). Posible subconteo si una suite imprime múltiples formatos. **Severidad: Bajo.** Accionable: tomar el máximo de checks entre patrones o documentar el formato único.

5. `game/isla-ancestral/tests/run_tests.gd:278` (`_instancia_voxel`) — detección por substring "main_island" puede generar falsos positivos si aparece en comentarios. **Severidad: Ruido.** Accionable: detección por regex de instanciación real.

6. `game/isla-ancestral/tests/run_tests.gd:292` (`_es_segura_para_pool`) — detección por substring "user://" puede generar falsos negativos si aparece en comentarios. **Severidad: Ruido.** Accionable: detección por regex de escritura real.

7. `game/isla-ancestral/tests/run_tests.gd:467` — `tests_total := _checks_total + _tests_gdunit` no incluye suites SceneTree fallidas que sí reportaron checks. Drift. **Severidad: Bajo.** Accionable: alinear con el total de checks reportados por todas las suites.

### B. Checklist (05-Checklist.md M112)

8. `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md:262` y `:263` y `:302` y `:339` — múltiples líneas de "Totales" con valores distintos (226/222/0/4, 232/228/0/4, 225/211/5/9, 216/0/9=225). Drift de contadores declarados. **Severidad: Alto.** Accionable: mantener una sola línea de Totales actualizada y archivar las históricas.

9. `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md:375` — recuento "475 archivos test_*.gd" vs 481 reales (delta +6). Drift. **Severidad: Bajo.** Accionable: recalcular con `glob` y actualizar.

10. `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md:376` — no existe contador persistente de flakes; techo 2/sem sin instrumento. Contador no implementado. **Severidad: Medio.** Accionable: agregar contador de flakes en disco (tag [FLAKY]) y alerta 3+.

11. `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md:124` y `:258` — tiempo de suite 620.1s (10.34min) excede 10min; re-medido 897s. Drift de contador de tiempo. **Severidad: Medio.** Accionable: documentar el tiempo real medido y el presupuesto.

12. `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md:98-99` y `:255` — cobertura NO MEDIBLE (GdUnit4 v6.2.1 headless sin runner de cobertura); umbrales 70%/60%/50% declarados sin instrumento. **Severidad: Alto.** Accionable: implementar runner de cobertura o ajustar umbrales a lo medible.

13. `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md:190` — seed fijo no testeado (0 tests con "seed"/"SEED"). Contador 0. **Severidad: Medio.** Accionable: agregar tests de generación determinista con seed fijo.

14. `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md:200-201` — fallbacks M122: 0 tests de crash paths (luego cerrado con suite). **Severidad: Bajo.** Accionable: mantener la suite `test_m122_fallbacks_datos_invalidos.gd` en el runner por defecto.

15. `DOCUMENTACION/112-Testing-Automatico/plan-actual/05-Checklist.md:257` — máquina limpia pendiente CI real; contador no medido. **Severidad: Bajo.** Accionable: ejecutar CI real y registrar resultado.

### C. Validación de entrada en runners

16. `scripts/test_scripts.py` — no valida contadores de tests ni drift de suites; solo valida scripts de automatización. **Severidad: Bajo.** Accionable: extender con checks de conteo de suites y checks.

## Mejoras de diseño concretas

1. **Unificar el conteo de tests**: modificar `run_tests.gd` para sumar checks de todas las suites ejecutadas (OK y fallidas) y reportar un solo total medido, evitando drift entre `_checks_total` y los checks reales.

2. **Instrumentar contador de flakes persistente**: agregar un archivo `tests/flakes_counter.json` actualizado por el runner con tag [FLAKY], alerta 3+/semana, y umbral 2/sem documentado en el checklist, cerrando la deuda de observabilidad.
filePath">
D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\Mensajes entre modelos\Reflection-Beam-1.0\REPORTES-Prueba-Paralela\reporte_beam_tests_automaticos_2026-11-18.md