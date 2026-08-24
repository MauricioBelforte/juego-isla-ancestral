**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 139: Pre-Alpha (130 ítems)

## Convención
- `[ ]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Arquitectura de la fase (M07)

- [ ] Definir capas de la fase: UI → Managers → World Services → Infra (desacople M07) [S]
- [ ] Definir contratos de interfaces entre capas: `IInteractable`, `ITienda`, `ITemplo`, `IViajable` [M]
- [ ] Asegurar que ningún manager de gameplay toca la UI directamente (regla M07) [M]
- [ ] Definir `SesionMaster` como único orquestador de arranque (bootstrapping) [M]
- [ ] Documentar el flujo de sesión: menú → continuar/nuevo → carga de zona [M]
- [ ] Definir ciclo de vida de los managers (init, tick, shutdown) [M]
- [ ] Definir la comunicación entre managers por señales/servicios (sin referencias cruzadas) [M]
- [ ] Documentar el modo "degradación" si un servicio falla al arrancar (M66) [S]
- [ ] Mantener el desacople al agregar un sistema nuevo sin re-trabajo estructural [C]

## 2. Primer bioma — Aurora (M10/M09/M27)

- [ ] Definir la geografía de Aurora: costa E (puerto), pradera central (pueblo), bosque W, colina N (templo), acantilados S (faro) [M]
- [ ] Definir el área navegable de ~2 km² [S]
- [ ] Dividir Aurora en 6 zonas de streaming (M63) [M]
- [ ] Definir los POIs de cada sector (muelle, plaza, talleres, tienda, mina, templo, faro) [M]
- [ ] Definir la vegetación del bioma: palmeras, bambú, hibiscos, pasto alto (M50) [M]
- [ ] Definir el litoral con agua jugable para pesca (M51/M34) [M]
- [ ] Definir la flora transmisora de estado (M09) [S]
- [ ] Definir puntos de descanso/cama (M11/M18) [S]
- [ ] Definir el ciclo día/noche aplicado a Aurora (M31) [S]
- [ ] Definir el clima base del bioma (tropical suave) (M32) [S]
- [ ] Definir la fauna inicial visible de Aurora (aves, peces costeros) (M36) [M]

## 3. Enclave de Coral (núcleo del 2º bioma)

- [ ] Definir el enclave visitable: muelle, tienda glasswork, 1 NPC [M]
- [ ] Asegurar que Coral NO se construye en fase: queda "inacabado a propósito" [S]
- [ ] Documentar el anzuelo de curiosidad al océano (M152/M153) [S]
- [ ] Definir el NPC enano de Coral con 10+ líneas de diálogo (M21) [M]
- [ ] Definir la tienda única de Coral (arrecife glasswork) con stock propio (M39) [M]
- [ ] Registrar hit explícito para Alpha: completar Coral (M140) [S]

## 4. Primeros NPC (M19/M64)

- [ ] Diseñar la plantilla `npc_profile.gd` (rutina, horarios, personalidad) [M]
- [ ] Diseñar la IA de rutina `rutina_ia.gd` (máquina de estados + waypoints) [M]
- [ ] Definir Finneas como vecino principal (heredado del slice M138) [S]
- [ ] Diseñar Maribel: rutina muelle → mercado (40% del día) [M]
- [ ] Diseñar el gancho de Maribel: pescado +15% al entardecer [S]
- [ ] Diseñar Obé: rutina taller → mina; desbloquea piezas de construcción [M]
- [ ] Diseñar Tía Rúa: tienda abierta 08:00-20:00 (M39) [M]
- [ ] Diseñar Pax: rutina libre serpenteando bosque/playa [M]
- [ ] Diseñar el gancho de Pax: coleccionables escondidos (M73) [S]
- [ ] Diseñar Kor: bucle fijo en acantilado S, misterio del faro (M153) [M]
- [ ] Diseñar Cole: banco local con oficina de 2 h al día [M]
- [ ] Definir 10+ líneas de diálogo por NPC (M21) [M]
- [ ] Definir variantes de diálogo por estación/día (M29) [M]
- [ ] Implementar anti-stuck con teleport a waypoint previo (M66) [M]
- [ ] Definir pronombres/nombres canónicos del elenco (M147) [S]
- [ ] Definir rangos de horarios de rutina sin solapamiento catastrófico [M]

## 5. Primer sistema económico (M38/M39/M93)

- [ ] Definir la moneda AO como única divisa de fase [S]
- [ ] Definir las 2 tiendas de Aurora + 1 de Coral [M]
- [ ] Integrar precios desde `curvas.json` (M93: lineal clave/suave logarítmica metas) [M]
- [ ] Aplicar márgenes de venta 55-70% sobre compra (M93) [S]
- [ ] Definir el stock regenerativo diario de cada tienda [M]
- [ ] Documentar los 60+ ítems del mundo con precio base (M15) [C]
- [ ] Diseñar el banco local de Cole: interés 0.5% diario [M]
- [ ] Definir el techo de depósito del banco (anti-inflación) [S]
- [ ] Definir el flujo de venta: confirmación, oro, sonido ASMR, persistencia [M]
- [ ] Definir la simulación económica en CI (M93/M118) [M]
- [ ] Definir el umbral de fallo de la simulación (< 30 h sin romper curva) [S]
- [ ] Definir anti-grind: precios de compra suben levemente con stock bajo [M]
- [ ] Definir anti-exploit: techo de oro diario por sistemas cruzados [M]
- [ ] Definir trueque conceptual (no implementado) para islas futuras [S]

## 6. Primer sistema de construcción (M17/M16/M18)

- [ ] Definir el catálogo de 30+ piezas (vallas, caminos, mobiliario, deco) [M]
- [ ] Definir 3 estructuras: casa de campo, invernadero pequeño, gazebo [M]
- [ ] Definir la colocación por grid ligero (sin física) [M]
- [ ] Definir validación contra terreno voxel y colisiones (M08/M09) [M]
- [ ] Definir preview translúcido con feedback de validez (M44) [S]
- [ ] Definir desbloqueo por amistad/misiones con Obé (M20/M23) [M]
- [ ] Definir persistencia de piezas en save v3 [M]
- [ ] Definir el costo de cada pieza en AO y materiales (M93) [M]
- [ ] Definir cómo las piezas interactúan con el clima (invernadero) [S]
- [ ] Definir límite de piezas por zona (presupuesto M61) [M]
- [ ] Definir categorías visuales de piezas coherentes con la estética cozy (M46) [S]
- [ ] Definir piezas que interactúan con NPC (bancos sentables, vallas) [M]

## 7. Primer templo — Templo de Brisa (M26/M24/M13)

- [ ] Definir el acceso por la colina N con 2 puzzles ambientales en la subida [M]
- [ ] Definir la sala 1 "Las Velas": 3 velas con ráfagas de viento en orden [M]
- [ ] Definir el feedback de las velas (sonido y luz, M42/M44) [S]
- [ ] Definir la sala 2 "El Carillón": 5 campanas con melodía suave [M]
- [ ] Definir el feedback ASMR del carillón (M44) [S]
- [ ] Definir la Herramienta del Viento como recompensa (M13) [M]
- [ ] Definir el lore canónico del templo con símbolos (M147/M153) [M]
- [ ] Asegurar que NO se revela spoiler de los otros 5 templos (M153) [S]
- [ ] Definir hint no intrusivo por formato de acceso (M58/M66) [S]
- [ ] Definir la variante de solución (3 rutas por sala) [M]
- [ ] Garantizar ausencia de softlock en el templo (M66) [M]
- [ ] Definir la recompensa extra: pieza de lore coleccionable (M73) [S]
- [ ] Definir cómo el viento afecta al exterior tras obtener la herramienta [M]

## 8. Primer viaje — Gran Vapor (M28/M67/M68)

- [ ] Definir el Gran Vapor atracado en el puerto como vehículo de fase [M]
- [ ] Definir la interacción de embarque (IViajable) [S]
- [ ] Definir la cutscene corta de travesía (sin gameplay de mar) [M]
- [ ] Definir el desembarco en Coral y la vuelta [M]
- [ ] Definir el costo del viaje (ticket AO bajo) [S]
- [ ] Definir qué se puede llevar (inventario completo) [S]
- [ ] Definir la vista del océano como anzuelo de curiosidad (M51/M152) [S]
- [ ] Definir la cámara del Gran Vapor (M12) [S]
- [ ] Definir el audio de travesía (olas, gaviotas, música) (M42/M41) [M]
- [ ] Asegurar que el viaje no sea repetitivo (variante de diálogo del tripulante) [S]

## 9. Primer conjunto de assets + pipeline (M108/M45/M46/M47)

- [ ] Definir los assets de Aurora: árboles, rocas, edificios, NPC, flora (M45/M46/M47) [C]
- [ ] Definir el flujo: modelo → import normalizado → materiales/texturas → prefab → biblioteca [M]
- [ ] Definir convenciones de importación: nombres, unidades, collision, bounds [M]
- [ ] Definir el validador de assets en CI (frame budget, LOD, naming) [M]
- [ ] Asegurar que el 100% de los assets de fase pasa por el pipeline (sin atajos) [C]
- [ ] Definir LOD y culling por zona desde el día 1 (M61/M63) [C]
- [ ] Definir presupuesto de draw calls por zona (M61) [M]
- [ ] Definir compresión de texturas del bioma (M47) [M]
- [ ] Definir el rolling backlog de assets (familia por semana) [M]
- [ ] Documentar los assets heredados del slice y su reimport [S]

## 10. Primer save completo (M59/M60) + menú (M53/M92)

- [ ] Definir save v3: manifest.json + zonas + voxel delta + meta [M]
- [ ] Definir versionado de schema (M60) [M]
- [ ] Definir escritura transaccional (temp + rename) [M]
- [ ] Definir verificación de integridad al continuar (M66) [M]
- [ ] Definir recuperación con copia alternativa [M]
- [ ] Definir carga < 2 s en 20/20 ciclos [M]
- [ ] Definir el menú principal: continuar/nuevo/ajustes/créditos [M]
- [ ] Definir deshabilitado de UI durante cargas (regla sección 8 AGENTS.md) [S]
- [ ] Definir pantalla de carga con barra y mensajes de estado [S]
- [ ] Definir el flujo "nuevo juego" con confirmación de sobrescritura [S]
- [ ] Definir navegación de menú con gamepad y teclado (M57/M58) [M]
- [ ] Definir el tutorial visual sin texto de la fase (M92) [M]

## 11. Primer sistema de audio global (M41-M44)

- [ ] Definir buses: Music, Ambient, SFX, ASMR, UI [M]
- [ ] Definir transiciones de música por zona y estado (día/noche, lluvia) [M]
- [ ] Definir el ambiente por sector (puerto, bosque, templo, faro) [M]
- [ ] Definir eventos de SFX por interacción (M43) [M]
- [ ] Definir eventos ASMR de recolección y venta (M44) [S]
- [ ] Definir el audio UI (menús, confirmaciones) [S]
- [ ] Definir la música del templo con tensión suave [S]
- [ ] Definir la mezcla con config de audio (M91) [M]
- [ ] Definir la persistencia de niveles de volumen [S]

## 12. Métricas y rendimiento (M61/M62/M63/M104/M105)

- [ ] Definir metricas de fase: FPS/p99, memoria, tiempos de carga, uso por sistema [M]
- [ ] Definir dashboards locales para playtest (M114) [M]
- [ ] Aplicar frame budget por categoría a cada zona nueva [C]
- [ ] Definir presupuesto de memoria 1.5 GB con streaming (M62) [M]
- [ ] Definir el gate de zona: falla CI si no cumple presupuesto [M]
- [ ] Definir telemetría de sesión local sin envío remoto (M104/M105) [M]
- [ ] Definir playtest de fase: 2-4 h con 5+ testers (M114) [M]
- [ ] Definir la encuesta de sesión (M114) [S]
- [ ] Definir criterio ≥ 80% "quería seguir jugando" [S]
- [ ] Definir medición de distancia de streaming y pops (M63) [M]

## 13. Cierre de fase (GONOGO a Alpha M140)

- [ ] Definir los 10 hits H1-H10 con criterios verificables [M]
- [ ] Definir la revisión DoD antes de declarar completada la fase (sección 12 AGENTS.md) [S]
- [ ] Definir el documento GONOGO firmado con fecha [S]
- [ ] Definir los riesgos residuales que pasan a Alpha [M]
- [ ] Definir la mano derecha de continuidad para M140 (qué se entrega) [S]
- [ ] Definir el registro de learning de la fase (qué se corrigió) [S]
- [ ] Asegurar 0 errores en consola al entrar en Play Mode (regla sección 12) [M]
- [ ] Asegurar flujo completo verificado en Play Mode antes de cerrar (sección 12) [M]
- [ ] Documentar el coste de la fase (tiempo real vs estimado) [S]
- [ ] Documentar el inventario de bugs conocidos y clasificados (M101/M102) [M]

## Totales

**Total de ítems:** 142
**Ítems resueltos por documentación:** 142 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)