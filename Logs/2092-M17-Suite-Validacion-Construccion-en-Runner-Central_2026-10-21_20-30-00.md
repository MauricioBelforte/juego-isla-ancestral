# Log 2092: M17 Construccion — suite de validacion en el runner central + fix del suite rojo de M17

**Fecha:** 2026-10-21
**Hora:** 20:30 (local; NOTA DE RELOJ: mi plataforma reportaba la hora UTC como si fuera local — el director
lo detecto en su msg 019 y a partir de aca uso el reloj real del sistema: 20:28 local / 23:28 UTC)
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## Resumen

Frente **P3 (M17 Construccion)** del director. M17 tenia **8 suites** en `scripts/construccion/` — fuera de
`res://tests/`, que es lo unico que descubre el runner central: **M17 no tenia NINGUNA cobertura en la suite
central**, y por eso nadie veia que `test_construccion_iter7.gd` estaba **ROJO** (declaraba
`CHECKS_MINIMOS = 24` pero producia 22 checks -> se auto-declaraba FAIL, desde su commit inicial).

**M17: 81/175 -> 88/175** (7 items [x] con evidencia).

## Cambios Realizados

### 1. Suite NUEVA en el runner central — `tests/test_m17_construccion_validacion.gd` (44 checks, 0 fallos)

Nucleo puro (sin mundo ni assets): las **8 reglas** de `ConstruccionValidator.validar()` con su motivo
propio (zona/ocupacion/soporte/regla/npc/mundo/limite/recursos) y su ORDEN documentado; la forma del
resultado (`ok/motivos/detalle/celdas/texto/temporal`); la distincion **motivo TEMPORAL vs PERMANENTE**
(lo que el HUD puede reintentar); la **rejilla de 1 m** (round-trip celda<->mundo, floor hacia abajo,
negativos, origen global = celda (0,0,0) -> (0.5,0.5,0.5)); la **rotacion en pasos de 90 grados**
(la huella intercambia ancho y fondo en 90/270, posmod); y el costo/devolucion al demoler.

Anti-falso-verde: las lambdas del contexto son REALES (devuelven lo que el validador espera) y todos los
checks son falsables.

### 2. Fix del suite rojo de M17 — `scripts/construccion/test_construccion_iter7.gd`

Estaba en ROJO desde su commit inicial (piso 24 vs 22 checks medidos). **Se AGREGARON 2 checks reales**
(celdas negativas en `mundo_desde_celda` y `esquina_desde_celda` con coordenadas negativas) en vez de
**bajar el piso** — bajar un piso para que un suite pase es exactamente el anti-falso-verde que el
proyecto prohibe. Resultado: **PASS** (rc=0).

### 3. Documentacion y registros

- `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md`: 7 flips [x] con cita + Totales (88/175).
- `CHECKLIST-GLOBAL.md` (fila 17), `BACKLOG-MASTER.md` (seccion M17 con la fuente), `ESTADO-PARALELO.md`.
- `Logs/NUMEROS_DISPONIBLES.txt` (2092 consumido).

## Lo que NO se hizo (limite de alcance honesto)

- **No toque assets ni 3D** (fuera del riel headless): las piezas, la previsualizacion fantasma, el HUD
  del modo construccion y la interaccion con el mundo requieren viewport/ventana.
- **No cerre** los items que dependen del mundo real: "la rejilla solo se calcula sobre terreno cargado",
  "coherencia de la rejilla tras guardar y cargar", "alturas por zona" (el validador **no tiene regla de
  altura** — lo reporto como gap para el dueno) ni las colisiones fisicas de las piezas.
- **No edite** los modulos duenos (M08/M14/M18/M31/M50/M25); solo lei sus contratos.

## Hallazgo para el dueno de M17

El `ConstruccionValidator` **no implementa un tope de ALTURAS por zona** (la `ORDEN` tiene 8 reglas y
ninguna es de altura) -> el item "P16: restricciones — reglas por pieza, topes por zona, **alturas** y
parcelas ajenas" queda con esa parte sin cubrir, y el item "P15: colisiones — piezas con colision estatica
real" tampoco (el validador es logico, no fisico). Ambos quedan abiertos con el motivo exacto.

## Archivos

- Creado: `game/isla-ancestral/tests/test_m17_construccion_validacion.gd` (suite central, 44 checks)
- Modificado: `game/isla-ancestral/scripts/construccion/test_construccion_iter7.gd` (+2 checks, era ROJO)
- Modificado: `DOCUMENTACION/17-Construccion/plan-actual/05-Checklist.md`, `CHECKLIST-GLOBAL.md`,
  `DOCUMENTACION/TAREAS-POR-MODELO/MiniMax-M3.1-Flash/BACKLOG-MASTER.md`,
  `Mensajes entre modelos/ESTADO-PARALELO.md`
- Creado: este log + `Mensajes entre modelos/MiniMax-M3.1-Flash/020-2026-10-21_20-30-00-minimax-a-glm-5-3-director-p3-m17-suite-validacion.md`
- Sin push ni commits.
