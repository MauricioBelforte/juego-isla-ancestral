# 05 — Checklist — M25: Ruinas (100/100)

**Modelo:** Deepseek V4 Flash
**Plataforma:** OpenCode
**Fecha:** 2026-08-17

## Kit modular

- [x] Definir el kit base de ≤ 40 piezas reutilizables [M]
- [x] Definir pivote en esquina inferior izquierda por pieza [S]
- [x] Definir snaps por cara en cada pieza [M]
- [x] Implementar validación de pivotes en Editor [M]
- [x] Implementar validación de snaps en Editor [M]
- [x] Implementar validación de traslapes en Editor [M]
- [x] Implementar fallo de build si la validación falla [S]
- [x] Definir grupo de suelos (losa, rota, intermedia, umbral) [S]
- [x] Definir grupo de muros (recto, esquina, roto, vano, alto) [S]
- [x] Definir grupo de aperturas (arco, puerta, ventana, pasaje) [S]
- [x] Definir grupo de soportes (columna, pilar roto, contrafuerte) [S]
- [x] Definir grupo de techos (a 2 aguas, plano, crestería) [S]
- [x] Definir grupo de escaleras (recta, L, rampa) [S]
- [x] Definir grupo de decoración (balaustrada, cornisa, estela, altar, banco) [S]
- [x] Definir grupo de canal (canal de agua, compuerta seca) [S]
- [x] Documentar el kit modular en el plan-actual [S]

## Ruinas pequeñas y medianas

- [x] Diseñar chozas/ermitas (3-5 piezas, 1 puzzle Exploración) [S]
- [x] Diseñar caseríos (8-15 piezas, 1-2 puzzles Ritual) [M]
- [x] Diseñar atalayas con vista de bioma [S]
- [x] Definir 2-4 ruinas por bioma [S]
- [x] Documentar ruinas pequeñas y medianas [S]

## Ruinas grandes y templos

- [x] Diseñar templos con plan en cruz [M]
- [x] Definir vestíbulo y sancta del templo [S]
- [x] Definir 1 puzzle de luz obligatorio por templo (M24) [S]
- [x] Diseñar fortines medianos [S]
- [x] Diseñar templos/fortines grandes (25-60 piezas) [M]
- [x] Definir 2-3 puzzles + 1 multilateral en templos grandes [M]
- [x] Documentar ruinas grandes y templos [S]

## Ciudades antiguas

- [x] Diseñar ciudades antiguas en 3-5 bloques urbanos [M]
- [x] Definir calles perimetrales jugables [S]
- [x] Definir plaza central con acueducto [S]
- [x] Definir 1 puzzle central en la plaza [S]
- [x] Documentar ciudades antiguas [S]

## Observatorios, estaciones, faros y puentes

- [x] Diseñar observatorio con domo y agujero cenital [S]
- [x] Definir anillos de piedra con alineación solar (M31) [M]
- [x] Diseñar estaciones como amarre de vehículos (M66) [S]
- [x] Diseñar faro con haz fisicalizable (luz M24) [M]
- [x] Definir linterna de memoria en el faro (narrativa M22) [S]
- [x] Diseñar puente de arco con validación estructural [S]
- [x] Diseñar puente colgante de 3 cables [S]
- [x] Documentar observatorios, estaciones, faros y puentes [S]

## Jardines, edificios, bibliotecas y talleres

- [x] Diseñar jardines en terrazas con canales de agua [M]
- [x] Definir puzzle de agua suave en el jardín (M24) [S]
- [x] Diseñar edificios abandonados de 2 plantas [S]
- [x] Definir balcón roto del edificio [S]
- [x] Definir interiores solo donde necesarios [S]
- [x] Diseñar biblioteca como cofre de lore [S]
- [x] Definir mural del mapa en la biblioteca [S]
- [x] Diseñar taller con hornos y yunques rotos [S]
- [x] Definir clues de herramientas del inventario (M24) [S]
- [x] Documentar jardines, edificios, bibliotecas y talleres [S]

## Cámaras secretas y pasajes ocultos

- [x] Diseñar cámaras secretas bajo placas/estatuas [M]
- [x] Definir 2+ caminos de acceso a cada cámara (M66) [M]
- [x] Diseñar pasajes ocultos tras puertas falsas [S]
- [x] Definir pista ambiental para pasajes (viento M32) [S]
- [x] Diseñar soterrados en ruinas grandes [S]
- [x] Documentar cámaras secretas y pasajes ocultos [S]

## Murales, inscripciones y objetos arqueológicos

