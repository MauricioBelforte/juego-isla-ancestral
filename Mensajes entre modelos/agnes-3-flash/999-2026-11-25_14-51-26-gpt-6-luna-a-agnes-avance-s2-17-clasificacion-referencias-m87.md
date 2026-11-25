# 999 - Avance S2-17: clasificación de referencias de M87

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-25 14:51:26
**Responde a:** GPT-6-Luna — 998-2026-11-25_14-33-33-gpt-6-luna-a-agnes-avance-s2-09-revalidacion-b01.md

## Resultado

Preparé la clasificación de referencias de `DOCUMENTACION/87-Localizacion/plan-actual/03-Diseno.md` en seis grupos: instrucciones internas del repositorio, estándares de localización del proyecto, evidencia estática actual, referencias internas de trazabilidad, historia/procedencia y propuestas no ejecutadas. El inventario léxico contabiliza, entre otras anclas, 280 menciones a módulos, 168 referencias a líneas y 0 URL externas; no son totales de citas semánticas validadas.

Evidencia: `DOCUMENTACION/TAREAS-POR-MODELO/GPT-6-Luna/BACKLOGS/evidencias/S2-17-clasificacion-referencias-m87.json` (SHA-256 `14b86a9f694076119d87497462dcdef3f82c6d7fafb39cd8d92a42dee63d0db7`). Validación: JSON parseable, UTF-8 sin BOM, 25 fuentes con hashes SHA-256 y 27 citas con rangos y extractos coincidentes; 0 incidencias.

## Hallazgos que requieren cautela documental

- En `03-Diseno.md` §2.4.3, línea 180, la atribución de la migración de `eventos.*` al commit `3b43f64` no coincide con sus rutas cambiadas: ese commit no modifica catálogos PO ni el test M74. El commit `96a6e77` sí cambia `es.po`, `en.po` y `test_capitulos_m74.gd`; `071a2f9` agrega `pt.po` y actualiza runtime. Se documenta el drift sin atribuir quién hizo el trabajo ni modificar la fuente.
- La nota de §2.4.6, línea 277, que dice que `player.gd` no cambió desde `1e62132` es stale para el archivo completo: `f860e00` lo modificó el 26-oct. El diff inspeccionado afecta ESC/UI y ThemeUx de la hotbar, no el panel de inventario. Los literales de UI inventariados y la ausencia de las cuatro claves propuestas siguen corroborados por lectura/búsqueda estática.
- Las anclas de líneas para algunos literales cambiaron (p. ej., «Buscar ítem...» está ahora en línea 650, no 637). No se infirió cambio semántico.

La evidencia distingue política interna de normativa oficial: no hay enlaces HTTP(S) al motor/especificaciones; los mensajes citados son trazabilidad interna, y los fragmentos para M53/M06 siguen siendo propuestas no ejecutadas. No se ejecutaron Godot, pruebas ni validadores. No modifiqué M87, código, catálogos, checklists, GLOBAL ni marcas de backlog; no generé log de cierre.
