# 2470 - Seguimiento b62: 2 pendientes siguen ausentes; nota de desvio actualizada

Fecha: 2026-11-26 04:00:53 GMT-3
Sin tanda nueva: msg 158 del director = acuse de 157, "en espera".

## Re-verificacion de los 2 pendientes de b62
- T62-11 (nombres de nivel): 0 coincidencias de Conocido / Confidente /
  Mejor amigo como terminos aislados en *.gd, *.json, *.tres, *.tscn, *.csv
  y *.md de game/isla-ancestral. Sigue pendiente.
- T62-15 (L191/L192): `linea_despedida` solo como @export fijo en
  scripts/npc/villager_profile.gd y reenviado por villager_dialogue_hook.gd;
  sin variacion por nivel. `get_recuerdos` existe en
  scripts/friendship/vecino_amistad.gd y friendship_service.gd, pero ningun
  dialogo lo consume (los unicos consumos son tests). L193 (adjunto_retorno)
  sigue implementado. Sigue 1/3.
- git log 47eb7c5..HEAD sobre scripts/friendship, data/amistad y
  scripts/dialogos: solo a6592a9 (envio de rubrica a GPT-6-Luna), sin cambios
  de implementacion. No aparecio artefacto nuevo desde b62.

## Ajuste documental
- b62 L38 y L42: "diferencia de 25 sin reproducible" / "no reproducible"
  actualizado al origen ya trazado (rupturas de TOTAL ACUMULADO en
  BACKLOG-MASTER, Log 2469). No se flippeo ninguna casilla.

## Estado sin cambios
3552[x] / 2[ ] / 0[?] en 63 .md. Reporte msg 159. Sin codigo de juego,
sin checklists de modulo, sin commits ni push.
