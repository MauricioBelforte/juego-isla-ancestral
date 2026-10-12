# Log 1690: BUG-098 — 2 archivos propios con parseo roto, corregidos

**Fecha:** 2026-10-12
**Hora:** 18:35
**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code

## Resumen

Encargo del director (msg 205): BUG-098, 44 SCRIPT ERROR residuales. Mi contribución
al bug fueron **2 archivos nuevos** con la cabecera mal ordenada. Corregidos.

## Causa raíz

Al crear los archivos puse el `class_name` **dentro del cuerpo** y, además, dejé
`const` y el docstring **antes** del `extends`. El parser entraba en "class body" y
rechazaba el `class_name`:

```
SCRIPT ERROR: Parse Error: Unexpected "class_name" in class body.
```

El orden válido es: `class_name` → `extends` → docstring → `const` → `func`.

## Archivos corregidos

| Archivo | Error | Fix |
|---|---|---|
| `scripts/analytics/telemetria_m104.gd` | class_name en L19 del cuerpo | cabecera reconstruida |
| `scripts/analytics/pausa_contemplativa.gd` | idem | idem |

## Verificación

```
--check-only telemetria_m104.gd     -> 0 errores (antes 2)
--check-only pausa_contemplativa.gd -> 0 errores (antes 2)

barrido de parseo completo: 0 ROTOS de 1049 archivos .gd de runtime
barrido de class_name ilegal:    5 hallazgos, todos falsos positivos
                                 (`@tool` antes de class_name SÍ es válido)
                                 verificados uno por uno: 0 roto

suites de consumo:
  test_m18_casas.gd               0 fallos
  test_transporte_m68_iter2.gd    0 fallos
```

Los 9 archivos que el director listó como afectados por BUG-098 ya compilan: otros
agentes los corrigieron antes.

## Dato para el barrido futuro

El orden `extends` → `class_name` es **válido** en GDScript (11 archivos del repo lo
usan). Lo inválido es cualquier declaración de miembro antes del `class_name`. Un
detector que marque "class_name después de extends" da 66 falsos positivos; el
correcto debe ignorar `extends`, comentarios y anotaciones (`@tool`).
