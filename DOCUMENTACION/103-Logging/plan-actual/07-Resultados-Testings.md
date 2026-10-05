**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# 07-Resultados-Testings.md — Módulo 103: Logging

> **Iter. 1 (2026-09-15, Log 918).** Todas las cifras de este documento están **medidas** (salida real
> de Godot), no copiadas de otro documento.
>
> **Iter. 2 (2026-09-19, Log 1109).** Ver §9 al final: auditoría de suites muertas, endurecimiento de
> las 3 suites, **11 checks inalcanzables resucitados** y la **medición del frame budget** que cierra
> el ítem L199 (hallazgo → BUG-067).

## 1. Entorno

- Godot **4.7.2.stable.official** (ed1daf0bf), headless.
- Ejecutable: `D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe` (es un **directorio**).
- Comando: `--headless --path game/isla-ancestral --script res://scripts/logging/test_logging_m103_iter1.gd`

## 2. Resultado global (3 corridas consecutivas)

| Corrida | Checks | Fallos | `SCRIPT ERROR` | Exit |
|---|---|---|---|---|
| 1 | 131 | 0 | 0 | 0 |
| 2 | 131 | 0 | 0 | 0 |
| 3 | 131 | 0 | 0 | 0 |

```
=== Resumen M103 iter. 1: 131 checks, 0 fallos ===
TEST M103 iter. 1 OK — todos los checks pasaron
```

**Determinista:** las 3 corridas dieron el mismo total y el mismo desglose.

## 3. Desglose por bloque (medido)

```
-- checks por bloque: { "A": 33, "B": 10, "C": 5, "D": 9, "E": 10, "F": 12, "G": 19, "H": 11, "I": 6, "J": 15 }
```

| Bloque | Checks |
|---|---|
| A. Autoload, registro y API pública | 33 |
| B. Niveles y filtrado | 10 |
| C. Categorías | 5 |
| D. Formato humano | 9 |
| E. Formato JSON | 10 |
| F. Sanitización de datos sensibles | 12 |
| G. Exportación | 19 |
| H. Rotación (disparada desde `_log`) + `LogRotator` | 11 |
| I. Persistencia inmediata + señal `line_emitted` | 6 |
| J. Configuración | 15 |
| **Suma de bloques** | **130** |
| **+ check del guardián** (`los 10 bloques se completaron`) | **1** |
| **Total del `Resumen`** | **131** |

✅ La suma de bloques **cuadra** con el total (130 + 1 = 131). Este cuadre es un criterio de aceptación
precisamente porque en M60 se detectó que las cifras publicadas estaban **copiadas** y no medían.

## 4. Prueba del guardián anti-falso-verde (por inyección)

No basta con que el guardián exista: hay que **comprobar que falla cuando debe**. Se copió la suite a
`_tmp_guard_probe.gd` y se inyectó un aborto al principio del bloque D
(`var nulo = null; nulo.metodo_inexistente()`), que en GDScript aborta la función **en silencio**:

```
[FIN] A. Autoload, registro y API pública (+33 checks)
[FIN] B. Niveles y filtrado (+10 checks)
[FIN] C. Categorías (+5 checks)
SCRIPT ERROR: Invalid call. Nonexistent function 'metodo_inexistente' in base 'Nil'.
[FIN] E. Formato JSON (+10 checks)
...
-- checks por bloque: { "A": 33, "B": 10, "C": 5, "E": 10, "F": 12, "G": 19, "H": 11, "I": 6, "J": 15 }
  [FALLO] los 10 bloques se completaron (sin abortos silenciosos) — bloques que no terminaron: ["D"]
=== Resumen M103 iter. 1: 122 checks, 1 fallos ===
TEST M103 iter. 1 FALLIDO — salida con código 1
```

Resultado: **el bloque D desaparece del desglose**, el guardián **lo nombra** (`["D"]`), la suite cae de
**131 a 122** checks y sale con **EXIT 1**. La sonda se retiró y la suite volvió a 131/0 ×3.

## 5. Defectos reales encontrados por la suite (no cosmética)

