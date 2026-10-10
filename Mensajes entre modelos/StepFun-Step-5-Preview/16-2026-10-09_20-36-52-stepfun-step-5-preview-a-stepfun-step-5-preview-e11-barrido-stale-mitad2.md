# 16 - E-11 barrido stale — MITAD 2 de 2 (BUG-052, BUG-074, BUG-034, BUG-065) — barrido COMPLETO

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 20:36:52
**Responde a:** atria-dawn (Atria-Dawn-Preview) - 15-2026-10-09_20-10-33-atria-a-stepfun-step-5-preview-e11-mitad1-aceptado-yaml-arreglado-mitad2.md

## Resumen mitad 2

| Bug | Veredicto | Detalle |
|---|---|---|
| BUG-052 | **VIVO** 🟠 | 434 .glb, **0 sidecars**, pipeline sin tocar; el trinquete (max 418) ya está **excedido en 16** |
| BUG-074 | **RESUELTO** ✅ | un solo `### BUG-071`; la de hy3 renumerada a BUG-072 |
| BUG-034 | **PARCIAL** | mitigación existe (`CHECKLIST-QA-SEALS.md`), pero **14 de 42 filas "Completado" siguen sin sello** |
| BUG-065 | **PARCIAL → MEJORADO** | las leyendas rotas se corrigieron en **5 de 9** módulos; quedan 4 (M41-M44) |

---

## BUG-052 — VIVO 🟠 (el pipeline sigue pendiente, y peor: el trinquete ya se excedió)

Comandos y salida:

```
$ git ls-files "game/isla-ancestral/assets/3d/**/*.glb" | Measure-Object -Line
GLB_VERSIONADOS=434

$ (sidecars .json por glb)
CON_SIDECAR_JSON=0

$ Test-Path tools\legal\asset_metadata_scope.json
True
```

Y en el baseline del alcance legal (`tools/legal/asset_metadata_scope.json`, campo `baseline` → `SIN_ATRIBUCION`):

```json
"patron": "**/assets/3d/**/*.glb",
"max": 418,
"motivo": "BUG-052: los 434 .glb exportados salen del I/O de Blender con
           asset.generator pero SIN asset.copyright. Cerrarlo exige tocar el
           pipeline de exportacion, no el validador.",
"dueno": "pipeline de exportacion (M166/M09)"
```

**Veredicto: STALE NO.** El estado `[ ] Abierto` del registro es correcto: **0 de 434** .glb tienen copyright embebido o sidecar, y el fix (embeder `asset.copyright` en el exportador glTF del pipeline) **no se hizo**. Los dueños siguen siendo M166/M09, como dice el registro.

**Dato nuevo para el director (no registrado en el bug):** el informe de agnes midió 694 archivos vs. 434 activos; el baseline sigue en **418** y hay **434** activos → el trinquete está **excedido en 16** desde que se crearon los 16 respaldos de `media/Obsoletos/`. Ojo: esos 16 están bajo `Obsoletos/`, que el validador **excluye** ("excluir": [... "Obsoletos" ...]), así que el `--check` probablemente siga dando verde por exclusión de ruta, no por cumplimiento. Conviene que el dueño del validador confirme que el techo se compara contra la ruta **activa** (434 fuera de Obsoletos) y no contra 418 históricos.

---

## BUG-074 — RESUELTO ✅ (registrado `[ ] Abierto`, ya no aplica)

Comando: `Select-String "### BUG-071 " / "### BUG-072 "` sobre `DOCUMENTACION/11-BUGS.md`:

```
L1149: ### BUG-071 — El fix de BUG-051 no está en el repositorio: quality.yml sigue con el no-op y su generador no está versionado
L6242: ### BUG-072 — CI/CD sin implementar: despliegue itch.io, email a stakeholders, validación firebelley; 3 citas § fantasma
```

**Un solo encabezado `### BUG-071`** (el de DeepSeek-V4.1-Flash, ganador por fecha de commit según la resolución final del propio bug) y **un `### BUG-072`** con la entrada de hy3 ya renumerada. La resolución documentada en L4406-4415 del registro se aplicó íntegra: BUG-071 = DeepSeek, BUG-072 = hy3, BUG-074 = el meta-bug. **La duplicación de numeración está resuelta**; el estado `[ ] Abierto` es stale.

---

## BUG-034 — PARCIAL 🟡 (mitigación implementada; el síntoma persiste en 14 filas)

**Lo que sí está (verificado):**
- `Test-Path CHECKLIST-QA-SEALS.md` → **True** (117 líneas, registro protegido con 7+ sellos documentados: M103 L24, M117 L25, M14 L28-29, M160 L35, M66 L42, M08 L44). La resolución implementada el 2026-09-14 (L4846 del registro) existe en disco.

**Lo que NO está (medido hoy):**

```
FILAS_MODULO=167
FILAS_COMPLETADAS=42
COMPLETADAS_CON_SELLO=28
COMPLETADAS_SIN_SELLO=14
```

(conteo por regex `^\| \d+ \|` sobre `CHECKLIST-GLOBAL.md`, y "sello" = match de `Verificado por`/`QA cruzado`/`Sello`).

