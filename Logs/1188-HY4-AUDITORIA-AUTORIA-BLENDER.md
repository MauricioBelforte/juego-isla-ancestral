# Log 1188: Auditoría de autoría Blender (`tools/mcp/blender-mcp`)

**Fecha:** 2026-10-02
**Modelo:** Hy4 / WorkBuddy
**Plataforma:** WorkBuddy
**Módulo:** transversal (assets 3D).
**Reserva:** `Logs/reservas/1188-HY4.txt`
**Encaje:** Opción B del backlog HY4 — "parchar huecos".

---

## 0. Alcance

Inventario completo de la carpeta de autoría Blender y cruce **script ↔ asset
generado**. No es QA visual (§15.3 lo excluye del perfil Hy4) ni sella nada:
es **auditoría administrativa** de qué scripts existen y qué produjeron.

Herramienta: comparación por nombre normalizado (se quitan los prefijos `SM_`
y `crear_`, y los sufijos `_lowpoly` / `_alta` / `_media` / `_baja`).

| Dato | Valor |
|---|---|
| Scripts `crear_*.py` | **126** |
| Módulos con `.blend` | **16** |

---

## 1. Huérfanos: 8 de 126

Un huérfano = script del que **no existe** un `.blend` que corresponda en su
módulo. De los 8, **4 son falsos positivos** del método y **2 son duplicados**
(§2), así que los **realmente pendientes son 2**:

### Reales

| Script | Módulo | Nota |
|---|---|---|
| `crear_hierba_alta_lowpoly.py` | `50-Vegetacion` | No hay ningún blend de hierba alta en el módulo. |
| `crear_jugador_voxel.py` | `scripts-reutilizables` | Generador del jugador voxel; sin salida registrada. |

### Falsos positivos (NO son huecos)

| Script | Por qué no lo es |
|---|---|
| `15-Recursos/crear_roca_lowpoly.py` | Su salida es `roca_comun.blend` (nombre distinto, mismo asset). |
| `18-Casas/crear_decoracion_tienda_batch.py` | Script **batch**: decora una escena, no genera un blend con su nombre. |
| `33-Agricultura/crear_cultivo_etapa_lowpoly.py` | **Parametrizado**: produce `cultivo_brote`, `_creciendo`, `_lista`, `_madura`. |
| `NPC_SCRIPTS/crear_catalogo_npcs.py` | Script de catálogo, no de generación. |

> Trampa metodológica: el primer intento de auditoría dio **126 huérfanos de
> 126** (100 %). Causa: el normalizador del nombre del blend no quitaba el
> sufijo `_lowpoly`, así que `crear_monton_ramas_lowpoly.py` nunca podía
> coincidir con `monton_ramas_lowpoly.blend`. **Un detector que da 100 % no
> está encontrando nada: está roto.** Se corrigió y bajó a 8.

---

## 2. Duplicados: 2 pares (medidos, no estimados)

### 2.1 `crear_casa_01_choza.py` — copia byte-idéntica en carpeta ajena

| Archivo | sha256 (16) | Tamaño |
|---|---|---|
| `18-BIS-Casas-Grandes/CASA_01_CHOZA/BAJA/crear_casa_01_choza.py` | `6b02317ff9f04260` | 31 166 B / 1157 líneas |
| `18-BIS-Casas-Grandes/CASA_02_CASA_MEDIANA/BAJA/crear_casa_01_choza.py` | `6b02317ff9f04260` | 31 166 B / 1157 líneas |

**Son el mismo archivo.** El de `CASA_02_CASA_MEDIANA/BAJA/` es una copia que
quedó en la carpeta equivocada. ⚠️ **M18-BIS es territorio de MiMo** (regla
"No tocar M18-BIS"); se **reporta**, no se borra.

### 2.2 `crear_luna.py` — dos versiones que difieren solo por la cabecera

| Archivo | sha256 (16) | Líneas |
|---|---|---|
| `NPC_SCRIPTS/crear_luna.py` | `7c7f17f13c3719b2` | 1087 |
| `scripts-reutilizables/crear_luna.py` | `b587cee5e713f1fd` | 1102 |

Diff completo (`unified`, n=0): **19 líneas**, y son exactamente
**14 líneas de cabecera de documentación** (`# LUNA — NPC 01/35 — ISLA RAIZ…`)
más **1 línea en blanco** al final. Las 1087 líneas de código son idénticas.

→ No hay divergencia funcional. Son el mismo generador con y sin encabezado.

---

## 3. 42 scripts `.py` dentro de `game/`

`game/isla-ancestral/scripts/` debería contener **solo `.gd`**. Hay **42**
archivos `.py` viviendo ahí: generadores (`gen_m162_*` ×5), scripts de Blender
para fauna (`conejo_v7`…`v11`, `abeja_v1`, `erizo_rana_v1`, `lechuza_v1`,
`nutria_v1`, `pez_v1`), utilidades de reescalado (`reescalar_*` ×9), renders
orbitales (`render_orbital*`) y `crear_conejo_lowpoly.py`.

Godot los ignora (no afectan al runtime), pero:
- Ensucian el conteo de "scripts del proyecto" (los `.gd` reales son ~1019).
- `crear_conejo_lowpoly.py` es un **script de Blender** y está en el árbol
  de Godot.

⚠️ **No se movió nada.** La regla del proyecto es que el scratch **no se borra:
se relocaliza** a `Obsoletos/raiz-temporales-*/`, y estos archivos son de otros
agentes (M36 Fauna, M162, M39). Se documenta para que sus dueños decidan.

---

## 4. Lo que NO hice

- **No generé ningún asset**: el MCP de Blender está caído en esta sesión y el
  §15.3 excluye del perfil Hy4 la aprobación visual final.
- **No borré ni moví** los duplicados (M18-BIS = MiMo) ni los `.py` de `game/`
  (dueños ajenos).
- **No emití ningún sello §21.8**: esto es inventario, no cierre de módulo.

## 5. Próximo paso sugerido

1. Dueño de M18-BIS (MiMo): borrar la copia de `CASA_02_CASA_MEDIANA/BAJA/`.
2. Unificar `crear_luna.py` dejando la versión **con** cabecera en
   `scripts-reutilizables/` y apuntando `NPC_SCRIPTS/` a ella.
3. Decidir el destino de `crear_jugador_voxel.py` y `crear_hierba_alta_lowpoly.py`
   (¿se ejecutan o se archivan?).
4. Extraer los 42 `.py` de `game/` a `tools/` o `Obsoletos/raiz-temporales-*/`.
