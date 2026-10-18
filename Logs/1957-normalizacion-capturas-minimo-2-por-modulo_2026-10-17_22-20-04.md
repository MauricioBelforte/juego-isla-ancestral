# Log 1957 - Normalizacion de capturas/ (minimo 2 por modulo, item 66 Bloque D)

**Agente:** Step-5-WorkBuddy
**Modulo:** CANAL (barrido de repositorio, sin modulo unico)
**Fecha:** 2026-10-17 22:20
**Origen:** metodologia V2, RAMA 2 (sin mensajes nuevos del director; tracker en 70). Tarea de la COLA ACTIVA: BACKLOG-MASTER seccion A, item 66 "Normalizacion de la carpeta capturas/ (minimo 2 por modulo)".
**Pool:** head medido JUSTO ANTES = 1957 -> reservado 1957 (protocolo v3). Script de analisis y snapshots en `.workbuddy-ai/tmp/` (zona gitignored): `normalizar_capturas.py`, `capturas_antes.json`, `capturas_despues.json`.

## 1. Universo real medido (la convencion manda: AGENTS.md sec. 1231-1240)

- La carpeta canonica NO es `DOCUMENTACION/*/capturas/` (existe UNA sola, `04-Game-Engine/capturas`, con 2 archivos, anterior a la convencion). La convencion vigente es `tools/mcp/godot-mcp/capturas/{ID-Modulo}-Nombre/`.
- Ademas: **las capturas NO se versionan en git** (`.gitignore:104` = `**/capturas/`) -> la normalizacion no toca el repo commiteado; no hace falta commit ni push.
- Estado ANTES: 41 carpetas + 37 archivos sueltos en la raiz = **407 archivos**, 7 carpetas con numero pelado (`9/`, `09/`, `19/`, `45/`, `47/`, `50/`, `51/`), 5 carpetas con sufijo no canonico, 2 carpetas duplicadas de mismo ID, 4 carpetas que en realidad eran ARCHIVOS (dirs bogus) y 1 carpeta vacia.

## 2. Reparaciones de estructura (5 dirs bogus, 0 archivos perdidos)

Un bug repetido: un archivo de captura quedo como DIRECTORIO con el .webp/adentro (parece un `mkdir` o un move mal cerrado). Verificado 1 archivo interno en cada uno; resto restaurado como archivo con el nombre que correspondia:

| Ruta | Antes | Despues |
|---|---|---|
| `12-Camara/cap_12_camera_follow.webp/` | dir con `20260826-222518-window-isla-ancestral-debug.webp` (17.248 B) adentro | archivo `cap_12_camera_follow.webp` |
| `09-Terreno-Y-Geografia/cap_09_Aurora.webp/` | dir con 1 archivo adentro | archivo |
| `09-Terreno-Y-Geografia/cap_09_Aurora_biomas.webp/` | dir con 1 archivo adentro | archivo |
| `09-Terreno-Y-Geografia/cap_09_Aurora_playa.webp/` | dir con 1 archivo adentro | archivo |
| `09-Terreno-Y-Geografia/cap_09_Aurora_playa2.webp/` | dir con 1 archivo adentro | archivo |

`find . -mindepth 2 -type d` = 0 tras la reparacion. Total recursivo ANTES = 407, DESPUES = 407 (snapshots comparados por nombre: 0 perdidos, 0 nuevos).

## 3. Merges y renombres ejecutados (solo mover/renombrar; NUNCA borrar)

