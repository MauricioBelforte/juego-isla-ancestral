# 06 — Plan de Testings — M27: Islas del Mundo

**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-15
**Iteración:** 4 (edge cases K1–K9 + catálogo de la §26)
**Log:** `Logs/912-Islas-Del-Mundo-Iter2_2026-09-15.md`

## Cómo se ejecuta

```
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral --script res://scripts/islas/test_islas_m27_iter2.gd
```

Salida esperada: `=== Resumen M27 iter.2: 238 checks, 0 fallos ===` y `EXIT 0`.

**Criterio de éxito:** 0 fallos, **0 líneas `SCRIPT ERROR`**, y el check final
`los 8 bloques se completaron (sin abortos silenciosos)` en `[OK]`.

> **Por qué existe ese check final.** Un error de script **aborta la función en
> silencio**: el bloque no corre, sus checks no se cuentan y la suite sale
> "verde" con menos checks. Es el falso verde dominante del proyecto. El test
> lleva dos defensas: cada bloque registra su letra en `_fin()`, y `_process`
> mata la corrida con `quit(1)` si `_run()` no termina en 1800 frames.

## Bloques de la suite

| Bloque | Alcance | Checks |
|---|---|---|
| — | Dataset y vista (antes del bloque A) | 2 |
| A | `IslandOps` — cola, prioridad, pesos, estados, cancelación | 46 |
| B | K1 precarga sin congelar + K2 viaje con descarga en curso | 30 |
| C | K3 náufrago + K8 respawn cozy | 28 |
| D | K4 ancla pendiente + K5 punto seguro de desembarco | 28 |
| E | K6 cancelación limpia + K7 guardado durante una carga | 22 |
| F | K9 descarga forzada por memoria | 25 |
| G | `IslandDesignCatalog` — los 26 puntos de la §26 | 27 |
| H | Integración con el autoload `IslandRegistry` real | 29 |
| — | Marcadores de bloque ejecutados (al final) | 1 |
| | **Total** | **238** |

## Casos de prueba

### A — `IslandOps` (cola de operaciones)

| ID | Caso | Esperado |
|---|---|---|
| CP-A01 | Las 4 etapas y sus pesos | `["losa","props","audio","navmesh"]`, 60/25/10/5, suma 1.0 |
| CP-A02 | `progreso_hasta()` | −1→0.0 · 0→0.60 · 1→0.85 · 3→1.0 |
| CP-A03 | `etapa_nombre()` fuera de rango | `""` |
| CP-A04 | `encolar()` con tipo inválido o isla vacía | `0` |
| CP-A05 | `encolar()` **idempotente** por (tipo, isla) | mismo id, la cola no crece |
| CP-A06 | Prioridad | viaje(0) < carga(1) < descarga(2) < precarga(3) |
| CP-A07 | `iniciar()` | arranca la primera; **una sola** en curso |
| CP-A08 | `avanzar_etapa()` ×4 | cierra la operación, progreso 1.0, cola libre |
| CP-A09 | `fallar()` / `cancelar()` | estado correcto, `cancelar` dos veces → `false` |
| CP-A10 | `pendientes()`/`vivas()`/`historial()` | devuelven **copias**, no referencias internas |
| CP-A11 | `limpiar()` | cola vacía e historial vacío |
| CP-A12 | `MAX_OPS_POR_FRAME` | `1` (nunca congelar) |

### B — K1 precarga + K2 viaje

| ID | Caso | Esperado |
|---|---|---|
| CP-B01 | `coste_por_frame()` | `no_congela: true`, 1 op/frame, margen declarado |
| CP-B02 | `debe_precargar()` desde la costa de coral (margen 256 m) | exactamente `["coral"]` |
| CP-B03 | Presupuesto 0 | no precarga nada |
| CP-B04 | La isla actual | nunca se precarga a sí misma |
| CP-B05 | Isla ya cargada | no se vuelve a precargar |
| CP-B06 | Presupuesto 3 con margen amplio | 3 vecinas, la más cercana primero |
| CP-B07 | `evaluar_viaje()` destino en descarga | se **encola**, no se cancela |

### C — K3 náufrago + K8 respawn cozy

| ID | Caso | Esperado |
|---|---|---|
| CP-C01 | A pie en alta mar | `accion: respawn_cozy`, isla más cercana, distancia > límite |
| CP-C02 | En agua dentro del radio de seguridad | `riesgo: true`, `accion: salvavidas` |
| CP-C03 | `respawn_cozy()` desde (0,0,2400) | isla `coral` (1300 m; la siguiente a 2400 m) |
| CP-C04 | La posición devuelta | siempre tierra firme, nunca agua |
| CP-C05 | `respawn_cozy()` sin islas | `ok: false`, `motivo: sin_islas` |

### D — K4 ancla pendiente + K5 punto seguro

| ID | Caso | Esperado |
|---|---|---|
| CP-D01 | `estado_destino()` con ancla | `viajable: true` |
| CP-D02 | Sin ancla | `motivo: ancla_pendiente`, `espera_coherente: true` |
| CP-D03 | Isla secreta sin descubrir | `motivo: secreta_no_descubierta` |
| CP-D04 | `punto_seguro()` sobre agua | proyecta al interior del disco |
| CP-D05 | `punto_seguro()` sobre tierra | devuelve el punto tal cual, `ajustado: false` |
| CP-D06 | `punto_seguro()` de isla desconocida | `ok: false`, `isla_desconocida` |

### E — K6 cancelación + K7 guardado

