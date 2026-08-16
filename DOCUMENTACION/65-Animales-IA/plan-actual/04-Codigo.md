# 04 — Código — M65: Animales IA

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Archivos/componentes a crear (implementación futura)

| Archivo | Contenido |
|---|---|
| `Assets/_Project/Scripts/AI/FaunaManager.cs` | Orquestador de fauna; delega del NPCManager (M64); burbuja 64 m, tick 1 s lejanos, presupuesto |
| `Assets/_Project/Scripts/AI/FaunaBrain.cs` | FSM datos-driven: estados del perfil + agenda (hambre, energía, etapa) |
| `Assets/_Project/Scripts/AI/FaunaProfile.cs` (ScriptableObject) | Perfil por especie: biomas, horarios, radios (huida/curiosidad/alarma), comida, velocidad, manada |
| `Assets/_Project/Scripts/AI/FaunaBody.cs` | Pool: cuerpo + animación instanciada + anclado (reciclado fuera de burbuja) |
| `Assets/_Project/Scripts/AI/PackLogic.cs` / `SchoolLogic.cs` | Manada/banco: delta ≤ 1.2 m, líder rotativo, sincronización leve |
| `Assets/_Project/Scripts/AI/FaunaSpawner.cs` | Sorteo por slot (pesos por bioma), densidad, validación de navegación, despawn/rehidratación |
| `Assets/_Project/Scripts/Data/FaunaCatalog.asset` | Catálogo de especies (15-25 perfiles) |
| M42/M43 (audio) | Timestamps por evento con cooldowns (tabla del diseño) |

## API clave (borrador)

```csharp
public enum FaunaState { Dormir, Pastorear, Hidratarse, Comer, Explorar, Curiosear, Huir, Migrar, Reproducir, Anclado }

public class FaunaManager : MonoBehaviour
{
    public int Activos { get; private set; }
    public int PresupuestoAnimales { get; private set; }   // M61: tope global
    public bool EntraEnPresupuesto(FaunaBody body);        // tope + bioma + manada
    public void Anclar(FaunaBody body);                    // reciclaje fuera de burbuja
    public FaunaBody Rehidratar(AncladoRecord r);          // estado completo al volver
}

public class FaunaSpawner : MonoBehaviour
{
    public bool SlotValido(Slot s, FaunaProfile p);        // navegable + suelo/agua correctos
    public FaunaBody SorteoSpawn(Bioma b, int slotId);     // seed = seedPartida + biomaId + slotId
    public void RevalidarZona(Chunk c);                    // M08/M28: revalidación por chunk
}
```

## Reglas de implementación (para quien concrete)

1. **No tocar** NPCManager (M64) salvo contrato `FaunaManager`; compartir pool, NavigationServer3D y watchdog anti-atasco.
2. FSM con agenda en datos, sin behavior tree; estados unit-testables sin escena.
3. Toda operación asíncrona con callbacks; cero `WaitForSeconds` en Update; cero asignaciones (pool).
4. `FaunaProfile` sobre ScriptableObject; perfiles por especie; pesos normalizados por bioma.
5. Los estados con efectos colaterales (sonido, cría, migración) emiten eventos → managers (M42/M43, M29, M36).
6. Documentar cada desvío en `plan-actual/` + Log en `Logs/` + fila 65 del CHECKLIST-GLOBAL con estado real.

## Notas del Agente

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa (delegable) — implementación pendiente

- Documenté los 19/19 puntos de la sección 64 con checklist de 100 ítems (ver `05-Checklist.md`).
- El módulo queda **DELEGABLE**: depende de M36, M64 (ya documentados) para su implementación; presupuestos M61 necesarios.
- Reproducción sin explotación: sin loot ni crías recolectables (regla cozy).
- Al implementar, actualizar fila 65 del CHECKLIST-GLOBAL y crear el Log correspondiente.