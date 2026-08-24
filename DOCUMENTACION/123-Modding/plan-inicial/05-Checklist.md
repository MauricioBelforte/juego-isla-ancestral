**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 123: Modding (110 ítems)

## Convención
- `[ ]` = completado por documentación. `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple · `[M]` medio · `[C]` complejo.

## 1. Decidir si habrá modding (1º)

- [ ] Definir evaluación de modding post-lanzamiento (V2) [M]
- [ ] Definir criterio: pedidos de la comunidad ≥ 50 [M]
- [ ] Definir criterio: presupuesto ≤ 10% [M]
- [ ] Definir criterio: diseño aprobado 100% [S]
- [ ] Definir criterio: cero re-arquitectura [S]
- [ ] Definir GATE ejecutable en V2 (no en V1) [S]
- [ ] Definir posposición a V3 si el GATE falla [S]
- [ ] Definir decisión de "no modding en V1" documentada [S]

## 2. Diseñar API (2º)

- [ ] Definir API data-first v1 (sin scripts) [M]
- [ ] Definir dominios modables: objetos/items [S]
- [ ] Definir dominios modables: recetas [S]
- [ ] Definir dominios modables: biomas/vegetación [S]
- [ ] Definir dominios modables: misiones secundarias [S]
- [ ] Definir dominios modables: NPC nuevos [S]
- [ ] Definir dominios modables: tiendas/economía [S]
- [ ] Definir dominios modables: clima/estaciones [S]
- [ ] Definir dominios modables: texturas/paletas [S]
- [ ] Definir NO modables: mundo core, sellos, IA, física [M]
- [ ] Definir scripting v2 con whitelist firmada (opcional) [C]

## 3. Definir formato de mods (3º)

- [ ] Definir paquete zip/.mod con manifest.json [M]
- [ ] Definir campos del manifiesto (id, versión, minBuild, author, override) [M]
- [ ] Definir esquema data idéntico al de M108 [M]
- [ ] Definir carpeta assets/ con referencias por id [M]
- [ ] Definir readme obligatorio en el paquete [S]
- [ ] Definir límite 100 MB por mod [S]
- [ ] Definir límite 100 mods simultáneos [S]
- [ ] Definir límite 10 MB de assets por dominio [S]

## 4. Definir seguridad (4º)

- [ ] Definir validación de datos al cargar (M109 validators) [M]
- [ ] Definir sin ejecución de scripts en v1 [M]
- [ ] Definir v2: scripts solo con hash aprobado (M106) [C]
- [ ] Definir rechazo de paquete corrupto con error claro [M]
- [ ] Definir no acceso a la red por parte de mods [M]
- [ ] Definir aislamiento de paths (sin path traversal) [C]
- [ ] Definir log de mods cargados (M103) [S]

## 5. Definir carga de mods (5º)

- [ ] Definir ModLoader al boot (M63) [C]
- [ ] Definir orden de carga: base < ui < contenido < override [M]
- [ ] Definir validación previa al montaje por mod [M]
- [ ] Definir mod inválido omitido con reporte [M]
- [ ] Definir recarga en caliente solo para contenido [M]
- [ ] Definir reinicio obligatorio para scripts v2 [S]
- [ ] Definir tiempo de carga objetivo < 5 s con 100 mods [M]

## 6. Definir conflictos (6º)

- [ ] Definir detección de ids duplicados sin override [M]
- [ ] Definir comportamiento: menor prioridad se omite + warning [M]
- [ ] Definir override explícito en manifest gana [M]
- [ ] Definir reporte de conflictos en pantalla Mods (M89) [M]
- [ ] Definir códigos de error por caso [S]
- [ ] Definir 0 conflictos no detectados en pruebas [M]

## 7. Definir compatibilidad (7º)

- [ ] Definir semver de mods contra build (M117) [M]
- [ ] Definir mod con minBuild mayor → bloqueado [M]
- [ ] Definir mod con versión baja → warning [S]
- [ ] Definir incompatibilidad por funciones inexistentes → advertencia en gate [M]
- [ ] Definir regla de compatibilidad con updates (M118) [S]

## 8. Definir herramientas (8º)

- [ ] Definir exportador "Exportar a Mod" en editores de M109 [C]
- [ ] Definir CLI modchecker (validate) en CI [M]
- [ ] Definir reutilización de DataValidator con reglas de mod [M]
- [ ] Definir vista de previsualización del paquete [S]
- [ ] Definir documentación de uso de las herramientas [M]

## 9. Definir documentación (9º)

- [ ] Definir guía "Crear tu primer mod" (web M99) [M]
- [ ] Definir esquema JSON de ejemplo por dominio [M]
- [ ] Definir 1 mod de ejemplo funcional (cultivo + receta) [C]
- [ ] Definir FAQ de modding (M100) [S]
- [ ] Definir documentación de límites y políticas [S]

## 10. Definir distribución (10º)

- [ ] Definir solo Steam Workshop para distribución oficial [M]
- [ ] Definir no tienda propia de mods en V2 [S]
- [ ] Definir actualización de mods por Workshop [M]
- [ ] Definir integración con M97 (Steamworks) [M]
- [ ] Definir moderación de mods (reportes → M100) [M]
- [ ] Definir límite de tamaños del Workshop (100 MB) [S]

## 11. Definir workshop si corresponde (11º)

- [ ] Definir soporte Workshop vía Steamworks API [C]
- [ ] Definir appid y región del Workshop [S]
- [ ] Definir telemetría de subscripciones (M104) sin datos personales [M]
- [ ] Definir lista negra de mods retirados [M]
- [ ] Definir notificación de actualización de mods [S]

## 12. Definir límites (12º)

- [ ] Definir dominios modables (whitelist) [M]
- [ ] Definir tamaño por mod (100 MB) y por assets (10 MB) [S]
- [ ] Definir máximo de mods simultáneos (100) [S]
- [ ] Definir límite de override por mod [S]
- [ ] Definir límite de entidades por mod (npc/items) [S]

## 13. Definir saves con mods (13º)

- [ ] Definir marca `modsActive[]` en save v3.x (M59) [M]
- [ ] Definir carga de save con mods sin loader → advertencia [M]
- [ ] Definir opciones: continuar / activar mods [M]
- [ ] Definir guardado de save con mods: marca y versión [M]
- [ ] Definir backup del save antes de cargar mods nuevos (M107) [M]
- [ ] Definir icono visual de "mundo con mods" en slots (M89) [S]
- [ ] Definir logros desactivados en sesiones con mods (M72) [M]
- [ ] Definir 100 ciclos de prueba de carga con mods [M]

## 14. Definir soporte oficial (14º)

- [ ] Definir triaje: bugs con mods SOLO si reproducen sin mods [M]
- [ ] Definir flag `--no-mods` de soporte [S]
- [ ] Definir SLA de respuesta 72 h a issues de mods (V2) [S]
- [ ] Definir canal #modding en Discord (M100) [S]
- [ ] Definir exclusiones de soporte (mods maliciosos/corruptos) [S]
- [ ] Definir base de conocimientos de mods en web [M]

## 15. Evaluar coste técnico (15º)

- [ ] Definir estimación: ModLoader+manifiesto+conflictos (80-120 h) [M]
- [ ] Definir estimación: validación de mods (30-50 h) [M]
- [ ] Definir estimación: exportadores M109 (40-60 h) [M]
- [ ] Definir estimación: saves con mods (20-30 h) [M]
- [ ] Definir estimación: Workshop+telemetría (40-60 h) [M]
- [ ] Definir estimación: docs+ejemplo+soporte (30-40 h) [M]
- [ ] Definir total estimado 240-360 h (< 10% presupuesto) [M]
- [ ] Definir tracking de horas reales en V2 contra la estimación [S]
- [ ] Definir re-evaluación del GATE tras el tracking [S]

## 16. Calidad y cierre

- [ ] Definir notificación de mods en telemetría (flag) [S]
- [ ] Definir separación del loader del gameplay core [M]
- [ ] Definir documentación plan-actual actualizada y firmada [S]
- [ ] Definir log del módulo en Logs/ [S]
- [ ] Definir feed a V2 roadmap (M136) y M100 [S]

## Totales

**Total de ítems:** 106
**Ítems resueltos por documentación:** 106 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)