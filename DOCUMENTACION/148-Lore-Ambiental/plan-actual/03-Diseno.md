**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 148: Lore Ambiental

## 1. Arquitectura general

```
[LoreCatalogo (SO/JSON)]                ← única fuente de verdad (canonRef → M147)
        │
        ├── Piezas estáticas (prefabs/triggers en escena)
        │     ruinas, objetos, arquitectura, vegetación, daños, murales, estatuas
        ├── Piezas canalizadas (sistemas existentes)
        │     mapas (M73), canciones (M21), rumores (M21/M23),
        │     peces (M34), plantas (M50), minerales (M35), terreno (M74/M50)
        │
        └── Consumidores de piezas
              Diario Lore Ambiental (M55)   ← notificación + entrada
              Colecciones (M73)             ← lore en fichas de pez/planta/mineral
              Puzzles (M24/M26)             ← pistas de murales
              Sellos/Artefactos (M22/M13)   ← pistas de estatuas
```

## 2. Modelo de datos (LoreCatalogo)

```csharp
[CreateAssetMenu("IslaAncestral/Lore/PiezaDeLore")]
public class PiezaDeLore : ScriptableObject {
    public string Id;                 // unique: "LORE-AUR-001"
    public string CanonRef;           // id del canon en M147 (auditable)
    public IslaId Isla;               // Aurora, Coral, Ceniza, Flora, Velo, Profundidad
    public TipoPieza Tipo;            // Ruina, Objeto, Arquitectura, Vegetacion, Dano,
                                      // Mural, Estatua, Mapa, Cancion, Rumor, Pez, Planta,
                                      // Mineral, Terreno
    public string TextoLore;          // 3-5 líneas (plantilla por tipo)
    public string ConsumidorId;       // pista dirigida: puzzle/sello/coleccionable/rumor
    public bool EsPista;              // si es pista, participa del grafo
}
```

## 3. Flujos principales

### 3.1 Inspección (piezas estáticas)
```
Jugador → Interactuar (IInteractable) → TriggerLore (colider/trigger)
   └─ LoreCatalogo.ObtenerPieza(id)
   └─ save v3.x: yaExplorado? → no notificar de nuevo
   └─ Diario.AddLore(pieza) → notificación "Lore nuevo en diario (isla x/y)"
```

### 3.2 Pistas (grafo dirigido)
```
PiezaPista (mural/estatua/mapa/canción) → ConsumidorId → consumidor objetivo
   └─ Trazabilidad: script valida que ConsumidorId exista en su catálogo
   └─ Regla 3-pistas: cada misterio crítico (sello, artefacto, puzzle final)
      tiene ≥ 3 pistas distintas; el jugador puede resolver con 2/3
```

### 3.3 Lore canalizado
- **Peces/Plantas/Minerales**: al completar una ficha (captura/cosecha/extracción), la entrada de colección (M73) incorpora el `TextoLore` de la pieza vinculada (`ConsumidorId` = id de la ficha).
- **Mapas**: ítem coleccionable (M73) con lore; al recolectarlo pasa al diario (M55).
- **Canciones**: aprendidas por eventos/amistad (M20); el rumor se registra cuando el NPC la canta (M21).
- **Rumores**: los NPC (M21/M23) dan acceso locativo al lore de su zona al avanzar amistad (nivel ≥ 4).

### 3.4 Terreno que revela secretos
```
Calendario (M74) → nueva temporada → TerrenoService.MarcarUbicaciones(id, 3)
   └─ los triggers de lore ocultos se activan en la nueva temporada
   └─ se registran en el diario como "El terreno ha cambiado... (isla)"
```
- 3 ubicaciones por temporada (verano/otoño/invierno/primavera) = 12 secretos anuales de ciclo.

## 4. Distribución de piezas (objetivo mín. 72)
| Isla | Piezas mín. | Composición sugerida |
|------|-------------|----------------------|
| Aurora | 12 | 3 ruinas, 2 objetos, 1 arquitectura, 1 vegetación, 1 daño, 1 mural, 1 estatua, 1 mapa, 1 rumor |
| Coral | 12 | 3 ruinas, 2 objetos, 1 arquitectura, 2 daños, 1 mural, 1 estatua, 1 canción, 1 rumor |
| Ceniza | 12 | 2 ruinas, 3 objetos, 2 arquitectura, 2 daños, 1 mural, 1 estatua, 1 mapa |
| Flora | 12 | 2 ruinas, 2 objetos, 2 vegetación, 1 daño, 2 murales, 1 estatua, 1 canción, 1 rumor |
| Velo | 12 | 3 ruinas, 2 objetos, 1 arquitectura, 2 vegetación, 1 mural, 1 estatua, 1 mapa, 1 rumor |
| Profundidad | 12 | 3 ruinas, 2 objetos, 2 arquitectura, 2 daños, 1 mural, 1 estatua, 1 canción |
| **Total** | **72** | 30 pistas dentro del total (murales/estatuas/mapas/canciones) |

## 5. Integración con el diario (M55)
```
Sección "Lore Ambiental"
   └─ Contador por isla: "Lore de Aurora 8/12"
   └─ Filtro: Nuevos / Leídos / Pistas
   └─ Entrada con tipo de pieza + texto + isla
```

## 6. Regla anti-infodump (RF7)
- **Proporción:** ≥ 60% del trasfondo narrativo viaja en lore ambiental; los diálogos cuentan trama y estados, no explican el mundo.
- **Auditoría:** muestreo de 10 zonas (2 por isla) con checklist: "¿este diálogo explica algo que ya debería contarse en el mundo?"
- **Plantilla de texto por tipo:** ruina 3-5 líneas (historia del lugar), objeto 2-3 líneas (procedencia), arquitectura 2 líneas (cultura constructiva), daño 2 líneas (evento pasado), planta/pez/mineral 2-3 líneas (mito local).

## 7. Persistencia (RF8/M59)
- Save v3.x: `loreExplorado: {piezaId: bool}` + `lorePorIsla: {isla: count}`.
- Compatibilidad: los saves previos sin el campo se inicializan en vacío (migración v3.1).
- 30 ciclos de carga/guardado sin pérdida (test M112).