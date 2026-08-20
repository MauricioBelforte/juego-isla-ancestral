**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 04-Codigo.md — Módulo 95: Monetización

## 1. Archivos involucrados
La monetización es un **documento de estrategia + config** (no hay gameplay de pago): los únicos artefactos de código son herramientas de soporte y la definición de la tienda del juego (si los DLC añaden items):

| Archivo | Sistema | Propósito |
|---------|---------|-----------|
| `Assets/_Project/Scripts/Data/EdicionesDelJuego.cs` | SO | Catálogo de ediciones (id, nombre, contenido, precio referencia) |
| `Assets/_Project/Scripts/Data/DlcCatalogo.cs` | SO | DLC planificados (id, tipo, contenido, precio) |
| `Assets/Editor/Monetizacion/AntiP2WScanner.cs` | Editor/CI | Scan: 0 ítems de pago que alteren M38/M71 |
| `Assets/Editor/Monetizacion/AntiLootboxScanner.cs` | Editor/CI | Scan: 0 UI/систем de cajas de azar |
| `assets/ops/tabla-impuestos.md` | Documento | Tabla de impuestos por tienda/región (mutable por contabilidad) |

## 2. Funciones clave
```csharp
// EdicionesDelJuego
public Edicion Obtener(string id);          // Standard/Deluxe/Coleccionista
public bool ContieneHistoriaCompleta();     // siempre true (R3)

// DlcCatalogo
public List<DlcInfo> Roadmap();              // DLC-1 y DLC-2

// AntiP2WScanner (Editor)
public Reporte EscanearItemsPago()           // lanza error si itemPago altera progresión
// CI: AntiP2WGate + AntiLootboxGate en build

// tabla-impuestos.md
// Tabla: plataforma | región | tasa | neto esperado por unidad
```

## 3. Datos / config
| Dato | Formato | Sistema |
|------|---------|---------|
| Ediciones | SO | EdicionesDelJuego |
| DLC roadmap | SO | DlcCatalogo |
| Impuestos | Markdown tabulado | tabla-impuestos.md |
| Precio por tienda | API de la tienda (M149) | Publicación (no runtime) |

## 4. Tests (Unity Test Framework — M112)
| Suite | Tipo | Cobertura |
|-------|------|-----------|
| `EdicionesTests` | EditMode | Ediciones sin ventaja; historia completa en todas |
| `AntiP2WTests` | EditMode | Un item de pago "acelerador" agregado por test → scan lo detecta |
| `AntiLootboxTests` | EditMode | Caja de azar simulada → scanner la detecta |
| `DlcRoadmapTests` | EditMode | DLC-1/DLC-2 definidos; sin conflicto de canon (ref M147) |

## 5. Notas de integración
- La tienda del juego NO existe en el juego base (sin microtransacciones); los DLC se compran desde la plataforma (M149).
- Las ediciones solo alteran contenido cosmético/OST; nunca tocan `EconomiaGlobal` (M38) ni `ProgressionManager` (M71).
- Los precios de la tabla (M149) tiran del SO `EdicionesDelJuego` + `tabla-impuestos.md`.
- El AntiP2W/AntiLootbox corre en CI junto al AntiFomoGate (M94): 3 gates de ética monetaria.