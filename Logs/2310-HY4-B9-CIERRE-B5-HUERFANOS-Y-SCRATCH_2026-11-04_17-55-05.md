# Log 2310: Cierre de B5 (reauditoria de huerfanos Blender + relocalizacion de scratch)

**Fecha:** 2026-11-04
**Hora:** 17:55:05
**Modelo:** Hy4 preview (Tencent Hunyuan)
**Plataforma:** WorkBuddy
**Canal:** `Mensajes entre modelos/HY4/` (mensaje 02)
**Reserva:** protocolo v3, `reservar_log.py --reservar --agente HY4 --modulo B5`
**Rol:** parcheo de huecos / auditoria de tooling. No sella, no hace QA 21.8.
**Encuadre:** fundador, "si segui con eso el B5" (chat 2026-11-04 17:23).

---

## 0. Estado medido al arrancar

- HEAD al reservar log: `c50932e`. Entre B8 (`9485c8c`) y la reserva entro el
  commit ajeno `Preservacion 4nov 17:27` (saneo de pools + DS-OC). Verificado:
  `git diff --name-only 9485c8c..HEAD` no toca ningun path de B5.
- `crear_*.py` en el repo: **127** (126 en `tools/`, 1 en `game/`).
- `.py` dentro de `game/`: **65** (57 versionados + 8 ignorados por los
  patrones `fix_*.py` / `gen_*.py` de `.gitignore`). El Log 1190 media 42 el
  2-oct: crecieron **23** en un mes.
- Referencias: escaneo sobre **19870** archivos versionados (incluidos `.gd`,
  `Logs/` y `Mensajes entre modelos/`). 24 de los 65 tienen referencia;
  41 no tienen ninguna.
- Pool de logs: 691 libres, primero 2310. Consumido 2310. Pool NO commiteado.
- Canal HY4: 1 mensaje previo (`01`). Consumido el numero **02**.

## 1. Reauditoria: 0 huerfanos reales

El Log 1190 declaro "2 huerfanos reales" con un detector que buscaba solo
`.blend` en la raiz del modulo. Ambos eran falsos positivos:

1. `tools/mcp/blender-mcp/scripts-reutilizables/crear_jugador_voxel.py`
   declara `RUTA_SALIDA` y `export_format="GLB"`. Exporta GLB directo, sin
   generar `.blend`. Su salida
   `game/isla-ancestral/assets/3d/media/45-Arte3D_jugador_voxel.glb`
   existe, pesa 25104 B y esta versionada (blob `c1defbc4...`).
2. `tools/mcp/blender-mcp/50-Vegetacion/scripts/crear_hierba_alta_lowpoly.py`
   no esta en la raiz de `50-Vegetacion/` sino en su subcarpeta `scripts/`
   (versionado, blob `3c152bf6...`). Produce
   `hierba_alta_lowpoly.blend`, `_baja`, `_media`, 3 GLB en
   `game/isla-ancestral/assets/3d/{alta,media,baja}/` y la ficha
   `game/isla-ancestral/assets/fichas/50-Vegetacion_hierba_alta.md`
   (versionada, blob `d4947657...`).

Conclusion: **no hay que generar ningun asset**. El MCP de Blender caido ya no
bloquea el item. Leccion registrada con nombre descriptivo (ver seccion 5):
"detector de un solo formato de salida". La asercion de cierre debe ser
POSITIVA (el artefacto existe), no solo "no encontre .blend".

## 2. Clasificacion de los 65 .py

| Clase | Cantidad |
|---|---|
| Scripts Blender (`import bpy`) | 29 |
| Generadores / flips de un solo uso | 28 |
| Otros (herramientas M100/M88/M39, validadores, debug) | 8 |
| Con referencias versionadas | 24 |
| Sin ninguna referencia | 41 |

Exclusion deliberada: `game/isla-ancestral/tools/validate_dialogues.py` no es
citado por ningun archivo, pero resuelve `data/dialogues` mediante
`os.path.dirname(__file__)`. Moverlo romperia el validador. Lecciones:
"sin referencias NO significa relocalizable". Tambien quedo fuera
`font_subsetter.py`, citado desde
`game/isla-ancestral/scripts/fonts/test_fuentes_optimizadas_m88.gd`.

## 3. Relocalizacion (22 archivos, nunca borrado)

Seleccion: 17 `scripts/saving/_*.py`, `scripts/fasttravel/_flips_t9.py`,
`scripts/crafting/_parche_test_m16.py`, `scripts/expandir_hitos.py`,
`scripts/debug_imposibles.py`, `scripts/debug_stats_validos.py`.

Criterio verificado ANTES de mover, para cada uno:
- existe y esta versionado (`git ls-files --error-unmatch`);
- sin cambios ajenos en el worktree (`git diff --quiet`);
- 0 referencias en los 19870 archivos versionados;
- de un solo uso, con rutas absolutas de esta maquina o flips de checklist;
- destino NO ignorado (`git check-ignore -q` = distinto de 0).

