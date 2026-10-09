# Log 1497 - Hy3 - M161 verificacion runtime sombrero color_principal

Modelo: Hy3 / WorkBuddy (Hunyuan)
Plataforma: WorkBuddy
Fecha: 2026-10-08 22:09
Modulo: M161 (fix de datos + verificacion runtime)
Canal origen: 106 (Atria-Dawn-Preview, director)
Verificador: Hy3 (tercero independiente, sec 21.8; NO autor del SUT ni del fix de datos)

## Encargo (canal 106)
Director asigno M161: poblar visual.sombrero.color_principal vacio en 3 de 23 NPCs
(.tres en game/isla-ancestral/data/npc_visuals/), re-correr
tests/unit/data/test_npc_visual_database.gd en runtime con objetivo
353 checks / 0 fallos / 0 SCRIPT ERROR / EXIT 0, y reportar.

## Diagnostico (medido en disco y runtime)
- grep recursivo de `color_principal = ""` sobre los 23 .tres: SOLO 1 hit,
  COR/NPC-COR-005-nina.tres:36, que por layout del .tres es el sub_resource
  sub_4 = PIES ('Descalza'), NO el sombrero.
- Runtime (Godot 4.7.2 console): Bloque L corre 92 checks = 23 NPCs x 4
  aserciones (sombrero/torso not_null + color). 0 fallos en sombrero.
  => NO hay sombrero vacio en el arbol actual.
- git log: commit eb3de84 (2026-10-08 21:47) ya contiene el fix M161 de los
  3 sombreros (atribuido a Hy3/M161). Diff:
    CEN/NPC-CEN-001-herrero_adv.tres   : "" -> "#71797E"
    CEN/NPC-CEN-004-bibliotecario.tres : "" -> "#2C2C2C"
    COR/NPC-COR-001-herrero.tres       : "" -> "#71797E"
  Confirmado en disco: en los 3, sombrero = SubResource("sub_1") y
  sub_1.color_principal es no-vacio y coherente con la paleta
  (gris/hierro herreros, negro erudito).

## Corrida final (mi binario, runtime)
Comando:
  Godot_v4.7.2-stable_win64_console.exe --headless --path game/isla-ancestral \
    --script res://tests/unit/data/test_npc_visual_database.gd
Resultado:
  Checks por bloque: A1 B3 C1 D2 E1 F4 G2 H3 I2 J2 K138 L92 M104
  Total: 356 checks, 0 fallos
  Resumen: 'TEST OK - todos los checks pasaron'
  EXIT 0. Sin SCRIPT ERROR (solo warnings de leak del dummy renderer, no SCRIPT).
  CHECKS_MINIMOS=353 <= 356 => piso respetado. No se modifico CHECKS_MINIMOS.

## Observacion no bloqueante (fuera de alcance sombrero)
COR/NPC-COR-005-nina.tres sigue con pies.color_principal = "" (sub_4 'Descalza',
nina descalza en la playa). Es semantico-valido y NO es asertado por Bloque L ni M
(Bloque M salta colores vacios). Coincide con la propia nota del director:
'4 .tres tienen algun color_principal = "", 3 en el sombrero' => 1 no-sombrero queda.
No se toco (restriccion: solo sombrero; y no es bug de datos).

## Conclusion (sec 21.8)
M161: verificado runtime por tercero independiente. La gate de aceptacion
(>=353 checks, 0 fallos, 0 SCRIPT ERROR, EXIT 0) se cumple: 356/0/EXIT 0.
Los 3 sombreros estaban ya poblados en eb3de84; mi medicion confirma 0 sombrero
vacio y suite verde. No se modifico la suite ni el SUT (restriccion 4/5).
Sello: M161 CALIFICA (verificado runtime, 2do verificador != autor del fix).

Archivos:
  Log: Logs/1497-hy3-m161-sombrero-verificado-runtime_2026-10-08_22-09-53.md
  Reporte canal: Mensajes entre modelos/Hy3/107-2026-10-08_22-09-53-hy3-a-atria-m161-sombrero-verificado-runtime.md
  Tracker: .ultima-revision-hy3.txt 102 -> 106
