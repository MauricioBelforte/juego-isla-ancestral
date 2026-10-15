# 309 — M139 sección 6 CERRADA (Construcción): 53 → 65/142

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
**Fecha:** 2026-10-14 06:00
**Responde a:** step-5-kilocode — 307-2026-10-14_05-40-00-step-5-kilocode-a-step-5-kilocode-m139-seccion5-cerrada-53-142.md

Sección 6 completa. Commit `0d4b7f8` (2 archivos, pathspec verificado).

## Conteo

| | Sección 5 | Ahora |
|---|---|---|
| `[x]` | 53 | **65** |
| `[ ]` | 87 | **75** |

En 3 secciones llevo **+42 ítems** (22 → 65) sin inflar ninguno.

## Lo hecho — 12 ítems, 7 con respaldo real en disco

**Verificados (no solo documentados):**
- **Validador de terreno** — `construccion_validator.gd`, núcleo puro sin dependencias de nodos ni
  VoxelTools: valida superficie/pared/agua y ya rechaza con `Motivo.LIMITE_DE_ZONA`.
- **Permisos por zona** — `zonas_permisos.gd`: parcela del jugador EDIFICABLE, ruinas y templos
  PROTEGIDOS (M25).
- **Preview translúcido** — `build_preview.gd` + `build_ghost.gd`.
- **Persistencia** — `buildings_save_provider.gd` implementa ISaveProvider (M59) y
  `test_m18_m60_integration.gd` tiene 10 checks de persistencia.
- **Desbloqueo por amistad** — `data/economia/friendship.json`: nivel 2 → `recetas_basicas`,
  nivel 4 → `recetas_avanzadas` + trueque.
- **Interacción con NPC** — la acción `SENTARSE` ya existe en `item_data.gd`.
- **Catálogo base** — 6 muebles `.tres` reales en `data/houses/`.

**Definición nueva (§2.6.1 del 03-Diseno.md):**
- Catálogo de **30 piezas** (6 vallas, 6 caminos, 10 mobiliario, 8 deco) marcando cuáles ya
  existen vs cuáles son definición para M17/M46.
- **3 estructuras** con etapas (casa de campo 4, invernadero 3, gazebo 2) sobre `avanzar_etapa()`
  que ya tiene `house_manager.gd`.
- **Grid de 1 m sin física**, tabla de costos por categoría, límites por zona (40 parcela / 25
  plaza / 0 ruinas y templos), 4 materiales canónicos (M46) y la regla de clima (solo el
  invernadero interacta: lluvia ×2 crecimiento, sol ×0.5).

**Nota honesta incluida:** el save provider existe, pero la fuente M17 todavía no está
implementada — quedó escrito en el ítem.

## próXIMO

Sección 7 (Primer templo — Templo de Brisa, M26/M24/M13). Conteo vigente: **65/142**.

---

**Modelo:** step-5-kilocode
**Plataforma:** Kilo Code
