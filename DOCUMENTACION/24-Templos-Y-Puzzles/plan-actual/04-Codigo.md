# 04 — Código — M24: Templos y Puzzles

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Archivos/componentes a crear (implementación futura)

| Archivo | Contenido |
|---|---|
| `Assets/_Project/Scripts/Gameplay/Puzzles/Framework/Emisor.cs` _(diseno heredado)_ | Emisor de señal (acción del jugador o del mundo) |
| `Assets/_Project/Scripts/Gameplay/Puzzles/Framework/Receptor.cs` _(diseno heredado)_ | Receptor de señal (efecto visible) |
| `Assets/_Project/Scripts/Gameplay/Puzzles/Framework/Regla.cs` _(diseno heredado)_ | Conector declarativo emisor→receptor con condiciones |
| `Assets/_Project/Scripts/Gameplay/Puzzles/Framework/EstadoSala.cs` _(diseno heredado)_ | Vector de estado S, objetivo T, validación de solución |
| `Assets/_Project/Scripts/Gameplay/Puzzles/Framework/PuzzleManager.cs` _(diseno heredado)_ | Orquestador por sala; serialización JSON/YAML |
| `Assets/_Project/Scripts/Gameplay/Puzzles/Framework/ValidadorArbitrariedad.cs` _(diseno heredado)_ | Editor + tests: 1 solución única alcanzable |
| `Assets/_Project/Scripts/Gameplay/Puzzles/GuiaTemplo.cs` _(diseno heredado)_ | Sistema de ayuda por capas (pista → solución) |
| `Assets/_Project/Scripts/Gameplay/Puzzles/PuzzleTimer.cs` _(diseno heredado)_ | Métricas: tiempo, pistas, abandonos |
| `Assets/_Project/Scripts/Data/Puzzles/*.json` | Datos por familia (15 carpetas con archivos por sala) |

## API clave (borrador)

```csharp
public class PuzzleManager : MonoBehaviour
{
    public EstadoSala Estado;                      // vector de sala
    public EstadoSala Objetivo;                    // solución única verificable
    public bool Completado { get; private set; }
    public void ActivarEmisor(string id);          // acción del jugador/mundo
    public bool EstaACasiSolucion();               // 1 paso del objetivo (feedback sutil)
    public void ReiniciarASlot();                  // contrato M66
    public void GuardarCheckpoint();               // atomico tmp+rename+.bak
}

public class ValidadorArbitrariedad
{
    public bool EsUnicaSolución(List<Regla> reglas, EstadoSala T);
    // BFS/DPLL sobre estados alcanzables: exactamente 1 camino T
}
```

## Reglas de implementación (para quien concrete)

1. Todo puzzle se define en **datos** (JSON/YAML); el código es solo el intérprete del framework emisor→receptor.
2. El Validador corre en Editor (errores en consola al armar salas) y en tests (falla → no build).
3. Runtime ≤ 1 ms por tick; cero allocations en Update; serialización con JsonUtility/System.Text.Json según entorno.
4. Integración obligatoria con M66: `IRecoverable` en PuzzleManager (ReiniciarASlot).
5. No tocar M25/M26 (salas), M45/M47 (assets) ni M13 (dependencia declarada; se integra vía eventos).
6. Instrumentar `PuzzleTimer` (tiempo, pistas usadas, abandonos) para playtests externos.
7. Documentar cada desvío en `plan-actual/` + Log en `Logs/` + fila 24 del CHECKLIST-GLOBAL.

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa (delegable) — implementación pendiente

- Documenté los 26/26 puntos de la sección 23 con checklist de 100 ítems (ver `05-Checklist.md`).
- El módulo queda **DELEGABLE**: se integra con M13 (framework emisor→receptor, dependencia), M66 (reinicio), M25/M26 (salas) y M43 (cues).
- Clave: el Validador de arbitrariedad (1 solución única) es la garantía de "puzzles justos".
- Al implementar, actualizar fila 24 del CHECKLIST-GLOBAL y crear el Log correspondiente.

## Implementacion real en Godot (iter. 1 — DeepSeek-V4.1-Flash, 2026-10-07)

Las rutas C# de arriba son **diseno heredado de Unity** (no existen en el proyecto). La implementacion viva del framework emisor->receptor esta en `game/isla-ancestral/scripts/templos/`:

