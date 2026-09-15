# 07-Resultados-Testings.md — Módulo 60: Datos y Serialización

**Modelo:** DeepSeek-V4.1-Flash · **Plataforma:** WorkBuddy
**Fecha:** 2026-09-15 · **Log:** 916 (iter. 4) · **Reserva:** `Logs/reservas/916-DSV41F-M60.txt`

## 1. Resultado global

| Suite | Checks | Fallos | Corridas | `SCRIPT ERROR` | Exit |
|---|---|---|---|---|---|
| `test_datos_m60.gd` | **94** | **0** | ×3 | 0 | 0 |
| `test_datos_m60_iter3.gd` | **132** | **0** | ×3 | 0 | 0 |
| `test_datos_m60_iter4.gd` | **152** | **0** | ×3 | 0 | 0 |
| **TOTAL** | **378** | **0** | 9 corridas | **0** | **0** |

Binario: `D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe`
Invocación: `--headless --path game/isla-ancestral --script res://scripts/datos/<suite>.gd`

## 2. Desglose de la suite iter. 4 (152 checks)

```
[FIN] A. migrar_con_cadena (motor inyectable)                        (+27 checks)
[FIN] B. patrones renombrar / eliminar / transformar                 (+18 checks)
[FIN] C. atomicidad, rotación de backups y tamaños RN                (+25 checks)
[FIN] D. slots: meta regenerada, slot vacío, borrado                 (+18 checks)
[FIN] E. catálogo estático: validar_ids y carga perezosa             (+15 checks)
[FIN] F. log M103 (GameLogger real)                                  (+15 checks)
[FIN] G. integración: ServiceRegistry, SaveManager, orden del voxel  (+21 checks)
[FIN] H. formato, determinismo y una sola serialización              (+12 checks)
=== Resumen M60 iter. 4: 152 checks, 0 fallos ===
TEST M60 iter. 4 OK — todos los checks pasaron
```

**Suma verificada:** A 27 + B 18 + C 25 + D 18 + E 15 + F 15 + G 21 + H 12 = **151**, más el
check del guardián de bloques = **152**. Medido en 3 corridas consecutivas con el mismo
resultado (no estimado, no copiado de una iteración anterior).

> ⚠️ **Corregido 2026-09-15:** este desglose decía `A 29 · C 27` (suma 155 ≠ 152) — cifras
> arrastradas de una versión previa de la suite, no medidas. Los valores de arriba son los
> que **imprime** el suite (`[FIN] … (+N checks)`), reconfirmados 3 veces.

## 3. Prueba del guardián anti-falso-verde (evidencia de que el guardián funciona)

| Paso | Acción | Resultado medido |
|---|---|---|
| 1 | Aborto inyectado en el bloque **D** (`var nulo: Node = null` + `nulo.get_name()`) | `SCRIPT ERROR: Cannot call method 'get_name' on a null value.` — el bloque D **no** imprimió `[FIN]` |
| 2 | Resumen con el aborto presente | `[FALLO] los 8 bloques se completaron (sin abortos silenciosos) — bloques que no terminaron: ["D"]` · **128 checks, 1 fallo** · `EXIT 1` |
| 3 | Aborto retirado | **152 checks, 0 fallos** · `EXIT 0` |

Sin el guardián, el paso 1 habría dejado la suite en "0 fallos" (falso verde) — que es exactamente el modo de fallo dominante documentado en el proyecto.

## 4. Medidas de rendimiento (headless, `Time.get_ticks_msec()`)

| Medida | Valor | Presupuesto | Estado |
|---|---|---|---|
| Guardar (síncrono, test) | ~124 ms (iter. 3) / < 300 ms | RN1 < 300 ms | ✅ |
| Cargar + validar + migrar | ~17 ms | RN1 < 1 s | ✅ |
| `save.json` | 22 537 B (con voxel) | RN2 < 1 MB | ✅ |
| `meta.json` | < 1 KB | RN2 < 10 KB | ✅ |
| `config.cfg` | < 1 KB | RN2 < 50 KB | ✅ |
| Guardado asíncrono: bloqueo del frame | < 50 ms | RN1 | ✅ |
| Carga perezosa del catálogo | 0 Resources cargados tras indexar 111 items | — | ✅ |

## 5. Hallazgos de la iter. 4

1. **BUG-041 (M103, abierto)** — `GameLogger` **no registra nada**: `log_buffer` nunca se escribe y `categories_enabled` arranca vacío (el guardián de `_log()` descarta todas las categorías). Detectado por el bloque F (6 checks en rojo). Workaround en la suite: habilitar `categories_enabled[SYSTEM]` y capturar por `line_emitted`. **No se modificó M103** (módulo ajeno): queda documentado y delegado.
2. **`GestorSlot.borrar_slot` mentía** — devolvía `true` para un slot in-range sin ningún archivo. Corregido: ahora devuelve `false`.
3. **Fuga de disco en `borrar_slot`** — no borraba `mundo_voxel.bin.deflate` ni las copias `.bak`/`.bak.1`/`.bak.2` del save ni del voxel → el directorio del slot no se podía eliminar. Corregido.
4. **`mundo_voxel.bin` sin backup** — era el único archivo de slot sin `.bak`. Implementado con la misma ventana de 3 copias.
5. **Slot sin `meta.json`** — cargaba pero `listar_slots()` no lo veía (el menú lo "perdía"). Ahora la meta se regenera al cargar.
6. **Sin log de migración ni de validación** — la carga no registraba el salto de versión real ni el motivo del rechazo de contrato. Agregado.
7. **Sin validación al guardar** — agregada como **detección temprana NO bloqueante**.
8. **Motor de migración no testeable** — `migrar()` partido en `migrar_con_cadena(datos, cadena, objetivo)`; producción intacta.

## 6. Regresiones conocidas (para otros módulos)

- `GestorSlot.borrar_slot(slot)` ahora devuelve `false` cuando el slot está **in-range pero vacío**. Si algún consumidor (M59/M107) dependía del `true`, debe ajustarse.
- `DataStore.guardar_partida()` ahora **registra en el log** una advertencia si el payload no cumple el contrato v1, pero **sigue guardando** (no cambia el valor de retorno).

## 7. Reproducibilidad

Los 3 comandos de §1, corridos 3 veces cada uno el 2026-09-15 (hora local GMT-3), dieron siempre `0 fallos` y `exit 0` con `SCRIPT ERROR = 0`. Las suites limpian `user://saves/slot_1..3` al inicio y al final, y **preservan y restauran** `user://config.cfg` del usuario (la suite iter. 4 guarda los bytes originales y los reescribe al terminar).
