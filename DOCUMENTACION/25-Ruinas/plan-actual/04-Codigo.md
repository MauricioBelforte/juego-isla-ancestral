# 04 — Código — M25: Ruinas

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Archivos/componentes a crear (implementación futura)

| Archivo | Contenido |
|---|---|
| `Assets/_Project/Scripts/World/Ruins/RuinPiece.cs` | Pieza base del kit: pivote, snaps, lod, validación |
| `Assets/_Project/Scripts/World/Ruins/RuinAssembler.cs` | Editor: ensamblaje de los 13 tipos desde el kit |
| `Assets/_Project/Scripts/World/Ruins/RuinPieceCatalog.asset` | Catálogo de ≤ 40 piezas |
| `Assets/_Project/Scripts/World/Ruins/RuinRuinProfile.cs` (ScriptableObject) | Perfil por ruina tipo |
| `Assets/_Project/Scripts/World/Ruins/RuinProgression.cs` | 4 estados + transiciones + eventos |
| `Assets/_Project/Scripts/World/Ruins/RuinActivators/` (8 scripts) | Sistemas de activación reutilizables |
| `Assets/_Project/Scripts/Data/Ruins/*.json` | Datos de cada ruina (tipo, puzzles, conexiones) |

## API clave (borrador)

```csharp
public class RuinProgression : MonoBehaviour
{
    public enum Estado { NoDescubierta, Descubierta, Explorada, Completada }
    public Estado Current { get; private set; }
    public event Action<Estado> OnEstadoCambio;
    public bool EstaEnProgreso();
    public void MarcarDescubierta();   // 15 m / hint horizonte
    public void MarcarExplorada();     // 50% puzzles
    public void MarcarCompletada();    // puzzles + relicto (M66 cofre)
}

public class RuinAssembler : EditorWindow
{
    public void ValidarKit();          // pivotes, snaps, traslapes → consola
    public void ArmarTipo(RuinTipo t, seed);   // variante de puzzles por seed
}
```

## Reglas de implementación (para quien concrete)

1. Kit ≤ 40 piezas; cada pieza con `Config` (pivote + snaps); la validación en Editor falla → no build.
2. Los datos de cada ruina viven en JSON (tipo, puzzles, conexiones); los scripts solo interpretan.
3. Progresión con eventos (diario, mapa M58, museo M36, guardado atómico); cero Update por ruina.
4. Activadores implementan el contrato del framework M24 (son Emisores/Reglas en datos).
5. No tocar M45/M47 (assets visuales) ni M26 (templo subterráneo).
6. Integración con M66 (objetos únicos al cofre) y M28 (caminos) vía nodos.
7. Documentar cada desvío en `plan-actual/` + Log en `Logs/` + fila 25 del CHECKLIST-GLOBAL.

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa (delegable) — implementación pendiente

- Documenté los 25/25 puntos de la sección 24 con checklist de 100 ítems (ver `05-Checklist.md`).
- El módulo queda **DELEGABLE**: se integra con M24 (puzzles), M26 (templo), M28 (caminos), M36 (museo) y M66 (cofre).
- Clave: el kit modular de ≤ 40 piezas con validación automática en Editor es la base de todo el armado.
- Al implementar, actualizar fila 25 del CHECKLIST-GLOBAL y crear el Log correspondiente.