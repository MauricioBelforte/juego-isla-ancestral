# Log 2142 - M00 - Auditor de citas de checklists + verificacion de M90 (item 36)

**Fecha:** 2026-10-22
**Agente:** DeepSeek-V4.1-Flash
**Director vigente:** GLM-5.3 Flash-Director (Kilo Code)
**Rama:** RAMA 1 (mensaje 367 del director) y luego trabajo de cola
**Modulo:** M00 (herramientas transversales)

---

## 1. Punto de partida: RAMA 1

Al abrir la vuelta el tracker estaba en 366 y el mensaje mas alto del director era 364,
asi que empece por RAMA 2. A mitad de la tanda el CRON commiteo en vuelo
(`659cca1`, `8f97325`) y aparecio el **mensaje 367**: `item35-ratificado-p1-p5`.

Contenido del 367 (verificado por el director contra disco):

- **P1: COMMIT hecho** en `48c022c` (8 archivos, +1436 lineas).
- **P2: `quality.yml`** sigue esperando la decision del fundador (junto con la de M107).
- **P3 (2 exactos + fauna): escalados al fundador.** CASA_02 debe adaptar su script
  (defecto de trazabilidad de M18-BIS); retirar o anotar `36-Fauna/scripts-blender`.
- **P4 (81 funciones de boilerplate Blender): escalado como deuda de documentacion.**
- **P5: `[->]` RATIFICADO.** Mi lado del item 35 queda cerrado; el residuo es de duenos ajenos.
- **Pool:** mi discrepancia de head (363 frente a 364/365/366) queda encolada al saneo total;
  el director pide explicitamente que yo no la toque.
- "Tu 367 consumido; proximo 368."

No hay tarea nueva en el 367. Es ratificacion y cierre. Continuo con la cola.

---

## 2. Item 36 (M90-Configuracion-Grafica): la premisa estaba vencida

El item 36 dice: "M90 (149/249): 100 pendientes -> lote 1 (presets)".

**Medido antes de escribir**, con conteo estricto por prefijo de linea sobre
`DOCUMENTACION/90-Configuracion-Grafica/plan-actual/05-Checklist.md`:

| marca | cantidad |
|---|---|
| `[x]` | 249 |
| `[ ]` | 0 |
| `[?]` | 0 |
| **total items** | **249** |

El propio archivo lo declara en su linea `**Totales:**`: "249 lineas-item - Completados: 249
- Pendientes: 0". La linea 344 del mismo archivo conserva un snapshot viejo
("69 [x] / 180 [ ]") que ya no corresponde a nada.

**Conclusion:** no hay 100 pendientes. El item 36 no es ejecutable como esta escrito.

### 2.1 Verificacion positiva contra disco (no basta con decir "no hay pendientes")

Un `[x]` solo vale si el codigo y las pruebas estan en disco y pasan HOY. Medido:

| artefacto | ruta | tamano / lineas |
|---|---|---|
| nucleo | `game/isla-ancestral/scripts/settings/graphics_config.gd` | 24.630 B / 575 lineas |
| suite nucleo | `.../test_graphics_config.gd` | 11.188 B / 217 lineas |
| suite post | `.../test_graphics_config_post_m90.gd` | 9.151 B / 182 lineas |

Presets presentes en el nucleo: `EFECTOS` en L68 `{baja 0.25, media 0.5, alta 0.85,
ultra 1.0}`, `PRESETS` en L126, `aplicar_preset()` en L174, `preset_actual()` en L182.

Suites corridas con el binario real `Godot_v4.7.2-stable_win64_console.exe`, headless:

| suite | checks | fallos | bloques | SCRIPT ERROR | EXIT |
|---|---|---|---|---|---|
| `test_graphics_config.gd` | 85 | 0 | 6 | 0 | 0 |
| `test_graphics_config_post_m90.gd` | 57 | 0 | (sin bloques) | 0 | 0 |

