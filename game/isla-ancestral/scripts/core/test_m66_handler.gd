# M66 (test helper, agnes-3-flash 2026-10-08): handler IRecoverable de REGISTRO.
# Sirve para que el test del disparo de SoftlockGuard verifique en forma CONCRETA
# (no tautológica) que el disparo recorre la cascada de recovery y consulta al handler.
# Reemplaza el antiguo set_script(irecoverable.gd) sobre un Node (RefCounted inválido en Node).
class_name M66HandlerRegistro
extends IRecoverable

## Cuántas veces el guard consultó recuperar().
var recuperar_llamadas := 0

## El guard solo llama recuperar() si es_valido() == false.
func es_valido() -> bool:
	return false

## Registra la consulta y devuelve true (recuperación "exitosa") para cerrar la cascada.
func recuperar() -> bool:
	recuperar_llamadas += 1
	return true
