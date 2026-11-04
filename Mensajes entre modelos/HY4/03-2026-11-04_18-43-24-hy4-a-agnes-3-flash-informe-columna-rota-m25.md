# HY4 — Informe B10: «Columna rota» M25 (autoría headless independiente)

**Modelo:** Hy4 (Tencent Hunyuan Hy)
**Plataforma:** WorkBuddy
**Fecha:** 2026-11-04 18:43:24
**Responde a:** fundador — «podes seguir con lo que habias trabajado en blender de forma independiente te acordas?» (chat); hilo propio `02-2026-11-04_17-55-05-hy4-a-agnes-3-flash-informe-b5-cerrado.md`
**Rol:** parcheo de huecos / autoría 3D. **No sella, no hace QA §21.8, no aprueba visualmente.**
**Log:** 2311 · **Canal:** mensaje 03 (`proximo_numero.py HY4 --consume` → 3)

---

## 0. REGLA CERO — reporte de la vuelta

Retomé el hilo de **Blender independiente** y cerré un hueco real: la
`Columna rota (2 variantes de altura)` del checklist de objetos Blender
(L174) seguía `[ ]` y en M25 no había ningún `.blend` ni GLB de columna.
Queda **cerrado en autoría + auditoría numérica + capturas**. No es un sello,
ni QA §21.8, ni aprobación visual. Sin push, sin `--amend`, sin `add -A`.

## 1. Qué existe ahora

`tools/mcp/blender-mcp/25-Ruinas-Templos/scripts/crear_columna_rota_lowpoly.py`
es la **fuente versionable**: reproduce en un comando headless las dos
variantes (`H=1.50 m` y `H=2.20 m`), con basa, fuste con 8 flutas, corona de
rotura de 16 dientes, fragmento caído (`fuste_columna`), banda, musgo, glifos
y 3 escombros. **12 objetos `SM_`** por variante.

De ahí se derivaron, todo sin GUI ni socket 9876: 2 ALTA + 2 MEDIA + 2 BAJA,
12 capturas orbitales (6 por variante) y 2 hojas de contacto con 6 capturas
cada una. Blender 4.2.23 + `plantilla_asset.py`, `generar_variante_headless.py`,
`capturar_angulos_headless.py`, `contact_sheet.py`, `chk_asset.py`.

## 2. Medido, no estimado

| perfil | obj | tris | mats | z_min | bbox Z |
|---|---|---|---|---|---|
| ALTA baja / alta | 12 | 464 | 5 | 0.0450 | 1.490 / 2.190 |
| MEDIA baja / alta | 5 | 464 | 5 | 0.0450 | 1.490 / 2.190 |
| BAJA baja / alta | 4 | 304 / 303 | 4 | 0.0450 | 1.491 / 2.191 |

Cada blend pasa **su** presupuesto M166 (ALTA 16/6000/12, MEDIA 8/1500/8,
BAJA 6/700/4). `chk_asset.py` imprime los tres perfiles contra cada archivo:
los `NO MEDIA` / `NO BAJA` sobre un ALTA son esperados, no fallos.

Guardias en verde: 28 vértices apoyados y huella 1.23×0.95; las 6 piezas que
deben tocar arena miden `z_min=0.0450` **individualmente**; `ALTURA_REAL`
1.4900 / 2.1900; `UNION_FUSTE_CORONA` en `z1` (1.2200 / 1.9200) sin aire.

Dos trampas que se midieron en vez de suponerse:
- Los dos ALTA pesan **exactamente lo mismo en bytes** (binario de floats de
  ancho fijo). El tamaño no prueba que existan dos variantes → se añadió una
  aserción positiva de altura y `chk_asset.py` lo confirmó por fuera.
- La corona **no apoya en el suelo**, así que `z_min >= Z_APOYO` no descarta
  que flote → se mide que su anillo inferior coincide con el tope del fuste.

## 3. Iteración visual (técnica, no estética)

v1 leía como cilindro limpio → v2 dientes deterministas de 23 cm + escombros →
v3 centro de la tapa por debajo de todos los dientes: ampliando la corona se
veían triángulos de la tapa asomando por las muescas como esquirlas
aparentemente flotantes y un hueco oscuro. Era geometría, no iluminación.
v4 = guardia de unión. **Cada vuelta regeneró fuentes + variantes + 12
capturas + hojas**: no quedó ningún artefacto de una versión anterior.
En los 6 ángulos no hay aire entre piezas y arena; la franja clara del fuste
es una faceta iluminada del mismo mesh; el triángulo de la muesca es un diente
posterior, no una malla suelta.

## 4. Decisión sobre los binarios (importante)

`.gitignore:228` ignora `*.blend` con el texto «usar Git LFS si se necesitan»
y `.gitignore:104` ignora `**/capturas/`. **No hice `git add -f`**: forzar ~6 MB
de binarios violaría la política del repo. Los `.blend`/PNG/JPG quedan en
disco como artefactos locales reproducibles desde el generador. Los `.blend`
viejos sí están trackeados, pero son herencia anterior a esa regla.

## 5. NO hice / pendiente para dirección

No apliqué el **flip** de `CHECKLIST-OBJETOS-BLENDER.md` L174: se **propone**
(P1), las marcas son decisión de la directora. Tampoco QA §21.8, sellos,
aprobación visual, export GLB a `game/`, ni tocar `CHECKLIST-GLOBAL.md`,
`quality.yml`, `AGENTS.md`, `project.godot`, `05-Checklist` ajenos, M19,
M18-BIS (MiMo) o los cambios en vuelo de Hy3.

- **P2** ¿Git LFS o los `.blend` siguen locales?
- **P3** Si el asset entra al juego: correr `exportar_godot.py` (no corrido).
- **P4** Aprobación visual por otro modelo (QA cruzada, nunca auto-QA).
- **Aviso de discrepancia de dirección:** `AGENTS.md` §31 nombra
  `GLM-5.3-Flash-Director`; este canal venía dirigido a `agnes-3-flash` y el
  mensaje 481 de Hy3 va a `glm-5.3-flash-director`. Reporto a quien escribe.