Ambas verdes hoy. **Los 249 `[x]` de M90 estan respaldados por codigo y pruebas reales.**

### 2.2 Dos huecos reales que si existen en M90 (no tocados: modulo en NO TOCAR)

1. **La suite post no tiene piso de checks.** Su `_fin()` solo mira `_fallos == 0`:
   no hay `CHECKS_MINIMOS`, asi que una corrida recortada seguiria diciendo PASS.
   La suite del nucleo si tiene piso (80) y piso de bloques (6).
2. **Ninguna de las dos suites esta cableada a un workflow.** Lo dice el propio
   checklist: "Sin gate en CI: el test NO corre en ningun workflow". `quality.yml`
   es archivo protegido: la decision es del director.

---

## 3. Trabajo entregado: auditor de citas de checklists

### 3.1 Por que

La trampa "cita fantasma" (un item marcado `[x]` que cita un archivo, seccion o linea
que no existe) estaba registrada en mi memoria pero nunca se habia medido a escala.
Medirla a mano en 167 checklists es inviable.

### 3.2 Artefactos

| archivo | bytes | lineas | higiene |
|---|---|---|---|
| `scripts/auditar_citas_checklist.py` | 27.991 | 651 | ASCII puro, LF, sin BOM |
| `scripts/test_auditar_citas_checklist.py` | 13.241 | 330 | ASCII puro, LF, sin BOM |
| `scripts/citas_baseline.json` | 15.982 | 155 | ASCII puro, LF, sin BOM |

El auditor tiene tres metodos de deteccion y un conjunto cerrado de estados:

- **Defectos:** `cita_archivo` (token con extension real que no resuelve en ninguna
  base), `linea_fuera` (referencia `L<a>-<b>` que supera las lineas reales del archivo)
  y `checklist_binaria` (byte NUL: `grep` la salta en silencio).
- **Informativos:** `cita_directorio` ausente, `glob_roto`, `ruta_sin_extension`,
  `cita_clase` (la clase existe con otro nombre de archivo).

Resolucion en cinco bases: raiz del repo, `game/isla-ancestral/`, la carpeta del modulo,
su `plan-actual/` y `game/isla-ancestral/scripts/`. Despues, por basename unico, y por
ultimo indice de `class_name`.

Codigos de salida: 0 sin defectos, 1 con defectos (o con defectos nuevos en `--check`),
2 uso incorrecto, **3 DETECTOR CIEGO**.

### 3.3 Medicion sobre el corpus completo

`python scripts/auditar_citas_checklist.py --todas`

| metrica | valor |
|---|---|
| checklists leidas | 167 |
| citas extraidas | 13.811 |
| citas de archivo rotas | 192 |
| refs de linea fuera de rango | 2 |
| checklists binarias (NUL) | 1 |
| **DEFECTOS** | **195** |
| de esos, en item `[x]` (falso verde declarado) | 50 |
| de esos, en prosa/diseno (artefacto planificado) | 144 |
| citas de directorio ausentes (informativo) | 57 |
| globs sin coincidencia (informativo) | 51 |
| citas de clase con nombre de archivo (imprecisas) | 8 |

**M90 medida aparte: 293 citas, 0 defectos.** El modulo del item 36 no tiene ninguna
cita rota.

### 3.4 Verificacion manual de las acusaciones

El detector no se cree solo. Ocho citas acusadas, comprobadas con `find` sobre todo el
repo (excluyendo `.git`): `perf_base.json`, `chunk_memory.gd`, `enemy_ai.gd`,
`validate_mesh.gd`, `settings.gd`, `opt_out.cfg`, `simulate_economy.gd`,
`update_checker.gd` -> **0 coincidencias las ocho**. Las acusaciones son ciertas.

### 3.5 Hallazgo propio: la checklist de M159 es binaria para grep

`DOCUMENTACION/159-Catalogo-De-Objetos/plan-actual/05-Checklist.md` tiene **1 byte NUL
(0x00) en el offset 356**, en la linea 9. El texto es:

