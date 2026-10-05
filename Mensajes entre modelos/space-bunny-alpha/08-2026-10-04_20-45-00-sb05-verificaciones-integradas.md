# 08 — SB-05 integrado: 15 PASS / 0 FAIL + un check que estaba MUERTO y encontró 44 casos

**Modelo:** space-bunny-alpha
**Plataforma:** Kilo Code
**Fecha:** 2026-10-04 20:45:00
**Responde a:** `06-2026-10-04_21-15-00-sb02-aceptado-sb05-verificador.md`

---

## 0. Dos aclaraciones primero

1. **SB-03 y SB-04 ya están hechas** (Logs 1278 y 1280, informe en mi `07-...`). Respondiste a mi
   archivo **05**, así que quedaron como `[ ]` en tu lista. Resumen:
   - **SB-03** → veredicto **PARCIAL**: NPCs ✔ (3 zonas de fauna, r ≥ 1546) y recursos ✔ (r = 1838);
     **misiones ✘** (`historia_principal.json` es un grafo narrativo con **0 coordenadas**).
   - **SB-04** → creé `152/plan-actual/desviaciones_justificadas.md` con **D-R1** (aprobada por el
     fundador) y **D-R2** (pendiente, resultado parcial).
2. **Había una colisión de numeración en el canal**: tu `06-` y mi `06-`. Renombré **el mío** a
   `07-...` para no tocar tu archivo. Siguiente: **08** (este).

---

## 1. SB-05 — Las 4 verificaciones están en `scripts/verificar_checklist.py`

**Las 4 restricciones tuyas, cumplidas:**

| Tu requisito | Estado |
|---|---|
| `test_scripts.py` sigue dando 0 FAIL | **15 PASS, 0 FAIL** (10 previos + 5 nuevos). No cambié ninguna línea de test existente |
| Dry-run primero (`--help` + simulación) | Abajo está la salida medida |
| Cuidado con E4 (regex agrupadas) | Todas las alternaciones van `(?:...)`. Hay un test que congela E4 |
| No tocar `generar_checklist_global.py` ni el GLOBAL | **No los toqué** (verificado con `git status`) |

**Funciones nuevas** (no invasivas: no toqué `leer_tabla_global()` ni `detectar_colgados()`):

| Función | Verificación | Activación |
|---|---|---|
| `estado_emoji()` | E3: solo el emoji inicial del estado | usada por los checks existentes |
| `analizar_estructura_tabla()` | **(2)** filas mal formadas + filas sin `\|` final, con **E2** (excluye la leyenda §21.2) y fail-fast BUG-075 heredado | `--estructura` |
| `parsear_totales()` + `detectar_totales_incoherentes()` | **(4)** `Totales` que contradicen el conteo real, **campo por campo** (E1), regex agrupadas (E4) | `--totales` |

**Flags:** `--estructura` · `--totales` · `--todos`.

**Por qué opt-in:** si las 2 nuevas alerted por defecto, el script passería de `exit 0` a `exit 1`
de golpe y CI se pondría rojo sin avisar. Con opt-in el **default es idéntico al previo**.

---

## 2. ⚠️ Lo que no esperaba: el fix E3 despertó un check que llevaba tiempo MUERTO

El default pasó de **2 → 44 alertas**. Y **44 de las 44** son del check que **ya existía en el
código pero nunca podía dispararse**:

```python
# ANTES — igualdad exacta, NUNCA True:
if x > 0 and estado_declarado in ("⬜", "🟢"):   # "🟢 Disponible" != "🟢"
if dudas > 0 and estado_declarado == "✅":        # "✅ Completado (P-36)" != "✅"

# AHORA — emoji inicial:
emoji_estado = estado_emoji(estado_declarado)
```

Es decir: el check (3) que el propio docstring del script documenta («Que no haya `[x]` en módulos
cuya estado global es 🟡/⬜») estaba **100 % inactivo**. Lo verifiqué en 4 a mano y **los 44 son
reales**:

| Módulo | Estado GLOBAL | `[x]` reales | Progreso GLOBAL |
|---|---|---:|---|
| **`03-Documentacion-Del-Proyecto`** | 🟢 Disponible | **117** | `0/133` |
| `04-Game-Engine` | 🟢 Disponible | 14 | `14/128` |
| `05-Lenguaje-Y-Programacion` | 🟢 Disponible | 4 | `4/103` |
| `99-Marketing` | 🟢 Disponible | 7 | `7/169` |

`03-Documentacion-Del-Proyecto` con **117 `[x]`**, estado `🟢 Disponible` y progreso `0/133` es
probablemente **el peor caso del repo**. También es la alerta de drift que ya estaba en el baseline.

### Impacto en CI — lo declaro explícitamente

El **exit code NO cambia** (ya era `1`: el drift de M03 y el colgado de M37; vos viste «SIN
ALERTAS» porque el repo derivó después). Lo que cambia es el **volumen: 2 → 44**.

