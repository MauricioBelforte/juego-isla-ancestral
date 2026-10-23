# Log 2137 - M23 iter. 13: clusters Puzzles (6, L46) + Investigacion (5, L45), consolidados
# Step-5-WorkBuddy - tanda del 2026-10-22, cerrada el 2026-10-23 - ASCII puro, CRLF, sin BOM (verificado por bytes)

## 0. Tracker y canal

- Tracker `.ultima-revision-step-5.txt`: 182 -> **183** (procesado el mensaje 183 del
  director, llegado a las 20:45 del 2026-10-22). Mi mensaje de esta vuelta = **184**.
- Mensaje 183 del director (GLM-5.3-Flash, Kilo Code): iter. 12 RATIFICADA (Comerciantes:
  3 cadenas, suite 379/0, fila 23 del GLOBAL sincronizada), flips L47/L48 ratificados, fila
  23 ajustada al canon de 11 columnas. **GO consolidado: Puzzles (6, L46) + Investigacion
  (5, L45) en UN reporte** (regla del fundador) con el commit final del cluster a mi cargo.
  "Tu 182 consumido" (tomo el 182 de MI pool; el 184 lo tomo del pool al responder).
- Pool del canal: cabeza medida en 183 (stale en 1: el director consumo el 183 sin
  borrarlo del pool). Usado el ultimo+1 = **184**, borrado solo ese numero. Reportado al
  director.
- Estructura del canal: el rango 100-199 quedo COMPLETO y se archivo en
  `arch_0101-0200/` (regla del fundador 2026-10-15); en la raiz solo quedan los archivos
  de control. Los scripts de listado recursivo (`ver_mensajes.py`) leen sin problemas.

## 1. Tanda: clusters Puzzles (03-Diseno L46) + Investigacion (03-Diseno L45)

- Verificado en disco ANTES de escribir: los 7 NPC con su rol real en data/villagers/
  (vera_ardilla farera, sofia_buho bibliotecaria, pablo_pato ceramista, teo_conejo
  herbolario, bruno_sapo carpintero, luna_zorra artesana, catalina_oso cocinera) y los 11
  objetos REALES por campo id dentro del .tres (OBJ-LUZ-012 "Linterna", OBJ-EST-006
  "Vitrina", OBJ-REL-002 "Reloj de pendulo", OBJ-HER-015 "Lupa", OBJ-LUZ-008 "Lampara de
  cristal", OBJ-TAL-004 "Rueda de alfarero", OBJ-HER-018 "Sierra", OBJ-PLA-004
  "Orquidea", OBJ-ITE-021 "Pan", OBJ-NAT-024 "seta", OBJ-LUZ-004 "Veladora").
- Colisiones medidas antes de escribir: ids, consecuencias, capitulos de diario y refs de
  puzzle = **0** sobre las 40 cadenas previas. Lugares: 4 nuevos (templo_24, templo_25,
  templo_26, biblioteca) + 6 reutilizados por diseno (faro, jardines, observatorio,
  barrizal, manantial, acantilado - los que nombra el 03-Diseno L45/L46).
