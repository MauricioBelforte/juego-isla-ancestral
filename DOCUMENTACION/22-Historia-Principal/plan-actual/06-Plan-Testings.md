**Modelo:** DeepSeek-V4.1-Flash
**Plataforma:** WorkBuddy
**Fecha:** 2026-10-30

# 06-Plan-Testings.md — Módulo 22: Historia Principal

> **Iter. 1 (2026-10-30, TANDA 7, msg 467 de agnes-3-flash).** Este archivo no existía: el ítem
> `05-Checklist.md` L126 ("Diseñar 06-Plan-Testings.md") estaba `[ ]` porque la justificación previa
> citaba `m22_spec.md` (diseño) y no un plan de testings. Se escribe con las cifras **medidas** de la
> corrida real del 2026-10-30, no con las declaradas.

## 1. Objetivo y alcance

M22 tiene **dos artefactos ejecutables** y una capa documental:

| Capa | Artefacto | Naturaleza | Se prueba |
|---|---|---|---|
| (a) **Servicio** | `scripts/historia/story_manager.gd` (autoload `Historia`) | GDScript sobre `data/historia/historia_principal.json` | **Sí** — suite headless |
| (b) **Validador de grafo** | `scripts/historia/validar_historia.gd` | GDScript, `extends SceneTree` | **Sí** — corrida propia con exit code |
| (c) Integraciones con otros módulos | 7 ítems L89-L95 del checklist | Cableado entre módulos | **No** en esta iteración (§5) |

Dataset medido (2026-10-30, `data/historia/historia_principal.json`): **12 nodos**, **7 sellos**
(`sellos_totales = 7`), **4 finales** declarados (`principal`, `regresar`, `guardian`, `secreto`),
capítulos **0..7**, tipos de nodo `cutscene | final | llegada | mision | templo`.

## 2. Suite headless — `scripts/historia/test_historia.gd`

Patrón del proyecto: `extends SceneTree` + `--script`, **6 bloques** con marcador `_fin("bloque")`,
`_summary()` en un `call_deferred` **separado** del `_run()` (un aborto de runtime no se lleva el
resumen) y piso `CHECKS_MINIMOS = 41` **medido en verde**.

| Bloque | Qué verifica |
|---|---|
| A `_test_carga_grafo` | 12 nodos cargados, `prologo` existe, nodo inexistente = `{}`, capítulo inicial 0 |
| B `_test_progresion_lineal` | `prologo→c1→c2→c3` con requisitos previos; `c4` rechazado con **≥2 motivos**; `c4` no completado |
| C `_test_gating_sellos` | 7 sellos declarados; sello inexistente y vacío rechazados; los 7 reales se marcan; duplicado **idempotente**; `c4` sigue bloqueado sin flag |
| D `_test_flags_worldstate` | `WorldState` presente (M21); `c4` abre con sellos + `templo_brisa_abierto`; `c5..c7`; 3 finales base disponibles; `final_secreto` bloqueado sin `pistas_secreto_completas` y abierto con ella |
| E `_test_finales` | elegir `final_principal`; `final_elegido() == "principal"`; capítulo queda en 7 |
| F `_test_persistencia` | `get_save_data()` con `completados/sellos/final_elegido`; sección `historia`; `restore_save_data({})` resetea; round-trip restaura 7 sellos + final |

Total **medido** de la corrida: **41 checks** (más 1 check de precondición del autoload, contado
dentro de los 41). **El desglose por bloque no se publica**: la suite no lo imprime y contarlo a mano
sobre el código es la trampa 49 del proyecto (cifra copiada, no medida). Si hace falta el desglose, se
instrumenta la suite y se vuelve a medir.

**Invariante de la suite:** el bloque D **muta** `WorldState` (flags globales del autoload). Por eso la
suite no es re-ejecutable en el mismo proceso sin `restore_save_data()`: el orden A→F es parte del
contrato del test, no una preferencia.

### Cómo se corre

```bash
GODOT="D:/ISLA ANCESTRAL/Godot_v4.7.2-stable_win64.exe/Godot_v4.7.2-stable_win64_console.exe"
"$GODOT" --headless --path game/isla-ancestral --script res://scripts/historia/test_historia.gd
```

Criterio de verde: `=== Resumen M22: 41 checks, 0 fallos ===`, **EXIT 0** y **0 `SCRIPT ERROR`** en la
salida. El exit code se lee del **proceso**, nunca del último eslabón de una tubería.

## 3. Validador de grafo — `scripts/historia/validar_historia.gd`

Verifica cuatro reglas de `03-Diseno §Grafo` sobre el JSON: sin huérfanos, sin retroceso de capítulo
(DAG), cada final alcanzable por BFS desde `prologo`, y requisitos bien formados (tipos conocidos +
ids de sellos declarados). Además declara los **finales secretos por flag externa** (M25/M147) como
ADVERTENCIA, no como fallo.

Criterio de verde: `=== VALIDADOR M22 HISTORIA: 79 checks, 0 fallo(s) ===`, **EXIT 0**, **0
`SCRIPT ERROR`** y **0 `String formatting error`**.

### Guardas anti-falso-verde (las tres, no una)

1. **Piso de checks.** `CHECKS_MINIMOS = 79`, medido en verde. Sin piso, un validador que ejecuta 0
   checks imprime exactamente lo mismo que uno limpio: `0 fallo(s)`.
2. **El piso va probado EN ROJO.** Sonda: subir el piso 1 por encima del real → debe salir **EXIT 1**
   nombrando la causa (`solo 79 checks ejecutados (minimo 80)`).
3. **`quit()` después del veredicto**, no antes: el código de salida es `1` si `_fallos > 0`.

## 4. Regresión que esta suite arrastra

- **M21** (`WorldState`): el bloque D depende de `set_flag`/`siguientes_disponibles`. Si M21 cambia el
  contrato de flags, el bloque D debe fallar (no debe "seguir pasando" por leer otro estado).
- **M59** (save): el bloque F usa el contrato `ISaveProvider` (`get_section_name`, `get_save_data`,
  `restore_save_data`) con sección `historia`.
- **M25/M147** (templos/pistas): la flag `pistas_secreto_completas` es externa por diseño; el
  validador la reporta como advertencia y la suite la inyecta para probar el desbloqueo.

## 5. Fuera de alcance (con dueño declarado)

Los **7 ítems de integración** del checklist (L89-L95: M21, M23, M24/M25/M26, M28, M31, M33,
M41/M44) **no** tienen suite aquí porque el artefacto que falta no es de M22: es el **cableado** entre
`scripts/historia/` y el módulo contraparte (`0 llamadas .connect()` medido el 2026-10-30). Un test
que inyecte el cableado a mano probaría el test, no la integración. Dueño: M22 + el módulo citado en
cada ítem.

## 6. Qué NO prueba esta suite

- **No** prueba que el jugador vea el contenido: no hay UI ni cutscene en el alcance.
- **No** prueba el grafo completo de los 4 finales jugados de punta a punta: solo `final_principal`
  (bloque E). Los otros 3 se cubren por estructura en el validador (alcanzabilidad).
- **No** prueba balance ni duración (eso es M140/M139).
