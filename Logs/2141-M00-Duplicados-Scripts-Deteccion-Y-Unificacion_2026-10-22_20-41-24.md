# Log 2141 - DeepSeek-V4.1-Flash - M00 (transversal: tooling/scripts) - Item 35: duplicados de scripts

**Fecha:** 2026-10-22 20:41
**Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
**Rama de la metodologia V2:** RAMA 2 (sin mensaje nuevo del director: maximo del canal = 364 = tracker)
**Item de la COLA ACTIVA:** 35 - "Refactor de scripts-* duplicados (deteccion y unificacion con evidencia) - 10 [C]"
**Log reservado:** 2141 (protocolo v3, `reservar_log.py --reservar`; pool medido justo antes: primero=2141)
**Mensaje al director:** 366 (canal: ultimo 365 -> proximo = ultimo+1; ver discrepancia declarada abajo)

---

## 1. Encargo y alcance

El item 35 pide "deteccion y unificacion con evidencia" de scripts duplicados. Se interpreto
como tres preguntas distintas, porque son tres defectos distintos:

1. **Duplicado exacto** (sha256): el mismo archivo con otro nombre.
2. **Duplicado normalizado**: mismo codigo con distinto formato/comentarios.
3. **Funcion duplicada**: mismo cuerpo de funcion en >= 2 archivos (la duplicacion que no se
   ve mirando archivos enteros).

No se toco ningun modulo del juego ni `CHECKLIST-GLOBAL.md`, `quality.yml`, `AGENTS.md`,
`project.godot` ni el `05-Checklist.md` de ningun modulo.

## 2. Medicion ANTES de escribir la cifra

Primera corrida del detector: **4942 archivos auditados y 57 grupos exactos**. Ese numero era
**falso como deuda del proyecto**: incluia `tools/mcp/.venv` y `site-packages`, asi que 40 de los
57 grupos eran `pip/_vendor/rich` copiado por pip mismo. Se agrego `.venv`, `venv`,
`site-packages`, `.claude`, `.mypy_cache` y `.pytest_cache` a `EXCLUIDOS` y se re-midio.

**Medicion final (universo real del proyecto): 967 archivos auditados** (`.py` + `.ps1`).

| Metrica | Valor medido |
|---|---|
| Archivos auditados | 967 |
| Duplicados exactos | 2 grupos |
| Duplicados normalizados (AST igual, bytes distintos) | 1 grupo |
| Funciones duplicadas (mismo cuerpo, >= 8 lineas, >= 2 archivos) | 81 grupos |
| Nombres de archivo repetidos | 4 |

## 3. Entregado (codigo + testing, no solo diagnostico)

### 3.1 `scripts/detectar_duplicados.py` (NUEVO, 25.076 B, ASCII puro)

Detector con tres metodos independientes:

- **Exacto**: sha256 del archivo.
- **Normalizado**: `ast.dump(..., include_attributes=False)`. El `include_attributes=False` es
  el punto: con atributos, los numeros de linea entran en el hash y dos archivos con el mismo
  codigo en distinta posicion salen "distintos". Para `.ps1` (sin AST) se usa texto normalizado
  (sin comentarios de linea completa, blancos colapsados, minusculas). Un `.py` que no parsea cae
  a texto y queda declarado en `sin_parsear` con su motivo.
- **Funcion duplicada**: huella del **cuerpo** de cada `FunctionDef`, sin nombre ni firma. Dos
  funciones con el mismo cuerpo y distinto nombre SON duplicacion: el nombre es lo que cambia.

Guardas y contratos:

- **`exit 3` = DETECTOR CIEGO** si no leyo ningun script, si el mapa quedo vacio o si ningun
  `.py` parseo (en ese caso los metodos 2 y 3 son ciegos). Un detector que no leyo nada y uno
  que leyo todo y no encontro nada imprimen lo mismo; sin esto el informe es indistinguible de
  un aprobado.
- **`--json` PURO**: solo el objeto. Verificado con `json.loads` sobre la salida entera.
- **`--check --baseline`**: rojo si aparece una firma NUEVA y tambien si una firma del baseline
  **ya no es duplicado** (baseline obsoleto). Una deuda que ya no existe deja el baseline
  podrido y en tres meses nadie sabe cuales firmas siguen siendo reales.
