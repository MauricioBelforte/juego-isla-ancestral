# Log 1801 - M04-Game-Engine iteracion 2: seccion A (Evaluacion de candidatos) - 12 flips con cita real

**Modelo:** step 5 workbuddy
**Plataforma:** WorkBuddy
**Modulo:** M04-Game-Engine (DOCUMENTACION/04-Game-Engine/plan-actual/05-Checklist.md)

## Contexto

Encargo del director mimo-v2.6-flash-free (msg 5 a mi carpeta, 2026-10-13 00:50):
iteracion 1 (seccion B) ACEPTADA - 24/128 1:1 con mi reporte; fila GLOBAL aplicada
por el director (14 -> 24, cita e38ad5a). Orden: iteracion 2 / seccion A
(Evaluacion de candidatos, 12 items) con los guardrails de siempre: grep obligatorio
antes de cada flip, cita archivo+linea, linea Totales al dia. M90/M17 siguen
diferidos. Hueco 1797: dejarlo declarado, sin log de nota (indicacion del director).
Status check de atria-dawn-s3 (msg 6, 01:44) acusado con msg 7: (1) EN CURSO.

## Medida (antes -> despues, conteo por PREFIJO de linea sobre 05-Checklist.md)

Antes:   x=24  ?=0  [ ]=104  total=128
Despues: x=36  ?=0  [ ]=92   total=128
Flips aplicados: 12 (seccion A completa, lineas 20-31 del checklist).

## Evidencia por item (archivo + linea verificada en disco ANTES de cada flip)

Se documento la seccion 7 de DOCUMENTACION/04-Game-Engine/plan-actual/02-Analisis.md
con las 12 verificaciones (mismo formato que la seccion 6 de la iteracion 1).
Todas las citas se verificaron por grep/sed sobre el archivo en disco:

A1 Evaluar Unity: 02-Analisis.md L14 (punto 1: "Descartado por defecto: costo por
   asiento > USD 200k ingresos... voxel sin soporte nativo") + L45 (tabla costo).
A2 Evaluar Godot: 02-Analisis.md L15 (punto 2: "Elegido: gratis (MIT), sin
   regalias, native Linux/SteamOS") + L8 (decision adoptada, seccion 1).
A3 Evaluar Unreal: 02-Analisis.md L16 (punto 3: "Descartado: overkill para cozy
   sim, voxel manual, tasa del 5%").
A4 Unity descartado documentado: L14 + L45 ("Gratis < USD 200k; Pro ~USD
   2.300/ano") + L46 ("Voxel nativo | No - terceros").
A5 Unreal descartado documentado: L16 + L63 ("curva y tasa eliminatorias") +
   L76 (seccion 6, B4: 5% tras USD 1M, umbral verificado en
   unrealengine.com/release el 2026-10-12).
A6 Recomendacion Plan-de-produccion sec.2 como fuente: 02-Analisis.md L8, que cita
   DOCUMENTACION/00-PLAN-INICIAL/Plan-de-produccion.md L111 ("Godot 4.x es la
   opcion mas defendible por defecto"; linea reverificada por sed 2026-10-13).
A7 Adoptar Godot 4.x: L8 + L15 + L29 (punto 16 "Godot 4.x LTS estable") +
   game/isla-ancestral/project.godot L16 (config/features=PackedStringArray("4.7",
   "Forward Plus")) + Logs/17 (cierre de la decision por el usuario).
A8 Comparativa Unity vs Godot en tabla: 02-Analisis.md sec.3 L43-49 (Costo L45 /
   Voxel nativo L46 / IA-MCP L47 / Deck L49).
A9 Revisable SOLO antes del hito M1: 02-Analisis.md L8 ("el usuario puede
   revertirla antes del hito M1").
A10 Confirmacion del usuario: Logs/17-CONFIRMACION_MOTOR_GODOT-VOXELTOOLS_
   2026-08-16_06-10-00.md ("Por encargo explicito del usuario... se cerro la
   decision final del motor... se descarta el volantazo"). Refuerzo:
   05-Checklist.md L159 (seccion J, mismo respaldo). Nota de honestidad: el texto
   del item conserva su redaccion original ("(veto pendiente)"); la cita agregada
   documenta que el veto quedo cerrado el 2026-08-16.
A11 Trade-off animacion: 02-Analisis.md L22 (punto 9: "Mejor en Unity (Mecanim)
   pero Godot 4 cubre rigging basico para cozy").
A12 Trade-off bolsa de talento: 02-Analisis.md L26 (punto 13: "mas chica que
   Unity") + L55 (seccion 4, riesgo "Comunidad Godot mas chica para
   arte/animation" con su mitigacion).

## Verificaciones de higiene y conteos (medidas, no estimadas)

- 05-Checklist.md: LF puro (0 CRLF, 0 CR suelto), sin BOM; 12260 -> 13006 bytes.
- 02-Analisis.md: LF puro, sin BOM; 6846 -> 10492 bytes (+3646, seccion 7).
  El archivo no terminaba en salto de linea: se agrego el separador antes del
  bloque (verificado por bytes).
- Conteo por prefijo de linea: [x]=36 [?]=0 [ ]=92 total=128; cuadra con la
  linea Totales actualizada ("Completados: 36 | Pendientes: 92 | No resueltos: 0").
- scripts/verificar_checklist.py: exit 1 con 15 alertas. La de M04 es la
  ESPERADA ("CHECKLIST-GLOBAL dice '24/128' pero el 05-Checklist.md tiene
  '36/128'"): la fila GLOBAL la aplica el director (msg 5: "no edites
  CHECKLIST-GLOBAL.md... mandame el conteo final y la fila la aplico yo").
  Las otras 14 alertas son ajenas (M105 de DeepSeek-V4.1-Flash + drift de
  estado en 137-144).
- Sin colision de doble asignacion: git log --oneline -5 --
  DOCUMENTACION/04-Game-Engine/ -> ultimo commit el mio (e38ad5a); worktree
  limpio para el modulo antes de empezar.

## Limites respetados

0 commits, 0 push (pedido de commit a atria-dawn por su canal, msg 9). NO se toco
CHECKLIST-GLOBAL.md ni quality.yml. Los 12 items son de evaluacion/documentacion
con cita real; los items de implementacion (secciones F/G/J) no se tocaron.
