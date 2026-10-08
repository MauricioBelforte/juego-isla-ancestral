# Log 1289: M151-Control-Final — `verificar_puntos.py` + 11 tests + corrección de la cifra falsa

**Fecha:** 2026-10-04
**Hora:** 23:55:00
**Modelo:** space-bunny-alpha
**Plataforma:** Kilo Code

## Resumen

Primer trabajo de **C2 con código** (Python puro) del proyecto para este agente. Cerré el ítem
`[M]` «Definir verificación automática: puntos sin evidencia = alerta» construyendo la herramienta
que el propio `04-Codigo.md` §1 especifica, con **11 tests propios**.

Además encontré y corregí **la cifra falsa del bloque `## Totales`** de M151 y documenté la
**deriva entre el diseño (`04-Codigo.md` §1) y la implementación real**.

## Qué construí

### `scripts/auditoria/verificar_puntos.py` (nuevo)

Valida el acta de Control Final contra los **26 puntos** de `03-Diseno.md` §2. Reglas que
implementa (todas del `05-Checklist.md` de M151):

| Regla del checklist | Implementación |
|---|---|
| «Evidencia obligatoria para cada estado (sin evidencia = no aprobado)» | Punto con `evidencia` vacía/null → alerta |
| «Plan de acción con dueño y fecha para cada ⚠/✖» | Estado ⚠/✖ exige `planAccion.dueño` + `.fecha` + `.desc` |
| «0 puntos en ✖ al cierre (requisito)» | Solo con `--cierre` |
| «Acta firmada por producción y QA» | Solo con `--cierre`: exige `produccion` y `qa` |
| «Verificación automática: puntos sin evidencia = alerta» | Es el ítem que este trabajo cierra |

Además valida **integridad estructural**: los 26 puntos deben estar (detecta falta y sobra),
sin `id` duplicados, `id` entero, estado del semáforo válido. Y `--plantilla` emite el esqueleto
del acta con los 26 puntos.

**Acepta el semáforo en 3 formas** (glifo `✔`/`⚠`/`✖` **o** `OK`/`WARN`/`BLOCK`), porque un acta
puede venir de un editor que no escribe los símbolos.

**Fail-fast BUG-075 con `exit 3` = detector ciego**, distinguible de `exit 1` («miré y hay
alertas»). Verificado **como proceso**, no como valor de retorno: un `return {}` sería
indistinguible de «no hay datos».

### `scripts/auditoria/test_verificar_puntos.py` (nuevo, 11 tests)

**Suite autocontenida a propósito:** `scripts/test_scripts.py` es de s2 y el director lo prohibió
explícitamente en SB-05. Estos tests corren aparte y **no toco los de s2**.

Cubren los 4 casos que `04-Codigo.md` §4 exige (los 3 no implementados quedan como **pendientes
honestos**, no como falsos verdes) + los míos: detección de puntos que faltan/sobran, ids
duplicados, estados en ambas formas, fail-fast en 4 caminos, `exit 3` como proceso, round-trip
JSON UTF-8 en disco.

**`11 PASS, 0 FAIL`.**

## Hallazgos (verificados, no supuestos)

### 1. Los 2 `[?]` de M151 siguen abiertos, y el motivo NO es solo «falta cablesar»

- **`release-build.yml` NO ejecuta el gate** (verificado: el workflow corre tests, lint, build,
  checksums y release notes; el gate no aparece). Sin cablesarlo, los 7 gates de
  `estado_release.json` **no bloquean nada**.
- **`estado_release.json` está congelado en «2026-09-02 18:00»** y **nada lo escribe**. Aunque se
  cableara el gate, leería datos viejos → **falsa seguridad**. Es la trampa 81/100: *un gate
  decorativo es peor que no tener gate*, y el propio `quality.yml` ya lo documenta en sus
  comentarios.
- **Dueño: s2** (M118 es suyo). Coordinado por su canal (`atria-dawn-s2/21-...`).

### 2. Deriva diseño ↔ implementación

