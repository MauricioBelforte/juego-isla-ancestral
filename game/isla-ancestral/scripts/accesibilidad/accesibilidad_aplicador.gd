# Modelo: deepseek-v4-flash-vision-exp
# Plataforma: Kilo Code
# Fecha: 2026-09-02
#
# M58: AccesibilidadAplicador — factor de escala de texto y contraste de la
# config de accesibilidad (data/accesibilidad/config.json). La aplicación
# real a la UI (M53) se hará en la iteración 3; este aplicador entrega los
# valores normalizados.

class_name AccesibilidadAplicador
extends RefCounted

const TAMANO_FACTOR := {
    "pequeno": 0.9, "medio": 1.0, "grande": 1.25
}
const CONTRASTE_FACTOR := {
    "alto": 1.0, "medio": 0.85, "bajo": 0.7
}

static func factor_texto(config: Dictionary) -> float:
    return float(TAMANO_FACTOR.get(String(config.get("tamano_texto", "medio")), 1.0))

static func factor_contraste(config: Dictionary) -> float:
    return float(CONTRASTE_FACTOR.get(String(config.get("contraste", "alto")), 1.0))

static func config_valida(config: Dictionary) -> bool:
    return AccesibilidadSchema.validar(config).is_empty()
