**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code
**Fecha:** 2026-10-05 05:35:00
**Responde a:** `34-2026-10-05_04-54-00-voxel-linter-0-gate-m151-m112.md` (mi informe anterior)

# Actualizacion: gate M151 verificado en CI + M87 resuelto (M112: 15 -> 12)

## 1. Gate M151 verificado en CI de verdad — funciona

El run `37281229611` (commit 40615d2) dejo el job **Release Gate (M151): success**.
Detalle del log:

- El regenerador leyo `11-BUGS.md`: **criticos abiertos n=2 (BUG-078, BUG-091)**.
- Bloqueantes detectados: `suite_tests_verde` (M112 fallo) + `zero_criticos_abiertos`.
- Pendientes **no bloqueantes**: `smoke_aprobado`, `crash_rate_cero`,
  `textos_localizados`, `backup_configurado`.
- Gate Godot imprimio `CONTROL FINAL: BLOQUEADO` y el job emitio `::warning::` +
  **exit 0** — exactamente la decision (a): acta informativa, no bloquea quality.
- Subio el artifact `estado-release-m151.zip` (608 bytes).

Los dos gates rotos que detecto son **reales** (la suite fallo y hay 2 criticos
abiertos). El gate hizo justo lo que tiene que hacer.

## 2. M87 resuelto: 3 fallos -> 0 (commit 7ace860)

Los 3 fallos de M87 no eran un solo problema, eran **tres causas distintas**:

1. **`SETTINGS.AUDIO_TITULO` sin traducir en EN.** El catalogo `strings_en.json` no
   tenia la clave, y `en.po` tenia `msgstr "Audio"` — identico al `es.po`, asi que
   el validador P5 lo marco como "no traducido". Corregido a `"Audio settings"` en
   ambos.
2. **`DIARY.BLOQUEADO` "sin traducir" siendo intencional.** Su valor es `???`
   (secreto del lore, §3.2) en **todos** los idiomas — el validador no puede
   distinguirlo de un hueco. Declare la exencion con `MARCADOR_NO_TRADUCIBLE`
   (`#. no-traducir: secreto del lore §3.2...`) en `es.po` y `en.po`: es el
   mecanismo preferido (Poedit lo muestra al traductor; no toca codigo).
3. **Test A7 obsoleto (bug 100 oculto).** El test afirmaba que
   `Nunito-Regular.ttf` mide 0 px "porque es una pagina HTML 404 (BUG-042)". Pero
   **BUG-042 ya esta resuelto desde el 2026-09-19 (Log 1024)**: la fuente ahora es
   un TTF valido (129 KB, magic `00 01 00 00`, tablas GDEF/GPOS/GSUB). El test
   fallaba **porque el bug se arreglo y nadie actualizo la asercion**. Cambie A7 a
   la verificacion positiva: `mide de verdad (38.0 px)`.

Ademas: añadi ambas claves a `strings_{es,en,pt}.json` y corregi un typo
preexistente en `strings_pt.json` (`eventos.historia_c2.nome` con punto; debia ser
`_nome` para coincidir con es/en).

Verificacion local: base 20/0, ITER5 0/0, iter6 **82/0**, iter4 0/0.

## 3. M112: 26 -> 12 fallos

| Modulo | Antes | Ahora |
|---|---|---|
| M11 Player | 11 | **0** (voxel, Log 1312) |
| M87 | 3 | **0** (este commit) |
| M60 | 8 -> 6 | 6 (snapshot de estructuras, real) |
| M83 Scanner | 3 | 3 (gdUnit4, **espera tu decision**) |
| M103 | 1 | 1 (timing CI: eco 59.7% vs 80%) |
| M62 liberacion | 1 | 1 (timing CI: pico 3.612 ms vs 3.00 ms) |
| M106-env | 1 | 1 (`.env.local` no existe en CI; el test deberia skip) |

De los 12 restantes: **6 son M60** (un test de snapshot/save de estructuras que
serializa un stub vacio; requiere meterse en el modulo), **3 esperan tu decision**
sobre gdUnit4, y **3 son de entorno CI** (2 timing + 1 archivo de config local que
no se puede versionar).

## 4. Trampa T-10: la cometi 2 veces mas

Mi canal 31 tenia `U+00C2 U+00A7` y mi canal 34 tambien — en ambos casos escribi la
**notacion correcta Y el literal corrupto entre parentesis "como ejemplo"**. El
literal es el que dispara el gate. Documente el refuerzo v2 en
`GUIA-COMUNICACION.md`: la notacion `U+XXXX` es lo unico que se escribe, nunca se
añade el literal "para ilustrar"; si hace falta mostrar la secuencia, usar bytes
hex (`C2 A7`, ASCII puro). Commit 94ab0b0.

## 5. Pendiente de verificar

- **GDScript Formatting Check**: es el job mas lento (10+ min) y llego "cancelled"
  en el ultimo run porque llego un commit nuevo. Todavia no vi uno completo despues
  del voxel. Si falla por timeout, es otro frente.
- La decision sobre **gdUnit4** (1.1 MB, 516 archivos) para M83.

## Huellas de push

`c2616da` (mojibake canal 31), `5d0ffd5` (if: always), `df7efe7` (canal 34),
`40615d2` (fix canal 34), `94ab0b0` (T-10 refuerzo), `c56bdb7` (doc M151),
`7ace860` (M87). Todos con `git add --` explicito y `git diff --cached --name-only`
verificado antes de cada commit.
