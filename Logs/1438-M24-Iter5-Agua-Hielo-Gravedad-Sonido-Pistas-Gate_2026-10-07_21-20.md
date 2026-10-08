# Log 1438 - M24: iter. 5 - familias agua, hielo, gravedad, sonido y pistas + gate extendido

**Fecha:** 2026-10-07 21:20 (local -0300; UTC 2026-10-08 00:20)
**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Modulo:** M24-Templos-Y-Puzzles
**Plan:** aprobado por el director (canal DeepSeek/81, mensaje 81). Alcance = Frente 0 (gate extendido por familia) + Frentes A-E (agua, hielo, gravedad, sonido, pistas); 30 cierres (70 -> 100/128).
**Mensaje de canal:** 76 (deepseek-a-atria)

## 0. Condiciones del director (msg 81) - cumplimiento

1. Gate por familia: cada familia nueva suma su suite al guardian y sube el TOTAL_MINIMO. HECHO:
   13 suites, TOTAL_MINIMO 362 -> 649 (medido 649 == piso). Gate 76/0 EXIT 0 x3.
2. Bloqueos respetados: item 103 (M43) sigue [ ] con nota (scripts/audio/ = 0 hits "linea de audicion");
   item 112 (M25) intacto.
3. Cero regresion: las 8 suites previas siguen verdes; total 649.
4. main_island.gd libre: no se toco.

Sonda roja EN VIVO del gate: se muto data/templos/puzzles/agua/agua_01.json ("caudal": 2 -> 3) y el
gate paso a EXIT 1 nombrando test_puzzle_agua (57 checks, 5 fallos) + los checks "EXIT 0" y "0 fallos"
en rojo. JSON restaurado byte-exacto (sha256 af65594038546fce8757e243e97e71cd0c38ce3db517019e59e78a6dcd48fd8b).

## 1. Frente A - familia agua (items 58-63)

NUEVOS:
- game/isla-ancestral/scripts/templos/puzzle_agua.gd - PuzzleAgua (RefCounted): capa hidraulica
  discreta. cargar/desde_def, tick() (suma EXACTAMENTE el caudal, tope max), drenar() (resta 1),
  altura(celda)/alturas(), compuerta_abierta(id)/compuertas_abiertas(), barca_en_destino(id),
  ticks(), receptor_activado(), validar_agua().
- data/templos/puzzles/agua/agua_01.json - 5x3, fuente (1,1) caudal 2 max 12, compuerta (1,1) umbral 6
  emisor 0, barca (1,1) umbral 6 destino (3,1) emisor 1; objetivo [0,1].
- data/templos/puzzles/agua/agua_02.json - 6x4, fuentes (2,2) caudal 3 y (3,2) caudal 1, compuerta
  (2,2) umbral 9; objetivo [0].
- scripts/templos/test_puzzle_agua.gd - suite headless bloques A-F.
MEDIDO: 57 checks, 0 fallos, EXIT 0 x3; CHECKS_MINIMOS=57. tick() 7.4944 us/tick; validar_agua 32.92 us.

## 2. Frente B - familia hielo (items 67-71)

NUEVOS:
- scripts/templos/puzzle_hielo.gd - PuzzleHielo (RefCounted): deslizamiento. deslizar(id,dir) hasta
  chocar con borde/pared/bloque; huecos consumen el bloque (cayo_en_hueco); pedazos {pos,usos} se
  agrietan y se rompen dejando hueco; validar_simetria() data-driven (ejes x|y|ambos).
- data/templos/puzzles/hielo/hielo_01.json - 5x1, 1 bloque, simetria x.
- data/templos/puzzles/hielo/hielo_02.json - 7x3 simetrico, paredes [[2,1],[4,1]], huecos [[1,0],[5,0]],
  2 bloques, 2 pedazos (usos 2).
- scripts/templos/test_puzzle_hielo.gd - suite headless bloques A-F.
MEDIDO: 59 checks, 0 fallos, EXIT 0 x3; CHECKS_MINIMOS=59. cargar+deslizar 51.13 us; validar_hielo 45.84 us.

## 3. Frente C - familia gravedad (items 92-98)

NUEVOS:
- scripts/templos/puzzle_gravedad.gd - PuzzleGravedad (RefCounted): burbujas {zona,dir} +
  direccion_gravedad(pos)/cambia_direccion; plataformas {grupo,amplitud,periodo} +
  plataforma_offset(id,fase) (onda triangular entera) / plataforma_en_extremo; pulsos {periodo,duracion}
  + pulso_activo(id,fase); cintas {pos,dir} + cinta_dir/cinta_en; fase_desde_reloj(reloj) sobre M29
  scripts/time/game_clock.gd (dia_absoluto/get_hora/get_minuto), duck-typed; validar_gravedad().
- data/templos/puzzles/gravedad/gravedad_01.json - 6x4, burbuja NORTE, 2 plataformas sincronizadas
  (grupo g1, amplitud 2, periodo 8), pulso, cinta; objetivo [0,1].
- data/templos/puzzles/gravedad/gravedad_02.json - 6x4, 2 burbujas opuestas, 1 plataforma, 1 pulso,
  1 cinta; objetivo [0].
- scripts/templos/test_puzzle_gravedad.gd - suite headless bloques A-F (+ RelojFalso para el contrato M29).
MEDIDO: 59 checks, 0 fallos, EXIT 0 x3; CHECKS_MINIMOS=59. tick() 7.8618 us/tick; validar_gravedad 64.90 us.

## 4. Frente D - familia sonido (items 102, 104-107; 103 BLOQUEADO)

