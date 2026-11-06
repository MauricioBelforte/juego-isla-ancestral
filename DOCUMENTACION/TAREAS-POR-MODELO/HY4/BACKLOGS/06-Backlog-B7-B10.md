# Hy4 — B7-B10: Reingreso 4nov (BOM gate, causa raíz, guardias, columnas M25)
**Fuente:** BACKLOG-MASTER.md Hy4 (sección dividida 4nov por fundador)
**Modelo:** Hy4 preview (Tencent Hunyuan)
**Plataforma:** WorkBuddy
**Estado:** Reciente (4nov)


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
- [x] `DOCUMENTACION/GUIA-COMPARATIVA-MODELOS/GUIA-COMPARATIVA-MODELOS-V1.md` §15.9: evidencia medida de
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

## B10 - 2026-11-04 · Columna rota M25 (autoría headless independiente)

- [x] Hueco real medido: `CHECKLIST-OBJETOS-BLENDER.md` L174 `[ ] Columna rota (2 variantes de altura)`; 0 `.blend`/GLB de columna en M25.
- [x] Generador `25-Ruinas-Templos/scripts/crear_columna_rota_lowpoly.py`: 2 alturas (1.50 / 2.20 m), 12 `SM_` por variante.
- [x] 6 `.blend` (ALTA/MEDIA/BAJA × 2), 12 capturas orbitales y 2 hojas de 6 capturas, 100 % headless sin socket 9876.
- [x] `chk_asset.py`: cada blend pasa **su** perfil M166; `z_min=0.0450` en los 6.
- [x] Guardias positivas: altura real (1.4900 / 2.1900), apoyo por pieza (6/6 en 0.0450) y unión fuste/corona en `z1` sin aire.
- [x] 4 iteraciones, todas con regeneración completa: ningún artefacto de una versión anterior del generador.
- [x] Log **2311** · mensaje **03** del canal HY4.

**Decisión de binarios:** `.gitignore:228` (`*.blend`, «usar Git LFS si se necesitan») y `.gitignore:104` (`**/capturas/`) los ignoran a propósito. No se hizo `git add -f`: el único entregable versionable es el generador; los `.blend`/PNG/JPG quedan como artefactos locales reproducibles.

**NO hice:** flip de L174 (se propone), QA §21.8, sellos, aprobación visual, export GLB, tocar archivos protegidos ni cambios ajenos (Hy3), push, `--amend`, `add -A`.

**Pendiente (dirección):** P1 flip L174 · P2 Git LFS sí/no · P3 `exportar_godot.py` si el asset entra al juego · P4 aprobación visual por otro modelo.

