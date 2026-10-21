# Log 2062 - M76: items 4/10 del Bloque W (captura del inventario con tema dark) EJECUTADOS

**Agente:** Step-5-WorkBuddy | **Modulo:** M76 | **Fecha:** 2026-10-21 02:25 (GMT-3)
**Ciclo:** V2 - RAMA 1 (msg 128 del director) + RAMA 2 (BACKLOG Bloque W items 4/10)

## 1. Contexto

- RAMA 1: unico mensaje nuevo = **128** del director (acuse de mi 127: item 59 dead-links
  preservado y visible en el commit de la ronda del Cron C; "segui RAMA 2"). Acusado con mi
  msg **129**. Tracker 127 -> 128. Pool del canal: 129 consumido, reeexpandido a 130..229
  (100 numeros consecutivos verificados); head del pool = ultimo+1, sin huecos.
- RAMA 2: items 4 y 10 del Bloque W del BACKLOG-MASTER = "captura V2 del inventario B larga
  con el tema dark (la verificacion visual propia)" / "captura del inventario con el tema dark".

## 2. Hallazgo de partida: el STALE del 2026-10-17 quedo desactualizado

- En Log 1946 (2026-10-17) los items 4/10 se marcaron STALE: M76 cerrado y sellado
  (b465697), su 05-Checklist no tenia items de captura y no existia carpeta capturas/.
- **Medido HOY 2026-10-21 (no se hereda el verde):**
  - M76 plan-actual/05-Checklist.md = **126 [x] / 4 [ ] = 130** (CRLF 221/0 LF, sin BOM);
    0 coincidencias de `captura|inventario B|tema dark|dark` (regex insensible).
  - M76 plan-inicial/05-Checklist.md = 130 [ ] (LF puro).
  - CHECKLIST-GLOBAL.md fila 76 = 126/130 "Con dudas" - **coincide con disco**, sin drift.
  - `tools/mcp/godot-mcp/capturas/` = 57 carpetas, **0 para 76**.
  - **PERO el tema dark SI existe en codigo desde 2026-10-18**: `scripts/ui/theme/theme_ux.gd`
    L13 dice "Contraste WCAG AA verificado por test_m53_wcag.gd (tema dark desde 2026-10-18)"
    y L4 la paleta "cozy dark (D102)". El barrido de `tema dark` en DOCUMENTACION/ solo
    devuelve mi BACKLOG-MASTER (no hay doc del tema, pero si codigo cerrado y verificado).
  - Conclusion: el item dejo de ser fantasma el 2026-10-18, un dia DESPUES del STALE.
    La tarea es **ejecutable**: el patron de preview determinista de M53 D102b
    (`preview_paneles_m53.{gd,tscn}`) monta el UIRoot real y abre una capa por UIManager.

## 3. Trabajo ejecutado

- Creados (temporales, se borran al cerrar la verificacion, patron M53 D102b):
  - `game/isla-ancestral/scripts/ui/preview_inventario_s5.gd` (451 -> 108 lineas de prueba)
  - `game/isla-ancestral/scripts/ui/preview_inventario_s5.tscn`
  Montan el UIRoot real (ThemeService aplica ThemeUx.build(), tema dark), pueblan el
  bolsillo via `Inventario.add_item()` y abren InventoryLayer con `toggle()`.
- **Verificacion previa headless** (binario real, `--headless --path game/isla-ancestral`):
  32 items agregados, bolsillo **24/24 slots**, capa visible=true, grid 24 slots,
  EXIT 0, **0 SCRIPT ERROR**. La captura fallo con mensaje explicito
  ("viewport sin textura (headless?)") en vez de crashear: guardia anti-falso-verde.
- **Run con ventana (directiva 094, libertad de runs del fundador)**:
  2 capturas 1152x648, `save_png` err=0, EXIT 0, 0 SCRIPT ERROR, cierre solo del juego.
- **Trampa propia detectada y corregida:** la 1ra version poblaba el bolsillo empezando por
  Mobiliario, asi que las 24 ranuras eran todo mobiliario y la 2da captura (filtro pestana
  Mobiliario) salia **byte identica** a la 1ra (mismo sha256 b68ac610...). Un filtro que
  "no cambia nada" puede ser un bug del script de prueba o un universo de una sola categoria:
  hay que medir el hash, no mirar. Corregido repartiendo 2 items por categoria: hashes
  2a47ec85 (lista larga) y 853f3b11 (pestania) ahora son distintos.

## 4. Verificacion visual propia (mire las 2 capturas)

- `cap_76_2026-10-21_02-21-30_inventario_dark_lista_larga.png` (54.050 B): panel navy oscuro
  con borde oro, titulo "Inventario" cream, "Slots: 24/24", 16 pestanas de categoria,
  buscador, "Ordenar Favoritos+ID + Aplicar", 24 slots con nombre y cantidad, pie
  "Click en un objeto para marcar/desmarcar favorito. Esc para cerrar." y boton Descartar
  atenuado (correcto: ningun slot seleccionado). Lista larga REAL.
- `cap_76_2026-10-21_02-23-30_inventario_dark_pestania_mobiliario.png` (33.743 B): filtro
  Mobiliario aplicado -> "Slots: 3/24" y solo mobiliario visible. El filtro funciona.
- Contrastes cream sobre navy: legibles, coherentes con el contrato D102 (la suite
  test_m53_wcag quedo 17/0 el 2026-10-18, no reejecutada hoy).
- Observacion menor de CONTENIDO (no del tema): nombres de item sin tilde
  ("Herramienta Basica", "Baye Roja" ok) -> datos de M159/M53, no del tema.

## 5. Artefactos

- Log 2062 (ASCII puro por bytes, CRLF, sin BOM; head medido JUSTO antes = 2062 -> pool 2063).
- msg 129 (UTF-8 sin BOM, LF) en Mensajes entre modelos/Step-5-WorkBuddy/.
- 2 capturas en tools/mcp/godot-mcp/capturas/76-Multijugador/ (hash verificado contra el
  user:// de origen).
- BACKLOG-MASTER: items 4/10 documentados con la ejecucion + items 5/8 verificados.

## 6. Limites y pendientes

- 0 commits / 0 push / 0 auto-sellos 21.8 / 0 ediciones a CHECKLIST-GLOBAL.md, quality.yml,
  AGENTS.md, project.godot ni 05-Checklist ajenos. Los 2 archivos .gd/.tscn son NUEVOS
  (preview temporal), no tocan logica de produccion.
- Pendiente director: (a) decision sobre items 4/10 - propongo cerrarlos como EJECUTADOS
  (evidencia en disco) y no como STALE; (b) autorizacion de commit acumulada (8 paths del
  2026-10-20 + los 6 de esta tanda); (c) reposicion de cola: la seccion A quedo con estos
  2 unicos pendientes, ya resueltos -> COLA VACIA salvo Bloque W item 9 (necesita commit
  autorizado).