| Archivo | Contenido | Iter. |
|---|---|---|
| `scripts/templos/puzzle_room.gd` | `PuzzleRoom`: vector S, reglas, `recalcular()`, `validar()`. Iter. 1 anade (aditivo) el campo `objetivo`, `vector_objetivo()`, `distancia_objetivo()`, `estado_igual_objetivo()`, `esta_a_casi_solucion()`. | Hy3 / DeepSeek |
| `scripts/templos/puzzle_emisor.gd` | `PuzzleEmisor`: golpe / placa. Iter. 1 anade (aditivo) `umbral_peso` + `recibir_peso(peso)`. | Hy3 / DeepSeek |
| `scripts/templos/puzzle_puerta.gd` | `PuzzlePuerta`: receptor; abre el sello de voxels. | Hy3 |
| `scripts/templos/puzzle_def.gd` | **NUEVO iter. 1.** `PuzzleDef` (RefCounted + static): `cargar`, `ids_emisores`, `ids_objetivo`, `validar_def`, `soluciones_minimas`, `solucion_minima`, `completado_por`, `a_puzzle_room`, `umbral_peso_de`. Interprete datos-driven + validador de unicidad real. | DeepSeek |
| `scripts/templos/test_puzzles.gd` | Suite heredada del framework (0 fallos). | Hy3 |
| `scripts/templos/test_puzzle_datos.gd` | **NUEVO iter. 1.** Suite headless del interprete datos-driven: 42 checks, 0 fallos, EXIT 0 x3; piso `CHECKS_MINIMOS` medido; guardian probado EN ROJO por 3 inyecciones; detector de ambiguedad probado EN ROJO. | DeepSeek |
| `data/templos/puzzles/presion/presion_01.json`, `presion_02.json` | **NUEVOS iter. 1.** 2 puzzles de la familia presion en formato `{emisores, reglas, objetivo}` (umbral de peso por emisor). | DeepSeek |

**Formato de datos:** `{ "id", "familia", "schema_version", "emisores": [{"id","tipo","etiqueta","umbral_peso"}], "reglas": [{"emisores":[ids],"receptor":"..."}], "objetivo": [ids] }`.

**Contrato:** el codigo es solo el interprete; cada puzzle se define en datos (regla 1 de esta seccion). El validador de unicidad (`soluciones_minimas == 1`) corre en tests; el gate de CI queda **pendiente de visto bueno de s2** (dueno de `quality.yml`).

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — Log 1407.

## Framework emisor→receptor — mapa de conceptos a código (iter. 2 — DeepSeek-V4.1-Flash, 2026-10-07)

| Concepto | Archivo | API clave |
|---|---|---|
| Emisor | `scripts/templos/puzzle_emisor.gd` | `recibir_golpe()`, `set_activo(bool)`, `recibir_peso(peso)` (+ `umbral_peso`) |
| Receptor | `scripts/templos/puzzle_puerta.gd` | `evaluar(activos)`, `abrir()` |
| Regla | `scripts/templos/puzzle_room.gd` / `puzzle_def.gd` | `PuzzleRoom.add_regla(emisores, receptor)`, `PuzzleDef.reglas_def(def)` |
| EstadoSala | `scripts/templos/puzzle_room.gd` | `emisores`, `get_vector_estado()`, `recalcular()` |
| Objetivo único | `scripts/templos/puzzle_def.gd` / `puzzle_room.gd` | `PuzzleDef.ids_objetivo(def)`, `PuzzleRoom.objetivo`, `estado_igual_objetivo()` |

## Familia multilateral (iter. 2 — DeepSeek-V4.1-Flash, 2026-10-07)

| Archivo | Contenido |
|---|---|
| `scripts/templos/test_puzzle_multilateral.gd` | **NUEVO iter. 2.** Suite headless de la familia multilateral: 38 checks, 0 fallos, EXIT 0 x3; piso `CHECKS_MINIMOS=38` medido; **sonda ROJA en vivo** (ambigüedad inyectada en el JSON real -> EXIT 1 con 6 fallos nombrados; JSON restaurado byte-exacto, sha256 verificado). |
| `data/templos/puzzles/multilateral/multilateral_anillos.json` | **NUEVO iter. 2.** Migración de `puz_anillos` (columna de 7 anillos de M26): 7 emisores (glifos) + regla central AND + objetivo `[0..6]`. |
| `data/templos/puzzles/multilateral/multilateral_final_3fases.json` | **NUEVO iter. 2.** Migración de `puz_final_3fases` (luz+sonido+agua): 3 emisores de fase + regla final AND + objetivo `[0..2]`. |

