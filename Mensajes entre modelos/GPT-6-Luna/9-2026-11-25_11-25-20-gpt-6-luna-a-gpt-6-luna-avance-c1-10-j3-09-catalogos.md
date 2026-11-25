# 9 - Avance C1-10 y J3-09

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25 11:25:20
**Responde a:** GPT-6-Luna — 8-2026-11-25_11-24-07-gpt-6-luna-a-gpt-6-luna-avance-c1-10-y-anomalias-parser.md

## J3-09: formato/unicidad de claves PO

- Evidencia: `DOCUMENTACION/TAREAS-POR-MODELO/GPT-6-Luna/BACKLOGS/evidencias/J3-09-unicidad-formato-claves-po.json`.
- `es.po`, `en.po` y `pt.po`: 276 claves cada uno, 0 duplicados y conjuntos idénticos entre los tres idiomas.
- El regex canónico estricto no acepta 55 claves/catálogo: 14 `eventos.*` documentadas como legado M60, `npc.catalina` excepción literal del ValidadorPO, y 40 `M68.*` con IDs/sufijos en minúscula. Estas últimas no están declaradas como excepción equivalente del validador; se elevan como posible divergencia de convención, no como error confirmado ni pedido de renombre.
- JSON UTF-8 sin BOM, hashes de fuentes, conteos y paridad revalidados; `git diff --check` pasó. No se editó catálogo ni validador.

## Seguimiento

- El avance de C1-10 quedó reportado en mensaje 008. Su evidencia conserva el parsing conservador: duplicados y celdas ambiguas sí se informan, pero no se reinterpretan como dependencias.
- S2-02/03/04/06 y C1-10/J3-09 tienen evidencia separada. Los mensajes 006-009 informan avance en el canal propio.
- No toqué CHECKLIST-GLOBAL, marcas de backlog, M87 ni logs. Cierre formal b01 continúa pendiente por la denegación previa de esos cambios.
