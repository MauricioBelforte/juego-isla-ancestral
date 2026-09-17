# Tareas módulo 139 139-Pre-Alpha

**Estado:** ðŸŸ¢ Disponible

**Items pendientes:** 130

[ ] T-139-001: Definir contratos de interfaces entre capas: `IInteractable`, `ITienda`, `ITemplo`, `IViajable`
[ ] T-139-002: Definir `SesionMaster` como único orquestador de arranque (bootstrapping)
[ ] T-139-003: Documentar el flujo de sesión: menú → continuar/nuevo → carga de zona
[ ] T-139-004: Documentar el modo "degradación" si un servicio falla al arrancar (M66)
[ ] T-139-005: Definir la geografía de Aurora: costa E (puerto), pradera central (pueblo), bosque W, colina N (templo), acantilados S (faro)
[ ] T-139-006: Definir el área navegable de ~2 km²
[ ] T-139-007: Dividir Aurora en 6 zonas de streaming (M63)
[ ] T-139-008: Definir los POIs de cada sector (muelle, plaza, talleres, tienda, mina, templo, faro)
[ ] T-139-009: Definir la vegetación del bioma: palmeras, bambú, hibiscos, pasto alto (M50)
[ ] T-139-010: Definir el litoral con agua jugable para pesca (M51/M34)
[ ] T-139-011: Definir la flora transmisora de estado (M09)
[ ] T-139-012: Definir puntos de descanso/cama (M11/M18)
[ ] T-139-013: Definir el ciclo día/noche aplicado a Aurora (M31)
[ ] T-139-014: Definir el clima base del bioma (tropical suave) (M32)
[ ] T-139-015: Definir la fauna inicial visible de Aurora (aves, peces costeros) (M36)
[ ] T-139-016: Definir el enclave visitable: muelle, tienda glasswork, 1 NPC
[ ] T-139-017: Asegurar que Coral NO se construye en fase: queda "inacabado a propósito"
[ ] T-139-018: Documentar el anzuelo de curiosidad al océano (M152/M153)
[ ] T-139-019: Definir el NPC enano de Coral con 10+ líneas de diálogo (M21)
[ ] T-139-020: Definir la tienda única de Coral (arrecife glasswork) con stock propio (M39)
[ ] T-139-021: Registrar hit explícito para Alpha: completar Coral (M140)
[ ] T-139-022: Diseñar la plantilla `npc_profile.gd` (rutina, horarios, personalidad)
[ ] T-139-023: Diseñar la IA de rutina `rutina_ia.gd` (máquina de estados + waypoints)
[ ] T-139-024: Definir Finneas como vecino principal (heredado del slice M138)
[ ] T-139-025: Diseñar Maribel: rutina muelle → mercado (40% del día)
[ ] T-139-026: Diseñar el gancho de Maribel: pescado +15% al entardecer
[ ] T-139-027: Diseñar Obé: rutina taller → mina; desbloquea piezas de construcción
[ ] T-139-028: Diseñar Tía Rúa: tienda abierta 08:00-20:00 (M39)
[ ] T-139-029: Diseñar Pax: rutina libre serpenteando bosque/playa
[ ] T-139-030: Diseñar el gancho de Pax: coleccionables escondidos (M73)
[ ] T-139-031: Diseñar Kor: bucle fijo en acantilado S, misterio del faro (M153)
[ ] T-139-032: Diseñar Cole: banco local con oficina de 2 h al día
[ ] T-139-033: Definir 10+ líneas de diálogo por NPC (M21)
[ ] T-139-034: Definir variantes de diálogo por estación/día (M29)
[ ] T-139-035: Definir pronombres/nombres canónicos del elenco (M147)
[ ] T-139-036: Definir rangos de horarios de rutina sin solapamiento catastrófico
[ ] T-139-037: Definir la moneda AO como única divisa de fase
[ ] T-139-038: Definir las 2 tiendas de Aurora + 1 de Coral
[ ] T-139-039: Aplicar márgenes de venta 55-70% sobre compra (M93)
[ ] T-139-040: Definir el stock regenerativo diario de cada tienda
[ ] T-139-041: Documentar los 60+ ítems del mundo con precio base (M15)
[ ] T-139-042: Diseñar el banco local de Cole: interés 0.5% diario
[ ] T-139-043: Definir el techo de depósito del banco (anti-inflación)
[ ] T-139-044: Definir el flujo de venta: confirmación, oro, sonido ASMR, persistencia
[ ] T-139-045: Definir la simulación económica en CI (M93/M118)
[ ] T-139-046: Definir el umbral de fallo de la simulación (< 30 h sin romper curva)
[ ] T-139-047: Definir anti-grind: precios de compra suben levemente con stock bajo
[ ] T-139-048: Definir el catálogo de 30+ piezas (vallas, caminos, mobiliario, deco)
[ ] T-139-049: Definir 3 estructuras: casa de campo, invernadero pequeño, gazebo
[ ] T-139-050: Definir la colocación por grid ligero (sin física)
[ ] T-139-051: Definir validación contra terreno voxel y colisiones (M08/M09)
[ ] T-139-052: Definir preview translúcido con feedback de validez (M44)
[ ] T-139-053: Definir desbloqueo por amistad/misiones con Obé (M20/M23)
[ ] T-139-054: Definir persistencia de piezas en save v3
[ ] T-139-055: Definir el costo de cada pieza en AO y materiales (M93)
[ ] T-139-056: Definir cómo las piezas interactúan con el clima (invernadero)
[ ] T-139-057: Definir límite de piezas por zona (presupuesto M61)
[ ] T-139-058: Definir categorías visuales de piezas coherentes con la estética cozy (M46)
[ ] T-139-059: Definir piezas que interactúan con NPC (bancos sentables, vallas)
[ ] T-139-060: Definir el acceso por la colina N con 2 puzzles ambientales en la subida
[ ] T-139-061: Definir la sala 1 "Las Velas": 3 velas con ráfagas de viento en orden
[ ] T-139-062: Definir el feedback de las velas (sonido y luz, M42/M44)
[ ] T-139-063: Definir la sala 2 "El Carillón": 5 campanas con melodía suave
[ ] T-139-064: Definir el feedback ASMR del carillón (M44)
[ ] T-139-065: Definir la Herramienta del Viento como recompensa (M13)
[ ] T-139-066: Definir el lore canónico del templo con símbolos (M147/M153)
[ ] T-139-067: Asegurar que NO se revela spoiler de los otros 5 templos (M153)
[ ] T-139-068: Definir hint no intrusivo por formato de acceso (M58/M66)
[ ] T-139-069: Definir la variante de solución (3 rutas por sala)
[ ] T-139-070: Garantizar ausencia de softlock en el templo (M66)
[ ] T-139-071: Definir la recompensa extra: pieza de lore coleccionable (M73)
[ ] T-139-072: Definir cómo el viento afecta al exterior tras obtener la herramienta
[ ] T-139-073: Definir el Gran Vapor atracado en el puerto como vehículo de fase
[ ] T-139-074: Definir la interacción de embarque (IViajable)
[ ] T-139-075: Definir la cutscene corta de travesía (sin gameplay de mar)
[ ] T-139-076: Definir el desembarco en Coral y la vuelta
[ ] T-139-077: Definir el costo del viaje (ticket AO bajo)
[ ] T-139-078: Definir qué se puede llevar (inventario completo)
[ ] T-139-079: Definir la vista del océano como anzuelo de curiosidad (M51/M152)
[ ] T-139-080: Definir la cámara del Gran Vapor (M12)
[ ] T-139-081: Definir el audio de travesía (olas, gaviotas, música) (M42/M41)
[ ] T-139-082: Asegurar que el viaje no sea repetitivo (variante de diálogo del tripulante)
[ ] T-139-083: Definir los assets de Aurora: árboles, rocas, edificios, NPC, flora (M45/M46/M47)
[ ] T-139-084: Definir el flujo: modelo → import normalizado → materiales/texturas → prefab → biblioteca
[ ] T-139-085: Definir convenciones de importación: nombres, unidades, collision, bounds
[ ] T-139-086: Definir el validador de assets en CI (frame budget, LOD, naming)
[ ] T-139-087: Asegurar que el 100% de los assets de fase pasa por el pipeline (sin atajos)
[ ] T-139-088: Definir LOD y culling por zona desde el día 1 (M61/M63)
[ ] T-139-089: Definir presupuesto de draw calls por zona (M61)
[ ] T-139-090: Definir compresión de texturas del bioma (M47)
[ ] T-139-091: Definir el rolling backlog de assets (familia por semana)
[ ] T-139-092: Documentar los assets heredados del slice y su reimport
[ ] T-139-093: Definir versionado de schema (M60)
[ ] T-139-094: Definir escritura transaccional (temp + rename)
[ ] T-139-095: Definir verificación de integridad al continuar (M66)
[ ] T-139-096: Definir recuperación con copia alternativa
[ ] T-139-097: Definir carga < 2 s en 20/20 ciclos
[ ] T-139-098: Definir el menú principal: continuar/nuevo/ajustes/créditos
[ ] T-139-099: Definir deshabilitado de UI durante cargas (regla sección 8 AGENTS.md)
[ ] T-139-100: Definir pantalla de carga con barra y mensajes de estado
[ ] T-139-101: Definir el flujo "nuevo juego" con confirmación de sobrescritura
[ ] T-139-102: Definir navegación de menú con gamepad y teclado (M57/M58)
[ ] T-139-103: Definir el tutorial visual sin texto de la fase (M92)
[ ] T-139-104: Definir buses: Music, Ambient, SFX, ASMR, UI
[ ] T-139-105: Definir transiciones de música por zona y estado (día/noche, lluvia)
[ ] T-139-106: Definir el ambiente por sector (puerto, bosque, templo, faro)
[ ] T-139-107: Definir eventos de SFX por interacción (M43)
[ ] T-139-108: Definir eventos ASMR de recolección y venta (M44)
[ ] T-139-109: Definir el audio UI (menús, confirmaciones)
[ ] T-139-110: Definir la música del templo con tensión suave
[ ] T-139-111: Definir la persistencia de niveles de volumen
[ ] T-139-112: Definir dashboards locales para playtest (M114)
[ ] T-139-113: Aplicar frame budget por categoría a cada zona nueva
[ ] T-139-114: Definir presupuesto de memoria 1.5 GB con streaming (M62)
[ ] T-139-115: Definir el gate de zona: falla CI si no cumple presupuesto
[ ] T-139-116: Definir telemetría de sesión local sin envío remoto (M104/M105)
[ ] T-139-117: Definir playtest de fase: 2-4 h con 5+ testers (M114)
[ ] T-139-118: Definir la encuesta de sesión (M114)
[ ] T-139-119: Definir criterio ≥ 80% "quería seguir jugando"
[ ] T-139-120: Definir medición de distancia de streaming y pops (M63)
[ ] T-139-121: Definir los 10 hits H1-H10 con criterios verificables
[ ] T-139-122: Definir la revisión DoD antes de declarar completada la fase (sección 12 AGENTS.md)
[ ] T-139-123: Definir el documento GONOGO firmado con fecha
[ ] T-139-124: Definir los riesgos residuales que pasan a Alpha
[ ] T-139-125: Definir la mano derecha de continuidad para M140 (qué se entrega)
[ ] T-139-126: Definir el registro de learning de la fase (qué se corrigió)
[ ] T-139-127: Asegurar 0 errores en consola al entrar en Play Mode (regla sección 12)
[ ] T-139-128: Asegurar flujo completo verificado en Play Mode antes de cerrar (sección 12)
[ ] T-139-129: Documentar el coste de la fase (tiempo real vs estimado)
[ ] T-139-130: Documentar el inventario de bugs conocidos y clasificados (M101/M102)