- MERGE `9/` (67) + `09/` (1) -> `09-Terreno-Y-Geografia/` (1+4 reparados = **73**)
- MERGE `50/` (12) -> `50-Vegetacion/` (4 -> **16**)
- MERGE `49/` (17) -> `49-Iluminacion/` (7 -> **24**)
- MERGE `51/` (21) -> nueva `51-Agua/`
- MERGE `155-Vestimenta/` (1) -> `155-Vestimenta-Y-Accesorios/` (10 -> **11**)
- MERGE `19/` (1) -> nueva `19-NPC-Y-Vecinos/`; `45/` (3) -> nueva `45-Arte-3D/`; `47/` (3) -> nueva `47-Texturas-Y-Materiales/`
- RENAME `10-Mundo-Voxel/` -> `10-Generacion-Del-Mundo/` (22)
- RENAME `37-Museo/` -> `37-Museos-Y-Colecciones/` (3)
- RENAME `163-Encantamientos/` -> `163-Sistema-De-Encantamientos/` (5)
- RENAME `105-Agua-Blanca/` -> `105-Telemetria-De-Gameplay/` (5) - los 5 archivos son `cap_105_*` de debug de agua/costa (specular, distancia, espuma); "Agua Blanca" no existe como modulo ni aparece en DOCUMENTACION (grep = 0)
- RENAME `01-Jugador/` -> `01-Fundamentos-Del-Proyecto/` (18) - los 18 archivos son `cap_01_*` de 2026-08-26 (arranque)
- 22 archivos sueltos de la raiz mudados a su carpeta por prefijo `cap_<NN>_`: 15-Recursos (2), 16-Crafting (2), 33-Agricultura (7), 34-Pesca (1), 40-Infraestructura (1), 53-UI-UX (+9 -> 25), 110-Debug-Menu (+1 -> 3)

## 4. Cobertura final (minimo 2 por modulo)

- 169 modulos canonicos (dirs de DOCUMENTACION). **37 tienen carpeta de capturas**; de esos, **29 cumplen el minimo de 2** y **8 tienen solo 1** (deuda): 108-Pipeline-De-Assets, 12-Camara, 154-Vision-Del-Agente, 19-NPC-Y-Vecinos, 34-Pesca, 40-Infraestructura, 88-Fuentes-Tipograficas (+ 52-QA-WEB, ver abajo).
- **132 modulos no tienen carpeta**. La mayor parte no es visual (06-Control-De-Versiones, 100-Community-Management, 102-Bug-Tracking, 106-Seguridad, 107-Backups, 111-Codigo-De-Calidad, 112-Testing, legal, marketing, gestion...) y no aplica captura. Pero SI son visuales y estan en 0: 11-Personaje-Del-Jugador, 57-Interfaz-De-Control, 58-Accesibilidad, 89-Diseno-De-Menus, 146-Diseno-Emocional, 147-World-Building, 150-Diseno-Sonoro (audio: N/A), 151-Control-Final, 156-Terrenos-Y-Movimiento, 158-Desbloqueos, 160-Ubicaciones, 164-Combate-Endgame, 166-Variantes (166 si tiene 4 en `tools/` fuera de capturas/), 168-Plantilla - deuda de captura real, no resuelta aca (no se pueden generar capturas sin corrida visual).
- top 5: 09-Terreno-Y-Geografia 73, 25-Ruinas 64, 53-UI-UX 25, 49-Iluminacion 24, 10-Generacion-Del-Mundo 22.

## 5. Pendientes para decision del director (NO tocados, ambiguos)

- 4 carpetas con nombre no canonico y 1 archivo c/u: `19-Muelle/` (`cap_19M-AntorchaPared...`; no existe modulo Muelle, "M" seria un area), `52-QA-WEB/` (`cap_web_52...polen-web`; QA del build web de M52), `QA-M51-M31-M19/` (`cap_QA_2026-09-19`), `gameplay/` (`cap_gameplay-fps60`).
- 15 archivos sueltos en la raiz: 13 `cap_diag_*`/`cap_fix_*`/`cap_tienda_*` (dialogos/tienda: ambiguos entre 21-Dialogos y 162-Dialogos-Contextuales-De-NPCs - NO asignados a ciegas) + `prueba-agnes-2026-09-05_17-15.png` y `prueba_vision_workbuddy.png` (sin modulo).
- `DOCUMENTACION/04-Game-Engine/capturas/` (2 archivos, previa a la convencion): migrar a `tools/mcp/godot-mcp/capturas/04-Game-Engine/` o dejar como historico.
- Los 8 modulos con 1 captura y los visuales con 0: deuda de captura, necesita corrida con el juego.

## 6. Limites

0 archivos borrados (solo mover/renombrar; verificacion por snapshots). 0 commits / 0 push (la carpeta es gitignored). 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml, AGENTS.md, project.godot, ni a modulos ajenos. 0 flips / 0 auto-sellos 21.8.
