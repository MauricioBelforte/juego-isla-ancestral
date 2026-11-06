# BACKLOG-MASTER — Nemotron-3.5-Super-VL (ÍNDICE)

**Mantenido por:** agnes-3-flash (Sapiens AI) / Kilo Code — DIRECTORA
**Estructura:** 5nov 00:38 (fundador: reducir tamaño, dividir en archivos temáticos)
**Modelo:** Nemotron-3.5-Super-VL (NVIDIA)
**Plataforma:** Kilo Code
**Nicho:** Boot headless / QA visual / doc intelligence / investigación
**Rol:** COLABORADOR PERMANENTE (boot/doc, 10min cron). Decisiones conjuntas con agnes.

## ESTRUCTURA

Nemotron trabaja por **RIELES** (archivos separados `RIEL-*.md` en su carpeta). Este índice lo mantiene.

| Archivo | Contenido | Estado |
|---------|-----------|--------|
| `00-Backlog-Original-PreSplit.md` | BACKLOG-MASTER original (133 líneas, pre-split 5nov) | Archivo |
| `RIEL-G2-GATE2-SONDAS-MICRO.md` | G2: 6 items gate-2 micro-sondas | [x] Agotado |
| `RIEL-G1-GODOT-MCP-VISION-ACTIVA.md` | B-1: 36 items QA visual godot-mcp | [x] Agotado |
| `RIEL-V1-VISION-CAPTURAS.md` | B-2: 88 items capturas históricas | [x] Agotado |
| `RIEL-W1-WEB-RESEARCH.md` | B-3: 12 items web research | [x] Agotado |
| `RIEL-D1-DOC-INTELLIGENCE.md` | B-4: 15 items doc drift/censo | [x] Agotado |
| `RIEL-I1-INVESTIGACION.md` | B-5: 20 items investigación + fuel | [x] Agotado |
| `RIEL-G3-A1-WORKOUT-BOOT-HEADLESS.md` | G3: 6 items boot headless + event bus | [x] Agotado |
| `RIEL-DRIFT-CHECKLIST-GLOBAL.md` | DR: 10 items drift GLOBAL | [x] Agotado |
| `RIEL-POSTFLIP-QA-VISUAL.md` | PF: 12 items postflip visual | [x/ ?] |
| `RIEL-B-13-M75-POSTGAME-BOOT.md` | B-13: M75 boot | [x] |
| `RIEL-B-14-M73-COLECCIONABLES-BOOT.md` | B-14: M73 boot | [x] |
| `RIEL-B-15-M67-VEHICULOS-BOOT.md` | B-15: M67 boot + assets | [x] |
| `RIEL-B-16-M87-I18N-VISUAL.md` | B-16: M87 i18n visual | [x] |
| `RIEL-B-18-BUG153-BOOT.md` | B-18: 10 módulos BUG-153 boot | [x/ ?] |

## PENDIENTES VIVOS

- [ ] B-12-03: M64 IA NPC (cuando MiMo libere)
- [ ] B-12-04: M17 Construccion (cuando DeepSeek libere)
- [ ] B-12-05: M37 Museos (cuando kimi libere)
- [ ] B-12-06: M129 Merchandising (cuando agnes libere)
- [ ] B-17: M129 boot pre-check
- B-19: 4 vehículos M157 → **DELEGADO A HY4** (Blender)

## NUEVOS RIELES (creados 2026-11-06 por Nemotron-3.5-Super-VL — solo tareas apropiadas para Nemotron según GUIA-COMPARATIVA-MODELOS-V1.md)

- [x] **RIEL-INVESTIGACION-UI-MENUS.md** — Investigar por qué botones del menú principal no responden a teclado ni clic, y menús que se repiten/solapan. Bloquea B-9 y B-10. H1-H5 completados: causa raíz identificada (capas UI compiten por layer=100; HUD con mouse_filter=STOP intercepta clicks).
- [x] **RIEL-QA-VISUAL-ADICIONAL.md** — QA visual adicional de 15 módulos (M55, M60, M48, M151, M75, M73, M67, M87, M34, M156, M106, M117, M160, M69, M50) usando Godot-MCP + capturas + send_keys. **15/15 completados.**
- [ ] **RIEL-QA-VISUAL-PROFUNDA.md** — QA visual profunda de 15 ítems usando visión nativa por API de Nemotron (Intelligence Index 26, texto+imagen). Módulos: M55, M87, M34, M156, M106, M117, M160, M69, M50, M73. 9/15 completados (01, 02, 03, 04, 05, 06, 07, 08, 09).
- [ ] **RIEL-DOC-INTELLIGENCE-3.md** — Document Intelligence profundo de 44 ítems: auditoría completa de DOCUMENTACION/, consistencia de checklists, drift, referencias rotas, firmas, QA cruzado. 42/44 completados (01-42).

## REGLAS

- Produce-first comprobable; output = REPORTE en canal + capturas.
- Citas textuales o nada. NO tocar módulos 🔵/🔴.
- Ítem no resuelto = `[?]` + razón. Sin push/commits. UTF-8.

---

**Firma:** agnes-3-flash (Sapiens AI) / Kilo Code — 2026-11-05 00:38
