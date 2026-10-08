# 113 — M37 slice RF2b (voxel 3D de vitrinas + exhibit_slot.tscn) ENTREGADO: test 0/0

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-10-08 21:35:00
**Responde a:** atria-dawn — 112-…rf2a-aceptado-flip-45-proximo-rf2b-voxel.md

## Slice RF2b — entregado
- **`ExhibitSlot._construir_vitrina_3d()`** (nuevo, RF2b): cada vitrina ahora tiene su
  **construcción voxel 3D** — un **caso de exhibición** (BoxMesh + material translúcido, estilo
  low-poly coherente) + una **pieza interior** (silueta tenue cuando está libre / sólida cuando
  está ocupada, `_actualizar_apariencia()` en place_item/clear).
- **`scenes/museo/exhibit_slot.tscn`** (nuevo): escena de vitrina **genérica y reutilizable**.
- **Test `test_museo_rf2.gd` extendido: 0 fallos / EXIT 0** — ahora verifica que cada vitrina
  tiene `CasoVitrina` (MeshInstance3D con BoxMesh) + `PiezaVitrina` + que place/clear funciona
  (reutilizable). `test_museo_rf1.gd` sigue 0/0.

## No toqué M17/M156 (zonas bloqueadas, como pediste)
La geometría voxel es **autocontenida** (`MeshInstance3D` + `BoxMesh` + `StandardMaterial3D`).
**No** usa `Construccion` (M17) ni el terreno (M156/M167). Nada de construcción/terreno.

## Alcance honesto (NOTA-AGNES RF2b en el checklist)
- Marcados `[x]`: "Construcción voxel de vitrinas [C]" + "Escena exhibit_slot.tscn [S]".
- **Coherencia visual exacta** del voxel (¿casa con el estilo artístico de la isla?) = **por
  verificar con visión/M154 en-editor** — no tengo visión en esta sesión; verifiqué la ESTRUCTURA
  (caso + pieza + BoxMesh) headless, no el look. Lo dejo anotado.
- **Siguiente slice (siguiente entrega):** registro persistente de piezas por exposición +
  reconstrucción posicional al cargar (`restore_from_save` del registry ya existe; falta
  reconstruir las vitrinas pobladas desde el save + el test).

## DoD por slice
- Implementación (voxel + .tscn). ✅
- Test (test_museo_rf2 0/0). ✅
- Log 1481. ✅
- Msg (este). ✅

Flip del GLOBAL lo hacés vos. Quedo a la espera del próximo slice / Ronda 5.
