**Modelo:** DeepSeek-V4.1-Flash / WorkBuddy
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-13

# 06-Plan-Testings.md — Módulo 148: Lore Ambiental (iter. 2)

Plan de pruebas de la iteración 2 (parte **data-only**): gate de CI, grafo de
pistas, persistencia y migración. Los casos `CP-*` describen qué se prueba y
con qué evidencia; todos se ejecutan en **headless** (Godot 4.7.2).

## 1. Comandos

```bash
GODOT="D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
"$GODOT" --headless --path game/isla-ancestral --script res://scripts/lore/test_lore_m148.gd
"$GODOT" --headless --path game/isla-ancestral --script res://scripts/lore/lore_gate.gd
```

## 2. Casos de prueba

| CP | Qué se verifica | Método | Evidencia esperada |
|----|-----------------|--------|--------------------|
| CP-01 | Catálogo carga y no está vacío | `cargar()` + `cantidad_total()` | total > 0 |
| CP-02 | Cobertura total ≥ 48 (12×4) | `cantidad_total() >= 48` | 60 |
| CP-03 | Lookup por id existente / inexistente | `obtener_pieza()` | objeto / `null` |
| CP-04 | Cobertura por isla ≥ 12 (4 islas) | `por_isla()` | 18/14/14/14 |
| CP-05 | ≥ 4 murales (1 por templo) | `por_tipo(MURAL)` | 4 |
| CP-06 | `todos_los_ids()` ordenado y estable | doble llamada | arrays iguales |
| CP-07 | Catálogo real sin errores de auditoría | `LoreAuditor.validar()` | `[]` |
| CP-08 | Reporte de cobertura legible | `reporte_cobertura()` | contiene islas + `[OK]` |
| CP-09 | **ID duplicado** detectado | catálogo sintético | error "duplicado" |
| CP-10 | **ID duplicado por la vía real** (JSON→cargar) | `cargar_desde_texto()` | `ids_duplicados()` lo lista |
| CP-11 | **`canon_ref` vacío** detectado | catálogo sintético | error "canon_ref" |
| CP-12 | **Tipo fuera de rango** detectado | `tipo=99` | error "tipo fuera de rango" |
| CP-13 | **Texto vacío** detectado | pieza sin texto | error "texto vacío" |
| CP-14 | **Cobertura insuficiente** detectada | isla nueva con 1 pieza | error "mínimo 12" |
| CP-15 | **Pista sin consumidor** detectada | MURAL con `consumidor_id=""` | error "sin consumidor_id" |
| CP-16 | **Consumidor desconocido** detectado | MURAL → `consumidor_inexistente` | error "consumidor desconocido" |
| CP-17 | Catálogo sintético válido no da errores (control) | 12 piezas raiz | `[]` |
| CP-18 | Entrada sin `id` contabilizada y reportada | JSON con pieza sin id | `entradas_sin_id()==1` |
| CP-19 | Documento sin `"piezas"` → `false` y catálogo limpio | `cargar_desde_texto('{"otra":1}')` | `false`, total 0 |
| CP-20 | Registro de consumidores cargado | `ids_consumidores()` | ≥ 10 |
| CP-21 | `es_pista_valida` acepta/rechaza correctamente | registro + desconocido + vacío | true/false/false |
| CP-22 | Grafo real consistente | `validar_grafo()` | `[]` |
| CP-23 | Grafo roto detectado | ESTATUA → `sello_fantasma` | errores ≥ 1 |
| CP-24 | 4 temporadas con secretos | `activar_temporada()` ×4 | ≥ 1 cada una |
| CP-25 | Temporada desconocida → vacío | `activar_temporada("nada")` | 0 |
| CP-26 | `activar_temporada` devuelve copia | mutar el retorno | el servicio no cambia |
| CP-27 | Sección del save == `"lore"` | `get_section_name()` | `"lore"` |
| CP-28 | Primera marca = nueva; segunda = ya vista | `marcar_explorado()` | `true` / `false` |
| CP-29 | `ya_explorado` coherente | tras marcar / desconocida | true / false |
| CP-30 | Contadores por isla acumulan | 2 marcas misma isla | `contador_isla()==2` |
| CP-31 | `id` vacío no se marca | `marcar_explorado("")` | `false` |
| CP-32 | `get_save_data` incluye version/explorado/por_isla | inspección del dict | coherente |
| CP-33 | `restore_save_data` conserva estado | provider nuevo | total y contadores iguales |
| CP-34 | `reset()` limpia | tras restaurar | total 0 |
| CP-35 | **Migración: save sin la sección** | `restore_save_data({})` | estado vacío válido, no aborta |
| CP-36 | `migrar()` marca version 1 | `migrar({})` | `version==1` |
| CP-37 | Sección parcial (sin version/por_isla) | `migrar({"explorado":[...]})` | conserva + crea `por_isla` |
| CP-38 | **IDs duplicados deduplicados** en migración | `migrar({"explorado":["a","a","b"]})` | 2 |
| CP-39 | Datos basura → vacío válido | `migrar("no_es_dict")` | `[]` |
| CP-40 | Coerción de tipos (ids numéricos, contador string) | `restore_save_data` con ints | `"1"` marcado, contador int |
| CP-41 | **30 ciclos save/load sin pérdida** | round-trip JSON ×30 | ids y totales estables |
| CP-42 | Contadores por isla coherentes tras 30 ciclos | suma de contadores | == total |
| CP-43 | **Anti-falso-verde**: los 8 bloques cierran | marcadores `_fin()` | 8/8 presentes |
| CP-44 | LoreGate exit 0 con catálogo real | ejecución del gate | exit 0 |
| CP-45 | LoreGate exit 1 con catálogo roto | inyección + restauración | exit 1 |

## 3. Criterios de aceptación

1. `test_lore_m148.gd` → **0 fallos**, determinista en **3/3** corridas, **0 `SCRIPT ERROR`**.
2. `lore_gate.gd` → **exit 0** con el catálogo real y **exit 1** con un catálogo inválido.
3. Los 8 marcadores de bloque presentes (sin falsos verdes por aborto silencioso).
4. El archivo de datos real queda **restaurado** tras cualquier prueba negativa.

## 4. Fuera de alcance (declarado)

- Trigger de inspección en escena 3D (`TriggerLore`): requiere escena y arte.
- UI del diario (sección "Lore Ambiental", filtros, contadores): depende de M55/M89.
- Contenido narrativo: pasar de 4 a 6 islas y de 16 a 30 pistas.
- **Registro real de `LoreSaveProvider` en `SaveManager`**: la prueba verifica el
  proveedor de forma aislada (30 ciclos de round-trip), pero la sección no se
  registra todavía porque no hay juego de lore que escriba estado (falta
  `TriggerLore` + UI). El registro es una línea y pertenece al paso de integración.
