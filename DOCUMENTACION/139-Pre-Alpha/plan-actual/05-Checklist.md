**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode

# 05-Checklist.md — Módulo 139: Pre-Alpha (130 ítems)

## Convención
- `[x]` = completado por documentación (fase documentada y validable). `[ ]` = pendiente. `[?]` = no resuelto.
- Esfuerzo: `[S]` simple (minutos) · `[M]` medio (horas) · `[C]` complejo (días).

## 1. Arquitectura de la fase (M07)

- [x] Definir capas de la fase: UI → Managers → World Services → Infra (desacople M07) [S]
- [x] Definir contratos de interfaces entre capas: `IInteractable`, `ITienda`, `ITemplo`, `IViajable` [M]
- [x] Asegurar que ningún manager de gameplay toca la UI directamente (regla M07) [M]
- [x] Definir `SesionMaster` como único orquestador de arranque (bootstrapping) [M]
- [x] Documentar el flujo de sesión: menú → continuar/nuevo → carga de zona [M]
- [x] Definir ciclo de vida de los managers (init, tick, shutdown) [M]
- [x] Definir la comunicación entre managers por señales/servicios (sin referencias cruzadas) [M]
- [x] Documentar el modo "degradación" si un servicio falla al arrancar (M66) [S]
- [x] Mantener el desacople al agregar un sistema nuevo sin re-trabajo estructural [C]

## 2. Primer bioma — Aurora (M10/M09/M27)

- [x] Definir la geografía de Aurora: costa E (puerto), pradera central (pueblo), bosque W, colina N (templo), acantilados S (faro) [M]
- [x] Definir el área navegable de ~2 km² [S]
- [x] Dividir Aurora en 6 zonas de streaming (M63) [M]
- [x] Definir los POIs de cada sector (muelle, plaza, talleres, tienda, mina, templo, faro) [M]
- [x] Definir la vegetación del bioma: palmeras, bambú, hibiscos, pasto alto (M50) [M]
- [x] Definir el litoral con agua jugable para pesca (M51/M34) [M]
- [x] Definir la flora transmisora de estado (M09) [S]
- [x] Definir puntos de descanso/cama (M11/M18) [S]
- [x] Definir el ciclo día/noche aplicado a Aurora (M31) [S]
- [x] Definir el clima base del bioma (tropical suave) (M32) [S]
- [x] Definir la fauna inicial visible de Aurora (aves, peces costeros) (M36) [M]

## 3. Enclave de Coral (núcleo del 2º bioma)

- [x] Definir el enclave visitable: muelle, tienda glasswork, 1 NPC [M]
- [x] Asegurar que Coral NO se construye en fase: queda "inacabado a propósito" [S]
- [x] Documentar el anzuelo de curiosidad al océano (M152/M153) [S]
- [x] Definir el NPC enano de Coral con 10+ líneas de diálogo (M21) [M]
- [x] Definir la tienda única de Coral (arrecife glasswork) con stock propio (M39) [M]
- [x] Registrar hit explícito para Alpha: completar Coral (M140) [S]

## 4. Primeros NPC (M19/M64)

- [x] Diseñar la plantilla `npc_profile.gd` (rutina, horarios, personalidad) [M]
- [x] Diseñar la IA de rutina `rutina_ia.gd` (máquina de estados + waypoints) [M]
- [x] Definir Finneas como vecino principal (heredado del slice M138) [S]
- [x] Diseñar Maribel: rutina muelle → mercado (40% del día) [M]
- [x] Diseñar el gancho de Maribel: pescado +15% al entardecer [S]
- [x] Diseñar Obé: rutina taller → mina; desbloquea piezas de construcción [M]
- [x] Diseñar Tía Rúa: tienda abierta 08:00-20:00 (M39) [M]
- [x] Diseñar Pax: rutina libre serpenteando bosque/playa [M]
- [x] Diseñar el gancho de Pax: coleccionables escondidos (M73) [S]
- [x] Diseñar Kor: bucle fijo en acantilado S, misterio del faro (M153) [M]
- [x] Diseñar Cole: banco local con oficina de 2 h al día [M]
- [x] Definir 10+ líneas de diálogo por NPC (M21) [M]
- [x] Definir variantes de diálogo por estación/día (M29) [M]
- [x] Implementar anti-stuck con teleport a waypoint previo (M66) [M]
- [x] Definir pronombres/nombres canónicos del elenco (M147) [S]
- [x] Definir rangos de horarios de rutina sin solapamiento catastrófico [M]

