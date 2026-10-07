# Log 1418: BUG-095 verificado — agnes ya lo había cerrado, re-verificación independiente 149 checks / 0 fallos

**Fecha:** 2026-10-07
**Hora:** 03:09
**Modelo:** atria-dawn-s2
**Plataforma:** Kilo Code

## Resumen

El director (canal 114) me delegó BUG-095 (`item_data.gd:88` `es_valido()` con precedencia de
operadores mal) creyendo que estaba "sin fix visible todavía". **Verifiqué contra disco: agnes
ya lo había fixeado y cerrado** en su tanda del 2026-10-07. Realicé la re-verificación
independiente que pide el protocolo (comando + output reales) y confirmé la suite verde.

## Verificación contra disco

**Fix presente** en `game/isla-ancestral/scripts/data/item_data.gd:88`:

```gdscript
func es_valido() -> bool:
	return id != "" and nombre != "" and (tamano.x > 0) and (tamano.y > 0)
```

Paréntesis explícitos correctos. La versión buggy original era
`id != "" and nombre != "" and not tamano.x <= 0 or tamano.y <= 0` donde `and` liga más que
`or`, dando `(A and B and C) or D` → `tamano=(1,0)` devolvía `true`.

**Segundo archivo descartado:** existe otro `scripts/utils/data/item_data.gd` (11 líneas,
`class_name ItemDataStruct`, M111) — struct distinto, no relacionado con el bug.

## Re-verificación independiente (comando + output reales)

```
godot472.exe --headless --path . --script res://tests/unit/data/test_item_data.gd
```

Salida real (fragmento relevante):

```
[FIN] H. test_es_valido_true (+1 checks)
[FIN] I. test_es_valido_false_no_id (+1 checks)
[FIN] J. test_es_valido_false_no_nombre (+1 checks)
-- K. test_es_valido_false_invalid_size --
  [OK] item.es_valido() .is_false()
  [OK] item.es_valido() .is_false()
  [OK] item.es_valido() .is_false()
[FIN] K. test_es_valido_false_invalid_size (+3 checks)
...
Checks por bloque: { "A": 7, "B": 16, "C": 4, "D": 14, "E": 2, "F": 1, "G": 2, "H": 1, "I": 1, "J": 1, "K": 3, "L": 1, "M": 1, "N": 2, "O": 1, "P": 11, "Q": 79, "R": 1 }
=== Resumen Unit tests ItemData + ItemDatabase: 149 checks, 0 fallos ===
```

**149 checks, 0 fallos, 0 SCRIPT ERROR.** El test K (3 checks) es el que cubre BUG-095:
tamaños inválidos → `es_valido()` devuelve `false`. Coincide con el reporte de agnes.

## Cambios Realizados

- `DOCUMENTACION/11-BUGS.md`: agregada mi re-verificación a la fila BUG-095 (comando +
  output reales, firma atria-dawn-s2 2026-10-07). El bug ya estaba marcado `[x] Resuelto
  2026-10-07` por agnes; yo sumé la confirmación independiente.
- **No se tocó código** — el fix ya estaba correcto en disco. `CHECKLIST-GLOBAL.md` no se
  tocó (regla del director: flips son suyos).

## Nota técnica: falsa alarma de mojibake descartada

Al inspeccionar el archivo con PowerShell, la salida de la consola mostró `crÃ­ticos` en el
comentario L86 (añadido por agnes). Verifiqué a nivel de bytes: el archivo es **UTF-8
válido** (4 secuencias `í` = `0xC3 0xAD` correctas, sin dobles codificaciones). La
deformación era un **artefacto de visualización de la consola de Windows**, no del archivo.
Lección: confirmar mojibake con el Read tool o a nivel de bytes antes de declararlo (§28).

## Archivos Modificados/Creados

- `DOCUMENTACION/11-BUGS.md` (fila BUG-095 re-verificada)
- `Logs/1418-...md` (este log)
- `Logs/NUMEROS_DISPONIBLES.txt` (1418 consumido: 1583 → 1582 líneas)

## Huella de push §4.3

- **Rango empujado:** `d9534a0..8a6d504` (main → main)
- **Fecha/hora:** 2026-10-07 07:30
- **Ejecutante:** atria-dawn-s2 (Kilo Code)
- **Tipo:** push principal de este turno (Log 1418 + 11-BUGS.md + canal 115), autorizado por
  el director en el canal 116.

### Rebase documentado (push paralelo de DeepSeek)

Antes de empujar, `git fetch` mostró `main [ahead 9, behind 3]`: DeepSeek había empujado 3
commits de M24 iter.3 (familia bloques + plan/resultados de testings, Log 1426) en paralelo
(autorizado por el director en el canal 116).

1. **Stash preventivo** de 41 archivos modified sin commitear (trabajo de mimo/agnes/kimi,
   incluyendo `interaction_manager.gd`, que tengo prohibido tocar) — preservados íntegros y
   restaurados tras el push (`git stash pop`, 36 restaurados).
2. **`git pull --rebase origin main`** — falló primero por 8 archivos untracked de DeepSeek
   (M24) que origin también crea. Se respaldaron fuera del repo
   (`C:\Users\MAURY-~1\AppData\Local\Temp\kilo\s2-rebase-bak-20261007`), se removieron, y el
   rebase completó **9/9 sin conflictos**.
3. **Verificación post-rebase:** los 4 archivos de código de DeepSeek llegaron **idénticos**
   (hash) a las versiones locales; los 4 docs/logs/mensajes difieren solo en **CRLF vs LF**
   (diff textual = 0, normalización de git en checkout de Windows). **Cero pérdida de
   contenido.**
4. **Push:** `d9534a0..8a6d504`. `HEAD == origin/main == 8a6d504`, ahead=0.
5. Mi commit BUG-095 quedó rehashado: **`54b3629`** (antes `2750328`).

**Nota para DeepSeek:** si tu working tree tenía esos 4 archivos (06-Plan-Testings.md,
07-Resultados-Testings.md, Log 1426, canal 73) en LF puro, ahora están en CRLF en el working
tree por el checkout de git — el contenido es idéntico, no hay que reescribirlos.
