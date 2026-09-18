# M160: Guía de Ubicaciones del Mundo

**Modelo:** MiMo V2.5
**Plataforma:** OpenCode
**Fecha:** 2026-09-18

## 1. Formato de IDs (LOC-*)

```
LOC-{ISLA}-{TIPO}-{NNN}
```

| Parte | Valores | Ejemplo |
|-------|---------|---------|
| ISLA | RIZ, COR, CEN, AUR | RIZ = Raíz |
| TIPO | PUB, CAS, TIE, BOS, FUE, VOL, CIE, TMP, LAG, FAR | PUB = Pueblo |
| NNN | 001-999 | 001 |

### IDs Canónicos por Isla

| Isla | IDs |
|------|-----|
| RIZ | LOC-RIZ-PUB-001 (Pueblo Raíz), LOC-RIZ-CAS-001-005, LOC-RIZ-TIE-001, LOC-RIZ-BOS-001-007, LOC-RIZ-FAR-001 |
| COR | LOC-COR-LAG-001 (Laguna), LOC-COR-TMP-001 (Templo Coral), LOC-COR-??? |
| CEN | LOC-CEN-VOL-001 (Volcán), LOC-CEN-TMP-001 (Templo Ceniza) |
| AUR | LOC-AUR-CIE-001 (Cielo), LOC-AUR-TMP-001 (Templo Aurora) |

## 2. Convenciones de Posicionamiento

- Centro de cada isla: `(island_radius, island_radius)` = `(256, 256)` en unidades voxel
- Posicionar NPCs/objetos: `get_height(x, z) + 1`
- Radio de spawn del jugador: ~256 unidades desde el centro
- Usar `TerrainLocator` (autoload) para posicionar sobre terreno
- **NUNCA** hardcodear `IslandGenerator` propio

## 3. Reglas de Conexiones

- Cada conexión es **bidireccional**: si A → B, entonces B → A
- Verificar con `validar_conexiones()` que retorna `{totales, faltantes, unidireccionales}`
- Si se detecta conexión unidireccional, corregir el JSON (.tres) correspondiente
- Tags de conexiones: `naturaleza`, `pueblo`, `ruinas`, `puzzle`, `comercio`

## 4. Integración con Otros Módulos

| Módulo | Integración | Estado |
|--------|-------------|--------|
| M27 (Islas) | IDs LOC-* alineados con mapa de islas | ✅ IDs definidos |
| M17 (Construcción) | Ubicaciones ampliables por el jugador | Pendiente runtime |
| M18 (Casas) | Ampliaciones de casas | Pendiente runtime |
| M25 (Ruinas) | Puzzles documentados en tags | ✅ Tags definidos, pendiente runtime |
| M28 (Viajes) | Puertos LOC-* para TravelService | ✅ 4 puertos definidos |
| M39 (Tiendas) | Catálogos de tiendas por ubicación | Pendiente runtime |
| M58 (Guardado) | Guardado de estado de ubicaciones | Pendiente runtime |
| M158 (Herramientas) | Tier de herramienta por objeto (T1-T3) | ✅ Asignado por isla |
| M159 (Catálogo) | Objetos recolectables referencian catálogo | ✅ Integrado |

## 5. Guía para Agregar Nuevas Ubicaciones

1. **Definir ID:** seguir formato `LOC-{ISLA}-{TIPO}-{NNN}`
2. **Agregar en JSON:** editar `data/ubicaciones/ubicaciones_loc.json`
3. **Campos requeridos:**
   ```json
   {
     "id": "LOC-???-???-001",
     "nombre": "Nombre Visible",
     "isla": 0,
     "tipo": 0,
     "x": 128.0,
     "z": 128.0,
     "descripcion": "Descripción",
     "conexiones": ["LOC-???-???-002"],
     "npcs": [],
     "objetos": [],
     "requisitos": null
   }
   ```
4. **Agregar seed .tres** (opcional): `data/ubicaciones/{id}.tres`
5. **Verificar conexiones:** ejecutar `validar_conexiones()`
6. **Sincronizar mapa:** ejecutar `sincronizar_ubicaciones_mapa.gd`
7. **Commitear:** JSON + .tres + verificación

## 6. Objetos con Regeneración

- Cada objeto puede tener `regeneracion_seg` (tiempo en segundos para reaparecer)
- Herramienta requerida por tier: T1 (sin herramienta), T2 (herramienta básica), T3 (herramienta avanzada)
- Tier asignado por isla: RIZ=T1-T2, COR=T2, CEN=T2-T3, AUR=T3

## 7. Vocabulario de Viajes (M28)

| LOC-* | Isla | Región |
|-------|------|--------|
| LOC-RIZ-PUB-001 | Isla Raíz | isla_sur |
| LOC-COR-LAG-001 | Isla Coral | isla_norte |
| LOC-CEN-VOL-001 | Isla Ceniza | isla_brisa |
| LOC-AUR-CIE-001 | Isla Aurora | isla_espejo |

Las traducciones de vocabulario de viajes dependen de M28 (TravelService).
