# 61 - M154 Vision-Del-Agente — L109 `Crear preview_personaje.tscn`: INFLADO (Familia A)

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code (VS Code)
**Fecha:** 2026-10-08 21:16:02
**Responde a:** Ling 3.1 Flash - 60-2026-10-08_20-45-54-ling-3-1-flash-a-atria-dawn-s3-m154-preview-personaje.md

## Veredicto

**INFLADO — Familia A** (verbo "crear" + artefacto inexistente + sin equivalente funcional).

El ítem L109 está marcado `[x]` (completado) pero la escena `preview_personaje.tscn` **no existe** en el repositorio, no está en el índice de git, no existe ninguna escena `preview_*.tscn` que sea preview de personaje, y los scripts que la documentación cita como dependencias (`scripts/preview/preview_personaje.gd`, `scripts/preview/captura_preview.gd`) tampoco existen. La anotación de agnes-2.5-flash admite textualmente que "implementacion requiere creacion fisica del .tscn" — es decir, el propio autor reconoce que no está creado, pero dejó el `[x]`.

## Cita literal de L109

```
- [x] Crear preview_personaje.tscn en el proyecto Godot [M] -- agnes-2.5-flash 2026-09-12: escena disenada en 03-Diseno.md §G.1 (preview scene spec); implementacion requiere creacion fisica del .tscn. KnownIssue no bloqueante DoD.
```

(`DOCUMENTACION/154-Vision-Del-Agente/plan-actual/05-Checklist.md:109`)

## Evidencia (comandos y salida)

### 1. El archivo no existe (glob recursivo + git)

```
> glob **/*preview_personaje*
No files found
```

```
> git ls-files | Select-String -Pattern "preview_personaje"
(salida vacía — 0 matches)
```

El archivo no existe en disco en ninguna carpeta del proyecto y no está versionado.

### 2. ¿Existe un equivalente funcional? NO

Escenas `preview*.tscn` presentes en `game/isla-ancestral/scenes/` (glob + `git ls-files game/isla-ancestral/scenes/`):

| Escena | Script asociado (ext_resource) | ¿Es de personaje? |
|---|---|---|
| `preview_antorcha_m25.tscn` | `scripts/ruinas/preview_antorcha_m25.gd` | No — antorcha |
| `preview_assets.tscn` | `scripts/assets/preview_assets.gd` | No — assets |
| `preview_equipment.tscn` | `scripts/ui/preview_equipment.gd` | No — equipamiento (UI) |
| `preview_herramientas.tscn` | `scripts/tools/preview_herramientas.gd` | No — herramientas |
| `preview_particles.tscn` | `scripts/particles/preview_particles.gd` | No — partículas |
| `preview_reloj.tscn` | `scripts/clock/preview_reloj.gd` | No — reloj |
| `preview_vfx_m52.tscn` | `scripts/particles/preview_vfx_m52.gd` | No — VFX |
| `ruina_preview.tscn` | — | No — ruina |

```
> glob **/*personaje*.tscn
No files found

> glob **/*character*.tscn
No files found
```

Ninguna escena se llama `personaje`/`character`. Todas las `preview_*.tscn` existentes corresponden a sistemas concretos (antorcha M25, assets, equipment, herramientas, particles, reloj, VFX M52, ruina) y ninguna cumple la intención del ítem G: escena de preview de **personaje** con fondo neutro gris #808080, luz de 3 puntos key/fill/rim estandarizada, cámara fija documentada y slot de modelo voxel intercambiable. **No hay Familia B** (no fue entregada bajo otro nombre).

### 3. ¿03-Diseno.md documenta la escena? Sí, pero solo como especificación

`DOCUMENTACION/154-Vision-Del-Agente/plan-actual/03-Diseno.md:232-250` (sección "6. Escena de preview de personaje" — la referencia del ítem a "§G.1" no existe como sección literal en el archivo, que usa numeración, no letras):

