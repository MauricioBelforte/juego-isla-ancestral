# 04 — Código — M24: Templos y Puzzles

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Archivos/componentes a crear (implementación futura)

| Archivo | Contenido |
|---|---|
| `Assets/_Project/Scripts/Gameplay/Puzzles/Framework/Emisor.cs` | Emisor de señal (acción del jugador o del mundo) |
| `Assets/_Project/Scripts/Gameplay/Puzzles/Framework/Receptor.cs` | Receptor de señal (efecto visible) |
| `Assets/_Project/Scripts/Gameplay/Puzzles/Framework/Regla.cs` | Conector declarativo emisor→receptor con condiciones |
| `Assets/_Project/Scripts/Gameplay/Puzzles/Framework/EstadoSala.cs` | Vector de estado S, objetivo T, validación de solución |
| `Assets/_Project/Scripts/Gameplay/Puzzles/Framework/PuzzleManager.cs` | Orquestador por sala; serialización JSON/YAML |
| `Assets/_Project/Scripts/Gameplay/Puzzles/Framework/ValidadorArbitrariedad.cs` | Editor + tests: 1 solución única alcanzable |
| `Assets/_Project/Scripts/Gameplay/Puzzles/GuiaTemplo.cs` | Sistema de ayuda por capas (pista → solución) |
| `Assets/_Project/Scripts/Gameplay/Puzzles/PuzzleTimer.cs` | Métricas: tiempo, pistas, abandonos |
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