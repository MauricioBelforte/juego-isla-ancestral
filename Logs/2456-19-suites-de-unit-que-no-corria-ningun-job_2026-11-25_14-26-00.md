# Log 2456: 19 suites de tests/unit que no corría ningún job (y no estaban rojas)

**Fecha:** 2026-11-25
**Hora:** 14:26
**Modelo:** Deepseek V4.1 Flash-DeepAI
**Plataforma:** DeepAI

## Cómo apareció

En el Log 2451 audité 40 suites de `tests/` fuera de CI y **excluí `tests/unit/**`** con un
supuesto: "son GdUnit4, no se corren con `--script`". El supuesto era verdad a medias.

## Lo medido

```
archivos .gd bajo tests/unit .......... 23
  tipo GdUnit4 (extends GdUnitTestSuite) 4   <- los corre testing.yml por directorio
  tipo SceneTree ....................... 19   <- NO los corría ningún job
```

Y los 19 no estaban en `quality.yml` porque `quality.yml` corre `suite --script`, y el job
GdUnit4 de `testing.yml` hace `-a res://tests/unit/{foto,inventario,ui,debug}`: colecta solo
suites del addon. Una suite SceneTree dentro de esas carpetas cae en el hueco entre los dos
jobs: no la ve ninguno.

## Resultado de correrlas

```
19 suites | rojas: 0 | timeouts: 0   (timeout 150 s por suite)
```

No hay rojos escondidos: el problema es de **cobertura**, no de rotura. Entre hoy y el Log 2451
quedaron auditadas 59 suites de `tests/` que el CI no ejecuta, todas en verde.

## Herramienta

`tools/quality/auditar_cobertura_suites.py` ahora **clasifica por tipo** (lee la cabecera):

```
Suites en disco ......... 526  (scenetree 522 / gdunit4 4)
Suites en el workflow ... 104
Fuera del workflow ...... 426
  ejecutables con --script y sin correr: 422
Bajo tests/ específicamente: 61 (57 scenetree + 4 gdunit4), 57 sin ningún job
```

Las 422 incluyen ~190 probes sueltos bajo `scripts/` (diagnósticos de módulo, válidos como
herramienta, no como regresión). La cifra que importa para el gate es la de `tests/`.

## Decisión pendiente

Registrar en `quality.yml` las 57 suites SceneTree de `tests/` (o al menos las 19 de
`tests/unit` + 10 de `tests/integration`). Es gratis en riesgo —ya están verdes— y cuesta
tiempo de CI. No lo hago sin OK porque `quality.yml` tiene un diff ajeno sin commitear.