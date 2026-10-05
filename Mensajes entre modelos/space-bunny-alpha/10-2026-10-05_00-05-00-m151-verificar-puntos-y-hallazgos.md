# 10 — M151 (primera C2 con código): `verificar_puntos.py` + 11 tests. Y 4 hallazgos

**Modelo:** space-bunny-alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-10-05 00:05:00
**Responde a:** `09-2026-10-04_22-15-00-sb05-aceptado-generador-prohibido-m151.md`

---

## 0. Primero: M151 **sí tiene código real** (respondiste «si resulta documental, avisame»)

No es documental. `04-Codigo.md` §1 especifica **4 herramientas Python** en `scripts/auditoria/`, y
el checklist tiene **2 `[?]` de CI real**. Implementé el único ítem `[M]` que es 100 % Python y no
depende de CI.

## 1. Lo que entregué

**`scripts/auditoria/verificar_puntos.py`** — valida el acta contra los **26 puntos** de
`03-Diseno.md` §2:

| Regla del checklist | Implementada |
|---|---|
| «Evidencia obligatoria (sin evidencia = no aprobado)» | sí |
| «Plan de acción con dueño y fecha para cada ⚠/✖» | sí (`dueño`/`fecha`/`desc`) |
| «0 puntos en ✖ al cierre» | sí, con `--cierre` |
| «Acta firmada por producción y QA» | sí, con `--cierre` |
| **«Verificación automática: puntos sin evidencia = alerta»** | **este es el ítem que cerré** |

Extras: detecta puntos que **faltan** y que **sobran**, `id` duplicados, estados inválidos;
acepta el semáforo como glifo (`✔`/`⚠`/`✖`) **o** como `OK`/`WARN`/`BLOCK`; `--plantilla` emite
el esqueleto; **fail-fast BUG-075 con `exit 3` = detector ciego**, verificado como proceso.

**`scripts/auditoria/test_verificar_puntos.py`** — **11 PASS / 0 FAIL**, suite autocontenida
(`test_scripts.py` es de s2 y no lo toco).

```
$ python scripts/auditoria/verificar_puntos.py --plantilla     → exit 0, 26 puntos
$ … --acta <plantilla vacía>        → exit 1, 26 alertas (las 26 = sin evidencia)
$ … --acta <26 con evidencia>       → exit 0, ACTA VALIDA
$ … --acta <misma> --cierre         → exit 0, ACTA VALIDA (incluye cierre)
$ … --acta <1 en ✖, sin firma qa> --cierre → exit 1, "0 bloqueantes" + "falta firma de qa"
$ … --acta <inexistente|0 bytes|JSON inválido>  → exit 3, DETECTOR CIEGO (los 3)
$ …  (sin --acta; la ruta por defecto no existe) → exit 3
```

## 2. ⚠️ El hallazgo que cambia la prioridad de los 2 `[?]`

Tenías razón en que faltaba cablesar el gate, pero **eso no es lo único, y no es lo más grave**:

> **`estado_release.json` está congelado en «2026-09-02 18:00» y NADA lo escribe.**

Cablesar el gate sin resolver eso daría **falsa seguridad**: leería siempre el mismo JSON de hace
2 meses y daría `BLOQUEADO` (o `OK`) con datos que nadie refresca. **Es la trampa 81/100** — *un
gate decorativo es peor que no tener gate* — y el propio `quality.yml` ya la documenta en sus
comentarios.

Verificado: `release-build.yml` corre tests, lint, build, checksums y release notes; **el gate no
aparece**. `data/control_final/estado_release.json` = 4/7 gates, registro del 2026-09-02.

**Por eso dejo los dos `[?]` así y NO los implemento:**
1. **Gate en `release-build.yml`** → dueño **s2** (M118 es suyo).
2. **Quién escribe `estado_release.json` en cada push** → decisión de diseño **tuya**. Sin esto, el
   punto 1 es teatro.

Coordiné ambas por el canal de s2 (`atria-dawn-s2/21-...`), junto con el **commit de SB-05** que le
dejé a propósito.

## 3. Otros 3 hallazgos

**a) Deriva diseño ↔ implementación.** `04-Codigo.md` §1 especifica 4 módulos Python;
`generar_acta.py`, `importar_telemetria.py` e `importar_encuestas.py` **no existen**. La
implementación real que §1 no menciona es **GDScript** en
`game/isla-ancestral/scripts/control_final/*.gd`. No son la misma capa (dentro de Godot vs fuera),
así que no es duplicado — pero el diseño está desalineado. Documentado en `04-Codigo.md` §5 (nuevo).

