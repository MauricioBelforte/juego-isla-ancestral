# 06-Plan-Testings.md — Módulo 60: Datos y Serialización

**Modelo:** DeepSeek-V4.1-Flash · **Plataforma:** WorkBuddy · **Fecha:** 2026-09-15
**Log:** 916 (iter. 4) · **Suites:** 3 · **Checks totales:** 378

## 1. Cómo se ejecuta

```bash
GODOT="D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"

# Regresión base (núcleo iter. 1/2)
"$GODOT" --headless --path game/isla-ancestral --script res://scripts/datos/test_datos_m60.gd

# Regresión iter. 3 (construcciones, backups, compresión, catálogos perezosos)
"$GODOT" --headless --path game/isla-ancestral --script res://scripts/datos/test_datos_m60_iter3.gd

# iter. 4 (huecos de verificación: migración inyectable, atomicidad, slots, log M103)
"$GODOT" --headless --path game/isla-ancestral --script res://scripts/datos/test_datos_m60_iter4.gd
```

**Protocolo obligatorio (regla del proyecto):** cada suite se corre **×3**, se filtra `SCRIPT ERROR` en la salida (`grep -c "SCRIPT ERROR"` debe dar **0**) y se exige `exit code 0`. Un verde sin `SCRIPT ERROR: 0` **no es un verde**.

## 2. Qué cubre cada suite

| Suite | Checks | Alcance |
|---|---|---|
| `test_datos_m60.gd` | 94 | Núcleo: `Serializer` (JSON/canónico/binario IAVX1), `Validador` (CRC32 + contrato v1), `Versionador` (v0→v1, v1→v2, versión futura), `WriterAtomico` (atómico + `.bak` + restauración), `GestorSlot`, `GestorConfig`, catálogos, DataStore síncrono y **guardado asíncrono** (RF10: cola de profundidad 1, "la última gana") |
| `test_datos_m60_iter3.gd` | 132 | `EstructurasCodec` (sección `buildings`), `BuildingsSaveProvider`, caracterización de los providers de M19/M36, rotación de backups (ventana 3), compresión ZIP_DEFLATE (bajo/sobre umbral + round-trip), catálogos perezosos (0 Resources en memoria), presupuestos RN medidos, progreso del guardado asíncrono |
| `test_datos_m60_iter4.gd` | 152 | **Huecos de verificación** que quedaron sin prueba tras la auditoría del 2026-09-14 (ver §3) |

## 3. Bloques de la suite iter. 4

| Bloque | Checks | Qué prueba |
|---|---|---|
| **A** | 27 | `Versionador.migrar_con_cadena` (motor **inyectable**): 1 salto, N=3 saltos, no mutación del original, cadena incompleta, migración que no avanza versión, migración que devuelve dict sin `version`, save sin versión (v0), versión ≥ objetivo (copia, no alias), idempotencia, post-validación contra el contrato destino, delegación de `migrar()` de producción |
| **B** | 18 | Patrones puros `renombrar_campo` / `eliminar_campo` / `transformar_valor` (valor, default, no mutación, no invención) + los tres combinados en una cadena real de 3 saltos |
| **C** | 25 | Atomicidad y backups: `.bak` al 2.º guardado, `.bak.1` al 3.º, ventana = 3 (no crece), `.tmp` residual inocuo, tamaños RN2 (save < 1 MB, meta < 10 KB, config < 50 KB), config con `.bak` + atómica + corrupta → defaults, escritura imposible → `Error` sin crash, escritura interrumpida → save intacto |
| **D** | 18 | Slots: slot vacío, slot fuera de rango, borrado de slot inexistente → `false`, **regeneración de `meta.json`**, `listar_slots()` sólo meta, `borrar_slot` limpia `.deflate` + copias + directorio |
| **E** | 15 | Catálogo: `contar_items() > 100`, `tiene_item` sin cargar, `obtener_item` con caché, `validar_ids` (faltantes, orden, vacíos, sin cargar Resources) |
| **F** | 15 | Log M103: guardado/carga registran, rechazo por versión futura, contrato inválido con detalle, **detección temprana al guardar (no bloqueante)**, payload válido sin aviso, helper del log de migración |
| **G** | 21 | Integración: `ServiceRegistry.get_service("datos")`, `SaveManager.snapshot.collect()` (>30 secciones: player/npc/buildings), provider `buildings` registrado, orden de carga del voxel (save válido primero), semilla del mundo ida y vuelta, `_voxel_payload` |
| **H** | 12 | Formato: pretty de 2 espacios, canónico determinista, **una sola serialización** (checksum del archivo == CRC del `payload_str`), sin BOM, UTF-8 válido, checksum excluye el campo `checksum` |

> Suma de bloques: 27 + 18 + 25 + 18 + 15 + 15 + 21 + 12 = **151**, más el check del
> guardián de bloques (§4) = **152**. Valores **medidos** con `[FIN] … (+N checks)`, no
> estimados.

## 4. Guardián anti-falso-verde (obligatorio)

En GDScript un error de script **aborta la función en silencio**: la suite seguiría imprimiendo `0 fallos` (falso verde). La suite iter. 4 lo bloquea con **dos** defensas independientes:

1. **`_fin()` por bloque**: cada bloque registra su cierre; `_summary()` exige que estén los **8** y nombra los que no terminaron.
2. **Watchdog** en `_process()`: si `_run()` no termina en `TIMEOUT_FRAMES = 1800` frames, imprime `WATCHDOG` y sale con `exit 1`.

**El guardián debe PROBARSE, no confiarse.** Prueba ejecutada (Log 916): se inyectó `var nulo: Node = null` + `nulo.get_name()` al inicio del bloque **D** → la suite reportó `los 8 bloques se completaron ... bloques que no terminaron: ["D"]`, el conteo cayó de **152 → 128** y la salida fue `EXIT 1`. Con el aborto retirado, la suite volvió a **152/0**.

## 5. Qué NO cubre (honestidad)

- **Disco lleno real**: no es reproducible en headless. Se verifica el **camino de error** del writer (no puede abrir/escribir el `.tmp` → devuelve `Error`, sin crash, sin `.tmp` colgado).
- **Corte de energía / quit real a mitad del guardado**: se verifica el **invariante** (un `.tmp` cortado deja el save vigente intacto y cargable), no el corte físico.
- **Profiler de Godot**: no corre en headless. Los presupuestos RN se miden con `Time.get_ticks_msec()`.
- **Regeneración procedural del mundo (M08/M10)**: fuera del alcance de M60. Se verifica que la **semilla viaja y vuelve** del save.
- **Registro en M103**: verificado contra el `GameLogger` real **tal cual** (sin forzar categorías), capturando por la señal `line_emitted`. ⚠️ **Corrección (2026-09-15):** BUG-041 quedó en **falso positivo** — el logger **sí registra**; el fallo original era de la propia suite (ver `07-Resultados-Testings.md` §8).