- **Baseline = `{firma: motivo}`**, no una lista. Una firma aceptada sin justificacion es deuda
  que nadie puede revisar. `--escribir-baseline` **conserva** los motivos ya escritos: re-generar
  no puede volver a dejar el gate mudo.
- `_correr(argv)` para que la suite asierte sobre el EFECTO (codigo + texto) y no sobre el texto:
  un gate que imprime "FALLO" y sale 0 se ve igual que uno que falla si solo miras el texto.

### 3.2 `scripts/test_detectar_duplicados.py` (NUEVO, 18.986 B, 29 checks)

**29 checks / 0 fallos / EXIT 0 x3 corridas.** Piso `CHECKS_MINIMOS = 28` **MEDIDO** (28 es el
total ejecutado antes del check de piso; el suite completo son 29). No estimado: la primera
version puso 34 "a ojo" y el piso fallo sobre una suite SANA.

Cobertura: deteccion en las tres vias + **6 controles negativos** (sin duplicado, funcion corta,
mismo nombre con distinto cuerpo, mismo cuerpo 2x en UN solo archivo, carpeta excluida,
archivo byte-distinto con el mismo AST), codigos 0/1/2/3, `--json` puro, estabilidad de firmas,
ciclo de vida completo del baseline (declarar, nuevo, obsoleto, conservar motivos, formato) y
3 checks sobre el repo real (audita > 100 archivos, sin ceguera, gate VERDE con el baseline
commiteado).

### 3.3 `scripts/duplicados_baseline.json` (NUEVO, 1.092 B)

2 firmas, **cada una con su motivo medido** (no un blob mudo). Gate sobre el repo real:
`--check` = **EXIT 0** (0 nuevas / 0 obsoletas).

### 3.4 Sondas del guardian EN ROJO (`out/probar_guardian_dup.py`, 3/3)

Se probo que la suite **discrimina**, no solo que pasa. Cada sonda inyecta un defecto, corre la
suite, exige EXIT != 0 **y** que el check que corresponde sea el que falla, y restaura
byte-exacto verificando sha256.

| Sonda | Inyeccion | Resultado |
|---|---|---|
| A | guarda de ceguera desactivada (`if False and motivos:`) | EXIT 1, falla "carpeta vacia -> exit 3" |
| B | aviso de deuda obsoleta silenciado (`if False and obsoletas:`) | EXIT 1, falla "firma OBSOLETA -> ROJO" |
| C | suite recortada (un `test()` menos) | EXIT 1, falla el piso: "solo 27 checks (minimo 28)" |

Restauracion byte-exacta de los 2 archivos: `sha256sum -c` = **OK / OK**.

## 4. Unificacion aplicada (1 caso, no destructiva)

**Caso: `scripts-reutilizables/generar_tareas_modelo.py` vs `scripts/generar_tareas_modelo.py`.**

Evidencia medida:

| | copia de `scripts-reutilizables/` | copia de `scripts/` |
|---|---|---|
| Lineas / bytes | 80 / 3.399 | 220 / 8.691 |
| Funciones | 1 (`extraer_modulo`) | 8 |
| CLI | **ninguna** (`add_argument` = 0) | `--modelo --recom --plataforma --dry-run` |
| `__main__` | **no tiene** -> no es ejecutable | si |
| Modelo | `modelo = 'deepseek-v4-flash'` **hardcodeado** | parametro |
| Modulos | lista de 8 **hardcodeada** | derivada de `CHECKLIST-GLOBAL` por Recom |
| mtime | 2026-09-02 03:30 | 2026-09-02 **14:44** (posterior) |

No es un extractor reutilizable: es un one-off con el modelo y los modulos de OTRO modelo
hardcodeados. Y `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md:83` lo citaba como
**"el patron"** para un modelo nuevo -> un modelo nuevo que siguiera la guia copiaba el archivo
equivocado.

**Accion (aditiva, reversible, sin borrar contenido):**

1. Banner `SUPERSEDED (2026-10-22, Log 2141)` al inicio de la copia vieja, con el motivo y el
   puntero al canonico. El contenido original queda **intacto como sufijo exacto** (verificado
   por sha256 del resto).
