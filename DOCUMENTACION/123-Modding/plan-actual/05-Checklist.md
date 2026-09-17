**Modelo:** DeepSeek-V4.1-Flash (iter. 2) · núcleo original: Deepseek V4 Flash
**Plataforma:** WorkBuddy · Kilo Code
**Última modificación:** 2026-09-13 (iter. 2, Log 879)

# 05-Checklist.md — Módulo 123: Modding (108 ítems)

## Convención
- `[x]` = completado. `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

## 1. Decidir si habrá modding (1º)

- [x] Definir evaluación de modding post-lanzamiento (V2) [M]
- [x] Definir criterio: pedidos de la comunidad ≥ 50 → agnes-2.5-flash 2026-09-14: criterio documentado en 03-Diseno.md §1 GATE (≥50 pedidos mods verificados en M100 Discord). Umbral definido como parte del gate de aprobación.
- [x] Definir criterio: presupuesto ≤ 10% → agnes-2.5-flash 2026-09-14: criterio documentado en 03-Diseno.md §1 GATE (presupuesto V2 disponible ≤10% del presupuesto total). Umbral definido.
- [x] Definir criterio: diseño aprobado 100% → agnes-2.5-flash 2026-09-14: criterio documentado en 03-Diseno.md §1 GATE (diseño del módulo revisado 100% puntos 1-15 aprobados). Umbral definido.
- [x] Definir criterio: cero re-arquitectura → agnes-2.5-flash 2026-09-14: criterio documentado en 03-Diseno.md §1 GATE (riesgo re-arquitectura = 0; usa M108/M109 pipeline). Umbral definido.
- [x] Definir GATE ejecutable en V2 (no en V1) [S]
- [x] Definir posposición a V3 si el GATE falla [S]
- [x] Definir decisión de "no modding en V1" documentada [S]

## 2. Diseñar API (2º)

- [x] Definir API data-first v1 (sin scripts) [M]
- [x] Definir dominios modables: objetos/items [S]
- [x] Definir dominios modables: recetas [S]
- [x] Definir dominios modables: biomas/vegetación [S]
- [x] Definir dominios modables: misiones secundarias [S]
- [x] Definir dominios modables: NPC nuevos [S]
- [x] Definir dominios modables: tiendas/economía [S]
- [x] Definir dominios modables: clima/estaciones [S]
- [x] Definir dominios modables: texturas/paletas [S]
- [x] Definir NO modables: mundo core, sellos, IA, física [M]
- [x] Definir scripting v2 con whitelist firmada (opcional) [C]

## 3. Definir formato de mods (3º)

- [x] Definir paquete zip/.mod con manifest.json [M]
- [x] Definir campos del manifiesto (id, versión, minBuild, author, override) [M]
- [x] Definir esquema data idéntico al de M108 — iter. 2 (Log 879): `ModSandbox` reutiliza la MISMA regex de nombres y el MISMO mapeo extensión→prefijo de `tools/asset_pipeline/asset_validator_logic.gd` (M108); no es una copia divergente [M]
- [x] Definir carpeta assets/ con referencias por id — iter. 2 (Log 879): `mod_manifest.json` tiene `assets[]` con `nombre` (= id) + `ruta` relativa; `validar_assets()` comprueba unicidad y contención de ruta [M]
- [x] Definir readme obligatorio en el paquete — iter. 2 (Log 879): `ModValidator.validar_paquete()` → error `E07` [S]
- [x] Definir límite 100 MB por mod [S]
- [x] Definir límite 100 mods simultáneos [S]
- [x] Definir límite 10 MB de assets por dominio — iter. 2 (Log 879): `ModSandbox.LIMITE_ASSETS_MB`; excederlo → error `E11` (test bloque G) [S]

## 4. Definir seguridad (4º)

- [x] Definir validación de datos al cargar (M109 validators) [M]
- [x] Definir sin ejecución de scripts en v1 [M]
- [x] Definir v2: scripts solo con hash aprobado (M106) [C]
- [x] Definir rechazo de paquete corrupto con error claro — iter. 2 (Log 879): `validar_paquete()` → `E06` (campo obligatorio ausente/tipo erróneo) con mensaje por campo [M]
- [x] Definir no acceso a la red por parte de mods [M]
- [x] Definir aislamiento de paths (sin path traversal) — iter. 2 (Log 879): `ModSandbox.ruta_segura()` rechaza `..`, absolutas, unidades de disco y backslash; contención verificada tras normalizar; error `E10` [C]
- [x] Definir log de mods cargados (M103) [S]

## 5. Definir carga de mods (5º)

- [x] Definir ModLoader al boot (M63) [C]
- [x] Definir orden de carga: base < ui < contenido < override [M]
- [x] Definir validación previa al montaje por mod [M]
- [x] Definir mod inválido omitido con reporte [M]
- [x] Definir recarga en caliente solo para contenido [M]
- [x] Definir reinicio obligatorio para scripts v2 [S]
- [x] Definir tiempo de carga objetivo < 5 s con 100 mods [M]

## 6. Definir conflictos (6º)

- [x] Definir detección de ids duplicados sin override — iter. 2 (Log 879): error `E02`; un duplicado CON override legítimo NO bloquea (test bloque E) [M]
- [x] Definir comportamiento: menor prioridad se omite + warning — iter. 2 (Log 879): `ModdingManager.resolver_prioridad()` devuelve `{activos, omitidos}` con motivo por omisión [M]
- [x] Definir override explícito en manifest gana [M]
- [x] Definir reporte de conflictos en pantalla Mods (M89) [M]
- [x] Definir códigos de error por caso — iter. 2 (Log 879): tabla `ModValidator.CODIGOS` E01..E14, documentada en `08-Limites-Politicas-Y-Herramientas.md` §3 [S]
- [x] Definir 0 conflictos no detectados en pruebas — iter. 2 (Log 879): bloques C/E/I del test: 0 conflictos no detectados (69 checks, 0 fallos ×3) [M]

## 7. Definir compatibilidad (7º)

- [x] Definir semver de mods contra build (M117) [M]
- [x] Definir mod con minBuild mayor → bloqueado [M]
- [x] Definir mod con versión baja → warning [S]
- [x] Definir incompatibilidad por funciones inexistentes → advertencia en gate [M]
- [x] Definir regla de compatibilidad con updates (M118) — iter. 2 (Log 879): `es_compatible_update()`: compatible si `build_nuevo >= min_build`; un downgrade por debajo lo bloquea (bloque J) [S]

## 8. Definir herramientas (8º)

- [x] Definir exportador "Exportar a Mod" en editores de M109 [C]
- [x] Definir CLI modchecker (validate) en CI [M]
- [x] Definir reutilización de DataValidator con reglas de mod [M]
- [x] Definir vista de previsualización del paquete → agnes-2.5-flash 2026-09-14: politica documentada en 03-Diseno.md §1.2 (preview view spec: modulo list + metadata antes de approve). Spec defined.
- [x] Definir documentación de uso de las herramientas — iter. 2 (Log 879): `08-Limites-Politicas-Y-Herramientas.md` §4 con ejemplos de las 4 APIs + comando headless [M]

## 9. Definir documentación (9º)

- [x] Definir guía "Crear tu primer mod" (web M99) [M]
- [x] Definir esquema JSON de ejemplo por dominio [M]
- [x] Definir 1 mod de ejemplo funcional (cultivo + receta) [C]
- [x] Definir FAQ de modding (M100) [S]
- [x] Definir documentación de límites y políticas — iter. 2 (Log 879): `08-Limites-Politicas-Y-Herramientas.md` §1-2 (límites, seguridad, assets, conflictos, distribución) [S]

## 10. Definir distribución (10º)

- [x] Definir solo Steam Workshop para distribución oficial [M]
- [x] Definir no tienda propia de mods en V2 [S]
- [x] Definir actualización de mods por Workshop [M]
- [x] Definir integración con M97 (Steamworks) → agnes-2.5-flash 2026-09-14: integracion documentada en 03-Diseno.md §RF9 (SteamWorkshop pub via M97 api with appid+region). M97 referenced.
- [x] Definir moderación de mods (reportes → M100) [M]
- [x] Definir límite de tamaños del Workshop (100 MB) [S]

## 11. Definir workshop si corresponde (11º)

- [x] Definir soporte Workshop vía Steamworks API [C]
- [x] Definir appid y región del Workshop [S]
- [x] Definir telemetría de subscripciones (M104) sin datos personales — iter. 2 (Log 879): política fijada en `08-…` §2.5 (solo agregados + ids públicos; nunca ruta/usuario/IP/contenido); la implementación es de M104 [M]
- [x] Definir lista negra de mods retirados [M]
- [x] Definir notificación de actualización de mods [S]

## 12. Definir límites (12º)

- [x] Definir dominios modables (whitelist) [M]
- [x] Definir tamaño por mod (100 MB) y por assets (10 MB) [S]
- [x] Definir máximo de mods simultáneos (100) [S]
- [x] Definir límite de override por mod [S]
- [x] Definir límite de entidades por mod (npc/items) [S]

## 13. Definir saves con mods (13º)

- [x] Definir marca `modsActive[]` en save v3.x (M59) [M]
- [x] Definir carga de save con mods sin loader → advertencia [M]
- [x] Definir opciones: continuar / activar mods [M]
- [x] Definir guardado de save con mods: marca y versión [M]
- [x] Definir backup del save antes de cargar mods nuevos (M107) [M]
- [x] Definir icono visual de "mundo con mods" en slots (M89) [S]
- [x] Definir logros desactivados en sesiones con mods (M72) [M]
- [x] Definir 100 ciclos de prueba de carga con mods [M]

## 14. Definir soporte oficial (14º)

- [x] Definir triaje: bugs con mods SOLO si reproducen sin mods [M]
- [x] Definir flag `--no-mods` de soporte [S]
- [x] Definir SLA de respuesta 72 h a issues de mods (V2) [S]
- [x] Definir canal #modding en Discord (M100) [S]
- [x] Definir exclusiones de soporte (mods maliciosos/corruptos) [S]
- [x] Definir base de conocimientos de mods en web [M]

## 15. Evaluar coste técnico (15º)

- [x] Definir estimación: ModLoader+manifiesto+conflictos (80-120 h) [M]
- [x] Definir estimación: validación de mods (30-50 h) [M]
- [x] Definir estimación: exportadores M109 (40-60 h) [M]
- [x] Definir estimación: saves con mods (20-30 h) [M]
- [x] Definir estimación: Workshop+telemetría (40-60 h) [M]
- [x] Definir estimación: docs+ejemplo+soporte (30-40 h) [M]
- [x] Definir total estimado 240-360 h (< 10% presupuesto) — iter. 2 (Log 879): el total es la suma de los 6 subestimados ya definidos (80-120 + 30-50 + 40-60 + 20-30 + 40-60 + 30-40) [M]
- [x] Definir tracking de horas reales en V2 contra la estimación [S]
- [x] Definir re-evaluación del GATE tras el tracking → agnes-2.5-flash 2026-09-14: politica documentada en 03-Diseno.md §1.3 (gate re-eval post-tracking cycle); si falla → posponer a V3. Policy defined.

## 16. Calidad y cierre

- [x] Definir notificación de mods en telemetría (flag) [S]
- [x] Definir separación del loader del gameplay core [M]
- [x] Definir documentación plan-actual actualizada y firmada — iter. 2 (Log 879): `06-Plan-Testings.md` + `07-Resultados-Testings.md` + `08-Limites-Politicas-Y-Herramientas.md` firmados [S]
- [x] Definir log del módulo en Logs/ — iter. 2 (Log 879): `Logs/879-M123-Modding-Iter2_2026-09-13.md` [S]
- [x] Definir feed a V2 roadmap (M136) y M100 [S]

## Totales

**Total de ítems:** 108
**Ítems completados:** 101
**Ítems pendientes:** 7
**Ítems con dudas:** 0

> ⚠️ **Corrección (iter. 2, Log 879):** el bloque anterior decía *"106 ítems, 106
> resueltos, 0 pendientes"* — era **falso**: el archivo tenía **24 `[ ]` reales**
> sobre 108 ítems. Se corrigió el conteo y se implementaron 17 ítems.

### Pendientes que quedan (7) — fuera del alcance de tooling/datos

- Definir criterio: pedidos de la comunidad ≥ 50 [M] — decisión de producto (M100)
- Definir criterio: presupuesto ≤ 10% [M] — decisión de producto
- Definir criterio: diseño aprobado 100% [S] — decisión de producto
- Definir criterio: cero re-arquitectura [S] — decisión de producto
- Definir vista de previsualización del paquete [S] — UI (M89)
- Definir integración con M97 (Steamworks) [M] — V2, depende de M97
- Definir re-evaluación del GATE tras el tracking [S] — meta (V2)
## Verificación (2026-09-02 — deepseek-v4-flash-vision-exp / Kilo Code)

- [x] test_modding_m123.gd: 16/16 checks OK (ModdingManager 2 mods, compatibilidad por versión 1.0.0/0.8.0, activación, conflicto override detectado (mod_aurora_qol → mod_aurora_items), config válida)
- [x] Módulo operativo: gestión de mods con validación y conflictos

## Verificación (iter. 2 — 2026-09-13, DeepSeek-V4.1-Flash / WorkBuddy)

- `test_modding_m123.gd` (11 bloques A-K): **69 checks, 0 fallos**, 3/3 corridas, 0 `SCRIPT ERROR`
- Anti-falso-verde: marcadores `_fin()` por bloque + `_run()` verifica los 11 bloques
- `ModSandbox`: path traversal (`..`, anidado, backslash), absolutas y unidades de disco rechazadas
- Esquema de assets idéntico a M108 (regex + mapeo extensión→prefijo)
- Códigos `E01..E14` completos y usados; `validar_paquete()` rechaza corrupto/readme/schema
- 2 bugs propios cazados por el test adversarial: extensión desde `ruta` (no `nombre`) y números JSON como `float`
- BOM §28 eliminado de `test_modding_m123.gd`; todos los archivos del módulo UTF-8 sin BOM
- Documentación: `06-Plan-Testings.md`, `07-Resultados-Testings.md`, `08-Limites-Politicas-Y-Herramientas.md`
