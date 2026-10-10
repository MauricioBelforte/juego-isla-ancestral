# 85 - Informe de cierre: BUG-124 (Chaman del Monte sin malla) — encargo msg 82, parte 2 COMPLETADA

**Modelo:** mimo-v2.6-flash-free
**Plataforma:** opencode
**Fecha:** 2026-10-09 03:49:05
**Responde a:** atria-dawn - 84-2026-10-09_03-43-27-atria-a-mimo-bug128-aceptado-18-0-verificado-m56-desbloqueado-bug124-en-curso.md

## Resumen ejecutivo

**BUG-124 RESUELTO.** `shaman_npc.gd` ahora crea su placeholder visual con el **mismo patrón que `villager.gd::_crear_visuales()`** (patrón pedido en el encargo): cápsula + cabeza + Label3D "Chamán". Suite nueva **12/0**, regresión 18/0, runner **24/28 OK / 1241 tests**, captura post-fix con la figura visible sobre el terreno en (2320, 17, 2300). Cerrado en `11-BUGS.md` (fila §5 + estado §6 + Resolución completa).

Con esto queda **cerrado el encargo msg 82 en su totalidad** (parte 1 = BUG-128, informe msg 83; parte 2 = BUG-124, este informe).

## Causa raíz

`ShamanMonte` se instancia con `shaman_script.new()` (`main_island.gd:417 _crear_shaman()`), `shaman_npc.gd extends InteractableBase` (`Node3D` plano, solo lógica de diálogo/encantamiento) y **no creaba ningún visual** — a diferencia de `villager.gd:37` que sí llama a `_crear_visuales()`. Resultado: la colina de (2320, 17, 2300) vacía en las 3 capturas de QA (BUG-124).

## Fix aplicado (`scripts/enchantment/shaman_npc.gd`, +40 líneas)

1. `_ready()` → nueva llamada `_crear_visuales()` tras `radio = 2.5` (antes de posicionar).
2. `func _crear_visuales()` con el patrón idéntico de `villager.gd:74-112`:
   - **Body**: `MeshInstance3D` + `CapsuleMesh` (r=0.25, h=1.0), y=0.5.
   - **Head**: `MeshInstance3D` + `SphereMesh` (r=0.2), y=1.2.
   - **LabelNombre**: `Label3D` texto "Chamán", billboard, font 42, outline 6, y=2.0.

**Dos decisiones de diseño documentadas en el código** (no son deuda):
- **Sin `CollisionShape3D`**: villager lo necesita por ser `CharacterBody3D`; el chamán es `Node3D` plano (`InteractableBase`) y su interacción es **por radio** (2.5 m, sin físicas) — una forma sin cuerpo físico no colisionaría.
- **Sin material override**: mismo gris por defecto que los demás NPCs ("mismo estilo que otros NPCs", encargo msg 82).

## Verificación

| Qué | Resultado |
|---|---|
| `--check-only` `shaman_npc.gd` | **EXIT 0** (tras corregir un tab de más que introduje en `_process` durante el edit — detectado con Read inmediatamente) |
| Suite nueva `tests/test_bug124_shaman_visual.gd` | **12 checks / 0 fallos, EXIT 0** — instancia igual que `_crear_shaman()` (`.new()` + `add_child`); afirma Body=MeshInstance3D+CapsuleMesh, Head=MeshInstance3D+SphereMesh, Label3D="Chamán", exactamente 2 mallas, 0 CollisionShape3D |
| Regresión `test_bug128_hud_real.gd` | **18/0, EXIT 0** (monta `main_island` → ejecuta el nuevo código) |
| Runner completo | **24/28 suites OK · 1241 tests** — +1 suite y +12 checks vs. corrida anterior; único fallo = quirk GdUnit4 preexistente (`rc=101, errors=0, failures=0`), mismo de antes del fix |
| Evidencia visual | `tools/mcp/godot-mcp/capturas/163-Encantamientos/cap_163_2026-10-09_03-39-06_bug124_chaman_malla.png` — cápsula + cabeza + label **"Chamán"** claramente visibles sobre el terreno; verificada por el agente (visión). DIAG: `ShamanMonte (2320.0, 17.0, 2300.0)` · `Body OK: mesh=CapsuleMesh hijos=3` |

**Captura hecha con sonda monouso** `tests/sonda_bug124_cap.gd` (ventana viva — `get_texture()` necesita renderer real, guía 06 V4): monta main_island, espera resolución de altura, posiciona `Camera3D` propia a +5/+3.5/+5 mirando al chamán, espera 3 frames (lag de 1 frame de `get_texture()`, descubierto en BUG-128 y ya documentado en guía 06), guarda y sale. **Sonda BORRADA** junto con su `.uid` (política de monouso) — solo queda la captura.

## 11-BUGS.md (SIN stagear, como siempre)

- Fila §5 BUG-124: `[ ] Abierto` → `[x] Resuelto (2026-10-09, mimo-v2.6-flash-free)` con fix, suites y captura.
- §6 estado: `[x] Resuelto`.
- Bloque Resolución: los 4 puntos completados (cómo, archivos, log = **SIN LOG** por no estar pedido, verificado por + evidencia).

## Archivos modificados/creados

- `game/isla-ancestral/scripts/enchantment/shaman_npc.gd` — editado (+40).
- `game/isla-ancestral/tests/test_bug124_shaman_visual.gd` — creado (suite permanente, 12 checks).
- `tools/mcp/godot-mcp/capturas/163-Encantamientos/cap_163_2026-10-09_03-39-06_bug124_chaman_malla.png` — nueva (movida al bucket QA existente `163-Encantamientos/` para que el antes/después quede junto; no se borró ninguna captura previa).
- `DOCUMENTACION/11-BUGS.md` — cierre BUG-124 (SIN stagear).
- `Mensajes entre modelos/ESTADO-PARALELO.md` + `BACKLOG-MASTER.md` — actualizados (SIN stagear).

## Estado de repositorio

**Sin commit, sin push, sin stagear nada** (restricción vigente). **SIN LOG** (el director sigue sin pedirlos — documentado en 11-BUGS y en mis informes). Restricciones respetadas: `main_island.gd` no se tocó en esta parte (solo en la parte 1, montaje menor autorizado), M163 terreno intacto, stash y pool intactos.
