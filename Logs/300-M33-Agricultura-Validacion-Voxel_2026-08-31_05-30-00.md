# Log 300: M33 Agricultura (iter. 3) — Validación voxel real + flujo pala→plantar

**Fecha:** 2026-08-31
**Modelo:** Deepseek V4 Flash
**Plataforma:** Kilo

## Resumen
Iteración 3 del M33: el flujo agrícola respeta el ciclo real (pala → tierra arada → plantar).
`till_tile` valida que el voxel sea terreno natural (GRASS=2/DIRT=1 vía VoxelTool real si el
VoxelTerrain está disponible; validación de unidad en headless), registra el arado en `_arados`,
y `plant` exige arado previo. `puede_plantar_en` y la persistencia (M59) incluyen los arados.

## Cambios Realizados

### Código (Godot) — solo scripts/farm/ y test
- `scripts/farm/farm_service.gd`:
  - `_arados: Dictionary` (tierra arada registrada en el servicio — sin tocar M08).
  - `till_tile()`: rechaza si ya hay cultivo/arado; valida bloque natural vía
    `_bloque_es_terreno_natural()` (VoxelTool real: DIRT=1/GRASS=2; true en headless).
  - `plant()`: exige `_arados.has(voxel)` (flujo §3: primero pala, luego semilla).
  - `puede_plantar_en()`: requiere arado sin cultivo.
  - Persistencia: `_arados` serializado/restaurado (M59).
- `scripts/farm/test_farm.gd`: `_test_controller_ruta()` actualizado al flujo real —
  tierra sin arar NO permite plantar; pala → arada → plantar OK. 0 fallos.

### Documentación
- `DOCUMENTACION/33-Agricultura/plan-actual/05-Checklist.md`: relevado 14 [x] de 153
  (P1/P4/P8/P10/P12/P19/P20, CropTile, can_advance_today, DORMANTE/SIN_AGUA, diccionario tiles,
  RF7-RF12, water_need) + firma Kilo actualizada.

## Archivos Modificados/Creados
| Archivo | Acción |
|---------|--------|
| `scripts/farm/farm_service.gd` | Modificado (validación voxel + arados + plant exige arado) |
| `scripts/farm/test_farm.gd` | Actualizado (flujo real pala→plantar) |
| `DOCUMENTACION/33-Agricultura/plan-actual/05-Checklist.md` | Relevado 14/153 + firma |
| `Logs/ULTIMO_NUMERO.txt` | Modificado (299 → 300) |
| `Logs/300-M33-Agricultura-Validacion-Voxel_2026-08-31_05-30-00.md` | Creado (este log) |

## Validación
- `test_farm.gd` headless: 0 fallos (ciclo completo, pausas, persistencia + arados, ruta controller).
- Regresión del turno: M34/M39/M53 0 fallos anterio.

## Pendientes (iter. 4+)
- Conversión visual a TIERRA_ARADA vía bloque nuevo de M08 (esperar al módulo M08 — no se toca
  de otros agentes).
- HUD agrícola tooltip (get_growth_hint expuesto; capa M53 dedicada pendiente — §9.47).
- Lluvia real M32 (GLM) conectando apply_rain ya expuesto.
