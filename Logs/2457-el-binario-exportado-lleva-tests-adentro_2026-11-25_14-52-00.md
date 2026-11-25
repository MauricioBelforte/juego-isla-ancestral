# Log 2457: el binario exportado lleva el addon de tests y las suites adentro

**Fecha:** 2026-11-25
**Hora:** 14:52
**Modelo:** Deepseek V4.1 Flash-DeepAI
**Plataforma:** DeepAI

## Punto de partida

El job `build` de `dev-build.yml` exporta con el preset `Windows`
(`godot --headless --path . --export-release "Windows" build/dev/IslaAncestral.exe`). Nunca se
había medido **qué** entra al paquete. Con templates 4.7.2 instalados, se puede medir en local.

## Medición (export real, no estimación)

```
godot --headless --path . --export-release "Windows" <tmp>/IslaAncestral.exe
EXIT=0 en 24.7 s  ->  124.5 MB
  referencias a 'gdUnit4' en el binario .... 1234
  referencias a 'tests/test_' .............. 146
  referencias a 'GdUnitTestSuite' .......... 70
```

Causa: los 4 presets usan `export_filter="all_resources"` y
`exclude_filter="Godot/*"` — nada más. Entran `addons/gdUnit4/**`, `tests/**` y las ~190 suites
probe de `scripts/**`.

## Prueba del filtro (revertida, no aplicada)

Cambié los 4 presets a `exclude_filter="Godot/*,addons/gdUnit4/*,tests/*"` y re-exporté:

```
EXIT=0 en 9.7 s  ->  123.2 MB
  'gdUnit4' ......... 1234 -> 6
  'tests/test_' .....  146 -> 2
  'GdUnitTestSuite' ..  70 -> 0
```

Funciona, pero **no lo dejé aplicado** por dos razones concretas:

1. El ahorro es de 1.3 MB sobre 124.5: el peso no es el addon, es el resto del proyecto.
2. `scenes/test_runner.tscn` referencia `res://tests/run_tests.gd`. Excluir `tests/*` deja una
   escena del proyecto apuntando a un script que no viaja: el export pasa, el error aparece recién
   si algo instancia esa escena. Arreglarlo bien es **partir el preset** (Dev con todo, Release sin
   tests) o excluir también esa escena — decisión de release, no mía.

`export_presets.cfg` quedó **byte-idéntico** al estado previo (verificado con `git status`: sin
diff) y los paquetes de prueba se borraron.

## Lo que sí queda como dato

- El export de Windows **funciona hoy** y en 25 s: el job de build no está roto por presets.
- El binario distribuye el framework de tests y 146 suites. No rompe nada; es higiene de release
  (tamaño, superficie y ruido de strings).
- Si el fundador quiere un `Release` limpio, el trabajo es un preset nuevo + correr este mismo
  escaneo como verificación. Ya está el procedimiento medido.

## Archivos

Ninguno del repo modificado (solo temporales, todos borrados).