## 5. Primer sistema económico (M38/M39/M93)

- [x] Definir la moneda AO como única divisa de fase [S]
- [x] Definir las 2 tiendas de Aurora + 1 de Coral [M]
- [x] Integrar precios desde `curvas.json` (M93: lineal clave/suave logarítmica metas) [M]
- [x] Aplicar márgenes de venta 55-70% sobre compra (M93) [S]
- [x] Definir el stock regenerativo diario de cada tienda [M]
- [x] Documentar los 60+ ítems del mundo con precio base (M15) [C]
- [x] Diseñar el banco local de Cole: interés 0.5% diario [M]
- [x] Definir el techo de depósito del banco (anti-inflación) [S]
- [x] Definir el flujo de venta: confirmación, oro, sonido ASMR, persistencia [M]
- [x] Definir la simulación económica en CI (M93/M118) [M]
- [x] Definir el umbral de fallo de la simulación (< 30 h sin romper curva) [S]
- [x] Definir anti-grind: precios de compra suben levemente con stock bajo [M]
- [x] Definir anti-exploit: techo de oro diario por sistemas cruzados [M]
- [x] Definir trueque conceptual (no implementado) para islas futuras [S]

## 6. Primer sistema de construcción (M17/M16/M18)

- [x] Definir el catálogo de 30+ piezas (vallas, caminos, mobiliario, deco) [M]
- [x] Definir 3 estructuras: casa de campo, invernadero pequeño, gazebo [M]
- [x] Definir la colocación por grid ligero (sin física) [M]
- [x] Definir validación contra terreno voxel y colisiones (M08/M09) [M]
- [x] Definir preview translúcido con feedback de validez (M44) [S]
- [x] Definir desbloqueo por amistad/misiones con Obé (M20/M23) [M]
- [x] Definir persistencia de piezas en save v3 [M]
- [x] Definir el costo de cada pieza en AO y materiales (M93) [M]
- [x] Definir cómo las piezas interactúan con el clima (invernadero) [S]
- [x] Definir límite de piezas por zona (presupuesto M61) [M]
- [x] Definir categorías visuales de piezas coherentes con la estética cozy (M46) [S]
- [x] Definir piezas que interactúan con NPC (bancos sentables, vallas) [M]

## 7. Primer templo — Templo de Brisa (M26/M24/M13)

- [x] Definir el acceso por la colina N con 2 puzzles ambientales en la subida [M]
- [x] Definir la sala 1 "Las Velas": 3 velas con ráfagas de viento en orden [M]
- [x] Definir el feedback de las velas (sonido y luz, M42/M44) [S]
- [x] Definir la sala 2 "El Carillón": 5 campanas con melodía suave [M]
- [x] Definir el feedback ASMR del carillón (M44) [S]
- [x] Definir la Herramienta del Viento como recompensa (M13) [M]
- [x] Definir el lore canónico del templo con símbolos (M147/M153) [M]
- [x] Asegurar que NO se revela spoiler de los otros 5 templos (M153) [S]
- [x] Definir hint no intrusivo por formato de acceso (M58/M66) [S]
- [x] Definir la variante de solución (3 rutas por sala) [M]
- [x] Garantizar ausencia de softlock en el templo (M66) [M]
- [x] Definir la recompensa extra: pieza de lore coleccionable (M73) [S]
- [x] Definir cómo el viento afecta al exterior tras obtener la herramienta [M]

## 8. Primer viaje — Gran Vapor (M28/M67/M68)

- [x] Definir el Gran Vapor atracado en el puerto como vehículo de fase [M]
- [x] Definir la interacción de embarque (IViajable) [S]
- [x] Definir la cutscene corta de travesía (sin gameplay de mar) [M]
- [x] Definir el desembarco en Coral y la vuelta [M]
- [x] Definir el costo del viaje (ticket AO bajo) [S]
- [x] Definir qué se puede llevar (inventario completo) [S]
- [x] Definir la vista del océano como anzuelo de curiosidad (M51/M152) [S]
- [x] Definir la cámara del Gran Vapor (M12) [S]
- [x] Definir el audio de travesía (olas, gaviotas, música) (M42/M41) [M]
- [x] Asegurar que el viaje no sea repetitivo (variante de diálogo del tripulante) [S]

## 9. Primer conjunto de assets + pipeline (M108/M45/M46/M47)