- 11 cadenas nuevas en data/historias/secundarias.json (40 -> 51; 52 con la de ejemplo
  en carga):
  - Investigacion (5): cadena-registro-del-faro (vera_ardilla; explorar faro; entregar
    OBJ-LUZ-012; puzzle alturas-de-la-luz; consecuencia registro_del_faro_recuperado),
    cadena-catalogo-perdido (sofia_buho; biblioteca; OBJ-EST-006;
    signos-en-los-margenes; catalogo_perdido_devuelto), cadena-mediciones-de-la-isla
    (pablo_pato; observatorio; OBJ-REL-002; sombras-del-mediodia;
    mediciones_de_la_isla_recuperadas), cadena-mapa-de-las-plantas (teo_conejo; jardines;
    OBJ-HER-015; tinta-de-hojas; mapa_de_plantas_dibujado) y cadena-cartas-estelares
    (sofia_buho; observatorio; OBJ-LUZ-008; reloj-de-estrellas;
    cartas_estelares_descifradas - extension declarada: el 03-Diseno L45 nombra 4 temas y
    el item pide 5).
  - Puzzles (6): cadena-templo-de-las-24-marcas (pablo_pato; templo_24; OBJ-TAL-004;
    sellos-de-arcilla; templo_de_las_24_marcas_abierto), cadena-templo-de-los-25-engranajes
    (bruno_sapo; templo_25; OBJ-HER-018; mecanismo-escondido;
    templo_de_los_25_engranajes_abierto), cadena-templo-de-las-26-mareas (luna_zorra;
    templo_26; OBJ-PLA-004; tintes-del-templo; templo_de_las_26_mareas_abierto),
    cadena-ruinas-del-barrizal (catalina_oso; barrizal; OBJ-ITE-021; ofrenda-de-la-ruina;
    ruinas_del_barrizal_leidas), cadena-ruinas-del-manantial (teo_conejo; manantial;
    OBJ-NAT-024; raices-en-la-piedra; ruinas_del_manantial_leidas) y
    cadena-ruinas-del-acantilado (vera_ardilla; acantilado; OBJ-LUZ-004; eco-de-las-ruinas;
    ruinas_del_acantilado_leidas).
  Las 11 nacen visibles (oculta:false): se descubren hablando, como las comerciantes de
  iter. 12. Contextos medidos: 111-138 caracteres (>= 10 exigidos). Consecuencias peladas
  unicas 51/51 en disco (52/52 sobre la carga); 11 capitulos de diario unicos (50 cadenas
  con diario sobre 52 cargadas: 2 preexistentes no declaran). Edicion puramente aditiva
  (+396 lineas, 0 borradas; formato Godot preservado, LF puro sin BOM por bytes).

## 2. Evidencia (binario real, Godot 4.7.2 console headless)

- Suite scripts/historias/test_historias.gd: bloque R `_test_puzzles_investigacion()` (77
  checks: 33 carga/fuente/no-oculta + 1 visibilidad en disponibles + 2 unicidad GLOBAL de
  flags medida sobre la carga real - reemplaza la lista transcrita a mano, que podia omitir
  un flag y dar un falso verde - + 7 NPC REALES por efecto (FileAccess.file_exists sobre
  data/villagers/) + 11 objetos REALES por campo id (_ids_items_reales()) + 1 diarios +
  3x7 end-to-end + 1 puente diario) al FINAL de _run(); BLOQUES A-R; conteos de A/I
  actualizados (41 -> 52 cargadas, principal 40 -> 51). Piso 379 -> **456 checks /
  0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR.
- Guardian EN ROJO por inyeccion de runtime (Node null -> free()) al inicio del bloque R:
  EXIT 1, "el bloque R NO se ejecuto (posible SCRIPT ERROR que aborto la funcion)" +
  "solo 380 checks ejecutados (minimo 456)", 2 fallos. Sonda borrada en la misma
  operacion; sha256 del original restaurado byte-exacto; git status de
  scripts/historias/ vacio. NOTA: la sonda se RE-EJECUTO en el cierre de la tanda
  (ver sec. 6) para dejar las cifras medidas en disco.
- Regresiones medidas tras la tanda: M55 test_diario.gd 0 fallos + test_diario_persist.gd
  0 fallos, M59 test_autosave_m59.gd 0 fallos, M71 test_bug_reevaluar_m71_hy3.gd 8/2 (los
  2 fallos son la reproduccion del BUG-143 conocido, previa a la tanda). Todas EXIT 0
  salvo M71 (EXIT 1 por el bug reproducido a proposito).
- El validador historias/validate_quest_chains.gd NO se pudo medir: cuelga en modo
  --script headless (EXIT 124 por timeout; es un SceneTree sin quit()). Condicion previa
  ajena a la tanda - se reporta, no se toca.

## 3. Documentacion

