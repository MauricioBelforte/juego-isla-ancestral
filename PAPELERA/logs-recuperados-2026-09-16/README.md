# Logs recuperados - cuarentena 2026-09-16

Material **unico** rescatado del borrado masivo de `Logs/` del 2026-09-16 (trampa 64).
Se conserva aqui (versionado) porque la cuarentena original vive en `.workbuddy-ai/`
que esta **gitignoreado** -> mismo punto unico de fallo que causo la perdida.

> ## ESTADO 2026-09-17 — CUARENTENA VACIADA (restauracion aplicada)
>
> El dueno delego la reparacion ("arregla los problemas") y se ejecuto el
> **2026-09-17** (DeepSeek-V4.1-Flash, Log 975):
>
> - Los **25 huerfanos** se movieron a `Logs/`: los 7 numeros vacios
>   (`723, 792, 800, 801, 802, 803, 805`) recuperaron su numero original, y los
>   otros 18 se renumeraron a slots libres (`956`-`973`).
> - El duplicado byte-identico `152-…AAAA-MM-DD…` se descarto (el log vivo es
>   `Logs/152-…_2026-08-25_00-00-00.md`).
> - Se actualizaron las citas vivas (codigo de juego, guias, registros, M115).
> - **Mapa completo old→new + citas: `MAPA-RENUMERACION.md`** (en esta carpeta).
>
> Esta carpeta queda como **lapida forense**: la tabla de abajo es el registro de
> lo que el dedup borro. Los bytes originales de cada archivo siguen recuperables
> desde git (`git show <commit>:PAPELERA/logs-recuperados-2026-09-16/<archivo>`),
> commit en que entraron: `a466ab3`.
>
> **Regla que esto dejo:** deduplicar **por numero** es destructivo. Antes de citar
> `Log NNN`, verificar con `ls Logs/NNN-*`.

**Historicamente NO se restauraron en `Logs/`** (situacion previa al 2026-09-17): en
varios casos el numero esta ocupado por OTRO log distinto, y en otros (801/802/803)
hay 2-3 logs distintos con el mismo numero. Restaurar tal cual recrearia la colision
(trampa 67). La reparacion correcta es renumerar a slots libres + actualizar las
citas, y eso es decision del dueno de cada log.

## Procedencia

- Cuarentena: `.workbuddy-ai/recuperado-2026-09-16-borrado-logs/Logs/` (gitignoreada).
- Ledger de snapshots del host: `refs/kilo/snapshots/<epoch-ms>/<sha>` (trees).
- Herramienta: `tools/logs/recuperar_desde_snapshots.py`.

## Clasificacion (contra el arbol actual)

- 12 duplicados exactos (SHA-256 identico a un log vivo) -> NO se copian (redundantes).
- 3 gemelos renombrados (mismo contenido, otro numero) -> NO se copian:
  - `831-HY3-M09-REGRESSION-VoxelViewer-reparent.md`  ->  vive como `832-HY3-M09-REGRESSION-VoxelViewer-reparent.md`
  - `926-M105-Telemetria-Iter7_2026-09-15.md`  ->  vive como `926-M105-Telemetria-Iter7_2026-09-16.md`
  - `938-M117-Build-System-Iter2_2026-09-16.md`  ->  vive como `941-M117-Build-System-Iter2_2026-09-16.md`
- **26 huerfanos** (contenido unico) -> copiados aqui.

## Huerfanos

