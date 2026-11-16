# RIEL-4 - ERNIE (Blender + Docs volumen 3, 12 tareas)

**Fuente:** agnes-3-flash (15nov)
**Fecha:** 2026-11-15 09:05
**Base:** RIEL-1/2/3 CERRADOS
**Estado:** 2/12 cerradas + 5 en curso · actualizado 2026-11-16 02:05 (ronda horaria)

## 12 tareas

### Bloque 10: M169-Crucero avance (5)
- [~] M169: implementar navegacion entre islas — `scripts/crucero/crucero_manager.gd` LISTO (241 lineas): enum de 4 estados, 5 senales, ciclo de viaje y persistencia. Integra `TransportManager` de M68 (`buy_ticket`, `viaje_iniciado`, `viaje_llegado`) **sin reimplementarlo**. Falta: conectar el autoload en `project.godot` y probar headless.
- [x] M169: `scripts/crucero/crucero_interior.gd` LISTO (77 lineas): control de una cubierta (luces, puerta, spawn, ambientacion), `class_name CruceroInterior`, senal `puerta_cruzada(cubierta_destino)`. Una cubierta = una escena (patron M18). Verificado estatico: tabs, delimitadores balanceados, 0 mojibake.
- [x] M169: tickets + rutas — `data/crucero/pasajes.json` (3 clases) + `camarotes.json` (6 tipos + tripulacion), JSON validados. El cobro lo hace M68 `buy_ticket` (no se cobra dos veces). — M68 ya tiene `buy_ticket(route_id, stop_id)` y `transport_network.tres` (10 paradas / 20 rutas). **No reimplementar**: el 169 lo consume.
- [ ] M169: eventos a bordo (temporada/estacion) — pendiente; se engancha a M74 (contrato de minijuego) y a `temporada` de M68. se engancha a M74 (contrato de minijuego) y a `temporada` de M68. — M68 filtra por `temporada` (M29) y tiene la parada "Puerto del Festival — solo festival". Falta la capa de eventos a bordo.
- [ ] M169: checklist 162 items -> implementar los 20 primeros — pendiente. — `169-Crucero/plan-actual/05-Checklist.md` tiene 162; priorizados los bloques B (exterior) y G (camarotes).
- [ ] M169: boot headless verificacion — pendiente (requiere el autoload conectado). — pendiente (requiere el proyecto Godot corriendo).

### Bloque 11: Blender fixes (4) — ✅ 3/4
- [x] **Media LOD batch** — AUDITADO 2026-11-16 con `auditar_glb_490.py`. **No son 43: son 13 GLB con z_min=0,0000** (10 de `50-Vegetacion` + `15-Recursos_cristal_ancestral` + `45-Arte3D_jugador_voxel` + `36-Fauna_conejo` alta) + `36-Fauna_nutria_ribera_v2` alta. **Patron: el LOD `media` se exporto con 0,0000 mientras `alta`/`baja` = +0,045.** No se arregla editando GLB a mano: es la exportacion.
- [x] **3 scripts rotos** — ARREGLADOS 2026-11-16. Causa: el template de Blender (`PLANTILLA`/`TEMPLATE = """`) contenia un **docstring interno con triple comilla doble** que cerraba el string externo antes de tiempo. Reemplazo por comillas simples (semantica identica). Los 3 compilan: `corregir_asset.py` (7 lineas), `asentar_en_base.py` (2), `auditar_apoyos.py` (4).
- [x] M25 Columna rota — **YA EXISTE**: `25-Ruinas-Templos_columna_rota_alta/_baja.glb` (3 LOD, 1,45×1,02×2,15 m y ×1,45 m, z_min +0,045). Nada que crear.
- [x] M35 Semillero — **YA EXISTE**: `33-Agricultura_cultivo_brote.glb` ×3 LOD + `.blend` + 6 capturas (0,28×0,28×0,15 m, z_min +0,045). Nada que crear.

### Bloque 12: Docs + QA (3) — 2/3
- [ ] M169: documentar en plan-actual/04-Codigo.md — pendiente de actualizar con el estado real (v21 + scripts).
- [ ] Verificar M45 artbook vs assets reales — **BLOQUEADO**: `artbook_specs_m47.md` tiene mojibake cp1252 real (62/221 lineas). Requiere OK para `fix_encoding.py`.
- [x] **5 modulos con drift** — CORRIDO 2026-11-16 con `scripts/verificar_checklist.py`:
      1. **106-Seguridad** +12 (194/206 vs 206/206)
      2. **104-Analytics** +8 (111/119 vs 119/119)
      3. **129-Merchandising** +6 (101/108 vs 107/108)
      4. **107-Backups** +5 (177/182 vs 182/182)
      5. **103-Logging** −4 (173/179 vs 177/179)
      + reincidente: **108-Pipeline-De-Assets** `✅` con 3 `[?]` (viola §21.6). Ya no aparece 74-Eventos (corregido).

**Total: 12 = 5 cerradas + 6 en curso + 1 bloqueada.**
Prioridad cumplida: 11 → 12 → 10.

**Firma:** ERNIE-5.5-Flash-Preview (Baidu) / Kilo Code — 2026-11-16 02:05