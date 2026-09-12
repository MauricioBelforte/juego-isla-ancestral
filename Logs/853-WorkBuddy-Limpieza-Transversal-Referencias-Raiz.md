# Log 853: Limpieza transversal — TMP de libvoxel, referencias cruzadas e inventario de la raíz

**Fecha:** 2026-09-12
**Hora:** 14:35
**Modelo:** Hy3 / WorkBuddy
**Plataforma:** WorkBuddy (WorkBuddy AI)

## 0. Contexto

Continuación de la tarea transversal del Log 852. El usuario pidió: *"hace lo
que mejor sepas corregi esos problemas"*, refiriéndose a los tres candidatos
que quedaron listados al cierre del 852:

1. los `~libvoxel*.TMP` en `addons/zylann.voxel/bin/`
2. las referencias cruzadas rotas entre `DOCUMENTACION/` y `Logs/`
3. los scripts huérfanos de la raíz

## 1. Residuos `~libvoxel*.TMP` (166 MB)

Estos archivos los genera Godot cuando recarga en caliente una GDExtension
cuyo DLL está bloqueado: Windows no permite borrarlo y lo renombra a
`~nombre~RF<hex>.TMP`. Son copias huérfanas.

Verificación antes de tocar nada (nada de esto era evidente sin medir):

| Comprobación | Resultado |
|---|---|
| Cantidad | **23** archivos |
| Tamaño total | **166 MB** (había crecido desde los 82 MB anotados) |
| ¿Duplicados? | **Sí**: los 23 tienen el **mismo md5** |
| ¿DLL real intacto? | Sí: `libvoxel.windows.editor.x86_64.dll`, 7.547.392 bytes |
| ¿Versionados? | 0 (`.gitignore:16` ignora `game/isla-ancestral/addons/`) |
| ¿Godot en ejecución? | No |

Acción: se conservó **1 copia** en `Obsoletos/libvoxel-TMP-20260912/` y se
eliminaron las 22 restantes. Directorio de 267 MB → 101 MB.

> Nota: la ruta real era `game/isla-ancestral/addons/...`, no
> `addons/zylann.voxel/bin/` como decía la anotación anterior. Corregido.

## 2. Referencias cruzadas a `Logs/`

Se creó `scripts/auditar_referencias.py`. Detecta rutas del tipo
`Logs/401-*` y menciones `Log NNN`, y verifica que existan.

**Resultado: 145 referencias rotas reparadas, 0 restantes.**

La parte no obvia estuvo en la regla de reparación. La primera versión
emparejaba por número y habría introducido un error grave:

```
Logs/679-workbuddy-M16-3D.md  ->  679-AGNES-BUCLE-M30-BADGE-FIXED_2026-09-05.md
```

El número 679 está ocupado por un log de **otro tema**. Reemplazar habría
creado una referencia *equivocada*, que es peor que una rota. Se rehízo la
regla con dos casos:

- **Comodín o sin descripción** (`Logs/401-*`): el número es la clave → se
  usa el único log con ese número. Cubre el grueso (144 de 145, casi todo
  `11-BUGS.md`).
- **Nombre concreto inexistente**: no se fía del número, busca por **tokens
  del nombre entre todos los logs**. Así `workbuddy-M16-3D` encontró sus logs
  reales (`730-workbuddy-M16-3D-MISCELANEA.md`, `737-workbuddy-M16-3D.md`),
  no el 679. Con coincidencia exacta de nombre (ignorando número) se resuelve
  la ambigüedad.

Quedan **4 casos para decisión humana** (la herramienta no adivina):
`Logs/679-workbuddy-M16-3D.md` (2 candidatos), `Logs/364-qa-sim-m70.py` (sin
coincidencia) y dos `Logs/258/263/333` (ruta múltiple, no resolvible
automáticamente).

### Hallazgo: `CHECKLIST-GLOBAL.md` cita un Log 723 que nunca existió

El verificador marcó `Log 723` en la fila del módulo **M11**. Comprobación:

```
ls Logs/ | grep -E "^72[0-9]"   ->   720, 721, 722, 724, 725 ...   (723 NO)
git log --all -- Logs/723*      ->   (vacío: nunca existió en el historial)
```

Es una referencia a un número que jamás se creó. La misma fila ya cita el
**Log 848** (mi QA cruzado del Lote A, que incluye M11), así que la cita a 723
es redundante y obsoleta. **No se editó**: `CHECKLIST-GLOBAL.md` es la fuente
de verdad del estado global y otro agente la está editando en paralelo —
un cambio erróneo ahí es peor que una referencia vieja. Queda documentado.

## 3. Inventario de la raíz

Se generó `DOCUMENTACION/INVENTARIO-RAIZ.md` con `scripts/inventariar_raiz.py`:
tamaño, fecha, si están versionados, cuántas veces se mencionan en la
documentación, tipo, encoding detectado y primera línea (indicio de propósito).

Se movieron a `Obsoletos/raiz-temporales-20260912/` **29 archivos** en dos
tandas: 25 claramente temporales (`_tmp_*`, `tmp_*`, `patch_m74_*`,
`recover_estado*`, `revert_m74.py`, `mark_m74_checklist.py`, `_gen_*`,
`_main_*`, `renombrados_logs.json`) y después 4 scripts de un solo uso
(`_capture_tier_c.py`, `_fix_piramide2.py`, `_fix_spawn_pradera.py`,
`bloquear_m23.py`).

**No se borró nada**: mudanza reversible. Raíz: 64 → **39** entradas sueltas.

### 3.1 El primer inventario salió corrupto y el repo lo vio como binario

Esto merece registrarse aparte porque es el mismo daño que el Log 852
documenta, **causado por la herramienta que se suponía que lo evitaba**.

