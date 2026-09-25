# 65-Animales-IA — Código (plan-actual)

**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-25 (P-38, Log 1154)

## Archivos
- `game/isla-ancestral/scripts/animales_ia/m65_animal_ai.gd` — autoload.
- `game/isla-ancestral/scripts/animales_ia/test_m65.gd` — test headless.
- `game/isla-ancestral/scripts/animales_ia/pack_logic.gd` — manada (P-38, Log 1154: movida a `animales_ia/` en el Log 584; ahora la consume el autoload).
- `game/isla-ancestral/scripts/animales_ia/school_logic.gd` — banco (P-38, Log 1154: movida a `animales_ia/` en el Log 584; ahora la consume el autoload).
- `game/isla-ancestral/scripts/fauna/fauna_behavior.gd` — MODIFICADO en QA (Log 415):
  auto-impulso FSM + cableado avistamiento.

## Funciones clave
- `registrar(nodo)` / `desregistrar(nodo)`: alta/baja de individuos + conexión señal.
- `tick(dt)`: recorre individuos y ejecuta movimiento (`_procesar_individuo`).
- `_on_solicitar_movimiento`: actualiza destino/velocidad/en_movimiento.

### P-38 (Log 1154) — integración manada/banco (resuelve BUG-080)
- `registrar(nodo)`: además del alta individual, clasifica la especie (catálogo M36)
  y crea/une el grupo: `gregaria + TERRESTRE → PackLogic`,
  `gregaria + (ACUATICA|AEREA|ANFIBIA) → SchoolLogic`.
- `desregistrar(nodo)`: retira al individuo del grupo (`remover` del pack/school).
- `tick(dt)`: al final corre `_grupos_tick` (cohesión/aliéamiento/separación/migración
  emiten `solicitar_movimiento`; la huida coordinada sobreescribe el destino de todo el grupo).
- `grupo_tamanio(especie_id)`: inspección QA read-only (tamaño del grupo, 0 si no existe).

## Logs
- Log 384 (implementación minimax-m3-free, 23 OK/0).
- Log 453 (pack/school logic, agnes-2.5-flash).
- Log 415 (QA cruzado Hy3: fix integración M36↔M65).
- Log 1154 (P-38, agnes-3-flash: revivió BUG-080 — preloads de `tests/test_m65.gd`,
  integración PackLogic/SchoolLogic en el autoload `m65_animal_ai`, fix de `get()` de 2 args
  en Resource, fix de `limpiar()`/`tick()` de PackLogic y prueba del flujo real
  `fauna_behavior` → autoload).

## Notas del Agente (QA)
**Modelo:** Hy3
**Plataforma:** Kilo Code
**Fecha:** 2026-09-02 00:50
**Estado:** QA cruzado aprobado (mantiene 🟡).

### Lo que corregí
- `fauna_behavior.gd`: `set_process(true)` + `_process` que llama `tick`; conexión
  `solicitar_avistamiento` → `fauna_registry.registrar_avistamiento`. Sin esto, en
  gameplay real los animales no se moverían ni se registrarían avistamientos.

### Recomendaciones
- Mover `pack_logic.gd`/`school_logic.gd` a `scripts/animales_ia/`.
- Resolver `[?]`: NavigationServer3D (M08), spawner burbuja 72m (M09), visuales M45, sonidos M43.

## Notas del Agente (P-38)
**Modelo:** agnes-3-flash
**Plataforma:** Kilo Code
**Fecha:** 2026-09-25
**Estado:** BUG-080 resuelto — manada/banco de vuelta en producción.

### Lo que hice
- Corregí los preloads muertos de `tests/test_m65.gd` (`res://scripts/fauna/*` →
  `res://scripts/animales_ia/*`): la suite volvió a ser ejecutable.
- Integré `PackLogic`/`SchoolLogic` en el autoload `m65_animal_ai.gd`: `registrar`
  clasifica la especie (gregaria/clase del catálogo M36) y crea el grupo; `tick`
  corre `_grupos_tick`; `desregistrar` retira al miembro.
- Ajustes de semántica de PackLogic para que el spec (test) y la producción coincidan:
  `limpiar()` vacía el grupo (espejo de SchoolLogic) y `tick` elige líder con ≥1 miembro
  (cohesión solo con ≥2). Quité la llamada `pack.limpiar()` de cada tick del autoload.
- Cambié los accesos a propiedades de especie de `Resource.get("k", def)` (2 args,
  inválido en Resource) a acceso directo (`especie.clase`, `especie.gregaria`, ...).
- Agregué `grupo_tamanio(especie_id)` (QA read-only) y una prueba del flujo real
  `fauna_behavior._ready → animal_ai.registrar → PackLogic` en `tests/test_m65.gd`.

### Evidencia (headless Godot 4.7.2)
- `tests/test_m65.gd`: 35 OK / 0 fallos (incluye la prueba del flujo real).
- `scripts/animales_ia/test_m65.gd`: 0 fallos (la suite base de 24 OK; el registro de
  conejo_pradera ya va por PackLogic).
- `scripts/fauna/test_fauna.gd`: 0 fallos.
- `main_island.tscn --quit-after 300` ×2: 0 SCRIPT ERROR.

### Lo que NO pude hacer / limitación honesta
- En `main_island` los NPCs (Tortuga/Cangrejo/Jabali/Gaviota) son scripts legacy
  (no heredan `fauna_behavior` ni llevan `especie`), así no se observan allí logs de
  grupo `[M65]` todavía: el flujo de producción real es `fauna_behavior` (M36), y esa
  integración no está aún en la escena principal. La evidencia dura del flujo es la
  prueba agregada (fauna_behavior → autoload → PackLogic) y la suite de animales_ia.

### Recomendaciones para el próximo agente
- Si se integra el spawner de M36 (`fauna_behavior` + catálogo) en `main_island`,
  los grupos de manada/banco se verán en runtime (logs `[M65]`).
- NavigationServer3D (M08) y los visuales/sonidos siguen como `[?]` de otros módulos.
