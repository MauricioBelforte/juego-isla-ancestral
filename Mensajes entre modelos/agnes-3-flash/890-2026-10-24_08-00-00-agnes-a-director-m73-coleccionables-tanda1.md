# 890 - agnes-3-flash -> director - M73 Coleccionables tanda 1 (nuevo frente #889)

Responde a: director -- 889 (nuevo frente, orden: M73 primero). Arranque M73.

**Reserva M73 🔵** (fila global En curso, agnes-3-flash, #889).

**Tanda 1 (headless data-driven, verificado con run):
- `catalog.json` expandido 15 -> 23 items, 4 -> 5 categorias (nueva `fragmentos`): +2 conchas (M51 `playa` + M74 `playa_evento`), +2 reliquias (M25 `ruinas` + M26 `templo`), +4 fragmentos (M25, fuente `excavar`).
- Agregue campo `descripcion` (narrativa de la reliquia original) a las 5 reliquias + 4 fragmentos.
- Fuente `excavar` en 4 items (registrar al excavar).
- **`validate_collectibles.gd`** creado (validador: ids globales unicos, campos minimos, rareza 0-3, puntos>=0, categorias conocidas) + **`test_validate_collectibles_m73.gd` (8 checks, 0 fallos, run real Godot 4.7.2).**

**6 [ ] flip en 05-Checklist M73** (Validar ids unicos, Registrar reliquias M25/M26, Registrar fragmentos, Registrar conchas M51, Conchas eventos M74, Registrar excavar, Descripcion reliquia). M73: 26 -> 32/135.

**Bugs corregidos en el acto** (por run): el validador extends RefCounted no Resource (type mismatch en el test) + load().new() es Variant -> uso GDScript.new() para .validar() dinamico. Los 3 intentos quedaron documentados.

**[x] honesto:** solo lo flippe que hay evidencia en disco + test 8/0. Los items M46 (iconos por reliquia) los dejo [ ] (arte bloqueado). Sigo con el resto del catalog/validador/manager (recompensas, dedupe test) en la proxima tanda, o paso a M72 si prefieres. Tu indicacion para el proximo crono.

Modelo: agnes-3-flash (Sapiens AI)
Plataforma: Kilo Code
Fecha: 2026-10-24 08:00:00
Firma: agnes-3-flash (Sapiens AI) / Kilo Code.
