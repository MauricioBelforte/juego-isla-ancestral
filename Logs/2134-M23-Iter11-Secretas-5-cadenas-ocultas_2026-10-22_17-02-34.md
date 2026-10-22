# Log 2134 - M23 Historias Secundarias - Iter. 11: cluster Secretas (5 cadenas ocultas)

**Modelo:** Step-5-WorkBuddy (WorkBuddy)
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-22
**Hora:** 17:02
**Modulo:** M23 - Historias Secundarias
**Iteracion:** 11 (cluster Secretas del 03-Diseno L38)
**Orden:** director GLM-5.3 Flash, msg 179 (2026-10-22 18:45): toma como NUEVA TANDA las
Secretas (5, L38) de M23; Comerciantes (3, L36) autorizadas despues de Secretas (solo las
CADENAS M23; la integracion M37 fuera); Puzzles despues de Comerciantes; Investigacion cierra.

## 1. Trabajo ejecutado

5 cadenas secretas ocultas nuevas en game/isla-ancestral/data/historias/secundarias.json
(32 -> 37 cadenas; 6 ocultas contando cadena-secretta-luciernagas). Todas con NPC REAL de
data/villagers/ y objeto REAL de data/items/ verificado por campo id dentro del .tres:

| id | NPC (rol) | Objeto (id) | Consecuencia pelada |
|---|---|---|---|
| cadena-mapa-secreto | nico_gato (guardabosques) | OBJ-SEC-002 "Mapa secreto" | sendero_secreto_revelado |
| cadena-cristal-oculto | vera_ardilla (farera) | OBJ-SEC-003 "Cristal oculto" | cristal_oculto_recuperado |
| cadena-diario-antiguo | sofia_buho (bibliotecaria) | OBJ-SEC-005 "Diario antiguo" | autor_del_diario_identificado |
| cadena-pergamino-mistico | teo_conejo (herbolario) | OBJ-ART-002 "Pergamino mistico" | versos_antiguos_descifrados |
| cadena-mascara-ceremonial | luna_zorra (artesana) | OBJ-ART-004 "Mascara ceremonial" | mascara_ceremonial_restaurada |

- 4 pasos cada una (hablar/explorar/entregar/puzzle), contexto >= 10 chars, capitulos de
  diario unicos (37/37), consecuencias peladas unicas (37/37, sin colision con las 33 previas).
- Las 5 nacen oculta:true -> invisibles en cadenas_disponibles() hasta iniciarse (regla de
  descubrimiento por mundo, 03-Diseno L38/L58, secondary_stories_service.gd L71).
- Edicion puramente aditiva sobre el JSON: diff +75/-0 lineas, formato Godot preservado
  (dicts hoja inline), LF puro sin BOM verificado por bytes antes y despues.

## 2. Evidencia medida (binario real)

Suite scripts/historias/test_historias.gd (bloque P _test_secretas, 35 checks, al FINAL de
_run(); BLOQUES A-P; conteos de A e I actualizados 33->38 y 32->37):

- Verde: **351 checks / 0 fallos / EXIT 0 x3** (binario
  D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe,
  --headless --path game/isla-ancestral). 0 SCRIPT ERROR en las 3 corridas.
- Piso CHECKS_MINIMOS 316 -> 351 MEDIDO en verde antes de fijarlo (no estimado).
- Guardian EN ROJO por inyeccion de runtime (Variant con Array -> Dictionary al inicio del
  bloque P, sonda temporal): EXIT 1, "[FAIL] el bloque P NO se ejecuto" +
  "[FAIL] solo 317 checks ejecutados (minimo 351)", 2 fallos. Sonda borrada en la misma
  operacion; git status del directorio verificado (solo lasuite modificada).
- Regresiones medidas tras la tanda (mismo binario, todas EXIT 0, 0 SCRIPT ERROR):
  M22 scripts/historia/test_historia.gd 41/0 - M71 scripts/progresion/test_progresion.gd
  83/0 - M59 scripts/saving/test_rotate_m59.gd 43/0 (9 bloques) +
  test_backup_rotate_return.gd 4/0 + test_backup_rotations.gd 7/0 -
  M55 scripts/diario/test_diario.gd 0 fallos + test_diario_persist.gd 0 fallos.

## 3. Documentacion

- 05-Checklist: flip con cita "Crear 5 cadenas secretas ocultas" (L56) [ ] -> [x].
  M23 = 63 [x] / 40 [ ] / 2 [?] = 105 por prefijo de linea. Las DOS lineas de totales
  (L170 y L201) sincronizadas a 63/40/2. El item "Documentar historias estacionales y
  secretas" (L58) sigue [ ]: es compuesto y las estacionales son de M32 (0 en disco) -
  no se flippa por la mitad (patron anti-inflacion de iter. 6).
- 04-Codigo: seccion Iter. 11 (+2.884 B, aditiva).
- 06-Plan-Testings: fila del bloque P, piso 351, guardian once veces, catalogo vivo 37.
- 07-Resultados-Testings: seccion 8 (Iter. 11) con veredicto y regresiones.

## 4. Hallazgos

- Puente M23->M55 (dueno M55, NO tocado): degrada en silencio para las 5 nuevas
  (mision_cadena-mapa-secreto y compania ausentes del catalogo M55; capitulo-* tambien).
  Mismo patron que cadena-biblioteca (H), cadena-jardines (K), cadena-puente (L),
  cadena-brujula (M), cadena-guardas (N) y cadena-regalo-favorito (O). No se inventa
  contenido de M55.
- Los 14 villagers de data/villagers/ tienen cadena; las secretas reutilizan 5 de ellos
  en rol narrativo (no hay restriccion de NPC unico por cadena en el diseno).

## 5. Trampas y correcciones propias de la corrida

- 1a corrida de la suite: 1 fallo propio ("iniciar cadena-mapa-secreto OK"): el check de
  visibilidad iniciaba la cadena y el end-to-end la volvia a iniciar. Corregido con un
  restore_save_data({}) entre ambos (estado limpio). Leccion: dentro de un bloque, un
  check que muta estado invalida la premisa del check siguiente.
- El header de la suite quedo con una comilla colgante al insertar la nota de iter. 11
  (Parse Error "Closing ) doesn't have an opening counterpart"): detectada y corregida
  antes de la 2a corrida. Un append de texto a un .gd se verifica corriendo, no mirando.
- El script de insercion en el JSON aborto 2 veces por construccion incorrecta del texto
  (verificacion en memoria ANTES de escribir): el archivo nunca quedo a medio camino.

## 6. Limites

0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml,
AGENTS.md ni project.godot. El flip se ofrece a revertir. El move de los 3 scripts
scripts-prueba_tmp_familias_*.py a Obsoletos/raiz-temporales-2026-10-22-step5/ (autorizado
por el director, msg 179 punto 4) quedo ejecutado y staged como rename; el commit de las
bajas lo hace el director. Log 2134 reservado con head del pool medido 2134 justo antes
(consumido; head nuevo 2135).
