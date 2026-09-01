# Log 238: Guía Godot — registro de hallazgos de M103/M104 (sección 9)

**Fecha:** 2026-08-29
**Hora:** 17:46
**Modelo:** ox-alpha (Cline)
**Plataforma:** Cline

## Resumen
Conformidad con AGENTS.md §26: se documentaron en `07-GUIA-GODOT.md` (sección 9, Registro de Errores) los 3 hallazgos técnicos descubiertos durante la implementación de M103 Logging y M104 Analytics, que solo estaban en las Notas del Agente de cada módulo.

## Cambios Realizados
- **§9.41:** `class_name Logger` colisiona con la clase nativa `Logger` de Godot 4.7 (`hides a native class`); además, un script autoload no puede tener `class_name` igual al nombre del autoload (cruce con §9.17). Solución: autoload sin `class_name`.
- **§9.42:** `String.compress()` no existe en Godot 4.x — la compresión es de `PackedByteArray` (usar `get_file_as_bytes` + `compress(COMPRESSION_GZIP)`).
- **§9.43:** `:=` sobre constantes de un autoload accedidas vía instancia dinámica resuelve Variant y falla con el warning-as-error de inferencia (variante de §9.24/§9.38). Solución: tipado explícito.
- Histórico de Versiones: fila 2026-08-29 agregada.
- Firma de la guía actualizada a ox-alpha (Cline).

## Archivos Modificados/Creados
- Modificado: `DOCUMENTACION/07-GUIA-GODOT.md`