**Contrato:** el código sigue siendo el intérprete; los 2 puzzles multilaterales se definen en datos y los valida `PuzzleDef.validar_def`. El gate de CI de la suite queda **pendiente de visto bueno de s2** (dueño de `quality.yml`).

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — iter. 2.

## Familia bloques (iter. 3 — DeepSeek-V4.1-Flash, 2026-10-07)

| Archivo | Contenido |
|---|---|
| `scripts/templos/puzzle_bloques.gd` | **NUEVO iter. 3.** `PuzzleBloques` (RefCounted): capa espacial de la familia bloques. `cargar` / `desde_def`, `empujar(pieza_id, dx, dy)`, `eje_de`, `posicion`, `ranura_de`, `ranuras_ocupadas`, `puente_activo`, `validar_espacial`. Traduce posiciones→emisores sobre un `PuzzleRoom`; no modifica el framework. |
| `data/templos/puzzles/bloques/bloques_01.json` | **NUEVO iter. 3.** 1 bloque, eje `x`, 1 ranura, receptor `puente_bloques`. |
| `data/templos/puzzles/bloques/bloques_02.json` | **NUEVO iter. 3.** 2 bloques (uno eje `x`, uno eje `y`), 2 ranuras, regla AND → `puente_bloques`. |
| `scripts/templos/test_puzzle_bloques.gd` | **NUEVO iter. 3.** Suite headless: 64 checks, 0 fallos, EXIT 0 ×3; piso `CHECKS_MINIMOS=64` **medido**; **sonda ROJA en vivo** (eje inválido inyectado en el JSON real → 12 fallos nombrados, EXIT 1; JSON restaurado byte-exacto, sha256 verificado). |

| Concepto (familia bloques) | Archivo | API clave |
|---|---|---|
| Pieza empujable | `scripts/templos/puzzle_bloques.gd` | `empujar(pieza_id, dx, dy)`, `eje_de(id)`, `posicion(id)` |
| Ranura de destino | `scripts/templos/puzzle_bloques.gd` | `ranura_de(id)`, `ranuras_ocupadas()` |
| Puente desplegable | `scripts/templos/puzzle_bloques.gd` / `puzzle_puerta.gd` | `puente_activo()` (receptor `puente_bloques`) |
| Límites de sala | `scripts/templos/puzzle_bloques.gd` | `limites`, `validar_espacial()` |

**Contrato:** `PuzzleBloques` es el intérprete espacial; los puzzles se definen en datos
(`{emisores, reglas, objetivo}` + bloque `bloques`) y los validan `PuzzleDef.validar_def` +
`PuzzleBloques.validar_espacial`. El gate de CI de la suite queda **pendiente del visto bueno de s2**
(dueño de `quality.yml`).

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — iter. 3.

## Familias luz y espejos (iter. 4 — DeepSeek-V4.1-Flash, 2026-10-07)

