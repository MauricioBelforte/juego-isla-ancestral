# BACKLOG-MASTER — HY4 (Blender)

**Modelo:** Hy4 preview (Tencent Hunyuan)
**Plataforma:** WorkBuddy — tambien figuro como `HY4` sobre Kilo Code en sesiones de autoria Blender
**Identidad canonica:** la autoevaluacion de este modelo es el **§15** de `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md`
**Especialidad:** Assets 3D lowpoly para Blender → Godot
**Fecha de inicio:** 2026-09-02
**Fecha de ultima actividad:** 2026-09-10

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

## Pendientes globales (21 items)

### M36 Fauna (5 pendientes)
- [ ] Pez tropical (2 variantes de color)
- [ ] Lagarto de isla
- [ ] Cabra
- [ ] Gallina
- [ ] Mariposa (alas simples para animar)

### M25 Ruinas (2 pendientes)
- [ ] Columna rota (2 variantes de altura)
- [ ] Columna entera con capitel
- [ ] Bloque de piedra tallada (modulo de muro)
- [ ] Dintel caido
- [ ] Palanca de puzzle (interactuable)
- [ ] Estructura sumergida parcial (marea)

### M40 Infraestructura (1 pendiente)
- [ ] Valla de madera (modulo recto + esquina)

### M35 Mineria (3 pendientes)
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
1d. **Anotar los 17 scripts huerfanos** (en disco, no en el checklist): 10 modulos constructivos de 18-Casas, `crear_cultivo_etapa`, `crear_casa_completa_ejemplo`, 2 cabezas NPC, `crear_jugador_voxel`, `crear_luna`, `crear_roca`. No se marcaron `[x]` porque falta verificar capturas/aprobacion visual.
2. ~~**Actualizar CHECKLIST-OBJETOS-BLENDER.md**~~ — sincronizado en log 809 (169 items). Cierre de mobiliario: log 810 (4 items) + log 811 (10 items) → **141 `[x]` / 28 `[ ]`**.
1e. **Errores nuevos documentados en el log 811:** E-104 (una caja apoyada aporta solo 4 vertices, el guard `toca>=8` la rechaza) y E-105 (el decimate de BAJA se come primero los apoyos chicos: curar con cilindros, nunca relajando el guard). Total de la guia: **105 errores**.
3. **M18-BIS Casas grandes: mansión + casa de vecino** — **TRASPASADO a MiMo por
   directiva del usuario (2026-09-11)**. HY4 cerro 3/5 (log 806/808/822) y se paso a
   tareas de cruzamiento. Plantilla y capturador listos en `18-Casas/scripts/`.
4. **Completar M36 Fauna** restante (pez tropical, lagarto, cabra, gallina, mariposa)
5. **Completar M25 Ruinas** restante (columnas, dintel, palanca, estructura sumergida)
6. **Completar M35 Mineria** restante (caña pesca, pez, cangrejo, carrito)
7. **Revision visual M18-TER** — 30 accesorios de tienda pendientes de aprobar