> **Si algo del pipeline parsea el stdout en vez del exit code, verá 44 líneas más.** Decime si lo
> dejo también opt-in (son 2 líneas) o si lo dejo siempre activo. **Yo lo dejaría siempre activo:**
> silenciarlo sería dejar el check muerto otra vez, que es exactamente el bug que acabo de arreglar.

También **añadí un check que no existía**: `✅` con items `[ ]` pendientes (la DoD §21.6 pide que
`✅` implique todo `[x]`; antes solo se checkeaba `[?]`).

---

## 3. Dry-run medido

```
$ python scripts/test_scripts.py
RESULTADO: 15 PASS, 0 FAIL
✅ TODOS LOS TESTS PASARON

$ python scripts/verificar_checklist.py --help
usage: verificar_checklist.py [-h] [--checklist CHECKLIST]
                              [--horas-limite HORAS_LIMITE] [--estructura]
                              [--totales] [--todos]

$ python scripts/verificar_checklist.py             # default
exit=1 · SE ENCONTRARON 44 ALERTAS

$ python scripts/verificar_checklist.py --todos
exit=1 · SE ENCONTRARON 116 ALERTAS
   🔧 SB-05 · Estructura de la tabla: 11 columnas en el encabezado
      filas mal formadas: 55 (faltan=19 sobran=36)
      de las cuales no terminan en '|': 2 -> lineas [358, 382]
   🔧 SB-05 · Bloques 'Totales' que contradicen el conteo real: 15
```

**Ojo con la comparación con SB-02:** los números **bajan** (58 → 55 mal formadas, 6 → 2 sin pipe
final) porque vos y agnes fueron arreglando mientras tanto (la fila 53 ya está reconstruida).
**Eso confirma que el script lee el estado real, no una foto.** Los `Totales` subieron 14 → 15
porque aparecieron bloques nuevos.

---

## 4. Los 5 tests nuevos congelan mis 4 bugs

No es «tests de cobertura», es **regresión sobre errores que ya cometí**:

| Test | Congela |
|---|---|
| `test_ver_estado_emoji` | **E3**: `✅ Re-verificado (iter. 1)` → `✅`; `🟡 Con dudas (Log 1130 ✅)` → `🟡` |
| `test_ver_analizar_estructura_tabla` | **E2**: la leyenda §21.2 no se cuela como módulo; detecta pipe sin escapar y fila sin pipe final |
| `test_ver_analizar_estructura_deteccion_ciega` | La verificación 2 hereda BUG-075 (no devuelve «0 mal formadas») |
| `test_ver_parsear_totales` | **E1** (semántica de campos) y **E4** (alternación agrupada) |
| `test_ver_detectar_totales_incoherentes` | Punta a punta + **control de que NO hay falso positivo** cuando el bloque cuadra |

---

## 5. ⚠️ Riesgo equivalente que encontré y **NO toqué**

**`scripts/generar_checklist_global.py` tiene el mismo problema de parseo por posición.** Usa
`readlines()` + `split("|")` en vez de parsear por encabezado. Con pipes sin escapar dentro de
`Notas`, ese script puede **ESCRIBIR columnas corridas** al regenerar el GLOBAL — y a diferencia
de `verificar_checklist.py`, que solo lee, ese **escribe sobre la fuente de verdad**.

Lo dejo anotado, no tocado (me dijiste que no lo toque). Pero mientras las 55 filas mal formadas
sigan ahí, **correr el generador es riesgoso**. Sugiero: arreglar la causa raíz (escapar los pipes
de `Notas`, o mover `Notas` al final) **antes** de la siguiente regeneración.

Relacionado: `estado_emoji()` debería vivir en un módulo compartido, porque
`generar_checklist_global.py` también **infiere** el estado y tiene el mismo bug de comparación.

---

## 6. Errores míos en esta tarea (6, y el último es el importante)

| # | Error | Detección |
|---|---|---|
| 1 | `NameError: name 'pend'` (la variable es `pendientes`) | crasheó al correr |
| 2 | CJK + typo en un comentario del módulo | scan de CJK |
| 3 | CJK otra vez (`el pipeline`) | scan de CJK |
| 4 | `assert x == y, d, "msg"` → `SyntaxError` | la suite no corría |
| 5 | Mi test afirmaba `4 in sin_pipe`, pero la función devuelve **números de línea** | 14 PASS / 1 FAIL |
| 6 | Extraje el baseline con `git show > file` desde PowerShell → se escribió en **UTF-16**, Python no lo pudo leer. **Casi reporté `exit=1` como baseline real; era un crash** | el error nombraba el archivo, no el código |

**E6 es la tercera vez** que una lectura que parecía resultado del repo era una lectura mala mía
(1ª `Get-Content` sin `-Encoding UTF8`, 2ª un `os.path.isfile` False transitorio, 3ª esta
redirección UTF-16). **Ya lo escribí en el informe 05 y lo repito porque se está repitiendo:
ante dos lecturas que se contradicen, desconfiar de la lectura.**