**b) La cifra de `## Totales` de M151 era FALSA — 14ª vez que aparece el patrón H-D.** Declaraba
«144 ítems · **144 resueltos** · 0 pendientes · 0 dudas — DoD cubierto» con **139 `[ ]`** reales.
Corregido a conteo real y falsable.

> Y acá me agarré a mí mismo: al añadir mi iteración el conteo pasó a **159** y **el Totales quedó
> en 151**. Lo vi porque el script de verificación final compara marca contra marca. Si no lo
> hubiera verificado, habría dejado en M151 exactamente el drift que denomino H-D. Corregido dos
> veces; el bloque final dice **16 `[x]` · 5 `[?]` · 138 `[ ]` = 159**.

**c) La ruta de las iteraciones 1-2 del checklist es imprecisa.** Marcan `[x]` en
`scripts/control_final/control_final_schema.gd`; los archivos existen pero en
`game/isla-ancestral/scripts/control_final/`. Las marcas son correctas, la ruta no.

> **Casi reporté esto como «2 `[x]` apuntan a archivos inexistentes».** No lo hice porque busqué en
> todo el repo antes de acusar. **Cuarta vez** que aplico *desconfiar de la lectura, no del
> archivo* — y van 5 si cuento la redirección UTF-16 de PowerShell.

## 4. Mis 5 errores de esta tarea

| # | Error | Detección |
|---|---|---|
| 1 | CJK (2 caracteres) en un comentario | scan de CJK |
| 2 | **UTF-16** en el archivo de prueba al redirigir con PowerShell → el CLI parecía roto | `UnicodeDecodeError` |
| 3 | `NameError: io` en mi script de prueba | traceback |
| 4 | Párrafo markdown con `**` anidado + una palabra en inglés | relectura del bloque |
| 5 | **Escribí 159 ítems y dejé el Totales en 151** | verificación final marca-vs-marca |

**E2 es la quinta vez** que la redirección `>` de PowerShell me muerde. **Regla que me llevo: para
capturar salida de un proceso a archivo, `subprocess` desde Python, nunca `>` de PowerShell.**

## 5. Lo que NO hice

- **No cablesé nada** (`quality.yml` y `.github/workflows/` son de s2; me lo prohibiste).
- **No implementé los otros 3 módulos Python** — son `[M]` que dependen de **datos que no
  existen** (telemetría 72 h de M143/M104, CSV de encuestas, criterios de S1). Implementarlos sin
  los datos sería teatro. Quedan como **pendientes honestos**, visibles en la salida de mis tests.
- **No commiteé nada.**
- **No toqué** `CHECKLIST-GLOBAL.md` · checklists de otros módulos · `generar_checklist_global.py`
  (**prohibido**, no lo corrí).
- **No marqué los 138 `[ ]`.** Casi todos son `Definir ...` (criterios de auditoría) que requieren
  **juicio del fundador**, no código. No los voy a marcar por completar una cifra.
- **CERO afirmaciones visuales.**

## 6. Sobre la promesa de C3

Agradezco la promesa, pero quiero ser preciso sobre lo que **esta** tarea demuestra y lo que no:

- **Demuestra:** Python puro, un validador con 11 tests, fail-fast con exit codes, lectura crítica
  de documentaciónvs código, y que **escribo tests que congelan mis propios errores**.
- **No demuestra:** GDScript. No escribí una línea. Este módulo tenía GDScript
  (`control_final_schema.gd`) y **no lo toqué** porque no sé si puedo mantenerlo con calidad.
- **No implementé los 3 módulos que dependían de datos inexistentes**, y creo que esa es la
  decisión más útil que tomé hoy: Preferí dejar un hueco honesto a hacer teatro.

**Mi recomendación:** si la promesa de C3 es real, dame un módulo **GDScript acotado y con
verificación headless disponible** (tipo `control_final_schema.gd`, que ya tiene
`test_control_final_headless.gd`), no un módulo grande. Quiero **una** muestra de código GDScript
con test antes de que me habilites C3 — exactamente lo que hiciste bien conmigo con M151: una
tarea C2 antes de C3.

**SB-06** (gate anti-CJK) queda después de que s2 commitee SB-05, como me indicaste.

---

**Firma:** **Modelo:** space-bunny-alpha · **Plataforma:** Kilo Code · **Fecha:** 2026-10-05 00:05:00
**Logs de la sesión:** 1270 (SB-01) · 1278 (SB-03) · 1279 (SB-02) · 1280 (SB-04) · 1282 (SB-05) · 1289 (M151)