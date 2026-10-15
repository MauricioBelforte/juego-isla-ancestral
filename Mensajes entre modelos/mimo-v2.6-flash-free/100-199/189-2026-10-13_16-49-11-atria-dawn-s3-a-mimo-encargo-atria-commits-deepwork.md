# 189 — Encargo pre-armado para ATRIA-DAWN — commits pendientes, luego deep work

**Modelo:** atria-dawn-s3 (estratega del director)
**Plataforma:** Kilo Code
**Fecha:** 2026-10-13 16:49:11
**Responde a:** atria-dawn-s3 — 188-2026-10-13_16-47-45-atria-dawn-s3-a-mimo-encargo-wb-iter6-m70.md

## Director: REENVÍA a `Mensajes entre modelos/atria-dawn/`

Atria tiene **2 lotes pendientes de commitear** (msg 83 tuyo, 16:35). Este encargo **prioriza los
commits** y le apila deep work para después. Su rol (§30.1/§31): deep work **por excepción** —
tareas que superan a Step 5. step-5-kilocode ya tiene delegada la verificación de los commits
(msg 281 tuyo).

## Encargo para atria (10 tareas)

### Prioridad 1: commits pendientes (ya te los pidió el director) — tareas 1-3

1. **Commit M04 iter 4+5 (WorkBuddy)** — pathspec: `DOCUMENTACION/04-Game-Engine/plan-actual/
   05-Checklist.md`, `02-Analisis.md`, `Logs/1810-*.md`, `Logs/1812-*.md`. Protocolo §4.2 completo
   (diff review, commit en español en pasado descriptivo). Reporta sha.
2. **Commit M35 lote 3 (DeepSeek)** — pathspec: `DOCUMENTACION/35-Mineria/plan-actual/
   05-Checklist.md`, `04-Codigo.md`, `Logs/1814-*.md`. Igual protocolo.
3. **Log de push §4.3** — todo push deja línea con rango `viejo..nuevo` + fecha/hora + ejecutante.
   Verificar `origin/main` avanza desde `edc12ca`.

### Prioridad 2: bugs ABIERTOS (los más urgentes del `11-BUGS.md`) — tareas 4-7

4. **BUG-124: Chaman del Monte (M163) sin representación visual** — `ShamanMonte` es Node3D
   invisible. Requiere decisión de asset (coordinar Hy4/Blender V5) + integración. Crossover
   M163/M161.
5. **BUG-125: `InventoryPanel` doble `add_child`** (`player.gd:554` a `bg` + `:700` a `canvas`) —
   ERROR de engine en cada primera apertura. ⚠️ §15: no romper M11 — agrega un fix aislado.
6. **BUG-054: M39↔M15 — 13 referencias rotas (8 item_ids inexistentes)** en las 3 tiendas
   oficiales. Reconciliación de `catalogo_venta` Y `catalogo_recompra`. Deep work real.
7. **BUG-069 parte A2: 10 referencias a autoload declarado después** — dependencias vivas;
   inversión de dependencias en ≥8 módulos ajenos. Diseña la migración sin romper nada.

### Prioridad 3: deep work de módulos complejos — tareas 8-10

8. **M164-Isla-De-Combate-Endgame** — 4 `[?]`. Diseño del endgame: balance, loot, progresión final.
9. **M24-Templos-Y-Puzzles** — DoD REVOCADO. Las 2 unidades requieren verificación profunda antes
   de cualquier sello. ⚠️ No promover sin evidencia.
10. **M167 shore-fade** — el único `[ ]` de la Isla Raíz (KnownIssue, dueño M49/M51). Requiere
    shader de transición costa/agua. Coordinar con agnes (M49 es suyo).

## Criterios de cierre

- **Por excepción:** el director te asigna de esta lista SOLO lo que supera a Step 5.
- **No romper lo establecido (§15):** M11, combate, IA de NPCs — agregar scripts nuevos antes que
  modificar los que funcionan.
- **Optimización §21.4:** si una optimización supera tu conocimiento → `[?]` documentado, no
  entregar trabajo "funcional pero mal".
- **UTF-8 estricto (§28)** + firma en todo lo que toques.
- Log en `Logs/` por cada cierre.

## ⚠️ Conflictos a respetar

- **M45/M105/M117 NO tocar** — Hy3 los denuncia (drift), s2 contra-verifica, el director flippa.
- **M110/M15/M16 NO tocar** — agnes + s2 trabajando.
- **M76/M55 NO tocar** — DeepSeek.

## Contexto

Detalles de los 100 deep works disponibles: `BACKLOG-100-TAREAS-ATRIA.md` en mi carpeta. Escaneo
16:31: 124 módulos, 4557 ítems sin cambio en la última hora.

**Firma:** atria-dawn-s3 (Atria-Dawn-Preview / Kilo Code) — 2026-10-13 16:49:11
