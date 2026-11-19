# Auditoría de Contadores de Pruebas de Estrés — Módulo 113-Pruebas-De-Stress

**Modelo:** Reflection-Beam-1.0
**Plataforma:** Kilo Code
**Fecha:** 2026-11-18 23:05:29

## Alcance

- Runner: `game/isla-ancestral/scripts/stress/stress_runner.gd`.
- Base: `scripts/stress/stress_scenario.gd`.
- Comparador: `scripts/stress/stress_comparator.gd`.
- Escenario flycam: `scripts/stress/escenarios/flycam_stress.gd`.
- Checklist: `DOCUMENTACION/113-Pruebas-De-Stress/plan-actual/05-Checklist.md`.

## Hallazgos

### A. Runner (stress_runner.gd)

1. `game/isla-ancestral/scripts/stress/stress_runner.gd:77-92` (`_ejecutar_uno`) — `status` siempre "ok" y `errores` vacío; no captura excepciones de `setup()/execute()/teardown()`. Si un escenario falla, el runner no lo refleja. **Severidad: Alto.** Accionable: envolver en try/catch (o validar retornos) y marcar status "error".

2. `game/isla-ancestral/scripts/stress/stress_runner.gd:72-73` — `memoria_static_inicial_kb := memoria_inicial / 1024` (división entera). Si memoria_inicial < 1024, resulta 0 KB. **Severidad: Bajo.** Accionable: usar float division.

3. `game/isla-ancestral/scripts/stress/stress_runner.gd:104-108` (`_es_check_status`) — solo verifica status == "ok", pero status siempre "ok" (ver hallazgo 1). **Severidad: Medio.** Accionable: vincular a métricas no vacías y errores.

### B. Escenario FlyCam (flycam_stress.gd)

4. `game/isla-ancestral/scripts/stress/escenarios/flycam_stress.gd:25-26` — `RADIO := 256.0`, `CENTRO := Vector2(256.0, 256.0)`. El mundo real es 5120×5120 con centro (2560,2560). El recorrido no coincide con el mundo real. **Severidad: Medio.** Accionable: usar centro/radio del mundo real o documentar como fixture.

5. `game/isla-ancestral/scripts/stress/escenarios/flycam_stress.gd:34` y `:56` — `_fuera_de_radio` se incrementa globalmente en `_recorrer` (L72) y se ejecuta PASADAS (200) veces. El contador acumula entre pasadas, no por pasada. **Severidad: Medio.** Accionable: resetear por pasada o contar por pasada.

6. `game/isla-ancestral/scripts/stress/escenarios/flycam_stress.gd:65` — `_plan[i % _plan.size()]`. Si `_plan` vacío, `_recorrer` retorna false (L61-62) antes. OK. Pero `_plan` sintético tiene 45 puntos; si el plan real tiene 0, fallback. OK.

7. `game/isla-ancestral/scripts/stress/escenarios/flycam_stress.gd:51` — `frame_ms := snappedf(total / float(MUESTRAS * PASADAS), 0.0001)`. total es suma de ms de PASADAS pasadas. OK. No off-by-one.

### C. Base (stress_scenario.gd)

8. `game/isla-ancestral/scripts/stress/stress_scenario.gd:48-61` (`_resumen_metrica`) — si muestras vacío → ceros. OK. `_percentil` (L64-73): base = int(pos); si n=1, pos=0, base=0, base >= n-1 → returns ordenadas[0]. OK.

9. `game/isla-ancestral/scripts/stress/stress_scenario.gd:84-88` (`_medir_ms`) — mide Callable. OK.

### D. Comparador (stress_comparator.gd)

10. `game/isla-ancestral/scripts/stress/stress_comparator.gd:61-80` (`comparar`) — regresión si delta > umbral (0.05). Solo compara p95, no max. **Severidad: Bajo.** Accionable: comparar también max si se desea.

11. `game/isla-ancestral/scripts/stress/stress_comparator.gd:91-103` (`cargar`) — si baseline inválido → {}. OK.

### E. Checklist (05-Checklist.md M113)

12. `DOCUMENTACION/113-Pruebas-De-Stress/plan-actual/05-Checklist.md:259-261` — Totales contradictorios: L259 "132/132/0/0", L260 "132/131/0/1", L261 "131 [x]/0 [ ]/1 [?]". Drift de contadores declarados. **Severidad: Alto.** Accionable: mantener una sola línea de Totales actualizada.

13. `DOCUMENTACION/113-Pruebas-De-Stress/plan-actual/05-Checklist.md:283` — QA cruzado dice 132 [x]/0 [ ]/0 [?]. L287 aritmética 102+29+1=132. Pero L261 dice 131 [x]/1 [?]. Drift. **Severidad: Medio.** Accionable: reconciliar.

14. `DOCUMENTACION/113-Pruebas-De-Stress/plan-actual/05-Checklist.md:269` — afirma 102 [x]/0 [?]/30 [ ]. L272 afirma 102 [x]/0 [?]/30 [ ]. L283 afirma 132 [x]/0 [ ]/0 [?]. Inconsistente. **Severidad: Medio.** Accionable: reconciliar.

### F. Validación de entrada en runners de estrés

15. `game/isla-ancestral/scripts/stress/stress_runner.gd:35-37` — si `_escenarios` vacío → quit(1). OK. Pero no valida nombres únicos. **Severidad: Ruido.** Accionable: validar unicidad.

16. `game/isla-ancestral/scripts/stress/stress_runner.gd:94-102` (`_escribir_reporte`) — si file null, push_warning y return. OK.

17. `game/isla-ancestral/scripts/stress/stress_comparator.gd:107-114` (`guardar`) — si file null, push_warning. OK.

## Mejoras de diseño concretas

1. **Captura de errores en el runner**: modificar `stress_runner._ejecutar_uno` para envolver setup/execute/teardown en try/catch (o validar retornos) y marcar status "error" con errores, evitando falsos "ok".

2. **Alinear flycam con el mundo real**: usar centro/radio del mundo real (2560, 2560, radio 2560) o documentar explícitamente el fixture de 256, y resetear `_fuera_de_radio` por pasada para que la integridad sea por pasada.
filePath">
D:\Escritorio\PORTFOLIO\Proyectos para GitHub\PROYECTOS OPENCODE\juego-isla-ancestral\Mensajes entre modelos\Reflection-Beam-1.0\REPORTES-Prueba-Paralela\reporte_beam_stress_2026-11-18.md