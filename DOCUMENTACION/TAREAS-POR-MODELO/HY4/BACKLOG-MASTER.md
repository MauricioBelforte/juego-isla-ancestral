# BACKLOG-MASTER — HY4 (Blender)

**Modelo:** Hy4 preview (Tencent Hunyuan)
**Plataforma:** WorkBuddy — tambien figuro como `HY4` sobre Kilo Code en sesiones de autoria Blender
**Identidad canonica:** la autoevaluacion de este modelo es el **§15** de `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md`
**Especialidad:** Assets 3D lowpoly para Blender → Godot
**Fecha de inicio:** 2026-09-02
**Fecha de ultima actividad:** 2026-11-04 (reingreso; ver B7)

---

> ⛔ **REGLA OBLIGATORIA — CODIFICACION UTF-8**
> Todos los archivos del proyecto DEBEN guardarse en UTF-8 sin BOM. NUNCA en cp1252/ANSI.
> Los caracteres rotos (Ã³, â€", ðŸŸ¢, etc.) RETRASAN EL TRABAJO, ROMPEN EL FLUJO y CAUSAN PERDIDA DE TIEMPO E INFORMACION.
> Si tu plataforma escribe en cp1252, NO TOQUES EL REPOSITORIO hasta configurar UTF-8.
> Ver AGENTS.md seccion 28 paradetalles y herramientas de reparacion.

## Resumen de trabajo

HY4 es un modelo especializado en **creacion de assets 3D en Blender**. Trabaja exclusivamente con el MCP de Blender (V5), creando modelos lowpoly con la paleta de materiales del proyecto. Si maneja GDScript y logica de Godot (ver §15.2: escribe `.py` para Blender y `.gd` para Godot). Lo que NO hace es generacion visual directa ni aprobacion visual final (vision intermitente, §15.3).

### Estadisticas globales

| Metrica | Valor |
|---------|-------|
| Assets completados | **93** |
| Modulos trabajados | **15** |
| Scripts creados | ~80+ `.py` |
| Blends generados | ~280+ `.blend` (source + media + baja) |
| Capturas realizadas | ~500+ JPG/PNG |
| GLB exportados | **370** (export masivo 2026-09-10, 0 errores) |

---

## Modulos completados (100%)

| ID | Modulo | Items | Estado |
|----|--------|-------|--------|
| 15 | Recursos (materiales recolectables) | 11/11 | ✅ CERRADO |
| 16 | Crafting / Inventario | 10/10 | ✅ CERRADO |
| 18 | Casas (modular 1x1) | 11/11 | ✅ CERRADO (Tier E) |
| 18-M | Mobiliario interior | 14/14 | ✅ CERRADO |
| 19 | NPCs y Vecinos | 8/8 | ✅ CERRADO (reservado por MiMo — no tocar) |
| 27 | Islas y Ubicaciones | 5/5 | ✅ CERRADO |
| 45 | Arte 3D (props) | 11/11 | ✅ CERRADO |
| 50 | Vegetacion | 15/15 | ✅ CERRADO |
| 70 | Interacciones | 5/5 | ✅ CERRADO |

### Total cerrados: 90/90

---

## Modulos parcialmente completados

| ID | Modulo | Completados | Pendientes | Estado |
|----|--------|-------------|------------|--------|
| 33 | Agricultura | 10/10 | 0 | ✅ CERRADO |
| 36 | Fauna | 5/10 | 5 | 🔵 En progreso |
| 25 | Ruinas / Templos | 6/8 | 2 | 🟡 Parcial |
| 40 | Infraestructura | 7/8 | 1 | 🟡 Parcial |
| 35 | Mineria | 2/5 | 3 | 🟡 Parcial |

### Total parcial: 30/41

> **MODULOS RESERVADOS (no trabajar en estos):**
> - **M19 NPCs y Vecinos** — reservado por MiMo (acompañante)
> - **M18-BIS Casas grandes** — reservado por MiMo (acompañante)

---

## Pendientes globales

> **RECONTADO 2026-09-13 (Hy4, auditoria 1d):** el titulo decia "21 items" y no
> cerraba con las casillas. Conteo real de `[ ]` de este archivo:
> **M36 = 5 · M25 = 6 · M40 = 1 · M35 = 4 → 16 pendientes propios**
> (mas M18-BIS 2 = **traspasados a MiMo**, no contar; mas M18-TER 30 = bloqueados
> por revision visual). Los encabezados de M25 ("2 pendientes") y M35 ("3
> pendientes") estaban mal y se corrigen abajo.

### M36 Fauna (5 pendientes)
- [ ] Pez tropical (2 variantes de color)
- [ ] Lagarto de isla
- [ ] Cabra
- [ ] Gallina
- [ ] Mariposa (alas simples para animar)

### M25 Ruinas (6 pendientes — el encabezado decia 2, corregido 2026-09-13)
- [ ] Columna rota (2 variantes de altura)
- [ ] Columna entera con capitel
- [ ] Bloque de piedra tallada (modulo de muro)
- [ ] Dintel caido
- [ ] Palanca de puzzle (interactuable)
- [ ] Estructura sumergida parcial (marea)

### M40 Infraestructura (1 pendiente)
- [ ] Valla de madera (modulo recto + esquina)

### M35 Mineria (4 pendientes — el encabezado decia 3, corregido 2026-09-13)
- [ ] Cana de pescar
- [ ] Pez capturable (compartido con fauna)
- [ ] Cangrejo ermitano (recompensa rara)
- [ ] Carrito de vias (26 subterraneo)

### M18-BIS Casas grandes — **TRASPASADO A MiMo (directiva del usuario 2026-09-11)**
HY4 cerro 3/5 (mediana log 806, choza ampliada log 808, casona log 844) y deja el
resto. **No retomar mansión ni casa de vecino salvo que MiMo los libere.**
Para quien los tome, artefactos reutilizables YA listos:/n- `18-Casas/scripts/capturar_casa.py` — capturador GENERICO (dict `VINETAS`).
  Entradas existentes: `casa_mediana` r=22.0/4 vin, `choza_ampliada` r=10.0/4 vin,
  `casona` r=14.0/6 vin. Agregar la entrada de la casa nueva y listo.
- `18-Casas/scripts/crear_casa_casona_lowpoly.py` — plantilla mas reciente y completa
  (~580 lineas): muros con vanos por lista, tabiques interiores, techo de tablones +
  frontones por bmesh, chimenea que atraviesa el techo, porche de entrada.
- `18-Casas/scripts/crear_casa_choza_ampliada_lowpoly.py` — la mas simple (500 lineas).
- `18-Casas/scripts/mobiliario_util.py` + `hoja_util.py` (scripts-reutilizables).
Reglas duras que se aprendieron a costa de iteraciones: pendiente 19-20 deg (12=galpon,
29=choza), chimenea SIEMPRE asomando sobre el techo, frontones en la misma mesh del
techo (E-70), apoyos chicos en CILINDRO y nunca en caja (E-104/E-105).
- [x] **Casa mediana** 2 ambientes (16x12 m por directiva v4) — v8 CERRADA, log 806.
      60 SM_/3172 tris/12 mats ALTA · 17/3172/8 MEDIA · 17/2522/4 BAJA
- [x] **Casa choza ampliada** (1 ambiente 5x4 m) — CERRADA, log 808.
      15 SM_/1140 tris/12 mats ALTA · 11/1140/8 MEDIA · 11/902/4 BAJA.
      Cumple M166 §3.3 **sin excepcion**. Bug corregido: cano de chimenea corto (E-100)
- [x] Casa amplia / casona (10x8 m: sala + 2 dormitorios + cocina) — CERRADA log 844 (30 SM_/3052 tris/12 mats ALTA · 19/3052/8 MEDIA · 19/2122/4 BAJA)
- [ ] Mansion (14x10 m, multi-habitacion, biblioteca + sala de museo) — **TRASPASADO a MiMo**
- [ ] Casa de vecino (variante cozy re-amueblada, para M19 RF12) — **TRASPASADO a MiMo**

### M18 Mobiliario interior interactivo (14/14 CERRADOS — 4 en log 810, 10 en log 811)
Auditados 2026-09-10: figuraban `[x]` en el checklist pero **no existe script,
.blend ni GLB**. Son muebles interactivos (dormir/sentarse/cocinar/almacenar),
NO decoracion estatica. No confundir con los `decor_*` de M18-TER (esos si existen).
- [x] cama_basica — CERRADA log 810 (15·5·5 / 180·180·124 tris / 5·5·4 mats)
- [x] velador — CERRADO log 810 (9·4·4 / 160·160·108 tris / 5·5·4 mats; vela+llama unidas)
- [x] silla_madera — CERRADA log 810 (11·2·2 / 132·132·90 tris / 2·2·2 mats)
- [x] mesa_madera — CERRADA log 810 (9·2·2 / 108·108·74 tris / 2·2·2 mats)
- [x] cama_doble — CERRADA log 811 (14·5·5 / 168·168·114 tris / 5·5·4 mats)
- [x] sillon — CERRADO log 811 (10·3·3 / 120·120·82 tris / 3·3·3 mats)
- [x] nevera_rustica — CERRADA log 811 (11·5·5 / 360·360·248 tris / 5·5·4 mats)
- [x] estufa_lena — CERRADA log 811 (12·3·3 / 268·268·186 tris / 3·3·3 mats)
- [x] estanteria — CERRADA log 811 (10·5·5 / 264·264·184 tris / 5·5·4 mats)
- [x] comoda — CERRADA log 811 (10·3·3 / 144·144·98 tris / 3·3·3 mats)
- [x] lampara_pie — CERRADA log 811 (6·3·3 / 300·300·208 tris / 4·4·4 mats)
- [x] alfombra — CERRADA log 811 (4·4·4 / 496·496·344 tris / 4·4·4 mats)
- [x] cuadro_ancestral — CERRADO log 811 (7·5·5 / 240·240·164 tris / 4·4·4 mats)
- [x] maceta_interior — CERRADA log 811 (5·3·3 / 436·436·302 tris / 3·3·3 mats)

### M18-TER Tienda decoracion (30 pendientes — batch script creado, pendiente revision visual)
- 30 accesorios de decoracion (iluminacion, pared, plantas, alfombras, cocina, ancestral, oceano, floral, mobiliario, exteriores)

---

## Convenciones de HY4

### Naming de archivos
- **Scripts:** `crear_{objeto}_lowpoly.py` en `scripts-reutilizables/`
- **Blends:** `{objeto}_lowpoly.blend` (+ `_media.blend`, `_baja.blend`)
- **Capturas:** `{objeto}_az{angulo}.png` + `_hoja_{objeto}.jpg`
- **GLB:** Pendiente de exportar (los blends existen pero no se han exportado a Godot)

### Materiales
Usa la paleta estandar del proyecto:
- `MAT_MaderaClara` — (180, 140, 90)
- `MAT_MaderaOscura` — (90, 65, 40)
- `MAT_PajaClara` — (210, 180, 120)
- `MAT_Piedra` — (130, 125, 120)
- `MAT_TelaCrudo` — (200, 190, 170)
- `MAT_Cuero` — (120, 80, 45)
- `MAT_Cobre` — (180, 120, 60)

### Presupuesto M166 §3.3 (CORREGIDO 2026-09-10 — el dato anterior era erroneo)
- **ALTA:**  <=16 obj / <=6000 tris / <=12 mats
- **MEDIA:** <=8  obj / <=1500 tris / <=8  mats
- **BAJA:**  <=6  obj / <=700  tris / <=4  mats
- **Excepcion casas grandes (plan §6.1):** sub-grupos de <=16 SM_ por room; la casa
  completa puede exceder el nominal de MEDIA/BAJA (caso real: casa mediana v8 = 17 obj).
- Fuente: `scripts-reutilizables/generar_alta.py` + cabeceras de los generadores.

### z_min
- Todos los assets contactan el suelo en `z_min = 0.045`

---

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

## Opción B — "parchar huecos" (encargada por el usuario 2026-09-14)

Rol asignado explicitamente: *"te necesito en este tipo de tareas parchando
huecos"*. Cuatro frentes transversales. Estado al 2026-09-14:

| # | Frente | Estado | Log | Commits |
|---|--------|--------|-----|---------|
| B1 | Mojibake real | **CERRADO** | 903 | `f308b7c`, `c952bdf` |
| B2 | 14 módulos sobre-cerrados | **CERRADO** (ninguno lo estaba) | 904 | `d35d458` |
| B3 | Log 723 inexistente | **CERRADO** | 904 | `a50b061` |
| B3b | 296 rutas `.cs` fantasma | **PENDIENTE** (decidir alcance) | — | — |
| B4 | Vigilar primer push de CI | **PENDIENTE** | — | — |

### B1 — Mojibake
Los 22 marcadores que quedaban eran **documentación** del síntoma, no
corrupción. Se añadió filtro por contenido de línea (`PAT_LINEA_DOC`) y
`scripts/test_diagnosticar_mojibake.py` como guarda contra falso verde.
Verificador: **SUCIO 0 / IRREVERSIBLE 0**.

### B2 — Auditoría de sobre-cierre
**Ninguno de los 14 está sobre-cerrado.** Los 7 revertidos por agnes sí estaban
bien reflejados (fila global 0/N). Trampas corregidas: contar `[x]` a secas
cuenta el propio banner de reversión; `head`/`grep` muestran falso mojibake por
la consola.
Desajustes reales (cierre no propagado): **M145** 105/105 vs fila 90/105,
**M146** 100/100 vs 90/100, **M119** 118 vs 100, **M136** 199 vs 200.
→ M145/M146 derivados a Hy3 (QA §21.8); el perfil Hy4 excluye el sello.

### B2b — BOM (hallazgo mayor, §28)
`scripts/fix_encoding.py` **detecta el BOM y lo descarta**: líneas 195-196 lo
quitan en memoria y la 260 solo reescribe cp1252/mojibake. Por eso sobrevivían.
Alcance medido: **509 archivos** (`scripts/verificar_bom.py`).
Corregidos los 7 del alcance auditado; **5 de ellos eran regresiones recién
introducidas** (HEAD limpio, BOM solo en working tree) → hay agentes escribiendo
BOM ahora mismo. Quedan 502 por decidir (362 en `Logs/`, histórico).

### B3 — Log 723
`CHECKLIST-GLOBAL.md` citaba 2 veces el "Log 723" como QA de M11, pero no
existe (salta 722→724). El QA real es el **Log 835**
(`Logs/835-HY3-M11-QA-CRUZADO.md`). Sustituido.

### B3b — Rutas `.cs` (pendiente)
296 rutas distintas, 561 ocurrencias; 531 en `DOCUMENTACION`, de las que
**238 están en `plan-actual`** (documentación viva), no solo en el diseño
histórico de Unity. Concentradas en M01 (55), M113 (22×3), M109 (21×4),
M141 (13×2). No se tocan sin decidir: renombrar `.cs`→`.gd` sería ficción.

---

## Cierres del 2026-09-16 (Log 925)

### B2 — BOM: CERRADO (decisión del usuario: "los 502, en dos commits")

| Commit | Contenido |
|---|---|
| `eb98614` | 83 archivos vivos con BOM en HEAD (por blob: 44 `.gd` con ediciones ajenas en vuelo quedaron intactos) |
| `b929ba0` | 361 logs históricos. Verificado antes: **0 de 361** con ediciones sin commitear → `git add` directo |

**Estado:** 509 → **3** archivos con BOM, los 3 fuera de versionado
(`app_userdata/…m87_val_bom.po`, `_probe_col.gd`, `scripts/backups/`).
⚠️ **El BOM se regenera**: ese mismo día aparecieron 5 archivos nuevos con BOM
y luego una regresión más en `08-GUIA-ORDEN-DE-IMPLEMENTACION.md`. Sigue
pendiente meter `scripts/verificar_bom.py` en CI (tarea B4).

### B3b — Rutas `.cs`: CERRADO (decisión: "corregir las reales + marcar el resto")

El grueso lo hizo **otro agente** en `53edd1b` (34 reemplazos + 175 marcas en
44 archivos, `plan-actual` y `plan-inicial`). **No se duplicó**: se auditó y se
cerró lo que faltaba.

| Commit | Contenido |
|---|---|
| `5df6e55` | 61 menciones en 12 archivos: **6** con `.gd` real reemplazadas, **55** marcadas `_ (diseno heredado) _` |

Reemplazos reales: `StressRunner`, `StressScenario`, `InventoryStress`,
`SaveLoadStress`, `BuildInfo` ×2.
Método: 9 archivos limpios por disco; 3 con ediciones ajenas
(M26, M118, M81) **por blob** para no pisarlas.

**Hecho verificado:** 0 `.cs` propios (el único es del addon gdUnit4),
0 `.csproj`/`.sln`/`.unity`/`.prefab`, **800 `.gd`** en `game/isla-ancestral/`.

### ⚠️ Trampa nueva (60) — regex de ruta con prefijo opcional sin anclar

`(?:[A-Za-z0-9_./\-]*/)?([A-Za-z0-9_]+)\.cs\b` **captura solo la última letra**:
el prefijo se come el nombre porque su clase incluye `_` y alfanuméricos.
Produjo 205 reemplazos con rutas inventadas. Se detectó por guardas
(`20 <= con_gd <= 40`, `os.path.isfile`) y se revirtió con
`git reset -q HEAD -- <paths>` (worktree intacto).
**Regla:** en sustituciones masivas, guarda que falle fuerte ANTES de escribir.

### Hueco nuevo detectado (no tocado)

**Dos autoloads de localización duplicados** en `project.godot`:
`Localization` → `res://scripts/localization/localization_manager.gd` (14,6 KB) y
`LocalizationManager` → `res://scripts/localizacion/localization_manager.gd` (2,7 KB).
Conocido como H-1. Requiere dueño de módulo; no mergear de paso.

---

## B4 — BOM en CI: CERRADO (commit `a0dd230`)

Job **`encoding-guard`** en `.github/workflows/quality.yml`: python 3.12 +
`scripts/verificar_bom.py` (sale con 1 si hay BOM). Agregado a `needs` del
`summary` y a la condición de fallo. Segundo paso informativo
(`continue-on-error`): `diagnosticar_mojibake.py` — no bloquea a propósito.

Correcciones en `scripts/verificar_bom.py` imprescindibles para que la guarda
sea confiable:

- Excluye directorios ocultos salvo `.github` → `.kilo/worktrees/phase-judge/`
  metía **463** "BOM" que no son del repo versionado.
- Exclusión de carpetas **case-insensitive** (conviven `Obsoletos/` y `OBSOLETOS/`).
- Excluye `Godot/` (user:// runtime). `m87_val_bom.po` es el BOM **legítimo**:
  es el fixture del validador `.po`.

Limpieza: 9 `.gitkeep` versionados tenían BOM y nadie los veía (`.gitkeep` no
está en la lista de extensiones). Ahora vacíos.

**Verificación:** simulación sobre `git ls-files` → **0 versionados con BOM**
→ exit 0. Quedan 4 BOM versionados, todos en
`Obsoletos/encoding-backup-20260902_014555/` (respaldo histórico: se preserva).

---

## B5 — Auditoría de autoría Blender (Log 1188)

Inventario de `tools/mcp/blender-mcp`: **126** `crear_*.py`, **16** módulos con
`.blend`.

| Hallazgo | Cantidad |
|---|---|
| Huérfanos reales (script sin asset) | **2** |
| Duplicados | **2 pares** |
| `.py` viviendo dentro de `game/` | **42** |

**Huérfanos reales:** `50-Vegetacion/crear_hierba_alta_lowpoly.py` y
`scripts-reutilizables/crear_jugador_voxel.py`.

**Falsos positivos** (documentados para no re-auditarlos): `crear_roca_lowpoly`
(su salida es `roca_comun`), `crear_decoracion_tienda_batch` (batch),
`crear_cultivo_etapa_lowpoly` (parametrizado), `crear_catalogo_npcs` (catálogo).

**Duplicados medidos:**
- `crear_casa_01_choza.py` **byte-idéntico** (sha `6b02317ff9f04260`, 1157 líneas)
  en `CASA_01_CHOZA/BAJA/` y `CASA_02_CASA_MEDIANA/BAJA/` → **reportado a MiMo**
  (`Mensajes entre modelos/2026-10-02_17-17-31_2-HY4-M18BIS-script-duplicado.md`).
  No se tocó: M18-BIS es de MiMo.
- `crear_luna.py`: `NPC_SCRIPTS` (1087) vs `scripts-reutilizables` (1102).
  Diff = 14 líneas de cabecera + 1 blanca. Código idéntico.

### ⚠️ Trampa nueva (61) — un detector que da 100 % está roto

El primer cruce dio **126 huérfanos de 126**. Causa: el normalizador del
nombre del blend no quitaba el sufijo `_lowpoly`, así que
`crear_monton_ramas_lowpoly.py` nunca podía coincidir con
`monton_ramas_lowpoly.blend`. Corregido → 8, y de esos 8 solo 2 eran reales.
**Regla:** si un detector marca todo, sospechar del detector antes que del repo.

### REAUDITADO 2026-11-04 (B9, Log 2310) — corrección del propio B5

- **Los «2 huérfanos reales» son 0.** El detector buscaba solo `.blend`:
  `crear_jugador_voxel.py` exporta **GLB directo** y su GLB está versionado;
  `crear_hierba_alta_lowpoly.py` vive en `50-Vegetacion/scripts/` (no en la
  raíz del módulo) y tiene 3 `.blend` + GLB + ficha. No hay que generar nada.
- Los `.py` de `game/` eran **65**, no 42: crecieron 23 entre el 2-oct y el
  4-nov. 22 se relocalizaron (sin borrar) y quedan 43 congelados por guardia.
- Ver §B9 para el criterio de selección, el manifiesto y las guardias en rojo.

### Pendiente (requiere dueño o Blender MCP)

- MCP de Blender caído en esta sesión → **no se generó ningún asset** (ya no
  hace falta para los ex-huérfanos).
- 29 scripts de autoría Blender siguen en `game/scripts/` (territorio M36/M50):
  moverlos en bloque requiere actualizar 13 rutas citadas en documentación.
- H-1 (localización duplicada) sigue abierto.

---

## B6 — Artefactos documentados inexistentes (Log 1189)

Auditoría: ¿la documentación de `plan-actual` cita rutas que no existen?
**2763 referencias** escaneadas en 169 carpetas.

| Clase | Cantidad | Significado |
|---|---|---|
| A | **1529** | la ruta resuelve exactamente — correctas |
| B | **147** | nombre base existe en otra ruta — doc desactualizada |
| C2 | **515** | candidato parecido (`difflib`) — renombrado/reubicado |
| C1 | **572** | sin coincidencia — **artefacto ausente** |

**28 módulos marcados ✅ citan artefactos ausentes.** Peores:
M112 (25, incluido el framework GUT completo que nunca se usó), M154 (18),
M122 (7), M123 (6), M82 (6), M81 (5), M11 (4).

**Acción:** 2 marcas `_ (diseno heredado) _` donde el `[x]` cita un `.cs` de
Unity que no puede existir (M118 `BuildScript.cs`, M81 `DataSanitizer.cs`).
**No se volteó ningún `[x]`** — eso es §21.8, perfil Hy4 excluido.

### Falsos positivos (no re-auditar)

- **M26 Templo** — sus 5 rutas `.cs` ya están explicadas por un bloque
  `Diseno original NO implementado (rutas muertas)`. El detector es ciego al
  contexto.
- **M106 Seguridad** — `security/X.gd` no resuelve, pero **existe** como
  `scripts/security/security_X.gd` (los 8). Deriva de prefijo.
- **Módulos sin implementar** (M120/121/125/150/90/91/58…) — sus rutas son
  intención de diseño: ≈1030 de las 1314 menciones "rotas".

### ⚠️ Trampa nueva (62) — tres bases antes de creer un "roto"

Probar `raíz repo` · `game/isla-ancestral/` · `game/isla-ancestral/scripts/`;
separar "ausente" de "renombrado" con `difflib`; y descartar módulos no
implementados cruzando `CHECKLIST-GLOBAL.md`. Sin esos cuatro filtros el
número (1577) es indistinguible del real.
**Regla:** un "roto" sólo es hueco si el módulo está cerrado **Y** el nombre
base no aparece en ningún lado del repo.

### B0 — BOM: regresión recurrente (commit `0abeab6`)

Tras cerrar 509 → 0, volvieron a aparecer **13** con BOM (12 scripts de
`atria-dawn-s2/scripts-prueba` + 1 log). Limpiados en disco (diff 1:1, sólo
los 3 bytes `EF BB BF`). Confirmación: **0 BOM** tras el commit.
El BOM lo siguen regenerando otros agentes → el job `encoding-guard` de CI
(`a0dd230`) es ahora la red de contención.

---

### B7 — Reingreso 4-nov: gate de BOM en rojo (Log 2306, commit `3614c45`)

**Estado medido al volver:** HEAD `58f23fc` (2-nov), logs 1189 → **2305**,
`MEMORY.md` consolidado por otro modelo el 2-nov (mis notas de octubre ya no
están ahí; este backlog sí las conserva). Protocolo nuevo adoptado: pool v3
(`reservar_log.py`), log ASCII puro + **CRLF**, canal propio de mensajes.
Regla nueva respetada: no tocar `CHECKLIST-GLOBAL.md`, `quality.yml`,
`AGENTS.md`, `project.godot` ni `05-Checklist` ajenos sin orden.

**Hueco:** `verificar_bom.py` reportaba **96 BOM** y salía `1` → el job
`encoding-guard` de CI estaba en rojo sobre HEAD. El conteo crudo sobre
`git ls-files` da 160: la diferencia son ~64 backups en `Obsoletos/` que el
verificador excluye a propósito. El job sigue vivo (`quality.yml:835`) y el
verificador fue blindado por DeepSeek-WB en `d25580a` (UTF-16 + `U+FEFF`).

**Acción:** 94 versionados limpiados (diff **1:1**, sólo los 3 bytes
`EF BB BF`), commit `3614c45`, `add`+`commit` encadenados con
`--pathspec-from-file`. HEAD verificado: **0 BOM** en los 94. 74 byte-exactos
y 20 con normalización CRLF de git (`core.autocrlf=true`).

**NO tocado (requiere orden):** el único BOM que el gate sigue viendo,
`DOCUMENTACION/138-Vertical-Slice/plan-actual/05-Checklist.md`, es
`05-Checklist` ajeno. Tampoco los 4 `U+FEFF` embebidos, las 12 colisiones de
numeración heredadas (1290..2120) ni las entradas ajenas del worktree.

**⚠️ Trampa nueva (63): medir un diff con rutas con espacios.** El primer
`numstat` dio **1 archivo** cuando había 94: el shell partió los pathspec de
`Mensajes entre modelos/…` por word splitting. No falló el fix, falló la
**medición**. Usar argv de Python / `git diff -z` / `--pathspec-file-nul`.
Corolario: con `core.autocrlf=true`, comparar disco contra `git show HEAD:p`
da un **falso fallo** (blob LF vs disco CRLF) → normalizar antes de comparar.
Corolario 2: `--fix` no respeta `.gitignore` y tocó un
`NUMEROS_DISPONIBLES.txt` no versionado (inofensivo, documentado).

**Discrepancia de canal:** no existe `Mensajes entre modelos/HY4/`. Hay
backlog HY4, 2 mensajes firmados en la raíz (2-oct) y columna `Hy4` en
`CHECKLIST-GLOBAL`. AGENTS §10.2 dice que la carpeta la crea el director →
**no la creé**; queda pendiente de orden si hay encargo nuevo.

- [x] Log reservado: **2306** — reingreso + regresión del gate de BOM.

### Pendiente (sin dueño o con orden del director)

- ~~Autorización para limpiar el BOM de `M138/plan-actual/05-Checklist.md`~~
  **RESUELTO en B8** (4-nov, autorización explícita del fundador; gate verde).
- H-1: autoloads de localización duplicados (`project.godot`, no tocar).
- B6: 662 rutas desactualizadas sin reescribir (riesgo trampa 60) y los
  28 módulos ✅ que citan artefactos ausentes → decisión de Hy3/coordinador.
- ~~B5: 2 scripts Blender huérfanos y los 42 `.py` dentro de `game/`.~~
  **CERRADO en B9** (4-nov): 0 huérfanos reales, 22 relocalizados, 43 congelados.

---

## B8 — 2026-11-04 · Gate de BOM: verde, causa raíz y guardia probada en rojo

**Encuadre:** el fundador autorizó (a) limpiar el único BOM que mantenía rojo el
`encoding-guard` y (b) crear el canal `Mensajes entre modelos/HY4/`. Para el
siguiente hueco pidió elegir lo que §15 dice que Hy4 hace mejor que la flota:
**diagnóstico de causa raíz de tooling + cadenas multi-paso con verificación al
final**, no documentación repetitiva ni aprobación visual (§15.5).

**Medido antes de escribir:** HEAD `95aab9d`; gate `exit=1` con 1 BOM; 25 canales,
0 HY4; pool de logs `693 libres (primero=2308)`.

**Cerrado:**

- [x] BOM de `M138/plan-actual/05-Checklist.md`: 3 bytes (`EF BB BF`), diff 1:1,
  28967→28964 B. Gate real **exit 0** (verde). Quedan 4 `U+FEFF` embebidos como
  aviso, no bloqueantes por diseño.
- [x] Causa raíz de la reincidencia medida en 25 commits: los BOM vuelven por
  **mensajes de canal** de otros agentes (hasta 6 por commit: `6c9eee8`,
  `b90440a`, `8677142`) y 2 pools, no por código. La limpieza masiva de B7 trató
  el síntoma; el gate es la contención.
- [x] `scripts/verificar_bom.py`: `--fix` ahora respeta `.gitignore` vía
  `git check-ignore -z --stdin`, **falla cerrado** si git no responde y escribe
  con `os.replace` atómico (trampa 18). Modo informe/CI sin cambios.
- [x] `scripts/test_verificar_bom.py` (nuevo): prueba end-to-end por ruta real
  sobre repo temporal. **26 checks / 0 fallos**, `CHECKS_MINIMOS=26` medido en
  verde. Rojo por inyección: filtro roto → 6 FAIL (exit 1); bloque no llamado →
  CIEGO (exit 3); control → 0.
- [x] Canal `Mensajes entre modelos/HY4/` abierto: pool 1..200 (no versionado),
  `proximo_numero.py HY4 --consume` → **01**, mensaje de apertura + informe B8
  escrito. Excepción §10.2 declarada en el propio `01` (normalmente lo escribe
  el director; acá lo autorizó el fundador).
- [x] `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` §15.9: evidencia medida de
  esta sesión. Hy4 **ya estaba** en la guía (§15 / §5.G) → no hizo falta
  investigar capacidades en la web ni adjudicarse áreas nuevas.
- [x] Log reservado: **2308** — reingreso B8, gate verde, causa raíz y guardias.

**Trampa nueva (B8, sin número — corregido en B9): un `--fix` que no distingue
versionado de ignorado miente en verde local.** Nota B9: la etiqueta «64» que
puso B8 **colisiona** con la numeración heredada de otros agentes (ya existía
«trampa 64 = logs untracked»). Desde B9 se usan nombres descriptivos.
CI corre sobre checkout limpio y nunca ve el archivo ignorado;
el fix local sí lo mutaba. Corolario: si `git check-ignore` falla, la única
salida honesta es **abortar sin mutar**, no «seguir con todo». Y el piso de
checks hay que medirlo en verde y probarlo en rojo quitando un bloque.

**NO hice:** flips de marcas ajenas, QA §21.8, sellos, aprobación visual, tocar
`AGENTS.md` / `CHECKLIST-GLOBAL.md` / `quality.yml` / `project.godot`, ni push.
`quality.yml` sigue sin correr la suite nueva → queda pedido a la directora.

**Pendiente que sigue abierto:** H-1, B6 (662 rutas + 28 módulos), 12
colisiones de numeración heredadas, y ahora: que `encoding-guard` ejecute
`test_verificar_bom.py` (archivo protegido, requiere orden).

---

## B9 — 2026-11-04 · B5 cerrado: reauditoría de huérfanos + relocalización de scratch

**Encuadre:** el fundador pidió seguir con B5 («si segui con eso el B5»). B5
quedó abierto en el Log 1190 con tres decisiones pendientes. Encuadre §15:
diagnóstico de causa raíz de tooling + cadena multi-paso con verificación al
final. No es QA visual ni sello.

**Medido antes de escribir:** HEAD `c50932e` (entre B8 y la reserva entró un
commit ajeno `Preservación 4nov 17:27`, sin tocar paths de B5). **127**
`crear_*.py` (126 en `tools/` + 1 en `game/`), **65** `.py` dentro de `game/`
(57 versionados + 8 ignorados por `fix_*.py` / `gen_*.py`), **19870** archivos
versionados escaneados para referencias. El Log 1190 hablaba de 42: crecieron
**23** en un mes.

### 1. Los «2 huérfanos reales» eran 0 (defecto del detector, no del repo)

| Script citado | Realidad medida |
|---|---|
| `crear_jugador_voxel.py` | Declara `RUTA_SALIDA` y `export_format="GLB"`. Su salida `game/isla-ancestral/assets/3d/media/45-Arte3D_jugador_voxel.glb` existe y está versionada (`c1defbc4…`). **Nunca genera `.blend`.** |
| `crear_hierba_alta_lowpoly.py` | No está en la raíz de `50-Vegetacion/` sino en `50-Vegetacion/scripts/` (versionado `3c152bf6…`). Produce `hierba_alta_lowpoly.blend` + `_baja` + `_media`, 3 GLB y `assets/fichas/50-Vegetacion_hierba_alta.md`. |

**Trampa (nombre descriptivo, sin número): «detector de un solo formato de
salida».** Definir huérfano como «script sin `.blend` en la raíz del módulo»
declara huérfano a cualquier generador que exporte GLB directo o que viva en
una subcarpeta `scripts/`. Corolario: la aserción de cierre debe ser **positiva**
(el artefacto existe) y no solo «no encontré `.blend`». Quedó fijado con 8
aserciones positivas en la guardia.

### 2. Clasificación de los 65 `.py`

- **29** scripts Blender (`import bpy`), **28** generadores/flips de un solo
  uso, **8** otros (herramientas M100/M88/M39 y validadores).
- **24** tienen referencias en archivos versionados; **41** no tienen ninguna
  (escaneo completo, incluidos `.gd`, `Logs/` y `Mensajes entre modelos/`).
- **Trampa (nombre descriptivo): «sin referencias ≠ relocalizable».**
  `game/isla-ancestral/tools/validate_dialogues.py` no es citado por nadie y
  sin embargo resuelve `data/dialogues` con `os.path.dirname(__file__)`:
  moverlo lo rompería. Se dejó en su sitio.

### 3. Relocalización (nunca borrado)

22 scripts muertos (17 `saving/_*.py`, `_flips_t9.py`, `_parche_test_m16.py`,
`expandir_hitos.py` y 2 `debug_*`): todos versionados, sin cambios ajenos en el
worktree, **0 referencias**, de un solo uso y con rutas absolutas de esta
máquina. `git mv` a **`Obsoletos/scratch-hy4-b5-2026-11-04/`** con
`MANIFIESTO.md` (origen, destino, sha256, bytes, mtime).

- **No se usó** `Obsoletos/raiz-temporales-*/`: `.gitignore:246` lo ignora y
  explicitamente dice «se conserva en disco, no en el historial». Mover 22
  archivos **versionados** ahí los habría sacado del repo. El destino elegido
  está verificado como **versionable** con `git check-ignore` antes de cada `mv`.
- `sha256` idéntico antes/después en **22/22**; 65 → **43** `.py` en `game/`.
- Quedan sin mover: 29 de autoría Blender (M36/M50, 13 con rutas citadas en
  docs), generadores M162, herramientas M100/M88/M39 y el validador vivo.

### 4. Guardia nueva: `scripts/auditar_scratch_game.py`

- `--check`: congela el inventario medido de **43** `.py`; cualquier `.py`
  nuevo bajo `game/` → rojo. Además exige las **8 evidencias positivas** de los
  ex-huérfanos. Resultado real: `43 / baseline 43 / nuevos 0 / faltantes 0`,
  **exit 0**.
- `--self-test`: end-to-end por ruta real sobre repositorios temporales.
  **13 checks / 0 fallos**, `CHECKS_MINIMOS=13` **medido en verde**, guardia de
  alcanzabilidad (si un bloque no se llamó → CIEGO exit 3) y guardia de ceguera
  (árbol sin `.py` → exit 3, nunca verde heredado).
- **Probado en rojo por inyección (4 mutaciones):** detector que nunca marca
  nuevos → 3 FAIL (exit 1); bloque S4 no llamado → CIEGO (exit 3); evidencias
  positivas hardcodeadas en `True` → FAIL del control negativo (exit 1); guardia
  CIEGO removida → FAIL (exit 1). Control intacto → 0.

### 5. Cierre y corrección de numeración

- [x] Reauditoría: **0 huérfanos reales**; no se generó ningún asset.
- [x] 22 scripts relocalizados con manifiesto y sha256 verificado.
- [x] Guardia nueva, 13/0 en verde y 4 guardias en rojo.
- [x] Corregida la etiqueta «trampa 64» que B8 se adjudicó: **colisiona** con
  la numeración heredada de otros agentes. Desde B9, nombres descriptivos.
- [x] Log reservado: **2310** · mensaje **02** del canal HY4.

**NO hice:** flips de marcas ajenas, QA §21.8, sellos, aprobación visual, tocar
M18-BIS (MiMo) / M19 / `CHECKLIST-GLOBAL.md` / `quality.yml` / `AGENTS.md` /
`project.godot` / `05-Checklist.md` ajenos, ni push. Mensaje `02-` (no `002-`
como sugiere el helper) para conservar el orden lexicográfico con el `01-` del
hilo; el helper parsea `^(\d{1,3})-` y sigue devolviendo el número correcto.

**Pendiente:** que la directora autorice ejecutar en `encoding-guard` las dos
suites (`test_verificar_bom.py` y `auditar_scratch_game.py --self-test`); hoy
existen y pasan, pero CI no las corre. Y la decisión de los dueños M36/M50
sobre los 29 scripts de autoría que siguen en `game/`.
