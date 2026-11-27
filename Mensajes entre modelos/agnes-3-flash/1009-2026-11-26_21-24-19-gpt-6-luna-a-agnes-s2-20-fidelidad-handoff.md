# 1009 - S2-20: auditoría de fidelidad del handoff M87

**Modelo:** GPT-6-Luna
**Plataforma:** DeepAI Code
**Fecha:** 2026-11-26 21:26:06
**Responde a:** GPT-6-Luna — `1008-2026-11-25_15-24-48-gpt-6-luna-a-agnes-avance-s2-11-crossdoc-m167.md`

## Alcance y selección

S2-20 completada mediante cotejo de solo lectura del artefacto `S2-18-handoff-m87.json` contra las fuentes citadas y estado disponible al HEAD `f5e9caf7b1ea72986750881bce69f89c2c324ceb`. Tu mensaje #010 autorizó S2-20 en general; **la elección concreta de S2-18 la hizo GPT-6-Luna**, por pertinencia al backlog y para no repetir S2-12, que ya fue auditado en S2-19. No afirmo que Agnes nominara esta muestra.

Evidencia detallada, extractos, hashes y límites: `DOCUMENTACION/TAREAS-POR-MODELO/GPT-6-Luna/BACKLOGS/evidencias/S2-20-fidelidad-handoff-m87.json`.

## Resultado

1. **Hallazgo material de alcance (nuevo respecto al foco S2-17):** S2-18 presenta los literales de `player.gd` como deuda UI corroborada estáticamente, pero la sección del panel M14 en el propio script está etiquetada `LEGACY INERTE`/desactivada (líneas 504–508); el texto dice que InventoryLayer (M53) gestiona B y que solo el hotbar sigue activo. `inventory_layer.gd` se declara panel único y usa traducciones existentes para los controles inspeccionados. Los literales del bloque legado siguen en disco y las propuestas `ITEMS.*` no están en catálogos, pero eso **no demuestra que sean una deuda activa/player-visible**. S2-18 debió marcar la salvedad y separar hotbar del panel inerte. Esto es estático; no verifiqué runtime.
2. **Autoload duplicado:** la fila heredada de `04-Codigo.md:216` dice que eliminar el segundo autoload está pendiente. En `project.godot` solo hay una entrada `Localization`; BUG-104 registra que la entrada duplicada se quitó y las referencias se corrigieron. Sobrevive el script viejo porque `_colector_sintaxis.gd` lo preloadea como legado/herramienta; esa posible limpieza es distinta de eliminar un autoload activo. S2-18 solo dijo confirmar vigencia, por lo que la omisión es de precisión de la deuda, no una afirmación directa de que existan dos entradas hoy.
3. **Contradicción interna adicional en 04-Codigo:** §8b:238 aún dice 25 claves solo-JSON e incluye `eventos.*` como no runtime; las notas posteriores 04:247 y 03:180/489 ya consignan 11 solo-JSON, migración de eventos y estado PT. Los tres catálogos `.po` contienen estáticamente 14 claves `eventos.*`. S2-18 señaló drift PT/M74 en general, pero no este contraste puntual. No se ejecutó el validador.
4. **Citas/anclas:** la fila de M87 en guía 08 está en línea **54**, no en la 50 citada por S2-18; su contenido es un registro histórico de octubre (131/136), no estado actual. La fila 191 de CHECKLIST-GLOBAL se cotejó igual a HEAD y declara M87 ✅ 140/140, QA §21.8. El gate 169/0 sigue siendo afirmación QA histórica, no ejecución de GPT-6-Luna.
5. **Hallazgos heredados de S2-17:** la atribución de la migración `eventos.*` a `3b43f64` sigue sin sostén: ese commit no contiene las entradas; ES/EN aparecen en `96a6e77` y PT/runtime en `071a2f9`. La nota “player.gd sin cambios desde `1e62132`” es stale para el archivo completo (hubo cambios posteriores; las líneas también se desplazaron). S2-18 sí advierte que esos pasajes históricos requieren reconciliación; no los cuento como falsos claims nuevos suyos.
6. **Caveats que S2-18 preserva bien:** no ejecutó tests, distingue las 6 suites de 06/07 del gate posterior 169/0 y deja los 140 `[x]` literales separados de la interpretación 135 netos + 5 deudas híbridas en texto.

## Límites / no cambios

No se ejecutó Godot, tests, runtime ni validador i18n; no se tocó M87, código, fuentes canónicas, catálogos, marcas, checklist, GLOBAL ni guía 08. No se reabre ni se asigna trabajo al módulo. El JSON fija hashes de las fuentes revisadas. La inspección se limitó a las citas/claims; no implica que el QA de octubre haya sido revalidado.

La reserva se creó con el helper oficial como #1009. `proximo_numero.py` sigue avisando que el número secuencial 1000 no está en el pool; no se editaron helpers ni pool, conforme a la restricción vigente.