2. La guia pasa a citar `scripts/generar_tareas_modelo.py` con la invocacion concreta.

Verificado: el resto del archivo sigue parseando (`ast.parse` OK), la operacion es **idempotente**
(2a corrida: `[SKIP]` en las dos ediciones, EXIT 0), EOL **LF preservado** en ambos (0 CRLF,
0 CR antes y despues), sin BOM, 0 U+FFFD.

## 5. Hallazgos NO tocados (escalados al director)

Los 2 duplicados exactos restantes **no son mios y no los borre**:

1. **`crear_casa_01_choza.py` (31.166 B, sha256 6b02317ff9f0)** identico en
   `18-BIS-Casas-Grandes/CASA_01_CHOZA/BAJA/` y `.../CASA_02_CASA_MEDIANA/BAJA/`. La carpeta de
   la CASA MEDIANA tiene su **propio** `.blend` y `.glb` (`SM_CASA_02_CASA_MEDIANA_BAJA`,
   1.608.028 / 65.936 B) pero su script fuente es el de la CHOZA sin adaptar. Es un defecto de
   **trazabilidad del asset**, no una copia redundante: borrarla destruiria la unica fuente
   declarada de ese `.glb`. Dueno: M18-BIS (assets).
2. **`nutria_ribera_alta.py` (16.214 B, sha256 7977eee01f11)** identico en `36-Fauna/` y en
   `36-Fauna/scripts-blender/`. `scripts-blender/` contiene **un solo archivo** y es copia del de
   la raiz: subcarpeta creada por copia, no por migracion. Candidato a unificar (conservar el de
   la raiz, retirar el subdirectorio), pero toca el arbol de assets de otro modulo.

Otros datos medidos que quedan como deuda informativa:

- **81 grupos de funciones duplicadas**, dominados por el boilerplate de los scripts de Blender:
  `crear_mat` aparece identico en **42 archivos** (9 lineas), `nueva_caja`/`agregar` en 8,
  `crear_objeto`/`limpiar` en 4. Extraer un helper comun exigiria editar decenas de scripts de
  assets ajenos: no se hizo.
- **`tmp_m117_verif_final2.py` y `tmp_m117_verif_secciones.py`** en `scripts-reutilizables/` son
  scratch **sin trackear** (no estan en `git ls-files`). No se tocaron (no son mios; la
  convencion del proyecto es relocalizar el scratch, no borrarlo).
- **1 duplicado normalizado**: `crear_luna.py` en `NPC_SCRIPTS/` y en `scripts-reutilizables/`
  (mismo AST, distinto formato). Mismo criterio: assets ajenos, se reporta.

## 6. Evidencia medida (re-medida DESPUES del cambio)

| Comprobacion | Antes | Despues |
|---|---|---|
| Archivos auditados | 966 | 967 (incluye el detector nuevo) |
| Duplicados exactos | 2 | 2 |
| Normalizados | 1 | 1 |
| Funciones duplicadas | 81 | 81 |
| Gate `--check` | EXIT 0 | **EXIT 0** |
| Suite | 29/0/EXIT 0 x3 | **29/0/EXIT 0** |

Gates del repo sobre mis archivos: `verificar_bom.py` y `diagnosticar_mojibake.py` estan en
**EXIT 1 por deuda AJENA** (36+ archivos con BOM y mojibake en mensajes de otros modelos), con
**0 menciones** a `detectar_duplicados` o `duplicados_baseline`. `verificar_funcs_duplicadas.py`
= EXIT 0.

## 7. Trampas nuevas (para el skill)

1. **Un detector de duplicados que incluye `site-packages` mide pip, no el proyecto.** 57 grupos
   exactos -> 2 al excluir `.venv`/`site-packages`. El 96% del "hallazgo" era `pip/_vendor/rich`.
   Antes de publicar un conteo de duplicados, decir QUE se audito.
2. **`ast.dump()` con atributos hace que el mismo codigo en otra linea sea "distinto".**
   `include_attributes=False` no es cosmetico: es lo que convierte el hash en una huella
   estructural. Sin el, el metodo 2 es un sha256 con pasos extra.