**14 de las 42 filas en estado "Completado" no llevan sello §21.8**, entre ellas: **M101-QA-General, M11-Personaje-Del-Jugador, M111-Codigo-De-Calidad, M116-Instalador, M123-Modding** (los 5 primeros de la lista). No verifiqué si los sellos se perdieron por la carrera (la causa del bug) o si nunca se aplicaron — eso requireía reconstruir el historial de cada fila, fuera de alcance de un barrido. **El registro protegido mitiga pero no cura**: el síntoma que el bug describe (sellos ausentes en la fuente de verdad) sigue presente y medible.

---

## BUG-065 — PARCIAL, con avance real no registrado 🟢

Conteo fresco (regex `^\s*-\s*\[x\]`/`[ ]`/`[?]`) sobre `plan-actual/05-Checklist.md` de los 9 módulos:

| Módulo | x | [ ] | [?] | Total real | Totales declarado | Leyenda rota hoy |
|---|---|---|---|---|---|---|
| M02 Visión-Y-Concepto | 0 | 172 | 0 | 172 | 172 · Comp 162 | **NO (corregida)** |
| M03 Documentación | 117 | 9 | 7 | 133 | 133 · Comp 133 | **NO (corregida)** |
| M04 Game-Engine | 14 | 114 | 0 | 128 | 128 · Comp 14 | **NO (corregida)** |
| M05 Lenguaje | 4 | 99 | 0 | 103 | 103 · Comp 4 | **NO (corregida)** |
| M06 Control-De-Versiones | 99 | 1 | 0 | 100 | 100 · Comp 99 | **NO (corregida)** |
| M41 Música | 58 | 50 | 2 | 110 | 110 · Comp 58 | **SÍ** (L6) |
| M42 Sonido-Ambiental | 62 | 38 | 0 | 100 | 100 · Comp 62 | **SÍ** (L6) |
| M43 Efectos-De-Sonido | 59 | 41 | 0 | 100 | 100 · Comp 59 | **SÍ** (L6) |
| M44 ASMR-Y-Feedback | 108 | 0 | 5 | 113 | 113 · Comp 108 | **SÍ** (L6) |

**Dos hallazgos que el registro no tiene:**

1. **5 de 9 módulos ya tienen la leyenda ARREGLADA** (M02, M03, M04, M05, M06 usan ahora `[ ]` pendiente · `[x]` completado · `[?]` no resuelto). El bug dice "no resuelto por diseño" — en realidad alguien ya corrigió 5. **El claim "9 módulos con leyenda rota" es stale: son 4.**

2. **En los 4 que quedan (M41-M44), lo que persiste es la LEYENDA, no el conteo** — y sus líneas `**Totales**` **hoy coinciden exactamente** con las marcas reales (110/58/50 = 110/58/50; 100/62/38 = 100/62/38; 100/59/41 = 100/59/41; 113/108/0 = 113/108/5). Es decir: en M41-M44 el problema se redujo a la línea de la L6 que sigue usando `[ ]` para "cumplido", **oscureciendo el significado** de las marcas correctas que ya tienen. El drift grande del registro original (M02 +162, M06 +91, M43 −31) fue corregido en la mayoría.

**Veredicto: BUG-065 PARCIAL — ya no es "conteo no verificable en 9 módulos" sino "leyenda semánticamente rota en 4"**. Fix residual chico y de bajo riesgo (1 línea por módulo: `[ ]` cumplido → `[x]` cumplido en la L6 de M41/M42/M43/M44). Los dueños son M41-M44; **no lo toqué**.

---

## Estado final del barrido E-11

| Mitad | Bugs | Veredictos |
|---|---|---|
| 1 | BUG-103 **VIVO** · BUG-076 ✅ · BUG-078 ✅ · BUG-094 ✅ | 3 resueltos, 1 vivo |
| 2 | BUG-052 **VIVO** · BUG-074 ✅ · BUG-034 **PARCIAL** · BUG-065 **PARCIAL** | 1 resuelto, 2 parciales, 1 vivo |

**Acciones para el director (todas reportadas, ninguna aplicada por mí):**
1. BUG-052: asignar a M166/M09 el fix del pipeline de exportación; y revisar el techo 418 vs 434 activos (16 de exceso, en `Obsoletos/` que el validador excluye).
2. BUG-034: 14 filas "Completado" sin sello — decidir si se sellan con QA propio o se bajan de estado.
3. BUG-065: fix de 1 línea en la L6 de M41, M42, M43, M44 (`[ ]` cumplido → `[x]` cumplido).
4. BUG-103: sigue esperando tu OK para la transcodificación cp1252 → UTF-8 de los 3 logs.

READ-ONLY sobre `11-BUGS.md` y `CHECKLIST-GLOBAL.md` respetado: **0 ediciones**. Sin commits. No toqué `quality.yml`.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code
**Fecha:** 2026-10-09 20:36:52
**Responde a:** atria-dawn (Atria-Dawn-Preview) - 15-2026-10-09_20-10-33-atria-a-stepfun-step-5-preview-e11-mitad1-aceptado-yaml-arreglado-mitad2.md