La primera versión del inventario se generó leyendo todo como UTF-8. En la
raíz hay un archivo **UTF-16** (`_gen_aprobado.gd`). Resultado:

```
NULs: 310      -> git clasificó el .md de BINARIO ("Bin 0 -> 5305 bytes")
U+FFFD: sí     -> caracteres de reemplazo incrustados en el markdown
```

Se reescribió el generador con detección de BOM, heurística de UTF-16 sin BOM,
y **caída final a `latin-1`**, que nunca falla y nunca produce U+FFFD (al
contrario que `errors="replace"`, que es el creador del daño). El preview se
sanea de caracteres de control. El script **falla con `assert`** si el
resultado contiene un NUL o un U+FFFD, así no puede volver a pasar desapercibido.

### 3.2 Huérfanos que NO se movieron

Un inventario automático sugiere mover todo lo que no entiende. Se excluyeron
explícitamente en el script (dict `CONSERVAR`), con el motivo:

| Archivo | Por qué se queda |
|---|---|
| `isla-modelo*.jpg`, `paleta-propuesta-isla.png` | referencia visual de la isla, insumo del usuario |
| `renombrar_logs.py` | utilidad reutilizable: la numeración de `Logs/` se rompe seguido (BUG-014) |
| `postlaunch_checklist.json` | decidir si se integra a M121 o se descarta |

Las utilidades con pinta de reutilizables (`analizar_logs.py`,
`corregir_logs.py`, `check_godot.bat`, `validate_tscn.bat`,
`validate_m13.bat`, `run_m105.ps1`) siguen en la raíz, documentadas.

## 4. Resultados

| Problema | Antes | Después |
|---|---|---|
| `~libvoxel*.TMP` | 23 archivos / 166 MB | 0 (1 copia en `Obsoletos/`) |
| Referencias rotas a `Logs/` | 149 | **0** (145 reparadas, 4 a revisión) |
| Archivos sueltos en la raíz | 64 | 39 (29 mudados, 0 borrados) |
| NUL / U+FFFD en el inventario | 310 / sí | **0 / 0** (assert en el generador) |

### Commit selectivo

El árbol tenía 348 cambios de otros agentes. Se creó
`scripts/stage_solo_referencias.py`, que prueba si el working tree se explica
**completamente** por mis transformaciones (`enc`, `ref` o `enc+ref` aplicadas
a HEAD). Resultado: **5 archivos puros**, 81 mezclados con trabajo ajeno en
curso (verificado a mano sobre `11-BUGS.md`: lleva BUG-025 de
DeepSeek-V4.1-Flash y cambios de rutas de guías).

Las 145 reparaciones de referencias viven casi todas en archivos mezclados, así
que **quedan sin commitear a la espera de que sus dueños cierren sus ediciones**.
No se fuerza el stageo: commitear trabajo ajeno sin revisarlo es peor que
dejar una referencia rota un rato más.

Además se agregaron a `.gitignore` `Obsoletos/libvoxel-TMP-*/` (binario de
7.2 MB) y `Obsoletos/raiz-temporales-*/`, para que la copia de respaldo del DLL
y el scratch no terminen en el historial por un `git add -A` distraído.

## 5. Advertencias y honestidad (§21.4)

- **Trampa de fines de línea.** La primera versión del auditor leía en modo
  texto (convierte CRLF→LF) y escribía con `newline=''`, así que podía cambiar
  los saltos de todo un archivo camuflado de reparación. Parcheado: ahora lee
  también con `newline=''`. Git normaliza al commitear (los propios avisos
  `LF will be replaced by CRLF` lo confirman), por lo que no hay daño
  permanente, pero queda registrado.
- **Eliminación de TMP**: se borraron 22 de 23. Son bytes idénticos entre sí y
  el DLL real está intacto, pero si algo fallara al abrir el proyecto con
  Godot, la copia de respaldo está en `Obsoletos/libvoxel-TMP-20260912/`.
- No se tocó `CHECKLIST-GLOBAL.md` (Log 723) ni los 4 casos ambiguos: requieren
  criterio humano o del agente dueño.
- Siguen sin commitear (del Log 852) 57 archivos cuya reparación de
  codificación venía mezclada con trabajo ajeno en curso.

## 6. Archivos

- Creado: `scripts/auditar_referencias.py` (audita y repara rutas a `Logs/`)
- Creado: `scripts/stage_solo_referencias.py` (stageo selectivo por transformación)
- Creado: `scripts/inventariar_raiz.py` (inventario con assert anti-NUL/U+FFFD)
- Creado: `DOCUMENTACION/INVENTARIO-RAIZ.md`
- Modificado: `.gitignore` (2 reglas de exclusión de residuos)
- Modificado: 145 referencias reparadas (principalmente `DOCUMENTACION/11-BUGS.md`
  y `DOCUMENTACION/10-GUIA-COMPARATIVA-MODELOS.md`)
- Commiteados: 5 archivos puros (`04-Codigo.md` de M01 ×2 y M166 ×2,
  `ESTADO-QA.md` de Gemini)
- Mudados: 29 temporales → `Obsoletos/raiz-temporales-20260912/`
- Eliminados: 22 `~libvoxel*.TMP` (1 conservado → `Obsoletos/libvoxel-TMP-20260912/`)

## 7. Próximo paso sugerido

1. Resolver los 4 casos ambiguos y el `Log 723` de `CHECKLIST-GLOBAL.md`.
2. Auditar enlaces markdown relativos (más allá de `Logs/`), que es el
   siguiente nivel de referencias cruzadas.
3. Commitear los 57 archivos de codificación pendientes cuando sus dueños
   cierren sus ediciones.

---
**Firma:** Hy3 / WorkBuddy · 2026-09-12 14:35
