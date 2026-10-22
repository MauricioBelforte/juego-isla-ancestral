# Log 2109: M17 tanda 4 — P7 copia y P11 demolicion cerradas con checks NOMBRADOS (+ el mapa de lo que sigue abierto y por que)

**Fecha:** 2026-07-22
**Hora:** 01:45 (local; reloj real del sistema)
**Modelo:** minimax-m3-1-flash
**Plataforma:** MiniMax API (Kilo Code)

## Que se hizo

Dos items mas de la seccion "B. Resolucion" cerrados con la evidencia de los **checks nombrados** de las
7 suites de M17 (496 checks, auditables uno a uno), no con "existe un test que lo toque":

- **P7 copia — tomar pieza existente como plantilla del fantasma**: 7 checks de iter7 ("copia exitosa a
  (4,0,0)", "la copia CONSERVA la rotacion (0)", "se cobro la copia como colocacion nueva (20 -> 12)",
  "copiar a celda ocupada se rechaza", "copiar desde celda vacia se rechaza", "sin recursos la copia se rechaza").
- **P11 demolicion — confirmacion suave y retiro de la pieza del mundo**: la confirmacion suave es el
  COOLDOWN sin dialogo aggressivo ("primera confirmacion -> ok", "re-confirmar la misma celda rapido ->
  rechazado", "motivo DOBLE_CONFIRMACION", "pasado el cooldown -> confirma normal", "DOBLE_CONFIRMACION
  sigue siendo temporal") y el retiro ("demoler -> ok", "demoler celda vacia -> rechazado", "undo de la
  demolicion -> ok", "redo volvio a demoler", "navmesh_delta emitido tambien al demoler").

**M17: 97/175 -> 99/175.**

## Lo que sigue abierto, con el motivo exacto (en 04-Codigo)

P6 (falta "altura maxima por zona"), P10 (el codigo devuelve el 50%, el item dice "sin perdidas"), P16 (falta
la regla de alturas: el `ConstruccionValidator.ORDEN` son 8 reglas y ninguna es de altura), P21 (la
transparencia a la luz es de M48), P22 (0 checks de escalera: no hay suite), P23 (falta verificar el rango
de tamanos 1-4: el catalogo no esta en `data/construccion/piezas/`, la ruta que citan los tests), P27 (falta
la interaccion con M18), P15 (el validator es logico, no fisico) y los items de documentacion/UI.

## Archivos

- Modificado: `DOCUMENTACION/17-Construccion/plan-actual/{{05-Checklist.md, 04-Codigo.md}}`
- Creado: este log + el acuse 037 del canal
- Sin push ni commits.
