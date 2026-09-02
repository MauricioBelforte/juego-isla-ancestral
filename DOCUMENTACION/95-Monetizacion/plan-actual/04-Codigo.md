**Modelo:** deepseek-v4-flash (último modificador)
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01 (implementación iter. 1 núcleo; diseño original Unity/C# por Deepseek V4 Flash / OpenCode 2026-08-20)

# 04-Codigo.md — Módulo 95: Monetización

## 1. Archivos involucrados (REAL — Godot 4.7 / GDScript)

### 1.1 Nuevos (`game/isla-ancestral/scripts/monetizacion/`)
| Archivo | Propósito |
|---------|-----------|
| `edicion_catalogo.gd` | `EdicionCatalogo`: catálogo de ediciones (Standard/Deluxe/Coleccionista) desde JSON, con `contiene_historia_completa()` |
| `dlc_catalogo.gd` | `DlcCatalogo`: roadmap de DLC (expansión + cosmético) desde JSON, `es_cosmetico()`, orden de lanzamiento |
| `scanner_antip2w.gd` | `ScannerAntip2w`: scan anti-pay-to-win (0 ítems de pago que alteren progresión) |
| `scanner_antilootbox.gd` | `ScannerAntilootbox`: scan anti-lootbox (0 cajas de azar) |
| `test_monetizacion_m95.gd` | Test headless (27/0 OK) |
| `data/monetizacion/ediciones.json` | 3 ediciones con precio USD, historia_completa=true en todas |
| `data/monetizacion/dlc.json` | DLC-1 expansión + DLC-2 cosmético |
| `data/monetizacion/impuestos.json` | Tabla de impuestos por plataforma/región |

### 1.2 Diferencias vs diseño original (Unity/C#)
- `EdicionesDelJuego.cs` (SO) → `edicion_catalogo.gd` (RefCounted + JSON data-driven)
- `DlcCatalogo.cs` (SO) → `dlc_catalogo.gd` (RefCounted + JSON)
- `AntiP2WScanner.cs` / `AntiLootboxScanner.cs` (Editor) → `scanner_antip2w.gd` / `scanner_antilootbox.gd` (helpers estáticos GDScript, ejecutables en test headless)
- `tabla-impuestos.md` → `data/monetizacion/impuestos.json` (data-driven)

## 2. API pública

### 2.1 `edicion_catalogo.gd`
```gdscript
cargar() -> void
obtener(id) -> Dictionary
contiene_historia_completa(id) -> bool   # siempre true (RF/03)
ids() -> Array
cantidad() -> int
```

### 2.2 `dlc_catalogo.gd`
```gdscript
cargar() -> void
obtener(id) -> Dictionary
roadmap() -> Array                       # ordenado por lanzamiento
es_cosmetico(id) -> bool
cantidad() -> int
```

### 2.3 `scanner_antip2w.gd` (static)
```gdscript
escanear(items_pago: Array) -> Array[String]   # 0 violaciones = OK
reporte(violaciones) -> String
```

### 2.4 `scanner_antilootbox.gd` (static)
```gdscript
escanear(sistemas: Array) -> Array[String]     # 0 violaciones = OK
reporte(violaciones) -> String
```

## 3. Datos (JSON data-driven)
- **ediciones.json**: standard $24.99, deluxe $34.99, coleccionista $59.99 — todas con `historia_completa: true` (RF: la historia completa está en el juego base).
- **dlc.json**: DLC-1 expansión (nueva isla, $14.99), DLC-2 cosmético ($4.99) — sin fragmentar historia.
- **impuestos.json**: tasa por plataforma/región (Steam/Epic/GOG × latam/eu/us).

## 4. Verificación
- Test M95: `Godot --headless --path game/isla-ancestral --script res://scripts/monetizacion/test_monetizacion_m95.gd` → **27 checks, 0 fallos**.
- Regresión M60: **66/0 OK**.

## 5. Pendientes honestos (81 ítems de checklist)
- Documentos de estrategia (modelo comercial, reembolsos, descuentos, bundles) — son documentos, no código (M149 publicación).
- Gates CI reales (AntiP2WGate/AntiLootboxGate en pipeline M112).
- Integración con M149 (precios por tienda reales).

## Notas del Agente

**Modelo:** deepseek-v4-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-01
**Estado:** Núcleo implementado (iter. 1), 🟡 liberado

### Lo que hice
- Catálogo de ediciones data-driven (3 ediciones, historia completa verificada en todas).
- Roadmap DLC (expansión + cosmético, ordenado, sin tocar historia).
- AntiP2W y AntiLootbox scanners (detección de violaciones, reportes).
- Tabla de impuestos data-driven.
- Test headless 27/0 OK + regresión M60 66/0 OK.

### Lo que NO pude hacer (honestidad obligatoria)
- [M] Documentos de estrategia completos (reembolsos, descuentos, bundles) → son contenido de texto, M149/publicación.
- [M] Gates CI reales en pipeline → depende de M112 (GdUnit4) y CI configurado.
- [M] Precios por tienda reales → M149.

### Recomendaciones para el próximo agente
- Los scanners están listos para CI: basta llamarlos en un script de gate que falle si `escanear()` no está vacío.
- Conectar impuestos.json con M149 cuando se definan las tiendas.
- Documentar política de reembolsos/descuentos como documento (no código).