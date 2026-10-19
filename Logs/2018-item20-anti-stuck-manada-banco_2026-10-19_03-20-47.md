# Log 2018 - Item 20 REPOBLACION V3: anti-stuck de manada/banco (36-Fauna L212 + M65)

**Agente:** Step-5-WorkBuddy | **Modulo:** M36 (fuente del item) / M65 (diseno)
**Fecha:** 2026-10-19 03:20 (GMT-3) | **Tracker:** 86 -> 87 (msg 087 del director)

## Rama 1: msg 087 del director (cruce item 57)

- Unico mensaje nuevo: 087 (04:55) = cruce de universos del item 57. Declara el
  item 57 CERRADO con las dos listas como evidencia (la mia: drift de deudores
  viejos >24 h; la del: flips del dia sincronizados en la fila GLOBAL).
- Verificado en disco ANTES de acusar: las 5 filas que dice haber sincronizado
  cuadran hoy en CHECKLIST-GLOBAL.md (227.742 B, LF puro 225, sin BOM):
  M109 135/138 | M125 105/105 | M62 127/150 | M90 181/249 | M93 134/134.
  Las 5 coinciden con las cifras del mensaje.

## Rama 2: item 20 = [36-Fauna] Anti-stuck de manada/banco coordinado [M65]

Fuente: DOCUMENTACION/36-Fauna/plan-actual/05-Checklist.md L212.
Texto del item: '[M65] Anti-stuck de manada/banco coordinado [M] - KnownIssue
no bloqueante DoD: dueno M65; logica basica implementada en behavior.gd.
Avanzar con navmesh M65.'

### Mediciones de hoy (no heredadas)

1. **behavior.gd NO EXISTE**: busqueda exhaustiva en game/isla-ancestral
   (find -name behavior.gd) = 0 archivos. La cita del item es falsa.
2. **Anti-stuck individual SI implementado**, en el autoload
   scripts/animales_ia/m65_animal_ai.gd L159-168: acumula distancia_acumulada
   y si > 30.0 m con dist > 0.5 aborta (en_movimiento=false + resetea).
   Resets en L151 (llegada), L163 (llegada), L168 (aborto), L287/L313/L333.
3. **PackLogic/SchoolLogic SIN anti-stuck de grupo** (lectura completa de
   pack_logic.gd y school_logic.gd): 0 referencias a distancia_acumulada,
   aborta o umbral de grupo. Sus miembros heredan el anti-stuck individual
   via senal solicitar_movimiento (registrados en el autoload, P-38/Log 1154).
4. **Suites medidas con el binario real** (Godot_v4.7.2-stable_win64_console,
   --headless):
   - scripts/animales_ia/test_m65.gd: 24 OK / 0 fallos / EXIT 0 /
     0 SCRIPT ERROR. Incluye 'anti-stuck: tras 35m acumulados, aborta'.
   - tests/test_m65.gd (pack/school, preloads corregidos por P-38):
     35 OK / 0 FAIL / EXIT 0 / 0 SCRIPT ERROR. Cubre lider rotativo,
     cohesion, huida coordinada, delta_max, migracion. NO cubre anti-stuck
     de grupo (no existe).

### Trabajo hecho

- 65-Animales-IA/plan-actual/03-Diseno.md: nueva seccion 'Anti-stuck
  (individual + grupo coordinado)' con las 3 reglas: individual implementado
  (cita L159-168), herencia por grupo via solicitar_movimiento, y el DISENO
  del grupo coordinado (manada: recalculo de cohesion si el lider aborta;
  rotacion forzada si el grupo no desplaza > 0.5 m en 5 s. banco: migracion
  anticipada si la direccion grupal no produce desplazamiento neto) con la
  implementacion diferida a navmesh M65 (KnownIssue no bloqueante).
- 36-Fauna/plan-actual/05-Checklist.md L212: flip [ ] -> [x] con cita real,
  corrigiendo la atribucion behavior.gd -> m65_animal_ai.gd y preservando el
  KnownIssue. Totales L271: 228/228/0. Nota de Total L237 actualizada.

### Estado medido por bytes (36-Fauna 05-Checklist, LF puro, sin BOM)

- Antes: 18.182 B, 227 [x] / 0 [?] / 1 [ ] = 228 items, 278 LF.
- Despues: mismo EOL, 228 [x] / 0 [?] / 0 [ ], diff = 3 lineas (L212, L237,
  L271). M65 03-Diseno.md: 1.110 B, 28 LF, sin BOM, +1 seccion.

### Observaciones ajenas (NO tocadas)

- Nota de auditoria L274 dice '228 [x] / 0 [ ]' cuando habia 1 [ ]: quedaba
  desactualizada; tras el flip sus cifras son correctas de facto.
- M65 03-Diseno.md L28 nota que pack/school 'viven en scripts/fauna/' -
  stale desde el move del Log 584 (hoy estan en scripts/animales_ia/).
- M65 05-Checklist L120 cita '35 OK' de P-38: corresponde a tests/test_m65.gd
  (medido hoy 35 OK); la suite scripts/animales_ia/ da 24 OK. No es contradiccion
  pero conviene explicitarlo en futuras citas.

## Limites

0 commits / 0 push / 0 archivos ajenos modificados / 0 ediciones a
CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot /
0 auto-sellos 21.8. Flip ofrecido a revertir al director (msg 088).