| Archivo | Contenido |
|---|---|
| `scripts/templos/puzzle_luz.gd` | **NUEVO iter. 4.** `PuzzleLuz` (RefCounted): intérprete del grafo óptico. `cargar` / `desde_def`, `trazar()` (traza paso a paso; devuelve `{celdas, concentracion, llega, receptor_activado, salidas, pasos}`), `celdas` / `concentracion` / `llega` / `receptor_activado` / `pasos` / `salidas` / `direccion_salida`, `angulo_espejo` / `set_angulo_espejo`, `bloquear` / `desbloquear` / `esta_bloqueada`, `validar_optica`; estáticos `nombre_dir` / `_norm_angulo`. Mapea el recorrido del rayo → emisores sobre un `PuzzleRoom`; no modifica el framework. |
| `data/templos/puzzles/luz/luz_01.json` | **NUEVO iter. 4.** 4x4, fuente (0,3)→E, espejo_a (3,3) a 45°, cristal (3,1) conc 0: el rayo E→N. |
| `data/templos/puzzles/luz/luz_02.json` | **NUEVO iter. 4.** 6x4, fuente (0,0)→E, lente_a (2,0) conc 1, prisma_a (4,0) desvío 90°, cristal (4,2) conc 1: el rayo E→S. |
| `scripts/templos/puzzle_espejos.gd` | **NUEVO iter. 4.** `PuzzleEspejos` (RefCounted): capa de rotación que **compone** un `PuzzleLuz` (ítem 52). `cargar` / `desde_def`, `rotar(id, grados)`, `es_movil` / `es_fijo` / `angulo`, `camino` / `validar_camino`, `feedback(id)`, `direccion_salida`, `validar_espejos`, `receptor_activado` / `llega` / `concentracion` / `sala`. |
| `data/templos/puzzles/espejos/espejos_01.json` | **NUEVO iter. 4.** 6x6, espejo_a (2,0) 135° FIJO + espejo_b (2,4) 0° MÓVIL (+45°), cristal (0,4). |
| `data/templos/puzzles/espejos/espejos_02.json` | **NUEVO iter. 4.** 5x5, espejo_a (4,0) 45° MÓVIL (+90°) + espejo_b (4,4) 135° MÓVIL (+90°), cristal (0,4). |
| `scripts/templos/test_puzzle_luz.gd` | **NUEVO iter. 4.** Suite headless: 60 checks, 0 fallos, EXIT 0 ×3; piso `CHECKS_MINIMOS=60` **medido**; **sonda ROJA en vivo** (ángulo 30 en el JSON real → 11 fallos nombrados, EXIT 1; JSON restaurado byte-exacto, sha256 `4f0000af…`). |
| `scripts/templos/test_puzzle_espejos.gd` | **NUEVO iter. 4.** Suite headless: 62 checks, 0 fallos, EXIT 0 ×3; piso `CHECKS_MINIMOS=62` **medido**; **sonda ROJA en vivo** (espejo fijo a 90 en el JSON real → 9 fallos nombrados, EXIT 1; JSON restaurado byte-exacto, sha256 `e2b08324…`). |
| `scripts/templos/test_regresion_templos.gd` | **NUEVO iter. 4.** Gate de regresión (Frente 0): corre las 8 suites como subprocesos y exige EXIT 0 + 0 `SCRIPT ERROR` + checks ≥ piso por suite; 51 checks, 0 fallos, EXIT 0 ×3; total MEDIDO 362 == piso 362; incluye sonda roja del clasificador. |

| Concepto (familias luz/espejos) | Archivo | API clave |
|---|---|---|
| Fuente + dirección | `scripts/templos/puzzle_luz.gd` | `fuente_pos`, `fuente_dir` |
| Espejo (ángulo 0/45/90/135) | `scripts/templos/puzzle_luz.gd` | `angulo_espejo(id)`, `direccion_salida(id)`, `_reflexion(dir, angulo)` |
| Lente (concentración) | `scripts/templos/puzzle_luz.gd` | `concentracion()`, `lentes[id].concentracion` |
| Prisma (desvío 90) | `scripts/templos/puzzle_luz.gd` | `_desviar(dir, grados)`, `prismas[id].desvio` |
| Cristal receptor | `scripts/templos/puzzle_luz.gd` | `cristal_pos`, `cristal_requerida`, `receptor_activado()` |
| Ocultación (jugador) | `scripts/templos/puzzle_luz.gd` | `bloquear(celda)`, `desbloquear(celda)`, `esta_bloqueada(celda)` |
| Rotación discreta | `scripts/templos/puzzle_espejos.gd` | `rotar(id, grados)`, `es_movil(id)`, `es_fijo(id)` |
| Camino verificable | `scripts/templos/puzzle_espejos.gd` | `camino()`, `validar_camino()` |
| Feedback de dirección | `scripts/templos/puzzle_espejos.gd` | `feedback(id)` → `"E->N"` |

**Contrato:** `PuzzleLuz` es el motor óptico y `PuzzleEspejos` la capa de rotación (compone a `PuzzleLuz`).
Los puzzles se definen en datos (`{emisores, reglas, objetivo}` + bloque `luz` + bloque `espejos`) y los
validan `PuzzleDef.validar_def` + `PuzzleLuz.validar_optica` + `PuzzleEspejos.validar_espejos`. El gate de
CI de las suites queda **pendiente del visto bueno de s2** (dueño de `quality.yml`).

**Firma:** DeepSeek-V4.1-Flash (WorkBuddy) — iter. 4.