`04-Codigo.md` §1 especifica **4 herramientas Python** en `scripts/auditoria/`. Al verificar:

| Especificado | Realidad |
|---|---|
| `generar_acta.py` | ❌ no existe |
| `importar_telemetria.py` | ❌ no existe |
| `importar_encuestas.py` | ❌ no existe |
| `verificar_puntos.py` | ✅ **este trabajo** |
| `acta-control-final.md` | ❌ no existe (el validador usa `.json`) |

**Y la implementación que §1 no menciona** es **GDScript**, en otra ruta:
`game/isla-ancestral/scripts/control_final/{control_final_schema,control_final_gate,test_control_final_headless}.gd`
+ `game/isla-ancestral/data/control_final/estado_release.json`.

**No son la misma capa:** el schema/gate corren *dentro de Godot* (`extends SceneTree`); el
validador corre *fuera*. Documentado en `04-Codigo.md` §5 (nuevo).

### 3. La ruta citada en las iteraciones 1-2 del checklist es imprecisa

El checklist marca `[x]` en `scripts/control_final/control_final_schema.gd`. **Los archivos
existen** — pero en `game/isla-ancestral/scripts/control_final/`. Las marcas son correctas; **la
ruta omite el prefijo**.

> **Casi reporté esto como «2 `[x]` apuntan a archivos inexistentes».** No lo hice porque busqué en
> todo el repo antes de acusar. Cuarta vez que aplico la regla de *desconfiar de la lectura* y no
> del archivo.

### 4. La cifra de `## Totales` era FALSA (patrón H-D, 14ª vez)

El bloque declaraba «**144 ítems · 144 resueltos por documentación · 0 pendientes · 0 dudas — DoD
cubierto**» mientras el archivo tenía **139 `[ ]`**. Mismo patrón que detecté en M152 (SB-01) y en
13 checklists más (SB-02).

**Corregido a un conteo real y falsable.** Y al añadir mi iteración el conteo pasó a 159, así que
**volví a corregirlo**: no voy a introducir yo mismo el drift que critico.

## Archivos Modificados/Creados

### Creados
- `scripts/auditoria/verificar_puntos.py` — el validador.
- `scripts/auditoria/test_verificar_puntos.py` — 11 tests.
- `Logs/1289-M151-VERIFICAR-PUNTOS-Y-CIFRA-FALSA-CORREGIDA_2026-10-04_23-55-00.md` — este log.
- `Mensajes entre modelos/atria-dawn-s2/21-2026-10-04_23-40-00-coordinacion-sb05-commit-y-m151.md`
  — coordinación: commit de SB-05 + territorio de M151.
- `Mensajes entre modelos/space-bunny-alpha/10-...` — informe al director.

### Modificados
- `DOCUMENTACION/151-Control-Final/plan-actual/05-Checklist.md` — 1 `[ ]` → `[x]` con evidencia ·
  bloque `## Totales` corregido (2 veces) · **Iteración 3** agregada con 6 `[x]` y 3 `[?]`.
- `DOCUMENTACION/151-Control-Final/plan-actual/04-Codigo.md` — nueva **§5** con el estado real y la
  deriva.
- `DOCUMENTACION/TAREAS-POR-MODELO/space-bunny-alpha/BACKLOG-MASTER.md` — M151 + SB-05 + SB-06.
- `Logs/NUMEROS_DISPONIBLES.txt` — **1289 borrado** (reservado). Cabeza **1290**.

### Sin tocar (por restricción)
`CHECKLIST-GLOBAL.md` · los 167 `05-Checklist.md` **de otros módulos** · `quality.yml` ·
`.github/workflows/**` · `generar_checklist_global.py` · `test_scripts.py` (de s2) ·
`generar_checklist_global.py` (**no lo corrí**: está **PROHIBIDO** por decisión del director).

## Salida medida

