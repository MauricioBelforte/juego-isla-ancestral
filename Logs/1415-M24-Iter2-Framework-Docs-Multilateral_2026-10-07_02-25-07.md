# Log 1415 - M24: iter. 2 - framework documentado + familia multilateral migrada

**Fecha:** 2026-10-07 02:25 (local -0300; UTC 2026-10-07 05:25)
**Agente:** DeepSeek-V4.1-Flash (WorkBuddy)
**Modulo:** M24-Templos-Y-Puzzles
**Plan:** aprobado por el director (canal DeepSeek/68, mensaje 68). Alcance = Frente A + Frente B (sin ampliar a bloques).
**Mensaje de canal:** 69 (deepseek-a-atria)

## 1. Alcance ejecutado (aprobado tal cual)

- Frente A (docs, items 27-31 y 35): documentar el framework emisor->receptor ya implementado en iter. 1.
- Frente B (familia multilateral, items 126-128): migrar los 2 puzzles legacy multi-fuente al esquema datos-driven + suite con SONDA ROJA.
- Frente C (auditoria del catalogo legacy) NO ejecutado (opcional, cierra 0 items; el director lo dejo como anexo).
- Familia bloques (83-87): NO aprobada para iter. 2 (queda para iter. 3, decision de tamano del director).

## 2. Frente A - documentacion (items 27, 28, 29, 30, 31, 35)

- `DOCUMENTACION/24-Templos-Y-Puzzles/plan-actual/03-Diseno.md`: seccion nueva "Framework emisor->receptor - definiciones"
  (tabla concepto -> definicion -> clase viva) + seccion "Familia multilateral".
- `DOCUMENTACION/24-Templos-Y-Puzzles/plan-actual/04-Codigo.md`: "Framework emisor->receptor - mapa de conceptos a codigo"
  + "Familia multilateral" (archivos nuevos).
- Anclas reales (firmas, no memoria):
  - Emisor -> `scripts/templos/puzzle_emisor.gd`: recibir_golpe(), set_activo(bool), recibir_peso(peso) + umbral_peso.
  - Receptor -> `scripts/templos/puzzle_puerta.gd`: evaluar(activos), abrir().
  - Regla -> `PuzzleRoom.add_regla(emisores, receptor)` + `PuzzleDef.reglas_def(def)`.
  - EstadoSala -> `PuzzleRoom.emisores` + get_vector_estado()/recalcular().
  - Objetivo unico -> `PuzzleDef.ids_objetivo(def)` + `PuzzleRoom.estado_igual_objetivo()`; unicidad por validar_def.
- Cierra 6 items (solo docs, riesgo nulo). Nada renombrado ni quitado.

## 3. Frente B - familia multilateral (items 126, 127, 128)

- Datos NUEVOS en `game/isla-ancestral/data/templos/puzzles/multilateral/`:
  - `multilateral_anillos.json`: 7 emisores (anillo 0..6 = glifo_brisa..glifo_sello) + 1 regla AND -> receptor_columna; objetivo [0..6].
    Migrado del legacy `puz_anillos` (emisor `columna_7_anillos`, solucion `7_anillos_glifos`).
  - `multilateral_final_3fases.json`: 3 emisores de fase (espejo_maestro/gongs/timon_agua) + 1 regla AND -> receptor_final; objetivo [0..2].
    Migrado del legacy `puz_final_3fases` (emisor `espejo_maestro_gongs_timon`, solucion `luz_sonido_agua`).
  - Ambos conservan bloque `origen_legacy` con id/emisor/receptor/solucion del catalogo (procedencia).
- Suite NUEVA `game/isla-ancestral/scripts/templos/test_puzzle_multilateral.gd` (extends SceneTree, bloques A-E):
  carga + validacion/unicidad + CRUCE contra el catalogo real + SONDA ROJA + interprete.
- Verificacion de n (la sorpresa que el director pidio medir): `puz_anillos` SI es n=7 real.
  Evidencia: `templo_layout_diseno.json` declara el array `anillos` con 7 glifos; `test_templo_m26.gd`
  activa 7 anillos (linea 101 "7 anillos iniciales"; lineas 136/138 "los 7 anillos con sus 7 sellos").
  No hubo sorpresa que obligara a parar; no se forzo nada.
- Cruce con el catalogo (no se inventan datos): la suite afirma receptor migrado == receptor legacy
  (receptor_columna / receptor_final) y que ambos legacy son tipo "multilateral".