- 04-Codigo.md: + sec. "Iter. 13 - Puzzles e Investigacion" (+78 lineas, aditiva, LF).
- 05-Checklist.md: flips con cita L85 (crear 5 misiones de investigacion), L87 (documentar
  amistad e investigacion, compuesta: sec. Iter. 10 + sec. Iter. 13), L91 (crear 6 misiones
  de puzzles) y L93 (documentar misiones de puzzles). M23 = **69 [x] / 34 [ ] / 2 [?] =
  105** por prefijo de linea. Las DOS lineas de totales sincronizadas. Cabecera actualizada
  con la cadena de iteraciones.
- 06-Plan-Testings.md: Bloques (17) -> (18) con la fila del bloque R; piso 379 -> 456 con
  la cadena extendida (-> 379 con 17 -> 456 con 18); guardian "doce" -> "trece" rojos con
  la entrada de iter. 13; catalogo vivo 40 (41) -> 51 (52).
- 07-Resultados-Testings.md: + sec. 10 (iter. 13); sec. 5 con el catalogo en 51 (52 vivo),
  la nota de puente M55 de iter. 13 y las 11 consecuencias nuevas; veredicto DOCE -> TRECE
  rojos, suite 456, regresiones actualizadas.
- BACKLOG-MASTER.md: flips en los DOS espejos - items 156 (DESYNC reparada: estaba [ ] en
  el espejo pero [x] en el checklist desde iter. 10, Log 2131; las 6 cadenas estan en
  disco), 157, 159, 160 y 162 - y nota de cierre de la tanda. Archivo CRLF: invariante
  preservado (0 LF sueltos, sin BOM).

## 4. Hallazgo (dueno M55, no tocado)

- El puente M23->M55 degrada en silencio para las 11 nuevas
  (mision_cadena-registro-del-faro y las otras 10 ausentes del catalogo M55; capitulo-*
  tambien). Mismo patron desde cadena-biblioteca en el bloque H. No se inventa contenido
  de M55.

## 5. Limites

- 0 commits propios / 0 push / 0 auto-sellos 21.8 / 0 protegidos tocados
  (CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot intactos).
- `reservar_log.py --reservar`: head del pool medido 2137 justo antes -> consumido. 0
  colisiones propias.

## 6. Cierre de la tanda (2026-10-23) - interrupcion por limite de frecuencia de la API

- La corrida original quedo interrumpida el 2026-10-22 a la madrugada por el limite de
  frecuencia de la API, con la tanda practicamente completa en disco (JSON, suite, guardia
  y diffs medidos) pero SIN el log, el mensaje al director ni la documentacion de cierre.
- El CRON commiteo EN VUELO lo que habia en el worktree: secundarias.json y
  test_historias.gd en 4fef055 ("Se preserva la tanda en curso de step-5"); 04-Codigo.md y
  05-Checklist.md en 9a29a03 (que ademas sincronizo la fila 23 del GLOBAL a 69/105 citando
  este log). Verificado contra HEAD antes de escribir cada cifra de este log.
- Trampas propias corregidas en el cierre: (1) el primer script de reinsercion del JSON
  re-dumpeo el archivo completo (238 borrados: el original tiene formato mixto
  compacto/expandido) -> restaurado desde HEAD y append quirurgico por bytes (+396/-0);
  (2) el import del modulo de cadenas ejecutaba el main() del script completo -> corregido
  con guard __main__; (3) la sonda del guardian se re-ejecuto para dejar las cifras
  medidas (380 < 456) porque la corrida original quedo sin registro; (4) el assert de
  pureza del append de 04-Codigo contaba "Iter. 13" (2 ocurrencias legitimas: cabecera +
  cita en los flips) -> verificado por cabecera unica; (5) DESYNC del backlog detectada y
  reparada con cita (item 156, ver sec. 3).
- Pendiente de ronda de commit del director (en el worktree, sin commitear por orden):
  06-Plan-Testings.md, 07-Resultados-Testings.md y BACKLOG-MASTER.md de M23.

## 7. Artefactos

- Log 2137 (este archivo), mensaje 184 al director, 04/05/06/07 de M23,
  BACKLOG-MASTER.md, tracker 183.
