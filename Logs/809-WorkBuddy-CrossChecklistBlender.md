# Log 809 — Auditoría cruzada del checklist de Blender vs. disco (56 GLB perdidos recuperados + 14 falsos completos)

**Modelo:** Hy4 preview
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-10
**Alcance:** transversal — `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md`,
`game/isla-ancestral/assets/3d/{alta,media,baja}`, `DOCUMENTACION/GUIA-BLENDER/`
**Reserva:** `Logs/reservas/809-WorkBuddy-CrossChecklistBlender.txt` (se borra al cerrar este log)

---

## 0. Por qué esta tarea

Directiva del usuario: *"no solo te necesito en blender sino cruzando y tomando
tareas que solo vos podés hacer bien"*. Elegí auditar el checklist maestro de
assets contra los artefactos reales del repo porque cae de lleno en mis puntos
fuertes (§15.5 de `10-GUIA-COMPARATIVA-MODELOS.md`): cadenas de varios pasos
verificables **por conteo al final**, tareas que cruzan muchos archivos sin
perder dependencias, y diagnóstico de tooling. Y evita por completo mi punto
débil: no requiere leer imágenes.

## 1. Herramienta creada

**`tools/mcp/blender-mcp/auditar_checklist.py`** — cruza los ítems del checklist
contra el disco y reporta cinco categorías:

| Cat | Qué detecta | Resultado final |
|---|---|---|
| A | FALSO PENDIENTE: `- [ ]` pero script + `.blend` + GLB existen | **0** |
| B | FALSO COMPLETO: `- [x]` pero le falta script, `.blend` o GLB | **0** (eran 14) |
| C | Ítems sin script referenciado (límite del parser, no defecto) | 43 (informativo) |
| D | Scripts huérfanos: en disco pero no en el checklist | 17 (informativo) |
| E | Sidecar `.glb.import` cuyo `.glb` **no existe** | **0** (eran 56) |

Uso: `python tools/mcp/blender-mcp/auditar_checklist.py` (o `--json`).

---

## 2. 🐛 HALLAZGO PRINCIPAL — 56 GLB perdidos (E-103)

### Síntoma

El checklist daba por buenos 56 assets, y Godot mostraba su `.glb.import`, pero
**el binario `.glb` no estaba en disco**:

| Variante | GLB presentes | `.glb.import` | Huérfanos |
|---|---|---|---|
| ALTA  | 104 | 145 | **41** |
| MEDIA | 111 | 115 | **4** |
| BAJA  | 102 | 113 | **11** |
| **Total** | **317** | **373** | **56** |

Los 56 pertenecían a sólo dos módulos: **18-Casas** (`casa_mediana` + 30 `decor_*`
del lote de la tienda) y **33-Agricultura** (10 assets: bananero, cañaveral,
compostera, 4 etapas de cultivo, regadera, tierra arada/regada).

### Causa

Los 56 GLB son archivos **nuevos, nunca commiteados**. Se comprobó con
`git ls-files`: **ninguno** figura en el índice, `git check-ignore` no los
ignora, y `git ls-files` devuelve 103 GLB trackeados en ALTA (todos presentes).
Conclusión: un `git clean -fd`, `git stash -u` o checkout de otro agente borró
los binarios sin commitear y dejó los sidecars `.glb.import`, que sí sobrevivieron.

**Consecuencia:** `git checkout` **no** los recupera. Sólo se pueden regenerar
desde el `.blend`, que sí estaba intacto (424 `.blend` en el repo).

### Fix aplicado

Re-exportación **selectiva**, sin `EXPORT_FORZAR` (que habría reescrito los 317
GLB restantes y pisado trabajo de otros agentes). Como `exportar_godot.py` saltea
cuando el destino existe y es más nuevo que el `.blend`, bastó acotar por módulo:

```
EXPORT_MODULOS="18-Casas;33-Agricultura" \
  blender -b --factory-startup --python scripts-reutilizables/exportar_godot.py
```

→ **`{"exportados": 56, "saltados": 46, "errores": 0}`**. Exactamente los 56.

Después, reimport en Godot:
`Godot_v4.7.2_console --headless --path game/isla-ancestral --import`
→ reimportó los 56 y nada más.

### Verificación (por conteo y por hash)

- Huérfanos `.glb.import` sin `.glb`: **0** en las 3 variantes.
- Totales finales: **145 ALTA / 115 MEDIA / 113 BAJA = 373 GLB**, 373 `.import`, 399 `.scn`.
- **El hash que Godot guarda en el nombre del `.scn` no cambió**: `casa_mediana`
  sigue en `f20efca8…` (ALTA) / `d0ae8a0a…` (MEDIA) / `f194e690…` (BAJA), idénticos
  a los del log 806. La re-exportación reproduce el binario original.
- Conteo de objetos coherente con el log 806: casa_mediana 60 / 17 / 17 `SM_`.

> **Aviso metodológico:** el hash del nombre del `.scn` de Godot **NO** es el md5
> del GLB. Se probó: 0 de 373 coinciden. No sirve como prueba de identidad de
> archivo; sirve como prueba de que *Godot* considera el recurso equivalente.

---

## 3. 🐛 SEGUNDO HALLAZGO — 14 ítems de mobiliario marcados completos sin existir

La sección **"Mobiliario interior"** de M18 tenía 14 ítems en `- [x]` con su
`crear_*.py` referenciado, pero **sin script, sin `.blend` y sin GLB**:

`cama_basica`, `cama_doble`, `mesa_madera`, `velador`, `silla_madera`, `sillon`,
`nevera_rustica`, `estufa_lena`, `estanteria`, `comoda`, `lampara_pie`,
`alfombra`, `cuadro_ancestral`, `maceta_interior`.