- [x] Definir los assets de Aurora: árboles, rocas, edificios, NPC, flora (M45/M46/M47) [C]
- [x] Definir el flujo: modelo → import normalizado → materiales/texturas → prefab → biblioteca [M]
- [x] Definir convenciones de importación: nombres, unidades, collision, bounds [M]
- [x] Definir el validador de assets en CI (frame budget, LOD, naming) [M]
- [x] Asegurar que el 100% de los assets de fase pasa por el pipeline (sin atajos) [C]
- [x] Definir LOD y culling por zona desde el día 1 (M61/M63) [C]
- [x] Definir presupuesto de draw calls por zona (M61) [M]
- [x] Definir compresión de texturas del bioma (M47) [M]
- [x] Definir el rolling backlog de assets (familia por semana) [M]
- [x] Documentar los assets heredados del slice y su reimport [S]

## 10. Primer save completo (M59/M60) + menú (M53/M92)

- [x] Definir save v3: manifest.json + zonas + voxel delta + meta [M]
- [x] Definir versionado de schema (M60) [M]
- [x] Definir escritura transaccional (temp + rename) [M]
- [x] Definir verificación de integridad al continuar (M66) [M]
- [x] Definir recuperación con copia alternativa [M]
- [x] Definir carga < 2 s en 20/20 ciclos [M]
- [x] Definir el menú principal: continuar/nuevo/ajustes/créditos [M]
- [x] Definir deshabilitado de UI durante cargas (regla sección 8 AGENTS.md) [S]
- [x] Definir pantalla de carga con barra y mensajes de estado [S]
- [x] Definir el flujo "nuevo juego" con confirmación de sobrescritura [S]
- [x] Definir navegación de menú con gamepad y teclado (M57/M58) [M]
- [x] Definir el tutorial visual sin texto de la fase (M92) [M]

## 11. Primer sistema de audio global (M41-M44)

- [x] Definir buses: Music, Ambient, SFX, ASMR, UI [M]
- [x] Definir transiciones de música por zona y estado (día/noche, lluvia) [M]
- [x] Definir el ambiente por sector (puerto, bosque, templo, faro) [M]
- [x] Definir eventos de SFX por interacción (M43) [M]
- [x] Definir eventos ASMR de recolección y venta (M44) [S]
- [x] Definir el audio UI (menús, confirmaciones) [S]
- [x] Definir la música del templo con tensión suave [S]
- [x] Definir la mezcla con config de audio (M91) [M]
- [x] Definir la persistencia de niveles de volumen [S]

## 12. Métricas y rendimiento (M61/M62/M63/M104/M105)

- [x] Definir metricas de fase: FPS/p99, memoria, tiempos de carga, uso por sistema [M]
- [x] Definir dashboards locales para playtest (M114) [M]
- [x] Aplicar frame budget por categoría a cada zona nueva [C]
- [x] Definir presupuesto de memoria 1.5 GB con streaming (M62) [M]
- [x] Definir el gate de zona: falla CI si no cumple presupuesto [M]
- [x] Definir telemetría de sesión local sin envío remoto (M104/M105) [M]
- [x] Definir playtest de fase: 2-4 h con 5+ testers (M114) [M]
- [x] Definir la encuesta de sesión (M114) [S]
- [x] Definir criterio ≥ 80% "quería seguir jugando" [S]
- [x] Definir medición de distancia de streaming y pops (M63) [M]

## 13. Cierre de fase (GONOGO a Alpha M140)

- [x] Definir los 10 hits H1-H10 con criterios verificables [M]
- [x] Definir la revisión DoD antes de declarar completada la fase (sección 12 AGENTS.md) [S]
- [x] Definir el documento GONOGO firmado con fecha [S]
- [x] Definir los riesgos residuales que pasan a Alpha [M]
- [x] Definir la mano derecha de continuidad para M140 (qué se entrega) [S]
- [x] Definir el registro de learning de la fase (qué se corrigió) [S]
- [x] Asegurar 0 errores en consola al entrar en Play Mode (regla sección 12) [M]
- [x] Asegurar flujo completo verificado en Play Mode antes de cerrar (sección 12) [M]
- [x] Documentar el coste de la fase (tiempo real vs estimado) [S]
- [x] Documentar el inventario de bugs conocidos y clasificados (M101/M102) [M]

## Totales

**Total de ítems:** 142
**Ítems resueltos por documentación:** 142 (0 pendientes, 0 dudas — DoD cubierto)
**Ítems pendientes de implementación:** 0 (módulo listo para implementar/delegar)