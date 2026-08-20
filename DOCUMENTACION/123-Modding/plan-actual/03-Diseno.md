**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 03-Diseno.md — Módulo 123: Modding

## 1. GATE de modding (D1)
| Criterio | Umbral |
|----------|--------|
| Comunidad activa (Discord activo / pedidos) | ≥ 50 pedidos de mods verificados en M100 |
| Presupuesto V2 disponible | ≤ 10% del presupuesto |
| Diseño de este módulo revisado | 100% puntos 1-15 aprobados |
| Riesgo de re-arquitectura | 0 (se usa M108/M109) |
- Si el GATE falla → posponer a V3 sin coste ya comprometido.

## 2. Formato de mod (RF3)
```
mod.ejemplo.zip (o .mod)
├── manifest.json          ← id, name, version (semver), minBuild, author, override: []
├── data/
│   ├── objects.json       ← items (se usa el mismo esquema M108)
│   ├── recipes.json
│   ├── biomes.json
│   ├── quests.json
│   ├── npc.json
│   ├── shops.json
│   └── weather.json
├── assets/                ← texturas/audio (referidas por id)
└── readme.md
```
- Los `.json` son EXACTAMENTE el esquema de M108 (exportadores de M109).
- Límite: 100 MB por mod; 100 mods simultáneos; tamaños por dominio (10 MB assets).

## 3. API de contenido (RF2 — data-first) — dominios modables v1
| Dominio | Ejemplo de mod |
|---------|----------------|
| Objetos/items | nuevo cultivo/cosecha |
| Recetas | crafting nuevo (M16) |
| Biomas y vegetación | bioma propio con paleta (M09) |
| Misiones (secundarias) | quest nueva con diálogos |
| NPC (nuevo, sin rutinas de IA extensas) | npc con casa |
| Tiendas/economía | tienda con items propios (M39) |
| Clima/estaciones (variaciones) | niebla propia (M32) |
| Texturas/paletas (assets) | re-skin de objetos |
- NO modables en v1: mundo principal/generación core (M10), sellos/historia principal (M22), IA de rutinas, física, técnicos.
- v2 (whitelist): scripts C# autorizados listados en manifest + verificación de hash (M106).

## 4. Carga (RF5 — ModLoader)
1. Boot: el ModLoader (M63) lee `mods/` local (instalados manuales) y Workshop (M97) — en ese orden de prioridad.
2. Orden: por manifiesto: `base` < `ui` < `contenido` < `override` (último gana).
3. Validación: los validators de M109 corren sobre el paquete ANTES de montar; error → el mod se omite y se informa (lista en menú de mods).
4. Recarga en caliente: solo para mods de "contenido" (no requiere reinicio); scripts/estado exigen reinicio.
5. Build embargo: mods que piden `minBuild` mayor al build actual → bloqueados con mensaje.

## 5. Conflictos y compatibilidad (RF6/RF10)
| Caso | Comportamiento |
|------|----------------|
| id duplicado sin override | mod de menor prioridad se omite + warning |
| id duplicado CON override en manifest | override gana (documentado) |
| versión de mod baja vs build | warning (risk de features inexistentes) |
| minBuild mayor que el actual | bloqueado |
| esquema corrupto (no parsea) | mod omitido + error claro |
- Todo se reporta en la pantalla "Mods" (M89) con código de error.

## 6. Herramientas (RF7)
- En M109: comando "Exportar a Mod" en cada editor → genera el paquete (zip + manifest) con validación.
- CLI de validate (ci): `modchecker` reutiliza DataValidator con reglas de mod.
- Documentación: `docs/mods/README` en la web (M99) — guía "Crear tu primer mod" con 1 ejemplo funcional (cultivo + receta).

## 7. Saves con mods (RF11)
- Save v3.x (M59) guarda `modsActive: [ids]` y `worldSeed`.
- Al cargar: si el save tiene mods y el loader está off → pantalla de advertencia: "Este mundo fue jugado con N mods. Continuar sin mods puede perder contenido" con opciones: Continuar / Activar mods.
- Ubicación de saves con mods: mismo slot, pero se marca visualmente (icono de mod).
- Backup de save antes de cargar con mods nuevos (M107).

## 8. Workshop y distribución (RF9)
- Publicación vía SteamWorkshop (Steamworks API de M97) con `appid` y región.
- Los mods de Workshop integran telemetría de subscripciones (M104) sin datos del usuario.
- Moderación: reportes → M100 (reglas de contenido) + lista negra.
- Fuera de Steam: no distribuimos en tiendas propias (V2 mantiene solo Workshop).

## 9. Soporte oficial (RF12)
- Regla de triaje: con mods → SOLO se aceptan si reproducen sin mods (flags `--no-mods` de soporte).
- FAQ de modding en M100 (cómo instalar, desinstalar, reportar).
- SLA V2: los issues de mods compartidos por la comunidad se responden en ≤ 72 h (no prometemos fixes).

## 10. Coste técnico estimado (RF13)
| Área | Horas (estimado) |
|------|------------------|
| ModLoader + manifiesto + conflictos | 80-120 h |
| Validación de mods (M109 esq) | 30-50 h |
| Exportadores M109 | 40-60 h |
| Saves con mods (M59) | 20-30 h |
| Workshop + telemetría (M97/M104) | 40-60 h |
| Docs + ejemplo + soporte FAQ | 30-40 h |
| **Total** | **240-360 h** (~6-9 semanas) — dentro del 10% de presupuesto.