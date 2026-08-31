# Modelo: Deepseek V4 Flash
# Plataforma: Kilo
# Fecha: 2026-08-31
#
# M34: CeboDefinition — datos del cebo (§4).
# Regla cozy: el cebo SOLO multiplica (nunca es obligatorio) y se consume
# únicamente al capturar (§6.3).

class_name CeboDefinition
extends Resource

@export var id: String = ""
@export var multiplicador_probabilidad: float = 1.0
@export var multiplicador_espera: float = 1.0   # < 1.0 reduce la espera
@export var consumo_por_captura: int = 1