| ID | Caso | Esperado |
|---|---|---|
| CP-E01 | `cancelar_viaje()` con operación viva | cancela y deja la cola limpia **para ese destino** |
| CP-E02 | Cancelar lo que no está | `canceladas: 0`, `limpio: true` |
| CP-E03 | Sólo cancela el destino pedido | otra isla conserva sus operaciones y se **reporta** viva |
| CP-E04 | `evaluar_guardado()` con cola libre | `puede_guardar: true`, `motivo: libre` |
| CP-E05 | Con cola pendiente | `esperar: true`, `motivo: cola_pendiente` |
| CP-E06 | Con carga en curso | `esperar: true`, `motivo: carga_en_curso` + a qué op esperar |
| CP-E07 | `evaluar_guardado(null)` | `puede_guardar: true` |

### F — K9 descarga forzada

| ID | Caso | Esperado |
|---|---|---|
| CP-F01 | Tope de memoria | `MAX_ISLAS_EN_MEMORIA == 2` |
| CP-F02 | Presión de memoria | descarga por LRU (la menos usada primero) |
| CP-F03 | Intocables | nunca `aurora` (principal) ni la isla actual |
| CP-F04 | Resultado | memoria resultante ≤ tope |
| CP-F05 | Marca de caché | las descargadas quedan `cargada: false` |
| CP-F06 | Cola | una operación de descarga por víctima |
| CP-F07 | **Estado de partida (M59)** | descubrimiento y visitas **idénticos** antes y después |
| CP-F08 | `sincronizar_estado_partida()` | propaga M59 → guardia sin tocar la caché |
| CP-F09 | `snapshot_estado()` tras descargar | sigue conservando descubrimiento y visitas |
| CP-F10 | Sin presión | no descarga nada |

### G — `IslandDesignCatalog` (§26)

| ID | Caso | Esperado |
|---|---|---|
| CP-G01 | Puntos del plan | **26** (no 24) |
| CP-G02 | `validar(_defs)` / `campos_faltantes` / `islas_faltantes` | sin errores |
| CP-G03 | `cobertura()` | 26 total = 15 resueltos + 7 declarativos + 4 externos |
| CP-G04 | Grupos | 13 islas + 2 rutas + 11 atributos = 26 |
| CP-G05 | Extremos | el punto 1 es la isla principal; el 26, la relevancia narrativa |
| CP-G06 | Los 4 externos | declaran dueño (`externo:M##`) |
| CP-G07 | Puntos con 2 resoluciones | el 15 (anillo + radio) y el 26 (flag + secreta) |
| CP-G08 | `claves_localizacion()` | 26 claves únicas `M27.DISENO.P01..P26` |
| CP-G09 | `informe()` | expone el desajuste `plan_dice` 24 vs `plan_tiene` 26 |
| CP-G10 | `punto(99)` | `{}` |

### H — Integración con `IslandRegistry` real

| ID | Caso | Esperado |
|---|---|---|
| CP-H01 | Catálogo real | 13 islas, principal `aurora` |
| CP-H02 | Anillos | 1 NUCLEO + 3 CERCANO + 3 MEDIO + 6 LEJANO |
| CP-H03 | Flags | sólo `secreta` es secreta; `cielo` y `flotante` flotantes |
| CP-H04 | **Hallazgo**: sin M10 | las 13 islas están **sin ancla**; la guardia es válida igual |
| CP-H05 | Sin anclas | `estado_destino` → `ancla_pendiente` y el viaje **espera**, no bloquea |
| CP-H06 | Con la disposición de referencia | 12 de 13 viajables: `secreta` no, por estar sin descubrir |
| CP-H07 | Descubrir `secreta` en M59 + sincronizar | pasa a viajable → **13 de 13** |
| CP-H08 | `aurora` | descubierta **por definición** (regla de M59) |
| CP-H09 | Documentación | 01-Requerimientos declara 13 islas; 03-Diseno §5 cataloga 13 |

## Guardián anti-falso-verde — cómo se prueba

El mecanismo no se da por bueno: **se prueba**. Procedimiento ejecutado en esta
iteración:

1. Inyectar un aborto silencioso al abrir un bloque
   (`var nulo: Node = null` + `nulo.get_name()`).
2. Correr la suite y comprobar que **falla** y **nombra el bloque**.
3. Retirar la sonda y comprobar que vuelve a verde.

Resultado medido: `[FALLO] los 8 bloques se completaron (sin abortos silenciosos)
— bloques que no terminaron: ["D"]`, `210 checks, 1 fallos`, `EXIT 1`. Los 28
checks del bloque D desaparecieron: **ese** era el falso verde.

## Regresiones que deben seguir verdes

| Suite | Esperado |
|---|---|
| `test_islas_m27.gd` (iter. 1) | 171 checks / 0 fallos |
| `test_islas_headless.gd` (legacy) | 5 checks / 0 fallos |
| `sincronizar_islas_mapa.gd` | 4 islas coherentes + 9 POIs, `EXIT 0` |

## Fuera de alcance de esta suite (honestidad)

- **`IslandLoading`** (carga/descarga/streaming real, 19 ítems `[?]`): dueño M63/M61.
- **Anclas reales** (M10): el test usa la disposición de referencia documentada.
- **Geometría, muelles físicos y aprobación visual**: no es de M27 ni de este
  agente (§15.3: no soy aprobador visual).
- **El cableado al juego**: nadie llama todavía a `IslandOps` ni a
  `IslandTravelGuard`. Se prueban como lógica pura.
