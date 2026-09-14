# Log 866 — HY3 — QA cruzado Lote F (headless EXIT 0)

**Fecha:** 2026-09-12 | **Agente:** Hy3/WorkBuddy | **Protocolo:** §21.8 (verifier ≠ author)
**Alcance:** 33 módulos "🟢 Disponible" sin sello §21.8 previo, verificados por ejecución headless real.
**Resultado global:** 33/33 tests EXIT 0, 0 fallos, 0 bugs.

## Metodología
Para cada módulo se ejecutó `"<godot>" --headless --path game/isla-ancestral --script res://scripts/<dom>/<test>.gd`.
El test llama `quit(0 if _fallos==0 else 1)`. EXIT 0 = verificado. Criterio de honestidad: los tests que
solo emiten ruido de shutdown ("ObjectDB leaked") pero corrieron completos NO se cuentan como regresión.

## Tabla de resultados (headless)
| MID | Módulo | Test | Resultado |
|-----|--------|------|----------|
| 1 | 01-Fundamentos-Del-Proyecto | test_fundamentals_m01.gd | EXIT 0 (8 checks) |
| 2 | 02-Vision-Y-Concepto | test_vision_m02.gd | EXIT 0 (8 checks) |
| 3 | 03-Documentacion-Del-Proyecto | test_documentation_m03.gd | EXIT 0 (8 checks) |
| 6 | 06-Control-De-Versiones | test_version_control_m06.gd | EXIT 0 (6 checks) |
| 100 | 100-Community-Management | test_community_m100.gd | EXIT 0 (8 checks) |
| 106 | 106-Seguridad | test_security_m106.gd | EXIT 0 (12 checks) |
| 113 | 113-Pruebas-De-Stress | test_stress_m113.gd | EXIT 0 (19 checks) |
| 114 | 114-Playtest | test_playtest_m114.gd | EXIT 0 (14 checks) |
| 120 | 120-DLC-Y-Expansiones | test_dlc_m120.gd | EXIT 0 (16 checks) |
| 121 | 121-Soporte-Post-Lanzamiento | test_support_m121.gd | EXIT 0 (15 checks) |
| 125 | 125-Terminos-De-Servicio | test_terms_m125.gd | EXIT 0 (9 checks) |
| 126 | 126-Marketing-Legal | test_marketing_legal_m126.gd | EXIT 0 (9 checks) |
| 128 | 128-Identidad-De-Marca | test_brand_m128.gd | EXIT 0 (8 checks) |
| 129 | 129-Merchandising | test_merch_m129.gd | EXIT 0 (8 checks) |
| 130 | 130-Artbook | test_artbook_m130.gd | EXIT 0 (8 checks) |
| 132 | 132-Produccion-De-Equipo | test_production_m132.gd | EXIT 0 (8 checks) |
| 150 | 150-Diseo-Sonoro-Narrativo | test_narrative_m150.gd | EXIT 0 (12 checks) |
| 152 | 152-Principios-Innegociables | test_principios_m152.gd | EXIT 0 (12 checks) |
| 38 | 38-Economia | test_m38_economia_smoke.gd | EXIT 0 (smoke) |
| 44 | 44-ASMR-Y-Feedback | test_feedback_m44.gd | EXIT 0 (9 checks) |
| 78 | 78-Legal-Propiedad-Intelectual | test_legal_m78.gd | EXIT 0 (9 checks) |
| 79 | 79-Legal-Contratos | test_contracts_m79.gd | EXIT 0 (9 checks) |
| 80 | 80-Legal-Privacidad | test_privacy_m80.gd | EXIT 0 (10 checks) |
| 81 | 81-Legal-Menores | test_minors_m81.gd | EXIT 0 (8 checks) |
| 82 | 82-Clasificacion-Por-Edades | test_rating_m82.gd | EXIT 0 (9 checks) |
| 84 | 84-Musica-Y-Audio-Legal | test_audio_licenses_m84.gd | EXIT 0 (8 checks) |
| 85 | 85-Modelos-3D-Legal | test_model3d_m85.gd | EXIT 0 (8 checks) |
| 86 | 86-IA-Generativa | test_genai_m86.gd | EXIT 0 (8 checks) |
| 88 | 88-Fuentes-Tipograficas | test_fonts_m88.gd | EXIT 0 (11 checks) |
| 97 | 97-Steam-Store-Page | test_store_m97.gd | EXIT 0 (15 checks) |
| 98 | 98-Trailer | test_trailer_m98.gd | EXIT 0 (12 checks) |
| 99 | 99-Marketing | test_marketing_m99.gd | EXIT 0 (11 checks) |
| 55 | 55-Diario-Del-Jugador | test_diario.gd | EXIT 0 (smoke) |


## Notas de honestidad
- M38: `test_m38_economia_smoke.gd` es smoke test (0 fallos, sin conteo de checks explícito) → EXIT 0 válido.
- M55: `test_diario.gd` (DiaryService) EXIT 0; emite "ObjectDB leaked at exit" (ruido de shutdown, no fallo de test).
- Los tests de módulos legales/marketing/comunidad (M78-M86, M97-M99, M125-M132) verifican artifacts de
  cumplimiento/documentación; EXIT 0 confirma presencia y coherencia de los entregables.

## Total §21.8 tras Lote F
Antes Lote F: 73. Lote F headless: +33. Total = 106.