| Archivo | Logs/NNN | Estado del numero |
|---|---|---|
| `152-Verificacion-MCP-OpenCode-y-Actualizacion-NPCs_AAAA-MM-DD_HH-MM-SS.md` | 152 | ocupado por otro log: `152-Verificacion-MCP-OpenCode-y-Actualizacion-NPCs_2026-08-25_00-00-00.md` |
| `722-HY3-M10-QA-CRUZADO_2026-09-07.md` | 722 | ocupado por otro log: `722-M48-AnimationService-FSM_2026-09-06_08-50-00.md` |
| `723-HY3-M11-QA-CRUZADO_2026-09-07.md` | 723 | **numero vacio** (sin archivo en `Logs/`) |
| `724-HY3-M12-QA-CRUZADO_2026-09-07.md` | 724 | ocupado por otro log: `724-M118-ITER3-ARTEFACTOS-SEMVER-SHA256-FIRMA_2026-09-06_03-23-00.md` |
| `761-workbuddy-M33-3D-CULTIVOS.md` | 761 | ocupado por otro log: `761-AGNES-BUCLE-P9-CIERRE-ITEMS_2026-09-06.md` |
| `789-M09-VIEWDIST-512-ANTITILDE_2026-09-08_20-30-00.md` | 789 | ocupado por otro log: `789-M09-HORIZONTE-DEFINITIVO-OPTIMIZADO_2026-09-07_23-59-00.md` |
| `790-workbuddy-M33-3D-Regadera.md` | 790 | ocupado por otro log: `790-M09-DISCO-VERDE-FUNCIONA-MONTANAS-600M_2026-09-07_21-15-00.md` |
| `792-M09-PARED-VERDE-SUELO-FANTASMA-AGUA_2026-09-08_09-20-00.md` | 792 | **numero vacio** (sin archivo en `Logs/`) |
| `793-workbuddy-M33-3D-Bananero.md` | 793 | ocupado por otro log: `793-M09-IMPOSTORES-FINALES-MONTANAS-PLANO-VERDE_2026-09-08_06-45-00.md` |
| `795-M09-VERIFICACION-VISUAL-DISCO-VERDE_2026-09-08_08-05-00.md` | 795 | ocupado por otro log: `795-M09-IMPOSTOR-HEIGHTMAP-COMPLETO_2026-09-08_07-45-00.md` |
| `795-workbuddy-M33-3D-Canaveral.md` | 795 | ocupado por otro log: `795-M09-IMPOSTOR-HEIGHTMAP-COMPLETO_2026-09-08_07-45-00.md` |
| `799-M09-DOCUMENTACION-ANTITILDES-GUIA-GODOT_2026-09-08_22-30-00.md` | 799 | ocupado por otro log: `799-M09-SWITCH-BOT-HUMANO_2026-09-08_06-35-00.md` |
| `800-M09-GENERACION-POR-COLUMNAS_2026-09-08_10-10-00.md` | 800 | **numero vacio** (sin archivo en `Logs/`) |
| `801-M09-DISCO-INCREMENTAL-FUNCIONA_2026-09-09_00-05-00.md` | 801 | **numero vacio** (sin archivo en `Logs/`) |
| `801-M09-SPAWN-SIN-GET-VOXEL-BLOQUEANTE_2026-09-08_10-35-00.md` | 801 | **numero vacio** (sin archivo en `Logs/`) |
| `802-M09-FIXES-ANTITILDE-SPAWNER-IMPOSTOR_2026-09-09_05-10-00.md` | 802 | **numero vacio** (sin archivo en `Logs/`) |
| `802-M09-VERIFICACION-ZOOM_2026-09-08_10-45-00.md` | 802 | **numero vacio** (sin archivo en `Logs/`) |
| `802-workbuddy-M33-3D-Compostera.md` | 802 | **numero vacio** (sin archivo en `Logs/`) |
| `803-M49-ANILLO-ARENA_2026-09-09_19-55-00.md` | 803 | **numero vacio** (sin archivo en `Logs/`) |
| `803-M57-FIX-SCROLL-MINIMAPA_2026-09-09_04-35-00.md` | 803 | **numero vacio** (sin archivo en `Logs/`) |
| `803-workbuddy-M33-3D-Tierra.md` | 803 | **numero vacio** (sin archivo en `Logs/`) |
| `804-workbuddy-M18BIS-CasaMediana.md` | 804 | ocupado por otro log: `804-M49-ANILLO-ARENA-INTEGRADO_2026-09-10_00-20-00.md` |
| `805-M49-FIX-WINDING-ANILLO-ARENA_2026-09-09_05-15-00.md` | 805 | **numero vacio** (sin archivo en `Logs/`) |
| `806-M09-CIERRE-HORIZONTE-DEFINITIVO_2026-09-08_01-15-00.md` | 806 | ocupado por otro log: `806-workbuddy-M18BIS-CasaMediana-v8.md` |
| `807-M09-CIERRE-SESION-HORIZONTE_2026-09-09_20-55-00.md` | 807 | ocupado por otro log: `807-M09-CIERRE-SESION-HORIZONTE-ESTABLE_2026-09-09_22-55-00.md` |
| `874-AGNES-ROUND11-CIERRE-M123-M116_2026-09-14.md` | 874 | ocupado por otro log: `874-M87-Localizacion-Iter5-Validador_2026-09-13.md` |

## Numeros vacios citados por codigo/documentos

`723, 792, 800, 801, 802, 803, 805` no tienen ningun archivo en `Logs/`, y varios
estan citados desde **codigo de juego** (`game/isla-ancestral/scripts/world/terreno_horizonte.gd`)
y desde guias vivas. Ver `scripts/auditar_referencias.py` y el informe en
`.workbuddy-ai/memory/AUDITORIA-REFERENCIAS-LOGS-2026-09-16.md`.

