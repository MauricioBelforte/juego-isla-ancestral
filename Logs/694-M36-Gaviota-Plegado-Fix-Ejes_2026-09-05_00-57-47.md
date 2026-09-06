# Log 694: M36 Gaviota — Fix del plegado de alas (ejes equivocados v11/v12)

**Fecha:** 2026-09-05
**Hora:** 00:57
**Modelo:** glm-5.3-free
**Plataforma:** Kilo Code

## Resumen
Corregido el bug historico del plegado de alas de la gaviota ("ala derecha
por la nuca, ala izquierda desde la garganta" — reporte del usuario). La
causa raiz era usar ejes de rotacion equivocados para la geometria real del
GLB exportado. Fix verificado con diagnostico geometrico en runtime.

## Causa raiz (dump_glb.py del GLB alta)
El GLB queda con: pico +X, arriba +Y, span de las alas en ±Z
(Ala_L Z 0→+0.82, Ala_R −0.82→0), cola −X. Godot compone Euler como
R = Ry·Rx·Rz (Z se aplica PRIMERO al vector del span).

- v11 (NPC): usaba rotation.z (twist helice) + rotation.x — equivocados.
- v12 (demo): usaba rotation.y (yaw, correcto) + rotation.x como "roll".
  Pero X es el eje de la CUERDA: al aplicarse antes del yaw, ponia el
  span VERTICAL — ala izq (+Z) hacia ARRIBA (nuca), ala der (−Z) hacia
  ABAJO (garganta), por el espejo. Exactamente lo que el usuario vio.

## Solucion (v13)
Plegado de ave = DOS rotaciones con ejes correctos:
- ROLL rotation.z (eje del span): MISMO signo en ambas alas (−1.50).
  Verticaliza la superficie contra el flanco. (Negado por lado = bug
  v13a: una ala plegada y la otra levantada.)
- YAW rotation.y (barrido hacia atras): signo NEGADO por lado (±1.45).
  Lleva el span ±Z hacia −X (la cola).
- Pose parada del modelo: pitch morro-arriba = rotation.z POSITIVA
  (0.45), no rotation.x (era roll lateral y la volcaba).

## Verificacion (runtime, escena gaviota_demo_parada.tscn)
DIAG a los 2s (convergencia del lerp) — ambas alas:
- ala 0: rotZ=−1.500 (obj −1.500) rotY=−1.450 — PLEGADA OK
- ala 1: rotZ=−1.500 rotY=+1.450 — PLEGADA OK
- Verificacion GEOMETRICA: puntas del span en mundo rel.x=−0.51 y
  −0.64 (DETRAS del cuerpo, hacia la cola), |rel.y|=0.19 (superficie
  casi vertical contra el flanco). Boot 0 errores del script.

## Archivos Modificados
- game/isla-ancestral/scripts/fauna/gaviota_demo.gd (v13: ejes fix)
- game/isla-ancestral/scripts/fauna/gaviota_npc.gd (v13: _bater_alas
  plegado con roll/yaw correctos, pose parada en rot Z, head-bob en X)

## Pendiente
- Validacion visual del usuario en la demo (V1) y en main_island (ciclo
  aterrizaje→caminata con alas plegadas→despegue).
- Documentar E-11 (ejes del plegado) en 07-GUIA-GODOT §11.5 si el
  usuario aprueba visualmente.
