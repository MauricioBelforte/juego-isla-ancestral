# Log 2085 - Step-5-WorkBuddy - M23: normalizacion estado_mundo.* + plaza rechazo persistente (msg 153)

**Agente:** Step-5-WorkBuddy | **Modulo:** M23-Historias-Secundarias
**Fecha:** 2026-10-21 18:40 (GMT-3) | **Disparador:** mensaje 153 del director (GLM-5.3 Flash-Director)
**Numero reservado:** 2085 (head de Logs/NUMEROS_DISPONIBLES.txt medido JUSTO antes = 2085; consumido del pool v3)

## 1. Mensaje procesado

Tracker 152 -> 153. Unico entrante: **153** del director = acuse de mi 152 (iter. 3
RATIFICADA: merge por id, +1 [x] biblioteca, rechazo validado de plaza) + 4 decisiones:

1. Tipo "construir": NO se agrega hoy (sin respaldo de diseno). cadena-postgame-plaza
   queda RECHAZADA PERSISTENTE con nota en el 05 + item [?] nuevo (contenido con tipo
   no soportado) para que M22/M17 decidan. NO migro datos sin orden. El flip del item
   de plaza se otorga solo cuando el tipo exista o el dato se migre.
2. commit de la iter. 3 por CRON C.
3. mision_cadena-biblioteca en M55 = derivacion vigente (cae cuando M55 tenga dueno activo).
4. **GO a mi:** normalizar claves estado_mundo.* (data-only en el fichero de ejemplos
   + test que afirme ambas cargas consistentes).

## 2. Normalizacion ejecutada (data-only)

game/isla-ancestral/data/historias/cadenas_ejemplo.json: 5 claves peladas
(0 ocurrencias de "estado_mundo" tras el cambio, JSON revalidado):

| cadena | campo | antes | despues |
|---|---|---|---|
| cadena-faro | pasos[0].condicion | estado_mundo.faro_apagado | faro_apagado |
| cadena-faro | consecuencia | estado_mundo.faro_encendido | faro_encendido |
| cadena-biblioteca | pasos[0].condicion | estado_mundo.biblioteca_abierta | biblioteca_abierta |
| cadena-biblioteca | consecuencia | estado_mundo.biblioteca_iluminada | biblioteca_iluminada |
| cadena-postgame-plaza | consecuencia | estado_mundo.plaza_decorada | plaza_decorada |

Direccion MEDIDA, no elegida: el motor aplica la clave de consecuencia LITERAL a
WorldState (ws.set_flag(String(flag), bool(consec[flag])),
secondary_stories_service.gd L235-236) y el catalogo de produccion
(secundarias.json) ya usaba flags pelados (faro_encendido, invernadero_abierto,
plaza_decorada, luciernagas_vueltas): es el esquema que consume el resto del
juego. El prefijo habria creado flags que nadie lee. quest_chain.gd L19 documentaba
{estado_mundo.xxx = true/false}, que no coincidia con el motor ni con produccion:
comentario actualizado al esquema canonico (clave pelada). 0 cambio de comportamiento.

## 3. Suite (binario real Godot 4.7.2 console, headless)

res://scripts/historias/test_historias.gd:

- Bloque H: afirma la clave PELADA (biblioteca_iluminada) y que la prefija NO se aplica.
- Bloque I nuevo _test_esquema_consistente (10 checks): ejemplos crudo sin prefijos
  (condicion + consecuencia); principal sin consecuencia prefijada; carga mergeada en
  runtime sin prefijos (5 cadenas cargadas); flags compartidos con el MISMO deletreo
  en los dos catalogos (faro_encendido, plaza_decorada).
- 3x verde: **70 checks / 0 fallos / EXIT 0 / 0 SCRIPT ERROR**. Piso CHECKS_MINIMOS
  59 -> 70 MEDIDO (y reverificado en verde con el piso nuevo).

## 4. Guardian probado EN ROJO (2 inyecciones, ambas TERMINAN)

1. Aborto de runtime en el bloque I (copia-sonda _probe_aborto_i.gd con llamada sobre
   instancia null): EXIT 1, "[FAIL] el bloque I NO se ejecuto (posible SCRIPT ERROR
   que aborto la funcion)" + "[FAIL] solo 61 checks ejecutados (minimo 70)". Sonda
   borrada y verificada.
2. Regresion de datos: prefijo estado_mundo. re-inyectado en una clave del fichero de
   ejemplos: EXIT 1 con 4 fallos que NOMBRAN la clave
   ("cadena-biblioteca/consecuencia/estado_mundo.biblioteca_iluminada" en bloque I;
   las 2 afirmaciones de H). Fichero restaurado y verificado por sha256 (0 prefijos).

## 5. Trampas propias (corregidas antes de publicar)

1. La primera corrida de la inyeccion 1 uso --path relativo equivocado (game/ en vez
   de game/isla-ancestral/) y dio EXIT 1 por "script not found": un ROJO FALSO que se
   parecia al guardian. Rehecha con el path correcto: la evidencia valida es la que
   NOMBRA el bloque.
2. El bloque I concatenaba ejemplos + principal y contaba las cadenas cargadas
   recorriendo la lista: cadena-faro esta en los DOS catalogos (conflicto de merge) y
   se conto dos veces -> falso rojo "5 cadenas cargadas en runtime: 6". Corregido a
   ids unicos (diccionario). Leccion: un conflicto de merge es una cadena en dos catalogos.

## 6. Regresiones de integracion (binario real, misma tanda)

M22 test_historia.gd 41/0 | M55 test_diario.gd 0 fallos | M55 test_diario_persist.gd
0 fallos | M59 validate_save.gd 16/0 | M71 test_progresion.gd 83/0: todos EXIT 0,
0 SCRIPT ERROR.

## 7. Documentacion M23 actualizada

- 05-Checklist: L34 documenta la decision del director (rechazo PERSISTENTE; flip solo
  cuando el tipo exista o el dato se migre); NUEVO item [?] "Definir el tipo de paso
  construir" (contenido con tipo no soportado, duenos M22/M17). La linea "Totales"
  (L200) estaba DESACTUALIZADA desde iter. 2 (decia 24/80/0) y quedo sincronizada con
  las marcas. Medido por prefijo de linea: **43 [x] / 60 [ ] / 2 [?] = 105**.
- 04-Codigo: Notas del Agente iter. 4 (LF preservado, append sin BOM).
- 07-Resultados-Testings: nota de esquema marcada RESUELTA + veredicto con las 4
  inyecciones.

## 8. Residual reportado, NO tocado

secundarias.json (principal) mantiene UNA condicion con prefijo
(cadena-faro p1: estado_mundo.faro_apagado). Es declarativa: 0 consumidores de
condicion en scripts/ (grep: solo el comentario de esquema y la declaracion del
campo) y el GO del director era data-only en el fichero de ejemplos. Si el director
extiende el GO, se normaliza en una linea. Reportado en el mensaje 154.

## 9. Limites

0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md,
quality.yml, AGENTS.md, project.godot ni 05-Checklist ajenos. Pools NO commiteados.
