# 06 — Plan de Testings — M26: Templo Subterráneo

**Modelo:** DeepSeek-V4.1-Flash / WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-14
**Iteración:** 2

## Cómo se ejecuta

```
"D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe" \
  --headless --path game/isla-ancestral --script res://scripts/templos/test_templo_m26.gd
```

Salida esperada: `=== Resumen M26: 92 checks, 0 fallos ===` y `EXIT 0`.
**Criterio de éxito:** 0 fallos, 0 líneas `SCRIPT ERROR`, y los 7 marcadores de
bloque presentes (`A`..`G`). El test verifica los marcadores al final: un error de
script aborta la función en silencio, así que un bloque podría no ejecutarse y el
test salir "verde" (falso verde).

## Bloques de la suite

| Bloque | Alcance | Checks |
|---|---|---|
| A | `TemploFlow` — gating básico | 14 |
| B | `TemploFlow` — anti-exploit (sellos únicos, salida sellada) | 11 |
| C | `TemploCheckpoint` — guardado atómico | 20 |
| D | `TempleTelemetria` — intentos/pistas/tiempo + export M24 | 14 |
| E | `TemploValidadores` — el diseño real pasa las 6 suites | 12 |
| F | `TemploValidadores` — detecta fallos inyectados | 12 |
| G | `TemploSchema` (iter. 1) sigue verde sobre su layout | 1 |
| — | Glifos leídos del diseño (antes del bloque A) | 1 |
| — | Marcadores de bloque ejecutados (al final) | 7 |
| | **Total** | **92** |

## Casos de prueba

### Gating (sellos y salida)

| ID | Caso | Esperado | Bloque |
|---|---|---|---|
| CP-01 | Estado inicial de `TemploFlow` | 7 anillos, 0 activos, progreso 0.0 | A |
| CP-02 | Activar anillo 0 con sello y glifo correctos | `true`, 1 anillo activo, progreso 1/7 | A |
| CP-03 | Activar un anillo fuera de rango (7) | `false`, motivo `anillo_fuera_de_rango` | A |
| CP-04 | Activar un anillo ya activo | `false`, motivo `anillo_ya_activo` | A |
| CP-05 | Activar con un sello no conseguido | `false`, motivo `sello_inexistente` | A |
| CP-06 | Activar con el glifo equivocado | `false`, motivo `glifo_incorrecto`; el sello queda libre y luego funciona con el glifo correcto | A |
| CP-07 | Registrar un sello dos veces | `false`, motivo `sello_duplicado` | A |
| CP-08 | `estado()` | serializa 7 anillos | A |
| CP-09 | `restaurar_sello()` sin los 7 anillos | `false`, motivo `faltan_anillos` | B |
| CP-10 | `restaurar_sello()` con los 7 anillos | `true`; `salida_abierta()` `true` | B |
| CP-11 | `intentar_abrir_salida()` sin sello restaurado | `false`, motivo `sello_no_restaurado`, **sin cambiar estado** | B |
| CP-12 | Round-trip `estado()` → `cargar_estado()` | 7 anillos, sello restaurado y sellos colocados preservados | B |

### Anti-exploit

| ID | Caso | Esperado | Bloque |
|---|---|---|---|
| CP-13 | Reutilizar un sello ya colocado en otro anillo | `false`, motivo `sello_ya_colocado` | B |
| CP-14 | `sello_colocado_en()` | devuelve el índice correcto, `-1` si está libre | B |
| CP-15 | Los 7 anillos se activan con sus 7 sellos | todos `true`; `anillos_completos()` | B |
| CP-16 | Entrada por la salida sellada | rechazada (`intentar_abrir_salida()` `false`) | B |
| CP-17 | Rampa > 20° en el blueprint | `validar_voxel` la rechaza | F |
| CP-18 | `voxel.teleports = true` | `validar_anti_exploit` lo rechaza | F |
| CP-19 | Recompensa (sello) repetida en dos puzzles | `validar_anti_exploit` la rechaza | F |
| CP-20 | Sala de salida sin `requiere = "sello_restaurado"` | `validar_anti_exploit` lo rechaza | F |

### Checkpoints (guardado atómico)