| # | Defecto | Cómo se detectó | Impacto |
|---|---|---|---|
| 1 | `log_buffer` era **código muerto**: nadie hacía `append`, así que `_flush()` era un **no-op permanente** | auditoría de código + grep global (sólo aparecía en `logger.gd` y en docs) | Engaño: la documentación prometía un buffer que no existía |
| 2 | **La rotación no se disparaba nunca desde `_log()`** — sólo se comprobaba en `flush()` explícito | bloque H: 40 líneas sin `flush()` no producían `.1.gz` | **El archivo activo podía crecer sin límite** (RF15 incumplido en la práctica) |
| 3 | **`json_output` con contexto generaba JSON INVÁLIDO**: faltaba la coma antes de `"context"` | bloque E: `JSON.parse_string` → `Expected '}' or ','` | Toda línea con contexto era ilegible para cualquier herramienta |
| 4 | **`export_by_date(hours)` era un no-op**: comparaba en **días enteros** (`hours < 24` ≡ 24) y su regex exigía un **espacio**, pero Godot emite `T` → ninguna línea coincidía y el `else` devolvía **todo** | bloque G: `export_by_date(-1)` seguía devolviendo las líneas | El filtro por fecha no filtraba **nada** |
| 5 | `export_by_level` / `export_by_category` **sólo entendían el formato humano** | bloque G (mitad JSON) | Con `json_output=true` devolvían vacío |
| 6 | `_json_escape` no escapaba **CR** ni **TAB** | bloque E: tabulador crudo dentro del JSON | JSON frágil ante mensajes con tabulaciones |
| 7 | `LogRotator.get_size()` devolvía **caracteres**, no bytes | bloque H: `"áéíóúñ"` → 6 en vez de 12 | El nombre de la función prometía bytes |

Los 7 quedaron corregidos en `logger.gd` / `log_rotator.gd` y **verificados** por la propia suite.

## 6. Regresión (no romper consumidores)

| Suite | Resultado |
|---|---|
| `scripts/logging/test_logger.gd` | **14 / 0** ✅ (antes y después del refactor) |
| `scripts/logging/test_logging_m103.gd` | **14 / 0** ✅ |
| `scripts/datos/test_datos_m60_iter4.gd` (usa `GameLogger` intensivamente) | **152 / 0** ✅ |
| `grep -rn "log_buffer" game/**/*.gd` | sólo comentarios → nadie consumía la variable eliminada |

Además, `--check-only --script` sobre `logger.gd`, `log_rotator.gd`, `sensitive_data_sanitizer.gd`,
`log_exporter.gd` y `logging_config.gd`: **0 errores de parseo**.

## 7. Hallazgos que NO son de esta iteración

- **`data/logging/logger_config.json` es huérfano.** El bloque J recorre `res://scripts/` entero y
  comprueba que **ningún** script de producción lo referencia; además **contradice** la config real
  (`nivel_por_defecto: INFO` / `max_tamano_bytes: 512000` / `niveles: [DEBUG, INFO, WARN, ERROR]`
  frente a `level_min = 0` / `10 MB` / `[DEBUG..CRASH]`). **No se borra** para no alterar el manifiesto
  `data.drift.json` de otro equipo (que ya reporta **21 cambios ajenos** sin commitear).
- **`LogRotator.rotate()` no puede renombrar un archivo que el logger mantiene abierto** (Windows: el
  `rename` falla y el error se ignora en silencio). Se descubrió porque un check propio fallaba; la
  sonda aislada demostró que `rotate()` funciona bien sobre un archivo **cerrado**. El flujo interno
  (`_rotate()`) cierra primero, así que **no afecta en producción**.
- **Ajeno (para M38, no para M103):** de los 6 tests de economía/tiendas/tiempo del ítem N20,
  **5 pasan** (`test_m38_economia_smoke`, `test_barter`, `test_tiendas`, `test_consumidores_tiempo`,
  `test_reloj_hud`) y **`shops/test_loop_economico.gd` da 14/1** por «precio compra definido».
  **No es una regresión de M103**: probado **por dependencia** — ese test no menciona `GameLogger`
  ni `logger` en ninguna línea, y `scripts/economia/` tiene **5 archivos modificados + 4 tests nuevos
  sin commitear** de otro agente. Por eso el ítem N20 queda en `[?]` y no en `[x]`.

## 8. Reproducir

```bash
GODOT="D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
for i in 1 2 3; do
  "$GODOT" --headless --path game/isla-ancestral \
    --script res://scripts/logging/test_logging_m103_iter1.gd 2>&1 | grep -E "Resumen|SCRIPT ERROR"
done
```

