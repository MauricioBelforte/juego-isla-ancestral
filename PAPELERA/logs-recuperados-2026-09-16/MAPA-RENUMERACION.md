# MAPA DE RENUMERACIÓN — cuarentena del dedup 2026-09-16

> Generado el **2026-09-17** por **DeepSeek-V4.1-Flash** (Log 975).
> Este mapa es la trazabilidad de la restauración de la cuarentena descrita en
> `README.md`. La cuarentena original (en `.workbuddy-ai/`, gitignoreada) ya no
> existe como fuente viva: los archivos se movieron a `Logs/`.

## Qué pasó (trampa 67)

El dedup del 2026-09-16 deduplicó **por número**. Renumeró bien 12 casos, pero en
7 números (`723, 792, 800, 801, 802, 803, 805`) **borró todas las copias sin
renumerar ninguna** → esos números quedaron vacíos mientras el **código de juego**
y **guías vivas** los seguían citando. Además borró otros 18 archivos cuyo número
estaba ocupado por un log **distinto** (colisión silenciosa: citar el número
resolvía al log equivocado).

**Regla de desempate aplicada:** el log que **primero** usó el número lo conserva;
el otro se renumera a un slot libre. Para los 7 números vacíos no hay desempate:
el huérfano recupera su número original.

## Los 25 archivos movidos

Los 7 primeros **recuperan su número original** (estaba vacío). Los 18 siguientes
**se renumeran** porque su número original está ocupado por otro log.

| # | Archivo en cuarentena | Destino en `Logs/` | Por qué |
|---|---|---|---|
| 1 | `723-HY3-M11-QA-CRUZADO_2026-09-07.md` | `Logs/723-…` (igual) | número vacío |
| 2 | `792-M09-PARED-VERDE-SUELO-FANTASMA-AGUA_2026-09-08_09-20-00.md` | `Logs/792-…` (igual) | número vacío; **título corregido** (decía "Log 797", ver abajo) |
| 3 | `800-M09-GENERACION-POR-COLUMNAS_2026-09-08_10-10-00.md` | `Logs/800-…` (igual) | número vacío |
| 4 | `801-M09-SPAWN-SIN-GET-VOXEL-BLOQUEANTE_2026-09-08_10-35-00.md` | `Logs/801-…` (igual) | número vacío |
| 5 | `802-M09-FIXES-ANTITILDE-SPAWNER-IMPOSTOR_2026-09-09_05-10-00.md` | `Logs/802-…` (igual) | número vacío |
| 6 | `803-M49-ANILLO-ARENA_2026-09-09_19-55-00.md` | `Logs/803-…` (igual) | número vacío |
| 7 | `805-M49-FIX-WINDING-ANILLO-ARENA_2026-09-09_05-15-00.md` | `Logs/805-…` (igual) | número vacío |
| 8 | `801-M09-DISCO-INCREMENTAL-FUNCIONA_2026-09-09_00-05-00.md` | `Logs/956-…` | 801 ocupado por el #4 |
| 9 | `802-M09-VERIFICACION-ZOOM_2026-09-08_10-45-00.md` | `Logs/957-…` | 802 ocupado por el #5 |
| 10 | `803-M57-FIX-SCROLL-MINIMAPA_2026-09-09_04-35-00.md` | `Logs/958-…` | 803 ocupado por el #6 |
| 11 | `802-workbuddy-M33-3D-Compostera.md` | `Logs/959-…` | 802 ocupado por el #5 |
| 12 | `803-workbuddy-M33-3D-Tierra.md` | `Logs/960-…` | 803 ocupado por el #6 |
| 13 | `722-HY3-M10-QA-CRUZADO_2026-09-07.md` | `Logs/961-…` | 722 = `722-M48-AnimationService-FSM` |
| 14 | `724-HY3-M12-QA-CRUZADO_2026-09-07.md` | `Logs/962-…` | 724 = `724-M118-ITER3-ARTEFACTOS-SEMVER` |
| 15 | `761-workbuddy-M33-3D-CULTIVOS.md` | `Logs/963-…` | 761 = `761-AGNES-BUCLE-P9-CIERRE-ITEMS` |
| 16 | `789-M09-VIEWDIST-512-ANTITILDE_2026-09-08_20-30-00.md` | `Logs/964-…` | 789 = `789-M09-HORIZONTE-DEFINITIVO-OPTIMIZADO` |
| 17 | `790-workbuddy-M33-3D-Regadera.md` | `Logs/965-…` | 790 = `790-M09-DISCO-VERDE-FUNCIONA` |
| 18 | `793-workbuddy-M33-3D-Bananero.md` | `Logs/966-…` | 793 = `793-M09-IMPOSTORES-FINALES` |
| 19 | `795-M09-VERIFICACION-VISUAL-DISCO-VERDE_2026-09-08_08-05-00.md` | `Logs/967-…` | 795 = `795-M09-IMPOSTOR-HEIGHTMAP-COMPLETO` |
| 20 | `795-workbuddy-M33-3D-Canaveral.md` | `Logs/968-…` | 795 = `795-M09-IMPOSTOR-HEIGHTMAP-COMPLETO` |
| 21 | `799-M09-DOCUMENTACION-ANTITILDES-GUIA-GODOT_2026-09-08_22-30-00.md` | `Logs/969-…` | 799 = `799-M09-SWITCH-BOT-HUMANO` |
| 22 | `804-workbuddy-M18BIS-CasaMediana.md` | `Logs/970-…` | 804 = `804-M49-ANILLO-ARENA-INTEGRADO` |
| 23 | `806-M09-CIERRE-HORIZONTE-DEFINITIVO_2026-09-08_01-15-00.md` | `Logs/971-…` | 806 = `806-workbuddy-M18BIS-CasaMediana-v8` |
| 24 | `807-M09-CIERRE-SESION-HORIZONTE_2026-09-09_20-55-00.md` | `Logs/972-…` | 807 = `807-M09-CIERRE-SESION-HORIZONTE-ESTABLE` |
| 25 | `874-AGNES-ROUND11-CIERRE-M123-M116_2026-09-14.md` | `Logs/973-…` | 874 = `874-M87-Localizacion-Iter5-Validador` |

