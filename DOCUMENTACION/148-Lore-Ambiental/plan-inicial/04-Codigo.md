**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 148: Lore Ambiental

## 1. Archivos involucrados

### 1.1 Nuevos
| Archivo | Sistema | Propósito |
|---------|---------|-----------|
| `Assets/_Project/Scripts/World/Lore/PiezaDeLore.cs` | SO | Modelo de datos de la pieza (Id, CanonRef, Tipo, Texto, ConsumidorId) |
| `Assets/_Project/Scripts/World/Lore/LoreCatalogo.cs` | Manager | Catálogo central con índice por isla/tipo; lookup por Id |
| `Assets/_Project/Scripts/World/Lore/TriggerLore.cs` | MonoBehaviour | Trigger de inspección reutilizable (IInteractable) |
| `Assets/_Project/Scripts/World/Lore/TerrenoLoreService.cs` | Servicio | Activa secretos por temporada (M74/M50) |
| `Assets/_Project/Scripts/UI/DiarioLoreSeccion.cs` | UI (M55) | Sección "Lore Ambiental" con contadores y filtros |
| `Assets/Editor/Lore/LoreAuditor.cs` | Editor | Valida canonRef, IDs únicos, grafo de pistas, cobertura por isla |

### 1.2 Modificados
| Archivo | Cambio |
|---------|--------|
| `DiarioManager.cs` (M55) | Sección Lore Ambiental; notificación de nuevo lore |
| `SaveManager.cs` (M59) | Campo `loreExplorado` + migración v3.1 |
| `ColeccionManager.cs` (M73) | Lore en fichas de pez/planta/mineral |
| `NPCAmistad.cs` (M20/M21) | Rumores locativos (nivel ≥ 4) |
| `CalendarioManager.cs` (M74) | Hook de nueva temporada → TerrenoLoreService |

## 2. Funciones clave
```csharp
// LoreCatalogo
public PiezaDeLore ObtenerPieza(string id)
public List<PiezaDeLore> PorIsla(IslaId isla)
public bool EsPistaValida(string consumidorId)   // grafo de pistas

// TriggerLore : MonoBehaviour, IInteractable
public void AlInteractuar() {
    if (save.LoreYaExplorado(id)) return;
    diario.NotificarLore(pieza);
    save.MarcarLoreExplorado(id);
}

// TerrenoLoreService
public void NuevaTemporada(Temporada t) {       // M74 hook
    var ubicaciones = config.SecretosPorTemporada(t);  // 3 c/u
    foreach (var u in ubicaciones) ActivarTrigger(u);
}

// DiarioLoreSeccion
public void MostrarFiltro(FiltroLore f)          // nuevos/leídos/pistas
public int ContadorPorIsla(IslaId isla)

// LoreAuditor (Editor)
public void ValidarCatalogo()          // canonRef + IDs únicos
public void ValidarGrafoDePistas()     // 30 pistas → consumidores existen
public void ReporteCobertura()         // ≥ 12 piezas por isla
```

## 3. Datos / config
| Dato | Formato | Sistema |
|------|---------|---------|
| Catálogo de lore | SO por pieza + `LoreCatalogo` | PiezaDeLore |
| Secretos por temporada | SO `{temporada: [3 ubicaciones]}` | TerrenoLoreService |
| Canon (referencia) | keys de M147 | pieza.CanonRef |
| Estado de exploración | save v3.x `loreExplorado` | SaveManager |
| Rumores locativos | SO de rumores de NPC | NPCAmistad |

## 4. Tests (Unity Test Framework — M112)
| Suite | Tipo | Cobertura |
|-------|------|-----------|
| `LoreCatalogoTests` | EditMode | IDs únicos; canonRef no vacío; por isla ≥ 12 |
| `GrafoDePistasTests` | EditMode | 30 pistas con consumidor existente; 3-pistas por misterio crítico |
| `TriggerLoreTests` | PlayMode | Inspección → notificación + diario; no re-notifica |
| `TerrenoLoreTests` | PlayMode | Nueva temporada activa 3 secretos; persisten |
| `PersistenciaLoreTests` | PlayMode | 30 ciclos save/load sin pérdida; migración v3.1 |
| `ColeccionLoreTests` | EditMode | Fichas pez/planta/mineral con lore cuando corresponda |

## 5. Notas de integración
- La inspección reutiliza `IInteractable` del sistema de interacción (M13/M16), sin UI nueva.
- El lore del diario usa la arquitectura existente de M55 (agrega sección de datos solamente).
- Los rumores de NPC (M21) son el puente de descubrimiento para evitar lore invisible.
- El auditor se ejecuta en CI (LoreGate): falla si hay IDs duplicados, canonRef vacío o cobertura < 12 por isla.
- Compatible con los módulos estables de M13/M55/M73/M74/M20-M23/M34/M35/M50 (no los modifica estructuralmente).
- M10 P2-archivos de datos (JSON/SO) en `Assets/StreamingAssets` o SO según convención del proyecto.