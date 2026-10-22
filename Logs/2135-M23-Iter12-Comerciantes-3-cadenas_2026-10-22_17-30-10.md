# Log 2135 - M23 iter. 12: cluster Comerciantes (3 cadenas) + acuse msg 181 del director
# Step-5-WorkBuddy - 2026-10-22 - ASCII puro, CRLF, sin BOM (verificado por bytes)

## 0. Tracker y canal

- Tracker `.ultima-revision-step-5.txt`: 179 -> **181** (procesado el mensaje 181 del
  director, llegado a las 20:15 durante el cierre de la vuelta anterior).
- Mensaje 181 del director (GLM-5.3-Flash, Kilo Code): ratifica mi 180 (iter. 11
  Secretas: 351/0, conteo exacto, fila 23 del GLOBAL sincronizada por el a 63/105,
  los 8 paths + las 3 bajas del move commiteados en su ronda 1889b2d + f6e350b,
  test_historias.gd con bloque P incluido). **Flip L56 RATIFICADO.** GO NEXT:
  Comerciantes (3, L36) solo cadenas M23, integracion M37 AFUERA; despues Puzzles
  (6, L46) e Investigacion (5, L45). REGLA NUEVA DEL FUNDADOR: reportes
  consolidados (acumular clusters en 1 reporte si se puede, menos mensajes mismo
  rigor). "Tu 181 consumido" (tomo el 181 de MI pool).
- Pool del canal: 181 consumido por el director; mi mensaje de esta vuelta = **182**
  (cabeza del pool stale en 181; medida contra los archivos del canal).
- Hallazgo de estado: fila 23 del GLOBAL con dos celdas -- Estado = 63/105
  (sincronizada por el director) pero Progreso = 58/105 (stale desde iter. 8).
  Reportado al director; CHECKLIST-GLOBAL.md es protegido, no tocado.

## 1. Tanda: cluster Comerciantes (03-Diseno L36, "3 cadenas de rutas y secretos")

- Verificado en disco ANTES de escribir: mercedes_lince = **mercader** (rol real en
  data/villagers/mercedes_lince.tres), olivia_nutria = sastra, ramon_tejon = herrero.
  Objetos REALES por campo id dentro del .tres: OBJ-ITE-052 "Moneda de oro",
  OBJ-ITE-010 "Tela", OBJ-TAL-002 "Yunque".
- Colisiones medidas antes de escribir: ids, consecuencias, diarios, refs de puzzle
  y lugares de exploracion = **0** sobre las 37 cadenas previas.
- 3 cadenas nuevas en data/historias/secundarias.json (37 -> 40):
  - cadena-ruta-del-mercader (mercedes_lince; explorar ruta_comercial; entregar
    OBJ-ITE-052; puzzle paradas-en-orden; consecuencia ruta_comercial_reabierta;
    diario capitulo-ruta-del-mercader; cosmetico balanza de viaje)
  - cadena-cargamento-de-telas (olivia_nutria; explorar almacen_del_camino; entregar
    OBJ-ITE-010; puzzle ovillo-enredado; consecuencia telas_reunidas; diario
    capitulo-cargamento-de-telas; cosmetico carrete de viaje)
  - cadena-secreto-del-yunque (ramon_tejon; explorar taller_viejo; entregar
    OBJ-TAL-002; puzzle marca-del-herrero; consecuencia tecnica_del_yunque_recuperada;
    diario capitulo-secreto-del-yunque; cosmetico martillo de bolsillo)
  Las 3 nacen visibles (oculta:false): rutas de trueque que se descubren hablando,
  a diferencia de las secretas de iter. 11. 40/40 consecuencias unicas, 39 diarios
  unicos (una cadena preexistente no declara diario). Edicion puramente aditiva
  (+45 lineas, LF puro sin BOM verificado por bytes).

## 2. Evidencia (binario real, Godot 4.7.2 console headless)

- Suite scripts/historias/test_historias.gd: bloque Q `_test_comerciantes()` (28
  checks: 9 carga/fuente/no-oculta + 1 visibilidad + 2 unicidad + 1 diarios +
  2x7 end-to-end + 1 puente diario) al FINAL de _run(); BLOQUES A-Q; conteos de A/I
  actualizados (38 -> 41 cargadas; principal 37 -> 40). Piso 351 -> **379 checks /
  0 fallos / EXIT 0 x3**, 0 SCRIPT ERROR.
- Guardian EN ROJO por inyeccion de runtime (Variant con Array -> Dictionary) al
  inicio del bloque Q: EXIT 1, "el bloque Q NO se ejecuto" + "solo 352 checks
  ejecutados (minimo 379)", 2 fallos. Sonda borrada en la misma operacion; sha256
  restaurado byte-exacto (56f5878ba31bb4e1c68478a7613355543624864a5428c898a3ca2b83647ebfe6).
  NOTA DE METODOLOGIA: mi primera sonda afirmaba "solo 351 checks" (numero escrito
  de memoria, patron de iter. 11); el medido es 352 (379 - 28 del bloque + 1 del
  bloque faltante que cuenta _summary). La sonda quedo en VERDE con la asercion
  correcta: el guardian SI detecta la caida.
- Regresiones medidas tras la tanda: M22 scripts/historia/test_historia.gd 41/0,
  M71 test_progresion.gd 83/0, M59 test_rotate_m59.gd 43/0 (9 bloques) +
  test_backup_rotate_return.gd 4/0 + test_backup_rotations.gd 7/0, M55
  test_diario.gd + test_diario_persist.gd 0 fallos. Todas EXIT 0, 0 SCRIPT ERROR.

## 3. Documentacion

- 04-Codigo.md: + sec. "Iter. 12 -- Historias de comerciantes" (+3.621 B, aditiva).
- 05-Checklist.md: flips con cita L47 (crear 3 comerciantes) y L48 (documentar
  familias y comerciantes, compuesta: sec. Iter. 9 + sec. Iter. 12). M23 =
  **65 [x] / 38 [ ] / 2 [?] = 105** por prefijo de linea. Las DOS lineas de totales
  sincronizadas. L152 (integrar con M37) sigue [ ] con su dueno externo.
  AUTOCORRECCION: el primer calculo del script de flips dio 66/37/2 (3 cadenas
  contadas como 3 flips); la verificacion por prefijo integrada al script lo
  detecto ANTES de escribir -- son 2 flips -> 65/38/2. El archivo nunca se escribio
  con la cifra falsa.
- 06-Plan-Testings.md: fila del bloque Q, heading "Bloques (17)" (estaba en 15 con
  16 filas reales: deriva preexistente reparada), piso 379 con la cadena extendida,
  guardian "doce veces" con la entrada de iter. 12, catalogo vivo 40 (41 con merge).
- 07-Resultados-Testings.md: + sec. 9 (iter. 12) y REPARACION de la deriva de
  iter. 11 (la sec. 5 y el veredicto seguian en 32 cadenas / 316 checks / DIEZ
  rojos): sincronizados a 40 (41 vivo) / 379 / DOCE con las notas de puente M55 de
  iters. 11 y 12.

## 4. Hallazgo (dueno M55, no tocado)

- El puente M23->M55 degrada en silencio para las 3 nuevas
  (mision_cadena-ruta-del-mercader ausente del catalogo M55; capitulo-* tambien).
  Mismo patron desde cadena-biblioteca en H. No se inventa contenido de M55.

## 5. Limites

- 0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos tocados
  (CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot intactos).
- `reservar_log.py --estado`: colisiones de numeracion ajenas conocidas (patron
  recurrente de la familia; 0 propias).
