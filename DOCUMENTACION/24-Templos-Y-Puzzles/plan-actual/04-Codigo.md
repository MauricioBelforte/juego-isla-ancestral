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
