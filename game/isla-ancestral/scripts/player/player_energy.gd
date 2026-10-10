class_name PlayerEnergy
extends RefCounted

## M11 - Energia / stamina del Personaje del Jugador (MODELO PURO, cozy).
##
## Implementa `01-Requerimientos.md` seccion 6.1 (documento de requisitos del
## fundador), que gana sobre `03-Diseno.md` seccion 1 por decision del director
## (mensaje 135, 2026-10-10):
##   - Costo correr ......... 1/minuto  (L63)
##   - Regeneracion ......... 1/minuto, SIEMPRE, incluso en movimiento (L66)
##   - Regeneracion dormir .. 100% completo (L67)
##   - Regeneracion descanso  +30% (L68)
##   - Aviso de fatiga ...... 30% (03-Diseno seccion 8; informativo, no bloqueante)
##
## REGLA COZY (L70, directiva del usuario): "La energia NUNCA llega a cero por
## caminar o correr." Con regen 1/min aplicada SIEMPRE y costo de correr 1/min,
## correr tiene balance NETO 0/min: la energia no puede bajar por correr ni
## caminar -> la regla se cumple ESTRUCTURALMENTE, no por un clamp cosmetico.
## La energia solo baja por uso intensivo de herramientas (2-8 por uso, M13),
## que NO es responsabilidad de este modelo.
##
## RESUELTO (antes divergencia D1): `03-Diseno.md:18` decia 12/s drain y 8/s
## regen, que contradecia L70 (100/12 = 8,3 s corriendo para agotar). El
## director resolvio: gana 1/minuto. `03-Diseno.md` queda como deuda documental
## del dueno del diseno (no la corrige este agente).
##
## Alcance: modelo puro + contrato. No esta cableado a `player.gd` (ver
## 04-Codigo.md seccion 9). Consumidores previstos: HUD de stamina (M53).

const ENERGIA_MAX := 100.0
const SEGUNDOS_POR_MINUTO := 60.0

## Costo de correr por minuto (01-Requerimientos L63: "1/minuto, suave").
const COSTO_CORRER_POR_MINUTO := 1.0
## Regeneracion por minuto (01-Requerimientos L66: "1/minuto, siempre, incluso
## en movimiento"). Se aplica SIEMPRE, tambien mientras se corre: por eso correr
## tiene balance neto 0/min y no puede agotar (regla cozy L70).
const REGEN_POR_MINUTO := 1.0

## Umbral de fatiga (informativo): aviso suave al 30% (03-Diseno seccion 8).
const UMBRAL_FATIGA := 30.0

var _energia: float = ENERGIA_MAX
var _descansando: bool = false
var _fatiga_avisada: bool = false

func energia() -> float:
	return _energia

func fraccion() -> float:
	return _energia / ENERGIA_MAX

func agotada() -> bool:
	return _energia <= 0.0

## True mientras el aviso de fatiga (<=30%) esta activo. Informativo.
func en_fatiga() -> bool:
	return _energia <= UMBRAL_FATIGA

func descansando() -> bool:
	return _descansando

## Regeneracion efectiva por segundo (1/min -> 1/60 por s). Expuesta para el
## contrato HUD/telemetria y para que la suite afirme la conversion.
func regen_por_segundo() -> float:
	return REGEN_POR_MINUTO / SEGUNDOS_POR_MINUTO

## Costo de correr efectivo por segundo (1/min -> 1/60 por s).
func costo_correr_por_segundo() -> float:
	return COSTO_CORRER_POR_MINUTO / SEGUNDOS_POR_MINUTO

## Un tic del modelo. `corriendo` es el input; el modelo decide si puede correr.
## `en_movimiento` se conserva por contrato (el HUD lo provee) pero con la tabla
## de 01-Requerimientos la regen es la MISMA parado o caminando (1/min siempre).
## Devuelve true si el personaje PUEDE correr en el tic siguiente.
func actualizar(delta: float, corriendo: bool, en_movimiento: bool) -> bool:
	if delta <= 0.0:
		return puede_correr()

	# Regeneracion SIEMPRE (L66), tambien corriendo.
	var regen := regen_por_segundo() * delta
	var costo := 0.0
	if corriendo and puede_correr():
		costo = costo_correr_por_segundo() * delta
		_descansando = false

	_energia = clampf(_energia + regen - costo, 0.0, ENERGIA_MAX)

	# Cozy: solo se llega a 0 por desgaste externo (herramientas). Si pasa, el
	# personaje se sienta a descansar; no hay muerte ni bloqueo permanente.
	if _energia <= 0.0:
		_descansando = true
	elif _descansando and _energia >= UMBRAL_FATIGA:
		_descansando = false

	_fatiga_avisada = en_fatiga()
	return puede_correr()

## Solo se puede correr si queda energia Y el personaje no esta en descanso.
## Caminar siempre esta permitido (cozy: el sprint es el unico regulado, y con
## la tabla 1/min correr no puede agotar la energia por si solo).
func puede_correr() -> bool:
	return _energia > 0.0 and not _descansando

## Dormir recarga al 100% (01-Requerimientos L67: regeneracion dormir completo).
func recargar_dormir() -> void:
	_energia = ENERGIA_MAX
	_descansando = false

## Descanso (silla/banco): +30% de la energia maxima (01-Requerimientos L68).
func recargar_descanso() -> void:
	_energia = minf(_energia + ENERGIA_MAX * 0.30, ENERGIA_MAX)
	if _energia >= UMBRAL_FATIGA:
		_descansando = false

## Restaura un valor persistido, clampeado al rango valido.
func restaurar(valor: float) -> void:
	_energia = clampf(valor, 0.0, ENERGIA_MAX)
	_descansando = _energia <= 0.0

## No hay deuda permanente: la energia es un valor absoluto, sin penalizacion
## acumulada. Se expone para que la suite lo afirme explicitamente.
func sin_deuda_permanente() -> bool:
	return _energia >= 0.0 and _energia <= ENERGIA_MAX
