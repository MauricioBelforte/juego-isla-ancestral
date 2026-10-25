# Log 2187 - M23 L97 capitulos de diario: puente con data muerta, 2 de 79 con respaldo en M55

**Modelo:** Step-5-WorkBuddy
**Fecha:** 2026-10-25 17:48
**Modulo:** M23 (23-Historias-Secundarias)
**Tracker de canal:** 226 (sin mensajes nuevos de la directora desde mi 227)
**Numero de log:** 2187 (reservado del pool; head medido 2187 justo antes de consumir)

## Contexto de la corrida

Metodologia V2: RAMA 1 sin novedad (agnes-3-flash no escribio desde mi msg 227 de las
06:19) -> RAMA 2, proxima tanda de la COLA ACTIVA de M23. La directora (msg 226)
ofrecia L97/L98/L99 o L159. El orden de la cola marca L97 "Crear 20 capitulos de
diario (recompensa narrativa)" como el primer item propio accionable (L34 plaza
sigue bloqueado por su decision msg 153; L52-55/L70/L72/L148-152 son de duenos
externos).

## Medicion (disco, ANTES de tocar nada)

- 80 cadenas en `data/historias/secundarias.json`; 79 declaran `recompensa.diario`
  (la unica sin diario es `cadena-secretta-luciernagas`, solo cosmetico).
- `recompensa.diario` era DATA MUERTA: `secondary_stories_service.gd` (puente
  M23->M55) derivaba `"mision_" + cadena_id` SIN LEER el valor declarado. Los 79
  valores `capitulo-*` tenian 0 usos en todo el codebase (grep sobre scripts/):
  `quest_chain.gd` L43 solo valida que exista la CLAVE.
- Catalogo de M55 (`data/diario/diario_catalog.json`, categoria `misiones`): 4
  entradas, de las que SOLO 2 son de M23: `mision_cadena-faro` y
  `mision_cadena-invernadero` (esquema `mision_<id>`, igual que el puente de M22 en
  `diary_service.gd` L103). Las otras 77 recompensas degradan EN SILENCIO:
  `registrar()` devuelve false sin log (diary_service.gd L136-137).
- Cluster medido para el informe: L98 `dialogo_posterior` 0/80 usos (campo existe en
  el schema, sin contenido; los dialogos viven en data/dialogues, dueno ajeno);
  L99 = 74 cosmeticos distintos, 0 con item homonimo en data/items/ (los items son
  .tres; el desbloqueo solo emite senal, M71 escucha). L98 y L99 tambien desembocan
  en duenos externos.

## Tanda ejecutada (lado M23 solamente)

1. **Puente consume el capitulo declarado:** `_completar_cadena` ahora hace
   `diary.registrar(capitulo, "misiones")` con `capitulo = recompensa.diario`
   (antes derivaba `"mision_" + cadena_id`). Comentario stale corregido (decia
   "categoria descubrimientos").
2. **79 valores renombrados** de `capitulo-*` a `mision_<cadena_id>` en
   secundarias.json (reemplazo exacto sobre texto crudo; cada patron verificado
   con conteo == 1 antes de escribir). Comportamiento VERIFICADO como identico:
   con el dataset actual declarado == derivado, las 2 con respaldo siguen
   registrando y las 77 siguen degradando. El invariante de suite garantiza ademas
   que el puente de M22 (`mision_ + slug`) y el de M23 registren EL MISMO id.
3. **Suite:** bloque Y `_test_recompensa_diario()` (+8 checks: invariante
   `diario == "mision_" + id` en las 79; 79 con / 1 sin diario; 77 sin respaldo en
   el catalogo M55; runtime faro registrado / biblioteca no). Piso 742 -> 750.

## Evidencia (binario real Godot 4.7.2, headless)

- Verde: **750 checks / 0 fallos / EXIT 0 x3** (salidas completas capturadas).
- Guardian EN ROJO por inyeccion de runtime sobre el bloque Y (sonda null-call):
  EXIT 1, "[FAIL] el bloque Y NO se ejecuto" + "[FAIL] solo 743 checks (minimo 750)"
  = 2 fallos. Sonda borrada y verificada (grep 0) antes del verde final.
- Ruido conocido: "ERROR: Failed to retrieve non-existent singleton 'AnimationService'"
  cae DESPUES del resumen (teardown de NPC), no es aborto de test.

## Documentacion

- `04-Codigo.md` +seccion Iter. 21 (LF puro, 1166 -> 1208 lineas).
- `05-Checklist.md`: L97 con nota medida, SIGUE `[ ]` (el contenido de los 77
  capitulos es de M55). Conteo medido sin cambios: **86 [x] / 17 [ ] / 2 [?] = 105**.
- `03-Diseno.md`: nota del esquema real `mision_<cadena_id>` junto al ejemplo L18.
- Log ASCII puro por bytes, CRLF, sin BOM.

## Pedidos (msg 228 a la directora)

1. Los 77 capitulos faltantes (de 79 declarados) son contenido de M55: rutear a su
   dueno o autorizar escritura directa. Hasta eso L97 no se puede flipear.
2. Re-planteo de los 5 pedidos de mi msg 227 (siguen sin respuesta): dictamen de
   los 15 flips Beam de M33; sync fila 33 GLOBAL (133/155 vs 148/155); visto bueno
   de los 3 flips de M23; ronda de commit; ruteo de proxima tanda.

## Limites

0 commits / 0 push / 0 auto-sellos 21.8 / 0 protegidos tocados (CHECKLIST-GLOBAL,
quality.yml, AGENTS.md, project.godot intactos). Colisiones de numeracion de log
listadas por `reservar_log.py --estado` (1290, 1468, 1547, ...) son AJENAS: se
reportan, no se tocan.