Esperado: tres veces `=== Resumen M103 iter. 1: 131 checks, 0 fallos ===` y ningún `SCRIPT ERROR`.

---

## 9. Iter. 2 (2026-09-19, Log 1109) — auditoría, endurecimiento y medición del frame budget

### 9.1 Resultado global (4 suites × 3 corridas)

| Suite | Checks | Bloques | Fallos | `SCRIPT ERROR` | Exit | Determinista ×3 |
|---|---|---|---|---|---|---|
| `test_logger.gd` | 14 | A2 B4 C4 D2 E1 F1 | 0 | 0 | 0 | ✅ 14/14/14 |
| `test_logging_m103.gd` | 25 | A10 B4 C3 D8 | 0 | 0 | 0 | ✅ 25/25/25 |
| `test_logging_m103_iter1.gd` | 131 | A33 B10 C5 D9 E10 F12 G19 H11 I6 J15 | 0 | 0 | 0 | ✅ 131/131/131 |
| `test_m103_frame_budget.gd` (**nuevo**) | 9 | A3 B4 C2 | 0 | 0 | 0 | ✅ 9/9/9 |
| **Total** | **179** | | **0** | **0** | **0** | |

### 9.2 Los 2 defectos reales que encontró la auditoría

| # | Defecto | Cómo se detectó | Impacto |
|---|---|---|---|
| 1 | **`test_logging_m103.gd` tenía 11 checks INALCANZABLES** (trampa 46): `_test_export()` y `_test_rotation()` estaban **definidos y nunca llamados** desde `_run()` | lectura del flujo de llamadas: la suite publicaba «14 checks» pero **jamás** ejercitaba `export_last_lines()` ni los 8 métodos de rotación | La suite daba una **cobertura falsa**: prometía export y rotación que nunca corrían. Ahora los llama → **25 checks** |
| 2 | **`test_logger.gd` no limpiaba su archivo exportado**: reconstruía el nombre del export a partir del reloj **actual**, así que `_limpiar()` borraba **otro** nombre y el temporal quedaba en disco | revisión del bloque de limpieza (trampa de estado residual) | Basura en `user://` entre corridas; podía dar verde/rojo según el segundo exacto |

**Las 3 suites del módulo no tenían** (a) `_summary()` diferido —trampa 61: si vive al final de
`_run()`, un aborto se lleva el `quit()` y el `SceneTree` **cuelga**— ni (b) **piso de checks**. Las
dos cosas se añadieron.

### 9.3 Guardián probado EN ROJO por inyección (4 suites)

Aborto inyectado dentro de un helper, vía un intermedio sin tipo (para que el `SCRIPT ERROR` **no**
detenga `_run()` sino que se coma los checks del bloque):

| Suite | Antes | Tras la inyección | Bloques nombrados | Exit |
|---|---|---|---|---|
| `test_logging_m103.gd` | 25 | **11** | `["B","C","D"]` | **1** (sin colgar) |
| `test_logger.gd` | 14 | **7** | `["C","D","E","F"]` | **1** (sin colgar) |
| `test_logging_m103_iter1.gd` | 131 | **126** | `["C"]` | **1** (sin colgar) |
| `test_m103_frame_budget.gd` | 9 | **4** (2 fallos) | `["B","C"]` | **1** (sin colgar) |

Puntos de inyección (documentados, para poder repetirlo):

| Suite | Dónde se inyectó |
|---|---|
| `test_logging_m103.gd` | tras cerrar el bloque **A** (sólo A completo) |
| `test_logger.gd` | tras cerrar el bloque **B** (A y B completos) |
| `test_logging_m103_iter1.gd` | **dentro del helper** del bloque C (C no cierra; D..J sí) |
| `test_m103_frame_budget.gd` | al inicio del bloque **B** (`_run()` aborta: no cierran B ni C) |

Las sondas eran **copias temporales** (`_tmp_probe_*.gd`) y se borraron; las suites volvieron a su
total ×3. En **las 4** se dispararon **las dos** defensas a la vez —el guardián de bloques *y* el piso
(`solo N checks ejecutados (minimo M)`)— y las 4 salieron con **exit 1 sin colgarse** (trampa 61
cubierta: el `_summary()` diferido imprime aunque `_run()` aborte).

