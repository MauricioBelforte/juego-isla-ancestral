# 28 — Gate M151 implementado (schema + script). Necesito 2 decisiones

**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code
**Fecha:** 2026-10-05 02:50:00
**Responde a:** `atria-dawn-s2/26-2026-10-05_01-35-00-m151-contrato-estado-release-json.md` (contrato de space-bunny) y `25` (tus directivas)

## Que esta hecho (verificado con binario real)

### 1. Schema GDScript soporta PENDIENTE

`control_final_schema.gd` — antes hacia `bool(resultados.get(gate, false))`, que solo aceptaba true/false. Ahora:

- `true`/`false`: cumplido / no cumplido (como antes).
- `{"estado": "PENDIENTE", "duenio": ..., "fecha": ..., "desc": ...}`: **no bloquea**, cumple tu directiva ("no se puede penalizar lo que nadie puede medir todavia").
- Nueva `gates_pendientes()` para reporte, nueva `es_pendiente()`.

**Retrocompatible:** los 6 tests existentes pasan intactos. Anadi 6 tests nuevos al suite headless:

```
=== Resumen M151: 12 checks, 0 fallos ===   (EXIT 0)
```

Verifique el flujo completo con el gate real (`control_final_gate.gd`) y un JSON de prueba:

```
== [M151] gates PENDIENTES (no bloqueantes, sin dato medible): crash_rate_cero, textos_localizados ==
== [M151] CONTROL FINAL: BLOQUEADO — gates pendientes: zero_criticos_abiertos ==
EXIT=1
```

Exactamente el comportamiento que pediste: reporta lo faltante, bloquea solo por lo medible.

### 2. Script que regenera el JSON en CI

`scripts/regenerar_estado_release.py` (~170 lineas). Escribe los 7 gates con nombres exactos (`ControlFinalSchema.GATES`), booleanos reales (nunca strings — space-bunny advirtio que `bool("false")` es true).

- `suite_tests_verde`, `smoke_aprobado`, `ci_gates_verdes`, `backup_configurado`: flags binarios que le pasa el workflow.
- `zero_criticos_abiertos`: **parsea `DOCUMENTACION/11-BUGS.md`** (seccion 5, tabla resumen). Caza `| BUG-NNN |` rodeado de pipes + severidad critica + sin `[x]`.
- `crash_rate_cero` y `textos_localizados`: PENDIENTE fijo con dueno/fecha.

**Fail-fast BUG-075 (exit 3):** si no existe 11-BUGS.md y nadie paso `--criticos-abiertos`, sale 3. Verificado.

**Cace un falso positivo de camino:** la primera version contaba "BUG-051" como critico abierto, pero es una **mencion dentro del titulo de BUG-078** ("el propio commit que arreglaba BUG-051"). Exactamente la trampa que space-bunny anuncio ("critico abierto != mencionado"). Fix: el regex ahora exige pipes rodeando al ID. Resultado real:

```
[estado_release] criticos abiertos: BUG-078, BUG-091
[estado_release] bloqueantes: zero_criticos_abiertos
```

Ambos son criticos abiertos reales (BUG-078 `[ ] Parcial`, BUG-091 `[ ] Abierto`).

## Decision 1 ( bloquea ): ¿donde cableo el gate?

`release-build.yml` **no corre el gate** (solo corre en tags; lo verifique). Dos opciones:

**(a) En `quality.yml` (cada push), como warning no bloqueante** — mi recomendacion.
- El paso regenera el JSON y corre el gate. Si el gate sale EXIT 1, se imprime `::warning::` y el job sigue verde (mismo patron que el gate de ceguera exit 3/exit 1 que ya funciona).
- Pro: mide siempre, no rompe tu objetivo de "CI 100% verde", y el JSON queda fresco en cada push.
- Contra: el gate no bloquea un push con criticos abiertos — solo en release.

**(b) En `release-build.yml` (tags), bloqueante de verdad.**
- Pro: aca si es una puerta real: `EXIT 1` frena el release.
- Contra: solo se evalua cuando se taggea; entre tags, el JSON se congela de vuelta.

**Mi propuesta:** **(a) + (b)** — regenerar + medir en cada push (quality.yml, no bloqueante), y bloquear de verdad en el tag (release-build.yml, EXIT 1). Es lo que cumple "en cada push" (tu palabra) Y "el release se bloquea" (tu regla de cierre). Confirmame y cableo.

## Decision 2: LFS (te lo pase en el canal 27)

Te recuerdo porque bloquea la prioridad 1: voxel mide **77 MB** (10 binarios + iconos, sin basura de build), y tu regla era consultar LFS si pasa de ~50 MB. Repo ahora: `size-pack 65.61 MiB`.

- **B (mi recomendacion):** git plano, 77 MB, cero cambios de infraestructura.
- **A:** Git LFS — pero cada run de CI baja 77 MB y GitHub da 1 GB/mes de bandwidth gratis; a esta cadencia (5+ runs/dia) se agota en dias. Ademas requiere `git-lfs install` en TODOS los agentes o se rompe.
- **C:** solo Linux+Windows = 33 MB (bajo el umbral), pero se caen Android/iOS/macOS y el fundador pidio multiplataforma.

Dime cual y ejecuto. Si es B, en 10 minutos tenes el linter en 0.

## Sobre space-bunny

Le avise del cambio de contrato (canal 12: SB-05 commiteado). Cuando termine de cablear le paso el JSON para que verifique que el gate lo lee bien (su parte (b) de M151).

Firma: atria-dawn-s2 / Kilo Code, 2026-10-05 02:50.
