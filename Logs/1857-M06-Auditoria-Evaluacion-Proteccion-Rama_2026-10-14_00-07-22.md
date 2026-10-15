# Log 1857: M06-Control-De-Versiones - Auditoria del pendiente + evaluacion de proteccion de rama main

**Fecha:** 2026-10-14
**Hora:** 00:07 (GMT-3)
**Modelo:** Step-5-WorkBuddy
**Plataforma:** WorkBuddy
**Modulo:** M06 (DOCUMENTACION/06-Control-De-Versiones)
**Origen:** mensaje 36 del director mimo (2026-10-15 02:00 hora del director): M109 lote 3
ACEPTADO (120/138, GLOBAL aplicado) + nueva tarea = elegir un modulo amarillo con [ ] y
SIN [?] que este cerca de completar y PROPONER flips con cita real (Patron D). Reportar
por lote.

## Resumen

Barrido de CHECKLIST-GLOBAL.md: 108 modulos amarillos con items pendientes; 28 de ellos
tienen [ ] y CERO [?] (criterio del director). Elegido M06: 99/100, 1 solo pendiente,
0 [?], sin agente activo (verificado: agnes-3-flash trabaja M08/M133; su ultima menciona
de M06 es del 2026-10-14 07:10, msg 419, sobre otro modulo). El unico [ ] es L25
"Evaluar proteccion de rama main en GitHub -> dueno: Publicacion". La evaluacion se
EJECUTO en esta corrida via API de GitHub (no requeria la UI de GitHub). Propuesta al
director: 1 flip 99 -> 100/100. Yo NO aplico la marca: la aplica el director.

## Mediciones (todas de esta corrida, 2026-10-14 23:40-00:07 GMT-3)

1. Estado del modulo medido por prefijo de linea en plan-actual/05-Checklist.md:
   99 [x] / 0 [?] / 1 [ ] = 100. Coincide con la linea Totales (L139) y con la fila
   GLOBAL (99/100, estado "Con dudas").
2. Cierre previo verificado en disco: docs/version-control-policy.md existe (4322 B) y
   game/isla-ancestral/scripts/proyecto/test_version_control_m06.gd existe. Coincide
   con la nota del GLOBAL ("Verificado por Hy3/WorkBuddy (Log 1290, re-verify; sello
   Log 866 invalido): test 6 checks/0 fallos" + "Cerrado por agnes-3-flash (Log 1240):
   99/100").
3. API de GitHub: `gh api repos/MauricioBelforte/juego-isla-ancestral/branches/main/protection`
   -> HTTP 404, {"message":"Branch not protected", ...} => main SIN proteccion de rama.
4. GitHub Actions corre en cada push a main: 12 runs recientes (2026-10-14 02:56-07:13
   UTC), todos evento push sobre rama main.
5. CI en ROJO (medido hoy): Testing Suite (testing.yml) failure en las ultimas 3
   corridas (2m32s-2m43s); quality.yml failure "This run likely failed because of a
   workflow file issue" en 0s en las ultimas 3; Development Build (M118 CI-CD,
   dev-build.yml) cancelled en las ultimas 3 (15m39s). Backup Externo (backup.yml,
   schedule) success.
6. Flota multiagente: 131 commits en las ultimas 24 h (`git log --since="24 hours ago"`);
   los pushes directos a main son la norma (GHA solo ve push/main como disparador).
7. Politica del modulo: 05-Checklist L19 "no se usan ramas develop (1 persona)", L22
   "politica de commits directos + excepciones (features de riesgo)", L33/L58 "PR solo
   para modulos de riesgo"; 02-Analisis L21 "Activar proteccion de main en GitHub
   (ci nunca, PR nunca para 1 persona - evaluar)".

## Evaluacion ejecutada (item L25)

- Estado medido: main sin proteccion de rama (API, hoy).
- Activar proteccion estilo PR-only romperia el flujo de la flota (131 commits/24 h,
  pushes directos constantes) y contradiria la politica documentada del modulo
  (05 L19/L22) y 02-Analisis L21 ("PR nunca para 1 persona").
- Activar "require status checks" con el CI en rojo hoy bloquearia TODOS los pushes
  (medido: Testing Suite + quality.yml en rojo, dev-build cancelled).
- Opcion liviana compatible con el flujo directo: bloquear solo force-push y borrado
  de main (protege contra accidentes - familia del reset ajeno que borra commits,
  trampa 115 del skill - sin exigir PR ni checks verdes).
- Recomendacion: opcion liviana. La decision/accion sigue siendo del dueno Publicacion
  (el item queda delegado, como dice su propia nota).

## Propuesta de flip (la aplica el director; yo no marco)

- L25 -> [x] con nota: "Evaluacion ejecutada 2026-10-14 (Log 1857):
  gh api .../branches/main/protection -> 404 Branch not protected (main sin
  proteccion); opciones medidas contra la politica de commits directos (05 L19/L22,
  02-Analisis L21); opcion liviana (bloquear force-push/borrado) compatible con la
  flota; activacion -> dueno Publicacion". Totales 99 -> 100/100 (modulo completo).
- CAVEAT para el director: la nota de cierre del modulo (fila GLOBAL, cita a Log 1240
  de agnes) dice que el [ ] restante "requiere UI de GitHub". La evaluacion se pudo
  completar por API. Si el director lee el item como la ACCION de activar la
  proteccion (y no la evaluacion), el [ ] se mantiene. Queda a su criterio.

## Hallazgo reportado (no tocado): CI en rojo en cada push

GitHub Actions SI corre en cada push a main (validacion real existente), pero esta en
rojo: Testing Suite failure (3/3 ultimas), quality.yml "workflow file issue" (0s, 3/3),
Development Build cancelled (3/3). Relevante para M118 (118-CI-CD), cuyo unico [ ] es
"Validacion en GitHub Actions real (requiere push...)" con nota de QA s2 (Log 1539,
CASO A: infra externa no disponible). La validacion real YA ocurre por los pushes de
la flota; el resultado medido hoy es ROJO, por lo que ese item NO es flippable como
exito: la validacion destapo que el CI esta roto. No se toca quality.yml (prohibido)
ni modulos ajenos. Dato: quality.yml falla en 0s con "workflow file issue" - mismo
sintoma del BUG-122 (gemelo quality.yml) reportado por la flota.

## Barrido: 28 modulos amarillos con [ ] y SIN [?] (criterio del director)

Por pendientes ascendentes: M06 (1), M118 (1), M150 (1, step-5-kilocode), M167 (1,
sello hy3), M65 (1, KnownIssue M08 ya decidido), M36 (2), M93 (3), M153 (7,
step-5-kilocode), M119 (9), M131 (9, Ling), M99 (14, Ling), M18 (35), M62 (37),
M42 (38), M54 (44), M33 (47, atria-dawn), M37 (52, atria-dawn-s2), M110 (75),
M23 (80), M28 (80), M158 (87), M95 (94), M20 (98), M157 (106), M46 (110), M67 (112),
M75 (113), M01 (126, DeepSeek).

## Limites

0 commits / 0 push. 0 flips aplicados (solo propuesta). 0 ediciones a
CHECKLIST-GLOBAL.md / quality.yml / AGENTS.md. Pool de logs: head medido 1857 justo
antes de reservar -> consumido 1857 (1856 lo tomo otro agente; su archivo no estaba
en disco al escribir este log). Colisiones ajenas conocidas, no tocadas:
1290/1468/1547/1559/1585/1645/1698/1726.
