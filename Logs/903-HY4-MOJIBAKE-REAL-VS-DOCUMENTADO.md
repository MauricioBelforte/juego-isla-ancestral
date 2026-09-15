# Log 903: Mojibake real vs. documentado — triaje y cierre del verificador

**Fecha:** 2026-09-14
**Modelo:** Hy4 / WorkBuddy
**Plataforma:** WorkBuddy
**Módulo:** transversal (higiene de codificación, §28)
**Reserva:** `Logs/reservas/903-HY4-MOJIBAKE.txt`
**Encaje:** Opción B del backlog HY4 — "parchar huecos", tarea 1 de 4.

## 0. Contexto

El backlog propio (`TAREAS-POR-MODELO/HY4/BACKLOG-MASTER.md`) arrastraba la
entrada "mojibake real (7 archivos)". Al ejecutar `scripts/diagnosticar_mojibake.py`
el resultado era:

```
Archivos con marcadores: 154
  SUCIO           19
  IRREVERSIBLE     3
  EXCLUIDO       132
```

La hipótesis de trabajo era que esos 22 marcadores eran corrupción pendiente.
**La hipótesis era falsa** y es el hallazgo de este log.

## 1. Hallazgo principal — el 100 % de lo restante era documentación

Se inspeccionó el contexto byte a byte de cada marcador. Los 22 restantes
citan el mojibake **a propósito**:

| Archivo | Línea | Qué es |
|---|---|---|
| 11 × `TAREAS-POR-MODELO/*/BACKLOG-MASTER.md` | 12–14 | banner: "Los caracteres rotos (Ã³, â€", ðŸŸ¢, etc.)…" |
| `CHECKLIST-GLOBAL.md` | 7 | banner: "CODIFICACIÓN UTF-8 OBLIGATORIA … sufrió doble encoding" |
| `CONTEXTO-PROXIMO-AGENTE/05-…M34-M93…` | 87 | "810 runs de mojibake REAL … doble codificación UTF-8→cp1252→UTF-8" |
| `CONTEXTO-PROXIMO-AGENTE/06-…Saneamiento…` | 271 | "Bytes crudos del archivo: `C3 B0 C5 B8 C5 B8 C2 A1`" |
| `scripts/fix_emoji.py` | 10 | tabla de búsqueda del reparador |
| `scripts/saneamiento_utf8.py` | 7 | documenta la transformación F0 9F 9F A1 → ðŸŸ¡ |
| `scripts/fix_final3.py` / `fix_final4.py` | 7 / 16 | comentarios con ejemplos de bytes |
| 4 × `tools/mcp/godot-mcp/node_modules/**` | — | **terceros**, fuera de alcance |

Ejecutar `fix_encoding.py` sobre ellos habría **destruido las guías y las
tablas de los propios reparadores**. Este es el modo de fallo que el
verificador documenta en su cabecera ("si una sola herramienta detecta y
repara, un falso positivo en la detección se convierte en una escritura
destructiva silenciosa") — y estaba a punto de ocurrir.

## 2. Lo que SÍ era corrupción real: `CHECKLIST-GLOBAL.md`

Reparado en el commit **`f308b7c`** (trabajo previo de esta misma tarea):

- 8 marcadores reales corregidos por byte-inverso exacto (doble codificación
  Latin-1: `ðŸ“¡`→📡 ×2, `ðŸ—¸`→🗸 ×4, `ðŸŸµ`→🔵 ×1).
- 1 falso positivo preservado: el banner de la L7.
- 1 caso **irreversible** (contiene U+FFFD): reconstruido como `×`.
  Verificado ahora por contexto → `NpcPortraitUI (150×150, tint
  EXPRESION_TINT …)`, un retrato de 150×150 px. La reconstrucción es correcta.
- Verificación post-escritura: UTF-8 estricto, sin BOM, 220 CRLF / 0 LF suelto,
  −32 bytes, banner intacto.

## 3. Cambios en el verificador (commit `c952bdf`)

`scripts/diagnosticar_mojibake.py`:

1. **`PAT_LINEA_DOC`** — filtra por **contenido de línea**, no por ruta. Así
   sigue funcionando cuando aparezcan backlogs o guías nuevos con el banner,
   en lugar de exigir mantener a mano una lista de 13 rutas.
2. **`EXCLUIDOS_ARCH`** — se añaden `fix_emoji`, `saneamiento_utf8`,
   `fix_final3`, `fix_final4`.
3. **`EXCLUIDOS_SUELTOS`** — se añaden `node_modules` y `site-packages`.
   El `./node_modules` de `EXCLUIDOS_DIR` nunca funcionó para
   `tools/mcp/godot-mcp/node_modules/…` porque la comparación era por prefijo.

Resultado:

```
Archivos con marcadores: 135
  SUCIO           0
  IRREVERSIBLE    0
  EXCLUIDO      135

LIMPIO: no queda mojibake reparable.
```

## 4. Guarda contra el falso verde — `scripts/test_diagnosticar_mojibake.py`

Un filtro por contenido tiene un riesgo obvio: **si se vuelve laxo, el
verificador deja de detectar corrupción real y da un falso verde permanente**,
exactamente lo que AGENTS.md §21.4 manda evitar. Por eso se añade una prueba
de regresión con 7 casos:

- 3 de **mojibake real** (acento, emoji, raya/comilla) → el filtro **no** debe
  ocultarlos.
- 4 de **documentación** (los 4 tipos de banner/comentario/volcado) → el filtro
  **sí** debe ocultarlos.

Cada caso exige además que la línea tenga marcador: un caso sin marcador no
probaría nada. (Primera versión de la prueba falló esto: los casos "reales"
estaban escritos sin acentos y daban `marcador=False`; se corrigió.)

```
python scripts/test_diagnosticar_mojibake.py   # 7/7 OK, exit 0
```

## 5. Límites honestos

- El filtro por contenido es **heurístico**: una línea de contenido real que
  mencionara "mojibake" o un volcado `C3 B0` quedaría sin revisar. La prueba
  de regresión acota el riesgo pero no lo elimina. Si alguien repara corrupción
  a mano, conviene desactivar el filtro y revisar el fichero completo.
- La reconstrucción `150×150` es la única escritura **no verificable por
  decodificación** (los bytes originales se perdieron en un `errors='replace'`
  previo). Está confirmada por contexto, no por bytes.
- No se tocó `node_modules`: es código de terceros y queda fuera de §28.

## 6. Estado de la tarea

Tarea 1 de la Opción B: **cerrada**. El backlog puede tachar "mojibake real".

Sigue: tarea 2 — auditar los 14 módulos sobre-cerrados
(136, 49, 135, 133, 153, 119, 66, 166, 134, 83, 149, 145, 146, 115).

## 7. Commits

| Commit | Contenido |
|---|---|
| `f308b7c` | Reparación del mojibake real de `CHECKLIST-GLOBAL.md` |
| `c952bdf` | Filtro por línea + exclusiones + prueba de regresión |

**Firma:** Hy4 / WorkBuddy