### 9.4 Medición del frame budget (cierra el ítem L199)

Metodología: `RONDAS := 5` **intercaladas** (no 5 corridas seguidas del mismo orden) y **mínimo por
variante**; trampa 78 — un benchmark de una sola pasada en orden fijo miente. `ITERACIONES := 200`.

```
-- presupuesto: 0.50% de 16.67 ms (60 FPS) = 83.35 us por frame
     gate is_level_enabled ....... 0.140 us
     llamada FILTRADA ............ 1.110 us   (caben 75 por frame en el 0.5%)
     solo disco (store+flush) .... 4.925 us
     llamada que ESCRIBE (total).. 512.310 us   (caben 0 por frame en el 0.5%)
-- ATRIBUCION del coste de escribir: disco=1%  resto(consola+formato)=99%
```

Sonda aislada de atribución (`N := 50`, salida a **archivo** para no medir la tubería): `print()`
**430,8 µs (86 %)** · `FileAccess` + `flush` **11,4 µs (2 %)** · sin `flush` **1,4 µs**.

**Lectura honesta:**

- Lo que mantiene el coste fuera del frame es el **gate por nivel** (0,14 µs). Una llamada **filtrada**
  cabe ~75 veces por frame; una que **escribe**, **0**.
- **El buffer de escritura que pedía el diseño no habría servido de nada**: ataca el **1 %** (disco) y
  el cuello de botella es el **99 %** (consola+formato). Por eso el ítem se cierra como innecesario y
  no como «implementado».
- **El diseño se contradice** (`03-Diseno.md` §3 pide `print` a consola **y** < 0,5 %; §10 Regla 5 pide
  buffer+flush periódico mientras el código hace flush por línea): bajo tubería un `print` cuesta
  ~35× más que a archivo. Registrado como **BUG-067**.

### 9.5 Regresión (ítem L240, cerrado)

| Suite | Resultado |
|---|---|
| `scripts/economia/test_m38_economia_smoke.gd` | exit 0 ✅ |
| `scripts/economia/test_barter.gd` | exit 0 ✅ |
| `scripts/shops/test_tiendas.gd` | exit 0 ✅ |
| `scripts/time/test_consumidores_tiempo.gd` | exit 0 ✅ |
| `scripts/clock/test_reloj_hud.gd` | exit 0 ✅ |
| `scripts/shops/test_loop_economico.gd` | **15 checks / 0 fallos** ✅ (antes daba **14/1**: el dueño de M38 lo arregló) |

**6 de 6**, así que el ítem N20 pasa de `[?]` a `[x]`.

### 9.6 Reproducir (iter. 2)

```bash
GODOT="D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
for S in test_logger test_logging_m103 test_logging_m103_iter1 test_m103_frame_budget; do
  for i in 1 2 3; do
    "$GODOT" --headless --path game/isla-ancestral \
      --script "res://scripts/logging/$S.gd" 2>&1 | grep -E "Resumen|SCRIPT ERROR"
  done
done
```

Esperado: 14 · 25 · 131 · **14** checks, **0 fallos**, ningún `SCRIPT ERROR`, exit 0, tres veces cada uno.

### 9.7 BUG-067: fix del eco a consola (iter. 2-bis, Log 1180)

La medición de iter. 2 dejó abierto BUG-067: una llamada que **escribe** no cabía en el frame (512 µs)
y el diseño se contradecía (`03-Diseno.md` §3 pedía `print` a consola **y** < 0,5 %). El coste se
atribuyó al `print()` (99 %), no al disco (1 %). Fix aplicado: **gate del eco a consola**
(`console_echo`, default `true` = comportamiento histórico intacto).

`test_m103_frame_budget.gd` mide ahora **5 variantes** (la 5ª es la misma llamada que escribe pero con
`set_console_echo(false)`). Resultado (mínimo de 5 rondas intercaladas, salida a tubería):

| Variante | Coste | ¿Cabe en 83,35 µs? |
|---|---|---|
| llamada FILTRADA (gate de nivel) | ~1,1 µs | sí |
| solo disco (store+flush) | ~5 µs | sí |
| ESCRIBE (eco encendido, default) | ~14 138 µs | no (17 % del frame) |
| **ESCRIBE con eco APAGADO** | **~40,5 µs** | **sí -- 49 % del presupuesto** |

