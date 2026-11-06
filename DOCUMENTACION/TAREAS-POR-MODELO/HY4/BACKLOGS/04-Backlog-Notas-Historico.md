# Hy4 — Notas del Agente (histórico 10/09-14/09)
**Fuente:** BACKLOG-MASTER.md Hy4 (sección dividida 4nov por fundador)
**Modelo:** Hy4 preview (Tencent Hunyuan)
**Plataforma:** WorkBuddy
**Estado:** Histórico/Cerrado


## Notas del Agente

**Modelo:** Acompanante (OpenCode)
**Plataforma:** OpenCode
**Fecha:** 2026-09-10

### Lo que hizo HY4
- Creo **93 assets 3D lowpoly** completos con source + media + baja variantes
- Trabajo en **15 modulos** diferentes del proyecto
- Creo **~80+ scripts** de Blender Python
- Genero **~280+ archivos .blend**
- Realizo **~500+ capturas** orbitales
- Templates usados: `plantilla_asset.py`, `crear_cultivo_etapa_lowpoly.py`
- Batch de 30 accesorios de tienda (`crear_decoracion_tienda_batch.py`)

### Lo que NO pudo hacer (o no hizo)
- ~~**No exporto GLB**~~ — **RESUELTO 2026-09-10**: `exportar_godot.py` exporto todos los GLB, 0 errores. Estado real al cierre del log 809: **373 GLB** (145 ALTA / 115 MEDIA / 113 BAJA) con 373 `.glb.import`.
- ~~**No actualizo el CHECKLIST-OBJETOS-BLENDER.md**~~ — **AUDITADO log 809**: 0 falsos pendientes, 0 falsos completos. Los 14 falsos completos que habia (mobiliario M18) se revirtieron a `[ ]`.
- **No registro en TAREAS-POR-MODELO** — trabajaba directamente en Blender sin el protocolo
- **M18-BIS Casas grandes** — pendientes (nuevos prompts disponibles en `PROMPTS-PARA-CREAR-EN-BLENDER/`)
- **M18-TER Tienda** — batch creado pero sin revision visual del usuario

### Pendiente para el proximo agente
1. ~~**Exportar GLB** de todos los assets~~ — **HECHO** (373 GLB, log 809)
1b. ~~**Auditar y sincronizar `CHECKLIST-OBJETOS-BLENDER.md`** contra el disco~~ — **HECHO log 809**. Herramienta creada: `tools/mcp/blender-mcp/auditar_checklist.py` (5 categorias A-E). Hallazgos: **56 GLB perdidos regenerados** (E-103) y **14 falsos completos revertidos**. Errores nuevos documentados: E-101, E-102, E-103.
1c. ~~**URGENTE: commitear los GLB nuevos**~~ — **HECHO 2026-09-11 (commit `5ec9649`)**: 101 GLB untracked trackeados (56 del log 809 + 12 del 810 + 30 del 811 + 3 de otros agentes). Commit **selectivo**: solo esos binarios, los cambios de otros agentes quedaron intactos y sin stagear. Herramienta reutilizable: `tools/mcp/blender-mcp/stage_glb_huerfanos.py --add`.
1d. ~~**Anotar los 17 scripts huerfanos**~~ — **REAUDITADO 2026-09-13: son 7, no 17.**
    Los otros 10 ya figuran en el checklist (se agregaron en logs 809/810/811).
    Criterio: nombre EXACTO del script buscado en `CHECKLIST-OBJETOS-BLENDER.md`.
    | # | Script | Modulo | Dueno | Estado |
    |---|--------|--------|-------|--------|
    | 1 | `33-Agricultura/scripts/crear_cultivo_etapa_lowpoly.py` (295 l.) | M33 | **HY4** | M33 esta 10/10 cerrado y el script no esta en el checklist -> **trazabilidad rota, es mio** |
    | 2 | `scripts-reutilizables/crear_jugador_voxel.py` (121 l.) | M45 | **HY4** | M45 esta 11/11 cerrado; idem -> **es mio** |
    | 3 | `NPC_SCRIPTS/crear_catalogo_npcs.py` (1078 l.) | M19 | **MiMo** | No tocar |
    | 4 | `NPC_SCRIPTS/crear_luna.py` (1087 l.) | M19 | **MiMo** | No tocar |
    | 5 | `scripts-reutilizables/crear_luna.py` (1102 l.) | M19 | **MiMo** | **DUPLICADO DIVERGENTE** del #4 (md5 distinto, 1087 vs 1102 lineas) -> avisar a MiMo |
    | 6 | `18-BIS-Casas-Grandes/CASA_01_CHOZA/BAJA/crear_casa_01_choza.py` (1156 l.) | M18-BIS | **MiMo** | No tocar |
    | 7 | `18-BIS-Casas-Grandes/CASA_02_CASA_MEDIANA/BAJA/crear_casa_01_choza.py` (1156 l.) | M18-BIS | **MiMo** | **BUG**: carpeta `CASA_02_CASA_MEDIANA` pero el script dice "CASA 01 - CHOZA AMPLIADA"; es copia identica del #6 -> avisar a MiMo |
    Ademas: **1 caso de trazabilidad debil** — `15-Recursos/scripts/crear_roca_lowpoly.py`
    (M15, mio): el item "Roca comun (recolectable)" existe en el checklist pero NO cita
    el script. No es huerfano, pero hay que agregarle la referencia.
    Herramienta: `auditar_checklist.py` (5 categorias A-E, log 809).
1f. **BOM corregido (2026-09-13, commit `e4fe80e`)**: `CHECKLIST-OBJETOS-BLENDER.md`
    arrancaba con `EF BB BF` **tanto en HEAD como en el working tree** → violacion de
    AGENTS.md §28. Commiteado via blob (`git hash-object -w` + `update-index
    --cacheinfo`) para aislar el cambio: el working tree conserva intactas las 26/25
    lineas de actualizacion de rutas de documentacion de otro agente.
2. ~~**Actualizar CHECKLIST-OBJETOS-BLENDER.md**~~ — sincronizado en log 809 (169 items). Cierre de mobiliario: log 810 (4 items) + log 811 (10 items) → **141 `[x]` / 28 `[ ]`**.
1e. **Errores nuevos documentados en el log 811:** E-104 (una caja apoyada aporta solo 4 vertices, el guard `toca>=8` la rechaza) y E-105 (el decimate de BAJA se come primero los apoyos chicos: curar con cilindros, nunca relajando el guard). Total de la guia: **105 errores**.
3. **M18-BIS Casas grandes: mansión + casa de vecino** — **TRASPASADO a MiMo por
   directiva del usuario (2026-09-11)**. HY4 cerro 3/5 (log 806/808/822) y se paso a
   tareas de cruzamiento. Plantilla y capturador listos en `18-Casas/scripts/`.
4. **Completar M36 Fauna** restante (pez tropical, lagarto, cabra, gallina, mariposa)
5. **Completar M25 Ruinas** restante (columnas, dintel, palanca, estructura sumergida)
6. **Completar M35 Mineria** restante (caña pesca, pez, cangrejo, carrito)
7. **Revision visual M18-TER** — 30 accesorios de tienda pendientes de aprobar

---