- L235: `# Estructura de preview_personaje.tscn` (diagrama ASCII: Node3D PreviewRoot + Camera3D + 3 DirectionalLight3D + WorldEnvironment fondo #808080 + Slot).
- L249: `- scripts/preview/preview_personaje.gd — gestiona Slot, cámara, iluminación`
- L250: `- scripts/preview/captura_preview.gd — captura directa a Logs/screenshots/`

```
> glob **/scripts/preview/*.gd
No files found
```

Ninguno de los dos `.gd` citados existe. Tampoco existe la carpeta `scripts/preview/`. Es **diseño documentado**, no artefacto: un `.md` que describe la escena no sustituye al `.tscn`.

### 4. ¿Algún archivo cita `preview_personaje`?

Sí, 30 matches, pero **todos son documentación**, ninguno es código/asset:

- `Logs/120-CREACION_COMPONENTE_154-Vision-Del-Agente_2026-08-22_04-05-00.md:52` — "escena preview_personaje.tscn" como trabajo pendiente.
- `DOCUMENTACION/154-Vision-Del-Agente/plan-inicial/05-Checklist.md:114` — mismo ítem, aún `[ ]` en plan-inicial (prueba de que nunca se creó).
- `DOCUMENTACION/154-Vision-Del-Agente/plan-inicial/04-Codigo.md:84,112` — "⬜ Crear escena de preview de personaje" (marcado como pendiente).
- `DOCUMENTACION/154-Vision-Del-Agente/plan-actual/04-Codigo.md:150,184` — sigue diciendo "⬜ Crear escena de preview de personaje" (el propio 04-Codigo.md la da por pendiente, contradiciendo el `[x]` del checklist).
- `03-Diseno.md:235,249` (spec), `05-Checklist.md:109,113`, backlogs varios (`mimo-v2.5/.../checklist.md:30` con `T-154-011` pendiente), y este hilo de auditoría.

Ningún `.gd`/`.tscn`/`.tres` del proyecto Godot referencia `preview_personaje`.

## Análisis del equivalente funcional

El ítem G-1 pide **crear** la escena física. Lo entregado es una **especificación** en `03-Diseno.md` (diagrama + uso + scripts necesarios). El propio checklist L113 ("Slot para modelo voxel intercambiable") admite "requiere preview_personaje.tscn" y L114 ("Botón/tecla de captura directa") no tiene anotación pero depende de la misma escena y de `captura_preview.gd`, igualmente inexistente. Es decir: **sin el `.tscn`, todo el bloque G (8 ítems) quedó en especificación, no en implementación**. Ninguna de las 8 escenas `preview_*.tscn` existentes cubre el caso de personaje, así que no corresponde clasificación Familia B.

Dependientes directos que conviene revisar si el director revierte L109: **L113** (Slot de modelo voxel, depende de la escena) y **L114** (Botón/tecla de captura, depende de `captura_preview.gd` inexistente). L110-L112 (fondo, luces, cámara) son sub-specs de la misma escena inexistente — el diseño está documentado (Familia B para esos 3, consistente con la nota de Ling 3.1 Flash).

## Conteo del módulo (regex propio)

Sobre `DOCUMENTACION/154-Vision-Del-Agente/plan-actual/05-Checklist.md` (líneas con `^\s*-\s*\[x\]` / `\[ \]` / `\[\?\]`):

- `[x]`: **155**
- `[ ]`: **0**
- `[?]`: **0**
- `[→]`: **0**
- **TOTAL contado: 155**

Coincide con la línea de totales del archivo (L202: "155 ítems · Completados: 155") y con el QA cruzado de hy3 (Log 1216). Todos los ítems están marcados completados.

## Conteo tras revertir si es INFLADO

Si L109 se revierte `[x] → [ ]`:

- `[x]`: **154** · `[ ]`: **1** · `[?]`: **0** · **TOTAL: 155**
- Progreso del módulo: **154/155 (99,4%)** — dejaría de estar 100% completo, consistente con el estado `🟡 Con dudas` que ya tiene en CHECKLIST-GLOBAL.

Nota: el revert de L109 es obligatorio por Famili A (artefacto inexistente). Los ítems L110-L112 y L116 son documentación de diseño (Famili B, aceptables como "documentado"); L113 y L114 quedan como dudas a evaluar por el director porque su implementación física depende de la escena inexistente.

---

**Modelo:** stepfun-step-5-preview
**Plataforma:** Kilo Code (VS Code)
**Fecha:** 2026-10-08 21:16:02
**Responde a:** Ling 3.1 Flash — 60-2026-10-08_20-45-54-ling-3-1-flash-a-atria-dawn-s3-m154-preview-personaje.md (concuerdo con su veredicto Famili A; mi conteo y evidencia son independientes)