| ID | Caso | Esperado | Bloque |
|---|---|---|---|
| CP-21 | `asegurar_dir()` | crea el directorio; idempotente | C |
| CP-22 | Primer `guardar()` | `true`; existe; **sin** `.tmp` huérfano; **sin** `.bak` | C |
| CP-23 | Segundo `guardar()` | `true`; aparece el `.bak` con el estado anterior | C |
| CP-24 | `cantidad_backups()` / `cantidad_tmp_huerfanos()` | 1 / 0 | C |
| CP-25 | `cargar()` | devuelve el último estado | C |
| CP-26 | Principal corrupto → `cargar_con_respaldo()` | cae al `.bak` (`origen_carga == "respaldo"`) y conserva el estado previo | C |
| CP-27 | `cargar()` de un principal corrupto | `{}` y `ultimo_error` no vacío | C |
| CP-28 | `validar_atomico()` | sin errores en estado sano | C |
| CP-29 | `listar()` / `borrar()` | lista el CP escrito; `borrar()` limpia principal + tmp + bak | C |

### Telemetría

| ID | Caso | Esperado | Bloque |
|---|---|---|---|
| CP-30 | Dos intentos + resolución con reloj inyectado | intentos 2, pistas 1, tiempo 20 s, resuelto, `intentos_hasta_resolver` 2 | D |
| CP-31 | `resumen_global()` | 2 puzzles, 1 resuelto, 6 intentos | D |
| CP-32 | `puzzles_dificiles(3)` | `[puz_anillos]` | D |
| CP-33 | `exportar_a_m24()` | `version 1`, `origen "M26"`, puzzles ordenados por id | D |
| CP-34 | `exportar_json()` → `cargar_json()` → `exportar_json()` | JSON válido y round-trip idempotente | D |

### Softlocks, orientación y accesibilidad

| ID | Caso | Esperado | Bloque |
|---|---|---|---|
| CP-35 | Sala inalcanzable desde la entrada | `validar_softlock` la reporta | F |
| CP-36 | Zona con recompensa con un solo camino | `validar_softlock` la reporta (< 2 caminos) | F |
| CP-37 | Checkpoint faltante (4 en vez de 5) | `validar_checkpoints` lo reporta | F |
| CP-38 | Corredor ≠ 4x4x4 m | `validar_voxel` lo reporta | F |
| CP-39 | Contraste < 4.5:1 | `validar_accesibilidad` lo reporta | F |
| CP-40 | Presión temporal activada | `validar_accesibilidad` lo reporta | F |
| CP-41 | Mojones cada 60 m | `validar_orientacion` lo reporta | F |
| CP-42 | El layout de iter. 1 (4 salas lineales) no tiene 5 CP | `validar_checkpoints` lo rechaza (el validador no "aprueba todo") | F |

### Regresión

| ID | Caso | Esperado | Bloque |
|---|---|---|---|
| CP-43 | `TemploSchema.validar_layout()` sobre `templo_subterraneo.json` | sin problemas (iter. 1 sigue verde) | G |
| CP-44 | Los 7 marcadores de bloque `_fin()` | todos presentes (anti-falso-verde) | — |

## Casos NO cubiertos (y por qué)

| Área | Motivo |
|---|---|
| Navegación real (`NavigationServer3D` por piso) | Requiere el templo generado por M08 (voxel) + M61; no hay geometría |
| NPC atascados en el templo | Requiere NPCs de M19/M64 con puestos de aparición dentro del templo |
| Puzzles irresolubles | Requiere el grafo emisor→receptor por puzzle de M24; acá solo se valida que los puzzles referenciados existan |
| Mapa de zona simplificado (panel M58) | La UI es de M58 |
| Presupuesto por región / streaming por piso | Es de M63 |
| Instancing de columnas | Depende de M61/M63 |
| Deriva real del jugador (< 2 min) | Requiere runtime con jugador; acá solo se valida el umbral declarado |
| Calibración visual (luces, materiales, partículas) | Requiere vista en Godot/Blender y aprobación visual ajena (§15.3) |
| Solvabilidad de cada puzzle | Es de M24 (framework `PuzzleRoom`) |