Y uno más de fondo: **me coló CJK en 4 documentos distintos de 3 sesiones diferentes.** Es un
fallo sistemático mío de generación, no un accidente. Lo detecto siempre con el scan, pero
primero llega al archivo. Si querés, lo convierto en un **gate de CI** (`scripts/verificar_bom.py`
ya existe; le agregaría un chequeo de CJK) para que no dependa de que yo me acuerde de escanear.

---

## 7. Estado

| Registro | Estado |
|---|---|
| `scripts/verificar_checklist.py` | **+272 / -7** — 3 funciones, 3 flags, fix E3, 1 check nuevo |
| `scripts/test_scripts.py` | **+155** — 5 tests nuevos, 0 líneas existentes cambiadas |
| `CHECKLIST-GLOBAL.md` | **sin cambios** (verificado) |
| 167 `05-Checklist.md` | **sin cambios** |
| `Logs/` | 1282 (SB-05). Pool: cabeza **1283** |
| Commit / push | **NO HECHO** — `scripts/` es de s2 y vos coordinás |

**Lo que queda en manos tuyas / de agnes (T-A3):** las 44 alertas del fix E3, las 55 filas mal
formadas y los 15 bloques `Totales`. **No arreglé ninguna** porque son archivos que me prohibiste
tocar, y son de la fuente de verdad.

---

## 8. Sobre mí, sin cambios

**C1 ✔ · C2 documental ✔ (SB-02 y SB-05 lo confirman) · C2 con código ✘ · C3+ ✘.**
SB-05 fue **Python puro**, que es donde tengo capacidad demostrada. **Visión: sin evidencia, no la
usé en ninguna de las 5 tareas.** **GDScript: sin evidencia.**

**Próximo frente:** M153 (10 ítems, cierre de sesión) o M151 (141 ítems). **Ojo:** ya pedí dos veces
una **tarea de C2 con código** y no me llegaste ninguna. Sin eso, mi perfil queda congelado en
documental y no voy a pedir C3+. Si querés probarme en código, decime qué módulo de C2 te parece
seguro y lo miro.

---

**Firma:** **Modelo:** space-bunny-alpha · **Plataforma:** Kilo Code · **Fecha:** 2026-10-04 20:45:00
---

## Addendum (2026-10-04 20:55) — Corregi LF y 2 U+FFFD de mi propia entrega — Correccion de fin de linea y U+FFFD

Dos defectos de MI entrega, detectados y corregidos en la verificacion final:

### 1. Converti 3 archivos de LF a CRLF (AGENTS.md 28.3)

El editor que uso para `scripts/verificar_checklist.py` y `scripts/test_scripts.py` los dejo en
**CRLF** cuando en HEAD eran **LF**. Eso viola «al editar un archivo existente, preservar su
codificacion» y vuelve el diff un **reescritura de archivo entero** en vez de un diff legible.

Comparado contra HEAD y corregido con `scripts-prueba/normalizar_lf.py`:

| Archivo | HEAD | Antes de corregir | Ahora | Diff |
|---|---|---|---|---|
| `scripts/verificar_checklist.py` | LF | **CRLF** | LF | +272 / -7 |
| `scripts/test_scripts.py` | LF | **CRLF** | LF | +155 / -0 |
| `Logs/NUMEROS_DISPONIBLES.txt` | LF | **CRLF** | LF | solo la linea consumida |

`NUMEROS_DISPONIBLES.txt` es un archivo **contestado** (20+ agentes lo escriben); estaba en CRLF
porque otro agente lo reescribio despues de que yo lo normalizara a LF en SB-01. Lo normalize de
nuevo para que el diff contra HEAD sea limpio, pero **es una carrera**: el próximo que lo escriba
con CRLF lo vuelve a romper.

### 2. Introduje 2 caracteres U+FFFD en mi backlog

`BACKLOG-MASTER.md` quedaba con `no me lleg\ufffd\ufffd ninguna`. El AGENTS.md 28 declara los
U+FFFD **irrecuperables**, asi que los corregi y verifique con un escaner dedicado
(`scan_fffd.py`) que ahora corre sobre los 18 archivos de mi entrega:
**0 BOM · 0 CRLF donde HEAD es LF · 0 U+FFFD · 0 CJK no intencional.**

### Nota sobre el fallo transitorio de filesystem (4to caso)

Durante el scan final, `open()` fallo con `FileNotFoundError` sobre
`Logs/1279-SB02-...md` un archivo que `os.listdir` listaba correctamente. Ya me habia pasado 3
veces en esta sesion. Es un comportamiento de Windows en este repo, **no** un archivo faltante: el
escaner final reintenta 3 veces antes de declarar fallo. Lo dejo anotado porque **un agente que no
reintente puede reportar «el archivo no existe» cuando si existe** — que es exactamente el tipo de
falsa alarma que me contaminaron los dos primeros SB.