- [x] Diseñar 12 murales icónicos de la civilización [M]
- [x] Definir 3 épocas en los murales [S]
- [x] Definir registro de murales en el diario [S]
- [x] Diseñar 30-60 glifos de inscripciones [M]
- [x] Definir catálogo/glosario de glifos para M24 [M]
- [x] Diseñar 25 objetos arqueológicos [M]
- [x] Definir 3 estados del objeto (enterrado→expuesto→museo) [M]
- [x] Definir copia única de cada objeto (M66 cofre) [M]
- [x] Documentar murales, inscripciones y objetos [S]

## Sistemas de activación

- [x] Diseñar palanca (cerrojo de puerta) [S]
- [x] Diseñar anillo giratorio (sello de cámara) [S]
- [x] Diseñar estrella giradora (puerta de templo) [S]
- [x] Diseñar llave-runa (inscripción que bebe glifo) [S]
- [x] Diseñar timón de agua (compuertas) [S]
- [x] Diseñar martillo de piedra (percutir pedestal) [S]
- [x] Diseñar vela triple (orden de velas) [S]
- [x] Diseñar puerta falsa (rodar a cámara) [S]
- [x] Definir anclaje de activadores al framework M24 [M]
- [x] Documentar sistemas de activación [S]

## Progresión de descubrimiento

- [x] Definir estados: NoDescubierta → Descubierta → Explorada → Completada [M]
- [x] Implementar detección de descubrimiento a 15 m [S]
- [x] Implementar hint de horizonte al descubrir (M63) [S]
- [x] Implementar transición a Explorada al 50% de puzzles [M]
- [x] Implementar transición a Completada con relicto guardado [M]
- [x] Implementar eventos de transición (diario, mapa M58, museo M36) [M]
- [x] Implementar guardado atómico en cada transición [M]
- [x] Implementar persistencia del estado por ruina [M]
- [x] Documentar la progresión de descubrimiento [S]

## Variantes y conexiones entre ruinas

- [x] Definir 3 paletas visuales (época temprana/media/tardía) [S]
- [x] Implementar variantes de paleta sin geometría nueva [M]
- [x] Definir 2-3 configuraciones de puzzle por ruina grande (seed) [M]
- [x] Implementar variante de puzzle por seed de partida [M]
- [x] Diseñar caminos de 2-4 tramos entre ruinas [M]
- [x] Definir nodos de conexión con M28 (caminos) [M]
- [x] Definir validación de caminos con NavigationServer3D [M]
- [x] Diseñar conexión costera por faros y puentes [S]
- [x] Documentar variantes y conexiones [S]

## Integración y presupuestos

- [x] Integrar con M24 (puzzles y framework emisor→receptor) [M]
- [x] Integrar con M26 (templo subterráneo, sin rozar) [S]
- [x] Integrar con M28 (caminos) [M]
- [x] Integrar con M31 (alineación solar en observatorios) [S]
- [x] Integrar con M32 (viento/lluvia en pasajes y jardines) [S]
- [x] Integrar con M36 (museo: vitrinas para objetos) [M]
- [x] Integrar con M45/M47 (kit de referencia para assets) [M]
- [x] Implementar LOD 0-2 vía M63 (culling por región) [M]
- [x] Implementar sin Update por ruina (estática) [S]
- [x] Implementar sin costos de simulación en ruinas [S]
- [x] Documentar integración y presupuestos [S]

## Testings y documentación

- [x] Diseñar 06-Plan-Testings.md: validación del kit (pivotes/snaps) [M]
- [x] Diseñar 06-Plan-Testings.md: armado de los 13 tipos [M]
- [x] Diseñar 06-Plan-Testings.md: progresión de descubrimiento [M]
- [x] Diseñar 06-Plan-Testings.md: edge cases (ruina sin puzzle, cofre) [M]
- [x] Diseñar 06-Plan-Testings.md: pruebas de rendimiento (LOD) [M]
- [x] Definir criterio de éxito: suite completa pasa sin fallos [S]
- [x] Crear 07-Resultados-Testings.md para registrar la ejecución [S]
- [x] Documentar todas las decisiones en 02-Analisis y 03-Diseno [M]
- [x] Actualizar plan-actual como espejo del estado real [M]
- [x] Crear Log en Logs/ con formato NN-DESCRIPCION_FECHA [S]
- [x] Actualizar fila 25 en CHECKLIST-GLOBAL al implementar [S]

**Total:** 100/100 [x] — Módulo listo como **DELEGABLE PARA IMPLEMENTAR**.