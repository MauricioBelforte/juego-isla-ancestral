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

**Modelo:** ox-alpha
**Plataforma:** Cline
**Fecha:** 2026-08-25
**Estado:** Parcial — núcleo implementado y validado (18/117 ítems `[x]`)

### Lo que hice (2026-08-25)

Implementé el **núcleo funcional** del detector anti-softlock en Godot 4.7.2 (adaptación GDScript del diseño C#):

- `scripts/core/softlock_guard.gd` — Autoload singleton: tick 60 s, dispatcher de invariantes por prioridad, cascada de recuperación vía handlers duck-typed (`has_method("es_valido")/("recuperar")`), ventana de 3 fallos/10 min, toasts con cooldown. Usa `preload()` para las clases del módulo (los autoloads se compilan antes que los `class_name` externos).
- `scripts/core/softlock_rules.gd` — Config central (constantes: tiempos, radios, slots).
- `scripts/core/invariants/irecoverable.gd` — Contrato `IRecoverable` (`class_name`, extends RefCounted) + enum `CategoriaRecuperable`.
- `scripts/core/invariants/invariant_base.gd` + 6 invariantes (Jugador, Misión, NPC, ObjetoClave, Vehículo, Puzzle) con registro de claves/fallbacks.
- `scripts/core/recovery/cofre_recuperacion.gd` — Cofre Node: 12 slots, copia inmutable por clave, jamás duplica (`fue_entregada`), serializable.
- `scripts/core/recovery/checkpoint_manager.gd` — 3 slots rotativos/bioma + global; escritura atómica tmp+rename+.bak **reutilizando SaveWriter** (M59) con checksum SHA-256.
- Autoload `SoftlockGuard` registrado en `project.godot`.

### Validación

`--check-only --verbose` headless: **"Completed load"** para softlock_guard.gd y dependencias, 0 errores M66/M59/M159. Único error del proyecto: `main_island.tscn:36` (preexistente, módulo terreno).

### Bugs encontrados y documentados (honestidad obligatoria)

1. **`class_name` colisiona con autoload**: `class_name SoftlockGuard` + autoload del mismo nombre → `Parse Error: Class hides an autoload singleton`. Solución: sin `class_name` en el autoload.
2. **Orden en GDScript**: `extends` DEBE ir antes de las `const preload` → `Unexpected "extends" in class body`.
3. **Autoload vs class_name race**: un autoload NO puede referenciar `class_name` de scripts que aún no cargaron → `Identifier not declared`. Solución: `preload()` explícito.
4. **API DirAccess 4.x**: métodos estáticos correctos son `dir_exists_absolute()` / `make_dir_absolute()` / `rename_absolute()`. `folder_exists()` y `dir_exists()` estático NO existen.
5. **Inferencia de tipos**: `var x := dict.get(k)` falla (Variant) → envolver con `int(...)`.

(Ítems 1-4 complementan lo ya registrado en `07-GUIA-GODOT.md` §8/§9.)

### Lo que NO pude hacer (pendiente, honestidad)

- Hooks reales de disparo (transición de escena / al guardar): existen `forzar_chequeo()` pero falta conectarlos a SaveManager/scene_router (esos sistemas aún no exponen eventos).
- Lógica concreta de detección en NPC/Misión/Puzzle/Vehículo/Jugador invariantes: delegadas a M64/M22/M24-M26/sistema vehículos/player, que aún no existen como código. Los stubs devuelven válido.
- Watchdog 2s/6s NPC (requiere M64), amarre de vehículos (requiere sistema de vehículos), teleport jugador (requiere player + checkpoints conectados).
- Tests automatizados de provocación de softlocks (06-Plan-Testings pendiente de ejecutar cuando existan consumidores).

### Recomendaciones para el próximo agente

- Al implementar M64 (NPC), registrar un handler IRecoverable vía `SoftlockGuard.registrar_handler(handler)` y conectar el watchdog real dentro de NpcInvariant.
- Conectar `SaveManager.save_completed` → `SoftlockGuard.forzar_chequeo("guardado")` cuando se integre UI de guardado (M53).
- El cofre es `Node` (no Node3D): la representación física 3D debe ser una escena aparte que consulte `SoftlockGuard.cofre`.

## Notas del Agente (histórico)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17
**Estado:** Documentación completa (delegable) — implementación pendiente

- Documenté los 15/15 puntos de la sección 65 con checklist de 100 ítems (ver `05-Checklist.md`).
- El módulo queda **DELEGABLE**: para implementar requiere M22 (Historia Principal) y M26 (Templo Subterráneo) publicando sus invariantes.
- Detector central con reglas declarativas; cosito: cofre de recuperación con copias inmutables —jamás duplicar--.
- Al implementar, actualizar fila 66 del CHECKLIST-GLOBAL y crear el Log correspondiente.