```
(el \x006-Diseno-Visual.md de MiMo ya cubre la mayoria)
```

Debia decir `06-Diseno-Visual.md`. Consecuencia medible: `grep` clasifica el archivo
como binario y lo **salta en silencio** en cualquier busqueda normal, asi que toda
auditoria que dependa de grep deja de ver esa checklist. Es un generador de falsos
negativos, no una curiosidad. UTF-8 sigue siendo valido (NUL es UTF-8 legal), por eso
ningun validador de BOM/mojibake lo detecta.

No lo arreglo: el `05-Checklist` de un modulo es archivo protegido. Lo reporto.

### 3.6 Las dos refs de linea fuera de rango

1. `scripts/data/validar_catalogo_m159.gd` citado en `L210`; el archivo tiene **181 lineas** (M159).
2. `moon_curve.tres` citado en `L54`; el `.tres` tiene **5 lineas** (M31). El `L54`
   corresponde en realidad a `day_night_cycle.gd`: es una cita **mal atribuida**, no
   un archivo que falte.

### 3.7 Suite y guardian en rojo

Suite `scripts/test_auditar_citas_checklist.py`: **42 checks / 0 fallos / EXIT 0 x3**.
Piso `CHECKS_MINIMOS = 42` **MEDIDO** en verde (la primera version puso 34 de memoria;
al agregar el bloque de NUL el valor real paso a 42). El piso se evalua antes de
contarse a si mismo, asi que no puede incluirse en su propio conteo.

13 bloques, 6 de ellos controles negativos: pseudo-codigo, fracciones, listas de
extensiones (`.ogg/.wav/.mp3`), plantillas de nombre (`NN-Nombre.md`,
`save_001_v<X.Y.Z>.tres`), carpetas excluidas (`.godot/`), pares de API
(`profundidad_min/max`). Ademas comprueba que el auditor **no escribe** en el repo
(foto del arbol antes/despues, 4 archivos identicos).

**Guardian EN ROJO 3/3** por inyeccion (`out/probar_guardian_citas.py`):

| sonda | que rompe | resultado |
|---|---|---|
| A | desactiva el guardia de ceguera | suite EXIT 1, nombra el bloque 8 |
| B | clasificador permisivo (todo es archivo) | suite EXIT 1, nombra el bloque 4 |
| C | suite recortada en un test | suite EXIT 1, delata el piso |

Las tres restauraciones se verificaron **byte-exactas por sha256**.

### 3.8 Gate `--check` y baseline

`scripts/citas_baseline.json`: **150 firmas** con motivo (39 en item `[x]`, 108 en prosa,
2 de linea, 1 de NUL). Congela la deuda actual para que el gate solo falle con defectos
**NUEVOS**.

- `--todas --check` -> **EXIT 0** (150 firmas de baseline, 195 ocurrencias actuales).
- Prueba en rojo sobre el corpus REAL sin tocar archivos protegidos: baseline recortado
  en una firma (`out/baseline_recortado.json`) -> **EXIT 1** nombrando
  `05-Lenguaje-Y-Programacion|archivo|ULTIMO_NUMERO.txt` tres veces.
- El gate controla solo defectos. Directorios ausentes y globs quedan fuera a proposito:
  si entraran, el gate fallaria para siempre por deuda que no se quiere pagar.

---

## 4. Defectos propios encontrados y corregidos (honestidad)

1. **Regex de listas de extensiones**: `^(?:\.[a-z0-9]+/)+$` exigia barra final y
   `.ogg/.wav/.mp3` caia como cita de archivo. Lo cazo mi propio `--selftest` (26 checks,
   1 fallo). Corregido a `^(?:\.[a-z0-9]+/)+\.[a-z0-9]+$`.
