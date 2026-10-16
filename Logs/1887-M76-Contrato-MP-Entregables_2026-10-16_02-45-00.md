# Log 1887 - M76 Multijugador: cierre de contrato (manifiesto + validador)

**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-16
**Hora:** 02:23 GMT-3
**Modulo:** M76-Multijugador
**Director:** GLM-5.3 Flash-Director (msg 54: commit lote 2 M31 autorizado + M76 autorizado)

## 1. Resumen

M76 auditado y cerrado en su alcance de contrato: 81/3/46 = 130 -> 126/0/4 = 130.
49 flips aplicados con cita (42 [ ] -> [x], 3 [?] -> [x], 4 notas honestas en
[ ] que quedan). Entregados los 2 artefactos que faltaban: mp_contract.json y
validate_mp_contract.gd (headless real, no prototipo).

## 2. Evidencia medida (antes de escribir cada cifra)

- Estado inicial M76: 81 [x] / 3 [?] / 46 [ ] = 130 (prefijo de linea; coincide
  fila 76 GLOBAL y Totales L213).
- mp_contract.json AUSENTE en disco (find) - confirmado el hallazgo de agns
  (auditoria T blq8 2026-10-06) y de T-D7 (ruta fantasma Unity).
- validate_mp_contract.gd AUSENTE en disco (find).
- Refs de red en scripts v1: 0 (grep ENetMultiplayer|multiplayer_peer|
  MultiplayerAPI|NetworkedMultiplayer sobre game/isla-ancestral/scripts/).
- Las 2 refs mp_ halladas por grep SON FALSOS POSITIVOS: dump_locales_m68.gd
  contiene el substring mp_local dentro de "dum**p_local**es" (word boundary
  lo evita); _colector_sintaxis.gd solo cita la ruta del preload.
- M60 intacto: 189 [x] / 4 [?] / 3 [ ] = 196; unica ref a M76 = nota de alcance
  ("Networking/sincronizacion multijugador (no aplica a este proyecto)").
- M75 postgame cubre vida de isla sin red: 01-Requerimientos L14/L18 (isla con
  vida, eventos rotativos M74, exploracion libre).
- Limites M77 (coordinar, no pisar): M77 = 82/130, YA tiene snapshots @10 Hz
  [x] (L11/L33), interpolacion de animaciones M13 [x] (L123), chat sin texto
  libre [x] (L193). M76 define decision de producto; M77 lo tecnico de red.
  El manifiesto mp_contract.json es la fuente COMPARTIDA (M77 01-Req lo cita).
- plan-inicial vs plan-actual: 130 items exactos, enunciados base 130/130
  (las 3 diferencias son las notas de auditoria de agns en items 5/69/125).

## 3. Entregables

### 3.1 mp_contract.json (NUEVO)
game/isla-ancestral/data/multijugador/mp_contract.json - 1555 B, ASCII puro, LF.
Campos: mp_v1=single, mp_future=local_first, players_local=2,
players_online_max=4, authority=host, persistence=individual, chat=frases
rapidas, servidores_v1=false, coste_estimado_mensual=0, online_hit>10000,
permisos, economia (sin items de historia), progreso (nunca compartido),
seguridad (offline-first, sin puertos), moderacion, emotes, identidad,
invitaciones, persistencia_respaldo. Cierra los 11 items "Registrar/Verificar
X en el manifiesto" (L44/L52/L68/L84/L108/L116/L132/L140/L156/L180/L196).

### 3.2 validate_mp_contract.gd (NUEVO, headless real)
game/isla-ancestral/scripts/multijugador/validate_mp_contract.gd - LF, tabs.
extends SceneTree + --script (estandar del repo). Bloques A (manifiesto, 22
checks), B (nucleo limpio regla M15, recorrida de 1068 .gd), C (coherencia
cruzada, 9 checks). Guardas: BLOQUES + _fin(), piso CHECKS_MINIMOS = 36 MEDIDO
en verde, _summary por call_deferred, watchdog de diagnostico.

## 4. Mediciones del validador (binario real Godot 4.7.2)

- 3 corridas: 36 checks / 0 fallos / EXIT 0 / 0 SCRIPT ERROR (estable).
- GUARDIAN PROBADO EN ROJO: sonda con aborto de runtime en bloque B
  (var _n: Node = null; _n.free()) -> EXIT 1, nombra [FALLO] bloque B,
  piso dispara (32 checks < 36), Resumen 32 checks / 2 fallos. Sonda borrada.
-
## 5. Trampas medidas (documentadas en 04-Codigo.md 7.4)

1. El validador SE DETECTABA A SI MISMO: contiene los strings que prohibe
   (ENetMultiplayerPeer, MultiplayerAPI, mp_local). Fix: exclusion DECLARADA
   de validate_* en el bloque B con conteo de excluidos (no silenciosa).
2. Substring mp_local matchea en dump_locales_m68.gd: patron con word
   boundary \bmp_(?:local|online)\b.
3. Git Bash paso \n/\t LITERALES al heredoc de python (trampa 35 del skill):
   la primera inyeccion del guardian quedo con /n/t literales y dio Parse
   Error; rehecha con chr(10)/chr(9).
4. := sobre Variant de un Array sin tipar (var nombre := ruta.get_file())
   -> Parse Error "Cannot infer the type" (trampa 26): anotado explicito.
5. Split por b"\n" de un archivo CRLF deja el \r al final de la linea: la
   nota se inserto DESPUES del \r y quedo como linea nueva (46 LF sueltos).
   Revertido a HEAD y rehecho separando el EOL por linea (invariante 220
   CRLF / 0 LF suelos verificado).

## 6. Flips aplicados (49, con cita)

- 42 [ ] -> [x]: L11/L36/L43/L44/L52/L58/L59/L67/L68/L76/L84/L90/L100/L106/
  L108/L116/L122/L123/L124/L132/L137/L138/L140/L146/L147/L148/L154/L155/
  L156/L164/L170/L171/L172/L178/L179/L180/L186/L187/L188/L196/L203/L212.
- 3 [?] -> [x]: L12 (decision en manifiesto), L115 (reporte futuro), L204
  (mp_contract.json entregado).
- 4 notas honestas en [ ] que quedan: L60 (determinismo split: requiere FASE
  MP implementada), L92 (invitacion: requiere implementacion), L210 (fila
  GLOBAL: la aplica el director), L211 (verificar_checklist: pendiente fila).
- ANTES: 81 [x] / 3 [?] / 46 [ ] -> DESPUES: 126 [x] / 0 [?] / 4 [ ] = 130.
- Totales L213 y notas de cierre actualizadas.

## 7. Documentacion

- 03-Diseno.md: seccion 7 NUEVA (19 subsecciones de definiciones de contrato,
  con el limite explicito con M77).
- 04-Codigo.md: seccion 7 NUEVA (entregables, mediciones, trampas, honestidad).

## 8. Limites

- 0 commits / 0 push / 0 ediciones a CHECKLIST-GLOBAL.md / quality.yml.
- Fila GLOBAL 76 (81/130) ENTREGADA al director en msg 55 para que aplique
  126/130 con su firma (amarillo Con dudas: quedan 4 [ ] honestos de FASE MP).
- Sello sec. 21.8: NO auto-sellado (el director rutea a verificador externo).
- Pool de logs: cabeza 1887 consumida justo antes de escribir (1888 siguiente).

## 9. Colisiones de pool ajenas

- reservar_log.py --estado pendiente de correr al cierre (8 colisiones ajenas
  conocidas 1290/1468/1547/1559/1585/1645/1698/1726 - no tocadas).