El número absoluto se **reporta** (`-- VEREDICTO`), **no** se asevera como gate (depende de la máquina;
`quality.yml:285` lo corre como gate duro). Lo asertado es un **orden** con holgura (`< 3x`).

`CHECKS_MINIMOS` 9 → 12. Totales M103: **14 + 25 + 131 + 14 = 184 checks / 0 fallos**, sin `SCRIPT ERROR`.

### 9.8 T-D8: cierre del falso positivo del frame-budget — opción (b) (2026-10-05, Log 1323)

**El falso positivo (documentado por el director, mensaje 29):** el coste **absoluto** del `print()` a
stdout depende del **destino** (tubería de CI vs archivo, **~25-35x**). La suite aseveraba la
atribución con **ratios contra la llamada que ESCRIBE** (`_min_gateada < _min_escritura * 0.20`,
`_min_filtrada < _min_escritura * 0.05`): bajo tubería daban 0,1-0,2 % y pasaban; con la escritura
barata (archivo, o un runner más rápido) el mismo ratio sube y el gate **se pondría ROJO sin que
nada del logger haya cambiado** → falso positivo (un gate que depende del entorno, no del código).

**Decisión: opción (b)** — comparar el eco contra una **constante medida en local**, no contra la
tubería del runner. La constante elegida es el **suelo del disco** (`_min_disco`, `store_line`+`flush`
por línea), que es **estable e independiente del destino de stdout**.

**Reproducir (medido, ambos destinos):**

```bash
GODOT="D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
# a tubería (como CI):      ... | grep ATRIBUCION
"$GODOT" --headless --path game/isla-ancestral --script res://scripts/logging/test_m103_frame_budget.gd
# a archivo (como local):   > out.txt 2>&1 ; grep ATRIBUCION out.txt
"$GODOT" --headless --path game/isla-ancestral --script res://scripts/logging/test_m103_frame_budget.gd > out.txt 2>&1
```

| Destino de stdout | eco (escritura-gateada) | suelo del disco (constante) | ratio eco/disco | ¿14/0? |
|---|---|---|---|---|
| **tubería** (3 corridas) | 10 460 · 7 414 · 10 549 µs | 5,9 · 5,8 · 8,2 µs | 1 774x · 1 289x · 1 285x | **sí** |
| **archivo** (3 corridas) | 619 · 531 · 566 µs | 6,0 · 6,5 · 7,2 µs | 103x · 82x · 78x | **sí** |

**Lectura:** el eco absoluto cae **~17x** entre tubería y archivo (10 460 → 619 µs), que es
exactamente el artefacto del destino; pero **siempre supera el suelo del disco** (78x-1 774x) →
la aserción `escritura > gateada + disco` es **cierta en ambos entornos**. El ratio eco/disco se
**reporta**; la aserción es de **orden** (supera el disco), no de proporción.

**Cambios en la suite (14 checks, siguen siendo 14):**
- Se **eliminan** las dos aserciones con ratio contra `_min_escritura` (destino-dependientes).
- `_min_filtrada < _min_escritura * 0.05` → `_min_filtrada < _min_disco` (constante local).
- `_min_gateada < _min_escritura * 0.20` (eco ≥ 80 %) → `_min_escritura > _min_gateada + _min_disco`
  (el eco supera el suelo del disco ⇒ el coste es el `print()`, no el disco).
- El veredicto de presupuesto (`us_gateada`) se **reporta** y se asevera con holgura (`< 3x`), como
  antes (su valor absoluto depende de la máquina, no del destino).

**Guardián probado EN ROJO por inyección** (aborto al inicio del bloque B vía intermedio sin tipo):
`_run()` aborta tras A → `6 checks, 2 fallos`, nombra `["B","C"]`, dispara el piso `solo 6 checks
(minimo 14)` y sale con **exit 1 sin colgarse**. Sonda borrada.

**Veredicto:** M103 sigue en **184 checks / 0 fallos** (14+25+131+14) en tubería **y** en archivo,
sin `SCRIPT ERROR`. El ítem L199 sigue `[x]` (medido) y ahora el gate es **determinista en cualquier
entorno**.
