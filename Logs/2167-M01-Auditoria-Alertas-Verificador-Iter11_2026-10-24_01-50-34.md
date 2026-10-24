# Log 2167 - M01 iter.11: auditoria de las 42 alertas del verificador (clasificacion por causa raiz)

**Fecha:** 2026-10-24 01:50:34
**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Modulo:** M01 Fundamentos Del Proyecto
**Entrada:** mensajes del director 381 (iter.10 ratificada + decisiones aplicadas) y 382 (proxima tanda D-6, despues de la COLA). Tracker 379 -> 382.
**Marcas:** 0 flips / 0 commits / 0 push. Ninguna edicion a CHECKLIST-GLOBAL.md ni a verificar_checklist.py.

## 1. Tarea ejecutada (COLA: auditoria de las 42 alertas del gate)

El director definio en el 382 que mi COLA actual era "la auditoria de las 42/48 del
verificar". El gate corre con EXIT 1 y 42 alertas, pero publica el texto de cada una
sin decir de que familia es: un drift real, un sintoma de fila mal formada y un falso
positivo categorico del propio gate salen todos con el mismo icono.

Entregable: `scripts/auditar_alertas_verificador.py` (NUEVO). No reimplementa el gate:
importa `verificar_checklist` y consume su lista de alertas. Si el gate cambia la
redaccion, el clasificador falla en voz alta (exit 2) en vez de devolver una tabla
verde e incompleta.

## 2. Resultado medido: 42 de 42 clasificadas, 0 sin clasificar, EXIT 0

| Clase | Alertas |
|---|---|
| drift_progreso_obsoleto | 15 |
| drift_estado_sobrescrito | 10 |
| estado_disponible_con_avance (FALSO POSITIVO del gate) | 7 |
| colgado_timestamp_en_celda_equivocada (sintoma) | 4 |
| colgado_actividad_vencida (REAL) | 2 |
| colgado_sin_timestamp (1 sintoma + 1 real) | 2 |
| drift_progreso_con_texto_anexo (numero correcto) | 1 |
| cobertura_fila_sin_checklist | 1 |

De las 42: 8 no senalan defecto de progreso (7 del eje de reclamo + 1 con prosa en la
celda numerica) y 6 son sintomas de filas mal formadas. Las 26 de drift SI son reales,
pero 15 de esas 26 tienen ademas el bloque `Totales` del propio checklist incoherente:
arreglar el GLOBAL solo no reconcilia el modulo.

## 3. Hallazgo 1: el gate confunde el eje de RECLAMO con el eje de AVANCE (7 alertas)

`verificar_checklist.py` alerta si `x > 0` y el emoji es `BLANCO (U+2B1C)` o `VERDE (U+1F7E2)`. Pero AGENTS.md
define `VERDE (U+1F7E2)` como "Disponible (puede ser reclamado)": es el estado del eje de reclamo,
no del eje de avance. Un modulo con 78/104 hechos y sin dueno activo DEBE estar `VERDE (U+1F7E2)`.
Medido en 7 modulos: 33, 56, 115, 127, 137, 142, 143. Esas 7 alertas no se pueden
cerrar sin mentir: o se cambia el estado real, o se cambia el gate.

## 4. Hallazgo 2: 40 de 168 filas de la tabla estan mal formadas

Medido con el propio gate (`--estructura`): 35 filas con celdas de mas, 5 con celdas de
menos, 27 que no terminan en pipe. Dos causas: (a) un pipe sin escapar dentro de Notas,
(b) una celda faltante (Recom o Agente actual) que corre todo una columna a la izquierda.
Consecuencia directa: los 4 avisos de "timestamp ilegible" (M17, M20, M41, M49) NO son
bloqueos colgados, la fecha esta en la fila y el parser mapea por posicion.

Ademas: 15 filas tienen la celda Estado sobrescrita por un numero de progreso (el emoji
se perdio) y 4 tienen el emoji destruido por mojibake (45, 83, 159, 161).

## 5. Hallazgo 3: ceguera latente del gate por mojibake

`estado_emoji()` devuelve basura en las 4 filas con el emoji destruido, asi que AMBAS
comprobaciones de DoD 21.6 pasan en silencio. Medido: hoy no oculta ninguna alerta (los
estados reales son En curso / Con dudas, que no entran en las reglas), pero si una de
esas filas fuera completada con dudas abiertas, el gate la dejaria pasar. Es ceguera
LATENTE, no un falso negativo activo. Se declara como tal, sin inflarlo.

## 6. Los 3 que necesitan dueno (no son de la tabla)

- M139 Pre-Alpha: En curso sin actividad desde 2026-10-14 (10 dias).
- M158 Herramientas: En curso sin actividad desde 2026-09-04 (50 dias). Casi dos meses.
- M104 Analytics: fila restaurada el 2026-10-18 con todo en guion, sin fecha. El modulo
  esta trabajado (111/119), lo que falta es el dato de actividad.
- Fila 157 Medios-De-Transporte: sin checklist en disco -> fila stale (cobertura).

## 7. Evidencia de la herramienta

Suite `scripts/test_auditar_alertas_verificador.py`: **41 checks / 0 fallos / EXIT 0 x3**,
piso 41 MEDIDO en verde (no estimado). 8 bloques nombrados. Dos sondas EN ROJO:
(a) inyectar una alerta desconocida -> `exit 2` y la nombra como sin clasificar;
(b) `--piso 9999` -> `exit 2` por piso no alcanzado. Restauracion byte-exacta por sha256
de CHECKLIST-GLOBAL.md y verificar_checklist.py verificada en cada corrida.

Un defecto propio corregido durante la construccion: el primer bucle clasificaba las 7
alertas de estado Y las volvia a apendar como "sin clasificar" (49 registros para 42
alertas). Lo detecto la asercion "suma de clases == alertas del gate", no la vista.

## 8. Numeros corregidos antes de publicar

- Escribi "50 de 152 checklists" y el medido es **50 de 167** (63 bloques Totales en
  total: un checklist puede tener mas de uno). El 152 era de mi iter.8 y ya no vale.
- El JSON publicaba solo el set de modulos; se agrego la cifra de lineas para que las
  dos no se confundan.

## 9. Lo que NO hice

- No edite CHECKLIST-GLOBAL.md (prohibido sin orden; la tabla es del director).
- No edite verificar_checklist.py (gate compartido ya aceptado; exige procedimiento).
- No aplique los 26 drifts ni las 7 reclasificaciones: los aplica el director.
- No commit, no push.

## 10. Proximo

El 382 asigna como proxima tanda el paquete D-6 (210 items pre-clasificados de
M27/M34/M31/M156, cubos A-FORMULA/A-DOC: escribir la formula o spec en el 03 del modulo
y flipear el 05). Tranche pedido: 40-50 items. Arranca en la proxima vuelta.

## 11. Pools

- Log: 2167 reservado con `reservar_log.py --reservar` (el 2166 ya habia salido del pool
  por otro agente: ultimo archivo en disco 2165, cabeza del pool 2167). Cabeza ahora 2168.
- Canal: ultimo archivo 382, cabeza del pool 383 -> mensaje 383.
