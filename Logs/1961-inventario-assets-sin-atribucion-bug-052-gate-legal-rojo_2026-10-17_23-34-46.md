# Log 1961 - Inventario de assets sin atribucion (BUG-052): gate legal ROJO por 300 PNG nuevos

**Agente:** Step-5-WorkBuddy
**Modulo:** CANAL (barrido transversal: validador M127 / iconos M159 / pipeline M166-M09)
**Fecha:** 2026-10-17 23:34
**Origen:** metodologia V2, RAMA 2 (sin mensajes nuevos del director; tracker en 70, ultimo entrante = 070). Tarea de la COLA ACTIVA: BACKLOG-MASTER seccion A, item 67 "Inventario de assets sin atribucion (BUG-052, 694 glb)".
**Pool:** head medido JUSTO ANTES = 1961 -> reservado 1961 con `scripts/reservar_log.py --reservar --agente Step-5-WorkBuddy --modulo CANAL` (protocolo v3). Evidencia cruda en `.workbuddy-ai/tmp/` (gitignored): `inv_assets.json` = informe `--json` completo del validador.

## 1. Universo medido: 3 perimetros que no hay que confundir

| Perimetro | Fuente | Archivos | Entra en el gate |
|---|---|---|---|
| Gate (res://assets) | scope `game/isla-ancestral/assets` | 722 en alcance | SI (unica ruta de `asset_metadata_scope.json`) |
| Repo versionado | `git ls-files "*.glb"` | 694 .glb | NO (fuera de res://) |
| Disco total | `find` excl. .git | 1388 .glb | NO |

- Desglose de los 694 versionados: **418** en `game/isla-ancestral/assets/3d` (los unicos dentro de res://) + **250** en `tools/mcp` (libreria Blender MCP, primer commit daa028c 2026-09-06) + **16** en `Obsoletos/2026-10-10_01-49-00_glb-respaldos-assets-3d/` (los respaldos que movio el fix de BUG-052) + **10** en `game/Obsoletos` (9e378d6). 418+250+16+10 = 694 y cuadra con la auditoria de Log 1035 (`tools/legal/auditoria_copyright_glb.json`, por_scope: assets 434 = 418 activos + 16 respaldos, tools(blender-mcp) 250, obsoletos 10; CON 0 / SIN 694 / AMBIGUO 0).
- Los 1388 de disco = 694 versionados + 694 de la copia de trabajo `.kilo/worktrees/phase-judge/` (excluida por el scope: `.kilo` esta en `excluir`).

## 2. Estado del gate hoy (medido 23:20-23:34, Python 3.13.12 administrado)

`python tools/legal/validate_asset_metadata.py --check` -> **EXIT 1**. Informe (`--json`):

- archivos en alcance: **722** (= 418 .glb + 300 .png + 4 .ttf)
- magic invalido: **0** (BUG-042 esta resuelto: las 4 .ttf de assets/fonts son fuentes reales de 39-277 KB; el ratchet MAGIC_INVALIDO quedo con 3 lugares libres)
- CON atribucion embebida: **0**
- SIN atribucion embebida: **718** (= 418 .glb + 300 .png)
- entradas de inventario: 54 (incompletas: 0)

Techo (baseline / trinquete):
- SIN_ATRIBUCION `**/assets/3d/**/*.glb`: **aceptados 418 de max 418**, clavado en el techo, 0 holgura: UN .glb nuevo sin copyright rompe el gate.
- MAGIC_INVALIDO `**/assets/fonts/*.ttf`: aceptados 0 de max 3 (holgura ociosa por BUG-042 ya resuelto).

HALLAZGOS NUEVOS: **300**, todos `.png` de `game/isla-ancestral/assets/2d/items_m159/` (ico_*.png, 48x48 RGBA de 8 bits, 226 bytes cada uno; placeholders de la tanda de iconos de M159). Commits que los trajeron: 94c1c7f (tanda 1, 10 iconos), cd7d85c (tanda 2, 20), 13825c6 (registro de tandas), todos del 2026-10-17: POSTERIORES al cierre de BUG-052 del 2026-10-10 (418/418, EXIT 0).

## 3. El hallazgo: el gate legal esta rojo desde el 2026-10-17

- BUG-052 se cerro el 2026-10-10 (mimo-v2.6-flash-free, Log 1575, verificado por atria-dawn): disco 434 -> 418 = techo = conteo, `--check` 418/418 EXIT 0, trinquete max 418 intacto.
- El trabajo de iconos de M159 (deuda L212 "300/300 sin icono", tandas de agnes) commiteo el 2026-10-17 los 300 PNG placeholder SIN copyright embebido. El validador los cuenta como hallazgos nuevos (el baseline solo cubre .glb y .ttf) -> `--check` EXIT 1 hoy, medido.
- CI: el paso `Verify legal gates (M127 iter. 3)` de `.github/workflows/quality.yml:659` corre exactamente `python3 tools/legal/validate_asset_metadata.py --check` sin `|| true`, y Actions corre los `run: |` con `-e` -> **el job no puede estar verde en HEAD**. Es un rojo DISTINTO del ya conocido del job de tests Godot (`scripts/legal/test_licenses_m83.gd:111`, ajeno, ruteado a agnes).
- No es regresion de codigo: es la misma deuda de raiz (exportador sin copyright embebido / sin sidecar) trasladada de .glb a .png. Los 300 PNG entraron por una puerta que el trinquete no cubria.

## 4. Opciones para el director (NO ejecutadas, requieren orden)

- (a) Fix de raiz en el pipeline de exportacion (M166/M09): embedar copyright al exportar. Cierra futuros; no toca los 300 existentes.
- (b) Backfill de los 300 PNG: script que inserte chunk tEXt/iTXt (Copyright/Author) en cada uno + re-run del validador. Verificable byte a byte, pero reescribe 300 binarios commiteados de M159/agnes -> necesita autorizacion explicita con paths.
- (c) Baseline nuevo SIN_ATRIBUCION `**/assets/2d/**/*.png` max 300: apaga el rojo hoy, pero consagra la deuda y regala holgura para 300 iconos futuros sin copyright, contra la filosofia de trinquete declarada en el scope. Ultimo recurso.

Recomendacion: (a) + (b). NO (c). El backfill lo puedo hacer yo con autorizacion.

## 5. Derivas documentales detectadas (reportadas, no tocadas)

- `DOCUMENTACION/11-BUGS.md`: la fila de la tabla (L135) dice BUG-052 RESUELTO 2026-10-10, pero la seccion de detalle (L4481-4486) sigue con "Estado: [ ] Abierto - duenos M166/M09" y titulo "fix del pipeline pendiente". Ademas corresponde registrar la re-apertura parcial por los 300 PNG de M159. Es registro compartido: no edite, lo propongo al director.
- `tools/legal/asset_metadata_scope.json`: la nota del baseline .glb sigue exacta (418 = techo = disco). La de MAGIC_INVALIDO quedo obsoleta (las 3 .ttf placeholder de BUG-042 fueron reemplazadas por fuentes reales); el techo de 3 queda como holgura muerta, no rompe nada.

## 6. Limites de la vuelta

0 commits / 0 push / 0 assets modificados / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot, 11-BUGS.md ni a ningun asset. Solo lectura, medicion y mis artefactos (este log, el mensaje 74 al director, BACKLOG-MASTER, tracker, memorias).
