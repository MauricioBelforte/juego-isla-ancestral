# Log 2464: un format string roto dejaba un check ciego y en verde

**Fecha:** 2026-11-25
**Hora:** 16:12
**Modelo:** Deepseek V4.1 Flash-DeepAI
**Plataforma:** DeepAI

## Cómo apareció

Corrí el gate completo (107 suites del workflow) para verificar los commits de la flota:
**107/107 verdes, 0 timeouts**. Pero al revisar qué suites no imprimían línea de `Resumen`
(mi criterio era demasiado literal: 24 la llaman `=== TEST M63 STREAM: ...`), encontré en su
salida un error que el gate nunca vio:

```
ERROR: String formatting error: unsupported format character.
   at: validated_evaluate (core/variant/variant_op.h:829)
   [0] _test_progreso_piso_tope (res://scripts/stream/test_stream.gd:81)
```

## El defecto

```gdscript
_check(p0 >= 0.02, "piso 2% al iniciar cola (%.2f)" % p0)   # linea 81
_check(p1 <= 0.98 + 0.02, "tope 98% respetado ... (%.2f)" % p1)  # linea 94
```

El `% ` de `2% al` se parsea como inicio de especificador (`%` + bandera espacio) y la `a` no
es una conversión válida. Godot imprime el ERROR y deja la cadena **vacía**; la expresión sigue
y el check se evalúa igual. Consecuencias:

1. **Ruido permanente**: 2 ERROR por corrida desde la versión inicial de la suite.
2. **Peor: el check queda ciego**. Si `p0 < 0.02`, el mensaje de diagnóstico sale vacío. El
   assert sigue vivo, pero cuando falla no dice nada.

Se veía como verde porque `suite()` en `quality.yml` solo mira el exit code, y Godot sale 0 con
un ERROR de formateo (no es `SCRIPT ERROR`).

## Arreglo

`%%` (el escape correcto) en las dos líneas. Verificado:

```
test_stream.gd  EXIT=0  "STRING FORMATTING ERROR"=0  "SCRIPT ERROR"=0
                "=== TEST M63 STREAM: 21 checks, 0 fallo(s) ==="
```

## Herramienta nueva

`tools/quality/detectar_format_invalido.py` — escanea los 1378 `.gd` (sin `addons/`) y valida
los especificadores **solo en literales que son operando de `%`** (un `%` suelto en un `print`
no es bug). Sintaxis: `%[flags][ancho][.precision]<conv>`, conversiones `s d f x X o c v e E %`.

```
fixture con 3 casos malos + 3 buenos -> 3 hallazgos (los 3 malos, ninguno bueno)
arbol real (tras el arreglo)          -> 0 hallazgos, EXIT=0
```

Falso positivo corregido en el camino: el primer detector exigía que el argumento empezara con
`[`, letra o `(`, y se le escapaban justamente los dos casos reales (argumento `0.5`). Ahora
cualquier `%` seguido de algo es operador de formateo.

Los otros 6 candidatos que marcó el escáner eran `%` literales en mensajes sin formatear
(`"escala mínima 50 % y máxima 150 %"`, `"[QA-TRAVEL] OK barra y % a 50"`, etc.): **no son
bugs**, y el detector final ya no los marca.

## Archivos

- Modificado: `game/isla-ancestral/scripts/stream/test_stream.gd` (líneas 81 y 94: `%` -> `%%`).
- Nuevo: `tools/quality/detectar_format_invalido.py`.