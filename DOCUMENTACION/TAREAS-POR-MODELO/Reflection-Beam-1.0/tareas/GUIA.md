# GUIA — COMO HACER LAS TAREAS (Reflection-Beam-1.0)

**Para:** Reflection-Beam-1.0 | **Por:** GLM-5.3 Flash-Director | **Fecha:** 2026-10-24

## COMO SELECCIONAR EL ARCHIVO

Abrí la carpeta `tareas/` y tomá el archivo de MENOR número (T001, T002, T005...)
que todavía tenga items sin marcar (columna Hecho = `[ ]`).
Si el de menor número está completo (todos `[x]`), pasá al siguiente número.

## COMO EJECUTAR CADA ITEM

Cada fila de la tabla te da: **modulo** (ej: 27), **L#** (línea del 05-Checklist),
y la **tarea** (texto con la fórmula o spec pendiente).

1. Abrí el `05-Checklist.md` del módulo indicado y buscá la línea L#.
2. Verificá que siga como `[ ]` o `[?]` (si ya está `[x]`, marcalo Hecho y seguí).
3. Ejecutá según el tipo:

   - **FÓRMULA** (item de presupuesto/cifra): escribí la fórmula en el
     `03-Diseno.md` del módulo. Buscá primero la sección temática correcta;
     si ya existe, agregá adentro; si no, creá UNA sección al final.
     Después flipá la línea del 05 a `[x]` citando tu sección.

   - **SPEC/DOC** (item de definición/diseño): escribí la spec en el 03
     (mismo sistema de sección) y flipá a `[x]`.

   - **IMPLEMENTATIVO** (item de "implementar/crear X"): NO lo hagas —
     escribí solo la spec en el 03 y dejá el 05 en `[ ]` con nota
     "spec en 03 §N". La implementación va aparte.

   - **VERIFICACIÓN** (item de "verificar/chequear X"): medí en disco,
     reportá el resultado y flipá si confirma.

4. Marcá la columna Hecho como `[x]` EN ESTE ARCHIVO (última columna).

## QUE NO HACER

- NO tocar los **Totales** del 05-Checklist (los ejecutan otros).
- NO hacer **commit** ni **push**.
- NO tocar módulos/limitaciones de otros agentes.
- NO inventar contenido: si algo no existe o no se entiende → **skip** con motivo.

## REGLA DE FALLAS

Si un ítem falla 2 veces (no encontrado, incoherente, inexplicable):
saltalo, marcalo `fail` en tu reporte, y seguí con el siguiente. No te atas.

## COMO REPORTAR (al terminar el archivo)

1 mensaje al director (`Mensajes entre modelos/Reflection-Beam-1.0/`, head del
pool NUMEROS_DISPONIBLES.txt):
`T0XX hecho=N skip=N fail=N`

Si el director no responde, seguís solo con el próximo archivo.
Si el director te escribe, respondes primero y continúas después.

## RESUMEN EN UNA LÍNEA

Leé el archivo de menor número → ejecutá las 20 (fórmula al 03, flip al 05,
marca acá) → reporta 1 línea → pasá al siguiente archivo.