2. **Gate desalineado**: `firmas_de()` comparaba directorios y globs contra un baseline
   que solo congelaba defectos -> 108 "NUEVAS" falsas. Corregido: el gate controla solo
   `rotas_archivo`, `lineas_fuera` y `binarios`.
3. **Generador de baseline** omitia la firma de NUL -> el gate nacia en rojo. Corregido.
4. **Fixtures sin ninguna cita resoluble** disparaban el guardia de ceguera (9 fallos).
   Correcto el guardia, irreales los fixtures: se agregaron citas validas.
5. **Asercion `"binarias = 1"`** fallaba porque el total era 2 (el NUL tambien rompia la
   cita `\x006-Diseno-Visual.md`). Corregida la asercion, no el codigo.

Tambien verifique un falso positivo propio grande: `profundidad_min/max`,
`feature/NN-modulo`, `163/222` y `space-bunny-alpha/01` no son citas de archivo. De ahi
la regla de precision: **un defecto exige extension real**; lo que tiene barra pero no
extension se informa como `ruta_sin_extension` y nunca cuenta.

---

## 5. Estado del arbol y aviso sobre HEAD

- **El CRON commiteo en vuelo** (`8f97325`) una version **a medio construir** de
  `scripts/auditar_citas_checklist.py`: 545 lineas / 22.199 B. La version terminada en
  disco tiene **651 lineas / 27.991 B** (`git diff --stat HEAD` = +198 / -92).
- La version commiteada **no tiene** el indice de `class_name`, ni la deteccion de NUL,
  ni el gate alineado. Quien la ejecute obtiene numeros distintos (inflados).
  **Necesita commit del estado actual.**
- `scripts/test_auditar_citas_checklist.py` y `scripts/citas_baseline.json` siguen sin
  trackear.
- `out/` esta en `.gitignore` (linea 220), asi que las sondas y volcados no entran al repo.
- **0 commits / 0 push / 0 flips** de mi lado.

---

## 6. Pedidos al director

- **P1:** commit de 3 rutas: `scripts/auditar_citas_checklist.py` (estado final),
  `scripts/test_auditar_citas_checklist.py`, `scripts/citas_baseline.json`.
  La version en HEAD esta superseded por el propio commit del CRON.
- **P2:** cablear `test_auditar_citas_checklist.py` y `--todas --check` a `quality.yml`
  (protegido). Es la misma decision pendiente de P2 del item 35.
- **P3:** decidir sobre el **byte NUL de M159** (arreglo de 1 byte, archivo protegido)
  y sobre la cita mal atribuida de M31 (`moon_curve.tres L54`).
- **P4:** decidir si los **50 defectos en item `[x]`** se degradan a `[?]` o se arreglan
  por dueno. Lista completa en `out/auditoria_citas.txt` con modulo y linea.
- **P5:** reponer cola. Items 36/37/38 (M90) son vacuos por premisa vencida: M90 esta
  249/249 con codigo y suites verdes medidas hoy. Item 34 (M113) sigue bloqueado y el 39
  (M91) esta en vuelo de step-5-kilocode.

---

## 7. Resumen de numeros medidos (todos re-medidos, ninguno heredado)

```
M90 items                 249 (249 [x] / 0 [ ] / 0 [?])
M90 suite nucleo          85 checks / 0 fallos / 6 bloques / EXIT 0
M90 suite post            57 checks / 0 fallos / EXIT 0
M90 citas                 293 / 0 defectos
checklists auditadas      167
citas extraidas           13811
DEFECTOS de cita          195 (192 archivo + 2 linea + 1 binaria)
  en item [x]             50
  en prosa                144
informativos              57 dirs + 51 globs + 8 clases
suite auditor             42 checks / 0 fallos / EXIT 0 x3 (piso 42 medido)
guardian                  3/3 en rojo, restauracion byte-exacta
gate --check              EXIT 0 (150 firmas)
gate en rojo              EXIT 1 nombrando la firma recortada
commits / push / flips    0 / 0 / 0
```
