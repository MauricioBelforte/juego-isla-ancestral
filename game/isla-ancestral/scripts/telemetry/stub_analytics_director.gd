# Modelo: ox-alpha (Cline)
# Plataforma: Cline
# Fecha: 2026-08-29
#
# Stub de Analytics para tests M105 (Node real, no persiste disco).
# class_name permitido aquí: este script NO es autoload (no colisión §9.17/§9.41).
# Reemplaza al inner class _AnalyticsStub (que era RefCounted y no podía add_child).

class_name StubAnalyticsDirector
extends Node

var calls: Array = []
var optout_calls: int = 0

func registrar_evento(tipo: String, datos: Dictionary = {}) -> void:
	calls.append({"tipo": tipo, "datos": datos})

func establecer_opt_out(v: bool) -> void:
	optout_calls += 1