3. **El selftest del propio detector cazo un defecto mio en la 1a corrida.** `metodo_normal`
   quedaba como `"syntax_error:<msg>"`, mezclando METODO con MOTIVO: un consumidor que pregunte
   `metodo == "texto"` no encuentra el archivo. Se separo `motivo_fallback`. El selftest no era
   decorativo.
4. **El piso de checks escrito antes de medir hace fallar una suite SANA.** Puse 34 "a ojo" y el
   real era 28 (el piso se evalua cuando todavia no se conto a si mismo). Y hay una circularidad:
   el piso no puede incluirse a si mismo, asi que su valor es "checks ejecutados ANTES del check
   de piso".
5. **La FIRMA del gate se calcula sobre BYTES: agregar un comentario saca al par de `exactos`
   legitimamente.** Mi test aserto "la firma no cambia con un comentario" y fallo con razon: lo
   que no puede cambiar es la huella **NORMALIZADA** (AST), no la firma byte-based. Confundir las
   dos hace que un cambio correcto parezca una regresion.
6. **Un invariante de EOL por CONTEOS convierte un cambio correcto en "fallo".** Agregar 10
   lineas a un archivo LF sube `lf_solo` de 79 a 89 legitimamente. El invariante es el **TIPO**
   (`lf`/`crlf`/`mixto`), no el conteo. Es la trampa K del skill vista desde el otro lado.
7. **Un script de verificacion idempotente puede reportar FALLO sobre el estado correcto.** En la
   2a corrida comparaba el contenido sin banner contra un hash que ya incluia el banner. La
   verificacion tiene que ser **condicional a que el cambio se haya aplicado en esa corrida**.

## 8. Pedidos al director

- **P1.** Autorizar commit de 5 paths: `scripts/detectar_duplicados.py`,
  `scripts/test_detectar_duplicados.py`, `scripts/duplicados_baseline.json`,
  `scripts-reutilizables/generar_tareas_modelo.py`,
  `DOCUMENTACION/TAREAS-POR-MODELO/GUIA-METODOLOGIA.md`. (Los 2 de `out/` son scratch de
  evidencia: no hace falta versionarlos, pero se puede si prefiere.)
- **P2.** Cablear `scripts/test_detectar_duplicados.py` y
  `detectar_duplicados.py --check --baseline` a `quality.yml` (no lo toco: es protegido). El gate
  nace VERDE con 2 firmas de deuda justificadas.
- **P3.** Decision sobre los 2 duplicados exactos: (a) `CASA_02_CASA_MEDIANA/BAJA` ->
  adaptar el script al asset real o declararlo deuda de trazabilidad de M18-BIS; (b)
  `36-Fauna/scripts-blender/` -> retirar el subdirectorio de 1 archivo o dejarlo con nota.
  Al resolverlos, `--escribir-baseline` conserva los motivos y el gate avisa si la firma quedo
  obsoleta.
- **P4.** Decision sobre las 81 funciones duplicadas de boilerplate Blender (extraer helper comun
  vs declarar deuda): 42 archivos comparten `crear_mat` de 9 lineas.
- **P5.** Ratificar la marca `[->]` del item 35 en mi BACKLOG-MASTER (cerrado de mi lado; el
  residuo es de assets ajenos).

## 9. Estado

- **0 commits / 0 push / 0 flips** en `05-Checklist.md` de modulos ni en `CHECKLIST-GLOBAL.md`.
- 5 archivos del repo modificados/creados (4 nuevos + 1 editado) + 2 scratch en `out/`.
- **Discrepancia de numeracion declarada:** el head del pool del canal
  (`Mensajes entre modelos/DeepSeek-V4.1-Flash/NUMEROS_DISPONIBLES.txt`) sigue en **363** con
  363/364/365 ya usados -> el proximo numero real es `ultimo+1` = **366**, presente en el pool.
  No se renumero nada ajeno. `reservar_log.py --estado` reporta **12 colisiones AJENAS**
  (1290, 1468, 1547, 1559, 1585, 1645, 1698, 1726, 1876, 1878, 1888, 2120): se reportan, no se
  tocan.
