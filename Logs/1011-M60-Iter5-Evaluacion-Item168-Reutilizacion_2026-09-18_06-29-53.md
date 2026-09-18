# Log 1011: M60 iter. 5 — evaluación del ítem 168 (reutilización de dicts y buffers)

- **Fecha:** 2026-09-18
- **Hora:** 06:29
- **Agente / Modelo:** DeepSeek-V4.1-Flash (WorkBuddy)
- **Módulo:** 60-Datos-Y-Serializacion
- **Reserva:** 1011 (protocolo v3: consumido del pool, sin archivo de reserva)
- **Tipo:** iteración de evaluación (sin cambio de código de producción)

## Resumen

El ítem 168 del checklist pedía *"Optimización: reutilización de dicts y buffers en bucles de
guardado"*. **Se evaluó con un arnés propio y resultó CONTRAPRODUCENTE: NO se implementó y el código
de producción quedó SIN CAMBIOS** (`serializador.gd` es byte a byte idéntico a HEAD).

Se prefirió medir antes de implementar, y la medición dijo que no. **No se envía una pesimización.**

## Qué se midió

Misma salida, varias implementaciones del MISMO formato IAVX1 / del mismo `a_plano`:

1. **Producción (actual):** `resize()` por campo + `encode_s32`; asignador recursivo (un contenedor
   nuevo por nodo).
2. **Reutilización:** buffer del llamador con un único `resize()` al tamaño exacto (calculado en una
   pasada previa); dict de destino reutilizado con `keys()`/`erase()`/`get()`.
3. **BULK:** `PackedInt32Array` + `to_byte_array()` (memcpy masivo en vez de un `encode_s32` por entero).

El arnés `test_datos_m60_iter5.gd` **no toca producción**: define las variantes localmente y las
compara contra `Serializer` tal cual está. Bloques A-D son aserciones duras (equivalencia byte a byte
con un **oráculo independiente** escrito a mano, round-trip, equivalencia entre variantes y **sin
aliasing**); el bloque E sólo mide.

## Resultado

| caso | producción | reutilización | BULK |
|---|---|---|---|
| 6000 chunks × 1 vóxel | **52-64 ms** | 61-80 ms | 51-69 ms |
| 400 chunks × 60 vóxeles | **38-49 ms** | 44-50 ms | 40-41 ms |
| payload de 60 entidades | **315-369 ms** | 339-394 ms | — |

Suma de los **mismos 3 casos**, mínimo de 5 rondas intercaladas, ×3 corridas:
**producción 410-459 ms vs reutilización 472-499 ms → la reutilización es 1,08-1,15× MÁS LENTA.**

## Por qué la premisa era falsa

- **`PackedByteArray.resize()` ya crece de forma amortizada.** Los ~6 `resize()` por chunk que la
  optimización pretendía eliminar **no eran el coste**; añadir una pasada previa para calcular el
  tamaño exacto cuesta más de lo que ahorra.
- **El reuso de dicts añade libro mayor:** `keys()` (que asigna un Array nuevo), `erase()` y `get()`
  por clave cuestan más que asignar el árbol nuevo en GDScript.
- **BULK no es fiable:** gana en una corrida (40 vs 49 ms) y pierde en otra (41 vs 38 ms).

## Trampa metodológica nueva (importante)

La **primera** versión del arnés medía cada variante **una sola vez y en orden fijo**. Eso castiga a
la primera con el warm-up y **invirtió el veredicto**: llegó a reportar la reutilización como
**1,4× más rápida**. Al re-medir con **rondas intercaladas + mínimo por variante** el resultado se dio
vuelta y quedó estable en 3 corridas.

**Lección: un benchmark de una sola pasada y orden fijo no prueba nada.** Estuve a un paso de reportar
una conclusión falsa (y de "optimizar" el código hacia una versión más lenta).

## Verificación

- `test_datos_m60_iter5.gd`: **40 checks, 0 fallos, ×3 corridas, 0 `SCRIPT ERROR`, exit 0.**
- Guardián anti-falso-verde: 5 bloques con marcador `_fin()`, `_summary()` que **nombra** los bloques
  faltantes, **piso** `CHECKS_MINIMOS = 34` y watchdog de frames.
- Regresión del módulo (misma corrida): `test_datos_m60.gd` **94/0** · `test_datos_m60_iter3.gd`
  **132/0** · `test_datos_m60_iter4.gd` **152/0** — los tres con 0 `SCRIPT ERROR` y exit 0.
- `verificar_checklist.py`: **M60 = 189 [x] · 3 [ ] · 4 [?] = 196.**

## Riesgo residual (honesto)

- **La medición es de un entorno headless** (Godot 4.7.2, Windows). Se afirma el **orden de magnitud**
  (reutilización ≥ producción), no los valores exactos.
- **No se midió el efecto en el juego real** (presión de GC / frame-time): el arnés mide *throughput*,
  no latencia de frame. Si algún día importa la consistencia de frame, **re-medir antes de concluir**.
- **Los tiempos del bloque E son informativos, no aserciones** (en CI son ruidosos). Lo que la suite
  garantiza de verdad es la **equivalencia** (bloques A-D): si alguien cambia el formato al
  "optimizar", el arnés lo detecta.

## Archivos tocados

- **Nuevo:** `game/isla-ancestral/scripts/datos/test_datos_m60_iter5.gd` (arnés).
- `DOCUMENTACION/60-Datos-Y-Serializacion/plan-actual/05-Checklist.md` (ítem 168: `[ ]` → `[x]` con la
  evidencia y el veredicto).
- `DOCUMENTACION/60-Datos-Y-Serializacion/plan-actual/04-Codigo.md` (sección "Notas del Agente — iter. 5").
- `DOCUMENTACION/60-Datos-Y-Serializacion/plan-actual/06-Plan-Testings.md` y `07-Resultados-Testings.md`.
- `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/60-Datos-Y-Serializacion/checklist.md` (T-168).
- `CHECKLIST-GLOBAL.md` (fila 60), `Mensajes entre modelos/ESTADO-PARALELO.md`,
  `DOCUMENTACION/TAREAS-POR-MODELO/DeepSeek-V4.1-Flash/BACKLOG-MASTER.md`.
- **`game/isla-ancestral/scripts/datos/serializador.gd`: SIN CAMBIOS** (revertido a HEAD; sha
  `1b039343e6ed3d1a428e42068858b4c652187af1`).

## Pendiente

- **Nada propio en M60.** Los 3 `[ ]` que quedan son de **M08/Voxel Tools** (115/117/122) y los 4 `[?]`
  tienen dueño externo (131→M53/M59, 133→M63, 145→M16/M33, 172→Profiler/GUI).
- **QA cruzado §21.8 de M60 iter. 5: pendiente** (verificador ≠ autor). Es un arnés de evaluación sin
  cambio de producción, así que el riesgo es bajo — pero el sello lo pone otro modelo.
- **Cablear `test_datos_m60_iter5.gd` en `quality.yml`:** NO se hizo porque ese archivo tiene
  modificaciones ajenas en vuelo (gates M83/M126/M128 de agnes-3-flash). Queda para cuando se libere
  (trampa 70: no arrastrar bytes ajenos).