```
$ python scripts/auditoria/test_verificar_puntos.py
RESULTADO: 11 PASS, 0 FAIL

$ python scripts/auditoria/verificar_puntos.py --plantilla
exit=0 · 26 puntos · "Identidad propia" … "Plan post-lanzamiento" · acentos UTF-8 OK

$ … --acta <plantilla vacia>
exit=1 · SE ENCONTRARON 26 ALERTAS   (las 26 = sin evidencia)

$ … --acta <acta con 26 evidencias + firmas>
exit=0 · ACTA VALIDA: los 26 puntos tienen estado y evidencia
$ … --acta <misma> --cierre
exit=0 · ACTA VALIDA … (incluye requisitos de cierre)

$ … --acta <1 punto en ✖, sin firma de qa> --cierre
exit=1 · "punto 7: en ✖ y el cierre exige 0 puntos bloqueantes"
      · "falta la firma de 'qa' en el acta de cierre"

$ … --acta <inexistente | 0 bytes | JSON inválido>
exit=3 · DETECTOR CIEGO: no pude leer el acta   (en los 3 casos)

$ …   (sin --acta; la ruta por defecto no existe)
exit=3 · "el acta no existe: …/plan-actual/acta-control-final.json"
```

## Errores míos en esta tarea (5)

| # | Error | Detección |
|---|---|---|
| 1 | CJK (2 caracteres, en un comentario mio de `verificar_puntos.py`) | scan de CJK |
| 2 | Metí **UTF-16** en el archivo de prueba al redirigir con PowerShell (`0xff`) → el CLI parecía roto | `UnicodeDecodeError` |
| 3 | `NameError: io` en mi script de prueba | traceback |
| 4 | Parrafo markdown con `**` anidado + una palabra en inglés | relectura del bloque Totales |
| 5 | **Escribí 159 ítems y dejé el Totales en 151** — introduje yo mismo el drift que critico | el script de verificación final |

**E2 es la quinta vez** que la redirección de PowerShell me muerde (`>` escribe UTF-16). **Mi
regla:** para capturar salida de un proceso a un archivo, usar `subprocess` desde Python, nunca
`>` de PowerShell.

**E5 es el más relevante:** si no hubiera **verificado el conteo después de mi propia edición**,
habría dejado en M151 exactamente el tipo de cifra falsa que denomino H-D. **La autocrítica tiene
que incluir el trabajo propio.**

## Lo que NO hice

- **No cablesé el gate al CI.** `.github/workflows/` y `quality.yml` son de s2; el director lo
  prohibió para mí y lo dejé **[?]** con dueño.
- **No definí quién escribe `estado_release.json`.** Es una decisión de diseño que afecta la
  fuente de verdad de la puerta de release; la propuse y la dejé **[?]** con dueño.
- **No implementé** `generar_acta.py`, `importar_telemetria.py` ni `importar_encuestas.py`. Son
  `[M]` que dependen de **datos que no existen** (telemetría 72 h de M143/M104, CSV de encuestas,
  criterios de S1). Implementarlos sin los datos sería teatro. Quedan como pendientes honestos.
- **No commiteé nada.** `scripts/` es de s2 (SB-05 sigue sin commitear por diseño).
- **CERO afirmaciones visuales.** No apliqué nada de esto al juego.

## Recomendaciones

1. **Prioridad 1 — definir quién escribe `estado_release.json`.** Sin eso, cablesar el gate es
   teatro: siempre leería el mismo JSON del 2026-09-02.
2. **Prioridad 2 — commit de SB-05** (s2). 15 PASS / 0 FAIL verificados.
3. **Prioridad 3 — decidir el destino de los 3 módulos Python faltantes** (`04-Codigo.md` §1):
   se implementan, o se actualiza el diseño para reflejar que la capa de auditoría es GDScript +
   el validador Python que hice.
4. **Corregir la ruta imprecisa** `scripts/control_final/…` → `game/isla-ancestral/scripts/control_final/…`
   en las iteraciones 1-2 del checklist. Las marcas son correctas; la ruta no.
5. **Los 138 `[ ]`** de M151 son casi todos `Definir ...` (criterios de auditoría) que requieren
   **juicio del fundador**, no código. No los voy a marcar porbardear.