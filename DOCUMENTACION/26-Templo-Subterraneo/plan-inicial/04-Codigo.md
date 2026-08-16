# 04 — Código — M26: Templo Subterráneo

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Archivos/componentes a crear (implementación futura)

| Archivo | Contenido |
|---|---|
| `Assets/_Project/Scripts/World/Templo/TempleFlow.cs` | Orquestador de gating (estado del templo: sellos, anillos, salida) |
| `Assets/_Project/Scripts/World/Templo/TempleVoxelBlueprint.asset` | Blueprint voxel-compatible del templo (metría 4x4x4) para M08 |
| `Assets/_Project/Scripts/World/Templo/AnilloViento.cs` | Mecanismo de 7 anillos (M24 símbolos + multilateral) |
| `Assets/_Project/Scripts/World/Templo/PuzzleFinalFases.cs` | 3 fases (luz+sonido+agua) |
| `Assets/_Project/Scripts/World/Templo/TempleCheckpoint.cs` | 5 CP atómicos + telemetría early-exit |
| `Assets/_Project/Scripts/World/Templo/TempleTelemetry.cs` | Telemetría de puzzles (JSON → M24) |
| `Assets/_Project/Scripts/Data/Templo/*.json` | Salas, gating, sellos, glifos |

## API clave (borrador)

```csharp
public class TempleFlow : MonoBehaviour
{
    public int Sellos;                                   // 0..7
    public bool SelloRestaurado { get; private set; }
    public event Action<int> OnAnilloActivado;
    public bool IntentarSello(int anillo, string detalleDelGlifo);  // M24
    public void RestaurarSello();                        // abre salida + cutscene hook
    public bool SalidaAbierta { get; private set; }
}

public class TempleTelemetry : MonoBehaviour
{
    public void RegistrarIntento(string puzzleId);       // intentos, pistas, tiempo
    public string ExportarJson();                        // balance M24
}
```

## Reglas de implementación (para quien concrete)

1. El templo se genera desde `TempleVoxelBlueprint` (M08); el diseño de salas es datos, no código.
2. Gating estricto: la salida se abre solo con `RestaurarSello()`; los sellos son objetos únicos (cofre M66).
3. Los 5 CP usan el patrón de guardado atómico + `.bak` (persistencia del proyecto).
4. Anti-exploit: sin teleports (salvo M66), rampas ≤ 20°, barreras invisibles en huecos; suite de saltos.
5. Telemetría en JSON exportable a M24 (balance de dificultad).
6. No tocar M45/M47 (assets) ni M33 (cutscenes) — solo hooks.
7. Documentar cada desvío en `plan-actual/` + Log en `Logs/` + fila 26 del CHECKLIST-GLOBAL.

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa (delegable) — implementación pendiente

- Documenté los 26/26 puntos de la sección 25 con checklist de 100 ítems (ver `05-Checklist.md`).
- El módulo queda **DELEGABLE**: requiere M08 (voxel), M24/M25 (puzzles y ruinas), M66 (antisoftlock), M58 (accesibilidad) y presupuestos M61.
- Clave: metría voxel fija (4x4x4 m) para que M08 lo genere sin retrabajo; gating por 7 anillos + sello único.
- Al implementar, actualizar fila 26 del CHECKLIST-GLOBAL y crear el Log correspondiente.