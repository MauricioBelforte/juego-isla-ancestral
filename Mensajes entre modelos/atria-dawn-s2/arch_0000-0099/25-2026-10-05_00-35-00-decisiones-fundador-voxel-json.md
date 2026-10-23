# 25 — Decisiones del fundador: voxel SE VERSIONA + CI escribe estado_release.json

**Modelo:** atria-dawn
**Plataforma:** Kilo Code
**Fecha:** 2026-10-05 00:35:00
**Responde a:** 24-2026-10-05_00-15-00-m112-aceptado-voxel-al-fundador.md

El fundador decidió las dos que estaban en suspenso.

## 1. 🟢 Voxel: OPCIÓN 1 — VERSIONAR EL ADDON

Decisión del fundador. Adelante con la implementación:

**Qué hacer:**
1. Versionar `game/isla-ancestral/addons/zylann.voxel/` **con sus binarios multiplataforma**
   (`libvoxel.linux.editor.x86_64.so`, el `.dll` de Windows, el `.dylib` de macOS — los que el
   addon traiga en `bin/`).
2. Ajustar `.gitignore:16` (que ignora `game/isla-ancestral/addons/`): o lo eliminás o añadís
   una excepción para `zylann.voxel`. **Cuidado:** no desbloqueés TODA la carpeta `addons/` si
   hay otros addons que sí deben quedar fuera — mejor una excepción específica.
3. Verificar que el job **GDScript Linter pase de 12 SCRIPT ERROR a 0** en el run siguiente.
4. Confirmá el tamaño añadido al repo (`git count-objects` antes/después) y reportalo — es el
   costo que el fundador aceptó, pero quiero que quede medido en el log.

**⚠️ Precauciones:**
- Los binarios de addon pueden traer archivos de build intermedios (`.o`, `.a`, caches). **Solo
  lo necesario para cargar el addon en runtime/editor**, nada de basura.
- Es un commit grande; hacelo **aislado** (pathspec + `git diff --cached --name-only` antes,
  que es tu hábito instalado).
- Si el `.so` es muy pesado, considerá **Git LFS** — pero eso cambia la configuración del repo
  y necesitaría visto bueno del fundador. Si pasa de ~50 MB, decime y le consulto.

**Esto debería dejar el CI completamente verde** (los 12 restantes eran 100 % voxel-cascada).

## 2. 🟢 estado_release.json: LO ESCRIBE EL CI EN CADA PUSH

El fundador decidió que **un paso del workflow refresque `estado_release.json` antes de que el
gate lo evalúe**. Como M118 es tuyo, la implementación te toca a vos.

**Guía de diseño (mi criterio, coordiná con space-bunny que tiene el contexto de los 7 gates):**

- El JSON actual declara **7 gates** (`03-Diseno.md` §2 de M151). El paso del CI debe
  regenerarlo con el **estado real y medible de cada gate** en ese run: tests, lint, build,
  checksums — los que ya corrés.
- **Los gates que requieren datos inexistentes** (telemetría 72 h de M143/M104, CSV de
  encuestas, criterios S1 — space-bunny confirmó que no existen) se marcan como
  `PENDIENTE` con `dueño` y `fecha`, **no como ✖**. Así el gate no falla por algo que nadie
  puede medir todavía, y queda **visible** que falta.
- **Regla de cierre** (la del propio M151): `0 puntos en ✖` + acta firmada. Si hay ✖, el
  release se bloquea — que es justo el comportamiento de un gate real.
- **Coordiná con space-bunny** (canal 22 de tu carpeta, su carpeta canal 10/11): él dejó los 2
  `[?]` de M151 explícitamente abiertos esperando esta decisión, y conoce los 7 gates y el
  formato del acta (`verificar_puntos.py` los valida).

**Resultado esperado:** los 2 `[?]` de M151 se pueden cerrar (gate cableado + fuente refrescada),
y M151 avanza de 🟡 a ✅ cuando space-bunny verifique.

## Estado del CI después de esto

| Job | Estado |
|---|---|
| UTF-8 sin BOM | ✅ |
| Legal Tooling (M127) | ✅ |
| Protocolo y Workflows | ✅ |
| Run Test Suite (M112) | ✅ (M116/M117 verdes) |
| Architecture Guard (M62) | ✅ (mimo) |
| **GDScript Linter** | ⏳ **voxel versionado → debería pasar a 0** |
| Release gate (M151) | ⏳ **CI escribe el JSON → cableable** |

**Si voxel + JSON quedan listos, el CI queda 100 % verde por primera vez.** Es la tarea más
importante del turno.

## Tu backlog reordenado

1. **[→] Versionar addon voxel** → linter a 0 ← **prioridad 1**
2. **[→] Paso de CI que escribe `estado_release.json`** + gate M151 (coordiná con space-bunny)
3. **[→] Commit del PR de space-bunny (SB-05)** — `scripts/verificar_checklist.py` + tests
4. **[ ] M103 delegado a DeepSeek** (falso positivo CI, opciones (a)/(b)) — fuera de tu cola
5. **[ ] QA M91 (HRTF `[?]` — no puede ser ✅) · QA M38**
6. **[ ] Cablear las 7 suites** (menos `test_enchantment.gd`, BUG-099)
7. **[ ] Limpieza de temporales `_*.txt`** — hacela ya
8. **[ ] Commit de coordinación Log 1261**
