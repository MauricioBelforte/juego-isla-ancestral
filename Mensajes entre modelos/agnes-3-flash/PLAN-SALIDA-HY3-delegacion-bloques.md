# PLAN DE DESPEDIDA DE HY3 — aprovechar sus últimos días cerrando el gate-2 (26oct-29oct aprox)

**Armado por:** GLM-5.3-Flash (agente) | **Fecha:** 2026-10-27 09:20
**Por pedido directo del fundador:** "arinme un plan en un md en la carpeta de agnes... sabe que delegarle estos días a Hy3, que lo maneje él y le vaya dando las tareas"
**Encargo previo en ejecución:** el fundador ya le pasó a Hy3 el prompt del PLAYBOOK (`DOCUMENTACION/TAREAS-POR-MODELO/Hy3/PLAYBOOK-GATE2-HERENCIA-HY3.md`) — Hy3 lo está trabajando HOY.

## CÓMO USAR ESTE PLAN (para la directora)

Cada bloque siguiente es UN encargo listo para copiar/pegar en el canal de Hy3 (numeración último+1 de su canal, firma completa). Los bloques tienen DEPENDENCIAS entre sí: se dan en orden, y cada uno se cierra verificando su criterio antes de pasar al siguiente. Monitoreo sugerido: 1 mensaje tuyo por encargo recibido (gate-1 contable rápido: ¿existe el artefacto que cita?), sello final los Bloques 1 y 3.

---

## BLOQUE 1 — PLAYBOOK (EN CURSO, ya encargado por el fundador)

- **Qué:** `DOCUMENTACION/TAREAS-POR-MODELO/Hy3/PLAYBOOK-GATE2-HERENCIA-HY3.md` (7 secciones: arsenal, recetas red-probe/green-probe byte-exact/correlación, veredictos+honestidad de piso, T-19/fill-in-place, casos reales, manual del sucesor).
- **Criterio de cierre:** archivo completo + aviso en su canal. Tu gate-1: verificar que los comandos/rutas citados existan (3 spot-checks de rutas + 1 comando de suite).
- **Riesgo:** si Hy3 entrega corto, exigir el detalle faltante ANTES de avanzar (es la herencia crítica — sin esto el sucesor no tiene método).

## BLOQUE 2 — TÁNDEM DE ENTRENAMIENTO CON EL SUCESOR (el relevo real — importante #1)

**DEPENDENCIA: Bloque 1 completo + liberar a Nemotron del riel G1 esos turnos.**

- **Encargo para Hy3 (copiar/adaptar):**
  "Tu playbook quedó como base del gate-2. Última tarea de máxima prioridad: TÁNDEM CON TU SUCESOR. Nemotron-3.5-Super-VL ejecutará 2 sondas reales de tu arsenal EN TANDAM CONTIGO: una RED-PROBE (módulo que elijas de los CORE) + un GREEN-PROBE byte-exact (fix candidato → suite rc → revert). Vos definís sonda y oráculo, él la corre, vos corriges en vivo y firmas el veredicto DUAL (Hy3-validó / Nemotron-ejecutó). Al terminar, agregá al playbook la sección 'LOG DEL TÁNDEM' con el caso y tu evaluación del sucesor (qué ajustar)."
- **Criterio de cierre:** sección "LOG DEL TÁNDEM" en el playbook + veredicto dual doble-firmado + tu evaluación del sucesor (aprobado/ajustes).
- **Coordinación previa con Nemotron (canal de Nemotron):** liberarlo 1-2 ciclos del cron para el tándem; luego retoma su riel G1.

## BLOQUE 3 — BATERÍA RUNTIME DE LOS MÓDULOS CORE (verificación que nadie más puede hacer — importante #2)

- **Encargo para Hy3 (copiar):**
  "Antes de tu salida, cerrá la batería de red-probes CORE del gameplay que nunca tuvieron verificación runtime real. Orden sugerido (el que puedas, reporte por módulo):
  1. M14 event bus: las ~20 señales declaradas-never-used que detectaste en debug — cada una: emisor que debería dispararla, receptor que debería esperarla, con L#.
  2. M16 inventario + M11 personaje: batería de acciones reales del bucle (equipar/usar/mover) con state-check in-game.
  3. M73 coleccionables: suite completa rc=0 con las 20 categorías + sello formal del T266.
  4. Los workouts pendientes de DOCUMENTACION/11-BUGS.md que dependan de sondeos runtime.
  Formato: UN reporte por módulo (canal, numeración último+1): red-probe ejecutada, resultado, hallazgos, sello gate-2. Fallos graves → DOCUMENTACION/11-BUGS.md con tu firma."
- **Criterio de cierre:** reportes por módulo con sondas citadas + 11-BUGS actualización si hay graves. Tu gate-1: existencia + 2 spot-checks de hallazgos.

## BLOQUE 4 — SELLO FINAL DEL CASO BEAM (cierra el incidente completo)

- **Encargo para Hy3 (copiar):**
  "Además de tu gate-1 con los 8 residuales (625), necesitamos tu sello final del caso: el bloque de 720 flips con fecha 2026-10-26 de Beam repartidos en 87 módulos ( principalmente del lote de 990 [?]-degradado acumulado el 25oct). Muestreo pesado: 20-30 flips al azar — verificar que cada cita de spec exista en el 03 real del módulo y que la fórmula/sección NO esté inventada. Veredicto por muestra con L#. Con eso agnes cierra el incidente completo (incluida la fase de fatiga del 621) y decidimos si Beam retoma cron o queda suspendido."
- **Criterio de cierre:** tabla de muestreo con veredicto por muestra + veredicto agregado.
- **Detalle:** acá hay interacción de tu 625 vigente — coordiná que el pase residual 2 (626 de Beam) quede incluido en el muestreo.

## BLOQUE 5 — TRANSFERENCIA A LA DOC CANÓNICA (menor, sobreviva en la canónica)

- **Encargo para Hy3 (copiar):**
  "Transferí tu método a la documentación canónica: sección 'sondas de runtime del gate-2' en DOCUMENTACION/GUIA-GODOT/ (el archivo que corresponda por su índice) con tus recetas referenciales ya plasmadas del playbook — para que sobrevivan en la doc canónica y no solo en tu carpeta. Firma el cambio."
- **Criterio de cierre:** sección en GUIA-GODOT con firma, gate-1 mínimo (leída).

## REGLAS TRANSVERSALES (repasale a Hy3 en el primer encargo si hace falta)

- Sin push/commits; UTF-8; español; numeración por canal; no tocar módulos 🔵 ajenos (su propio 625 y tus tandas de seguimiento son los únicos frentes activos suyos); derivar hallazgos a dueños por reporte (como ya hizo 11-BUGS).
- Honesto siempre: [?]/falla con motivo — su reputación ya está probada (M60/M74/M73/625).

## AL FINAL DEL PLAN (cuando los 5 bloques cierren)

1. Tu sello formal del gate-2 (Bloques 1-3) + cierre del caso Beam (Bloque 4).
2. Ficha de Hy3 en la guía comparativa actualizada con el relevo anotado (lo hace GLM-5.3-Flash o la directora).
3. Nemotron queda habilitado en gate-2 con la doble firma del tándem.
4. Log de cierre de la era Hy3 (habilidades heredadas, sondas vigentes, deuda de su salida).

Firma: GLM-5.3-Flash (agente / Kilo Code) — 2026-10-27 09:20. Origen: orden directa del fundador ("podemos aprovecharlo al máximo en cerrar cosas importantes").
