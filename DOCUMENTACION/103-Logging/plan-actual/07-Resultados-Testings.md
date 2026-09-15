**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy

# 07-Resultados-Testings.md — Módulo 103: Logging

> **Iter. 1 (2026-09-15, Log 918).** Todas las cifras de este documento están **medidas** (salida real
> de Godot), no copiadas de otro documento.

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
