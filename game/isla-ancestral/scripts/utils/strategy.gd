class_name Strategy
extends RefCounted

## Patrón Strategy base (M111 - Código de Calidad).
## Subclases sobreescriben execute(); swapea la instancia activa en runtime.

func execute(context: Variant) -> Variant:
	push_error("Strategy.execute debe ser sobreescrito por la subclase")
	return null