**Descartado (no movido):** `152-Verificacion-MCP-OpenCode-y-Actualizacion-NPCs_AAAA-MM-DD_HH-MM-SS.md`
— duplicado **byte-idéntico** del log vivo `Logs/152-…_2026-08-25_00-00-00.md`
(era la plantilla sin fechas). Comparar bytes en crudo daba un falso "distinto":
hay que normalizar (quitar BOM + CRLF→LF + `rstrip` por línea) antes de comparar.

## Colisión adicional resuelta (fuera de la cuarentena)

Dos logs de **atria-dawn** (Kilo Code) reusaron números ya tomados por **Hy3**
(escritos 02:41 del 2026-09-17). Se renumeraron los de Atria (llegaron después):

| Antes | Después | Colisionaba con |
|---|---|---|
| `Logs/949-QA-M08-Mundo-Voxel_2026-09-17_05-38.md` | `Logs/976-…` | `Logs/949-Hy3-M87.md` |
| `Logs/950-QA-M11-Personaje_2026-09-17_08-32.md` | `Logs/977-…` | `Logs/950-Hy3-M127.md` |

## Nota sobre el título de `Logs/792`

El archivo `792-M09-PARED-VERDE-SUELO-FANTASMA-AGUA_…` tenía como título
`# Log 797: …`, que **colisionaba** con el log real y distinto
`Logs/797-M09-VERIFICACION-IMPOSTOR-PASO64_2026-09-08_08-25-00.md`. Como el
nombre del archivo es la identidad y el código de juego lo cita como "Log 792"
(`terreno_horizonte.gd:255`), se corrigió el título a `# Log 792:` y se agregó
una nota de procedencia en el propio log.

## Citas actualizadas

| Archivo | Antes | Después | Motivo |
|---|---|---|---|
| `GUIA-GODOT/16-zoom-camara-personaje.md` | Log 803 | **Log 958** | el 803 es el anillo de arena; el fix del minimapa es el 958 |
| `CHECKLIST-GLOBAL.md` (M10) | Log 722 ×2 | **Log 961** ×2 | QA de hy3 del 2026-09-07 |
| `CHECKLIST-GLOBAL.md` (M12) | Log 724 | **Log 962** | QA de hy3 del 2026-09-07 |
| `CHECKLIST-GLOBAL.md` (M33) | Log 761 | **Log 963** | assets 3D CULTIVOS |
| `CHECKLIST-GLOBAL.md` (M33) | Log 790 | **Log 965** | assets 3D REGADERA |
| `CHECKLIST-GLOBAL.md` (atria) | Log 949 / 950 | **Log 976 / 977** | QA de atria-dawn |
| `10-Generacion-Del-Mundo/…/05-Checklist.md` | Log 722 | **Log 961** | ídem M10 |
| `atria-dawn/BACKLOG-MASTER.md` | Log 722 ×3, Log 724 | **961 ×3, 962** | ídem |
| `08-Mundo-Voxel/plan-actual/04-Codigo.md` | Log 949 ×2 | **Log 976** ×2 | QA de atria-dawn |
| `11-Personaje-Del-Jugador/…/05-Checklist.md` | Log 950 | **Log 977** | QA de atria-dawn |
| `Mensajes entre modelos/ESTADO-PARALELO.md` | 722, 949, 950 + rutas | **961, 976, 977** | registros + rutas completas |
| `115-Hardware/plan-actual/05-Checklist.md` | `Logs/308, 320, 327` | **`Logs/327, 414, 526, 921`** | 308 no existe; 320 es de M30 |
| `deepseek-v4-flash/115-Hardware/checklist.md` | `Logs/308, 320, 327` | **`Logs/327, 414, 526, 921`** | ídem |

**NO se tocaron** (a propósito):
- `scripts/backups/CHECKLIST-GLOBAL_*.md` y `Obsoletos/` → instantáneas históricas.
- `Logs/555`, `Logs/849`, `Logs/952` → los logs son registro histórico.
- Las citas "Log 722/724" del **M118 (CI-CD)** → esas sí apuntan al log commiteado
  en 722/724 (`M48-AnimationService`, `M118-ITER3`), que es correcto.

## Pendientes / discrepancias registradas (no resueltas aquí)

1. `terreno_horizonte.gd:255` cita "FIX Log 792 v2 (aro sin superficie)", pero el
   log 792 recuperado trata de la **pared perimetral + suelo fantasma**. La guía 17
   atribuye el fix del abanico a **Log 790**, pero el contenido del 790 tampoco
   menciona el abanico. Sin prueba concluyente → **no se editó la cita**.
2. `GUIA-GODOT/18-impostores-terreno.md` L149/L319 citan "Log 803" para el fix de
   *exageración*; el 803 recuperado trata del anillo de arena. Los logs que sí
   mencionan la exageración son 817/820/843. Sin prueba concluyente → **no se editó**.
3. `GUIA-GODOT/19-diagnostico-tildes.md` C-09 cita "Log 805: `terreno_horizonte.gd:163`"
   para un parse error; el 805 recuperado trata del *winding* del anillo. **No se editó**.
4. `terreno_horizonte.gd:238` cita "Log 800" para el disco base de fondo marino; el
   800 recuperado trata de la generación por columnas (misma sesión y subsistema).
   **No se editó.**
