**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 123: Modding (110 ítems)

## Convención
- `[x]` = completado por documentación. `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

## 1. Decidir si habrá modding (1º)

- [x] Definir evaluación de modding post-lanzamiento (V2) [M]
- [x] Definir criterio: pedidos de la comunidad ≥ 50 [M]
- [x] Definir criterio: presupuesto ≤ 10% [M]
- [x] Definir criterio: diseño aprobado 100% [S]
- [x] Definir criterio: cero re-arquitectura [S]
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
- [x] Definir esquema data idéntico al de M108 [M]
- [x] Definir carpeta assets/ con referencias por id [M]
- [x] Definir readme obligatorio en el paquete [S]
- [x] Definir límite 100 MB por mod [S]
- [x] Definir límite 100 mods simultáneos [S]
- [x] Definir límite 10 MB de assets por dominio [S]

## 4. Definir seguridad (4º)

- [x] Definir validación de datos al cargar (M109 validators) [M]
- [x] Definir sin ejecución de scripts en v1 [M]
- [x] Definir v2: scripts solo con hash aprobado (M106) [C]
- [x] Definir rechazo de paquete corrupto con error claro [M]
- [x] Definir no acceso a la red por parte de mods [M]
- [x] Definir aislamiento de paths (sin path traversal) [C]
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

- [x] Definir detección de ids duplicados sin override [M]
- [x] Definir comportamiento: menor prioridad se omite + warning [M]
- [x] Definir override explícito en manifest gana [M]
- [x] Definir reporte de conflictos en pantalla Mods (M89) [M]
- [x] Definir códigos de error por caso [S]
- [x] Definir 0 conflictos no detectados en pruebas [M]

## 7. Definir compatibilidad (7º)

- [x] Definir semver de mods contra build (M117) [M]
- [x] Definir mod con minBuild mayor → bloqueado [M]
- [x] Definir mod con versión baja → warning [S]
- [x] Definir incompatibilidad por funciones inexistentes → advertencia en gate [M]
- [x] Definir regla de compatibilidad con updates (M118) [S]

## 8. Definir herramientas (8º)

- [x] Definir exportador "Exportar a Mod" en editores de M109 [C]
- [x] Definir CLI modchecker (validate) en CI [M]
- [x] Definir reutilización de DataValidator con reglas de mod [M]
- [x] Definir vista de previsualización del paquete [S]
- [x] Definir documentación de uso de las herramientas [M]

## 9. Definir documentación (9º)

- [x] Definir guía "Crear tu primer mod" (web M99) [M]
- [x] Definir esquema JSON de ejemplo por dominio [M]
- [x] Definir 1 mod de ejemplo funcional (cultivo + receta) [C]
- [x] Definir FAQ de modding (M100) [S]
- [x] Definir documentación de límites y políticas [S]

## 10. Definir distribución (10º)

- [x] Definir solo Steam Workshop para distribución oficial [M]
- [x] Definir no tienda propia de mods en V2 [S]
- [x] Definir actualización de mods por Workshop [M]
- [x] Definir integración con M97 (Steamworks) [M]
- [x] Definir moderación de mods (reportes → M100) [M]
- [x] Definir límite de tamaños del Workshop (100 MB) [S]

## 11. Definir workshop si corresponde (11º)

- [x] Definir soporte Workshop vía Steamworks API [C]
- [x] Definir appid y región del Workshop [S]
- [x] Definir telemetría de subscripciones (M104) sin datos personales [M]
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
- [x] Definir total estimado 240-360 h (< 10% presupuesto) [M]
- [x] Definir tracking de horas reales en V2 contra la estimación [S]
- [x] Definir re-evaluación del GATE tras el tracking [S]

## 16. Calidad y cierre

- [x] Definir notificación de mods en telemetría (flag) [S]
- [x] Definir separación del loader del gameplay core [M]
- [x] Definir documentación plan-actual actualizada y firmada [S]
- [x] Definir log del módulo en Logs/ [S]
- [x] Definir feed a V2 roadmap (M136) y M100 [S]

## Totales

**Total de ítems:** 106
**Ítems resueltos por documentación:** 106 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)