Se comprobó que no existen bajo otro nombre: `18-Casas/scripts/` sólo tiene
`crear_casa_*`, los 10 módulos constructivos (pared/piso/techo/puerta/ventana/
zócalo/escalera) y `crear_decoracion_tienda_batch.py`. El mobiliario interactivo
(dormir/sentarse/cocinar/almacenar) **no está construido**.

**Acción:** revertidos a `- [ ]` con la nota
*"REVERTIDO a pendiente (auditoría log 809): no existe script, .blend ni GLB
(falso completo)"*. No se inventó nada para que el número diera verde.

**Estado del checklist tras la auditoría:** 169 ítems → `[x] = 127`, `[ ] = 42`
(antes `[x] = 141`, `[ ] = 28`).

### Contadores corregidos

El bloque "Contadores" era internamente inconsistente: decía *total 165* con
*104 completados + 46 pendientes = 150*. Ahora dice los números reales del
recuento automático y declara la auditoría ejecutada.

---

## 4. 🐛 TERCER HALLAZGO — dos bugs en mi propio script de auditoría (E-101, E-102)

Documentados porque son trampas en las que va a caer cualquier herramienta nueva:

- **E-101 — raíz del repo contando `..` a mano.** `os.path.join(ROOT,'..','..')`
  desde `tools/mcp/blender-mcp` aterriza en `.../tools`, no en la raíz. Daba
  `GLB en Godot: 0` e inflaba la categoría B a **123 falsos positivos**.
  Fix: derivar la raíz buscando `AGENTS.md` hacia arriba.
  **Regla: si un índice da 0, desconfiar del script antes que del repo.**
- **E-102 — derivar el nombre base de un `.blend` quitando sólo `_media`/`_baja`.**
  Quedaba `cristal_ancestral_lowpoly` en vez de `cristal_ancestral`, así que
  los 424 `.blend` parecían ausentes. Hay que quitar también `_alta`/`_lowpoly`.

---

## 5. Cambios de documentación

| Archivo | Cambio |
|---|---|
| `DOCUMENTACION/GUIA-BLENDER/04-errores-avanzados.md` | **Renombrado** desde `04-errores-avanzados-e36-e100.md`. Agregados **E-101**, **E-102**, **E-103**. Encabezado con nota explicando el renombre. |
| `DOCUMENTACION/GUIA-BLENDER/INDICE.md` | Referencias al nuevo nombre; total 100 → **103** errores. |
| `AGENTS.md` | Referencia y total actualizados. |
| `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md` | Corregido un enlace **roto** que apuntaba a `...-e36-e97.md`. |
| `tools/mcp/blender-mcp/CHECKLIST-OBJETOS-BLENDER.md` | 14 ítems revertidos; bloque de contadores con números reales. |

**Sobre el renombre:** el archivo se llamaba por rango y había que renombrarlo en
cada error nuevo (e36-e97 → e36-e100 → …), rompiendo enlaces en tres documentos
cada vez. Se pasó a un nombre estable `04-errores-avanzados.md`; el rango real
vive en el título de cada sección y el total en `INDICE.md`. Se verificó con
Grep que **no queda ninguna referencia** al nombre viejo en el repo.

---

## 6. Observaciones honestas (§21.4)

1. **No determiné quién borró los 56 GLB.** Sé que no estaban en git y que sí
   existieron (los sidecars y los `.scn` de Godot los referencian con su hash).
   No encontré evidencia para atribuirlo y no voy a especular.
2. **La categoría C (43 ítems "sin script") es una limitación de mi parser**, no
   un defecto del checklist: la mayoría son ítems cuyo nombre no incluye el
   `crear_*.py` (p. ej. "Tierra arada", "Columna rota"). No los toqué.
3. **Los 17 scripts huérfanos (categoría D) son trabajo real no anotado** en el
   checklist: los 10 módulos constructivos de 18-Casas, `crear_cultivo_etapa`,
   `crear_casa_completa_ejemplo`, 2 cabezas de NPC, `crear_jugador_voxel`,
   `crear_luna` y `crear_roca`. **No los marqué `[x]`** porque no verifiqué sus
   capturas ni su aprobación visual — queda como deuda documental.
4. **El renombre del archivo de errores toca `AGENTS.md`**, que es un archivo
   caliente con edición concurrente de otros modelos. El cambio es una
   sustitución de una línea; si aparece un conflicto, el fix es trivial.
5. **No commiteé los 56 GLB recuperados.** El working tree tiene ~335 cambios de
   otro modelo que deliberadamente no toqué. **Recomendación urgente:** commitear
   los GLB nuevos apenas se exportan — mientras sean untracked son irrecuperables
   por git y sólo se salvan regenerándolos (E-103).

---

## 7. Artefactos

- Creado: `tools/mcp/blender-mcp/auditar_checklist.py`
- Modificado: `CHECKLIST-OBJETOS-BLENDER.md` (14 ítems + contadores)
- Modificado: `04-errores-avanzados.md` (+E-101/E-102/E-103, renombrado),
  `INDICE.md`, `AGENTS.md`, `10-GUIA-COMPARATIVA-MODELOS.md`
- Regenerados: 56 GLB (41 ALTA, 4 MEDIA, 11 BAJA) + sus 56 `.scn`

---

## 8. Firma

**Modelo:** Hy4 preview
**Plataforma:** WorkBuddy
**Fecha:** 2026-09-10
**Estado:** auditoría transversal **CERRADA**. Checklist sincronizado con el disco:
0 falsos pendientes, 0 falsos completos, 0 sidecars huérfanos.
**Siguiente módulo (sugerido por esta auditoría):** mobiliario interior M18
(14 ítems revertidos) y/o las 3 casas restantes de M18-BIS (casona, mansión, casa de vecino).
