# 04 — Código — M66: Anti-Softlock

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Archivos/componentes a crear (implementación futura)

| Archivo | Contenido |
|---|---|
| `Assets/_Project/Scripts/Core/SoftlockGuard.cs` | Singleton detector + recuperador (tick 60 s + eventos) |
| `Assets/_Project/Scripts/Core/Invariants/*.cs` | Invariantes por categoría (objeto, NPC, misión, puzzle, vehículo, jugador) |
| `Assets/_Project/Scripts/Core/Recovery/CofreRecuperacion.cs` | Catálogo de objetos únicos recuperados (1 copia inmutable) |
| `Assets/_Project/Scripts/Core/Recovery/CheckpointManager.cs` | 3 slots/bioma + emergencia; escritura atómica |
| `Assets/_Project/Scripts/Core/Recovery/MisionFallbacks.cs` | Registro declarativo de rutas alternativas por objetivo |
| `Assets/_Project/Scripts/Core/Recovery/NpcRestore.cs`, `VehiculoRestore.cs`, `JugadorRestore.cs` | Recuperaciones por categoría |
| `Assets/_Project/Scripts/Data/SoftlockRules.asset` | Config (tiempos, radios, cantidades de slots) |

## API clave (borrador)

```csharp
public class SoftlockGuard : MonoBehaviour
{
    public static SoftlockGuard I { get; private set; }
    public float TickSegundos;                 // 60 s (config)
    public void Rastrear();                    // dispara chequeo completo
    public void RegistrarClave(string clave);  // misiones publican sus claves
    public void RegistrarFallback(string objetivo, string alternativo, object recompensaEquivalente);
    public void EnCascada(InvariantId id, object contexto);
}

public class CofreRecuperacion : MonoBehaviour
{
    public bool Entregar(string claveUnica);        // 1 sola vez, marca recuperado
    public bool SlotDisponible(string claveUnica);  // no duplica
    public Dictionary<string, bool> IndiceSerializado { get; set; }
}
```

## Reglas de implementación (para quien concrete)

1. No tocar misiones/NPC/vehículos: el guard se suscribe a eventos (persistencia, M22, M64, vehículos), nunca edita sus estados directamente salvo vía `IRecoverable` (interfaz).
2. `IRecoverable` como contrato: `bool EsValido(); bool Recuperar();` — cada sistema implementa su recuperación.
3. Escritura atómica de checkpoints reaprovechando el patrón establecido (tmp+rename+.bak); jamás escribir a mitad de Update.
4. Toast de eventos solo si afecta al jugador (UI M57): nivel informativo, sin interrumpir.
5. La suite de testings provoca softlocks artificialmente (estados injertados en memoria) y verifica la recuperación ≤ 15 s.
6. Documentar cada desvío en `plan-actual/` + Log en `Logs/` + fila 66 del CHECKLIST-GLOBAL.

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa (delegable) — implementación pendiente

- Documenté los 15/15 puntos de la sección 65 con checklist de 100 ítems (ver `05-Checklist.md`).
- El módulo queda **DELEGABLE**: para implementar requiere M22 (Historia Principal) y M26 (Templo Subterráneo) publicando sus invariantes.
- Detector central con reglas declarativas; cosito: cofre de recuperación con copias inmutables —jamás duplicar--.
- Al implementar, actualizar fila 66 del CHECKLIST-GLOBAL y crear el Log correspondiente.