NUEVOS:
- scripts/templos/puzzle_sonido.gd - PuzzleSonido (RefCounted): campanas {pos,tono,emisor} + tocar(id);
  secuencia validada entre LARGO_MIN=3 y LARGO_MAX=5; INTENTOS_PARA_PISTA=2 + pista_disponible()/
  pista_patron(); tocar_secuencia(); validar_sonido(). MODELO PURO: 0 referencias a AudioServer en
  codigo (item 104, verificado por lectura del fuente descartando comentarios).
- data/templos/puzzles/sonido/sonido_01.json - 3 campanas, secuencia 3; objetivo [0].
- data/templos/puzzles/sonido/sonido_02.json - 5 campanas en 2 grupos, secuencia 5; objetivo [0,1].
- scripts/templos/test_puzzle_sonido.gd - suite headless bloques A-F.
MEDIDO: 54 checks, 0 fallos, EXIT 0 x3; CHECKS_MINIMOS=54. cargar+tocar_secuencia 89.39 us; validar_sonido 33.79 us.
BLOQUEADO: item 103 (M43) - scripts/audio/ no expone "linea de audicion" (0 hits). No se fuerza.

## 5. Frente E - familia pistas (items 132, 134-139)

NUEVOS:
- scripts/templos/puzzle_pistas.gd - PuzzlePistas (RefCounted): capas() (3 capas) +
  registrar_en_diario(diary) (capa 2, ancla scripts/diario/diary_service.gd); avanzar(dt) +
  pista_diferida_disponible() (DEMORA_PISTA_S=90.0); pista_familia(); pista_emisor_exacto() (deriva de
  PuzzleDef.solucion_minima); pista_anclada_a_grafo() (deriva de PuzzleDef.reglas_def);
  solucion_paso_a_paso() (exige PISTAS_PARA_SOLUCION=3); usar_pista()/penalizacion() (siempre 0).
- data/templos/puzzles/pistas/pistas_01.json - familia presion, 2 emisores AND.
- data/templos/puzzles/pistas/pistas_02.json - familia luz, 1 emisor.
- scripts/templos/test_puzzle_pistas.gd - suite headless bloques A-F (+ DiarioFalso para el contrato diary).
MEDIDO: 58 checks, 0 fallos, EXIT 0 x3; CHECKS_MINIMOS=58. cargar+derivar 2 pistas 17.89 us; validar_pistas 11.00 us.

## 6. Frente 0 - gate extendido

MODIFICADO scripts/templos/test_regresion_templos.gd: SUITES 8 -> 13 (se agregaron agua 57, hielo 59,
gravedad 59, sonido 54, pistas 58); TOTAL_MINIMO 362 -> 649; CHECKS_MINIMOS 51 -> 76; el check de
catalogo paso de "8 suites" a "13 suites".
MEDIDO: gate 76 checks, 0 fallos, EXIT 0 x3; total de las suites = 649 == piso 649.
Sonda roja EN VIVO: agua_01.json mutado -> gate EXIT 1 (ver seccion 0).

## 7. Anti-falso-verde

Las 5 suites: bloques A-F nombrados + _fin(); _summary() en call_deferred (nombra el bloque que no
corrio); piso CHECKS_MINIMOS MEDIDO en verde (57/59/59/54/58, nunca estimado); bloque D = sonda roja
sobre copias mutadas. Las 5 suites verdes x3 (0 fallos, 0 SCRIPT ERROR).

## 8. Regresion

13 suites en verde: datos 42, multilateral 38, bloques 64, luz 60, espejos 62, agua 57, hielo 59,
gravedad 59, sonido 54, pistas 58, m26 92, headless 4, puzzles (sin contador). Gate 649/0 EXIT 0 x3.
No se modifico ningun archivo de otro modulo.

## 9. Documentacion

- DOCUMENTACION/24-Templos-Y-Puzzles/plan-actual/03-Diseno.md: 5 secciones nuevas (agua, hielo,
  gravedad, sonido, pistas).
- 04-Codigo.md: mapa de codigo de las 5 familias + fila del gate actualizada.
- 06-Plan-Testings.md: 5 suites + 16 edge cases nuevos + rendimiento.
- 07-Resultados-Testings.md: cifras MEDIDAS (13 suites, 649, sonda roja del gate, rendimiento).
- 05-Checklist.md: 30 flips ([ ] -> [x]) + seccion "Iteracion 5" + linea Totales corregida (57 -> 100).

## 10. Conteo

MEDIDO: 100 [x] / 1 [?] / 27 [ ] = 128 (conteo por prefijo de linea).

## 11. Hallazgo operativo - pool de mensajes trackeado en git

python scripts/verificar_pool_numeros.py reporta FALLO en TODOS los canales: "mensaje(s) ya creado(s)
pero su numero sigue en el pool". Causa: Mensajes entre modelos/<canal>/NUMEROS_DISPONIBLES.txt esta
VERSIONADO, asi que un git checkout restaura numeros ya consumidos. En el canal DeepSeek el pool volvio
a [46..500] con 46-81 ya usados -> el helper (que salta usados) asigno el primer libre real: 76.
Reportado al director; no se toco (pool compartido, drift global).

## 12. Git

Commits LOCALES (sin push, restriccion vigente; el director pushea). Sin tocar CHECKLIST-GLOBAL.md,
quality.yml, interaction_manager.gd, service_registry.gd/bootstrap.gd, main_island.gd, item 144 [?],
ni el worktree ajeno.

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) - Log 1438.