## 4. Evidencia MEDIDA

- `test_puzzle_multilateral.gd`: **38 checks, 0 fallos, EXIT 0 x3** (desglose por bloque MEDIDO: A=7 B=9 C=9 D=5 E=8; suma 38 = total).
  `CHECKS_MINIMOS = 38` MEDIDO en verde (se escribio 32 estimado y se corrigio al valor medido).
- 0 SCRIPT ERROR en las 3 corridas verdes.
- **SONDA ROJA (obligatoria, condicion 1 del director) - EN VIVO sobre el JSON REAL:**
  - Inyeccion: reemplazar la unica regla AND de `multilateral_anillos.json` por 2 caminos OR
    incomparables ({0,1,2} y {3,4,5,6}) -> 2 soluciones minimas.
  - Corrida con el JSON inyectado: `=== Resumen M24-Multilateral: 38 checks, 6 fallos ===` / EXIT 1.
    Fallos nombrados: B validar_def(anillos) sin errores; B soluciones_minimas(anillos)==1; B solucion_minima(anillos)==objetivo;
    D control positivo; D control negativo; E a_puzzle_room(anillos) declara 1 regla.
  - `PuzzleDef.validar_def` reporta: "soluciones minimas = 2 (se exige exactamente 1): puzzle ambiguo".
  - JSON restaurado byte-exacto: sha256 `cb1db249899c4297bc91398f168e63ae561c4806e230450fe1ed1d95f99c18c4` igual antes/despues;
    re-corrida -> 38/0 EXIT 0.
- Regresiones (M24): `test_puzzle_datos.gd` 42/0 EXIT 0; `test_puzzles.gd` 0 fallos EXIT 0;
  `test_templo_m26.gd` 92/0 EXIT 0; `test_templo_headless.gd` 4/0 EXIT 0. 0 SCRIPT ERROR en las 4.

## 5. Higiene de bytes

- Archivos nuevos (2 JSON + 1 .gd): UTF-8 sin BOM, 0 FFFD, 0 NUL (medido por bytes).
- `03-Diseno.md`: LF (116 LF, 0 CRLF). `04-Codigo.md`: CRLF (104). `05-Checklist.md`: CRLF=251 + LF=3 (los mismos 3 LF previos; EOL preservado).
- Sin BOM ni NUL en los 3 .md (medido antes/despues).

## 6. Conteo MEDIDO del checklist (43/128)

- Flips a [x] (9): 27, 28, 29, 30, 31, 35 (Frente A); 126, 127, 128 (Frente B).
- Conteo: **43 [x] / 1 [?] / 84 [ ] = 128**. `**Totales:**` actualizado a 43/84/1.
- `verificar_checklist.py` reporta el UNICO drift esperado: "24-Templos-Y-Puzzles: CHECKLIST-GLOBAL dice '34/128' pero el 05-Checklist.md tiene '43/128'".
  El flip de la fila 24 del GLOBAL lo hace el director (condicion 3). Las demas alertas son preexistentes de otros modulos.

## 7. No tocado / pendiente

- NO se toco `CHECKLIST-GLOBAL.md` (el director hace el flip 34->43 con este reporte).
- NO se toco `quality.yml`: el cableo del test nuevo sigue pendiente del visto bueno de s2 (modo A / BUG-091). No se le volvio a pedir (el director dijo que el le habla).
- NO se toco `interaction_manager.gd` / `service_registry.gd` / `bootstrap.gd` (cuarentena) ni M25/M26 ni M45/M47 ni M13.
- Frente C (adaptador `PuzzleDef.desde_legado()` + informe) NO ejecutado.
- Sin push: los commits de M24 (`0776386`, `dd974a1` + los de iter. 2) quedan locales hasta la autorizacion del director.
- Colision AJENA reportada (no tocada): pool de Logs, numero 1290 con 2 archivos distintos (M112 + TH2).

## 8. Archivos

- Nuevos: `game/isla-ancestral/data/templos/puzzles/multilateral/multilateral_anillos.json`,
  `game/isla-ancestral/data/templos/puzzles/multilateral/multilateral_final_3fases.json`,
  `game/isla-ancestral/scripts/templos/test_puzzle_multilateral.gd`.
- Modificados: `DOCUMENTACION/24-Templos-Y-Puzzles/plan-actual/03-Diseno.md`, `.../04-Codigo.md`, `.../05-Checklist.md`.