Destino: `Obsoletos/scratch-hy4-b5-2026-11-04/` + `MANIFIESTO.md` con origen,
destino, sha256, bytes y mtime de cada archivo. Se uso `git mv` (22/22) y se
verifico **sha256 identico antes/despues en los 22**. Resultado: 65 -> **43**
`.py` dentro de `game/`.

NO se uso `Obsoletos/raiz-temporales-*/`: `.gitignore:246` lo ignora y el
propio comentario dice "se conserva en disco, no en el historial". Mover 22
archivos VERSIONADOS ahi los habria sacado del repo. El destino elegido esta
verificado como versionable (hay 425 archivos versionados bajo `Obsoletos/`).

Quedan sin mover: 29 scripts de autoria Blender (territorio M36/M50; 13 citados
en documentacion), los generadores M162, las herramientas M100/M88/M39 y los
validadores vivos. Mover los 29 en bloque exige actualizar 13 rutas citadas:
queda a decision de sus duenos, no se hizo unilateralmente.

## 4. Guardia nueva: scripts/auditar_scratch_game.py

- `--check`: congela el inventario MEDIDO de 43 `.py` bajo `game/`; cualquier
  `.py` nuevo da rojo. Ademas exige las 8 evidencias POSITIVAS de los
  ex-huerfanos (scripts, blends, GLB, ficha, declaracion de export GLB).
  Resultado real: `43 / baseline 43 / nuevos 0 / faltantes 0`, **exit 0**.
- `--self-test`: end-to-end por ruta real sobre repositorios temporales.
  **13 checks / 0 fallos**, `CHECKS_MINIMOS=13` MEDIDO en verde (no estimado).
  Guardia de alcanzabilidad: si un bloque no se llamo -> CIEGO exit 3.
  Guardia de ceguera: arbol sin `.py` -> exit 3, nunca verde heredado.
- ROJO POR INYECCION (4 mutaciones sobre copias temporales):
  1. detector que nunca marca nuevos -> 3 FAIL, exit 1;
  2. bloque S4 no llamado -> CIEGO, exit 3;
  3. evidencias positivas hardcodeadas en True -> falla el control negativo S6,
     exit 1;
  4. guardia CIEGO removida -> falla S3, exit 1.
  Control sin mutar -> exit 0. Los cinco resultados salieron como se esperaba.

Causa raiz: B5 habia tratado el sintoma (contar 42 scripts). Sin guardia, cada
vuelta de la flota deja scratch nuevo y la limpieza se deshace sola.

## 5. Correccion de un error propio (B8)

En B8 etiquete una trampa como "64". Ese numero YA estaba usado por otros
agentes para "logs untracked" (Log 952, Log 975, memoria 2026-09-16).
Corregi la etiqueta en el backlog HY4 a "B8, sin numero" y desde B9 uso
nombres descriptivos para no sumar colisiones a las 12 heredadas.

Nombres adoptados en B9:
- "detector de un solo formato de salida" (seccion 1);
- "sin referencias != relocalizable" (seccion 2);
- "archivo versionado a carpeta ignorada" (seccion 3).

## 6. Cierre documental

- Backlog HY4: seccion B5 reauditada, pendientes actualizados, seccion B9.
- Canal HY4: mensaje `02-2026-11-04_17-55-05-...-informe-b5-cerrado.md` con
  cabecera `Responde a:` (REGLA CERO). Se nombra `02-` y no `002-` (sugerido
  por el helper) para conservar el orden lexicografico con el `01-` del hilo;
  `proximo_numero.py` parsea `^(\d{1,3})-` y sigue devolviendo el numero bien.
- `MANIFIESTO.md` del archivo relocalizado.
- Log 2310: ASCII puro + CRLF + sin BOM.

## 7. Lo que NO hice

No genere assets (MCP caido y ya no hacen falta). No movi los duplicados de
M18-BIS (MiMo) ni toque M19. No hice flips de marcas ajenas, QA 21.8, sellos
ni aprobacion visual. No toque `CHECKLIST-GLOBAL.md`, `quality.yml`,
`AGENTS.md`, `project.godot` ni `05-Checklist.md` ajenos. No hice push, no use
`git add -A`, no use `--amend`. Las entradas ajenas del worktree
(Hy3/DS-OC/pool de logs/Temp) quedaron intactas.

## 8. Peticiones abiertas a la directora

1. `quality.yml` esta protegido: las dos suites (`test_verificar_bom.py` y
   `auditar_scratch_game.py --self-test`) existen y pasan, pero CI no las
   ejecuta. Autorizar su alta en `encoding-guard`.
2. Decision de los duenos M36/M50 sobre los 29 scripts de autoria Blender.
3. Discrepancia ya reportada: `AGENTS.md 31` nombra director a
   `GLM-5.3 Flash-Director`, pero quien firma y da ordenes es
   `agnes-3-flash (directora)`. Reporto a quien escribe.

---

**Firma:** Hy4 preview / WorkBuddy - 2026-11-04 17:55:05
